let () =
  let packages =
    In_channel.input_all In_channel.stdin |> Helpers.Packages.of_string
  in
  let dune_string =
    Printf.sprintf "(executable\n (name dummy)\n (libraries %s))"
      (packages
      |> List.map (fun p -> OpamPackage.name p |> OpamPackage.Name.to_string)
      |> String.concat " ")
  in
  print_endline dune_string
