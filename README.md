# opam-generate-big-monorepo

Tool for generating package with as many dependencies as possible for the
purpose of benchmarking dune.

Example usage:

```
git submodule init
git submodule update
opam install --deps-only .
eval $(opam env)
make dist/{out.opam,dune}
docker build . --tag opam-generate-big-monorepo && docker run --rm -it opam-generate-big-monorepo
```

The docker image will contain an opam monorepo with all its dependencies
downloaded into the "duniverse" directory.

To do manual experiments, run:
```
make dependency_closure_sexp
```
...which will generate dist/packages.sexp containing a list of packages. Modify
this file so it contains the packages you want present in the eventual .opam
file, then run:
```
make dist/{out.opam,dune}
docker build . --tag opam-generate-big-monorepo && docker run --rm -it opam-generate-big-monorepo
```
...to rebuild the docker image with the desired packages.
