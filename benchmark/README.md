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

The contents of this directory was generated using the tools in ../generate in a
partially manual process. For the sake of reproducability, the revision of this
repo and its submodules that were used to generate the current version of the
benchmark in this directory are listed here.

- this repo 5092b85bcde75807bf81f7e76a577c2d93b35ea2
- opam-overlays d4092e1baab603ae787bca8ba677035568852d64
- opam-repository 0fd96b90e04599bcce3b6ae8ba54febdafeddb11

