## tensor.diderot: demo of some details of how tensors work

In Diderot, vectors (rank-1 tensors), matrices (rank-2 tensors), and
tensors generally are objects with some number of ordered indices.
The semantics of operations like indexing and contraction, with either
`•` or `:`, depend on the index ordering, as demonstrated by the
statements here.

Like Mathematica, Diderot doesn't create or support a semantic
distinction between row and column vectors, but the following assumptions
should not create any surprises. In a rank-2 tensor, i.e. a matrix,
the first index is into the rows, and the second index is into the columns.
Indexing starts at 0. A matrix is created by `mm = [[a,b,c],[d,e,f],[g,h,i]]`
would conventionally be written as:

	a b c
	d e f
	g h i

This program demonstrates how differentiation increases tensor rank
with the help of a small 3-vector dataset `vec.nrrd`, created via:
with a Jacobian that is intentionally non-symmetric for demonstration purposes.

Notes that things commented out and tagged with `RSN` refer to things
that should be working hopefully real soon now.

