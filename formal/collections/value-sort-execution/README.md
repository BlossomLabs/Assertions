# Concrete value-sort merge execution

This package constructs the complete `sortValues` merge suffix from the proved
source comparator, after admission. `Connection.Run` invokes that comparator at
each reached pair, threads prepared arguments and full low-level history, and
assembles an oracle that makes the retained source merge-loop adapter reproduce
exactly the constructed execution.

`Model.Receipt` retains each pair's current merge positions, original occurrence
IDs, both concrete component receipts, the callback environment, before/after
prepared state and history, and signed comparison or exact error. `Records.At`
exposes the corresponding record at any reached index. `Records.Meaning`
connects its decision to exact callback or malformed-result error bytes, and
`Records.Summary` proves target-check reuse and external-call counts. Rejection stops the chain,
including a successful external call whose result has the wrong byte length.

`Replay` establishes equality of recursive merge/pass/sort executions within
observed history windows. `Connection.Merge`, `Pass` and `Sort` build those
executions by calling the source comparator, rather than accepting a supplied
list of claimed observations. The final `Run` applies the existing source-loop
connection. A successful result preserves all occurrence IDs; sortedness and
stable ties require decisions coherent with a total preorder. No determinism is
assumed for arbitrary external observations.

`Budget` is a finite sufficient envelope over bounded requests and continuing
receipt-compatible states. Its local conditions retain existing size, cursor,
encoding and error-packet premises. The conservative n*(n-1) comparison envelope
is not a gas or tight complexity result. Failure imposes no continuation budget.
Empty/singleton merge suffixes make no comparator requests and preserve the
incoming state/history. Public admission still must execute before that shortcut.

Trust boundaries remain: faithful source/compiler and callback context projections,
occurrence-to-value representation, bytes-array copies/assignments and memory,
allocation/serialization, adequate execution resources, and Dafny/Boogie/Z3.
Raw public admission is not yet composed, so this package adds no completed public
entry. Exact bytecode, deployment and performance verification are separate.

Run `verify.py` with the pinned Dafny/solc paths and a new `--output` directory.
The driver verifies fresh local declarations, audits for proof escapes, checks
formatting, snapshots inputs, and checks retained dependency sources, tools,
artifacts and declaration/native results. No fresh EVM or source-mutation campaign
is claimed for this composition.
