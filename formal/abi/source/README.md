# Bytes/string source correspondence

This milestone connects a **restricted program derived from the pinned Solidity
AST** to the independent ABI validator in the parent directory. The source slice
is `AbiCodec.body` for the literal descriptors `bytes` and `string`, the
three-argument `word` helper, and `validateDynamic`, with `ContextKind.Value`.
The original milestone left production unchanged. The current rerun includes
the bundled production correction: `validateDynamic` reports the first trailing
byte (`32 + walked extent`), while `unpack` is unchanged.

This is a conditional source-level proof. The small Python translator and its
memory interpretation are trusted, not formally verified. It is **not a proof
of compiled bytecode, the Solidity compiler, the descriptor parser, or the full
recursive ABI implementation**.

## Proof structure

1. `generate.py` requests the typed AST from solc 0.8.36 and lowers the selected
   statements into `BytesBody.generated.dfy`. The two aggregate branches are
   excluded only after evaluating their descriptor predicates at both literal
   types. Source spans and node IDs are retained. Unknown syntax, changed helper
   routing, unsupported types/callees and changed memory-load assembly stop
   generation. Do not use Python `-O`: validation assertions are required and
   optimized execution is refused.
2. Checked additions, subtractions, multiplications, division and indexing retain
   explicit panic outcomes. Short-circuit evaluation and the padding loop are
   retained. Proof hints are assertions and proved lemma calls, never assumptions.
3. The source's low-byte mask is normalized to a remainder. Its actual AST mask
   expression is checked by 32 independent 256-bit SMT queries, one for each
   possible padding count. Each quantifies over every 256-bit word. The generated
   program proves the count is in that exhaustive range. All 32 queries must be
   UNSAT for the normalization to be accepted; a standalone Dafny run without
   this gate does not establish the connection to the source mask.
4. `ByteSemantics.dfy` proves rounding, big-endian suffix/mask correspondence,
   zero padding and first-dirty-byte properties. `BodySpec` reads the actual
   length word and checks the consumed interval and zero padding independently
   of the production algorithm's mask optimization.
5. The three generated methods prove exact equality to `WordSpec`, `BodySpec`
   and `ValidationSpec`. `Correspondence.dfy` connects those results to
   `WalkBytes` and `Validate`, and then to the previously proved
   `AcceptedIffCanonical` theorem. The complete run includes every parent model,
   example and new source proof file.

For any admitted byte sequence and position, `body` succeeds exactly when the
model's prefix walker accepts, returns the same consumed extent, and ignores
following bytes. Invalid lengths/truncation report the frame position; dirty
padding reports its first dirty byte. The dynamic envelope must be 32 and exact
consumption is required; a suffix is rejected at its first byte. Under the assumptions below, none of the modeled panic
outcomes is reachable, including on hostile 256-bit length words. Strings are
arbitrary bytes; this imposes no UTF-8 requirement.

## Trusted boundary and remaining obligations

- The input is an existing valid Solidity `bytes memory` object, represented by
  its contents. A checked in-bounds `mload(add(add(data,32),p))` is interpreted as
  a big-endian 32-byte slice. Memory allocation, object layout construction,
  wrapped memory addresses and compiler-generated memory management are outside
  this model.
- The input length and initial position fit `uint256`. There is no chosen input
  length or loop unrolling bound below that limit. Mathematical sequences do not
  imply physically executable allocations of those sizes. Sufficient gas and
  execution resources are assumed; this contributes no gas-exhaustion proof.
- The descriptor is exactly `bytes` or `string`, `s=0`, and `e=t.length`.
  Descriptor parsing, non-root descriptor slices, recursive arrays/tuples,
  navigation and other callers' preconditions are separate obligations.
- `Invalid(offset)` denotes the existing `InvalidValue(offset)` error under
  `ContextKind.Value`. The error-routing helper is source-pinned. Callback and
  tuple-component contexts are excluded. Exact revert-data serialization and
  the public `validate` dispatcher are concretely tested, not derived by this
  source proof.
- The pinned solc typed AST, restricted AST translator, Dafny/Boogie and Z3 are
  in the trusted computing base. The translator is small enough for review but
  has no verified translation theorem. Source mutation checks show selected
  faults are detected; they cannot establish translator correctness in general.
- The bitvector queries and inductive proofs must pass together. No user axioms,
  `assume`, skipped bodies or termination escapes are used. `dafny audit` checks
  explicit proof escape hatches, not the verifier's own correctness.

