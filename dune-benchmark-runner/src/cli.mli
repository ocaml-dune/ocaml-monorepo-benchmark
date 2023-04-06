type t = { dune_exe_path : string; monorepo_path : string; skip_clean : bool }

val parse : unit -> t
