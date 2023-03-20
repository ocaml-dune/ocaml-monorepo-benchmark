module Policy = Policy
module Supported_versions = Supported_versions

let pkg_to_filtered_formula pkg : OpamTypes.filtered_formula =
  let name = OpamPackage.name pkg in
  let version = OpamPackage.version pkg in
  Atom
    ( name,
      Atom (Constraint (`Eq, FString (OpamPackage.Version.to_string version)))
    )

let pkg_set_to_filtered_formula pkg_set : OpamTypes.filtered_formula =
  OpamPackage.Set.elements pkg_set
  |> List.map pkg_to_filtered_formula
  |> OpamFormula.ands

let pkg_set_to_opam_file pkg_set =
  OpamFile.OPAM.empty
  |> OpamFile.OPAM.with_depends (pkg_set_to_filtered_formula pkg_set)

let packages_to_opam_file_string packages =
  pkg_set_to_opam_file (OpamPackage.Set.of_list packages)
  |> OpamFile.OPAM.write_to_string

let write_string_file string ~path =
  let f =
    Unix.openfile path [ Unix.O_RDWR; Unix.O_TRUNC; Unix.O_CREAT ] 0o666
  in
  let _ = Unix.write_substring f string 0 (String.length string) in
  Unix.close f

let write_opam_file opam ~path =
  let opam_file_string = OpamFile.OPAM.write_to_string opam in
  write_string_file opam_file_string ~path

module Packages = struct
  open Sexplib.Std
  module Sexp = Sexplib.Sexp

  module Package = struct
    type t = OpamPackage.t

    let t_of_sexp = function
      | Sexp.Atom atom -> OpamPackage.of_string atom
      | other ->
          failwith (Printf.sprintf "failed to parse: %s" (Sexp.to_string other))
  end

  type t = Package.t list [@@deriving of_sexp]

  let to_string_pretty t =
    List.map OpamPackage.to_string t |> String.concat "\n"

  let of_string s = Sexp.of_string s |> t_of_sexp
end
