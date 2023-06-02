type t = { name : string; duration_secs : float }

module Group : sig
  type benchmark_result = t
  type t

  val list_of_benchmark_results : benchmark_result list -> t list

  val remove_outliers : t -> num_outliers_to_remove:int -> t
  (** [remove_outliers t ~num_outliers_to_remove] removes
      [num_outliers_to_remove] outliers from both extremes of the group [t].
      That is, [2 * num_outliers_to_remove] values will be removed from the
      group by this function. *)

  val list_to_current_bench_json : t list -> Yojson.t
end
