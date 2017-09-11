#!/usr/bin/env python3 -Wdefault

import sys
import argparse
import os
import subprocess
import re
import shutil

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def stop(why):
    eprint('%s: %s; stopping' % (me, why))
    sys.exit(1)

# subprocess.run is from version 3.5
if sys.version_info < (3,5):
    stop('need python3 version >= 3.5')

parser = argparse.ArgumentParser(
    description='Use Diderot to probe image to learn something, like the '
    +'vprobe and gprobe utilities in Teem (upon which many of the '
    +'command-line options here were based).',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-i', metavar='nin', required=True,
                    help='input sampled image',
                    nargs=1)
parser.add_argument('-k', metavar='kind', required=True,
                    help='"kind" of image: currently either '
                    +'"real", "vec3", or "tensor[3,3]"',
                    nargs=1)
parser.add_argument('-kern', metavar='kernel',
                    help='kernel to use to reconstruct image values '
                    +'(one of tent, ctmr, bspln3, bpsln5, c4hexic). The '
                    +'field produced by convolution will be called \"F\", '
                    +'and this kernel is differentiated to get derivatives. '
                    +'This is like the -k00 option to Teem\'s vprobe, but '
                    +'there\'s no ability here to supply different kernels '
                    +'for derivatives.',
                    nargs=1, default='tent')
parser.add_argument('-q', metavar=('type','expr','deriv'), required=True,
                    help='(1) type of query (e.g. real, vec3), '
                    +'(2) the query expression itself, in terms of field F, '
                    +'and (3) the number of derivatives needed, '
                    +'e.g. "vec3 ∇F 1". The query expression will be '
                    +'suffixed with "(pos)" to evaluate at a probe position. '
                    +'You may have to quote the query expression '
                    +'to keep the shell from getting confused. This script '
                    +'isn\'t smart enough to infer the output type or the '
                    +'derivatives needed.',
                    nargs=3)
parser.add_argument('-o', metavar='output', # required=True, no since maybe -pp
                    help='where to save output',
                    nargs=1)
parser.add_argument('-bc', metavar='border control',
                    help='how to handle samples at edge of image '
                    +'(either "none", "mirror", "clamp", or "wrap")',
                    nargs=1, default='none')
parser.add_argument('-nt', metavar='#threads',
                    help='instead of compiling to sequential target, compile '
                    +'to pthread, and run with this number of threads',
                    nargs=1, type=int, default=os.cpu_count())
parser.add_argument('-s', metavar='scl',
                    help='Absent any of the "-p" options, sampling will '
                    +'happen on a grid of equal dimension to the image '
                    +'domain, with the # of samples on each axis being '
                    +'the scaling by the input # samples by this (per-axis) '
                    +'value', nargs='*'); # can't know nargs yet
parser.add_argument('-pg', metavar='probe grid',
                    help='overrides "-s": filename of 2-D nrrd which '
                    +'specifies origin and direction vectors for sampling '
                    +'grid', nargs=1)
parser.add_argument('-pi', metavar='probe locs',
                    help='overrides "-pg": probe at this list of vec3 '
                    +'positions', nargs=1)
parser.add_argument('-pp', metavar='pos',
                    help='overrides "-pi": probe only at this one single '
                    +'location, and print query result there, rather than '
                    +'save to file', nargs='*')  # can't know nargs yet
parser.add_argument('-v', metavar='verbose', help='verbosity level',
                    nargs='?', type=int, const='1', default='0')
parser.add_argument('-op', metavar='name', default='probe',
                    help='name of generated output program; using this '
                    +'option causes the Diderot source and compiled output '
                    +'to be saved, instead of cleaned up at completion. ',
                    nargs=1)
me=sys.argv[0]
args = parser.parse_args()

