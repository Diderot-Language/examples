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
	
	        4   3   2   1   0 <-- strand idx
	step 0      |   |   |   |
	step 1      |   |   |   x
	step 2      |   |   |
	step 3      |   |   o
	step 4      |   |   :
	step 5    n(4)  |   :
	step 6  |   |   |   :
	step 7  |   x   o   :
	step 8  |       :   :
	step 9  o       :   :

The `print()` statements in this program are set up so that the output
can be piped into `sort` to put the results into a canonical order
that tells the chronology of super-steps, which have a strand update
and a following global update (so "global" comes alphabetically after
"Strand").  The `print` statements start with `print("0", step`
instead of `print(step` to be consistent with how the last snapshot
saved is state-0010.nrrd.

To compile, run, and show output:

	diderotc --snapshot --exec steps.diderot
	rm -f state*nrrd log.txt
	./steps -s 1 > log.txt
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
	   echo "0 1 2 3 4" | # array of strand idx
	     unu subst -s tmp-$II.txt -o tmp-$II.txt # after application of map
	   unu slice -i $SIIN -a 0 -p 0 |
	     unu histo -b 5 -min 0 -max 4 | unu axinsert -a 1 |
	     unu 3op lerp - 0 tmp-$II.txt | # zero out missing strands
	     unu flip -a 0 -o tmp-$II.txt # highest index first
	   echo -n "${II: -2}-Snap " | cat - tmp-$II.txt >> snaps.txt
	done
	rm -f tmp-*.txt

To combine part of the printed program output with the processed snapshots:

	grep ======= log.txt | cut -d' ' -f 4,5,6,7,8,9 | cat - snaps.txt | sort

Some features of the output of the above:

	00-Snap 0 1 1 1 1
	00-glob 0 3 3 3 3
	01-Snap 0 3 3 3 3
	01-glob 0 3 3 3 0

The `00-Snap` line comes before `00-glob` because snapshot
`state-0000.nrrd` documents the strand state after strand
initialization, but before the first step (step 0) has run.  The
`01-Snap` line (from `state-0001.nrrd`) shows how things are before
step 1, the step in which strand 0 (represented by the last digit in
the line) calls "die", and hence is removed from the strands visible
in the global update phase of step 1 (which logically comes after the
per-strand updates). In general `state-NNNN.nrrd` documents things
after `NNNN` steps have finished, and before step `NNNN` runs (this
was also noted in the [`life.diderot`](../life) example).

	05-Snap 0 3 3 7 0
	05-glob 1 3 3 7 0
	06-Snap 1 3 3 7 0
	06-glob 3 3 3 7 0

Step 5 is when strand 3 calls `new digit(4)`. Prior to running that
step, the `05-Snap` line (from snapshot `state-0005.nrrd`) shows no
strand 4 (the first digit in the line).  In the global update of step
5, strand 4 has been initialized but not updated, which is how things
still are in the the `06-Snap` line (from snapshot `state-0006.nrrd`).
The `06-glob` line (from the global update of step 6) we see that
strand 4 has updated.

	09-Snap 3 0 7 7 0
	09-glob 7 0 7 7 0
	10-Snap 7 0 7 7 0
	99-Snap 7 0 7 7 0

Before the last step (step 9), the `09-Snap` line (from snapshot
`state-0009.nrrd`) shows that strand 4 is still active (strands 2 and
1 are idle).  After strand 4 calls `stabilize` in step 9, the global
phase of step 9 (the `09-glob` line) reflects that change.  There is
one last snapshot, shown in the `10-Snap` line (from snapshot
`state-0010.nrrd`) documents things before step 10, which is not
executed.  The `99-Snap` line shows the final saved program output
`state.nrrd`, which is the same as the final snapshot.

TODO: what does it look like if a new strand immediately dies.

