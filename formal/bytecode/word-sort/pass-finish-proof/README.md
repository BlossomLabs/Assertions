# Final pass invariant factor

The first complete sort retention timed out in the final quantified run
invariant of `BytecodeSortPassEngine.Run` after 365 passing obligations.
Development had passed the same contract at the unchanged 30-second limit.
The running retention and its inputs remain untouched.

`Finished.dfy` isolates the exact final implication: every completed doubled
block is a stable sorted permutation of its original occurrence IDs, and the
completed block extent covers the array, so the whole scratch array satisfies
the doubled-width `Runs` predicate. No range, ordering or multiset requirement
is weakened. Native development evidence is required before using the lemma;
the existing engine can only be changed after its full retainer terminates.
