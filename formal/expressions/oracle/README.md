# Finite receipt traces and recursive replay

BuildTrace constructs a receipt for every entry of an arbitrary finite request
trace by calling the proved primitive dispatcher. Each receipt satisfies its
stage-specific semantic postcondition, with explicit external frame observations,
codec result witnesses and allocation bounds. No global oracle existence axiom
or assumed dispatcher result function is introduced.

Replay returns those constructed receipts when queried at the matching trace
prefix. ReceiptContracts proves the recursive evaluator’s required receipt
contracts, and Run connects the request-instrumented evaluator to the independent
recursive specification while preserving canonical cache values, cache extension,
footprints, successful values and byte-valued failures.

The full primitive-stage connection is conditional: the evaluator’s resulting
request history must equal the supplied trace. Trace generation and alignment
inside recursive execution remain open. Off-trace queries return a mathematical
bare-error fallback solely to make Replay total; this is not a Solidity error or
out-of-resource theorem. A mismatched trace does not establish source execution.

Each Config frame is still externally supplied. Faithful call histories, decoder
outcomes, guarded frame provenance and error/validation observations must be
connected to actual execution. Existing source translation, ABI, memory and
resource assumptions remain, as do the determinism conditions for graph/tree
substitution. Public graph entrypoints and exact compiled bytecode are separate
outstanding obligations.

This is proof-only composition. Its baseline checks identical dependency source,
tool and retained evidence hashes and complete successful native declaration
inventories. It adds no new EVM or actual-source mutation campaign.
