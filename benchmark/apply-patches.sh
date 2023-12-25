#!/bin/sh
for f in patches/*; do p=$(basename ${f%.diff}); echo Applying $p; patch --forward -p1 -d duniverse/$p < $f; done
