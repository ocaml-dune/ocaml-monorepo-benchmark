type t = { name : string; duration_secs : float }

let current_bench_json_of_metrics metrics =
  `Assoc
    [
      ( "results",
        `List
          [
            `Assoc
              [
                ("name", `String "dune monorepo benchmarks");
                ("metrics", `List metrics);
              ];
          ] );
    ]

module String = struct
  include String
  module Map = Map.Make (String)
end

module List = struct
  include List

  (* remove n elements from the start of xs *)
  let rec drop n xs =
    if n <= 0 then xs else match xs with [] -> [] | _ :: xs -> drop (n - 1) xs

  (* remove all but the first n elements from xs *)
  let rec take n xs =
    if n <= 0 then []
    else match xs with [] -> [] | x :: xs -> x :: take (n - 1) xs

  (* remove n elements from the end of xs *)
  let drop_back n xs = take (List.length xs - n) xs
end

module Group = struct
  type benchmark_result = t
  type t = { name : string; durations_secs : float list }

  let list_of_benchmark_results benchmark_results =
    List.fold_left
      (fun acc { name; duration_secs } ->
        String.Map.update name
          (function
            | None -> Some [ duration_secs ]
            | Some durations_secs -> Some (duration_secs :: durations_secs))
          acc)
      String.Map.empty benchmark_results
    |> String.Map.bindings
    |> List.map (fun (name, durations_secs) -> { name; durations_secs })

  let remove_outliers t ~num_outliers_to_remove =
    if List.length t.durations_secs == 1 then t
    else
      let sorted_durations = List.sort Float.compare t.durations_secs in
      let durations_without_outliers =
        List.drop num_outliers_to_remove sorted_durations
        |> List.drop_back num_outliers_to_remove
      in
      { t with durations_secs = durations_without_outliers }

  let to_current_bench_metric { name; durations_secs } =
    let assoc =
      [
        ("name", `String name);
        ( "value",
          `List
            (List.map
               (fun duration_secs -> `Float duration_secs)
               durations_secs) );
        ("units", `String "sec");
      ]
    in
    `Assoc assoc

  let list_to_current_bench_json ts =
    List.map to_current_bench_metric ts |> current_bench_json_of_metrics
end
