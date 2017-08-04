#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./sieve

diderotc  --exec sieve.diderot
./sieve -NN 1000
junk pp.nrrd
unu save -f text -i pp.nrrd


#cleanup if successful so far; not removing executable
#since programs may need each other (e.g. fs2d, fs3d)
junk sieve.o sieve.cxx
