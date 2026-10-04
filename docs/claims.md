# Functional claims

<!-- claim-coverage -->
| | Formally verified | Partially verified | Tested | Partially tested | Scope limitation | Environment assumption | Unverified |
|---|---|---|---|---|---|---|---|
| Claims | 140 | 44 | 136 | 3 | 2 | 1 | 0 |
<!-- /claim-coverage -->

Unless a claim specifies an error or resource limit, execution assumes valid ABI decoding, representable intermediate arithmetic, faithful EVM observations and enough gas, stack and memory. External call results may vary with caller, gas and history; consistency is required only where stated.

Verification labels refer to the linked run's source snapshot and stated scope. **Formally verified** means the linked symbolic properties passed within their documented assumptions and bounds; **Partially verified** covers only part of the claim. **Prior snapshot** marks formal evidence not revalidated against the current sources. **Tested** identifies unit, fuzz or differential evidence; **Partially tested** covers only part of the claim. **Scope limitation** records a boundary of the guarantees; **Environment assumption** records a condition required for execution. **Unverified** means no retained passing evidence. Current formal labels reflect the bounded Halmos baseline; separate source and bytecode proof campaigns are excluded. Detailed scope, references and run limitations are in [per-claim evidence](claim-evidence.md).

A claim whose text begins with \* changed after the rc1 snapshot: its statement, and the tests behind it, differ from what rc1 recorded.

