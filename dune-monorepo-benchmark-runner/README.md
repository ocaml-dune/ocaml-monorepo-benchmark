# Dune Benchmark Runner

Tool to benchmark dune building a monorepo in different scenarios.

## Example Usage

For testing purposes there is a small monorepo at ../small-monorepo. To exercise
this benchmark runner on the small monorepo, you can run:

```
dune exec src/main.exe -- \
  --dune-exe-path=/path/to/dune.exe \
  --monorepo-path=../small-monorepo \
  --build-target=./small_monorepo.exe
```
