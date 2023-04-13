open Switch_builder

module Package_graph : sig
  type t = OpamPackage.t list OpamPackage.Map.t

  val reverse : t -> t
  val closure : t -> OpamPackage.Set.t -> t
  val to_dot : t -> string
end = struct
  type t = OpamPackage.t list OpamPackage.Map.t

  let reverse t =
    OpamPackage.Map.to_seq t
    |> Seq.fold_left
         (fun acc (package, deps) ->
           List.fold_left
             (fun acc dep ->
               OpamPackage.Map.update dep (fun xs -> package :: xs) [] acc)
             acc deps)
         OpamPackage.Map.empty

  let closure t init =
    let keys_to_keep =
      Import.fixpoint ~equal:OpamPackage.Set.equal
        ~f:(fun keys ->
          OpamPackage.Set.fold
            (fun key acc ->
              match OpamPackage.Map.find_opt key t with
              | Some deps ->
                  OpamPackage.Set.of_list deps |> OpamPackage.Set.union acc
              | None -> acc)
            keys keys)
        init
    in
    let keys_to_remove =
      OpamPackage.Set.diff
        (OpamPackage.Map.keys t |> OpamPackage.Set.of_list)
        keys_to_keep
    in
    OpamPackage.Set.fold
      (fun package acc -> OpamPackage.Map.remove package acc)
      keys_to_remove t

  let to_dot t =
    let digraph_members =
      OpamPackage.Map.to_seq t
      |> Seq.map (fun (package, deps) ->
             List.map
               (fun dep ->
                 Printf.sprintf "\"%s\" -> \"%s\""
                   (OpamPackage.to_string package)
                   (OpamPackage.to_string dep))
               deps)
      |> List.of_seq |> List.concat
    in
    Printf.sprintf "digraph {\n%s\n}" (String.concat ";\n" digraph_members)
end

module Package_graph_by_name = struct
  type t = {
    package_graph : Package_graph.t;
    name_to_package : OpamPackage.t OpamPackage.Name.Map.t;
  }

  let of_package_graph package_graph =
    let name_to_package =
      let package_set =
        OpamPackage.Map.keys package_graph |> OpamPackage.Set.of_list
      in
      OpamPackage.Set.to_seq package_set
      |> Seq.map (fun package ->
             let name = OpamPackage.name package in
             (name, package))
      |> OpamPackage.Name.Map.of_seq
    in
    { package_graph; name_to_package }

  let reverse t =
    { t with package_graph = Package_graph.reverse t.package_graph }

  let closure t init =
    let init =
      OpamPackage.Name.Set.elements init
      |> List.map (fun name -> OpamPackage.Name.Map.find name t.name_to_package)
      |> OpamPackage.Set.of_list
    in
    { t with package_graph = Package_graph.closure t.package_graph init }

  let closure' t init =
    let package_name_set =
      List.map OpamPackage.Name.of_string init |> OpamPackage.Name.Set.of_list
    in
    closure t package_name_set

  let to_dot t = Package_graph.to_dot t.package_graph

  let has_name_string t string =
    let name = OpamPackage.Name.of_string string in
    OpamPackage.Name.Map.mem name t.name_to_package
end

let make_dependency_graph ~arch () =
  let repo = Helpers.Policy.cached_repo_with_overlay () in
  let set =
    Helpers.Policy.large_closed_package_set ~arch ~allow_depexts:true repo
  in
  let name_to_package =
    OpamPackage.Set.to_seq set
    |> Seq.map (fun package ->
           let name = OpamPackage.name package in
           (name, package))
    |> OpamPackage.Name.Map.of_seq
  in
  OpamPackage.Set.to_seq set
  |> Seq.map (fun package ->
         let dep_names = Helpers.Policy.dependency_names ~repo package in
         let deps =
           List.filter_map
             (fun name ->
               match OpamPackage.Name.Map.find_opt name name_to_package with
               | Some x -> Some x
               | None ->
                   if OpamPackage.Name.Set.mem name Helpers.Policy.assumed_deps
                   then None
                   else (
                     Logs.warn (fun m ->
                         m "missing %s, dependency of %s"
                           (OpamPackage.Name.to_string name)
                           (OpamPackage.to_string package));
                     None))
             dep_names
         in
         (package, deps))
  |> OpamPackage.Map.of_seq

module Args = struct
  type t = { arch : string; reverse : bool; roots : string list }

  let parse () =
    let arch = ref "x86_64" in
    let reverse = ref false in
    let roots = ref [] in
    let specs =
      [
        ("--arch", Arg.Set_string arch, "architecture to target");
        ( "--reverse",
          Arg.Set reverse,
          "expand reverse dependencies instead of dependencies" );
      ]
    in
    Arg.parse specs
      (fun anon_arg -> roots := anon_arg :: !roots)
      "Generate graphviz file showing dependency hierarchy from a given set of \
       starting points";
    { arch = !arch; reverse = !reverse; roots = !roots }
end

let () =
  let { Args.arch; reverse; roots } = Args.parse () in
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  let dependency_graph =
    make_dependency_graph ~arch () |> Package_graph_by_name.of_package_graph
  in
  List.iter
    (fun root ->
      if not (Package_graph_by_name.has_name_string dependency_graph root) then
        failwith (Printf.sprintf "Couldn't find package: %s" root))
    roots;
  let dependency_graph_for_query =
    if reverse then Package_graph_by_name.reverse dependency_graph
    else dependency_graph
  in
  let closure =
    Package_graph_by_name.closure' dependency_graph_for_query roots
  in
  let dotfile_string = Package_graph_by_name.to_dot closure in
  print_endline dotfile_string
