# Concrete codec error bytes for Collections

This package replaces the supplied typed-codec-error encoder in the completed
admission, constant-validation and binding compositions with concrete ABI bytes.
It does not complete the public Collections traversal proofs.

`generate.py` compiles the current Collections and AbiCodec sources with pinned
solc 0.8.36. The union of their ABI errors checks all seven names and field kinds;
compiler AST error selectors bind the generated constants. Neither ABI alone
contains all seven errors. The standard Panic(uint256) selector is explicit.

`Encoding.dfy` maps each typed codec result to its selector and typed fields.
It proves the field schema, static ABI frame equivalence, exact packet length,
selector prefix and every argument word position. `RoundTrip` additionally proves
field values and bytes4 right padding under `Fits`: four-byte selectors fit 32
bits, addresses fit 160 bits, and uint256/bytes32 fields fit 256 bits. Encoding is
total outside these bounds but is not claimed to preserve unrepresentable natural
values. Success maps to an empty byte sequence and is never used as a revert.

`Connection.dfy` instantiates arbitrary descriptor admission with this encoder.
For admitted matching tuple descriptors, `Constants` preserves the exact first
non-substituted invalid constant and all earlier valid constants, exposing its
concrete selector/frame bytes. `Binding` preserves the selected component's
canonical-value equivalence, validated assignment, cache flag and one-request
history, with exact encoded failure bytes. These wrappers call the existing
source-connected methods; they do not posit successful codec observations.

Inherited descriptor/resource/CursorRoom and memory assumptions remain. Source
receipt scalar values must faithfully project Solidity fields. Compiler ABI
encoding, the source translation and Dafny/Boogie/Z3 remain trusted. Unreached
fallback environment observations are not certified. Input/result-validation
helpers and complete state/history-sensitive callback/traversal composition are
still open, as are the remaining Collections public families and sorting.

The retained driver checks fresh generated metadata, identical dependency source,
artifact and tool hashes, native proof rows for every local method/lemma, a zero
finding audit, formatting, and seven concrete EVM fixtures. Five fixtures execute
production Collections constant/binding failures; two compare independent packed
field geometry with compiler ABI encoding, including bytes4, address, count,
descriptor, uint256 maximum and Panic. These are representative execution checks,
not universal bytecode proofs. There is no new source-fault campaign or gas,
deployment, or performance claim.

Run from the repository root with the pinned executables:

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/codec-errors/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/codec-errors/evidence/concrete-codec-errors
```

The manifest and native proof results are authoritative for completion; the
cross-package ledger checker is `scripts/check-collections-codec-errors-evidence.py`.
