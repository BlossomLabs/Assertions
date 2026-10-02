# Pure value structure source composition

This package targets `reverseValues`, `sliceValues` (including `_sliceIndex`),
and `flattenValues` at the faithfully decoded ABI boundary. Coverage is added
only after its retained verifier passes and a checked ledger is installed.

`Model.dfy` specifies selected original cells independently of the source loops:
reverse selects all ascending original positions and reverses their output;
slice selects the signed/clamped end-exclusive interval; flatten selects rows
and columns in ascending order. Recursive validation specifies the first invalid
selected cell, exact error bytes and reached validation prefix. No successful
output is returned on a failure. Successful output preserves every original byte
encoding and validates canonicality against the raw type descriptor.

`generate.py` gates complete compiler AST bodies for all four functions,
including raw descriptor/validation calls, allocation arguments, checked count
assignment, loop increments, flatten `k++` and validation-before-copy order.
It lowers actual clamp expressions, loop predicates and validation/value/output
indices into `Control.generated.dfy` from `Control.template.dfy`. Fixed slice
helper arguments and entire syntax outside translated slots remain gated.
Never hand-edit generated files.

`Source.dfy` composes actual retained descriptor and value-validation receipts.
It proves representable uint-to-int length conversion, models actual checked
count overflow before flatten allocation/validation, and follows source loops
and writes into logical arrays. `Connection.dfy` connects those loops to exact
original encodings, canonicality, slice positions, row-major flatten positions
and the first invalid reached prefix. Invalid descriptors win even on empty
input; skipped slice values are not validated. Exact signed minimum and maximum
slice indices are admitted. The mathematical checked flatten count overflow is
proved conditionally even though extreme sizes are excluded by the faithful
physical representation/allocation/execution premises.

The decoded representation has finite byte encodings and uint256 pointer-array
footprints. Successful allocation, calldata-to-memory copying, logical-array
write interpretation, outer ABI serialization and sufficient reached codec and
execution resources remain explicit premises. Logical value arrays do not prove
physical allocator or serializer behavior. `Budget` requires validation resources
for all selected cells after successful descriptor/count admission; this is a conservative budget even when validation fails early. No callbacks
or external observations occur. Exact compiled-bytecode correspondence, gas,
deployment, complexity and performance verification remain separate and open.

`ValueStructureOracle.t.sol` has eleven real EVM fixtures: empty/descriptor
priority, full-width reversal, original-order and every-element narrow validation,
signed slice bounds, skipped invalid values, row-major flatten with empty rows,
first invalid flatten cell, every-column narrow validation and unchanged dynamic
canonical encodings. `source-fault-audit.py` isolates five semantic faults: wrong
reverse destination, reverse validating only its first value, wrong negative
slice clamp, wrong flatten count, and flatten validating only its first column.
Every fault must translate and fail both a recorded native semantic assertion
covered by the full baseline and an EVM fixture. Timeouts are not evidence.

Run `verify.py --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny --solc <pinned
0.8.36 executable> --output evidence/<fresh-name>`. It snapshots complete package
and dependency inputs, checks twelve retained dependency manifests and all native
source/tool/declaration/artifact hashes, verifies every local declaration,
requires zero escape-audit findings, checks formats, executes the complete EVM
fixture inventory and mutation campaign, and refuses input drift. Finish all
package edits before snapshotting. Poll a live run to completion; never restart
it because a polling call yields.
