This program finds square roots of numval reals between minval and maxval
using Heron's method (aka the Babylonion method)
https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method

Assuming the directions at https://github.com/Diderot-Language/examples
this program can be compiled and run with:

	../../vis12/bin/diderotc --exec heron.diderot
	./heron

The output stores four numbers for each value processed:

0. the value whose square root was found
1. the computed square root
2. the number of iterations taken to compute it
3. the error, relative to Diderot's sqrt() function

To see the values (one set of 4 numbers per line):

	unu save -f text -i vrie.nrrd

The command-line executables produced by Diderot have hest-generated
usage infomation; try:

	./heron --help

to see how to set the input values and output filename stem.  Note
that input variables can document their purpose with ("...")
annotations that are included in the --help usage information.

Try experimenting with different values for eps; if it is set too low
the algorithm may not converge.  Compiling with:

	../../vis12/bin/diderotc --double --exec heron.diderot

makes "reals" into doubles, instead of the default single-precision
floats, which permits higher-accuracy results.
