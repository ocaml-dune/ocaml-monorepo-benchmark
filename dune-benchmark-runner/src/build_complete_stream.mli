type t
(** A stream of events indicating that dune has completed a build successfully
    or unsuccessfully while running in watch mode *)

module Status : sig
  type t = Success | Failed

  val assert_equal : expected:t -> actual:t -> unit
  (** Raises an exception if the expected and actual statuses are different *)
end

val with_ : workspace_root:string -> f:(t -> 'a Lwt.t) -> 'a Lwt.t
(** Connects to a dune RPC server running in a given workspace (dune in watch
    mode) and calls [f] on a stream of build completion events. Note that the
    first build completion in the stream will represent the initial build which
    occurs when watch mode is started. This will happen regardless of whether
    this function ([with_]) is called during the initial build or after it
    completes, eliminating the race condition between completing the initial
    watch mode build and creating the event stream. *)

val wait_for_next_build_complete : t -> Status.t Lwt.t
(** Waits until the next build completes then returns the status of the build *)
