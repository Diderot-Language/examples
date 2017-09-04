## tensor2.diderot: more details of how tensors work

This continues the work of [`tensor.diderot`](../tensor), with more
details about how tensors work in Diderot. This uses the [`fs3d-vec.diderot`](../fs3d)
to generate a synthetic vector field `vec.nrrd` for testing.

	../fs3d/fs3d-vec -width 10 -angle 30 -axis 1 2 3 -which foo -sz0 30 -sz1 25 -sz2 20 |
	unu save -f nrrd -o vec.nrrd
	rm -f out.nrrd

With this proxy input in place, we compile with:

	diderotc --exec tensor2.diderot

The vector-valued function sampled by this field over (x,y,z) has an
intentionally non-symmetric Jacobian, and some isolated elements in the second
derivative (an order-3 tensor), for the testing purposes here.