Solidity's [compiler JSON/AST interface](https://docs.soliditylang.org/en/latest/using-the-compiler.html#compiler-input-and-output-json-description),
[checked arithmetic semantics](https://docs.soliditylang.org/en/latest/types.html#integers)
and [source mappings](https://docs.soliditylang.org/en/latest/internals/source_mappings.html)
describe the external interfaces interpreted by the translator.

The [current source baseline](../evidence/abi-codec-source-final/manifest.json)
retains all 182 successful verification batches, 32 mask obligations and 15 EVM
tests against the corrected source. The earlier source baselines and nine-fault
mutation evidence remain as separate history.

## Reproduce and inspect evidence

Use the parent `toolchain.json`: Dafny 4.11.0, bundled Z3 4.12.1, explicit
induction, two verifier workers and 30 seconds per batch. solc is pinned to
`0.8.36+commit.8a079791`; the concrete oracles use optimizer 200 and Cancun.
Forge and the repository's existing Node dependencies must be available.

```sh
python3 formal/abi/source/verify.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --output /tmp/abi-source-baseline

python3 formal/abi/source/mutations.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --baseline /tmp/abi-source-baseline/manifest.json \
  --output /tmp/abi-source-mutations
```

The retained [original baseline](../evidence/source-bytes-complete/manifest.json) passed
**68 lemmas and 5 proof methods, 182 verification batches, all 32 mask queries
and all 15 EVM tests**, with zero proof errors/timeouts, zero audit findings and
no source drift. Its native CSV and logs are beside the manifest. This includes
the 58 lemmas from the independent model; the milestone adds ten lemmas and five
methods, not 68 new lemmas.

Output directories must be new. The baseline snapshots sources, regenerates the
program and checks freshness, runs all bitvector and Dafny checks, inventories
every declaration, audits, checks the independent viem fixture, runs 15 EVM
tests and checks formatting. Logs, native CSV results, tool versions, executable
hashes, source hashes, source mappings, solc inputs/AST outputs, commands and
assumptions are retained. AST outputs are compressed as `solc-output.json.gz`.
The revision records the checkout base; source hashes
identify uncommitted inputs. Proof errors, zero/missing results, timeouts,
unknown solver answers and source drift cannot be reported as passed.

The six added EVM tests cover all padding bytes for payload lengths 0–65,
unaligned frames and arbitrary following data, first-dirty-byte ordering,
truncated words, hostile length words, missing padding, exact envelopes/extents
and a 4097-byte payload. They use independent solc `abi.encode` values and check
low-level call success and exact return/revert bytes. They supplement the nine
existing model oracles; finite EVM examples are not the inductive proof.

The ten mutations change copies of the **actual Solidity**: remove the payload
or padded-length guard, round down, skip padding validation, change the dirty
offset, change consumed extent, accept trailing data, restore the old trailing offset, reject an exact-size word,
or change the bit mask. Each valid source is recompiled to an AST and translated.
The nine non-mask cases require semantic failures in specific methods that passed the
full baseline. The mask mutation requires a SAT counterexample to normalization.
Syntax errors, translator rejection and timeouts do not count as detection.
Each altered contract must also fail at least one of the 15 concrete EVM tests,
with all tests accounted for. Live contracts are never edited. Mutation proof
runs are targeted fault checks, not complete baselines for altered implementations.
The round-down case uses `--isolate-assertions` to separate its obligations while
keeping the 30-second limit; no assertion is omitted or weakened.
The retained [source-mutation report](../evidence/abi-codec-source-mutations/mutations.json)
records **all ten faults detected**, each with an EVM test failure as well as
the required formal failure/counterexample. The final run has no timeouts or
source drift. Per-case altered sources, generated programs, compressed ASTs,
solver results and EVM logs are retained alongside the report.

The [initial mutation attempt](../evidence/source-bytes-mutation-attempt/archive.json)
is retained as a compressed archive with its baseline, sources, commands, native
results and logs. It is explicitly incomplete: grouped verification timed out
on round-down, and the first reporting regex missed a genuine loop-invariant
failure for dirty padding. Assertion isolation resolved the former; correcting
the report parser resolved the latter. This historical attempt is not counted
as a successful mutation run.

The [array/tuple milestone](../aggregate/README.md) now proves source-derived
cursor kernels and typed recursive composition with explicit descriptor and
static-word interfaces. [Exact-runtime checks](../bytecode/README.md) separately
cover finite array/tuple geometries. Descriptor parsing, `checkWords`, the
whole-function connection, caller/error contexts and unbounded bytecode induction
remain open.
