# Operators extension handoff

This is an unreleased contract update. The local EVMcrispr SDK is integrated with the refreshed artifacts, but no public-chain deployment or published website vendor-pin update is included. `AbiCodec` now owns the shared grammar, strict validation, and assembly; core behavior and ERC-8211 are unchanged, but importing the new library changes artifact metadata and CREATE2 addresses. There is no RationalOperators contract.

## Numeric ABI

`Rounding` encodes as `uint8`: `Trunc=0`, `Floor=1`, `Ceil=2`. Selectors are based on:

- `mulDiv(uint256,uint256,uint256,uint8)` → uint256
- `mulDiv(int256,int256,int256,uint8)` → int256
- `exp(int256,uint256)` → int256
- `parseInt(bytes)` → int256; `toString(int256)` → string
- `parseUnits(bytes,uint256,uint8)` → int256
- `parseUnitsUnsigned(bytes,uint256,uint8)` → uint256
- `formatUnits(int256,uint256)` and `formatUnits(uint256,uint256)` → string

The old three-argument mulDiv and mulDivUp selectors are removed, without aliases. Each mulDiv performs a full 512-bit product and rounds the quotient once; it accepts signed minima and negative denominators. A zero denominator panics `0x12`. An out-of-range rounded result panics `0x11`, including cases where truncation fits but ceil/floor does not. Rounded division alone is multiplication by one. Ordinary multiplication remains checked word arithmetic.

Decimal conversions use precision 0–77 and reject whitespace, exponent notation and malformed input. At least one digit is required, but `.1` and `1.` are accepted. Unsigned parsing rejects a minus sign, including `-0`; plus signs are accepted. Formatting trims fractional trailing zeros. Excess input precision uses the selected rounding mode.

## ABI collections

The complete generic family is in CollectionOperators: `packArray`, `unpackArray`, `validateValue`, `mapValues`, `filterValues`, `foldValues`, `sortValues`, `distinctValues`, and `flattenValues`. Each bytes element is one canonical single-value ABI encoding. Callback metadata is `(address target,bytes4 selector,string arguments,bytes[] constants,uint256 first,uint256 second)`.

Unary operations substitute the element at `first`; binary operations substitute accumulator/left at `first`, element/right at `second`. Other argument slots remain constants. Full calldata is rebuilt, including dynamic offsets. Map/fold callbacks must return exactly one value matching the declared result shape; dynamic multiple-return tuples need an explicit single tuple/struct return. Predicates must return exactly one canonical bool word, comparators one int256 word. Map/filter/fold preserve order; sorting and deduplication are stable. Fold has no early-exit mode.

Descriptors use AbiCodec's shape grammar. Canonical offsets, lengths, byte padding and bounds are validated, but scalar semantics such as narrow integer range or address high bits remain the caller's claim. An invalid callback result identifies operation/index/target. A reverted callback additionally preserves revert data. Empty lists still validate callback descriptors/slots and value-type descriptors. Slot placeholders can be empty encodings because they are replaced before the callback.

Generic callbacks and ABI validation are materially more expensive than the word-specialized operators. Prefer the latter for word-only data. CollectionOperators uses MCOPY and requires Cancun opcode support. There is no Unicode-aware string conversion.

Operators additionally exposes stable `distinctWords`, full `split` preserving empty segments, and `encodeBytes` returning the existing encoder's output in a normal bytes envelope. Raw-returning `encode` and adjacent-only `uniqueWords` retain their behavior.

## Shared codec and validation

`AbiCodec` replaces the separate shape and value libraries. `encode` and `encodeBytes` now strictly validate complete canonical values, including nested tails. Tuple and array assembly share a single allocation/copy implementation. Component diagnostics retain their original signatures, with `InvalidComponentValue(index, offset)` added for nested failures. Callback result validation is internal and keeps operation/index/target context.

Typed callbacks prepare their argument geometry and validate constants once per operation. Word map/filter/folds share window checking, stamping, and invocation. Their existing overlap, first-word, and early-exit semantics remain intact.

See [ABI codec refactor measurements](abi-codec-refactor.md) for reproducible compiler-size and gas comparisons and validation results. The merged periphery still exceeds the runtime limit; the deployed layout remains a core plus two periphery contracts with unchanged production compiler settings.

## Artifacts and integration

`website/scripts/export-deploy-artifact.mjs` exports ABIs, creation bytecode, verification inputs, deployment gas, and deterministic addresses for all three contracts, enforcing the runtime limit and replaying CREATE2 deployment locally.

Current artifact candidates (not public deployment claims):

- Assertions: `0x8794b0d097C07e7520B421d02201E34c9eE3E156` (13,116 runtime bytes).
- Operators: `0x7B4F82C8A21dCaf7D96D4113D6d23578d1F0A91D` (23,737 runtime bytes).
- CollectionOperators: `0x87841575F679dA8E877db0A95b1bCF2C0d0D55dc` (13,825 runtime bytes).

The local EVMcrispr SDK addresses and runtime fixtures are updated together. Compiler routing still uses fixed windows for word templates and whole argument slots for typed callbacks. The website integration checker now checks all three artifacts and can run against the local checkout with `EVMCRISPR_SRC`.

The website vendor pin remains unchanged: publishing and pinning a tested SDK commit is still pending. The interactive deployment UI retains its existing core/Operators inventory; the optional collection artifact is exported separately.
