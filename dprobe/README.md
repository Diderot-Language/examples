# dprobe: image probing utility

This is an atypical Diderot example because it is not a single program, but a
generator/compiler for a programs, based on the various command-line options
to `dprobe`, which is a `python3` program. The variety of things that
`dprobe` can do and act on require creating new programs, because currently
various elements and properties of Diderot programs must be known at compile
time (rather than being learned at run-time):

* The input image dimension
* (Tensor) shape of values in input image (e.g. `[]` for `real` or `[3]` for `vec3`)
* Whether to use any border control on an image, or which one one to use (e.g. `clamp`, `wrap`, `mirror`)
* The reconstruction kernel
* The mathematical expressions involving fields that will be evaluated (e.g. `F(pos)` vs `|∇F(pos)|`)
* The differentiability requirement of a field for some expression involving that field
(e.g. `field#0` if no derivatives needed, vs `field#2` if two derivatives are needed)
* The (tensor) shape of output values
* Whether output should a list (from a strand collection) or an array (from a strand grid)

While later versions of Diderot may permit learning some of these things at
run-time, the more fundamental things (like whether to run as a collection
versus a grid of strands) will likely always need to be known at
compile-time.

There is a single template program (look for the definition of `TEMPLATE` at
the top of `dprobe`), which is transformed according to the arguments to
`dprobe`, but it is so heavily transformed that it doesn't really look like a
Diderot program. You can see the final generated program by specifying its
basename with the `-op` option, or otherwise using the `-kg` option to keep
generated files.

(... dprobe still being written/tested ...)
