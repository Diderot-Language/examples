## Sample colormaps

Some colormaps that may be generally useful.

* `gray.nrrd`: Domain is from 0 to 1, producing a 3-vector of grays going
linearly from [0,0,0] to [1,1,1].

* `spiral.nrrd`: Domain is from 0 to 1, producing a 3-vector of RGB colors
that go from [0,0,0] to [1,1,1], spiraling around to various hues along the way.
The idea for this colormap was described by [Colin Ware in an important paper](http://ccom.unh.edu/sites/default/files/publications/Ware_1988_CGA_Color_sequences_univariate_maps.pdf).

* `isobow.nrrd`: Domain is from 0 to 1, producing a 3-vector of RGB colors
that circle through hues (starting and ending at same blue).
[Face-based luminance matching](http://people.cs.uchicago.edu/~glk/pubs/#VIS-2002)
was used to try to enforce isoluminance, but displays and viewers will differ.

More colormaps will be added as more example programs need them.
