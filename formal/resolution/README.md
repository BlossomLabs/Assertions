# Resolution and judge source correspondence

This package connects `_resolve`, `_staticCall`, `_rejectOutOfGas`, `_firstWord`,
`_asAddress`, `_judge` and both overloads of `assertParam`/`assertBatch` to an
independent ordered execution model. It composes the constraint engine proof
rather than assuming constraints succeed. The raw-value public `resolve`
primitive and the remaining core primitives have separate composition work;
this package's `ResolveSource` is the internal resolver.

The authoritative status is in
[`evidence/resolution-judge/manifest.json`](evidence/resolution-judge/manifest.json).
The [fault campaign](evidence/resolution-faults/manifest.json) requires actual
Solidity faults to fail both their named semantic proof and an EVM test.
Neither a declaration nor an earlier development run establishes completion.

## Semantics

`ResolutionModel.Fetch` defines RAW_BYTES as identity, STATIC_CALL through an
explicit decoder and external observation, and BALANCE through exactly forty
packed address bytes. Native balance reads produce a single canonical word.
Token balances use the `balanceOf(address)` calldata, require at least one return
word, and encode just that word; extra returndata is ignored. Fetch errors occur
before constraint checks. `ResolveSuccess` characterizes resolver success as
fetch success, enough complete words and success of every positional constraint.
Successful resolution preserves the fetched bytes exactly.

External results are **history-indexed observations** of code presence,
staticcall success, raw returndata, the two sampled gas values and native
balances. Repeated requests can differ; there is no hidden deterministic-call
assumption. The history records call attempts (including failed code-presence
checks) and native balance reads, not only EVM call opcodes. Successful calls
ignore the failure-only gas check. Failed calls propagate `SubcallOutOfGas` when
the sampled gas comparison holds or the returndata is exactly its four-byte
selector; longer data with the same prefix does not count. Other failures and
code-less targets produce `CallFailed(target, calldata)`.

`RouteAll` specifies sequential parameter routing with full entry/parameter
contexts. Output parameters reject before any input; VALUE rejects before
resolution; duplicate TARGET rejects before checking whether its fetcher is
BALANCE. A TARGET's constraints are checked before its first word and address
width. CALL_DATA results concatenate in parameter order after the four-byte
selector. A zero resolved target performs no constructed call, even when a
TARGET parameter was present. A nonzero constructed call must succeed, but its
returned bytes—including an encoded false—are ignored.

`JudgeBatch` refines `Batch` for arbitrary finite entry and parameter lists.
`BatchResults`/`BatchFirstFailure` characterize the actually evaluated prefix:
all earlier entries succeed, the first failed entry's exact result and history
propagate, and no later entry executes. `AssertOne` ignores routing and supplies
context (message, 0, 0). `DefaultParam` and `DefaultBatch` additionally pin the
source's PARAM and COMPOSABLE default messages. Empty batches succeed.

`ResolutionWords.ReadBridge` connects the constraint engine's full-width word
interpretation to the existing ABI model's big-endian `ReadNat` for every byte
sequence of length at most 32. `EncodedWord` proves the canonical 32-byte
round-trip; `AddressFits` proves the packed 20-byte address bound. These reuse
`AbiFrames` rather than assuming an independent encoding oracle.

## Source connection and limits

The pinned solc 0.8.36 AST is gated in full for the ten helper/overload bodies,
the balance interface, errors and wire definitions. The restricted translator
extracts actual gas, length and address guards and default-message literals into
the source model. Everything else, including statement order, is checked against
the reviewed structure. Unsupported drift rejects. `--bootstrap` is a developer
review operation, never part of a positive or mutation run.

The control-flow template, AST frontend/normalization and memory projection are
trusted translations, not a certified Solidity compiler. `ConstraintError`
embeds the original constraint error unchanged; it is a model namespace, not a
new on-chain error wrapper. Error ABI serialization, selectors and physical
memory operations are checked concretely and remain explicit translation
premises. Dafny/Boogie/Z3 are trusted. All included proof modules, including the
ABI word and constraint dependencies, run afresh in the retained baseline.

Inputs are well-typed decoded Solidity arguments, with four-byte entry selectors.
`decodeCall` and `decodeOr` must supply actual solc decoder outcomes. This proves
propagation of decoder rejection, not general solc decoder acceptance. External
observations must correspond to the execution being modeled. All intermediate
byte lengths and physical memory arithmetic must be representable, memory must
be valid/nonwrapping, and local computation must have sufficient gas, stack and
allocation. These conditions exclude local resource failures; the explicit
subcall failure policy is still modeled. The gas classifier is proved against
sampled values, not a universal diagnosis of whether a callee truly exhausted gas.

No list-unrolling bound is imposed. This is a source theorem; it does not prove
compiler correctness, exact compiled bytecode, arbitrary external producer
correctness, Biconomy equivalence, deployment observations or gas performance.
The full Assertions/Expressions/Collections objective remains open beyond this
package; its inventory is tracked in `../verification-plan.json`.

## Reproduce

Use the Dafny/Z3 distribution pinned in `../abi/toolchain.json` and solc 0.8.36:

```sh
python3 -B formal/resolution/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/resolution-judge
python3 -B formal/resolution/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/resolution-faults
```

The runners refuse existing output directories and retain source snapshots,
compiler input/output, tool versions/hashes, commands, native proof rows and
exact concrete test inventories. Missing results, timeouts, audit findings and
unaccounted tests cannot count as passed. Mutation source rejection is incomplete,
not a proof kill. Production Solidity is never modified by either runner.
