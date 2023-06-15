# Ocaml Monorepo Benchmark

[![test status](https://github.com/ocaml-dune/ocaml-monorepo-benchmark/actions/workflows/test.yml/badge.svg)](https://github.com/ocaml-dune/ocaml-monorepo-benchmark/actions/workflows/test.yml)

- `generate-duniverse.sh` is a script for generating the duniverse directory needed by the monorepo benchmark
- `generate` contains a tool for generating large monorepos from packgaes in the opam repository
- `benchmark` contains opam and dune files describing a benchmark
- `dune-monorepo-benchmark-runner` contains an executable for benchmarking dune building a monorepo
- `small-monorepo` contains a small monorepo for testing the benchmark runner
