# Concrete finite map/filter/fold iteration chains

`Build` constructs an arbitrary finite reached chain by calling actual input,
callback binding/encoding/execution, predicate and result-validation helpers in
order. It does not accept a precomputed sequence of successful callbacks.
Each next iteration receives the previous prepared arguments, target-check cache,
low-level callback history and high-level traversal context. Fold receives the
previous successful callback value as its next accumulator. Any input, callback,
predicate or result failure stops construction immediately.

`Run` assembles the local environments into one environment and proves equality
to `CollectionsTraversalModel.Tail`. Every reached observation window is
preserved. Every row is pinned to the exact independent input, callback and
result replies derived from its concrete callback record. `At` exposes each reached callback's source invocation, actual iteration
index, concrete receipt environment and preceding state/history. `Stop` proves
that all rows before the last succeeded, that success exhausts the input suffix,
and that failure propagates the last reached row's exact outcome. No earlier
partial output is returned after failure.

`Step.dfy` strengthens the frozen single-iteration construction with the concrete
component receipts/environment and successful-continuation postconditions. Its
source-helper calls are verified again. It neither changes Solidity nor edits a
passed proof package.

## Resource and external-observation premises

`Budget` is recursive in the remaining finite input length. At a reached row,
`LocalRoom` supplies the previous iteration theorem's representability,
CursorRoom, argument/expression/error-packet resources and prepared-state
invariants. Its recursive obligation follows only input-accepted,
receipt-consistent, callback-returned, predicate/result-accepted transitions.
The guards use independent canonical input acceptance. The next accumulator and
state come from that exact modeled callback outcome. No successful verdict or
canonical callback return is assumed. `EmptyBudget` and `InputFailureBudget`
explicitly establish that no suffix resource condition is needed after completion
or input rejection. There is no universal requirement that all arbitrary byte
sequences or canonical values fit uint256.

The existing `AfterRoom` overapproximation remains within each reached row. It
may require resources for work skipped inside that row. Budget is sufficient, not
necessary, and does not characterize gas-limited executions. Initial nonempty
tails require an admitted partially canonical prepared state; preparation is
proved separately. A fixed external environment supplies code/call/gas
observations as functions of the complete low-level history and call inputs.
The host must faithfully capture relevant execution context in these observations;
no context-free determinism is inferred. High-level logical state tokens are
separate from the actual prepared state and callback history.

Source translation, compiler ABI, context/offset projections, physical memory,
execution resources and Dafny/Boogie/Z3 remain explicit premises. This package
completes concrete tail construction and environment assembly, not public
map/filter/fold admission or application of source-loop correspondence. Other
public families, sorting and exact compiled bytecode remain open.

The proof-only driver checks identical dependency source/tool/artifact hashes,
native declaration coverage, formatting and a zero-finding audit. No new EVM
fixture, mutation, gas, deployment or performance claim is made.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/iteration-chain/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/iteration-chain/evidence/concrete-finite-tail
```
