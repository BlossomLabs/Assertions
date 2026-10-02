# Guarded dispatch candidate — isolated experiment

This candidate inserts `_checkPublicCall` at the start of both `_call` and
`_probe`. It rejects a self-targeted call whose first four bytes name
`evaluateGuarded`, using `GuardedCallForbidden()`. The typed `_tryEvaluate`
self-call is unchanged. Production Solidity and deployment artifacts are **not**
changed by this package. The original injection counterexample remains open for
production until adoption, compatibility work and artifact/proof refresh finish.

`Model.dfy` independently specifies dispatch admission and proves, for arbitrary
finite traces, that a guarded frame accepted by this boundary originated at the
typed guard helper. It also proves that trusted helper calls remain possible and
that calls to other targets remain allowed. This establishes call-site origin,
not validity of the helper's cache: that remains a recursive evaluator obligation.

`generate.py` obtains the pinned solc AST and gates the complete normalized
Expressions contract against the reviewed candidate structure. The only variable
slots are the presence of the two first-statement `_checkPublicCall(target, data)`
checks; missing-check faults lower to `true` rather than failing translation.
The helper's byte-length, self-target and selector checks, the direct sender
check, all external-call sites and the typed guard call are fixed by the gate.
The manual lowering maps a memory bytes sequence to its four-byte prefix and
models the guard's `msg.sender` check through the call site's EVM sender.

Assumptions: ordinary execution of the fixed deployed evaluator (no delegatecall
context); normal STATICCALL sender semantics; distinct foreign callers; faithful
Solidity memory/ABI projection; sufficient local resources; trusted pinned
compiler, translator and Dafny/Boogie/Z3. The theorem is not an exact compiled
bytecode proof or a full expression semantics theorem. An arbitrary external
callee can call back, but its sender is foreign and the direct check rejects it.
An ordinary self-evaluation starts fresh and traverses the same guarded generic
call sites. The gate must be reviewed again if any dispatch route is added.

The EVM suite covers the original Call injection, both well-formed and truncated
Probe payloads, short calldata, the same selector on a different target, ordinary
self-evaluation and `evaluateEncoded`. It also reruns all admission and cache
oracles. Each omitted-check fault must both fail `Dispatch`'s semantic
postcondition and fail exactly its designated EVM tests. A source-gate, parse,
type, timeout or resource failure does not count as a semantic kill.

Run from the repository root:

```sh
python3 -B formal/expressions/call-context/candidate/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /fresh/evidence/directory
```

The runner retains source snapshots, compiler AST input/output, translated
Dafny, native verification batches, auditor output, exact test inventories and
hashes. The baseline must pass every listed test and proof declaration; fault
runs must have the designated native and EVM failures. The retained manifest
uses `candidate-tested`, deliberately distinct from production proof status.
