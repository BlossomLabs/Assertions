# Complete Assertions public ABI boundary

The compiler-derived inventory contains seventeen function entries: fifteen
explicit function/overload cases plus the public `LEN()` and `PAYLOAD()` constant
getters. `generate.py` compiles the current production sources for AST and ABI,
checks all signatures, outputs and mutabilities against `inventory.json`, checks
the one-to-one proof-case mapping, and translates the actual public int256
constant initializers. Any extra public function, overload or getter fails this
gate. The previous fifteen-case dispatcher remains a dependency with its scope
corrected in the claims ledger.

`Getters.Source` establishes the exact signed values and 32-byte ABI words.
`GetterResult` proves that a literal-resolver representation used in the existing
recursive model emits the same bytes with no external observations. This is a
semantic lowering for the proof; deployed constant getters do not invoke resolve.
The constant-getter ABI rule is an explicit compiler projection premise.

`Compose` gives a public-entrypoint postcondition for the root. `ReachedChild`
extracts the same postcondition and exact parent observation for any reached
self-call, including either getter and rejected calldata. The existing finite
recursive construction retains actual calldata, independent frame environments,
exact reached-site coverage, unique sites and explicit unready outcomes. No
canonical calldata or deterministic external-call assumption is added.

Faithful public ABI decoding, generated resolver calldata, error and bytes[]
serialization, call context, memory and sufficient local resources remain
explicit premises. This completes the entrypoint inventory/connection; it does
not by itself instantiate the remaining error/bytes[] wire functions or prove
compiler correctness, infinite recursion behavior, physical gas guarantees or
exact compiled bytecode. No new EVM or production source-fault campaign is
claimed. The retained verifier checks generation, native declarations, complete
dependency source/tool/artifact hashes, audit, formatting and unchanged inputs.
