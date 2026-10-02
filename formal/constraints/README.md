# Constraint engine correspondence

This package proves `_checkConstraint` and `_validateConstraints` against an
independent predicate and ordered-list specification. The input boundary is a
resolved byte sequence, a well-typed constraint list, and the actual outcomes of
Solidity's OR `abi.decode`. It does not yet connect `_resolve`, `assertParam` or
`assertBatch`. Those can reuse `ConstraintEngine.JudgeResolved`.

The authoritative run status, declaration inventory, native solver results,
commands, versions, hashes and source snapshots are in
[`evidence/constraint-engine/manifest.json`](evidence/constraint-engine/manifest.json).
The separate [fault campaign](evidence/constraint-faults/manifest.json) records
actual Solidity mutations, translated semantic failures and real EVM failures.
A declaration alone is not a completed proof.

## Claims

- `Check` agrees with `Leaf` and its independent kind-indexed `Holds` predicate
  for all 256-bit words and every non-OR kind. Signed words use two's-complement
  interpretation. Scalar references are exactly 32 bytes, ranges exactly 64,
  and SKIP exactly zero. Range endpoints are inclusive; reversed bounds reject
  according to the range's signedness.
- `Or` checks the entire decoded list for nested ORs before testing any leaf.
  Empty OR rejects. A decoder failure propagates as bare revert. `Alternatives`
  and `AlternativeFirstStop` characterize left-to-right evaluation: false
  continues; true or an error stops. Thus an earlier true masks later malformed
  leaf data, but cannot mask nested OR. Every leaf checks the same actual word.
- `ValidateConstraints` checks the available complete-word count before any
  predicate, including SKIP. Empty lists succeed without reading a word;
  trailing partial words are ignored. Constraint i consumes complete word i.
  `FirstFailure` and `FailureFields` establish the exact earliest failure index,
  constraint, actual word and reason, with every prior predicate successful.
- `JudgeResolved` succeeds exactly when enough complete words exist and every
  positional predicate succeeds. `Execute` gives the typed Solidity error and
  its fields, including the original outer OR kind/reference on an ordinary OR
  false result and the outer constraint index on a leaf error. Assertion text,
  entry index and parameter index are preserved where the error carries them.
- The loops are proved for arbitrary finite constraint and alternative lists,
  with no fixed unrolling or list-length bound. `WordWindow` discharges word
  offset, loop-increment and signed word-count conversion arithmetic under
  representable byte lengths. Actual execution still requires sufficient
  resources and representable physical arrays.

## Source connection and trust boundary

`generate.py` compiles the current production sources with pinned solc 0.8.36.
It gates the full normalized AST of both helpers and the constraint/error wire
vocabulary against `structure.json`. The gate includes statement order, loop
structure, error arguments, length checks, the memory read and enum order.
Only the named comparison and bounds slots vary; their actual AST expressions
are translated into `Engine.generated.dfy`. Unsupported structure changes fail
closed. `--bootstrap` is a developer operation for reviewing a new structure;
neither verification nor mutation runs bootstrap the gate.

The control-flow template and error projection are hand-written trusted
translations, not a verified Solidity frontend. The normalization helper is
reused from the navigation package, and its transitive Python sources are
snapshotted. The byte-object projection treats `mload` as a big-endian 256-bit
read, under valid, disjoint, nonwrapping Solidity memory. Mathematical words are
integers restricted to [0, 2^256), and signed conversion subtracts 2^256 above
the sign boundary. No arbitrary-width bitvector or integer is silently accepted
as a word.

OR decoder correctness is **an explicit open dependency**: `decode` is a total
function mapping reference bytes to rejection or the actual decoded finite
`Constraint[]`. The theorem quantifies over every such function and decoded
list; applying it to Solidity requires the supplied function to match solc.
It neither assumes OR bytes are canonical nor proves which malformed or
noncanonical byte encodings solc accepts. Out-of-range enum values are outside
the typed input boundary. Resource failures, compiler correctness and exact
compiled/deployed bytecode are outside this proof. Typed error serialization is
checked by the EVM oracle, rather than proved in Dafny. Dafny/Boogie/Z3 remain
trusted. No gas measurements, deployment observations or historical performance
claims are established here.

The source theorem removes list-unrolling bounds for the stated semantic
boundary. It does not retroactively unbound the existing Halmos ERC-8211
bytecode/parity evidence. Their bounds and status remain as recorded.

## Reproduce

Use the Dafny and Z3 distribution pinned in `../abi/toolchain.json` and the same
solc 0.8.36 binary as navigation:

```sh
python3 -B formal/constraints/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/constraint-engine
python3 -B formal/constraints/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/constraint-faults
```

Both runners refuse an existing output directory and retain immutable input
snapshots. The baseline verifies included definitions, requires complete native
results for every lemma/method, audits for unsound constructs, checks generated
output and formatting, and accounts for every oracle test. The EVM suite checks
exact revert bytes, positional errors, long lists, signed extremes and scalar
fuzz cases with a recorded seed. A fault counts only if generation succeeds, the
named semantic method fails without timeout, and its designated EVM test fails;
all other concrete tests must also be accounted for. Faults never modify the
production checkout. See the manifests for actual counts and outcomes.
