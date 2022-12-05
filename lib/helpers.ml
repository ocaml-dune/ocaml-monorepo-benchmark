open Switch_builder

let cached_repo_with_overlay () =
  let opam_repo = Repository.path "./data/repos/opam-repository" in
  let opam_overlays = Repository.path "./data/repos/opam-overlays" in
  let combined_repo = Repository.combine opam_repo opam_overlays in
  let cache = Repository.Cache.create () in
  let cached_repo = Repository.cache cache combined_repo in
  cached_repo
