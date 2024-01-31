open Watch_mode_file_to_change

(* Add more watch mode benchmarks by adding to this list. *)
let scenarios =
  [
    {
      name = "'base' library";
      path_relative_to_duniverse = "base/src/list.ml";
      text_to_replace = "let to_list t = t";
      text_changed_valid = "let to_list t = print_endline \"hello\"; t";
      text_changed_invalid = "let to_list t = print_endline \"hello; t";
    };
    {
      name = "'file_path' library";
      path_relative_to_duniverse = "file_path/src/path.ml";
      text_to_replace = "let root = of_absolute Absolute.root";
      text_changed_valid =
        "let root = print_endline \"hello\"; of_absolute Absolute.root";
      text_changed_invalid =
        "let root = print_endline \"hello; of_absolute Absolute.root";
    };
  ]
