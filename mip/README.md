## mip.diderot: basic maximum intensity projection (MIP) volume rendering

Maximum intensity projection is the minimalist volume visualization tool. This
implementation is about as short as possible; much of the code is spent on
specifying and setting up the ray geometry. It can also be adapted (by
changing a line or two) to do other kinds of projections.  The code for camera
geometry and ray sampling will be re-used verbatim in other volume rendering
programs. This may later become a target for evolving Diderot to support
libraries that contain common functionality. Note that the explicitly
pedagogical nature of this example means that some unusual usages are required
(like recompiling the program multiple times for different datasets).

Just like [`iso2d`](../iso2d) depends on first creating a dataset with
[`fs2d-scl`](../fs2d), we need to create a volume dataset with [`fs3d-scl`](../fs3d)
in order to compile this program `mip.diderot`:

	../fs3d/fs3d-scl -which cube -width 3 -sz0 73 -sz1 73 -sz2 73 | unu save -f nrrd -o cube.nrrd

In this case the volume size is chosen to ensure that the local maxima of
this -which cube synthetic function, a cube frame with maxima at
(x,y,z)=(+-1,+1,+1), are actually hit by grid sample points, which helps
reason about subsequent debugging.  We can inspect the volume by tiled slicing
in `unu` to make [cube-tile.png](cube-tile.png):

	unu pad -i cube.nrrd -min 0 0 0 -max M M 79 |
	  unu tile -a 2 0 1 -s 10 8 |
	  unu quantize -b 8 -o cube-tile.png

We copy `cube.nrrd` to `vol.nrrd`, so that `mip.diderot` can see it in its
default location (in the current directory), and then we can compile
`mip.diderot`:

	cp cube.nrrd vol.nrrd
	diderotc --exec mip.diderot

And then make some MIP renderings:

	./mip -out0 0 -camFOV 20 -rayStep 0.03 -iresU 300 -iresV 300
	unu quantize -b 8 -i out.nrrd -o cube-persp.png
	./mip -out0 0 -camFOV 20 -rayStep 0.03 -iresU 300 -iresV 300 -camOrtho true
	unu quantize -b 8 -i out.nrrd -o cube-ortho.png

Make sure you can run these steps to get the same
[cube-persp.png](cube-persp.png) and [cube-ortho.png](cube-ortho.png).  The
only difference in the second image is the use of orthographic instead of
perspective projection, which is apparent in the result.  The `-out0 0`
initialization of the MIP accumulator is safe because `unu minmax cube.nrrd`
reports that the minimum value is 0; this avoids an extra `unu 2op exists`
step.

The usual parameters in volume rendering can be set by command-line options.
This sampling of the various options is not exhaustive; you should try more
yourself.  For the purposes of this demo we set a (shell) variable to store
repeatedly used options, which can be over-ridden later in the command-line.

	OPTS="-out0 0 -camFOV 20 -rayStep 0.03 -iresU 300 -iresV 300"
	./mip $OPTS -camAt 1 1 1;  unu quantize -b 8 -i out.nrrd -o cube-111.png
	./mip $OPTS -camFOV 30;    unu quantize -b 8 -i out.nrrd -o cube-wide.png
	./mip $OPTS -rayStep 0.3;  unu quantize -b 8 -i out.nrrd -o cube-sparse.png
	./mip $OPTS -camFar 0;     unu quantize -b 8 -i out.nrrd -o cube-farclip.png
	./mip $OPTS -camEye 7 7 7; unu quantize -b 8 -i out.nrrd -o cube-eyefar.png

Make sure that these commands generate similar [cube-111.png](cube-111.png),
[cube-wide.png](cube-wide.png), [cube-sparse.png](cube-sparse.png),
[cube-farclip.png](cube-farclip.png), and [cube-eyefar.png](cube-eyefar.png)
for you, and also make sure that you understand why the results look the way they do.

