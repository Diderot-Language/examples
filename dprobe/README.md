# dprobe: image probing utility

This is a rather atypical Diderot example because it is not a single program,
but a generator/compiler for a programs, based on the various command-line
options to `dprobe`, which is a Python program. The variety of things that
`dprobe` can do and act on require creating new programs, because various
Diderot program must currently be known at compile time:

* The input image dimension and value type (e.g. `real` vs `vec3`)
* The reconstruction kernel
* Whether output should a list (from a strand collection) or an array (from a strand grid)
* The differentiability requirement of a field for some expression involving that field
* Whether to use any border control, or which one one to use (e.g. `clamp`, `wrap`, `mirror`)
* The output value type

While later versions of Diderot may permit learning some of the things at
run-time, the more fundamental things (like whether to run as a collection versus a grid
of strands) will likely always require different programs to compile.

(... dprobe still being written/tested ...)
