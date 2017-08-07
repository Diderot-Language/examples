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


diderotc  --exec heron.diderot
#prog heron.diderot
./heron
#> vrie.nrrd 0

./heron -eps 1e-8 -l 20 -o vrie-lim.nrrd
#> vrie-lim.nrrd 0

grep -v "initially \[" heron.diderot > coll.diderot
echo "initially { sqroot(lerp(minval, maxval, 1, ii, numval)) | ii in 1 .. numval };" >> coll.diderot
diderotc --exec coll.diderot
#tmp coll.diderot
./coll -eps 1e-8 -l 20 -o vrie-coll.nrrd
#> vrie-coll.nrrd 0
