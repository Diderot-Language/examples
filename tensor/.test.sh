#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./tensor

diderotc  --exec tensor.diderot
./tensor
junk out.nrrd
echo == output out.nrrd:
unu save -f text -i out.nrrd


#cleanup if successful so far
#not removing executable since programs may need each other (like fs2d, fs3d)
junk tensor.o tensor.cxx
