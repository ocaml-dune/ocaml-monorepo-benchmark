```
git submodule init
git submodule update
opam install --deps-only .
eval $(opam env)
make dist/out.opam dist/dune
docker build . --tag opam-generate-big-monorepo && docker run --rm -it opam-generate-big-monorepo
```
