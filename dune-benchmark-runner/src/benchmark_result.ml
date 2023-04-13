type t = { name : string; duration_secs : float }

let to_current_bench_metric { name; duration_secs } =
  let assoc =
    [
      ("name", `String name);
      ("value", `Float duration_secs);
      ("units", `String "sec");
    ]
  in
  `Assoc assoc

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

let list_to_current_bench_json ts =
  List.map to_current_bench_metric ts |> current_bench_json_of_metrics
