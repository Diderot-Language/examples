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
unu resample -s = 400 400 -t float |
unu 2op x - wght.txt |
unu project -a 0 -m sum -o tmp.nrrd; junk tmp.nrrd

# a touch of high-pass filtering
unu resample -i tmp.nrrd -s x1 x1 -k gauss:20,5 |
unu 2op x - 0.25 |
unu 2op - tmp.nrrd - -o tmp.nrrd

# learn mapping from histogram equalization of central area,
# then apply to whole image
unu crop -i tmp.nrrd -min 114 48 -max 338 M |
unu heq -b 1000 -a 0.75 -m map.nrrd -o /dev/null; junk map.nrrd
MIN=$(unu slice -i map.nrrd -a 0 -p 10 | unu save -f text)
MAX=$(unu slice -i map.nrrd -a 0 -p M-40 | unu save -f text)
unu rmap -i tmp.nrrd -m map.nrrd |
unu affine $MIN - $MAX 0 1 -clamp true |
unu gamma -g 0.8 |
unu axinfo -a 0 1 -mm -1 1 -c cell |
unu dnorm -o ddro.nrrd

# downsample to different resolutions
unu resample -i ddro.nrrd -s 200 a -k hann:5 | unu 3op clamp 0 - 1 -o ddro-200.nrrd
unu resample -i ddro.nrrd -s 100 a -k hann:5 | unu 3op clamp 0 - 1 -o ddro-100.nrrd
