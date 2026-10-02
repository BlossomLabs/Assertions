# Recursive `typeShape` success soundness

This milestone connects successful execution of the source-derived `typeShape`
and `shape` parsers to a recursive descriptor grammar and the existing ABI shape
model. Descriptor bytes are arbitrary; valid syntax is an output of the theorem,
not an input assumption. There is no chosen bound on name length, decimal digits,
array suffix count, tuple arity or nesting depth.

## Established properties

`AbiShapeSource.TypeShape` establishes, whenever parsing succeeds:

- The returned end is strictly past the starting position, within `limit`, and
  the consumed byte slice is exactly the spelling of a valid descriptor tree.
  Parsing stops before the next non-suffix byte. `shape` additionally requires
  that the entire descriptor was consumed.
- Names are nonempty `[a-z0-9]+` sequences. Exactly `bytes` and `string` are
  dynamic base names; other spellings are static, even if Solidity would not
  recognize them as ABI type names. Tuples contain at least one component.
- Fixed counts are positive and at most `2^32-1`. Leading zeros preserve the
  decimal value. Static fixed-array footprints have the same cap; dynamic
  arrays have one head word. Bare static tuple sums do **not** have a uint32 cap.
- Dynamic flags and head widths agree with the recursive model. Every accepted
  node has a positive head width representable in uint256.

`ModelShape` maps that syntax into `AbiEncoding.AbiType` and proves
`WellFormed`, `IsDynamic`, `HeadWords` and the aggregate interface's recursive
`ShapesFit` condition. Static leaf names are erased to `Scalar(Opaque)` **for
shape only**: this does not replace the separately proved narrow-word classifier.

`ParsedShape` discharges the earlier suffix proof's assumptions for successful
static non-tuple parses: `SuffixList`, exact suffix text at the name end,
`Product < 2^32`, and equality between the product and returned word footprint.
The suffix scanner no longer needs a separate assumption that such a successful
parse somehow established those properties.

The [final mutation campaign](../evidence/type-shape-complete-mutations/mutations.json)
passes **5/5**: disabling tuple dynamic propagation, altering tuple addition,
changing decimal radix, disabling dynamic-array propagation and replacing fixed
multiplication with addition each cause semantic proof failures and EVM failures.
There are no timeouts, unaccounted tests or source drift in that campaign.

## Source connection and trust

`generate.py` obtains the pinned solc 0.8.36 AST and checks the full `typeShape`,
`shape`, `scanName` and `byteAt` structure against `structure.json`. Selected
arithmetic and boolean right-hand sides are translated from the AST, so faults
in those expressions reach the proof rather than being rejected by a text hash.
The retained compiler input/output and mapping identify the exact source.

`TypeShape.template.dfy` preserves recursive calls, loop guards, early exits,
checked arithmetic and the order of rejection checks. The suffix loop and digit
loop are factored into proof methods; a ghost descriptor tree records what was
consumed. Checked sum/product overflow produces `ArithmeticPanic`, rather than
silently using unbounded integers. Index arithmetic and digit accumulation are
proved to fit on the paths that execute them.

Three bitvector obligations justify the normalized uint32 bitwise-OR bound and
the five/six-byte calldata-name extraction. Big-endian decoding injectivity then
connects the extracted value to the exact name spelling. The prior descriptor
baseline supplies the separately verified scanner/classifier and word-mask gates;
its evidence and all shared source hashes must match.

The Python translation, loop factoring, pinned solc AST, Dafny/Boogie/Z3 and
calldata projection remain trusted. Valid nonwrapping calldata layout and
sufficient execution resources are assumed. This is a source-level theorem,
not a compiler-correctness, gas, physical-memory or EVM stack-depth theorem.
No axioms, `assume`, skipped proof bodies or termination escapes are introduced.

## Successor milestones and limits

This milestone itself proves success soundness. The later
[parser correspondence](../parser/README.md) characterizes acceptance in both
directions using `Admissible` trees and proves every source outcome equal to a
recursive reference, including checked panics and exact rejection positions.
It accounts for the tuple accumulator even after a dynamic component makes the
final width one. The [static tuple traversal](../tuples/README.md) then connects
parsed syntax to recursive `checkWords` and its zero-copy no-read behavior.

All retain resource assumptions: there is no unlimited on-chain recursion or
unconditional typed-error guarantee. The parser EVM oracle records a 96-level
malformed descriptor failing with empty data at 2,000,000 gas. `suffixStart`,
`tupleLayout` enumeration, the complete `body` connection, other error contexts
and arbitrary-geometry bytecode induction remain open.

## Reproduce and evidence

The [original complete baseline](../evidence/type-shape-complete/manifest.json) passes **100
lemmas, 30 proof methods and 899 verification batches**, with zero errors,
timeouts or audit findings. All three bitvector gates and all eight EVM tests
pass, as do the generated-source freshness, dependency integrity and formatting
gates. Counts include earlier milestones and must not be added to their totals.


```sh
python3 -B formal/abi/shape/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --descriptor-evidence formal/abi/evidence/descriptor-traversal-final/manifest.json \
  --output /tmp/abi-shape-baseline

python3 -B formal/abi/shape/mutations.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --baseline /tmp/abi-shape-baseline/manifest.json \
  --output /tmp/abi-shape-mutations
```

Output directories must be new. Results retain source snapshots and hashes,
revision, compiler/solver versions, exact commands, assertion-batch inventory,
logs, limits, EVM test counts, formatting and audit checks. Mutations alter copies
of the actual Solidity source and must cause both semantic proof failures and
EVM failures; translator rejection or a solver timeout does not count.

The [initial combined attempt](../evidence/type-shape/manifest.json) is retained
as incomplete: its raw Dafny log reports 831 verified batches, one unproved digit
invariant and one timeout. The historical summary parser reported zero verified
batches because it did not recognize singular `1 error`; the CSV and raw log are
authoritative. The current runner handles that form. Splitting the proof methods
and making the decimal-step lemma explicit retains the original obligations.

The [split-method baseline](../evidence/type-shape-split/manifest.json) passed all
897 batches. Its [first mutation campaign](../evidence/type-shape-mutations/mutations.json)
was incomplete: two faults reached both semantic and EVM failures, while three
were stopped by compiler-generated declaration IDs/source locations retained in
the structural fingerprint. Those bookkeeping fields are now excluded; declared
variables, types, expressions, control flow and assembly remain checked. The
current baseline re-ran the complete proof graph after that translator correction.

The [following baseline](../evidence/type-shape-final/manifest.json) passed all
897 batches with the corrected structural fingerprint. Its [mutation campaign](../evidence/type-shape-final-mutations/mutations.json)
detected four faults completely; the dynamic-array fault failed an invariant and
two EVM tests but also timed out downstream, so the campaign remains incomplete.
The current proof adds a local, verified shape-transition assertion before the
grammar/positivity checks. All earlier obligations and the 30-second solver limit
are retained; the two extra batches bring the current total to 899.

The [explicit-slice refresh](../evidence/type-shape-explicit-slices/manifest.json)
passes **914 batches**, with the same 100 lemmas, 30 methods, three bitvector
gates and eight EVM tests. A later combined parser run exposed solver sensitivity
in the existing suffix-text equality. Two explicit byte/slice assertions make
that equality local without weakening any obligation or changing Solidity.
The earlier 899-batch evidence and five-mutation campaign remain historical.
