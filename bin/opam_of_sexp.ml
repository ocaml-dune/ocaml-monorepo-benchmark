let () =
  let packages =
    In_channel.input_all In_channel.stdin |> Helpers.Packages.of_string
  in
  let opam_file_string = Helpers.packages_to_opam_file_string packages in
  print_endline opam_file_string
