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

module Benchmark_result_group = struct
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

let list_to_current_bench_json ts =
  Benchmark_result_group.(
    list_of_benchmark_results ts |> list_to_current_bench_json)
