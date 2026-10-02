# Actual pass engine candidate

This is the complete actual finite merge-pass proof with identical entry, loop,
physical memory, trace, stable sorted-run and occurrence multiset contracts.
The final quantified implication is delegated to the independently proved
`BytecodeSortFinishedPass.Finished` lemma (25 obligations); preservation after
each block uses `BytecodeSortPassBlocks.Advance` (49 obligations). The canonical engine
and first complete retainer remain frozen while that retainer is live.

Native development must pass before transferring this proof factoring to the
canonical owner after the retainer terminates. A fresh complete retained graph
and independent checker still precede public bytecode coverage.

V1 retained its full contract but timed out once in loop-invariant preservation
after 358 passing obligations. That development snapshot remains preserved. V2
also isolates preservation of completed blocks; no postcondition is weakened.
