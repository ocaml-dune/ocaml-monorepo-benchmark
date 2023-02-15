# Custom Overlays Upstreaming Status

Each of these opam packages are modified via the custom-overlays repo (inside
the directory custom-overlays). This was a quick fix to get the dune monorepo
benchmark working quickly, but the changes introduced in these overlays should
either be ustreamed to their original packages, or added to the
[opam-overlays](https://github.com/dune-universe/opam-overlays.git) repo.

## afl-persistent

Upstream: [https://github.com/stedolan/ocaml-afl-persistent](https://github.com/stedolan/ocaml-afl-persistent)

Fork: [https://github.com/gridbugs/ocaml-afl-persistent/tree/dune](https://github.com/gridbugs/ocaml-afl-persistent/tree/dune)

Forked to add dune files and optional dependency on dune.

[PR to upstream (open)](https://github.com/stedolan/ocaml-afl-persistent/pull/11)

## batteries

Upstream: [https://github.com/ocaml-batteries-team/batteries-included](https://github.com/ocaml-batteries-team/batteries-included)

Forked to fix some problems with dune integration.

[PR to upstream (merged)](https://github.com/ocaml-batteries-team/batteries-included/pull/1104)

## bigstring

Upstream: [https://github.com/c-cube/ocaml-bigstring](https://github.com/c-cube/ocaml-bigstring)

TODO


## bigstring-unix

Upstream: [https://github.com/c-cube/ocaml-bigstring](https://github.com/c-cube/ocaml-bigstring)

TODO


## bisect_ppx

Upstream: [https://github.com/aantron/bisect_ppx](https://github.com/aantron/bisect_ppx)

TODO


## camlp5

Upstream: [https://github.com/camlp5/camlp5](https://github.com/camlp5/camlp5)

Forked to add dune files. These files aren't enough to get this package to build
with dune but they do allow other packages to depend on libraries defined within
camlp5 (namely `elpi`). This is a hack to increase the number of packages that
can be built so it won't be upstreamed.

## conf-gobject-introspection

Upstream: [https://github.com/ocaml/opam-repository](https://github.com/ocaml/opam-repository)

TODO


## conf-netsnmp

Upstream: [https://www.github.com/stevebleazard/ocaml-conf-netsnmp](https://www.github.com/stevebleazard/ocaml-conf-netsnmp)

TODO


## cookie

Upstream: [https://github.com/ulrikstrid/ocaml-cookie](https://github.com/ulrikstrid/ocaml-cookie)

TODO


## hacl-star

Upstream: [https://github.com/hacl-star/hacl-star](https://github.com/hacl-star/hacl-star)

This monorepo uses an old version of hacl-star with some hacks to make it build
with dune. We use an old version because many tezos packages depend on it.
Recent versions of hacl-star already build with dune, so I won't upstream any of
my changes.

## hacl-star-raw

Upstream: [https://github.com/hacl-star/hacl-star](https://github.com/hacl-star/hacl-star)

This monorepo uses an old version of hacl-star with some hacks to make it build
with dune. We use an old version because many tezos packages depend on it.
Recent versions of hacl-star already build with dune, so I won't upstream any of
my changes.

## ocaml-inifiles

Upstream: (there is no public repo containing the source code for this package)

The change adds a dune and dune-project file so it builds with dune.

TODO: upstream to the dune overlay repo


## ocurl

Upstream: [https://github.com/ygrek/ocurl](https://github.com/ygrek/ocurl)

The upstream version of this package is already vendor-friendly but unreleased.
[Here is a discussion about doing a release.](https://github.com/ygrek/ocurl/issues/66)

TODO: upstream to dune overlay repo (remove it once the dune version of this package gets released)

## ptime

Upstream: [https://github.com/dbuenzli/ptime](https://github.com/dbuenzli/ptime)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo

## session-cookie

Upstream: [https://github.com/ulrikstrid/ocaml-cookie](https://github.com/ulrikstrid/ocaml-cookie)

TODO


## session-cookie-async

Upstream: [https://github.com/ulrikstrid/ocaml-cookie](https://github.com/ulrikstrid/ocaml-cookie)

TODO


## session-cookie-lwthttps://github.com/ocaml/opam-repository

Upstream: [https://github.com/ulrikstrid/ocaml-cookie](https://github.com/ulrikstrid/ocaml-cookie)

TODO


## tiny_json

Upstream: [https://gitlab.com/camlspotter/tiny_json](https://gitlab.com/camlspotter/tiny_json)

The master branch of this project builds with dune, but these changes haven't
been released to the opam repo. I've
[forked](https://gitlab.com/gridbugs/tiny_json) the project and released a
version which builds with dune to the custom overlays repo, and made an issue
upstream requesting that the maintainer release a new version to opam.

TODO: upstream to the dune overlays repo

## topkg

Upstream: [https://github.com/dbuenzli/topkg](https://github.com/dbuenzli/topkg)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo


## uucd

Upstream: [https://github.com/dbuenzli/uucd](https://github.com/dbuenzli/uucd)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo


## uucp

Upstream: [https://github.com/dbuenzli/uucp](https://github.com/dbuenzli/uucp)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo


## uunf

Upstream: [https://github.com/dbuenzli/uunf](https://github.com/dbuenzli/uunf)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo


## uutf

Upstream: [https://github.com/dbuenzli/uutf](https://github.com/dbuenzli/uutf)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo


## why3

Upstream: [https://gitlab.inria.fr/why3/why3](https://gitlab.inria.fr/why3/why3)

TODO


## why3-coq

Upstream: [https://gitlab.inria.fr/why3/why3](https://gitlab.inria.fr/why3/why3)

TODO


## why3-ide

Upstream: [https://gitlab.inria.fr/why3/why3](https://gitlab.inria.fr/why3/why3)

TODO


