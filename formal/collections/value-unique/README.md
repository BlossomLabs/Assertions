# Public callback-defined value uniqueness

Targets `uniqueValues`. This package proves conditional source semantics at the
finite decoded ABI boundary. Read the retained manifest for actual run status;
development checks alone add no public coverage. Exact compiled bytecode remains
a separate incomplete track.

`Spec` defines an independent greedy retained-index algorithm. Every candidate is
validated in original order. Unordered mode compares retained originals in order
until the first true result; ordered mode compares only the last retained original.
`Decisions` proves the exact comparison prefix: false replies precede the stopping
true reply or failure. A dropped candidate has a witnessed true comparison; a
retained candidate has exhausted its chosen comparison range with false replies.
Returned indices increase strictly, preserving original encodings and order.

`Model` gives explicit resources. `Compare` calls the actual retained component
binding, callback and strict-result adapters with retained original in `first`,
candidate in `second`, original candidate index `i` and retained ordinal `j`.
`Engine` validates each actual candidate before those comparisons. It threads
prepared arguments, persistent lazy target checks and low helper/external histories.
The high environment is built from these actual receipts. Opaque trace predicates
and replay lemmas retain every reached record without assuming callback acceptance.
`Entry` calls raw binary preparation and descriptor admission before the loop.
`Connection` composes these with the compiler-derived source loop and independent
specification, exact first failures, stable original-value writes and output count.
Empty/singleton inputs make no comparison, but admission and candidate validation
still execute. An unselected later comparison cannot fail a stopped comparison.

Arbitrary actual callbacks may be history-sensitive or asymmetric. The theorem
proves their exact greedy algorithm; it does not infer equality-class uniqueness,
mathematical equivalence classes or ordered/unordered agreement. Such stronger
relations require explicit observation coherence, equivalence and grouping
premises. The concrete ordered/non-grouped fixture intentionally shows repeats.
`Classes.Run` separately calls the actual public source composition and proves
first representatives of a key partition under explicit coherent key-equality
observations. Ordered mode then returns run starts; grouped keys additionally
make its selection equal the unordered selection. Failures remain observable;
these stronger premises never assume public acceptance. No gas or complexity
property is inferred from source termination.

`generate.py` gates the complete compiler AST and binds the public selector. It
lowers validation/operand/metadata indices, binary mode, both loop conditions,
ordered start, keep/write controls and final output-header shrink. Other fixed
source statements are structurally gated and projected by the adapters. Edit
`Control.template.dfy` and regenerate; never edit generated controls directly.

Premises include faithfully decoded finite strings/bytes/pointer arrays; fitting
uint256 lengths/cursors/packets/encoding footprints; codec resources for rejecting
and accepted values; faithful source/compiler/calldata/call contexts and byte
memory/MCOPY/MSTORE/logical writes; successful allocation/outer return serialization
and sufficient allocation/execution resources. Outer budgets conservatively cover
both retained-index choices and future histories while preserving non-binding
constant slots, plan and canonical constants. Only reached comparisons need call
resources. Logical arrays and source shrink controls do not establish physical
allocator or serializer behavior. Compiler allocator guards/OOG remain excluded.

`verify.py` freezes all package files before checking every local declaration,
identical transitive native/source/tool/artifact closure, regeneration, zero escape
audit, formats, sixteen real EVM fixtures and eight source mutations in isolated
snapshots. Faults must translate and fail a baseline-covered native semantic
assertion and real EVM fixture; timeouts never count as detection. Finish package
files before the snapshot and poll live verification to completion without
restarting because a polling request times out.

```sh
python3 -B formal/collections/value-unique/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/value-unique/evidence/public-greedy-uniqueness
```
