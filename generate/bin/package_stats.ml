(* Prints out info about the number of packages compatible with the versions of
   ocabml, dune, and ppxlib, and which list dune as a dependency. This is the
   upper bound on the number of packages that can go into the monorepo. *)

open Switch_builder
module Supported_versions = Helpers.Supported_versions

let () =
  let repo = Helpers.Policy.cached_repo_with_overlay () in
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
        [ is_compatible_with (OpamPackage.of_string Supported_versions.ocaml) ]
        latest)
  in
  let compatible_with_latest_dune =
    Select.(
      apply repo
        [ is_compatible_with (OpamPackage.of_string Supported_versions.dune) ]
        compatible_with_latest_ocaml)
  in
  let compatible_with_latest_ppxlib =
    Select.(
      apply repo
        [ is_compatible_with (OpamPackage.of_string Supported_versions.ppxlib) ]
        compatible_with_latest_dune)
  in
  let builds_with_dune =
    OpamPackage.Set.filter
      (fun p -> Repository.read_opam repo p |> Helpers.Policy.depends_on_dune)
      compatible_with_latest_ppxlib
  in
  print_endline
    (Printf.sprintf "There are %d packages in total."
       (OpamPackage.Set.cardinal latest));
  print_endline
    (Printf.sprintf "Of them, %d of them are compatible with %s."
       (OpamPackage.Set.cardinal compatible_with_latest_ocaml)
       Supported_versions.ocaml);
  print_endline
    (Printf.sprintf "Of them, %d are compatible with %s."
       (OpamPackage.Set.cardinal compatible_with_latest_dune)
       Supported_versions.dune);
  print_endline
    (Printf.sprintf "Of them, %d are compatible with %s."
       (OpamPackage.Set.cardinal compatible_with_latest_ppxlib)
       Supported_versions.ppxlib);
  print_endline
    (Printf.sprintf "Of them, %d depend on dune."
       (OpamPackage.Set.cardinal builds_with_dune))
