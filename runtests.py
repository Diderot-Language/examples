#!/usr/bin/env python3

# This is an experiment in combining test generation and documentation.
# ./gen-readme.sh not only processes a certain comment (containing Markdown)
# into the README.md file, it also generates a .test.sh test script. There
# are some contrived ways of controlling how the pre-formated code blocks
# (Markdown lines starting with tab) are turned into test scripts, as follows:
# \t#! == do generate .test.sh
# \t#R == following code block is only for README.md, not for test script
# \t#T == following code block is only for test script, not for README.md
# \t#^ == this line is only for README.md, not for test script
# \t#_ == this line is only for test script, not for README.md
# \t#I == ignore differences in out.txt, because they are to be expected
#         (e.g. due to acceptable differences in floating point ops)
# \t#=diderotc == substitute in diderotc compilation line,
#         using directory name as program name
# \t#tmp PROG.diderot == declare that PROG is compiled from PROG.diderot, to
#         enable eventual clean-up of PROG{,.diderot,.o,.cxx} at end.
#         PROG.diderot is new (tmp) source generated by the test script.
#         Requiring the .diderot suffix is a clumsy way of ensuring
#         that globs only match what they're supposed to match
# \t#prog PROG.diderot == like #tmp, but don't clean up PROG.diderot
#         (only PROG{,.o,.cxx}) because that source was here already,
#         not generated by the test script
# \t#||: == suffix command on following line with "||:" to avoid stopping from error
# \t#> OUT EPS == compare output file(s) OUT with reference, with tolerance EPS
#         OUT can be a glob that expands to multiple filenames, which will
#         be compared individually, but *NOTE* unfortunately python's
#         glob.glob does *NOT* do brace expansion
#
# Assumptions and limitations of gen-readme.sh and this testing:
# * any command line starting with "./" (to run an executable
#   in current directory) is running a executable *generated by diderotc*;
#   these are the commands for which it would be useful to prefix something
#   else for testing (like valgrind or a timing command)
# * invocations of diderotc (in the Diderot comment source) always use
#   --exec, and may also use --snapshot or --double, but NOT --debug or
#   --target or anything else: these other options are only to be set via
#   this testing script
# * "#>" output file specification does not do brace expansion (noted above)
# * only one diderotc or program execution per line
#
# Note: GLK welcomes help making this more pythonic
#
# TODO: enable compiling with --debug
# TODO: enable compiling with --double (and maybe --long-int, --scalar)

import sys
import argparse
import os
import subprocess
import re
import glob
import shutil
import copy

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def stop(why):
    eprint('%s: %s; stopping' % (me, why))
    sys.exit(1)

# subprocess.run is from version 3.5
if sys.version_info < (3,5):
    stop('need python3 version >= 3.5')

# TESTS are all the tests we know about. Explicitly listing these, rather
# than discovering which directories have .test.sh scripts, to document the
# tests for which we know dependencies (see PREREQ below), which for now
# are manually specified
TESTS=[
'hello',
'heron',
'sieve',
'life',
'steps',
'unicode',
'plot1d',
'tensor',
'vimg',
'fs2d',
'iso2d',
# TODO: lic, fs3d, tensor2, mip, dvr
'circle',
'sphere',
'halftone'
]
PREREQ={
    'iso2d': ['fs2d'],
    'halftone': ['fs2d']
}

outFileTol='#>' # HEY sync with gen-readme.sh
oftre=re.compile('^' + outFileTol + ' *')

ignoreOutDotTxt='^#I' # HEY sync with gen-readme.sh
iodtre=re.compile('^' + ignoreOutDotTxt)

tmpProgName="#tmp"; # HEY sync with gen-readme.sh
tpnre=re.compile('^' + tmpProgName + ' *')

progName="#prog"; # HEY sync with gen-readme.sh
pnre=re.compile('^' + progName + ' *')

# for finding segfaults; need egmentation or else it matches "default"
faultre=re.compile('.*egmentation.*ault.*')

# pattern for warnings from diderotc
ddrcwre=re.compile('^\[.*\.diderot.*\] Warning: ')

#################################
################################# command-line parsing and simple globals
#################################
parser = argparse.ArgumentParser(description='Run tests generated from Diderot examples')
parser.add_argument('-v', action='store_true', help='verbose mode')
parser.add_argument('-l', action='store_true', help='list known tests and exit')
parser.add_argument('-r', metavar='refdir',
                    help='directory containing all reference outputs, in one subdirectory per test',
                    nargs=1)
