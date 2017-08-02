#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./life

diderotc --snapshot --exec life.diderot

rm -f state*{nrrd,png}
./life -s 1 -l 200 -NN 80 -init patterns/gosperglidergun.nrrd ||:
 junk state-*.nrrd

 unu join -i state-*.nrrd -a 0 -incr |
 unu project -a 0 -m sum max histo-median -t float |
 unu 2op exists - 0 |
 unu axmerge -a 0 | unu save -f text


#cleanup if successful so far
junk life life.o life.cxx
