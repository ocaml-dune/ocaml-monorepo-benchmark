type t

val start : unit -> t
val time_since_start_secs : t -> float

val measure_secs : (unit -> unit) -> float
(** [measure_secs f] calls [f] and returns the time it took to run in seconds *)