parser.add_argument('-c', action='store_true',
                    help='create reference results, rather than compare against them')
parser.add_argument('-g', action='store_true',
                    help='run diderotc -with -g (same as --debug) for debugging')
parser.add_argument('-ke', action='store_true',
                    help='keep diderotc-generated executables, even when test passes, instead of cleaning them up')
parser.add_argument('-ko', action='store_true',
                    help='keep computed outputs, even when test passes, instead of cleaning them up')
parser.add_argument('-kc', action='store_true',
                    help='keep .o and .cxx (and .diderot for tmps) files, even when test passes, instead of cleaning them up')
parser.add_argument('-p', metavar='#runs',
                    help='instead of compile to sequential target, compile to pthread, and run this number of times',
                    nargs=1, type=int)
parser.add_argument('-prfx', metavar='prefix',
                    help='prepend execution of compiled programs with this (e.g. "valgrind")',
                    nargs=1)
parser.add_argument('test', nargs='*')
me=sys.argv[0]
tsh='.test.sh'
args = parser.parse_args()
if (args.l):
    print("%s: available tests:\n%s" % (me, ' '.join(TESTS)))
    sys.exit(0)
# else they need to have used -r
# (hence can't use required=True with parser.add_argument)
if not args.r:
    stop("need to identify reference output directory with -r")
verbose=args.v
createref=args.c
debug=args.g
keepexe=args.ke
keepout=args.ko
keepcod=args.kc
parallel=args.p[0] if args.p else 0
_refroot=args.r[0]
_tests=[]
if args.test:
    _tests=[t.rstrip('/') for t in args.test]
    for T in _tests:
        if not T in TESTS:
            print("%s: warning: possible prerequisites of test \"%s\" unknown" % (me, T))
else:
    _tests=TESTS

#################################
################################# checking validity of command-line invocation and path
#################################

if parallel:
    if not 0 < parallel < 100:
        stop('parallel runs (from -p) %d not in range [1,99]' % parallel)

def _addpreq(tlist):
    plist=[]
    for T in tlist:
        if T in PREREQ:
            for p in PREREQ[T]:
                if not p in plist:
                    plist.append(p)
                    print('%s: adding prerequisite test "%s" for "%s"' % (me, p, T))
        plist.append(T)
    ret=[]
    for T in plist:
        if not T in ret: ret.append(T)
    return ret
def addpreq(olist):
    nlist=_addpreq(olist)
    while nlist != olist:
        olist=nlist
        nlist=_addpreq(olist)
    return nlist
tests=addpreq(_tests)
if (verbose):
    print('%s: original test list: ' % me, _tests)
    print('%s: expanded test list: ' % me, tests)

