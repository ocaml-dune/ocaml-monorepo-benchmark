type t

val create : dune_exe_path:string -> workspace_root:string -> t
val clean : t -> unit

val build :
  t -> build_target:string -> stdio_redirect:Command.Stdio_redirect.t -> unit

module Trace_file : sig
  type t

  val durations_micros_in_order : t -> int list
end

val with_build_complete_stream_in_watch_mode :
  t ->
  build_target:string ->
  stdio_redirect:Command.Stdio_redirect.t ->
  f:(Build_complete_stream.t -> unit Lwt.t) ->
  Trace_file.t Lwt.t
