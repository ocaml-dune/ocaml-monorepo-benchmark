# opam-generate-big-monorepo

Tool for generating package with as many dependencies as possible for the
purpose of benchmarking dune.

Example usage:

```bash
git submodule init
git submodule update
opam install --deps-only .
eval $(opam env)

# generate a file dist/packages listing the packages that will go into the monorepo
make

# Build a docker image with a debian environment with system deps installed
# and a dune project which depends on libraries from as many packages as possible,
# then run the image in a container.
docker build . --tag opam-generate-big-monorepo && docker run --rm -it opam-generate-big-monorepo

# Run `make` from within the container. This will build the generated project
# with dune.
make
```

The docker image will contain an opam monorepo with all its dependencies
downloaded into the "duniverse" directory.
