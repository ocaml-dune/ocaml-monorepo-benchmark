type t
(** A command that can be executed *)

val create : string -> string list -> t
val to_string : t -> string

module Exit_status : sig
  type t = int
end

module Running : sig
  type t
  (** Handle to a process running in the background *)

  val term : t -> unit
  (** Send the TERM signal ot the process. *)
end

module Stdio_redirect : sig
  type t = [ `This_process | `Ignore ]
  (** Controls whether the stdin, stdout and stderr of a process should be
      connected to the corresponding file descriptors of this process
      ([`This_process])or connected to /dev/null ([`Ignore]) *)
end

val run_background : t -> stdio_redirect:Stdio_redirect.t -> Running.t
(** Run a command in a background process, immediately returning a handle to
    the running process. *)

val run_blocking_exn : t -> stdio_redirect:Stdio_redirect.t -> Exit_status.t
(** Run a command in a new process, waiting for the process to exit before
    returning its exit status. *)
