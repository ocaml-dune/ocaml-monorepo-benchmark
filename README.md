```
git submodule init
git submodule update
opam install --deps-only .
eval $(opam env)
make dependency_closure_arm64
docker build . --tag opam-generate-big-monorepo && docker run --rm -it opam-generate-big-monorepo
```
