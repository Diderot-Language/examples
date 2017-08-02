#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./unicode

#just to make sure no-op compiles and runs
diderotc  --exec unicode.diderot
./unicode
junk out.nrrd
unu save -f text -i out.nrrd


#cleanup if successful so far
#not removing executable since programs may need each other (like fs2d, fs3d)
junk unicode.o unicode.cxx
