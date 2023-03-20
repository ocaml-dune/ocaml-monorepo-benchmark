module Policy = Policy
module Supported_versions = Supported_versions

val pkg_set_to_opam_file : OpamPackage.Set.t -> OpamFile.OPAM.t
val write_opam_file : OpamFile.OPAM.t -> path:string -> unit
val packages_to_opam_file_string : OpamPackage.t list -> string
val write_string_file : string -> path:string -> unit

module Packages : sig
  type t = OpamPackage.t list

  val of_string : string -> t
  val to_string_pretty : t -> string
end
