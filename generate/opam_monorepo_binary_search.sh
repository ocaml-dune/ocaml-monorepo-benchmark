#!/usr/bin/env bash

# Sometimes running `opam monorepo lock` fails and it's not clear why from its output.
# This script binary searches a list of packages to find a single package which causes
# `opam monorepo lock` to fail.

set -ue

OUT_DIR=$PWD

TMP=$(mktemp --directory)
trap "rm -rf $TMP" EXIT

while read line; do
    echo $line >> $TMP/packages
done

TOTAL_NUM_PACKAGES=$(wc -l $TMP/packages | cut -f1 -d' ')

packages_range() {
    local START=$1
    local END=$2
    if [[ $START -eq $END ]]; then
        echo "empty range" > /dev/stderr
        exit 1
    elif [[ $START -gt $END ]]; then
        echo "invalid range" > /dev/stderr
        exit 1
    elif [[ $END -gt $TOTAL_NUM_PACKAGES ]]; then
        echo "range out of bounds" > /dev/stderr
        exit 1
    fi
    local SIZE=$(($END - $START))
    cat $TMP/packages | tail -n+$(($START+1)) | head -n$SIZE
}

mkopam() {
    local START=$1
    local END=$2
    echo 'opam-version: "2.0"'
    echo 'depends: ['
    packages_range $START $END | sed -re 's/^([^.]*)\.(.*)/  "\1" {= "\2"}/'
    echo ']'
}

nth_package() {
    packages_range $1 $(($1 + 1))
}

cd $TMP

mkopam 0 $TOTAL_NUM_PACKAGES > x.opam

if opam monorepo lock; then
    echo "Success!"
    cp -v x.opam $OUT_DIR
    exit 0
fi

echo "Failed to create lockfile. Beginning binary search to find problematic package..."
mv x.opam bad.opam.tmp

START=0
END=$TOTAL_NUM_PACKAGES
while true; do
    N=$(($END - $START))
    if [[ $N -eq 1 ]]; then
        mkopam $START $END > x.opam
        echo "Bad package is #$START: $(nth_package $START)"
        mv x.opam bad.opam.tmp
        mv -v bad.opam.tmp $OUT_DIR
        break
    fi
    echo "At least one of $(($END - $START)) (from #$START to #$END) packages causes the problem"
    MID=$((($START + $END) / 2))
    echo "Generating opam file with packages from #$START to #$MID."
    mkopam $START $MID > x.opam
    echo "Testing on first half."
    if opam monorepo lock; then
        echo "Succeeded on first half, trying on second half..."
        mv x.opam good1.opam.tmp
        echo "Generating opam file with packages from #$MID to #$END."
        mkopam $MID $END > x.opam
        if opam monorepo lock; then
            echo "Succeeded on second half. This is unexpected. Stopping."
            mv x.opam good2.opam.tmp
            mv -v bad.opam.tmp good1.opam.tmp good2.opam.tmp $OUT_DIR
            exit 1
        else
            echo "Failed on second half."
            START=$MID
        fi
    else
        echo "Failed on first half."
        END=$MID
    fi
done
