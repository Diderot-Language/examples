## hello.diderot: The usual greeting, in Diderot


You can compile `hello.diderot` with:

	diderotc --exec hello.diderot
and then run it with:

	./hello
After the `hello` executable prints `hello, world`, it saves a single-element
1-D array into `out.nrrd`.  We can inspect its contents with:

	unu save -f text -i out.nrrd
which should print the number 42.
