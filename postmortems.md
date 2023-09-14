# Postmortems

## 2023-09-12

### Problem

On 2023-09-04 [dune/8293](https://github.com/ocaml/dune/pull/8293) was merged
which increased the minimum supported version of dune's `ctypes` extension to 0.3.
This prevented several packages in the dune monorepo benchmark from building as
they depended on older versions of the extension.

### Solution

This was noticed on 2023-09-12 and fixed on 2023-09-13. It was found that
changing the affected packages to depend on version 0.3 of the `ctypes`
extension allowed them to build again. The solution was to apply patches to the
affected packages while assembling the monorepo which bumped their `ctypes`
extension version to 0.3.

The affected packages:
 - colibrics
 - ocaml-eris
 - ocaml-flint
 - ocaml-monocypher
 - tezos

### Additional complications deploying the solution

In order to deploy the fix, the monorepo needed to be re-assembled and uploaded
to the benchmarking server. While regenerating the monorepo it was found that
the source archives for several packages were unavailable. The archives for the
packages `rosa.0.2.0` and `lucid.0.1.5` were unavailable as the github account
they were hosted on (`kodwx`) had ceased to exist. The package `simlog.0.0.3`
was unavailable because the github repo it's associated with has been renamed
(to "dog"). None of these packages appeared to be cached in opam.ocaml.org/cache
but fortunately were all cached on @gridbugs' dev machine. The archives were
[added to the opam-source-archives
repo](https://github.com/ocaml/opam-source-archives/pull/22).

An additional complication was that the hash for the package `duff.0.5` had
[changed in place](https://github.com/ocaml/opam-repository/pull/23990). The fix
was to update the hash in the opam-monorepo lockfile.

### Reasons for the delay in detecting the problem

This problem coincided with several unrelated issues with the current-bench
benchmarking service which led to frequent failures running dune's benchmarks.
This led to alert fatigue among dune developers resulting in us rarely checking
the reasons for benchmarks failing.
