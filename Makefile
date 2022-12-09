all: dist/out.opam

package_stats:
	dune exec --display=quiet bin/package_stats.exe

dependency_closure_sexp:
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure_sexp.exe $(shell uname -m) > dist/packages.sexp

dist/packages.sexp:
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure_sexp.exe $(shell uname -m) > $@

dist/out.opam: dist/packages.sexp
	dune exec --display=quiet bin/opam_of_sexp.exe < $< > $@

dist/dune: dist/packages.sexp
	dune exec --display=quiet bin/dune_of_sexp.exe < $< > $@

clean:
	dune clean
	rm -rf dist

.PHONY: package_stats dependency_closure clean
