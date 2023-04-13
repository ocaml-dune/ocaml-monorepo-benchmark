let measure_secs f =
  let before = Unix.gettimeofday () in
  f ();
  let after = Unix.gettimeofday () in
  after -. before
