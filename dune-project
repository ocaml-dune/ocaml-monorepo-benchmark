(lang dune 3.5)
(name opam-generate-big-monorepo)

(generate_opam_files true)

(package
  (name opam-generate-big-monorepo)
  (allow_empty true)
  (depends
    (dune (>= 3.5.0))
    switch-builder
    ocamlgraph
    opam-repository))
