# 2D isocontour sampling by independent (non-interacting) particles

First make a little dataset, using ../fs2d/fs2d-scl:

	../fs2d/fs2d-scl -size0 60 -size1 60 -which 3 -width 8 2>&1 | unu save -f nrrd -o cubic.nrrd

Then compile this program; assuming the directions at
https://github.com/Diderot-Language/examples you can:

	../../vis12/bin/diderotc --exec iso2d.diderot

Note that if a Diderot program refers to an image file, that image
file needs to exist at compile time (so that the compiler can generate
instructions specific to the data type and the image orientation). Hence the need to create
cubic.nrrd before running diderotc.  If a needed .nrrd file is missing,
the error message looks like:

	uncaught exception Fail [Fail: Nrrd file "cubic.nrrd" does not exist]
	  raised at common/phase-timer.sml:78.50-78.52
	  raised at common/phase-timer.sml:78.50-78.52
	  raised at nrrd/nrrd-info.sml:146.15-146.74

However, you can supply a different image at run-time, if the image
is noted as an "input" (as below), provided that it exactly matches
the type and shape of the image given at compile-time.
