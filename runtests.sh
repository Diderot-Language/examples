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
steps
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

outFileTol="#>" # HEY sync with gen-readme.sh

for TT in $TESTS; do
  echo ========== $TT
  cd $HERE/$TT
  if [[ $genref -eq 1 ]]; then
      # we are generating reference output, not comparing against
      if [[ ! -e .ref ]]; then
          echo == mkdir $TT/.ref
          mkdir .ref
      elif [[ ! -d .ref ]]; then
          echo "$TT/.ref already exists but is not a directory" 1>&2
          exit 1
      fi
      ./.test.sh > .ref/out.txt 2>&1
      while read -r line; do # reads lines from .test.sh
        if [[ $line =~ ^$outFileTol ]]; then
          line=${line#$outFileTol}
          # HEY add check that the same outFile isn't used twice
          outFile=$(echo $line | cut -d' ' -f 1) # messy from IFS modification
          mv $outFile .ref/$outFile
        fi
      done <<< $(cat .test.sh)
  else
      # we comparing against pre-existing reference outputs
      ./.test.sh > out.txt 2>&1
      # compare textual output with reference
      diff out.txt .ref/out.txt
      junk `pwd`/$TT `pwd`/out.txt
      # see what output files there are to compare;
      # NOTE that these comparisons are done AFTER test script execution
      saveIFS="$IFS"
      IFS='' # to preserve whitespace when reading lines of README.md
      while read -r line; do # reads lines from .test.sh
        if [[ $line =~ ^$outFileTol ]]; then
          line=${line#$outFileTol}
          # HEY add check that the same outFile isn't used twice
          outFile=$(echo $line | cut -d' ' -f 1) # messy from IFS modification
          toler=$(echo $line | cut -d' ' -f 2)
          # needs teem svn r6312
          unu diff -q -x $outFile .ref/$outFile -eps $toler
          # HEY if there is a difference, preserve $outFile, else
          junk `pwd`/$outFile
        fi
      done <<< $(cat .test.sh)
      IFS="$saveIFS"
  fi
done
