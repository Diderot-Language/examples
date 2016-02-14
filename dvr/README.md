## dvr.diderot: basic direct volume rendering of scalar field

Note that this example is heavily based on the [`mip`](../mip) example;
some of the variables and code are better documented there.

This program needs a dataset `vol.nrrd` to render; [`fs3d-scl`](../fs3d) is one
way to generate this.  Some examples:
* Sphere:  
   `../fs3d/fs3d-scl -which 4 -width 3 | unu save -f nrrd -o vol.nrrd`
* Ellipse:  
   `../fs3d/fs3d-scl -which 5 -parm 0 3 8 0 | unu save -f nrrd -o vol.nrrd`
* Three-lobed thing:  
   `../fs3d/fs3d-scl -which 9 -width 2 | unu save -f nrrd -o vol.nrrd`

This program also needs a colormap file `cmap.nrrd`, not because a colormap
is required to create a direct volume rendering example, but because its helpful
to demonstrate how one could be used.  For example:

	ln -s ../cmap/isobow.nrrd cmap.nrrd

The program can be compiled, assuming the directions at
https://github.com/Diderot-Language/examples, with:

	../../vis12/bin/diderotc --exec dvr.diderot

Some example invocations, organized according to dataset examples above
(still in-progress...):
* Sphere:  
   `./dvr ...`
* Ellipse:  
   `./dvr ...`
* Three-lobed thing:  
   `./dvr ...`

Note that things commented out and tagged with `RSN` refer to capabilities
that should be working hopefully real soon now.
