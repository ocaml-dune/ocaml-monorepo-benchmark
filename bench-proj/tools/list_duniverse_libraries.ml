open Sexplib.Std
module Sexp = Sexplib.Sexp

module String = struct
  include String

  let chop_prefix s ~prefix =
    if String.starts_with s ~prefix then
      let pos = String.length prefix in
      let len = String.length s - pos in
      Some (String.sub s pos len)
    else None

  module Set = struct
    include Set.Make (String)

    let t_of_sexp sexp = list_of_sexp string_of_sexp sexp |> of_list
    let sexp_of_t t = elements t |> sexp_of_list sexp_of_string
  end
end

let dir_contents dir =
  Sys.readdir dir |> Array.to_list |> List.sort String.compare
  |> List.map (Filename.concat dir)

let is_normal_dir path =
  let ({ st_kind; _ } : Unix.stats) = Unix.lstat path in
  match st_kind with S_DIR -> true | _ -> false

let is_normal_file path =
  let ({ st_kind; _ } : Unix.stats) = Unix.lstat path in
  match st_kind with S_REG -> true | _ -> false

let rec list_files_recursive dir =
  dir_contents dir
  |> List.concat_map (fun path ->
         if is_normal_dir path then list_files_recursive path else [ path ])

let list_dune_files dir =
  list_files_recursive dir
  |> List.filter (fun filename ->
         is_normal_file filename
         && String.equal (Filename.basename filename) "dune")

let run_command_stdout command =
  let in_ = Unix.open_process_in command in
  let s = In_channel.input_all in_ in
  In_channel.close in_;
  s

let read_text_file path =
  let in_ = In_channel.open_text path in
  let s = In_channel.input_all in_ in
  In_channel.close in_;
  s

let resolve_dune_file ~dir_path ~rel_dune_file_path ~run_dune_ml =
  let abs_dune_file_path = Filename.concat dir_path rel_dune_file_path in
  let contents = read_text_file abs_dune_file_path in
  if String.starts_with ~prefix:"(* -*- tuareg -*- *)" contents then
    run_command_stdout
      (String.concat " " [ run_dune_ml; dir_path; rel_dune_file_path ])
  else contents

module Library = struct
  type t = { public_name : string; simple_deps : String.Set.t }
  [@@deriving sexp]
end

module Package = struct
  type t = { name : string; path : string; libraries : Library.t list }
  [@@deriving sexp]

  let library_public_names { libraries; _ } =
    List.map (fun (library : Library.t) -> library.public_name) libraries

  let _to_string_hum t = Sexp.to_string_hum (sexp_of_t t)
end

let parse_dune_string_all_public_libraries s =
  let sexps = Sexp.of_string_many s in
  List.filter_map
    (fun sexp ->
      match sexp with
      | Sexp.List (Sexp.Atom "library" :: fields) ->
          let public_name =
            List.find_map
              (function
                | Sexp.List [ Sexp.Atom "public_name"; Sexp.Atom public_name ]
                  ->
                    Some public_name
                | _ -> None)
              fields
          in
          Option.map
            (fun public_name ->
              let simple_deps =
                List.find_map
                  (function
                    | Sexp.List (Sexp.Atom " libraries" :: libraries) ->
                        Some
                          (List.filter_map
                             (function
                               | Sexp.Atom name -> Some name | _ -> None)
                             libraries)
                    | _ -> None)
                  fields
                |> Option.value ~default:[] |> String.Set.of_list
              in
              { Library.public_name; simple_deps })
            public_name
      | _ -> None)
    sexps

let is_library_valid_for_package_by_name ~library_name ~package_name =
  match String.equal library_name package_name with
  | true -> true
  | false -> (
      match String.chop_prefix library_name ~prefix:package_name with
      | None -> false
      | Some remainder -> String.starts_with remainder ~prefix:".")

let ignore_dune_file_by_path =
  let pattern = Re.Perl.re "dune_/test/blackbox-tests" |> Re.compile in
  fun path ->
    let matches = Re.matches pattern path in
    List.length matches > 0

let packages_in_dir dir ~run_dune_ml =
  let all_public_libraries =
    list_dune_files dir
    |> List.filter (Fun.negate ignore_dune_file_by_path)
    |> List.concat_map (fun dune_file_path ->
           let rel_dune_file_path =
             String.chop_prefix dune_file_path ~prefix:dir |> Option.get
           in
           let rel_dune_file_path =
             String.chop_prefix rel_dune_file_path ~prefix:"/"
             |> Option.value ~default:rel_dune_file_path
           in
           resolve_dune_file ~dir_path:dir ~rel_dune_file_path ~run_dune_ml
           |> parse_dune_string_all_public_libraries)
  in
  Sys.readdir dir |> Array.to_list
  |> List.filter (fun filename ->
         String.equal (Filename.extension filename) ".opam")
  |> List.map (fun filename ->
         let name = Filename.chop_extension filename in
         let path = dir in
         let libraries =
           List.filter
             (fun (library : Library.t) ->
               is_library_valid_for_package_by_name
                 ~library_name:library.public_name ~package_name:name)
             all_public_libraries
         in
         { Package.name; path; libraries })

let read_list path = read_text_file path |> String.split_on_char '\n'

let read_sexp_list path =
  read_text_file path |> Sexp.of_string |> list_of_sexp string_of_sexp

let read_package_names_from_package_list path =
  read_list path
  |> List.map (fun s -> String.split_on_char '.' s |> List.hd)
  |> String.Set.of_list

let () =
  match List.map (Array.get Sys.argv) [ 1; 2; 3; 4 ] with
  | [ duniverse_dir; packages_list_path; library_ignore_list_sexp; run_dune_ml ]
    ->
      let duniverse_subdirs =
        dir_contents duniverse_dir |> List.filter Sys.is_directory
      in
      let package_names =
        read_package_names_from_package_list packages_list_path
      in
      let libraries_to_ignore =
        read_sexp_list library_ignore_list_sexp |> String.Set.of_list
      in
      let all_libraries =
        List.concat_map
          (fun dir ->
            let packages =
              packages_in_dir dir ~run_dune_ml
              |> List.filter (fun (package : Package.t) ->
                     String.Set.mem package.name package_names)
            in
            List.concat_map
              (fun package -> Package.library_public_names package)
              packages)
          duniverse_subdirs
        |> List.filter
             (Fun.negate (fun library ->
                  String.Set.mem library libraries_to_ignore))
        |> String.Set.of_list |> String.Set.elements
      in
      print_endline
        (Printf.sprintf "(\n  %s\n)" (String.concat "\n  " all_libraries))
  | _ -> failwith "incorrect number of arguments"
