## vimg.diderot: 2D image sampler/viewer

This program needs a dataset to render, and a colormap, for example:

	ln -s ../data/sscand.nrrd img.nrrd
	ln -s ../cmap/spiralch.nrrd cmap.nrrd

Then compile this program; assuming the directions at
https://github.com/Diderot-Language/examples you can:

	../../vis12/bin/diderotc --exec vimg.diderot

If the needed `img.nrrd` file is missing, the error message looks something like:

	uncaught exception Fail [Fail: Nrrd file "img.nrrd" does not exist]
	  raised at common/phase-timer.sml:78.50-78.52
	  raised at common/phase-timer.sml:78.50-78.52
	  raised at nrrd/nrrd-info.sml:146.15-146.74

in which case you should run the `ln -s` command above, or link `img.nrrd`
to some other 2D scalar nrrd file to view.  The same applies to the need
for `cmap.nrrd` to link to a colormap.

The `-w` option will determine which function is sampled; look
for `(0 == w)` below to see the start of the function definitions.
Some examples are, using the links, given above, of `img.nrrd`
and `cmap.nrrd` to `../data/sscand.nrrd` and `../cmap/spiralch.nrrd`
respectively.
* `./vimg -cent 280 418 -fov 42 -w 0`
* `./vimg -cent 280 418 -fov 42 -w 1`
* `./vimg -cent 280 418 -fov 42 -w 2`
* `./vimg -cent 280 418 -fov 42 -w 3 -cmin -500 -cmax 1900 -iso 1210 -th 18`
* `./vimg -cent 280 418 -fov 42 -w 4 -cmin -500 -cmax 1900 -iso 1210 -th 0.18`

In all cases, one can `unu quantize -b 8 -i rgb.nrrd -o rgb.png` to create
an 8-bit image version of the output.  The `-w 3` and `-w 4` commands show an
important comparison, by demonstrating how knowing the gradient permits
drawing of equal-thickness isocontours (according to the first-order Taylor
expansion).
