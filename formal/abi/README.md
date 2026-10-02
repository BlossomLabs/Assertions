# Recursive ABI model — encoding and validation

This directory contains an independent Dafny specification of ABI frame
construction and recursive canonical validation, connected to the production
`AbiCodec.sol` through inductive source-correspondence proofs. The
[complete source baseline](evidence/production-abi-correspondence/manifest.json)
passes **187 lemmas, 102 proof methods and 7,579 verification batches across
54 modules**, plus **40 independent EVM tests**. All nine final
[Solidity fault injections](evidence/production-abi-faults/mutations.json) fail
both their source-connected proof and an EVM test.

The connection covers descriptor parsing, word rules, recursive static/dynamic
validation, tuple layout, cached/component validation, error routing, frame
assembly, tuple/pack/unpack and both pack/unpack inverse directions. It depends
on a trusted AST translator and memory interpretation, matching internal caches,
explicit arithmetic bounds and adequate EVM resources. It does not prove the
compiler or arbitrary-geometry bytecode execution. See the
[completion checklist](CONNECTION.md) and [construction proof](construction/README.md)
for the precise scope, assumptions, evidence history and reproduction commands.

The earlier
[bytes/string source milestone](source/README.md) additionally connects a
restricted program derived from the Solidity AST to that model, under an
explicitly trusted translator and memory interpretation. The
[array/tuple milestone](aggregate/README.md) adds source-derived cursor kernels
and recursive typed composition; the [runtime milestone](bytecode/README.md)
checks enumerated geometries against the exact Hardhat Collections bytecode.
The [word-classification milestone](words/README.md) adds exhaustive assembly
predicate checks and unbounded scan-loop proofs. It found a real descriptor
boundary bug: `bytes3` followed by ASCII `2` outside its declared length could
lose its narrow-word check. The original failed baseline is retained; the
production source is now fixed and its fresh proof/runtime gates pass.
The [descriptor milestone](descriptor/README.md) starts discharging the static
traversal interface with source-derived fixed-array suffix scanning and the
non-tuple `checkWords` branch. The [typeShape milestone](shape/README.md) derives
its syntax/product premises from successful recursive parsing and establishes
model head shapes and recursive `ShapesFit`. The [parser correspondence](parser/README.md)
adds acceptance completeness and exact reference outcomes; the
[recursive static traversal](tuples/README.md) connects parsed tuples and arrays
to their ordered word checks. The [static connection milestone](connection/README.md)
proves static canonical acceptance with source-derived span bounds,
`suffixStart` and body array/tuple head preparation. The
[dynamic successor](dynamic/README.md) and [construction successor](construction/README.md)
complete the source connection; arbitrary-geometry bytecode verification remains open.
The word-boundary fix and bundled `validateDynamic` trailing-offset correction
require coordinated deployment artifacts and SDK addresses. The latter now names
the first trailing byte (`32 + walked extent`); `unpack` behavior is unchanged.

Independent-model baseline: **58 lemmas, 148 verification batches, zero errors or
timeouts**, zero audit findings, nine passing EVM tests, and passing fixture and
formatting checks. All nine targeted model mutations were rejected by semantic
proof failures, with no mutation timeouts. Milestone 2 adds an independent validator, its inverse
theorems, and malformed-input rejection. Milestone 1's evidence (29 lemmas,
78 batches) is preserved separately.

The aggregate baseline has **79 lemmas, 16 proof methods and 260 verification
batches**, including the earlier model and bytes/string work. All nine aggregate
source mutations are detected. The exact-runtime suite separately passes twelve
symbolic properties and catches five bytecode mutations, each reproduced on an
EVM. Counts from successive baselines overlap; they must not be added together.
The linked milestone documents retain the source-interface assumptions and
finite bytecode coverage bounds.
The [descriptor baseline](evidence/descriptor-traversal-final/manifest.json)
rechecks the earlier dependencies and passes **91 lemmas, 25 proof methods and
388 batches**, plus six new EVM tests. It adds static suffix traversal and
non-tuple word-copy composition under explicit validated-syntax premises.
The [typeShape baseline](evidence/type-shape-complete/manifest.json) rechecks that
dependency graph and passes **100 lemmas, 30 proof methods and 899 batches**,
plus three bitvector gates and eight EVM tests. Successful parsing now establishes
the static suffix premises. Its later parser and tuple successors retain the full dependency graph and close grammar acceptance and recursive static traversal under explicit arithmetic/resource premises; see their manifests for current combined counts.

