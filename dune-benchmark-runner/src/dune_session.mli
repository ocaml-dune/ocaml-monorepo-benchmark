type t

val create : dune_exe_path:string -> workspace_root:string -> t
val clean : t -> unit

val build :
  t -> build_target:string -> stdio_redirect:Command.Stdio_redirect.t -> unit

module Trace_file : sig
  type t

  val durations_micros_in_order : t -> int list
end

val with_rpc_client_in_watch_mode :
  t ->
  build_target:string ->
  stdio_redirect:Command.Stdio_redirect.t ->
  f:(Dune_rpc_client.t -> unit Lwt.t) ->
  Trace_file.t Lwt.t
(** Starts dune in watch mode and waits for the first build to complete, then
  calls [f] on an RPC client connected to the RPC server inside dune *)
