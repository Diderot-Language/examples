#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset
shopt -s expand_aliases

if [ ! -z ${DDRO_TARG+x} ]; then
    if [ $DDRO_TARG == noop ]; then
        alias diderotc=:
    elif [ $DDRO_TARG == pthread ]; then
        alias diderotc="diderotc --target=pthread"
    fi
fi

if [ ! -z ${DDRO_PRFX+x} ]; then
    PRFX=$DDRO_PRFX
else
    PRFX=
fi


diderotc  --exec tensor.diderot
#prog tensor.diderot
$PRFX ./tensor
junk out.nrrd
echo == output out.nrrd:
unu save -f text -i out.nrrd
