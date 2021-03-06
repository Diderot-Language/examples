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


echo "0 0 1 0 0" | unu axdelete -a -1 | unu dnorm -rc -o data.nrrd
junk data.nrrd
diderotc $DFLG --exec plot1d.diderot
#prog plot1d.diderot
$PRFX ./plot1d -img data.nrrd -ymm -0.3 1.3
junk rgb.nrrd
unu quantize -b 8 -i rgb.nrrd -o ctmr.png
#> ctmr.png 2

echo "0.1 0.5 1 0 0" | unu axdelete -a -1 | unu dnorm -rc -o data5.nrrd
unu resample -i data5.nrrd -s 6 -o data6.nrrd
junk data{5,6}.nrrd
PARM="-ymm -0.15 1.15 -xmm -20 20 -xsize 1000 -ysize 200"
rm -f plot-*-*-*.png
for BC in clamp wrap mirror; do
  for KK in c1tent ctmr bspln3 bspln5 c4hexic; do
     # NOTE: these substitutions assume clamp and ctmr are uncommented
     cat plot1d.diderot | sed -e s/clamp/$BC/g | sed -e s/ctmr/$KK/g > plot1d-$KK-$BC.diderot
     diderotc $DFLG --exec plot1d-$KK-$BC.diderot
     for DD in 5 6; do
        $PRFX ./plot1d-$KK-$BC -img data$DD.nrrd $PARM
        unu quantize -b 8 -i rgb.nrrd -o plot-$DD-$KK-$BC.png
     done
  done
done
#tmp plot1d-*-*.diderot
#> plot-*-*-*.png 2

M=10;
MP=$[M+4];
echo "-$MP $MP" | unu axdelete -a -1 |
unu resample -s $[2*MP+1] -k tent -c node |
unu axinfo -a 0 -mm -$MP $MP | unu dnorm -o dataf.nrrd
unu crop -i dataf.nrrd -min $[MP-1] -max M | unu pad -min -$[MP-1] -max M -b pad -v 0 -o dataf.nrrd
junk dataf.nrrd
PARM="-xmm -$M $M -ymm -3 3"
src='field#1(1)[] F0 = ctmr ⊛ bcimg;'
dst='field#4(1)[] F0 = c4hexic ⊛ bcimg;'
cat plot1d.diderot | perl -pe "s|\Q$src\E|$dst|g" > 0-tmp.diderot
junk 0-tmp.diderot
src='field#1(1)[] F = F0;'
FF=("$src"
  'field#1(1)[] F = -F0;'
  'field#1(1)[] F = |F0|;'
  'field#1(1)[] F = sin(F0);'
  'field#1(1)[] F = ∇(sin(F0));'
  'field#1(1)[] F = |∇(sin(F0))|;'
  'field#1(1)[] F = ∇|∇(sin(F0))|;'
  )
NF=${#FF[@]}
for I in $(seq 0 $[NF-1]); do
  II=$(printf %02d $I)
  dst="${FF[$I]}"
  cat 0-tmp.diderot | perl -pe "s!\Q$src\E!${dst}!g" > plot1d-f$II.diderot
  diderotc $DFLG --exec plot1d-f$II.diderot
  $PRFX ./plot1d-f$II -img dataf.nrrd $PARM
  unu quantize -b 8 -i rgb.nrrd -o plot-f$II.png
done
#tmp plot1d-f*.diderot
#> plot-f??.png 2
