open Switch_builder

let shrink_step ~assumed_deps repo packages =
  let without_conflict =
    Helpers.find_conflict (OpamPackage.Set.elements packages) ~repo |> function
    | None -> packages
    | Some p ->
        Printf.eprintf "Removed due to conflict: %s\n" (OpamPackage.to_string p);
        OpamPackage.Set.remove p packages
  in
  let ( with_unmet_deps_removed,
        ({ had_missing_deps; had_incompatible_version_deps } :
          Helpers.unmep_dependencies) ) =
    Helpers.remove_unmet_dependencies
      (OpamPackage.Set.elements without_conflict)
      ~repo ~assumed_deps
  in
  Printf.eprintf
    "After removing packages with unmet deps there are %d packages\n"
    (OpamPackage.Set.cardinal with_unmet_deps_removed);
  List.iter
    (fun (package, dep_name) ->
      Printf.eprintf "Removed %s (lacks dependency %s)\n"
        (OpamPackage.to_string package)
        (OpamPackage.Name.to_string dep_name))
    had_missing_deps;
  List.iter
    (fun (package, dep_name) ->
      Printf.eprintf "Removed %s (no compatible version of dependency %s)\n"
        (OpamPackage.to_string package)
        (OpamPackage.Name.to_string dep_name))
    had_incompatible_version_deps;

  with_unmet_deps_removed

let shrink_fixpoint ~assumed_deps repo =
  Import.fixpoint ~equal:OpamPackage.Set.equal
    ~f:(shrink_step ~assumed_deps repo)

let () =
  let arch =
    if Array.length Sys.argv < 2 then failwith "missing arch"
    else Array.get Sys.argv 1
  in
  let repo = Helpers.cached_repo_with_overlay () in
  let packages = Repository.packages repo in
  let latest =
    Version_policy.(
      apply
        (always_latest
        |> override (OpamPackage.of_string "ocaml-config.2")
        |> override (OpamPackage.of_string "data-encoding.0.6")
        |> override (OpamPackage.of_string "ringo.0.9")
        |> override (OpamPackage.of_string "hacl-star.0.4.2+dune")
        |> override (OpamPackage.of_string "hacl-star-raw.0.4.2+dune")
        |> override (OpamPackage.of_string "ocamlfind.1.8.1+dune")
        |> override (OpamPackage.of_string "bisect_ppx.2.8.1+fixed")
        |> override (OpamPackage.of_string "libtorch.1.13.0+linux-x86_64")
        |> override (OpamPackage.of_string "libwasmtime.0.22.0+linux-x86_64")
        |> override (OpamPackage.of_string "ocaml.4.14.0")
        |> override (OpamPackage.of_string "ocaml-base-compiler.4.14.0")))
      packages
  in
  let required_compatible = [ "ocaml.4.14.0"; "dune.3.6.1"; "ppxlib.0.28.0" ] in
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
                   OpamPackage.Name.of_string "ocaml-beta";
                   OpamPackage.Name.of_string "base-domains";
                   OpamPackage.Name.of_string "base-nnp";
                   OpamPackage.Name.of_string "winsvc";
                   OpamPackage.Name.of_string "ocamlog";
                   OpamPackage.Name.of_string "nlfork";
                   OpamPackage.Name.of_string "ocp-indent";
                   OpamPackage.Name.of_string "scfg";
                   OpamPackage.Name.of_string "yojson-bench";
                   OpamPackage.Name.of_string "xml-light";
                   OpamPackage.Name.of_string "sedlex";
                 ];
               exclude_package_prefix "ocaml-option-";
               exclude_package_prefix "ocaml-options-";
             ])
        latest)
    |> OpamPackage.Set.filter (fun package ->
           let opam = Repository.read_opam repo package in
           let builds_with_dune =
             Helpers.depends_on_dune opam
             || Helpers.has_no_build_commands opam
             || Helpers.has_no_source opam
           in
           let available = Helpers.is_available opam ~arch in
           let _no_depexts = not (Helpers.has_depexts opam) in
           if not builds_with_dune then
             Printf.eprintf "Removed %s (doesn't build with dune)\n"
               (OpamPackage.to_string package);
           if not available then
             Printf.eprintf "Removed %s (not available on this system)\n"
               (OpamPackage.to_string package);
           (*if not no_depexts then
             Printf.eprintf "Removed %s (has depexts)\n"
               (OpamPackage.to_string package); *)
           builds_with_dune && available)
  in
  Printf.eprintf "Starting with set of %d packages...\n"
    (OpamPackage.Set.cardinal latest_filtered);
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
           "core_unix";
           "ocamlbuild";
         ])
  in
  let shrunk = shrink_fixpoint ~assumed_deps repo latest_filtered in
  print_endline
    (OpamPackage.Set.elements shrunk |> Helpers.Packages.to_string_pretty)
