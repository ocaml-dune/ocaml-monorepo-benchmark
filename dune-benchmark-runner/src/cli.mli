type t = {
  dune_exe_path : string;
  build_target : string;
  monorepo_path : string;
  skip_clean : bool;
  skip_one_shot : bool;
  print_dune_output : bool;
}

val parse : unit -> t
