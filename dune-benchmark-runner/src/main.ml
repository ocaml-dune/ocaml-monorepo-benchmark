let () =
  let { Cli.dune_exe_path; monorepo_path } = Cli.parse () in
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  let dune_session =
    Dune_session.create ~dune_exe_path ~workspace_root:monorepo_path
  in
  Dune_session.clean dune_session;
  let dune_watch_mode = Dune_session.watch_mode_start dune_session in
  let scenario_runner = Scenario_runner.create ~monorepo_path in
  Scenario_runner.run_watch_mode_scenarios ~dune_watch_mode scenario_runner;
  Dune_session.Watch_mode.stop dune_watch_mode;
  Scenario_runner.undo_all_changes scenario_runner
