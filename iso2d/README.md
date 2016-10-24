## iso2d.diderot: 2D isocontour sampling by independent (non-interacting) particles

The previous [`fs2d-scl.diderot`](../fs2d) program makes a little dataset
in which we can try to find isosurfaces:

	../fs2d/fs2d-scl -size0 50 -size1 50 -which 3 -width 8 | unu save -f nrrd -o cubic.nrrd

Then compile this program:

	diderotc --exec iso2d.diderot

and try `./iso2d --help` to see the available input variables.  See
the info with [`vimg.diderot`](../vimg) about how Diderot handles input arrays.

To run isocontour sampling (starting with a 100x100 grid of points),
at the default isovalue 0:

	./iso2d -cmin -4 -4 -cmax 4 4 -size 100

This saves the output positions into `pos.nrrd` as a list of 2-vectors, which
can be seen by running `unu head pos.nrrd`. You can convert this to a
text file with `unu save -f text -i pos.nrrd -o pos.txt`.

In any case, Diderot doesn't itself supply a way of visualizing this
point set; some other graphics or plotting program is needed.  A really
quick-and-dirty way of showing the points is as a joint histogram
of their X and Y coordinates:

	unu jhisto -i pos.nrrd -b 500 500 -min -4 4 -max 4 -4 -t float | unu 2op gt - 0 | unu quantize -b 8 -o pos.png

Make sure your `pos.png` looks like [`pos-ref.png`](pos-ref.png); it may
not be an exact pixel match but it should be close.  If `pos.png`
looks very different (or blank), your Teem checkout may be old (a new
fix was committed Nov 5 2015).  Assuming your PNG viewer uses
conventional display orientation, the `-min -4 4 -max 4 -4` arguments
to `unu jhisto` should make the first coordinate ("x") increase to the
right, and the second coordinate ("y") increase towards up.

As noted with the [`vimg.diderot`](../vimg) example, even if you compiled
with one proxy file, you can
supply a different file at run-time, as long as the new file matches
the type and shape of the proxy image.  We can add some noise
to the dataset, and then add a little ramp along the Y axis (to explicitly
break the over-all symmetry of the isocontour):

	unu 2op nrand cubic.nrrd 0.5 -s 42 -o noisy.nrrd
	../fs2d/fs2d-scl -size0 50 -size1 50 -which 1 -width 8 | unu save -f nrrd -o yramp.nrrd
	rm out.nrrd
	unu 2op x yramp.nrrd 3 | unu 2op + noisy.nrrd - -o noisy.nrrd

and then re-run the isocontouring and display on the new data.

	./iso2d -cmin -4 -4 -cmax 4 4 -size 100 -img noisy.nrrd -o pos2
	unu jhisto -i pos2.nrrd -b 500 500 -min -4 4 -max 4 -4 -t float | unu 2op gt - 0 | unu quantize -b 8 -o pos2.png

Make sure your pos2.png looks like [`pos2-ref.png`](pos2-ref.png).

Things to try (to see their effect on the output positions, both the
number of outputs and their location):
* increasing or decreasing `stepsMax`
* increasing or decreasing `epsilon`
* increasing or decreasing `size`; if it goes too low then the program will not have any output
