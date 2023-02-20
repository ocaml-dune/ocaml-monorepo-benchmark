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

TODO: Add version to dune overlays repo

## batteries

Upstream: [https://github.com/ocaml-batteries-team/batteries-included](https://github.com/ocaml-batteries-team/batteries-included)

The overlay adds a dependency on dune. Batteries is already capable of being built with dune.
I've upstreamed a patch to add dune as an optional dependency of batteries so this overlay
will become unnecessary after the next release of batteries.

TODO: add batteries to opam-overlays

TODO: remove overlay after next batteries release

## bisect_ppx

Upstream: [https://github.com/aantron/bisect_ppx](https://github.com/aantron/bisect_ppx)

The version of this package in opam is incompatible with the latest version of `ppxlib`. There is a [PR](https://github.com/aantron/bisect_ppx/pull/400)
to add compatibility but it hasn't been merged yet, and people have started
forking `bisect_ppx` to add `ppxlib` support on their own. I've cherry-picked
commits from [this fork](https://github.com/anmonteiro/bisect_ppx/tree/fork)
onto [my own
fork](https://github.com/gridbugs/bisect_ppx/tree/ppxlib-compatibility) and done
a release which is the `url.src` of the overlay package.

I'm not sure what the right thing is to do assuming the PR against `bisect_ppx`
is never merged. This probably doesn't belong in the opam-overlays repo.

## camlp5

Upstream: [https://github.com/camlp5/camlp5](https://github.com/camlp5/camlp5)

Forked to add dune files. These files aren't enough to get this package to build
with dune but they do allow other packages to depend on libraries defined within
camlp5 (namely `elpi`). This is a hack to increase the number of packages that
can be built so it won't be upstreamed.

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

This already exists in opam-overlays but needs an update.

TODO: update in opam-overlays repo

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

This already exists in the dune overlays but needs an update.

TODO: update in opam-overlays repo


## uunf

Upstream: [https://github.com/dbuenzli/uunf](https://github.com/dbuenzli/uunf)

Author has indicated that they aren't interested in dune integration.

TODO: add to opam-overlays repo
