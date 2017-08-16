## steps.diderot: Demonstrates strand interaction, steps, and snapshots

This program creates a small collection of strands that undergo a
carefully scripted set of updates, to illustrate the interaction of
strand initialization, strand updates, and global updates as part of
the program super-steps and snapshots.  It also shows how the "all",
"active", and "stable" strand sets can be accessed in the global
update method.

Here is an ASCII-art depiction of the strand state and actions
on each step:

	| means strand is active
	o means active strand calls "stabilize"
	: means strand is stable (or idle)
	x means active strand calls "die"
	n(x) means active strand calls "new digit(x)"
	
	          5   4   3   2   1   0 <-- strand idx
	step  0           |   |   |   |
	step  1           |   |   |   x
	step  2           |   |   |
	step  3           |   |   o
	step  4           |   |   :
	step  5         n(4)  |   :
	step  6       |   |   |   :
	step  7       |   x   o   :
	step  8       |       :   :
	step  9     n(5),o    :   :
	step 10   x   :       :   :

The `print()` statements in this program are set up so that the output
can be piped into `sort` to put the results into a canonical order
that tells the chronology of super-steps, which have a strand update
and a following global update (so "global" comes alphabetically after
"Strand").  The `print` statements start with `z=zz(step); print(step,`
so that there is a consistent two-digit numbering; currently Diderot's
`print()` has no conversion sequences like `02%d` with `printf` in C.

To compile, run, and show output:

	diderotc --snapshot --exec steps.diderot
	rm -f state*nrrd log.txt
	./steps -s 1 > log.txt
	export LC_ALL=C # to ensure traditional sort order
	sort log.txt | grep -v =======

(TODO: explain output in `log.txt`)

The snapshots `state-????.nrrd` are processed into `snaps.txt` with:

	rm -f snaps.txt
	touch snaps.txt
	for SIIN in state-????.nrrd state.nrrd; do
	   IIN=${SIIN#*-}
	   II=${IIN%.*}
	   if [ "$II" == "state" ]; then
	      II=99;  # final (not snapshot) state is numbered 99
	   fi
	   echo 0 0 1 2 4 | # 1:inited 2:updated 4:idle
	     unu 2op x $SIIN - | # (pair-wise multiply)
	     unu project -a 0 -m sum | # one octal value per strand
	     unu splice -i $SIIN -s - -a 0 -p 1 | # 2nd pos on axis 0
	     unu crop -min 0 0 -max 1 M -o tmp-$II.txt # substitution map
	   echo "0 1 2 3 4 5" | # array of strand idx
	     unu subst -s tmp-$II.txt -o tmp-$II.txt # after application of map
	   unu slice -i $SIIN -a 0 -p 0 |
	     unu histo -b 6 -min 0 -max 5 | unu axinsert -a 1 |
	     unu 3op lerp - 0 tmp-$II.txt | # zero out missing strands
	     unu flip -a 0 -o tmp-$II.txt # highest index first
	   echo -n "${II: -2}-Snap " | cat - tmp-$II.txt >> snaps.txt
	done
	rm -f tmp-*.txt

To combine part of the printed program output with the processed snapshots:

	grep ======= log.txt | # looking for status summaries from global update
	cut -d' ' -f 4,5,6,7,8,9,10 | # -glob index and values for 6 strands
	cat - snaps.txt | # combining with snapshot summary
	sort

Some features of the output of the above:

	00-Snap 0 0 1 1 1 1
	00-glob 0 0 3 3 3 3
	01-Snap 0 0 3 3 3 3
	01-glob 0 0 3 3 3 0

The `00-Snap` line comes before `00-glob` because snapshot
`state-0000.nrrd` documents the strand state after strand
initialization, but before the first step (step 0) has run.  The
`01-Snap` line (from `state-0001.nrrd`) shows how things are before
step 1, the step in which strand 0 (represented by the last digit in
the line) calls "die", and hence is removed from the strands visible
in the global update phase of step 1 (which logically comes after the
per-strand updates). **In general `state-NNNN.nrrd` documents things
after NNNN steps (with normal 1-based counting) have finished, and
before (0-based index) step `NNNN` runs**.  This subtle point bears
some contemplation: it **not** the case that `state-NNNN.nrrd` documents
things at the end (0-based index) step `NNNN`. The chronology of steps
and snapshots is also demonstrated in the [`life.diderot`](../life) example.
Continuing with this example:

	05-Snap 0 0 3 3 7 0
	05-glob 0 1 3 3 7 0
	06-Snap 0 1 3 3 7 0
	06-glob 0 3 3 3 7 0

Step 5 is when strand 3 calls `new digit(4)`. Prior to running that
step, the `05-Snap` line (from snapshot `state-0005.nrrd`) shows no
strand 4 (the first digit in the line).  In the global update of step
5, strand 4 has been initialized but not updated, which is how things
still are in the the `06-Snap` line (from snapshot `state-0006.nrrd`).
The `06-glob` line (from the global update of step 6) we see that
strand 4 has updated.

	09-Snap 0 3 0 7 7 0
	09-glob 1 7 0 7 7 0
	10-Snap 1 7 0 7 7 0
	10-glob 0 7 0 7 7 0
	11-Snap 0 7 0 7 7 0
	99-Snap 0 7 0 7 7 0

Before the step 9, the `09-Snap` line (from snapshot
`state-0009.nrrd`) shows that strand 4 is still active (strands 2 and
1 are idle). In step 9, strand 4 calls `new digit(5)`, and the global
phase of step 9 (the `09-glob` line) reflects that strand 5 has been
initialized by not updated; the `10-Snap` line (from snapshot
`state-0010.nrrd`) shows the same information. Step 10 is when the
new strand 5 immediately dies. So even though the `update` method
of strand 5 has been called, because this strand does not show up
in any strand set in the global phase, it is not included included
in the summary of strand states (that is, in these logs we never
see value 3 for strand 5, even though its `update` was executed).
**This highlights what is currently a limit on what you can learn about
the program execution from within Diderot or by looking at snapshots:
there is no enduring record of what strands died when or why**.  That means
you can only learn that a strand's `update` method was called if it does not
immediately die, unless you've used `print` messages to explicitly document
the execution of `update` as it happens.
The `99-Snap` line shows the final saved program output
`state.nrrd`, which is the same as the final snapshot.

