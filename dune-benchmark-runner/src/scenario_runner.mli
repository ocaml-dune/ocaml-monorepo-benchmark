type t

val create : monorepo_path:string -> t

val run_watch_mode_scenarios :
  t -> dune_watch_mode:Dune_session.Watch_mode.t -> unit

val undo_all_changes : t -> unit
val convert_durations_into_current_bench_json : t -> int list -> Yojson.t
