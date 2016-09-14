## dvr.diderot: basic direct volume rendering of scalar field

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
   `./dvr -camEye 3.1 4.0 2.1       -camAt 0.2 0.0 0.4       -camUp 0 0 1       -camNear -0.7 -camFar 0.5       -camFOV 20 -iresU 560 -iresV 480       -thick 0.03 -rayStep 0.005 -maxAlpha 1 -transp0 0.01       -isoval 1 -litdir -1 -2 -1 -mcnear 1.2 1.0 0.8 -mcfar 0.5 0.7 0.9`
