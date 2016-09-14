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
  rm -f $exdir/README.md ||:
  touch $exdir/README.md
  printing=0
  echo "  ... processing $got to create $exdir/README.md"
  IFS='' # to preserve spaces and tabs when reading lines of README.md
  cat $got | while read -r line; do
    if [[ "$line" =~ $flag ]]; then
      # toggle whether we print
      printing=$((1 - $printing))
    fi
    # but don't print line that triggered toggling
    if [[ $printing -eq 1 && ! "$line" =~ $flag ]]; then
      echo "$line" >> $exdir/README.md
    fi
  done
  IFS="$saveIFS"
done
