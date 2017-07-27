#!/bin/bash
#
# script to generate initial Life patterns, starting with pattern description
# hosted at conwaylife.com, in their fileformat.
#
set -o errexit
set -o nounset
shopt -s expand_aliases
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term

export NRRD_STATE_DISABLE_CONTENT=true

# many patterns available at http://www.conwaylife.com/wiki/Category:Patterns
# but this script assumes a specific URL for the pattern, and that the pattern
# is available in "Life 1.06" format, which can be processed with "unu jhisto"

#NAME=gosperglidergun # http://www.conwaylife.com/wiki/Gosper_glider_gun
#NAME=max # http://www.conwaylife.com/wiki/Max
#NAME=104p177 # http://www.conwaylife.com/wiki/104P177
NAME=blinkerpuffer1 # http://www.conwaylife.com/wiki/Blinker_puffer_1
#NAME=breeder1 # http://www.conwaylife.com/wiki/Breeder_1    (BIG!)

curl -O http://www.conwaylife.com/patterns/${NAME}_106.lif
junk ${NAME}_106.lif

MIN=$(unu minmax ${NAME}_106.lif | grep min: | cut -d' ' -f 2)
MAX=$(unu minmax ${NAME}_106.lif | grep max: | cut -d' ' -f 2)
BIN=$[$MAX - $MIN + 1]

unu jhisto -i ${NAME}_106.lif -min $MIN.5 $MIN.5 -max $MAX.5 $MAX.5 -b $BIN $BIN -t float |
unu acrop -m stdv -f 0.001 |
unu pad -min -2 -2 -max M+2 M+2 -b pad -v 0 |
unu dnorm -o $NAME.nrrd

unu resample -i $NAME.nrrd -s x10 x10 -k box -c cell | unu quantize -b 8 -o $NAME.png

