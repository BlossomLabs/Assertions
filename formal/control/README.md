# Guarded resolution and revert-probe correspondence

This package connects `orElse`, `isValid`, `revertData` and their exhaustion guard
to independent semantics. It composes the proved resolver and constraint engine.
The retained [baseline](evidence/guarded-control/manifest.json) and
[source-fault campaign](evidence/guarded-faults/manifest.json) are authoritative.

`GuardSource.OrElseSource` preserves successful bytes, evaluates the fallback
only after an ordinary failure, and resolves it with operand index 1. Exhaustion
classification precedes fallback. `IsValidSource` returns the encoded word 1 or
0 from the attempt's success status, except that failed exhaustion propagates.
`GuardModel.ValidityFromResolution` connects this result to successful fetching
and every positional constraint, without fixed constraint or OR-leaf bounds.
`SuccessfulAttemptPreserved` and `ExhaustionSurvivesSelfCall` connect guarded
results to the resolver in its own call frame.

`ProbeSource.RevertDataSource` checks STATIC_CALL admission before constraints,
then decoding, then the target. `InspectSource` establishes exact precedence:
code-less handling; successful-call rejection; failed-call exhaustion; selector
matching and stripping. A zero selector accepts the entire ordinary revert
payload. Nonzero selectors require at least four matching bytes. Underlength
payloads report selector zero. The independent `SelectorStripped` lemma proves
that concatenating the selector and returned suffix recovers the original data.
Payloads and finite constraint lists have no fixed verification bound.

## The call-boundary premise

An outer self-call receipt is related to resolution in the callee's own
history/context by `MatchesResolution`. `ResolutionReceipt` runs the proved
resolver and constructs such a receipt. Relating that receipt to an actual EVM
self-call remains an explicit ABI, frame and external-observation premise:
`SelfEnvironment.core` is this contract, `encodeResolve` is its actual
`abi.encodeCall(this.resolve, (param))`, and error serialization matches solc.
The proof does not identify sender, gas or call histories across frames, nor
assume repeated calls deterministic. It does not prove recursive tree/graph
equivalence. Histories record attempted requests, including code-less probes;
they are a semantic trace, not a count of executed STATICCALL opcodes.

`generate.py` pins the complete normalized solc AST of the three public methods,
`resolve` and `_rejectOutOfGas`, together with error and wire declarations. It
translates the exhaustion condition, admission guards, selector width, fallback
index and validity constants from AST expressions. Remaining control flow and
memory operations are reviewed, structurally gated template translations.
Unsupported structural drift rejects; normal verification never bootstraps.

Trusted premises include this translation, solc AST/decoder and error encoding,
valid typed inputs, faithful nonwrapping memory projection, representable
intermediate sizes and sufficient local resources. External observations must
match code presence, call outcome, returndata and sampled gas. Gas classification
is exactly the source's sampled predicate; it is not a universal proof that every
exhaustion is detected or every ordinary failure is distinguishable. The exact
four-byte marker is reserved, not authenticated. Dafny/Boogie/Z3 are trusted.
Compiler correctness and exact deployed bytecode are separate obligations.

The eight EVM tests check exact bytes, malformed decoding, code-less calls,
fallback indices, all admission cases, selector boundaries and reserved-marker
propagation, including a nested guard. One bounded burner checks a concrete
exhaustion path; no gas measurement or historical performance claim follows.
Five actual Solidity faults must pass translation and fail both their named
semantic theorem and designated EVM test without a timeout. All included proof
dependencies are verified afresh; native rows and declaration accounting,
source/tool hashes, audit, formatting and complete EVM inventories are retained.

```sh
python3 -B formal/control/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/guarded-control
python3 -B formal/control/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/guarded-faults
```

The broader objective remains in `../verification-plan.json`. Codec-backed
`get`, resolver/navigation composition, recursive self-call semantics,
Expressions, Collections and exact-bytecode verification remain separate work.
