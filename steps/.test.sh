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


diderotc --snapshot --exec steps.diderot
#prog steps.diderot
rm -f state*nrrd log.txt
./steps -s 1 > log.txt
echo == output of "sort log.txt | grep -v ======="
export LC_ALL=C # to ensure traditional sort order
sort log.txt | grep -v =======
junk state.nrrd log.txt state-????.nrrd

rm -f snaps.txt
touch snaps.txt
for SIIN in state-????.nrrd state.nrrd; do
  IIN=${SIIN#*-}
  II=${IIN%.*}
  if [ "$II" == "state" ]; then
     II=99;  # final (not snapshot) state is numbered 99
  fi
  echo 0 0 1 2 4 | # 1:inited 2:updated 4:idle
    unu 2op x $SIIN - | # (pair-wise multiply)
    unu project -a 0 -m sum | # one octal value per strand
    unu splice -i $SIIN -s - -a 0 -p 1 | # 2nd pos on axis 0
    unu crop -min 0 0 -max 1 M -o tmp-$II.txt # substitution map
  echo "0 1 2 3 4 5" | # array of strand idx
    unu subst -s tmp-$II.txt -o tmp-$II.txt # after application of map
  unu slice -i $SIIN -a 0 -p 0 |
    unu histo -b 6 -min 0 -max 5 | unu axinsert -a 1 |
    unu 3op lerp - 0 tmp-$II.txt | # zero out missing strands
    unu flip -a 0 -o tmp-$II.txt # highest index first
  echo -n "${II: -2}-Snap " | cat - tmp-$II.txt >> snaps.txt
done
rm -f tmp-*.txt
junk snaps.txt

echo == integrating logs:
grep ======= log.txt | # looking for status summaries from global update
cut -d' ' -f 4,5,6,7,8,9,10 | # -glob index and values for 6 strands
cat - snaps.txt | # combining with snapshot summary
sort
