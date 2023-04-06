let of_name_durations_micros_assoc_list name_durations_micros_assoc_list =
  let metrics =
    List.map
      (fun (name, duration_micros) ->
        let duration_secs = float_of_int duration_micros /. 1_000_000.0 in
        let assoc =
          [
            ("name", `String name);
            ("value", `Float duration_secs);
            ("units", `String "sec");
          ]
        in
        `Assoc assoc)
      name_durations_micros_assoc_list
  in
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
