# Recursive expression control and cache bridge

This package is an intermediate proof toward the complete evaluator. It verifies
an abstract recursive machine and connects its invariant to the existing ABI,
graph-admission and cache specifications. **It is not yet a production source
correspondence theorem.** The Solidity-to-control lowering, primitive receipts,
exact errors and first-word truth interpretation remain explicit obligations.

The control machine covers every node kind, arbitrary finite graphs with
strictly backward references, and arbitrary history-dependent primitive
outcomes. It validates each newly produced value before storing it, preserves
existing cache values and metadata through the bridge, and proves a footprint
bound: evaluating node i can add only entries at or before i. This bound prevents
a child from making its still-running parent ready. Successful results are
canonical under the instantiated ABI predicate. A ready hit returns exactly the
stored value and makes no primitive request. The decreasing node index proves
termination in the unbounded mathematical model, not sufficient EVM gas.

`Choose` pins the selected reference to truth/falsehood; only that recursive
branch is taken after evaluating the condition. `GuardCache` pins success
adoption and failure discard. Failed attempts retain their observation history
but their memo changes are discarded before fallback evaluation. A failed guard emits a separate `GuardFailure` request whose receipt models
that boundary's sampled gas/marker decision. An inner error's origin alone
does not classify exhaustion. Connecting this request to the actual sampled
check and exact signal bytes is still required. Target-address checking for Call and ProbeCall
occurs before evaluating the remaining arguments/calldata. The primitive oracle
represents leaf resolution, address checking, encoding and external responses;
it does not receive or modify the memo.

The ABI bridge proves that an admitted graph has the control machine's arities
and backward references. It maps ready cache entries to the recursive memo,
instantiates validity with canonical ABI validation, and reconstructs a valid
cache while preserving previous entries and parsed metadata. The successful
recursive result then satisfies `ExpressionCache.SuccessfulReceipt`; this is
derived by recursion rather than assumed for each guarded attempt. Applying
that result to production still requires the source/primitive connections above.

`verify.py` verifies every local proof declaration, audits for trusted escape
hatches, checks format, and reuses dependencies only after complete native,
declaration, source, tool and artifact audits. Three **model faults** remove
validation, adopt failed cache changes, and invert branch selection; each must
reach a semantic verifier failure in the designated method. These are not
Solidity mutation tests and do not replace the later source fault campaign.
All source and proof-tool hashes and native batches are retained.

```sh
python3 -B formal/expressions/evaluation/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /fresh/evidence/directory
```

Further work: production AST gate and control lowering; codec/leaf/argument/
call/probe adapters with exact failures and trace order; connection of guarded
receipts to the actual call boundary; top-level raw return; graph/tree equality
under explicit deterministic context assumptions. Collections and the separate
exact compiled bytecode track are unaffected and remain open.
