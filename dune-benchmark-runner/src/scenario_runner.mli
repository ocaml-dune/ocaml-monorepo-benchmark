type t

val create : monorepo_path:string -> t

val run_watch_mode_scenarios :
  t ->
  build_complete_stream:Build_complete_stream.t ->
  Benchmark_result.t list Lwt.t

val undo_all_changes : t -> unit

val convert_durations_into_benchmark_results :
  t -> int list -> Benchmark_result.t list
