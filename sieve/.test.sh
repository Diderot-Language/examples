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


diderotc $DFLG --exec sieve.diderot
#prog sieve.diderot
$PRFX ./sieve -NN 1000
junk pp.nrrd
unu save -f text -i pp.nrrd
