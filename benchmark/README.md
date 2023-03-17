# Monorepo Benchmark

## Dune File

Note the dune file defines a library `monorepo` with many dependencies:
```
(library
 (name monorepo)
 (modules monorepo)
 (libraries
  0install-solver
  ANSITerminal
  FrontC
  ISO3166
  ISO8601
  ...
```

This is necessary for two reasons:

1. When opam-monorepo downloads the package dependencies it creates a dune file
   in the duniverse directory with the stanza `(vendored_dirs *)` which prevents
   dune from treating the vendored packages as part of the current project.
   That is they won't be built by default by `dune build`. If we were to remove
   this file we would need to rename the libraries defined in each package to
   have a prefix `<package-name>.` to satisfy dune's library naming rules.
2. Not all the libraries in the monorepo can be built in a monorepo setting and
   the libraries that don't build are omitted from the list of library
   dependencies in the dune file.

## Repo Revisions

- this repo 3e74e34d7622eedeee716e99023a6bbb2172987
- opam-overlays fe1b268c68f1b851abc0680262e960c63918c332
- opam-repository 0fd96b90e04599bcce3b6ae8ba54febdafeddb11

