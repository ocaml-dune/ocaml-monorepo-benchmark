# opam-generate-big-monorepo

Tool for generating package with as many dependencies as possible for the
purpose of benchmarking dune.

Example usage:

```bash
git submodule init
git submodule update
opam install --deps-only .
eval $(opam env)

# generate an opam file with as many dependencies as possible
make

# Build a docker image with a ubuntu environment with system deps installed
# and a dune project which depends on libraries from as many packages as possible,
# then run the image in a container.
docker build . --tag opam-generate-big-monorepo && docker run --rm -it opam-generate-big-monorepo

# Run `make` from within the container. This will build the generated project
# with dune.
make
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
