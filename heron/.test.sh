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


diderotc $DFLG --exec heron.diderot
#prog heron.diderot
$PRFX ./heron
#> vrie.nrrd 0

$PRFX ./heron -eps 1e-8 -l 20 -o vrie-lim.nrrd
#> vrie-lim.nrrd 0

grep -v "initially \[" heron.diderot > coll.diderot
echo "initially { sqroot(lerp(minval, maxval, 1, ii, numval)) | ii in 1 .. numval };" >> coll.diderot
diderotc $DFLG --exec coll.diderot
#tmp coll.diderot
$PRFX ./coll -eps 1e-8 -l 20 -o vrie-coll.nrrd
#> vrie-coll.nrrd 0
