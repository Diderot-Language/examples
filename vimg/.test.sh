#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset
shopt -s expand_aliases

if [ ! -z ${DDRO_TEST+x} ]; then
    if [ $DDRO_TEST == noop ]; then
        alias diderotc=:
    elif [ $DDRO_TEST == pthread ]; then
        alias diderotc="diderotc --target=pthread"
    fi
fi


unu resample -i ../data/sscand.nrrd -s /2 /2 -o img.nrrd
junk img.nrrd
cp ../cmap/spiral.nrrd cmap.nrrd
junk cmap.nrrd
diderotc  --exec vimg.diderot
#prog vimg.diderot

PARM="-cent 290 414 -fov 80"
CMM="-cmin -500 -cmax 1900"
EPRM=("" "" ""          # 0 1 2
"$CMM -iso 1210 -th 20" # 3
"$CMM -iso 1210 -th 0.2"
"$CMM -th 0.3 -sthr 2"
"$CMM -th 0.3 -sthr 2"  # 6
"$CMM -th 0.4 -sthr 25 -fcol 0 0 0.8"
"$CMM -th 0.4 -fcol 0 1 0"
"$CMM -th 0.4 -sthr 25 -fcol 0 1 1" # 9
)
for I in $(seq 0 9); do
  ./vimg -which $I $PARM ${EPRM[$I]} -o rgb.nrrd
  unu quantize -b 8 -i rgb.nrrd -o rgb-$I.png
done
junk rgb.nrrd
#> rgb-?.png 0
