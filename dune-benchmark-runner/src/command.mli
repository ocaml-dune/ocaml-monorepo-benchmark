type t

val create : string -> string list -> t
val to_string : t -> string

module Exit_status : sig
  type t = int
end

module Running : sig
  type t

  val wait_exn : t -> Exit_status.t
  val term : t -> unit
end

module Stdio_redirect : sig
  type t = [ `This_process | `Ignore ]
end

val run_background : t -> stdio_redirect:Stdio_redirect.t -> Running.t
val run_blocking_exn : t -> stdio_redirect:Stdio_redirect.t -> Exit_status.t
val run_blocking_stdout_string : t -> string
