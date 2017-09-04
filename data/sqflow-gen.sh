#!/bin/bash

# unu/bash script for making square cylinder flow datasets

export NRRD_STATE_DISABLE_CONTENT=true
set -o errexit; set -o nounset; shopt -s expand_aliases
JUNK=""; function junk { JUNK="$JUNK $@"; }; function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term

# get dataset linked to from https://people.mpi-inf.mpg.de/~weinkauf/notes/squarecylinder.html
echo === getting SquareCylinder.7z
curl -O http://people.mpi-inf.mpg.de/~weinkauf/datasets/SquareCylinder.7z
#junk SquareCylinder.7z

echo === opening SquareCylinder.7z
## There are various different utilities for opening 7z archives, each with
## different ways for invoking them.  Find one that works for you, run it,
## and make sure that all the files within SquareCylinder.7z end up in a new
## directory called "SquareCylinder"
#junk SquareCylinder

# We want to make NRRD headers for the available timesteps. Based on the
# "Technical Details" on Dr. Weinkauf's page about the data, we specify the
# min-max along each axis, and then convert to more general orientation
# representation with "unu dnorm", as follows.  GLK is unsure whether this
# should be a cell-centered or node-centered; using cell for now.
if false; then  # can comment out by changing true to false
    unu make -i SquareCylinder/flow_t2408.am -s 3 192 64 48 -t float -e raw -en little -ls 16 \
        | unu axinfo -a 0 -k 3-vector \
        | unu axinfo -a 1 -k space -mm -12 20 -c cell \
        | unu axinfo -a 2 -k space -mm -4 4 -c cell \
        | unu axinfo -a 3 -k space -mm 0 6 -c cell \
        | unu dnorm -i - -o - | unu head -
fi
# The resulting "space direction" and "space origin" information is used
# below to make the .nhdr files

echo === making nhdrs
for FILE in SquareCylinder/flow_t????.am; do
    TTTTAM=${FILE#SquareCylinder/flow_t}; TTTT=${TTTTAM%.am}
    echo "($TTTT) making nhdr for $FILE"
    # the "-ls 16" skips 16 lines of ascii text
    unu make -h -i $(basename $FILE) -t float -s 3 192 64 48 \
        -spc 3 -orig "(-11.916666666666666,-3.9375,0.0625)" \
        -dirs "none (0.16666666666666666,0,0) (0,0.125,0) (0,0,0.125)" \
        -k 3-vector space space space -cn none cell cell cell \
        -en little -e raw -ls 16 -o SquareCylinder/flow_t${TTTT}.nhdr
done

# the time steps that we process further
TIMES="1608 3928"

echo === making 3D fields
for TTTT in $TIMES; do
    # on the slowest axis, the last slice is all zeros, so cropping that out
    unu crop -i SquareCylinder/flow_t${TTTT}.nhdr -min 0 0 0 0 -max M M M M-1 |
    unu dnorm -i - -o sqflow-$TTTT.nrrd
done

# We want to extract a 2D flow field from this as well, so we want to find
# where the flow is maximally contained within a 2D cutting plane
# By extracting the Z coordinate, and then looking at the L2 norm of the
# values within an XY slice, we can see exactly where this happens:
if false; then
    unu slice -i sqflow-3928.nrrd -a 0 -p 2 \
        | unu axmerge -a 0 \
        | unu project -a 0 -m l2 \
        | unu dhisto -h 300 -nolog -o zplot.png
fi
# The minimum happens at slice number 23

# We can use interpolation to find a better 2D slice. The default kernel
# for "unu resample" is Catmull-Rom, so we bracket slice 23 with a few
# samples on either side, upsample a bunch, and make another plot of the
# L2 norm of Z-coordinates:
if false; then
    unu crop -i sqflow-3928.nrrd -min 0 0 0 20 -max M M M 26 \
        | unu resample -s = = = 71 \
        | unu slice -a 0 -p 2 \
        | unu axmerge -a 0 \
        | unu project -a 0 -m l2 \
        | unu dhisto -h 300 -nolog -o zupplot.png
fi
# GLK found that upsampling to an odd number of slices gave a more
# distinct minimum, which happens at index 38 in this case

echo === making 2D fields
for TTTT in $TIMES; do
    unu crop -i sqflow-$TTTT.nrrd -min 0 0 0 20 -max M M M 26 |
    unu resample -s = = = 71 |
    unu slice -a 3 -p 38 | # extract the best 2D slice
    unu crop -min 0 0 0 -max M-1 M M | # crop out last vector component
    unu basinfo -spc 2 -orig "(-11.916666666666666,-3.9375)" | # 2D orientation; will crop axes' space vecs
    unu axinfo -a 0 -k 2-vector |
    unu dnorm -i - -o sqflow2D-$TTTT.nrrd
done
