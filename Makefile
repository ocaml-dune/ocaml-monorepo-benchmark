all: dist/packages

package_stats:
	dune exec --display=quiet bin/package_stats.exe

dist/packages: bin/dependency_closure.ml
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure.exe $(shell uname -m) > $@

clean:
	dune clean
	rm -rf dist

.PHONY: package_stats clean
