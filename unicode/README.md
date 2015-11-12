## unicode.diderot: The Diderot unicode cheatsheet

This example program doesn't actually do anything; its just a
list of the Unicode characters that you might need in Diderot.
After each character is the LaTeX equivalent, which might be
useful for Diderot programs in LaTeX documents.

⊛ means convolution, as in:

	field#2(3)[] F = bspln3 ⊛ image("img.nrrd");
LaTeX: `circledast` is probably typical, but
`varoast` (with `usepackage{stmaryrd}`) is slightly more legible

× means cross product, as in

	vec3 camU = normalize(camN × camUp);
LaTeX: `times`

π means Pi, as in

	real rad = degrees*π/180;
LaTeX: `pi`

∇ means Del, as in

	vec3 grad = ∇F(pos);
LaTeX: `nabla`

• means dot product and matrix multiplication, as in

	real ld = norm • lightDir;
LaTeX: `bullet` which is more consistently visible than
the `cdot` which more typical for dot products.
Note that tensor double-dot product is just ASCII :

⊗ means tensor product, as in

	tensor[3,3] Proj = identity[3] - norm⊗norm
LaTeX: `otimes`

∞ means Infinity, as in

	output real max = -∞;
LaTeX: `infty`