The [parser correspondence baseline](evidence/parser-modular-complete/manifest.json)
passes **111 lemmas, 37 methods and 1,988 batches** across all 22 dependency
files, plus the three bitvector checks and ten EVM tests. Every source module is
verified separately; every dependency and declaration remains in the baseline.
It characterizes grammar acceptance and exact reference outcomes under explicit
arithmetic and resource assumptions.

The [recursive static traversal baseline](evidence/tuple-traversal-complete/manifest.json)
rechecks those dependencies and passes **135 lemmas, 47 methods and 2,711
batches** across 27 files, plus ten traversal EVM tests. It connects parsed
static names, tuples and fixed arrays to the flattened narrow-word scan,
including exact first-invalid offsets and zero-copy no-read behavior under
representable-cursor premises.

The [static connection baseline](evidence/connection-static-heads/manifest.json)
rechecks all 32 dependency files and passes **148 lemmas, 61 proof methods and
2,764 batches**, plus twelve EVM tests. The static validation branch is connected
to canonical acceptance with its data-span bounds derived from the source guard;
`suffixStart` and body array/tuple head preparation are also proved. Its proof
counts include earlier dependencies. Dynamic-body recursion was completed by
the later [dynamic baseline](evidence/dynamic-body-verified/manifest.json):
159 lemmas, 74 methods and 4,511 batches across 36 modules, plus 16 EVM tests.
Its [seven actual-source mutations](evidence/connection-static-heads-mutations/mutations.json)
all produce semantic proof failures and EVM failures, with no timeouts.

The word milestone extends the successful conditional Dafny results to **82
lemmas, 21 proof methods and 279 batches**, plus 107 new SMT obligations. The
fixed source passes the classification gate, and the original runtime's
counterexample is preserved as failed evidence. See the
[production handoff](words/HANDOFF.md) and separate baseline/candidate evidence.

## What is established

`Frames.dfy` proves big-endian word serialization and decoding, zero padding,
exact head/tail lengths, contiguous dynamic tails, static and dynamic component
slices, minimum head footprints, and preservation of encoded offsets and target
bytes when a complete frame is embedded at a different position.

`Encoding.dfy` defines types, well-typed values, in-place bodies, single-value
encodings, shape and representability. Structural induction proves positive,
word-aligned bodies and exact static footprints at arbitrary finite nesting
depth. `RecursiveChildLayout` connects each dynamic child's actual offset word
to its body slice and canonical re-wrapping. The parent body's prefix is explicit:
only dynamic arrays put a count word before the element frame, and offsets do
not include that count. `EncodedLengthsFit` derives length/count and frame-size
bounds from the explicit representability premise.

`Examples.dfy` supplies non-vacuous cases: empty dynamic arrays, exclusion of
empty tuples and zero fixed arrays, opaque words, dirty booleans, arbitrary
string bytes, and `(uint8[2],bytes[])` with an empty and a one-byte element.
The last value is 320 bytes; its expected vector is independently checked against
pinned viem in `fixtures.json` by `check-fixtures.mjs`. The same literal is checked
against solc `abi.encode` by `EncodingOracle.t.sol`, executed on a real EVM in an
isolated Forge project. A fixture is a concrete check, not a proof of compatibility
for every Solidity type. The oracle is outside `contracts/` so it does not enter
the production build or the other agent’s Halmos inventory.

`Validation.dfy` defines a separate parser. It reads scalar words and payload
lengths, checks word ranges and padding, and walks each tuple/array frame with
separate head and tail cursors. It checks each dynamic offset against the next
tail position. `Walk` consumes a prefix so siblings can follow; `Validate`
requires the single-value envelope and exact input consumption. Neither makes
acceptance decisions by comparing input to `Encode` or `Body`.

