# Public array codec source composition

This package targets `packArray` and `unpackArray` at the decoded ABI boundary.
Coverage is added only after retained verification passes and its checked ledger
is installed. Exact compiled bytecode remains a separate open track.

`Model.dfy` specifies raw descriptor errors, the first invalid original packing
input and canonical array construction independently of the packing loop.
Unpacking errors follow the retained exact recursive array validator, including
envelope/count/offset/body/exact-consumption error positions. Error packets use
retained compiler-bound signatures and the actual codec error-context routing.

`generate.py` gates the complete Collections wrappers and complete `AbiCodec.pack`
and `AbiCodec.unpack` compiler AST bodies. It lowers the packing validation index,
array-envelope mode and unpack initial/exact-tail rejection guards into controls.
`Pack.template.dfy` strengthens the source packing loop with exact per-input
validation receipts and first-error correspondence, retaining canonical assembly.
`Unpack.template.dfy` strengthens source splitting with exact recursive dynamic
body/array-element errors while preserving original static checks and successful
canonical output. Template generation includes those fixed source adapters;
never hand-edit generated files. Complete source/helper and compiler hashes are
bound by the native dependency closure and generator gate.

`Connection.dfy` composes the public wrappers with exact errors, canonical array
output/splitting and both inverse directions. The inverse theorems call the
public source adapters, using explicit canonical-input and arithmetic-resource
premises. Dynamic elements retain their own 0x20 envelope after splitting;
static values remain their complete original word encoding.

Representation and resources remain explicit: finite faithfully decoded bytes,
uint256 pointer-array/input footprints, packing's representable 64+total encoding
bytes, and raw descriptor/element/array cursor budgets. These do not assume
validation accepts. Faithful calldata/memory copying, logical array writes,
checked arithmetic, successful allocator and outer ABI serialization/error
projection and adequate execution resources remain premises. This source proof
does not establish the physical compiler allocator or ABI serializer. No
callbacks or external observations occur, and no gas, deployment, complexity or
performance claim follows.

Nine real EVM fixtures cover empty/static/full-width/dynamic canonical arrays,
both inverse directions, raw descriptor priority, every narrow packing value,
first invalid packing offset, unpack envelope/count/trailing-byte positions,
narrow values, malformed dynamic offsets and exact dirty-padding errors.
Four isolated semantic mutations change the packing validation index, omit the
array envelope, change the initial envelope word or invert exact consumption.
Every mutation must translate and fail a baseline-covered native semantic
assertion and a real EVM fixture without timeout.

Run `verify.py --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny --solc <pinned
0.8.36 executable> --output evidence/<fresh-name>`. It retains complete snapshots,
compiler generation, all local native obligations, zero escape audit, formats,
EVM fixture inventory and source-fault campaign; checks twelve retained
dependency manifests with complete source/tool/native/declaration/artifact
closure; and rejects current input drift. Finish package edits before snapshotting.
Poll live runs to completion; never restart because a polling call yields.
