## vimg.diderot: 2D image sampler/viewer

This program needs a dataset to render, and a colormap, for example:

	ln -s ../data/sscand.nrrd img.nrrd
	ln -s ../cmap/spiral.nrrd cmap.nrrd

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
and `cmap.nrrd` to `../data/sscand.nrrd` and `../cmap/spiral.nrrd`
respectively), some examples usages are:
* Grayscale image of reconstructed field:  
   `./vimg -cent 290 414 -fov 45 -which 0`
* Grayscale image of gradient magnitude:  
   `./vimg -cent 290 414 -fov 45 -which 1`
* Color image of gradient vector (blue is always zero):  
   `./vimg -cent 290 414 -fov 45 -which 2`
* Colormapped field, with naive pseudo-isocontour:  
   `./vimg -cent 290 414 -fov 45 -which 3 -cmin -500 -cmax 1900 -iso 1210 -th 20`
* Colormapped field, with smarter pseudo-isocontour:  
   `./vimg -cent 290 414 -fov 45 -which 4 -cmin -500 -cmax 1900 -iso 1210 -th 0.2`
* Colormapped field, with ridge lines:  
   `./vimg -cent 290 414 -fov 45 -which 5 -cmin -500 -cmax 1900 -th 0.2 -sthr 2`
* Colormapped field, with valley lines:  
   `./vimg -cent 290 414 -fov 45 -which 6 -cmin -500 -cmax 1900 -th 0.2 -sthr 2`
* Colormapped field, with blue maxima:  
   `./vimg -cent 290 414 -fov 45 -which 7 -cmin -500 -cmax 1900 -th 0.25 -sthr 25 -fcol 0 0 0.8`
* Colormapped field, with green saddle points:  
   `./vimg -cent 290 414 -fov 45 -which 8 -cmin -500 -cmax 1900 -th 0.25 -fcol 0 1 0`
* Colormapped field, with cyan minima:  
   `./vimg -cent 290 414 -fov 45 -which 9 -cmin -500 -cmax 1900 -th 0.25 -sthr 25 -fcol 0 1 1`

Each command can be followed by `unu quantize -b 8 -i rgb.nrrd -o rgb.png` to create
an 8-bit image version of the output.  The `-which 3` and `-which 4` commands
show an important comparison, demonstrating how knowing the gradient permits
drawing of equal-thickness isocontours (according to the first-order Taylor
expansion).

Viewing `../data/sscand.nrrd` with the parameters above gives a roughly
100km view of the area around Geilo, Norway, site of the
[Winter School](http://www.sintef.no/projectweb/geilowinterschool/2016-scientific-visualization/)
for which this program was originally created.
