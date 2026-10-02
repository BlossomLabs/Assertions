# Claim evidence

Evidence references and limitations for [the functional claims](claims.md). Each recorded run applies to its own source snapshot, assumptions and bounds. File links open the current test source; run records identify the source snapshot that actually ran. A passing test supports its stated coverage, rather than an unrestricted proof of the claim. Some detailed run artifacts are retained locally and excluded from Git.

The evidence records are preserved in [claim-evidence.json](claim-evidence.json).

**Halmos baseline:** [results, source hashes and logs](assertions-2.0-release-checks.json) — 172 passed, 0 failed, 0 incomplete. Separate source and bytecode proof campaigns are excluded.

**Concrete suite:** 602 passed, 0 failed against this source snapshot. See the linked run record.

## C1

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testAtomicityRequiresExecutorToPropagateFailure`; `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol)

**Supporting sources:** `README.md:3`, [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [testAtomicityRequiresExecutorToPropagateFailure](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** The executor example proves rollback of its earlier storage write when it propagates failure, and retained state when it swallows failure. Separate transactions and optional/caught assertions do not guarantee rollback.

## C2

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** `genAssertParam` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (run by `composed expression fuzz` `:913`); unit tests [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Scope and limitations:** TS interpreter oracle compares values and error names

## C3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testFuzzPrimitivesNeverPanic` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) draws paramType 0..2 but asserts only "no panic"; `check_resolveIgnoresParamType` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:219`, `:239-240`

**Test/property definitions:** [check_resolveIgnoresParamType](../contracts/tests/OperandsSymbolic.t.sol), [testFuzzPrimitivesNeverPanic](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** Proved for `resolve`: TARGET, VALUE and CALL_DATA resolve alike (`assertParam` shares `_resolve`)

## C4

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** predicate branch [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (judge fuzz `:1033`); `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:759-760`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol).

## C5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchConstructsTheCall` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `test_assertBatch_constructedCall_reverts_withBuiltCalldata` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:753-759`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Test/property definitions:** [check_batchConstructsTheCall](../contracts/tests/BatchSymbolic.t.sol), [test_assertBatch_constructedCall_reverts_withBuiltCalldata](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** Bounded: one entry, three word params, TARGET at each of 3 positions

## C6

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** target0 branch [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_assertBatch_zeroTarget_skipsCall` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:786`

**Test/property definitions:** [test_assertBatch_zeroTarget_skipsCall](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** Stated only in `@dev`; public docs never mention that a zero target silently turns a call entry into a predicate entry

## C7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchStructuralRefusals` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); compose judge fuzz [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:58-59`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md), [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Test/property definitions:** [check_batchStructuralRefusals](../contracts/tests/BatchSymbolic.t.sol).

**Scope and limitations:** Indices proved at entry 1, param 1 only

## C8

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_C8_DirtyTargetNamesNonzeroIndex`; retained supporting evidence: dirty-target branch [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (name only); `test_assertBatch_dirtyTargetWord` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol) (index 0)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:892-895`, [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_C8_DirtyTargetNamesNonzeroIndex](../contracts/tests/ClaimCoverageEasy.t.sol), [test_assertBatch_dirtyTargetWord](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** Exact InvalidAddressWord index 3 and complete dirty-word payload are asserted for a nonzero TARGET entry.

## C9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `test_assertBatch_secondEntry_reverts_withEntryIndex` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertParam_secondConstraint_reverts_withIndex` `:250`

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md), `AGENTS.md:133-134`

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [test_assertBatch_secondEntry_reverts_withEntryIndex](../contracts/tests/Assertions.t.sol), [test_assertParam_secondConstraint_reverts_withIndex](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** One concrete structure (entry 1, param 1, constraint 0), words symbolic

## C10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertParam_withMessage` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertBatch_withMessage` `:449`; `test_resolve_constraint_holds_and_reverts` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_judgesEchoTheirMessage` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_judgesEchoTheirMessage](../contracts/tests/OperandsSymbolic.t.sol), [test_assertBatch_withMessage](../contracts/tests/Assertions.t.sol), [test_assertParam_withMessage](../contracts/tests/Assertions.t.sol), [test_resolve_constraint_holds_and_reverts](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: custom messages on both overloads, defaults "PARAM" and "COMPOSABLE", and "" on a primitive operand; a planted default change fails it

## C11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertBatch_constructedCall_reverts_withBuiltCalldata` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `check_batchConstructedCallFailure` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_batchConstructedCallFailure](../contracts/tests/OperandsSymbolic.t.sol), [test_assertBatch_constructedCall_reverts_withBuiltCalldata](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** Proved: `CallFailed(target, functionSig ++ operands)` byte for byte for a reverting target, success for a quiet one; dropping the selector fails it

## C12

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** none; enforced by the compiler through `view` on [contracts/Assertions.sol](../contracts/Assertions.sol), `:200`, `:213`, `:222`; `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `README.md:7`, [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes: no SSTORE, TSTORE, LOG, CREATE, CREATE2, SELFDESTRUCT, CALL, CALLCODE or DELEGATECALL in any runtime, and the scan finds STATICCALLs and refuses a CALL or an SSTORE (non-vacuous both ways)

## C13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_isValid_batchAsOperand` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_revertData_batchFailsOnExactConstraint` `:1485`; `check_batchIsAnOperand` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Test/property definitions:** [check_batchIsAnOperand](../contracts/tests/OperandsSymbolic.t.sol), [test_isValid_batchAsOperand](../contracts/tests/CoreReads.t.sol), [test_revertData_batchFailsOnExactConstraint](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: `isValid` over an `assertBatch` self-call is 1 exactly when the batch passes

## C14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_gatherReturnsRawValues` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `test_resolve_rawBytes_passthrough` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_gatherReturnsRawValues](../contracts/tests/ControlSymbolic.t.sol), [test_resolve_rawBytes_passthrough](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Lengths 0, 5, 32, 64

## C15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_staticCallResolvesToReturndata` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:798-799`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), `:20`

**Test/property definitions:** [check_staticCallResolvesToReturndata](../contracts/tests/BatchSymbolic.t.sol).

**Scope and limitations:** Returndata lengths 0, 5, 32, 64

## C16

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_staticCallToEmptyAccountFails` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `test_assertParam_codelessTarget` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Test/property definitions:** [check_staticCallToEmptyAccountFails](../contracts/tests/BatchSymbolic.t.sol), [test_assertParam_codelessTarget](../contracts/tests/Assertions.t.sol).

## C17

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** compose-fuzz leaves [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (name only); `test_assertParam_callReverts` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol) (args)

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_assertParam_callReverts](../contracts/tests/Assertions.t.sol).

## C18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_balanceFetcher` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_balanceFetcher](../contracts/tests/BatchSymbolic.t.sol).

**Scope and limitations:** Primary Halmos lengths 0, 20, 39, 41. The supplemental source proof handles arbitrary lengths; the new EVM oracle also asserts short token-return rejection and first-word normalization of long returns

## C19

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** oracle rule [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts), `composed expression fuzz` `:913`

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md)

## C20

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testReadsAndBatchRejectImpossibleDecoderAllocation`, `testOrRejectsImpossibleDecoderAllocation`, `testFuzzBoundedReadAndBatchSucceed` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); [docs/halmos-checks.json](halmos-checks.json) isolated replay source/results (`test_decoderAllocationFailure0`, `test_decoderAllocationFailure1`, `test_orDecoderAllocationFailure`); retained supporting evidence: `CoreNoPanicTest.call` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) tolerates a bare revert when junk was injected

**Recorded test run:** [results, commands and source hashes](bounded-test-checks.json).

**Supporting sources:** [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md), `AGENTS.md:324-329`

**Test/property definitions:** [testFuzzBoundedReadAndBatchSucceed](../contracts/tests/CoreNoPanic.t.sol), [testOrRejectsImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol), [testReadsAndBatchRejectImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** Canonical bounded read/batch sweeps require selector-bearing non-panic failures; successful read/get and both batch overloads are exercised with uint256 arguments. Exact regressions assert Panic(0x41) from an impossible STATIC_CALL bytes allocation before target execution. Malformed nested ABI payloads do not universally revert without data.

## C21

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** `composed expression fuzz` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_resolve_constraint_holds_and_reverts` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [test_resolve_constraint_holds_and_reverts](../contracts/tests/CoreReads.t.sol).

## C22

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** random self-nested trees [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_selfNesting_*` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Scope and limitations:** Tree depth bounded by the generator

## C23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_gatherReturnsRawValues` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`gather`)

**Test/property definitions:** [check_gatherReturnsRawValues](../contracts/tests/ControlSymbolic.t.sol).

**Scope and limitations:** Two operands, lengths 0, 5, 32, 64

## C24

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `test_gather_resolvesEachOperandOnce` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `test_get_sixLiveStrings_resolveEachOnce` `:104` (`vm.expectCall` counts); `test_gatherResolvesEachOperandOnce`, `test_getResolvesEachArgumentOnce` [contracts/tests/CallCountsAndFallbacks.t.sol](../contracts/tests/CallCountsAndFallbacks.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:534-535`, [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), `:26`, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), `AGENTS.md:50-53`

**Test/property definitions:** [test_gatherResolvesEachOperandOnce](../contracts/tests/CallCountsAndFallbacks.t.sol), [test_gather_resolvesEachOperandOnce](../contracts/tests/CoreExtensions.t.sol), [test_getResolvesEachArgumentOnce](../contracts/tests/CallCountsAndFallbacks.t.sol), [test_get_sixLiveStrings_resolveEachOnce](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Pinned with exact call counts (a symbolic run cannot count calls)

## C25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_gather_constraintNamesOperand` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_gatherNamesByIndex` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_gatherNamesByIndex](../contracts/tests/OperandsSymbolic.t.sol), [test_gather_constraintNamesOperand](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Proved over three operands: the first failing one is named by its list index, otherwise every raw value is returned in order; a planted index bug fails it

## C26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_gather_isCanonicalBytesArrayForGet` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_gatheredValuesFeedGet` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_gatheredValuesFeedGet](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_gather_isCanonicalBytesArrayForGet](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Proved: the target receives exactly selector ++ abi.encode(values) for two symbolic gathered words

## C27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_pickSelectsFullWords` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`pick`, `_rawWord`)

**Test/property definitions:** [check_pickSelectsFullWords](../contracts/tests/ControlSymbolic.t.sol).

**Scope and limitations:** Lengths 0, 32, 63, 96, 128; nine index cases

## C28

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** empty path [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `genNav` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_nav_emptyPath_passthrough` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [test_nav_emptyPath_passthrough](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## C29

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (viem); `testFuzz_nav_staticTuple_exactBytes` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol) (solc); `check_staticTerminals` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `test_nav_staticSpan_rejectsTruncationAndOutOfRange` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_staticTerminals](../contracts/tests/NavSymbolic.t.sol), [testFuzz_nav_staticTuple_exactBytes](../contracts/tests/StaticLenses.t.sol), [test_nav_staticSpan_rejectsTruncationAndOutOfRange](../contracts/tests/StaticLenses.t.sol).

**Scope and limitations:** Halmos retains scalar/truncation cases (lengths 128, 159, 160, 192). The supplemental source theorem covers complete static encodings at arbitrary finite geometry under the recorded assumptions.

## C30

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_staticTerminals` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `check_dynamicArray` `:94` (solc soundness); offsets `test_nav_rejectsOutOfRangeStaticTerminals` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol), `test_nav_rejectsOutOfRangeElementsOfDynamicArrays` `:176`; `check_navReencodedWordsMatchSolc` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol), [check_navReencodedWordsMatchSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_staticTerminals](../contracts/tests/NavSymbolic.t.sol), [test_nav_rejectsOutOfRangeElementsOfDynamicArrays](../contracts/tests/StaticLenses.t.sol), [test_nav_rejectsOutOfRangeStaticTerminals](../contracts/tests/StaticLenses.t.sol).

**Scope and limitations:** Partial: primary Halmos families remain scalar terminals, uint8[] and the listed nested narrow-word geometries. The supplemental caller proof connects all returned static/dynamic values to the independent recursive validator; recursive codec error offsets propagate unchanged, with nested dirty-word error bytes pinned concretely.

## C31

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nav_checksOnlyTheReturnedValue` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol); `check_navSkipsSiblings` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_navSkipsSiblings](../contracts/tests/OperandsSymbolic.t.sol), [test_nav_checksOnlyTheReturnedValue](../contracts/tests/StaticLenses.t.sol).

**Scope and limitations:** Primary Halmos covers selecting one uint8 of two. Source cursor correspondence preserves selective head reads and validates only the returned terminal; an unvisited dirty sibling and a loose parent offset are concrete oracle cases.

## C32

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_bytesValue` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol) (output must re-encode to itself under solc); `test_nav_rejectsDirtyPaddingOfBytesTerminal` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [test_nav_rejectsDirtyPaddingOfBytesTerminal](../contracts/tests/StaticLenses.t.sol).

**Scope and limitations:** Primary Halmos retains byte lengths 0, 1, 31, 32, 33, 64. The source extent theorem proves the exact first dirty byte for arbitrary finite payloads, and 32 bitvector cases verify the actual padding mask.

## C33

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `check_arrayOfBytes` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `stays typed under data corruption` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_reencodeRejectsMalformedNestedOffset` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_arrayOfBytes](../contracts/tests/NavSymbolic.t.sol), [test_nav_reencodeRejectsMalformedNestedOffset](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Primary Halmos covers bytes[] and the corruption fuzzer checks error class. Source correspondence now covers arbitrary finite dynamic nesting, rewrapping and canonical acceptance. Recursive InvalidValue offsets are forwarded from the codec helper receipt; this is not an independent recursive diagnostic-location proof.

## C34

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_dynamicArray` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol).

**Scope and limitations:** Primary Halmos retains offsets 0x20, 0x40, 0x1000, 2^256-1 and counts 0..3 / maximum. Source correspondence covers arbitrary finite counts with checked stride multiplication and zero-copy cursor panic outcomes preserved.

## C35

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (negative array indices), empty arrays `:250-253`; `check_dynamicArray` (0, 1, -1, past end); `test_nav_indexOutOfBounds` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navNegativeTupleIndexCountsComponents` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol), [test_navNegativeTupleIndexCountsComponents](../contracts/tests/MutationGaps.t.sol), [test_nav_indexOutOfBounds](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Source proofs preserve tuple counting, negative-array normalization and exact error arguments/order. The full-width helper can panic for negative index with count 2^255; actual callers establish smaller counts. The all-input model also includes accepted tuple-root array descriptors.

## C36

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** deliberate leaf steps [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_invalidSteps` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navErrorsAtNonzeroPositions` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [test_navErrorsAtNonzeroPositions](../contracts/tests/MutationGaps.t.sol), [test_nav_invalidSteps](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Source cursor/descriptor-span correspondence proves the reported type position for arbitrary finite paths. EVM cases pin nonzero descriptor positions.

## C37

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C37_SelectedTupleArrayValuesAndSkippedSiblingPolicy`; retained supporting evidence: `stays typed under data corruption` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `testNavNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol); hostile offsets in `check_dynamicArray`/`check_bytesValue` (soundness only); `test_navArrayCountNamesItsWord` .. `test_navPayloadBounded` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol), [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [test_C37_SelectedTupleArrayValuesAndSkippedSiblingPolicy](../contracts/tests/ClaimCoverageModerate.t.sol), [test_navArrayCountNamesItsWord](../contracts/tests/MutationGaps.t.sol), [test_navPayloadBounded](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Canonical selected dynamic tuple/array values, selected invalid narrow words, skipped invalid siblings and dirty byte padding are checked. These concrete cases complement retained corruption grids and conditional source correspondence; arithmetic/resource exceptions and weaker parent/sentinel policy remain.

## C38

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C38_DescriptorErrorsPrecedeInvalidData`; retained supporting evidence: `stays typed under descriptor mutation` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_invalidSteps` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navRefusesTrailingDescriptorText` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [test_C38_DescriptorErrorsPrecedeInvalidData](../contracts/tests/ClaimCoverageModerate.t.sol), [test_navRefusesTrailingDescriptorText](../contracts/tests/MutationGaps.t.sol), [test_nav_invalidSteps](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Complete malformed descriptor rejection and exact error positions precede both valid and invalid data. Arithmetic and resource premises remain explicit.

## C39

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C39_FourLevelDynamicArraySelection`; retained supporting evidence: `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (`genType(rng, 2)` under the top tuple); `test_nav_nestedDynamicArrays` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_nav_structArraySteps` `:308`

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [test_C39_FourLevelDynamicArraySelection](../contracts/tests/ClaimCoverageModerate.t.sol), [test_nav_nestedDynamicArrays](../contracts/tests/CoreReads.t.sol), [test_nav_structArraySteps](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Partial: concrete selection now includes four-level dynamic arrays and terminal-array encoding, complementing the older bounded differential shapes. These runtime examples do not establish arbitrary finite nesting. Retained inductive source correspondence has explicit arithmetic and resource premises and has not been rerun here.

## C40

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_dynamicArray`, `check_bytesValue`, `check_arrayOfBytes` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol), `:143`, `:177`; `utf8Len` oracle [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_arrayOfBytes](../contracts/tests/NavSymbolic.t.sol), [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol).

**Scope and limitations:** Source LengthAt and LengthCanonical connect arbitrary canonical byte/array lengths to the mode result; primary Halmos cases remain bounded.

## C41

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** `sentinelExpect` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts), bare `[LEN]` `:226`; `test_nav_staticComposites_keepSentinelRestrictions` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`_navLength`)

**Test/property definitions:** [test_nav_staticComposites_keepSentinelRestrictions](../contracts/tests/StaticLenses.t.sol).

**Scope and limitations:** The source theorem preserves length-read-before-type-rejection order for dynamic fixed arrays and tuples. A concrete truncated-value oracle distinguishes that order from PAYLOAD, which rejects these types before reading.

