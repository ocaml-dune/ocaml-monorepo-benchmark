let () =
  let {
    Cli.dune_exe_path;
    build_target;
    monorepo_path;
    skip_clean;
    skip_one_shot;
    print_dune_output;
    num_short_job_repeats;
    include_watch_mode_initial_build;
  } =
    Cli.parse ()
  in
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  let stdio_redirect = if print_dune_output then `This_process else `Ignore in
  let dune_session =
    Dune_session.create ~dune_exe_path ~workspace_root:monorepo_path
  in
  if not skip_clean then (
    Logs.info (fun m -> m "Cleaning");
    Dune_session.clean dune_session);
  let measure_one_shot_build name =
    let duration_secs =
      Timer.measure_secs (fun () ->
          Dune_session.build dune_session ~build_target ~stdio_redirect)
    in
    { Benchmark_result.name; duration_secs }
  in
  let one_shot_benchmark_results =
    if skip_one_shot then []
    else (
      Logs.info (fun m -> m "Building from scratch");
      let build_from_scratch_benchmark_result =
        measure_one_shot_build "build from scratch"
      in
      Logs.info (fun m -> m "Rebuilding after making no changes");
      let null_build_benchmark_result =
        List.init num_short_job_repeats (fun _ ->
            measure_one_shot_build "null build")
      in
      build_from_scratch_benchmark_result :: null_build_benchmark_result)
  in
  let scenario_runner = Scenario_runner.create ~monorepo_path in
  let watch_mode_benchmark_results =
    Lwt_main.run
      (let open Lwt.Syntax in
      let+ ( watch_mode_benchmark_results,
             `Initial_build_benchmark_result
               watch_mode_initial_build_benchmark_result ) =
        Dune_session.with_build_complete_stream_in_watch_mode dune_session
          ~build_target ~stdio_redirect ~f:(fun build_complete_stream ->
            Scenario_runner.run_watch_mode_scenarios scenario_runner
              ~build_complete_stream ~num_repeats:num_short_job_repeats)
      in
      (if include_watch_mode_initial_build then
       [ watch_mode_initial_build_benchmark_result ]
      else [])
      @ watch_mode_benchmark_results)
  in
  let benchmark_results =
    one_shot_benchmark_results @ watch_mode_benchmark_results
  in
  print_endline
    (Yojson.pretty_to_string
       (Benchmark_result.list_to_current_bench_json benchmark_results))
