open Switch_builder

val cached_repo_with_overlay : unit -> Repository.t
val assumed_deps : OpamPackage.Name.Set.t

val select_packages :
  arch:string -> allow_depexts:bool -> Repository.t -> OpamPackage.Set.t

val mkenv : OpamPackage.t -> OpamFilter.env
val depends_on_dune : OpamFile.OPAM.t -> bool

val large_closed_package_set :
  arch:string -> allow_depexts:bool -> Repository.t -> OpamPackage.Set.t

val find_conflict :
  OpamPackage.t list -> repo:Repository.t -> OpamPackage.t option

val shrink_to_dependency_closure :
  assumed_deps:OpamPackage.Name.Set.t ->
  Repository.t ->
  OpamPackage.Set.t ->
  OpamPackage.Set.t

type unmet_dependencies = {
  had_missing_deps : (OpamPackage.t * OpamPackage.Name.t) list;
  had_incompatible_version_deps : (OpamPackage.t * OpamPackage.Name.t) list;
}

val remove_unmet_dependencies :
  OpamPackage.t list ->
  repo:Repository.t ->
  assumed_deps:OpamPackage.Name.Set.t ->
  OpamPackage.Set.t * unmet_dependencies

val dependency_names :
  repo:Repository.t -> OpamPackage.t -> OpamPackage.Name.t list