Aside from camera and ray parameters, we now have a basis for testing that
field reconstruction can be invariant with respect to the details of the
sampling grid. We first sample a quadratic function in a few different ways
on a very low resolution grid (which is translating and rotating across these
four datasets):

	../fs3d/fs3d-scl -which dparab -sz0 10 -sz1 10 -sz2 10 | unu save -f nrrd -o parab0.nrrd
	../fs3d/fs3d-scl -which dparab -sz0 10 -sz1 10 -sz2 10 -angle 30 -off 0.25 0.25 0.25 | unu save -f nrrd -o parab1.nrrd
	../fs3d/fs3d-scl -which dparab -sz0 10 -sz1 10 -sz2 10 -angle 60 -off 0.05 0.50 0.50 | unu save -f nrrd -o parab2.nrrd
	../fs3d/fs3d-scl -which dparab -sz0 10 -sz1 10 -sz2 10 -angle 90 -off 0.75 0.75 0.75 | unu save -f nrrd -o parab3.nrrd

Then, using `mip.diderot` as it is, with the

	field#0(3)[] F = vol ⊛ tent;

field reconstruction line in effect (i.e. **not** commented out),
we recompile for the new data size
(shared by all `parab?.nrrd`), and then run some shell commands:

	cp parab0.nrrd vol.nrrd
	diderotc --exec mip.diderot
	OPTS="-out0 0 -inSphere true -camOrtho true -camEye 8 0 0 -camFOV 15 -rayStep 0.01 -iresU 300 -iresV 300"
	for I in 0 1 2 3; do
	  echo === $I ====
	  ./mip $OPTS -vol parab${I}.nrrd
	  unu quantize -b 8 -min 0 -max 1 -i out.nrrd -o parab${I}-tent.png
	done

This makes orthographic MIPs of the four low-res parab?.nrrd datasets, producing
images that reveal the underlying sampling grid:
[parab0-tent.png](parab0-tent.png),
[parab1-tent.png](parab1-tent.png),
[parab2-tent.png](parab2-tent.png),
[parab3-tent.png](parab3-tent.png).

The fact that these images differ means that the quadratic function sampled
by `fs3d-scl -which dparab` is not exactly reconstructed by the `tent`
reconstruction kernel.  If the reconstruction had been exact, then the
rendering would have been entirely determined by the underlying quadratic
function, rather than the particulars of the sampling grid.  Note that the
`inSphere` parameter is important here: it ensures that the region rendered
(the sphere) has the same rotational symmetry as the quadratic function
itself.

Now **we change one line of code below**, so that only the

	field#1(3)[] F = vol ⊛ ctmr;

field definition is in effect (commenting out `field#0(3)[] F = vol ⊛ tent;`).
This changes the reconstruction kernel the Catmull-Rom cubic interpolating
spline, which can accurately reconstruct quadratic functions.  Then we
recompile and re-run the commands above, but saving the results to
differently-named images.

	diderotc --exec mip.diderot
	OPTS="-out0 0 -inSphere true -camOrtho true -camEye 8 0 0 -camFOV 15 -rayStep 0.01 -iresU 300 -iresV 300"
	for I in 0 1 2 3; do
	  echo === $I ====
	  ./mip $OPTS -vol parab${I}.nrrd
	  unu quantize -b 8 -min 0 -max 1 -i out.nrrd -o parab${I}-ctmr.png
	done

This generates four new images:
[parab0-ctmr.png](parab0-ctmr.png),
[parab1-ctmr.png](parab1-ctmr.png),
[parab2-ctmr.png](parab2-ctmr.png),
[parab3-ctmr.png](parab3-ctmr.png).

As should be visually clear, these images are all the same (or very nearly
so), demonstrating the accuracy of the Catmull-Rom spline for quadratic
functions.

Things to try by further modifications of this program:
* Change the rendering from being a maximum intensity, to a summation intensity
(e.g. `out += F(pos)`). Make sure `out0` is zero.
* Change rendering to be mean intensity, which requires adding a counter to
count the number of samples of current ray inside the volume.
* Change the rendering to summating of gradient magnitude
(e.g. `out += |∇F(pos)|`).
* Change the rendering to generate a `vec3` output summing gradient vectors
(e.g. `out += ∇F(pos)`).  Type of `out` must be `vec3`, initialized to `[0,0,0]`.

