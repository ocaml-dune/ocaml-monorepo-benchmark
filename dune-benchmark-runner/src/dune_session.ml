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

let with_build_complete_stream_in_watch_mode t ~build_target ~stdio_redirect ~f
    =
  let open Lwt.Syntax in
  Logs.info (fun m -> m "starting dune in watch mode");
  let running =
    make_command t [ "build"; build_target; "-j"; "auto"; "--watch" ]
    |> Command.run_background ~stdio_redirect
  in
  Lwt.finalize
    (fun () ->
      Build_complete_stream.with_stream ~workspace_root:t.workspace_root
        ~f:(fun build_complete_stream ->
          Logs.info (fun m -> m "waiting for initial watch mode build");
          let timer = Timer.start () in
          let* status =
            Build_complete_stream.wait_for_next_build_complete
              build_complete_stream
          in
          let initial_build_duration_secs = Timer.time_since_start_secs timer in
          let initial_build_benchmark_result =
            {
              Benchmark_result.name = "watch mode: initial build";
              duration_secs = initial_build_duration_secs;
            }
          in
          Build_complete_stream.Status.assert_equal ~expected:Success
            ~actual:status;
          Logs.info (fun m ->
              m "initial watch mode build complete in %f secs"
                initial_build_duration_secs);
          let+ output = f build_complete_stream in
          ( output,
            `Initial_build_benchmark_result initial_build_benchmark_result )))
    (fun () ->
      Logs.info (fun m -> m "stopping watch mode");
      Command.Running.term running;
      Lwt.return_unit)
