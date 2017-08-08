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


# (here to ensure this program can be compiled, and to be
#  available to other tests)
diderotc  --exec fs2d-scl.diderot
#prog fs2d-scl.diderot
