## sieve.diderot: Sieve of Eratosthenes

The [Sieve of Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes)
is really not the sort of algorithm that Diderot is designed for, and this is not a particularly
efficient implementation. However, this is a simple way to demonstrate
three Diderot language feaures not shown in previous examples:
1. By executing `die`, strands exit the computation without saving their output.
2. The `global` update block contains code to run between per-strand updates.
3. The `global` update can use global reductions to compute properties of the set of extent strands.

This program takes one input int `NN`, the highest number to test for
primality.  Execution starts by creating strands for every integer from 2 to
NN. At each iteration, one strand may stabilize (and save its value `pp`) if
it is the next prime; otherwise strands die off if they are a multiple of the
most recent prime found. The global update looks through the remaining strands
to find the smallest value, which is the next prime.

Try adding `print()` statements to the program (either within the strand
`update` or the `global` update) to clarify which strands are active
for which iteration, and when they die off.

After running the program with `./sieve` or, say, `./sieve -NN 1000`, the
output can be shown with:

	unu save -f text -i pp.nrrd

