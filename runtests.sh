#!/bin/bash

# These tests are an experiment in literate programming for test generation.
# ./gen-readme.sh not only processes a certain comment (containing Markdown)
# into the README.md file, it also generates a .test.sh test script. There
# are some contrived ways of controlling how the pre-formated code blocks
# (Markdown lines starting with tab) are turned into test scripts, as follows:
# \t#! == do generate .test.sh (else the generated .test.sh is deleted)
# \t#R == following code block is only for README.md, not for test script
# \t#_ == this line is only for test script, not for README.md
# \t#=diderotc == substitute in diderotc compilation line
# \t#||: == suffix command on following line with "||:" to avoid stopping on error
# \t#> OUT EPS == compare output file OUT with reference with tolerance EPS

#TODO: valgrind commands starting with "./"
#TODO: compile for pthreads (control how many times run), --double ( --long-int, --scalar)

set -o errexit
set -o nounset
shopt -s extglob # for var=${var##*( )}
shopt -s expand_aliases
JUNK=""
function junk { JUNK="$JUNK $@"; }
function cleanup { rm -rf $JUNK; }
trap cleanup err exit int term

# explicitly listing these, rather than discovering which directories have
# .test.sh scripts, so that we can encode here dependencies (e.g. anything
# that depends on fs2d or fs3d has to come after them)
TESTS="
hello
heron
sieve
life
steps
unicode
plot1d
tensor
"

function usage {
    echo ""
    echo "usage: runtests.sh [-g] [-v] -r dir [ex1 ex2 ...]"
    echo ""
    echo "Use the per-subdirectory .test.sh for testing, for given example"
    echo "subdirectories (if given), else for all known subdirectories."
    echo "With the -g option, generates test results for reference, otherwise"
    echo "comparing new results to existing reference output."
    echo "-v turns on verbose mode."
    exit 1
}

genref=0
refdir=""
OPTERR=1
verbose=0
while getopts "vgr:" opt; do
    case $opt in
        g)
            genref=1
            ;;
        v)
            verbose=1
            ;;
        r)
            refdir=$OPTARG
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
if [[ -z $refdir ]]; then
    echo "$0: didn't use -r to set reference directory" >&2
    usage
    exit 1
fi
shift "$((OPTIND - 1))"
if [[ "$@" ]]; then
    tests="$@"
else
    tests="$TESTS"
fi

if [[ ! -d $refdir ]]; then
    echo "$0: reference directory \"$refdir\" does not exist" >&2
    exit 1
fi
REF="`(cd $refdir && pwd)`"

HERE="`dirname \"$0\"`"
HERE="`( cd \"$HERE\" && pwd )`"
if [[ $verbose -eq 1 ]]; then
    echo "$0: starting in directory HERE $HERE"
fi

outFileTol="#>" # HEY sync with gen-readme.sh

for TT in $tests; do
    if [[ ! -d $HERE/$TT ]]; then
        echo "$0: directory \"$HERE/$TT\" does not exist; stopping" >&2
        exit 1
    fi
    if [[ ! -e $REF/$TT ]]; then
        echo "$0: creating directory \"$REF/$TT\""
        mkdir $REF/$TT
    elif [[ ! -d $REF/$TT ]]; then
        echo "$0: \"$REF/$TT\" already exists but isn't a directory" >&2
        exit 1
    fi
    if [[ ! -e $HERE/$TT/.test.sh ]]; then
        echo "$0: \"$HERE/$TT\" has no .test.sh script; stopping" >&2
        exit 1
    fi
    echo "$0: $TT ..."
    cd $HERE/$TT
    if [[ $verbose -eq 1 ]]; then
        echo -n "$0: now in directory "; pwd
    fi
    if [[ $genref -eq 1 ]]; then
        # we are generating reference output, not comparing against it
        set +o errexit
        ./.test.sh > $REF/$TT/out.txt 2>&1
        status=$?
        if [[ $status -ne 0 ]]; then
            echo "$0: ERROR(status=$status): see $REF/$TT/out.txt" >&2
            continue;
        fi
        set -o errexit
        saveIFS="$IFS"
        IFS='' # to preserve whitespace when reading lines
        while read -r line; do # reads lines from .test.sh
            if [[ $line =~ ^$outFileTol ]]; then
                line=${line#$outFileTol}
                line=${line##*( )}
                # HEY add check that the same outFile isn't used twice
                outFile=$(echo $line | cut -d' ' -f 1) # messy from IFS modification
                mv $outFile $REF/$TT # can move globbed files
            fi
        done <<< $(cat .test.sh)
        IFS="$saveIFS"
    else
        # we compare against pre-existing reference outputs
        # generate textual output
        if [[ ! -f $REF/$TT/out.txt ]]; then
            echo "$0: missing reference $REF/$TT/out.txt; need to run with -g" >&2
            continue;
        fi
        set +o errexit
        ./.test.sh > out.txt 2>&1
        status=$?
        if [[ $status -ne 0 ]]; then # HEY copy-paste
            echo "$0: ERROR(status=$status): see $HERE/out.txt" >&2
            continue;
        fi
        set -o errexit
        # compare textual output with reference
        diff out.txt $REF/$TT/out.txt
        # see what other output files there are to compare;
        # NOTE that these comparisons are done AFTER test script execution
        saveIFS="$IFS"
        IFS='' # to preserve whitespace when reading lines
        sawdiff=0
        tojunk=""
        while read -r line; do # reads lines from .test.sh
            if [[ $line =~ ^$outFileTol ]]; then
                line=${line#$outFileTol} # HEY copy-paste from above
                line=${line##*( )}
                # HEY add check that the same outFile isn't used twice
                outFile=$(echo $line | cut -d' ' -f 1) # messy from IFS modification
                toler=$(echo $line | cut -d' ' -f 2)
                # needs teem svn r6312
                for ff in $outFile; do
                    set +o errexit
                    tojunk="$tojunk $HERE/$TT/$ff"
                    unu diff -q -x $ff $REF/$TT/$ff -eps $toler
                    status=$?
                    if [[ $status -ne 0 ]]; then
                        echo "$0: ERROR: diff (noted above) in $ff (A=new B=reference)" >&2
                        sawdiff=1
                    fi
                    set -o errexit
                done
            fi
        done <<< $(cat .test.sh)
        IFS="$saveIFS"
        if [[ $sawdiff -eq 0 ]]; then
            # no errors; cleanup
            junk `pwd`/out.txt $tojunk
        fi
    fi
    junk `pwd`/$TT # individual tests didn't clean these up
done
