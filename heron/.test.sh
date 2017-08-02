#!/bin/bash
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./heron

diderotc  --exec heron.diderot
./heron
 junk vrie.nrrd

 echo == vrie.nrrd ==
unu save -f text -i vrie.nrrd

./heron -eps 1e-8 -l 20
 echo == vrie.nrrd with -eps 1e-8 -l 20 ==
 unu save -f text -i vrie.nrrd

 echo == collection instead of array
 grep -v ARRAY heron.diderot > coll.diderot
 echo "initially { sqroot(lerp(minval, maxval, 1, ii, numval)) | ii in 1 .. numval };" >> coll.diderot
 diderotc --exec coll.diderot
 ./coll -eps 1e-8 -l 20
 echo == vrie.nrrd from coll.diderot
 unu save -f text -i vrie.nrrd
 junk coll{,.diderot,.o,.cxx}


#cleanup if successful so far
junk heron heron.o heron.cxx
