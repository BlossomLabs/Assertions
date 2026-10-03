# Operations.add

Proof homes for `add(uint256,uint256)` and `add(int256,int256)`:

- [Unsigned.dfy](Unsigned.dfy): `OperationsUnsignedAdd.VerifyAdd`.
- [Signed.dfy](Signed.dfy): `OperationsSignedAdd.VerifyAdd`.
- [Spec.dfy](Spec.dfy): independent mathematical outcomes and exact ABI return or `Panic(0x11)` payload.

Both top-level obligations remain incomplete. They have no accepted public-function proof credit. The dispatcher and common initialization blocks are supporting obligations, not replacements for the top-level theorems.

Each theorem quantifies over all operands in its ABI domain and an arbitrary hash/precompile backend. Execution begins at PC 0 with the complete runtime bound by [runtime.json](../runtime.json), empty stack and memory, canonical calldata and zero call value. The current sufficient-gas premise is 600, with a bounded execution budget of 163 instructions. Reachable-path composition must establish these bounds for all inputs; measured concrete paths alone do not establish them.

Unsigned addition returns the unbounded sum below 2^256, otherwise reverting. Signed addition returns the sum in [-2^255, 2^255-1] encoded as two's complement, otherwise reverting. Both errors must return the exact `Panic(0x11)` bytes. Malformed calldata, nonzero call value, insufficient gas and construction are excluded.

These obligations provide partial coverage of public claim O1, which also includes subtraction and multiplication. Existing claim wording, qualifications and evidence remain preserved.

Development command, after bootstrap and runtime capture:

```sh
proof-tools/dafny/dafny verify formal/contracts/Operations/add/Unsigned.dfy \
  --verify-included-files --manual-lemma-induction --isolate-assertions \
  --cores 2 --verification-time-limit 30 \
  --solver-path proof-tools/dafny/z3/bin/z3-4.12.1
```

Repeat for `Signed.dfy`. Complete source closures, audit, compiler reproduction, independent receipt review, concrete execution and native proof mutation gates are separately required for acceptance.
