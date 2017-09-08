## sphere.diderot: Mutually-repelling particles populating a unit sphere

This is heavily based on the [`circle.diderot`](../circle) example; see that
program for more detailed and explanatory comments. The new things added with
this example are documented in comments below. A significant capability
demonstrated here is "population control", whereby particles create new
particles (using `new`) if there seem to be too few, or die if there are too
may (using `die`).  Along with this there is a new variable `undone` that acts
as a crude signal (to the global update method monitoring the computation)
that things are unfinished because the system population is changing.

Like the [`circle.diderot`](../circle) example, we use snapshots to inspect
the system state as it progresses, and compile with `--double` for better
precision:

	diderotc --snapshot --double --exec sphere.diderot

The following creates a list of `N` randomly oriented unit-length 3-vectors in
`vec3.nrrd` which will be the initial input.  Setting the random number seed
of `unu 1op nrand` with `-s RNG` ensures reproducible results, or you can
leave that out to give different results each time.

	N=2
	RNG=1
	echo 0 0 0 | unu pad -min 0 0 -max M $((N-1)) | unu 1op nrand -s $RNG -o vec3.nrrd
	unu project -i vec3.nrrd -a 0 -m l2 | unu axinsert -a 0 -s 3 | unu 2op / vec3.nrrd - -o vec3.nrrd

Then to run with snapshots saved every iteration (`-s 1`), but limiting the program
to 400 iterations (`-l 400`), as well as cleaning results from previous run:

	rm -f pos-????.{png,nrrd} pos.nrrd
	./sphere -s 1 -l 400 -rad 0.15 -eps 0.033 -pcp 2

This should converge in under 500 iterations, many `pos-????.nrrd` files.
The interaction radius `-rad 0.15` can be decreased to create a denser
(though more computationally expensive) result; increasing it makes it sparser.
The following unu hackery processes this into corresponding `pos-????.png` images.
The images are 2*SZ by SZ, computed as a joint histogram of coordinates,
with oversampling OV (higher values improves anti-aliasing).

	SZ=350
	OV=2
	export NRRD_STATE_VERBOSE_IO=0
	for PIIN in pos-????.nrrd; do
	   IIN=${PIIN#*-}
	   II=${IIN%.*}
	   echo "post-processing $PIIN to pos-$II.png ... "
	   unu dice -i $PIIN -a 0 -o ./
	   unu 2op gt 2.nrrd 0 | # 1 if in lower hemisphere
	   unu 2op x - 2.1 |     # 2.1 if in lower hemisphere
	   unu 2op + - 0.nrrd |  # add to x component
	   unu jhisto -i - 1.nrrd -min -1.05 -1.05 -max 3.15 1.05 -b $((OV*SZ*2)) $((SZ*OV)) |
	   unu resample -s /$OV /$OV -k bspln5 -t float |
	   unu quantize -b 8 -min 0 -max $(echo "0.15 / ($OV * $OV)" | bc -l) -o pos-$II.png
	done
	rm -f {0,1,2}.nrrd

Note that while we are post-processing results after the computation is
finished, these snapshots are produced **while** the computation is
running. When compiling Diderot programs to a library, the API makes the
snapshots available between iterations. Also, the sort of unu hacking used
above is not actually a required part of using Diderot; the aim here is just
to producing something informative with the minimal number of software tools.
For fun we make an animated GIF of the results with [ImageMagick](http://www.imagemagick.org)'s `convert`:

	convert -delay 6 pos*.png sphere-spread.gif

The resulting `sphere-spread.gif`
(c.f. [`ref-sphere-spread.gif`](ref-sphere-spread.gif)) shows how the
population control worked to go from 2 to hundreds of particles.  On the other
hand, if the initial data commands above had started with `N=8000`, the
resulting animation `sphere-decim.gif`
(c.f. [`ref-sphere-decim.gif`](ref-sphere-decim.gif)) shows how the system
responds to starting with too many particles, by decimating the population to
arive at roughly the same number of points as when starting with `N=2`.

