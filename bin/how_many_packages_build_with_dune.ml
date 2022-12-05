open Switch_builder

let () =
  let repo = Helpers.cached_repo_with_overlay () in
  let packages = Repository.packages repo in
  let latest = Version_policy.(apply always_latest) packages in
  OpamPackage.Set.iter
    (fun p -> print_endline (Printf.sprintf "%s" (OpamPackage.to_string p)))
    latest
