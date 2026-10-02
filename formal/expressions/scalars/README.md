# Expression scalar source adapters

This package replaces selected primitive assumptions of the recursive evaluator
with source-connected proofs: Literal identity; Parameter length/index checks,
retrieval and errors; exact-word/clean-address validation; Select's first-word
truth; ABI Boolean encoding; and the sampled guard-failure predicate. Resolve,
compound constructors/arguments, external calls/probes, complete rejection
serialization and top-level entrypoint composition remain separate obligations.

The complete normalized `_evaluate`, `_address` and `_rejectOutOfGas` ASTs are
gated, but only these selected paths are lowered here. Four supported slots
translate Parameter's index bound, address upper bound, truth comparison and
exhaustion disjunction. Other source changes fail closed. The restricted
translator and manual control/data projection remain trusted.

`Parameter` first rejects data whose length is not 32, then decodes the full
word and checks it against the arbitrary finite parameter list. Exact 32-byte
uint256 decoding uses the same byte-word projection as the proved codec reader.
The result preserves the requested parameter bytes; subsequent node validation
remains the recursive evaluator's responsibility. The structured errors include
both indices. `ErrorWords` proves that their ABI words round-trip without
truncation under the source's uint256 index bounds. The generator checks selector constants against solc's AST-computed error
selectors, and the EVM oracle checks exact errors against Solidity's generated
selectors.

`Address` requires exactly one word and accepts the complete uint160 range,
including its maximum. It refuses a dirty upper bit or extra word before the
caller proceeds to code checks. Successful receipt projection acknowledges the
original word; it does not replace or truncate the bytes passed to a later call.

`CanonicalHasWord` derives a minimum of 32 bytes from ABI validation soundness
and canonical encoding's positive aligned size, for all well-formed nested
types. `TypedTruth` invokes the actual source-connected `AbiCodec.word` reader
and proves equivalence with a concrete total first-word predicate. All canonical
dynamic values have leading word 32 and therefore judge true, including empty
bytes. `EvaluateWithWordTruth` instantiates the recursive source theorem with
this concrete predicate. No caller-supplied truth oracle remains in that entry.

`BooleanValue` connects the pinned `abi.encode(success)` source expression to
the ABI encoding/validation specification for bool. `LiteralReceipt`,
`ParameterReceipt`, `AddressReceipt`, `BooleanReceipt` and `GuardFailure` produce
the recursive model's receipt type. `GuardFailure` proves the exact disjunction
of the sampled gas threshold and exact four-byte reserved signal; a longer
prefix match is ordinary failure when the gas predicate is false. This does
not diagnose every physical cause of exhaustion or assume view-call determinism.

Assumptions: faithful Solidity memory/calldata and ordinary word ABI projection,
fixed selector encoding, representable lengths/indices, sufficient local
resources, actual sampled gas/revert observations, and trusted pinned solc,
translator, Dafny/Boogie/Z3. Earlier dependency results are reused only after
complete source/tool/artifact and native declaration audits. This is source
verification, not exact compiled-bytecode verification.

The baseline runs all local proof declarations, audit, formatting and eight EVM
regressions. Four actual source faults must translate successfully, fail their
named semantic method and fail their named EVM regression. The faults exercise
the boundary index, maximum clean address, first-word comparison and reserved
marker. Parse/type/resource/timeout failures do not count as semantic kills.

```sh
python3 -B formal/expressions/scalars/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /fresh/baseline
python3 -B formal/expressions/scalars/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /fresh/faults
```
