# Public value map/filter/fold source composition

This package connects `mapValues`, `filterValues` and `foldValues` from raw
callback preparation through type admission, concrete iteration and their
source-gated public loop adapters. It covers arbitrary finite admitted executions
under the explicit resource and representation premises below.

`Admission.Run` calls the actual preparation adapter with concrete codec-error
encoding, then source-connected input descriptor parsing and output descriptor
parsing (map) or initial accumulator validation (fold). Preparation and admission
can reject. They still execute on empty input. The resulting environment pins
exact helper replies at each reached context and preserves preparation history.

`Connection.Run` constructs the concrete tail only after successful admission.
It threads prepared arguments, the lazy target-check cache, callback history and
fold feedback, then splices admission and tail environments without changing any
reached observation. Applying `CollectionsValueLoopsConnection.Run` connects this
environment to the actual source-loop adapters. Failure propagates the exact
admission outcome or last reached iteration outcome; all earlier rows succeeded.
Successful map has one checked result per input. Successful filter returns
original encodings at strictly increasing source positions. Fold threads each
checked callback value into the next accumulator and returns the initial value
on empty input after admission. Callback helper indices form exactly a prefix
starting at zero; a helper attempt can fail before an external call.

`Row` exposes concrete per-element records, input/result validation, map outputs,
fold accumulator updates and filter's exact one-word 0/1 predicate rule. There is
no success or valid-return assumption. The record's source callback invocation
retains its full prepared state and history, including direct ABI versus expression
encoding and gas-aware failure classification from the completed helper proofs.

Operation contexts equal the selected public function's selector. `generate.py`
obtains those selectors from pinned solc method identifiers; the retained verifier
regenerates and compares them. This discharges the previously caller-supplied
operation-context choice for these three entry points.

## Premises and remaining scope

`Room` records Solidity input widths/lengths, preparation codec resources and
admission validation resources. `Budget` requires a tail budget only for matching
admitted preparation receipts with canonical constants and successful type
admission. Its history is produced by preparation itself. The tail budget follows
continuing receipt-consistent iterations and assumes neither callback success nor
canonical returned values. No suffix resources are required after failure.
`EmptyBudget` and `RejectedTypesBudget` explicitly discharge the tail premise
for empty input and rejected type admission. Within a reached row, the existing `AfterRoom` still overapproximates some skipped
work; these bounds are sufficient, not necessary.

The external environment must faithfully supply history-sensitive code, call and
gas outcomes, including relevant execution context. No external determinism or
gas independence is inferred. Logical state tokens are separate from concrete
prepared state. Failure receipts describe the failed frame, not committed memory.

Valid ABI-decoded inputs and projected decoded returns, nonaliasing representable
memory/arithmetic, adequate local gas/stack/allocation, compiler ABI, reviewed
source/offset/context projection, restricted AST lowering and Dafny/Boogie/Z3
remain explicit premises. Logical sequence buffers do not prove the physical
allocator or outer ABI return serialization. This is conditional public source
semantics, not exact compiled-bytecode verification.

Only these three value entry points are covered. Other value operations, word
operations, sorting and complete Collections verification remain open. The full
29-entry public inventory remains the goal.

The retained run checks source/tool/artifact provenance and native declaration
coverage, regenerates public selectors, audits for trusted proof shortcuts, and
replays the seven existing public value-loop EVM fixtures. Those fixtures cover
map/filter/fold order, empty-input target behavior and exact failure precedence;
they do not establish universal bytecode correctness. No new source-fault, gas,
deployment or historical performance claim is made.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/value-entry/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/value-entry/evidence/public-value-traversals-v2
```

The first retained attempt failed on a timed-out auxiliary row assertion and is
not evidence. The v2 baseline removes that redundant proof step; all theorem
postconditions and scope are preserved.
