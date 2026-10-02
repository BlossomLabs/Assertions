# Value-sort preparation and input prevalidation

This package connects the actual `sortValues` admission prefix: binary callback
preparation, input type shaping, then a left-to-right validation pass over every
input. It stops before the merge loops and adds no completed public entry.

The complete function AST is gated. Binary preparation, descriptor operands,
validation-loop guard and selected input are translated into the generated
adapter. The fixed structure retains the source order. Copying the input array,
initializing its length and allocating scratch use faithful decoded-memory and
sufficient-resource premises; allocator or compiled-bytecode correctness is not
claimed. Gating the complete function anchors the prefix but does not prove the
untranslated merge suffix.

The independent `Judge` specification first observes the actual preparation
receipt, then the type reply, then recursive `Scan`. `ScanVerdict` establishes
success iff every remaining input passes, or the exact first failing index and
error bytes with an accepted preceding prefix. The source loop invokes the
proved actual codec validator and retains its visited index/request trace.
`Connection.Run` exposes the exact ready criterion, canonicality of all accepted
inputs, preparation/shape/element failure order, and the complete visited prefix.
Failure-stage labels 0, 1 and 2 are ghost labels for preparation, shape and element
validation; they are not new Solidity errors. Public errors retain actual codec
bytes, including the first failure's offset inside its input.

The admitted callback has its parsed layout, canonical non-placeholder constants
and `targetChecked == false`. Low-level preparation history contains only codec
events; input validation is recorded separately. There are no target checks or
external calls in this prefix, including empty and singleton cases. A successful
prefix is the prerequisite for the later comparator/merge composition.

`Room` requires preparation resources, uint256 descriptor/list/value lengths and
post-parse `CursorRoom` for all input values, including possibly unreached suffix
values. It does not assume canonical inputs or successful preparation. Codec
source/offset correspondence, valid memory, faithful copy/allocation projections,
compiler ABI, adequate execution resources and the Dafny/Boogie/Z3 toolchain remain
explicit premises. The final canonicality witness loop is ghost proof work over
pure validator receipts; it adds no source execution or event.

The driver checks identical retained dependency proofs and every local native
result, zero audit findings, generation and formatting, and eight EVM fixtures.
The fixtures pin binary-slot/arity rejection before type parsing, type parsing on
empty input, empty/singleton behavior with a code-less target, full prevalidation
before target checking, malformed singleton rejection and the first failure's
exact offset. Three isolated source faults skip the final input, repeatedly
validate the first input, or weaken preparation to unary; each must pass
translation and fail both the source proof and concrete suite. Timeout alone
never counts as semantic fault detection.

```sh
python3 formal/collections/sort-admission/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/sort-admission/evidence/value-sort-prefix-v2
```

The retained manifest determines completion and counts. Full merge traversal,
comparison history and failure composition, comparator coherence, other public
families and exact compiled bytecode remain open. No complexity, gas, deployment
or historical-performance evidence is asserted here.

The initial `value-sort-prefix` attempt is failed evidence: its concrete fixture
misqualified a top-level codec error, and its source-fault gate retained the
compiler `isSimpleCounterLoop` optimization annotation. The revised gate omits
that annotation; complete loop syntax and translated guard are still checked,
and source counter safety is proved independently of compiler optimization.
