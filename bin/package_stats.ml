open Switch_builder

let () =
  let ocaml_name = "ocaml.4.14.0" in
  let dune_name = "dune.3.6.1" in
  let ppxlib_name = "ppxlib.0.28.0" in
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
  let compatible_with_latest_ocaml =
    Select.(
      apply repo
        [ is_compatible_with (OpamPackage.of_string ocaml_name) ]
        latest)
  in
  let compatible_with_latest_dune =
    Select.(
      apply repo
        [ is_compatible_with (OpamPackage.of_string dune_name) ]
        compatible_with_latest_ocaml)
  in
  let compatible_with_latest_ppxlib =
    Select.(
      apply repo
        [ is_compatible_with (OpamPackage.of_string ppxlib_name) ]
        compatible_with_latest_dune)
  in
  let builds_with_dune =
    OpamPackage.Set.filter
      (fun p -> Repository.read_opam repo p |> Helpers.depends_on_dune)
      compatible_with_latest_ppxlib
  in
  print_endline
    (Printf.sprintf "There are %d packages in total."
       (OpamPackage.Set.cardinal latest));
  print_endline
    (Printf.sprintf "Of them, %d of them are compatible with %s."
       (OpamPackage.Set.cardinal compatible_with_latest_ocaml)
       ocaml_name);
  print_endline
    (Printf.sprintf "Of them, %d are compatible with %s."
       (OpamPackage.Set.cardinal compatible_with_latest_dune)
       dune_name);
  print_endline
    (Printf.sprintf "Of them, %d are compatible with %s."
       (OpamPackage.Set.cardinal compatible_with_latest_ppxlib)
       ppxlib_name);
  print_endline
    (Printf.sprintf "Of them, %d depend on dune."
       (OpamPackage.Set.cardinal builds_with_dune))
