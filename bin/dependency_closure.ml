open Switch_builder

let shrink_step ~assumed_deps repo packages =
  let without_conflict =
    Helpers.find_conflict
      (OpamPackage.Set.elements packages |> Helpers.shuffle)
      ~repo
    |> function
    | None -> packages
    | Some p ->
        print_endline
          (Printf.sprintf "Removed due to conflict: %s"
             (OpamPackage.to_string p));
        OpamPackage.Set.remove p packages
  in
  let with_unmet_deps_removed, _ =
    Helpers.remove_unmet_dependencies
      (OpamPackage.Set.elements without_conflict |> Helpers.shuffle)
      ~repo ~assumed_deps
  in
  print_endline
    (Printf.sprintf
       "After removing packages with unmet deps there are %d packages"
       (OpamPackage.Set.cardinal with_unmet_deps_removed));
  with_unmet_deps_removed

let shrink_fixpoint ~assumed_deps repo =
  Import.fixpoint ~equal:OpamPackage.Set.equal
    ~f:(shrink_step ~assumed_deps repo)

let () =
  let repo = Helpers.cached_repo_with_overlay () in
  let packages = Repository.packages repo in
  let latest =
    Version_policy.(
      apply
        (always_latest
        |> override (OpamPackage.of_string "ocamlfind.1.8.1+dune")
        |> override (OpamPackage.of_string "ocaml.4.14.0")
        |> override (OpamPackage.of_string "ocaml-base-compiler.4.14.0")))
      packages
  in
  let required_compatible = [ "ocaml.4.14.0"; "dune.3.6.0"; "ppxlib.0.28.0" ] in
  let latest_filtered =
    Select.(
      apply repo
        (List.map
           (fun name -> is_compatible_with (OpamPackage.of_string name))
           required_compatible
        |> List.append
             [
               exclude_package_names
                 [
                   OpamPackage.Name.of_string "ocaml-variants";
                   OpamPackage.Name.of_string "winsvc";
                   OpamPackage.Name.of_string "ocamlog";
                   OpamPackage.Name.of_string "nlfork";
                 ];
             ])
        latest)
    |> OpamPackage.Set.filter (fun package ->
           let opam = Repository.read_opam repo package in
           Helpers.depends_on_dune opam || Helpers.has_no_build_commands opam)
  in
  print_endline
    (Printf.sprintf "Starting with set of %d packages..."
       (OpamPackage.Set.cardinal latest_filtered));
  let assumed_deps =
    OpamPackage.Name.Set.of_list
      (List.map OpamPackage.Name.of_string
         [
           "base-bigarray";
           "base-threads";
           "base-unix";
           "dune";
           "ocaml";
           "ocaml-base-compiler";
           "ocaml-config";
           "ocaml-options-vanilla";
         ])
  in
  (* Random.set_state (Random.State.make_self_init ()); *)
  let shrunk = shrink_fixpoint ~assumed_deps repo latest_filtered in
  print_endline
    (Printf.sprintf "final package count: %d" (OpamPackage.Set.cardinal shrunk));
  let output_path =
    if Array.length Sys.argv < 2 then failwith "missing output file"
    else Array.get Sys.argv 1
  in
  let opam_file = Helpers.pkg_set_to_opam_file shrunk in
  Helpers.write_opam_file opam_file output_path;
  print_endline (Printf.sprintf "Written opam file to: %s" output_path)
