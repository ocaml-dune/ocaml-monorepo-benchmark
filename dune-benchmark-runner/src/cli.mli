type t = {
  dune_exe_path : string;
  monorepo_path : string;
  skip_clean : bool;
  print_watch_mode_stdout : bool;
}

val parse : unit -> t
