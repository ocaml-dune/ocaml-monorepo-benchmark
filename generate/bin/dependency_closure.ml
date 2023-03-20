(* Prints out a list of package names (including version numbers) which is
   closed under dependency, co-installable, and where each package can be built
   with dune. *)

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  let arch =
    if Array.length Sys.argv < 2 then failwith "missing arch"
    else Array.get Sys.argv 1
  in
  let set = Helpers.Policy.large_closed_package_set ~arch in
  print_endline
    (OpamPackage.Set.elements set |> Helpers.Packages.to_string_pretty)
