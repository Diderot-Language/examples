#!/usr/bin/env bash
set -o nounset
shopt -s extglob # for totest=${totest##*( )}

# Look away! This is a super-cheesy bash script to generate README.md files
# from the (hopefully one) comment delimited by $flag in the (hopefully
# single) such diderot program per example directory. Normal people would use
# a proper text-processing DSL for this task.

# This is the special flag, within the the top comment, that signifies
# that this is supposed to be put into a markdown file.
flag='=========================================='

examples=$(find . -depth 1 -type d -print | grep -v \.git)

tab="	";
tabDoTest="	#!$";
tabCompile="	#=diderotc";
tabErrorOk="	#\|\|:";
tabOutFileTol="	#>"; # HEY sync with runtests.sh
tabNoop="	:$";
forTest="#_";

for exdir in $examples; do
  echo $exdir ...
  ddros=$(ls -1 $exdir/*.diderot 2> /dev/null)
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
    echo "$0: HEY only using last program $got of $gotnum with Markdown delimiter $flag"
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
  saveIFS="$IFS"
  IFS='' # to preserve whitespace when read'ing lines below
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
        if [[ $line =~ ^$tabOutFileTol ]]; then nfe=1; fi
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
            totest=${totest##*( )}
            if [[ $errorok -eq 1 ]]; then
              echo "$totest ||:" >> $TEST
              errorok=0
            else
              echo $totest >> $TEST
            fi
          fi
          if [[ $line =~ ^$tabOutFileTol ]]; then
            echo "${line#$tab}" >> $TEST
            # comparison testing and junking of output done elsewhere
          fi
        fi
      fi
      if [[ $nfread -eq 0 && $nfe -eq 0 ]]; then
        echo $line >> $README
      fi
    fi
  done <<< $(cat $got)
  IFS="$saveIFS"
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
#not removing executable since programs may need each other (like fs2d, fs3d)
junk $prog.o $prog.cxx" >> $TEST
    chmod 755 $TEST
    echo "  ... also created $TEST"
  fi
done

