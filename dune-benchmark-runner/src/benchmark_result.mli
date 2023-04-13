type t = { name : string; duration_secs : float }

val list_to_current_bench_json : t list -> Yojson.t