## Assertions

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| C1 | A violated constraint reverts the judge call. Guarded actions roll back only when assertions execute mandatorily in the same transaction and the enclosing executor propagates failure. `assertBatch` evaluates entries in order and stops at the first failure. | Tested (unit) | [Tests & scope](claim-evidence.md#c1) |
| C2 | `assertParam` resolves one `InputParam` through its fetcher and validates its inline constraints | Tested (differential) | [Tests & scope](claim-evidence.md#c2) |
| C3 | `assertParam`/`resolve` ignore `paramType` (nothing is routed) | Formally verified | [Proof & scope](claim-evidence.md#c3) |
| C4 | `assertBatch` entries without a TARGET are predicate entries: resolve and validate only, no call | Tested (differential) | [Tests & scope](claim-evidence.md#c4) |
| C5 | For a nonzero TARGET, the constructed staticcall sends functionSig followed by CALL_DATA values in order; target position does not change that layout. | Formally verified | [Proof & scope](claim-evidence.md#c5) |
| C6 | A TARGET resolving to `address(0)` skips the constructed call | Tested (differential) | [Tests & scope](claim-evidence.md#c6) |
| C7 | View-mode refusals: outputParams `OutputParamsNotSupported(entry)`, VALUE `ValueParamNotSupported(entry,param)`, second TARGET `DuplicateTargetParam(entry)`, BALANCE target `BalanceCannotBeTarget(entry,param)` | Formally verified | [Proof & scope](claim-evidence.md#c7) |
| C8 | A TARGET word with dirty upper bytes reverts `InvalidAddressWord(paramIndex, word)` | Tested (unit) | [Tests & scope](claim-evidence.md#c8) |
| C9 | `ConstraintFailed` carries message, entry index, param index, constraint index, kind, actual word and echoed reference | Formally verified | [Proof & scope](claim-evidence.md#c9) |
| C10 | Every judge function has a custom-message overload echoed in `ConstraintFailed`; defaults are "PARAM", "COMPOSABLE", and "" on primitive operands | Formally verified | [Proof & scope](claim-evidence.md#c10) |
| C11 | A reverting constructed batch call reverts `CallFailed(target, builtCalldata)`; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#c11) |
| C12 | Call-based fetchers and constructed calls use STATICCALL; literals and native balances are read directly, with no storage writes. | Tested (unit) | [Tests & scope](claim-evidence.md#c12) |
| C13 | A STATIC_CALL operand can invoke `assertBatch`, allowing validity, fallback and revert probes over a batch. | Formally verified | [Proof & scope](claim-evidence.md#c13) |
| C14 | RAW_BYTES resolves to `paramData` unchanged | Formally verified | [Proof & scope](claim-evidence.md#c14) |
| C15 | STATIC_CALL resolution preserves raw returndata bytes after constraints; other caller/gas contexts may produce different values. | Formally verified | [Proof & scope](claim-evidence.md#c15) |
| C16 | A STATIC_CALL to a code-less address reverts `CallFailed(target, callData)` instead of yielding empty data | Formally verified | [Proof & scope](claim-evidence.md#c16) |
| C17 | A reverting STATIC_CALL target reverts `CallFailed(target, data)`; exhaustion and the exact reserved signal propagate instead (C69) | Tested (differential) | [Tests & scope](claim-evidence.md#c17) |
| C18 | BALANCE: 40-byte `token ++ account`; token 0 reads the native balance, else `balanceOf` first word; other lengths `InvalidBalanceData(entry,param,len)` | Formally verified | [Proof & scope](claim-evidence.md#c18) |
| C19 | A failure inside a nested STATIC_CALL surfaces as `CallFailed` in the resolving frame (inner reason lost); exhaustion and the exact reserved signal propagate instead (C69) | Tested (differential) | [Tests & scope](claim-evidence.md#c19) |
| C20 | Malformed STATIC_CALL `paramData` can produce ABI-decoder bare reverts; decoder allocation panics and resource failures remain possible. | Tested (unit) | [Tests & scope](claim-evidence.md#c20) |
| C21 | `resolve` validates constraints before returning; a violation reverts `ConstraintFailed("",0,0,..)`, making any node an inline assert | Tested (differential) | [Tests & scope](claim-evidence.md#c21) |
| C22 | STATIC_CALL operands can nest core primitives into finite trees; each call has its own caller and gas context. | Tested (differential) | [Tests & scope](claim-evidence.md#c22) |
| C23 | `gather` returns raw operand results as canonical `bytes[]`; element contents remain untyped until a consumer validates them. | Formally verified | [Proof & scope](claim-evidence.md#c23) |
| C24 | `gather` and `get` resolve each supplied operand once; duplicated entries are independent operands. | Tested (unit) | [Tests & scope](claim-evidence.md#c24) |
| C25 | `gather` names a failing operand by its list index | Formally verified | [Proof & scope](claim-evidence.md#c25) |
| C26 | `gather`'s result feeds a `bytes[]` position of `get` as one whole argument | Formally verified | [Proof & scope](claim-evidence.md#c26) |
| C27 | `pick` selects a full raw word, with negative indices counted from the end; invalid indices raise `ReturnDataOutOfBounds(index,length)`. | Formally verified | [Proof & scope](claim-evidence.md#c27) |
| C28 | After successful resolution, an empty `nav` path returns the bytes unchanged without checking the descriptor. | Tested (differential) | [Tests & scope](claim-evidence.md#c28) |
| C29 | Static `nav` terminals return their complete bare ABI footprint after bounds and word-range checks. | Tested (differential) | [Tests & scope](claim-evidence.md#c29) |
| C30 | Every static word returned by `nav` must satisfy its descriptor range; failures report `InvalidValue` at the resolved-data offset. | Partially verified | [Proof & scope](claim-evidence.md#c30) |
| C31 | Only the returned value is checked; siblings the path skips are not | Formally verified | [Proof & scope](claim-evidence.md#c31) |
| C32 | A string/bytes terminal returns `[0x20][len][payload]`; nonzero padding reverts `InvalidValue` at the first dirty byte | Formally verified | [Proof & scope](claim-evidence.md#c32) |
| C33 | Dynamic array/tuple terminals return canonical single-value ABI encoding; malformed selected nested values raise codec errors. | Tested (differential) | [Tests & scope](claim-evidence.md#c33) |
| C34 | Arrays of static elements return `[0x20][len][elements]`, bounds- and range-checked in place | Formally verified | [Proof & scope](claim-evidence.md#c34) |
| C35 | \* `nav` indexes tuple components nonnegatively and array elements with signed indices; within a step, index errors follow that step's descriptor and data validation. | Tested (differential) | [Tests & scope](claim-evidence.md#c35) |
| C36 | A step into a non-composite reverts `InvalidNavigation(descriptor position)` | Tested (differential) | [Tests & scope](claim-evidence.md#c36) |
| C37 | \* Ordinary nonempty `nav` selection returns canonical encoding of the declared terminal; parent offsets, skipped siblings, sentinels and descriptor text after the selected component have weaker validation. | Tested (differential) | [Tests & scope](claim-evidence.md#c37) |
| C38 | \* Nonempty navigation parses the descriptor along the path: each step validates the components it passes and the one it enters, through that component's delimiter, before reading that step's data, and malformed syntax there raises `InvalidTypeDescriptor`; text after the selected component is not read and cannot change the result. Up front, an array-of-tuples descriptor is parsed whole and a tuple descriptor's opening parenthesis must close at its last byte. Subject to arithmetic/resource limits. | Tested (unit) | [Tests & scope](claim-evidence.md#c38) |
| C39 | Navigation supports finite recursive tuples and arrays when intermediate arithmetic, gas, stack and memory suffice. | Partially tested (unit) | [Tests & scope](claim-evidence.md#c39) |
| C40 | `LEN` (`int256.min`) as last entry returns the decoded length: element count, or byte length for string/bytes | Formally verified | [Proof & scope](claim-evidence.md#c40) |
| C41 | `LEN` rejects static values and empty prefixes. For unsupported dynamic tuples/fixed arrays, a truncated selected word can fail before `InvalidNavigation`. | Tested (differential) | [Tests & scope](claim-evidence.md#c41) |
| C42 | `LEN` checks padded bytes or array heads fit; it does not validate array tails, narrow element ranges or byte padding contents. | Formally verified | [Proof & scope](claim-evidence.md#c42) |
| C43 | `PAYLOAD` (`int256.min + 1`) returns the raw string/bytes payload, exact length, unpadded; an outer nav re-enters it | Formally verified | [Proof & scope](claim-evidence.md#c43) |
| C44 | `PAYLOAD` accepts only bytes/string after a nonempty prefix; other terminal kinds raise `InvalidNavigation` before reading a length. | Tested (differential) | [Tests & scope](claim-evidence.md#c44) |
| C45 | A `PAYLOAD` length overrunning the data reverts `ReturnDataOutOfBounds`; nothing past the data is read | Formally verified | [Proof & scope](claim-evidence.md#c45) |
| C46 | Nonfinal LEN/PAYLOAD sentinels undergo ordinary navigation checks and cannot select a valid element. | Partially verified | [Proof & scope](claim-evidence.md#c46) |
| C47 | Navigation may fail on checked arithmetic or exhausted gas/stack/memory; no unconditional no-panic or no-exhaustion guarantee applies. | Tested (unit) | [Tests & scope](claim-evidence.md#c47) |
| C48 | `chain`: `start` resolves to a clean address; each non-final hop returns the next target in its first word; the final returndata passes through raw | Formally verified | [Proof & scope](claim-evidence.md#c48) |
| C49 | `chain` dirty address words revert `InvalidAddressWord` (0 for start, hop index + 1 mid-chain) | Formally verified | [Proof & scope](claim-evidence.md#c49) |
| C50 | `chain` with empty `calls` reverts `EmptyCallChain` | Formally verified | [Proof & scope](claim-evidence.md#c50) |
| C51 | A mid-chain hop returning under 32 bytes reverts `ReturnDataOutOfBounds` | Formally verified | [Proof & scope](claim-evidence.md#c51) |
| C52 | A failing hop reverts `CallFailed(target, hopCalldata)`, identifying the exact hop; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#c52) |
| C53 | `read` sends `selector ++` each segment's full resolved bytes, in order, to the resolved target and returns raw returndata | Formally verified | [Proof & scope](claim-evidence.md#c53) |
| C54 | `read`, `get` and `chain` require a clean target word: dirty upper bytes revert `InvalidAddressWord(0, word)` | Formally verified | [Proof & scope](claim-evidence.md#c54) |
| C55 | `read`/`get` revert `CallFailed` on a code-less target or a reverting constructed call; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#c55) |
| C56 | `read`/`get` name operands as target 0 and args at index + 1 | Formally verified | [Proof & scope](claim-evidence.md#c56) |
| C57 | The destination sees the core as `msg.sender` (`read`, `get`, `chain`) | Partially verified | [Proof & scope](claim-evidence.md#c57) |
| C58 | `get` constructs canonical ABI arguments from the declared descriptor and resolved component values; unknown names retain unrestricted-word semantics. | Formally verified | [Proof & scope](claim-evidence.md#c58) |
| C59 | `get` reverts with codec errors naming the argument (`ComponentCountMismatch`, `InvalidComponentEnvelope`, `InvalidComponentLength`, `InvalidComponentValue`) and `InvalidTypeDescriptor` | Partially verified | [Proof & scope](claim-evidence.md#c59) |
| C60 | `get` with `"()"` and no args calls the bare selector | Formally verified | [Proof & scope](claim-evidence.md#c60) |
| C62 | `cond` is lazy: the losing branch is never resolved | Formally verified | [Proof & scope](claim-evidence.md#c62) |
| C63 | `cond` truth is the first word nonzero; under 32 bytes reverts `ReturnDataOutOfBounds(0,len)` | Formally verified | [Proof & scope](claim-evidence.md#c63) |
| C64 | The winning branch is resolved with its constraints and returned byte-identically | Formally verified | [Proof & scope](claim-evidence.md#c64) |
| C65 | A violated condition constraint reverts the whole `cond`; operands are 0 (condition), 1 (then), 2 (else) | Formally verified | [Proof & scope](claim-evidence.md#c65) |
| C66 | `orElse` returns the attempt on success or resolves the fallback on an ordinary failure; exhaustion classification propagates `SubcallOutOfGas`. | Tested (unit) | [Tests & scope](claim-evidence.md#c66) |
| C67 | The fallback resolves in-frame, its failures propagate, and it is operand 1 | Formally verified | [Proof & scope](claim-evidence.md#c67) |
| C68 | `orElse(a, orElse(b, c))` tries sources in order; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#c68) |
| C69 | Failed calls classify reserved exact four-byte `SubcallOutOfGas` or remaining gas <= gasBefore/63 as exhaustion. The marker is unauthenticated, near-exhausting reverts may be refused, and external targets can hide failures. | Tested (unit) | [Tests & scope](claim-evidence.md#c69) |
| C70 | `isValid` reports successful resolution and constraints, not returned boolean truth; ordinary failure yields 0, exhaustion classification propagates. | Tested (unit) | [Tests & scope](claim-evidence.md#c70) |
| C71 | `isValid(revertData(a,selector))` reflects the probe rules, including zero-selector/code-less acceptance and the exhaustion exception. | Formally verified | [Proof & scope](claim-evidence.md#c71) |
| C72 | `revertData`: zero selector returns the whole revert data; a nonzero one must match and is stripped; mismatch or under 4 bytes reverts `UnexpectedRevertData(expected, actual or 0)`; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#c72) |
| C73 | `revertData` over a succeeding call reverts `DidNotRevert(target, callData)` | Formally verified | [Proof & scope](claim-evidence.md#c73) |
| C74 | `revertData` refuses a non-STATIC_CALL operand (`RevertProbeNotACall(fetcherType)`) and a constrained one (`RevertProbeConstrained(count)`) | Partially verified | [Proof & scope](claim-evidence.md#c74) |
| C75 | `revertData` on a code-less target: zero selector returns empty data, a nonzero one reverts `UnexpectedRevertData(sel, 0)` | Formally verified | [Proof & scope](claim-evidence.md#c75) |
| C76 | `revertData` calls in-frame so the direct target's revert reason survives; a nested core primitive reports the core's own error; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#c76) |
| C77 | Core failures may be declared errors, ABI-decoder bare reverts, checked panics or resource failures; selector-bearing failures are not universal. | Tested (unit) | [Tests & scope](claim-evidence.md#c77) |
| C78 | The core has only view entrypoints, no storage writes, no payable entrypoint and no authorization or fund-management logic. | Tested (unit) | [Tests & scope](claim-evidence.md#c78) |
| C79 | Deployed bytecode fits EIP-170 (24,576 bytes) | Tested (unit) | [Tests & scope](claim-evidence.md#c79) |
| C81 | An empty `assertBatch` succeeds | Tested (unit) | [Tests & scope](claim-evidence.md#c81) |
| C82 | An unconstrained RAW_BYTES operand may be empty and still pass `assertParam` | Tested (unit) | [Tests & scope](claim-evidence.md#c82) |
| C83 | A constructed batch call must succeed, but all its returndata is discarded, including encoded `false` | Tested (unit) | [Tests & scope](claim-evidence.md#c83) |
| C84 | `isValid` reports successful resolution and inline constraints, not boolean truth of the returned value | Tested (unit) | [Tests & scope](claim-evidence.md#c84) |

## ABI codec

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| A1 | Descriptors use nonempty `[a-z0-9]+` names/tuples and dynamic or positive fixed-array suffixes, subject to parser arithmetic/resource bounds. | Partially verified | [Proof & scope](claim-evidence.md#a1) |
| A2 | `bytes` and `string` are the only dynamic base names; `T[]` and any tuple with a dynamic component are dynamic; every other name is one 32-byte word | Formally verified | [Proof & scope](claim-evidence.md#a2) |
| A3 | Head footprint in words: 1 for a dynamic type, component sum for a static tuple, k times element footprint for a static `T[k]` | Formally verified | [Proof & scope](claim-evidence.md#a3) |
| A4 | Fixed lengths and static fixed-array footprints are at most `2^32-1`; bare tuple widths sum their components separately. | Formally verified | [Proof & scope](claim-evidence.md#a4) |
| A5 | InvalidTypeDescriptor for an oversized length is raised "at the length" (the closing bracket, or the digit that crosses the bound) | Formally verified | [Proof & scope](claim-evidence.md#a5) |
| A6 | `T[0]` is refused (as solc refuses to declare it), including `[00]` and `T[0]` nested inside a tuple; a leading zero before a nonzero digit is still a length | Formally verified | [Proof & scope](claim-evidence.md#a6) |
| A7 | Every supported canonical value spans at least one ABI word; zero-width descriptors are rejected. | Formally verified | [Proof & scope](claim-evidence.md#a7) |
| A8 | Malformed descriptors ordinarily raise `InvalidTypeDescriptor`; checked arithmetic and resource failures remain possible. | Partially verified | [Proof & scope](claim-evidence.md#a8) |
| A9 | Codec traversal requires representable cursors and adequate execution resources; no unlimited-input no-panic guarantee applies. | Tested (fuzz) | [Tests & scope](claim-evidence.md#a9) |
| A10 | Static words are held to their base name's range as solc's decoder does: uintN/address/bool high bits clear, intN sign-extended, bytesN/function low bits clear | Partially verified | [Proof & scope](claim-evidence.md#a10) |
| A11 | The 256-bit names and names that are not well-formed narrow ABI types (`uint7`, `uint08`, `int1000`, `bytes0`, `foo`) admit every word | Formally verified | [Proof & scope](claim-evidence.md#a11) |
| A12 | Range checks apply on every path: static elements of arrays, static components of dynamic tuples, static tuples nested in static tuples, fixed arrays (every copy), tuple components, words inside dynamic components | Partially verified | [Proof & scope](claim-evidence.md#a12) |
| A13 | Canonical single-value encoding is the bare static footprint or `[0x20][body]` for a dynamic value, with tight offsets, clean padding and in-range words. | Partially verified | [Proof & scope](claim-evidence.md#a13) |
| A14 | Offsets must be tight: every offset points exactly where the previous tail ended | Partially verified | [Proof & scope](claim-evidence.md#a14) |
| A15 | bytes/string padding must be zero; a dirty padding byte reverts InvalidValue at that byte | Partially verified | [Proof & scope](claim-evidence.md#a15) |
| A16 | Encoded lengths/counts are bounded before stride multiplication; descriptor/cursor arithmetic still requires representability. | Partially verified | [Proof & scope](claim-evidence.md#a16) |
| A17 | Trailing bytes after the last tail are rejected (InvalidValue at their offset) | Partially verified | [Proof & scope](claim-evidence.md#a17) |
| A18 | `packArray`/`pack` returns the canonical `abi.encode(T[])` of the values | Formally verified | [Proof & scope](claim-evidence.md#a18) |
| A19 | `unpack` validates an encoded array and returns canonical elements; `pack` reconstructs the same canonical array under the codec size bounds. | Partially verified | [Proof & scope](claim-evidence.md#a19) |
| A20 | `tupleLayout` requires a nonempty parenthesized tuple. Call constructors separately accept `()` with no arguments. | Partially verified | [Proof & scope](claim-evidence.md#a20) |
| A21 | `tuple(t, args)` is the canonical ABI encoding of the tuple: static components copied verbatim, dynamic envelopes stripped with the true offset written, verbatim splicing correct at any nesting depth | Tested (differential) | [Tests & scope](claim-evidence.md#a21) |
| A22 | ComponentCountMismatch when `args.length` differs from the component count | Tested (fuzz) | [Tests & scope](claim-evidence.md#a22) |
| A23 | InvalidComponentLength(index, expected, actual) when a static component is not exactly its head footprint | Tested (fuzz) | [Tests & scope](claim-evidence.md#a23) |
| A24 | InvalidComponentEnvelope(index, length, head) when a dynamic component is shorter than two words, unaligned, or not headed by 0x20 | Tested (fuzz) | [Tests & scope](claim-evidence.md#a24) |
| A25 | InvalidComponentValue(index, offset) for a malformed body or an out-of-range static word inside a component, with the codec's error rerouted through the caller's context | Formally verified | [Proof & scope](claim-evidence.md#a25) |
| A26 | Codec error offsets identify a word start, dirty padding byte or expected consumed end, depending on the failed check. | Formally verified | [Proof & scope](claim-evidence.md#a26) |
| A27 | InvalidCallbackResult routing: a Collections callback result not canonical for its declared type reverts InvalidCallbackResult(operation, index, other, target) via the Context | Partially verified | [Proof & scope](claim-evidence.md#a27) |
| A28 | Canonical values of supported descriptors are accepted within the codec arithmetic and execution-resource bounds. | Partially verified | [Proof & scope](claim-evidence.md#a28) |
| A29 | A shape-compatible but semantically wrong descriptor can reinterpret a value without rejection. | Tested (unit) | [Tests & scope](claim-evidence.md#a29) |
| A34 | All four production contracts import AbiCodec; imported-source metadata changes affect their deployment bytecode. | Tested (unit) | [Tests & scope](claim-evidence.md#a34) |

## ERC-8211 wire format

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| W1 | ConstraintType IDs are EQ=0, GTE=1, LTE=2, IN=3, GTE_SIGNED=4, LTE_SIGNED=5, OR=6, SKIP=7, IN_SIGNED=8, identical to the Biconomy reference | Formally verified | [Proof & scope](claim-evidence.md#w1) |
| W2 | The shared structs/enums use the ERC-8211 ABI wire layout; compatible predicate encodings decode without a private format extension. | Tested (differential) | [Tests & scope](claim-evidence.md#w2) |
| W3 | InputParamType TARGET=0, VALUE=1, CALL_DATA=2; InputParamFetcherType RAW_BYTES=0, STATIC_CALL=1, BALANCE=2; OutputParamFetcherType EXEC_RESULT=0, STATIC_CALL=1 | Tested (unit) | [Tests & scope](claim-evidence.md#w3) |
| W4 | Constraint i checks complete resolved word i (positional semantics) | Formally verified | [Proof & scope](claim-evidence.md#w4) |
| W5 | The same positions apply to STATIC_CALL and BALANCE fetchers; a BALANCE value is one word, so `[GTE(lo), LTE(hi)]` checks two words and reverts on a balance (use one IN for a scalar range) | Tested (differential) | [Tests & scope](claim-evidence.md#w5) |
| W6 | Constrained positions are raw ABI words: a dynamic return starts with its offset, not its contents | Tested (differential) | [Tests & scope](claim-evidence.md#w6) |
| W7 | Every constraint needs a complete word, SKIP included | Formally verified | [Proof & scope](claim-evidence.md#w7) |
| W8 | All word bounds are checked before any predicate is evaluated (short data reverts `ReturnDataOutOfBounds(words, length)` even when an earlier predicate would fail) | Formally verified | [Proof & scope](claim-evidence.md#w8) |
| W9 | EQ compares raw words; GTE and LTE compare unsigned; each takes exactly one 32-byte reference word | Formally verified | [Proof & scope](claim-evidence.md#w9) |
| W10 | GTE_SIGNED / LTE_SIGNED reinterpret complete words as int256; signed constraints are supported at the wire boundary (the SDK may still lower through Operations) | Formally verified | [Proof & scope](claim-evidence.md#w10) |
| W11 | IN and IN_SIGNED are inclusive ranges over `abi.encode(lo, hi)` (unsigned / signed) | Formally verified | [Proof & scope](claim-evidence.md#w11) |
| W12 | A range whose lower bound exceeds its upper bound (under its signedness) reverts `InvalidConstraintRange(entry, param, constraint)` | Formally verified | [Proof & scope](claim-evidence.md#w12) |
| W13 | SKIP takes empty referenceData and leaves its word unconstrained; a SKIP payload reverts `InvalidConstraintData` | Formally verified | [Proof & scope](claim-evidence.md#w13) |
| W14 | Reference lengths are exact: 32 bytes for EQ/GTE/LTE/signed leaves, 64 for ranges, 0 for SKIP; anything else reverts `InvalidConstraintData(entry, param, constraint, length)` | Partially verified | [Proof & scope](claim-evidence.md#w14) |
| W15 | Deliberate stricter rejection: IN / IN_SIGNED require exactly 64 bytes where Biconomy's decoder tolerates trailing bytes | Tested (differential) | [Tests & scope](claim-evidence.md#w15) |
| W16 | Constraint acceptance preserves the reference predicate rules, with stricter exact range lengths and view-mode routing restrictions. | Formally verified | [Proof & scope](claim-evidence.md#w16) |
| W17 | Canonical predicate constraints use the reference positional comparison, OR and SKIP rules. | Partially verified | [Proof & scope](claim-evidence.md#w17) |
| W18 | OR (6) carries `abi.encode(Constraint[])` of non-OR leaves and passes when at least one leaf matches the same word | Formally verified | [Proof & scope](claim-evidence.md#w18) |
| W19 | An empty OR reverts `InvalidOrConstraint(entry, param, constraint)` | Tested (differential) | [Tests & scope](claim-evidence.md#w19) |
| W20 | A nested OR is rejected wherever it sits, before short-circuiting, even after a matching leaf | Formally verified | [Proof & scope](claim-evidence.md#w20) |
| W21 | Non-OR leaves are evaluated in order and short-circuit on the first match (a malformed leaf before a match rejects; one after a match is never examined) | Formally verified | [Proof & scope](claim-evidence.md#w21) |
| W22 | Malformed OR `referenceData` can produce ABI-decoder bare reverts; decoder allocation panics and resource failures remain possible. | Tested (unit) | [Tests & scope](claim-evidence.md#w22) |
| W23 | An out-of-range ConstraintType (9..255) is never accepted and reverts without data | Partially verified | [Proof & scope](claim-evidence.md#w23) |
| W24 | `ConstraintFailed` carries the assertion message, entry index, param index, constraint index, constraint kind, the actual word at that index and the reference data echoed as given | Partially verified | [Proof & scope](claim-evidence.md#w24) |
| W25 | Every judge function has a custom-message overload whose message is reported in `ConstraintFailed`; the message is `""` when the constraint sits on a primitive's operand | Formally verified | [Proof & scope](claim-evidence.md#w25) |
| W26 | `InvalidConstraintData`, `InvalidOrConstraint` and `InvalidConstraintRange` identify the entry, operand and outer constraint (word) index | Formally verified | [Proof & scope](claim-evidence.md#w26) |
| W27 | Assertions does not implement `IComposableExecution`: the judge is a view function over the same encoding, not a payable executor | Tested (unit) | [Tests & scope](claim-evidence.md#w27) |
| W28 | A predicate check encoded as an ERC-8211 predicate entry (no TARGET) passes through `assertBatch` unchanged and is judged as `assertParam` judges it | Formally verified | [Proof & scope](claim-evidence.md#w28) |
| W29 | Constraints on primitive operands (`resolve`, graph Resolve nodes, etc.) use the same positional semantics as the judge | Formally verified | [Proof & scope](claim-evidence.md#w29) |
| W30 | The reference-oracle fixture is pinned bytecode; fixture identity does not establish current public-chain code availability. | Tested (unit) | [Tests & scope](claim-evidence.md#w30) |

## Operations

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| O1 | `add`/`sub`/`mul` (uint256 and int256) are checked: overflow or underflow reverts with Panic(0x11) | Tested (differential) | [Tests & scope](claim-evidence.md#o1) |
| O2 | Unsigned `div`/`mod` truncate; zero divisor reverts with Panic(0x12) | Tested (differential) | [Tests & scope](claim-evidence.md#o2) |
| O3 | Signed `div` truncates toward zero, `type(int256).min / -1` reverts Panic(0x11); signed `mod` takes the dividend's sign | Tested (differential) | [Tests & scope](claim-evidence.md#o3) |
| O4 | Unsigned `exp` is checked `**` with `0 ** 0 == 1` | Tested (differential) | [Tests & scope](claim-evidence.md#o4) |
| O5 | Signed-base exponentiation checks every selected multiplication/square; success equals the integer power and intermediate overflow raises Panic(0x11). | Tested (differential) | [Tests & scope](claim-evidence.md#o5) |
| O6 | `min`/`max` for both overloads (signed ordering on int256) | Tested (differential) | [Tests & scope](claim-evidence.md#o6) |
| O7 | `absDiff` is total and never reverts; the int256 overload returns the exact uint256 distance even for int256.min to int256.max | Tested (differential) | [Tests & scope](claim-evidence.md#o7) |
| O8 | Unsigned `mulDiv` uses the full 512-bit product and rounds once per `rounding` (Trunc = Floor, Ceil up); a result past uint256 reverts Panic(0x11) | Tested (differential) | [Tests & scope](claim-evidence.md#o8) |
| O9 | `mulDiv` with a zero denominator reverts Panic(0x12) (both overloads, every rounding) | Partially verified | [Proof & scope](claim-evidence.md#o9) |
| O10 | Signed `mulDiv`: magnitude 512-bit product, Trunc toward zero, Floor toward -inf, Ceil toward +inf, negative denominators and int256.min operands allowed, a rounded result outside int256 reverts Panic(0x11) | Tested (differential) | [Tests & scope](claim-evidence.md#o10) |
| O11 | An out-of-range `Rounding` value is refused by the ABI decoder with a bare revert | Tested (unit) | [Tests & scope](claim-evidence.md#o11) |
| O12 | Unsigned `addMod`/`mulMod` use the full 512-bit sum/product (EVM ADDMOD/MULMOD); zero modulus reverts Panic(0x12) | Tested (differential) | [Tests & scope](claim-evidence.md#o12) |
| O13 | Signed `addMod`/`mulMod`: overflow-free intermediate; the remainder takes the sign of the mathematical sum/product, independent of m's sign | Tested (differential) | [Tests & scope](claim-evidence.md#o13) |
| O14 | Signed `addMod`/`mulMod` support int256.min in every operand; zero modulus reverts Panic(0x12) | Partially verified | [Proof & scope](claim-evidence.md#o14) |
| O15 | Unsigned `powMod` returns the modular power without intermediate power overflow; exponent zero yields `1 % m`, and m=0 raises Panic(0x12). | Tested (differential) | [Tests & scope](claim-evidence.md#o15) |
| O16 | Exponents >= `2^32` try MODEXP; smaller exponents use MULMOD. The threshold is a policy, not a universal gas crossover. | Tested (differential) | [Tests & scope](claim-evidence.md#o16) |
| O17 | Failed or non-32-byte MODEXP replies select the MULMOD fallback. A successful 32-byte reply is trusted to represent the precompile result. | Tested (unit) | [Tests & scope](claim-evidence.md#o17) |
| O18 | Signed-base `powMod(int256,uint256,int256)`: power of abs(a) mod abs(m), negative iff a < 0 and the exponent is odd; modulus sign ignored; int256.min supported | Tested (differential) | [Tests & scope](claim-evidence.md#o18) |
| O19 | Negative modular exponents require an inverse; failure reports the original base/modulus magnitudes, and modulus 1 yields zero. | Tested (differential) | [Tests & scope](claim-evidence.md#o19) |
| O20 | `powMod(int256,int256,int256)`: signed base and signed exponent, sign rule "in either direction", magnitudes coprime for negative exponents | Tested (unit) | [Tests & scope](claim-evidence.md#o20) |
| O21 | `sqrt` is floor(sqrt(x)) via OpenZeppelin Math.sqrt | Tested (differential) | [Tests & scope](claim-evidence.md#o21) |
| O22 | `log2` is floor(log2(x)) (bit length minus one); `LogarithmUndefined(0)` at 0 | Formally verified | [Proof & scope](claim-evidence.md#o22) |
| O23 | `rpow`: fixed-point binary exponentiation rounding down each step; 0^0 is one unit, 0^n is 0; Panic(0x11) on a scaled intermediate past uint256, Panic(0x12) for base 0 | Partially tested (unit) | [Tests & scope](claim-evidence.md#o23) |
| O24 | `rpow`'s final error is not bounded by the number of multiplies: rpow(19, 16, 10) = 276889 vs a single rounding's 288441 | Tested (unit) | [Tests & scope](claim-evidence.md#o24) |
| O26 | `expWad` executes a quantized rational approximation; x<=-42139678854452767551 yields zero, and x>=135305999368893231589 raises Panic(0x11). | Tested (differential) | [Tests & scope](claim-evidence.md#o26) |
| O27 | `lnWad` executes a quantized rational approximation; nonpositive inputs raise `LogarithmUndefined(x)`. | Tested (differential) | [Tests & scope](claim-evidence.md#o27) |
| O28 | Global real-function accuracy, monotonicity, positivity and exp/log inverse-error bounds are not established by the finite-word source specifications. | Scope limitation | [Scope](claim-evidence.md#o28) |
| O29 | `eq`/`ne` (bit-level) and `lt`/`gt`/`le`/`ge` (both overloads) return bool, spliced as a 0/1 word | Tested (differential) | [Tests & scope](claim-evidence.md#o29) |
| O30 | `bitAnd`/`bitOr`/`bitXor`; `bitXor(x, ~0)` is NOT | Tested (differential) | [Tests & scope](claim-evidence.md#o30) |
| O31 | Unsigned shifts follow EVM semantics: shifts >=256 yield zero. | Tested (differential) | [Tests & scope](claim-evidence.md#o31) |
| O32 | `shr(int256,uint256)` is SAR: rounds toward -inf; shifts of 256 or more yield 0 or -1 by sign | Tested (differential) | [Tests & scope](claim-evidence.md#o32) |
| O33 | Sign-extension recipe `shr(int256(shl(x, 256 - bits)), 256 - bits)` re-widens a narrow two's-complement field | Formally verified | [Proof & scope](claim-evidence.md#o33) |
| O34 | `bitSet(mask, index)`: indices past 255 are never set | Tested (differential) | [Tests & scope](claim-evidence.md#o34) |
| O35 | Environment reads return judge-time values: `balance`, `timestamp`, `blockNumber`, `chainId`, `baseFee`, `prevRandao`, `coinbase`, `gasLimit`, `blobBaseFee`, `origin`, `gasPrice` | Tested (unit) | [Tests & scope](claim-evidence.md#o35) |
| O36 | `blockHash(n)`: BLOCKHASH semantics, 0 for the current block, the future and blocks older than 256 | Tested (unit) | [Tests & scope](claim-evidence.md#o36) |
| O37 | `codeHash`: EXTCODEHASH, 0 for a nonexistent account, keccak256("") for an existing code-less account | Tested (unit) | [Tests & scope](claim-evidence.md#o37) |
| O38 | `blobHash(i)`: the versioned hash of blob i, zero when the tx carries none at i | Tested (unit) | [Tests & scope](claim-evidence.md#o38) |
| O39 | `rawCall` is a raw staticcall: no selector, no code-length check, returndata returned as bytes; reaches precompiles | Tested (unit) | [Tests & scope](claim-evidence.md#o39) |
| O40 | `rawCall` to a code-less non-precompile address succeeds with empty returndata | Formally verified | [Proof & scope](claim-evidence.md#o40) |
| O41 | A reverting `rawCall` target reverts `RawCallFailed(target, data)`; the reason is lost; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#o41) |
| O42 | `code(account)` returns the full runtime code; a code-less account yields empty bytes | Formally verified | [Proof & scope](claim-evidence.md#o42) |
| O43 | `concat(parts, delimiter)` joins in order with the delimiter between consecutive parts, preserves empty parts, empty `parts` yields empty bytes | Tested (differential) | [Tests & scope](claim-evidence.md#o43) |
| O44 | `slice(data, start, len)` returns the window or reverts `SliceOutOfBounds(start, len, dataLength)`, including when `start + len` would overflow | Formally verified | [Proof & scope](claim-evidence.md#o44) |
| O45 | `sliceRange` has JS Array.slice semantics (signed, clamped, end exclusive, empty when inverted) and never reverts | Formally verified | [Proof & scope](claim-evidence.md#o45) |
| O46 | `byteAt` is strict: outside -length..length-1 reverts `InvalidByteIndex(index, length)` | Formally verified | [Proof & scope](claim-evidence.md#o46) |
| O47 | `stringSlice`: validates the whole input as UTF-8 first, takes the clamped signed byte range, reverts `InvalidUtf8` at a boundary that splits a code point, empty range returns empty | Partially verified | [Proof & scope](claim-evidence.md#o47) |
| O48 | `stringAt`: returns an ASCII byte; `InvalidByteIndex` out of range; `InvalidUtf8` for any byte of a multi-byte code point; validates the whole string | Formally verified | [Proof & scope](claim-evidence.md#o48) |
| O49 | UTF-8 validation follows the Unicode well-formed table: leads C2-F4, overlong/surrogate/past-U+10FFFF refused at the second byte, bad continuation at itself, truncated at the lead; error at the first offending byte | Partially verified | [Proof & scope](claim-evidence.md#o49) |
| O50 | `byteLen` is the raw byte length; `hash` is keccak256 of the argument | Tested (differential) | [Tests & scope](claim-evidence.md#o50) |
| O51 | \* `hashPairSorted` is keccak256 of the ascending pair, byte-identical to OpenZeppelin MerkleProof's combiner; a `Words` fold over a proof reproduces the root | Tested (unit) | [Tests & scope](claim-evidence.md#o51) |
| O52 | `indexOf` enumerates nonoverlapping matches left-to-right, supports signed occurrence ordinals and returns s.length when absent; empty needles match 0..s.length. | Tested (differential) | [Tests & scope](claim-evidence.md#o52) |
| O53 | For nonempty delimiters, segment j starts after match j-1 (or zero) and ends at match j (or input length); normalize negative j against matchCount+1. | Formally verified | [Proof & scope](claim-evidence.md#o53) |
| O54 | `contains`: true iff the needle occurs; an empty needle always matches, even in empty `s`; total | Tested (differential) | [Tests & scope](claim-evidence.md#o54) |
| O55 | `split`: count + 1 segments on the same enumeration as `indexOf`, empty segments preserved, `EmptyNeedle` for an empty delimiter | Tested (differential) | [Tests & scope](claim-evidence.md#o55) |
| O56 | `replace`: every non-overlapping occurrence replaced; empty `repl` deletes; empty needle reverts `EmptyNeedle` | Tested (differential) | [Tests & scope](claim-evidence.md#o56) |
| O57 | `toLower`/`toUpper` fold ASCII letters only; every other byte (UTF-8 units included) passes through | Tested (differential) | [Tests & scope](claim-evidence.md#o57) |
| O58 | `charset` equals the All-mode byte fold with constant mask, init=1 and accumulator/element windows sharing the byte-argument offset. | Tested (differential) | [Tests & scope](claim-evidence.md#o58) |
| O59 | Byte search compares complete words and masks the remaining tail bytes; it imposes no fixed gas-cost guarantee. | Tested (differential) | [Tests & scope](claim-evidence.md#o59) |
| O60 | Byte/text operations retain their declared validation and overflow errors; sufficiently large inputs or outputs can exhaust resources. | Tested (unit) | [Tests & scope](claim-evidence.md#o60) |
| O61 | `parseUint` is strict: `EmptyNumber` on empty input, `InvalidDecimalDigit(position, char)` outside 0-9, Panic(0x11) past 2^256 - 1, leading zeros accepted | Tested (differential) | [Tests & scope](claim-evidence.md#o61) |
| O62 | `toString(uint256)` renders without leading zeros; `toString(parseUint(s))` normalizes and `parseUint(toString(v)) == v` | Tested (differential) | [Tests & scope](claim-evidence.md#o62) |
| O63 | `parseInt`: optional + or -, `EmptyNumber` on empty input or a bare sign, `InvalidDecimalDigit` elsewhere, Panic(0x11) outside int256, "-2^255" accepted | Tested (unit) | [Tests & scope](claim-evidence.md#o63) |
| O64 | `toString(int256)`: leading minus for negatives, no plus, no leading zeros; int256.min renders correctly | Tested (differential) | [Tests & scope](claim-evidence.md#o64) |
| O65 | `parseUnits` accepts an optional sign, at most one decimal point and at least one digit; precision is <=77 and overflow raises Panic(0x11). | Tested (unit) | [Tests & scope](claim-evidence.md#o65) |
| O66 | `parseUnits` rounds dropped fractional digits: Trunc toward zero, Floor toward -inf, Ceil toward +inf | Partially verified | [Proof & scope](claim-evidence.md#o66) |
| O67 | `parseUnitsUnsigned`: accepts a leading +, rejects - with `InvalidDecimalDigit` at 0 (negative zero included), Panic(0x11) outside uint256 | Tested (unit) | [Tests & scope](claim-evidence.md#o67) |
| O68 | Unsigned `formatUnits` emits canonical decimal text with trimmed fractional zeros; parsing that text at the same precision recovers the value. | Tested (differential) | [Tests & scope](claim-evidence.md#o68) |
| O69 | `formatUnits(int256)`: leading minus, int256.min renders, `InvalidPrecision` above 77 | Tested (fuzz) | [Tests & scope](claim-evidence.md#o69) |
| O70 | `encode(types, values)` is runtime abi.encode from canonical component encodings (static: w * 32 bytes; dynamic: [0x20][tail]), nested dynamics spliced verbatim, returned raw without an envelope | Tested (differential) | [Tests & scope](claim-evidence.md#o70) |
| O71 | `encode` failures: `InvalidTypeDescriptor`, `ComponentCountMismatch`, `InvalidComponentLength`, `InvalidComponentEnvelope`, `InvalidComponentValue(component, offset)` | Tested (differential) | [Tests & scope](claim-evidence.md#o71) |
| O72 | `encodeBytes` returns the same tuple payload inside a bytes envelope | Tested (differential) | [Tests & scope](claim-evidence.md#o72) |
| O73 | `encode`/`encodeBytes` hold static words to their narrow type's range, as solc's decoder does | Formally verified | [Proof & scope](claim-evidence.md#o73) |
| O74 | A dirty word spliced into a typed Operations parameter (e.g. address) fails the callee's ABI decoding and surfaces as `CallFailed` | Formally verified | [Proof & scope](claim-evidence.md#o74) |
| O75 | Operations' own panics (`rpow` base 0, `expWad` overflow, signed magnitude overflow) are byte-identical to the compiler's Panic reverts | Tested (differential) | [Tests & scope](claim-evidence.md#o75) |
| O76 | An Operations call made through the core's `read` IS the composition; judged via a STATIC_CALL at the core | Tested (differential) | [Tests & scope](claim-evidence.md#o76) |
| O79 | Operations' runtime bytecode fits EIP-170 (24,576 bytes) | Tested (unit) | [Tests & scope](claim-evidence.md#o79) |
| O80 | Arithmetic helpers use the configured OpenZeppelin Math dependency; modular powers use their own checked-size precompile path. | Tested (unit) | [Tests & scope](claim-evidence.md#o80) |
| O81 | A string operand's resolved envelope splices into `hash`/`toLower`/`byteLen` so they see the decoded payload | Formally verified | [Proof & scope](claim-evidence.md#o81) |

## Collections

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| L1 | \* A `Words` fold is a left fold: accumulator window rewritten with the running accumulator, element window with each word, final accumulator returned | Formally verified | [Proof & scope](claim-evidence.md#l1) |
| L2 | \* A `Range` fold substitutes the index 0..n-1; a `Bytes` fold substitutes the byte VALUE as a word; a fold handed the argument its domain does not use (a subject for `Range`, a count for `Bytes` or `Words`) reverts `UnusedFoldArgument(domain)` | Formally verified | [Proof & scope](claim-evidence.md#l2) |
| L3 | FoldExit: Full scans all, Any stops at first nonzero accumulator, All at first zero; final accumulator returned either way | Formally verified | [Proof & scope](claim-evidence.md#l3) |
| L4 | Early exit never touches later elements, so a would-revert application past the exit point never happens | Tested (differential) | [Tests & scope](claim-evidence.md#l4) |
| L5 | Window stamping: accumulator first, then element windows in supplied order; element wins over accumulator on overlap, later element windows win on mutual overlap; bytes outside windows stay pristine template | Tested (differential) | [Tests & scope](claim-evidence.md#l5) |
| L6 | Empty fold domain validates template windows, then returns init without inspecting or calling the target | Formally verified | [Proof & scope](claim-evidence.md#l6) |
| L7 | Window offsets must leave room for a 32-byte word (LambdaOffsetOutOfBounds(offset, templateLength)), accumulator window included, checked before any call | Partially verified | [Proof & scope](claim-evidence.md#l7) |
| L8 | A code-less lambda/callback target (precompiles included) reverts InvalidCallbackTarget | Partially verified | [Proof & scope](claim-evidence.md#l8) |
| L9 | Target code is checked lazily: an empty input never touches the target | Partially verified | [Proof & scope](claim-evidence.md#l9) |
| L10 | A lambda revert reverts with CallbackFailed(operation, index, other, target, callData, reason), reason preserved; exhaustion and the exact reserved signal propagate instead (C69) | Partially verified | [Proof & scope](claim-evidence.md#l10) |
| L11 | A word lambda returning other than exactly 32 bytes reverts InvalidCallbackResult(op, index, 0, target) | Partially verified | [Proof & scope](claim-evidence.md#l11) |
| L12 | \* `applyWords` as a filter keeps the ELEMENTS whose lambda returns canonical 1, in order; any result other than 0/1 reverts InvalidCallbackResult | Formally verified | [Proof & scope](claim-evidence.md#l12) |
| L13 | \* `applyWords` as a map returns the lambda's word per element, same word count; empty payload returns empty without touching the target | Formally verified | [Proof & scope](claim-evidence.md#l13) |
| L14 | Every word operation (folds, map/filter, wordIndexOf, reverse, zip, unzip, sort, unique, sum) rejects a non-multiple-of-32 payload with UnalignedWords(length) | Partially verified | [Proof & scope](claim-evidence.md#l14) |
| L15 | iotaWords(n) returns 0, 1, ..., n-1 | Formally verified | [Proof & scope](claim-evidence.md#l15) |
| L16 | `iotaWords` allocates n*32 bytes; multiplication overflow, allocator limits and exhaustion can fail for sufficiently large n. | Tested (unit) | [Tests & scope](claim-evidence.md#l16) |
| L17 | wordIndexOf returns the least matching index, or the word COUNT as not-found sentinel | Formally verified | [Proof & scope](claim-evidence.md#l17) |
| L18 | reverseWords reverses word order | Formally verified | [Proof & scope](claim-evidence.md#l18) |
| L19 | zipWords interleaves a0,b0,a1,b1...; different word counts revert WordCountMismatch(aWords, bWords) | Formally verified | [Proof & scope](claim-evidence.md#l19) |
| L20 | unzipWords lane 0/1 is zipWords' inverse; lane > 1 reverts InvalidLane; odd count leaves the extra word in lane 0 | Formally verified | [Proof & scope](claim-evidence.md#l20) |
| L21 | sortWords returns the payload sorted ascending as UNSIGNED words (a permutation) | Formally verified | [Proof & scope](claim-evidence.md#l21) |
| L22 | Word sorting is stable. Callback sorting has stable ties and global order only for comparisons coherent with a total preorder. | Partially verified | [Proof & scope](claim-evidence.md#l22) |
| L23 | Merge sort uses O(n log n) algorithmic comparisons/moves and O(n) scratch space; callback cost and EVM gas are separate. | Partially tested (unit) | [Tests & scope](claim-evidence.md#l23) |
| L24 | \* Signed sort is the three-node recipe: flip sign bit via applyWords(bitXor), sortWords, flip back | Formally verified | [Proof & scope](claim-evidence.md#l24) |
| L25 | sumWords is the checked sum; overflow reverts Panic(0x11) | Formally verified | [Proof & scope](claim-evidence.md#l25) |
| L26 | \* sumWords equals the `Words` fold with `add` | Formally verified | [Proof & scope](claim-evidence.md#l26) |
| L27 | uniqueWords keeps the first occurrence of each word in original order (ordered=false, O(n^2)) and only drops adjacent duplicates when ordered=true (grouping trusted, not validated) | Formally verified | [Proof & scope](claim-evidence.md#l27) |
| L31 | An out-of-range FoldExit is refused by the ABI decoder with an empty revert | Tested (fuzz) | [Tests & scope](claim-evidence.md#l31) |
| L32 | Collection operations can fail through validation, callback errors, checked arithmetic, allocation or exhaustion; no universal resource-safety guarantee applies. | Tested (fuzz) | [Tests & scope](claim-evidence.md#l32) |
| L33 | Hostile callback modes retain ordinary declared failures; a failed exhausted callback or exact reserved signal raises `SubcallOutOfGas()` before wrapping | Tested (unit) | [Tests & scope](claim-evidence.md#l33) |
| L34 | packArray assembles canonical abi.encode(T[]) from canonical abi.encode(T) elements; unpackArray is its inverse | Tested (differential) | [Tests & scope](claim-evidence.md#l34) |
| L35 | packArray/unpackArray validate the whole input; non-canonical encodings revert AbiCodec InvalidValue at the offending offset | Tested (unit) | [Tests & scope](claim-evidence.md#l35) |
| L37 | Traversals validate visited elements; descriptors and callback preparation are still checked on empty input. | Partially verified | [Proof & scope](claim-evidence.md#l37) |
| L38 | mapValues applies the callback in order and validates each result as canonical outputType (InvalidCallbackResult otherwise) | Formally verified | [Proof & scope](claim-evidence.md#l38) |
| L39 | filterValues keeps the original encodings of matching values, in order | Formally verified | [Proof & scope](claim-evidence.md#l39) |
| L40 | Predicate callbacks must return exactly one word holding canonical 0/1, else InvalidCallbackResult (stricter than core `cond`) | Formally verified | [Proof & scope](claim-evidence.md#l40) |
| L41 | foldValues is a left fold, accumulator in slot `first`, element in `second`; empty input returns `initial`; no early exit | Formally verified | [Proof & scope](claim-evidence.md#l41) |
| L42 | foldValues validates each result as canonical accumulatorType and `initial` too | Formally verified | [Proof & scope](claim-evidence.md#l42) |
| L43 | `sortValues` interprets comparator results as signed words: <=0 selects the left occurrence, >0 the right; successful output preserves all occurrences. | Formally verified | [Proof & scope](claim-evidence.md#l43) |
| L44 | Callback consistency is trusted, not checked; inconsistent answers may change ordering/selection, and failed or invalid replies still revert. | Tested (unit) | [Tests & scope](claim-evidence.md#l44) |
| L45 | `uniqueValues` greedily compares retained values to each candidate. First equality-class representatives require coherent equivalence replies; ordered mode additionally requires grouped classes. | Partially verified | [Proof & scope](claim-evidence.md#l45) |
| L46 | flattenValues concatenates inner arrays in order, one level, validating every element | Formally verified | [Proof & scope](claim-evidence.md#l46) |
| L47 | reverseValues reverses without changing encodings | Formally verified | [Proof & scope](claim-evidence.md#l47) |
| L48 | sliceValues has JavaScript Array.slice semantics (signed, clamped, end exclusive, empty when end <= start) and never reverts on the range | Formally verified | [Proof & scope](claim-evidence.md#l48) |
| L49 | sliceValues validates only the selected elements | Formally verified | [Proof & scope](claim-evidence.md#l49) |
| L50 | indexOfValues returns the first index whose equality callback (element in `first`, needle in `second`) is true, else type(uint256).max; needle validated | Formally verified | [Proof & scope](claim-evidence.md#l50) |
| L51 | anyValues/allValues/findValues: any false and all true on empty; find returns first index or max; each stops at the first decisive element | Formally verified | [Proof & scope](claim-evidence.md#l51) |
| L52 | zipValues pairs element-wise into canonical (leftType,rightType) values; a dynamic side gets the 0x20 envelope, a static pair is bare words; LengthMismatch on unequal lengths | Formally verified | [Proof & scope](claim-evidence.md#l52) |
| L53 | unzipValues is zipValues' inverse; lane > 1 reverts InvalidLane; BOTH sides validated even when the requested lane is well formed; envelope, offsets and exact consumption checked | Formally verified | [Proof & scope](claim-evidence.md#l53) |
| L54 | Callback slots/counts must match a tuple descriptor; malformed syntax raises `InvalidTypeDescriptor`, while structural mismatch raises `InvalidCallback`. | Formally verified | [Proof & scope](claim-evidence.md#l54) |
| L55 | Constant slots validated once up front against their component types; substituted values validated at every binding against the slot type | Formally verified | [Proof & scope](claim-evidence.md#l55) |
| L56 | Calldata is rebuilt per application, so dynamic, variable-length slots (middle slot, string accumulator) are safe | Formally verified | [Proof & scope](claim-evidence.md#l56) |
| L57 | Every lambda/callback application is a staticcall, so callbacks cannot have side effects | Tested (unit) | [Tests & scope](claim-evidence.md#l57) |
| L58 | Expression callbacks: non-empty `expression` makes the call target.evaluateEncoded(expression, boundSlots), selector ignored; Parameter nodes read the bound slots | Formally verified | [Proof & scope](claim-evidence.md#l58) |
| L59 | An expression failure surfaces as NodeCallFailed wrapped inside CallbackFailed; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#l59) |
| L60 | Expression caches last one evaluation/callback invocation; sharing across collection iterations is not implied. | Tested (unit) | [Tests & scope](claim-evidence.md#l60) |
| L61 | The locally declared IExpressions.evaluateEncoded selector matches Expressions' | Tested (unit) | [Tests & scope](claim-evidence.md#l61) |
| L62 | Collections is stateless and view/pure only | Tested (unit) | [Tests & scope](claim-evidence.md#l62) |
| L63 | Collections runtime fits under the EIP-170 limit (and Operations plus Collections together would not) | Tested (unit) | [Tests & scope](claim-evidence.md#l63) |

## Expressions

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| E1 | A reference must point strictly backwards; a forward or self reference reverts `InvalidReference(node, ref)` before evaluation | Formally verified | [Proof & scope](claim-evidence.md#e1) |
| E2 | A Parameter node reads `parameters[index]`; an index past the supplied parameters reverts `InvalidReference(node, index)` | Formally verified | [Proof & scope](claim-evidence.md#e2) |
| E3 | A Parameter whose `data` is not exactly one word reverts `InvalidNode(node)` | Formally verified | [Proof & scope](claim-evidence.md#e3) |
| E4 | A `result` index past the last node reverts `InvalidNode(result)` | Formally verified | [Proof & scope](claim-evidence.md#e4) |
| E5 | Each kind carries an exact reference count (Call >= 1, Select 3, TryOrElse/ProbeCall 2, Wrap/IsValid 1, Literal/Parameter/Resolve 0, Array/Tuple any), else `InvalidNode(node)` | Formally verified | [Proof & scope](claim-evidence.md#e5) |
| E6 | \* ProbeCall calldata must reference a bytes-typed node and validate canonically; malformed Resolve payloads can still revert without data, and `evaluateEncoded` payloads fail as E38 states. | Formally verified | [Proof & scope](claim-evidence.md#e6) |
| E7 | Every node's `valueType` is parsed up front (unreachable nodes included), `InvalidTypeDescriptor` otherwise | Tested (unit) | [Tests & scope](claim-evidence.md#e7) |
| E8 | Every cold evaluated node is validated against valueType before caching; cached values originated from successful validation. | Partially verified | [Proof & scope](claim-evidence.md#e8) |
| E10 | Evaluation is on demand from `result`: only reachable nodes execute | Partially verified | [Proof & scope](claim-evidence.md#e10) |
| E11 | Successful node values are cached; failed guarded attempts discard cache changes, so their work may execute again. | Tested (unit) | [Tests & scope](claim-evidence.md#e11) |
| E12 | Select judges the first word of the condition: nonzero picks `refs[1]`, zero `refs[2]`; a multi-word condition counts only its first word | Formally verified | [Proof & scope](claim-evidence.md#e12) |
| E13 | Only the chosen Select branch executes (lazy) | Formally verified | [Proof & scope](claim-evidence.md#e13) |
| E14 | Successfully validated node values occupy at least one ABI word, so Select can read their first word. | Tested (fuzz) | [Tests & scope](claim-evidence.md#e14) |
| E15 | TryOrElse yields the attempt on success and the fallback on any ordinary failure; IsValid returns abi.encode(success); exhaustion and the exact reserved signal propagate instead (C69) | Partially verified | [Proof & scope](claim-evidence.md#e15) |
| E17 | Values memoized inside a successful guarded attempt are kept for the rest of the evaluation | Tested (unit) | [Tests & scope](claim-evidence.md#e17) |
| E18 | A failed guarded attempt discards its cache changes | Tested (unit) | [Tests & scope](claim-evidence.md#e18) |
| E19 | Only typed internal guarded calls can supply a cache; outside callers fail NotSelf and generic self-targeted guarded calls are forbidden. | Formally verified | [Proof & scope](claim-evidence.md#e19) |
| E20 | Call nodes construct canonical argument tuples and staticcall from Expressions; descriptor validity does not prove external target semantics. | Formally verified | [Proof & scope](claim-evidence.md#e20) |
| E21 | A Call or ProbeCall target word must be a clean address, else `InvalidNode(node)` | Partially verified | [Proof & scope](claim-evidence.md#e21) |
| E22 | A code-less call target reverts `InvalidTarget(node, target)` (Call, Resolve's core, evaluateEncoded self-call) | Partially verified | [Proof & scope](claim-evidence.md#e22) |
| E23 | A reverting node call reverts `NodeCallFailed(node, target, callData, reason)` with the target's reason intact; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#e23) |
| E24 | A Resolve node's value is `core.resolve(InputParam)` on `expression.core`, inline constraints enforced, validated as the node's type | Formally verified | [Proof & scope](claim-evidence.md#e24) |
| E25 | Malformed Resolve node data can produce ABI-decoder bare reverts, allocation panics or resource failures before the core call. | Tested (unit) | [Tests & scope](claim-evidence.md#e25) |
| E26 | ProbeCall: the target must revert (`DidNotRevert(target, callData)`); a nonzero selector must match the reason's first four bytes and is stripped, else `UnexpectedRevertData(expected, actual)` with `actual` zero under four bytes; a zero selector returns the whole reason; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#e26) |
| E27 | A code-less ProbeCall target yields empty bytes with a zero selector and `UnexpectedRevertData(expected, 0)` with a nonzero one | Formally verified | [Proof & scope](claim-evidence.md#e27) |
| E28 | ProbeCall runs in Expressions' own frame, so a dynamic reason survives intact and word-aligned after stripping; an argument-less error yields empty bytes | Formally verified | [Proof & scope](claim-evidence.md#e28) |
| E29 | Expressions' `DidNotRevert`, `UnexpectedRevertData` and local `ICore.resolve` share the core's selectors | Tested (unit) | [Tests & scope](claim-evidence.md#e29) |
| E30 | Wrap yields the referenced value as one bytes envelope, abi.encode(bytes) | Formally verified | [Proof & scope](claim-evidence.md#e30) |
| E31 | An Array node packs its referenced values as a canonical `T[]` of element type `arguments` | Partially verified | [Proof & scope](claim-evidence.md#e31) |
| E32 | A Tuple node assembles one canonical tuple value; a dynamic tuple gets its leading 0x20 offset word | Partially verified | [Proof & scope](claim-evidence.md#e32) |
| E33 | A Call or Tuple node whose value count differs from its descriptor reverts `ComponentCountMismatch` | Formally verified | [Proof & scope](claim-evidence.md#e33) |
| E34 | Empty argument tuples are special-cased for call construction; `()` is not a valid node valueType. | Formally verified | [Proof & scope](claim-evidence.md#e34) |
| E35 | `evaluate` returns the result node's value raw, so an evaluation nests as an operand like the value it computes | Formally verified | [Proof & scope](claim-evidence.md#e35) |
| E36 | \* `evaluateEncoded` forwards an encoded Expression to `evaluate` through a self-call without decoding it, returning the raw result under that call context; the payload is placed after the parameters in the forwarded call, so its offsets cannot reach them and the payload alone determines the graph. | Formally verified | [Proof & scope](claim-evidence.md#e36) |
| E37 | \* A failure inside `evaluateEncoded` surfaces as `NodeCallFailed(0, expressions, callData, reason)` wrapping the inner error, `callData` being the forwarded `evaluate` call, which Collections reports through `CallbackFailed`; exhaustion and the exact reserved signal propagate instead (C69) | Formally verified | [Proof & scope](claim-evidence.md#e37) |
| E38 | \* `evaluateEncoded` validates a payload only where evaluation reads it: one shorter than a word, or whose leading offset is below 32 or past its end, reverts without data; a field evaluation reads and cannot decode fails inside the self-call as `NodeCallFailed` with the decoder's reason (usually empty); and fields evaluation never reads cannot change the result. | Tested (unit) | [Tests & scope](claim-evidence.md#e38) |
| E39 | An out-of-range `Kind` never reaches the code: solc's decoder reverts without data | Tested (unit) | [Tests & scope](claim-evidence.md#e39) |
| E40 | Malformed graphs/payloads can produce declared errors or decoder bare reverts; checked arithmetic and execution-resource failures remain possible. | Tested (unit) | [Tests & scope](claim-evidence.md#e40) |
| E41 | Every evaluate/evaluateEncoded call initializes a fresh cache; traversal callbacks evaluate independently. | Tested (unit) | [Tests & scope](claim-evidence.md#e41) |
| E42 | Each node valueType shape is parsed during admission and reused during validation; recursive canonical validation still walks its contents. | Tested (unit) | [Tests & scope](claim-evidence.md#e42) |
| E46 | Expressions is stateless and view-only | Tested (unit) | [Tests & scope](claim-evidence.md#e46) |
| E47 | Collections reaches Expressions through a local `IExpressions` whose selector matches `evaluateEncoded` | Tested (unit) | [Tests & scope](claim-evidence.md#e47) |
| E48 | Errors identify the node by index (InvalidNode, InvalidReference, InvalidTarget, NodeCallFailed) | Partially verified | [Proof & scope](claim-evidence.md#e48) |
| E49 | Graph/tree value and error equivalence requires history-independent primitive results and guard classification in matching call contexts; call counts and gas need not match. | Tested (unit) | [Tests & scope](claim-evidence.md#e49) |

## Deployment and environment

| ID | Claim | Verification | Evidence |
|---|---|---|---|
| R1 | A release requires compiled artifacts, metadata, CREATE2 predictions, SDK addresses and runtime fixtures to agree; source edits require a coordinated rebuild. | Tested (unit) | [Tests & scope](claim-evidence.md#r1) |
| R2 | Execution requires the configured Cancun-compatible EVM/compiler semantics, supported environmental observations and correct used precompiles. | Environment assumption | [Scope](claim-evidence.md#r2) |
| R3 | A CREATE2 prediction does not establish deployment or matching code on any particular public chain. | Scope limitation | [Scope](claim-evidence.md#r3) |
