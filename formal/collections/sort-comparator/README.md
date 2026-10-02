# Signed sort comparator and concrete callback connection

This package proves the comparison request and result-checking fragment of
`sortValues`, then connects it to actual binary component binding, canonical
callback encoding and `_callValue` source semantics. It does not yet prove the
complete sort entry point or its traversal.

The complete `sortValues` AST is structurally gated. The generator translates
the actual operands `out[c.a]`/`out[c.b]`, binary flag, call context indices,
length test, word offset, signed comparison operator/bound and invalid-result
context fields. The operation selector comes from fresh compiler method IDs.
`Request` certifies that callback indices are the current merge positions.
Whole-function gating anchors the fragment; it does not claim the other source
statements have been lowered or verified by this package.

The independent verdict criterion is byte-based: a valid result has exactly
32 bytes, and chooses the left element iff the first byte has its high bit set
or all bytes are zero. `Leading`, `Zero` and `Sign` prove equivalence to signed
256-bit interpretation and `<= 0`. The generated source adapter calls the actual
proved `AbiCodec.word` reader. It accepts every one-word bit pattern, including
signed extremes and non-Boolean values. Wrong lengths fail with the exact
`InvalidCallbackResult(operation,a,b,target)` bytes. A callback failure is
propagated first, so it cannot turn into a result-length error.

`Connection.Run` composes this fragment with concrete `BoundCall.Run`, retaining
exact codec receipts, encoded arguments, target-cache state, partial argument
assignments and history-sensitive external outcomes. `FromIndices` instantiates
it with the generated current-buffer request and compiler-bound sort selector.
Result checking adds no low-level event, callback or prepared-state mutation.
These are tentative in-frame states; an enclosing Solidity revert still aborts
the sort and is not claimed to persist those states externally.

Entry assumes an admitted rendered callback tuple, valid distinct binding slots
and canonical constants outside those slots. Uint widths/lengths, CursorRoom,
argument/expression/error packet bounds, faithful decoded memory/context/offsets,
compiler ABI and sufficient execution resources remain explicit. `AfterRoom`
requires representable error packets for compatible actual binding receipts; it
does not require external success, a canonical comparator result, determinism or
history independence. Raw preparation, all-input prevalidation, merge traversal,
first failure across multiple comparisons and comparator coherence still require
composition. Signed casting, restricted translation, compiler AST, Dafny,
Boogie and Z3 remain trusted source-proof boundaries.

The driver checks identical retained dependency evidence, verifies all local
modules, requires zero audit findings and formatting, and executes nine EVM
fixtures. They cover minimum/maximum signed values, minus one, zero, plus one,
short/long returns, later-pass current indices, wrapped failure calldata/context,
and exact exhaustion-signal propagation. Three isolated source faults change
zero tie handling, invalid-result `other`, and call-context `other`; each must
pass translation but fail the relevant source theorem and EVM suite. Timeout
alone is not counted as fault detection.

```sh
python3 formal/collections/sort-comparator/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/sort-comparator/evidence/signed-comparison-source
```

The retained manifest is authoritative for completion and counts. This package
adds no completed public entry and makes no compiled-bytecode, complexity, gas,
deployment or historical-performance claim.