The proofs establish:

- `WalkSound` / `ValidationSound`: every accepted result is well-typed, and its
  body / complete encoding is exactly the consumed / complete input bytes.
- `WalkComplete` / `ValidationComplete`: every representable canonical value
  is accepted and reconstructed, including with arbitrary following bytes for
  the prefix walker. Induction covers all finite tuple/array nesting and counts.
- `AcceptedIffCanonical`: for a well-formed type and input shorter than
  `2^256` bytes, acceptance is equivalent to the existence of a well-typed,
  representable value with exactly that encoding. `FitsFromSize` derives all
  nested fit conditions from the top-level length bound.
- `EncodingInjective`: two representable values of the same type cannot have
  identical encodings unless they are equal.
- Separate rejection lemmas pin truncated byte bodies, dirty padding, trailing
  bytes, noncanonical scalar words, incorrect envelopes and loose offsets.

The examples prove acceptance of the same 320-byte viem/solc vector, empty arrays
of every well-formed element type, and rejection of concrete malformed byte
encodings. `ValidationOracle.t.sol` adds eight real-EVM test functions against a
copied `AbiCodec.sol`: byte-length boundaries, arbitrary string bytes, scalar
word rules, static aggregates, dynamic fixed arrays, dynamic arrays, the nested
tuple, and envelope/trailing-data checks. Together with the encoder oracle this
is nine tests. Calls expected to succeed are caught and checked explicitly;
rejections must be `InvalidValue`, not an unrelated panic. These are concrete
implementation checks, **not a Solidity refinement proof**.

## Scope and assumptions

- `WellFormed` models an algebraic type, **not descriptor text or its parser**.
  `WordRule` distinguishes unsigned, sign-extended and left-aligned narrow words,
  address, bool, function, and unrestricted words. The word milestone now proves
  name classification (including opaque unknown names) through a separate SMT
  gate. The later typeShape milestone maps every successful recursive parse to a
  well-formed model shape, erasing static names to Opaque for shape only. The parser
  successor characterizes acceptance by admissible grammar trees; the tuple
  successor composes narrow rules for static descriptors. The completed source
  connection preserves those rules through both static and dynamic validation.
- Strings are arbitrary bytes. ABI validity does not require valid UTF-8.
- Tuples are nonempty. Empty argument lists handled by public call construction
  are outside this type grammar. The internal helper `tupleLayout("()")` rejects;
  its NatSpec now documents that rejection and the caller-level empty-list handling.
- Fixed-array counts are positive and at most `2^32-1`. A static fixed-array
  footprint has that cap too. Tuple sums are modeled separately, matching the
  distinction in the source; no universal tuple footprint cap is assumed.
- Dynamic types have one head word. Static types occupy their full footprint.
  A dynamic single-value encoding is `Word(32) + Body`; tuples/fixed arrays use
  a frame directly, dynamic arrays prefix their frame with a count, and
  bytes/string bodies prefix their padded payload with its byte length.
- `NatBytes` is fixed-width serialization. Decoding its result equals the input
  only under the explicit fit precondition. Offset decoding uses
  `HeadSize + TailSize < 2^256`. `Fits` applies an encoded-size condition at every
  nested value. These preconditions are retained in the proofs and manifest.
- Sequences and integers are mathematical. There is no chosen depth/array-length
  unrolling bound, but this does not assert that arbitrarily large values can
  execute within EVM gas, stack, memory, or allocation limits.
- The independent walker is a ghost model algorithm. It constructs a child
  type sequence for arrays and uses mathematical arithmetic. It is not deployed
  code. The model alone does not prove Solidity's pre-allocation count checks,
  machine arithmetic or error fields. The complete source successor adds those
  connections, preserving checked panics and deriving recursive cursor bounds
  under its stated arithmetic budget. Its context audit and routing proofs cover
  the library's value, tuple-component and callback-result errors; surrounding
  contracts must still supply the intended context.
