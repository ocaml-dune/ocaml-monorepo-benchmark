module File_to_change = struct
  type t = {
    path : string;
    original_text : string;
    new_text : string;
    error_text : string;
    fix_error_text : string;
  }

  let write_text { path; _ } text = Text_file.write ~path ~data:text

  let undo_change { path; original_text; _ } =
    Text_file.write ~path ~data:original_text
end

module Watch_mode_file = struct
  type t = { file_to_change : File_to_change.t; name : string }
end

module Watch_mode_files = struct
  type t = { base : Watch_mode_file.t; file_path : Watch_mode_file.t }

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
      let error_text =
        Re.replace_string
          (Re.Posix.re "let to_list t = t" |> Re.compile)
          ~by:"let to_list t = print_endline \"hello; t" original_text
      in
      let fix_error_text =
        Re.replace_string
          (Re.Posix.re "let to_list t = t" |> Re.compile)
          ~by:"let to_list t = print_endline \"hello\"; t" original_text
      in
      {
        Watch_mode_file.file_to_change =
          {
            File_to_change.path;
            original_text;
            new_text;
            error_text;
            fix_error_text;
          };
        name = "'base' library";
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
      let error_text =
        Re.replace_string
          (Re.Posix.re "let root = of_absolute Absolute.root" |> Re.compile)
          ~by:"let root = print_endline \"hello; of_absolute Absolute.root"
          original_text
      in
      let fix_error_text =
        Re.replace_string
          (Re.Posix.re "let root = of_absolute Absolute.root" |> Re.compile)
          ~by:"let root = print_endline \"hello\"; of_absolute Absolute.root"
          original_text
      in
      {
        Watch_mode_file.file_to_change =
          {
            File_to_change.path;
            original_text;
            new_text;
            error_text;
            fix_error_text;
          };
        name = "'file_path' library";
      }
    in
    { base; file_path }

  let undo_all t =
    List.iter
      (fun scenario ->
        File_to_change.undo_change scenario.Watch_mode_file.file_to_change)
      (all t)
end

module Watch_mode_scenarios = struct
  type change = [ `Benign_change | `Introduce_error | `Fix_error ]

  let change_verb = function
    | `Benign_change -> "changing"
    | `Introduce_error -> "introducing error in"
    | `Fix_error -> "fixing error in"

  type t = {
    files : Watch_mode_files.t;
    schedule : (Watch_mode_file.t * change) list;
  }

  let init ~duniverse_dir =
    let files = Watch_mode_files.init ~duniverse_dir in
    let schedule =
      List.concat_map
        (fun f ->
          [ (f, `Benign_change); (f, `Introduce_error); (f, `Fix_error) ])
        (Watch_mode_files.all files)
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
    (watch_mode_file : Watch_mode_file.t) change_type =
  let open Lwt.Syntax in
  let file_to_change = watch_mode_file.file_to_change in
  let verb = Watch_mode_scenarios.change_verb change_type in
  let text, expected_status =
    match change_type with
    | `Benign_change ->
        (file_to_change.new_text, Build_complete_stream.Status.Success)
    | `Introduce_error -> (file_to_change.error_text, Failed)
    | `Fix_error -> (file_to_change.fix_error_text, Success)
  in
  let name =
    Printf.sprintf "watch mode: %s file in %s" verb watch_mode_file.name
  in
  Logs.info (fun m -> m "starting scenario: \"%s\"" name);
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
  |> Lwt_list.map_s (fun _ ->
         Lwt.finalize
           (fun () ->
             Lwt_list.map_s
               (fun (watch_mode_file, change_type) ->
                 make_change_and_wait_for_rebuild build_complete_stream
                   watch_mode_file change_type)
               t.watch_mode_scenarios.schedule)
           (fun () ->
             undo_all_changes t;
             Lwt.return_unit))
  >|= List.concat
