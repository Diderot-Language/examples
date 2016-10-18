## vimg.diderot: 2D image sampler/viewer

This program needs a dataset to render, and a colormap, for example:

	ln -s ../data/sscand.nrrd img.nrrd
	ln -s ../cmap/spiral.nrrd cmap.nrrd

When you compile this program (with `diderotc --exec vimg.diderot`)
the compiler will see that specific datafiles are named in the declaration
of the input image and colormap data:

	input image(2)[] img ("2D image dataset to view") = image("img.nrrd");
	input image(1)[3] cmimg ("colormap to use") = image("cmap.nrrd");

and the compiler will specialize some of the generated code according
to properties of that data in those files (which is why we wanted to
get those files in place before running the compiler).  In talking
about the action of the Diderot compiler, the named data files are
called *proxy files*. It is an error for a proxy file to not exist at
compilation. Without creating the `img.nrrd` file prior to
compilation, the compiler would exit with:

	[vimg.diderot] Error: proxy-image file "cmap.nrrd" does not exist

Currently, for arrays, the Diderot compiler specializes on the sample
type (the `type:` NRRD header field in `unu head img.nrrd`) and the array
axis sizes (`sizes:`). The compiler does not currently
specialize on array orientation (`space origin:` and `space directions:`).
The compiler will also check that the array dimension
(`dimension:`) and sample type (scalar, in this case) matches that of the
the array type declaration `image(2)[]`: `(2)` means a 2-D domain and
the shape `[]` means scalar-valued samples.  For the colormap, given the type
`image(1)[3]`, the compiler will check that `cmap.nrrd` is 1-D (`(1)`)
array of 3-vectors (`[3]`), which will be stored in NRRD as a 2-D 3-by-N array.
Multivariate samples always have their constituent values on the fastest
axis of the array. In the NRRD, the axes are tagged with a `kind` that can
disambiguate their purpose. `unu head cmap.nrrd` will show

	kinds: 3-vector space

which means that the 3-vectors components are on the faster axis, while
the sampling of 3-vectors over the 1-D domain happens on the slower axis.

In the generated command-line executable, the default value for the `-img`
option will be the filename `img.nrrd`, but other data can be supplied at
runtime (e.g. `-img otherimg.nrrd`) as long as the other data matches the
sample type, array dimension, and axis sizes of the proxy file.

If there is no proxy file named with the input image declaration, as with:

	input image(2)[] img ("2D image dataset to view");

then the compiler will assume `float` sample type, and will generate code that
checks that whatever array is supplied at runtime has the correct array
dimension and sample type, but will be general with respect to axis sizes.

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
