# Exact physical unknown-selector rejection

This package connects the immutable retained dispatcher certificates to actual
byte memory, stack operations and empty `REVERT` for the current Assertions,
Expressions and Collections runtime bytes. It adds no accepted public-body
coverage.

`Bridge.dfy` proves equal instruction fetches and each physical opcode step.
Generated per-state frame certificates establish stack bounds, initial memory
store admission and executable instruction/destination byte equality.
`Execution.dfy` connects every consecutive physical state; the generated runs
terminate by the retained increasing PC rank. `Connection.dfy` composes all
three families, retaining exact initial/final states and physical memory bounds.
The terminal certificates give a fixed empty-revert oracle for bytecode faults.

## Scope and premises

The root admits zero call value, a calldata size at least four and an unassigned
compiler selector. Size and the loaded first word range over all 256-bit values.
The lower 224 bits and other calldata contents are arbitrary. Nonpayable/short
rejection has independently retained evidence. Accepted selectors and their
ABI wrappers/bodies remain separate.

Trusted boundaries include exact artifact/source/runtime extraction and
reproduction; reviewed instruction-boundary scanning and reached EVM opcode
interpretation; faithful fresh memory and CALLVALUE/CALLDATASIZE/CALLDATALOAD
observations; Dafny/Boogie/Z3, solc, Node/Hardhat/EDR and reviewed scripts.
Adequate reached execution/memory/stack resources remain explicit. The theorem
bounds reached stack by three words and memory by 96 bytes; it proves no gas
cost, deployment, complexity, performance or unconditional resource availability.

## Retention

Finish every package file before starting `verify.py`. It snapshots inputs and
tools, binds retained dispatch and physical pre-ABI dependencies before/after,
reproduces full current runtimes, regenerates controls byte-for-byte, checks the
entire native declaration/include graph and zero audit, and records fifteen
complete EVM receipts. Three one-byte REVERT-to-RETURN faults require both a
baseline-covered native postcondition failure and a contradictory full EVM
receipt. Typing/generation/precondition failures and timeouts are not semantic
detections. A ledger/checker and any public claim require terminal retained
success; development checks and finite EVM fixtures cannot replace the native
connection. Never restart a live run because polling times out.

## Preserved development history

`development/physical-connections-v1` snapshots the original physical bridge,
execution and three generated connections. The Assertions module recorded
5,392 passed obligations and one timeout in its loop resource invariant;
Expressions passed 1,729 obligations. Its original snapshot/results are
preserved. An isolated proof experiment removes broad dispatcher predicate
unfolding from the loop and explicitly connects the next physical frame bounds.
The original Collections command hit its 1,800-second watchdog before final CSV.
Retained V1 stopped for an incomplete isolated dependency mirror. Retained V2
passed 7,272 fresh obligations, zero audit, fifteen complete EVM receipts, three
semantic bytecode faults and source/tool/dependency stability, but its Collections
command reached the 1,800-second watchdog after 270/273 symbols. Both failures
are preserved and excluded from public evidence. V3 raises only the command
watchdog to 5,400 seconds; per-obligation solver limits remain unchanged.
