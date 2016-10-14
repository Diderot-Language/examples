## heron.diderot: Computing square roots via Heron's method

This program finds square roots of numval reals between minval and maxval
using Heron's method (aka the Babylonion method)
https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method

After compiling, you can run this program with:

	./heron

The output stores four numbers for each value processed (by index along fast axis):
<ol start=0>
<li> the value whose square root was found
<li> the computed square root
<li> the number of iterations taken to compute it
<li> the error, relative to Diderot's sqrt() function
</ol>
To see the values (one set of 4 numbers per line):

	unu save -f text -i vrie.nrrd

You can see that with the defaults, it took at most 7 iterations to converge:

	unu slice -i vrie.nrrd -a 0 -p 2 | unu minmax -

The command-line executables produced by Diderot have hest-generated
usage infomation. Try:

	./heron --help

to see how to set the input values and output filename stem.  Note
that the input variables self-document their purpose with ("...")
annotations, which are in turn included in the generated `--help`
usage information.  So the declarations:

	input real minval ("min value to find root of") = 1;
	input real maxval ("max value to find root of") = 100;
	input int numval ("how many values to compute") = 100;
	input real eps ("relative error convergence test") = 0.000001;

become in the usage information:

	  -minval <x> = min value to find root of (double); default: "1"
	  -maxval <x> = max value to find root of (double); default: "100"
	-numval <int> = how many values to compute (long int); default: "100"
	     -eps <x> = relative error convergence test (double); default: "1e-06"

There are also command-line options that are unrelated to input variables:

	     -l <int> , --limit <int> = specify limit on number of super-steps (0
	                means unlimited) (unsigned long int); default: "0"
	 -print <str> = specify where to direct printed output (string); default: "-"
	           -v , --verbose = enable runtime-system messages
	           -t , --timing = enable execution timing

heron.diderot shows the value of `-l` option. If you try to increase the precision
of the result by lowering `eps`, as with:

	./heron -eps 1e-7

The program may not ever finish, because the limited precision of 32-bit
floats prevents the computation from reaching sufficient accuracy. So, noting
from above that at most 7 iterations were needed with the default `eps`, we
can run:

	./heron -eps 1e-7 -l 20

which will finish promptly. On the other hand, we can also increase the precision
of a Diderot `real` itself by making reals into a C `double`.  This is possible
by compiling with:

	diderotc --double --exec heron.diderot

at which point `./heron -eps 1e-7` will finish.
