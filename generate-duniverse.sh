#!/bin/sh

# Script for generating the duniverse directory needed by the monorepo benchmark.
# Run `./generate-duniverse.sh /path/to/output` and it will create the directory
# /path/to/output/duniverse

set -eux

OUTPUT_DIR=$1

pushd benchmark > /dev/null
docker build . --tag=generate-duniverse
popd > /dev/null

docker run --rm -it --volume=$OUTPUT_DIR:/output_dir generate-duniverse sudo cp -a duniverse /output_dir
