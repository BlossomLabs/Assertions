# Guarded dispatch source connection

The production `_call` and `_probe` entry checks reject self-targeted
`evaluateGuarded` calldata with `GuardedCallForbidden()`. The typed
`_tryEvaluate` self-call remains available. This closes the previously reproduced
generic Call/Probe route for supplying an arbitrary cache.

The independent model proves that an accepted guarded frame must originate at
the typed helper, for arbitrary finite request traces. It also proves that
trusted helper calls remain possible and other targets remain allowed. Cache
validity at that helper remains a recursive evaluator obligation. No complete
Expressions or exact-bytecode theorem is claimed.

`generate.py` gates the complete normalized production Expressions AST. Its only
variable slots are the two first-statement dispatch checks. Omission of either
check translates to `true`, then fails the semantic dispatch postcondition.
Compiler-allocated declaration IDs are resolved to source path/kind/name;
overload lists preserve cardinality. Translation and this normalization are
trusted. The production AST was compared with the previously tested candidate;
its executable structure is identical.

Assumptions: ordinary execution of fixed deployed code (no delegatecall context),
normal STATICCALL sender semantics, distinct foreign callers, faithful Solidity
byte-array/selector projection, sufficient local resources, and trusted pinned
solc/Dafny/Boogie/Z3. Outside callees calling back have foreign sender identities;
ordinary self-evaluation uses fresh caches and the same restricted dispatch.

The runner retains complete snapshots, compiler AST input/output, native Dafny
rows and declaration inventory, auditor results, source/tool/artifact hashes and
all 22 EVM tests. Tests cover the two blocked generic routes, malformed/short
calldata, normal self-evaluation, encoded evaluation, the same selector on an
external target, and the full admission/cache oracles. Both omitted-check faults
must fail the named semantic theorem and exactly their designated EVM tests.

```sh
python3 -B formal/expressions/dispatch/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /fresh/evidence/directory
```

The old candidate and counterexample snapshots remain historical evidence; they
must not be presented as tests of the revised production source. Deployment and
SDK adoption have a separate release gate.
