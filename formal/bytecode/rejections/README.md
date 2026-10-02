# Physical raw entry rejection

This package covers complete PC-zero through REVERT paths for nonzero call
value and zero-value calldata shorter than four bytes in all three current
runtimes. It strengthens these rejection classes from the dispatcher's memory
initialization flag to the retained getter model's physical byte memory.
No public rejection completion is counted before a retained verifier, current
native/declaration/source/tool/artifact closure, zero audits, full EVM fixtures
and semantic bytecode faults pass.

`verify.py` snapshots the finished package and the complete passed getter evidence
as an immutable model dependency. Its checker runs before and after retention,
and the exact shared model and proof-tool hashes must match. The runner reproduces
the current full runtimes, regenerates all six certificates and requires every
native declaration, zero audits and formatting. Twenty-one full EDR fixtures
check actual PCs, empty failed receipts, the initial physical MSTORE and final
memory/stack frames. Six binary candidates replace the reached REVERT with RETURN;
each must translate, fail a baseline-covered rejection postcondition, and produce
a real successful EVM receipt. Timeout or translation error is not detection.

`generate.py` checks each complete runtime hash and scans full instruction
boundaries. It emits both symbolic environment classes for each contract,
constraining every executed byte and taken jump destination. Nonzero value leaves
calldata size arbitrary. Short frames leave the loaded word arbitrary because
CALLDATALOAD is never reached. Every step must prove the selected path for the
whole admitted class, an actual stack cap of three and byte memory cap of 96,
then exact `Reverted([])`. Composition executes every step as a finite sequence;
no fuel cut-off drops a path. Generated files are never hand-edited.

The shared `../getters/Machine.dfy` has retained native proof evidence and remains
an explicit immutable dependency. Future retention must bind that exact model
and its current getter evidence/checker rather than assuming an imported method
is proved. No ABI argument decoding or accepted function body is covered here.

Trusted boundaries are exact byte extraction, reviewed instruction scanning and
reached EVM interpretation, fresh zero call memory and truthful CALLVALUE and
CALLDATASIZE observations. Declared jumps must be actual full-runtime instruction
boundaries; unconstrained unused bytes do not establish arbitrary mutation
invariance. Adequate reached execution resources and Dafny/Boogie/Z3 remain
explicit. No compiler/body equivalence, gas, deployment, complexity, performance
or unconditional resource safety claim follows.
