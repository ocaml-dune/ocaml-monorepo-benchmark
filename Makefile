how_many_packages_build_with_dune:
	dune exec bin/how_many_packages_build_with_dune.exe

clean:
	dune clean

.PHONY: how_many_packages_build_with_dune clean