## C42

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nav_len_requiresPaddedBytesPayload` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_nav_len_rejectsMissingPayloadAndHostileCounts` `:381`; `test_navLengthBounded` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_lenDoesNotTraverseTails` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_lenDoesNotTraverseTails](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_navLengthBounded](../contracts/tests/MutationGaps.t.sol), [test_nav_len_rejectsMissingPayloadAndHostileCounts](../contracts/tests/CoreReads.t.sol), [test_nav_len_requiresPaddedBytesPayload](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Primary Halmos covers two symbolic string[] heads. The source function checks only the rounded byte footprint or array head footprint; neither array tails nor narrow element words are visited. Concrete cases pin both omissions.

## C43

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_bytesValue` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `check_arrayOfBytes` `:177`; `sentinelExpect` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_payload_reentryDynamicContent` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_arrayOfBytes](../contracts/tests/NavSymbolic.t.sol), [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [test_nav_payload_reentryDynamicContent](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** The source theorem returns the exact unpadded byte slice for arbitrary fitting payloads. Existing bounded runtime cases continue to cover outer-nav reentry.

## C44

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts), `:227`; `test_nav_payload_invalidTerminals` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_nav_payloadStillRefusesArraysAndTuples` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [test_nav_payloadStillRefusesArraysAndTuples](../contracts/tests/CoreExtensions.t.sol), [test_nav_payload_invalidTerminals](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Source mode dispatch proves rejection of non-byte terminals before reading their length word, and rejects a bare PAYLOAD before descriptor parsing.

## C45

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nav_payload_lyingLength` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navPayloadBounded` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `test_navPayloadRefusesLengthJustPast` `:762`; `check_lenAndPayloadStayInsideTheData` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_lenAndPayloadStayInsideTheData](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_navPayloadBounded](../contracts/tests/MutationGaps.t.sol), [test_navPayloadRefusesLengthJustPast](../contracts/tests/MutationGaps.t.sol), [test_nav_payload_lyingLength](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Primary Halmos retains lengths 0, 5, 32, 33, 64, 65 and maximum over two words. Source payload bounds/error fields are unbounded in byte length subject to uint256 and memory premises; an actual source boundary mutant fails both proof and EVM oracle.

## C46

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testFuzzBoundedReadsNeverPanic` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) (random paths, no-panic only); `int256.min` guard [contracts/Assertions.sol](../contracts/Assertions.sol); `check_nonterminalSentinels` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (`LEN` and `PAYLOAD` as a tuple component index, as an index into a nested `uint8[]` and into a `bytes[]`, each `ElementIndexOutOfBounds(sentinel, 2)`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_nonterminalSentinels](../contracts/tests/ConstructorsSymbolic.t.sol), [testFuzzBoundedReadsNeverPanic](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** Partial: primary Halmos retains three mid-path positions. Source normalization/count bounds and canonical path induction now cover arbitrary finite paths; nonfinal sentinels go through ordinary navigation failure. The pick primitive remains outside this caller proof.

## C47

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C47_NavigationGasBudgetFailureAndSuccessfulControl`; retained supporting evidence: `testNavNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol) (10M gas per call)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [test_C47_NavigationGasBudgetFailureAndSuccessfulControl](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** The same valid navigation input fails under a 1,000-gas budget and succeeds with 1,000,000 gas. This witnesses resource failure; it does not characterize every possible arithmetic, stack or memory limit.

## C48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_chainHopWordMustBeClean` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol); `genChain` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), `:56`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_chainHopWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol).

**Scope and limitations:** Bounded: two hops

## C49

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_targetWordMustBeClean` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol); `check_chainHopWordMustBeClean` `:176`

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_chainHopWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol), [check_targetWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol).

**Scope and limitations:** Mid-chain index proved at hop 0 (reported 1) only

## C50

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_chain_emptyCalls` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_chainNamesTheHop` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_chainNamesTheHop](../contracts/tests/OperandsSymbolic.t.sol), [test_chain_emptyCalls](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved with the other `chain` outcomes (empty chain case)

## C51

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_chain_midHopEmptyReturn` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_chainNamesTheHop` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_chainNamesTheHop](../contracts/tests/OperandsSymbolic.t.sol), [test_chain_midHopEmptyReturn](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: a start or hop returning five bytes reverts `ReturnDataOutOfBounds(0, 5)`

## C52

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_chain_midHopReverts` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_chainNamesTheHop` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_chainNamesTheHop](../contracts/tests/OperandsSymbolic.t.sol), [test_chain_midHopReverts](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: a reverting or code-less hop reverts `CallFailed` with that hop's target and calldata, and a dirty hop word `InvalidAddressWord` at the next hop's index; a planted wrong hop index fails it

## C53

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `genRead` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_read_*` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_readSendsRawSegmentsInOrder` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), `:70`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_readSendsRawSegmentsInOrder](../contracts/tests/CoreSymbolic.t.sol).

**Scope and limitations:** Proved: over three segments of 0, 5, 32 or 33 bytes with symbolic contents, `read` sends exactly selector ++ segments, raw and in order, as the core, and returns the raw returndata. Longer argument lists are bounded out

## C54

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_targetWordMustBeClean` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:497-498`, `:538-539`, [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_targetWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol).

## C55

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_read_codelessTarget` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_read_constructedCallReverts` `:737`; `test_get_codelessTargetAndDirtyWord` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_readAndGetReportTheirCall` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:546-547`, [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_readAndGetReportTheirCall](../contracts/tests/OperandsSymbolic.t.sol), [test_get_codelessTargetAndDirtyWord](../contracts/tests/CoreExtensions.t.sol), [test_read_codelessTarget](../contracts/tests/CoreReads.t.sol), [test_read_constructedCallReverts](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: code-less and reverting targets revert `CallFailed` with the exact constructed calldata, for `read` and for `get`

## C56

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_read_argConstraint_identifiesOperand` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_get_constraintNamesTheArgument` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_readNamesItsOperands` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:539-541`, [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_readNamesItsOperands](../contracts/tests/OperandsSymbolic.t.sol), [test_get_constraintNamesTheArgument](../contracts/tests/CoreExtensions.t.sol), [test_read_argConstraint_identifiesOperand](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved for `read`: target 0 (dirty word), arguments at index + 1 (first failing constraint), byte for byte; a planted index bug fails it. `get`'s naming stays unit-tested

## C57

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_getStaticArgumentsMatchSolc` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol) and `check_chainHopWordMustBeClean` `:176` (Echo returns its caller); `test_caller_coreForReadAndGet` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** `AGENTS.md:53-55`, [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_chainHopWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol), [check_getStaticArgumentsMatchSolc](../contracts/tests/CoreSymbolic.t.sol), [test_caller_coreForReadAndGet](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Partial: `read` only UNIT

## C58

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_getStaticArgumentsMatchSolc` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol); `check_getDynamicArgumentsMatchSolc` `:76`

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), `AGENTS.md:51-52`

**Test/property definitions:** [check_getDynamicArgumentsMatchSolc](../contracts/tests/CoreSymbolic.t.sol), [check_getStaticArgumentsMatchSolc](../contracts/tests/CoreSymbolic.t.sol).

**Scope and limitations:** Two descriptors: `(uint8,address,bool,bytes4)` and `(uint256,string,uint8[])`

## C59

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_get_componentCountMismatch` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `test_get_valueMustFitItsType` `:160`; `testFuzzBoundedReadsNeverPanic` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); `check_getNamesArgumentsInCodecErrors` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_getNamesArgumentsInCodecErrors](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [testFuzzBoundedReadsNeverPanic](../contracts/tests/CoreNoPanic.t.sol), [test_get_componentCountMismatch](../contracts/tests/CoreExtensions.t.sol), [test_get_valueMustFitItsType](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Partial: Proved over `(uint8,string)`: `ComponentCountMismatch`, `InvalidComponentLength`, `InvalidComponentEnvelope` and `InvalidComponentValue` each name the offending argument InvalidTypeDescriptor through get remains unpinned.

## C60

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_get_emptyDescriptor` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_readAndGetReportTheirCall` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:870-871`

**Test/property definitions:** [check_readAndGetReportTheirCall](../contracts/tests/OperandsSymbolic.t.sol), [test_get_emptyDescriptor](../contracts/tests/CoreExtensions.t.sol).

**Scope and limitations:** Proved: `get` with `"()"` and no arguments sends the bare selector

## C62

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_condIsLazyAndJudgesFirstWord` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `test_cond_losingBranchNeverResolved` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), [website/src/content/docs/docs/evml.md](../website/src/content/docs/docs/evml.md)

**Test/property definitions:** [check_condIsLazyAndJudgesFirstWord](../contracts/tests/ControlSymbolic.t.sol), [test_cond_losingBranchNeverResolved](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Halmos bomb fails by constraint; the unit test uses a reverting call

## C63

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_condIsLazyAndJudgesFirstWord` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md)

**Test/property definitions:** [check_condIsLazyAndJudgesFirstWord](../contracts/tests/ControlSymbolic.t.sol).

**Scope and limitations:** Lengths 0, 31, 32, 64

## C64

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_condIsLazyAndJudgesFirstWord`; `test_cond_dynamicWinnerPassthrough` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_cond_winnerConstraintValidated` `:942`

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md)

**Test/property definitions:** [check_condIsLazyAndJudgesFirstWord](../contracts/tests/ControlSymbolic.t.sol), [test_cond_dynamicWinnerPassthrough](../contracts/tests/CoreReads.t.sol), [test_cond_winnerConstraintValidated](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Word values proved; dynamic winner and winner constraints UNIT

## C65

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_cond_conditionConstraintValidated` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_cond_winnerConstraintValidated` `:942`; `check_condNamesItsOperandsAndIsLazy` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_condNamesItsOperandsAndIsLazy](../contracts/tests/OperandsSymbolic.t.sol), [test_cond_conditionConstraintValidated](../contracts/tests/CoreReads.t.sol), [test_cond_winnerConstraintValidated](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: the condition is operand 0, then 1, else 2, and the branch not chosen is never judged; a planted index bug fails it

## C66

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_C66_C70_ControlFailureMatrix`; retained supporting evidence: `check_orElseAndIsValidAgree` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `genOrElse` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_orElse_revertSelectsFallback` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_orElse_codelessTargetSelectsFallback` `:1003`

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), `:62`, `:72`, [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_orElseAndIsValidAgree](../contracts/tests/ControlSymbolic.t.sol), [test_C66_C70_ControlFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_orElse_codelessTargetSelectsFallback](../contracts/tests/CoreReads.t.sol), [test_orElse_revertSelectsFallback](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** The control matrix distinguishes ordinary failed calls, false results, code-less targets, malformed static-call data, constraint failure and the exact reserved SubcallOutOfGas signal. Existing gas sweeps cover exhaustion.

## C67

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_orElse_fallbackFailurePropagates` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_orElseFallbackIsOperandOne` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_orElseFallbackIsOperandOne](../contracts/tests/OperandsSymbolic.t.sol), [test_orElse_fallbackFailurePropagates](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: the fallback resolves in-frame and its failure is `ConstraintFailed` naming operand 1

## C68

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_orElse_chainedFallbacks` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_orElseChainTriesInOrder` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md)

**Test/property definitions:** [check_orElseChainTriesInOrder](../contracts/tests/OperandsSymbolic.t.sol), [test_orElse_chainedFallbacks](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved over three sources: the first that resolves wins; when none does the outer frame reports the inner orElse as `CallFailed`

## C69

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_directAndRawCallGasSweeps`, `test_wordCallbackGasSweeps`, `test_valueCallbackGasSweeps`, `test_expressionCallbackGasSweeps`, `test_nestedCoreRawCallGasSweeps`, `test_exactSignalSurvivesEveryWrapperAndProbe`, `test_ordinaryErrorsKeepExactWrappers`; existing core/Expressions gas tests

**Supporting sources:** `_rejectOutOfGas` in [contracts/Assertions.sol](../contracts/Assertions.sol), [contracts/Operations.sol](../contracts/Operations.sol), [contracts/Collections.sol](../contracts/Collections.sol), [contracts/Expressions.sol](../contracts/Expressions.sol); [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md)

**Test/property definitions:** [test_directAndRawCallGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_exactSignalSurvivesEveryWrapperAndProbe](../contracts/tests/GasPropagation.t.sol), [test_expressionCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_nestedCoreRawCallGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_ordinaryErrorsKeepExactWrappers](../contracts/tests/GasPropagation.t.sol), [test_valueCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_wordCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol).

**Scope and limitations:** Finite identical 6000-hash workload; 100k–3M gas in 50k steps and 5M success, through all six probes; EQ-zero assertion rejected at 1M and 5M. Removing each of the three new guards kills its regression. Halmos has no concrete gas model. Guarantee requires immediate-call exhaustion detection or preserved reserved signal: arbitrary external targets that hide errors or branch on gas are excluded. Ordinary failures near the exhaustion threshold may conservatively reject. Exact four-byte marker is reserved, not authenticated; trailing bytes remain ordinary errors.

## C70

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_C66_C70_ControlFailureMatrix`; retained supporting evidence: `check_orElseAndIsValidAgree` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `genIsValid` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_isValid_revertingCall` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_isValid_constraintViolation` `:1048`

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_orElseAndIsValidAgree](../contracts/tests/ControlSymbolic.t.sol), [test_C66_C70_ControlFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_isValid_constraintViolation](../contracts/tests/CoreReads.t.sol), [test_isValid_revertingCall](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** The same control matrix verifies ordinary and reserved failure behavior without promising successful calls for hostile targets.

## C71

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_isValid_overRevertData` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_isValidOfRevertDataMatchesTheSelector` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_isValidOfRevertDataMatchesTheSelector](../contracts/tests/OperandsSymbolic.t.sol), [test_isValid_overRevertData](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Proved: 1 exactly when the probed call reverts and, for a nonzero selector, its data (0, 3, 4 or 32 bytes) starts with it

## C72

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataMatchesSelector` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_revertDataMatchesSelector](../contracts/tests/ControlSymbolic.t.sol).

**Scope and limitations:** Lengths 0, 3, 4, 36, 64

## C73

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataRefusals` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:691`, [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_revertDataRefusals](../contracts/tests/ControlSymbolic.t.sol).

## C74

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataRefusals` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:699-700`, [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_revertDataRefusals](../contracts/tests/ControlSymbolic.t.sol).

**Scope and limitations:** Partial: RAW_BYTES and one constraint only; BALANCE operand not covered

## C75

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataRefusals` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`revertData`)

**Test/property definitions:** [check_revertDataRefusals](../contracts/tests/ControlSymbolic.t.sol).

## C76

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataMatchesSelector` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `test_revertData_batchFailsOnExactConstraint` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/core/control.md](../website/src/content/docs/docs/core/control.md), `:110`, `:133`

**Test/property definitions:** [check_revertDataMatchesSelector](../contracts/tests/ControlSymbolic.t.sol), [test_revertData_batchFailsOnExactConstraint](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Nested case UNIT

## C77

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testReadsAndBatchRejectImpossibleDecoderAllocation`, `testOrRejectsImpossibleDecoderAllocation`, `testFuzzBoundedReadAndBatchSucceed` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); [docs/halmos-checks.json](halmos-checks.json) isolated replay source/results (`test_decoderAllocationFailure0`, `test_decoderAllocationFailure1`, `test_orDecoderAllocationFailure`); retained supporting evidence: `testFuzzPrimitivesNeverPanic`, `testFuzzBoundedReadsNeverPanic`, `testFuzzBoundedBatchNeverPanics` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol), `:97`, `:124`

**Recorded test run:** [results, commands and source hashes](bounded-test-checks.json).

**Supporting sources:** `AGENTS.md:323-334`

