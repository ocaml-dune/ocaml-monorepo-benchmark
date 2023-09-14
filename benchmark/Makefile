bench:
	opam exec dune-monorepo-benchmark-runner -- \
		--dune-exe-path=/home/user/.opam/bench/bin/dune \
		--build-target=./monorepo_bench.exe \
		--monorepo-path=. \
		--print-dune-output \
		--num-short-job-repeats=5 \
		--remove-outliers=1

.PHONY: bench
