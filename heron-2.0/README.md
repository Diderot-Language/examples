## heron.diderot: Computing square roots via Heron's method

*This is a revision of the [heron](../heron) example that uses
version 2.0 of the Diderot syntax.*

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
To see the output (four numbers per line):

	unu save -f text -i vrie.nrrd

You can see that with the defaults, it took at most 7 iterations to converge:

	unu slice -i vrie.nrrd -a 0 -p 2 | unu minmax -

The command-line executables produced by Diderot have hest-generated
usage infomation. Try:

	./heron --help

to see how to set the input values and output filename.  Note
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

heron.diderot shows the utility of `-l` option to limit the number of iterations
(called "super-steps" in Diderot) for which the computation can run. If you try to increase the precision
of the result by lowering `eps`, as with:

	./heron -eps 1e-8

The program may not ever finish, because the limited precision of 32-bit
floats prevents the computation from reaching sufficient accuracy. So, noting
from above that at most 7 iterations were needed with the default `eps`, we
can try limiting the computation at something higher than 7:

	./heron -eps 1e-8 -l 20

This will finish promptly, after 20 iterations. The initialization of the program output variable
with:

	output vec4 vrie = [val,-1,-1,-1];
makes clear which strands never stabilized because they were halted by the `-l
20` limit. When you view the output from the command above with `unu save -f
text -i vrie.nrrd`, you'll see lines like:

	89 -1 -1 -1
	90 -1 -1 -1
	91 -1 -1 -1

for the values where the algorithm didn't converge.
The consequences of active strands being halted by an iteration limit is
different for strand **collections** vs strand **arrays**.  If the program runs
as a collection of strands, i.e., the last line of the program is instead

	create_collection { sqroot(lerp(minval, maxval, 1, ii, numval)) | ii in 1 .. numval }

(note `create_collection` instead of `create_array`), then running `./heron -eps
1e-8 -l 20` will still finish after 20 iterations, but no output values will
be saved for those strands that didn't stabilize in time.  That is, `unu save -f text
-i vrie.nrrd` will produce fewer than 100 lines of text, including only the
values for which the algorithm converged with 20 iterations or fewer.

On the other hand, we can also increase the precision of a Diderot
`real` itself by using a C `double` to store a `real`, instead of a (single-precision) `float`,
the default.  We do this by compiling with:

	diderotc --double --exec heron.diderot

at which point `./heron -eps 1e-8` will finish, with every strand producing a
more accurate answer.
