#!/bin/sh
set -ue

echo 'opam-version: "2.0"'
echo 'depends: ['
sed -re 's/^([^.]*)\.(.*)/  "\1" {= "\2"}/' /dev/stdin
echo ']'
