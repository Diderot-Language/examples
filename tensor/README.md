## tensor.diderot: demo of some details of how tensors work

In Diderot, vectors (rank-1 tensors), matrices (rank-2 tensors), and
tensors generally are objects with some number of ordered indices.
This program demonstrates indexing and contraction, with either
`•` or `:`. The printed results can be used to determine how these
depend on index ordering.

Assuming the directions at https://github.com/Diderot-Language/examples
this program can be compiled with:

	../../vis12/bin/diderotc --exec tensor.diderot

Like Mathematica, Diderot doesn't enforce a semantic distinction
between row and column vectors, but the following assumptions should
not create any surprises. In a rank-2 tensor, i.e. a matrix, the first
index is into the rows, and the second index is into the columns.
A matrix is created by `mm = [[a,b,c],[d,e,f],[g,h,i]]`
would conventionally be written as:

	a b c
	d e f
	g h i

This program also demonstrates how differentiation increases tensor rank
with the help of a small 3-vector dataset `vec.nrrd`, created via:

	../fs3d/fs3d-vec -width 10 -angle 30 -axis 1 2 3 -which 2 -sz0 30 -sz1 25 -sz2 20 |
	unu save -f nrrd -o vec.nrrd
	rm -f out.nrrd

The vector-valued function sampled by this field over (x,y,z) should be:

	[1.4*x,
	2*y + 0.2*x + 0.4*x*x,
	4*z + 0.1*x + y*z]

This function has an intentionally non-symmetric Jacobian, and some isolated
elements in the second derivative, for the testing purposes here.

Notes that things commented out and tagged with `RSN` refer to things
that should be working hopefully real soon now.
