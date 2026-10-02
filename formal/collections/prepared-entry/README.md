# Raw preparation through the first callback attempt

This helper composition starts from a raw callback descriptor, constants and
slots. It invokes the completed arbitrary-admission/source-constant proof with
the concrete codec error encoder, then connects a successful prepared state to
the completed source callback invocation proof.

There is no admitted-descriptor, valid-slot, matching-arity or valid-constant
assumption at entry. `Room` supplies representability and sufficient resources:
uint256 lengths/counts, component widths and CursorRoom, final substituted
argument extent and expression packet extent. Conditions involving an accepted
tuple witness apply only if such a matching witness exists and slots are valid.
They do not assert that it exists. Some resource bounds cover unreached ghost
values. The two callback views must agree on their descriptor and slot fields.

`Run` returns the source preparation outcome and environments plus a tagged
result: preparation rejection or an invoked callback. Rejection preserves the
exact preparation bytes, including compiler-bound InvalidCallback, parser errors
and first failed constant receipts. Preparation emits only codec events: rejection
adds no target lookup or external call. The event-concatenation lemmas prove this
for arbitrary finite preparation histories and incoming histories.

Successful preparation recovers an admissible descriptor witness, canonical
constants outside replacement slots and an unchecked target flag. The subsequent
source `_callValue` uses actual component receipts and concrete calldata encoders,
with the preparation events prefixed to its supplied history. A successful call
has canonical final arguments, direct readiness, exact substituted slots and a
checked target cache. The complete attempt performs one target check and at most
one external call; rejected preparation performs neither.

This is not a public map/filter/fold entry-point theorem. Those traversals also
validate input/output descriptors and values between preparation and invocation,
and thread state through repeated calls. Those stages, result validation and
outer error-packet resource bounds remain to be composed. External code/call/gas
outcomes remain supplied history-sensitive observations. Source translation,
compiler ABI, faithful context/offset projections, physical memory/resources and
Dafny/Boogie/Z3 remain trusted. This adds no exact-bytecode, deployment or
performance claim.

The proof-only driver reuses completed source packages under identical source,
tool, artifact and native-result checks. It verifies every local lemma/method,
checks formatting and requires a zero-finding audit. No new EVM fixture or
source-fault campaign is claimed.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/prepared-entry/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/prepared-entry/evidence/raw-preparation-call
```
