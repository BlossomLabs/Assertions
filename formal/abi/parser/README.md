# Recursive descriptor parser correspondence

This milestone extends the [typeShape success theorem](../shape/README.md) to
all parser outcomes and characterizes acceptance in both directions. The input
is arbitrary bytes. There is no chosen bound on tuple depth, arity, suffix count
or decimal-digit count; uint256 arithmetic and the source's uint32 array limits
remain explicit.

## Established properties

`Spec.dfy` defines a pure recursive reference recognizer. `Parse` and `Fields`
handle names and tuples; `DigitsFrom` and `Suffix` handle array suffixes. They
return the exact descriptor-error position, checked-arithmetic panic, or parsed
syntax, dynamic flag, word footprint and end position. `Whole` additionally
rejects trailing descriptor bytes.

The source-derived `TypeShape` and `Shape` equal that reference for **every
outcome**, including failures. `WholeCorrespondence` separately proves:

```text
Shape(text) succeeds iff some Admissible tree renders exactly to text.
```

`Admissible` requires the existing grammar/array bounds and representable tuple
accumulators throughout the tree. A dynamic tuple still computes its component
sum before selecting head width one; bounding only the final width would be an
incorrect completeness premise. Fixed counts are positive, leading zeros are
allowed, and arbitrary lowercase alphanumeric names remain valid grammar even
when they are not Solidity ABI names. Narrow-word classification is separate.

The grammar acceptance theorem uses structural induction over rendered trees,
tuple prefixes and suffix lists, independently of the source loop invariants.
The all-outcomes reference is a source-level specification of rejection order;
it is not a claim that solc accepts exactly this descriptor grammar.

## Source connection and limits

The translator reuses the complete pinned solc AST gate for `typeShape`, `shape`,
`scanName` and `byteAt`. Decimal and product expressions are checked in small
proof methods; the caller retains the actual overflow branches and rejection
order. Ghost syntax records parsed text. No assertion is removed, and there are
no axioms, `assume` statements or termination escapes.

The trusted boundary includes the AST translator, loop factoring, calldata
projection, Dafny/Boogie/Z3 and pinned compiler AST. Base pointers must not wrap
and execution resources must suffice. This proves neither compiler correctness
nor unlimited EVM gas, stack, memory or allocation.

The EVM oracle has ten tests. Besides solc-encoded shape geometries, it checks
long decimal runs, leading zeros, prefix boundaries, malformed descriptors and
exact error bytes. A 32-level malformed tuple names its non-ASCII sentinel.
A **96-level malformed tuple with a 2,000,000-gas subcall fails with empty
returndata**. That case explicitly excludes resource exhaustion from any claim
that every on-chain parser failure must have `InvalidTypeDescriptor` data; the
mathematical correspondence does not establish which physical resource fails.

## Verification and mutations

The [current baseline](../evidence/parser-modular-complete/manifest.json)
passes **111 lemmas, 37 methods and 1,988 verification batches**, covering all
22 files in the proof dependency graph. The three bitvector checks, ten EVM
tests, audit, source freshness, dependency integrity and formatting gates pass.
These counts include prior milestones and must not be added to their totals.

The runner verifies the entire included proof graph, inventories declarations
and native assertion batches, checks prior evidence hashes, reruns the three
bitvector normalization gates, regenerates the source translation, audits proof
escape hatches, runs all ten EVM tests and checks formatting. Evidence retains
source snapshots, revision/hashes, tool versions, exact commands and outcomes.
The 30-second per-batch solver limit and explicit induction are unchanged.

The [current mutation campaign](../evidence/parser-modular-mutations/mutations.json)
passes **6/6**: every fault produces a semantic failure in its named source-derived
proof method and observed failures in the ten-test EVM inventory, with no
timeouts, missing tests or source drift.

Six isolated Solidity mutations test valid-input rejection, tuple dynamic
propagation, tuple sums, decimal radix, dynamic-array propagation and fixed
products. Detection requires both a semantic proof failure and an accounted EVM
test failure. Translator rejection and solver timeout do not count.

```sh
python3 -B formal/abi/parser/verify.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc-0.8.36 \
  --shape-evidence formal/abi/evidence/type-shape-explicit-slices/manifest.json \
  --output /tmp/abi-parser-baseline

python3 -B formal/abi/parser/mutations.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc-0.8.36 \
  --baseline /tmp/abi-parser-baseline/manifest.json \
  --output /tmp/abi-parser-mutations
```

Output directories must be new. Earlier attempted baselines and mutation runs
are retained; their incomplete/failed results are not promoted to proof claims.

The [recursive static traversal](../tuples/README.md) consumes the parser's
successful syntax. The [connection successor](../connection/README.md) proves
static canonical acceptance, `suffixStart` and body head preparation. The
recursive dynamic-body connection, `tupleLayout` enumeration, other caller error
contexts and arbitrary-geometry bytecode correspondence remain separate obligations.

Verification is modular: each file is checked as an entrypoint, while every file
in the include graph is inventoried and checked exactly once. Included method
contracts therefore have their own checked bodies in the same baseline. This
avoids unrelated later modules changing older SMT trigger contexts; it does not
trust unchecked dependencies or remove assertions. Native per-module CSV/logs
and the combined inventory are retained under one 900-second outer budget.

## Retained development attempts

The first [correspondence attempt](../evidence/parser-correspondence/manifest.json)
retains an unproved slice step and the original overly broad EVM expectation
for deep nesting. [Parser-complete](../evidence/parser-complete/manifest.json)
passed its proof but retained that failing EVM expectation and source drift.
The [first fully passing run](../evidence/parser-correspondence-final/manifest.json)
passed 1,581 batches and ten EVM tests; its
[mutations](../evidence/parser-correspondence-final-mutations/mutations.json)
left the decimal-radix fault incomplete because of a timeout.

The [next passing run](../evidence/parser-complete-final/manifest.json) isolated
the decimal expression and passed 1,582 batches. Its
[mutation campaign](../evidence/parser-complete-final-mutations/mutations.json)
detected five faults; the fixed-product fault had semantic and EVM failures but
also a timeout, so it remained incomplete. Product arithmetic is now isolated
too, with all caller overflow and grammar obligations retained.

The [product-isolated attempt](../evidence/parser-complete-isolated/manifest.json),
[combined correspondence retry](../evidence/parser-correspondence-complete/manifest.json)
and [induction retry](../evidence/parser-induction-complete/manifest.json)
retain later slice-proof failures, including sensitivity in an unchanged
included parser module. Explicit byte/slice and delimiter lemmas plus separate
module verification address these automation failures without changing
production code or weakening assertions. Historical source drift and failures
remain recorded in those manifests.
