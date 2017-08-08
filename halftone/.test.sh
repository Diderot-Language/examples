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


#I due to non-deterministic parallelism
../fs2d/fs2d-scl -which 0 -width 2 -size0 401 -size1 401 |
unu crop -min 0 100 -max M M-100 |
unu affine -1 - 1 0 1 |
unu pad -min -2 -2 -max M+2 M+2 -o img.nrrd
rm -f out.nrrd
junk img.nrrd

diderotc --snapshot --exec halftone.diderot
#prog halftone.diderot

NN=100
RNG=5
echo 0 0 | unu pad -min 0 0 -max M $((NN-1)) |
 unu 1op rand -s $RNG | unu affine 0 - 1 -1 1 -o vec2.nrrd
echo 1 0.5 | unu 2op x vec2.nrrd - -o vec2.nrrd
junk vec2.nrrd

rm -f {hp,pos}-????.{png,nrrd} pos.nrrd
NN=30000
RNG=5
echo 0 0 | unu pad -min 0 0 -max M $((NN-1)) |
  unu 1op rand -s $RNG | unu affine 0 - 1 -1 1 -o vec2.nrrd
echo 1 0.5 | unu 2op x vec2.nrrd - -o vec2.nrrd
./halftone -s 50 -l 150 -radmm 0.006 1 -eps 0.00004 -pcp 1 ||:
SZ=200
OV=2
export NRRD_STATE_VERBOSE_IO=0
for PIIN in pos-????.nrrd; do
  IIN=${PIIN#*-}; II=${IIN%.*}
  echo "post-processing $PIIN to pos-$II.png ... "
  unu jhisto -i $PIIN -min -1 -0.5 -max 1 0.5 -b $((OV*SZ*2)) $((SZ*OV)) |
    unu resample -s /$OV /$OV -k bspln3 -t float |
    unu quantize -b 8 -min 0 -max $(echo "1 / ($OV * $OV)" | bc -l) -o pos-$II.png
  unu slice -i $PIIN -a 0 -p 0 |
    unu histo -min -1 -max 1 -b $((SZ/3)) |
    unu dhisto -h $((SZ/3)) -nolog |
    unu resample -s $((SZ*2)) = -k box |
    unu join -i - pos-$II.png -a 1 -o hp-$II.png
done
junk hp-0{000,050,100}.png pos-????.{png,nrrd}
#> hp-0150.png 0
