# Monorepo Generator

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

## Patches

The `patches` directory contains a number of patches to projects that allows
them to be built as part of a monorepo. Each patch file begins with a comment
describing what the patch does and its upstreaming status with a link to the
relavent PR or issue. Note that some of the upstreaming PRs have been merged but
the patch is still necessary until the package gets a new release and the
revision of opam-repository used to build the monorepo is updated.
