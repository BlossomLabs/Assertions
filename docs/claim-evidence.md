# Claim evidence

Evidence references and limitations for [the functional claims](claims.md). Each recorded run applies to its own source snapshot, assumptions and bounds. File links open the current test source; run records identify the source snapshot that actually ran. A passing test supports its stated coverage, rather than an unrestricted proof of the claim. Some detailed run artifacts are retained locally and excluded from Git.

The evidence records are preserved in [claim-evidence.json](claim-evidence.json).

**Halmos baseline:** [results, source hashes and logs](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json) — 307 passed, 0 failed, 0 incomplete. Separate source and bytecode proof campaigns are excluded.

**Concrete suite:** 678 passed, 0 failed against this source snapshot. See the linked run record.

## C1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testAtomicityRequiresExecutorToPropagateFailure`; `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); check_behaviorExecutorRollback [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol); check_behaviorBatchStopsAtFirstFailure [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** `README.md:3`, [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [check_behaviorBatchStopsAtFirstFailure](../contracts/tests/ClaimConstructionSymbolic.t.sol), [check_behaviorExecutorRollback](../contracts/tests/ClaimConstructionSymbolic.t.sol), [testAtomicityRequiresExecutorToPropagateFailure](../contracts/tests/ClaimBoundaries.t.sol).