########### check that diderotc and unu are available
verbose=args.v
def run(wut):
    if verbose: print('%s: running "%s"' % (me, wut))
    res = None
    try:
        res = subprocess.run(wut, check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        eprint('%s: error running "%s":\n%s' % (me, wut, str(e.stdout,'utf-8')))
        eprint('%s: stopping' % me)
        sys.exit(1)
    return res
def checkpath():
    if not shutil.which('diderotc'):
        stop("need \"diderotc\" in path to compile Diderot program")
    version=[str(l,'utf-8') for l in run('diderotc --version').stdout.splitlines()][0]
    if not 'vis15' in version:
        stop("\"diderotc --version\" says \"%s\" but expected vis15" % version)
    if not shutil.which('unu'):
        stop("need \"unu\" in path to learn about input image")
    if verbose:
        print('%s: using %s' % (me, shutil.which('diderotc')))
        print('%s: using %s' % (me, shutil.which('unu')))
checkpath()

########### transform dprobe._ddro with these substitutions:
# _IMG_NAME_: filename of input image
# _IMG_DIM_: dimension of input image's domain
# _IMG_VECN_: type of variable for position in domain (e.g. vec3)
# _IMG_SHAPE_: shape of (tensor) value in each sample of input image
# _BC_OPEN_: either "" for no border control, or, e.g. "clamp("
# _BC_CLOSE_: either "" for no border control, or ")"
# _PROBE_HOW_: specification of how probing happens
# _KERN_: reconstruction kernel
# _QUERY_DERIV_: differentiability requirement for field
# _QUERY_TYPE_: type of the query result (and type of output)
# _QUERY_INIT_: how to initialize output to NaNs
# _QUERY_EXPR_: the query itself, involving field F
# _INSIDE_OPEN_: lacking border control, the inside test, else nothing
# _INSIDE_INDENT_: lacking border control, "   ", else ""
# _INSIDE_CLOSE_: lacking border control, "}", else nothing
# _SINGLE_PRINT_: if probing at only one location, the print statement
# _INITIALLY_: the strand initialization for the program

subs={}
if '-' == args.i[0]:
    stop('sorry, currently can\'t image input from stdin')
subs['_IMG_NAME_'] = args.i[0]
uhead = [str(l,'utf-8').rstrip() for l in run('unu dnorm -h -i ' + args.i[0]).stdout.splitlines()]
for line in uhead:
    if line.startswith('space dimension: '): subs['_IMG_DIM_'] = line.replace('space dimension: ','')
    if line.startswith('dimension: '): DIM = line.replace('dimension: ','')
    if line.startswith('kinds: '): KIND = line.replace('kinds: ','').split(' ')
subs['_IMG_VECN_'] = 'real' if '1' == subs['_IMG_DIM_'] else 'vec'+subs['_IMG_DIM_']
subs['_QUERY_TYPE_'] = args.q[0]
subs['_QUERY_EXPR_'] = args.q[1]
subs['_QUERY_DERIV_'] = args.q[2]
if 'real' == args.q[0]:
    subs['_QUERY_INIT_'] = 'nan'
elif 'vec2' == args.q[0]:
    subs['_QUERY_INIT_'] = 'nan[2]'
elif 'vec3' == args.q[0]:
    subs['_QUERY_INIT_'] = 'nan[3]'
elif 'tensor[2,2]' == args.q[0]:
    subs['_QUERY_INIT_'] = 'nan[2,2]'
elif 'tensor[3,3]' == args.q[0]:
    subs['_QUERY_INIT_'] = 'nan[3,3]'
else:
        stop('Don\'t know how to NaN-initialize query output ' + args.q[0])
subs['_KERN_'] = args.kern
if 'none' == args.bc:
    subs['_BC_OPEN_'] = subs['_BC_CLOSE_'] = ''
    subs['_INSIDE_OPEN_'] = 'if (inside(pos, F)) {'
    subs['_INSIDE_INDENT_'] = '   '
    subs['_INSIDE_CLOSE_'] = '}'
else:
    subs['_BC_OPEN_'] = args.bc[0] + '('
    subs['_BC_CLOSE_'] = ')'
    subs['_INSIDE_OPEN_'] = subs['_INSIDE_CLOSE_'] = subs['_INSIDE_INDENT_'] = ''
if DIM == subs['_IMG_DIM_']:
    subs['_IMG_SHAPE_'] = '[]'
else:
    if ('2-vector' == KIND[0]):
        subs['_IMG_SHAPE_'] = '[2]'
    elif ('3-vector' == KIND[0]):
        subs['_IMG_SHAPE_'] = '[3]'
    elif ('2D-matrix' == KIND[0]):
        subs['_IMG_SHAPE_'] = '[2,2]'
    elif ('3D-matrix' == KIND[0]):
        subs['_IMG_SHAPE_'] = '[3,3]'
    else:
        stop('Don\'t know how to interpret non-scalar kind[0] ' + KIND[0])

if verbose:
    print('%s: will apply substitutions:' % me)
    for k in sorted(subs.keys()):
        print('subs[%s] = %s' % (k, subs[k]))

# _PROBE_HOW_: specification of how probing happens       
# _SINGLE_PRINT_: if probing at only one location, the print statement
# _INITIALLY_: the strand initialization for the program


with open('dprobe._ddro', 'r') as insrc:
    lines = insrc.readlines()

outprog=args.op[0] if isinstance(args.op, list) else args.op
with open(outprog+'.diderot', 'w') as outsrc:
    for line in lines:
        if '/'==line[0] and '/'==line[1]: continue
        for A, B in subs.items():
            line = line.replace(A,B)
        outsrc.write(line)


# compile         
# run             

if not isinstance(args.op, list):
    if verbose:
        print('%s: removing generated files %s{,.diderot,.o,.cxx}' % (me, outprog))
    os.remove(outprog+'.diderot')
    #os.remove(outprog+'.o')
    #os.remove(outprog+'.cxx')
    #os.remove(outprog)

