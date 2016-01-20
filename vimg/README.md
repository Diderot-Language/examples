## vimg.diderot: 2D image sampler/viewer

This program needs a dataset to render, for example:

	ln -s ../data/sscand.nrrd img.nrrd

Then compile this program; assuming the directions at
https://github.com/Diderot-Language/examples you can:

	../../vis12/bin/diderotc --exec vimg.diderot

If the needed `img.nrrd` file is missing, the error message looks something like:

	uncaught exception Fail [Fail: Nrrd file "img.nrrd" does not exist]
	  raised at common/phase-timer.sml:78.50-78.52
	  raised at common/phase-timer.sml:78.50-78.52
	  raised at nrrd/nrrd-info.sml:146.15-146.74

in which case you should run the `ln -s` command above, or
link `img.nrrd` to some other 2D scalar nrrd file to view.

The `-w` option will determine which function is sampled; look
for `(0 == w)` below to see the start of the function definitions.
