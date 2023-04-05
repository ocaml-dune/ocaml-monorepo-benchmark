type t

val create : dune_exe_path:string -> workspace_root:string -> t
val clean : t -> unit

module Watch_mode : sig
  type t

  val stop : t -> unit
  val build_count : t -> int
  val wait_for_nth_build : t -> int -> unit
  val workspace_root : t -> string
end

val watch_mode_start : t -> Watch_mode.t
