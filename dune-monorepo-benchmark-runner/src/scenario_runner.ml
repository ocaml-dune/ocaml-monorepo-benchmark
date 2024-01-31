module File_to_change = struct
  type t = {
    name : string;
    path : string;
    original_text : string;
    new_text : string;
    error_text : string;
  }

  let write_text { path; _ } text = Text_file.write ~path ~data:text

  let undo_change { path; original_text; _ } =
    Text_file.write ~path ~data:original_text

  let of_watch_file_to_change ~duniverse_dir
      {
        Watch_mode_file_to_change.name;
        path_relative_to_duniverse;
        text_to_replace;
        text_changed_valid;
        text_changed_invalid;
      } =
    let path =
      Printf.sprintf "%s/%s" duniverse_dir path_relative_to_duniverse
    in
    let original_text = Text_file.read ~path in
    let new_text =
      Re.replace_string
        (Re.Posix.re text_to_replace |> Re.compile)
        ~by:text_changed_valid original_text
    in
    let error_text =
      Re.replace_string
        (Re.Posix.re text_to_replace |> Re.compile)
        ~by:text_changed_invalid original_text
    in
    { name; path; original_text; new_text; error_text }
end

module Watch_mode_files = struct
  type t = File_to_change.t list

  let init ~duniverse_dir =
    List.map
      (File_to_change.of_watch_file_to_change ~duniverse_dir)
      Watch_mode_scenarios.scenarios

  let undo_all t =
    List.iter (fun scenario -> File_to_change.undo_change scenario) t
end

module Watch_mode_scenarios = struct
  type change = [ `Benign_change | `Introduce_error | `Fix_error ]

  let change_verb = function
    | `Benign_change -> "changing"
    | `Introduce_error -> "introducing error in"
    | `Fix_error -> "fixing error in"

  type t = {
    files : Watch_mode_files.t;
    schedule : (File_to_change.t * change) list;
  }

  let init ~duniverse_dir =
    let files = Watch_mode_files.init ~duniverse_dir in
    let schedule =
      List.concat_map
        (fun f ->
          [ (f, `Benign_change); (f, `Introduce_error); (f, `Fix_error) ])
        files
    in
    { files; schedule }
end

type t = { watch_mode_scenarios : Watch_mode_scenarios.t }

let create ~monorepo_path =
  let watch_mode_scenarios =
    let duniverse_dir = Printf.sprintf "%s/duniverse" monorepo_path in
    Watch_mode_scenarios.init ~duniverse_dir
  in
  { watch_mode_scenarios }

let make_change_and_wait_for_rebuild build_complete_stream
    (file_to_change : File_to_change.t) change_type iteration_count =
  let open Lwt.Syntax in
  let verb = Watch_mode_scenarios.change_verb change_type in
  let text, expected_status =
    match change_type with
    | `Benign_change ->
        (file_to_change.new_text, Build_complete_stream.Status.Success)
    | `Introduce_error -> (file_to_change.error_text, Failed)
    | `Fix_error -> (file_to_change.original_text, Success)
  in
  let name =
    Printf.sprintf "watch mode: %s file in %s" verb file_to_change.name
  in
  Logs.info (fun m ->
      m "starting scenario: \"%s\" (iteration %d)" name iteration_count);
  Logs.info (fun m -> m "%s %s" verb file_to_change.path);
  File_to_change.write_text file_to_change text;
  let timer = Timer.start () in
  Logs.info (fun m -> m "waiting for rebuild");
  let+ status =
    Build_complete_stream.wait_for_next_build_complete build_complete_stream
  in
  Build_complete_stream.Status.assert_equal ~expected:expected_status
    ~actual:status;
  let duration_secs = Timer.time_since_start_secs timer in
  Logs.info (fun m -> m "rebuild complete in %f secs" duration_secs);
  { Benchmark_result.name; duration_secs }

let undo_all_changes t =
  Logs.info (fun m -> m "undoing changes to files");
  Watch_mode_files.undo_all t.watch_mode_scenarios.files

let run_watch_mode_scenarios t ~build_complete_stream ~num_repeats =
  let open Lwt.Infix in
  List.init num_repeats Fun.id
  |> Lwt_list.map_s (fun i ->
         Lwt.finalize
           (fun () ->
             Lwt_list.map_s
               (fun (watch_mode_file, change_type) ->
                 make_change_and_wait_for_rebuild build_complete_stream
                   watch_mode_file change_type i)
               t.watch_mode_scenarios.schedule)
           (fun () ->
             undo_all_changes t;
             Lwt.return_unit))
  >|= List.concat
