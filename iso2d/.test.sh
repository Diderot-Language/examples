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


../fs2d/fs2d-scl -size0 50 -size1 50 -which tcubic -width 8 | unu save -f nrrd -o cubic.nrrd
rm out.nrrd
diderotc $DFLG --exec iso2d.diderot
#prog iso2d.diderot
junk cubic.nrrd

$PRFX ./iso2d -cmin -4 -4 -cmax 4 4 -size 100
junk pos.nrrd

unu jhisto -i pos.nrrd -b 300 300 -min -4 4 -max 4 -4 -t float |
unu resample -s x1 x1 -k gauss:3,4 -o jhisto.nrrd
#> jhisto.nrrd 0.1

unu 2op nrand cubic.nrrd 0.5 -s 42 -o noisy.nrrd
../fs2d/fs2d-scl -size0 50 -size1 50 -which y -width 8 | unu save -f nrrd -o yramp.nrrd
rm out.nrrd
unu 2op x yramp.nrrd 3 | unu 2op + noisy.nrrd - -o noisy.nrrd
junk yramp.nrrd noisy.nrrd

$PRFX ./iso2d -cmin -4 -4 -cmax 4 4 -size 100 -img noisy.nrrd -o pos2.nrrd
junk pos2.nrrd
unu jhisto -i pos2.nrrd -b 300 300 -min -4 4 -max 4 -4 -t float |
unu resample -s x1 x1 -k gauss:3,4 -o jhisto2.nrrd
#> jhisto2.nrrd 0.1
