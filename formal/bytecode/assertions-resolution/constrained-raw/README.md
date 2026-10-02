# Exact RAW resolver with constraints

This directory composes actual `Assertions` runtime instructions with the
independent constraint and heap specifications in `../constraints`. Production
Solidity is unchanged. The runtime is pinned to SHA-256
`84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903`.

`Before.generated.dfy` proves all 239 instructions from `_resolve` at PC 3393
through its `_validateConstraints` call at PC 7580. Its count and payload are
arbitrary within explicit calldata, stack and allocation bounds. Its retained
native include closure is `evidence/before-native-v1/manifest.json`.

`Connection.dfy` joins the prefix, an arbitrary-count successful non-OR validator
and the eight-instruction resolver continuation. `Error.dfy` joins the prefix
with the first malformed non-OR leaf, including arbitrarily many preceding
successful constraints and exact physical error bytes. These interfaces preserve
the original resolved payload while the decoder allocates later records.

The `public` directory discharges the helper representation premises from an
empty public EVM frame:

- `Connection.dfy` returns exactly the original RAW calldata payload after all
  admitted non-OR constraints hold.
- `Error.dfy` physically reverts with the first `InvalidConstraintData` or
  `InvalidConstraintRange`, preserving its index and arguments.
- `WordBounds.dfy` physically rejects a constraint count larger than the number
  of complete resolved words before reading any constraint record. Its leaves
  may contain malformed enum or OR data because those bytes remain unread.

These are admitted public classes, not a completion claim for `resolve` as a
whole. OR, ordinary failed predicates and their `ConstraintFailed` serializer,
the other fetchers, malformed wrapper ABI and resource failures remain outside
these class theorems.

`public/verify.py` accepts only a passed immutable native include closure whose
exact source, tool and retained-evidence hashes match. It then reproduces the
compiler runtime, regenerates reached-opcode certificates, checks all literal
code guards and PUSH-aware destinations, runs independent complete EVM traces,
and kills an actual runtime-byte mutation with a native semantic failure and
an incorrect physical receipt. A development pass alone is insufficient;
the final manifest must report `passed`.

The global `--isolate-assertions` experiment remains in
`../constraints/evidence/success-native-v1`. It failed and is excluded from
accepted evidence. Fresh public closures use normal native verification of
every included file, retaining each source declaration's explicit isolation
attributes. Successful earlier dependency manifests remain immutable.