- There are no user axioms, `assume` statements, skipped proof bodies or
  termination escapes. Dafny/Boogie translation and the pinned Z3 solver are
  trusted. `dafny audit` checks explicit soundness escape hatches; it is not a
  verification of the verification tools themselves.

## Reproduce

The commands below reproduce the independent-model milestone. Use the
[construction runner](construction/README.md#reproduce) for the complete
production source connection, including all model dependencies.

Use Dafny **4.11.0** with its bundled **Z3 4.12.1**. The Linux x64 distribution,
release digest, solver path and verifier settings are pinned in `toolchain.json`.
Download the official archive to a temporary directory and verify its SHA-256
before extracting/running it. Do not commit the distribution. Other platforms
need the corresponding official release and a separately recorded digest.

From the repository root, after installing the existing Node dependencies:

```sh
python3 formal/abi/verify.py \
  --dafny /path/to/dafny/dafny \
  --output /tmp/abi-proof-recheck
```

Use a fresh output directory. The runner verifies **all included files**, checks
versions, inventories declarations, runs the Dafny soundness audit, checks the
independent fixture, the isolated solc/EVM oracles and formatting, and records
native per-batch CSV results. Forge with solc 0.8.36 must be available. The oracle
uses optimizer 200 and Cancun; its exact command and nonzero test count are retained.
Zero results, verification errors, warnings treated as errors, timeouts, source
drift, missing CSV results or failed checks cannot receive a passed status.
Source hashes and retained source snapshots identify the model; the exact
`AbiCodec.sol` used by the concrete oracle is also retained. Solidity hashes
are not an assertion of refinement. The run uses explicit induction, two workers,
and 30 seconds per verification batch. An outer 900-second watchdog terminates
the full verifier process group and records incomplete rather than success.

After a successful baseline, check the model's fault sensitivity:

```sh
python3 formal/abi/mutations.py \
  --dafny /path/to/dafny/dafny \
  --baseline /tmp/abi-proof-recheck/manifest.json \
  --output /tmp/abi-model-mutations
```

The nine mutations add an erroneous offset word, introduce nonzero padding,
change the single-value envelope, omit the array count, and ignore the fixed
array count in its footprint; they also remove the validator's padding,
trailing-byte, tight-offset and scalar-rule checks. They run in isolated temporary
copies using the same source/tool hashes as the passing baseline. Each mutation
checks an explicitly named declaration that passed in the complete baseline.
The target and native CSV results are retained. A mutation is rejected only
when that target has a semantic assertion/postcondition failure; a timeout alone
does not count. Mutation runs are targeted checks, not new full-model baselines.
These are model mutations, not evidence about mutated Solidity implementations.

## Relation to the claims ledger

| Existing claims | Complete source connection contributes | Remaining verification layers |
|---|---|---|
| A12–A13 | Parser-to-type mapping, recursive static/dynamic validation and canonical acceptance under the arithmetic/resource contract | Compiler correctness, arbitrary-geometry bytecode and surrounding caller correspondence |
| A14–A15 | Recursive tight offsets, byte slices, zero padding and library error-context routing | Arbitrary-geometry compiled-runtime correspondence; caller context selection |
| A16–A17 | Both tuple passes, recursive spans, unpack bounds, checked arithmetic and exact consumption/trailing offsets | Compiled-runtime coverage beyond recorded geometries; EVM resource limits remain explicit |
| A18–A19 | Production frame assembly, pack/unpack canonical correspondence and both inverse directions | Compiler/runtime correspondence for arbitrary geometry; universal solc/viem equivalence |
| A20–A27 | Complete tuple layout, cached plans, component checks and exact error fields | Correct cache/context selection in surrounding contracts |
| C30/C39, E8 | Recursive typed encodings and child layout without a chosen depth bound | Navigation/Expressions correspondence, resource assumptions, selective sibling validation |

The [claim-to-theorem mapping](../../docs/verification/abi-source-connection.json)
links 19 ledger rows to passed source declarations. Primary Halmos/concrete labels
retain their runtime bounds. The independent validator is never defined as
equality to the encoder; its equivalence is proved before source correspondence
is composed with it.

## Retained evidence

The current complete source run is
[production-abi-correspondence](evidence/production-abi-correspondence/manifest.json),
with its [nine-fault report](evidence/production-abi-faults/mutations.json).
Every module body is accounted for by verification or a passed result with
identical transitive inputs, tool hashes and verifier arguments. Generation,
audit, all 40 EVM tests and formatting gates ran again. Failed and incomplete
predecessors remain retained; [construction history](construction/README.md)
explains the corrected translator bug, timed-out proof and isolated context
mutation. The [integration check](evidence/production-abi-integration/manifest.json)
confirms existing artifacts and SDK identities agree with this production source.

The independent-model baseline is
[evidence/validator-complete/manifest.json](evidence/validator-complete/manifest.json),
with native verifier CSV, proof/audit logs, fixture check, real-EVM oracle and
formatting logs alongside it. Its `source-snapshot` retains proof and runner
sources, and `oracle-src` retains the concrete implementation tested.
Declaration results distinguish lemmas from a
pure definition such as `Frame` that has no separate verification batch.

Its [model mutation report](evidence/validator-mutations/mutations.json) retains
all nine altered snippets, target declarations, hashes, commands, semantic
failures and per-batch results, plus the exact runner and baseline manifest.

Milestone 1's [baseline](evidence/complete/manifest.json) and
[mutation report](evidence/mutations/mutations.json) remain historical. The latter retains all five altered
snippets, hashes, commands, semantic failures and per-batch results. Its
`baseline-used.json` identifies the earlier passing run used to authorize those
mutations; its three `.dfy` source hashes match the milestone 1 baseline.
The earlier run predates the added EVM-oracle gate and later runner reporting
changes. `runner-used.py.txt` preserves the exact mutation runner. Two mutated
runs additionally had a timeout; each also had explicit semantic proof failures.
A timeout by itself is never counted as detecting a fault.

`evidence/validator` retains an unsuccessful intermediate run while concrete
fixture proof hints were being completed. Source drift is recorded there; it is
not the milestone 2 baseline.

## Source correspondence and next milestone

[The bytes/string milestone](source/README.md) covers bounded reads,
length/padding arithmetic, consumed extent, canonical acceptance and exact error
positions for the default value context in a restricted source-derived program.
Its 256-bit mask checks and full Dafny baseline must pass together. The translator
and memory semantics remain explicit trust assumptions; the parent independent
model baseline does not itself establish any source correspondence.

The [array/tuple composition](aggregate/README.md) now establishes checked cursor
arithmetic and recursive model equivalence under explicit descriptor/static-word
interfaces. [Compiled-bytecode checks](bytecode/README.md) cover the declared
finite geometries and hostile-count families against the exact runtime.

The [descriptor milestone](descriptor/README.md) connects accepted static suffix
text to nested fixed-array footprints and repeated canonical-word checks. The
[typeShape milestone](shape/README.md) now establishes its syntax/product premises
from successful parsing, together with recursive `ShapesFit`. The
[parser correspondence](parser/README.md) closes grammar acceptance completeness
and exact source/reference rejection outcomes, including explicit arithmetic
panics. The [tuple traversal](tuples/README.md) proves recursive static word
checks and copy scheduling, including zero copies and first-invalid offsets.
The [connection milestone](connection/README.md) proves static canonical
acceptance with derived value-span bounds, `suffixStart`, array count/head
preparation and the first tuple head-sizing pass. The [dynamic proof](dynamic/README.md)
now connects the element loops, second tuple pass and body/envelope recursion,
deriving their caller bounds. The [construction proof](construction/README.md)
completes tuple layout, cached validation, all library error contexts and
tuple/pack/unpack correspondence. Both inverse directions derive cursor safety
from their stated encoded-size/descriptor budget.

Next verification layers are compiler correctness, arbitrary-geometry bytecode
induction and the surrounding contracts' use of the codec. Keep depth/resource
qualifications on C39: the 96-level parser oracle pins empty returndata under a
constrained gas budget. Source correspondence does not remove EVM resource limits.
