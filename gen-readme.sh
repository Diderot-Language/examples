#!/usr/bin/env bash
set -o nounset
shopt -s extglob # for var=${var##*( )}

# Look away! This is a super-cheesy bash script to generate README.md files
# from the (hopefully one) comment delimited by $flag in the (hopefully
# single) such diderot program per example directory. Normal people would use
# a proper text-processing DSL for this task.

# This is the special flag, within the the top comment, that signifies
# that this is supposed to be put into a markdown file.
flag='=========================================='

function usage {
    echo ""
    echo "usage: gen-readme.sh [-t] [ex1 ex2 ...]"
    echo ""
    echo "Generate README.md from Diderot source, for given example subdirectories"
    echo "(if given), else for all subdirectories.  With the -t option, also"
    echo "generates a per-subdirectory .test.sh script for testing."
    exit 1
}

gentest=0
while getopts "t" opt; do
    case $opt in
        t)
            gentest=1
            ;;
        \?)
            usage
            ;;
        :)
            echo "$0: Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND - 1))"

given=0
if [[ "$@" ]]; then
    examples="$@"
    given=1
else
    examples=$(ls -1F | grep ".*/$" | cut -d/ -f 1)
fi


# see documentation in runtests.py
tab="	";
tabDoTest="	#!$";
tabCompile="	#=diderotc";
tabErrorOk="	#\|\|:";
outFileTol="#>"; # HEY sync with runtests.py
tabForReadBlock="	#R";
tabForTestBlock="	#T";
forTestLine="#_";
forReadLine="#\^";
tabIgnoreOutDotTxt="	#I"; # HEY sync with runtests.py
tmpProgName="#tmp"; # HEY sync with runtests.py
progName="#prog"; # HEY sync with runtests.py

