## fs2d-scl.diderot: utility for generating synthetic scalar 2D datasets

This programs generates synthetic scalar 2D data on regular grids, and
the grids have specific location and orientation in world space.
The input arguments here make it easy to sample the same underlying
function on grids with differing orientation, resolution, and shear.
By using one strand per function evaluation, this is not an efficient
use of Diderot, but it can be nice to have a controlled place to test
the evaluation of Diderot expressions, especially since it prints out
the NRRD header that contains all the orientation meta-data to locate
the sampling grid in a world-space.

Assuming the directions at https://github.com/Diderot-Language/examples
this program can be compiled with:

../../vis12/bin/diderotc --exec fs2d-scl.diderot

The "-which" option will determine which function is sampled; look
for "(0 == which)" below to see the function definitions.
This program is unusual in that its printed output needs to be captured
in order to have a NRRD header that records the orientation of the
sampling grid, so using the program involves redirection.  To
get a self-contained parab.nrrd containing a parabola function
(assuming sh/bash redirection):

./fs2d-scl -which 2  2>&1 | unu save -f nrrd -o parab.nrrd
rm out.nrrd
