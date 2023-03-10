module Libraries = struct
  open Sexplib.Std
  module Sexp = Sexplib.Sexp

  type t = string list [@@deriving sexp]

  let of_string s = Sexp.of_string s |> t_of_sexp
end

let () =
  let libraries =
    In_channel.input_all In_channel.stdin |> Libraries.of_string
  in
  let dune_string =
    Printf.sprintf "(executable\n (name hello)\n (libraries \n  %s\n))"
      (String.concat "\n  " libraries)
  in
  print_endline dune_string
