package_stats:
	dune exec --display=quiet bin/package_stats.exe

dependency_closure_arm64:
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure.exe dist/out.opam arm64

dependency_closure_x86_64:
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure.exe dist/out.opam x86_64

clean:
	dune clean
	rm -rf dist

.PHONY: package_stats dependency_closure clean
