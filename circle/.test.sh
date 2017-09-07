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


diderotc $DFLG --snapshot --double --exec circle.diderot
#prog circle.diderot

N=120
RNG=42
eval echo {1..$((2*N))} | unu reshape -s 2 $N | unu 1op nrand -s $RNG -o vec2.nrrd
unu project -i vec2.nrrd -a 0 -m l2 | unu axinsert -a 0 -s 2 | unu 2op / vec2.nrrd - -o vec2.nrrd
junk vec2.nrrd

rm -f pos-????.nrrd pos.nrrd
#I   # because particle motions can change with any FP changes
$PRFX ./circle -s 1 -l 900  # experience shows converges around iter 811
junk pos-????.nrrd pos.nrrd

export NRRD_STATE_VERBOSE_IO=0
# N is still number of particles
unu join -i pos-????.nrrd -a 2 | # axes=(x,y), N, history
 unu axinsert -a 2 -s $N -o pos2.nrrd # axes=(x,y), N, N, history
 unu swap -i pos2.nrrd -a 1 2 | # transpose
 unu 2op - - pos2.nrrd |  # all pair-wise differences
 unu project -a 0 -m l2 | # axes= N, N, history
 unu axmerge -a 0 | # axes= N*N, history
 unu histax -a 0 -b 500 -min 0 -max 0.2 | # axes= histo, history
 unu crop -min 1 0 -max M M | # lose spike for differences w/ self
 unu resample -s x1 = -k gauss:2,4 -t float -o dhisto.nrrd # blur a bunch
junk pos2.nrrd
#> dhisto.nrrd 0
