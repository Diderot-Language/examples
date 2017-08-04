#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./sphere

diderotc --snapshot --double --exec sphere.diderot

N=2
RNG=1
echo 0 0 0 | unu pad -min 0 0 -max M $((N-1)) | unu 1op nrand -s $RNG -o vec3.nrrd
unu project -i vec3.nrrd -a 0 -m l2 | unu axinsert -a 0 -s 3 | unu 2op / vec3.nrrd - -o vec3.nrrd
junk vec3.nrrd

rm -f pos.nrrd
./sphere -s 0 -l 400 -rad 0.15 -eps 0.033 -pcp 2
junk pos.nrrd  # the #T block below tests pos.nrrd

NP=$(unu head pos.nrrd | grep sizes | cut -d' ' -f 3)
unu axinsert -i pos.nrrd -a 2 -s $NP -o pos2.nrrd
unu swap -i pos2.nrrd -a 1 2 -o pos1.nrrd
junk pos{1,2}.nrrd
unu 2op - pos1.nrrd pos2.nrrd |  # all pair-wise differences
 unu project -a 0 -m l2 | # lengths of diffs
 unu histo -b 400 -min 0 -max 0.24 | # HEY 0.24 depends on -rad 0.15 in execution
 unu crop -min 1 -max M | # lose spike for differences w/ self
 unu resample -s x1 -k gauss:6,4 -t float -o dhisto.nrrd # blur a bunch
#> dhisto.nrrd 0


#cleanup if successful so far; not removing executable
#since programs may need each other (e.g. fs2d, fs3d)
junk sphere.o sphere.cxx
