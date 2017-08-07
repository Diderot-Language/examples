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


#just to make sure no-op compiles and runs
diderotc  --exec unicode.diderot
#prog unicode.diderot
./unicode
junk out.nrrd
unu save -f text -i out.nrrd