def run(wut):
    if verbose: print('%s: running "%s" in %s' % (me, wut, os.getcwd()))
    return subprocess.run(wut, check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def checkpath():
    if not shutil.which('diderotc'):
        stop("don't have \"diderotc\" in path; test scripts won't work")
    version=[str(l,'utf-8') for l in run('diderotc --version').stdout.splitlines()][0]
    if not 'vis15' in version:
        stop("\"diderotc --version\" says \"%s\" but expected vis15" % version)
    if not shutil.which('unu'):
        stop("don't have \"unu\" in path; test scripts won't work")
    lines=[str(l,'utf-8') for l in run('unu about').stdout.splitlines()]
    formats=[l for l in lines if 'Formats available' in l][0]
    if not ' png ' in formats:
        stop("\"unu\" in path doesn't support PNG images; test scripts won't work (\"unu about\" reports %s)" % formats)
    print('%s: using %s' % (me, shutil.which('diderotc')))
    print('%s: using %s' % (me, shutil.which('unu')))
checkpath()

if parallel and createref:
    stop("can't use -p and -c at the same time")

if not os.path.isdir(_refroot):
    stop("reference root directory \"%s\" doesn't exist" % _refroot)

refroot=os.path.abspath(_refroot)
startdir = os.getcwd()

#################################
################################# other utility functions
#################################
def runsave(outname):
    ret=0
    res=None
    try:
        res=run('./' + tsh)
    except subprocess.CalledProcessError as e:
        eprint('%s: failed to run ./%s in %s' % (me, tsh, os.getcwd()))
        res=e
        ret=1
    # with or without error, res stores output, for saving to file
    with open(outname, 'w') as f:
        slines=[str(bl,'utf-8') for bl in res.stdout.splitlines()]
        # this is a unfortunately challenge for testing: it may not really
        # an error (for some Diderot program) to finish without all strands
        # converging, so we ignore the non-zero return status. But then how
        # do we catch real problems like a segfault?  Right now we
        # explicitly search for that line in the output. But HEY what if
        # there are other errors that we aren't searching for?
        if [l for l in slines if faultre.match(l)]: ret=1 # segfault!
        # dropping diderotc warnings because in case of parallel testing,
        # they are seen only on the first pass (and the difference in
        # presence of warning shouldn't be an error), and because they
        # aren't really the object of testing anyway
        flines=[l for l in slines if not ddrcwre.match(l)]
        f.write('\n'.join(flines))
        f.write('\n') # final newline
    return (ret,res)

def globprogs(TT, globs, progs, execs):
    for pg in globs:
        pds = glob.glob(pg['prog'])
        if not pds:
            stop("didn't find (for \"%s\") files matching glob \"%s\"" % (TT, pg))
        # array of the executable names
        ps = [ re.sub(r'\.diderot', '', pd) for pd in pds ]
        progs.extend([{'prog': p, 'tmp': pg['tmp']} for p in ps])
        # will clean execs regardless of tmp-ness, but need full path
        execs.extend([os.path.abspath(p) for p in ps])
    if verbose:
        print('%s: progs=' % me, progs)
        print('%s: execs=' % me, execs)

# first pass through tests to make sure needed directories and files exist
for TT in tests:
    os.chdir(startdir)
    if not os.path.isdir(TT):
        stop("test directory \"%s\" doesn't exist" % TT)
    if not os.path.isfile(TT + '/' + tsh):
        stop("test directory \"%s\" has no \"%s\" test script" % (TT, tsh))
    refdir = refroot + '/' + TT
    if not createref:
        want=refdir + '/out.txt'
        if not os.path.isfile(want):
            stop("missing reference output \"%s\"; need to first run with -c" % want)

#################################
################################# the testing itself
#################################
if 'DDRO_PRFX' in os.environ: del os.environ['DDRO_PRFX']
if args.prfx:
    os.environ['DDRO_PRFX'] = args.prfx[0]
    if (verbose):
        print('%s: NOTE: program executions will be prefixed by "%s"' % (me, os.environ['DDRO_PRFX']))
if 'DDRO_FLAG' in os.environ: del os.environ['DDRO_FLAG']
if debug:
    os.environ['DDRO_FLAG'] = '--debug'

execs=[]
failed=[]
passed=[]
for TT in tests:
    os.chdir(startdir)
    refdir = refroot + '/' + TT
    if not os.path.isdir(refdir):
        print(me+': creating directory "%s"' % refdir)
        os.makedirs(refdir)
    print(TT, '..................................')
    outtols=[]
    progglobs=[]
    texes=[]
    dodiff=True
    os.chdir(TT)
    if (verbose): print('%s: now in directory %s' % (me, os.getcwd()))
    with open(tsh, 'r') as f:
        for line in f:
            if iodtre.match(line): dodiff=False
            elif tpnre.match(line):
                progglobs.append({'prog': re.sub(tpnre, '', line).rstrip(),
                                  'tmp' : True})
            elif pnre.match(line):
                progglobs.append({'prog': re.sub(pnre, '', line).rstrip(),
                                  'tmp' : False})
            elif oftre.match(line):
                foo=re.sub(oftre, '', line).split()
                outtols.append({'out': foo[0],
                                'tol': foo[1]})
    if not progglobs:
        stop("%s/%s didn't declare program names w/ %s or %s"
             % (TT, tsh, progName, tmpProgName))
    if verbose:
        print('%s: outtols=' % me, outtols)
        print('%s: progglobs=' % me, progglobs)
    progs=[]
    junk=[]
    thispass=True
    if createref:
        (ret,out)=runsave(refdir + '/out.txt')
        if ret:
            eprint('%s: (for test "%s") couldn\'t create reference output because test script failed; %s records:\n%s'
                   % (me, TT, refdir + '/out.txt', str(out.stdout,'utf-8')))
            sys.exit(1)
        # done running script, now move outputs
        for ot in outtols:
            # glob.glob does NOT do brace expansion, but glob.glob will be
            # used later for per-file comparisons; so test now that glob.glob
            # is producing the same as what "ls" in the shell does (which is
            # probably what the user of "#>" expects)
            cmd = 'ls ' + ot['out']
            try: blsout=run(cmd)
            except subprocess.CalledProcessError as e:
                eprint('%s: (for test "%s") failed to "%s":' % (me, TT, cmd))
                eprint(str(e.output,'utf-8').rstrip())
                eprint('%s: stopping' % me)
                sys.exit(1)
            lsout=[str(l,'utf-8') for l in blsout.stdout.splitlines()]
            ggout=glob.glob(ot['out'])
            if not ggout:
                stop('(for test "%s") filename glob "%s" didn\'t match any files via glob.glob (which NOTE does not do brace expansion)' % (TT, ot['out']))
            if sorted(lsout) != sorted(ggout):
                stop('(for test "%s") filename glob "%s" produced different file lists via shell expansion (%d in %s) versus glob.glob (%d in %s), which is confusing'
                     % (me, ot['out'], len(lsout), lsout, len(ggout), ggout))
            cmd='mv ' + ot['out'] + ' ' + refdir
            try: run(cmd)
            except subprocess.CalledProcessError as e:
                eprint('%s: PANIC: failed to create "%s" reference output; "%s" returned:' % (me, TT, cmd))
                eprint(str(e.output,'utf-8').rstrip())
                eprint('%s: stopping' % me)
                sys.exit(1)
        globprogs(TT, progglobs, progs, texes)
        # "thispass" stays True; failures here are fatal anyway
    else:  # we compare against pre-existing reference outputs
        runs = parallel if parallel else 1
        # remove all outputs from previous run
        run('rm -f out.txt out-??.txt')
        for II in range(runs):
            if not thispass: break
            if parallel:
                # if doing repeated tests, only compile once
                os.environ['DDRO_TARG'] = 'pthread' if II==0 else 'noop'
                OUT='out-%02d.txt' % II
                print('... run %d/%d (%s) ...' % (II, runs, os.environ['DDRO_TARG']))
            else:
                OUT='out.txt'
                if 'DDRO_TARG' in os.environ: del os.environ['DDRO_TARG']
            junk.append(OUT)
            (ret,out)=runsave(OUT)
            if ret:
                eprint('%s: %s FAIL; %s script says (see %s):\n%s'
                       % (me, TT, tsh, refdir + '/out.txt', str(out.stdout,'utf-8')))
                thispass=False
                break
            if not II: # first time through
                globprogs(TT, progglobs, progs, texes)
            if dodiff:
                cmd='diff ' + OUT + ' ' + refdir + '/out.txt'
                try: run(cmd)
                except subprocess.CalledProcessError as e:
                    eprint('%s: "%s" FAIL; "%s" returned:' % (me, TT, cmd))
                    eprint(str(e.output,'utf-8'))
                    thispass=False
                    break
            for ot in outtols:
                for o in glob.glob(ot['out']):
                    if verbose:
                        print('%s: comparing \"%s\" (from \"%s\") to ref' % (me, o, ot['out']))
                    if not II: junk.append(o)
                    # needs teem svn >= r6312
                    cmd='unu diff -q -x %s %s/%s -eps %s' % (o, refdir, o, ot['tol'])
                    try: run(cmd)
                    except subprocess.CalledProcessError as e:
                        eprint('%s: "%s" FAIL; "%s" returned:' % (me, TT, cmd))
                        eprint(str(e.output,'utf-8'))
                        thispass=False
                        # break # by not breaking, all differences are reported
        # end loop over (parallel) runs
    # end else comparing (not generating)
    if thispass:
        if not keepout:
            for f in junk:
                if (verbose): print('%s: rm %s' % (me, f))
                os.remove(f)
        if not keepcod:
            for p in progs:
                torm=[p['prog'] + '.o', p['prog'] + '.cxx']
                if p['tmp']: torm.append(p['prog'] + '.diderot')
                if (verbose): print('%s: rm %s' % (me, ' '.join(torm)))
                for r in torm: os.remove(r)
        execs.extend(texes)
        passed.append(TT)
    else:
        failed.append(TT)

#################################
################################# cleanup and reporting
#################################
# remove generated executables (kept around so that different tests can use
# each others' programs)
if verbose:
    print('%s: final cleanup:' % me)
os.chdir(startdir)
if not keepexe:
    for e in execs:
        if (verbose): print('%s: rm %s' % (me, e))
        os.remove(e)

if not createref:
    eprint('%s: %d/%d tests passed:' % (me, len(passed), len(tests)))
    if passed:
        for p in passed:
            eprint(p)
    if failed:
        eprint('%s: %d/%d tests failed:' % (me, len(failed), len(tests)))
        for f in failed:
            eprint(f)
