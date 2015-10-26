# ddro-examples

## Example programs in the Diderot language

These examples demonstrate the various features of the Diderot language.
As a Diderot user, these examples are useful starting points for adapting and modifying for your
own purposes. You can help by fixing issues that arise, and contributing new example programs.

As Diderot is a fairly new language, the best practices for packaging up these examples and their
associated files is still evolving.  Patience and/or fearless engagement is appreciated.

The [diderot-language](https://goo.gl/kXpxhV) google group is the place to
discuss the language and its use.

## Building Diderot

1. The Diderot compiler is written in [SML/NJ](http://smlnj.org), so you'll
need to install that first.  On the [Downloads](http://smlnj.org/dist/working/index.html)
page, go to the top-most [Sofware links: files](http://smlnj.org/dist/working/110.79/index.html)
 (currently version 110.79) to get files needed to install SML/NJ on different platforms.

2. The Diderot run-time depends on [Teem](http://teem.sourceforge.net).
Teem is overdue for a release, but in the mean time you build from source
with [Cmake](https://cmake.org) (install CMake if you haven't already).  To get
the and build Teem source (assuming sh, bash, or similar shell):

bingo

	svn co https://svn.code.sf.net/p/teem/code/teem/trunk teem-src mkdir
	teem-install

bingo bingo
