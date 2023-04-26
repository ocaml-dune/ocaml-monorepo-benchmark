(* Prints out a list of package names (including version numbers) which is
   closed under dependency, co-installable, and where each package can be built
   with dune. *)

module Args = struct
  type t = { arch : string; allow_depexts : bool }

  let parse () =
    let arch = ref "x86_64" in
    let allow_depexts = ref false in
    let specs =
      [
        ("--arch", Arg.Set_string arch, "architecture to target");
        ( "--allow-depexts",
          Arg.Set allow_depexts,
          "include packages with external dependencies" );
      ]
    in
    Arg.parse specs
      (fun _ -> failwith "unexpected anonymous argument")
      "print out a list of packages to include in monorepo";
    { arch = !arch; allow_depexts = !allow_depexts }
end

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  let { Args.arch; allow_depexts } = Args.parse () in
  let repo = Helpers.Policy.cached_repo_with_overlay () in
  let set = Helpers.Policy.large_closed_package_set ~arch ~allow_depexts repo in
  print_endline
    (OpamPackage.Set.elements set |> Helpers.Packages.to_string_pretty)
