## Sample datasets

Some small sample datasets that may be useful for various examples.

* `sscand.nrrd`: Elevation data in an area around southern Scandanavia.
The original data is from http://www.ngdc.noaa.gov/mgg/global/global.html
but some hacky post-processing was used to make this image. The result doesn't
have a cleanly defined geographic coordinate system, so `sscand.nrrd` includes
only minimal orientation information so as to not be misleading.
* `ddro.nrrd`, `ddro-200.nrrd`, `ddro-100.nrrd`: portrait of [Diderot himself](https://en.wikipedia.org/wiki/Denis_Diderot),
as created and processed by `0-gen-ddro.sh`.  All resolutions of the image
are square, with the domain [-1,1]x[-1,1].

More datasets will be added as more example programs are finished.

