type t

val create : dune_exe_path:string -> workspace_root:string -> t
val clean : t -> unit

val build :
  t -> build_target:string -> stdio_redirect:Command.Stdio_redirect.t -> unit

val with_build_complete_stream_in_watch_mode :
  t ->
  build_target:string ->
  stdio_redirect:Command.Stdio_redirect.t ->
  f:(Build_complete_stream.t -> 'a Lwt.t) ->
  ('a * [ `Initial_build_benchmark_result of Benchmark_result.t ]) Lwt.t
