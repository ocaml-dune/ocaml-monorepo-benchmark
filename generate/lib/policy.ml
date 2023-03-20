open Switch_builder

let mkenv package =
  Env.common
  |> Env.extend "os" (OpamVariable.S "linux")
  |> Env.extend "os-version" (OpamVariable.S "22.04")
  |> Env.extend "os-distribution" (OpamVariable.S "ubuntu")
  |> Env.extend "ocaml-system:version" (OpamVariable.S "4.14.0")
  |> Env.extend "ocaml-base-compiler:version" (OpamVariable.S "4.14.0")
  |> Env.extend "ocaml-variants:version" (OpamVariable.S "4.14.0")
  |> Env.extend "version"
       (OpamVariable.S
          (OpamPackage.version package |> OpamPackage.Version.to_string))
  |> Env.extend "with-test" (OpamVariable.bool false)

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

let depends_on_dune opam =
  let deps =
    OpamFormula.ors [ OpamFile.OPAM.depends opam; OpamFile.OPAM.depopts opam ]
  in
  let dep_name_list =
    OpamFormula.fold_left (fun xs (x, _) -> x :: xs) [] deps
  in
  List.exists
    (fun p ->
      let s = OpamPackage.Name.to_string p in
      String.equal s "dune")
    dep_name_list

let has_no_build_commands opam =
  match OpamFile.OPAM.build opam with [] -> true | _ -> false

let has_no_source opam = OpamFile.OPAM.dev_repo opam |> Option.is_none

let has_depexts opam =
  match OpamFile.OPAM.depexts opam with [] -> false | _ -> true

let is_available opam ~arch =
  let package = OpamFile.OPAM.package opam in
  let available = OpamFile.OPAM.available opam in
  let env = mkenv package |> Env.extend "arch" (OpamVariable.S arch) in
  OpamFilter.eval_to_bool env available

let select_packages ~arch repo =
  let packages = Repository.packages repo in
  let latest =
    Version_policy.(
      apply
        (always_latest
        |> override (OpamPackage.of_string "ocaml-config.2")
        |> override (OpamPackage.of_string "data-encoding.0.6")
        |> override (OpamPackage.of_string "ringo.0.9")
        |> override (OpamPackage.of_string "ocamlfind.1.8.1+dune")
        |> override (OpamPackage.of_string "libtorch.1.13.0+linux-x86_64")
        |> override (OpamPackage.of_string "libwasmtime.0.22.0+linux-x86_64")
        |> override (OpamPackage.of_string "ocaml.4.14.1")
        |> override (OpamPackage.of_string "ocaml-base-compiler.4.14.1")
        (* downgrade some packages for better compatibility *)
        |> override (OpamPackage.of_string "ppxlib.0.28.0")
        |> override (OpamPackage.of_string "eigen.0.3.3")))
      packages
  in
  let required_compatible =
    let open Supported_versions in
    [ ocaml; dune; ppxlib ]
  in
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
                 OpamPackage.Name.of_string "yojson-bench";
                 (* collides with ocp-indent *)
                 OpamPackage.Name.of_string "ocp-indent-nlfork";
                 (* no build command so it looks like a conf package but isn't *)
                 OpamPackage.Name.of_string "xml-light";
               ];
             exclude_package_prefix "ocaml-option-";
             exclude_package_prefix "ocaml-options-";
           ])
      latest)
  |> OpamPackage.Set.filter (fun package ->
         let opam = Repository.read_opam repo package in
         let builds_with_dune =
           depends_on_dune opam || has_no_build_commands opam
           || has_no_source opam
         in
         let is_conf =
           String.starts_with ~prefix:"conf-"
             (OpamPackage.name_to_string package)
         in
         let available = is_available opam ~arch in
         let _no_depexts = not (has_depexts opam) in
         if not (builds_with_dune || is_conf) then
           Logs.info (fun m ->
               m "Removed %s (doesn't build with dune and is not conf)"
                 (OpamPackage.to_string package));
         if not available then
           Logs.info (fun m ->
               m "Removed %s (not available on this system)"
                 (OpamPackage.to_string package));
         (builds_with_dune || is_conf) && available)

let cached_repo_with_overlay () =
  let opam_repo = Repository.path "./data/repos/opam-repository" in
  let opam_overlays = Repository.path "./data/repos/opam-overlays" in
  let combined_repo = Repository.combine opam_repo opam_overlays in
  let cache = Repository.Cache.create () in
  let cached_repo = Repository.cache cache combined_repo in
  cached_repo

let check_conflict opam ~packages_by_name =
  let package = OpamFile.OPAM.package opam in
  let env = mkenv package in
  let conflicts_formula =
    OpamFile.OPAM.conflicts opam |> OpamFilter.filter_formula env
  in
  let res =
    Eval.m
      (fun (name, version_formula) ->
        match OpamPackage.Name.Map.find_opt name packages_by_name with
        | None -> Ok ()
        | Some pkg_in_set ->
            let version = OpamPackage.version pkg_in_set in
            let version_matches_formula =
              OpamFormula.check_version_formula version_formula version
            in
            if version_matches_formula then Error pkg_in_set else Ok ())
      conflicts_formula
  in
  match res with Ok () -> None | Error p -> Some p

