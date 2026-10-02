# Exact expression call receipts

`Encoding.dfy` gives explicit error encodings and proves them equal to the
independent ABI argument-frame specification for all six call/probe errors.
Selectors and argument signatures are checked against pinned solc's production
AST. `FailedPayloads` proves the exact NodeCallFailed index, dynamic offsets and
unchanged calldata/reason bytes for arbitrary finite payloads under word-fit
premises. Error arguments form a tuple frame directly after the selector;
there is no enclosing single-value offset.

`Connection.dfy` calls the already proved source-control methods and projects
their outcomes into the recursive evaluator's `E.Raw` interface. Failures carry
exact encoded errors; call success carries unchanged raw returndata; probe
success carries the canonical ABI bytes envelope, with validator completeness
proved. External request history is preserved by each adapter. The probe
allocation bound is explicit, and no external-call determinism is assumed.

The trusted connection to Solidity custom-error encoding is its standard ABI
projection, **not** a proof of solc's compiled encoder. Existing source-control,
memory, gas-observation and resource assumptions remain. Binding these adapters
into the full evaluator oracle, forwarding actual call-frame contexts and
representability bounds from entrypoints, and exact compiled bytecode are still
separate obligations. These methods supply reusable receipts; they do not alone
prove the full evaluator.

The verifier audits complete identical dependency proof inventories and native
results, current source/evidence/tool hashes, selector/signature bindings,
Dafny proof and audit, formatting, and six real-EVM exact-byte tests for empty,
single-byte, word-boundary and multiword dynamic error payloads. The source
control mutation campaign is retained in the dependency package; this receipt
package does not claim an additional actual-Solidity mutation campaign.
