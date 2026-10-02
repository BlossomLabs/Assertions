# Source-gated value traversal loops

The generated adapters for `mapValues`, `filterValues` and `foldValues` refine
`../traversal/Model.dfy` for arbitrary finite lists under **faithful helper
observations**. This is a conditional source-loop result; it does not complete
Collections or establish the pending helper correspondence.

The solc 0.8.36 AST gate checks each complete function body and signature,
including statement order, declared types, allocation, increment operations and
filter's assembly length write. Selected loop guards, callback arguments,
binary flags and result-validation arguments are translated from AST expressions.
The remaining lowering is reviewed and trusted. Unsupported structural changes
fail closed. `--bootstrap` creates the initial reviewed structural baseline and
is never used by the evidence verifier.

Map preallocates a length-n buffer, stores each result before validating it and
exposes the complete buffer only after success. Filter writes original values
at consecutive retained positions and returns the prefix corresponding to the
final assembly length. Fold assigns each callback result before validating it.
Every input validates before its callback. Preparation and descriptor/initial
checks precede traversal even on empty input. The generated bodies issue helper
requests explicitly; `Step` is used only for a proof assertion connecting each
iteration to the independently defined specification.

`Connection.Run` transfers the abstract specification's exact history and
failure semantics, callback-index prefix, map length, fold accumulator behavior
and stable filter-position witness to these adapters. Callback indices refer
to helper application attempts, which may fail before a physical staticcall.
There is no determinism assumption across distinct histories.

Remaining premises: valid decoded inputs, adequate local resources, representable
nonaliasing memory/arithmetic, and a faithful projection of all helper outcomes
and complete prepared callback state into the environment. In particular,
canonical predicate truth, actual validation, binding, target checking, external
call construction/outcomes and exact helper errors still need source adapters.
Sequence buffers prove logical bounds and exposed prefixes, not physical
allocator or ABI serializer correctness. A failure carries a ghost receipt,
not committed memory from a reverted call.

`verify.py` retains source snapshots, fresh solc input/AST and slot mappings,
generated-output equality, native proof rows, declaration inventory, zero-finding
audit, formatting and unchanged-input checks. Dependency results are reused only
under identical transitive source/tool/artifact hashes and successful native
results. Seven focused EVM fixtures cover value order, filter shrink, accumulator
order, empty-target behavior and exact first failures. They are concrete checks,
not an unbounded EVM theorem or a production source-fault campaign. Compiled
bytecode, gas measurements, deployment and historical performance remain outside
this result.
