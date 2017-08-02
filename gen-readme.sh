#!/usr/bin/env bash
set -o nounset

# Look away! This is a super-cheesy bash script to generate README.md files
# from the (hopefully one) comment delimited by $flag in the (hopefully
# single) such diderot program per example directory. Normal people would use
# a proper text-processing DSL for this task.

# This is the special flag, within the the top comment, that signifies
# that this is supposed to be put into a markdown file.
flag='=========================================='

saveIFS="$IFS"

examples=$(find . -depth 1 -type d -print | grep -v \.git)

tab="	";
tabDoTest="	#!$";
tabCompile="	#=diderotc";
tabErrorOk="	#\|\|:";
tabNoop="	:$";
forTest="#_";

for exdir in $examples; do
  echo $exdir ...
  ddros=$(ls -1 $exdir/*.diderot)
  got=""
  gotnum=0
  for ddr in $ddros; do
    if grep -q -F $flag $ddr; then
      got=$ddr
      ((gotnum++))
    fi
  done
  if [ $gotnum -eq 0 ]; then
    continue
  fi
  if [ $gotnum -gt 1 ]; then
    echo "$0: HEY got $gotnum programs with markdown, only processing last one: $got"
  fi
  progddro=$(basename $got)
  prog=$(basename $progddro .diderot)
  README=$exdir/README.md
  rm -f $README ||:
  touch $README
  TEST=$exdir/.test.sh
  rm -f $TEST ||:
  touch $TEST # may rm later
  printing=0
  intabs=0
  dotest=0
  testing=0
  errorok=0
  haveDiderotc=0
  echo "  ... processing $got to create $README"
  IFS='' # to preserve spaces and tabs when reading lines of README.md
  while read -r line; do # reads lines from $got
    if [[ "$line" =~ $flag ]]; then
      # toggle whether we print
      printing=$((1 - $printing))
    fi
    # but don't print line that triggered toggling
    if [[ $printing -eq 1 && ! "$line" =~ $flag ]]; then
      nfread=0
      nftest=0
      nfe=0
      if [[ ! $line =~ ^$tab ]]; then # line didn't start with tab
        intabs=0
        testing=0
      else  # line did start with tab; may be for test script generation
        if [[ $intabs -eq 0 && ! $line =~ ^$tabNoop ]]; then
          echo "" >> $TEST # separate script command blocks with a blank line
          testing=1
        fi
        intabs=1
        if [[ $line =~ ^$tabDoTest ]]; then dotest=1; nfe=1; fi
        if [[ $line =~ ^$tabNoop ]]; then nfe=1; fi
        if [[ $line =~ ^$tabCompile ]]; then nfread=1; fi
        if [[ $line =~ ^$tabErrorOk ]]; then nfe=1; errorok=1; fi
        if [[ $testing -eq 1 ]]; then
          totest=${line#$tab}
          if [[ $line =~ ^$tabCompile ]]; then
            totest="diderotc ${line#$tabCompile} --exec $progddro"
          elif [[ $totest =~ ^$forTest ]]; then
            totest=${totest#$forTest}
            nfread=1
          fi
          if [[ $nftest -eq 0 && $nfe -eq 0 ]]; then
            if [[ $errorok -eq 1 ]]; then
              echo "$totest ||:" >> $TEST
              errorok=0
            else
              echo $totest >> $TEST
            fi
          fi
        fi
      fi
      if [[ $nfread -eq 0 && $nfe -eq 0 ]]; then
        echo $line >> $README
      fi
    fi
  done <<< $(cat $got)
  if [[ ! -s $TEST ]]; then
    # didn't end up saving anything here
    rm -f $TEST
  elif [[ $dotest -eq 0 ]]; then
    rm -f $TEST
  else
    # add pre-amble to script
    echo "#!/bin/bash
JUNK=\"\"
function junk { JUNK=\"\$JUNK \$@\"; }
function cleanup { rm -rf \$JUNK; }
trap cleanup err exit int term
set -o errexit
set -o nounset

rm -f ./$prog
$(cat $TEST)" > $TEST
    echo "

#cleanup if successful so far
junk $prog $prog.o $prog.cxx" >> $TEST
    chmod 755 $TEST
    echo "  ... also created $TEST"
  fi
  IFS="$saveIFS"
done

