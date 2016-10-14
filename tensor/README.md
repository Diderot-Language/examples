## tensor.diderot: demo of some details of how tensors work

In Diderot, vectors (rank-1 tensors), matrices (rank-2 tensors), and
tensors generally are objects with some number of ordered indices.
This program demonstrates how indexing, contracting with either `•` or
`:`, and differentiation fields works with tensors. You can read through
this program's source, and what it prints out, to build your understanding
of how tensors in Diderot work.

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

Note that Diderot does not currently support distinguishing between
covariant and contravariant indices; the assumption is that all tensor
coefficients are measured with respect to an orthonormal coordinate
frame.

