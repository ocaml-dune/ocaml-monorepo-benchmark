let () =
  let { Cli.dune_exe_path; monorepo_path; skip_clean; print_watch_mode_stdout }
      =
    Cli.parse ()
  in
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  let dune_session =
    Dune_session.create ~dune_exe_path ~workspace_root:monorepo_path
  in
  if not skip_clean then Dune_session.clean dune_session;
  let dune_watch_mode =
    Dune_session.watch_mode_start dune_session
      ~stdio_redirect:
        (if print_watch_mode_stdout then `This_process else `Ignore)
  in
  let scenario_runner = Scenario_runner.create ~monorepo_path in
  Scenario_runner.run_watch_mode_scenarios ~dune_watch_mode scenario_runner;
  let trace_file = Dune_session.Watch_mode.stop dune_watch_mode in
  Scenario_runner.undo_all_changes scenario_runner;
  let durations_micros_in_order =
    Dune_session.Trace_file.durations_micros_in_order trace_file
  in
  let current_bench_json_string =
    Scenario_runner.convert_durations_into_current_bench_json scenario_runner
      durations_micros_in_order
  in
  print_endline (Yojson.pretty_to_string current_bench_json_string)
