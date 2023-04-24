type t = { start_time_secs : float }

let start () = { start_time_secs = Unix.gettimeofday () }

let time_since_start_secs { start_time_secs } =
  Unix.gettimeofday () -. start_time_secs

let measure_secs f =
  let timer = start () in
  f ();
  time_since_start_secs timer
