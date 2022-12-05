package_stats:
	dune exec --display=quiet bin/package_stats.exe

dependency_closure:
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure.exe dist/out.opam

clean:
	dune clean
	rm -rf dist

.PHONY: package_stats dependency_closure clean
