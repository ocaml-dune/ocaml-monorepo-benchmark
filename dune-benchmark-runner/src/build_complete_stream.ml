module Rpc_client = struct
  let id = Dune_rpc.V1.Id.make (Csexp.Atom "ocaml-monorepo-benchmark-runner")
  let init = Dune_rpc.V1.Initialize.create ~id

  module Where = struct
    let of_workspace_root workspace_root =
      let build_dir = Printf.sprintf "%s/_build" workspace_root in
      Dune_rpc_lwt.V1.Where.default ~build_dir ()
  end

  module Chan = struct
    let try_connect where =
      Lwt_result.catch (Dune_rpc_lwt.V1.connect_chan where)

    let rec connect_retrying where =
      let open Lwt.Syntax in
      let* result = try_connect where in
      match result with
      | Ok chan ->
          Logs.info (fun m ->
              m "connected to RPC server (%s)"
                (Dune_rpc_private.Where.to_string where));
          Lwt.return chan
      | Error (e : exn) ->
          Logs.warn (fun m ->
              m "failed to connect to RPC server (%s): %s (retrying)"
                (Dune_rpc_private.Where.to_string where)
                (Printexc.to_string e));
          let* () = Lwt_unix.sleep 0.5 in
          connect_retrying where
  end

  let with_client ~workspace_root ~f =
    let open Lwt.Syntax in
    let* chan =
      Chan.connect_retrying (Where.of_workspace_root workspace_root)
    in
    Dune_rpc_lwt.V1.Client.connect chan init ~f

  let with_progress_stream ~workspace_root ~f =
    let open Lwt.Syntax in
    let open Lwt.Infix in
    with_client ~workspace_root ~f:(fun client ->
        let* dune_progress_stream =
          Dune_rpc_lwt.V1.Client.poll ~id client Dune_rpc.V1.Sub.progress
          >|= Result.get_ok
        in
        let lwt_stream =
          Lwt_stream.from (fun () ->
              Dune_rpc_lwt.V1.Client.Stream.next dune_progress_stream)
        in
        f lwt_stream)
end

type t = Dune_rpc.V1.Progress.t Lwt_stream.t

module Status = struct
  type t = Success | Failed

  let assert_equal ~expected ~actual =
    match (expected, actual) with
    | Success, Success | Failed, Failed -> ()
    | Success, Failed -> failwith "expected build to succeed but it failed"
    | Failed, Success -> failwith "expected build to fail but it succeeded"
end

let with_stream = Rpc_client.with_progress_stream

let dune_progress_to_status progress =
  match (progress : Dune_rpc.V1.Progress.t) with
  | Success -> Some Status.Success
  | Failed -> Some Failed
  | Interrupted | In_progress _ | Waiting -> None

let wait_for_next_build_complete_opt progress_stream =
  Lwt_stream.find_map dune_progress_to_status progress_stream

let wait_for_next_build_complete p =
  let open Lwt.Infix in
  wait_for_next_build_complete_opt p >|= Option.get
