## unicode.diderot: The Diderot unicode cheatsheet

This example program doesn't actually do anything (in fact it is effectively
a no-op program).  These comments, however,
list the Unicode characters that you can use in Diderot.
With each character we give the Unicode code point and name, the LaTeX equivalent (might be
useful for Diderot programs in LaTeX documents), and other comments.

Our basic philosophy behind indicating mathematical values and operators
in an idiomatic and convenient way is similar to principles previously
articulated by other computer scientists:

> First, we want to establish the idea that a computer language is not
> just a way of getting a computer to perform operations but rather that
> it is a novel formal medium for expressing ideas about methodology.
> Thus, programs must be written for people to read, and only
> incidentally for machines to execute. -- Abelson & Sussman & Sussman,
> Structure and Interpretation of Computer Programs (1985)

> Let us change our traditional attitude to the construction of
> programs: instead of imagining that our main task is to instruct a
> computer what to do, let us concentrate rather on explaining to humans
> what we want the computer to do. -- Donald Knuth, Literate Programming (1984)

These statements predate Unicode development, but that does not
undermine their continued relevance for Diderot or for programming in general.
See https://en.wikipedia.org/wiki/Unicode_input for information about
how best to input unicode in your OS.  Or, copy and paste from this file.


#### π means pi, as in

	real rad = degrees*π/180;
* Unicode: U+03C0 (Greek Small Letter Pi)
* LaTeX: `\pi`
* This is currently the only finite real constant in Diderot.

#### ∞ means infinity, as in

	output real out = -∞;
* Unicode: U+221E (Infinity)
* LaTeX: `\infty`
* The above line of code is how the output of maximum-intensity projection might be intialized;
  from then on subsequent use might be like `out = max(out, F(pos))`.

#### ⊛ means convolution, as in

	field#2(3)[] F = bspln3 ⊛ image("img.nrrd");
* Unicode: U+229B (Circled Asterisk Operator)
* LaTeX: `\circledast` is probably typical, but `\varoast` (with `\usepackage{stmaryrd}`)
  is slightly more legible
* This commutes; you could also write `image("img.nrrd") ⊛ bspln3`.

#### × means cross product, as in

	vec3 camU = normalize(camN × camUp);
* Unicode: U+00D7 (Multiplication Sign)
* LaTeX: `\times`
* As the cross-product, this is only defined for `vec3` variables.
  It also works for the curl of a vector field; see below.

#### ⊗ means tensor product, as in

	tensor[3,3] Proj = identity[3] - norm⊗norm
* Unicode: U+2297 (Circled Times)
* LaTeX: `\otimes`.
* As an operator on coordinate vectors, this is typically called the outer product.
  It is also used to define the Jacobian of a vector field; see below.

#### • means dot product and matrix multiplication, as in

	real ld = norm • lightDir;
* Unicode: U+2022 (Bullet)
* LaTeX: `\bullet`, which is more consistently visible than
  the `\cdot` that is more typical for dot products.
* The meaning of `•` is really (in tensor-speak) "contract out the
  last index of the first argument with the first index of the second argument".
  Note that tensor double-dot product (which contracts out two indices
  in other side) is plain ASCII `:`.  `•` is also used for the divergence
  of a vector field; see below.

#### ∇ means Del, which is part of various derivative operators on fields, as in

	field#3(3)[] F = ...;
	field#2(3)[3] gradient = ∇F;
	field#1(3)[3,3] hessian = ∇⊗∇F;
	field#0(3)[3,3,3] wut = ∇⊗∇⊗∇F;
	field#2(3)[3] V = ...;
	field#1(3)[3,3] jacobian = ∇⊗V;
	field#1(3)[3] curl = ∇×V;
	field#1(3)[] divergence = ∇•V;
	field#2(2)[2] U = ...;
	field#1(2)[] vort = ∇×U;
* Unicode: U+2207 (Nabla)
* LaTeX: `\nabla`.
* See above for the different uses of `∇`.  Note that `∇×` applied to a 2D vector field
  gives you a scalar, but `∇×` applied to a 3D vector field gives you another 3D vector field.
* For consistency, `∇` is used even for fields on a 1-D domain, which unfortunately defies
the expectation that `∇` somehow generates a vector.  Currently Diderot does not have a
different notation for differentation over a 1-D domain.
