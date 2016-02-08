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

The `-which` option will determine which function is sampled; look
for `(0 == which)` below to see the start of the function definitions.
Assuming the symbolic links given above (of `img.nrrd`
and `cmap.nrrd` to `../data/sscand.nrrd` and `../cmap/spiralch.nrrd`
respectively), some examples usages are:
* `./vimg -cent 290 414 -fov 45 -which 0`
* `./vimg -cent 290 414 -fov 45 -which 1`
* `./vimg -cent 290 414 -fov 45 -which 2`
* `./vimg -cent 290 414 -fov 45 -which 3 -cmin -500 -cmax 1900 -iso 1210 -th 20`
* `./vimg -cent 290 414 -fov 45 -which 4 -cmin -500 -cmax 1900 -iso 1210 -th 0.2`
* `./vimg -cent 290 414 -fov 45 -which 5 -cmin -500 -cmax 1900 -th 0.2 -sthr 2`
* `./vimg -cent 290 414 -fov 45 -which 6 -cmin -500 -cmax 1900 -th 0.2 -sthr 2`
* `./vimg -cent 290 414 -fov 45 -which 7 -cmin -500 -cmax 1900 -th 0.2 -sthr 25 -fcol 1 0 0`
* `./vimg -cent 290 414 -fov 45 -which 8 -cmin -500 -cmax 1900 -th 0.2 -fcol 0 1 0`
* `./vimg -cent 290 414 -fov 45 -which 9 -cmin -500 -cmax 1900 -th 0.2 -sthr 25 -fcol 0 0 1`

In all cases, one can `unu quantize -b 8 -i rgb.nrrd -o rgb.png` to create
an 8-bit image version of the output.  The `-which 3` and `-which 4` commands
show an important comparison, demonstrating how knowing the gradient permits
drawing of equal-thickness isocontours (according to the first-order Taylor
expansion).

Viewing `../data/sscand.nrrd` with the parameters above gives a roughly
100km view of the area around Geilo, Norway, site of the
[Winter School](http://www.sintef.no/projectweb/geilowinterschool/2016-scientific-visualization/)
for which this program was originally created.
