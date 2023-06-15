type t
(** an instance of dune in a workspace *)

val create : dune_exe_path:string -> workspace_root:string -> t

val clean : t -> unit
(** runs `dune clean` in the workspace (blocking) *)

val build :
  t -> build_target:string -> stdio_redirect:Command.Stdio_redirect.t -> unit
(** runs `dune build <build_target>` in the workspace (blocking) *)

val with_build_complete_stream_in_watch_mode :
  t ->
  build_target:string ->
  stdio_redirect:Command.Stdio_redirect.t ->
  f:(Build_complete_stream.t -> 'a Lwt.t) ->
  ('a * [ `Initial_build_benchmark_result of Benchmark_result.t ]) Lwt.t
(** Starts dune in eager watch mode, waits for the initial build to complete,
    then calls [f] on a [Build_complete_stream.t] connected to dune in watch
    mode (this stream will receive events indicating that a build has
    complete either successfully or unsuccessfully). The value returned by
    [f] is eventually returned by this function along with a benchmark result
    representing the time it took for the initial build to complete. Note
    that this is not necessarily a clean build (e.g. if `dune build` had
    already been run in this workspace it will be a null build). After [f]
    returns, the watch mode instance of dune is terminated. *)
