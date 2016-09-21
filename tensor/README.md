## tensor.diderot: demo of some details of how tensors work

In Diderot, vectors (rank-1 tensors), matrices (rank-2 tensors), and
tensors generally are objects with some number of ordered indices.
This program demonstrates indexing and contraction, with either
`•` or `:`. The printed results can be used to determine how these
depend on index ordering.

Assuming the directions at https://github.com/Diderot-Language/examples
this program can be compiled with:

	../../vis12/bin/diderotc --exec tensor.diderot

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

This program also demonstrates how differentiation increases tensor rank
with the help of a small 3-vector dataset `vec.nrrd`, created with the
help of a [program in a later example, `fs3d-vec`](../fs3d):

	../fs3d/fs3d-vec -width 10 -angle 30 -axis 1 2 3 -which 2 -sz0 30 -sz1 25 -sz2 20 |
	unu save -f nrrd -o vec.nrrd
	rm -f out.nrrd

The vector-valued function sampled by this field over (x,y,z) should be:

	[1.4*x,
	0.2*x + 0.4*x*x + 2*y,
	0.1*x + y*z + 4*z]

This function has an intentionally non-symmetric Jacobian, and some isolated
elements in the second derivative, for the testing purposes here.

Note that things commented out and tagged with `RSN` refer to capabilitites
that should be working hopefully real soon now.
