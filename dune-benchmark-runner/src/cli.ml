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

type t = {
  dune_exe_path : string;
  build_target : string;
  monorepo_path : string;
  skip_clean : bool;
  skip_one_shot : bool;
  print_dune_output : bool;
  num_short_job_repeats : int;
  include_watch_mode_initial_build : bool;
}

let parse () =
  let dune_exe_path =
    String_arg_req.create "--dune-exe-path"
      "Path to dune executable to benchmark"
  in
  let build_target =
    String_arg_req.create "--build-target" "Anonymous argument to `dune build`"
  in
  let monorepo_path =
    String_arg_req.create "--monorepo-path"
      "Path to monorepo to build during benchmark"
  in
  let skip_clean = ref false in
  let skip_one_shot = ref false in
  let print_dune_output = ref false in
  let num_short_job_repeats = ref 1 in
  let include_watch_mode_initial_build = ref false in
  let specs =
    [ dune_exe_path; build_target; monorepo_path ]
    |> List.map String_arg_req.spec
    |> List.append
         [
           ( "--skip-clean",
             Arg.Set skip_clean,
             "don't run `dune clean` before starting dune" );
           ( "--skip-one-shot",
             Arg.Set skip_one_shot,
             "don't run one shot benchmarks (to save time debugging watch mode \
              benchmarks)" );
           ( "--print-dune-output",
             Arg.Set print_dune_output,
             "display the stdandard output of dune when it is run in watch \
              mode (for debugging)" );
           ( "--num-short-job-repeats",
             Arg.Set_int num_short_job_repeats,
             "number of times to repeat short benchmarking jobs (all jobs \
              other than the initial build)" );
           ( "--include-watch-mode-initial-build",
             Arg.Set include_watch_mode_initial_build,
             "include the benchmark for the initial watch-mode build (excluded \
              by default as it's similar to the null build benchmark but can't \
              be run multiple times to reduce noise)" );
         ]
  in
  Arg.parse specs
    (fun anon_arg ->
      failwith (Printf.sprintf "unexpected anonymous argument: %s" anon_arg))
    "Perform benchmarks building the monorepo with dune";
  {
    dune_exe_path = String_arg_req.get dune_exe_path;
    build_target = String_arg_req.get build_target;
    monorepo_path = String_arg_req.get monorepo_path;
    skip_clean = !skip_clean;
    skip_one_shot = !skip_one_shot;
    print_dune_output = !print_dune_output;
    num_short_job_repeats = !num_short_job_repeats;
    include_watch_mode_initial_build = !include_watch_mode_initial_build;
  }
