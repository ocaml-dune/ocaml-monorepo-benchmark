type t = {
  dune_exe_path : string;
  build_target : string;
  monorepo_path : string;
  skip_clean : bool;
  skip_one_shot : bool;
  print_dune_output : bool;
  num_short_job_repeats : int;
}

val parse : unit -> t
