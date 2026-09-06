# Operators extension handoff

This is an unreleased contract ABI update. No public-chain deployment or EVMcrispr compiler/helper migration is included. `Assertions.sol`, `AbiShape.sol`, ERC-8211 and the Assertions creation/runtime bytecode are unchanged. There is no RationalOperators contract.

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

Descriptors use AbiShape's existing shape grammar. Canonical offsets, lengths, byte padding and bounds are validated, but scalar semantics such as narrow integer range or address high bits remain the caller's claim. An invalid callback result identifies operation/index/target. A reverted callback additionally preserves revert data. Empty lists still validate callback descriptors/slots and value-type descriptors. Slot placeholders can be empty encodings because they are replaced before the callback.

Generic callbacks and ABI validation are materially more expensive than the word-specialized operators. Prefer the latter for word-only data. CollectionOperators uses MCOPY and requires Cancun opcode support. There is no Unicode-aware string conversion.

Operators additionally exposes stable `distinctWords`, full `split` preserving empty segments, and `encodeBytes` returning the existing encoder's output in a normal bytes envelope. Raw-returning `encode` and adjacent-only `uniqueWords` retain their behavior.

## Validation and measurements

With the existing solc 0.8.36 / optimizer 200 / Cancun configuration:

| Contract | Runtime bytes | Local CREATE2 deployment gas |
|---|---:|---:|
| Assertions | 13,116 | 2,895,849 |
| Operators | 20,554 | 4,507,861 |
| CollectionOperators | 12,534 | 2,769,577 |

A temporary contract inheriting both periphery contracts compiled to **30,227 bytes**, exceeding 24,576; the probe was removed after measurement. Each final deployed contract fits. Assertions creation and runtime bytecode matched the saved pre-change artifact byte-for-byte.

`pnpm test` outside the restricted sandbox passed **405 tests: 318 Solidity and 87 nodejs**. Four new Solidity fuzz tests ran 256 cases each. Independent review added randomized stable-sort/permutation coverage across lengths 0–12, middle-slot dynamic callback substitution with constants, and malformed predicate/comparator result checks. The numeric differential suite includes six signed/unsigned rounding variants with 100 cases each, using an independent bigint oracle. New viem fixtures cover strings, bytes, static tuples, fixed dynamic arrays, nested arrays and malformed encodings. Core integration exercises read, nav, cond and orElse, including a reverting unused branch.

Gas estimates include transaction intrinsic/calldata costs; they are not isolated execution costs. Numeric samples are emitted by `pnpm hardhat test nodejs test/math-fuzz.test.ts`:

- `mulDiv(uint256.max,2,4,Trunc)`: 23,460 gas; Floor/Ceil: 23,490.
- Signed `mulDiv(-7,1,3,Trunc)`: 23,460; Floor/Ceil: 23,490.
- `parseUnits("-1.239",2,Floor)`: 26,229.
- `formatUnits(int256(-10020),4)`: 26,644.

`pnpm hardhat run scripts/measure-collection-gas.ts` estimates signed integer arrays in descending order:

| Operation | 1 value | 4 values | 16 values |
|---|---:|---:|---:|
| packArray | 36,010 | 62,122 | 167,298 |
| sortValues | 56,011 | 267,030 | 1,642,971 |
| foldValues | 120,121 | 305,076 | 1,045,322 |

The sorter uses checked subtraction as the comparator for these small test values; consumers comparing unrestricted signed integers should use a comparator that returns order without subtraction overflow.

## Artifacts and next integration

`website/scripts/export-deploy-artifact.mjs` exports ABI modules, creation bytecode, verification inputs, measured deployment gas and deterministic addresses for all three contracts, enforcing the runtime limit. It verifies addresses by replaying deployment on a local Hardhat network. Operators retains its old salt but has a new address; CollectionOperators uses `keccak256("Assertions.CollectionOperators.v1")` as its salt.

Canonical addresses, independently verified with `node website/scripts/export-deploy-artifact.mjs` and local CREATE2 deployment replay:

- Assertions: `0x67DBB438FdC614466984Dc8F68dAB812d785a2aE`
- Operators: `0x795a1E555147d09AB6eE972B4D63a0508b582492`
- CollectionOperators: `0xd3F401e4C356667B061B6129755B7a1A279f2e1f`

The current upstream EVMcrispr SDK is on an older core fixture (12,885 runtime bytes at `0xA55E472841ca3D318205036724A94F5abDbf7b18`). This is pre-existing version skew: this change preserves this repository's 13,116-byte core exactly. Integration must align the SDK core ABI/fixture/address with the verified artifact together after reviewing compatibility; never install the new artifact under the old canonical address.

The generated modules under `website/src/lib/` are the ABI/deployment source of truth. The vendored EVMcrispr pin remains untouched. A subsequent integration must consume the new mulDiv selectors and typed collection callback/envelope contract; helper names and arithmetic mode policies are intentionally not specified here. Do not claim the existing website SDK bytecode parity gate passes until that integration updates fixtures and addresses together. The website's interactive deployment UI still has its existing two-contract inventory; this change exports the optional third contract without expanding that UI.
