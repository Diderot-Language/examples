#!/usr/bin/env python3
import sys
import argparse
import os
import subprocess
import re
import glob

# explicitly listing these, rather than discovering which directories have
# .test.sh scripts, so that we can encode here dependencies (e.g. anything
# that depends on fs2d or fs3d has to come after them)
TESTS=[
'hello',
'heron',
'sieve',
'life',
'steps',
'unicode',
'plot1d',
'tensor',
'sphere',
'vimg',
'fs2d',
'iso2d',
'halftone'
]

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

#TODO: valgrind commands starting with "./"
#TODO: maybe compile with --double ( --long-int, --scalar)

outFileTol='#>' # HEY sync with gen-readme.sh
oftre=re.compile('^' + outFileTol + ' *')

ignoreOutDotTxt='^#I' # HEY sync with gen-readme.sh
iodtre=re.compile('^' + ignoreOutDotTxt)

tmpProgName="#tmp"; # HEY sync with gen-readme.sh
tpnre=re.compile('^' + tmpProgName + ' *')

progName="#prog"; # HEY sync with gen-readme.sh
pnre=re.compile('^' + progName + ' *')

ddrcwre=re.compile('^\[.*\.diderot.*\] Warning: ') # pattern for warnings from diderotc


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

parser = argparse.ArgumentParser(description='Run tests generated from Diderot examples')
parser.add_argument('-v', action='store_true', help='verbose mode')
parser.add_argument('-g', action='store_true',
                    help='generate reference results, rather than compare against them')
parser.add_argument('-ke', action='store_true',
                    help='keep diderotc-generated executables, even when test passes, instead of cleaning them up')
parser.add_argument('-ko', action='store_true',
                    help='keep computed outputs, even when test passes, instead of cleaning them up')
parser.add_argument('-kc', action='store_true',
                    help='keep .o and .cxx (and .diderot for tmps) files, even when test passes, instead of cleaning them up')
parser.add_argument('-p', metavar='#runs',
                    help='instead of compile to sequential target, compile to pthread, and run this number of times',
                    nargs=1, type=int)
parser.add_argument('-r', metavar='refdir',
                    help='directory containing all reference outputs, in one subdirectory per test',
                    nargs=1, required=True)
parser.add_argument('test', nargs='*')
args = parser.parse_args()
verbose=args.v
generate=args.g
keepexe=args.ke
keepout=args.ko
keepcod=args.kc
parallel=args.p[0] if args.p else 0
refroot=args.r[0]
tests=args.test if args.test else TESTS
me=sys.argv[0]
tsh='.test.sh'

if parallel and generate:
    eprint(me+': cannot use -p and -g at the same time; stopping')
    sys.exit(1)

if not os.path.isdir(refroot):
    eprint(me+': reference root directory "%s" does not exist; stopping' % refroot)
    sys.exit(1)
refroot=os.path.abspath(refroot)
startdir = os.getcwd()

