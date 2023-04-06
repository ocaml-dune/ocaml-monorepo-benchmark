module String_arg_req = struct
  type t = { value : string option ref; opt : string; desc : string }

  let create opt desc = { value = ref None; opt; desc }

  let spec { value; opt; desc } =
    (opt, Arg.String (fun x -> value := Some x), desc)

  let get { value; opt; _ } =
    match !value with
    | Some x -> x
    | None -> failwith (Printf.sprintf "Missing required argument %s" opt)
end

type t = { dune_exe_path : string; monorepo_path : string; skip_clean : bool }

let parse () =
  let dune_exe_path =
    String_arg_req.create "--dune-exe-path"
      "Path to dune executable to benchmark"
  in
  let monorepo_path =
    String_arg_req.create "--monorepo-path"
      "Path to monorepo to build during benchmark"
  in
  let skip_clean = ref false in
  let specs =
    [ dune_exe_path; monorepo_path ]
    |> List.map String_arg_req.spec
    |> List.append
         [
           ( "--skip-clean",
             Arg.Set skip_clean,
             "don't run `dune clean` before starting dune" );
         ]
  in
  Arg.parse specs
    (fun anon_arg ->
      failwith (Printf.sprintf "unexpected anonymous argument: %s" anon_arg))
    "Perform benchmarks building the monorepo with dune";
  {
    dune_exe_path = String_arg_req.get dune_exe_path;
    monorepo_path = String_arg_req.get monorepo_path;
    skip_clean = !skip_clean;
  }
