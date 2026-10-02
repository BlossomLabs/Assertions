# Production ABI correspondence completion checklist

Objective: complete the connection between the independent mathematical ABI
specification and the production `contracts/lib/AbiCodec.sol` implementation.
Success requires source correspondence for validation and construction/splitting,
with all caller premises discharged or stated as real caller/environment
contracts, and fresh complete proof, EVM-oracle and mutation evidence. Completing
only the static branch or the dynamic walker does not complete this objective.

This is a source-level claim under an explicit trusted AST translator and
Solidity memory interpretation. Compiler correctness and arbitrary-geometry
bytecode induction remain a different verification layer. The canonical source
and retained build/runtime identities must continue to agree.

**Completed under those assumptions.** The
[final baseline](evidence/production-abi-correspondence/manifest.json) passes
187 lemmas, 102 proof methods and 7,579 verification batches across 54 modules,
with 40 independent EVM tests. All nine final
[source faults](evidence/production-abi-faults/mutations.json) are detected by
both semantic proof failures and EVM failures. The
[integration gate](evidence/production-abi-integration/manifest.json) also passes
for the same production source hash. No production Solidity change was needed
to complete this proof connection.

| Requirement | Evidence / current state |
|---|---|
| Independent encoding/validator soundness, completeness and canonical equivalence | `Validation.dfy`, `Encoding.dfy`; included in each complete baseline |
| Complete descriptor parser acceptance, rejection positions and arithmetic outcomes | `parser/`, passing `evidence/parser-modular-complete/` |
| Narrow-word classification including descriptor boundaries and opaque names | `words/`, passing source-SMT baseline and boundary regressions |
| Recursive static traversal and canonical static validation | `tuples/`, `connection/`; passing `evidence/connection-static-heads/` |
| Exact zero-copy traversal and checked cursor failures | Passed in `evidence/dynamic-body-verified/` |
| Full dynamic array/tuple recursion and body extents | Passed in `evidence/dynamic-body-verified/`; three source faults detected by proof and EVM in `evidence/dynamic-body-faults/` |
| All-input noncached validation, dynamic envelope and exact consumption | Passed in `evidence/dynamic-body-verified/`: 4,511 batches, 159 lemmas, 74 methods, 16 EVM tests |
| General cached validation contract | `construction/Validation.dfy`; passed in the final baseline under matching cached-shape premises |
| Tuple layout assembly scanner, spans, shapes and head size | `layout/`; source, canonical completeness and accepted-descriptor witness proofs passed in the final baseline |
| Component validation and complete error-context routing | `construction/`; proofs and context-forwarding audit passed; exact fields pinned by the construction oracle |
| Source-derived frame assembly and memory copy/store/slice semantics | Passed in the final baseline. The first run found a translator branch-order bug; corrected generation now passes. Production Solidity unchanged |
| Tuple construction, array packing and unpacking; model correspondence/inverse | Passed in the final baseline, including both source-composed inverse directions and their arithmetic-budget lemmas |
| No circular validator/encoder oracle; no silent arithmetic/resource exclusions | Independent validator and encoding theorems included; audit passed. Zero-copy overflow and checked panics remain explicit outcomes |
| Fresh full dependency inventory, hashes, versions, commands, bounds, outcomes | Final manifest accounts for every module/body. Reuse requires identical transitive inputs, tool hashes and verifier arguments; all generation/audit/EVM/format gates rerun |
| Independent solc/EVM oracles and fault sensitivity | Final baseline: 16 dynamic and 24 construction tests passed. Dynamic campaign: 3/3 faults detected; final layout/construction campaign: 9/9 detected. All tests accounted for |
| Ledger reflects final scope without promoting bounded/runtime checks to universal proofs | [Claims ledger](../../docs/claims.md) and [19-row source-proof mapping](../../docs/verification/abi-source-connection.json) reconcile closed source gaps and retain runtime/caller bounds |

Source arithmetic remains uint256. The new dynamic proof retains checked panic
outcomes instead of assuming all zero-copy cursors fit. A sufficient, separately
proved arithmetic budget is `|value| + 32 * 2^32 * |descriptor| < 2^256`; it
establishes the cursor premises without a chosen nesting, array-count or
loop-unrolling cap. Adequate gas, stack, allocation and nonwrapping physical
memory layout remain environmental assumptions. This is not an unlimited-resource
execution guarantee.

Remaining verification layers are compiler correctness, arbitrary-geometry
compiled-bytecode correspondence, and the surrounding contracts' use of the
codec (for example navigation's selective validation and Collections' context
selection). They are outside this completed library source-correspondence goal.
Earlier failed/incomplete evidence remains retained; see
[construction history and reproduction](construction/README.md).
