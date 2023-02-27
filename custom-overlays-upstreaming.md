# Custom Overlays Upstreaming Status

Each of these opam packages are modified via the custom-overlays repo (inside
the directory custom-overlays). This was a quick fix to get the dune monorepo
benchmark working quickly, but the changes introduced in these overlays should
either be ustreamed to their original packages, or added to the
[opam-overlays](https://github.com/dune-universe/opam-overlays.git) repo.

## batteries

Upstream: [https://github.com/ocaml-batteries-team/batteries-included](https://github.com/ocaml-batteries-team/batteries-included)

The overlay adds a dependency on dune. Batteries is already capable of being built with dune
but requires some fixes to its dune file.

[PR to add dune port (open)](https://github.com/dune-universe/batteries-included/pull/1)

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

## ptime

Upstream: [https://github.com/dbuenzli/ptime](https://github.com/dbuenzli/ptime)

Author has indicated that they aren't interested in dune integration.

This already exists in opam-overlays but needs an update.

[PR to update dune port (open)](https://github.com/dune-universe/ptime/pull/2)

TODO: update in opam-overlays repo

## uucp

Upstream: [https://github.com/dbuenzli/uucp](https://github.com/dbuenzli/uucp)

Author has indicated that they aren't interested in dune integration.

This already exists in the dune overlays but needs an update.

[PR to update dune port (open)](https://github.com/dune-universe/uucp/pull/1)

TODO: update in opam-overlays repo


## uunf

Upstream: [https://github.com/dbuenzli/uunf](https://github.com/dbuenzli/uunf)

Author has indicated that they aren't interested in dune integration.

[PR to add dune port (open)](https://github.com/dune-universe/uunf/pull/1)

TODO: add to opam-overlays repo
