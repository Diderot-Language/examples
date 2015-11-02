# Didrot Examples

These examples demonstrate the various features of the [Diderot language](http://diderot-language.cs.uchicago.edu)

As a Diderot user, these examples are useful starting points for adapting and modifying for your
own purposes. You can help by fixing issues that arise, and contributing new example programs.

As Diderot is a fairly new language, the best practices for packaging up these examples and their
associated files is still evolving.  Patience and/or constructive engagement is appreciated.

The [diderot-language](https://goo.gl/kXpxhV) Google group is the place to
discuss the language and its use.

The instructions below end with cloning these examples, and compiling them with Diderot.

Some information about the examples so far:

* <code>hello</code>: Hello world in Diderot
* <code>heron</code>: A non-trivial program to find square roots, via Heron's method. Also
shows input variables, the stabilize method, and 5-argument lerp().
* <code>unicode</code>: Not for computing anything; comments include a Diderot Unicode cheatsheet

## Building Diderot and these examples

You'll need [Cmake](https://cmake.org) to generate Makefiles, and
the [GNU autoconf](http://www.gnu.org/software/autoconf/manual/autoconf.html)
tools (specifically <code>autoconf</code> and <code>autoheader</code>).

To keep things contained, you may want to create a directory (perhaps <code>ddro</code>)
to contain all the other software directories below:

	mkdir ddro
	cd ddro

All shell commands used here assume sh/bash syntax.

#### (1) Get SML/NJ
The Diderot compiler is written in [SML/NJ](http://smlnj.org), so you'll
need to install that first.  On the SML/NJ [Downloads](http://smlnj.org/dist/working/index.html)
page, go to the topmost "Sofware links: files" link
(currently 110.79) to get files needed to install SML/NJ on your platform.

You need at least version 110.77 to build Diderot.  You can learn the version
of SML by running

	sml @SMLversion

If you do not install SML so that the executable <code>sml</code> is in your path,
you need to (for the sake of later Diderot configuration):

	export SMLNJ_CMD=/path/to/your/sml

#### (2) Get Teem
The Diderot run-time depends on [Teem](http://teem.sourceforge.net).
Teem is overdue for a release, but in the mean time you build from source with CMake.

Even if you already have a version of Teem installed, it is best if you build a new Teem
for Diderot, with *none* of the optional libraries (PNG, zlib, etc) enabled. Experience
has shown that additional dependencies from Teem will complicate the linking that
the Diderot compiler does.

To get the Teem source and set the
<code>TEEMDDRO</code> variable needed, run:

	svn co https://svn.code.sf.net/p/teem/code/teem/trunk teem-src
	mkdir teem-ddro
	cd teem-ddro; TEEMDDRO=`pwd`; cd -
To build Teem and install into <code>teem-ddro</code>:

	mkdir teem-ddro-build
	cd teem-ddro-build
	cmake \
	  -D BUILD_EXPERIMENTAL_APPS=OFF -D BUILD_EXPERIMENTAL_LIBS=OFF \
	  -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Release \
	  -D Teem_BZIP2=OFF -D Teem_FFTW3=OFF -D Teem_LEVMAR=OFF -D Teem_PTHREAD=OFF \
	  -D Teem_PNG=OFF -D Teem_ZLIB=OFF \
	  -D CMAKE_INSTALL_PREFIX:PATH=$TEEMDDRO \
	  ../teem-src
	make install
	cd ..
To make sure your build works, try:

	teem-ddro/bin/unu --version

Note that we do **not** recommend adding this <code>teem-ddro/bin</code> to your path;
its not very useful.

Instead, post-processing of Diderot output often generates PNG images, which means you'll
want a **separate** Teem build that includes PNG and zlib. You get get this with:

	mkdir teem-util
	cd teem-util; TEEMUTIL=`pwd`; cd -
	mkdir teem-util-build
	cd teem-util-build
	cmake \
	  -D BUILD_EXPERIMENTAL_APPS=OFF -D BUILD_EXPERIMENTAL_LIBS=OFF \
	  -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Release \
	  -D Teem_BZIP2=OFF -D Teem_FFTW3=OFF -D Teem_LEVMAR=OFF -D Teem_PTHREAD=OFF \
	  -D Teem_PNG=ON -D Teem_ZLIB=ON \
	  -D CMAKE_INSTALL_PREFIX:PATH=$TEEMUTIL \
	  ../teem-src
	make install
	cd ..
(The difference with the commands above is the "-D Teem_PNG=ON -D Teem_ZLIB=ON").
To make sure this build includes the useful libraries, try:

	teem-util/bin/unu about | tail -n 4

The "Formats available" should include "png", and the
"Nrrd data encodings available" should include "gz".

To add these Teem utilities to your path:

	cd teem-util/bin
	export PATH=${PATH}:`pwd`
	cd -

Finally, note that <code>unu dnorm</code> is a useful command for
normalizing the orientation and meta-data in a Nrrd arrays into the consistent
representation that the Diderot run-time assumes.

#### (3) Getting Diderot (the various branches)

**NOTE: As Diderot branches are merged, the names and URLs for these may change**

At this point there are different branches with different functionalities;
work on merging them is ongoing.
For all of the "svn co" commands below, the password is also "anonsvn".

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

The steps to configure and build any of these Diderot branches are the same;
these commands can be run inside any of the per-branch directories
(such as <code>vis12/</code>).
Note the use of the <code>TEEMDDRO</code> variable set above, and the possible
use of the <code>SMLNJ_CMD</code> variable also described above:

	autoheader -Iconfig
	autoconf -Iconfig
	./configure --with-teem=$TEEMDDRO
	make local-install

As long as there are multiple branches in play, "make local-install" makes more sense than "make install".
From within one of the Diderot branch directories, you can check that the build worked by trying:

	bin/diderotc --help

#### (4) Get the examples:

	git clone https://github.com/Diderot-Language/examples.git

#### (5) Try running the "hello world" example

	cd examples/hello
	../../vis12/bin/diderotc --exec hello.diderot
	./hello

Running <code>hello</code> should print "hello, world".  All Diderot programs,
even this out, produces an output file; this one created <code>out.nrrd</code>,
a container for a single int.  We can check its contents with:

	unu save -f text -i out.nrrd

which should show "42".  If you've gotten this far, you have successfully
built Diderot, and compiled and run a Diderot program!
