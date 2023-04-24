type t

val start : unit -> t
val time_since_start_secs : t -> float
val measure_secs : (unit -> unit) -> float