for exdir in $examples; do
    echo $0: $exdir ...
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
        if [[ $given -eq 1 ]]; then
            echo "$0: directory \"$exdir\" had no .diderot files"
        fi
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
    if [[ $gentest -eq 1 ]]; then
        TEST=$exdir/.test.sh
        rm -f $TEST ||:
        touch $TEST # may rm later
    fi
    printing=0
    intabs=0
    dotest=0
    testing=0
    errorok=0
    haveDiderotc=0
    echo "  ... processing $got to create $README"
    saveIFS="$IFS"
    IFS='' # to preserve whitespace when read'ing lines below
    while read -r line; do # reads Diderot source lines from $got
        if [[ "$line" =~ $flag ]]; then
            # toggle whether we print
            printing=$((1 - $printing))
        fi
        # but don't print line that triggered toggling
        if [[ $printing -eq 1 && ! "$line" =~ $flag ]]; then
            nfread=0
            nftest=0
            nfe=0
            if [[ $line =~ \<!--.*--\> ]]; then nfe=1; fi # only good for single-line HTML comments
            if [[ ! $line =~ ^$tab ]]; then # line didn't start with tab
                intabs=0
                testing=0
                reading=1
            else  # line did start with tab; may be for test script generation
                if [[ $gentest -eq 1 && $intabs -eq 0 && ! $line =~ ^$tabForReadBlock ]]; then
                    echo "" >> $TEST # separate script command blocks with a blank line
                    testing=1
                fi
                if [[ $intabs -eq 0 && $line =~ ^$tabForTestBlock ]]; then
                    reading=0
                fi
                intabs=1
                if [[ $line =~ ^$tab$outFileTol ]]; then nfread=1; fi
                if [[ $line =~ ^$tabCompile ]]; then nfread=1; fi
                if [[ $line =~ ^$tab$forTestLine ]]; then nfread=1; fi
                if [[ $line =~ ^$tab$forReadLine ]]; then nftest=1; fi
                if [[ $line =~ ^$tabDoTest ]]; then dotest=1; nfe=1; fi
                if [[ $line =~ ^$tabIgnoreOutDotTxt ]]; then nfread=1; fi
                if [[ $line =~ ^$tab$tmpProgName ]]; then nfread=1; fi
                if [[ $line =~ ^$tab$progName ]]; then nfread=1; fi
                if [[ $line =~ ^$tabForReadBlock ]]; then nfe=1; fi
                if [[ $line =~ ^$tabForTestBlock ]]; then nfe=1; fi
                if [[ $line =~ ^$tabErrorOk ]]; then nfe=1; errorok=1; fi
                if [[ $testing -eq 1 ]]; then
                    totest=${line#$tab}
                    if [[ $line =~ ^$tabCompile ]]; then
                        totest="diderotc ${line#$tabCompile} --exec $progddro
$progName $progddro"
                    elif [[ $totest =~ ^$forTestLine ]]; then
                        totest=${totest#$forTestLine}
                    fi
                    if [[ $line =~ ^$tab$outFileTol ]]; then # error checking
                        # HEY add check that the same outFile isn't used twice
                        filetol=${totest##$outFileTol*( )}
                        filetol=${filetol%%*( )}
                        file=$(echo $filetol | cut -d' ' -f 1) # alas, IFS hacking
                        tol=$(echo $filetol | cut -d' ' -f 2)
                        foo=$(echo $filetol | cut -d' ' -f 3)
                        if [[ ! $filetol =~ " " || -z $tol || ! -z $foo ]]; then
                            echo "$0: in $got, outFileTol line \"$line\" not of form \"\t$outFileTol OUT EPS\"" >&2
                            exit 1
                        fi
                    fi
                    if [[ $line =~ ^$tab$tmpProgName ]]; then # error checking
                        # HEY add check that the same progName isn't used twice
                        prog=${totest##$tmpProgName*( )}
                        prog=${prog%%*( )}
                        if [[ -z $prog ]]; then
                            echo "$0: in $got, tmpProgName line \"$line\" not of form \"\t$tmpProgName OUT\"" >&2
                            exit 1
                        fi
                    fi
                    if [[ $line =~ ^$tab$progName ]]; then # error checking; HEY copy+paste from above
                        # HEY add check that the same progName isn't used twice
                        prog=${totest##$progName*( )}
                        prog=${prog%%*( )}
                        if [[ -z $prog ]]; then
                            echo "$0: in $got, progName line \"$line\" not of form \"\t$progName OUT\"" >&2
                            exit 1
                        fi
                    fi
                    if [[ $nftest -eq 0 && $nfe -eq 0 ]]; then
                        totest=${totest# }
                        if [[ $errorok -eq 1 ]]; then
                            totest="$totest ||:"
                            errorok=0
                        fi
                        # add prefix PRFX to anything starting with "./"
                        totest=$(echo "$totest" | sed 's|^\( *\)./|\1$PRFX ./|g')
                        echo $totest >> $TEST
                    fi
                fi
            fi
            if [[ $reading -eq 1 && $nfread -eq 0 && $nfe -eq 0 ]]; then
                if [[ $line =~ ^$tab$forReadLine ]]; then
                    line=${line##$tab$forReadLine*( )}
                    echo "$tab$line" >> $README
                else
                    echo $line >> $README
                fi
            fi
        fi
    done <<< $(cat $got) # reading Diderot source lines
    IFS="$saveIFS"
    if [[ $gentest -eq 0 ]]; then
        continue;
    fi
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
shopt -s expand_aliases

if [ ! -z \${DDRO_TARG+x} ]; then
    if [ \$DDRO_TARG == noop ]; then
        alias diderotc=:
    elif [ \$DDRO_TARG == pthread ]; then
        alias diderotc=\"diderotc --target=pthread\"
    fi
fi

if [ ! -z \${DDRO_PRFX+x} ]; then
    PRFX=\$DDRO_PRFX
else
    PRFX=""
fi

$(cat $TEST)" > $TEST
        chmod 755 $TEST
        echo "  ... also created $TEST"
    fi
done

