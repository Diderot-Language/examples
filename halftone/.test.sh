#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset
shopt -s expand_aliases

DFLG=
if [ ! -z ${DDRO_FLAG+x} ]; then
    DFLG="$DDRO_FLAG"
fi
if [ ! -z ${DDRO_TARG+x} ]; then
    if [ $DDRO_TARG == noop ]; then
        alias diderotc=:
    elif [ $DDRO_TARG == pthread ]; then
        DFLG="$DFLG --target=pthread"
    fi
fi

PRFX=
if [ ! -z ${DDRO_PRFX+x} ]; then
    PRFX=$DDRO_PRFX
fi


#I due to non-deterministic parallelism and FP sensitivity
../fs2d/fs2d-scl -which 0 -width 2 -size0 401 -size1 401 |
 unu crop -min 0 100 -max M M-100 |
 unu affine -1 - 1 0 1 |
 unu pad -min -2 -2 -max M+2 M+2 -o img.nrrd
rm -f out.nrrd
junk img.nrrd

diderotc $DFLG --snapshot --exec halftone.diderot
#prog halftone.diderot

NN=300
RNG=5
echo 0 0 | unu pad -min 0 0 -max M $((NN-1)) |
 unu 1op rand -s $RNG | unu affine 0 - 1 -1 1 -o vec2.nrrd
echo 1 0.5 | unu 2op x vec2.nrrd - -o vec2.nrrd
junk vec2.nrrd

rm -f pos-????.{png,nrrd} pos.nrrd
$PRFX ./halftone -s 0 -l 800 -radmm 0.04 1 -eps 0.0001 -pcp 2

SZ=200
OV=2
export NRRD_STATE_VERBOSE_IO=0
for PIIN in pos.nrrd; do
   II=lores
  echo "post-processing $PIIN to pos-$II.png ... "
  unu jhisto -i $PIIN -min -1 -0.5 -max 1 0.5 -b $((OV*SZ*2)) $((SZ*OV)) |
    unu resample -s /$OV /$OV -k bspln5 -t float |
    unu quantize -b 8 -min 0 -max $(echo "0.15 / ($OV * $OV)" | bc -l) -o pos-$II.png
done
# with a tolerance of 256 we're saying "anything goes" but the reason
# is still to generate some way of looking at how the system ended up
#> pos-lores.png 256
# lo-res and blurred versions histograms of x and y positions
unu slice -i pos.nrrd -a 0 -p 1 |
  unu histo -min -0.5 -max 0.5 -b 50 -t float |
  unu resample -s x1 -k gauss:4,3 -b mirror -o pos-yhisto.nrrd
unu slice -i pos.nrrd -a 0 -p 0 |
  unu histo -min -1 -max 1 -b 100 -t float |
  unu resample -s x1 -k gauss:4,3 -b mirror -o pos-xhisto.nrrd
#> pos-?histo.nrrd 1
