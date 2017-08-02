#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./hello

diderotc  --exec hello.diderot
./hello
junk out.nrrd

unu save -f text -i out.nrrd


#cleanup if successful so far
junk hello hello.o hello.cxx
