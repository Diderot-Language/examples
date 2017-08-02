#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./plot1d

echo "0 0 1 0 0" | unu axdelete -a -1 | unu dnorm -rc -o data.nrrd
junk data.nrrd
diderotc  --exec plot1d.diderot
./plot1d -img data.nrrd -ymm -0.3 1.3
junk rgb.nrrd
unu quantize -b 8 -i rgb.nrrd -o ctmr.png
#> ctmr.png 0


#cleanup if successful so far
#not removing executable since programs may need each other (like fs2d, fs3d)
junk plot1d.o plot1d.cxx
