# Callback outcomes through traversal result checks

This package composes the source callback/predicate and canonical result-validator
proofs into the replies consumed by a traversal. `FromRecord` first exposes the
exact source `_callValue` outcome at an index of a completed callback record chain,
then applies the result adapter. It does not assume successful or well-typed
callback returns.

`Complete` retains three distinct outputs: the call reply, a zero-or-one sequence
of result-validation replies, and the final reply. A failed callback preserves
its exact encoded outer error and performs no result validation. A successful
value callback produces its raw return bytes before validation, matching the
source map/fold assignment order. Validation then either preserves that value or
propagates its own error.

For predicate callbacks, the source predicate accepts exactly Word(0) or Word(1).
Its invalid-result error uses the full operation/index/other/target context.
Value-result validation uses operation/index/zero/target as `_validateResult`
does. It accepts exactly the independent canonical ABI values, with exact field
bytes on value errors and preserved parser errors on malformed descriptors.
Predicate processing never adds a separate codec result-validation request.

`Room` requires representable context fields, the outer failure packet's explicit
`ErrorFits` bound, a uint256 descriptor length, and codec validation resources only
for a returned value in value-result mode. Failed calls do not require returned
value validation resources. Compiler ABI, source translation, faithful context
and offset projection, physical memory/resources and Dafny/Boogie/Z3 remain
trusted.

This is a per-callback observation connection. A repeated callback chain alone
does not establish that a public traversal reaches every one of its records:
the traversal must stop if an earlier predicate or result check fails. Operand
selection, fold accumulator feedback, input validation and that combined stopping
policy still need to be connected to the public source loops. No complete
map/filter/fold or exact-bytecode theorem is claimed here.

The proof-only retained run checks dependency source/tool/artifact hashes and
native evidence, every local declaration, formatting and a zero-finding audit.
Concrete/source-fault evidence is inherited through the completed dependencies;
there is no new EVM fixture, mutation campaign, deployment or performance claim.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/call-results/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/call-results/evidence/callback-result-observations
```
