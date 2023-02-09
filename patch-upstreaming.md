# Patch Upstreaming Status

This document is to keep track of the upstreaming of patches applied to packages
to make them work in this monorepo.

## albatross

Patch changes the `checkseum` implementation to avoid a collision. No upstreaming is needed.

## alg_structs

Patch removes dependency on non-existent library `ppx_deriving`. This works when
`ppx_deriving` is installed with opam but not when it's vendored.

[PR (open)](https://github.com/shonfeder/alg_structs/pull/8)

## archetype-lang

Patch removes dependency on non-existent library `ppx_deriving`. This works when
`ppx_deriving` is installed with opam but not when it's vendored.

[PR (closed)](https://github.com/completium/archetype-lang/pull/336)

## aws-s3

Patch changes the `digestif` implementation to avoid a collision. No upstreaming is needed.

## biocaml

Replace `core.caml_unix` with `core_kernel.caml_unix`.

[PR (closed)](https://github.com/biocaml/biocaml/pull/182)

## caisar

caisar-onnx doesn't build when ocaml-protoc-plugin is vendored

[Issue (closed)](https://git.frama-c.com/pub/caisar/-/issues/1)

## camltc

Copy src/3rd-party into _build during build

[PR (closed)](https://github.com/toolslive/camltc/pull/50)

## curses

The patch is to replace `workspace_root` with `project_root` in dune files.

[PR (closed)](https://github.com/mbacarella/curses/pull/10)

## elpi

Open Gramlib in legacy parser

[PR (open)](https://github.com/LPCIC/elpi/pull/173)

## ocaml-solidity

The patch is to remove the `ez_hash` library from this package as `ez_hash` has
been moved into a separate package. The problem is that `ocaml-solidity` hasn't
been released since.

## ocaml-jupyter

The patch is to replace `workspace_root` with `project_root` in dune files.

[PR (open)](https://github.com/akabe/ocaml-jupyter/pull/198)