def run(wut):
    if verbose: print('%s: running "%s" in %s' % (me, wut, os.getcwd()))
    return subprocess.run(wut, check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def runsave(outname):
    os.remove(outname) if os.path.exists(outname) else None
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
        # dropping diderotc warnings because in case of parallel testing, they
        # are seen only on the first pass (and the difference in presence of
        # warning shouldn't be an error), and because they aren't really the
        # object of testing anyway
        flines=[l for l in slines if not ddrcwre.match(l)]
        f.write('\n'.join(flines))
        f.write('\n') # final newline
    return ret

def globprogs(TT, globs, progs, execs):
    for pg in globs:
        pds = glob.glob(pg['prog'])
        if not pds:
            eprint('%s: FAILed (in "%s") to find files matching glob %s; stopping' % (me, TT, pg))
            sys.exit(1)
        # array of the executable names
        ps = [ re.sub(r'\.diderot', '', pd) for pd in pds ]
        progs.extend([{'prog': p, 'tmp': pg['tmp']} for p in ps])
        # will clean execs regardless of tmp-ness, but need full path
        execs.extend([os.path.abspath(p) for p in ps])
    if verbose:
        print('%s: progs=' % me, progs)
        print('%s: execs=' % me, execs)

execs=[]
failed=[]
passed=[]
for TT in tests:
    os.chdir(startdir)
    if not os.path.isdir(TT):
        eprint(me+': test directory "%s" does not exist; stopping' % TT)
        sys.exit(1)
    refdir = refroot + '/' + TT
    if not os.path.isfile(TT + '/' + tsh):
        eprint(me+': test directory "%s" has no "%s" test script; stopping' % (TT, tsh))
        sys.exit(1)
    if not os.path.isdir(refdir):
        print(me+': creating directory "%s"' % refdir)
        os.makedirs(refdir)
    print(TT, '..................................')
    outtols=[]
    progglobs=[]
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
        eprint('%s: %s/%s did not declare prog names w/ %s or %s; stopping'
               % (me, TT, tsh, progName, tmpProgName))
        sys.exit(1)
    if verbose:
        print('%s: outtols=' % me, outtols)
        print('%s: progglobs=' % me, progglobs)
    progs=[]
    junk=[]
    thispass=True
    if generate:
        if runsave(refdir + '/out.txt'):
            eprint('%s: PANIC: failed to run test script; see %s' % (me, refdir + '/out.txt'))
            sys.exit(1)
        # done running script, now move outputs
        for ot in outtols:
            cmd='mv ' + ot['out'] + ' ' + refdir
            if verbose: print('%s: running "%s"' % (me, cmd))
            try:
                run(cmd)
            except subprocess.CalledProcessError as e:
                eprint('%s: PANIC: failed to generate "%s" reference output; "%s" returned:' % (me, TT, cmd))
                eprint(str(e.output,'utf-8').rstrip())
                eprint('%s: stopping' % me)
                sys.exit(1)
        globprogs(TT, progglobs, progs, execs)
        # "thispass" stays True; failures here are fatal anyway
    else:  # we compare against pre-existing reference outputs
        if not os.path.isfile(refdir + '/out.txt'):
            eprint(me+': missing reference "%s"; need to run with -g; stopping' % (refdir + '/out.txt'))
            sys.exit(1)
        runs = parallel if parallel else 1
        for II in range(runs):
            if not thispass: break
            if parallel:
                # if doing repeated tests, only compile once
                os.environ['DDRO_TEST'] = 'pthread' if II==0 else 'noop'
                OUT='out-%02d.txt' % II
                print('... run %d/%d (%s) ...' % (II, runs, os.environ['DDRO_TEST']))
            else:
                OUT='out.txt'
                if 'DDRO_TEST' in os.environ: del os.environ['DDRO_TEST']
            junk.append(OUT)
            if runsave(OUT):
                eprint('%s: "%s" FAIL; %s returned:' % (me, TT, tsh))
                thispass=False
                break
            if not II: # first time through
                globprogs(TT, progglobs, progs, execs)
            if dodiff:
                cmd='diff ' + OUT + ' ' + refdir + '/out.txt'
                try:
                    run(cmd)
                except subprocess.CalledProcessError as e:
                    eprint('%s: "%s" FAIL; "%s" returned:' % (me, TT, cmd))
                    eprint(str(e.output,'utf-8'))
                    thispass=False
                    break
            for ot in outtols:
                for o in glob.glob(ot['out']):
                    if not II: junk.append(o)
                    # needs teem svn >= r6312
                    cmd='unu diff -q -x %s %s/%s -eps %s' % (o, refdir, o, ot['tol'])
                    try:
                        run(cmd)
                    except subprocess.CalledProcessError as e:
                        eprint('%s: "%s" FAIL; "%s" returned:' % (me, TT, cmd))
                        eprint(str(e.output,'utf-8'))
                        thispass=False
                        break
        # done looping over (parallel) runs
        if not thispass:
            break # so that all artifacts of problem remain as is
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
        passed.append(TT)
    else:
        failed.append(TT)

#final cleanup of generated executables (kept around so that different
#tests can use each others' programs)
if verbose:
    print('%s: final cleanup:' % me)
os.chdir(startdir)
if not keepexe:
    for e in execs:
        if (verbose): print('%s: rm %s' % (me, e))
        os.remove(e)

if not generate:
    eprint('%s: %d/%d tests passed:' % (me, len(passed), len(tests)))
    if passed:
        for p in passed:
            eprint(p)
    eprint('%s: %d/%d tests failed:' % (me, len(failed), len(tests)))
    if failed:
        for f in failed:
            eprint(f)
