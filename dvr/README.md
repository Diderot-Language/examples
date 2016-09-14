## dvr.diderot: basic direct volume rendering of a scalar field

Note that this example is heavily based on the [`mip`](../mip)
example, especially for the basic set-up of camera, rays, and strands;
some of the variables and code are better documented there.

This program needs a dataset `vol.nrrd` to render; [`fs3d-scl`](../fs3d) is one
way to generate this.  Some examples:
* Sphere:  
   `../fs3d/fs3d-scl -which 4 -width 3 | unu save -f nrrd -o vol.nrrd`
* XYZ axes indicator:  
   `../fs3d/fs3d-scl -which 12 -width 3.5 -sz0 93 -sz1 94 -sz2 95 | unu crop -min 30 30 30 -max M M M -o vol.nrrd`

The program also uses a univariate colormap `cmap.nrrd` (not for any
important purpose, just to show how it could be used). This can be created
via:

	cp ../cmap/isobow.nrrd cmap.nrrd

The program can be compiled, assuming the directions at
https://github.com/Diderot-Language/examples, with:

	../../vis12/bin/diderotc --exec dvr.diderot

Some example invocations, organized according to dataset examples above
(still in-progress...):
* Sphere:  
   `./dvr ...`
* XYZ axes indicator:  
   `./dvr -camEye 3.1 4.0 2.1 -camAt 0.2 0.0 0.4 -camUp 0 0 1       -camNear -0.7 -camFar 0.5       -camFOV 20 -iresU 560 -iresV 480       -thick 0.015 -rayStep 0.005 -maxAlpha 0.95       -isoval 1 -litdir -1 -2 -1 -mcnear 1.1 0.9 0.7 -mcfar 0.5 0.7 0.9`

All of these will generate an RGBA image as saved as `rgba.nrrd`, which can be
viewed with another Teem utility (peer to `unu`) called `overrgb`:

	overrgb -i rgba.nrrd -b 1 1 1 -g 1.2 -o out.png

For the XYZ axes indicator dataset (via `fs3d-scl -which 12`) this should produce
[axes.png](axes.png); make sure you get the same.

Note that this program approximates the volume rendering integral by updating two
variables at each sample along the ray (going front to back):

	rgb += transp*sampleA*sampleRGB;
	transp *= 1 - sampleA;

where `rgb` is the (pre-multiplied) color of the ray so far (going
front-to-back), `transp` is the transparency (1-opacity) of the ray so
far, and `sampleRGB` and `sampleA` are the color and opacity of the
current sample being composited.  While such an inner loop is common
for volume rendering, one could ask why couldn't Diderot have figured
out how transform a high-level mathematical statement of the volume
rendering integral into such an implementation.  This is a topic of
current research.
