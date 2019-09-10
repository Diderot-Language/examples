# Diderot Examples

These example programs demonstrate the [Diderot
language](http://diderot-language.cs.uchicago.edu), described in
[EuroVis 2018](http://people.cs.uchicago.edu/~glk/pubs/#EV-2018) and
[VIS 2015](http://people.cs.uchicago.edu/~glk/pubs/#VIS-2015) papers.  An
earlier version of the language was described in a [PLDI 2012
paper](http://diderot-language.cs.uchicago.edu/papers/pldi12-preprint.pdf).
These example programs have been written to help you learn how to use
Diderot, and to provide starting points for writing your own Diderot programs.

Diderot is a new language, and you can help improve it.
You can test and improve the instructions below on how
to build the Diderot compiler, try out the example
programs and report any problems or confusion, or
contribute new example programs.
Join the [diderot-language](https://goo.gl/kXpxhV) Google group to communicate with us.

The Diderot language and its compiler are the work of (in alphabetical order)
[Charisee Chiw](http://people.cs.uchicago.edu/~cchiw/),
[Gordon Kindlmann](http://people.cs.uchicago.edu/~glk/),
[John Reppy](http://people.cs.uchicago.edu/~jhr/),
and [Lamont Samuels](http://www.lamontksamuels.com).
Diderot development is partially supported by NSF Grants [CCF-1446412](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1446412)
and [CCF-1564298](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1564298),
as well as by donations from NVIDIA and AMD.

Once you've built the `diderotc` compiler (and added it to your path) with the
instructions below, you can create executable `foo` from Diderot program
`foo.diderot` with

	diderotc --exec foo.diderot

You can then run the program with:

	./foo

Some examples benefit from different compilation or execution options, as noted.

The examples below should compile with the "vis15" branch of the compiler,
which is the focus of ongoing work.  Each example has an introductory
README.md (generated from the first comment in the program), and more
explanatory comments within the source.  The example programs are listed here
in order from simple to more complex; the later examples assume you've read
through and run earlier examples.  The first few examples (through `tensor`)
do not exemplify the kinds of algorithms for which Diderot is designed, but do
demonstrate various basic language features. Enjoy!

* [`hello`](hello/): Hello world in Diderot
* [`heron`](heron/): A non-trivial program to find square roots, via Heron's method.
Demonstrates input variables, `stabilize` method, 5-argument `lerp()`, limiting iterations
with the `-l` option, and compiling with `--double`.
* [`sieve`](sieve/): Sieve of Eratosthenes for finding primes. Demonstrates
how strands can `die` (in a strand collection) and the `global` update block,
which can compute on globals and strand states between per-strand updates.
* [`life`](life/): Conway's Game of Life.  Demonstrates strand communication
and snapshots for watching how strand state changes.
* [`steps`](steps/): Documents interaction of strand communication, strand
updates, global updates, and snapshots, in a strand collection.
* [`unicode`](unicode/): Computes nothing (kind of a no-op program),
but the comments include a Diderot Unicode cheatsheet,
with information about the operators they represent.
* [`plot1d`](plot1d/): Plots a univariate function reconstructed by convolution
of 1-D, possibly with border control, and transformed by lifted functions.
* [`tensor`](tensor/): Describes tensor shape, and demonstrates printing, indexing, and
multiplication of tensors and user-defined functions.
* [`vimg`](vimg/): Viewing, within a window of specified location and orientation,
of an image or of some of its derived attributes. Demonstrates
having an image dataset as an input variable,
univariate colormapping,
finding gradients with ∇,
`inv` for matrix inverse,
and `evals` and `evecs` for eigenvalues and eigenvectors.
* [`dprobe`](dprobe/): Not a single Diderot program, but a utility for generating
and running programs that probe different things in different ways from fields
(conceptually a peer to the `vprobe` or `gprobe` utilities in Teem).
* [`fs2d`](fs2d/): For generating 2D synthetic datasets. Demonstrates
computing on globals at initialization-time,
uninitialized global inputs,
chained else-if conditionals to emulate a switch, and
single-expression functions defined with `=`.
* [`iso2d`](iso2d/): Sampling isocontours with non-interacting particles using
Newton-Raphson iteration, which is legible as such because of Diderot's mathematical notation.
Also demonstrates the `inside` and `normalize` functions.
* [`lic`](lic/): Line integral convolution (LIC) in a 2D flow field.
* [`fs3d`](fs3d/): For generating a variety of interesting 3D synthetic datasets;
similar to but more complicated than [`fs2d`](fs2d/).
Demonstrates a user-defined function for doing quaternion to
rotation matrix conversion, and nested conditional expressions.
* [`tensor2`](tensor2/): Details how differentiation adds indices
to the **end** of tensor shape.
* [`mip`](mip/): For maximum-intensity projections through 3D volumes;
Shows a minimal example of setting up a camera and casting rays,
and also provides a setting for demonstrating how better reconstruction
kernels can make a rendering output be invariant with respect to the sampling grid.
* [`dvr`](dvr/): For shaded volume rendering of scalar fields.
Shows how `continue` helps avoid having the main `update` body be too deeply nested in
`if` tests, and per-component vector multiplication with `modulate`.
* [`circle`](circle/): Mutually repulsive particles moving on a unit circle,
showing strand communication and global reductions, and introducing the program
structure used in other particle system examples.
* [`sphere`](sphere/): Mutually repulsive particles populating a unit sphere,
showing population control with `new` and `die`.
* [`halftone`](halftone/): Particles with radius determined by an underlying
image intensity generate an image half-toning.

Further examples (some overlapping in functionality with programs above)
are part of [the directions for reproducing the rendered figures](https://github.com/Diderot-Language/reproduce/tree/master/vis15)
in the [VIS 2015 paper](http://people.cs.uchicago.edu/~glk/pubs/#VIS-2015).

Some other directories contain supporting files:
* [`data`](data/): Small sample datasets that can't be generated by program.
* [`cmap`](cmap/): Colormaps

Many of these examples involve some non-trivial use of the shell (bash) to
pre-process input data or to post-process results from Diderot, in ways that
would normally use a high-level language like Python. However: **Diderot does
not require shell hacking to get work done**. These examples do that only to
be as self-contained as possible, so that no additional software is needed to
start trying out Diderot. Besides command-line executables, Diderot programs
can also be compiled to **libraries**, which can be called from other
software. Some examples of OpenGL-based GUIs around Diderot programs will be
shared here soon. Our ongoing work includes simplifying connections between
compiled Diderot programs and Python, and simplifying how Diderot programs may
be interactively debugged.

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
or via [Homebrew `brew`](http://brew.sh) or [MacPorts](https://www.macports.org)
on macOS.

To get Cmake:
* Linux: `sudo apt-get install cmake`
* macOS: `brew install cmake` or `port install cmake`
* In any case, the [CMake download](https://cmake.org/download/)
page includes "Binary distributions" that have the executable
`cmake` you'll need.

To get the autoconf tools (specifically `autoconf` and `autoheader`):
* Linux: `sudo apt-get install autoconf`
* macOS: `brew install autoconf` or `port install autoconf`
You will need autoconf version 2.64 or higher.

The Diderot runtime system is written in C++11 and the code generator
also produces C++ code, so you will need to have a modern C++ compiler
installed.

#### (2) Get Standard ML of New Jersey
The Diderot compiler is written in *Standard ML*, so you will need an SML
implementation to compile it.  We recommend [SML/NJ](http://smlnj.org), so
you should install that first.

The latest version of SML/NJ for macOS or Linux can be obtained from the
[SML/NJ website](http://smlnj.org) or from some common package managers (see
below). **You need at least version 110.81 to build the current version of Diderot.**

You can learn the version of the executable `sml` by running

	sml @SMLversion

There are different ways of getting `sml`.

**On macOS** you can download a macOS installer from <http://smlnj.org>
or you can install it from [Homebrew](https://brew.sh). Assuming that `brew info smlnj`
mentions version 110.81 or higher, then

	brew install smlnj

(possibly followed by `brew link smlnj`) should work. In case `smlnj` is only available
as a cask, you may need to run

	brew cask install smlnj

**On Ubuntu or Debian Linux**, `apt-get` may work to install a sufficiently recent
version.  `apt-cache policy smlnj` reports what version you can get;
if that's at or above version 110.81, you can:

	sudo apt-get install smlnj
	sudo apt-get install ml-lpt

The second `apt-get` to get `ml-lpt` is required because without it, the later compilation
of the Diderot compiler (with the `sml` from `apt-get`) will stop with an error message
like `driver/sources.cm:16.3-16.18 Error: anchor $ml-lpt-lib.cm not defined`.

**To install from http://smlnj.org**:
On the SML/NJ [Downloads](http://smlnj.org/dist/working/index.html)
page, go to the topmost "Sofware links: files" link
to get files needed to install SML/NJ on your platform.

On macOS there is an installer package to get executables,
which installs the `sml` command in `/usr/local/smlnj/bin`.
You can also follow the instructions for Linux below.

To build SML/NJ on Linux requires downloading and unzipping one file
and then running an install script.  The script will download additional
source and precompiled binary files to build the system.
**(The following may be moot or wrong now that recent versions of SML/NJ
have transitioned to 64-bit:**
Installing SML/NJ on a 64-bit Linux machine requires support for
32-bit executables, since `sml` is itself a 32-bit program. You will know
you're missing 32-bit support if the `config/install.sh` command below fails
with an error message like "`SML/NJ requires support for 32-bit executables`".
How you fix this will vary between different versions of Linux.
This is documented at the very bottom of the SML/NJ Installation Instructions,
for example [here](http://www.smlnj.org/dist/working/110.81/INSTALL) for version 110.81.
**)**


Then, to compile `sml` from source files at http://smlnj.org (the `wget` command
below is specific to version 110.91):

	mkdir $DDRO_ROOT/smlnj
	cd $DDRO_ROOT/smlnj
	wget http://smlnj.cs.uchicago.edu/dist/working/110.91/config.tgz
	tar xzf config.tgz
	config/install.sh
	export SMLNJ_CMD=$DDRO_ROOT/smlnj/bin/sml

Once you believe you have `sml` installed, it should either be in your path
(test this with `which sml`), or, if you didn't do this when compiling `sml`
with the steps immediately above:

	export SMLNJ_CMD=/path/to/your/sml
Subsequent Diderot compilation depends on `$SMLNJ_CMD` being set
if `sml` is not in your path.

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
	cmake -Wno-dev \
	  -D BUILD_EXPERIMENTAL_APPS=OFF -D BUILD_EXPERIMENTAL_LIBS=OFF \
	  -D BUILD_SHARED_LIBS=OFF -D BUILD_TESTING=OFF \
          -D CMAKE_BUILD_TYPE=Release \
	  -D Teem_BZIP2=OFF -D Teem_FFTW3=OFF -D Teem_LEVMAR=OFF -D Teem_PTHREAD=OFF \
	  -D Teem_PNG=OFF -D Teem_ZLIB=OFF \
	  -D CMAKE_INSTALL_PREFIX:PATH=$TEEMDDRO \
	  ../teem-src
	make install
To make sure your build works, try:

	$DDRO_ROOT/teem-ddro/bin/unu --version

Note that we do **not** recommend adding this `teem-ddro/bin` to your path;
it's not very useful.

Instead, post-processing of Diderot output often generates PNG images, which means you'll
want a **separate** Teem build that includes PNG and zlib. You get this with:

	mkdir $DDRO_ROOT/teem-util
	cd $DDRO_ROOT/teem-util; TEEMUTIL=`pwd`
	mkdir $DDRO_ROOT/teem-util-build
	cd $DDRO_ROOT/teem-util-build
	cmake -Wno-dev \
	  -D BUILD_EXPERIMENTAL_APPS=OFF -D BUILD_EXPERIMENTAL_LIBS=OFF \
	  -D BUILD_SHARED_LIBS=OFF -D BUILD_TESTING=OFF \
          -D CMAKE_BUILD_TYPE=Release \
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

The **vis15** branch contains features from other branches listed below, and is the
focus of ongoing merge work. It now supports pthreads. The source is available via:

	svn co --username anonsvn --password=anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis15

Prior to the vis15 branch, the vis12 branch (created with a
[VIS'12](http://ieeevis.org/year/2012/info/call-participation/welcome)
submission in mind) was the most reliable.

	svn co --username anonsvn --password=anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis12

The **vis12-cl** branch is the only one with a working OpenCL backend.  Other branch's
`diderotc` may advertise a `--target=cl` option, but it only works in the vis12-cl branch.

	svn co --username anonsvn --password=anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis12-cl

The **lamont** and **charisee** branches were created to support strand communication
(for particle systems) and tensor field operators (based on the EIN internal representation),
respectively, but these mechanisms have since been merged into the vis15 branch.

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

If `autoheader` fails with something like:

	configure.ac:82: error: Autoconf version 2.64 or higher is required
you'll need to update your autoconf installation.
If `configure` fails with:

	checking for nrrdMetaDataNormalize... no
	configure: error: "please update your teem installation"

it means that your Teem source checkout is not recent enough; `nrrdMetaDataNormalize`
was added with Teem revision r6294.
If the build fails with an error message `anchor $ml-lpt-lib.cm not defined`, it means
the ml-lpt library is missing. This is available through your package manager (such as `sudo apt-get install ml-lpt`)
or by, [for the latest release version](http://smlnj.org/dist/working/index.html) following the
"files" link.

Once the configure and build is finished, you can check that it worked by trying:

	bin/diderotc --help

One technical note: Unlike the executables created by the Diderot compiler `bin/diderotc`,
`bin/diderotc` is not itself a stand-alone executable. It is a
shell script containing absolute paths to the `sml` installation and to
an architecture-specific binary file in `bin/.heap` used by `sml` to compile Diderot.
Also, when `bin/diderotc` compiles the C++
files it generates, it depends on the relative locations of the `include` and `lib`
directories (peer to `bin`) created by `make local-install`.

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