**Test/property definitions:** [testFuzzBoundedBatchNeverPanics](../contracts/tests/CoreNoPanic.t.sol), [testFuzzBoundedReadAndBatchSucceed](../contracts/tests/CoreNoPanic.t.sol), [testFuzzBoundedReadsNeverPanic](../contracts/tests/CoreNoPanic.t.sol), [testFuzzPrimitivesNeverPanic](../contracts/tests/CoreNoPanic.t.sol), [testOrRejectsImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol), [testReadsAndBatchRejectImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** The full Solidity suite passes after replacing overbroad read/batch fuzz assertions with bounded canonical-input checks. Exact STATIC_CALL and OR regressions assert decoder allocation Panic(0x41); success controls prevent universal rejection from passing. There is no universal selector-bearing or no-panic guarantee. The earlier failing suite remains recorded in [docs/halmos-checks.json](halmos-checks.json).

## C78

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** none; compiler-enforced by the `view` modifiers; `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** `README.md:5`, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), `:69`

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes (see C12)

## C79

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `keeps every production artifact within EIP-170` [test/bytecode-size.test.ts](../test/bytecode-size.test.ts)

**Supporting sources:** `AGENTS.md:384-386`

## C81

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`assertBatch`); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** Empty input acceptance is intentional; it supplies no predicate.

## C82

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`assertParam`, `resolve`); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** Constraints must express the intended predicate; an empty constraint list asserts none.

## C83

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`assertBatch`); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** Add an explicit operand constraint when the returned boolean itself must hold.

## C84

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`isValid`); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** An unconstrained successful call returning false yields 1; ordinary failures yield 0 except C69.

## A1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (token-level recursive-descent reference); descriptor mutation fuzz [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); units [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_tupleLayoutInvalidCharacter` [contracts/tests/TupleLayoutSymbolic.t.sol](../contracts/tests/TupleLayoutSymbolic.t.sol) (every byte outside `[a-z0-9]` and `(),[]` at one position: uppercase, whitespace and non-ASCII included), `check_tupleLayoutMalformed` (stray `)`, trailing text, empty component, missing comma, bare name, `()`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md), AGENTS.md:105-109

**Test/property definitions:** [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [check_tupleLayoutInvalidCharacter](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutMalformed](../contracts/tests/TupleLayoutSymbolic.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (asserts dynamic flag)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol).

**Scope and limitations:** Halmos remains bounded to 4 tokens. The supplemental parser proof covers dynamic flags for arbitrary admissible recursive grammar trees in both directions. Names are erased to Opaque only in the head-shape model; the tuple successor uses the actual narrow-rule whitelist for static traversal.

## A3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol); `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol).

**Scope and limitations:** Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol) (asserts selector on rejection); `testHugeFixedLengthsRevertInvalidTypeDescriptor` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); sweep `testPackNeverPanics`/`testUnpackNeverPanics`/`testNavNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol),47,60

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:120-123, [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [testHugeFixedLengthsRevertInvalidTypeDescriptor](../contracts/tests/AbiCodec.t.sol), [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [testPackNeverPanics](../contracts/tests/NoPanic.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol).

**Scope and limitations:** The source parser characterizes acceptance by admissible grammar trees and matches all reference outcomes, retaining the source rejection order and checked arithmetic panics. Counts and static fixed-array footprints are at most uint32 maximum; bare tuple sums may exceed uint32 but must fit uint256. This is not a universal no-panic or no-resource-failure theorem.

## A5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testHugeFixedLengthsRevertInvalidTypeDescriptor` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (positions 18, 18, 21, 30); `check_oversizedLengthNamesItsDigit` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:121-122, [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_oversizedLengthNamesItsDigit](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [testHugeFixedLengthsRevertInvalidTypeDescriptor](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** Proved for every eleven-digit length: refused right after the digit that carries it past 2^32 - 1, and a zero length at the closing bracket

## A6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (`[0]` token); `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol) (fixedCase 0, leading-zero prefix); `testZeroLengthsRevertInvalidTypeDescriptor` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:123-124, [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [testZeroLengthsRevertInvalidTypeDescriptor](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** The source parser proof excludes zero counts recursively, accepts arbitrarily long leading-zero positive counts within the stated bounds, and matches the exact reference rejection position for zero counts. Concrete tests pin [00] and nested cases. EVM resource qualifications remain.

## A7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** Follows from A3 plus A6 (`check_shapeMatchesReference` reference footprints are always >= 1); `testUnpackNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol) with counts up to 2^256 - 1 over `bytes32[0]` bases

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:123-126

**Related behavioral evidence:** [A3](#a3), [A6](#a6).

**Test/property definitions:** [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol).

**Scope and limitations:** The source parser establishes positive head widths for every successful descriptor parse at arbitrary finite grammar depth; acceptance completeness retains all grammar and arithmetic bounds. No execution at unlimited on-chain depth is promised.

## A8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol); `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (validity agrees, so no unexpected revert); [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (typed errors under mutation); `check_tupleLayoutSpans`, `check_tupleLayoutMalformed`, `check_tupleLayoutInvalidCharacter` [contracts/tests/TupleLayoutSymbolic.t.sol](../contracts/tests/TupleLayoutSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:290-295, [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol), commit cc29dd4

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [check_tupleLayoutInvalidCharacter](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutMalformed](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutSpans](../contracts/tests/TupleLayoutSymbolic.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A9

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** `testPackNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol), `testUnpackNeverPanics` :47, `testNavNeverPanics` :60

**Supporting sources:** [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol), AGENTS.md:293-295

**Test/property definitions:** [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [testPackNeverPanics](../contracts/tests/NoPanic.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol).

**Scope and limitations:** Concrete grid (5 bases x 8 lengths x 8 lengths x tail), not random; no oracle beyond "declared selector".

## A10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (every word, 12 names, oracle solc abi.decode); `check_nameRuleMatchesTable` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (28 names incl. `function`, hand-written ABI table); `testStaticWordsMatchSolcDecoder` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `testFunctionWordsAreLeftAligned` :163; `testBytes3RejectsDirtyWordWithEveryDescriptorPaddingByte` and `testBytes3AcceptsCanonicalWordWithEveryDescriptorPaddingByte` [contracts/tests/AbiWordBoundaries.t.sol](../contracts/tests/AbiWordBoundaries.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:115-119

**Test/property definitions:** [check_nameRuleMatchesTable](../contracts/tests/ParserSymbolic.t.sol), [check_wordMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testBytes3AcceptsCanonicalWordWithEveryDescriptorPaddingByte](../contracts/tests/AbiWordBoundaries.t.sol), [testBytes3RejectsDirtyWordWithEveryDescriptorPaddingByte](../contracts/tests/AbiWordBoundaries.t.sol), [testFunctionWordsAreLeftAligned](../contracts/tests/AbiCodec.t.sol), [testStaticWordsMatchSolcDecoder](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_nameRuleMatchesTable` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol); `testFullWidthAndUnrecognisedNamesAcceptEveryWord` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:119-120

**Test/property definitions:** [check_nameRuleMatchesTable](../contracts/tests/ParserSymbolic.t.sol), [testFullWidthAndUnrecognisedNamesAcceptEveryWord](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** Oracle is a hand-written table (solc cannot decode `uint7`).

## A12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_fixedArrayOfTuplesMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (`(int8,bool)[2]`); `check_encodeMatchesSolc` :166 (`(uint8,bool,address,bytes4)`); `check_unpackNestedMatchesSolc` :202; `testDirtyWordsAreRejectedOnEveryPath` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `testFixedArraysOfTuplesCheckEveryCopy` :246; `test_rangeCheckAfterNestedTupleArray` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), `test_rangeCheckInTwoDigitFixedArray` :87, `test_rangeCheckAfterUnrecognisedName` :551; `check_dynamicTupleWordsMatchSolc` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol) (`(uint8,string)`, `(string,address)`, `(bool,bytes)`, `((address,uint8),string)`), `check_arrayOfNarrowTuplesMatchesSolc` (`(uint8,bool)[]`); `check_nestedFixedTupleCanonical` (`(uint8[2],string)`), `check_nestedFixedArrayCanonical` (`uint8[2][]`) and `check_nestedPayloadLengthBounds` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_nestedCountsAreBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (`(uint8[],string)`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_arrayOfNarrowTuplesMatchesSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_dynamicTupleWordsMatchSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_fixedArrayOfTuplesMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_nestedCountsAreBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_nestedFixedArrayCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedPayloadLengthBounds](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testDirtyWordsAreRejectedOnEveryPath](../contracts/tests/AbiCodec.t.sol), [testFixedArraysOfTuplesCheckEveryCopy](../contracts/tests/AbiCodec.t.sol), [test_rangeCheckAfterNestedTupleArray](../contracts/tests/MutationGaps.t.sol), [test_rangeCheckAfterUnrecognisedName](../contracts/tests/MutationGaps.t.sol), [test_rangeCheckInTwoDigitFixedArray](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol); `check_unpackNestedMatchesSolc` :202 (accept iff solc decodes and re-encodes byte-equal); [test/collection-codec.test.ts](../test/collection-codec.test.ts) (viem fixtures accepted), :51 (malformed rejected); `test_packRejectsStaticValueOfWrongLength` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), `test_packRejectsMalformedDynamicValue` :69; `check_nestedFixedTupleCanonical`, `check_nestedFixedArrayCanonical`, `check_twoStringsCanonical` and `check_nestedPayloadLengthBounds` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol) (accepted exactly when solc decodes AND re-encodes byte-equal); `check_nestedCountsAreBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_nestedCountsAreBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_nestedFixedArrayCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedPayloadLengthBounds](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_wordMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [test_packRejectsMalformedDynamicValue](../contracts/tests/MutationGaps.t.sol), [test_packRejectsStaticValueOfWrongLength](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackNestedMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (inner offset cases 0x20, 0, 0x1f, max); `testEncodingRejectsMalformedNestedValues` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `test_bodyNamesTheBadOffset` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); [test/collection-codec.test.ts](../test/collection-codec.test.ts); `check_nestedFixedTupleCanonical` (string offset 128 over a stale word, top offset 64) and `check_twoStringsCanonical` (second offset 160 over a stale word, second offset 64 pointing back) [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_unpackNamesLooseOffsetsAndTrailingBytes` and `check_validateNamesTheOffendingWord` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (`InvalidValue` at the loose offset's own word)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNamesLooseOffsetsAndTrailingBytes](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_validateNamesTheOffendingWord](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testEncodingRejectsMalformedNestedValues](../contracts/tests/AbiCodec.t.sol), [test_bodyNamesTheBadOffset](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_bodyNamesTheDirtyPaddingByte` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (offset 64+5); `testEncodingRejectsMalformedNestedValues` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (last byte 0x01); [test/collection-codec.test.ts](../test/collection-codec.test.ts); `check_dirtyPaddingNamesItsByte` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_dirtyPaddingNamesItsByte](../contracts/tests/NarrowWordsSymbolic.t.sol), [testEncodingRejectsMalformedNestedValues](../contracts/tests/AbiCodec.t.sol), [test_bodyNamesTheDirtyPaddingByte](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Halmos proves its two-byte string case. The arbitrary-length bytes/string source theorem and all 32 mask obligations are now connected through recursive dynamic callers and Value, TupleComponent and CallbackResult routing. The first dirty byte is preserved by the source padding scan; the combined EVM oracle pins nested/component errors. Translation, memory and resource assumptions remain.

## A16

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackArrayAcceptsOnlyCanonical_uint8` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (length case 2^256 - 1); `testEncodingRejectsOverflowingAndTruncatedLengths` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `test_bodyBoundsElementCount` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), `test_unpackBoundsElementCount` :332, `test_bodyBoundsTupleHead` :340, `test_bodyBoundsPaddedPayloadOnUnalignedValue` :513, `test_bodyBoundsHeadAfterAComponent` :535; `testUnpackNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol); corruption fuzz [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `check_nestedPayloadLengthBounds` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_nestedCountsAreBoundedBeforeMultiplying` and `check_unpackCountIsBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (exact `InvalidValue`, never a Panic, for the maximum count, a count whose `* 32` overflows, a one-past-fit count, and a length that would overflow `n + 31`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_nestedCountsAreBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_nestedPayloadLengthBounds](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackArrayAcceptsOnlyCanonical_uint8](../contracts/tests/AbiCodecSymbolic.t.sol), [check_unpackCountIsBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testEncodingRejectsOverflowingAndTruncatedLengths](../contracts/tests/AbiCodec.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol), [test_bodyBoundsElementCount](../contracts/tests/MutationGaps.t.sol), [test_bodyBoundsHeadAfterAComponent](../contracts/tests/MutationGaps.t.sol), [test_bodyBoundsPaddedPayloadOnUnalignedValue](../contracts/tests/MutationGaps.t.sol), [test_bodyBoundsTupleHead](../contracts/tests/MutationGaps.t.sol), [test_unpackBoundsElementCount](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackNestedMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (count 0 leaves trailing words, must reject); `test_unpackNamesTrailingBytes` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (offset 96); `testEncodingRejectsMalformedNestedValues` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `check_nestedFixedTupleCanonical` and `check_twoStringsCanonical` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol) (trailing-byte geometries); `check_unpackNamesLooseOffsetsAndTrailingBytes` (`unpack` names the trailing byte, 256) and `check_validateNamesTheOffendingWord` (`validate` names the first trailing byte) [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol); [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNamesLooseOffsetsAndTrailingBytes](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_validateNamesTheOffendingWord](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testEncodingRejectsMalformedNestedValues](../contracts/tests/AbiCodec.t.sol), [test_unpackNamesTrailingBytes](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Halmos retains its listed trailing-byte cases. The combined source correspondence includes exact consumption in recursive validate and unpack, preserving validate at 32 + walked extent and unpack at 64 + tail. Concrete trailing-offset tests remain. The older flat uint8[] Halmos property still lacks an explicit exact-length condition because solc alone tolerates trailing bytes; strengthening that runtime oracle is separate from the closed source theorem.

## A18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_packArrayMatchesSolc_uint8` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol), `check_packArrayMatchesSolc_string` :40 (solc abi.encode oracle, must-succeed via staticcall); [test/collection-codec.test.ts](../test/collection-codec.test.ts) (8 nested types vs viem)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_packArrayMatchesSolc_string](../contracts/tests/AbiCodecSymbolic.t.sol), [check_packArrayMatchesSolc_uint8](../contracts/tests/AbiCodecSymbolic.t.sol).

**Scope and limitations:** Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackArrayAcceptsOnlyCanonical_uint8` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (soundness vs solc); `check_unpackNestedMatchesSolc` :202 (soundness and completeness); [test/collection-codec.test.ts](../test/collection-codec.test.ts); `check_unpackUint8ArrayIsComplete` and `check_unpackStringArrayIsComplete` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol), `check_arrayOfNarrowTuplesMatchesSolc`; `check_twoStringsCanonical` (two-element `string[]`, each element re-wrapped in its own envelope) and `check_nestedFixedArrayCanonical` (`uint8[2][]`) [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_unpackCountIsBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), AGENTS.md:127-128

**Test/property definitions:** [check_arrayOfNarrowTuplesMatchesSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_nestedFixedArrayCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackArrayAcceptsOnlyCanonical_uint8](../contracts/tests/AbiCodecSymbolic.t.sol), [check_unpackCountIsBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_unpackStringArrayIsComplete](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_unpackUint8ArrayIsComplete](../contracts/tests/NarrowWordsSymbolic.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** units [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (`test_encode_malformedDescriptor`, positions 0 and 9), [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (`test_encodeRejectsStrayParenthesis`), :541 (`test_tupleRefusesTrailingComponentText`), :775 (`test_tupleNamesTextBetweenComponents`), [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `()` exercised by Expressions call nodes [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_tupleLayoutSpans` [contracts/tests/TupleLayoutSymbolic.t.sol](../contracts/tests/TupleLayoutSymbolic.t.sol) (every pair from an 8-component table against a hand-written span/shape/words table), `check_tupleLayoutMalformed` (stray `)` at 6, trailing text at 7, empty component at 7, missing comma at 6, bare name at 0, `()` at 1); `check_tupleLayoutInvalidCharacter` (every out-of-alphabet byte after `(uint8`, exact position 6)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/Assertions.sol](../contracts/Assertions.sol), [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [check_tupleLayoutInvalidCharacter](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutMalformed](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutSpans](../contracts/tests/TupleLayoutSymbolic.t.sol), [test_encodeRejectsStrayParenthesis](../contracts/tests/MutationGaps.t.sol), [test_encode_malformedDescriptor](../contracts/tests/Operations.t.sol), [test_tupleNamesTextBetweenComponents](../contracts/tests/MutationGaps.t.sol), [test_tupleRefusesTrailingComponentText](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A21

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (viem abi.encode, 300 random tuples up to depth 3 incl. nested dynamics); `check_encodeMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (static 4-tuple); `testEncodingAcceptsWordBoundaryPayloadsAndNestedFixedArrays` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testEncodingAcceptsWordBoundaryPayloadsAndNestedFixedArrays](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A22

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (error name); `test_encode_countMismatch` [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (args 2,1); [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol)

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_encode_countMismatch](../contracts/tests/Operations.t.sol).

**Scope and limitations:** The source-connected tuple wrapper proves the exact expected/actual counts on ComponentCountMismatch. The 24-test construction oracle pins the error arguments. Adequate memory/allocation resources remain an environmental contract.

## A23

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (mode 3); `test_encode_badStaticLength` [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `test_largeRepresentableFixedArrayEncodes` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_encode_badStaticLength](../contracts/tests/Operations.t.sol), [test_largeRepresentableFixedArrayEncodes](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** The source-connected component validator preserves index, required footprint and actual length. The construction oracle pins those fields. Checked words * 32 overflow is modeled explicitly for unusually wide bare tuples; valid tuple layouts establish a representable head before component validation.

## A24

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (all three kinds); `test_encode_badEnvelope` [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol)

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_encode_badEnvelope](../contracts/tests/Operations.t.sol).

**Scope and limitations:** The source-connected component validator proves the exact index, value length and first word (zero when shorter than a word) for envelope rejection. Canonical dynamic values satisfy the precheck. The construction oracle pins short and wrong-header envelopes.

## A25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testEncodingNamesMalformedComponent` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `testDirtyWordsAreRejectedOnEveryPath` :178 (lines 214, 219); `assertRejected` helper :17 over 5 malformed values; `check_invalidComponentValueNamesTheWord` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_invalidComponentValueNamesTheWord](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [testDirtyWordsAreRejectedOnEveryPath](../contracts/tests/AbiCodec.t.sol), [testEncodingNamesMalformedComponent](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** The source component validator and audited context forwarding preserve the component index and failing value offset through arbitrary finite recursive validation. The existing bounded uint8[] proof remains, supplemented by dirty static-word, dynamic-padding and nested-tuple EVM cases. Sufficient resources and the source/memory translation remain explicit assumptions.

## A26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testDirtyWordsAreRejectedOnEveryPath` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (offsets found by sentinel scan); MutationGaps offset tests [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol),87,323,332,340,346,353,513,535,551,559; `check_invalidValueNamesTheWord` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol) ; `check_errorOffsetNamesFirstBadWord`, `check_errorOffsetWithinWordRun` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol) (`InvalidValue`, `requireValue`, `body`, `validateDynamic`)

**Test/property definitions:** [check_errorOffsetNamesFirstBadWord](../contracts/tests/CoreSymbolic.t.sol), [check_errorOffsetWithinWordRun](../contracts/tests/CoreSymbolic.t.sol), [check_invalidValueNamesTheWord](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [testDirtyWordsAreRejectedOnEveryPath](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** The prior static traversal theorem retains exact first-invalid-word offsets and zero-copy arithmetic behavior. The combined source connection derives caller spans, carries the source guard offsets through dynamic recursion and unpack, and proves context routing preserves them for TupleComponent while supplying the specified CallbackResult fields. Parser failures and checked panics remain distinct. No unconditional resource-failure selector guarantee is claimed.

## A27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_mapValidatesResults` [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (every word, exact revert data); `testMalformedResultKeepsCallbackContextWithoutSelfCall` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_mapValidatesResults](../contracts/tests/ValuesSymbolic.t.sol), [testMalformedResultKeepsCallbackContextWithoutSelfCall](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** Partial: Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## A28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_packArrayMatchesSolc_*` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol),40 (must succeed); `check_wordMatchesSolc` :133; `check_unpackNestedMatchesSolc` :202; `testEmptyArraysOfNarrowTypesAreAccepted` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); [test/collection-codec.test.ts](../test/collection-codec.test.ts); [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (encode must succeed)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:249-252, [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_wordMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testEmptyArraysOfNarrowTypesAreAccepted](../contracts/tests/AbiCodec.t.sol).

**Scope and limitations:** Partial: solc/viem runtime comparisons retain their listed families. The combined source theorem proves canonical acceptance against the independent ABI specification at arbitrary finite accepted nesting under the stated arithmetic/resource conditions. The construction oracle adds nested arrays and tuples. Universal compiler/SDK equivalence and unlimited-resource execution are not claimed.

## A29

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_A29_ShapeCompatibleWrongDescriptorReinterpretsWord`

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** AGENTS.md:112-115, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [test_A29_ShapeCompatibleWrongDescriptorReinterpretsWord](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** Nonempty tuple navigation path [0] accepts the int256(-1) encoding as uint256.max under (uint256); the matching (int256) descriptor is a control. This is an example of semantic reinterpretation, not a promise that every wrong descriptor succeeds.

## A34

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-structure.py](../scripts/test-claim-structure.py) `test_A34_imported_comment_changes_metadata_and_bytecode_for_all_four`; discovered through [test/claim-structure.test.ts](../test/claim-structure.test.ts)

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** README.md:12, AGENTS.md:367-369, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), website/src/content/docs/docs/reference/deployments.mdx:45

**Test/property definitions:** [test_A34_imported_comment_changes_metadata_and_bytecode_for_all_four](../scripts/test-claim-structure.py).

**Scope and limitations:** Compiler AST checks all four direct AbiCodec imports. Appending one comment in the in-memory imported source changes metadata and creation/runtime bytecode, while executable bytes remain unchanged. Uses Solidity 0.8.36, optimizer 200 runs and Cancun; does not claim arbitrary edits or hash-collision impossibility. No production source or release artifact is rewritten.

## W1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) and `check_referenceLengths` :75 send raw uint8 IDs to both implementations; [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_wireEnumNumbersMatchReference` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:39-41; [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 76-86; [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), 49-59

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol), [test_wireEnumNumbersMatchReference](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** The unit test compares against hand-written numbers only; the semantic identity of each ID comes from the Biconomy-oracle properties.

## W2

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_W2_MultiEntryTargetWireCrossesReferenceAndCore`; [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_W2_ValueAndOutputWireCrossDecoding`; retained supporting evidence: [contracts/tests/ERC8211ReferenceHarness.sol](../contracts/tests/ERC8211ReferenceHarness.sol) builds a `ComposableExecution` from this repo's structs and Biconomy's `executeComposableDelegateCall` decodes it; `judge` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) and [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) feed identical `InputParam` bytes to both

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); README.md:12; [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [test_W2_MultiEntryTargetWireCrossesReferenceAndCore](../contracts/tests/ClaimCoverageModerate.t.sol), [test_W2_ValueAndOutputWireCrossDecoding](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** Independent uint8 wire structs cross-decode multi-entry TARGET data through both the pinned reference and current core. VALUE/output fields cross-decode; the core returns exact OutputParamsNotSupported(0) and ValueParamNotSupported(0,0) for unsupported wire fields.

## W3

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_W3_NumericWireEnums`; retained supporting evidence: [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts), 69-77 (raw paramType 2 and fetcherType 0/1/2 against Biconomy)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 36-41, 53

**Test/property definitions:** [test_W3_NumericWireEnums](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** All declared ERC-8211 parameter and comparison enums are checked against literal numeric wire values.

## W4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_positionalWords` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_eachConstraintChecksItsOwnWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); `test_matchingFirstWordDoesNotHideWrongSecondWord` :27

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); README.md:3; AGENTS.md:42, 129; [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_positionalWords](../contracts/tests/ERC8211Symbolic.t.sol), [test_eachConstraintChecksItsOwnWord](../contracts/tests/PositionalConstraints.t.sol), [test_matchingFirstWordDoesNotHideWrongSecondWord](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Bounds: two words, two leaf constraints. The unit test also pins the exact `ConstraintFailed` data at index 1.

## W5

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_balanceRejectsSecondConstraint` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Supporting sources:** [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); AGENTS.md:134-135

**Test/property definitions:** [test_balanceRejectsSecondConstraint](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Unit test pins `ReturnDataOutOfBounds(1, 32)`.

## W6

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) ("dynamic offset")

**Supporting sources:** [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Scope and limitations:** One example (a `string` envelope judged `EQ 32`).

## W7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_paramLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_boundsPrecedePredicatesAndSkipNeedsAWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:42; [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_paramLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_boundsPrecedePredicatesAndSkipNeedsAWord](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Bounds: data lengths {0,1,31,32,33,63}, one leaf plus optional SKIP.

## W8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_boundsPrecedePredicatesAndSkipNeedsAWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol) (word 0 fails EQ 0, yet the pinned error is `ReturnDataOutOfBounds(1, 63)`); `check_constraintBoundsComeFirst` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_constraintBoundsComeFirst](../contracts/tests/OperandsSymbolic.t.sol), [test_boundsPrecedePredicatesAndSkipNeedsAWord](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Proved: two constraints over one word revert `ReturnDataOutOfBounds(1, 32)` even when the first would fail; a planted reordering fails it

## W9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (symbolic value and reference); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (boundaries 0, 1, 42, 2^255-1, 2^255, 2^256-1); [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 72; [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol).

**Scope and limitations:** The primary Halmos property uses Biconomy as oracle. The supplemental source proof now checks an independent kind-indexed predicate for all full-width words.

## W10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_orAlternativesCheckTheSameWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), 61; [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md); [website/src/content/docs/docs/evml.md](../website/src/content/docs/docs/evml.md); AGENTS.md:135-138

**Test/property definitions:** [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol), [test_orAlternativesCheckTheSameWord](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** The SDK lowering clause lives in the vendored checkout, out of this repo's evidence.

## W11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (length 64, symbolic bounds); `check_orWithRangeAndSkip` :108; [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (upper bound = value); `test_assertParam_in_success_interior_and_bounds` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_skipAndSignedRange` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 71; [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md), 59; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md); README.md:3

**Test/property definitions:** [check_orWithRangeAndSkip](../contracts/tests/ERC8211Symbolic.t.sol), [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_assertParam_in_success_interior_and_bounds](../contracts/tests/Assertions.t.sol), [test_skipAndSignedRange](../contracts/tests/PositionalConstraints.t.sol).

## W12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** Verdict: `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (inverted symbolic bounds are canonical, so verdicts must match); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts). Error: `test_invalidRangeCannotBeHiddenByLaterOrAlternative` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_invalidRangeCannotBeHiddenByLaterOrAlternative](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** The supplemental source proof preserves the exact typed error for both signednesses; `ConstraintOracleTest.testSignedExtremesAndRanges` asserts exact unsigned and signed range error bytes. The primary parity property remains verdict-only.

## W13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (type 7 over every length); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts), 93; `test_skipRejectsPayload` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md)

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_skipRejectsPayload](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Error identity is UNIT (one payload length, 1).

## W14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (asserts rejection for leaf lengths 0,1,31,33 and a 32-byte range); `test_assertParam_invalidConstraintData_word` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertParam_invalidConstraintData_range` :353; `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); `check_exactReferenceLengths` [contracts/tests/ConstraintCompositionSymbolic.t.sol](../contracts/tests/ConstraintCompositionSymbolic.t.sol) (every non-OR kind at constraint index 1 with reference lengths 0, 1, 31, 32, 33, 64, 65 and 96: exactly the required length is accepted, every other reverts `InvalidConstraintData(0, 0, 1, length)`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [check_exactReferenceLengths](../contracts/tests/ConstraintCompositionSymbolic.t.sol), [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_assertParam_invalidConstraintData_range](../contracts/tests/Assertions.t.sol), [test_assertParam_invalidConstraintData_word](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** Partial: the one-way property against Biconomy remains; the new property asserts rejection directly for every listed length, 64 and 96 for leaves and 32 for ranges included, at a nonzero constraint index. Other indices and lengths beyond 96 are not enumerated; nonzero entry and param indices are the W26 properties.

## W15

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (asserts ours rejects, Biconomy accepts a 96-byte IN); `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (length 96)

**Supporting sources:** AGENTS.md:46-47; [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol).

**Scope and limitations:** The Halmos case only shows the difference is rejection-only; the Node test pins the concrete divergence.

## W16

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `agree` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol), applied in all six `check_*` properties in [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:46-47 ("stricter rejection"); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Scope and limitations:** Within the stated bounds (<=2 constraints, <=3 OR leaves, listed lengths, RAW_BYTES only).

## W17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** All six `check_*` in [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); mutation record [docs/mutation-testing.md](mutation-testing.md), 33 (erc8211-differential in stage 2; all Assertions non-equivalent mutants killed) ; `check_batchMatchesReference` [contracts/tests/BatchDifferentialSymbolic.t.sol](../contracts/tests/BatchDifferentialSymbolic.t.sol); `check_batchSecondConstraintAndOr` [contracts/tests/ConstraintCompositionSymbolic.t.sol](../contracts/tests/ConstraintCompositionSymbolic.t.sol) (two entries, one two-word parameter each, EQ then a two-leaf OR, verdicts equal to the reference over symbolic words)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); README.md:46; AGENTS.md:43-46; [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md), 38

**Test/property definitions:** [check_batchMatchesReference](../contracts/tests/BatchDifferentialSymbolic.t.sol), [check_batchSecondConstraintAndOr](../contracts/tests/ConstraintCompositionSymbolic.t.sol).

**Scope and limitations:** Partial: `assertBatch` predicate batches (two entries, three parameters) now match the reference on verdicts, but each parameter carries one constraint from five fixed cases or, in the new property, EQ then a two-leaf OR on one parameter per entry; OR payloads beyond two leaves are proved only through `assertParam` (at most three leaves), and the comparison with Biconomy is on verdicts only (its errors are its own).

## W18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_orOfWordBranches` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); `check_orWithRangeAndSkip` :108; [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_orAlternativesCheckTheSameWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); AGENTS.md:42, 130-131; README.md:3

**Test/property definitions:** [check_orOfWordBranches](../contracts/tests/ERC8211Symbolic.t.sol), [check_orWithRangeAndSkip](../contracts/tests/ERC8211Symbolic.t.sol), [test_orAlternativesCheckTheSameWord](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Bounds: 1..3 leaves.

## W19

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (asserts rejection); `test_emptyOrRejected` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md)

**Test/property definitions:** [test_emptyOrRejected](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** `check_orOfWordBranches` treats n=0 as non-canonical, so it checks only one direction there and does not prove the rejection.

## W20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_nestedOrRejected` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (asserts ours false, nested first or second); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_nestedOrRejectedEvenAfterMatchingLeaf` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:42-43; [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_nestedOrRejected](../contracts/tests/ERC8211Symbolic.t.sol), [test_nestedOrRejectedEvenAfterMatchingLeaf](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Bounds: two leaves, depth 2.

## W21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_invalidRangeCannotBeHiddenByLaterOrAlternative` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `check_orLeavesShortCircuitInOrder` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_orLeavesShortCircuitInOrder](../contracts/tests/OperandsSymbolic.t.sol), [test_invalidRangeCannotBeHiddenByLaterOrAlternative](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Proved: a malformed leaf after a matching one is never read, one before it rejects the OR with `InvalidConstraintData`; removing the short-circuit fails it

## W22

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testReadsAndBatchRejectImpossibleDecoderAllocation`, `testOrRejectsImpossibleDecoderAllocation`, `testFuzzBoundedReadAndBatchSucceed` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); [docs/halmos-checks.json](halmos-checks.json) isolated replay source/results (`test_decoderAllocationFailure0`, `test_decoderAllocationFailure1`, `test_orDecoderAllocationFailure`); retained supporting evidence: [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (both reject `0x01`, verdict only); `testFuzzPrimitivesNeverPanic` / `testFuzzBoundedBatchNeverPanics` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol), 124 inject junk OR payloads (:190-199) and TOLERATE a bare revert (:229)

**Recorded test run:** [results, commands and source hashes](bounded-test-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:324-329

**Test/property definitions:** [testFuzzBoundedBatchNeverPanics](../contracts/tests/CoreNoPanic.t.sol), [testFuzzBoundedReadAndBatchSucceed](../contracts/tests/CoreNoPanic.t.sol), [testFuzzPrimitivesNeverPanic](../contracts/tests/CoreNoPanic.t.sol), [testOrRejectsImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol), [testReadsAndBatchRejectImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** The retained ConstraintOracle test pins a bare revert for OR payload 0x01. The replacement OR regression asserts exact Panic(0x41) for an impossible Constraint[] allocation. General decoder error-byte equivalence with the reference is not asserted.

## W23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** Raw uint8 types 9..255 in `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol), `check_referenceLengths` :75, `check_positionalWords` :133; [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) (kind 9 injected)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** AGENTS.md:325-327; [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol)

**Test/property definitions:** [check_positionalWords](../contracts/tests/ERC8211Symbolic.t.sol), [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol).

**Scope and limitations:** Partial: proved only as "never accepted where Biconomy rejects"; no assertion that Assertions itself rejects, and the empty revert data is tolerated, not asserted.

## W24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol) (exact revert data, symbolic actual and reference, entry 1 param 1); [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol), 250, 403, 423; `test_matchingFirstWordDoesNotHideWrongSecondWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); `check_batchSecondConstraintAndOr` [contracts/tests/ConstraintCompositionSymbolic.t.sol](../contracts/tests/ConstraintCompositionSymbolic.t.sol) (exact first-failure payload: index 1 with kind OR echoing the whole OR payload, or index 0 with EQ, at entry 0 or 1) and `check_exactReferenceLengths` (exact leaf failure at constraint index 1 for every non-OR kind)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); AGENTS.md:133-134; [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md); [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [check_batchSecondConstraintAndOr](../contracts/tests/ConstraintCompositionSymbolic.t.sol), [check_exactReferenceLengths](../contracts/tests/ConstraintCompositionSymbolic.t.sol), [test_matchingFirstWordDoesNotHideWrongSecondWord](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Partial: Halmos now covers EQ at constraint 0, every non-OR kind at constraint 1 and a failing OR at constraint 1 (referenceData = the whole OR payload echoed) in a two-entry batch, in first-failure order across entries; param indices beyond 0 remain the BatchSymbolic case.

## W25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertParam_withMessage` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertBatch_withMessage` :449; `""` pinned at [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol), 795, 915, 934 and [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_judgesEchoTheirMessage` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md); [website/src/content/docs/docs/reference/core.md](../website/src/content/docs/docs/reference/core.md); [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_judgesEchoTheirMessage](../contracts/tests/OperandsSymbolic.t.sol), [test_assertBatch_withMessage](../contracts/tests/Assertions.t.sol), [test_assertParam_withMessage](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** Proved with C10

## W26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol), 84, 91, 101; [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol), 354; `check_primitiveConstraintsArePositional` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol); check_batchIsItsPartsInOrder [contracts/tests/BatchDifferentialSymbolic.t.sol](../contracts/tests/BatchDifferentialSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:133

**Test/property definitions:** [check_batchIsItsPartsInOrder](../contracts/tests/BatchDifferentialSymbolic.t.sol), [check_primitiveConstraintsArePositional](../contracts/tests/OperandsSymbolic.t.sol).

**Scope and limitations:** Proved: a malformed constraint names entry, operand and its own index (1 here), and batch errors carry the entry and operand position

## W27

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-structure.py](../scripts/test-claim-structure.py) `test_W27_judge_uses_execution_encoding_without_payable_executor_interface`; discovered through [test/claim-structure.test.ts](../test/claim-structure.test.ts)

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [test_W27_judge_uses_execution_encoding_without_payable_executor_interface](../scripts/test-claim-structure.py).

**Scope and limitations:** Compiled ABI checks both assertBatch overloads are view and use the same execution tuple components as the payable reference executor. Assertions has no executeComposable, payable function, receive or fallback entry.

## W28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertBatch_predicate_success` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertBatch_predicate_reverts` :385; `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `check_batchIsItsPartsInOrder` [contracts/tests/BatchDifferentialSymbolic.t.sol](../contracts/tests/BatchDifferentialSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** README.md:46; [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md); [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [check_batchIsItsPartsInOrder](../contracts/tests/BatchDifferentialSymbolic.t.sol), [test_assertBatch_predicate_reverts](../contracts/tests/Assertions.t.sol), [test_assertBatch_predicate_success](../contracts/tests/Assertions.t.sol).

**Scope and limitations:** A batch of three parameters over two entries passes exactly when `assertParam` passes on each, and otherwise reverts with the first failing parameter's error relabeled to its position (`"COMPOSABLE"`, entry, param), revert data included. Bounded: one constraint per parameter from five cases with distinct outcomes; planted bugs (skipping an entry, a wrong parameter index, the wrong label) all fail it.

## W29

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_expressionGraphResolvesNewConstraintKinds` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol) (SKIP + IN_SIGNED through an Expressions Resolve node); ConstraintFailed cases in [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_primitiveConstraintsArePositional` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/core/reads.md](../website/src/content/docs/docs/core/reads.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_primitiveConstraintsArePositional](../contracts/tests/OperandsSymbolic.t.sol), [test_expressionGraphResolvesNewConstraintKinds](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Proved on `resolve`: `[SKIP, EQ]` over two words judges only the second, and failures name constraint index 1

## W30

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-coverage-structure.py](../scripts/test-claim-coverage-structure.py) `test_W30_inlined_runtime_matches_pinned_fixture_bytes_and_hash_field`; [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) `test_inlinedRuntimeMatchesPinnedFixture`; retained supporting evidence: `test_inlinedRuntimeMatchesPinnedFixture` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); hash check [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_referenceRunsUnderFoundry` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); fixture metadata [test/fixtures/biconomy-erc8211.json](../test/fixtures/biconomy-erc8211.json) (Base 8453, fetched 2026-09-22)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** AGENTS.md:46, 254-257

**Test/property definitions:** [test_W30_inlined_runtime_matches_pinned_fixture_bytes_and_hash_field](../scripts/test-claim-coverage-structure.py), [test_inlinedRuntimeMatchesPinnedFixture](../contracts/tests/ERC8211Symbolic.t.sol), [test_referenceRunsUnderFoundry](../contracts/tests/ERC8211Symbolic.t.sol).

**Scope and limitations:** Fresh byte-for-byte/hash-field comparison and the compiled runtime hash test establish the pinned offline fixture identity. No present public-chain code availability is asserted.

## O1

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts), [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (BigInt oracle, exact Panic code decoded); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_add_and_overflow, :104 test_sub_and_underflow

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_add_and_overflow](../contracts/tests/Operations.t.sol), [test_sub_and_underflow](../contracts/tests/Operations.t.sol).

**Scope and limitations:** 100 runs per overload, operand pools biased to 0, powers of two/ten, 2^256-1, int256 min/max

## O2

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_mul_div_mod

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_mul_div_mod](../contracts/tests/Operations.t.sol).

## O3

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (oracle models min/-1 explicitly; BigInt `%` has dividend sign); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_div_mod_signed_truncation, :128 test_div_signed_minByMinusOne

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_div_mod_signed_truncation](../contracts/tests/Operations.t.sol), [test_div_signed_minByMinusOne](../contracts/tests/Operations.t.sol).

## O4

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) expRef, :250; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_exp

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_exp](../contracts/tests/Operations.t.sol).

## O5

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (full-width int256 base, uint256 exponent); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) test_signedPower ((-2)^255 == int256.min)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_signedPower](../contracts/tests/OperationsNumeric.t.sol).

## O6

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts), :299-300; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_minMax

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md)

**Test/property definitions:** [test_minMax](../contracts/tests/Operations.t.sol).

## O7

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts), :301 (genI draws int256.min/max 20% of the time); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_absDiff

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md), :181; [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md)

**Test/property definitions:** [test_absDiff](../contracts/tests/Operations.t.sol).

## O8

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) roundedMulDivRef, :254-255 (all three modes, full-width operands); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_mulDiv, :173 test_mulDivCeil

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md)

**Test/property definitions:** [test_mulDiv](../contracts/tests/Operations.t.sol), [test_mulDivCeil](../contracts/tests/Operations.t.sol).

## O9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol) check_mulDivZeroDenominatorPanics (symbolic a, b, rounding 0..2, exact revert bytes); [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :316-318; [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_mulDivZeroDenominatorPanics](../contracts/tests/OperationsSymbolic.t.sol).

**Scope and limitations:** Partial: the Halmos property is the unsigned overload only; the signed overload's zero-denominator case is one unit case ([contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol)) plus rare fuzz draws

## O10

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (full-width int256 incl. int256.min, all modes, BigInt oracle); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) testFuzz_signedRounding (int128 operands, native oracle), :49 test_signedMulDivBoundaries, :64 test_signedRoundingOverflowAfterTruncationFits

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [testFuzz_signedRounding](../contracts/tests/OperationsNumeric.t.sol), [test_signedMulDivBoundaries](../contracts/tests/OperationsNumeric.t.sol), [test_signedRoundingOverflowAfterTruncationFits](../contracts/tests/OperationsNumeric.t.sol).

## O11

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O11_AllInvalidRoundingValuesAcrossMulDivOverloads`; retained supporting evidence: [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol), :170-172 (rounding > 2 must revert with empty data)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:311-312

**Test/property definitions:** [test_O11_AllInvalidRoundingValuesAcrossMulDivOverloads](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Every invalid raw rounding value 3 through 255 is tested across both mulDiv overloads for the exact empty decoder revert. Valid rounding behavior retains its existing evidence.

## O12

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_addMod_mulMod

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_addMod_mulMod](../contracts/tests/Operations.t.sol).

## O13

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O13_FullWidthIndependentPythonRemainders`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) testFuzz_signedMod (int128 a, b; full int256 m; native Solidity `%` oracle); :10 test_signedModBoundaries; [test/signed-mod.test.ts](../test/signed-mod.test.ts)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [testFuzz_signedMod](../contracts/tests/OperationsNumeric.t.sol), [test_O13_FullWidthIndependentPythonRemainders](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O13_FullWidthIndependentPythonRemainders](../scripts/generate-claim-coverage-vectors.py), [test_signedModBoundaries](../contracts/tests/OperationsNumeric.t.sol).

**Scope and limitations:** Fresh seeded full-width Python arbitrary-precision remainder vectors exercise signed sums/products independently of Solidity intermediate overflow. They complement the retained 11,096-call BigInt run at its own source snapshot; general nonzero-result bytecode proofs remain incomplete.

## O14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol) check_signedModAtIntMin (no revert when a or m is int256.min, b fixed to 1 or 0); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol), :31 test_signedModZero; [test/signed-mod.test.ts](../test/signed-mod.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :374-375; [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [check_signedModAtIntMin](../contracts/tests/OperationsSymbolic.t.sol), [test_signedModZero](../contracts/tests/OperationsNumeric.t.sol).

**Scope and limitations:** Partial: Halmos proves non-reversion with b in {0, 1}; the full-domain mathematical and bytecode claims are not established by this release evidence.

## O15

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol) testFuzz_powModFullWidth (independent square-and-multiply reference at :78), :115 testFuzz_powModSmall (repeated-multiply reference), :10 test_powMod, :41 test_powModFailures

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`powMod(uint256,uint256,uint256)`, `_powMod`)

**Test/property definitions:** [testFuzz_powModFullWidth](../contracts/tests/OperationsModular.t.sol), [testFuzz_powModSmall](../contracts/tests/OperationsModular.t.sol), [test_powMod](../contracts/tests/OperationsModular.t.sol), [test_powModFailures](../contracts/tests/OperationsModular.t.sol).

**Scope and limitations:** Oracle is an independent Solidity loop, not in the Node fuzzers

## O16

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol) test_powModPrecompileThreshold, :104 testFuzz_powModAroundThreshold

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`POW_MOD_PRECOMPILE_THRESHOLD`, `_powMod`)

**Test/property definitions:** [testFuzz_powModAroundThreshold](../contracts/tests/OperationsModular.t.sol), [test_powModPrecompileThreshold](../contracts/tests/OperationsModular.t.sol).

## O17

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_O17_ModexpAcceptsExactlyOneWordAndFallsBackOtherwise`

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1398-1400, :1415; [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); AGENTS.md:380-383

**Test/property definitions:** [test_O17_ModexpAcceptsExactlyOneWordAndFallsBackOtherwise](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** All four public overloads exercise failed, empty, 1-byte, 31-byte and 64-byte MODEXP replies using Foundry call mocks. An intentionally incorrect successful 32-byte sentinel confirms interception and that the result is trusted. The fallback is checked against an independent modular-period example; this does not verify a real precompile implementation or gas availability.

## O18

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O18_FullWidthSignedBasePowers`; retained supporting evidence: [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol) testFuzz_powModSmall (negated a <= 255, e <= 255, m < 2^128), :25 test_powModWordBoundaries, :98-99

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [testFuzz_powModSmall](../contracts/tests/OperationsModular.t.sol), [test_O18_FullWidthSignedBasePowers](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O18_FullWidthSignedBasePowers](../scripts/generate-claim-coverage-vectors.py), [test_powModWordBoundaries](../contracts/tests/OperationsModular.t.sol).

**Scope and limitations:** Fresh full-width signed-base power vectors use Python arbitrary-precision modular exponentiation and independent sign handling. These are finite behavioral checks under the used precompile environment.

## O19

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O19_FullWidthNegativeExponents`; retained supporting evidence: [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol) testFuzz_inverseFullWidth (full-width a, m; independent Euclid gcd; checks a * inv == 1 mod m and exact error args); :14-19, :28-38, :41; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`ModularInverseDoesNotExist`, `_inverseMod`, signed-exponent `powMod` overloads)

**Test/property definitions:** [testFuzz_inverseFullWidth](../contracts/tests/OperationsModular.t.sol), [test_O19_FullWidthNegativeExponents](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O19_FullWidthNegativeExponents](../scripts/generate-claim-coverage-vectors.py).

**Scope and limitations:** Fresh Python inverse-power vectors cover signed and unsigned overloads, modulus one, zero/noncoprime bases, zero-modulus errors, signed minimum and exact NonInvertible errors. Environment and finite-input scope remain.

## O20

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol), :22, :30-38, :45

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Scope and limitations:** About ten examples

## O21

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) isqrt, :269-284 (perfect squares and neighbors); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_sqrt

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md)

**Test/property definitions:** [test_sqrt](../contracts/tests/Operations.t.sol).

## O22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_log2, :281 test_log2_rejectsZero; `check_log2IsTheExactFloor` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol) (added after the snapshot: every word, `2^r <= x < 2^(r+1)`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :557-569; [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_log2IsTheExactFloor](../contracts/tests/OperationsSymbolic.t.sol), [test_log2](../contracts/tests/Operations.t.sol), [test_log2_rejectsZero](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved for every word: `x >> log2(x) == 1` and `LogarithmUndefined(0)` at zero

## O23

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_O23_RpowExactIntegerPowersAndStepRounding`; retained supporting evidence: [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (mirror oracle plus independent exact-value bound), :123-141 rpowRef; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :227, :246, :251; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_O23_RpowExactIntegerPowersAndStepRounding](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** Partial: independent exact powers at unit scale (x 0..7, exponents 0..12), selected decimal step-rounding traces, zero identities and exact overflow/division panics supplement the mirrored oracle. General fixed-point step-rounding correctness for arbitrary operands remains beyond these finite examples.

## O24

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_rpow_roundingLossCanExceedMultiplicationCount

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_rpow_roundingLossCanExceedMultiplicationCount](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Exactly the documented example

## O26

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O26_GeneratedFiniteWordKernelAndExactErrors`; retained supporting evidence: [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) test_expWadMatchesReference (17 points vs 80-digit references, 1e-19 relative + 1 wei), :405 test_expWadUnderflowsToZero; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_expWad_overflowPanics

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_O26_GeneratedFiniteWordKernelAndExactErrors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_expWadMatchesReference](../contracts/tests/MutationGaps.t.sol), [test_expWadUnderflowsToZero](../contracts/tests/MutationGaps.t.sol), [test_expWad_overflowPanics](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Seeded finite-word kernel vectors come from the independent rational Horner oracle, covering range-reduction boundaries and exact errors. They test the quantized kernel, not global real exponential accuracy, monotonicity or inverse-error bounds.

## O27

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O27_GeneratedFiniteWordKernelAndExactErrors`; retained supporting evidence: [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) test_lnWadMatchesReference (12 points within 1 wei); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_lnWad_rejectsNonPositive

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_O27_GeneratedFiniteWordKernelAndExactErrors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_lnWadMatchesReference](../contracts/tests/MutationGaps.t.sol), [test_lnWad_rejectsNonPositive](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Seeded finite-word logarithm kernel vectors and exact errors come from the independent rational Horner oracle. They test the quantized kernel, not global analytic accuracy guarantees.

## O28

**Recorded evidence:** LIMITATION / DOCUMENTED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol); [scripts/claim-coverage-fixed-point-oracle.py](../scripts/claim-coverage-fixed-point-oracle.py)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`expWad`, `lnWad`)

**Scope and limitations:** The finite-word oracle tests do not establish global real-function accuracy, positivity, monotonicity or inverse-error bounds.

## O29

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (return word compared to exactly 0/1); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :297

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md)

## O30

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_bitwise

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_bitwise](../contracts/tests/Operations.t.sol).

## O31

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (shift amounts 0..300 and full width); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_shifts

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :667-679; [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_shifts](../contracts/tests/Operations.t.sol).

## O32

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (BigInt arithmetic shift, clamped); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_shr_signed

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_shr_signed](../contracts/tests/Operations.t.sol).

## O33

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (one int16 case); `check_signExtensionRecipe` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [check_signExtensionRecipe](../contracts/tests/OperationsSymbolic.t.sol).

**Scope and limitations:** Proved for every word and every width from 8 to 248 bits against an independent mask-and-fill reference

## O34

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_bitSet

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_bitSet](../contracts/tests/Operations.t.sol).

## O35

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :355, :363, :385 (also judged through the core), :408

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md); [website/src/content/docs/docs/solidity.md](../website/src/content/docs/docs/solidity.md)

**Scope and limitations:** Thin wrappers over opcodes

## O36

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_blockHash

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_blockHash](../contracts/tests/Operations.t.sol).

## O37

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O37_FundedCodeLessAccount`; retained supporting evidence: [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_codeHash (contract and nonexistent)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_O37_FundedCodeLessAccount](../contracts/tests/ClaimCoverageEasy.t.sol), [test_codeHash](../contracts/tests/Operations.t.sol).

**Scope and limitations:** A nonexistent account is funded and remains code-less: extcodehash changes from zero to the empty-code hash.

## O38

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/forge-only/BlobContext.sol](../scripts/forge-only/BlobContext.sol) `test_O38_InjectedBlobHashesAndOutOfRangeIndices`; retained supporting evidence: [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_blobHash (zero path only; the test notes EDR cannot synthesize a blob tx)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [test_O38_InjectedBlobHashesAndOutOfRangeIndices](../scripts/forge-only/BlobContext.sol), [test_blobHash](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Forge-injected versioned blob hashes cover three nonzero indices, out-of-range indices and an empty context. This tests the opcode wrapper with injected context; it does not validate acceptance/execution of a real blob transaction by a public chain.

## O39

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (sha256), :902 (ecrecover), :910 (identity)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

## O40

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_rawCall_codelessTargetSucceedsEmpty; `check_rawCallToCodelessAddressIsEmpty` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_rawCallToCodelessAddressIsEmpty](../contracts/tests/OperationsSymbolic.t.sol), [test_rawCall_codelessTargetSucceedsEmpty](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved for a code-less non-precompile address and any one-word calldata

## O41

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_rawCall_revertWrapped (exact error bytes); `check_rawCallRevertNamesTheCall` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :827-830; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_rawCallRevertNamesTheCall](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_rawCall_revertWrapped](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved: `RawCallFailed(target, data)` for any one-word calldata; a planted wrong target fails it

## O42

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_code; `check_codeReturnsTheRuntime` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_codeReturnsTheRuntime](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_code](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved: the full runtime of a deployed account, empty for a code-less one

## O43

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_concat

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [test_concat](../contracts/tests/Operations.t.sol).

**Scope and limitations:** "Allocates once" ([website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)) is an implementation remark, not tested

## O44

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_sliceBounds (symbolic out-of-range and literal boundary indices, exact bytes); [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (MAXU starts/lengths); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :897-906; [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_sliceBounds](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Scope and limitations:** Halmos bounds: bytes lengths 0,1,31,32,33,64,65

## O45

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_sliceRangeClamps

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_sliceRangeClamps](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Scope and limitations:** In-range indices are literal boundaries only (symbolic offsets are out of reach)

## O46

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_byteAtStrict; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :920-929; [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_byteAtStrict](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

## O47

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_stringSliceOverValidText; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :737 test_stringSliceClampsFarNegativeStart

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_stringSliceOverValidText](../contracts/tests/OperationsNoPanicSymbolic.t.sol), [test_stringSliceClampsFarNegativeStart](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: proved over a fixed set of concrete valid texts; the "validate first, even for an empty range" ordering on invalid input is unit only

## O48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_stringAtOverValidText; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) test_stringAtValidatesTheWholeString

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_stringAtOverValidText](../contracts/tests/OperationsNoPanicSymbolic.t.sol), [test_stringAtValidatesTheWholeString](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Over concrete valid texts

## O49

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :454, :466, :719; [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_utf8ValidatorNeverPanics (<= 4 symbolic bytes, declared errors only); `check_utf8MatchesTheUnicodeTable` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1461-1491; [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_utf8MatchesTheUnicodeTable](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [check_utf8ValidatorNeverPanics](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Scope and limitations:** Partial: Proved for every string of one to four bytes against the Unicode well-formed table written out independently (307 paths); loosening the E0 overlong bound fails it

## O50

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md), :79

## O51

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O51_OpenZeppelinCombinerAndFoldProof`; retained supporting evidence: [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (viem keccak of sorted concat, a == b 15%); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :944 test_merkleVerify_viaFoldWords

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [test_O51_OpenZeppelinCombinerAndFoldProof](../contracts/tests/ClaimCoverageEasy.t.sol), [test_merkleVerify_viaFoldWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** OpenZeppelin MerkleProof.processProof is the independent combiner oracle; both child orders and a multi-step fold match its result.

## O52

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) indexOfRef, :389-399 (ordinals incl. int256 min/max); [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_indexOfEmptyNeedle; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :473

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`indexOf`)

**Test/property definitions:** [check_indexOfEmptyNeedle](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Scope and limitations:** Empty-needle branch is PROVED

## O53

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_splitRecipe; `check_splitMatchesItsRecipe` [contracts/tests/SlotsSplitSymbolic.t.sol](../contracts/tests/SlotsSplitSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`indexOf`, `slice`, `split`)

**Test/property definitions:** [check_splitMatchesItsRecipe](../contracts/tests/SlotsSplitSymbolic.t.sol), [test_splitRecipe](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved over four symbolic bytes and a one-byte delimiter: part count, first part and last part agree with `indexOf` and `slice`; a shifted last part fails it

## O54

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :720-721

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

## O55

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) splitRef, :415-428; [contracts/tests/OperationsCollections.t.sol](../contracts/tests/OperationsCollections.t.sol), :25, :36

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

## O56

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) replaceRef, :430-447; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :1182, :1197

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

## O57

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

## O58

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (parity with the fold on one input)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`charset`); [contracts/Collections.sol](../contracts/Collections.sol) (`foldBytes`, `_stampWindows`)

## O59

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_O59_WordAndMaskedTailBoundariesAgainstByteOracle`; retained supporting evidence: correctness: [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (needles up to 70 bytes, near-miss last byte); cost: [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol) testFuzzBoundedSearchResults (10M gas budget per call); `testFuzzBoundedSearchResults`, `testBoundedSearchMaximumExpansionSucceeds`, `testReplacementExpansionExhaustsBudget` [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol) ([docs/bounded-test-checks.json](bounded-test-checks.json) current run)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); AGENTS.md:307-308

**Test/property definitions:** [testBoundedSearchMaximumExpansionSucceeds](../contracts/tests/OperationsNoPanic.t.sol), [testFuzzBoundedSearchResults](../contracts/tests/OperationsNoPanic.t.sol), [testReplacementExpansionExhaustsBudget](../contracts/tests/OperationsNoPanic.t.sol), [test_O59_WordAndMaskedTailBoundariesAgainstByteOracle](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** A naive byte-by-byte oracle checks word and masked-tail lengths 1/2/31/32/33/63/64/65, matches and changed tails. A scratch source mutation removing the tail mask is detected. Replacement bounded search tests cap haystacks at 256 bytes and needles/replacements at 64 bytes, require success or exact EmptyNeedle, and exercise the 16 KiB maximum expansion. A deterministic 8,352,000-byte expansion fails with empty data at 10M gas; a small replacement over the same haystack succeeds. These checks pass in [docs/bounded-test-checks.json](bounded-test-checks.json); the earlier failing suite remains recorded in [docs/halmos-checks.json](halmos-checks.json).

## O60

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_O60_TextGasBudgetFailureAndSuccessfulControl`; retained supporting evidence: [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol), :40, :55, :68, :88, :129; index arithmetic in [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol); `testFuzzBoundedSearchResults`, `testBoundedSearchMaximumExpansionSucceeds`, `testReplacementExpansionExhaustsBudget` [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol) ([docs/bounded-test-checks.json](bounded-test-checks.json) current run)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1026-1028; AGENTS.md:303-310

**Test/property definitions:** [testBoundedSearchMaximumExpansionSucceeds](../contracts/tests/OperationsNoPanic.t.sol), [testFuzzBoundedSearchResults](../contracts/tests/OperationsNoPanic.t.sol), [testReplacementExpansionExhaustsBudget](../contracts/tests/OperationsNoPanic.t.sol), [test_O60_TextGasBudgetFailureAndSuccessfulControl](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** The same valid concatenation of two 2,048-byte inputs fails at 1,000 gas and succeeds at 1,000,000 gas with exact output. This resource example complements bounded text sweeps without claiming exhaustive exhaustion/overflow behavior. Replacement bounded search tests cap haystacks at 256 bytes and needles/replacements at 64 bytes, require success or exact EmptyNeedle, and exercise the 16 KiB maximum expansion. A deterministic 8,352,000-byte expansion fails with empty data at 10M gas; a small replacement over the same haystack succeeds. These checks pass in [docs/bounded-test-checks.json](bounded-test-checks.json); the earlier failing suite remains recorded in [docs/halmos-checks.json](halmos-checks.json).

## O61

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (lengths straddling 78 digits, exact error args); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :505

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1174-1186; [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

## O62

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts), :653-663; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

## O63

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O63_ParseIntGrammarAndExactErrors`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) testFuzz_decimalRoundTrip (parseInt(toString(v)) == v), :115-116 (2^255 panics); [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [testFuzz_decimalRoundTrip](../contracts/tests/OperationsNumeric.t.sol), [test_O63_ParseIntGrammarAndExactErrors](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Focused signed parsing grammar, minimum/maximum boundaries, overflow and exact error positions complement existing fuzz cases.

## O64

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O64_O68_IndependentPythonCanonicalFormatVectors`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) (round trip); [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [test_O64_O68_IndependentPythonCanonicalFormatVectors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O64_O68_IndependentPythonCanonicalFormatVectors](../scripts/generate-claim-coverage-vectors.py).

**Scope and limitations:** Exact signed canonical strings include min/max and seeded full-width values independently formatted with Python integer arithmetic.

## O65

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O65_UnitsGrammarExactErrorsAndOverflow`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) test_decimalParsing, :119 testFuzz_decimalRoundTrip; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :727-728; [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol), :88

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`parseUnits`, `_parseUnits`)

**Test/property definitions:** [testFuzz_decimalRoundTrip](../contracts/tests/OperationsNumeric.t.sol), [test_O65_UnitsGrammarExactErrorsAndOverflow](../contracts/tests/ClaimCoverageEasy.t.sol), [test_decimalParsing](../contracts/tests/OperationsNumeric.t.sol).

**Scope and limitations:** Focused unit grammar, exact error positions, precision 77/78 and overflow boundaries complement existing fuzz cases.

## O66

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) (-1.239 at 2 decimals, "+.001" Ceil, "12." Floor); [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_parseUnitsRoundsAsItsMode` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1578-1619; [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_parseUnitsRoundsAsItsMode](../contracts/tests/OperationsSymbolic.t.sol).

**Scope and limitations:** Partial: Proved for every signed five-digit text `d0d1.f0f1f2` at 0 to 4 decimals in all three modes, against a division-based reference (the exact fraction N / 1000), so dropping one to three fractional digits and padding are both covered. Longer texts remain fuzzed without excess digits

## O67

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O67_UnsignedSignsAndBounds`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol), :103-104 (bare expectRevert on "-0"), :119 round trip

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [test_O67_UnsignedSignsAndBounds](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Unsigned sign handling, exact negative rejection, maximum and overflow boundaries are asserted.

## O68

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O64_O68_IndependentPythonCanonicalFormatVectors`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) (round trip, decimals 0..77), :101-102; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :722-723

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [test_O64_O68_IndependentPythonCanonicalFormatVectors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O64_O68_IndependentPythonCanonicalFormatVectors](../scripts/generate-claim-coverage-vectors.py).

**Scope and limitations:** Canonical unsigned units are checked with literal edge cases and seeded Python formatting vectors, including precision errors.

## O69

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) ("-1.002"), :119 round trip; [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

## O70

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (random tuples vs viem encodeAbiParameters); [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) check_encodeMatchesSolc; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Test/property definitions:** [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol).

## O71

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (count, length and envelope kinds, error name only); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :621, :628, :638; [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol), :50, :56; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :541

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

**Scope and limitations:** Error arguments and the descriptor/nested-value kinds are unit only

## O72

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (decodes the envelope and compares to solc); [test/collection-codec.test.ts](../test/collection-codec.test.ts); [contracts/tests/OperationsCollections.t.sol](../contracts/tests/OperationsCollections.t.sol); [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (both faces reject identically)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md)

## O73

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) check_encodeMatchesSolc ((uint8,bool,address,bytes4): accepts exactly what solc decodes)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** `AGENTS.md` (descriptor doctrine); [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md); [contracts/Operations.sol](../contracts/Operations.sol) (`encode`, `encodeBytes`)

**Test/property definitions:** [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol).

**Scope and limitations:** The former documentation contradiction was corrected in e6d375e. The solc differential property covers `(uint8,bool,address,bytes4)`; historical contradiction retained by A30/L36/E9.

## O74

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_dirtyAddressArg_revertsInsideCall; `check_dirtyWordIntoTypedParameterIsCallFailed` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/operators/words.md](../website/src/content/docs/docs/operators/words.md)

**Test/property definitions:** [check_dirtyWordIntoTypedParameterIsCallFailed](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_dirtyAddressArg_revertsInsideCall](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved through `read` into `balance(address)`: a dirty word is `CallFailed(ops, exact calldata)`, a clean one succeeds

## O75

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (decodes Panic codes for rpow and signed mulDiv), :362-406; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :258 (stdError selectors)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O76

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (Operations leaves with BigInt references inside random trees); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :1275; [contracts/tests/OperationsExtensionIntegration.t.sol](../contracts/tests/OperationsExtensionIntegration.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md); README.md:8

**Scope and limitations:** Oracle covers ten binary word operations

## O79

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [test/bytecode-size.test.ts](../test/bytecode-size.test.ts), :22

**Supporting sources:** [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md); AGENTS.md:384-386

## O80

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** structural: [contracts/Operations.sol](../contracts/Operations.sol) import, package.json:30 ("5.6.1", exact), foundry.toml:13; behavior covered by O8, O19, O21, O22

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :298, :434, :563, :1430; AGENTS.md:376-383

**Related behavioral evidence:** [O8](#o8), [O19](#o19), [O21](#o21), [O22](#o22).

**Scope and limitations:** Verified by inspection; no test guards the exact pin

## O81

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_core_judges_lowercasedSymbol (hash(toLower(symbol())) == keccak("weth")); `check_stringEnvelopeSplicesIntoBytesParameters` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/operators/data.md](../website/src/content/docs/docs/operators/data.md), :49

**Test/property definitions:** [check_stringEnvelopeSplicesIntoBytesParameters](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_core_judges_lowercasedSymbol](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved for strings of 0, 5 and 32 bytes through `read` into `byteLen`

## L1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldWordsIsLeftFold [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); fold differential fuzz [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (JS byte-level engine `simFold` :1164); test_foldWords_sum [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 278-282; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_foldWordsIsLeftFold](../contracts/tests/WordLambdasSymbolic.t.sol), [test_foldWords_sum](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=3 words with a non-commutative lambda; JS differential covers n<=12 words over 11 Operations lambdas

## L2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldRangeAndBytes [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz foldRange/foldBytes cases [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 260-263; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_foldRangeAndBytes](../contracts/tests/WordLambdasSymbolic.t.sol).

**Scope and limitations:** Halmos n<=3; JS differential n<=30 (range) and n<=40 (bytes)

## L3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldExits [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz simFold exit handling [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 226-228; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_foldExits](../contracts/tests/WordLambdasSymbolic.t.sol).

**Scope and limitations:** Halmos n<=3, all three modes

## L4

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** test_fold_anyShortCircuits [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_fold_allShortCircuits [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); compose-fuzz simFold breaks before later failing lambdas [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Supporting sources:** [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md), 114

**Test/property definitions:** [test_fold_allShortCircuits](../contracts/tests/Operations.t.sol), [test_fold_anyShortCircuits](../contracts/tests/Operations.t.sol).

**Scope and limitations:** JS engine returns ok when a failing element lies past the exit; unit tests pin both modes concretely

## L5

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** check_elementWinsOverlap [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); check_mapWordsKeepsTemplatePristine [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz windows anywhere in [4,36] stamped like `_stampWindows` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts), 1263-1270

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 303-306; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md), 37

**Test/property definitions:** [check_elementWinsOverlap](../contracts/tests/WordLambdasSymbolic.t.sol), [check_mapWordsKeepsTemplatePristine](../contracts/tests/WordLambdasSymbolic.t.sol).

**Scope and limitations:** Halmos proves element-over-accumulator and pristine bytes; mutual element-window order only observable with unaligned offsets, which only the JS simulation exercises

## L6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_fold_emptyDomainReturnsInit [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); compose-fuzz simFold (count 0 before dead-target check) [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); check_lambdaErrors case 0 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [test_fold_emptyDomainReturnsInit](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos proves window check on empty foldWords; the "target untouched" half is DIFFERENTIAL (JS) and UNIT

## L7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol) (case 0); test_foldAccumulatorWindowBounded [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_fold_offsetOutOfBounds [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_mapWords_errors [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_filterWords_errors [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); compose-fuzz :1175-1176, 1296-1297; `check_accumulatorWindow` [contracts/tests/CallbackContextSymbolic.t.sol](../contracts/tests/CallbackContextSymbolic.t.sol) (a symbolic accumulator offset over an empty fold with no target code: accepted exactly when a word fits, otherwise `LambdaOffsetOutOfBounds(offset, length)` with no call made; a 31-byte template refused at every offset)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 233; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_accumulatorWindow](../contracts/tests/CallbackContextSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [test_filterWords_errors](../contracts/tests/Operations.t.sol), [test_foldAccumulatorWindowBounded](../contracts/tests/MutationGaps.t.sol), [test_fold_offsetOutOfBounds](../contracts/tests/Operations.t.sol), [test_mapWords_errors](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Partial: Halmos covers the element window and the accumulator window on foldWords, the latter checked before any call; map/filter windows are UNIT plus DIFFERENTIAL (error name only).

## L8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors case 1 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); check_callbackErrors [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); test_fold_codelessTarget [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); testGenericCallbacksRejectCodelessTargetsWhenCalled [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (identity precompile 0x04)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 234, 309; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_callbackErrors](../contracts/tests/ValuesSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testGenericCallbacksRejectCodelessTargetsWhenCalled](../contracts/tests/Collections.t.sol), [test_fold_codelessTarget](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Partial: Precompile exclusion is UNIT (one precompile, filterValues only)

## L9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_callbackErrors [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_lambdaErrors case 1 (n=0 must succeed) [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testGenericCallbacksRejectCodelessTargetsWhenCalled [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 549-551; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_callbackErrors](../contracts/tests/ValuesSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testGenericCallbacksRejectCodelessTargetsWhenCalled](../contracts/tests/Collections.t.sol).

**Scope and limitations:** Partial: Halmos covers mapValues and mapWords; other traversals UNIT at most

## L10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors case 2 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol) (exact bytes); check_callbackErrors [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); test_fold_anyShortCircuits [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); testCallbackErrorsHaveContext [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `check_binaryCallbackContext` [contracts/tests/CallbackContextSymbolic.t.sol](../contracts/tests/CallbackContextSymbolic.t.sol) (sortValues and uniqueValues with a later pair's callback reverting: exact `CallbackFailed(operation, 2, 3 or 1, target, calldata, reason)` over symbolic values and reason words)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 230-232, 310-311, 552-553; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), 65

**Test/property definitions:** [check_binaryCallbackContext](../contracts/tests/CallbackContextSymbolic.t.sol), [check_callbackErrors](../contracts/tests/ValuesSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testCallbackErrorsHaveContext](../contracts/tests/Collections.t.sol), [test_fold_anyShortCircuits](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Partial: `other` is asserted nonzero with the exact calldata and reason for the sort and unique binary callbacks; indexOf and the value folds are still unary or unit only.

## L11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors case 3 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testWordCallbacksRejectMalformedResults [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); test_fold_lambdaReturnTooShort [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_mapWords_shortReturn [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 311-312, 1094-1101; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testWordCallbacksRejectMalformedResults](../contracts/tests/Collections.t.sol), [test_fold_lambdaReturnTooShort](../contracts/tests/Operations.t.sol), [test_mapWords_shortReturn](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Partial: Halmos: mapWords with a 64-byte return; short return and folds UNIT

## L12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_filterWordsNeedsCanonicalBool [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz filterWords [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); test_filterWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 935-960; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_filterWordsNeedsCanonicalBool](../contracts/tests/WordLambdasSymbolic.t.sol), [test_filterWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=3

## L13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_mapWordsKeepsTemplatePristine [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz mapWords [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); test_mapWords_emptyPayload [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_mapWordsKeepsTemplatePristine](../contracts/tests/WordLambdasSymbolic.t.sol), [test_mapWords_emptyPayload](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=3; JS differential n<=12

## L14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_unalignedPayloadsRevert [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol) (7 ops, lengths 1,31,33,127); test_zipWordsChecksEachSide [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); compose-fuzz foldWords/mapWords/filterWords unaligned cases [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts), 1174, 1295; string-fuzz word ops [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 281-282, 364-365; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md), 70; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_unalignedPayloadsRevert](../contracts/tests/WordsSymbolic.t.sol), [test_zipWordsChecksEachSide](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: foldWords/mapWords/filterWords alignment is DIFFERENTIAL (error name only), not in the Halmos property

## L15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_iotaWords [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz iotaWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_iotaWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_iotaWords](../contracts/tests/WordsSymbolic.t.sol), [test_iotaWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=4; JS n<=60

## L16

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_L16_IotaAllocationOverflowAndGasExhaustion`

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); AGENTS.md:315-318

**Test/property definitions:** [test_L16_IotaAllocationOverflowAndGasExhaustion](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** Checks multiplication Panic(0x11), allocator Panic(0x41), empty failure under a 50,000-gas memory-expansion budget, and a normal three-word output. The failure sizes are concrete examples, not a portable maximum successful allocation.

## L17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_wordIndexOfIsLeastIndex [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz wordIndexOf [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_wordIndexOf [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_wordIndexOfIsLeastIndex](../contracts/tests/WordsSymbolic.t.sol), [test_wordIndexOf](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=4

## L18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reverseWords [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz reverseWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_reverseWords](../contracts/tests/WordsSymbolic.t.sol).

**Scope and limitations:** Halmos n<=4

## L19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipAreInverse [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); check_zipRejectsMismatchAndUnzipBadLane [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz zipWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 392-395; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_zipRejectsMismatchAndUnzipBadLane](../contracts/tests/WordsSymbolic.t.sol), [check_zipUnzipAreInverse](../contracts/tests/WordsSymbolic.t.sol).

**Scope and limitations:** Halmos n<=4

## L20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipAreInverse [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); check_unzipLanes [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); check_zipRejectsMismatchAndUnzipBadLane [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz unzipWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 414-417; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_unzipLanes](../contracts/tests/WordsSymbolic.t.sol), [check_zipRejectsMismatchAndUnzipBadLane](../contracts/tests/WordsSymbolic.t.sol), [check_zipUnzipAreInverse](../contracts/tests/WordsSymbolic.t.sol).

**Scope and limitations:** Halmos n<=4

## L21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sortWordsIsSortedPermutation [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); testFuzzSortWordsMatchesInsertionOracle [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (in-test insertion-sort oracle, n<=128); string-fuzz sortWords (JS sort) [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_sortWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_sortWordsIsSortedPermutation](../contracts/tests/WordsSymbolic.t.sol), [testFuzzSortWordsMatchesInsertionOracle](../contracts/tests/Collections.t.sol), [test_sortWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=4; DIFFERENTIAL to n<=128

## L22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sortIsStableByKey [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (sortValues); testFuzzSortIsStablePermutation [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** README.md:9; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md); [contracts/Collections.sol](../contracts/Collections.sol), 635-640; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_sortIsStableByKey](../contracts/tests/ValuesSymbolic.t.sol), [testFuzzSortIsStablePermutation](../contracts/tests/Collections.t.sol).

**Scope and limitations:** Partial: stability proved for sortValues n<=3 (one merge level) and fuzzed n<=12; for sortWords stability is unobservable (equal words are identical), so only the sorted-permutation result matters there. "Bottom-up merge" is an implementation claim, not tested

## L23

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageSort.t.sol](../contracts/tests/ClaimCoverageSort.t.sol) `test_L23_OddLengthsReverseAndDuplicateComparisonCounts`; retained supporting evidence: [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_L23_MergeSortComparisonCountsOnPowersOfTwo`

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 640-641; [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [test_L23_MergeSortComparisonCountsOnPowersOfTwo](../contracts/tests/ClaimEvidenceGaps.t.sol), [test_L23_OddLengthsReverseAndDuplicateComparisonCounts](../contracts/tests/ClaimCoverageSort.t.sol).

**Scope and limitations:** Partial: finite exact sortValues callback comparison counts now include odd lengths 3/5/7/9/17/31/63 and ascending/reversed/duplicate patterns; both sortValues and sortWords outputs are checked. Previous power-of-two checks remain. These checks do not establish universal O(n log n) moves/comparisons or O(n) scratch space.

## L24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_sortWords_signedRecipe [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); `check_signedSortRecipe` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md); AGENTS.md:142-143

**Test/property definitions:** [check_signedSortRecipe](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_sortWords_signedRecipe](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved over three symbolic int256 words against a sorting network; a descending-sort mutant fails it

## L25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sumWordsIsExactOrReverts [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz sumWords (expects Panic11) [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_sumWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_sumWordsIsExactOrReverts](../contracts/tests/WordsSymbolic.t.sol), [test_sumWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos n<=4 proves exact value or revert; the Panic code is DIFFERENTIAL/UNIT

## L26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_sumWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); `check_sumWordsMatchesTheFoldRecipe` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_sumWordsMatchesTheFoldRecipe](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_sumWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Proved over three words: equal checked sums, and both refuse an overflow (Panic(0x11) from sumWords, CallbackFailed from the fold); an unchecked sum fails it

## L27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_uniqueWordsKeepsFirstOccurrences [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz uniqueWords (both modes, JS Set/adjacent filter) [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_uniqueWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); testUniqueUnorderedStable [contracts/tests/OperationsCollections.t.sol](../contracts/tests/OperationsCollections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/fold.md](../website/src/content/docs/docs/operators/fold.md)

**Test/property definitions:** [check_uniqueWordsKeepsFirstOccurrences](../contracts/tests/WordsSymbolic.t.sol), [testUniqueUnorderedStable](../contracts/tests/OperationsCollections.t.sol), [test_uniqueWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Halmos proves ordered=false and ordered=true on sorted input (n<=4); ordered=true on ungrouped input is DIFFERENTIAL; the O(n)/O(n^2) cost is unbacked

## L31

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** testFuzzFoldsNeverPanic [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol) (badExit asserts empty data at :296-298)

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:311-312

**Test/property definitions:** [testFuzzFoldsNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol).

## L32

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** testFuzzWordPayloadsNeverPanic [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol); testFuzzFoldsNeverPanic :109; testFuzzValuesNeverPanic :211

**Supporting sources:** [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol) (suite claim); AGENTS.md:312-315

**Test/property definitions:** [testFuzzFoldsNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol), [testFuzzValuesNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol), [testFuzzWordPayloadsNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol).

**Scope and limitations:** 10M gas budget per call; fold counts < 300, values < 20; iotaWords excluded (L16)

## L33

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_L33_ExactPredicateCallbackFailureMatrix`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_L33_ExactWordFoldCallbackFailureMatrix`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_exactSignalSurvivesEveryWrapperAndProbe`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_ordinaryErrorsKeepExactWrappers`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_wordCallbackGasSweeps`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_valueCallbackGasSweeps`; retained supporting evidence: testHostileTargetsFailDeclared [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol); [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) gas sweeps and `test_ordinaryErrorsKeepExactWrappers`

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** `AGENTS.md` (Testing law); [contracts/Collections.sol](../contracts/Collections.sol) (`_callWord`, `_callValue`)

**Test/property definitions:** [testHostileTargetsFailDeclared](../contracts/tests/CollectionsNoPanic.t.sol), [test_L33_ExactPredicateCallbackFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_L33_ExactWordFoldCallbackFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_exactSignalSurvivesEveryWrapperAndProbe](../contracts/tests/GasPropagation.t.sol), [test_ordinaryErrorsKeepExactWrappers](../contracts/tests/GasPropagation.t.sol), [test_valueCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_wordCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol).

**Scope and limitations:** Word-fold and predicate callback matrices assert exact failed/size/noncanonical/code-less wrappers. Retained gas sweeps cover exhausted callbacks and reserved-signal precedence.

## L34

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/collection-codec.test.ts](../test/collection-codec.test.ts) (viem encodeAbiParameters oracle, 8 type shapes incl. nested dynamic); testDynamicPackUnpack [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); testNestedFixedDynamicArray :124; testNestedArraysAndStaticStruct :137; testFuzzUintArray :228

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [testDynamicPackUnpack](../contracts/tests/Collections.t.sol), [testFuzzUintArray](../contracts/tests/Collections.t.sol), [testNestedArraysAndStaticStruct](../contracts/tests/Collections.t.sol), [testNestedFixedDynamicArray](../contracts/tests/Collections.t.sol).

**Scope and limitations:** Fixed fixtures, not random generation

## L35

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [test/collection-codec.test.ts](../test/collection-codec.test.ts) (rejects only, error not checked); testRejectMalformedOffsetsAndPadding [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (bare expectRevert); test_packRejectsStaticValueOfWrongLength [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_packRejectsMalformedDynamicValue :69; test_unpackNamesTrailingBytes :559

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 530-532; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [testRejectMalformedOffsetsAndPadding](../contracts/tests/Collections.t.sol), [test_packRejectsMalformedDynamicValue](../contracts/tests/MutationGaps.t.sol), [test_packRejectsStaticValueOfWrongLength](../contracts/tests/MutationGaps.t.sol), [test_unpackNamesTrailingBytes](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Exact error and offset pinned only in MutationGaps examples

## L37

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reverseValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_flattenValues :354; test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_emptyTraversalsStillParseTheDescriptor :143; test_remainingTraversalValidations :628; test_zipAndFindValidateElements :784; testFlattenValidatesEvenEmptyDescriptorsAndNestedValues [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_flattenValues](../contracts/tests/ValuesSymbolic.t.sol), [check_reverseValues](../contracts/tests/ValuesSymbolic.t.sol), [testFlattenValidatesEvenEmptyDescriptorsAndNestedValues](../contracts/tests/Collections.t.sol), [test_emptyTraversalsStillParseTheDescriptor](../contracts/tests/MutationGaps.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol), [test_zipAndFindValidateElements](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: Halmos only for reverse and flatten over uint8; callback traversals UNIT

## L38

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_mapAppliesInOrder [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_mapValidatesResults :76; testCallbackErrorsHaveContext [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), 32

**Test/property definitions:** [check_mapAppliesInOrder](../contracts/tests/ValuesSymbolic.t.sol), [check_mapValidatesResults](../contracts/tests/ValuesSymbolic.t.sol), [testCallbackErrorsHaveContext](../contracts/tests/Collections.t.sol).

**Scope and limitations:** n<=3, uint256 in / uint8 out

## L39

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_filterKeepsMatchesInOrder [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testMapFilterFold [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_filterKeepsMatchesInOrder](../contracts/tests/ValuesSymbolic.t.sol), [testMapFilterFold](../contracts/tests/Collections.t.sol).

**Scope and limitations:** n<=3

## L40

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testMalformedPredicateAndComparatorAreRejected [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (answer 2); test_predicateNeedsOneWord [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (two words); `check_expressionPredicateIsCanonical` [contracts/tests/CompositionSymbolic.t.sol](../contracts/tests/CompositionSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1319-1337; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), 65; AGENTS.md:69-70; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_expressionPredicateIsCanonical](../contracts/tests/CompositionSymbolic.t.sol), [testMalformedPredicateAndComparatorAreRejected](../contracts/tests/Collections.t.sol), [test_predicateNeedsOneWord](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved for `filterValues` through an expression callback over every word: 1 keeps, 0 drops, anything else is `InvalidCallbackResult` naming the element and the target. The other predicate traversals share `_predicate`

## L41

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldIsLeftFold [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testMapFilterFold [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_foldIsLeftFold](../contracts/tests/ValuesSymbolic.t.sol), [testMapFilterFold](../contracts/tests/Collections.t.sol).

**Scope and limitations:** n<=3

## L42

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_remainingTraversalValidations [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_foldValidatesInitialAndResults` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 613

**Test/property definitions:** [check_foldValidatesInitialAndResults](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved: `initial` is refused with `InvalidValue(0)` before any call, and each result that leaves `uint8` with `InvalidCallbackResult`; skipping the initial check fails it

## L43

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sortIsStableByKey [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (comparator returns -1/0/1)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), 47

**Test/property definitions:** [check_sortIsStableByKey](../contracts/tests/ValuesSymbolic.t.sol).

**Scope and limitations:** n<=3; a two-word comparator return is UNIT (testMalformedPredicateAndComparatorAreRejected [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol))

## L44

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_L44_InconsistentOrderingAndEqualityRetainAlgorithmOutcomes`; retained supporting evidence: testFuzzValuesNeverPanic [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol) (constant-answer hostile targets as comparator)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (contract NatSpec, `sortValues`, `uniqueValues`, `_callValue`, `_predicate`)

**Test/property definitions:** [testFuzzValuesNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol), [test_L44_InconsistentOrderingAndEqualityRetainAlgorithmOutcomes](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** Concrete inconsistent comparator decisions retain the resulting reversed order; always-equal uniqueness retains the first value and never-equal retains duplicated encodings. Semantic ordering/equivalence guarantees still require their documented comparator laws.

## L45

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_uniqueKeepsFirstRepresentatives [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (ordered=false); testUniqueValuesOrderedKeepsFirstRepresentative [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); testUniqueUnorderedChecksEveryPreviousValue :247; testUniqueValuesEmptyAndSingleton :281; `check_uniqueOrderedComparesWithTheLastKept` [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_uniqueKeepsFirstRepresentatives](../contracts/tests/ValuesSymbolic.t.sol), [check_uniqueOrderedComparesWithTheLastKept](../contracts/tests/ValuesSymbolic.t.sol), [testUniqueUnorderedChecksEveryPreviousValue](../contracts/tests/Collections.t.sol), [testUniqueValuesEmptyAndSingleton](../contracts/tests/Collections.t.sol), [testUniqueValuesOrderedKeepsFirstRepresentative](../contracts/tests/Collections.t.sol).

**Scope and limitations:** Partial: Halmos now covers ordered=false and ordered=true (n<=3; ordered=true compares only with the last kept element); the O(n) vs O(n^2) call counts are unbacked

## L46

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_flattenValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_flattenValues](../contracts/tests/ValuesSymbolic.t.sol).

**Scope and limitations:** Two groups, n<=3

## L47

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reverseValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_reverseValues](../contracts/tests/ValuesSymbolic.t.sol).

**Scope and limitations:** n<=3

## L48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sliceIsJsSlice [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testGenericTraversalSliceZipAndShortCircuit [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_sliceIsJsSlice](../contracts/tests/ValuesSymbolic.t.sol), [testGenericTraversalSliceZipAndShortCircuit](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Indices case-split to {0,1,3,5,-1,-3,int256.min}, n<=3; int256.max end only UNIT

## L49

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (a selected dirty element is refused); `check_sliceValidatesOnlySelected` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sliceValidatesOnlySelected](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved: a junk element outside the slice is never validated, inside it is refused with `InvalidValue(0)`

## L50

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_indexOfValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (dirty needle)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_indexOfValues](../contracts/tests/ValuesSymbolic.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** n<=3

## L51

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_findAnyAllAgree [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testGenericTraversalSliceZipAndShortCircuit [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (a reverting "bomb" element past the decision)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [check_findAnyAllAgree](../contracts/tests/ValuesSymbolic.t.sol), [testGenericTraversalSliceZipAndShortCircuit](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Values PROVED n<=3; short-circuit is UNIT (any/find/all only; indexOf short-circuit untested)

## L52

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (uint256,string); check_zipValuesRefusals :336; test_zipMultiWordStaticSides [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_zipUnzipValues](../contracts/tests/ValuesSymbolic.t.sol), [check_zipValuesRefusals](../contracts/tests/ValuesSymbolic.t.sol), [test_zipMultiWordStaticSides](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Static-pair bare form UNIT

## L53

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_zipValuesRefusals :336; test_unzipValidatesParts [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_unzipRequiresTheEnvelope :171; test_unzipRefusesNonCanonicalPairs :566; testUnzipBothDynamicAndStaticLanes [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1162-1189; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_zipUnzipValues](../contracts/tests/ValuesSymbolic.t.sol), [check_zipValuesRefusals](../contracts/tests/ValuesSymbolic.t.sol), [testUnzipBothDynamicAndStaticLanes](../contracts/tests/Expressions.t.sol), [test_unzipRefusesNonCanonicalPairs](../contracts/tests/MutationGaps.t.sol), [test_unzipRequiresTheEnvelope](../contracts/tests/MutationGaps.t.sol), [test_unzipValidatesParts](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Inverse and lane error proved; validation of the other side and envelope rules UNIT

## L54

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testEmptyValidatesDescriptorsAndCallback [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (first past constants); test_callbackDescriptorMustBeAMatchingTuple [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (non-tuple, count mismatch); `check_invalidCallbackRules` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`InvalidCallback`, `_prepareCallback`)

**Test/property definitions:** [check_invalidCallbackRules](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [testEmptyValidatesDescriptorsAndCallback](../contracts/tests/Collections.t.sol), [test_callbackDescriptorMustBeAMatchingTuple](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved for a slot past the constants, a repeated slot, a non-tuple descriptor and a constant count that differs, each before any call; allowing a repeated slot fails it

## L55

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_remainingTraversalValidations [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (dirty constant, InvalidComponentValue); testPreparedCallbackRetainsStaticSlotWidth [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (slot width mismatch, InvalidComponentLength); `check_constantsAndBindingsAreValidated` [contracts/tests/SlotsSplitSymbolic.t.sol](../contracts/tests/SlotsSplitSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 546-547, 1265; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md), 67

**Test/property definitions:** [check_constantsAndBindingsAreValidated](../contracts/tests/SlotsSplitSymbolic.t.sol), [testPreparedCallbackRetainsStaticSlotWidth](../contracts/tests/Collections.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved: a constant slot is refused before any call even over an empty input, a bound value at its binding, each as `InvalidComponentValue` naming the slot; removing either check fails it

## L56

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testCallbackSubstitutesMiddleDynamicSlot [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); testMapFilterFold [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (string accumulator fold); `check_variableLengthSlotIsRebuilt` [contracts/tests/SlotsSplitSymbolic.t.sol](../contracts/tests/SlotsSplitSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_variableLengthSlotIsRebuilt](../contracts/tests/SlotsSplitSymbolic.t.sol), [testCallbackSubstitutesMiddleDynamicSlot](../contracts/tests/Collections.t.sol), [testMapFilterFold](../contracts/tests/Collections.t.sol).

**Scope and limitations:** Proved: a string slot bound to a 2-byte then a 40-byte element (and the reverse) sends exactly selector ++ abi.encode(element, 7) each time

## L57

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** none (code uses staticcall at [contracts/Collections.sol](../contracts/Collections.sol), 1314); `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 551; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes: Collections holds no CALL, so every application is a STATICCALL (see C12)

## L58

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testComposedDynamicCallbackRepeatsParameter [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); test_stringParameterLambda [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_expressionCallbackFailureIsWrapped` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1287-1315; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); README.md:10

**Test/property definitions:** [check_expressionCallbackFailureIsWrapped](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [testComposedDynamicCallbackRepeatsParameter](../contracts/tests/Expressions.t.sol), [test_stringParameterLambda](../contracts/tests/ExpressionsGas.t.sol).

**Scope and limitations:** Proved: the callback call is exactly `evaluateEncoded(expression, bound slots)` on the target, the selector ignored

## L59

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_expressionCallbackFailureIsWrapped` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_expressionCallbackFailureIsWrapped](../contracts/tests/ReadsCallbacksSymbolic.t.sol).

**Scope and limitations:** Proved: `CallbackFailed(operation, i, 0, expressions, callData, reason)` where the reason is byte for byte what `evaluateEncoded` reverts with on its own

## L60

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_L60_CollectionCallbacksDoNotShareEvaluationCaches`

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** AGENTS.md:61-62; [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [test_L60_CollectionCallbacksDoNotShareEvaluationCaches](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** Three mapValues expression callbacks make exactly three external reads although each graph uses its Resolve leaf twice. Returned values are checked as well, demonstrating cache sharing within a callback and fresh evaluation between these callbacks.

## L61

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** testLocalExpressionsDeclarationMatches [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `test_sharedSelectorsMatch` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [testLocalExpressionsDeclarationMatches](../contracts/tests/Collections.t.sol), [test_sharedSelectorsMatch](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Pinned by a unit test (see E47)

## L62

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** none (solc enforces view/pure on every external function); `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** README.md:5

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes (see C12)

## L63

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [test/bytecode-size.test.ts](../test/bytecode-size.test.ts) (per-artifact 24,576 check)

**Supporting sources:** [website/src/content/docs/docs/operators/index.md](../website/src/content/docs/docs/operators/index.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); AGENTS.md:384-386

**Scope and limitations:** The "together would not fit" half is unbacked but trivially true by arithmetic

## E1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referencesMustPointBackwards` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (refs 0, 1 = self, 2, max); `testGraphRejectsForwardReferenceAndInvalidTarget` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :89, :139-145, :211; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :38, :96; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_referencesMustPointBackwards](../contracts/tests/ExpressionsSymbolic.t.sol), [testGraphRejectsForwardReferenceAndInvalidTarget](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Shown on a Wrap node only, ref case-split {0,1,2,max}. The file header [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) says a self-reference is out of Halmos' reach, but case 1 IS a self-reference and is proved (the up-front check rejects it before any recursion)

## E2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_parameterIndexBounded` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :140-145, :330; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :96; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_parameterIndexBounded](../contracts/tests/ExpressionsSymbolic.t.sol).

**Scope and limitations:** Indices {0,1,2,max} over symbolic parameter words

## E3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_parameterDataAndCallTarget` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_parameterDataIsOneWord` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :328; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :94; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_parameterDataIsOneWord](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [test_parameterDataAndCallTarget](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved: data of 0, 31, 33 or 64 bytes reverts `InvalidNode`, one word selects the parameter or reverts `InvalidReference`; removing the check fails it

## E4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_resultIndexMustExist` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_resultIndexInRange` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :134-135, :236; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :94; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_resultIndexInRange](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [test_resultIndexMustExist](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved for indices 0 to 2 and the maximum over a two-node graph

## E5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nodeReferenceCounts` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (Select 2, TryOrElse 3, Literal 2); `test_wrapNeedsExactlyOneReference` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `test_parameterDataAndCallTarget` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (Call 0); `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (wrong counts, no-panic only); `check_referenceCountsPerKind` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :211-212, :244-259; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_referenceCountsPerKind](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_nodeReferenceCounts](../contracts/tests/MutationGaps.t.sol), [test_parameterDataAndCallTarget](../contracts/tests/MutationGaps.t.sol), [test_wrapNeedsExactlyOneReference](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Proved for every kind and every count from 0 to 4: a wrong count reverts `InvalidNode` at the node, an allowed one never does; a planted Select count bug fails it

## E6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testProbeCallRequiresBytesCalldata` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (uint256 and string operands); `check_referenceCountsPerKind` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (`evaluate` ProbeCall admission, `_evaluate`, `evaluateEncoded`)

**Test/property definitions:** [check_referenceCountsPerKind](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testProbeCallRequiresBytesCalldata](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Structure proved with a bytes-typed operand (see E5); the untyped case is pinned by `testProbeCallRequiresBytesCalldata`

## E7

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E7_UnreachableDescriptorFailsBeforeCalls`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (types `((` and `uint256[0]` injected)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :240; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E7_UnreachableDescriptorFailsBeforeCalls](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** An unreachable invalid valueType is rejected during admission before any external leaf call; zero calls are observed.

## E8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callResultIsValidated` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (uint8); `check_resolveGoesThroughTheCore` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (address); `check_sharingEqualsDuplication` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (uint8 params vs solc decode); `test_nodeValidatesDynamicValues` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (string offset); `testGraphRejectsForwardReferenceAndInvalidTarget` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_nodeValueWordsMatchSolc` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol) (`(uint8,string)` Literal, added after the snapshot)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :31-38, :88-89, :225-227, :369; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :38; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:59-60

**Test/property definitions:** [check_callResultIsValidated](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_nodeValueWordsMatchSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_resolveGoesThroughTheCore](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_sharingEqualsDuplication](../contracts/tests/ExpressionsSymbolic.t.sol), [testGraphRejectsForwardReferenceAndInvalidTarget](../contracts/tests/Expressions.t.sol), [test_nodeValidatesDynamicValues](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Partial: proved for one-word static types and for a dynamic tuple with a narrow component (solc oracle, both directions); arrays and other dynamic shapes rely on the shared codec's properties and one unit case each

## E10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_selectIsLazyAndJudgesFirstWord` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_selectIsLazyAndJudgesFirstWord](../contracts/tests/ExpressionsSymbolic.t.sol).

**Scope and limitations:** Partial: shown only for the unchosen Select branch; a dangling node outside any Select that would revert is not tested

## E11

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testGraphMemoizesSharedDynamicCallAndLazyBranch` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (`vm.expectCall` count 1); `check_sharingEqualsDuplication` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (sharing is value-transparent: graph == duplicated tree == solc); `test_sharedNodeEvaluatesOnce` [contracts/tests/CallCountsAndFallbacks.t.sol](../contracts/tests/CallCountsAndFallbacks.t.sol) (added after the snapshot); [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testMemoizationChangesGasSensitiveCallResults`

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :112-116, :213-214, :323; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :38, :82; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), :57; README.md:10; AGENTS.md:49-50, :59-61

**Test/property definitions:** [check_sharingEqualsDuplication](../contracts/tests/ExpressionsSymbolic.t.sol), [testGraphMemoizesSharedDynamicCallAndLazyBranch](../contracts/tests/Expressions.t.sol), [testMemoizationChangesGasSensitiveCallResults](../contracts/tests/ClaimBoundaries.t.sol), [test_sharedNodeEvaluatesOnce](../contracts/tests/CallCountsAndFallbacks.t.sol).

**Scope and limitations:** Exact shared-call count is pinned; `check_sharingEqualsDuplication` proves value equality only for its deterministic leaf. Gas-sensitive duplicated reads can return different values (E49). Successful-attempt cache retained (E17); failed-attempt work may execute again (E18).

## E12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_selectIsLazyAndJudgesFirstWord` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (32 and 64 byte conditions, symbolic words); `testSelectFalseTakesElseWithoutEvaluatingThen` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `testSelectAcceptsAnyNonzeroFirstWord` :170; `testSelectJudgesFirstWordOfMultiWordCondition` :175

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :216-218, :337; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); index.md:13; AGENTS.md:62-68

**Test/property definitions:** [check_selectIsLazyAndJudgesFirstWord](../contracts/tests/ExpressionsSymbolic.t.sol), [testSelectAcceptsAnyNonzeroFirstWord](../contracts/tests/Expressions.t.sol), [testSelectFalseTakesElseWithoutEvaluatingThen](../contracts/tests/Expressions.t.sol), [testSelectJudgesFirstWordOfMultiWordCondition](../contracts/tests/Expressions.t.sol).

## E13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_selectIsLazyAndJudgesFirstWord` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (unchosen branch is an out-of-range Parameter); `testSelectFalseTakesElseWithoutEvaluatingThen` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :218-219; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); index.md:13

**Test/property definitions:** [check_selectIsLazyAndJudgesFirstWord](../contracts/tests/ExpressionsSymbolic.t.sol), [testSelectFalseTakesElseWithoutEvaluatingThen](../contracts/tests/Expressions.t.sol).

## E14

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (`uint256[0]` type injected, no-panic only)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); AGENTS.md:66-68, :123-126

**Test/property definitions:** [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol).

**Scope and limitations:** Supplemental source proof: `ExpressionScalarModel.CanonicalHasWord` proves every well-formed canonical value spans at least 32 bytes; recursive canonical preservation and the concrete first-word adapter carry explicit memory/resource premises

## E15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_guardedEvaluationFallsBackExactly` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (validation failure); `testGuardedGraphFailureAndValidity` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (reverting call)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :66-68, :219-222, :338-341; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :56

**Test/property definitions:** [check_guardedEvaluationFallsBackExactly](../contracts/tests/ExpressionsSymbolic.t.sol), [testGuardedGraphFailureAndValidity](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Partial: proved for a type-validation failure; the reverting-target failure is UNIT; out-of-gas see E16

## E17

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testGuardedGraphFallbackAndSuccessfulCacheMerge` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (`vm.expectCall` count 1)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :272-273, :375-378, :390-392; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [testGuardedGraphFallbackAndSuccessfulCacheMerge](../contracts/tests/Expressions.t.sol).

## E18

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `test_failedGuardedAttemptDiscardsCachedCalls`

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :393-395; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [test_failedGuardedAttemptDiscardsCachedCalls](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** Exact vm.expectCall count 2: the first attempt calls a shared leaf and then fails canonical uint8 validation; a later reference re-executes the leaf and returns the expected value.

## E19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testGuardedEvaluationRejectsOutsideCallers` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_evaluateGuardedIsSelfOnly` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :167-172, :265-271, :287; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :95; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_evaluateGuardedIsSelfOnly](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGuardedEvaluationRejectsOutsideCallers](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Coverage is limited to the linked Halmos properties and concrete tests with their recorded bounds. Separate source/bytecode proof campaigns are not included in this release.

## E20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callBuildsSolcCalldata` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (uint8, bytes32, string of length 0/5/32, symbolic selector; Reflector echoes caller and calldata)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :31-37, :361-367; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_callBuildsSolcCalldata](../contracts/tests/ExpressionsCallsSymbolic.t.sol).

**Scope and limitations:** Solc abi.encode is the oracle

## E21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callTargetRules` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (symbolic 96 upper bits); `testGraphRejectsForwardReferenceAndInvalidTarget` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :447-454; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :94; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_callTargetRules](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testGraphRejectsForwardReferenceAndInvalidTarget](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Partial: Call nodes only; a dirty ProbeCall target word is untested

## E22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callTargetRules` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (case 1)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :457-462; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_callTargetRules](../contracts/tests/ExpressionsCallsSymbolic.t.sol).

**Scope and limitations:** Partial: Call nodes only; a Resolve node with a code-less `core` is reached only by the no-panic sweep ([contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol)) without asserting the error; the self-call case cannot occur

## E23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callTargetRules` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (case 2, exact data); `check_resolveNodeEnforcesConstraints` [contracts/tests/CompositionSymbolic.t.sol](../contracts/tests/CompositionSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :156-165, :466; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_callTargetRules](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_resolveNodeEnforcesConstraints](../contracts/tests/CompositionSymbolic.t.sol).

**Scope and limitations:** Call failures and Resolve with a failing EQ constraint carry exact nested revert bytes. Gas artifacts are excluded explicitly in symbolic failure properties; C69 supplies concrete gas evidence.

## E24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_resolveGoesThroughTheCore` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (no constraints); `test_expressionGraphResolvesNewConstraintKinds` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol) (SKIP + IN_SIGNED pass and fail); `check_resolveNodeEnforcesConstraints` [contracts/tests/CompositionSymbolic.t.sol](../contracts/tests/CompositionSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :101-103, :332-334; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_resolveGoesThroughTheCore](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_resolveNodeEnforcesConstraints](../contracts/tests/CompositionSymbolic.t.sol), [test_expressionGraphResolvesNewConstraintKinds](../contracts/tests/PositionalConstraints.t.sol).

**Scope and limitations:** Proved for an EQ constraint over a symbolic word: the node evaluates exactly when the constraint holds, and on failure carries the core's own `resolve` revert, byte for byte, in `NodeCallFailed` at that node. Other constraint kinds are proved at the core (ERC8211Symbolic) and reach the node through the same call

## E25

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testResolveRejectsImpossibleDecoderAllocation` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E25_ResolveDecoderBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (junk Resolve data injected at :126-128)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:324-329; [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol)

**Test/property definitions:** [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [testResolveRejectsImpossibleDecoderAllocation](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E25_ResolveDecoderBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Exact retained bare-revert cases remain covered. The current allocation regression asserts Panic(0x41) before the core/self-call; decoder errors are not universally bare or wrapped in NodeCallFailed. The bounded graph sweep tolerates only empty data or exact allocation Panic(0x41) for injected malformed payloads, and rejects other panics.

## E26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_probeCallMatchesRevertData` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (reason lengths 0/3/4/36/64, symbolic selector); `check_probeCallRefusals` :181; `testProbeCallPreservesUnderlyingDynamicReason` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :174-192, :419-445; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :60; [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_probeCallMatchesRevertData](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_probeCallRefusals](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testProbeCallPreservesUnderlyingDynamicReason](../contracts/tests/Expressions.t.sol).

## E27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_probeCallRefusals` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol); `testProbeCallPreservesUnderlyingDynamicReason` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :429-432; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_probeCallRefusals](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testProbeCallPreservesUnderlyingDynamicReason](../contracts/tests/Expressions.t.sol).

## E28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testProbeCallPreservesUnderlyingDynamicReason` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_probeCallMatchesRevertData` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md), :60

**Test/property definitions:** [check_probeCallMatchesRevertData](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testProbeCallPreservesUnderlyingDynamicReason](../contracts/tests/Expressions.t.sol).

## E29

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testLocalCoreDeclarationsMatchTheCore` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_sharedSelectorsMatch` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :176-178, :186-187, :425-426

**Test/property definitions:** [testLocalCoreDeclarationsMatchTheCore](../contracts/tests/Expressions.t.sol), [test_sharedSelectorsMatch](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Pinned by a unit test: `DidNotRevert`, `UnexpectedRevertData`, `SubcallOutOfGas` and `ICore.resolve` match the core; it is a compile-time fact, so a unit test is the right evidence

## E30

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referencesMustPointBackwards` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (ref 0 case, concrete value); `testGraphAbiConstructors` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_unpack_*` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_wrapArrayTupleValues` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :346-347; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_referencesMustPointBackwards](../contracts/tests/ExpressionsSymbolic.t.sol), [check_wrapArrayTupleValues](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGraphAbiConstructors](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Proved: Wrap yields `abi.encode(bytes)` of its operand

## E31

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testGraphAbiConstructors` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (bytes[] vs abi.encode); `check_wrapArrayTupleValues` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol); `check_narrowArrayConstructor` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (`uint8[]` over full-width leaves, accepted exactly when in range, and the empty array); `check_dynamicElementArrayConstructor` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (`string[]` of zero, one or two strings equals `abi.encode`, a bare word refused with `InvalidValue`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :353-354; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_dynamicElementArrayConstructor](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_narrowArrayConstructor](../contracts/tests/ConstructorsSymbolic.t.sol), [check_wrapArrayTupleValues](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGraphAbiConstructors](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Partial: proved for `bytes32[]` of two, `uint8[]` of zero or two (range enforced) and `string[]` of zero to two; longer arrays and nested element shapes are units.

## E32

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_sharingEqualsDuplication` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (static tuple vs solc); `testGraphAbiConstructors` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) ((uint256,bytes[]) vs abi.encode); `check_dynamicTupleConstructor` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (`(uint8,string)` with an empty or two-byte string equals `abi.encode` with the 0x20 word); `check_tupleComponentShapeIsChecked` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (a bare word in the string slot reverts `InvalidComponentEnvelope(1, 32, word)`, a string in the uint8 slot `InvalidComponentLength(0, 32, 96)`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :355-358, :400-402; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_dynamicTupleConstructor](../contracts/tests/ConstructorsSymbolic.t.sol), [check_sharingEqualsDuplication](../contracts/tests/ExpressionsSymbolic.t.sol), [check_tupleComponentShapeIsChecked](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testGraphAbiConstructors](../contracts/tests/Expressions.t.sol).

**Scope and limitations:** Partial: a static and a dynamic tuple shape proved, the 0x20 prefix and the exact component-shape errors included; wider tuples are units.

## E33

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wrapArrayTupleValues` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol); `check_callArityMismatch` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (one operand too many reverts `ComponentCountMismatch(1, 2)`, one too few `(2, 1)`, before any call)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md)

**Test/property definitions:** [check_callArityMismatch](../contracts/tests/ConstructorsSymbolic.t.sol), [check_wrapArrayTupleValues](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Proved for a Tuple node (`ComponentCountMismatch(3, 2)`) and for a Call node in both directions, the arity check preceding the call.

## E34

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testGraphMemoizesSharedDynamicCallAndLazyBranch` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (`source()` called with "()"); `test_graphOverhead` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_emptyTupleCallSendsBareSelector` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :411-413

**Test/property definitions:** [check_emptyTupleCallSendsBareSelector](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGraphMemoizesSharedDynamicCallAndLazyBranch](../contracts/tests/Expressions.t.sol), [test_graphOverhead](../contracts/tests/ExpressionsGas.t.sol).

**Scope and limitations:** Proved: a Call node with `"()"` and no operands sends exactly the four selector bytes

## E35

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** All `check_*` in [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) and [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) compare raw returndata to abi.encode; `test_sharedLeaf_*` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol) (graph output == tree output through `Assertions.resolve`)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :227-229, :262; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

## E36

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testComposedDynamicCallbackRepeatsParameter` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_stringParameterLambda` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_evaluateEncodedMatchesEvaluate` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :305-309; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); README.md:10

**Test/property definitions:** [check_evaluateEncodedMatchesEvaluate](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testComposedDynamicCallbackRepeatsParameter](../contracts/tests/Expressions.t.sol), [test_stringParameterLambda](../contracts/tests/ExpressionsGas.t.sol).

**Scope and limitations:** Proved: the same value as `evaluate` for a valid graph

## E37

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_evaluateEncodedMatchesEvaluate` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [check_evaluateEncodedMatchesEvaluate](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Proved: `NodeCallFailed(0, expressions, evaluate calldata, evaluate's own revert)` byte for byte; a planted node index fails it

## E38

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testEvaluateEncodedRejectsImpossibleDecoderAllocation` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E38_EncodedDecoderBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (random payload, bare revert tolerated)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); [website/src/content/docs/docs/reference/errors.md](../website/src/content/docs/docs/reference/errors.md); AGENTS.md:324-329

**Test/property definitions:** [testEvaluateEncodedRejectsImpossibleDecoderAllocation](../contracts/tests/ExpressionsNoPanic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E38_EncodedDecoderBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Exact retained bare-revert cases remain covered. The current allocation regression asserts Panic(0x41) before the core/self-call; decoder errors are not universally bare or wrapped in NodeCallFailed. The bounded graph sweep tolerates only empty data or exact allocation Panic(0x41) for injected malformed payloads, and rejects other panics.

## E39

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E39_InvalidKindBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (kind 11 injected at :110-111)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); AGENTS.md:311-312, :324-329

**Test/property definitions:** [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E39_InvalidKindBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** All invalid node-kind values 11 through 255 assert the exact empty decoder revert.

## E40

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E7_UnreachableDescriptorFailsBeforeCalls`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E25_ResolveDecoderBareRevert`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E38_EncodedDecoderBareRevert`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E39_InvalidKindBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (up to 6 nodes, all kinds, 8 HostileTarget modes, 10M gas per call); `testResolveRejectsImpossibleDecoderAllocation`, `testEvaluateEncodedRejectsImpossibleDecoderAllocation` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); AGENTS.md:323-334

**Test/property definitions:** [testEvaluateEncodedRejectsImpossibleDecoderAllocation](../contracts/tests/ExpressionsNoPanic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [testResolveRejectsImpossibleDecoderAllocation](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E25_ResolveDecoderBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E38_EncodedDecoderBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E39_InvalidKindBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E7_UnreachableDescriptorFailsBeforeCalls](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Focused admission, invalid-kind and malformed payload checks distinguish declared errors from exact bare ABI-decoder reverts. The retained hostile-graph grid remains bounded; arithmetic/resource failures are still permitted.

## E41

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_E41_EvaluateAndEncodedCallsStartFreshCaches`

**Recorded test run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md); AGENTS.md:60-62

**Test/property definitions:** [test_E41_EvaluateAndEncodedCallsStartFreshCaches](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** Two evaluate and two evaluateEncoded invocations make exactly four external reads while each result refers twice to the same Resolve leaf. Results and exact call counts check fresh caches and within-invocation sharing.

## E42

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-coverage-structure.py](../scripts/test-claim-coverage-structure.py) `test_E42_admission_shape_metadata_reused_by_validation`; retained supporting evidence: `test_nodeValidatesDynamicValues` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (cached-shape validation path); `test_gas_evaluatePerNode` [contracts/tests/AbiCodecGas.t.sol](../contracts/tests/AbiCodecGas.t.sol) (first Literal < 13k, each further < 5k, Tuple node < 33k)

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :240, :369; AGENTS.md:73-76

**Test/property definitions:** [test_E42_admission_shape_metadata_reused_by_validation](../scripts/test-claim-coverage-structure.py), [test_gas_evaluatePerNode](../contracts/tests/AbiCodecGas.t.sol), [test_nodeValidatesDynamicValues](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Compiler-AST checks verify admission parses each node valueType into cached dynamic/words fields and validation consumes those fields. Wrong descriptor, cached field and iterator mutations are detected. This is structural evidence for the current metadata-reuse claim, not a runtime parse-count theorem; recursive validation still walks contents.

## E46

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** Structural: no state variables, every external function `view` ([contracts/Expressions.sol](../contracts/Expressions.sol), :281, :305); `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); README.md:5; [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md)

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes (see C12)

## E47

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testLocalExpressionsDeclarationMatches` [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `test_sharedSelectorsMatch` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol) (added after the snapshot)

**Supporting sources:** [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); [website/src/content/docs/docs/operators/collections.md](../website/src/content/docs/docs/operators/collections.md)

**Test/property definitions:** [testLocalExpressionsDeclarationMatches](../contracts/tests/Collections.t.sol), [test_sharedSelectorsMatch](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Pinned by a unit test: `IExpressions.evaluateEncoded` matches Expressions (compile-time fact)

## E48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** E1, E2, E3, E4, E5, E21, E22, E23 properties assert exact revert data with the node index

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :134-135, :141-144, :151, :160; AGENTS.md:133

**Related behavioral evidence:** [E1](#e1), [E2](#e2), [E3](#e3), [E4](#e4), [E5](#e5), [E21](#e21), [E22](#e22), [E23](#e23).

**Scope and limitations:** Partial: up-front ref counts, Parameter data and result bounds now have symbolic properties. Dirty ProbeCall targets and code-less Resolve cores remain unpinned as stated in E21/E22.

## E49

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testMemoizationChangesGasSensitiveCallResults`

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (contract NatSpec); [website/src/content/docs/docs/operators/expressions.md](../website/src/content/docs/docs/operators/expressions.md); `AGENTS.md`

**Test/property definitions:** [testMemoizationChangesGasSensitiveCallResults](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** At the same evaluation budget a shared gasleft leaf yields two equal values, duplicated leaves yield decreasing values. Call context also includes caller and calldata; view alone is insufficient.

## R1

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [website/scripts/check-integration.mjs](../website/scripts/check-integration.mjs) ([docs/assertions-2.0-release-checks.json](assertions-2.0-release-checks.json)); `pnpm check:integration`; [website/src/lib/deployments.json](../website/src/lib/deployments.json)

**Recorded test run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/scripts/check-integration.mjs](../website/scripts/check-integration.mjs); [website/scripts/export-deploy-artifact.mjs](../website/scripts/export-deploy-artifact.mjs); `AGENTS.md`

**Integration check:** [check:integration](../website/scripts/check-integration.mjs).

**Scope and limitations:** The final canonical Hardhat artifacts, CREATE2 predictions, generated deployment/ABI/verification modules, SDK constants and runtime fixtures agree in the offline integration check. Salts are newly mined against the final source. This check does not establish deployment on any public chain.

## R2

**Recorded evidence:** ASSUMPTION / DOCUMENTED.

**References:**  compiler settings in manifest

**Supporting sources:** `hardhat.config.ts`; `foundry.toml`; `README.md`; [website/src/lib/deployments.json](../website/src/lib/deployments.json)

**Scope and limitations:** Environment precondition: execute with the recorded compiler/EVM settings and correct environmental observations and used precompiles. Local Cancun and fork checks cover selected environments; they do not certify every possible chain. MODEXP fallback handles failed or wrong-sized receipts, but a successful 32-byte reply remains trusted.

## R3

**Recorded evidence:** LIMITATION / DOCUMENTED.

**References:** `pnpm check:integration` verifies predictions; no public-chain deployment performed by this change

**Supporting sources:** `README.md`; [website/scripts/export-deploy-artifact.mjs](../website/scripts/export-deploy-artifact.mjs); SDK `packages/sdk/src/onchain/addresses.ts`

**Integration check:** [check:integration](../website/scripts/check-integration.mjs).

**Scope and limitations:** CREATE2 predicts an address from deployer, salt and creation-code hash; the prediction by itself does not establish code presence or matching runtime on a public chain. Local prediction/integration checks support the formula, not public deployment availability.
