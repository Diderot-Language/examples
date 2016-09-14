## dvr.diderot: basic direct volume rendering of a scalar field

Note that this example is heavily based on the [`mip`](../mip)
example, especially for the basic set-up of camera, rays, and strands;
some of the variables and code are better documented there.

This program needs a dataset `vol.nrrd` to render; [`fs3d-scl`](../fs3d) is one
way to generate this.  Some examples:
* Sphere:  
   `../fs3d/fs3d-scl -which 4 -width 5 -sz0 30 -sz1 32 -sz2 35 | unu save -f nrrd -o vol.nrrd`
* XYZ axes indicator:  
   `../fs3d/fs3d-scl -which 12 -width 3.5 -sz0 93 -sz1 94 -sz2 95 | unu crop -min 30 30 30 -max M M M -o vol.nrrd`

The program also uses a univariate colormap `cmap.nrrd` (not for any
important purpose, just to show how it could be used). This can be created
via (here we are desaturating the `isobow.nrrd` colormap):

	unu 3op lerp 0.5 ../cmap/isobow.nrrd 1 -o cmap.nrrd

The program can be compiled, assuming the directions at
https://github.com/Diderot-Language/examples, with:

	../../vis12/bin/diderotc --exec dvr.diderot

Because the program names a default input volume (`vol.nrrd`), compilation
is specialized on the volume data sizes and sample type.  Recompilation
is required to operate on new input data with different sizes or type.

Some example invocations, organized according to dataset examples above
(still in-progress...):
* Sphere:  
   `./dvr -camEye 10 20 5 -camAt 0 0 0 -camUp 0 0 1 \
    -camNear -2 -camFar 2 \
    -camFOV 8 -iresU 400 -iresV 400 \
    -thick 0.1 -refStep 0.1 -rayStep 0.01 \
    -isoval 0.0 -cmin -1 -cmax 1`
* XYZ axes indicator:  
   `./dvr -camEye 3.1 4.0 2.1 -camAt 0.2 0.0 0.4 -camUp 0 0 1 \
      -camNear -0.7 -camFar 0.5 \
      -camFOV 20 -iresU 560 -iresV 480 \
      -thick 0.015 -rayStep 0.005 -maxAlpha 0.95 \
      -isoval 1 -mcnear 1.1 0.9 0.7 -mcfar 0.5 0.7 0.9`

All of these will generate an RGBA image as saved as `rgba.nrrd`, which can be
viewed with another Teem utility (peer to `unu`) called `overrgb`:

	overrgb -i rgba.nrrd -b 1 1 1 -g 1.2 -o out.png

For the sphere dataset (via `fs3d-scl -which 4`), this should produce
[sphere.png](sphere.png).  For the
XYZ axes indicator dataset (via `fs3d-scl -which 12`) this should produce
[axes.png](axes.png); make sure you get the same.

Volume rendering is one setting in which we can make sure Diderot is
doing all the right transformations for measuring derivatives:
derivatives measured in volume index-space have to be transformed to
get the derivative in world-space.  The [`mip`](../mip) example tested
for this kind of invariance in reconstruction of values, but not
derivatives. The following generates three different samplings of a
rotationally symmetric paraboloid dataset, and then renders each of
them with the same parameters, including a little fog to see the shape
of the volume domain itself.  **For this to work as intended**, one must
comment out `field#2(3)[] V = bspln3 ⊛ vol;` and uncomment
`field#1(3)[] V = ctmr ⊛ vol;`: the Catmull-Rom accurately
reconstructs quadratic functions, but the cubic B-spline does not.

	../fs3d/fs3d-scl -which 4 -width 3.8 -sz0 20 -sz1 22 -sz2 25 | unu save -f nrrd -o sphere-0.nrrd
	../fs3d/fs3d-scl -which 4 -width 3.8 -sz0 55 -sz1 29 -sz2 12 -angle -30 | unu save -f nrrd -o sphere-1.nrrd
	../fs3d/fs3d-scl -which 4 -width 3.8 -sz0 30 -sz1 80 -sz2 19 -angle -30 -axis 1 -1 1 -shear 0.5 -0.6 0.9 | unu save -f nrrd -o sphere-2.nrrd
	for I in 0 1 2; do
	   cp sphere-$I.nrrd vol.nrrd
	   echo "compiling with sphere-$I.nrrd ..."
	   ../../vis12/bin/diderotc --exec dvr.diderot
	   echo "rendering with sphere-$I.nrrd ..."
	   ./dvr -camEye 10 20 5 -camAt 0 0 0 -camUp 0 0 1 \
	      -camNear -4 -camFar 4 -camFOV 12 -iresU 400 -iresV 300 \
	      -phongKa 0 -phongKd 0.8 -phongKs 0.3 \
	      -thick 0.03 -rayStep 0.01 \
	      -isoval 0.0 -fog 0.5 0.5 0.5 0.012 -o rgba-$I.nrrd
	   overrgb -i rgba-$I.nrrd -b 1 1 1 -g 1.2 -o sphere-$I.png
	done
	unu join -i sphere-?.png -a 0 -incr | unu slice -a 1 -p 0 -o sphere-compare.png

Looking at the individual `sphere-?.png`, one should see the same sphere
(with the same shading and same specular hightlight), surrounded by different
foggy regions.  These show how `sphere-1.nrrd` is sampled on a rotated grid,
and how `sphere-2.nrrd` is sampled on a rotated and sheared grid.  The
[sphere-compare.png](sphere-compare.png) image puts these three images into
the red, green, and blue channels, providing another way to confirm that
the sphere itself is the same in each.  Try changing the reconstruction kernel
to `c1tent` to see the results of inaccurate reconstruction.

Note that this program approximates the volume rendering integral by updating two
variables at each sample along the ray (going front to back):

	rgb += transp*sampleA*sampleRGB;
	transp *= 1 - sampleA;

where `rgb` is the (pre-multiplied) color of the ray so far, `transp`
is the transparency (1-opacity), and `sampleRGB` and `sampleA` are the
color and opacity of the current sample being composited.  While such
an inner loop is common for volume rendering, one could ask why
couldn't Diderot have figured out how transform a high-level
mathematical statement of the volume rendering integral into such an
implementation.  This is a topic of current research.
