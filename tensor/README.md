## tensor.diderot: demo of some details of how tensors work

In Diderot, vectors (rank-1 tensors), matrices (rank-2 tensors), and tensors
generally are objects with some number of ordered indices.  This program
demonstrates tensor construction, indexing, and contracting with either `•` or
`:`.

Like Mathematica, Diderot doesn't enforce a semantic distinction between
row and column vectors; tensor indices are ordered, and the semantics of
tensor operations depends on that order. Still, we can assume for the sake
of familiarity that in a rank-2 tensor, i.e. a matrix, the first index
selects the row, and the second index selects the column.  A matrix created
by `mm = [[a,b,c],[d,e,f],[g,h,i]]` would conventionally be written as:

	a b c
	d e f
	g h i

The first row is `mm[0,:]`, the first column is `mm[:,0]`, and
`b == mm[0,1]` (row 0 and column 1).

Reading through this program's source alongside what it prints out can help
build understanding of how tensors in Diderot work, which is basically the
same way they work in other languages that support higher-order tensors. The
program ends with a demonstration of how, when saved out to files, tensor
indices are ordered slow to fast.

Note that Diderot does not currently support distinguishing between
covariant and contravariant indices; the assumption is that all tensor
coefficients are measured with respect to an orthonormal coordinate
frame.
