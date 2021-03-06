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


diderotc $DFLG --snapshot --exec life.diderot
#prog life.diderot

rm -f state*{nrrd,png}
$PRFX ./life -s 1 -l 200 -NN 80 -init patterns/gosperglidergun.nrrd ||:
junk state-*.nrrd state-*.png

unu join -i state-*.nrrd -a 0 -incr |
unu project -a 0 -m sum max histo-median histo-min histo-max -t float |
unu 2op exists - 0 | unu convert -t int -o out.nrrd
#>out.nrrd 0
