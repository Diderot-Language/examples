life.diderot Conway's Game of Life

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