let find_conflict packages ~repo =
  let packages_by_name =
    packages
    |> List.map (fun pkg -> (OpamPackage.name pkg, pkg))
    |> OpamPackage.Name.Map.of_list
  in
  List.find_opt
    (fun package ->
      let opam = Repository.read_opam repo package in
      check_conflict opam ~packages_by_name |> Option.is_some)
    packages

let package_incompatible opam ~packages_by_name ~assumed_deps =
  let package = OpamFile.OPAM.package opam in
  if
    OpamPackage.name package |> OpamPackage.Name.to_string
    |> String.equal "ocaml"
  then None
  else
    let env = mkenv package in
    let deps = OpamFile.OPAM.depends opam |> OpamFilter.filter_formula env in
    let res =
      Eval.m
        (fun (name, version_formula) ->
          if OpamPackage.Name.Set.mem name assumed_deps then Ok ()
          else
            match OpamPackage.Name.Map.find_opt name packages_by_name with
            | None -> Error (`Missing (name, version_formula))
            | Some dep ->
                let dep_version = OpamPackage.version dep in
                let has_compatible_dep =
                  OpamFormula.check_version_formula version_formula dep_version
                in
                if has_compatible_dep then Ok ()
                else Error (`Incompatible_version (name, version_formula)))
        deps
    in
    match res with Ok () -> None | Error e -> Some e

type unmet_dependencies = {
  had_missing_deps : (OpamPackage.t * OpamPackage.Name.t) list;
  had_incompatible_version_deps : (OpamPackage.t * OpamPackage.Name.t) list;
}

let remove_unmet_dependencies packages ~repo ~assumed_deps =
  let packages_by_name =
    packages
    |> List.map (fun pkg -> (OpamPackage.name pkg, pkg))
    |> OpamPackage.Name.Map.of_list
  in
  let init =
    ( OpamPackage.Set.of_list packages,
      { had_missing_deps = []; had_incompatible_version_deps = [] } )
  in
  List.fold_left
    (fun ((packages, { had_missing_deps; had_incompatible_version_deps }) as
         acc) package ->
      let opam = Repository.read_opam repo package in
      match package_incompatible opam ~packages_by_name ~assumed_deps with
      | None -> acc
      | Some (`Missing (missing_dep, _)) ->
          ( OpamPackage.Set.remove package packages,
            {
              had_missing_deps = (package, missing_dep) :: had_missing_deps;
              had_incompatible_version_deps;
            } )
      | Some (`Incompatible_version (missing_dep, _)) ->
          ( OpamPackage.Set.remove package packages,
            {
              had_missing_deps;
              had_incompatible_version_deps =
                (package, missing_dep) :: had_incompatible_version_deps;
            } ))
    init packages

let shrink_step ~assumed_deps repo packages =
  let without_conflict =
    find_conflict (OpamPackage.Set.elements packages) ~repo |> function
    | None -> packages
    | Some p ->
        Logs.info (fun m ->
            m "Removed due to conflict: %s" (OpamPackage.to_string p));
        OpamPackage.Set.remove p packages
  in
  let ( with_unmet_deps_removed,
        ({ had_missing_deps; had_incompatible_version_deps } :
          unmet_dependencies) ) =
    remove_unmet_dependencies
      (OpamPackage.Set.elements without_conflict)
      ~repo ~assumed_deps
  in
  Logs.info (fun m ->
      m "After removing packages with unmet deps there are %d packages"
        (OpamPackage.Set.cardinal with_unmet_deps_removed));
  List.iter
    (fun (package, dep_name) ->
      Logs.info (fun m ->
          m "Removed %s (lacks dependency %s)"
            (OpamPackage.to_string package)
            (OpamPackage.Name.to_string dep_name)))
    had_missing_deps;
  List.iter
    (fun (package, dep_name) ->
      Logs.info (fun m ->
          m "Removed %s (no compatible version of dependency %s)"
            (OpamPackage.to_string package)
            (OpamPackage.Name.to_string dep_name)))
    had_incompatible_version_deps;
  with_unmet_deps_removed

let shrink_to_dependency_closure ~assumed_deps repo =
  Import.fixpoint ~equal:OpamPackage.Set.equal
    ~f:(shrink_step ~assumed_deps repo)

let large_closed_package_set ~arch =
  let repo = cached_repo_with_overlay () in
  let latest_filtered = select_packages ~arch repo in
  Logs.info (fun m ->
      m "Starting with set of %d packages..."
        (OpamPackage.Set.cardinal latest_filtered));
  shrink_to_dependency_closure ~assumed_deps repo latest_filtered
