type t = { dune_exe_path : string; workspace_root : string }

let create ~dune_exe_path ~workspace_root = { dune_exe_path; workspace_root }

let make_command t args =
  let all_args = List.append args [ "--root"; t.workspace_root ] in
  Command.create t.dune_exe_path all_args

let run_command_exn t args ~stdio_redirect =
  let command = make_command t args in
  match Command.run_blocking_exn ~stdio_redirect command with
  | 0 -> ()
  | other ->
      failwith
        (Printf.sprintf "command `%s` exited with unexpected status: %d"
           (Command.to_string command)
           other)

let clean t = run_command_exn t [ "clean" ] ~stdio_redirect:`Ignore

let build t ~build_target ~stdio_redirect =
  run_command_exn t [ "build"; build_target ] ~stdio_redirect

module Trace_file = struct
  type t = { path : string }

  let random () =
    Random.self_init ();
    let i = Random.int 10000 in
    let path = Printf.sprintf "/tmp/dune-trace-file.%04d.json" i in
    { path }

  let parse { path } = Yojson.Safe.from_file path

  let yojson_to_durations_micros_in_order yojson =
    let eager_watch_mode_build_complete_event_name =
      "eager_watch_mode_build_complete"
    in
    match yojson with
    | `List entries ->
        List.filter_map
          (function
            | `Assoc assoc ->
                Option.bind (List.assoc_opt "name" assoc) (function
                  | `String event_name
                    when String.equal event_name
                           eager_watch_mode_build_complete_event_name ->
                      Option.bind (List.assoc_opt "dur" assoc) (function
                        | `Int dur -> Some dur
                        | _ -> None)
                  | _ -> None)
            | _ -> failwith "unexpected structure")
          entries
    | _ -> failwith "unexpected  structure"

  let durations_micros_in_order t =
    parse t |> yojson_to_durations_micros_in_order
end

let with_build_complete_stream_in_watch_mode t ~build_target ~stdio_redirect ~f
    =
  let open Lwt.Syntax in
  let trace_file = Trace_file.random () in
  Logs.info (fun m -> m "starting dune in watch mode");
  Logs.info (fun m -> m "will store trace in %s" trace_file.path);
  let running =
    make_command t
      [
        "build";
        build_target;
        "-j";
        "auto";
        "--watch";
        "--trace-file";
        trace_file.path;
      ]
    |> Command.run_background ~stdio_redirect
  in
  let+ () =
    Lwt.finalize
      (fun () ->
        Build_complete_stream.with_stream ~workspace_root:t.workspace_root
          ~f:(fun build_complete_stream ->
            Logs.info (fun m -> m "waiting for initial build");
            let* status =
              Build_complete_stream.wait_for_next_build_complete
                build_complete_stream
            in
            Build_complete_stream.Status.assert_equal ~expected:Success
              ~actual:status;
            f build_complete_stream))
      (fun () ->
        Logs.info (fun m -> m "stopping watch mode");
        Command.Running.term running;
        Lwt.return_unit)
  in
  trace_file
