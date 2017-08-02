#!/bin/bash

# This is an experiment in literate programming for testing: turning
# the information about running the program in the Markdown comment
# at the top of the program into test script. ... in progress ...

set -o errexit
set -o nounset
shopt -s expand_aliases
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term

TESTS="
hello
heron
sieve
life
"

genref=0
while getopts "g" opt; do
  case $opt in
    g)
      genref=1
      ;;
    \?)
      echo "$0: Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "$0: Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


HERE="`dirname \"$0\"`"
HERE="`( cd \"$HERE\" && pwd )`"

for TT in $TESTS; do
  echo ========== $TT
  cd $HERE/$TT
  if [[ $genref -eq 1 ]]; then
      if [[ ! -e .ref ]]; then
          echo == mkdir $TT/.ref
          mkdir .ref
      elif [[ ! -d .ref ]]; then
          echo "$TT/.ref already exists but is not a directory" 1>&2
          exit 1
      fi
      ./.test.sh > .ref/out.txt 2>&1
  else
      ./.test.sh > out.txt 2>&1
      diff out.txt .ref/out.txt
  fi
done