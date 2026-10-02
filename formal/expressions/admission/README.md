# Expression graph admission

This package verifies the admission prefix of `Expressions.evaluate`: result
bounds, descriptor parsing, reference validation and kind-specific arity/type
checks over arbitrary finite graphs. It does **not** prove `_evaluate`, cold
cache allocation, memoization, guarded cache adoption/rollback, canonical node
results or the complete entrypoint. Those remain explicit obligations in
`../../verification-plan.json`.

The independent specification is `ExpressionAdmission.Admit`. It first rejects
an out-of-range result, then scans every node in index order, including nodes
unreachable from the result. Each node's descriptor is parsed before its
references are checked in list order; arity and probe-type checks come last.
Errors preserve the actual first descriptor position, node index or invalid
reference value. `ReferenceVerdict` establishes first-reference ordering.
`ScanVerdict` proves that admission succeeds exactly when all nodes satisfy the
structural predicate, and identifies each resulting shape with its descriptor.

`ExpressionAdmissionSource.Prepare` implements the source's loop, calling the
proved parser. It refines `Admit` and carries the admitted shapes' dynamic flags,
word widths and positive width bounds. Backward references are therefore in
range and strictly decrease the node index, a prerequisite for recursive
termination. Admission alone says nothing about whether node data, parameter
indices or external calls will succeed when evaluated. Unused malformed
Parameter data is intentionally accepted, while unused malformed descriptors
are rejected.

The probe check retains the actual `keccak256(type) == keccak256("bytes")`
comparison, represented by the supplied hash function. `ProbeType` concludes
literal bytes typing only under an explicit no-collision premise for this
graph's descriptors against the bytes hash. No global hash injectivity is
assumed by admission itself.

## Source and evidence

The [baseline](evidence/expression-admission/manifest.json) and
[actual-source faults](evidence/admission-faults/manifest.json) record executed
checks. `generate.py` gates the complete `evaluate` AST and struct/enum/error
vocabulary, translating result/reference bounds and Select arity guards. The
last evaluation call and raw return are structurally pinned but are outside
this package's theorem: its operational model ends when admission succeeds.
The template's loop/helper decomposition and memory projection are trusted.
The full AST gate is not a claim to have verified every statement it pins.

New admission declarations run afresh. Included ABI proofs are reused only
after current transitive source and tool hashes, complete native/declaration
results and retained artifact hashes match the passed ABI baseline. The copied
manifest preserves provenance and links the original commands/logs; the
supplemental checker audits linked evidence again. Missing results, timeouts,
source drift and unaccounted declarations prevent a passed run.

Premises include the actual keccak function, valid typed calldata/enums,
representable node/reference/descriptor lengths, valid disjoint nonwrapping
memory, and sufficient local gas, stack and allocation. The pinned solc AST,
restricted translator, reviewed templates and Dafny/Boogie/Z3 are trusted.
Physical error serialization and compiler correctness remain separate. No
exact-bytecode or universal resource claim is made; production Solidity is
unchanged.

Nine EVM regressions check exact admission precedence, first invalid reference,
unused-node descriptor validation, every kind’s arity family, probe calldata typing and deferred
Parameter-data checks. Three Solidity faults change result bounds, reference
bounds and Select arity. Each must translate, fail its named semantic proof
without timeout and fail the designated concrete test.

```sh
python3 -B formal/expressions/admission/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/expression-admission
python3 -B formal/expressions/admission/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/admission-faults
```
