type t

module Status : sig
  type t = Success | Failed

  val assert_equal : expected:t -> actual:t -> unit
end

val with_stream : workspace_root:string -> f:(t -> 'a Lwt.t) -> 'a Lwt.t
val wait_for_next_build_complete : t -> Status.t Lwt.t
