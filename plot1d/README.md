## plot1d.diderot: simple univariate function plotting

This example shows how it is possible, though not exactly convenient, to do 1D
data plotting in Diderot. While such plotting done is normally done with a
vector (not a raster) graphics display, this program is still useful to:
* demonstrate the various "border controls" for reconstructing at the edges of index space
* show exactly what the available reconstruction kernels look like
* demonstrate how functions can be "lifted" to fields

The program as distributed here plots the reconstruction of data with the
"ctmr" Catmull-Rom reconstruction kernel, with "clamp" border-control. We can plot
`ctmr` itself, as the response to an impulse in the data:

	echo "0 0 1 0 0" | unu axdelete -a -1 | unu dnorm -rc -o data.nrrd
	./plot1d -img data.nrrd -ymm -0.3 1.3
	unu quantize -b 8 -i rgb.nrrd -o ctmr.png

(See [ctmr.png](ctmr.png)). To learn more, try
changing the program in all the places noted with "Choose ONE by
uncommenting", then recompiling, running, and looking at the results.

To plot a function created within Diderot,
uncomment and edit the "or write your own function of F0" line below. If
playing with taking derivates, choose reconstruction with `c4hexic` for a high
(C^4) continuity order. Be sure to recompile.  The following makes `data.nrrd`
into a linear ramp from (-M,-M) to (M,M), with 4 samples of extra padding to account
for kernel support. The number of samples (`unu resample -s 10`) is not
related to M.

	M=12;
	echo "-$[M+4] $[M+4]" | unu axdelete -a -1 |
	  unu resample -s 10 -k tent -c node |
	  unu axinfo -a 0 -mm -$[M+4] $[M+4] | unu dnorm -o data.nrrd
	./plot1d -img data.nrrd -xmm -$M $M -ymm -2 2
	unu quantize -b 8 -i rgb.nrrd -o func.png

Computing the plot as a raster image, with the thickness of plot elements
defined in index space, requires conversions back and forth between world and
index space, which are currently somewhat cumbersome in Diderot. Using
homogeneous coordinate transforms might simplify this (available with
matrix-vector multiplications in Diderot), though that would be a very
different program.
