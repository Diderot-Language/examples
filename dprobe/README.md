# dprobe: image probing utility

This is a rather atypical Diderot example because it is not a single program,
but a generator/compiler for a programs, based on the various command-line
options to `dprobe`, which is a Python program. The variety of things that
`dprobe` can do and act on require creating new programs, because currently various
elements and properties of Diderot programs must be known at compile time
(rather than being learned at run-time):

* The input image dimension
* (Tensor) shape of values in input image (e.g. `[]` for `real` or `[3]` for `vec3`)
* Whether to use any border control on an image, or which one one to use (e.g. `clamp`, `wrap`, `mirror`)
* The reconstruction kernel
* The differentiability requirement of a field for some expression involving that field
(e.g. `field#0` if no derivatives needed, vs `field#2` if two derivatives are needed)
* The (tensor) shape of output values
* Whether output should a list (from a strand collection) or an array (from a strand grid)

While later versions of Diderot may permit learning some of the things at
run-time, the more fundamental things (like whether to run as a collection versus a grid
of strands) will likely always require different programs to compile.

(... dprobe still being written/tested ...)
