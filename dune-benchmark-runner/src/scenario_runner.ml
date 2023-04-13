module Watch_mode = Dune_session.Watch_mode

module File_to_change = struct
  type t = { path : string; original_text : string; new_text : string }

  let make_change { path; new_text; _ } = Text_file.write ~path ~data:new_text

  let undo_change { path; original_text; _ } =
    Text_file.write ~path ~data:original_text
end

module Watch_mode_scenario = struct
  type t = { file_to_change : File_to_change.t; description : string }
end

module Watch_mode_scenarios = struct
  type t = { base : Watch_mode_scenario.t; file_path : Watch_mode_scenario.t }

  let all { base; file_path } = [ base; file_path ]

  let init ~duniverse_dir =
    let base =
      let path = Printf.sprintf "%s/base/src/list.ml" duniverse_dir in
      let original_text = Text_file.read ~path in
      let new_text =
        Re.replace_string
          (Re.Posix.re "let to_list t = t" |> Re.compile)
          ~by:"let to_list t = print_endline \"hi\"; t" original_text
      in
      {
        Watch_mode_scenario.file_to_change =
          { File_to_change.path; original_text; new_text };
        description =
          "watch mode: change a file in the base library and wait for rebuild";
      }
    in
    let file_path =
      let path = Printf.sprintf "%s/file_path/src/path.ml" duniverse_dir in
      let original_text = Text_file.read ~path in
      let new_text =
        Re.replace_string
          (Re.Posix.re "let root = of_absolute Absolute.root" |> Re.compile)
          ~by:"let root = print_endline \"hi\"; of_absolute Absolute.root"
          original_text
      in
      {
        Watch_mode_scenario.file_to_change =
          { File_to_change.path; original_text; new_text };
        description =
          "watch mode: change a file in the file_path library and wait for \
           rebuild";
      }
    in
    { base; file_path }

  let undo_all t =
    List.iter
      (fun scenario ->
        File_to_change.undo_change scenario.Watch_mode_scenario.file_to_change)
      (all t)
end

type t = { watch_mode_scenarios : Watch_mode_scenarios.t }

let create ~monorepo_path =
  let watch_mode_scenarios =
    let duniverse_dir = Printf.sprintf "%s/duniverse" monorepo_path in
    Watch_mode_scenarios.init ~duniverse_dir
  in
  { watch_mode_scenarios }

let make_change_and_wait_for_rebuild watch_mode file_to_change =
  let build_count_before = Watch_mode.build_count watch_mode in
  Logs.info (fun m -> m "changing %s" file_to_change.File_to_change.path);
  File_to_change.make_change file_to_change;
  Logs.info (fun m -> m "waiting for rebuild");
  Watch_mode.wait_for_nth_build watch_mode (build_count_before + 1);
  Logs.info (fun m -> m "rebuild complete")

let run_watch_mode_scenarios t ~dune_watch_mode =
  Watch_mode_scenarios.all t.watch_mode_scenarios
  |> List.iter (fun scenario ->
         make_change_and_wait_for_rebuild dune_watch_mode
           scenario.Watch_mode_scenario.file_to_change)

let undo_all_changes t =
  Logs.info (fun m -> m "undoing changes to files");
  Watch_mode_scenarios.undo_all t.watch_mode_scenarios

let convert_durations_into_benchmark_results t durations_in_order =
  let watch_mode_scenario_descriptions =
    Watch_mode_scenarios.all t.watch_mode_scenarios
    |> List.map (fun scenario -> scenario.Watch_mode_scenario.description)
  in
  let watch_mode_scenario_descriptions_including_initial_build =
    "watch mode: initial build" :: watch_mode_scenario_descriptions
  in
  if
    List.length watch_mode_scenario_descriptions_including_initial_build
    <> List.length durations_in_order
  then failwith "unexpected number of durations";
  List.combine watch_mode_scenario_descriptions_including_initial_build
    durations_in_order
  |> List.map (fun (name, duration_micros) ->
         {
           Benchmark_result.name;
           duration_secs = float_of_int duration_micros /. 1_000_000.0;
         })
