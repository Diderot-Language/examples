# Diderot Examples

These examples demonstrate [Diderot language](http://diderot-language.cs.uchicago.edu),
recently described in a [VIS 2015 paper](http://people.cs.uchicago.edu/~glk/pubs/#VIS-2015).
A much simpler version of the language
was described in a [PLDI 2012 paper](http://people.cs.uchicago.edu/~glk/pubs/#PLDI-2012).
The example programs have been written to help you learn how to use Diderot,
and to provide starting points for writing your own Diderot programs.

Diderot is a new language; constructive engagement is appreciated.
You can help by testing and improving the instructions below on how
to build the Diderot compiler, trying out the example
programs and reporting any problems or confusion, or
contributing new example programs.
Join the [diderot-language](https://goo.gl/kXpxhV) Google group to communicate with us.

Once you've built the `diderotc` compiler (and added it to your path) with the
instructions below, you can create executable `foo` from Diderot program
`foo.diderot` with

	diderotc --exec foo.diderot

You can then run the program with:

	./foo

Some examples benefit from different compilation or execution options, as noted.

The examples below should work without modification with the "vis15" branch
of the compiler, which is the focus of ongoing work.
Each example has an introductory README.md (generated from the first
comment in the program), and more explanatory comments within the source.
The example programs are listed here in order from simple to more complex;
the later examples assume you've read through and run earlier examples.  Enjoy!

* [`hello`](hello/): Hello world in Diderot
* [`heron`](heron/): A non-trivial program to find square roots, via Heron's method.
Demonstrates input variables, `stabilize` method, 5-argument `lerp()`, limit super-steps
with the `-l` option, and compiling with `--double`.
* [`sieve`](sieve/): Sieve of Eratosthenes for finding primes. Demonstrates
how strands can `die` (in a strand collection) and the `global` update block,
which can compute on globals and strand states between per-strand updates.
* [`unicode`](unicode/): Computes nothing, but comments include a Diderot Unicode cheatsheet,
with information about the operators that they represent.
* [`tensor`](tensor/): Describes tensor shape, and demonstrates printing, indexing, and
multiplication of tensors and user-defined functions.
* [`vimg`](vimg/): Viewing, within a window of specified location and orientation,
of an image or of some of its derived attributes. Demonstrates
having an image dataset as an input variable,
univariate colormapping,
finding gradients with ∇,
`inv` for matrix inverse,
and `evals` and `evecs` for eigenvalues and eigenvectors.
* [`fs2d`](fs2d/): For generating 2D synthetic datasets. Demonstrates
computing on globals at initialization-time,
uninitialized global inputs,
chained else-if conditionals to emulate a switch, and
single-expression functions defined with `=`.
* [`iso2d`](iso2d/): Sampling isocontours with non-interacting particles using
Newton-Raphson iteration, which is legible as such because of Diderot's mathematical notation.
Also demonstrates the `inside` and `normalize` functions,
* [`fs3d`](fs3d/): For generating a variety of interesting 3D synthetic datasets;
similar to but more complicated than [`fs2d`](fs2d/).
Demonstrates a user-defined function for doing quaternion to
rotation matrix conversion, and nested conditional expressions.
* [`mip`](mip/): For maximum-intensity projections through 3D volumes;
Shows a minimal example of setting up a camera and casting rays,
and also provides a setting for demonstrating how better reconstruction
kernels can make a rendering output be invariant with respect to the sampling grid.
* [`dvr`](dvr/): For shaded volume rendering of scalar fields.
Shows how `continue` helps avoid having the main `update` body be too deeply nested in
`if` tests, and per-component vector multiplication with `modulate`.

Some other directories contain supporting files:
* [`data`](data/): Small sample datasets that can't be generated by program.
* [`cmap`](cmap/): Colormaps

## Building Diderot and these examples

#### (0) Create $DDRO_ROOT, a place for everything to go in

To keep things contained, you should create a directory (perhaps `~/ddro`)
to contain all the other software directories referred to below,
and set `$DDRO_ROOT` to refer to it:

	mkdir ddro
	cd ddro
	export DDRO_ROOT=`pwd`

Note: **All shell commands used here assume sh/bash syntax (rather than csh/tcsh).**

#### (1) Prerequisites: Cmake, autoconf, C++11

[Cmake](https://cmake.org) is needed to build Teem, and
[GNU autoconf](http://www.gnu.org/software/autoconf/manual/autoconf.html)
is need to configure the compilation of Diderot.
These utilities can be obtained via `apt-get` on Ubuntu/Debian Linux,
or via [Homebrew `brew`](http://brew.sh) on OSX.

To get Cmake:
* Linux: `sudo apt-get install cmake`
* OSX: `brew install cmake`
* In any case, the [CMake download](https://cmake.org/download/)
page includes "Binary distributions" that have the executable
`cmake` you'll need.

To get the autoconf tools (specifically `autoconf` and `autoheader`):
* Linux: `sudo apt-get install autoconf`
* OSX: `brew install autoconf`

The Diderot runtime system is written in C++11 and the code generator
also produces C++ code, so you will need to have a modern C++ compiler
installed.

#### (2) Get SML/NJ
The Diderot compiler is written in [SML/NJ](http://smlnj.org), so you'll
need to install that first.  **You need at least version 110.80 to build
the current version of Diderot.**
You can learn the version of the executable `sml` by running

	sml @SMLversion

There are different ways of getting `sml`.

**On OSX**, (using [Homebrew](https://brew.sh)). Assuming that `brew info smlnj`
mentions version 110.80 or higher, then

	brew install smlnj

(possibly followed by `brew link smlnj`) should work.

**On Ubuntu or Debian Linux**, `apt-get` may work to install a sufficiently recent
version.  `apt-cache policy smlnj` reports what version you can get;
if that's at or above version 110.80, you can:

	sudo apt-get install smlnj
	sudo apt-get install ml-lpt
The second `apt-get` to get `ml-lpt` is required because without it, the later compilation
of the Diderot compiler (with the `sml` from `apt-get`) will stop with an error message
like `driver/sources.cm:16.3-16.18 Error: anchor $ml-lpt-lib.cm not defined`.

**To install from files at http://smlnj.org**:
On the SML/NJ [Downloads](http://smlnj.org/dist/working/index.html)
page, go to the topmost "Sofware links: files" link
(currently 110.80) to get files needed to install SML/NJ on your platform.
On OSX there is an installer package to get executables.

Or, you can compile smlnj from source yourself. Doing this on a modern 64-bit
Linux machine requires support for 32-bit executables, since
`sml` is itself a 32-bit program. You will know you're missing
32-bit support if the `config/install.sh` command below fails
with an error message like "`SML/NJ requires support for 32-bit executables`".
How you fix this will vary between different versions of Linux.
This is documented in the
[at the very bottom of the SML/NJ Installation Instructions](http://www.smlnj.org/dist/working/110.80/INSTALL).

Then, to compile `sml` from source files at http://smlnj.org (the `wget` command
is specific to version 110.80; there may now be a newer version):

	mkdir $DDRO_ROOT/smlnj
	cd $DDRO_ROOT/smlnj
	wget http://smlnj.cs.uchicago.edu/dist/working/110.80/config.tgz
	tar xzf config.tgz
	config/install.sh
	export SMLNJ_CMD=$DDRO_ROOT/smlnj/bin/sml
Once you believe you have `sml` installed, it should either be in your path
(test this with `which sml`), or, if you didn't do this when compiling `sml`
with the steps immediately above:

	export SMLNJ_CMD=/path/to/your/sml
This is required for subsequent Diderot compilation.

#### (3) Get Teem
The Diderot run-time depends on [Teem](http://teem.sourceforge.net).
Teem is overdue for a release, but in the mean time you should build
it from source with CMake, because Diderot (and these examples) assume
the current source (revision **r6294** or later).

It is best to build a Teem for Diderot that has *none* of the optional
libraries (PNG, zlib, etc) enabled. Experience has shown that
additional library dependencies from Teem will complicate the linking that the
Diderot compiler must do to create executables.

To get the Teem source and set the
`TEEMDDRO` variable needed later, run:

	cd $DDRO_ROOT
	svn co https://svn.code.sf.net/p/teem/code/teem/trunk teem-src
	mkdir teem-ddro
	cd teem-ddro; TEEMDDRO=`pwd`
Then, build Teem and install into `teem-ddro`:

	mkdir $DDRO_ROOT/teem-ddro-build
	cd $DDRO_ROOT/teem-ddro-build
	cmake \
	  -D BUILD_EXPERIMENTAL_APPS=OFF -D BUILD_EXPERIMENTAL_LIBS=OFF \
	  -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Release \
	  -D Teem_BZIP2=OFF -D Teem_FFTW3=OFF -D Teem_LEVMAR=OFF -D Teem_PTHREAD=OFF \
	  -D Teem_PNG=OFF -D Teem_ZLIB=OFF \
	  -D CMAKE_INSTALL_PREFIX:PATH=$TEEMDDRO \
	  ../teem-src
	make install
To make sure your build works, try:

	$DDRO_ROOT/teem-ddro/bin/unu --version

Note that we do **not** recommend adding this `teem-ddro/bin` to your path;
its not very useful.

Instead, post-processing of Diderot output often generates PNG images, which means you'll
want a **separate** Teem build that includes PNG and zlib. You get this with:

	mkdir $DDRO_ROOT/teem-util
	cd $DDRO_ROOT/teem-util; TEEMUTIL=`pwd`
	mkdir $DDRO_ROOT/teem-util-build
	cd $DDRO_ROOT/teem-util-build
	cmake \
	  -D BUILD_EXPERIMENTAL_APPS=OFF -D BUILD_EXPERIMENTAL_LIBS=OFF \
	  -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Release \
	  -D Teem_BZIP2=OFF -D Teem_FFTW3=OFF -D Teem_LEVMAR=OFF -D Teem_PTHREAD=OFF \
	  -D Teem_PNG=ON -D Teem_ZLIB=ON \
	  -D CMAKE_INSTALL_PREFIX:PATH=$TEEMUTIL \
	  ../teem-src
	make install
(The difference with the commands above is the `-D Teem_PNG=ON -D Teem_ZLIB=ON`).
To make sure this build includes the useful libraries, try:

	$DDRO_ROOT/teem-util/bin/unu about | tail -n 4

The "Formats available" should include "png", and the
"Nrrd data encodings available" should include "gz".

To add these Teem utilities to your path:

	export PATH=$DDRO_ROOT/teem-util/bin:${PATH}

This will only have an effect for your current shell, you'll have to [take
other steps, depending your environment](https://www.google.com/search?q=adding+paths+at+login+unix),
to ensure that this path is added with every login.

**Note** that `unu dnorm` is used by the Diderot compiler to assert a
canonical representation of orientation and meta-data in Nrrd arrays
to simplify and specialize how that information is incoporated into a
compiled Diderot program.  You can run `unu dnorm` (perhaps followed
by piping into `unu head -`) on your own data to see exactly what it
will do, or to normalize the meta-data prior to compiling the Diderot
program (the normalization is idempotent by definition).

#### (4) Getting Diderot itself.

With the [VIS'15 Diderot paper](http://people.cs.uchicago.edu/~glk/pubs/#VIS-2015),
work began on merging the various branches of the compiler that had been
created to implement the new functionalities described in the paper, relative to
the earlier [PLDI'12 paper](http://people.cs.uchicago.edu/~glk/pubs/#PLDI-2012).
The ongoing merge effort is available in the vis15 branch, but the earlier
branches are also available, as described here.

The source for any Diderot branch should be within `$DDRO_ROOT`:

	cd $DDRO_ROOT

An `svn co` command gets the source for a branch; the only difference
in the `svn co` commands below is the branch name at the end of the URL.

The **vis15** branch contains functionality from other branches listed below, and is the
focus of ongoing merge work. Pthread support is coming soon. The source is available via:

	svn co --username anonsvn --password=anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis15

Before the vis15 branch, the vis12 branch (created with a
[VIS'12](http://ieeevis.org/year/2012/info/call-participation/welcome)
submission in mind) was the most reliable. It lacks some newer features
in vis15, but it does have pthread support.

	svn co --username anonsvn --password=anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis12

The **vis12-cl** branch is the only one with a working OpenCL backend.  The vis12 branch's
`diderotc` also advertises a `--target=cl` option, but it only works in the vis12-cl branch.

	svn co --username anonsvn --password=anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis12-cl

The **lamont** and **charisee** branches were created to support strand communication
(for particle systems) and tensor field operators (based on the EIN internal representation),
respectively, but these functionalities have been merged into the vis15 branch.

**To configure and build** any of these branches, the steps are the same. First go into
the source directory for the branch, for example:

	cd vis15

And then run:

	autoheader -Iconfig
	autoconf -Iconfig
	./configure --with-teem=$TEEMDDRO
	make local-install

Note the use of the `$TEEMDDRO` variable set above, and the possible
(implicit) use of the `$SMLNJ_CMD` variable also described above.

If the configure fails with:

	checking for nrrdMetaDataNormalize... no
	configure: error: "please update your teem installation"

it means that your Teem source checkout is not recent enough; `nrrdMetaDataNormalize`
was added with Teem revision r6294.
If the build fails with an error message `anchor $ml-lpt-lib.cm not defined`, it means
the ml-lpt library is missing. This is availble through your package manager (such as `sudo apt-get install ml-lpt`)
or from the [SML/NJ Distribution Files page](http://smlnj.org/dist/working/110.80/index.html).

Once the configure and build of the Diderot compiler is finished, you can check that it worked by trying:

	bin/diderotc --help

One technical note: `bin/diderotc` is not a stand-alone executable. It is a
shell script that assumes working paths to the `sml` installation and to where
Diderot was compiled. Also, when `bin/diderotc` compiles the C++
files it generates, it depends on the relative location of an `include` directory
(peer to `bin`) created by `make local-install`.

To compile these examples or any other Didorot programs you write, you
should add the new `diderotc` to your path.  Assuming you only want to
use the latest (vis15) branch of the compiler, you can do this with:

	export PATH=$DDRO_ROOT/vis15/bin:${PATH}

#### (5) Get the examples:

	cd $DDRO_ROOT
	git clone https://github.com/Diderot-Language/examples.git

#### (6) Try compiling and running the "hello world" example [`hello`](hello/):

	cd $DDRO_ROOT/examples/hello
	diderotc --exec hello.diderot
	./hello

Running `./hello` should print "hello, world".  Every Diderot program,
even this trivial one, produces an output file. `hello` created `out.nrrd`,
a container for a single int.  We can check its contents with:

	unu save -f text -i out.nrrd

which should show "42".  If you've gotten this far, you have successfully
built Diderot, and compiled and run a Diderot program!

#### (7) Try the rest of the examples

The beginning of this README.md lists the examples in a sensible order for
reading and experimenting, from simple to complex (after [`hello`](hello/)
is [`heron`](heron/)).  The idea is that later
examples build on ideas and features shown in earlier examples.

If you use Diderot for your own research or teaching, please share it with
the [diderot-language](https://goo.gl/kXpxhV) Google group, and consider
adding some new examples here.
