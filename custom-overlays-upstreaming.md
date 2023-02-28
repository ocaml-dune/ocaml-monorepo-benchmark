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

## ocaml-inifiles

Upstream: (there is no public repo containing the source code for this package)

The change adds a dune and dune-project file so it builds with dune.

[PR to add dune port (open)](https://github.com/dune-universe/ocaml-inifiles/pull/1)

TODO: upstream to the dune overlay repo

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
