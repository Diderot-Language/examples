## mip.diderot: basic maximum intensity projection (MIP) volume rendering

Maximum intensity projection is the minimalist volume visualization
tool. This implementation is about as short as possible; much of the code is
spent on specifying and setting up the ray geometry. It can also be adapted
(by changing a line or two) to do other kinds of projections.  The code for
camera geometry and ray sampling will be re-used verbatim in other volume
rendering programs. This may later become a target for evolving Diderot to
support libraries that contain common functionality.

Just like [`iso2d`](../iso2d) depends on first creating a dataset with
[`fs2d-scl`](../fs2d), we need to create a volume dataset with [`fs3d-scl`](../fs3d)
in order to compile this program `mip.diderot`:

	../fs3d/fs3d-scl -which 13 -width 3 -sz0 73 -sz1 73 -sz2 73 | unu save -f nrrd -o vol.nrrd

In this case the volume size is chosen to ensure that the local maxima of
this -which 13 synthetic function, a cube frame with maxima at
(x,y,)=(+-1,+1,+1), are actually hit by grid sample points, which helps
reason about subsequent debugging.  Now we can compile `mip.diderot`;

	../../vis12/bin/diderotc --exec mip.diderot

And then make some pictures:

	./mip -out0 0 -camFOV 20 -rayStep 0.03 -iresU 300 -iresV 300
	unu quantize -b 8 -i out.nrrd -o cube-persp.png
	./mip -out0 0 -camFOV 20 -rayStep 0.03 -iresU 300 -iresV 300 -camOrtho true
	unu quantize -b 8 -i out.nrrd -o cube-ortho.png

Make sure you can run these steps to get the same [cube-persp.png] and [cube-ortho.png].

