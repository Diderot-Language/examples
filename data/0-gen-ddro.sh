#!/bin/bash

# unu/bash script for making Diderot portrait test dataset

set -o errexit; set -o nounset; shopt -s expand_aliases
JUNK=""; function junk { JUNK="$JUNK $@"; }; function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term

# image linked from the https://en.wikipedia.org/wiki/Denis_Diderot
curl -O https://upload.wikimedia.org/wikipedia/commons/6/63/Denis_Diderot_111.PNG
junk Denis_Diderot_111.PNG

export NRRD_STATE_DISABLE_CONTENT=true

# crop RGB image, and convert to gray-scale
echo "0.4 0.3 0.3" > wght.txt; junk wght.txt
unu crop -i Denis_Diderot_111.PNG -min 0 555 195 -max M m+725 m+725 |
unu resample -s = 420 420 -t float |
unu 2op x - wght.txt |
unu project -a 0 -m sum -o tmp.nrrd; junk tmp.nrrd

# a touch of high-pass filtering
unu resample -i tmp.nrrd -s x1 x1 -k gauss:20,5 |
unu 2op x - 0.2 |
unu 2op - tmp.nrrd - -o tmp.nrrd

# get range into [0,1]
MIN=$(unu minmax tmp.nrrd | grep min | cut -d' ' -f 2)
MAX=$(unu minmax tmp.nrrd | grep max | cut -d' ' -f 2)
unu affine $MIN tmp.nrrd $MAX 0 1 |
unu axinfo -a 0 1 -mm -1 1 -c cell |
unu dnorm -o ddro.nrrd

# downsample to different resolutions
unu resample -i ddro.nrrd -s 200 a -k hann:5 | unu 3op clamp 0 - 1 -o ddro-200.nrrd
unu resample -i ddro.nrrd -s 100 a -k hann:5 | unu 3op clamp 0 - 1 -o ddro-100.nrrd
