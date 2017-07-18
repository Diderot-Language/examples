## life.diderot: Conway's Game of Life

[Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
is not in the target domain of the Diderot DSL, but it is a simple
program for demonstrating **strand communication**, a new feature relative
to previous examples. Strands are located in their domain according to a
special variable named `pos`, and strands can learn about nearby strands
via the `sphere` query. Strands have read-only access to the values of
other strands' variables *as they were at the start of the iteration*.
It would take two iterations for information to get from strand, to another,
and back.

Diderot's strand communication was primarily intended for running particle
systems, in which particles are moving around in some domain, dynamically
changing which other strands they interact with, and the program output is a
1-D sequence (or set) of values. In this example, strands do not move,
and do not change their interacting neighbors, and the output is a rectangular
array. The `sphere` query (to find strands within some radius) will always
return the same 8 neighbors.

This example also shows off the **snapshot** mechanism that can be used to
inspect the state of computation at each iteration, by saving the values of
the output variable(s) during execution.  This is enabled by the `--snapshot`
option to the compiler:

	diderotc --snapshot --exec life.diderot

This adds a new `-s` option to the `./life` executable, which controls the
periodicity of snapshots being saved, i.e. `-s 1` means save at every iteration,
`-s 10` means save at every tenth iteration. The default `-s 0` means that no
snapshots are saved.

We can run Life with one of the supplied initial patterns in the `patterns`
subdirectory, like the [Gosper glider
gun](http://www.conwaylife.com/w/index.php?title=Gosper_glider_gun) (as well
as clean up any results from a previous run):

	rm -f state*{nrrd,png}
	./life -s 1 -l 200 -NN 80 -init patterns/gosperglidergun.nrrd

which generates many `state-NNNN.nrrd` files, one for each iteration, starting
with `state-0000.nrrd` to record initialization state before the first iteration.
We can use some `unu` to turn these into an image sequence:

	unu join -i state-*.nrrd -a 2 |
	unu quantize -b 8 |
	unu resample -s x4 x4 = -k box -c cell |
	unu dice -a 2 -ff state-%04d.png -o ./

[ImageMagick](http://www.imagemagick.org)'s `convert` can then make an animated GIF:

	convert -delay 2 state*.png gosperglidergun.gif

The resulting `gosperglidergun.gif` should look the same as the
reference [gosperglidergun-ref.gif](gosperglidergun-ref.gif)
