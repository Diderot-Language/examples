## Sample datasets

Some small sample datasets that may be useful for various examples.

* `sscand.nrrd`: Elevation data in an area around southern Scandanavia.
The original data is from http://www.ngdc.noaa.gov/mgg/global/global.html
but some hacky post-processing was used to make this image. The result doesn't
have a cleanly defined geographic coordinate system, so `sscand.nrrd` includes
only minimal orientation information so as to not be misleading.
* `ddro.nrrd`, `ddro-200.nrrd`, `ddro-100.nrrd`: Portrait of [Diderot himself](https://en.wikipedia.org/wiki/Denis_Diderot),
as created and processed by `0-gen-ddro.sh`.  All resolutions of the image
are square, with the domain [-1,1]x[-1,1].
* `sqflow.nrrd`: `sqflow2D.nrrd`: From a
Navier Stokes simulation of incompressible flow past a square cylinder,
by Simone Camarri and Maria-Vittoria Salvetti (University of Pisa), Marcelo Buffoni (Politecnico of
Torino), and Angelo Iollo (University of Bordeaux I). A uniform resampling
was [computed by Tino Weinkauf](https://people.mpi-inf.mpg.de/~weinkauf/notes/squarecylinder.html),
and [used in von Funck et al. for smoke visualizations](https://doi.org/10.1109/TVCG.2008.163).
`sqflow.nrrd` is time step 3928, and `sqflow.nrrd-2D` is a central slice (of 2-vectors) in which
the 3D flow is maximally contained within the slice.

More datasets will be added as more example programs are finished.

