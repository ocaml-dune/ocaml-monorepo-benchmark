# Dune Benchmark Runner

Tool to benchmark dune building a monorepo in different scenarios.

Note that this currently depends on the `dune internal build-count` subcommand
which prints the number of builds that have been completed by dune in watch
mode since it was started. At the time of writing this functionality doesn't
exist on the main branch of dune, so consider this benchmark runner to be very
experimental.

## Example Usage

For testing purposes there is a small monorepo at ../small-monorepo. To exercise
this benchmark runner on the small monorepo, you can run:

```
dune exec src/main.exe -- \
  --dune-exe-path=/path/to/dune.exe \
  --monorepo-path=../small-monorepo \
  --build-target=./small_monorepo.exe
```
