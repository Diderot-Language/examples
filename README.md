# Didrot Examples

These examples demonstrate the various features of the [Diderot language](http://diderot-language.cs.uchicago.edu)

As a Diderot user, these examples are useful starting points for adapting and modifying for your
own purposes. You can help by fixing issues that arise, and contributing new example programs.

As Diderot is a fairly new language, the best practices for packaging up these examples and their
associated files is still evolving.  Patience and/or constructive engagement is appreciated.

The [diderot-language](https://goo.gl/kXpxhV) Google group is the place to
discuss the language and its use.

The instructions below end with cloning these examples, and compiling them with Diderot.

Here is a list of the examples written so far, in the order we suggest you read through
them in (going from simpler to more complex programs):

* [`hello`](hello/): Hello world in Diderot
* [`heron`](heron/): A non-trivial program to find square roots, via Heron's method.
Demonstrates input variables, the stabilize method, and 5-argument lerp().
* [`unicode`](unicode/): Computes nothing, but comments include a Diderot Unicode cheatsheet
* [`fs2d`](fs2d/): For generating 2D synthetic datasets. Demonstrates computing on globals at
initialization-time, user-defined function, and printing.
* [`iso2d`](iso2d/): Sampling isocontours with non-interacting particles using
Newton-Raphson iteration. Demonstrates
having an image dataset as an input variable, strands calling `die`,
the `inside` and `normalize` functions, and finding gradients with ∇.

## Building Diderot and these examples

#### (0) Get Cmake, autoconf, and creating $DDRO_ROOT

CMake is needed to build Teem, and autoconf is need to configure the compilation
of Diderot.  These utilities can be obtained via `apt-get` on Ubuntu/Debian Linux,
or via [Homebrew `brew`](http://brew.sh) on OSX.

To get [Cmake](https://cmake.org):
* Linux: `sudo apt-get install cmake`
* OSX: `brew install cmake`
* In any case, the [CMake download](https://cmake.org/download/)
page includes "Binary distributions" that have the executable
`cmake` you'll need.

To get the [GNU autoconf](http://www.gnu.org/software/autoconf/manual/autoconf.html)
tools (specifically <code>autoconf</code> and <code>autoheader</code>):
* Linux: `sudo apt-get install autoconf`
* OSX: `brew install autoconf`

To keep things contained, you should create a directory (perhaps <code>~/ddro</code>)
to contain all the other software directories referred to below,
and set `$DDRO_ROOT` to refer to it:

	mkdir ddro
	cd ddro
	export DDRO_ROOT=`pwd`

All shell commands used here assume sh/bash syntax.

#### (1) Get SML/NJ
The Diderot compiler is written in [SML/NJ](http://smlnj.org), so you'll
need to install that first.  **You need at least version 110.77 to build Diderot.**
You can learn the version of the executable `sml` by running

	sml @SMLversion

There are different ways of getting `sml`.

**On OSX**, (using [Homebrew](https://brew.sh)). Assuming that `brew info smlnj`
mentions version 110.77 or higher, then

	brew install smlnj

(possibly followed by `brew link smlnj`) should work.

**On Ubuntu or Debian Linux**, `apt-get` may work to install a sufficiently recent
version.  `apt-cache policy smlnj` reports what version you can get;
if that's at or above version 110.77, you can:

	sudo apt-get install smlnj
	sudo apt-get install ml-lpt
The second `apt-get` command is included because one user reported that
this resolved error messages like "ml-lpt-lib.cm not defined" (arising
during the later compilation of the Diderot compiler).

**To install from files at http://smlnj.org**:
On the SML/NJ [Downloads](http://smlnj.org/dist/working/index.html)
page, go to the topmost "Sofware links: files" link
(currently 110.79) to get files needed to install SML/NJ on your platform.
On OSX there is an installer package to get executables.

Or, you can compile smlnj from source. Doing this on a modern 64-bit
Linux machine requires support for 32-bit executables, since
`sml` is available only as a 32-bit program. You will know you're missing
32-bit support if the `config/install.sh` command below fails
with an error message like "`SML/NJ requires support for 32-bit executables`".
How you fix this will vary between different versions of Linux;
please tell us specific steps for your Linux flavor!

* On Ubuntu (at least in version 14.04): [`sudo apt-get install gcc-multilib`](http://stackoverflow.com/questions/23182765/how-to-install-ia32-libs-in-ubuntu-14-04-lts-trusty-tahr)

Then, to compile `sml` from files at http://smlnj.org (the `wget` command
is specific to version 110.79; there may now be a newer version):

	mkdir $DDRO_ROOT/smlnj
	cd $DDRO_ROOT/smlnj
	wget http://smlnj.cs.uchicago.edu/dist/working/110.79/config.tgz
	tar xzf config.tgz
	config/install.sh
	export SMLNJ_CMD=$DDRO_ROOT/smlnj/bin/sml
Once you believe you have `sml` installed, it should either be in your path
(test this with `which sml`), or, if you didn't do this when compiling `sml`
with the steps immediately above:

	export SMLNJ_CMD=/path/to/your/sml
This is required for subsequent Diderot compilation.

#### (2) Get Teem
The Diderot run-time depends on [Teem](http://teem.sourceforge.net).
Teem is overdue for a release, but in the mean time you should build
it from source with CMake, because Diderot (and these examples) assume
the current source.

It is best to build a Teem for Diderot that has *none* of the optional
libraries (PNG, zlib, etc) enabled. Experience has shown that
additional dependencies from Teem will complicate the linking that the
Diderot compiler does.

To get the Teem source and set the
<code>TEEMDDRO</code> variable needed later, run:

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

Note that we do **not** recommend adding this <code>teem-ddro/bin</code> to your path;
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

Finally, note that <code>unu dnorm</code> is a useful command for
normalizing the orientation and meta-data in a Nrrd arrays into the consistent
representation that the Diderot run-time assumes.

#### (3) Getting Diderot (the various branches)

**NOTE: As Diderot branches are merged, the names and URLs for these may change**

At this point there are different branches with different functionalities;
work on merging them is ongoing.  Any or all of them should be within `$DDRO_ROOT`:

	cd $DDRO_ROOT

Every branch is available via an "svn co" command below.  The password is also "anonsvn".

The **vis12** branch was created with a
[VIS'12](http://ieeevis.org/year/2012/info/call-participation/welcome)
submission in mind. That never happened, and the
[VIS'13](http://ieeevis.org/year/2013/info/vis-welcome/welcome) submission was rejected.
Still, this has become the most mature branch, though it lacks some features from other branches.

	svn co --username anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis12

The **vis12-cl** branch includes the OpenCL backend.

	svn co --username anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/vis12-cl

The **lamont** branch includes the implementation of strand communication.

	svn co --username anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/lamont

The **charisee** branch includes field "lifting", based on the EIN internal representation.

	svn co --username anonsvn https://svn.smlnj-gforge.cs.uchicago.edu/svn/diderot/branches/charisee

**To configure and build** any of these branches, the steps are
the same. Run these commands inside any of the per-branch directories
(such as `$DDRO_ROOT/vis12/`):

	autoheader -Iconfig
	autoconf -Iconfig
	./configure --with-teem=$TEEMDDRO
	make local-install

Note the use of the <code>TEEMDDRO</code> variable set above, and the possible
(implicit) use of the <code>SMLNJ_CMD</code> variable also described above:
As long as there are multiple branches in play, "make local-install" makes more sense than "make install".
From within one of the Diderot branch directories, you can check that the build worked by trying:

	bin/diderotc --help

#### (4) Get the examples:

	cd $DDRO_ROOT
	git clone https://github.com/Diderot-Language/examples.git

#### (5) Try running the "hello world" example

	cd $DDRO_ROOT/examples/hello
	../../vis12/bin/diderotc --exec hello.diderot
	./hello

Running <code>hello</code> should print "hello, world".  All Diderot programs,
even this out, produces an output file; this one created <code>out.nrrd</code>,
a container for a single int.  We can check its contents with:

	unu save -f text -i out.nrrd

which should show "42".  If you've gotten this far, you have successfully
built Diderot, and compiled and run a Diderot program!
