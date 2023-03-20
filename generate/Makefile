all: dist/packages

package_stats:
	dune exec --display=quiet bin/package_stats.exe

dist/packages: bin/dependency_closure.ml
	mkdir -p dist
	dune exec --display=quiet bin/dependency_closure.exe $(shell uname -m) > $@

dist/dependency_graph.dot: bin/dependency_graph.ml
	mkdir -p dist
	dune exec --display=quiet bin/dependency_graph.exe $(shell uname -m) > $@

dist/dependency_graph.svg: dist/dependency_graph.dot
	dot -Tsvg -o $@ < $<

clean:
	dune clean
	rm -rf dist

.PHONY: package_stats clean
