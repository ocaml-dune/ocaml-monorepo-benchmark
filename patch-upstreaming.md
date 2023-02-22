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

[PR (merged)](https://github.com/completium/archetype-lang/pull/336)

## aws-s3

Patch changes the `digestif` implementation to avoid a collision. No upstreaming is needed.

## bastet

Remove patch number from dune-project

[PR (open)](https://github.com/Risto-Stevcev/bastet/pull/38)

## bastet-async

Remove patch number from dune-project

[PR (open)](https://github.com/Risto-Stevcev/bastet-async/pull/1)

## bastet-lwt

Remove patch number from dune-project

[PR (open)](https://github.com/Risto-Stevcev/bastet-lwt/pull/1)

## batteries-included

Various fixes to dune file

[PR (merged)](https://github.com/ocaml-batteries-team/batteries-included/pull/1104)

## biocaml

Replace `core.caml_unix` with `core_kernel.caml_unix`.

[PR (merged)](https://github.com/biocaml/biocaml/pull/182)

## caisar

caisar-onnx doesn't build when ocaml-protoc-plugin is vendored

[Issue (closed)](https://git.frama-c.com/pub/caisar/-/issues/1)

## camltc

Copy src/3rd-party into _build during build

[PR (merged)](https://github.com/toolslive/camltc/pull/50)

## elpi

Open Gramlib in legacy parser. This is due to a problem with the camlp5 overlay
I made so that camlp5 builds with dune. I think I need to add a `(wrapped
false)` somewhere to the dune files for that overlay.

TODO: fix the camlp5 overlay so that this patch is not necessary

## hacl-star

This monorepo uses an old version of hacl-star with some hacks to make it build
with dune. We use an old version because many tezos packages depend on it.
Recent versions of hacl-star already build with dune, so I won't upstream any of
my changes.

## lambda-streams

Remove patch number from dune-project

[PR (open)](https://github.com/Risto-Stevcev/lambda-streams/pull/2)

## lilac

Remove patch number from dune-project

[PR (merged)](https://github.com/shnewto/lilac/pull/1)

## ocaml-aws

Patch changes the `digestif` implementation to avoid a collision. No upstreaming is needed.

## ocaml-bigstring

Removes `bigstring_unix` library to avoid a conflict. No upstreaming is needed.

## ocaml-csv

The patch is to replace `workspace_root` with `project_root` in dune files.

[PR (merged)](https://github.com/Chris00/ocaml-csv/pull/39)

## ocaml-junit

The patch replaces the `oUnit` dependency with `oUnit2` as there is no dune
library named `oUnit`.

[PR (merged)](https://github.com/Khady/ocaml-junit/pull/4)

## ocaml-jupyter

The patch is to replace `workspace_root` with `project_root` in dune files.

[PR (merged)](https://github.com/akabe/ocaml-jupyter/pull/198)

## ocaml-mindstorm

Fix some problems preventing vendoring

[PR (open)](https://github.com/Chris00/ocaml-mindstorm/pull/4)

## ocaml-mock

The patch replaces the `oUnit` dependency with `oUnit2` as there is no dune
library named `oUnit`.

[PR (open)](https://github.com/cryptosense/ocaml-mock/pull/6)

## ocaml-mustache

Increase lang dune version to 1.4

Upstream has independently been updated so no change is needed.

## ocaml-qbf

Patch fixes some issues with vendoring.

[PR (merged)](https://github.com/c-cube/ocaml-qbf/pull/14)

## ocaml-solidity

The patch is to remove the `ez_hash` library from this package as `ez_hash` has
been moved into a separate package. The problem is that `ocaml-solidity` hasn't
been released since.

## OSCADml

Hack to rename some public executables whose names collide with those of another
package. No need to upstream.

## owl_opt

Increase lang dune version to 1.7 to prevent warning that version 1.1 of
automatic filters is not support until 1.7 of the  dune language.

The lang dune version of the upstream package has been independently updated to
2.0, so no change is needed.

## pg_query-ocaml

Remove patch number from dune lang version. Independently fixed upstream.

## randoml

Fixes issue where cargo updates lockfile during build.

[PR (merged)](https://github.com/mimoo/randoml/pull/4)

## resource-pooling

Fix error where field is marked mutable but never mutated. This is a workaround
for what I suspect is a bug in dune where it treats warnings as errors according
to the top-level dune-project only, ignoring the `lang dune` version of
vendored packages.

[Issue (open)](https://github.com/ocaml/dune/issues/7034)
