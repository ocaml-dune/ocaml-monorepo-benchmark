#!/usr/bin/env bash
set -euo pipefail

# Script to invoke dune on a tuareg file (ocaml programs files that generate
# dune files). The resulting dune file will be print to this script's stdout.

PACKAGE_DIR=$1
DUNE_FILE=$2

TMP=$(mktemp --directory)
trap "rm -rf $TMP" EXIT

cp -r $PACKAGE_DIR $TMP
cd $TMP/$(basename $PACKAGE_DIR)
dune build $DUNE_FILE
DUNE_SEXP=_build/.dune/default/$DUNE_FILE
if test -f $DUNE_SEXP; then
  cat $DUNE_SEXP
fi