**Retained formal results:** [check_batchErrorNamesTheOperand: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchErrorNamesTheOperand.json), [check_behaviorBatchStopsAtFirstFailure: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorBatchStopsAtFirstFailure.json), [check_behaviorExecutorRollback: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorExecutorRollback.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A small executor starts with zero storage, writes an unrestricted mark, then invokes one RAW_BYTES EQ assertion. Propagated failure rolls back its write; caught failure retains it; success retains it. Three predicate entries stop at the selected first failure, with exact message/entry/parameter/constraint context and ghost-observed call counts. This is not a proof over arbitrary executors, batches or operand trees; the mandatory same-transaction propagation premises remain required.

## C2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `genAssertParam` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (run by `composed expression fuzz` `:913`); unit tests [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); check_judgeSingleParamFetchers [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_judgeSingleParamFetchers](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol).

**Retained formal results:** [check_judgeSingleParamFetchers: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgeSingleParamFetchers.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A symbolic word is fetched through four selected routes and judged against an unrestricted reference, with both message overloads and every legal paramType. Complete success and ConstraintFailed bytes are required. Fetcher encodings, constraint count and target behaviors are fixed; arbitrary constraints, payloads and targets remain outside coverage.

## C3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testFuzzPrimitivesNeverPanic` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) draws paramType 0..2 but asserts only "no panic"; `check_resolveIgnoresParamType` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:219`, `:239-240`

**Test/property definitions:** [check_resolveIgnoresParamType](../contracts/tests/OperandsSymbolic.t.sol), [testFuzzPrimitivesNeverPanic](../contracts/tests/CoreNoPanic.t.sol).

**Retained formal results:** [check_resolveIgnoresParamType: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_resolveIgnoresParamType.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for `resolve`: TARGET, VALUE and CALL_DATA resolve alike (`assertParam` shares `_resolve`)

## C4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** predicate branch [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (judge fuzz `:1033`); `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); check_judgePredicateOnlyBatches [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:759-760`

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [check_judgePredicateOnlyBatches](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol).

**Retained formal results:** [check_batchErrorNamesTheOperand: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchErrorNamesTheOperand.json), [check_judgePredicateOnlyBatches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgePredicateOnlyBatches.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Three CALL_DATA-only entries resolve and validate one EQ each, with both message overloads. Every success requires empty output and complete failure context identifies the first bad entry. Code at address zero observes erroneous constructed calls through a ghost counter, including reverted calls. This does not establish arbitrary batch sizes or fetcher/parameter combinations.

## C5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchConstructsTheCall` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `test_assertBatch_constructedCall_reverts_withBuiltCalldata` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:753-759`

**Test/property definitions:** [check_batchConstructsTheCall](../contracts/tests/BatchSymbolic.t.sol), [test_assertBatch_constructedCall_reverts_withBuiltCalldata](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_batchConstructsTheCall: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchConstructsTheCall.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bounded: one entry, three word params, TARGET at each of 3 positions

## C6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** target0 branch [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_assertBatch_zeroTarget_skipsCall` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); check_edgesZeroTargetSkipsCall [contracts/tests/ClaimBoundaryCasesSymbolic.t.sol](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:786`

**Test/property definitions:** [check_edgesZeroTargetSkipsCall](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol), [test_assertBatch_zeroTarget_skipsCall](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_edgesZeroTargetSkipsCall: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimBoundaryCasesSymbolicTest.check_edgesZeroTargetSkipsCall.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A zero TARGET in each of three literal positions skips the constructed call, with unrestricted data words and both message overloads. Test-only code at address zero advances the ghost clock if called, making an otherwise silent wrong call observable. This is one batch geometry and RAW_BYTES resolution, not arbitrary entries/fetchers. The observer assumption and separate counter call are explicit.

## C7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchStructuralRefusals` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); compose judge fuzz [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:58-59`

**Test/property definitions:** [check_batchStructuralRefusals](../contracts/tests/BatchSymbolic.t.sol).

**Retained formal results:** [check_batchStructuralRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchStructuralRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Indices proved at entry 1, param 1 only

## C8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_C8_DirtyTargetNamesNonzeroIndex`; retained supporting evidence: dirty-target branch [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (name only); `test_assertBatch_dirtyTargetWord` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol) (index 0); check_behaviorDirtyBatchTarget [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:892-895`

**Test/property definitions:** [check_behaviorDirtyBatchTarget](../contracts/tests/ClaimConstructionSymbolic.t.sol), [test_C8_DirtyTargetNamesNonzeroIndex](../contracts/tests/ClaimCoverageEasy.t.sol), [test_assertBatch_dirtyTargetWord](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_behaviorDirtyBatchTarget: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorDirtyBatchTarget.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: All nonzero uint96 upper bits are symbolic; the clean lower address is the fixed observer. A canonical four-parameter batch with TARGET in each literal position rejects the exact complete dirty word at that position, through both message overloads. Other addresses, batch geometries and earlier competing errors are outside this property.

## C9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `test_assertBatch_secondEntry_reverts_withEntryIndex` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertParam_secondConstraint_reverts_withIndex` `:250`

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), `AGENTS.md:133-134`

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [test_assertBatch_secondEntry_reverts_withEntryIndex](../contracts/tests/Assertions.t.sol), [test_assertParam_secondConstraint_reverts_withIndex](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_batchErrorNamesTheOperand: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchErrorNamesTheOperand.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** One concrete structure (entry 1, param 1, constraint 0), words symbolic

## C10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertParam_withMessage` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertBatch_withMessage` `:449`; `test_resolve_constraint_holds_and_reverts` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_judgesEchoTheirMessage` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_judgesEchoTheirMessage](../contracts/tests/OperandsSymbolic.t.sol), [test_assertBatch_withMessage](../contracts/tests/Assertions.t.sol), [test_assertParam_withMessage](../contracts/tests/Assertions.t.sol), [test_resolve_constraint_holds_and_reverts](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_judgesEchoTheirMessage: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_judgesEchoTheirMessage.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: custom messages on both overloads, defaults "PARAM" and "COMPOSABLE", and "" on a primitive operand; a planted default change fails it

## C11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertBatch_constructedCall_reverts_withBuiltCalldata` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `check_batchConstructedCallFailure` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_batchConstructedCallFailure](../contracts/tests/OperandsSymbolic.t.sol), [test_assertBatch_constructedCall_reverts_withBuiltCalldata](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_batchConstructedCallFailure: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_batchConstructedCallFailure.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `CallFailed(target, functionSig ++ operands)` byte for byte for a reverting target, success for a quiet one; dropping the selector fails it

## C12

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** none; enforced by the compiler through `view` on [contracts/Assertions.sol](../contracts/Assertions.sol), `:200`, `:213`, `:222`; `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `README.md:7`

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes: no SSTORE, TSTORE, LOG, CREATE, CREATE2, SELFDESTRUCT, CALL, CALLCODE or DELEGATECALL in any runtime, and the scan finds STATICCALLs and refuses a CALL or an SSTORE (non-vacuous both ways)

## C13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_isValid_batchAsOperand` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_revertData_batchFailsOnExactConstraint` `:1485`; `check_batchIsAnOperand` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_batchIsAnOperand](../contracts/tests/OperandsSymbolic.t.sol), [test_isValid_batchAsOperand](../contracts/tests/CoreReads.t.sol), [test_revertData_batchFailsOnExactConstraint](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_batchIsAnOperand: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_batchIsAnOperand.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `isValid` over an `assertBatch` self-call is 1 exactly when the batch passes

## C14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_gatherReturnsRawValues` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `test_resolve_rawBytes_passthrough` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_gatherReturnsRawValues](../contracts/tests/ControlSymbolic.t.sol), [test_resolve_rawBytes_passthrough](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_gatherReturnsRawValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_gatherReturnsRawValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Lengths 0, 5, 32, 64

## C15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_staticCallResolvesToReturndata` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:798-799`, `:20`

**Test/property definitions:** [check_staticCallResolvesToReturndata](../contracts/tests/BatchSymbolic.t.sol).

**Retained formal results:** [check_staticCallResolvesToReturndata: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_staticCallResolvesToReturndata.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Returndata lengths 0, 5, 32, 64

## C16

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_staticCallToEmptyAccountFails` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `test_assertParam_codelessTarget` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_staticCallToEmptyAccountFails](../contracts/tests/BatchSymbolic.t.sol), [test_assertParam_codelessTarget](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_staticCallToEmptyAccountFails: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_staticCallToEmptyAccountFails.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## C17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** compose-fuzz leaves [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (name only); `test_assertParam_callReverts` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol) (args); check_judgeStaticFailureContext [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol); check_judgeReservedFailurePropagation [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_judgeReservedFailurePropagation](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol), [check_judgeStaticFailureContext](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol), [test_assertParam_callReverts](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_judgeReservedFailurePropagation: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgeReservedFailurePropagation.json), [check_judgeStaticFailureContext: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgeStaticFailureContext.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: An ordinary failed target call reports the exact resolving-frame target and calldata, with inner reason omitted. Ordinary-failure properties exclude reserved input reasons and symbolic SubcallOutOfGas outputs through explicit Keccak digest-inequality assumptions; the Halmos hash abstraction applies. The exact reserved signal separately propagates at all selected depths without exclusions. Actual gas exhaustion is concrete evidence only; arbitrary failures and nesting require separate evidence.

## C18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_balanceFetcher` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_balanceFetcher](../contracts/tests/BatchSymbolic.t.sol).

**Retained formal results:** [check_balanceFetcher: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_balanceFetcher.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Primary Halmos lengths 0, 20, 39, 41. The supplemental source proof handles arbitrary lengths; the new EVM oracle also asserts short token-return rejection and first-word normalization of long returns

## C19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** oracle rule [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts), `composed expression fuzz` `:913`; check_judgeStaticFailureContext [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol); check_judgeReservedFailurePropagation [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_judgeReservedFailurePropagation](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol), [check_judgeStaticFailureContext](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol).

**Retained formal results:** [check_judgeReservedFailurePropagation: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgeReservedFailurePropagation.json), [check_judgeStaticFailureContext: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgeStaticFailureContext.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Selected nested STATIC_CALL failures are wrapped in the outer resolving frame with complete CallFailed target/calldata. Inner ordinary reasons are lost. Exact reserved signals propagate unchanged without exclusions; ordinary-failure checks exclude reserved input reasons and symbolic gas artifacts through Keccak digest-inequality assumptions, subject to the Halmos hash abstraction. No unbounded nesting or real gas model is inferred.

## C20

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testReadsAndBatchRejectImpossibleDecoderAllocation`, `testOrRejectsImpossibleDecoderAllocation`, `testFuzzBoundedReadAndBatchSucceed` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); [docs/halmos-checks.json](halmos-checks.json) isolated replay source/results (`test_decoderAllocationFailure0`, `test_decoderAllocationFailure1`, `test_orDecoderAllocationFailure`); retained supporting evidence: `CoreNoPanicTest.call` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) tolerates a bare revert when junk was injected

**Recorded run:** [results, commands and source hashes](bounded-test-checks.json).

**Supporting sources:** `AGENTS.md:324-329`

**Test/property definitions:** [testFuzzBoundedReadAndBatchSucceed](../contracts/tests/CoreNoPanic.t.sol), [testOrRejectsImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol), [testReadsAndBatchRejectImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** Canonical bounded read/batch sweeps require selector-bearing non-panic failures; successful read/get and both batch overloads are exercised with uint256 arguments. Exact regressions assert Panic(0x41) from an impossible STATIC_CALL bytes allocation before target execution. Malformed nested ABI payloads do not universally revert without data.

## C21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `composed expression fuzz` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_resolve_constraint_holds_and_reverts` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); check_judgeResolveConstraints [contracts/tests/ClaimCoreConstraintsSymbolic.t.sol](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_judgeResolveConstraints](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol), [test_resolve_constraint_holds_and_reverts](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_judgeResolveConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCoreConstraintsSymbolicTest.check_judgeResolveConstraints.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Resolve must return the raw two-word bytes exactly when all supplied EQ constraints hold. Otherwise it must return complete ConstraintFailed context with empty assertion text and the first bad constraint index. All four actual/reference words are unrestricted. Other constraint kinds, counts, payloads and fetchers remain separate.

## C22

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** random self-nested trees [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_selfNesting_*` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Scope and limitations:** Tree depth bounded by the generator

## C23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_gatherReturnsRawValues` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`gather`)

**Test/property definitions:** [check_gatherReturnsRawValues](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_gatherReturnsRawValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_gatherReturnsRawValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Two operands, lengths 0, 5, 32, 64

## C24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_gather_resolvesEachOperandOnce` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `test_get_sixLiveStrings_resolveEachOnce` `:104` (`vm.expectCall` counts); `test_gatherResolvesEachOperandOnce`, `test_getResolvesEachArgumentOnce` [contracts/tests/CallCountsAndFallbacks.t.sol](../contracts/tests/CallCountsAndFallbacks.t.sol) (added after the snapshot); check_behaviorGatherResolvesEntriesOnce [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol); check_behaviorGetResolvesTargetAndEntriesOnce [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:534-535`, `:26`, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), `AGENTS.md:50-53`

**Test/property definitions:** [check_behaviorGatherResolvesEntriesOnce](../contracts/tests/ClaimConstructionSymbolic.t.sol), [check_behaviorGetResolvesTargetAndEntriesOnce](../contracts/tests/ClaimConstructionSymbolic.t.sol), [test_gatherResolvesEachOperandOnce](../contracts/tests/CallCountsAndFallbacks.t.sol), [test_gather_resolvesEachOperandOnce](../contracts/tests/CoreExtensions.t.sol), [test_getResolvesEachArgumentOnce](../contracts/tests/CallCountsAndFallbacks.t.sol), [test_get_sixLiveStrings_resolveEachOnce](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_behaviorGatherResolvesEntriesOnce: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorGatherResolvesEntriesOnce.json), [check_behaviorGetResolvesTargetAndEntriesOnce: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorGetResolvesTargetAndEntriesOnce.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: get and gather observe exactly one resolution per independent operand, including repeated entries; get also resolves its STATIC_CALL target once. Zero through three arguments use unrestricted words or canonical 33-byte bytes payloads. The ghost clock records calls, independently cross-checked by Foundry expectCall. These are selected one-level operands, not arbitrary operand trees or gas-sensitive read equivalence.

## C25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_gather_constraintNamesOperand` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_gatherNamesByIndex` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_gatherNamesByIndex](../contracts/tests/OperandsSymbolic.t.sol), [test_gather_constraintNamesOperand](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_gatherNamesByIndex: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_gatherNamesByIndex.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved over three operands: the first failing one is named by its list index, otherwise every raw value is returned in order; a planted index bug fails it

## C26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_gather_isCanonicalBytesArrayForGet` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_gatheredValuesFeedGet` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_gatheredValuesFeedGet](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_gather_isCanonicalBytesArrayForGet](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_gatheredValuesFeedGet: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_gatheredValuesFeedGet.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: the target receives exactly selector ++ abi.encode(values) for two symbolic gathered words

## C27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_pickSelectsFullWords` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`pick`, `_rawWord`)

**Test/property definitions:** [check_pickSelectsFullWords](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_pickSelectsFullWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_pickSelectsFullWords.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Lengths 0, 32, 63, 96, 128; nine index cases

## C28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** empty path [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `genNav` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_nav_emptyPath_passthrough` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); check_edgesEmptyNavigation [contracts/tests/ClaimBoundaryCasesSymbolic.t.sol](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_edgesEmptyNavigation](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol), [test_nav_emptyPath_passthrough](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_edgesEmptyNavigation: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimBoundaryCasesSymbolicTest.check_edgesEmptyNavigation.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: After successful RAW_BYTES resolution, an empty navigation path returns the exact symbolic payload without reading an independently symbolic 32-byte descriptor. The displayed payload lengths cross word/padding boundaries. Other descriptor lengths, fetchers and operand failures retain separate evidence; no arbitrary-length claim is supplied.

## C29

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (viem); `testFuzz_nav_staticTuple_exactBytes` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol) (solc); `check_staticTerminals` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `test_nav_staticSpan_rejectsTruncationAndOutOfRange` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol); check_navStaticTerminals [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navStaticDirtyWords [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_navStaticDirtyWords](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navStaticTerminals](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_staticTerminals](../contracts/tests/NavSymbolic.t.sol), [testFuzz_nav_staticTuple_exactBytes](../contracts/tests/StaticLenses.t.sol), [test_nav_staticSpan_rejectsTruncationAndOutOfRange](../contracts/tests/StaticLenses.t.sol).

**Retained formal results:** [check_navStaticDirtyWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navStaticDirtyWords.json), [check_navStaticTerminals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navStaticTerminals.json), [check_staticTerminals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_staticTerminals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Selected static arrays, a four-word static tuple and narrow scalar terminals return their full bare solc encoding. Independently placed dirty words reject at exact source offsets. Values and dirty words are symbolic; the geometry and paths are literal cases. Arbitrary static descriptors and footprints are outside the added coverage.

## C30

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_staticTerminals` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `check_dynamicArray` `:94` (solc soundness); offsets `test_nav_rejectsOutOfRangeStaticTerminals` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol), `test_nav_rejectsOutOfRangeElementsOfDynamicArrays` `:176`; `check_navReencodedWordsMatchSolc` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol), [check_navReencodedWordsMatchSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_staticTerminals](../contracts/tests/NavSymbolic.t.sol), [test_nav_rejectsOutOfRangeElementsOfDynamicArrays](../contracts/tests/StaticLenses.t.sol), [test_nav_rejectsOutOfRangeStaticTerminals](../contracts/tests/StaticLenses.t.sol).

**Retained formal results:** [check_dynamicArray: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_dynamicArray.json), [check_navReencodedWordsMatchSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_navReencodedWordsMatchSolc.json), [check_staticTerminals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_staticTerminals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: primary Halmos families remain scalar terminals, uint8[] and the listed nested narrow-word geometries. The supplemental caller proof connects all returned static/dynamic values to the independent recursive validator; recursive codec error offsets propagate unchanged, with nested dirty-word error bytes pinned concretely.

## C31

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nav_checksOnlyTheReturnedValue` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol); `check_navSkipsSiblings` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_navSkipsSiblings](../contracts/tests/OperandsSymbolic.t.sol), [test_nav_checksOnlyTheReturnedValue](../contracts/tests/StaticLenses.t.sol).

**Retained formal results:** [check_navSkipsSiblings: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_navSkipsSiblings.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Primary Halmos covers selecting one uint8 of two. Source cursor correspondence preserves selective head reads and validates only the returned terminal; an unvisited dirty sibling and a loose parent offset are concrete oracle cases.

## C32

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_bytesValue` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol) (output must re-encode to itself under solc); `test_nav_rejectsDirtyPaddingOfBytesTerminal` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [test_nav_rejectsDirtyPaddingOfBytesTerminal](../contracts/tests/StaticLenses.t.sol).

**Retained formal results:** [check_bytesValue: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_bytesValue.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Primary Halmos retains byte lengths 0, 1, 31, 32, 33, 64. The source extent theorem proves the exact first dirty byte for arbitrary finite payloads, and 32 bitvector cases verify the actual padding mask.

## C33

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `check_arrayOfBytes` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `stays typed under data corruption` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_reencodeRejectsMalformedNestedOffset` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); check_navDynamicTuple [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navDynamicArrays [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navDynamicDirtyWords [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_arrayOfBytes](../contracts/tests/NavSymbolic.t.sol), [check_navDynamicArrays](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navDynamicDirtyWords](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navDynamicTuple](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_nav_reencodeRejectsMalformedNestedOffset](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_arrayOfBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_arrayOfBytes.json), [check_navDynamicArrays: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicArrays.json), [check_navDynamicDirtyWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicDirtyWords.json), [check_navDynamicTuple: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicTuple.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Canonical selected dynamic tuple/array terminals match independent solc encodings, including inner arrays and negative scalar selection. Nested arrays have two elements of two words each; composite arrays have two numbers and byte payloads of length 1/33. Dirty narrow words reject at exact sentinel-located source offsets. Other layouts, lengths and corruption classes retain separate evidence.

## C34

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_dynamicArray` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol).

**Retained formal results:** [check_dynamicArray: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_dynamicArray.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Primary Halmos retains offsets 0x20, 0x40, 0x1000, 2^256-1 and counts 0..3 / maximum. Source correspondence covers arbitrary finite counts with checked stride multiplication and zero-copy cursor panic outcomes preserved.

## C35

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (negative array indices), empty arrays `:250-253`; `check_dynamicArray` (0, 1, -1, past end); `test_nav_indexOutOfBounds` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navNegativeTupleIndexCountsComponents` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); check_navSignedArraySelections [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navArrayIndexRefusal [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navTupleIndexRefusal [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol), [check_navArrayIndexRefusal](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navSignedArraySelections](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navTupleIndexRefusal](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_navNegativeTupleIndexCountsComponents](../contracts/tests/MutationGaps.t.sol), [test_nav_indexOutOfBounds](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_dynamicArray: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_dynamicArray.json), [check_navArrayIndexRefusal: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navArrayIndexRefusal.json), [check_navSignedArraySelections: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navSignedArraySelections.json), [check_navTupleIndexRefusal: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navTupleIndexRefusal.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Fixed/dynamic arrays accept each literal index in -3..2 with the independent expected element. All remaining int256 indices except the final LEN/PAYLOAD sentinels reject with exact index/count. A two-component tuple rejects every negative/out-of-range ordinary index. Data and descriptors are valid controls; arbitrary index-versus-malformation error ordering and other geometries are not established.

## C36

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** deliberate leaf steps [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_invalidSteps` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navErrorsAtNonzeroPositions` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); check_navNonCompositeRefusal [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_navNonCompositeRefusal](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_navErrorsAtNonzeroPositions](../contracts/tests/MutationGaps.t.sol), [test_nav_invalidSteps](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_navNonCompositeRefusal: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navNonCompositeRefusal.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: An attempted second step into a scalar, bytes or string terminal reports exact InvalidNavigation(1). Dynamic controls have a fitting parent offset but no body, so this refusal cannot depend on a later body read. Other positions, path lengths and base names are outside these selected cases.

## C37

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C37_SelectedTupleArrayValuesAndSkippedSiblingPolicy`; retained supporting evidence: `stays typed under data corruption` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `testNavNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol); hostile offsets in `check_dynamicArray`/`check_bytesValue` (soundness only); `test_navArrayCountNamesItsWord` .. `test_navPayloadBounded` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); check_navStaticTerminals [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navStaticDirtyWords [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navDynamicTuple [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navDynamicArrays [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navDynamicDirtyWords [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol), [check_navDynamicArrays](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navDynamicDirtyWords](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navDynamicTuple](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navStaticDirtyWords](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navStaticTerminals](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [test_C37_SelectedTupleArrayValuesAndSkippedSiblingPolicy](../contracts/tests/ClaimCoverageModerate.t.sol), [test_navArrayCountNamesItsWord](../contracts/tests/MutationGaps.t.sol), [test_navPayloadBounded](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_bytesValue: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_bytesValue.json), [check_dynamicArray: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_dynamicArray.json), [check_navDynamicArrays: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicArrays.json), [check_navDynamicDirtyWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicDirtyWords.json), [check_navDynamicTuple: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicTuple.json), [check_navStaticDirtyWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navStaticDirtyWords.json), [check_navStaticTerminals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navStaticTerminals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: The selected static and dynamic terminal cases additionally check canonical solc output and exact dirty-word refusal. They do not establish all parent-offset, skipped-sibling, sentinel or unread-descriptor behaviors. Earlier concrete cases and their native/source discussions retain their original separate provenance.

## C38

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C38_DescriptorParsedAlongThePath`, `testFuzz_C38_UnreadDescriptorTextCannotChangeTheResult`; retained supporting evidence: `stays typed under descriptor mutation` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_invalidSteps` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navRefusesTrailingDescriptorText` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); check_behaviorUnreadDescriptorTextIndependent [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol); check_behaviorVisitedDescriptorErrorsBeforeData [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`_navigate`, `_navTupleStep`, `_closesTuple`, `_navArrayStep`)

**Test/property definitions:** [check_behaviorUnreadDescriptorTextIndependent](../contracts/tests/ClaimUnreadSymbolic.t.sol), [check_behaviorVisitedDescriptorErrorsBeforeData](../contracts/tests/ClaimUnreadSymbolic.t.sol), [testFuzz_C38_UnreadDescriptorTextCannotChangeTheResult](../contracts/tests/ClaimCoverageModerate.t.sol), [test_C38_DescriptorParsedAlongThePath](../contracts/tests/ClaimCoverageModerate.t.sol), [test_navRefusesTrailingDescriptorText](../contracts/tests/MutationGaps.t.sol), [test_nav_invalidSteps](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_behaviorUnreadDescriptorTextIndependent: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorUnreadDescriptorTextIndependent.json), [check_behaviorVisitedDescriptorErrorsBeforeData: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorVisitedDescriptorErrorsBeforeData.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Two independently symbolic descriptor tails without parentheses leave component zero of a flat tuple unchanged. Tail lengths are 0, 1, 4 and 8. Entered/passed zero arrays, an invalid delimiter, an earlier tuple closing parenthesis and zero/oversized tuple-array suffixes reject at exact positions before empty or valid data is read. Parentheses and layout-defining structure are not treated as unread. The larger interrupted probe grants no credit; arbitrary descriptor lengths, paths and nesting need separate evidence.

## C39

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C39_FourLevelDynamicArraySelection`; retained supporting evidence: `nav differential fuzz` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (`genType(rng, 2)` under the top tuple); `test_nav_nestedDynamicArrays` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_nav_structArraySteps` `:308`

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [test_C39_FourLevelDynamicArraySelection](../contracts/tests/ClaimCoverageModerate.t.sol), [test_nav_nestedDynamicArrays](../contracts/tests/CoreReads.t.sol), [test_nav_structArraySteps](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** Partial: concrete selection now includes four-level dynamic arrays and terminal-array encoding, complementing the older bounded differential shapes. These runtime examples do not establish arbitrary finite nesting. Retained inductive source correspondence has explicit arithmetic and resource premises and has not been rerun here.

## C40

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_dynamicArray`, `check_bytesValue`, `check_arrayOfBytes` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol), `:143`, `:177`; `utf8Len` oracle [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_arrayOfBytes](../contracts/tests/NavSymbolic.t.sol), [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [check_dynamicArray](../contracts/tests/NavSymbolic.t.sol).

**Retained formal results:** [check_arrayOfBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_arrayOfBytes.json), [check_bytesValue: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_bytesValue.json), [check_dynamicArray: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_dynamicArray.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Source LengthAt and LengthCanonical connect arbitrary canonical byte/array lengths to the mode result; primary Halmos cases remain bounded.

## C41

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `sentinelExpect` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts), bare `[LEN]` `:226`; `test_nav_staticComposites_keepSentinelRestrictions` [contracts/tests/StaticLenses.t.sol](../contracts/tests/StaticLenses.t.sol); check_navLengthRefusals [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`_navLength`)

**Test/property definitions:** [check_navLengthRefusals](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_nav_staticComposites_keepSentinelRestrictions](../contracts/tests/StaticLenses.t.sol).

**Retained formal results:** [check_navLengthRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navLengthRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Empty prefixes, scalar/static-array/static-tuple terminals reject exactly. A selected dynamic tuple or fixed array of bytes first reads its selected word: a missing word reports ReturnDataOutOfBounds(1,32), while complete controls report InvalidNavigation(1). These are explicit shapes and positions, not every descriptor or truncation geometry.

## C42

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nav_len_requiresPaddedBytesPayload` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_nav_len_rejectsMissingPayloadAndHostileCounts` `:381`; `test_navLengthBounded` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_lenDoesNotTraverseTails` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_lenDoesNotTraverseTails](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_navLengthBounded](../contracts/tests/MutationGaps.t.sol), [test_nav_len_rejectsMissingPayloadAndHostileCounts](../contracts/tests/CoreReads.t.sol), [test_nav_len_requiresPaddedBytesPayload](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_lenDoesNotTraverseTails: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_lenDoesNotTraverseTails.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Primary Halmos covers two symbolic string[] heads. The source function checks only the rounded byte footprint or array head footprint; neither array tails nor narrow element words are visited. Concrete cases pin both omissions.

## C43

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_bytesValue` [contracts/tests/NavSymbolic.t.sol](../contracts/tests/NavSymbolic.t.sol); `check_arrayOfBytes` `:177`; `sentinelExpect` [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `test_nav_payload_reentryDynamicContent` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_arrayOfBytes](../contracts/tests/NavSymbolic.t.sol), [check_bytesValue](../contracts/tests/NavSymbolic.t.sol), [test_nav_payload_reentryDynamicContent](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_arrayOfBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_arrayOfBytes.json), [check_bytesValue: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NavSymbolicTest.check_bytesValue.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The source theorem returns the exact unpadded byte slice for arbitrary fitting payloads. Existing bounded runtime cases continue to cover outer-nav reentry.

## C44

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts), `:227`; `test_nav_payload_invalidTerminals` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_nav_payloadStillRefusesArraysAndTuples` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); check_navPayloadRefusals [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_navPayloadRefusals](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_nav_payloadStillRefusesArraysAndTuples](../contracts/tests/CoreExtensions.t.sol), [test_nav_payload_invalidTerminals](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_navPayloadRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navPayloadRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Empty prefixes and selected non-byte scalar/array/tuple terminals reject with the exact descriptor position. Dynamic controls have a fitting parent offset and an absent selected body, so rejection must precede the length read. Existing byte/string success properties remain freshly revalidated; arbitrary families and paths remain outside coverage.

## C45

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nav_payload_lyingLength` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_navPayloadBounded` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `test_navPayloadRefusesLengthJustPast` `:762`; `check_lenAndPayloadStayInsideTheData` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_lenAndPayloadStayInsideTheData](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_navPayloadBounded](../contracts/tests/MutationGaps.t.sol), [test_navPayloadRefusesLengthJustPast](../contracts/tests/MutationGaps.t.sol), [test_nav_payload_lyingLength](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_lenAndPayloadStayInsideTheData: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_lenAndPayloadStayInsideTheData.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Primary Halmos retains lengths 0, 5, 32, 33, 64, 65 and maximum over two words. Source payload bounds/error fields are unbounded in byte length subject to uint256 and memory premises; an actual source boundary mutant fails both proof and EVM oracle.

## C46

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testFuzzBoundedReadsNeverPanic` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) (random paths, no-panic only); `int256.min` guard [contracts/Assertions.sol](../contracts/Assertions.sol); `check_nonterminalSentinels` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (`LEN` and `PAYLOAD` as a tuple component index, as an index into a nested `uint8[]` and into a `bytes[]`, each `ElementIndexOutOfBounds(sentinel, 2)`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_nonterminalSentinels](../contracts/tests/ConstructorsSymbolic.t.sol), [testFuzzBoundedReadsNeverPanic](../contracts/tests/CoreNoPanic.t.sol).

**Retained formal results:** [check_nonterminalSentinels: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstructorsSymbolicTest.check_nonterminalSentinels.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: primary Halmos retains three mid-path positions. Source normalization/count bounds and canonical path induction now cover arbitrary finite paths; nonfinal sentinels go through ordinary navigation failure. The pick primitive remains outside this caller proof.

## C47

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_C47_NavigationGasBudgetFailureAndSuccessfulControl`; retained supporting evidence: `testNavNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol) (10M gas per call)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [test_C47_NavigationGasBudgetFailureAndSuccessfulControl](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** The same valid navigation input fails under a 1,000-gas budget and succeeds with 1,000,000 gas. This witnesses resource failure; it does not characterize every possible arithmetic, stack or memory limit.

## C48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_chainHopWordMustBeClean` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol); `genChain` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:56`

**Test/property definitions:** [check_chainHopWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol).

**Retained formal results:** [check_chainHopWordMustBeClean: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_chainHopWordMustBeClean.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bounded: two hops

## C49

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_targetWordMustBeClean` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol); `check_chainHopWordMustBeClean` `:176`

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_chainHopWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol), [check_targetWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol).

**Retained formal results:** [check_chainHopWordMustBeClean: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_chainHopWordMustBeClean.json), [check_targetWordMustBeClean: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_targetWordMustBeClean.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Mid-chain index proved at hop 0 (reported 1) only

## C50

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_chain_emptyCalls` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_chainNamesTheHop` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_chainNamesTheHop](../contracts/tests/OperandsSymbolic.t.sol), [test_chain_emptyCalls](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_chainNamesTheHop: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_chainNamesTheHop.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved with the other `chain` outcomes (empty chain case)

## C51

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_chain_midHopEmptyReturn` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_chainNamesTheHop` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_chainNamesTheHop](../contracts/tests/OperandsSymbolic.t.sol), [test_chain_midHopEmptyReturn](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_chainNamesTheHop: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_chainNamesTheHop.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a start or hop returning five bytes reverts `ReturnDataOutOfBounds(0, 5)`

## C52

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_chain_midHopReverts` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_chainNamesTheHop` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_chainNamesTheHop](../contracts/tests/OperandsSymbolic.t.sol), [test_chain_midHopReverts](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_chainNamesTheHop: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_chainNamesTheHop.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a reverting or code-less hop reverts `CallFailed` with that hop's target and calldata, and a dirty hop word `InvalidAddressWord` at the next hop's index; a planted wrong hop index fails it

## C53

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `genRead` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_read_*` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_readSendsRawSegmentsInOrder` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:70`

**Test/property definitions:** [check_readSendsRawSegmentsInOrder](../contracts/tests/CoreSymbolic.t.sol).

**Retained formal results:** [check_readSendsRawSegmentsInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_readSendsRawSegmentsInOrder.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: over three segments of 0, 5, 32 or 33 bytes with symbolic contents, `read` sends exactly selector ++ segments, raw and in order, as the core, and returns the raw returndata. Longer argument lists are bounded out

## C54

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_targetWordMustBeClean` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:497-498`, `:538-539`

**Test/property definitions:** [check_targetWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol).

**Retained formal results:** [check_targetWordMustBeClean: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_targetWordMustBeClean.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## C55

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_read_codelessTarget` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_read_constructedCallReverts` `:737`; `test_get_codelessTargetAndDirtyWord` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_readAndGetReportTheirCall` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:546-547`

**Test/property definitions:** [check_readAndGetReportTheirCall](../contracts/tests/OperandsSymbolic.t.sol), [test_get_codelessTargetAndDirtyWord](../contracts/tests/CoreExtensions.t.sol), [test_read_codelessTarget](../contracts/tests/CoreReads.t.sol), [test_read_constructedCallReverts](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_readAndGetReportTheirCall: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_readAndGetReportTheirCall.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: code-less and reverting targets revert `CallFailed` with the exact constructed calldata, for `read` and for `get`

## C56

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_read_argConstraint_identifiesOperand` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_get_constraintNamesTheArgument` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_readNamesItsOperands` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:539-541`

**Test/property definitions:** [check_readNamesItsOperands](../contracts/tests/OperandsSymbolic.t.sol), [test_get_constraintNamesTheArgument](../contracts/tests/CoreExtensions.t.sol), [test_read_argConstraint_identifiesOperand](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_readNamesItsOperands: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_readNamesItsOperands.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for `read`: target 0 (dirty word), arguments at index + 1 (first failing constraint), byte for byte; a planted index bug fails it. `get`'s naming stays unit-tested

## C57

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_getStaticArgumentsMatchSolc` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol) and `check_chainHopWordMustBeClean` `:176` (Echo returns its caller); `test_caller_coreForReadAndGet` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); check_behaviorConstructedCallers [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** `AGENTS.md:53-55`, [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_behaviorConstructedCallers](../contracts/tests/ClaimConstructionSymbolic.t.sol), [check_chainHopWordMustBeClean](../contracts/tests/CoreSymbolic.t.sol), [check_getStaticArgumentsMatchSolc](../contracts/tests/CoreSymbolic.t.sol), [test_caller_coreForReadAndGet](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_behaviorConstructedCallers: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorConstructedCallers.json), [check_chainHopWordMustBeClean: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_chainHopWordMustBeClean.json), [check_getStaticArgumentsMatchSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_getStaticArgumentsMatchSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: An independent caller/calldata reflector sees the core through read, get and chain, with one unrestricted word. The caller mutation preserves destination and calldata while inserting a relay, and is rejected. Existing get and chain evidence is retained; arbitrary argument lists and hop counts remain outside the new property.

## C58

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_getStaticArgumentsMatchSolc` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol); `check_getDynamicArgumentsMatchSolc` `:76`

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `AGENTS.md:51-52`

**Test/property definitions:** [check_getDynamicArgumentsMatchSolc](../contracts/tests/CoreSymbolic.t.sol), [check_getStaticArgumentsMatchSolc](../contracts/tests/CoreSymbolic.t.sol).

**Retained formal results:** [check_getDynamicArgumentsMatchSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_getDynamicArgumentsMatchSolc.json), [check_getStaticArgumentsMatchSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_getStaticArgumentsMatchSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Two descriptors: `(uint8,address,bool,bytes4)` and `(uint256,string,uint8[])`

## C59

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_get_componentCountMismatch` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `test_get_valueMustFitItsType` `:160`; `testFuzzBoundedReadsNeverPanic` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); `check_getNamesArgumentsInCodecErrors` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol); check_behaviorGetMalformedDescriptor [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_behaviorGetMalformedDescriptor](../contracts/tests/ClaimConstructionSymbolic.t.sol), [check_getNamesArgumentsInCodecErrors](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [testFuzzBoundedReadsNeverPanic](../contracts/tests/CoreNoPanic.t.sol), [test_get_componentCountMismatch](../contracts/tests/CoreExtensions.t.sol), [test_get_valueMustFitItsType](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_behaviorGetMalformedDescriptor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorGetMalformedDescriptor.json), [check_getNamesArgumentsInCodecErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_getNamesArgumentsInCodecErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: get reports InvalidTypeDescriptor at exact positions for a zero fixed array, an empty tuple supplied one value, an unclosed tuple and a bad component delimiter. Existing (uint8,string) component count/length/envelope/value properties also remain freshly revalidated. Arbitrary malformed descriptor grammars and argument shapes are not established.

## C60

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_get_emptyDescriptor` [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_readAndGetReportTheirCall` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:870-871`

**Test/property definitions:** [check_readAndGetReportTheirCall](../contracts/tests/OperandsSymbolic.t.sol), [test_get_emptyDescriptor](../contracts/tests/CoreExtensions.t.sol).

**Retained formal results:** [check_readAndGetReportTheirCall: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_readAndGetReportTheirCall.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `get` with `"()"` and no arguments sends the bare selector

## C62

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_condIsLazyAndJudgesFirstWord` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `test_cond_losingBranchNeverResolved` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), [website/src/content/docs/docs/evml.md](../website/src/content/docs/docs/evml.md)

**Test/property definitions:** [check_condIsLazyAndJudgesFirstWord](../contracts/tests/ControlSymbolic.t.sol), [test_cond_losingBranchNeverResolved](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_condIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_condIsLazyAndJudgesFirstWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos bomb fails by constraint; the unit test uses a reverting call

## C63

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_condIsLazyAndJudgesFirstWord` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_condIsLazyAndJudgesFirstWord](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_condIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_condIsLazyAndJudgesFirstWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Lengths 0, 31, 32, 64

## C64

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_condIsLazyAndJudgesFirstWord`; `test_cond_dynamicWinnerPassthrough` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_cond_winnerConstraintValidated` `:942`

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_condIsLazyAndJudgesFirstWord](../contracts/tests/ControlSymbolic.t.sol), [test_cond_dynamicWinnerPassthrough](../contracts/tests/CoreReads.t.sol), [test_cond_winnerConstraintValidated](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_condIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_condIsLazyAndJudgesFirstWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Word values proved; dynamic winner and winner constraints UNIT

## C65

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_cond_conditionConstraintValidated` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_cond_winnerConstraintValidated` `:942`; `check_condNamesItsOperandsAndIsLazy` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_condNamesItsOperandsAndIsLazy](../contracts/tests/OperandsSymbolic.t.sol), [test_cond_conditionConstraintValidated](../contracts/tests/CoreReads.t.sol), [test_cond_winnerConstraintValidated](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_condNamesItsOperandsAndIsLazy: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_condNamesItsOperandsAndIsLazy.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: the condition is operand 0, then 1, else 2, and the branch not chosen is never judged; a planted index bug fails it

## C66

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_C66_C70_ControlFailureMatrix`; retained supporting evidence: `check_orElseAndIsValidAgree` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `genOrElse` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_orElse_revertSelectsFallback` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_orElse_codelessTargetSelectsFallback` `:1003`; check_behaviorOrElseCallOutcomes [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol); check_behaviorReservedSignalAcrossControlRoutes [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:62`, `:72`

**Test/property definitions:** [check_behaviorOrElseCallOutcomes](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [check_behaviorReservedSignalAcrossControlRoutes](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [check_orElseAndIsValidAgree](../contracts/tests/ControlSymbolic.t.sol), [test_C66_C70_ControlFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_orElse_codelessTargetSelectsFallback](../contracts/tests/CoreReads.t.sol), [test_orElse_revertSelectsFallback](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_behaviorOrElseCallOutcomes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorOrElseCallOutcomes.json), [check_behaviorReservedSignalAcrossControlRoutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorReservedSignalAcrossControlRoutes.json), [check_orElseAndIsValidAgree: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_orElseAndIsValidAgree.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: RAW_BYTES/STATIC_CALL success, ordinary target failure, a code-less target, malformed static-call data and a failed EQ choose the documented outcome. A STATIC_CALL fallback is lazy and resolves once. The exact reserved signal is separately required to propagate. Ordinary failures exclude only the symbolic exhaustion artifact; actual gas exhaustion and arbitrary operand trees remain outside the symbolic result.

## C67

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_orElse_fallbackFailurePropagates` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_orElseFallbackIsOperandOne` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_orElseFallbackIsOperandOne](../contracts/tests/OperandsSymbolic.t.sol), [test_orElse_fallbackFailurePropagates](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_orElseFallbackIsOperandOne: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_orElseFallbackIsOperandOne.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: the fallback resolves in-frame and its failure is `ConstraintFailed` naming operand 1

## C68

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_orElse_chainedFallbacks` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_orElseChainTriesInOrder` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_orElseChainTriesInOrder](../contracts/tests/OperandsSymbolic.t.sol), [test_orElse_chainedFallbacks](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_orElseChainTriesInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_orElseChainTriesInOrder.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved over three sources: the first that resolves wins; when none does the outer frame reports the inner orElse as `CallFailed`

## C69

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_directAndRawCallGasSweeps`, `test_wordCallbackGasSweeps`, `test_valueCallbackGasSweeps`, `test_expressionCallbackGasSweeps`, `test_nestedCoreRawCallGasSweeps`, `test_exactSignalSurvivesEveryWrapperAndProbe`, `test_ordinaryErrorsKeepExactWrappers`; existing core/Expressions gas tests; `docs/verification/gas-propagation/mutations.json`

**Supporting sources:** `_rejectOutOfGas` in [contracts/Assertions.sol](../contracts/Assertions.sol), [contracts/Operations.sol](../contracts/Operations.sol), [contracts/Collections.sol](../contracts/Collections.sol), [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [test_directAndRawCallGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_exactSignalSurvivesEveryWrapperAndProbe](../contracts/tests/GasPropagation.t.sol), [test_expressionCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_nestedCoreRawCallGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_ordinaryErrorsKeepExactWrappers](../contracts/tests/GasPropagation.t.sol), [test_valueCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_wordCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol).

**Scope and limitations:** Finite identical 6000-hash workload; 100k–3M gas in 50k steps and 5M success, through all six probes; EQ-zero assertion rejected at 1M and 5M. Removing each of the three new guards kills its regression. Halmos has no concrete gas model. Guarantee requires immediate-call exhaustion detection or preserved reserved signal: arbitrary external targets that hide errors or branch on gas are excluded. Ordinary failures near the exhaustion threshold may conservatively reject. Exact four-byte marker is reserved, not authenticated; trailing bytes remain ordinary errors.

## C85

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_extendedValidityLeafConstraints; check_extendedValidityOrWordConstraints; check_extendedValidityOrOrderedRanges; check_extendedValidityOrReversedRanges; check_extendedValidityTwoWordConstraints; check_extendedValidityBalances; check_extendedValidityMalformedFetchers [contracts/tests/ClaimValidityFamiliesSymbolic.t.sol](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol); check_claimValidityIsResolution; check_claimValidityOrdinaryFailure; check_claimValidityReservedSignal [contracts/tests/ClaimControlSymbolic.t.sol](../contracts/tests/ClaimControlSymbolic.t.sol); test_C66_C70_ControlFailureMatrix [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol); testEmptyAndUnconstrainedAssertionsAndFalseReturnPass [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol); test_isValid_constraintViolation [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Replaces:** [C70](#c70), [C84](#c84); each prior statement and its evidence are retained below.

**Recorded run:** [results, commands and source hashes](halmos-extensions-20261012.md).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`isValid`)

**Test/property definitions:** [check_claimValidityIsResolution](../contracts/tests/ClaimControlSymbolic.t.sol), [check_claimValidityOrdinaryFailure](../contracts/tests/ClaimControlSymbolic.t.sol), [check_claimValidityReservedSignal](../contracts/tests/ClaimControlSymbolic.t.sol), [check_extendedValidityBalances](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [check_extendedValidityLeafConstraints](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [check_extendedValidityMalformedFetchers](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [check_extendedValidityOrOrderedRanges](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [check_extendedValidityOrReversedRanges](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [check_extendedValidityOrWordConstraints](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [check_extendedValidityTwoWordConstraints](../contracts/tests/ClaimValidityFamiliesSymbolic.t.sol), [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol), [test_C66_C70_ControlFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_isValid_constraintViolation](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_claimValidityIsResolution: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlSymbolicTest.check_claimValidityIsResolution.json), [check_claimValidityOrdinaryFailure: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlSymbolicTest.check_claimValidityOrdinaryFailure.json), [check_claimValidityReservedSignal: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlSymbolicTest.check_claimValidityReservedSignal.json), [check_extendedValidityBalances: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityBalances.json), [check_extendedValidityLeafConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityLeafConstraints.json), [check_extendedValidityMalformedFetchers: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityMalformedFetchers.json), [check_extendedValidityOrOrderedRanges: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityOrOrderedRanges.json), [check_extendedValidityOrReversedRanges: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityOrReversedRanges.json), [check_extendedValidityOrWordConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityOrWordConstraints.json), [check_extendedValidityTwoWordConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimValidityFamiliesSymbolicTest.check_extendedValidityTwoWordConstraints.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the extension covers all eight non-OR constraint kinds over one RAW_BYTES or STATIC_CALL word; two-leaf ORs use a selected first leaf and EQ second leaf, including ordered and reversed signed/unsigned ranges. A visited reversed range aborts OR before the second equality leaf. Two RAW_BYTES words have positional GTE/LTE constraints in both signednesses. BALANCE uses every uint256 amount and symbolic account, native balances or a configured token, zero/one EQ constraint, token failure and a code-less token. Six malformed STATIC_CALL/BALANCE encodings are separate expected-failure cases. Original validity and exact reserved-signal properties are freshly revalidated. Ordinary failures exclude Halmos gas artifacts explicitly; actual exhaustion remains concrete. Arbitrary operand trees, OR shapes and constraint counts are outside these bounds.

## C71

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_isValid_overRevertData` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_isValidOfRevertDataMatchesTheSelector` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_isValidOfRevertDataMatchesTheSelector](../contracts/tests/OperandsSymbolic.t.sol), [test_isValid_overRevertData](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_isValidOfRevertDataMatchesTheSelector: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_isValidOfRevertDataMatchesTheSelector.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: 1 exactly when the probed call reverts and, for a nonzero selector, its data (0, 3, 4 or 32 bytes) starts with it

## C72

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataMatchesSelector` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_revertDataMatchesSelector](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_revertDataMatchesSelector: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_revertDataMatchesSelector.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Lengths 0, 3, 4, 36, 64

## C73

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataRefusals` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:691`

**Test/property definitions:** [check_revertDataRefusals](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_revertDataRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_revertDataRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## C74

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataRefusals` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:699-700`

**Test/property definitions:** [check_revertDataRefusals](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_revertDataRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_revertDataRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: RAW_BYTES and one constraint only; BALANCE operand not covered

## C75

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataRefusals` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`revertData`)

**Test/property definitions:** [check_revertDataRefusals](../contracts/tests/ControlSymbolic.t.sol).

**Retained formal results:** [check_revertDataRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_revertDataRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## C76

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_revertDataMatchesSelector` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `test_revertData_batchFailsOnExactConstraint` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol), `:110`, `:133`

**Test/property definitions:** [check_revertDataMatchesSelector](../contracts/tests/ControlSymbolic.t.sol), [test_revertData_batchFailsOnExactConstraint](../contracts/tests/CoreReads.t.sol).

**Retained formal results:** [check_revertDataMatchesSelector: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ControlSymbolicTest.check_revertDataMatchesSelector.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Nested case UNIT

## C77

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testReadsAndBatchRejectImpossibleDecoderAllocation`, `testOrRejectsImpossibleDecoderAllocation`, `testFuzzBoundedReadAndBatchSucceed` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); [docs/halmos-checks.json](halmos-checks.json) isolated replay source/results (`test_decoderAllocationFailure0`, `test_decoderAllocationFailure1`, `test_orDecoderAllocationFailure`); retained supporting evidence: `testFuzzPrimitivesNeverPanic`, `testFuzzBoundedReadsNeverPanic`, `testFuzzBoundedBatchNeverPanics` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol), `:97`, `:124`

**Recorded run:** [results, commands and source hashes](bounded-test-checks.json).

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

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`; check_behaviorEmptyBatch [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`assertBatch`)

**Test/property definitions:** [check_behaviorEmptyBatch](../contracts/tests/ClaimConstructionSymbolic.t.sol), [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Retained formal results:** [check_behaviorEmptyBatch: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorEmptyBatch.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Both default and fixed custom-message overloads accept the empty batch and return no bytes. This acceptance imposes no predicate; it is not an executor or nonempty-batch proof.

## C82

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`; check_behaviorEmptyUnconstrainedRaw [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`assertParam`, `resolve`)

**Test/property definitions:** [check_behaviorEmptyUnconstrainedRaw](../contracts/tests/ClaimConstructionSymbolic.t.sol), [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Retained formal results:** [check_behaviorEmptyUnconstrainedRaw: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorEmptyUnconstrainedRaw.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Default assertParam accepts an empty RAW_BYTES payload with no constraints for each legal paramType. The returned data is empty. No predicate is asserted by the empty constraint list.

## C83

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`; check_behaviorBatchDiscardsSuccessfulReturndata [contracts/tests/ClaimConstructionSymbolic.t.sol](../contracts/tests/ClaimConstructionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`assertBatch`)

**Test/property definitions:** [check_behaviorBatchDiscardsSuccessfulReturndata](../contracts/tests/ClaimConstructionSymbolic.t.sol), [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Retained formal results:** [check_behaviorBatchDiscardsSuccessfulReturndata: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimConstructionSymbolicTest.check_behaviorBatchDiscardsSuccessfulReturndata.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A constructed call returns any 32-byte word, including encoded false, or a canonical 33-byte bytes payload. Both message overloads accept successful calls and discard their complete returndata. The observer confirms one call. Arbitrary return lengths, batch sizes and resource exhaustion are outside these selected shapes.

## A1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (token-level recursive-descent reference); descriptor mutation fuzz [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); units [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_tupleLayoutInvalidCharacter` [contracts/tests/TupleLayoutSymbolic.t.sol](../contracts/tests/TupleLayoutSymbolic.t.sol) (every byte outside `[a-z0-9]` and `(),[]` at one position: uppercase, whitespace and non-ASCII included), `check_tupleLayoutMalformed` (stray `)`, trailing text, empty component, missing comma, bare name, `()`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:105-109

**Test/property definitions:** [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [check_tupleLayoutInvalidCharacter](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutMalformed](../contracts/tests/TupleLayoutSymbolic.t.sol).

**Retained formal results:** [check_shapeMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_shapeMatchesReference.json), [check_tupleLayoutInvalidCharacter: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutInvalidCharacter.json), [check_tupleLayoutMalformed: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutMalformed.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its 4-token/11-token bound and single-position invalid-alphabet case. The supplemental source proof now characterizes whole-parser acceptance iff an Admissible tree renders to the input, and matches every outcome to the recursive reference, including rejection positions and checked arithmetic panics. Admissibility includes intermediate tuple-sum bounds; sufficient EVM resources are assumed. The older mutation fuzzer still lacks uppercase, whitespace, underscore and non-ASCII mutations; the new oracle includes a nested non-ASCII sentinel.

## A2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (asserts dynamic flag)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol).

**Retained formal results:** [check_shapeMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_shapeMatchesReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos remains bounded to 4 tokens. The supplemental parser proof covers dynamic flags for arbitrary admissible recursive grammar trees in both directions. Names are erased to Opaque only in the head-shape model; the tuple successor uses the actual narrow-rule whitelist for static traversal.

## A3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol); `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol).

**Retained formal results:** [check_shapeFixedLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NoPanicSymbolicTest.check_shapeFixedLengths.json), [check_shapeMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_shapeMatchesReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The supplemental source proof establishes exact head widths and recursive ShapesFit for every successful parse, plus acceptance completeness for Admissible trees. Dynamic tuples have final width one but their intermediate component sum must still fit uint256. The recorded translation/calldata/resource assumptions remain. The connection successor carries the actual narrow-word rules into the independent ABI type and proves body array-head and first-pass tuple-head sizes from source parsing.

## A4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol) (asserts selector on rejection); `testHugeFixedLengthsRevertInvalidTypeDescriptor` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); sweep `testPackNeverPanics`/`testUnpackNeverPanics`/`testNavNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol), 47, 60

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:120-123

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [testHugeFixedLengthsRevertInvalidTypeDescriptor](../contracts/tests/AbiCodec.t.sol), [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [testPackNeverPanics](../contracts/tests/NoPanic.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol).

**Retained formal results:** [check_shapeFixedLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NoPanicSymbolicTest.check_shapeFixedLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The source parser characterizes acceptance by admissible grammar trees and matches all reference outcomes, retaining the source rejection order and checked arithmetic panics. Counts and static fixed-array footprints are at most uint32 maximum; bare tuple sums may exceed uint32 but must fit uint256. This is not a universal no-panic or no-resource-failure theorem.

## A5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testHugeFixedLengthsRevertInvalidTypeDescriptor` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (positions 18, 18, 21, 30); `check_oversizedLengthNamesItsDigit` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:121-122, [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_oversizedLengthNamesItsDigit](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [testHugeFixedLengthsRevertInvalidTypeDescriptor](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_oversizedLengthNamesItsDigit: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_oversizedLengthNamesItsDigit.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for every eleven-digit length: refused right after the digit that carries it past 2^32 - 1, and a zero length at the closing bracket

## A6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (`[0]` token); `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol) (fixedCase 0, leading-zero prefix); `testZeroLengthsRevertInvalidTypeDescriptor` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:123-124, [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [testZeroLengthsRevertInvalidTypeDescriptor](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_shapeFixedLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NoPanicSymbolicTest.check_shapeFixedLengths.json), [check_shapeMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_shapeMatchesReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The source parser proof excludes zero counts recursively, accepts arbitrarily long leading-zero positive counts within the stated bounds, and matches the exact reference rejection position for zero counts. Concrete tests pin [00] and nested cases. EVM resource qualifications remain.

## A7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** Follows from A3 plus A6 (`check_shapeMatchesReference` reference footprints are always >= 1); `testUnpackNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol) with counts up to 2^256 - 1 over `bytes32[0]` bases

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:123-126

**Related behavioral evidence:** [A3](#a3), [A6](#a6).

**Test/property definitions:** [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol).

**Retained formal results:** [check_shapeMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_shapeMatchesReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The source parser establishes positive head widths for every successful descriptor parse at arbitrary finite grammar depth; acceptance completeness retains all grammar and arithmetic bounds. No execution at unlimited on-chain depth is promised.

## A8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_shapeFixedLengths` [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol); `check_shapeMatchesReference` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (validity agrees, so no unexpected revert); [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (typed errors under mutation); `check_tupleLayoutSpans`, `check_tupleLayoutMalformed`, `check_tupleLayoutInvalidCharacter` [contracts/tests/TupleLayoutSymbolic.t.sol](../contracts/tests/TupleLayoutSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:290-295, [contracts/tests/NoPanicSymbolic.t.sol](../contracts/tests/NoPanicSymbolic.t.sol), commit cc29dd4

**Test/property definitions:** [check_shapeFixedLengths](../contracts/tests/NoPanicSymbolic.t.sol), [check_shapeMatchesReference](../contracts/tests/ParserSymbolic.t.sol), [check_tupleLayoutInvalidCharacter](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutMalformed](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutSpans](../contracts/tests/TupleLayoutSymbolic.t.sol).

**Retained formal results:** [check_shapeFixedLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NoPanicSymbolicTest.check_shapeFixedLengths.json), [check_shapeMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_shapeMatchesReference.json), [check_tupleLayoutInvalidCharacter: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutInvalidCharacter.json), [check_tupleLayoutMalformed: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutMalformed.json), [check_tupleLayoutSpans: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutSpans.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its recorded descriptor families. The combined source proof covers whole-parser and tupleLayout reference outcomes, including checked panics. Sufficient gas, stack and allocation remain assumptions; the constrained-gas 96-level parser oracle records empty returndata. No universal no-panic or typed-resource-error guarantee is made.

## A9

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** `testPackNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol), `testUnpackNeverPanics` :47, `testNavNeverPanics` :60

**Supporting sources:** [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol), AGENTS.md:293-295

**Test/property definitions:** [testNavNeverPanics](../contracts/tests/NoPanic.t.sol), [testPackNeverPanics](../contracts/tests/NoPanic.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol).

**Scope and limitations:** Concrete grid (5 bases x 8 lengths x 8 lengths x tail), not random; no oracle beyond "declared selector".

## A10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (every word, 12 names, oracle solc abi.decode); `check_nameRuleMatchesTable` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol) (28 names incl. `function`, hand-written ABI table); `testStaticWordsMatchSolcDecoder` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `testFunctionWordsAreLeftAligned` :163; `testBytes3RejectsDirtyWordWithEveryDescriptorPaddingByte` and `testBytes3AcceptsCanonicalWordWithEveryDescriptorPaddingByte` [contracts/tests/AbiWordBoundaries.t.sol](../contracts/tests/AbiWordBoundaries.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:115-119

**Test/property definitions:** [check_nameRuleMatchesTable](../contracts/tests/ParserSymbolic.t.sol), [check_wordMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testBytes3AcceptsCanonicalWordWithEveryDescriptorPaddingByte](../contracts/tests/AbiWordBoundaries.t.sol), [testBytes3RejectsDirtyWordWithEveryDescriptorPaddingByte](../contracts/tests/AbiWordBoundaries.t.sol), [testFunctionWordsAreLeftAligned](../contracts/tests/AbiCodec.t.sol), [testStaticWordsMatchSolcDecoder](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_nameRuleMatchesTable: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_nameRuleMatchesTable.json), [check_wordMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_wordMatchesSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its listed solc/name-table cases. The source-SMT classifier covers all 96 recognized narrow names and every 256-bit word, including descriptor boundaries; the combined source proof now integrates it through arbitrary finite static and dynamic recursion. The two production word-boundary regressions sweep every following byte. Translation, physical-memory and resource assumptions remain explicit.

## A11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_nameRuleMatchesTable` [contracts/tests/ParserSymbolic.t.sol](../contracts/tests/ParserSymbolic.t.sol); `testFullWidthAndUnrecognisedNamesAcceptEveryWord` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:119-120

**Test/property definitions:** [check_nameRuleMatchesTable](../contracts/tests/ParserSymbolic.t.sol), [testFullWidthAndUnrecognisedNamesAcceptEveryWord](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_nameRuleMatchesTable: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ParserSymbolicTest.check_nameRuleMatchesTable.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Oracle is a hand-written table (solc cannot decode `uint7`).

## A12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_fixedArrayOfTuplesMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (`(int8,bool)[2]`); `check_encodeMatchesSolc` :166 (`(uint8,bool,address,bytes4)`); `check_unpackNestedMatchesSolc` :202; `testDirtyWordsAreRejectedOnEveryPath` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `testFixedArraysOfTuplesCheckEveryCopy` :246; `test_rangeCheckAfterNestedTupleArray` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), `test_rangeCheckInTwoDigitFixedArray` :87, `test_rangeCheckAfterUnrecognisedName` :551; `check_dynamicTupleWordsMatchSolc` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol) (`(uint8,string)`, `(string,address)`, `(bool,bytes)`, `((address,uint8),string)`), `check_arrayOfNarrowTuplesMatchesSolc` (`(uint8,bool)[]`); `check_nestedFixedTupleCanonical` (`(uint8[2],string)`), `check_nestedFixedArrayCanonical` (`uint8[2][]`) and `check_nestedPayloadLengthBounds` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_nestedCountsAreBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (`(uint8[],string)`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_arrayOfNarrowTuplesMatchesSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_dynamicTupleWordsMatchSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_fixedArrayOfTuplesMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_nestedCountsAreBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_nestedFixedArrayCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedPayloadLengthBounds](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testDirtyWordsAreRejectedOnEveryPath](../contracts/tests/AbiCodec.t.sol), [testFixedArraysOfTuplesCheckEveryCopy](../contracts/tests/AbiCodec.t.sol), [test_rangeCheckAfterNestedTupleArray](../contracts/tests/MutationGaps.t.sol), [test_rangeCheckAfterUnrecognisedName](../contracts/tests/MutationGaps.t.sol), [test_rangeCheckInTwoDigitFixedArray](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_arrayOfNarrowTuplesMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_arrayOfNarrowTuplesMatchesSolc.json), [check_dynamicTupleWordsMatchSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_dynamicTupleWordsMatchSolc.json), [check_encodeMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_encodeMatchesSolc.json), [check_fixedArrayOfTuplesMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_fixedArrayOfTuplesMatchesSolc.json), [check_nestedCountsAreBoundedBeforeMultiplying: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_nestedCountsAreBoundedBeforeMultiplying.json), [check_nestedFixedArrayCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedArrayCanonical.json), [check_nestedFixedTupleCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedTupleCanonical.json), [check_nestedPayloadLengthBounds: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedPayloadLengthBounds.json), [check_unpackNestedMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackNestedMatchesSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the listed Halmos and solc cases retain their geometry bounds. The combined source proof now connects every static and dynamic ABI traversal path to the independent validator, including narrow and opaque leaves at arbitrary finite nesting. Zero copies suppress value reads while preserving the characterized checked-cursor failures. Codec correspondence is complete under its recorded translation, arithmetic and resource assumptions; navigation caller correspondence is now recorded in the supplemental navigation baseline; Expressions caller correspondence remains separate.

## A13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol); `check_unpackNestedMatchesSolc` :202 (accept iff solc decodes and re-encodes byte-equal); [test/collection-codec.test.ts](../test/collection-codec.test.ts) (viem fixtures accepted), :51 (malformed rejected); `test_packRejectsStaticValueOfWrongLength` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), `test_packRejectsMalformedDynamicValue` :69; `check_nestedFixedTupleCanonical`, `check_nestedFixedArrayCanonical`, `check_twoStringsCanonical` and `check_nestedPayloadLengthBounds` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol) (accepted exactly when solc decodes AND re-encodes byte-equal); `check_nestedCountsAreBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_nestedCountsAreBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_nestedFixedArrayCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_nestedPayloadLengthBounds](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_wordMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [test_packRejectsMalformedDynamicValue](../contracts/tests/MutationGaps.t.sol), [test_packRejectsStaticValueOfWrongLength](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_nestedCountsAreBoundedBeforeMultiplying: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_nestedCountsAreBoundedBeforeMultiplying.json), [check_nestedFixedArrayCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedArrayCanonical.json), [check_nestedFixedTupleCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedTupleCanonical.json), [check_nestedPayloadLengthBounds: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedPayloadLengthBounds.json), [check_twoStringsCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_twoStringsCanonical.json), [check_unpackNestedMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackNestedMatchesSolc.json), [check_wordMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_wordMatchesSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the Halmos runtime geometries remain bounded. The combined source proof connects both static and dynamic validate branches to the independent validator: success implies canonical encoding, and canonical acceptance equivalence holds under the stated cursor/resource budget. Malformed descriptor and checked-panic outcomes are retained. No chosen nesting/count bound is used; compiler correctness and general solc/viem equivalence remain outside this source theorem.

## A14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackNestedMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (inner offset cases 0x20, 0, 0x1f, max); `testEncodingRejectsMalformedNestedValues` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `test_bodyNamesTheBadOffset` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); [test/collection-codec.test.ts](../test/collection-codec.test.ts); `check_nestedFixedTupleCanonical` (string offset 128 over a stale word, top offset 64) and `check_twoStringsCanonical` (second offset 160 over a stale word, second offset 64 pointing back) [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_unpackNamesLooseOffsetsAndTrailingBytes` and `check_validateNamesTheOffendingWord` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (`InvalidValue` at the loose offset's own word)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNamesLooseOffsetsAndTrailingBytes](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_validateNamesTheOffendingWord](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testEncodingRejectsMalformedNestedValues](../contracts/tests/AbiCodec.t.sol), [test_bodyNamesTheBadOffset](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_nestedFixedTupleCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedTupleCanonical.json), [check_twoStringsCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_twoStringsCanonical.json), [check_unpackNamesLooseOffsetsAndTrailingBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_unpackNamesLooseOffsetsAndTrailingBytes.json), [check_unpackNestedMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackNestedMatchesSolc.json), [check_validateNamesTheOffendingWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_validateNamesTheOffendingWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its explicit offset cases, including the older uint8[][] exclusion of 0x40. The combined source proof checks tight offsets through arbitrary finite recursive arrays and tuples and through unpack, with source-derived guards and cursor bounds. The compiled-runtime evidence remains limited to its recorded geometries.

## A15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_bodyNamesTheDirtyPaddingByte` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (offset 64+5); `testEncodingRejectsMalformedNestedValues` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (last byte 0x01); [test/collection-codec.test.ts](../test/collection-codec.test.ts); `check_dirtyPaddingNamesItsByte` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_dirtyPaddingNamesItsByte](../contracts/tests/NarrowWordsSymbolic.t.sol), [testEncodingRejectsMalformedNestedValues](../contracts/tests/AbiCodec.t.sol), [test_bodyNamesTheDirtyPaddingByte](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_dirtyPaddingNamesItsByte: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_dirtyPaddingNamesItsByte.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos proves its two-byte string case. The arbitrary-length bytes/string source theorem and all 32 mask obligations are now connected through recursive dynamic callers and Value, TupleComponent and CallbackResult routing. The first dirty byte is preserved by the source padding scan; the combined EVM oracle pins nested/component errors. Translation, memory and resource assumptions remain.

## A16

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackArrayAcceptsOnlyCanonical_uint8` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (length case 2^256 - 1); `testEncodingRejectsOverflowingAndTruncatedLengths` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `test_bodyBoundsElementCount` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), `test_unpackBoundsElementCount` :332, `test_bodyBoundsTupleHead` :340, `test_bodyBoundsPaddedPayloadOnUnalignedValue` :513, `test_bodyBoundsHeadAfterAComponent` :535; `testUnpackNeverPanics` [contracts/tests/NoPanic.t.sol](../contracts/tests/NoPanic.t.sol); corruption fuzz [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts); `check_nestedPayloadLengthBounds` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_nestedCountsAreBoundedBeforeMultiplying` and `check_unpackCountIsBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (exact `InvalidValue`, never a Panic, for the maximum count, a count whose `* 32` overflows, a one-past-fit count, and a length that would overflow `n + 31`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_nestedCountsAreBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_nestedPayloadLengthBounds](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackArrayAcceptsOnlyCanonical_uint8](../contracts/tests/AbiCodecSymbolic.t.sol), [check_unpackCountIsBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testEncodingRejectsOverflowingAndTruncatedLengths](../contracts/tests/AbiCodec.t.sol), [testUnpackNeverPanics](../contracts/tests/NoPanic.t.sol), [test_bodyBoundsElementCount](../contracts/tests/MutationGaps.t.sol), [test_bodyBoundsHeadAfterAComponent](../contracts/tests/MutationGaps.t.sol), [test_bodyBoundsPaddedPayloadOnUnalignedValue](../contracts/tests/MutationGaps.t.sol), [test_bodyBoundsTupleHead](../contracts/tests/MutationGaps.t.sol), [test_unpackBoundsElementCount](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_nestedCountsAreBoundedBeforeMultiplying: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_nestedCountsAreBoundedBeforeMultiplying.json), [check_nestedPayloadLengthBounds: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedPayloadLengthBounds.json), [check_unpackArrayAcceptsOnlyCanonical_uint8: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackArrayAcceptsOnlyCanonical_uint8.json), [check_unpackCountIsBoundedBeforeMultiplying: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_unpackCountIsBoundedBeforeMultiplying.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its hostile count/length cases. The combined source proof derives recursive body spans and unpack count bounds before footprint products; it covers both tuple passes and recursive array cursors. Descriptor arithmetic and zero-copy cursor panics remain explicit outcomes, with a sufficient size budget proved separately. This is not an unlimited-resource guarantee.

## A17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackNestedMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (count 0 leaves trailing words, must reject); `test_unpackNamesTrailingBytes` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (offset 96); `testEncodingRejectsMalformedNestedValues` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `check_nestedFixedTupleCanonical` and `check_twoStringsCanonical` [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol) (trailing-byte geometries); `check_unpackNamesLooseOffsetsAndTrailingBytes` (`unpack` names the trailing byte, 256) and `check_validateNamesTheOffendingWord` (`validate` names the first trailing byte) [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol); [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_nestedFixedTupleCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackNamesLooseOffsetsAndTrailingBytes](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_validateNamesTheOffendingWord](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testEncodingRejectsMalformedNestedValues](../contracts/tests/AbiCodec.t.sol), [test_unpackNamesTrailingBytes](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_nestedFixedTupleCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedTupleCanonical.json), [check_twoStringsCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_twoStringsCanonical.json), [check_unpackNamesLooseOffsetsAndTrailingBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_unpackNamesLooseOffsetsAndTrailingBytes.json), [check_unpackNestedMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackNestedMatchesSolc.json), [check_validateNamesTheOffendingWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_validateNamesTheOffendingWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its listed trailing-byte cases. The combined source correspondence includes exact consumption in recursive validate and unpack, preserving validate at 32 + walked extent and unpack at 64 + tail. Concrete trailing-offset tests remain. The older flat uint8[] Halmos property still lacks an explicit exact-length condition because solc alone tolerates trailing bytes; strengthening that runtime oracle is separate from the closed source theorem.

## A18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_packArrayMatchesSolc_uint8` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol), `check_packArrayMatchesSolc_string` :40 (solc abi.encode oracle, must-succeed via staticcall); [test/collection-codec.test.ts](../test/collection-codec.test.ts) (8 nested types vs viem)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_packArrayMatchesSolc_string](../contracts/tests/AbiCodecSymbolic.t.sol), [check_packArrayMatchesSolc_uint8](../contracts/tests/AbiCodecSymbolic.t.sol).

**Retained formal results:** [check_packArrayMatchesSolc_string: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_packArrayMatchesSolc_string.json), [check_packArrayMatchesSolc_uint8: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_packArrayMatchesSolc_uint8.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos retains its 3-uint8/2-string bounds and listed byte lengths. The combined source proof now connects pack to the independent canonical array encoder for arbitrary finite admissible element types and counts, after actual source validation. The solc/viem differential fixtures remain independent runtime evidence. Output representability, valid memory and sufficient EVM resources are explicit premises.

## A19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_unpackArrayAcceptsOnlyCanonical_uint8` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (soundness vs solc); `check_unpackNestedMatchesSolc` :202 (soundness and completeness); [test/collection-codec.test.ts](../test/collection-codec.test.ts); `check_unpackUint8ArrayIsComplete` and `check_unpackStringArrayIsComplete` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol), `check_arrayOfNarrowTuplesMatchesSolc`; `check_twoStringsCanonical` (two-element `string[]`, each element re-wrapped in its own envelope) and `check_nestedFixedArrayCanonical` (`uint8[2][]`) [contracts/tests/CodecCanonicalSymbolic.t.sol](../contracts/tests/CodecCanonicalSymbolic.t.sol); `check_unpackCountIsBoundedBeforeMultiplying` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), AGENTS.md:127-128

**Test/property definitions:** [check_arrayOfNarrowTuplesMatchesSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_nestedFixedArrayCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_twoStringsCanonical](../contracts/tests/CodecCanonicalSymbolic.t.sol), [check_unpackArrayAcceptsOnlyCanonical_uint8](../contracts/tests/AbiCodecSymbolic.t.sol), [check_unpackCountIsBoundedBeforeMultiplying](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_unpackStringArrayIsComplete](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_unpackUint8ArrayIsComplete](../contracts/tests/NarrowWordsSymbolic.t.sol).

**Retained formal results:** [check_arrayOfNarrowTuplesMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_arrayOfNarrowTuplesMatchesSolc.json), [check_nestedFixedArrayCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_nestedFixedArrayCanonical.json), [check_twoStringsCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CodecCanonicalSymbolicTest.check_twoStringsCanonical.json), [check_unpackArrayAcceptsOnlyCanonical_uint8: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackArrayAcceptsOnlyCanonical_uint8.json), [check_unpackCountIsBoundedBeforeMultiplying: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_unpackCountIsBoundedBeforeMultiplying.json), [check_unpackNestedMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackNestedMatchesSolc.json), [check_unpackStringArrayIsComplete: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_unpackStringArrayIsComplete.json), [check_unpackUint8ArrayIsComplete: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_unpackUint8ArrayIsComplete.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the listed Halmos solc-comparison geometries remain bounded. The combined source proof establishes unpack acceptance against the independent recursive validator, canonical rewrapping of every element, exact consumption and both source-composed inverse directions with pack. The inverse theorems derive cursor safety from their explicit arithmetic budget. Arbitrary-geometry compiled-bytecode and universal solc/viem correspondence remain separate.

## A20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** units [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (`test_encode_malformedDescriptor`, positions 0 and 9), [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (`test_encodeRejectsStrayParenthesis`), :621 (`test_tupleRefusesTrailingComponentText`), :962 (`test_tupleNamesTextBetweenComponents`), [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `()` exercised by Expressions call nodes [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_tupleLayoutSpans` [contracts/tests/TupleLayoutSymbolic.t.sol](../contracts/tests/TupleLayoutSymbolic.t.sol) (every pair from an 8-component table against a hand-written span/shape/words table), `check_tupleLayoutMalformed` (stray `)` at 6, trailing text at 7, empty component at 7, missing comma at 6, bare name at 0, `()` at 1); `check_tupleLayoutInvalidCharacter` (every out-of-alphabet byte after `(uint8`, exact position 6)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/Assertions.sol](../contracts/Assertions.sol), [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [check_tupleLayoutInvalidCharacter](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutMalformed](../contracts/tests/TupleLayoutSymbolic.t.sol), [check_tupleLayoutSpans](../contracts/tests/TupleLayoutSymbolic.t.sol), [test_encodeRejectsStrayParenthesis](../contracts/tests/MutationGaps.t.sol), [test_encode_malformedDescriptor](../contracts/tests/Operations.t.sol), [test_tupleNamesTextBetweenComponents](../contracts/tests/MutationGaps.t.sol), [test_tupleRefusesTrailingComponentText](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_tupleLayoutInvalidCharacter: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutInvalidCharacter.json), [check_tupleLayoutMalformed: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutMalformed.json), [check_tupleLayoutSpans: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/TupleLayoutSymbolicTest.check_tupleLayoutSpans.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos retains its two-component/eight-shape bounds. The combined source proof covers the complete raw depth/comma scan, all-input layout reference outcomes, component spans/shapes/head size, canonical-layout completeness and a descriptor witness for every accepted layout. Empty tuples fail at position 1; malformed positions and checked head arithmetic are retained. The callers still special-case empty argument tuples.

## A21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (viem abi.encode, 300 random tuples up to depth 3 incl. nested dynamics); `check_encodeMatchesSolc` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (static 4-tuple); `testEncodingAcceptsWordBoundaryPayloadsAndNestedFixedArrays` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); check_navTupleEncoding [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_navTupleEncoding](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [testEncodingAcceptsWordBoundaryPayloadsAndNestedFixedArrays](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_encodeMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_encodeMatchesSolc.json), [check_navTupleEncoding: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navTupleEncoding.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Through production Operations.encode/encodeBytes, selected canonical static, dynamic and nested components assemble exactly the independently encoded solc tuple. The nested array has two two-word elements. This does not establish arbitrary descriptors, nesting depth or component counts; historical source evidence is retained without transferred acceptance.

## A22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (error name); `test_encode_countMismatch` [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (args 2,1); [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); check_navComponentCount [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_navComponentCount](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_encode_countMismatch](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_navComponentCount: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navComponentCount.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A two-component descriptor reports exact expected/actual ComponentCountMismatch before supplied values are read, at counts zero, one and three through both encoders. Other tuple geometries, counts and malformed descriptors retain separate evidence.

## A23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (mode 3); `test_encode_badStaticLength` [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `test_largeRepresentableFixedArrayEncodes` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); check_navStaticComponentWidth [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_navStaticComponentWidth](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_encode_badStaticLength](../contracts/tests/Operations.t.sol), [test_largeRepresentableFixedArrayEncodes](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_navStaticComponentWidth: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navStaticComponentWidth.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A two-word static array and one-word scalar exercise exact component index, expected width and actual byte count. The one-word valid case separately requires success and independent solc output. Both raw and bytes-wrapped encoders are covered. Arbitrary static footprints and lengths are not supplied.

## A24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (all three kinds); `test_encode_badEnvelope` [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); check_navDynamicComponentEnvelope [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_navDynamicComponentEnvelope](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [test_encode_badEnvelope](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_navDynamicComponentEnvelope: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicComponentEnvelope.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Short, unaligned and incorrectly headed dynamic components report exact index, length and head (zero below one word). Fault lengths are 0,31,32,63,64,65,96; one head is unrestricted except 0x20. Both encoders are covered, with symbolic content. Other component positions, lengths and body-validation outcomes remain separate.

## A25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testEncodingNamesMalformedComponent` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); `testDirtyWordsAreRejectedOnEveryPath` :178 (lines 214, 219); `assertRejected` helper :17 over 5 malformed values; `check_invalidComponentValueNamesTheWord` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_invalidComponentValueNamesTheWord](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [testDirtyWordsAreRejectedOnEveryPath](../contracts/tests/AbiCodec.t.sol), [testEncodingNamesMalformedComponent](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_invalidComponentValueNamesTheWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_invalidComponentValueNamesTheWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The source component validator and audited context forwarding preserve the component index and failing value offset through arbitrary finite recursive validation. The existing bounded uint8[] proof remains, supplemented by dirty static-word, dynamic-padding and nested-tuple EVM cases. Sufficient resources and the source/memory translation remain explicit assumptions.

## A26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testDirtyWordsAreRejectedOnEveryPath` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (offsets found by sentinel scan); MutationGaps offset tests [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), 95, 353, 364, 374, 382, 391, 587, 613, 633, 643; `check_invalidValueNamesTheWord` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol) ; `check_errorOffsetNamesFirstBadWord`, `check_errorOffsetWithinWordRun` [contracts/tests/CoreSymbolic.t.sol](../contracts/tests/CoreSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol) (`InvalidValue`, `requireValue`, `body`, `validateDynamic`)

**Test/property definitions:** [check_errorOffsetNamesFirstBadWord](../contracts/tests/CoreSymbolic.t.sol), [check_errorOffsetWithinWordRun](../contracts/tests/CoreSymbolic.t.sol), [check_invalidValueNamesTheWord](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [testDirtyWordsAreRejectedOnEveryPath](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_errorOffsetNamesFirstBadWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_errorOffsetNamesFirstBadWord.json), [check_errorOffsetWithinWordRun: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CoreSymbolicTest.check_errorOffsetWithinWordRun.json), [check_invalidValueNamesTheWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_invalidValueNamesTheWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The prior static traversal theorem retains exact first-invalid-word offsets and zero-copy arithmetic behavior. The combined source connection derives caller spans, carries the source guard offsets through dynamic recursion and unpack, and proves context routing preserves them for TupleComponent while supplying the specified CallbackResult fields. Parser failures and checked panics remain distinct. No unconditional resource-failure selector guarantee is claimed.

## A27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_mapValidatesResults` [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (every word, exact revert data); `testMalformedResultKeepsCallbackContextWithoutSelfCall` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol), [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_mapValidatesResults](../contracts/tests/ValuesSymbolic.t.sol), [testMalformedResultKeepsCallbackContextWithoutSelfCall](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_mapValidatesResults: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_mapValidatesResults.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the Collections-level Halmos proof retains mapValues/uint8 coverage. Within AbiCodec, the combined source proof and context-use audit now cover CallbackResult routing for all supported recursive types, with exact operation/index/other/target fields. Proving that every Collections caller supplies the intended context is still a separate caller obligation.

## A28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_packArrayMatchesSolc_*` [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol), 40 (must succeed); `check_wordMatchesSolc` :133; `check_unpackNestedMatchesSolc` :202; `testEmptyArraysOfNarrowTypesAreAccepted` [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol); [test/collection-codec.test.ts](../test/collection-codec.test.ts); [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (encode must succeed)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:249-252, [contracts/lib/AbiCodec.sol](../contracts/lib/AbiCodec.sol)

**Test/property definitions:** [check_unpackNestedMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_wordMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [testEmptyArraysOfNarrowTypesAreAccepted](../contracts/tests/AbiCodec.t.sol).

**Retained formal results:** [check_packArrayMatchesSolc_string: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_packArrayMatchesSolc_string.json), [check_packArrayMatchesSolc_uint8: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_packArrayMatchesSolc_uint8.json), [check_unpackNestedMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_unpackNestedMatchesSolc.json), [check_wordMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_wordMatchesSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: solc/viem runtime comparisons retain their listed families. The combined source theorem proves canonical acceptance against the independent ABI specification at arbitrary finite accepted nesting under the stated arithmetic/resource conditions. The construction oracle adds nested arrays and tuples. Universal compiler/SDK equivalence and unlimited-resource execution are not claimed.

## A29

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_A29_ShapeCompatibleWrongDescriptorReinterpretsWord`

**Recorded run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** AGENTS.md:112-115, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [test_A29_ShapeCompatibleWrongDescriptorReinterpretsWord](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** Nonempty tuple navigation path [0] accepts the int256(-1) encoding as uint256.max under (uint256); the matching (int256) descriptor is a control. This is an example of semantic reinterpretation, not a promise that every wrong descriptor succeeds.

## A34

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-structure.py](../scripts/test-claim-structure.py) `test_A34_imported_comment_changes_metadata_and_bytecode_for_all_four`; discovered through [test/claim-structure.test.ts](../test/claim-structure.test.ts)

**Recorded run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** README.md:12, AGENTS.md:367-369, [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [test_A34_imported_comment_changes_metadata_and_bytecode_for_all_four](../scripts/test-claim-structure.py).

**Scope and limitations:** Compiler AST checks all four direct AbiCodec imports. Appending one comment in the in-memory imported source changes metadata and creation/runtime bytecode, while executable bytes remain unchanged. Uses Solidity 0.8.36, optimizer 200 runs and Cancun; does not claim arbitrary edits or hash-collision impossibility. No production source or release artifact is rewritten.

## W1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) and `check_referenceLengths` :75 send raw uint8 IDs to both implementations; [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_wireEnumNumbersMatchReference` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:39-41; [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 79-89

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol), [test_wireEnumNumbersMatchReference](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json), [check_wordReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_wordReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The unit test compares against hand-written numbers only; the semantic identity of each ID comes from the Biconomy-oracle properties.

## W2

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_W2_MultiEntryTargetWireCrossesReferenceAndCore`; [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_W2_ValueAndOutputWireCrossDecoding`; retained supporting evidence: [contracts/tests/ERC8211ReferenceHarness.sol](../contracts/tests/ERC8211ReferenceHarness.sol) builds a `ComposableExecution` from this repo's structs and Biconomy's `executeComposableDelegateCall` decodes it; `judge` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) and [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) feed identical `InputParam` bytes to both

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); README.md:12; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [test_W2_MultiEntryTargetWireCrossesReferenceAndCore](../contracts/tests/ClaimCoverageModerate.t.sol), [test_W2_ValueAndOutputWireCrossDecoding](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** Independent uint8 wire structs cross-decode multi-entry TARGET data through both the pinned reference and current core. VALUE/output fields cross-decode; the core returns exact OutputParamsNotSupported(0) and ValueParamNotSupported(0,0) for unsupported wire fields.

## W3

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_W3_NumericWireEnums`; retained supporting evidence: [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts), 69-77 (raw paramType 2 and fetcherType 0/1/2 against Biconomy)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 36-41, 54

**Test/property definitions:** [test_W3_NumericWireEnums](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** All declared ERC-8211 parameter and comparison enums are checked against literal numeric wire values.

## W4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_positionalWords` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_eachConstraintChecksItsOwnWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); `test_matchingFirstWordDoesNotHideWrongSecondWord` :27

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [contracts/Assertions.sol](../contracts/Assertions.sol); README.md:3; AGENTS.md:42, 129

**Test/property definitions:** [check_positionalWords](../contracts/tests/ERC8211Symbolic.t.sol), [test_eachConstraintChecksItsOwnWord](../contracts/tests/PositionalConstraints.t.sol), [test_matchingFirstWordDoesNotHideWrongSecondWord](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_positionalWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_positionalWords.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bounds: two words, two leaf constraints. The unit test also pins the exact `ConstraintFailed` data at index 1.

## W5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_balanceRejectsSecondConstraint` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); check_wireFetchedWordPositions [contracts/tests/ClaimWireBoundarySymbolic.t.sol](../contracts/tests/ClaimWireBoundarySymbolic.t.sol); check_wireBalanceScalarRange [contracts/tests/ClaimWireBoundarySymbolic.t.sol](../contracts/tests/ClaimWireBoundarySymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** AGENTS.md:134-135

**Test/property definitions:** [check_wireBalanceScalarRange](../contracts/tests/ClaimWireBoundarySymbolic.t.sol), [check_wireFetchedWordPositions](../contracts/tests/ClaimWireBoundarySymbolic.t.sol), [test_balanceRejectsSecondConstraint](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_wireBalanceScalarRange: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWireBoundarySymbolicTest.check_wireBalanceScalarRange.json), [check_wireFetchedWordPositions: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWireBoundarySymbolicTest.check_wireFetchedWordPositions.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Selected RAW and STATIC_CALL two-word values use distinct positional GTE/LTE predicates with exact errors. Native and token balances accept/refuse a scalar IN as specified, then always reject two constraints with ReturnDataOutOfBounds(1,32) before evaluating predicates. Values and ordered bounds are unrestricted; arbitrary fetcher outputs and constraint families remain outside the new scope.

## W6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) ("dynamic offset"); check_wireDynamicHeaderPositions [contracts/tests/ClaimWireBoundarySymbolic.t.sol](../contracts/tests/ClaimWireBoundarySymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_wireDynamicHeaderPositions](../contracts/tests/ClaimWireBoundarySymbolic.t.sol).

**Retained formal results:** [check_wireDynamicHeaderPositions: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWireBoundarySymbolicTest.check_wireDynamicHeaderPositions.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A canonical bytes33 value judges offset 32, length 33 and the first payload word in order. Judging the payload word at position zero instead must compare against the offset, including an explicit equality success case. Payload content is symbolic; other dynamic shapes, lengths and positions retain separate evidence.

## W7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_paramLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_boundsPrecedePredicatesAndSkipNeedsAWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:42; [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_paramLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_boundsPrecedePredicatesAndSkipNeedsAWord](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_paramLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_paramLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bounds: data lengths {0,1,31,32,33,63}, one leaf plus optional SKIP.

## W8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_boundsPrecedePredicatesAndSkipNeedsAWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol) (word 0 fails EQ 0, yet the pinned error is `ReturnDataOutOfBounds(1, 63)`); `check_constraintBoundsComeFirst` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_constraintBoundsComeFirst](../contracts/tests/OperandsSymbolic.t.sol), [test_boundsPrecedePredicatesAndSkipNeedsAWord](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_constraintBoundsComeFirst: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_constraintBoundsComeFirst.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: two constraints over one word revert `ReturnDataOutOfBounds(1, 32)` even when the first would fail; a planted reordering fails it

## W9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (symbolic value and reference); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (boundaries 0, 1, 42, 2^255-1, 2^255, 2^256-1); [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 73

**Test/property definitions:** [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol).

**Retained formal results:** [check_wordReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_wordReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The primary Halmos property uses Biconomy as oracle. The supplemental source proof now checks an independent kind-indexed predicate for all full-width words.

## W10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_orAlternativesCheckTheSameWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [website/src/content/docs/docs/evml.md](../website/src/content/docs/docs/evml.md); AGENTS.md:135-138

**Test/property definitions:** [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol), [test_orAlternativesCheckTheSameWord](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_wordReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_wordReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The SDK lowering clause lives in the vendored checkout, out of this repo's evidence.

## W11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (length 64, symbolic bounds); `check_orWithRangeAndSkip` :108; [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (upper bound = value); `test_assertParam_in_success_interior_and_bounds` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_skipAndSignedRange` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol), 72; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md); README.md:3

**Test/property definitions:** [check_orWithRangeAndSkip](../contracts/tests/ERC8211Symbolic.t.sol), [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_assertParam_in_success_interior_and_bounds](../contracts/tests/Assertions.t.sol), [test_skipAndSignedRange](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_orWithRangeAndSkip: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orWithRangeAndSkip.json), [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## W12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** Verdict: `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (inverted symbolic bounds are canonical, so verdicts must match); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts). Error: `test_invalidRangeCannotBeHiddenByLaterOrAlternative` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_invalidRangeCannotBeHiddenByLaterOrAlternative](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The supplemental source proof preserves the exact typed error for both signednesses; `ConstraintOracleTest.testSignedExtremesAndRanges` asserts exact unsigned and signed range error bytes. The primary parity property remains verdict-only.

## W13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (type 7 over every length); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts), 93; `test_skipRejectsPayload` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_skipRejectsPayload](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Error identity is UNIT (one payload length, 1).

## W14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (asserts rejection for leaf lengths 0,1,31,33 and a 32-byte range); `test_assertParam_invalidConstraintData_word` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertParam_invalidConstraintData_range` :353; `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); `check_exactReferenceLengths` [contracts/tests/ConstraintCompositionSymbolic.t.sol](../contracts/tests/ConstraintCompositionSymbolic.t.sol) (every non-OR kind at constraint index 1 with reference lengths 0, 1, 31, 32, 33, 64, 65 and 96: exactly the required length is accepted, every other reverts `InvalidConstraintData(0, 0, 1, length)`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_exactReferenceLengths](../contracts/tests/ConstraintCompositionSymbolic.t.sol), [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [test_assertParam_invalidConstraintData_range](../contracts/tests/Assertions.t.sol), [test_assertParam_invalidConstraintData_word](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_exactReferenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstraintCompositionSymbolicTest.check_exactReferenceLengths.json), [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the one-way property against Biconomy remains; the new property asserts rejection directly for every listed length, 64 and 96 for leaves and 32 for ranges included, at a nonzero constraint index. Other indices and lengths beyond 96 are not enumerated; nonzero entry and param indices are the W26 properties.

## W15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (asserts ours rejects, Biconomy accepts a 96-byte IN); `check_referenceLengths` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (length 96); check_wireStrictRangeTrailingBytes [contracts/tests/ClaimWireBoundarySymbolic.t.sol](../contracts/tests/ClaimWireBoundarySymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** AGENTS.md:46-47; [contracts/Assertions.sol](../contracts/Assertions.sol); [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [check_wireStrictRangeTrailingBytes](../contracts/tests/ClaimWireBoundarySymbolic.t.sol).

**Retained formal results:** [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json), [check_wireStrictRangeTrailingBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWireBoundarySymbolicTest.check_wireStrictRangeTrailingBytes.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: The pinned Biconomy runtime must accept all three selected lengths. Assertions must accept exactly 64 and reject 96/128 with complete InvalidConstraintData context. Both signedness modes have unrestricted ordered bounds containing the actual word and symbolic trailing words. Arbitrary lengths, malformed bounds and deployment artifact matching are not added.

## W16

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `agree` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol), applied in all six `check_*` properties in [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:46-47 ("stricter rejection")

**Retained formal results:** [check_nestedOrRejected: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_nestedOrRejected.json), [check_orOfWordBranches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orOfWordBranches.json), [check_orWithRangeAndSkip: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orWithRangeAndSkip.json), [check_paramLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_paramLengths.json), [check_positionalWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_positionalWords.json), [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json), [check_wordReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_wordReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Within the stated bounds (<=2 constraints, <=3 OR leaves, listed lengths, RAW_BYTES only).

## W17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** All six `check_*` in [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); mutation record [docs/mutation-testing.md](mutation-testing.md), 33 (erc8211-differential in stage 2; all Assertions non-equivalent mutants killed) ; `check_batchMatchesReference` [contracts/tests/BatchDifferentialSymbolic.t.sol](../contracts/tests/BatchDifferentialSymbolic.t.sol); `check_batchSecondConstraintAndOr` [contracts/tests/ConstraintCompositionSymbolic.t.sol](../contracts/tests/ConstraintCompositionSymbolic.t.sol) (two entries, one two-word parameter each, EQ then a two-leaf OR, verdicts equal to the reference over symbolic words)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); README.md:46; AGENTS.md:43-46; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_batchMatchesReference](../contracts/tests/BatchDifferentialSymbolic.t.sol), [check_batchSecondConstraintAndOr](../contracts/tests/ConstraintCompositionSymbolic.t.sol).

**Retained formal results:** [check_batchIsItsPartsInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchDifferentialSymbolicTest.check_batchIsItsPartsInOrder.json), [check_batchMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchDifferentialSymbolicTest.check_batchMatchesReference.json), [check_batchSecondConstraintAndOr: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstraintCompositionSymbolicTest.check_batchSecondConstraintAndOr.json), [check_exactReferenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstraintCompositionSymbolicTest.check_exactReferenceLengths.json), [check_nestedOrRejected: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_nestedOrRejected.json), [check_orOfWordBranches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orOfWordBranches.json), [check_orWithRangeAndSkip: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orWithRangeAndSkip.json), [check_paramLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_paramLengths.json), [check_positionalWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_positionalWords.json), [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json), [check_wordReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_wordReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: `assertBatch` predicate batches (two entries, three parameters) now match the reference on verdicts, but each parameter carries one constraint from five fixed cases or, in the new property, EQ then a two-leaf OR on one parameter per entry; OR payloads beyond two leaves are proved only through `assertParam` (at most three leaves), and the comparison with Biconomy is on verdicts only (its errors are its own).

## W18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_orOfWordBranches` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); `check_orWithRangeAndSkip` :108; [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_orAlternativesCheckTheSameWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); AGENTS.md:42, 130-131; README.md:3

**Test/property definitions:** [check_orOfWordBranches](../contracts/tests/ERC8211Symbolic.t.sol), [check_orWithRangeAndSkip](../contracts/tests/ERC8211Symbolic.t.sol), [test_orAlternativesCheckTheSameWord](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_orOfWordBranches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orOfWordBranches.json), [check_orWithRangeAndSkip: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_orWithRangeAndSkip.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bounds: 1..3 leaves.

## W19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (asserts rejection); `test_emptyOrRejected` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); check_edgesEmptyOrContext [contracts/tests/ClaimBoundaryCasesSymbolic.t.sol](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_edgesEmptyOrContext](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol), [test_emptyOrRejected](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_edgesEmptyOrContext: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimBoundaryCasesSymbolicTest.check_edgesEmptyOrContext.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A canonical empty OR reports complete InvalidOrConstraint context at constraint zero or after one SKIP, with unrestricted complete data words. These are default-message assertParam cases, not arbitrary entry/parameter positions or competing malformed inputs. The context mutant is killed.

## W20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_nestedOrRejected` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) (asserts ours false, nested first or second); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_nestedOrRejectedEvenAfterMatchingLeaf` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:42-43; [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_nestedOrRejected](../contracts/tests/ERC8211Symbolic.t.sol), [test_nestedOrRejectedEvenAfterMatchingLeaf](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_nestedOrRejected: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_nestedOrRejected.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bounds: two leaves, depth 2.

## W21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_invalidRangeCannotBeHiddenByLaterOrAlternative` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `check_orLeavesShortCircuitInOrder` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_orLeavesShortCircuitInOrder](../contracts/tests/OperandsSymbolic.t.sol), [test_invalidRangeCannotBeHiddenByLaterOrAlternative](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_orLeavesShortCircuitInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_orLeavesShortCircuitInOrder.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a malformed leaf after a matching one is never read, one before it rejects the OR with `InvalidConstraintData`; removing the short-circuit fails it

## W22

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testReadsAndBatchRejectImpossibleDecoderAllocation`, `testOrRejectsImpossibleDecoderAllocation`, `testFuzzBoundedReadAndBatchSucceed` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol); [docs/halmos-checks.json](halmos-checks.json) isolated replay source/results (`test_decoderAllocationFailure0`, `test_decoderAllocationFailure1`, `test_orDecoderAllocationFailure`); retained supporting evidence: [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts) (both reject `0x01`, verdict only); `testFuzzPrimitivesNeverPanic` / `testFuzzBoundedBatchNeverPanics` [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) inject junk OR payloads (:190-199) and TOLERATE a bare revert (:229)

**Recorded run:** [results, commands and source hashes](bounded-test-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); AGENTS.md:324-329

**Test/property definitions:** [testFuzzBoundedBatchNeverPanics](../contracts/tests/CoreNoPanic.t.sol), [testFuzzBoundedReadAndBatchSucceed](../contracts/tests/CoreNoPanic.t.sol), [testFuzzPrimitivesNeverPanic](../contracts/tests/CoreNoPanic.t.sol), [testOrRejectsImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol), [testReadsAndBatchRejectImpossibleDecoderAllocation](../contracts/tests/CoreNoPanic.t.sol).

**Scope and limitations:** The retained ConstraintOracle test pins a bare revert for OR payload 0x01. The replacement OR regression asserts exact Panic(0x41) for an impossible Constraint[] allocation. General decoder error-byte equivalence with the reference is not asserted.

## W23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** Raw uint8 types 9..255 in `check_wordReference` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol), `check_referenceLengths` :75, `check_positionalWords` :133; [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol) (kind 9 injected)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** AGENTS.md:325-327; [contracts/tests/CoreNoPanic.t.sol](../contracts/tests/CoreNoPanic.t.sol)

**Test/property definitions:** [check_positionalWords](../contracts/tests/ERC8211Symbolic.t.sol), [check_referenceLengths](../contracts/tests/ERC8211Symbolic.t.sol), [check_wordReference](../contracts/tests/ERC8211Symbolic.t.sol).

**Retained formal results:** [check_positionalWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_positionalWords.json), [check_referenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_referenceLengths.json), [check_wordReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ERC8211SymbolicTest.check_wordReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: proved only as "never accepted where Biconomy rejects"; no assertion that Assertions itself rejects, and the empty revert data is tolerated, not asserted.

## W24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol) (exact revert data, symbolic actual and reference, entry 1 param 1); [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol), 294, 471, 509; `test_matchingFirstWordDoesNotHideWrongSecondWord` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol); `check_batchSecondConstraintAndOr` [contracts/tests/ConstraintCompositionSymbolic.t.sol](../contracts/tests/ConstraintCompositionSymbolic.t.sol) (exact first-failure payload: index 1 with kind OR echoing the whole OR payload, or index 0 with EQ, at entry 0 or 1) and `check_exactReferenceLengths` (exact leaf failure at constraint index 1 for every non-OR kind)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); AGENTS.md:133-134; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [check_batchSecondConstraintAndOr](../contracts/tests/ConstraintCompositionSymbolic.t.sol), [check_exactReferenceLengths](../contracts/tests/ConstraintCompositionSymbolic.t.sol), [test_matchingFirstWordDoesNotHideWrongSecondWord](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_batchErrorNamesTheOperand: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchErrorNamesTheOperand.json), [check_batchSecondConstraintAndOr: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstraintCompositionSymbolicTest.check_batchSecondConstraintAndOr.json), [check_exactReferenceLengths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstraintCompositionSymbolicTest.check_exactReferenceLengths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos now covers EQ at constraint 0, every non-OR kind at constraint 1 and a failing OR at constraint 1 (referenceData = the whole OR payload echoed) in a two-entry batch, in first-failure order across entries; param indices beyond 0 remain the BatchSymbolic case.

## W25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertParam_withMessage` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertBatch_withMessage` :449; `""` pinned at [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol), 793, 908, 912 and [contracts/tests/CoreExtensions.t.sol](../contracts/tests/CoreExtensions.t.sol); `check_judgesEchoTheirMessage` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_judgesEchoTheirMessage](../contracts/tests/OperandsSymbolic.t.sol), [test_assertBatch_withMessage](../contracts/tests/Assertions.t.sol), [test_assertParam_withMessage](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_judgesEchoTheirMessage: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_judgesEchoTheirMessage.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved with C10

## W26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol), 84, 91, 101; [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol), 406; `check_primitiveConstraintsArePositional` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol); check_batchIsItsPartsInOrder [contracts/tests/BatchDifferentialSymbolic.t.sol](../contracts/tests/BatchDifferentialSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol); AGENTS.md:133

**Test/property definitions:** [check_batchIsItsPartsInOrder](../contracts/tests/BatchDifferentialSymbolic.t.sol), [check_primitiveConstraintsArePositional](../contracts/tests/OperandsSymbolic.t.sol).

**Retained formal results:** [check_batchIsItsPartsInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchDifferentialSymbolicTest.check_batchIsItsPartsInOrder.json), [check_primitiveConstraintsArePositional: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_primitiveConstraintsArePositional.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a malformed constraint names entry, operand and its own index (1 here), and batch errors carry the entry and operand position

## W27

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-structure.py](../scripts/test-claim-structure.py) `test_W27_judge_uses_execution_encoding_without_payable_executor_interface`; discovered through [test/claim-structure.test.ts](../test/claim-structure.test.ts)

**Recorded run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [test_W27_judge_uses_execution_encoding_without_payable_executor_interface](../scripts/test-claim-structure.py).

**Scope and limitations:** Compiled ABI checks both assertBatch overloads are view and use the same execution tuple components as the payable reference executor. Assertions has no executeComposable, payable function, receive or fallback entry.

## W28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_assertBatch_predicate_success` [contracts/tests/Assertions.t.sol](../contracts/tests/Assertions.t.sol); `test_assertBatch_predicate_reverts` :385; `check_batchErrorNamesTheOperand` [contracts/tests/BatchSymbolic.t.sol](../contracts/tests/BatchSymbolic.t.sol); `check_batchIsItsPartsInOrder` [contracts/tests/BatchDifferentialSymbolic.t.sol](../contracts/tests/BatchDifferentialSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** README.md:46; [contracts/lib/ERC8211.sol](../contracts/lib/ERC8211.sol)

**Test/property definitions:** [check_batchErrorNamesTheOperand](../contracts/tests/BatchSymbolic.t.sol), [check_batchIsItsPartsInOrder](../contracts/tests/BatchDifferentialSymbolic.t.sol), [test_assertBatch_predicate_reverts](../contracts/tests/Assertions.t.sol), [test_assertBatch_predicate_success](../contracts/tests/Assertions.t.sol).

**Retained formal results:** [check_batchErrorNamesTheOperand: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchSymbolicTest.check_batchErrorNamesTheOperand.json), [check_batchIsItsPartsInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/BatchDifferentialSymbolicTest.check_batchIsItsPartsInOrder.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** A batch of three parameters over two entries passes exactly when `assertParam` passes on each, and otherwise reverts with the first failing parameter's error relabeled to its position (`"COMPOSABLE"`, entry, param), revert data included. Bounded: one constraint per parameter from five cases with distinct outcomes; planted bugs (skipping an entry, a wrong parameter index, the wrong label) all fail it.

## W29

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_expressionGraphResolvesNewConstraintKinds` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol) (SKIP + IN_SIGNED through an Expressions Resolve node); ConstraintFailed cases in [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `check_primitiveConstraintsArePositional` [contracts/tests/OperandsSymbolic.t.sol](../contracts/tests/OperandsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_primitiveConstraintsArePositional](../contracts/tests/OperandsSymbolic.t.sol), [test_expressionGraphResolvesNewConstraintKinds](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_primitiveConstraintsArePositional: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperandsSymbolicTest.check_primitiveConstraintsArePositional.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved on `resolve`: `[SKIP, EQ]` over two words judges only the second, and failures name constraint index 1

## W30

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-coverage-structure.py](../scripts/test-claim-coverage-structure.py) `test_W30_inlined_runtime_matches_pinned_fixture_bytes_and_hash_field`; [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol) `test_inlinedRuntimeMatchesPinnedFixture`; retained supporting evidence: `test_inlinedRuntimeMatchesPinnedFixture` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); hash check [test/erc8211-differential.test.ts](../test/erc8211-differential.test.ts); `test_referenceRunsUnderFoundry` [contracts/tests/ERC8211Symbolic.t.sol](../contracts/tests/ERC8211Symbolic.t.sol); fixture metadata [test/fixtures/biconomy-erc8211.json](../test/fixtures/biconomy-erc8211.json) (Base 8453, fetched 2026-09-22)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** AGENTS.md:46, 254-257

**Test/property definitions:** [test_W30_inlined_runtime_matches_pinned_fixture_bytes_and_hash_field](../scripts/test-claim-coverage-structure.py), [test_inlinedRuntimeMatchesPinnedFixture](../contracts/tests/ERC8211Symbolic.t.sol), [test_referenceRunsUnderFoundry](../contracts/tests/ERC8211Symbolic.t.sol).

**Scope and limitations:** Fresh byte-for-byte/hash-field comparison and the compiled runtime hash test establish the pinned offline fixture identity. No present public-chain code availability is asserted.

## O1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts), [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (BigInt oracle, exact Panic code decoded); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_add_and_overflow, :105 test_sub_and_underflow; check_arithmeticUnsignedAddSub [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol); check_arithmeticSignedAddSub [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_arithmeticSignedAddSub](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [check_arithmeticUnsignedAddSub](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [test_add_and_overflow](../contracts/tests/Operations.t.sol), [test_sub_and_underflow](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_arithmeticSignedAddSub: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticSignedAddSub.json), [check_arithmeticUnsignedAddSub: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticUnsignedAddSub.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Carry/borrow and sign-bit oracles specify full-word add/sub success and exact Panic(0x11) on overflow/underflow. Wrapping oracle arithmetic cannot discard overflow paths. The claim also covers multiplication, for which this campaign adds no symbolic value proof; existing concrete multiplication evidence retains its scope.

## O2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_mul_div_mod; check_arithmeticZeroDivisor [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol); check_arithmeticUnsignedBinaryDivisors [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_arithmeticUnsignedBinaryDivisors](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [check_arithmeticZeroDivisor](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [test_mul_div_mod](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_arithmeticUnsignedBinaryDivisors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticUnsignedBinaryDivisors.json), [check_arithmeticZeroDivisor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticZeroDivisor.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Unsigned div/mod with divisor zero must report exact Panic(0x12). For selected unit/power-of-two divisors, independent shift/mask oracles require exact successful quotient/remainder bytes for every dividend. Arbitrary nonzero divisors remain concrete evidence only.

## O3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (oracle models min/-1 explicitly; BigInt `%` has dividend sign); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_div_mod_signed_truncation, :129 test_div_signed_minByMinusOne; check_arithmeticZeroDivisor [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol); check_arithmeticSignedUnitDivisors [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol); check_arithmeticSignedBinaryDivisors [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_arithmeticSignedBinaryDivisors](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [check_arithmeticSignedUnitDivisors](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [check_arithmeticZeroDivisor](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [test_div_mod_signed_truncation](../contracts/tests/Operations.t.sol), [test_div_signed_minByMinusOne](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_arithmeticSignedBinaryDivisors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticSignedBinaryDivisors.json), [check_arithmeticSignedUnitDivisors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticSignedUnitDivisors.json), [check_arithmeticZeroDivisor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticZeroDivisor.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Selected signed division/remainder paths have exact outputs, truncation toward zero, dividend-signed remainder, zero-divisor Panic(0x12) and MIN/-1 division Panic(0x11). Independent magnitude/shift/mask oracles avoid symbolic division. Arbitrary nonzero divisors retain concrete evidence.

## O4

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) expRef, :250; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_exp

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_exp](../contracts/tests/Operations.t.sol).

## O5

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (full-width int256 base, uint256 exponent); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) test_signedPower ((-2)^255 == int256.min)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_signedPower](../contracts/tests/OperationsNumeric.t.sol).

## O6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts), :299-300; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_minMax; check_wordsUnsignedMinMax [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol); check_wordsSignedMinMax [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_wordsSignedMinMax](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [check_wordsUnsignedMinMax](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [test_minMax](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordsSignedMinMax: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsSignedMinMax.json), [check_wordsUnsignedMinMax: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsUnsignedMinMax.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Both returned extrema are input members and satisfy all order bounds. Signed order uses the independent sign-biased unsigned coordinate (word XOR 2^255). All input words are unrestricted; low-level calls must succeed and return exactly one word. No gas/resource or deployment claim is added.

## O7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts), :301 (genI draws int256.min/max 20% of the time); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_absDiff; check_wordsUnsignedDistance [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol); check_wordsSignedDistance [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_wordsSignedDistance](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [check_wordsUnsignedDistance](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [test_absDiff](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordsSignedDistance: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsSignedDistance.json), [check_wordsUnsignedDistance: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsUnsignedDistance.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Distance plus the lower coordinate reconstructs the upper coordinate, with an explicit range check and wrapping oracle arithmetic so faulty outputs cannot discard a path by overflowing the reference. Signed values use sign-biased unsigned coordinates. Success and one-word output are required for every pair, including int256 extrema. No wide multiplication/division proof is inferred.

## O8

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) roundedMulDivRef, :254-255 (all three modes, full-width operands); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_mulDiv, :177 test_mulDivCeil

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_mulDiv](../contracts/tests/Operations.t.sol), [test_mulDivCeil](../contracts/tests/Operations.t.sol).

## O9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol) check_mulDivZeroDenominatorPanics (symbolic a, b, rounding 0..2, exact revert bytes); [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :316-318

**Test/property definitions:** [check_mulDivZeroDenominatorPanics](../contracts/tests/OperationsSymbolic.t.sol).

**Retained formal results:** [check_mulDivZeroDenominatorPanics: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsSymbolicTest.check_mulDivZeroDenominatorPanics.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: the Halmos property is the unsigned overload only; the signed overload's zero-denominator case is one unit case ([contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol)) plus rare fuzz draws

## O10

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (full-width int256 incl. int256.min, all modes, BigInt oracle); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) testFuzz_signedRounding (int128 operands, native oracle), :52 test_signedMulDivBoundaries, :72 test_signedRoundingOverflowAfterTruncationFits

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [testFuzz_signedRounding](../contracts/tests/OperationsNumeric.t.sol), [test_signedMulDivBoundaries](../contracts/tests/OperationsNumeric.t.sol), [test_signedRoundingOverflowAfterTruncationFits](../contracts/tests/OperationsNumeric.t.sol).

## O11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O11_AllInvalidRoundingValuesAcrossMulDivOverloads`; retained supporting evidence: [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol), :233-235 (rounding > 2 must revert with empty data); check_behaviorInvalidRoundingWord [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); AGENTS.md:311-312

**Test/property definitions:** [check_behaviorInvalidRoundingWord](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [test_O11_AllInvalidRoundingValuesAcrossMulDivOverloads](../contracts/tests/ClaimCoverageEasy.t.sol).

**Retained formal results:** [check_behaviorInvalidRoundingWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorInvalidRoundingWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Raw enum words above 2, including words with dirty uint8 upper bits, produce the exact empty decoder revert for unsigned and signed four-argument mulDiv. Other arguments are valid literal controls. The enum-extension mutant is killed. This is decoder evidence, not a new arithmetic proof.

## O12

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_addMod_mulMod

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_addMod_mulMod](../contracts/tests/Operations.t.sol).

## O13

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O13_FullWidthIndependentPythonRemainders`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) testFuzz_signedMod (int128 a, b; full int256 m; native Solidity `%` oracle); :10 test_signedModBoundaries; [test/signed-mod.test.ts](../test/signed-mod.test.ts); `docs/verification/signed-mod/manifest.json`; `docs/verification/signed-mod/kontrol-summary.json`

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [testFuzz_signedMod](../contracts/tests/OperationsNumeric.t.sol), [test_O13_FullWidthIndependentPythonRemainders](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O13_FullWidthIndependentPythonRemainders](../scripts/generate-claim-coverage-vectors.py), [test_signedModBoundaries](../contracts/tests/OperationsNumeric.t.sol).

**Scope and limitations:** Fresh seeded full-width Python arbitrary-precision remainder vectors exercise signed sums/products independently of Solidity intermediate overflow. They complement the retained 11,096-call BigInt run at its own source snapshot; general nonzero-result bytecode proofs remain incomplete.

## O14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol) check_signedModAtIntMin (no revert when a or m is int256.min, b fixed to 1 or 0); [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol), :34 test_signedModZero; [test/signed-mod.test.ts](../test/signed-mod.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :374-375

**Test/property definitions:** [check_signedModAtIntMin](../contracts/tests/OperationsSymbolic.t.sol), [test_signedModZero](../contracts/tests/OperationsNumeric.t.sol).

**Retained formal results:** [check_signedModAtIntMin: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsSymbolicTest.check_signedModAtIntMin.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

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

**Recorded run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1409, :1424; AGENTS.md:380-383

**Test/property definitions:** [test_O17_ModexpAcceptsExactlyOneWordAndFallsBackOtherwise](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** All four public overloads exercise failed, empty, 1-byte, 31-byte and 64-byte MODEXP replies using Foundry call mocks. An intentionally incorrect successful 32-byte sentinel confirms interception and that the result is trusted. The fallback is checked against an independent modular-period example; this does not verify a real precompile implementation or gas availability.

## O18

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O18_FullWidthSignedBasePowers`; retained supporting evidence: [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol) testFuzz_powModSmall (negated a <= 255, e <= 255, m < 2^128), :25 test_powModWordBoundaries, :98-99

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [testFuzz_powModSmall](../contracts/tests/OperationsModular.t.sol), [test_O18_FullWidthSignedBasePowers](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O18_FullWidthSignedBasePowers](../scripts/generate-claim-coverage-vectors.py), [test_powModWordBoundaries](../contracts/tests/OperationsModular.t.sol).

**Scope and limitations:** Fresh full-width signed-base power vectors use Python arbitrary-precision modular exponentiation and independent sign handling. These are finite behavioral checks under the used precompile environment.

## O19

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O19_FullWidthNegativeExponents`; retained supporting evidence: [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol) testFuzz_inverseFullWidth (full-width a, m; independent Euclid gcd; checks a * inv == 1 mod m and exact error args); :14-19, :28-38, :41; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`ModularInverseDoesNotExist`, `_inverseMod`, signed-exponent `powMod` overloads)

**Test/property definitions:** [testFuzz_inverseFullWidth](../contracts/tests/OperationsModular.t.sol), [test_O19_FullWidthNegativeExponents](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O19_FullWidthNegativeExponents](../scripts/generate-claim-coverage-vectors.py).

**Scope and limitations:** Fresh Python inverse-power vectors cover signed and unsigned overloads, modulus one, zero/noncoprime bases, zero-modulus errors, signed minimum and exact NonInvertible errors. Environment and finite-input scope remain.

## O20

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/OperationsModular.t.sol](../contracts/tests/OperationsModular.t.sol), :22, :30-38, :45

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Scope and limitations:** About ten examples

## O21

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) isqrt, :269-284 (perfect squares and neighbors); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_sqrt

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_sqrt](../contracts/tests/Operations.t.sol).

## O22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_log2, :287 test_log2_rejectsZero; `check_log2IsTheExactFloor` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol) (added after the snapshot: every word, `2^r <= x < 2^(r+1)`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :561-573

**Test/property definitions:** [check_log2IsTheExactFloor](../contracts/tests/OperationsSymbolic.t.sol), [test_log2](../contracts/tests/Operations.t.sol), [test_log2_rejectsZero](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_log2IsTheExactFloor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsSymbolicTest.check_log2IsTheExactFloor.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for every word: `x >> log2(x) == 1` and `LogarithmUndefined(0)` at zero

## O23

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_O23_RpowExactIntegerPowersAndStepRounding`; retained supporting evidence: [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (mirror oracle plus independent exact-value bound), :123-141 rpowRef; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :233, :252, :257; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O23_RpowExactIntegerPowersAndStepRounding](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** Partial: independent exact powers at unit scale (x 0..7, exponents 0..12), selected decimal step-rounding traces, zero identities and exact overflow/division panics supplement the mirrored oracle. General fixed-point step-rounding correctness for arbitrary operands remains beyond these finite examples.

## O24

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_rpow_roundingLossCanExceedMultiplicationCount

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_rpow_roundingLossCanExceedMultiplicationCount](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Exactly the documented example

## O26

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O26_GeneratedFiniteWordKernelAndExactErrors`; retained supporting evidence: [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) test_expWadMatchesReference (17 points vs 80-digit references, 1e-19 relative + 1 wei), :455 test_expWadUnderflowsToZero; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_expWad_overflowPanics

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O26_GeneratedFiniteWordKernelAndExactErrors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_expWadMatchesReference](../contracts/tests/MutationGaps.t.sol), [test_expWadUnderflowsToZero](../contracts/tests/MutationGaps.t.sol), [test_expWad_overflowPanics](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Seeded finite-word kernel vectors come from the independent rational Horner oracle, covering range-reduction boundaries and exact errors. They test the quantized kernel, not global real exponential accuracy, monotonicity or inverse-error bounds.

## O27

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O27_GeneratedFiniteWordKernelAndExactErrors`; retained supporting evidence: [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) test_lnWadMatchesReference (12 points within 1 wei); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_lnWad_rejectsNonPositive

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O27_GeneratedFiniteWordKernelAndExactErrors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_lnWadMatchesReference](../contracts/tests/MutationGaps.t.sol), [test_lnWad_rejectsNonPositive](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Seeded finite-word logarithm kernel vectors and exact errors come from the independent rational Horner oracle. They test the quantized kernel, not global analytic accuracy guarantees.

## O28

**Recorded evidence:** LIMITATION / DOCUMENTED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol); [scripts/claim-coverage-fixed-point-oracle.py](../scripts/claim-coverage-fixed-point-oracle.py)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`expWad`, `lnWad`)

**Scope and limitations:** The finite-word source specifications establish quantized kernels and guards under their premises. They do not establish global real-function accuracy, positivity, monotonicity or inverse-error bounds. Numeric examples cannot establish those universal guarantees or certify the absence of every possible theorem.

## O29

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (return word compared to exactly 0/1); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :303; check_wordsUnsignedRelations [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol); check_wordsSignedRelations [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_wordsSignedRelations](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [check_wordsUnsignedRelations](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol).

**Retained formal results:** [check_wordsSignedRelations: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsSignedRelations.json), [check_wordsUnsignedRelations: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsUnsignedRelations.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Bit-level eq/ne and both overloads of lt/gt/le/ge return exact canonical boolean bytes. Signed order is independently specified through sign-biased unsigned coordinates; unsigned order uses the primitive numeric relation. Every input word is unrestricted and every low-level call must succeed. Selector, relation and signedness faults produce valid counterexamples.

## O30

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_bitwise; check_wordsBitTruthTable [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_wordsBitTruthTable](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [test_bitwise](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordsBitTruthTable: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsBitTruthTable.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** For each unrestricted uint8 bit position, projected output bits equal the boolean AND/OR/XOR truth table of the two input bits. Quantification over every position determines the complete returned word. XOR with the all-ones word also equals complement. Success and exact one-word return width are required; operator-swap mutants are killed.

## O31

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (shift amounts 0..300 and full width); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_shifts; check_wordsLeftShift [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol); check_wordsRightShift [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :671-683

**Test/property definitions:** [check_wordsLeftShift](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [check_wordsRightShift](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [test_shifts](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordsLeftShift: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsLeftShift.json), [check_wordsRightShift: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsRightShift.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Each output bit has its corresponding input bit or zero according to the mathematical index translation. Full uint256 shift counts include all values at or above 256. Literal bounds protect reference index arithmetic, and each operation must succeed and return one word. Shift-count masking faults are killed.

## O32

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (BigInt arithmetic shift, clamped); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_shr_signed; check_wordsArithmeticRightShift [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_wordsArithmeticRightShift](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [test_shr_signed](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordsArithmeticRightShift: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsArithmeticRightShift.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Each output bit is the translated input bit or the input sign bit beyond its width. This specifies arithmetic right shift, including floor rounding and the saturated 0/-1 result for shifts at least 256. Calls must succeed with a one-word result. Replacing SAR by logical shift is killed.

## O33

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (one int16 case); `check_signExtensionRecipe` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_signExtensionRecipe](../contracts/tests/OperationsSymbolic.t.sol).

**Retained formal results:** [check_signExtensionRecipe: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsSymbolicTest.check_signExtensionRecipe.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for every word and every width from 8 to 248 bits against an independent mask-and-fill reference

## O34

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_bitSet; check_wordsBitMembership [contracts/tests/ClaimWordSemanticsSymbolic.t.sol](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_wordsBitMembership](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol), [test_bitSet](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordsBitMembership: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimWordSemanticsSymbolicTest.check_wordsBitMembership.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** For indices below 256, membership is specified by intersection with the one-bit mask; every other uint256 index yields exact canonical false. The result must succeed and have the full canonical boolean encoding. A mutant wrapping the index modulo 256 is killed.

## O35

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :361, :369, :391 (also judged through the core), :414

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Scope and limitations:** Thin wrappers over opcodes

## O36

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_blockHash

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_blockHash](../contracts/tests/Operations.t.sol).

## O37

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O37_FundedCodeLessAccount`; retained supporting evidence: [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_codeHash (contract and nonexistent)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O37_FundedCodeLessAccount](../contracts/tests/ClaimCoverageEasy.t.sol), [test_codeHash](../contracts/tests/Operations.t.sol).

**Scope and limitations:** A nonexistent account is funded and remains code-less: extcodehash changes from zero to the empty-code hash.

## O38

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/forge-only/BlobContext.sol](../scripts/forge-only/BlobContext.sol) `test_O38_InjectedBlobHashesAndOutOfRangeIndices`; retained supporting evidence: [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_blobHash (zero path only; the test notes EDR cannot synthesize a blob tx)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O38_InjectedBlobHashesAndOutOfRangeIndices](../scripts/forge-only/BlobContext.sol), [test_blobHash](../contracts/tests/Operations.t.sol).

**Scope and limitations:** Forge-injected versioned blob hashes cover three nonzero indices, out-of-range indices and an empty context. This tests the opcode wrapper with injected context; it does not validate acceptance/execution of a real blob transaction by a public chain.

## O39

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (sha256), :948 (ecrecover), :956 (identity)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O40

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_rawCall_codelessTargetSucceedsEmpty; `check_rawCallToCodelessAddressIsEmpty` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_rawCallToCodelessAddressIsEmpty](../contracts/tests/OperationsSymbolic.t.sol), [test_rawCall_codelessTargetSucceedsEmpty](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_rawCallToCodelessAddressIsEmpty: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsSymbolicTest.check_rawCallToCodelessAddressIsEmpty.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for a code-less non-precompile address and any one-word calldata

## O41

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_rawCall_revertWrapped (exact error bytes); `check_rawCallRevertNamesTheCall` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :831-834

**Test/property definitions:** [check_rawCallRevertNamesTheCall](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_rawCall_revertWrapped](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_rawCallRevertNamesTheCall: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_rawCallRevertNamesTheCall.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `RawCallFailed(target, data)` for any one-word calldata; a planted wrong target fails it

## O42

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_code; `check_codeReturnsTheRuntime` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_codeReturnsTheRuntime](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_code](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_codeReturnsTheRuntime: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_codeReturnsTheRuntime.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: the full runtime of a deployed account, empty for a code-less one

## O43

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_concat

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_concat](../contracts/tests/Operations.t.sol).

**Scope and limitations:** "Allocates once" () is an implementation remark, not tested

## O44

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_sliceBounds (symbolic out-of-range and literal boundary indices, exact bytes); [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (MAXU starts/lengths); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :901-910

**Test/property definitions:** [check_sliceBounds](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Retained formal results:** [check_sliceBounds: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsNoPanicSymbolicTest.check_sliceBounds.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos bounds: bytes lengths 0,1,31,32,33,64,65

## O45

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_sliceRangeClamps

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_sliceRangeClamps](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Retained formal results:** [check_sliceRangeClamps: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsNoPanicSymbolicTest.check_sliceRangeClamps.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** In-range indices are literal boundaries only (symbolic offsets are out of reach)

## O46

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_byteAtStrict; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :924-933

**Test/property definitions:** [check_byteAtStrict](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Retained formal results:** [check_byteAtStrict: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsNoPanicSymbolicTest.check_byteAtStrict.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## O47

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_stringSliceOverValidText; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :845 test_stringSliceClampsFarNegativeStart

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_stringSliceOverValidText](../contracts/tests/OperationsNoPanicSymbolic.t.sol), [test_stringSliceClampsFarNegativeStart](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_stringSliceOverValidText: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsNoPanicSymbolicTest.check_stringSliceOverValidText.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: proved over a fixed set of concrete valid texts; the "validate first, even for an empty range" ordering on invalid input is unit only

## O48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_stringAtOverValidText; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) test_stringAtValidatesTheWholeString

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_stringAtOverValidText](../contracts/tests/OperationsNoPanicSymbolic.t.sol), [test_stringAtValidatesTheWholeString](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_stringAtOverValidText: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsNoPanicSymbolicTest.check_stringAtOverValidText.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Over concrete valid texts

## O49

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :512, :526, :825; [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_utf8ValidatorNeverPanics (<= 4 symbolic bytes, declared errors only); `check_utf8MatchesTheUnicodeTable` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1470-1510

**Test/property definitions:** [check_utf8MatchesTheUnicodeTable](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [check_utf8ValidatorNeverPanics](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Retained formal results:** [check_utf8MatchesTheUnicodeTable: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_utf8MatchesTheUnicodeTable.json), [check_utf8ValidatorNeverPanics: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsNoPanicSymbolicTest.check_utf8ValidatorNeverPanics.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Proved for every string of one to four bytes against the Unicode well-formed table written out independently (307 paths); loosening the E0 overlong bound fails it

## O50

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O51

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O51_OpenZeppelinCombinerAndFoldProof`; retained supporting evidence: [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (viem keccak of sorted concat, a == b 15%); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :990 test_merkleVerify_viaFoldWords

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O51_OpenZeppelinCombinerAndFoldProof](../contracts/tests/ClaimCoverageEasy.t.sol), [test_merkleVerify_viaFoldWords](../contracts/tests/Operations.t.sol).

**Scope and limitations:** OpenZeppelin MerkleProof.processProof is the independent combiner oracle; both child orders and a multi-step fold match its result.

## O52

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) indexOfRef, :389-399 (ordinals incl. int256 min/max); [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol) check_indexOfEmptyNeedle; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :479

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`indexOf`)

**Test/property definitions:** [check_indexOfEmptyNeedle](../contracts/tests/OperationsNoPanicSymbolic.t.sol).

**Scope and limitations:** Empty-needle branch is PROVED

## O53

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_splitRecipe; `check_splitMatchesItsRecipe` [contracts/tests/SlotsSplitSymbolic.t.sol](../contracts/tests/SlotsSplitSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`indexOf`, `slice`, `split`)

**Test/property definitions:** [check_splitMatchesItsRecipe](../contracts/tests/SlotsSplitSymbolic.t.sol), [test_splitRecipe](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_splitMatchesItsRecipe: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/SlotsSplitSymbolicTest.check_splitMatchesItsRecipe.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved over four symbolic bytes and a one-byte delimiter: part count, first part and last part agree with `indexOf` and `slice`; a shifted last part fails it

## O54

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :826-827

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O55

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) splitRef, :415-428; [contracts/tests/OperationsCollections.t.sol](../contracts/tests/OperationsCollections.t.sol), :27, :38

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O56

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) replaceRef, :430-447; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :1227, :1242

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O57

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O58

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) (parity with the fold on one input)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`charset`); [contracts/Collections.sol](../contracts/Collections.sol) (`foldBytes`, `_stampWindows`)

## O59

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_O59_WordAndMaskedTailBoundariesAgainstByteOracle`; retained supporting evidence: correctness: [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (needles up to 70 bytes, near-miss last byte); cost: [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol) testFuzzBoundedSearchResults (10M gas budget per call); `testFuzzBoundedSearchResults`, `testBoundedSearchMaximumExpansionSucceeds`, `testReplacementExpansionExhaustsBudget` [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol) ([docs/bounded-test-checks.json](bounded-test-checks.json) current run)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); AGENTS.md:307-308

**Test/property definitions:** [testBoundedSearchMaximumExpansionSucceeds](../contracts/tests/OperationsNoPanic.t.sol), [testFuzzBoundedSearchResults](../contracts/tests/OperationsNoPanic.t.sol), [testReplacementExpansionExhaustsBudget](../contracts/tests/OperationsNoPanic.t.sol), [test_O59_WordAndMaskedTailBoundariesAgainstByteOracle](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** A naive byte-by-byte oracle checks word and masked-tail lengths 1/2/31/32/33/63/64/65, matches and changed tails. A scratch source mutation removing the tail mask is detected. Replacement bounded search tests cap haystacks at 256 bytes and needles/replacements at 64 bytes, require success or exact EmptyNeedle, and exercise the 16 KiB maximum expansion. A deterministic 8,352,000-byte expansion fails with empty data at 10M gas; a small replacement over the same haystack succeeds. These checks pass in [docs/bounded-test-checks.json](bounded-test-checks.json); the earlier failing suite remains recorded in [docs/halmos-checks.json](halmos-checks.json).

## O60

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_O60_TextGasBudgetFailureAndSuccessfulControl`; retained supporting evidence: [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol), :118, :131, :151, :192; index arithmetic in [contracts/tests/OperationsNoPanicSymbolic.t.sol](../contracts/tests/OperationsNoPanicSymbolic.t.sol); `testFuzzBoundedSearchResults`, `testBoundedSearchMaximumExpansionSucceeds`, `testReplacementExpansionExhaustsBudget` [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol) ([docs/bounded-test-checks.json](bounded-test-checks.json) current run)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1058; AGENTS.md:303-310

**Test/property definitions:** [testBoundedSearchMaximumExpansionSucceeds](../contracts/tests/OperationsNoPanic.t.sol), [testFuzzBoundedSearchResults](../contracts/tests/OperationsNoPanic.t.sol), [testReplacementExpansionExhaustsBudget](../contracts/tests/OperationsNoPanic.t.sol), [test_O60_TextGasBudgetFailureAndSuccessfulControl](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** The same valid concatenation of two 2,048-byte inputs fails at 1,000 gas and succeeds at 1,000,000 gas with exact output. This resource example complements bounded text sweeps without claiming exhaustive exhaustion/overflow behavior. Replacement bounded search tests cap haystacks at 256 bytes and needles/replacements at 64 bytes, require success or exact EmptyNeedle, and exercise the 16 KiB maximum expansion. A deterministic 8,352,000-byte expansion fails with empty data at 10M gas; a small replacement over the same haystack succeeds. These checks pass in [docs/bounded-test-checks.json](bounded-test-checks.json); the earlier failing suite remains recorded in [docs/halmos-checks.json](halmos-checks.json).

## O61

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts) (lengths straddling 78 digits, exact error args); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :511

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1170-1182

## O62

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/string-fuzz.test.ts](../test/string-fuzz.test.ts), :653-663; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O63

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O63_ParseIntGrammarAndExactErrors`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) testFuzz_decimalRoundTrip (parseInt(toString(v)) == v), :132-133 (2^255 panics); [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [testFuzz_decimalRoundTrip](../contracts/tests/OperationsNumeric.t.sol), [test_O63_ParseIntGrammarAndExactErrors](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Focused signed parsing grammar, minimum/maximum boundaries, overflow and exact error positions complement existing fuzz cases.

## O64

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O64_O68_IndependentPythonCanonicalFormatVectors`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) (round trip); [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O64_O68_IndependentPythonCanonicalFormatVectors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O64_O68_IndependentPythonCanonicalFormatVectors](../scripts/generate-claim-coverage-vectors.py).

**Scope and limitations:** Exact signed canonical strings include min/max and seeded full-width values independently formatted with Python integer arithmetic.

## O65

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O65_UnitsGrammarExactErrorsAndOverflow`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) test_decimalParsing, :136 testFuzz_decimalRoundTrip; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :833-834; [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol), :151

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol) (`parseUnits`, `_parseUnits`)

**Test/property definitions:** [testFuzz_decimalRoundTrip](../contracts/tests/OperationsNumeric.t.sol), [test_O65_UnitsGrammarExactErrorsAndOverflow](../contracts/tests/ClaimCoverageEasy.t.sol), [test_decimalParsing](../contracts/tests/OperationsNumeric.t.sol).

**Scope and limitations:** Focused unit grammar, exact error positions, precision 77/78 and overflow boundaries complement existing fuzz cases.

## O66

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) (-1.239 at 2 decimals, "+.001" Ceil, "12." Floor); [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_parseUnitsRoundsAsItsMode` [contracts/tests/OperationsSymbolic.t.sol](../contracts/tests/OperationsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :1630-1671

**Test/property definitions:** [check_parseUnitsRoundsAsItsMode](../contracts/tests/OperationsSymbolic.t.sol).

**Retained formal results:** [check_parseUnitsRoundsAsItsMode: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/OperationsSymbolicTest.check_parseUnitsRoundsAsItsMode.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Proved for every signed five-digit text `d0d1.f0f1f2` at 0 to 4 decimals in all three modes, against a division-based reference (the exact fraction N / 1000), so dropping one to three fractional digits and padding are both covered. Longer texts remain fuzzed without excess digits

## O67

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_O67_UnsignedSignsAndBounds`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol), :120-121 (bare expectRevert on "-0"), :136 round trip

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O67_UnsignedSignsAndBounds](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Unsigned sign handling, exact negative rejection, maximum and overflow boundaries are asserted.

## O68

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageOracle.t.sol](../contracts/tests/ClaimCoverageOracle.t.sol) `test_O64_O68_IndependentPythonCanonicalFormatVectors`; retained supporting evidence: [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) (round trip, decimals 0..77), :115; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :828-829

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [test_O64_O68_IndependentPythonCanonicalFormatVectors](../contracts/tests/ClaimCoverageOracle.t.sol), [test_O64_O68_IndependentPythonCanonicalFormatVectors](../scripts/generate-claim-coverage-vectors.py).

**Scope and limitations:** Canonical unsigned units are checked with literal edge cases and seeded Python formatting vectors, including precision errors.

## O69

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** [contracts/tests/OperationsNumeric.t.sol](../contracts/tests/OperationsNumeric.t.sol) ("-1.002"), :136 round trip; [contracts/tests/OperationsNoPanic.t.sol](../contracts/tests/OperationsNoPanic.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

## O70

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (random tuples vs viem encodeAbiParameters); [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) check_encodeMatchesSolc; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); check_navTupleEncoding [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol), [check_navTupleEncoding](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol).

**Retained formal results:** [check_encodeMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_encodeMatchesSolc.json), [check_navTupleEncoding: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navTupleEncoding.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: The production raw encoder returns the independent solc tuple of the selected static/dynamic/nested components without a bytes envelope. Words remain symbolic; component count, array lengths and payload length are fixed. Arbitrary descriptor families and nesting require separate evidence.

## O71

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/nav-encode-fuzz.test.ts](../test/nav-encode-fuzz.test.ts) (count, length and envelope kinds, error name only); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :627, :634, :644; [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol), :52, :58; [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol), :621; check_navComponentCount [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navStaticComponentWidth [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol); check_navDynamicComponentEnvelope [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_navComponentCount](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navDynamicComponentEnvelope](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol), [check_navStaticComponentWidth](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol).

**Retained formal results:** [check_navComponentCount: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navComponentCount.json), [check_navDynamicComponentEnvelope: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navDynamicComponentEnvelope.json), [check_navStaticComponentWidth: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navStaticComponentWidth.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Added properties pin complete count, static-width and dynamic-envelope errors through both production encoders. These do not establish every InvalidTypeDescriptor or nested InvalidComponentValue case for Operations.encode; earlier concrete evidence remains retained.

## O72

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) (decodes the envelope and compares to solc); [test/collection-codec.test.ts](../test/collection-codec.test.ts); [contracts/tests/OperationsCollections.t.sol](../contracts/tests/OperationsCollections.t.sol); [contracts/tests/AbiCodec.t.sol](../contracts/tests/AbiCodec.t.sol) (both faces reject identically); check_navTupleEncoding [contracts/tests/ClaimNavigationEncodingSymbolic.t.sol](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_navTupleEncoding](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol).

**Retained formal results:** [check_navTupleEncoding: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNavigationEncodingSymbolicTest.check_navTupleEncoding.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: For the selected canonical tuple, encodeBytes returns exactly abi.encode of the independently computed raw tuple. A mutant returning the bare tuple instead of its bytes envelope is killed. Arbitrary descriptors, sizes and malformed values remain outside the new property.

## O73

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/AbiCodecSymbolic.t.sol](../contracts/tests/AbiCodecSymbolic.t.sol) check_encodeMatchesSolc ((uint8,bool,address,bytes4): accepts exactly what solc decodes)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** `AGENTS.md` (descriptor doctrine); [contracts/Operations.sol](../contracts/Operations.sol) (`encode`, `encodeBytes`)

**Test/property definitions:** [check_encodeMatchesSolc](../contracts/tests/AbiCodecSymbolic.t.sol).

**Retained formal results:** [check_encodeMatchesSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/AbiCodecSymbolicTest.check_encodeMatchesSolc.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The former documentation contradiction was corrected in e6d375e. The solc differential property covers `(uint8,bool,address,bytes4)`; historical contradiction retained by A30/L36/E9.

## O74

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_dirtyAddressArg_revertsInsideCall; `check_dirtyWordIntoTypedParameterIsCallFailed` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol); [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_dirtyWordIntoTypedParameterIsCallFailed](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_dirtyAddressArg_revertsInsideCall](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_dirtyWordIntoTypedParameterIsCallFailed: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_dirtyWordIntoTypedParameterIsCallFailed.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved through `read` into `balance(address)`: a dirty word is `CallFailed(ops, exact calldata)`, a clean one succeeds

## O75

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/math-fuzz.test.ts](../test/math-fuzz.test.ts) (decodes Panic codes for rpow and signed mulDiv), :362-406; [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :264 (stdError selectors); check_arithmeticRpowZeroBase [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol); check_arithmeticExpWadOverflow [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol); check_arithmeticSignedMagnitudeOverflow [contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_arithmeticExpWadOverflow](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [check_arithmeticRpowZeroBase](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol), [check_arithmeticSignedMagnitudeOverflow](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol).

**Retained formal results:** [check_arithmeticExpWadOverflow: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticExpWadOverflow.json), [check_arithmeticRpowZeroBase: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticRpowZeroBase.json), [check_arithmeticSignedMagnitudeOverflow: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimArithmeticBoundariesSymbolicTest.check_arithmeticSignedMagnitudeOverflow.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Full rpow operands at base zero and every expWad input at/above 135305999368893231589 must match exact caught compiler-generated panics. Signed magnitude overflow is selected through mulDiv(MIN,-1,1) for all three rounding modes. Compiler oracle failure is explicitly asserted before comparing bytes. General signed magnitude inputs and successful wide arithmetic are not proved.

## O76

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (Operations leaves with BigInt references inside random trees); [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol), :1331; [contracts/tests/OperationsExtensionIntegration.t.sol](../contracts/tests/OperationsExtensionIntegration.t.sol)

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol); README.md:8

**Scope and limitations:** Oracle covers ten binary word operations

## O79

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [test/bytecode-size.test.ts](../test/bytecode-size.test.ts), :22

**Supporting sources:** AGENTS.md:384-386

## O80

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** structural: [contracts/Operations.sol](../contracts/Operations.sol) import, package.json:30 ("5.6.1", exact), foundry.toml:13; behavior covered by O8, O19, O21, O22

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol), :298, :434, :567, :1439; AGENTS.md:376-383

**Related behavioral evidence:** [O8](#o8), [O19](#o19), [O21](#o21), [O22](#o22).

**Scope and limitations:** Verified by inspection; no test guards the exact pin

## O81

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol) test_core_judges_lowercasedSymbol (hash(toLower(symbol())) == keccak("weth")); `check_stringEnvelopeSplicesIntoBytesParameters` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Operations.sol](../contracts/Operations.sol)

**Test/property definitions:** [check_stringEnvelopeSplicesIntoBytesParameters](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_core_judges_lowercasedSymbol](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_stringEnvelopeSplicesIntoBytesParameters: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_stringEnvelopeSplicesIntoBytesParameters.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for strings of 0, 5 and 32 bytes through `read` into `byteLen`

## L1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldWordsIsLeftFold [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); fold differential fuzz [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts) (JS byte-level engine `simFold` :1164); test_foldWords_sum [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 350-354

**Test/property definitions:** [check_foldWordsIsLeftFold](../contracts/tests/WordLambdasSymbolic.t.sol), [test_foldWords_sum](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_foldWordsIsLeftFold: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_foldWordsIsLeftFold.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3 words with a non-commutative lambda; JS differential covers n<=12 words over 11 Operations lambdas

## L2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldRangeAndBytes [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz foldRange/foldBytes cases [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 329-332

**Test/property definitions:** [check_foldRangeAndBytes](../contracts/tests/WordLambdasSymbolic.t.sol).

**Retained formal results:** [check_foldRangeAndBytes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_foldRangeAndBytes.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3; JS differential n<=30 (range) and n<=40 (bytes)

## L3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldExits [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz simFold exit handling [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 295-297

**Test/property definitions:** [check_foldExits](../contracts/tests/WordLambdasSymbolic.t.sol).

**Retained formal results:** [check_foldExits: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_foldExits.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3, all three modes

## L4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_fold_anyShortCircuits [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_fold_allShortCircuits [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); compose-fuzz simFold breaks before later failing lambdas [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); check_orderEarlyFoldDomains [contracts/tests/ClaimCallbackOrderingSymbolic.t.sol](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol); check_orderEarlyReductions [contracts/tests/ClaimCallbackOrderingSymbolic.t.sol](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol); check_orderEarlyValuePredicates [contracts/tests/ClaimCallbackOrderingSymbolic.t.sol](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_orderEarlyFoldDomains](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol), [check_orderEarlyReductions](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol), [check_orderEarlyValuePredicates](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol), [test_fold_allShortCircuits](../contracts/tests/Operations.t.sol), [test_fold_anyShortCircuits](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_orderEarlyFoldDomains: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbackOrderingSymbolicTest.check_orderEarlyFoldDomains.json), [check_orderEarlyReductions: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbackOrderingSymbolicTest.check_orderEarlyReductions.json), [check_orderEarlyValuePredicates: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbackOrderingSymbolicTest.check_orderEarlyValuePredicates.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Range/bytes/word Any/All folds, Any/All word reductions and typed any/all/find predicates must succeed with exact results after one callback, skipping a callback that would fail at index one or two. Ghost counts observe even reverted callback attempts; concrete expectCall cross-checks sample counts. Arbitrary lengths, later exit points and callback behavior require separate evidence.

## L5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_elementWinsOverlap [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); check_mapWordsKeepsTemplatePristine [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz windows anywhere in [4,36] stamped like `_stampWindows` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts), 1263-1270; check_orderWindowStamping [contracts/tests/ClaimCallbackOrderingSymbolic.t.sol](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 377-379

**Test/property definitions:** [check_elementWinsOverlap](../contracts/tests/WordLambdasSymbolic.t.sol), [check_mapWordsKeepsTemplatePristine](../contracts/tests/WordLambdasSymbolic.t.sol), [check_orderWindowStamping](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol).

**Retained formal results:** [check_elementWinsOverlap: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_elementWinsOverlap.json), [check_mapWordsKeepsTemplatePristine: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_mapWordsKeepsTemplatePristine.json), [check_orderWindowStamping: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbackOrderingSymbolicTest.check_orderWindowStamping.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: An independent receiver compares every calldata byte against six literal expected streams: accumulator first, element windows in supplied order, and untouched bytes preserved. Aligned and half-word overlaps make mutual element-window order observable. An altered final byte must be refused by the receiver, guarding the partial comparison word. Arbitrary windows, template sizes, traversals and other stamping consumers remain outside the new scope.

## L6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_fold_emptyDomainReturnsInit [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); compose-fuzz simFold (count 0 before dead-target check) [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); check_lambdaErrors case 0 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [test_fold_emptyDomainReturnsInit](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_lambdaErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_lambdaErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos proves window check on empty foldWords; the "target untouched" half is DIFFERENTIAL (JS) and UNIT

## L7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol) (case 0); test_foldAccumulatorWindowBounded [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_fold_offsetOutOfBounds [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_mapWords_errors [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_filterWords_errors [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); compose-fuzz :1175-1176, 1296-1297; `check_accumulatorWindow` [contracts/tests/CallbackContextSymbolic.t.sol](../contracts/tests/CallbackContextSymbolic.t.sol) (a symbolic accumulator offset over an empty fold with no target code: accepted exactly when a word fits, otherwise `LambdaOffsetOutOfBounds(offset, length)` with no call made; a 31-byte template refused at every offset)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 302

**Test/property definitions:** [check_accumulatorWindow](../contracts/tests/CallbackContextSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [test_filterWords_errors](../contracts/tests/Operations.t.sol), [test_foldAccumulatorWindowBounded](../contracts/tests/MutationGaps.t.sol), [test_fold_offsetOutOfBounds](../contracts/tests/Operations.t.sol), [test_mapWords_errors](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_accumulatorWindow: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CallbackContextSymbolicTest.check_accumulatorWindow.json), [check_lambdaErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_lambdaErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos covers the element window and the accumulator window on foldWords, the latter checked before any call; map/filter windows are UNIT plus DIFFERENTIAL (error name only).

## L8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors case 1 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); check_callbackErrors [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); test_fold_codelessTarget [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); testGenericCallbacksRejectCodelessTargetsWhenCalled [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (identity precompile 0x04)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 303, 382

**Test/property definitions:** [check_callbackErrors](../contracts/tests/ValuesSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testGenericCallbacksRejectCodelessTargetsWhenCalled](../contracts/tests/Collections.t.sol), [test_fold_codelessTarget](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_callbackErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_callbackErrors.json), [check_lambdaErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_lambdaErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Precompile exclusion is UNIT (one precompile, filterValues only)

## L9

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_callbackErrors [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_lambdaErrors case 1 (n=0 must succeed) [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testGenericCallbacksRejectCodelessTargetsWhenCalled [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 679-681

**Test/property definitions:** [check_callbackErrors](../contracts/tests/ValuesSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testGenericCallbacksRejectCodelessTargetsWhenCalled](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_callbackErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_callbackErrors.json), [check_lambdaErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_lambdaErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos covers mapValues and mapWords; other traversals UNIT at most

## L10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors case 2 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol) (exact bytes); check_callbackErrors [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); test_fold_anyShortCircuits [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); testCallbackErrorsHaveContext [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `check_binaryCallbackContext` [contracts/tests/CallbackContextSymbolic.t.sol](../contracts/tests/CallbackContextSymbolic.t.sol) (sortValues and uniqueValues with a later pair's callback reverting: exact `CallbackFailed(operation, 2, 3 or 1, target, calldata, reason)` over symbolic values and reason words)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 299-301, 383-384, 682-683

**Test/property definitions:** [check_binaryCallbackContext](../contracts/tests/CallbackContextSymbolic.t.sol), [check_callbackErrors](../contracts/tests/ValuesSymbolic.t.sol), [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testCallbackErrorsHaveContext](../contracts/tests/Collections.t.sol), [test_fold_anyShortCircuits](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_binaryCallbackContext: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CallbackContextSymbolicTest.check_binaryCallbackContext.json), [check_callbackErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_callbackErrors.json), [check_lambdaErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_lambdaErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: `other` is asserted nonzero with the exact calldata and reason for the sort and unique binary callbacks; indexOf and the value folds are still unary or unit only.

## L11

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_lambdaErrors case 3 [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testWordCallbacksRejectMalformedResults [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); test_fold_lambdaReturnTooShort [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); test_mapWords_shortReturn [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 384-385, 1245-1252

**Test/property definitions:** [check_lambdaErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [testWordCallbacksRejectMalformedResults](../contracts/tests/Collections.t.sol), [test_fold_lambdaReturnTooShort](../contracts/tests/Operations.t.sol), [test_mapWords_shortReturn](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_lambdaErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_lambdaErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos: mapWords with a 64-byte return; short return and folds UNIT

## L12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_filterWordsNeedsCanonicalBool [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz filterWords [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); test_filterWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1079-1105

**Test/property definitions:** [check_filterWordsNeedsCanonicalBool](../contracts/tests/WordLambdasSymbolic.t.sol), [test_filterWords](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_filterWordsNeedsCanonicalBool: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_filterWordsNeedsCanonicalBool.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3

## L13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_mapWordsKeepsTemplatePristine [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); compose-fuzz mapWords [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); test_mapWords_emptyPayload [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_mapWordsKeepsTemplatePristine](../contracts/tests/WordLambdasSymbolic.t.sol), [test_mapWords_emptyPayload](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_mapWordsKeepsTemplatePristine: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_mapWordsKeepsTemplatePristine.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3; JS differential n<=12

## L14

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_unalignedPayloadsRevert [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol) (7 ops, lengths 1,31,33,127); test_zipWordsChecksEachSide [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); compose-fuzz foldWords/mapWords/filterWords unaligned cases [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts), 1174, 1295; string-fuzz word ops [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 353-354, 494-495

**Test/property definitions:** [check_unalignedPayloadsRevert](../contracts/tests/WordsSymbolic.t.sol), [test_zipWordsChecksEachSide](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_unalignedPayloadsRevert: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_unalignedPayloadsRevert.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: foldWords/mapWords/filterWords alignment is DIFFERENTIAL (error name only), not in the Halmos property

## L15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_iotaWords [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz iotaWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_iotaWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_iotaWords](../contracts/tests/WordsSymbolic.t.sol), [test_iotaWords](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_iotaWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_iotaWords.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4; JS n<=60

## L16

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_L16_IotaAllocationOverflowAndGasExhaustion`

**Recorded run:** [results, commands and source hashes](claim-gap-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); AGENTS.md:315-318

**Test/property definitions:** [test_L16_IotaAllocationOverflowAndGasExhaustion](../contracts/tests/ClaimEvidenceGaps.t.sol).

**Scope and limitations:** Checks multiplication Panic(0x11), allocator Panic(0x41), empty failure under a 50,000-gas memory-expansion budget, and a normal three-word output. The failure sizes are concrete examples, not a portable maximum successful allocation.

## L17

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_wordIndexOfIsLeastIndex [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz wordIndexOf [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_wordIndexOf [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_wordIndexOfIsLeastIndex](../contracts/tests/WordsSymbolic.t.sol), [test_wordIndexOf](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_wordIndexOfIsLeastIndex: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_wordIndexOfIsLeastIndex.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4

## L18

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reverseWords [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz reverseWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_reverseWords](../contracts/tests/WordsSymbolic.t.sol).

**Retained formal results:** [check_reverseWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_reverseWords.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4

## L19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipAreInverse [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); check_zipRejectsMismatchAndUnzipBadLane [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz zipWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 522-524

**Test/property definitions:** [check_zipRejectsMismatchAndUnzipBadLane](../contracts/tests/WordsSymbolic.t.sol), [check_zipUnzipAreInverse](../contracts/tests/WordsSymbolic.t.sol).

**Retained formal results:** [check_zipRejectsMismatchAndUnzipBadLane: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_zipRejectsMismatchAndUnzipBadLane.json), [check_zipUnzipAreInverse: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_zipUnzipAreInverse.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4

## L20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipAreInverse [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); check_unzipLanes [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); check_zipRejectsMismatchAndUnzipBadLane [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz unzipWords [test/string-fuzz.test.ts](../test/string-fuzz.test.ts)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 544-547

**Test/property definitions:** [check_unzipLanes](../contracts/tests/WordsSymbolic.t.sol), [check_zipRejectsMismatchAndUnzipBadLane](../contracts/tests/WordsSymbolic.t.sol), [check_zipUnzipAreInverse](../contracts/tests/WordsSymbolic.t.sol).

**Retained formal results:** [check_unzipLanes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_unzipLanes.json), [check_zipRejectsMismatchAndUnzipBadLane: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_zipRejectsMismatchAndUnzipBadLane.json), [check_zipUnzipAreInverse: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_zipUnzipAreInverse.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4

## L21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sortWordsIsSortedPermutation [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); testFuzzSortWordsMatchesInsertionOracle [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (in-test insertion-sort oracle, n<=128); string-fuzz sortWords (JS sort) [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_sortWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sortWordsIsSortedPermutation](../contracts/tests/WordsSymbolic.t.sol), [testFuzzSortWordsMatchesInsertionOracle](../contracts/tests/Collections.t.sol), [test_sortWords](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_sortWordsIsSortedPermutation: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_sortWordsIsSortedPermutation.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4; DIFFERENTIAL to n<=128

## L22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sortIsStableByKey [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (sortValues); testFuzzSortIsStablePermutation [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** README.md:9; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md); [contracts/Collections.sol](../contracts/Collections.sol), 774-775

**Test/property definitions:** [check_sortIsStableByKey](../contracts/tests/ValuesSymbolic.t.sol), [testFuzzSortIsStablePermutation](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_sortIsStableByKey: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_sortIsStableByKey.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: stability proved for sortValues n<=3 (one merge level) and fuzzed n<=12; for sortWords stability is unobservable (equal words are identical), so only the sorted-permutation result matters there. "Bottom-up merge" is an implementation claim, not tested

## L23

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageSort.t.sol](../contracts/tests/ClaimCoverageSort.t.sol) `test_L23_OddLengthsReverseAndDuplicateComparisonCounts`; retained supporting evidence: [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_L23_MergeSortComparisonCountsOnPowersOfTwo`

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 777

**Test/property definitions:** [test_L23_MergeSortComparisonCountsOnPowersOfTwo](../contracts/tests/ClaimEvidenceGaps.t.sol), [test_L23_OddLengthsReverseAndDuplicateComparisonCounts](../contracts/tests/ClaimCoverageSort.t.sol).

**Scope and limitations:** Partial: finite exact sortValues callback comparison counts now include odd lengths 3/5/7/9/17/31/63 and ascending/reversed/duplicate patterns; both sortValues and sortWords outputs are checked. Previous power-of-two checks remain. These checks do not establish universal O(n log n) moves/comparisons or O(n) scratch space.

## L24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_sortWords_signedRecipe [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); `check_signedSortRecipe` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); AGENTS.md:142-143

**Test/property definitions:** [check_signedSortRecipe](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_sortWords_signedRecipe](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_signedSortRecipe: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_signedSortRecipe.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved over three symbolic int256 words against a sorting network; a descending-sort mutant fails it

## L25

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sumWordsIsExactOrReverts [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz sumWords (expects Panic11) [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_sumWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sumWordsIsExactOrReverts](../contracts/tests/WordsSymbolic.t.sol), [test_sumWords](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_sumWordsIsExactOrReverts: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_sumWordsIsExactOrReverts.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=4 proves exact value or revert; the Panic code is DIFFERENTIAL/UNIT

## L26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_sumWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); `check_sumWordsMatchesTheFoldRecipe` [contracts/tests/RecipesOffsetsSymbolic.t.sol](../contracts/tests/RecipesOffsetsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sumWordsMatchesTheFoldRecipe](../contracts/tests/RecipesOffsetsSymbolic.t.sol), [test_sumWords](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_sumWordsMatchesTheFoldRecipe: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/RecipesOffsetsSymbolicTest.check_sumWordsMatchesTheFoldRecipe.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved over three words: equal checked sums, and both refuse an overflow (Panic(0x11) from sumWords, CallbackFailed from the fold); an unchecked sum fails it

## L27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_uniqueWordsKeepsFirstOccurrences [contracts/tests/WordsSymbolic.t.sol](../contracts/tests/WordsSymbolic.t.sol); string-fuzz uniqueWords (both modes, JS Set/adjacent filter) [test/string-fuzz.test.ts](../test/string-fuzz.test.ts); test_uniqueWords [contracts/tests/Operations.t.sol](../contracts/tests/Operations.t.sol); testUniqueUnorderedStable [contracts/tests/OperationsCollections.t.sol](../contracts/tests/OperationsCollections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_uniqueWordsKeepsFirstOccurrences](../contracts/tests/WordsSymbolic.t.sol), [testUniqueUnorderedStable](../contracts/tests/OperationsCollections.t.sol), [test_uniqueWords](../contracts/tests/Operations.t.sol).

**Retained formal results:** [check_uniqueWordsKeepsFirstOccurrences: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordsSymbolicTest.check_uniqueWordsKeepsFirstOccurrences.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos proves ordered=false and ordered=true on sorted input (n<=4); ordered=true on ungrouped input is DIFFERENTIAL; the O(n)/O(n^2) cost is unbacked

## L31

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testFuzzFoldsNeverPanic [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol) (badExit asserts empty data at :296-298); check_edgesInvalidFoldExit [contracts/tests/ClaimBoundaryCasesSymbolic.t.sol](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); AGENTS.md:311-312

**Test/property definitions:** [check_edgesInvalidFoldExit](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol), [testFuzzFoldsNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol).

**Retained formal results:** [check_edgesInvalidFoldExit: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimBoundaryCasesSymbolicTest.check_edgesInvalidFoldExit.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Every invalid raw FoldExit word, including dirty upper bits, yields the exact empty decoder revert through all three enum-bearing entrypoints. Other ABI fields use fixed complete encodings. A fourth enum-member mutant reaches the body and produces a different outcome, checking that this result is specific to enum rejection. This is decoder evidence, not a guarantee of successful folds or arbitrary callback/window behavior.

## L32

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** testFuzzWordPayloadsNeverPanic [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol); testFuzzFoldsNeverPanic :109; testFuzzValuesNeverPanic :211

**Supporting sources:** [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol) (suite claim); AGENTS.md:312-315

**Test/property definitions:** [testFuzzFoldsNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol), [testFuzzValuesNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol), [testFuzzWordPayloadsNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol).

**Scope and limitations:** 10M gas budget per call; fold counts < 300, values < 20; iotaWords excluded (L16)

## L33

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_L33_ExactPredicateCallbackFailureMatrix`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_L33_ExactWordFoldCallbackFailureMatrix`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_exactSignalSurvivesEveryWrapperAndProbe`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_ordinaryErrorsKeepExactWrappers`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_wordCallbackGasSweeps`; [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) `test_valueCallbackGasSweeps`; retained supporting evidence: testHostileTargetsFailDeclared [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol); [contracts/tests/GasPropagation.t.sol](../contracts/tests/GasPropagation.t.sol) gas sweeps and `test_ordinaryErrorsKeepExactWrappers`; check_behaviorCallbacksExactFailures [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol); check_behaviorReservedSignalAcrossControlRoutes [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** `AGENTS.md` (Testing law); [contracts/Collections.sol](../contracts/Collections.sol) (`_callWord`, `_callValue`)

**Test/property definitions:** [check_behaviorCallbacksExactFailures](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [check_behaviorReservedSignalAcrossControlRoutes](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [testHostileTargetsFailDeclared](../contracts/tests/CollectionsNoPanic.t.sol), [test_L33_ExactPredicateCallbackFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_L33_ExactWordFoldCallbackFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_exactSignalSurvivesEveryWrapperAndProbe](../contracts/tests/GasPropagation.t.sol), [test_ordinaryErrorsKeepExactWrappers](../contracts/tests/GasPropagation.t.sol), [test_valueCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol), [test_wordCallbackGasSweeps](../contracts/tests/GasPropagation.t.sol).

**Retained formal results:** [check_behaviorCallbacksExactFailures: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorCallbacksExactFailures.json), [check_behaviorReservedSignalAcrossControlRoutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorReservedSignalAcrossControlRoutes.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Word folds and typed predicates exercise ordinary reverts, empty/31/64-byte replies and noncanonical 32-byte boolean results at element zero or one. Full CallbackFailed and InvalidCallbackResult context and calldata are asserted. Word folds retain raw result 2; predicates reject it. Both callback routes propagate the exact reserved marker. Ordinary revert cases exclude symbolic exhaustion artifacts; other callback routes and actual gas exhaustion retain separate evidence.

## L34

**Recorded evidence:** DIFFERENTIAL / SUITE PASSED.

**References:** [test/collection-codec.test.ts](../test/collection-codec.test.ts) (viem encodeAbiParameters oracle, 8 type shapes incl. nested dynamic); testDynamicPackUnpack [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); testNestedFixedDynamicArray :124; testNestedArraysAndStaticStruct :137; testFuzzUintArray :228

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [testDynamicPackUnpack](../contracts/tests/Collections.t.sol), [testFuzzUintArray](../contracts/tests/Collections.t.sol), [testNestedArraysAndStaticStruct](../contracts/tests/Collections.t.sol), [testNestedFixedDynamicArray](../contracts/tests/Collections.t.sol).

**Scope and limitations:** Fixed fixtures, not random generation

## L35

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [test/collection-codec.test.ts](../test/collection-codec.test.ts) (rejects only, error not checked); testRejectMalformedOffsetsAndPadding [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (bare expectRevert); test_packRejectsStaticValueOfWrongLength [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_packRejectsMalformedDynamicValue :69; test_unpackNamesTrailingBytes :559; check_behaviorNestedPack [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorNestedUnpack [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorNestedUnpackEncodingFaults [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorNestedPackTrailingData [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorCompositePaddingErrors [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 660-662

**Test/property definitions:** [check_behaviorCompositePaddingErrors](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedPack](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedPackTrailingData](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedUnpack](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedUnpackEncodingFaults](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [testRejectMalformedOffsetsAndPadding](../contracts/tests/Collections.t.sol), [test_packRejectsMalformedDynamicValue](../contracts/tests/MutationGaps.t.sol), [test_packRejectsStaticValueOfWrongLength](../contracts/tests/MutationGaps.t.sol), [test_unpackNamesTrailingBytes](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_behaviorCompositePaddingErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorCompositePaddingErrors.json), [check_behaviorNestedPack: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedPack.json), [check_behaviorNestedPackTrailingData: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedPackTrailingData.json), [check_behaviorNestedUnpack: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedUnpack.json), [check_behaviorNestedUnpackEncodingFaults: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedUnpackEncodingFaults.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: packArray/unpackArray validate two uint8[] elements of two words each, with independently encoded canonical controls and exact dirty-word offsets found from sentinel fixtures. Added root/element-offset/count faults and arbitrary one-byte trailing data must reject. A selected (uint8[],bytes[]) pack case rejects dirty nested padding at its exact byte. These are bounded families, not arbitrary element descriptors or array lengths.

## L37

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reverseValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_flattenValues :354; test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_emptyTraversalsStillParseTheDescriptor :143; test_remainingTraversalValidations :628; test_zipAndFindValidateElements :784; testFlattenValidatesEvenEmptyDescriptorsAndNestedValues [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_flattenValues](../contracts/tests/ValuesSymbolic.t.sol), [check_reverseValues](../contracts/tests/ValuesSymbolic.t.sol), [testFlattenValidatesEvenEmptyDescriptorsAndNestedValues](../contracts/tests/Collections.t.sol), [test_emptyTraversalsStillParseTheDescriptor](../contracts/tests/MutationGaps.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol), [test_zipAndFindValidateElements](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_flattenValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_flattenValues.json), [check_reverseValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_reverseValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos only for reverse and flatten over uint8; callback traversals UNIT

## L38

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_mapAppliesInOrder [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_mapValidatesResults :76; testCallbackErrorsHaveContext [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_mapAppliesInOrder](../contracts/tests/ValuesSymbolic.t.sol), [check_mapValidatesResults](../contracts/tests/ValuesSymbolic.t.sol), [testCallbackErrorsHaveContext](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_mapAppliesInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_mapAppliesInOrder.json), [check_mapValidatesResults: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_mapValidatesResults.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** n<=3, uint256 in / uint8 out

## L39

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_filterKeepsMatchesInOrder [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testMapFilterFold [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_filterKeepsMatchesInOrder](../contracts/tests/ValuesSymbolic.t.sol), [testMapFilterFold](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_filterKeepsMatchesInOrder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_filterKeepsMatchesInOrder.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** n<=3

## L40

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testMalformedPredicateAndComparatorAreRejected [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (answer 2); test_predicateNeedsOneWord [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (two words); `check_expressionPredicateIsCanonical` [contracts/tests/CompositionSymbolic.t.sol](../contracts/tests/CompositionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1525-1553; AGENTS.md:69-70

**Test/property definitions:** [check_expressionPredicateIsCanonical](../contracts/tests/CompositionSymbolic.t.sol), [testMalformedPredicateAndComparatorAreRejected](../contracts/tests/Collections.t.sol), [test_predicateNeedsOneWord](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_expressionPredicateIsCanonical: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CompositionSymbolicTest.check_expressionPredicateIsCanonical.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for `filterValues` through an expression callback over every word: 1 keeps, 0 drops, anything else is `InvalidCallbackResult` naming the element and the target. The other predicate traversals share `_predicate`

## L41

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_foldIsLeftFold [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testMapFilterFold [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_foldIsLeftFold](../contracts/tests/ValuesSymbolic.t.sol), [testMapFilterFold](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_foldIsLeftFold: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_foldIsLeftFold.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** n<=3

## L42

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_remainingTraversalValidations [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_foldValidatesInitialAndResults` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 748

**Test/property definitions:** [check_foldValidatesInitialAndResults](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_foldValidatesInitialAndResults: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_foldValidatesInitialAndResults.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `initial` is refused with `InvalidValue(0)` before any call, and each result that leaves `uint8` with `InvalidCallbackResult`; skipping the initial check fails it

## L43

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sortIsStableByKey [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (comparator returns -1/0/1)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sortIsStableByKey](../contracts/tests/ValuesSymbolic.t.sol).

**Retained formal results:** [check_sortIsStableByKey: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_sortIsStableByKey.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** n<=3; a two-word comparator return is UNIT (testMalformedPredicateAndComparatorAreRejected [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol))

## L44

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageModerate.t.sol](../contracts/tests/ClaimCoverageModerate.t.sol) `test_L44_InconsistentOrderingAndEqualityRetainAlgorithmOutcomes`; retained supporting evidence: testFuzzValuesNeverPanic [contracts/tests/CollectionsNoPanic.t.sol](../contracts/tests/CollectionsNoPanic.t.sol) (constant-answer hostile targets as comparator)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (contract NatSpec, `sortValues`, `uniqueValues`, `_callValue`, `_predicate`)

**Test/property definitions:** [testFuzzValuesNeverPanic](../contracts/tests/CollectionsNoPanic.t.sol), [test_L44_InconsistentOrderingAndEqualityRetainAlgorithmOutcomes](../contracts/tests/ClaimCoverageModerate.t.sol).

**Scope and limitations:** Concrete inconsistent comparator decisions retain the resulting reversed order; always-equal uniqueness retains the first value and never-equal retains duplicated encodings. Semantic ordering/equivalence guarantees still require their documented comparator laws.

## L45

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_uniqueKeepsFirstRepresentatives [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (ordered=false); testUniqueValuesOrderedKeepsFirstRepresentative [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); testUniqueUnorderedChecksEveryPreviousValue :247; testUniqueValuesEmptyAndSingleton :281; `check_uniqueOrderedComparesWithTheLastKept` [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_uniqueKeepsFirstRepresentatives](../contracts/tests/ValuesSymbolic.t.sol), [check_uniqueOrderedComparesWithTheLastKept](../contracts/tests/ValuesSymbolic.t.sol), [testUniqueUnorderedChecksEveryPreviousValue](../contracts/tests/Collections.t.sol), [testUniqueValuesEmptyAndSingleton](../contracts/tests/Collections.t.sol), [testUniqueValuesOrderedKeepsFirstRepresentative](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_uniqueKeepsFirstRepresentatives: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_uniqueKeepsFirstRepresentatives.json), [check_uniqueOrderedComparesWithTheLastKept: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_uniqueOrderedComparesWithTheLastKept.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Halmos now covers ordered=false and ordered=true (n<=3; ordered=true compares only with the last kept element); the O(n) vs O(n^2) call counts are unbacked

## L46

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_flattenValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_flattenValues](../contracts/tests/ValuesSymbolic.t.sol).

**Retained formal results:** [check_flattenValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_flattenValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Two groups, n<=3

## L47

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reverseValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_reverseValues](../contracts/tests/ValuesSymbolic.t.sol).

**Retained formal results:** [check_reverseValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_reverseValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** n<=3

## L48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_sliceIsJsSlice [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testGenericTraversalSliceZipAndShortCircuit [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sliceIsJsSlice](../contracts/tests/ValuesSymbolic.t.sol), [testGenericTraversalSliceZipAndShortCircuit](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_sliceIsJsSlice: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_sliceIsJsSlice.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Indices case-split to {0,1,3,5,-1,-3,int256.min}, n<=3; int256.max end only UNIT

## L49

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (a selected dirty element is refused); `check_sliceValidatesOnlySelected` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_sliceValidatesOnlySelected](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_sliceValidatesOnlySelected: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_sliceValidatesOnlySelected.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a junk element outside the slice is never validated, inside it is refused with `InvalidValue(0)`

## L50

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_indexOfValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); test_traversalsValidateNarrowInputs [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (dirty needle)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_indexOfValues](../contracts/tests/ValuesSymbolic.t.sol), [test_traversalsValidateNarrowInputs](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_indexOfValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_indexOfValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** n<=3

## L51

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_findAnyAllAgree [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); testGenericTraversalSliceZipAndShortCircuit [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (a reverting "bomb" element past the decision)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_findAnyAllAgree](../contracts/tests/ValuesSymbolic.t.sol), [testGenericTraversalSliceZipAndShortCircuit](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_findAnyAllAgree: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_findAnyAllAgree.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Values PROVED n<=3; short-circuit is UNIT (any/find/all only; indexOf short-circuit untested)

## L52

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol) (uint256,string); check_zipValuesRefusals :336; test_zipMultiWordStaticSides [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_zipUnzipValues](../contracts/tests/ValuesSymbolic.t.sol), [check_zipValuesRefusals](../contracts/tests/ValuesSymbolic.t.sol), [test_zipMultiWordStaticSides](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_zipUnzipValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_zipUnzipValues.json), [check_zipValuesRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_zipValuesRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Static-pair bare form UNIT

## L53

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_zipUnzipValues [contracts/tests/ValuesSymbolic.t.sol](../contracts/tests/ValuesSymbolic.t.sol); check_zipValuesRefusals :336; test_unzipValidatesParts [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); test_unzipRequiresTheEnvelope :171; test_unzipRefusesNonCanonicalPairs :566; testUnzipBothDynamicAndStaticLanes [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1354-1389

**Test/property definitions:** [check_zipUnzipValues](../contracts/tests/ValuesSymbolic.t.sol), [check_zipValuesRefusals](../contracts/tests/ValuesSymbolic.t.sol), [testUnzipBothDynamicAndStaticLanes](../contracts/tests/Expressions.t.sol), [test_unzipRefusesNonCanonicalPairs](../contracts/tests/MutationGaps.t.sol), [test_unzipRequiresTheEnvelope](../contracts/tests/MutationGaps.t.sol), [test_unzipValidatesParts](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_zipUnzipValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_zipUnzipValues.json), [check_zipValuesRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ValuesSymbolicTest.check_zipValuesRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Inverse and lane error proved; validation of the other side and envelope rules UNIT

## L54

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testEmptyValidatesDescriptorsAndCallback [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (first past constants); test_callbackDescriptorMustBeAMatchingTuple [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (non-tuple, count mismatch); `check_invalidCallbackRules` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`InvalidCallback`, `_prepareCallback`)

**Test/property definitions:** [check_invalidCallbackRules](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [testEmptyValidatesDescriptorsAndCallback](../contracts/tests/Collections.t.sol), [test_callbackDescriptorMustBeAMatchingTuple](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_invalidCallbackRules: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_invalidCallbackRules.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for a slot past the constants, a repeated slot, a non-tuple descriptor and a constant count that differs, each before any call; allowing a repeated slot fails it

## L70

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_extendedScalarSlotTypes; check_extendedCompoundSlotTypes; check_extendedByteSlotEncodings; check_extendedNestedSlotOffsets [contracts/tests/ClaimTypeFamiliesSymbolic.t.sol](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol); check_claimSlotsMatchingAndDifferent; check_claimBinarySlots; check_claimConstantsBeforeTraversal [contracts/tests/ClaimCallbacksSymbolic.t.sol](../contracts/tests/ClaimCallbacksSymbolic.t.sol); [test/callback-boundaries.test.ts](../test/callback-boundaries.test.ts) (L70); testPreparedCallbackRetainsStaticSlotWidth [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); test_remainingTraversalValidations [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); check_behaviorNestedCallbackSlots [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorCompositePaddingErrors [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol)

**Replaces:** [L55](#l55); each prior statement and its evidence are retained below.

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`_prepareCallback`, `_prepare`, `_callValue`, `_bindValue`)

**Test/property definitions:** [check_behaviorCompositePaddingErrors](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedCallbackSlots](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_claimBinarySlots](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_claimConstantsBeforeTraversal](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_claimSlotsMatchingAndDifferent](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_extendedByteSlotEncodings](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol), [check_extendedCompoundSlotTypes](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol), [check_extendedNestedSlotOffsets](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol), [check_extendedScalarSlotTypes](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol), [testPreparedCallbackRetainsStaticSlotWidth](../contracts/tests/Collections.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_behaviorCompositePaddingErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorCompositePaddingErrors.json), [check_behaviorNestedCallbackSlots: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedCallbackSlots.json), [check_claimBinarySlots: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimBinarySlots.json), [check_claimConstantsBeforeTraversal: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimConstantsBeforeTraversal.json), [check_claimSlotsMatchingAndDifferent: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimSlotsMatchingAndDifferent.json), [check_extendedByteSlotEncodings: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedByteSlotEncodings.json), [check_extendedCompoundSlotTypes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedCompoundSlotTypes.json), [check_extendedNestedSlotOffsets: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedNestedSlotOffsets.json), [check_extendedScalarSlotTypes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedScalarSlotTypes.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Additional uint8[][] and (uint8[],bytes[]) slots enforce narrow nested words and byte padding. Wider incoming descriptors cannot bypass the slot claim, and constant slots reject before empty traversal. Successful calldata matches independent solc encodings. Existing scalar/compound/byte families remain revalidated. Arbitrary descriptors and traversal lengths remain outside coverage.

## L56

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testCallbackSubstitutesMiddleDynamicSlot [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); testMapFilterFold [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (string accumulator fold); `check_variableLengthSlotIsRebuilt` [contracts/tests/SlotsSplitSymbolic.t.sol](../contracts/tests/SlotsSplitSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [check_variableLengthSlotIsRebuilt](../contracts/tests/SlotsSplitSymbolic.t.sol), [testCallbackSubstitutesMiddleDynamicSlot](../contracts/tests/Collections.t.sol), [testMapFilterFold](../contracts/tests/Collections.t.sol).

**Retained formal results:** [check_variableLengthSlotIsRebuilt: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/SlotsSplitSymbolicTest.check_variableLengthSlotIsRebuilt.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a string slot bound to a 2-byte then a 40-byte element (and the reverse) sends exactly selector ++ abi.encode(element, 7) each time

## L57

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** none (code uses staticcall at [contracts/Collections.sol](../contracts/Collections.sol), 1520); `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 681

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes: Collections holds no CALL, so every application is a STATICCALL (see C12)

## L58

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** testComposedDynamicCallbackRepeatsParameter [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); test_stringParameterLambda [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_expressionCallbackFailureIsWrapped` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1493-1521; README.md:10

**Test/property definitions:** [check_expressionCallbackFailureIsWrapped](../contracts/tests/ReadsCallbacksSymbolic.t.sol), [testComposedDynamicCallbackRepeatsParameter](../contracts/tests/Expressions.t.sol), [test_stringParameterLambda](../contracts/tests/ExpressionsGas.t.sol).

**Retained formal results:** [check_expressionCallbackFailureIsWrapped: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_expressionCallbackFailureIsWrapped.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: the callback call is exactly `evaluateEncoded(expression, bound slots)` on the target, the selector ignored

## L59

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_expressionCallbackFailureIsWrapped` [contracts/tests/ReadsCallbacksSymbolic.t.sol](../contracts/tests/ReadsCallbacksSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol); [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [check_expressionCallbackFailureIsWrapped](../contracts/tests/ReadsCallbacksSymbolic.t.sol).

**Retained formal results:** [check_expressionCallbackFailureIsWrapped: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ReadsCallbacksSymbolicTest.check_expressionCallbackFailureIsWrapped.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `CallbackFailed(operation, i, 0, expressions, callData, reason)` where the reason is byte for byte what `evaluateEncoded` reverts with on its own

## L60

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_L60_CollectionCallbacksDoNotShareEvaluationCaches`; check_cacheSeparateCollectionCallbacks [contracts/tests/ClaimCacheSymbolic.t.sol](../contracts/tests/ClaimCacheSymbolic.t.sol); test_cacheObserverSeparateInvocationSamples in that harness; check_routesFilterCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol); check_routesFoldCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol); check_routesReductionCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol); check_routesPredicateScanCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (evaluate, evaluateEncoded); [contracts/Collections.sol](../contracts/Collections.sol) (_callValue)

**Test/property definitions:** [check_cacheSeparateCollectionCallbacks](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_routesFilterCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [check_routesFoldCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [check_routesPredicateScanCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [check_routesReductionCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [test_L60_CollectionCallbacksDoNotShareEvaluationCaches](../contracts/tests/ClaimEvidenceGaps.t.sol), [test_cacheObserverSeparateInvocationSamples](../contracts/tests/ClaimCacheSymbolic.t.sol).

**Retained formal results:** [check_cacheSeparateCollectionCallbacks: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheSeparateCollectionCallbacks.json), [check_routesFilterCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesFilterCaches.json), [check_routesFoldCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesFoldCaches.json), [check_routesPredicateScanCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesPredicateScanCaches.json), [check_routesReductionCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesReductionCaches.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: The added callback cases separately observe one shared leaf call in each visited evaluation and fresh work on the next callback. Both raw word-template and typed value callback routes are covered, with literal ABI window positions found by marker scans. Early exits execute only visited callbacks. Together with prior mapValues evidence these remain selected geometries, not arbitrary collection traversals or graph invariants.

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

**Supporting sources:** AGENTS.md:384-386

**Scope and limitations:** The "together would not fit" half is unbacked but trivially true by arithmetic

## L65

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reduceWordsMatchesReference [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testFuzz_reduceMatchesReference [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_everyComparisonAtItsBoundary [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1279-1309

**Test/property definitions:** [check_reduceWordsMatchesReference](../contracts/tests/WordLambdasSymbolic.t.sol), [testFuzz_reduceMatchesReference](../contracts/tests/ReduceWords.t.sol), [test_everyComparisonAtItsBoundary](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_reduceWordsMatchesReference: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_reduceWordsMatchesReference.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3 words, every comparison case-split, symbolic bound and results (element XOR a symbolic tag); the fuzz test covers n<=24 with bounds drawn from the results

## L66

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reduceWordsCount [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testFuzz_reduceMatchesReference [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1279-1309

**Test/property definitions:** [check_reduceWordsCount](../contracts/tests/WordLambdasSymbolic.t.sol), [testFuzz_reduceMatchesReference](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_reduceWordsCount: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_reduceWordsCount.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3 words in two steps: Count of one element equals the comparison, and Count of a payload equals the sum of its elements' counts (the direct statement exceeded the solver limit); the fuzz test covers n<=24 directly

## L67

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reduceWordsStopsAtFirstHit [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); test_earlyExitSkipsLaterElements [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_declaredErrors [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1279-1309

**Test/property definitions:** [check_reduceWordsStopsAtFirstHit](../contracts/tests/WordLambdasSymbolic.t.sol), [test_declaredErrors](../contracts/tests/ReduceWords.t.sol), [test_earlyExitSkipsLaterElements](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_reduceWordsStopsAtFirstHit: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_reduceWordsStopsAtFirstHit.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3 words with GT and a symbolic bound, over a lambda that reverts on one element value; symbolic exhaustion is excluded (no gas model)

## L68

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reduceWordsSum [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); testFuzz_sumMatchesReference [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_sumOverflowPanics [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1279-1309

**Test/property definitions:** [check_reduceWordsSum](../contracts/tests/WordLambdasSymbolic.t.sol), [testFuzz_sumMatchesReference](../contracts/tests/ReduceWords.t.sol), [test_sumOverflowPanics](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_reduceWordsSum: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_reduceWordsSum.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3 words, symbolic comparison and bound

## L71

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_extendedReductionWindowBounds [contracts/tests/ClaimReductionBoundsSymbolic.t.sol](../contracts/tests/ClaimReductionBoundsSymbolic.t.sol); check_claimReduceMultipleWindows [contracts/tests/ClaimCallbacksSymbolic.t.sol](../contracts/tests/ClaimCallbacksSymbolic.t.sol); check_reduceWordsErrors [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); test_emptyPayloadTouchesNoTarget and test_declaredErrors [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_everyElementWindowIsBounded [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Replaces:** [L69](#l69); each prior statement and its evidence are retained below.

**Recorded run:** [results, commands and source hashes](halmos-extensions-20261012.md).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`reduceWords`, `_checkElementWindows`)

**Test/property definitions:** [check_claimReduceMultipleWindows](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_extendedReductionWindowBounds](../contracts/tests/ClaimReductionBoundsSymbolic.t.sol), [check_reduceWordsErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [test_declaredErrors](../contracts/tests/ReduceWords.t.sol), [test_emptyPayloadTouchesNoTarget](../contracts/tests/ReduceWords.t.sol), [test_everyElementWindowIsBounded](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_claimReduceMultipleWindows: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimReduceMultipleWindows.json), [check_extendedReductionWindowBounds: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimReductionBoundsSymbolicTest.check_extendedReductionWindowBounds.json), [check_reduceWordsErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/WordLambdasSymbolicTest.check_reduceWordsErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** New cases cover zero to four symbolic words, all four modes, template lengths 31, 32 and 100, and zero or three windows. Three-window fixtures include exact-boundary offsets, an overlap at offset 5, a failing third offset 69 and type(uint256).max. Exact window errors must precede code-less-target inspection, even on empty input. Valid empty cases return All=1 and otherwise=0. Original one-window n≤3 and two-window n≤1 cases are freshly revalidated. These are validation-order proofs; arbitrary window counts and overlap copying are outside this extension.

## L72

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_extendedReductionWidths [contracts/tests/ClaimReductionBoundsSymbolic.t.sol](../contracts/tests/ClaimReductionBoundsSymbolic.t.sol); check_claimReduceResultWidth [contracts/tests/ClaimCallbacksSymbolic.t.sol](../contracts/tests/ClaimCallbacksSymbolic.t.sol); test_malformedResultNamesItsElement and test_declaredErrors [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol)

**Replaces:** [L69](#l69); each prior statement and its evidence are retained below.

**Recorded run:** [results, commands and source hashes](halmos-extensions-20261012.md).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`_callWord`)

**Test/property definitions:** [check_claimReduceResultWidth](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_extendedReductionWidths](../contracts/tests/ClaimReductionBoundsSymbolic.t.sol), [test_declaredErrors](../contracts/tests/ReduceWords.t.sol), [test_malformedResultNamesItsElement](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_claimReduceResultWidth: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimReduceResultWidth.json), [check_extendedReductionWidths: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimReductionBoundsSymbolicTest.check_extendedReductionWidths.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** The extension covers zero to four elements, every reachable selected/failing index, all four modes, and reply widths 0, 1, 2, 30, 31, 32, 33, 63, 64, 65, 96 and 97. Replies are prefixes of four independent symbolic words; the oracle explicitly allocates 128 bytes. Non-selected elements return zero; GE/zero for All and Count and LT/zero for Any force evaluation to the selected element, and Sum cannot overflow around zero replies. Only a 32-byte applied reply succeeds. InvalidCallbackResult must name the exact operation, selected index, other=0 and target. Empty inputs bypass a code-less target. Other widths, lengths and arbitrary targets are outside this bounded proof.

## L73

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_claimReduceEnumDecoder [contracts/tests/ClaimCallbacksSymbolic.t.sol](../contracts/tests/ClaimCallbacksSymbolic.t.sol); [test/callback-boundaries.test.ts](../test/callback-boundaries.test.ts) (L73); test_outOfRangeEnumsAreRefusedByTheDecoder [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol)

**Replaces:** [L69](#l69); each prior statement and its evidence are retained below.

**Recorded run:** [results, commands and source hashes](halmos-extensions-20261012.md).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`Reduce`, `Cmp`, `reduceWords`)

**Test/property definitions:** [check_claimReduceEnumDecoder](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [test_outOfRangeEnumsAreRefusedByTheDecoder](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_claimReduceEnumDecoder: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimReduceEnumDecoder.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Both numeric enum fields range over all uint256 values, including dirty uint8 high bits. A whole raw ABI call uses zero or one element and a valid template/window; if mode≥4 or cmp≥10 it must fail with exactly empty revert data, including mode=Sum. The harness does not cast to Solidity enums. Other ABI geometries and malformed dynamic heads are outside this proof.

## L74

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_extendedWordCallerRoutes; check_extendedDirectValueCallerRoutes; check_extendedGraphValueCallerRoutes [contracts/tests/ClaimCallerRoutesSymbolic.t.sol](../contracts/tests/ClaimCallerRoutesSymbolic.t.sol); check_claimWordCaller; check_claimValueAndGraphCaller [contracts/tests/ClaimCallbacksSymbolic.t.sol](../contracts/tests/ClaimCallbacksSymbolic.t.sol); [test/callback-boundaries.test.ts](../test/callback-boundaries.test.ts) (L74)

**Recorded run:** [results, commands and source hashes](halmos-extensions-20261012.md).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`_callWord`, `_callValue`); [contracts/Expressions.sol](../contracts/Expressions.sol) (`_call`)

**Test/property definitions:** [check_claimValueAndGraphCaller](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_claimWordCaller](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_extendedDirectValueCallerRoutes](../contracts/tests/ClaimCallerRoutesSymbolic.t.sol), [check_extendedGraphValueCallerRoutes](../contracts/tests/ClaimCallerRoutesSymbolic.t.sol), [check_extendedWordCallerRoutes](../contracts/tests/ClaimCallerRoutesSymbolic.t.sol).

**Retained formal results:** [check_claimValueAndGraphCaller: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimValueAndGraphCaller.json), [check_claimWordCaller: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimWordCaller.json), [check_extendedDirectValueCallerRoutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallerRoutesSymbolicTest.check_extendedDirectValueCallerRoutes.json), [check_extendedGraphValueCallerRoutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallerRoutesSymbolicTest.check_extendedGraphValueCallerRoutes.json), [check_extendedWordCallerRoutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallerRoutesSymbolicTest.check_extendedWordCallerRoutes.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: direct coverage now includes all six word callback entry points and all nine value callback entry points. New folds use three indices/bytes; the value and other word traversals use two unrestricted symbolic words. Caller-returning, context-testing and comparator oracles distinguish wrong sender contexts. Every value callback entry is also checked through a seven-node Call graph, optionally behind a successful TryOrElse self-call boundary; predicates and address results must observe Expressions, and comparators require that caller. Ordered/unordered unique paths and both sort orders are exercised. Arbitrary graph shapes and failed guarded attempts are outside this extension; E50 receives no cache-proof credit. Caller-sensitive sharing equivalence remains subject to E49.

## L75

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_extendedScalarResultTypes; check_extendedCompoundResultTypes; check_extendedByteResultEncodings; check_extendedRawWordPairs [contracts/tests/ClaimTypeFamiliesSymbolic.t.sol](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol); [contracts/tests/ClaimReductionBoundsSymbolic.t.sol](../contracts/tests/ClaimReductionBoundsSymbolic.t.sol); check_claimRawAndTypedWords [contracts/tests/ClaimCallbacksSymbolic.t.sol](../contracts/tests/ClaimCallbacksSymbolic.t.sol); [test/callback-boundaries.test.ts](../test/callback-boundaries.test.ts) (L75); check_behaviorNestedCallbackResults [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorCompositePaddingErrors [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol) (`_callWord`, `_applyWords`, `_reduce`, `_validateResult`)

**Test/property definitions:** [check_behaviorCompositePaddingErrors](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedCallbackResults](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_claimRawAndTypedWords](../contracts/tests/ClaimCallbacksSymbolic.t.sol), [check_extendedByteResultEncodings](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol), [check_extendedCompoundResultTypes](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol), [check_extendedRawWordPairs](../contracts/tests/ClaimReductionBoundsSymbolic.t.sol), [check_extendedScalarResultTypes](../contracts/tests/ClaimTypeFamiliesSymbolic.t.sol).

**Retained formal results:** [check_behaviorCompositePaddingErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorCompositePaddingErrors.json), [check_behaviorNestedCallbackResults: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedCallbackResults.json), [check_claimRawAndTypedWords: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCallbacksSymbolicTest.check_claimRawAndTypedWords.json), [check_extendedByteResultEncodings: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedByteResultEncodings.json), [check_extendedCompoundResultTypes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedCompoundResultTypes.json), [check_extendedRawWordPairs: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimReductionBoundsSymbolicTest.check_extendedRawWordPairs.json), [check_extendedScalarResultTypes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimTypeFamiliesSymbolicTest.check_extendedScalarResultTypes.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Additional nested-array/composite callback results are validated at the first or second element through mapValues and foldValues. Successful bytes match independent solc references; failures retain the exact callback operation/index/other/target. Dirty nested padding is also rejected. Existing raw-word and scalar/compound result properties remain; arbitrary families and callback routes are not established.

## E1

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referencesMustPointBackwards` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (refs 0, 1 = self, 2, max); `testGraphRejectsForwardReferenceAndInvalidTarget` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_E1_BadReferencePrecedesInvalidKind` [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) (a bad reference is reported before an out-of-range kind on the same node)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :96, :142-148, :214

**Test/property definitions:** [check_referencesMustPointBackwards](../contracts/tests/ExpressionsSymbolic.t.sol), [testGraphRejectsForwardReferenceAndInvalidTarget](../contracts/tests/Expressions.t.sol), [test_E1_BadReferencePrecedesInvalidKind](../contracts/tests/ClaimCoverageEasy.t.sol).

**Retained formal results:** [check_referencesMustPointBackwards: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_referencesMustPointBackwards.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Shown on a Wrap node only, ref case-split {0,1,2,max}. The file header [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) says a self-reference is out of Halmos' reach, but case 1 IS a self-reference and is proved (the up-front check rejects it before any recursion)

## E2

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_parameterIndexBounded` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :143-148, :362

**Test/property definitions:** [check_parameterIndexBounded](../contracts/tests/ExpressionsSymbolic.t.sol).

**Retained formal results:** [check_parameterIndexBounded: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_parameterIndexBounded.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Indices {0,1,2,max} over symbolic parameter words

## E3

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_parameterDataAndCallTarget` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_parameterDataIsOneWord` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :360

**Test/property definitions:** [check_parameterDataIsOneWord](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [test_parameterDataAndCallTarget](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_parameterDataIsOneWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_parameterDataIsOneWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: data of 0, 31, 33 or 64 bytes reverts `InvalidNode`, one word selects the parameter or reverts `InvalidReference`; removing the check fails it

## E4

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_resultIndexMustExist` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `check_resultIndexInRange` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :137-138, :240

**Test/property definitions:** [check_resultIndexInRange](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [test_resultIndexMustExist](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_resultIndexInRange: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_resultIndexInRange.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for indices 0 to 2 and the maximum over a two-node graph

## E5

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `test_nodeReferenceCounts` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (Select 2, TryOrElse 3, Literal 2); `test_wrapNeedsExactlyOneReference` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol); `test_parameterDataAndCallTarget` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (Call 0); `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (wrong counts, no-panic only); `check_referenceCountsPerKind` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :214-215, :248-266

**Test/property definitions:** [check_referenceCountsPerKind](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_nodeReferenceCounts](../contracts/tests/MutationGaps.t.sol), [test_parameterDataAndCallTarget](../contracts/tests/MutationGaps.t.sol), [test_wrapNeedsExactlyOneReference](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_referenceCountsPerKind: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_referenceCountsPerKind.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for every kind and every count from 0 to 4: a wrong count reverts `InvalidNode` at the node, an allowed one never does; a planted Select count bug fails it

## E6

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testProbeCallRequiresBytesCalldata` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (uint256 and string operands); `check_referenceCountsPerKind` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (`evaluate` ProbeCall admission, `_evaluate`, `evaluateEncoded`)

**Test/property definitions:** [check_referenceCountsPerKind](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testProbeCallRequiresBytesCalldata](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_referenceCountsPerKind: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_referenceCountsPerKind.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Structure proved with a bytes-typed operand (see E5); the untyped case is pinned by `testProbeCallRequiresBytesCalldata`. Since rc1 the `evaluateEncoded` clause defers to E38: that payload is no longer decoded up front.

## E7

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E7_UnreachableDescriptorFailsBeforeCalls`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (types `((` and `uint256[0]` injected); check_behaviorUnreachableTypesAdmittedFirst [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :244

**Test/property definitions:** [check_behaviorUnreachableTypesAdmittedFirst](../contracts/tests/ClaimUnreadSymbolic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E7_UnreachableDescriptorFailsBeforeCalls](../contracts/tests/ClaimCoverageEasy.t.sol).

**Retained formal results:** [check_behaviorUnreachableTypesAdmittedFirst: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorUnreachableTypesAdmittedFirst.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: An unreachable uint8[0], empty tuple or unclosed tuple descriptor is rejected at its exact byte before a reachable external leaf executes; zero calls are observed. This establishes eager admission for selected descriptors and this graph, not all graphs or malformed grammars.

## E8

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callResultIsValidated` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (uint8); `check_resolveGoesThroughTheCore` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (address); `check_sharingEqualsDuplication` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (uint8 params vs solc decode); `test_nodeValidatesDynamicValues` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (string offset); `testGraphRejectsForwardReferenceAndInvalidTarget` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_nodeValueWordsMatchSolc` [contracts/tests/NarrowWordsSymbolic.t.sol](../contracts/tests/NarrowWordsSymbolic.t.sol) (`(uint8,string)` Literal, added after the snapshot); check_behaviorNestedNodeValidation [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol); check_behaviorCompositePaddingErrors [contracts/tests/ClaimNestedTypesSymbolic.t.sol](../contracts/tests/ClaimNestedTypesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :31-38, :90, :228-230, :442; AGENTS.md:59-60

**Test/property definitions:** [check_behaviorCompositePaddingErrors](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_behaviorNestedNodeValidation](../contracts/tests/ClaimNestedTypesSymbolic.t.sol), [check_callResultIsValidated](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_nodeValueWordsMatchSolc](../contracts/tests/NarrowWordsSymbolic.t.sol), [check_resolveGoesThroughTheCore](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_sharingEqualsDuplication](../contracts/tests/ExpressionsSymbolic.t.sol), [testGraphRejectsForwardReferenceAndInvalidTarget](../contracts/tests/Expressions.t.sol), [test_nodeValidatesDynamicValues](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_behaviorCompositePaddingErrors: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorCompositePaddingErrors.json), [check_behaviorNestedNodeValidation: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimNestedTypesSymbolicTest.check_behaviorNestedNodeValidation.json), [check_callResultIsValidated: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callResultIsValidated.json), [check_nodeValueWordsMatchSolc: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/NarrowWordsSymbolicTest.check_nodeValueWordsMatchSolc.json), [check_resolveGoesThroughTheCore: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_resolveGoesThroughTheCore.json), [check_sharingEqualsDuplication: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_sharingEqualsDuplication.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Cold Literal nodes additionally accept exactly canonical selected two-level arrays and dynamic composites, and reject dirty narrow words and nested bytes padding at exact offsets. Four input words remain unrestricted; solc constructs independent narrow references. Earlier scalar and narrow-tuple properties remain. Every node kind, descriptor family and general cache-validity induction is not established.

## E10

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_selectIsLazyAndJudgesFirstWord` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol); check_behaviorDanglingNodesNeverExecute [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [check_behaviorDanglingNodesNeverExecute](../contracts/tests/ClaimUnreadSymbolic.t.sol), [check_selectIsLazyAndJudgesFirstWord](../contracts/tests/ExpressionsSymbolic.t.sol).

**Retained formal results:** [check_behaviorDanglingNodesNeverExecute: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorDanglingNodesNeverExecute.json), [check_selectIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_selectIsLazyAndJudgesFirstWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: A dangling Call outside every Select would return a dirty uint8 and fail if evaluated. The reachable Literal returns its unrestricted word and the dangling call count stays zero. The earlier Select laziness property is retained. Arbitrary graphs and reachability induction are not supplied.

## E50

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_sharedNodeEvaluatesOnce [contracts/tests/CallCountsAndFallbacks.t.sol](../contracts/tests/CallCountsAndFallbacks.t.sol); testGraphMemoizesSharedDynamicCallAndLazyBranch and testGuardedGraphFallbackAndSuccessfulCacheMerge [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); test_failedGuardedAttemptDiscardsCachedCalls [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol); check_cacheFailedGuardPreservesParent, check_cacheFailedGuardReexecutes, check_cacheNestedSuccessfulAdoption, check_cacheOnlyValidatedResultsReused, check_cacheOuterFailureDiscardsInnerSuccess, check_cacheRepeatedFailedAttempts, check_cacheSharedNodeReuse, check_cacheSuccessfulGuardAdopts, check_cacheSuccessfulGuardPreservesParent [contracts/tests/ClaimCacheSymbolic.t.sol](../contracts/tests/ClaimCacheSymbolic.t.sol); test_cacheObserverSharedAndSuccessfulSamples, test_cacheObserverFailedSample, test_cacheObserverParentAndNestedSamples, test_cacheObserverRepeatedAndInvalidSamples and test_cacheObserverSeparateInvocationSamples in that harness

**Replaces:** [E11](#e11), [E17](#e17), [E18](#e18); each prior statement and its evidence are retained below.

**Recorded run:** [results, commands and source hashes](verification/halmos-cache-20261012/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (`_evaluate`, `_tryEvaluate`)

**Test/property definitions:** [check_cacheFailedGuardPreservesParent](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheFailedGuardReexecutes](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheNestedSuccessfulAdoption](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheOnlyValidatedResultsReused](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheOuterFailureDiscardsInnerSuccess](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheRepeatedFailedAttempts](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheSharedNodeReuse](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheSuccessfulGuardAdopts](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheSuccessfulGuardPreservesParent](../contracts/tests/ClaimCacheSymbolic.t.sol), [testGraphMemoizesSharedDynamicCallAndLazyBranch](../contracts/tests/Expressions.t.sol), [testGuardedGraphFallbackAndSuccessfulCacheMerge](../contracts/tests/Expressions.t.sol), [test_cacheObserverFailedSample](../contracts/tests/ClaimCacheSymbolic.t.sol), [test_cacheObserverParentAndNestedSamples](../contracts/tests/ClaimCacheSymbolic.t.sol), [test_cacheObserverRepeatedAndInvalidSamples](../contracts/tests/ClaimCacheSymbolic.t.sol), [test_cacheObserverSeparateInvocationSamples](../contracts/tests/ClaimCacheSymbolic.t.sol), [test_cacheObserverSharedAndSuccessfulSamples](../contracts/tests/ClaimCacheSymbolic.t.sol), [test_failedGuardedAttemptDiscardsCachedCalls](../contracts/tests/ClaimBoundaries.t.sol), [test_sharedNodeEvaluatesOnce](../contracts/tests/CallCountsAndFallbacks.t.sol).

**Retained formal results:** [check_cacheFailedGuardPreservesParent: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheFailedGuardPreservesParent.json), [check_cacheFailedGuardReexecutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheFailedGuardReexecutes.json), [check_cacheNestedSuccessfulAdoption: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheNestedSuccessfulAdoption.json), [check_cacheOnlyValidatedResultsReused: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheOnlyValidatedResultsReused.json), [check_cacheOuterFailureDiscardsInnerSuccess: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheOuterFailureDiscardsInnerSuccess.json), [check_cacheRepeatedFailedAttempts: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheRepeatedFailedAttempts.json), [check_cacheSharedNodeReuse: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheSharedNodeReuse.json), [check_cacheSuccessfulGuardAdopts: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheSuccessfulGuardAdopts.json), [check_cacheSuccessfulGuardPreservesParent: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheSuccessfulGuardPreservesParent.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: nine properties cover selected Call/Tuple/TryOrElse/IsValid graphs, ordinary sharing, successful adoption, preservation of prior parent entries, failed-attempt re-execution, nested success followed by outer failure, and uint8 result validation. Leaves return an unrestricted bytes32 or a canonical 33-byte bytes payload. vm.warp is a test-only ghost call counter that survives reverted subcalls; the fixed production closure does not read it, and Foundry expectCall independently checks concrete sample counts. Exact SubcallOutOfGas outcomes are excluded only in ordinary-failure properties because Halmos has no gas model. No arbitrary graph/cache induction, arbitrary-length traversal, all node/type families, or gas/caller-sensitive duplication equivalence follows. Earlier concrete support and retired E11/E17/E18 records are retained.

## E12

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_selectIsLazyAndJudgesFirstWord` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (32 and 64 byte conditions, symbolic words); `testSelectFalseTakesElseWithoutEvaluatingThen` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `testSelectAcceptsAnyNonzeroFirstWord` :170; `testSelectJudgesFirstWordOfMultiWordCondition` :175

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :219-221, :380; index.md:13; AGENTS.md:62-68

**Test/property definitions:** [check_selectIsLazyAndJudgesFirstWord](../contracts/tests/ExpressionsSymbolic.t.sol), [testSelectAcceptsAnyNonzeroFirstWord](../contracts/tests/Expressions.t.sol), [testSelectFalseTakesElseWithoutEvaluatingThen](../contracts/tests/Expressions.t.sol), [testSelectJudgesFirstWordOfMultiWordCondition](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_selectIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_selectIsLazyAndJudgesFirstWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## E13

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_selectIsLazyAndJudgesFirstWord` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (unchosen branch is an out-of-range Parameter); `testSelectFalseTakesElseWithoutEvaluatingThen` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :221-222; index.md:13

**Test/property definitions:** [check_selectIsLazyAndJudgesFirstWord](../contracts/tests/ExpressionsSymbolic.t.sol), [testSelectFalseTakesElseWithoutEvaluatingThen](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_selectIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_selectIsLazyAndJudgesFirstWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## E14

**Recorded evidence:** FUZZED / SUITE PASSED.

**References:** `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (`uint256[0]` type injected, no-panic only)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); AGENTS.md:66-68, :126-129

**Test/property definitions:** [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol).

**Scope and limitations:** Supplemental source proof: `ExpressionScalarModel.CanonicalHasWord` proves every well-formed canonical value spans at least 32 bytes; recursive canonical preservation and the concrete first-word adapter carry explicit memory/resource premises

## E15

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_guardedEvaluationFallsBackExactly` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (validation failure); `testGuardedGraphFailureAndValidity` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (reverting call); check_behaviorExpressionGuardCallOutcomes [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol); check_behaviorReservedSignalAcrossControlRoutes [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :68-70, :222-225, :382-384

**Test/property definitions:** [check_behaviorExpressionGuardCallOutcomes](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [check_behaviorReservedSignalAcrossControlRoutes](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [check_guardedEvaluationFallsBackExactly](../contracts/tests/ExpressionsSymbolic.t.sol), [testGuardedGraphFailureAndValidity](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_behaviorExpressionGuardCallOutcomes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorExpressionGuardCallOutcomes.json), [check_behaviorReservedSignalAcrossControlRoutes: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorReservedSignalAcrossControlRoutes.json), [check_guardedEvaluationFallsBackExactly: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_guardedEvaluationFallsBackExactly.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: TryOrElse and IsValid handle successful unrestricted words including zero, and target reverts with symbolic reason bytes at the displayed lengths. The exact reserved four-byte marker propagates with no exclusion of its path. Existing type-validation guard evidence remains. Ordinary-failure gas artifacts are explicitly excluded; actual gas, arbitrary graph shapes and every failure source are not proved.

## E19

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testGuardedEvaluationRejectsOutsideCallers` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_evaluateGuardedIsSelfOnly` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :170-175, :274-279, :295

**Test/property definitions:** [check_evaluateGuardedIsSelfOnly](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGuardedEvaluationRejectsOutsideCallers](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_evaluateGuardedIsSelfOnly: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_evaluateGuardedIsSelfOnly.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Direct check proved: an outside caller gets `NotSelf(caller)`. The historical graph self-call is blocked in revised source.

## E20

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callBuildsSolcCalldata` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (uint8, bytes32, string of length 0/5/32, symbolic selector; Reflector echoes caller and calldata)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :31-37, :405-410

**Test/property definitions:** [check_callBuildsSolcCalldata](../contracts/tests/ExpressionsCallsSymbolic.t.sol).

**Retained formal results:** [check_callBuildsSolcCalldata: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callBuildsSolcCalldata.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Solc abi.encode is the oracle

## E21

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callTargetRules` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (symbolic 96 upper bits); `testGraphRejectsForwardReferenceAndInvalidTarget` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :497-504

**Test/property definitions:** [check_callTargetRules](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testGraphRejectsForwardReferenceAndInvalidTarget](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_callTargetRules: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callTargetRules.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Call nodes only; a dirty ProbeCall target word is untested

## E22

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callTargetRules` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (case 1)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :507-510

**Test/property definitions:** [check_callTargetRules](../contracts/tests/ExpressionsCallsSymbolic.t.sol).

**Retained formal results:** [check_callTargetRules: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callTargetRules.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Call nodes only; a Resolve node with a code-less `core` is reached only by the no-panic sweep ([contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol)) without asserting the error; the self-call case cannot occur

## E23

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_callTargetRules` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (case 2, exact data); `check_resolveNodeEnforcesConstraints` [contracts/tests/CompositionSymbolic.t.sol](../contracts/tests/CompositionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :159-168, :520

**Test/property definitions:** [check_callTargetRules](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_resolveNodeEnforcesConstraints](../contracts/tests/CompositionSymbolic.t.sol).

**Retained formal results:** [check_callTargetRules: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callTargetRules.json), [check_resolveNodeEnforcesConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CompositionSymbolicTest.check_resolveNodeEnforcesConstraints.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Call failures and Resolve with a failing EQ constraint carry exact nested revert bytes. Gas artifacts are excluded explicitly in symbolic failure properties; C69 supplies concrete gas evidence.

## E24

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_resolveGoesThroughTheCore` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (no constraints); `test_expressionGraphResolvesNewConstraintKinds` [contracts/tests/PositionalConstraints.t.sol](../contracts/tests/PositionalConstraints.t.sol) (SKIP + IN_SIGNED pass and fail); `check_resolveNodeEnforcesConstraints` [contracts/tests/CompositionSymbolic.t.sol](../contracts/tests/CompositionSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :104-106, :374-377

**Test/property definitions:** [check_resolveGoesThroughTheCore](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_resolveNodeEnforcesConstraints](../contracts/tests/CompositionSymbolic.t.sol), [test_expressionGraphResolvesNewConstraintKinds](../contracts/tests/PositionalConstraints.t.sol).

**Retained formal results:** [check_resolveGoesThroughTheCore: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_resolveGoesThroughTheCore.json), [check_resolveNodeEnforcesConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CompositionSymbolicTest.check_resolveNodeEnforcesConstraints.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for an EQ constraint over a symbolic word: the node evaluates exactly when the constraint holds, and on failure carries the core's own `resolve` revert, byte for byte, in `NodeCallFailed` at that node. Other constraint kinds are proved at the core (ERC8211Symbolic) and reach the node through the same call

## E25

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testResolveRejectsImpossibleDecoderAllocation` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E25_ResolveDecoderBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (junk Resolve data injected at :126-128)

**Recorded run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); AGENTS.md:324-329; [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol)

**Test/property definitions:** [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [testResolveRejectsImpossibleDecoderAllocation](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E25_ResolveDecoderBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Exact retained bare-revert cases remain covered. The current allocation regression asserts Panic(0x41) before the core/self-call; decoder errors are not universally bare or wrapped in NodeCallFailed. The bounded graph sweep tolerates only empty data or exact allocation Panic(0x41) for injected malformed payloads, and rejects other panics.

## E26

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_probeCallMatchesRevertData` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) (reason lengths 0/3/4/36/64, symbolic selector); `check_probeCallRefusals` :181; `testProbeCallPreservesUnderlyingDynamicReason` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :177-195, :469-495

**Test/property definitions:** [check_probeCallMatchesRevertData](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [check_probeCallRefusals](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testProbeCallPreservesUnderlyingDynamicReason](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_probeCallMatchesRevertData: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_probeCallMatchesRevertData.json), [check_probeCallRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_probeCallRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## E27

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_probeCallRefusals` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol); `testProbeCallPreservesUnderlyingDynamicReason` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :479-482

**Test/property definitions:** [check_probeCallRefusals](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testProbeCallPreservesUnderlyingDynamicReason](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_probeCallRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_probeCallRefusals.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## E28

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testProbeCallPreservesUnderlyingDynamicReason` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `check_probeCallMatchesRevertData` [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [check_probeCallMatchesRevertData](../contracts/tests/ExpressionsCallsSymbolic.t.sol), [testProbeCallPreservesUnderlyingDynamicReason](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_probeCallMatchesRevertData: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_probeCallMatchesRevertData.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## E29

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testLocalCoreDeclarationsMatchTheCore` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_sharedSelectorsMatch` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :179-181, :189-190, :475-476

**Test/property definitions:** [testLocalCoreDeclarationsMatchTheCore](../contracts/tests/Expressions.t.sol), [test_sharedSelectorsMatch](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Pinned by a unit test: `DidNotRevert`, `UnexpectedRevertData`, `SubcallOutOfGas` and `ICore.resolve` match the core; it is a compile-time fact, so a unit test is the right evidence

## E30

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_referencesMustPointBackwards` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (ref 0 case, concrete value); `testGraphAbiConstructors` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_unpack_*` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_wrapArrayTupleValues` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :390

**Test/property definitions:** [check_referencesMustPointBackwards](../contracts/tests/ExpressionsSymbolic.t.sol), [check_wrapArrayTupleValues](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGraphAbiConstructors](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_referencesMustPointBackwards: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_referencesMustPointBackwards.json), [check_wrapArrayTupleValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_wrapArrayTupleValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: Wrap yields `abi.encode(bytes)` of its operand

## E31

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testGraphAbiConstructors` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (bytes[] vs abi.encode); `check_wrapArrayTupleValues` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol); `check_narrowArrayConstructor` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (`uint8[]` over full-width leaves, accepted exactly when in range, and the empty array); `check_dynamicElementArrayConstructor` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (`string[]` of zero, one or two strings equals `abi.encode`, a bare word refused with `InvalidValue`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :396

**Test/property definitions:** [check_dynamicElementArrayConstructor](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [check_narrowArrayConstructor](../contracts/tests/ConstructorsSymbolic.t.sol), [check_wrapArrayTupleValues](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGraphAbiConstructors](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_dynamicElementArrayConstructor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_dynamicElementArrayConstructor.json), [check_narrowArrayConstructor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstructorsSymbolicTest.check_narrowArrayConstructor.json), [check_wrapArrayTupleValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_wrapArrayTupleValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: proved for `bytes32[]` of two, `uint8[]` of zero or two (range enforced) and `string[]` of zero to two; longer arrays and nested element shapes are units.

## E32

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_sharingEqualsDuplication` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (static tuple vs solc); `testGraphAbiConstructors` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) ((uint256,bytes[]) vs abi.encode); `check_dynamicTupleConstructor` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (`(uint8,string)` with an empty or two-byte string equals `abi.encode` with the 0x20 word); `check_tupleComponentShapeIsChecked` [contracts/tests/CanonicalBoundsSymbolic.t.sol](../contracts/tests/CanonicalBoundsSymbolic.t.sol) (a bare word in the string slot reverts `InvalidComponentEnvelope(1, 32, word)`, a string in the uint8 slot `InvalidComponentLength(0, 32, 96)`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :400-401, :447-449

**Test/property definitions:** [check_dynamicTupleConstructor](../contracts/tests/ConstructorsSymbolic.t.sol), [check_sharingEqualsDuplication](../contracts/tests/ExpressionsSymbolic.t.sol), [check_tupleComponentShapeIsChecked](../contracts/tests/CanonicalBoundsSymbolic.t.sol), [testGraphAbiConstructors](../contracts/tests/Expressions.t.sol).

**Retained formal results:** [check_dynamicTupleConstructor: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstructorsSymbolicTest.check_dynamicTupleConstructor.json), [check_sharingEqualsDuplication: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_sharingEqualsDuplication.json), [check_tupleComponentShapeIsChecked: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CanonicalBoundsSymbolicTest.check_tupleComponentShapeIsChecked.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: a static and a dynamic tuple shape proved, the 0x20 prefix and the exact component-shape errors included; wider tuples are units.

## E33

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_wrapArrayTupleValues` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol); `check_callArityMismatch` [contracts/tests/ConstructorsSymbolic.t.sol](../contracts/tests/ConstructorsSymbolic.t.sol) (one operand too many reverts `ComponentCountMismatch(1, 2)`, one too few `(2, 1)`, before any call)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol)

**Test/property definitions:** [check_callArityMismatch](../contracts/tests/ConstructorsSymbolic.t.sol), [check_wrapArrayTupleValues](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Retained formal results:** [check_callArityMismatch: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ConstructorsSymbolicTest.check_callArityMismatch.json), [check_wrapArrayTupleValues: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_wrapArrayTupleValues.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved for a Tuple node (`ComponentCountMismatch(3, 2)`) and for a Call node in both directions, the arity check preceding the call.

## E34

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testGraphMemoizesSharedDynamicCallAndLazyBranch` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (`source()` called with "()"); `test_graphOverhead` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `check_emptyTupleCallSendsBareSelector` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :458-463

**Test/property definitions:** [check_emptyTupleCallSendsBareSelector](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testGraphMemoizesSharedDynamicCallAndLazyBranch](../contracts/tests/Expressions.t.sol), [test_graphOverhead](../contracts/tests/ExpressionsGas.t.sol).

**Retained formal results:** [check_emptyTupleCallSendsBareSelector: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_emptyTupleCallSendsBareSelector.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a Call node with `"()"` and no operands sends exactly the four selector bytes

## E35

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** All `check_*` in [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) and [contracts/tests/ExpressionsCallsSymbolic.t.sol](../contracts/tests/ExpressionsCallsSymbolic.t.sol) compare raw returndata to abi.encode; `test_sharedLeaf_*` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol) (graph output == tree output through `Assertions.resolve`)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :230, :295

**Retained formal results:** [check_callBuildsSolcCalldata: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callBuildsSolcCalldata.json), [check_callResultIsValidated: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callResultIsValidated.json), [check_callTargetRules: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callTargetRules.json), [check_guardedEvaluationFallsBackExactly: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_guardedEvaluationFallsBackExactly.json), [check_parameterIndexBounded: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_parameterIndexBounded.json), [check_probeCallMatchesRevertData: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_probeCallMatchesRevertData.json), [check_probeCallRefusals: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_probeCallRefusals.json), [check_referencesMustPointBackwards: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_referencesMustPointBackwards.json), [check_resolveGoesThroughTheCore: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_resolveGoesThroughTheCore.json), [check_selectIsLazyAndJudgesFirstWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_selectIsLazyAndJudgesFirstWord.json), [check_sharingEqualsDuplication: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_sharingEqualsDuplication.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

## E36

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `testComposedDynamicCallbackRepeatsParameter` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol); `test_stringParameterLambda` [contracts/tests/ExpressionsGas.t.sol](../contracts/tests/ExpressionsGas.t.sol); `test_E36_PayloadCannotReadItsGraphFromTheParameters` [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol); `check_evaluateEncodedMatchesEvaluate` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (`evaluateEncoded`); README.md

**Test/property definitions:** [check_evaluateEncodedMatchesEvaluate](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [testComposedDynamicCallbackRepeatsParameter](../contracts/tests/Expressions.t.sol), [test_E36_PayloadCannotReadItsGraphFromTheParameters](../contracts/tests/ClaimCoverageEasy.t.sol), [test_stringParameterLambda](../contracts/tests/ExpressionsGas.t.sol).

**Retained formal results:** [check_evaluateEncodedMatchesEvaluate: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_evaluateEncodedMatchesEvaluate.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: the same value as `evaluate` for a valid graph. Changed since rc1, which decoded the payload and re-encoded it: the bytes are now forwarded, placed after the encoded parameters. ABI offsets only point forward, so a payload whose node list offset runs past its own end fails instead of reading nodes planted in the parameters; the unit test tries every such offset. The property was updated to expect the forwarded call and rerun on the changed source; the retained rc1 result predates the change.

## E37

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** `check_evaluateEncodedMatchesEvaluate` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol); `test_E38_EncodedPayloadFailsWhereItIsRead` [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol)

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (`evaluateEncoded`, `_call`)

**Test/property definitions:** [check_evaluateEncodedMatchesEvaluate](../contracts/tests/ExpressionsStructureSymbolic.t.sol), [test_E38_EncodedPayloadFailsWhereItIsRead](../contracts/tests/ClaimCoverageEasy.t.sol).

**Retained formal results:** [check_evaluateEncodedMatchesEvaluate: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_evaluateEncodedMatchesEvaluate.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: `NodeCallFailed(0, expressions, the forwarded evaluate call, evaluate's own revert)` byte for byte; a planted node index fails it. Changed since rc1: the reported calldata is the forwarded call (head, parameters, then the payload), a valid encoding of the same `evaluate` call but not the canonical one rc1 reported. The property now builds that expected calldata and was rerun on the changed source; the retained rc1 result predates the change.

## E38

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E38_EncodedPayloadFailsWhereItIsRead`, `testFuzz_E38_UnreadNodeDataCannotChangeTheResult`; `testEvaluateEncodedRefusesImpossibleNodeCountInsideTheSelfCall` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (random payload); check_behaviorUnreadEncodedLengthIndependent [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol); check_behaviorEncodedLeadingHeaderRefusal [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol); check_behaviorConsumedEncodedFieldWrapsFailure [contracts/tests/ClaimUnreadSymbolic.t.sol](../contracts/tests/ClaimUnreadSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (`evaluateEncoded`); AGENTS.md

**Test/property definitions:** [check_behaviorConsumedEncodedFieldWrapsFailure](../contracts/tests/ClaimUnreadSymbolic.t.sol), [check_behaviorEncodedLeadingHeaderRefusal](../contracts/tests/ClaimUnreadSymbolic.t.sol), [check_behaviorUnreadEncodedLengthIndependent](../contracts/tests/ClaimUnreadSymbolic.t.sol), [testEvaluateEncodedRefusesImpossibleNodeCountInsideTheSelfCall](../contracts/tests/ExpressionsNoPanic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [testFuzz_E38_UnreadNodeDataCannotChangeTheResult](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E38_EncodedPayloadFailsWhereItIsRead](../contracts/tests/ClaimCoverageEasy.t.sol).

**Retained formal results:** [check_behaviorConsumedEncodedFieldWrapsFailure: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorConsumedEncodedFieldWrapsFailure.json), [check_behaviorEncodedLeadingHeaderRefusal: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorEncodedLeadingHeaderRefusal.json), [check_behaviorUnreadEncodedLengthIndependent: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimUnreadSymbolicTest.check_behaviorUnreadEncodedLengthIndependent.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Two independent uint256 mutations of an unreachable node data-length word leave the selected result unchanged in a fixed two-node payload. Other locating headers remain fixed. Six short/low/past-end leading-header cases reject without data; a consumed out-of-bounds node-list offset produces the exact self-call NodeCallFailed wrapper and forwarded calldata. Only that ordinary-failure wrapper property excludes the symbolic exhaustion artifact. Arbitrary payloads and every unread field are not established.

## E39

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E39_InvalidKindBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (kind 11 injected at :110-111); check_behaviorInvalidKindWord [contracts/tests/ClaimControlErrorsSymbolic.t.sol](../contracts/tests/ClaimControlErrorsSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-behavior-20261013/run.json).

**Supporting sources:** [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); AGENTS.md:311-312, 

**Test/property definitions:** [check_behaviorInvalidKindWord](../contracts/tests/ClaimControlErrorsSymbolic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E39_InvalidKindBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol).

**Retained formal results:** [check_behaviorInvalidKindWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimControlErrorsSymbolicTest.check_behaviorInvalidKindWord.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Every invalid raw Kind word produces a bare decoder revert when its Kind field is read in an otherwise valid one-node graph. The enum-extension mutant is killed. This does not claim that Kind rejection precedes descriptor/reference admission errors; their ordering remains separate evidence (E1/E7). Other malformed graph fields are outside this property.

## E40

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E7_UnreachableDescriptorFailsBeforeCalls`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E25_ResolveDecoderBareRevert`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E38_EncodedPayloadFailsWhereItIsRead`; [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_E39_InvalidKindBareRevert`; retained supporting evidence: `testFuzzGraphsDocumentedFailures` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol) (up to 6 nodes, all kinds, 8 HostileTarget modes, 10M gas per call); `testResolveRejectsImpossibleDecoderAllocation`, `testEvaluateEncodedRefusesImpossibleNodeCountInsideTheSelfCall` [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol)

**Recorded run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [contracts/tests/ExpressionsNoPanic.t.sol](../contracts/tests/ExpressionsNoPanic.t.sol); AGENTS.md:323-334

**Test/property definitions:** [testEvaluateEncodedRefusesImpossibleNodeCountInsideTheSelfCall](../contracts/tests/ExpressionsNoPanic.t.sol), [testFuzzGraphsDocumentedFailures](../contracts/tests/ExpressionsNoPanic.t.sol), [testResolveRejectsImpossibleDecoderAllocation](../contracts/tests/ExpressionsNoPanic.t.sol), [test_E25_ResolveDecoderBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E38_EncodedPayloadFailsWhereItIsRead](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E39_InvalidKindBareRevert](../contracts/tests/ClaimCoverageEasy.t.sol), [test_E7_UnreachableDescriptorFailsBeforeCalls](../contracts/tests/ClaimCoverageEasy.t.sol).

**Scope and limitations:** Focused admission, invalid-kind and malformed payload checks distinguish declared errors from exact bare ABI-decoder reverts. The retained hostile-graph grid remains bounded; arithmetic/resource failures are still permitted.

## E41

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** [contracts/tests/ClaimEvidenceGaps.t.sol](../contracts/tests/ClaimEvidenceGaps.t.sol) `test_E41_EvaluateAndEncodedCallsStartFreshCaches`; check_cacheSeparateEvaluations and check_cacheSeparateCollectionCallbacks [contracts/tests/ClaimCacheSymbolic.t.sol](../contracts/tests/ClaimCacheSymbolic.t.sol); test_cacheObserverSeparateInvocationSamples in that harness; check_routesFilterCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol); check_routesFoldCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol); check_routesReductionCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol); check_routesPredicateScanCaches [contracts/tests/ClaimCacheRoutesSymbolic.t.sol](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol)

**Recorded run:** [results, commands and source hashes](verification/halmos-word-navigation-20261013/run.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (evaluate, evaluateEncoded); [contracts/Collections.sol](../contracts/Collections.sol) (_callValue)

**Test/property definitions:** [check_cacheSeparateCollectionCallbacks](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_cacheSeparateEvaluations](../contracts/tests/ClaimCacheSymbolic.t.sol), [check_routesFilterCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [check_routesFoldCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [check_routesPredicateScanCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [check_routesReductionCaches](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol), [test_E41_EvaluateAndEncodedCallsStartFreshCaches](../contracts/tests/ClaimEvidenceGaps.t.sol), [test_cacheObserverSeparateInvocationSamples](../contracts/tests/ClaimCacheSymbolic.t.sol).

**Retained formal results:** [check_cacheSeparateCollectionCallbacks: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheSeparateCollectionCallbacks.json), [check_cacheSeparateEvaluations: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheSymbolicTest.check_cacheSeparateEvaluations.json), [check_routesFilterCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesFilterCaches.json), [check_routesFoldCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesFoldCaches.json), [check_routesPredicateScanCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesPredicateScanCaches.json), [check_routesReductionCaches: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ClaimCacheRoutesSymbolicTest.check_routesReductionCaches.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: Additional filters, word/value folds, word reductions and any/all/find predicates start a fresh four-node graph cache for each visited callback. One external leaf is shared as condition and branch; independent outputs and ghost-observed call counts pin within-invocation reuse and separate invocations. Folds have zero through three elements; other cases have two, with early exits. Existing direct evaluate/evaluateEncoded and mapValues cases remain. This is not arbitrary callback, graph or traversal induction; the pinned observer assumptions and concrete expectCall counts apply.

## E42

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [scripts/test-claim-coverage-structure.py](../scripts/test-claim-coverage-structure.py) `test_E42_admission_shape_metadata_reused_by_validation`; retained supporting evidence: `test_nodeValidatesDynamicValues` [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (cached-shape validation path); `test_gas_evaluatePerNode` [contracts/tests/AbiCodecGas.t.sol](../contracts/tests/AbiCodecGas.t.sol) (first Literal < 13k, each further < 5k, Tuple node < 33k)

**Recorded run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :244, :442; AGENTS.md:73-76

**Test/property definitions:** [test_E42_admission_shape_metadata_reused_by_validation](../scripts/test-claim-coverage-structure.py), [test_gas_evaluatePerNode](../contracts/tests/AbiCodecGas.t.sol), [test_nodeValidatesDynamicValues](../contracts/tests/MutationGaps.t.sol).

**Scope and limitations:** Compiler-AST checks verify admission parses each node valueType into cached dynamic/words fields and validation consumes those fields. Wrong descriptor, cached field and iterator mutations are detected. This is structural evidence for the current metadata-reuse claim, not a runtime parse-count theorem; recursive validation still walks contents.

## E46

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** Structural: no state variables, every external function `view` ([contracts/Expressions.sol](../contracts/Expressions.sol), :289, :313); `test_noContractCanChangeState` [contracts/tests/Stateless.t.sol](../contracts/tests/Stateless.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol); README.md:5

**Test/property definitions:** [test_noContractCanChangeState](../contracts/tests/Stateless.t.sol).

**Scope and limitations:** Pinned on the deployed bytes (see C12)

## E48

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** E1, E2, E3, E4, E5, E21, E22, E23 properties assert exact revert data with the node index

**Recorded run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :137-138, :144-147, :154, :163; AGENTS.md:133

**Related behavioral evidence:** [E1](#e1), [E2](#e2), [E3](#e3), [E4](#e4), [E5](#e5), [E21](#e21), [E22](#e22), [E23](#e23).

**Retained formal results:** [check_callTargetRules: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsCallsSymbolicTest.check_callTargetRules.json), [check_parameterDataIsOneWord: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_parameterDataIsOneWord.json), [check_parameterIndexBounded: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_parameterIndexBounded.json), [check_referenceCountsPerKind: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_referenceCountsPerKind.json), [check_referencesMustPointBackwards: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsSymbolicTest.check_referencesMustPointBackwards.json), [check_resolveNodeEnforcesConstraints: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/CompositionSymbolicTest.check_resolveNodeEnforcesConstraints.json), [check_resultIndexInRange: passed](verification/halmos-core-wire-arithmetic-accepted-20261013/ExpressionsStructureSymbolicTest.check_resultIndexInRange.json).

**Run assumptions and source identity:** [manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Partial: up-front ref counts, Parameter data and result bounds now have symbolic properties. Dirty ProbeCall targets and code-less Resolve cores remain unpinned as stated in E21/E22.

## E49

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testMemoizationChangesGasSensitiveCallResults`

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol) (contract NatSpec); `AGENTS.md`

**Test/property definitions:** [testMemoizationChangesGasSensitiveCallResults](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** At the same evaluation budget a shared gasleft leaf yields two equal values, duplicated leaves yield decreasing values. Call context also includes caller and calldata; view alone is insufficient.

## R1

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [website/scripts/check-integration.mjs](../website/scripts/check-integration.mjs) ([docs/assertions-2.0-release-checks.json](assertions-2.0-release-checks.json)); `pnpm check:integration`; `docs/verification/abi-codec-final/checks.json`; [website/src/lib/deployments.json](../website/src/lib/deployments.json)

**Recorded run:** [results, commands and source hashes](assertions-2.0-release-checks.json).

**Supporting sources:** [website/scripts/check-integration.mjs](../website/scripts/check-integration.mjs); [website/scripts/export-deploy-artifact.mjs](../website/scripts/export-deploy-artifact.mjs); `AGENTS.md`

**Integration check:** [check:integration](../website/scripts/check-integration.mjs).

**Scope and limitations:** The final canonical Hardhat artifacts, CREATE2 predictions, generated deployment/ABI/verification modules, SDK constants and runtime fixtures agree in the offline integration check. Salts are newly mined against the final source. This check does not establish deployment on any public chain.

## R2

**Recorded evidence:** ASSUMPTION / DOCUMENTED.

**References:** Hardhat/Forge suites and local Anvil integration logs in `docs/verification/abi-codec-final/concrete`; compiler settings in manifest

**Supporting sources:** `hardhat.config.ts`; `foundry.toml`; `README.md`; [website/src/lib/deployments.json](../website/src/lib/deployments.json)

**Concrete run results:** [checks and exit statuses](verification/halmos-core-wire-arithmetic-accepted-20261013/checks.json).

**Scope and limitations:** Environment precondition: execute with the recorded compiler/EVM settings and correct environmental observations and used precompiles. Local Cancun and fork checks cover selected environments; they do not certify every possible chain. MODEXP fallback handles failed or wrong-sized receipts, but a successful 32-byte reply remains trusted.

## R3

**Recorded evidence:** LIMITATION / DOCUMENTED.

**References:** `pnpm check:integration` verifies predictions; no public-chain deployment performed by this change

**Supporting sources:** `README.md`; [website/scripts/export-deploy-artifact.mjs](../website/scripts/export-deploy-artifact.mjs); SDK `packages/sdk/src/onchain/addresses.ts`

**Integration check:** [check:integration](../website/scripts/check-integration.mjs).

**Scope and limitations:** CREATE2 predicts an address from deployer, salt and creation-code hash; the prediction by itself does not establish code presence or matching runtime on a public chain. Local prediction/integration checks support the formula, not public deployment availability.

## C70

**Historical statement:** `isValid` reports successful resolution and constraints, not returned boolean truth; ordinary failure yields 0, exhaustion classification propagates.

**Replaced by:** [C85](#c85). Merged validity, false-return and exhaustion semantics into a new statement.

**Retained evidence:** UNIT / SUITE PASSED for this historical statement.

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimCoverageEasy.t.sol](../contracts/tests/ClaimCoverageEasy.t.sol) `test_C66_C70_ControlFailureMatrix`; retained supporting evidence: `check_orElseAndIsValidAgree` [contracts/tests/ControlSymbolic.t.sol](../contracts/tests/ControlSymbolic.t.sol); `genIsValid` [test/compose-fuzz.test.ts](../test/compose-fuzz.test.ts); `test_isValid_revertingCall` [contracts/tests/CoreReads.t.sol](../contracts/tests/CoreReads.t.sol); `test_isValid_constraintViolation` `:1048`

**Recorded test run:** [results, commands and source hashes](claim-coverage-checks.json).

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol)

**Test/property definitions:** [check_orElseAndIsValidAgree](../contracts/tests/ControlSymbolic.t.sol), [test_C66_C70_ControlFailureMatrix](../contracts/tests/ClaimCoverageEasy.t.sol), [test_isValid_constraintViolation](../contracts/tests/CoreReads.t.sol), [test_isValid_revertingCall](../contracts/tests/CoreReads.t.sol).

**Scope and limitations:** The same control matrix verifies ordinary and reserved failure behavior without promising successful calls for hostile targets.

## C84

**Historical statement:** `isValid` reports successful resolution and inline constraints, not boolean truth of the returned value

**Replaced by:** [C85](#c85). Merged the overlapping validity statement without reusing either prior ID.

**Retained evidence:** UNIT / SUITE PASSED for this historical statement.

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testEmptyAndUnconstrainedAssertionsAndFalseReturnPass`

**Supporting sources:** [contracts/Assertions.sol](../contracts/Assertions.sol) (`isValid`)

**Test/property definitions:** [testEmptyAndUnconstrainedAssertionsAndFalseReturnPass](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** An unconstrained successful call returning false yields 1; ordinary failures yield 0 except C69.

## E11

**Historical statement:** Successful node values are cached; failed guarded attempts discard cache changes, so their work may execute again.

**Replaced by:** [E50](#e50). Merged node reuse and guarded cache outcomes into a new statement.

**Retained evidence:** UNIT / SUITE PASSED for this historical statement.

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testGraphMemoizesSharedDynamicCallAndLazyBranch` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (`vm.expectCall` count 1); `check_sharingEqualsDuplication` [contracts/tests/ExpressionsSymbolic.t.sol](../contracts/tests/ExpressionsSymbolic.t.sol) (sharing is value-transparent: graph == duplicated tree == solc); `test_sharedNodeEvaluatesOnce` [contracts/tests/CallCountsAndFallbacks.t.sol](../contracts/tests/CallCountsAndFallbacks.t.sol) (added after the snapshot); [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `testMemoizationChangesGasSensitiveCallResults`

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :115-119, :216-217, :355; [website/src/content/docs/docs/index.md](../website/src/content/docs/docs/index.md), :58; README.md:10; AGENTS.md:49-50, :62-63

**Test/property definitions:** [check_sharingEqualsDuplication](../contracts/tests/ExpressionsSymbolic.t.sol), [testGraphMemoizesSharedDynamicCallAndLazyBranch](../contracts/tests/Expressions.t.sol), [testMemoizationChangesGasSensitiveCallResults](../contracts/tests/ClaimBoundaries.t.sol), [test_sharedNodeEvaluatesOnce](../contracts/tests/CallCountsAndFallbacks.t.sol).

**Scope and limitations:** Exact shared-call count is pinned; `check_sharingEqualsDuplication` proves value equality only for its deterministic leaf. Gas-sensitive duplicated reads can return different values (E49). Successful-attempt cache retained (E17); failed-attempt work may execute again (E18).

## E17

**Historical statement:** Values memoized inside a successful guarded attempt are kept for the rest of the evaluation

**Replaced by:** [E50](#e50). Successful guarded cache adoption is included in the new cache statement.

**Retained evidence:** UNIT / SUITE PASSED for this historical statement.

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testGuardedGraphFallbackAndSuccessfulCacheMerge` [contracts/tests/Expressions.t.sol](../contracts/tests/Expressions.t.sol) (`vm.expectCall` count 1)

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :280-281, :418-420, :437-439

**Test/property definitions:** [testGuardedGraphFallbackAndSuccessfulCacheMerge](../contracts/tests/Expressions.t.sol).

## E18

**Historical statement:** A failed guarded attempt discards its cache changes

**Replaced by:** [E50](#e50). Failed guarded cache rollback is included in the new cache statement.

**Retained evidence:** UNIT / SUITE PASSED for this historical statement.

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** [contracts/tests/ClaimBoundaries.t.sol](../contracts/tests/ClaimBoundaries.t.sol) `test_failedGuardedAttemptDiscardsCachedCalls`

**Supporting sources:** [contracts/Expressions.sol](../contracts/Expressions.sol), :440-442

**Test/property definitions:** [test_failedGuardedAttemptDiscardsCachedCalls](../contracts/tests/ClaimBoundaries.t.sol).

**Scope and limitations:** Exact vm.expectCall count 2: the first attempt calls a shared leaf and then fails canonical uint8 validation; a later reference re-executes the leaf and returns the expected value.

## L55

**Historical statement:** Constant slots validated once up front against their component types; substituted values validated at every binding against the slot type

**Replaced by:** [L70](#l70). Replaced a per-binding implementation assertion with the slot-type guarantee.

**Retained evidence:** SYMBOLIC / PROVED for this historical statement.

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** test_remainingTraversalValidations [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol) (dirty constant, InvalidComponentValue); testPreparedCallbackRetainsStaticSlotWidth [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol) (slot width mismatch, InvalidComponentLength); `check_constantsAndBindingsAreValidated` [contracts/tests/SlotsSplitSymbolic.t.sol](../contracts/tests/SlotsSplitSymbolic.t.sol)

**Recorded test run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 676-677, 1471

**Test/property definitions:** [check_constantsAndBindingsAreValidated](../contracts/tests/SlotsSplitSymbolic.t.sol), [testPreparedCallbackRetainsStaticSlotWidth](../contracts/tests/Collections.t.sol), [test_remainingTraversalValidations](../contracts/tests/MutationGaps.t.sol).

**Retained formal results:** [check_constantsAndBindingsAreValidated: passed](verification/halmos-gas-pass-20261008/SlotsSplitSymbolicTest.check_constantsAndBindingsAreValidated.json).

**Run assumptions and source identity:** [manifest](verification/halmos-gas-pass-20261008/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Proved: a constant slot is refused before any call even over an empty input, a bound value at its binding, each as `InvalidComponentValue` naming the slot; removing either check fails it

## L69

**Historical statement:** reduceWords refuses an unaligned payload (UnalignedWords) and a window past the template (LambdaOffsetOutOfBounds) even on an empty payload; an empty payload returns 1 for All and 0 otherwise without inspecting the target; a code-less target reverts InvalidCallbackTarget and a result that is not one word InvalidCallbackResult naming its element; an out-of-range `mode` or `cmp` is refused by the ABI decoder without data

**Replaced by:** [L71](#l71), [L72](#l72), [L73](#l73). Split structural, result-width and enum-decoding guarantees by their evidence scope.

**Retained evidence:** SYMBOLIC / PROVED for this historical statement.

**Recorded evidence:** SYMBOLIC / PROVED.

**References:** check_reduceWordsErrors [contracts/tests/WordLambdasSymbolic.t.sol](../contracts/tests/WordLambdasSymbolic.t.sol); test_emptyPayloadTouchesNoTarget [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_declaredErrors [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_malformedResultNamesItsElement [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_outOfRangeEnumsAreRefusedByTheDecoder [contracts/tests/ReduceWords.t.sol](../contracts/tests/ReduceWords.t.sol); test_everyElementWindowIsBounded [contracts/tests/MutationGaps.t.sol](../contracts/tests/MutationGaps.t.sol)

**Recorded test run:** [results, commands and source hashes](gas-pass-checks.json).

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol), 1279-1309

**Test/property definitions:** [check_reduceWordsErrors](../contracts/tests/WordLambdasSymbolic.t.sol), [test_declaredErrors](../contracts/tests/ReduceWords.t.sol), [test_emptyPayloadTouchesNoTarget](../contracts/tests/ReduceWords.t.sol), [test_everyElementWindowIsBounded](../contracts/tests/MutationGaps.t.sol), [test_malformedResultNamesItsElement](../contracts/tests/ReduceWords.t.sol), [test_outOfRangeEnumsAreRefusedByTheDecoder](../contracts/tests/ReduceWords.t.sol).

**Retained formal results:** [check_reduceWordsErrors: passed](verification/halmos-gas-pass-20261008/WordLambdasSymbolicTest.check_reduceWordsErrors.json).

**Run assumptions and source identity:** [manifest](verification/halmos-gas-pass-20261008/manifest.json) (source hashes, tool configuration, bounds and gas model).

**Scope and limitations:** Halmos n<=3 words, every mode; the out-of-range enum refusal and the element index of a malformed result past the first element are pinned by unit tests only

## E47

**Historical statement:** Collections reaches Expressions through a local `IExpressions` whose selector matches `evaluateEncoded`

**Replaced by:** [L61](#l61). Removed a duplicate presentation of the unchanged local selector guarantee.

**Retained evidence:** UNIT / SUITE PASSED for this historical statement.

**Recorded evidence:** UNIT / SUITE PASSED.

**References:** `testLocalExpressionsDeclarationMatches` [contracts/tests/Collections.t.sol](../contracts/tests/Collections.t.sol); `test_sharedSelectorsMatch` [contracts/tests/ExpressionsStructureSymbolic.t.sol](../contracts/tests/ExpressionsStructureSymbolic.t.sol) (added after the snapshot)

**Supporting sources:** [contracts/Collections.sol](../contracts/Collections.sol)

**Test/property definitions:** [testLocalExpressionsDeclarationMatches](../contracts/tests/Collections.t.sol), [test_sharedSelectorsMatch](../contracts/tests/ExpressionsStructureSymbolic.t.sol).

**Scope and limitations:** Pinned by a unit test: `IExpressions.evaluateEncoded` matches Expressions (compile-time fact)
