type t
(** Knows how to perform a sequence of benchmarking scenarios on a monorepo *)

val create : monorepo_path:string -> t
(** Creates a benchmarking scenario runner that will perform benchmarks in a
    given directory (but does not run the benchmarks). This function requires
    that [monorepo_path] refer to a directory containing subdirectories
    directories "duniverse/base" and "duniverse/file_path" which contain the
    source code for the "base" and "file_path" opam packages respectively
    (otherwise an exception will be raised). *)

val run_watch_mode_scenarios :
  t ->
  build_complete_stream:Build_complete_stream.t ->
  num_repeats:int ->
  Benchmark_result.t list Lwt.t
(** Run all the benchmarking scenarios. Scenarios will make modifications to
    some of the files under the workspace root used to construct [t] in order
    to exercise dune in file-watching mode, though this function will attempt
    to clean up after itself and leave the monorepo in the same state it was in
    before this function was called. This function returns a list of benchmark
    results with an element for each benchmarking scenario. *)
