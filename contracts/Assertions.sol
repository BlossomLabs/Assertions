// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {
    ComposableExecution,
    ComposableLib,
    IComposableExecution,
    InputParam,
    InputParamFetcherType,
    InputParamType,
    CallFailed
} from "./ERC8211.sol";

/**
 * @title Assertions
 * @author Sembrestels
 * @notice On-chain assertion contract for verifying blockchain state,
 *         redesigned around a static call to ERC-8211 (Smart Batching).
 *         An assertion IS an ERC-8211 predicate batch: entries whose input
 *         parameters resolve live on-chain values (staticcalls, balances,
 *         literals) and validate them against inline constraints. Batch
 *         assertion calls alongside the transactions they guard (DAO
 *         proposals, Safe batches, upgrades): if any constraint fails, the
 *         entire transaction reverts, atomically.
 * @dev Two judging modes, both view-only:
 *
 *      NATIVE — assertComposable(executions) evaluates the ERC-8211
 *      execution algorithm directly, restricted to what a view context can
 *      express: every fetcher resolution is a staticcall, entries with a
 *      TARGET parameter execute the constructed call via STATICCALL (the
 *      call itself becomes an assertion — it must not revert), VALUE
 *      parameters and outputParams are rejected (no ETH forwarding, no
 *      Storage writes in view). Entries without a TARGET parameter are
 *      standard ERC-8211 predicate entries. The encoding is the unmodified
 *      ERC-8211 wire format, so batches built by any ERC-8211 SDK judge
 *      here unchanged.
 *
 *      WRAPPED — assertComposable(composable, executions) performs the
 *      literal static call to an ERC-8211 implementation:
 *      composable.staticcall(executeComposable(executions)). This asserts
 *      "this account would accept this batch right now" — the same
 *      eth_call gate ERC-8211 relayers use off-chain, made composable
 *      on-chain. Because it is a staticcall, it only passes for
 *      state-neutral batches (predicate entries); any state-changing entry
 *      makes the assertion fail.
 *
 *      assertParam(param) is sugar for the 90% case: resolve one input
 *      parameter and validate its constraints, no batch scaffolding.
 *
 *      Composed expressions (chained reads, arithmetic, logic, string
 *      operations) are computed by the separate Combinators contract and
 *      judged here through a STATIC_CALL fetcher pointed at the Combinators
 *      address. Assertions judge, Combinators compute.
 * @custom:version 2.0
 */
contract Assertions {
    using ComposableLib for InputParam;

    // ============ Custom Errors ============
    //
    // ConstraintFailed, CallFailed, InvalidBalanceData, InvalidConstraintData,
    // ReturnDataOutOfBounds and InvalidAddressWord are shared with the
    // resolution library and declared in ERC8211.sol.

    /// @notice Thrown when the wrapped static call to an ERC-8211
    ///         implementation's executeComposable reverts
    /// @param assertion The assertion type or custom message
    /// @param composable The IComposableExecution implementation that was called
    /// @param revertData The raw revert data the implementation returned
    ///        (empty when the staticcall failed without a reason, e.g. a
    ///        state-changing batch judged through a staticcall)
    error ComposableFailed(string assertion, address composable, bytes revertData);

    /// @notice Thrown when an entry carries output parameters — Storage
    ///         writes are impossible in a view-mode judge
    /// @param entryIndex The offending entry's position in the batch
    error OutputParamsNotSupported(uint256 entryIndex);

    /// @notice Thrown when an entry carries a VALUE input parameter — ETH
    ///         cannot be forwarded through a STATICCALL judge
    /// @param entryIndex The offending entry's position in the batch
    /// @param paramIndex The VALUE parameter's position within the entry
    error ValueParamNotSupported(uint256 entryIndex, uint256 paramIndex);

    /// @notice Thrown when an entry carries more than one TARGET input
    ///         parameter (the standard allows at most one)
    /// @param entryIndex The offending entry's position in the batch
    error DuplicateTargetParam(uint256 entryIndex);

    /// @notice Thrown when a TARGET input parameter uses the BALANCE
    ///         fetcher (a balance cannot be a call target address)
    /// @param entryIndex The offending entry's position in the batch
    /// @param paramIndex The TARGET parameter's position within the entry
    error BalanceCannotBeTarget(uint256 entryIndex, uint256 paramIndex);

    // ============ Composable Batch Assertions (native judge) ============

    /// @notice Assert that an ERC-8211 composable batch passes under
    ///         view-mode evaluation: every input parameter resolves, every
    ///         constraint holds, and every constructed call succeeds as a
    ///         staticcall
    /// @param executions The ERC-8211 batch entries (standard wire format)
    function assertComposable(ComposableExecution[] calldata executions) external view {
        _judge(executions, "COMPOSABLE");
    }

    /// @notice Assert that an ERC-8211 composable batch passes under
    ///         view-mode evaluation
    /// @param executions The ERC-8211 batch entries (standard wire format)
    /// @param message Custom error message on constraint failure
    function assertComposable(ComposableExecution[] calldata executions, string calldata message) external view {
        _judge(executions, message);
    }

    // ============ Composable Batch Assertions (wrapped implementation) ============

    /// @notice Assert that a deployed ERC-8211 implementation accepts the
    ///         batch right now, via a static call to executeComposable —
    ///         the on-chain equivalent of a relayer's eth_call gate. Only
    ///         state-neutral batches (predicate entries) can pass a
    ///         staticcall; a state-changing entry fails the assertion.
    /// @param composable The IComposableExecution implementation (account,
    ///        module, or adapter) to statically call
    /// @param executions The ERC-8211 batch entries (standard wire format)
    function assertComposable(address composable, ComposableExecution[] calldata executions) external view {
        _judgeWrapped(composable, executions, "COMPOSABLE");
    }

    /// @notice Assert that a deployed ERC-8211 implementation accepts the
    ///         batch right now, via a static call to executeComposable
    /// @param composable The IComposableExecution implementation to statically call
    /// @param executions The ERC-8211 batch entries (standard wire format)
    /// @param message Custom error message on failure
    function assertComposable(
        address composable,
        ComposableExecution[] calldata executions,
        string calldata message
    ) external view {
        _judgeWrapped(composable, executions, message);
    }

    // ============ Single-Parameter Assertions ============

    /// @notice Assert one ERC-8211 input parameter: resolve its value via
    ///         the fetcher and validate its inline constraints — the
    ///         single-check shorthand for a one-parameter predicate entry
    /// @param param The input parameter (paramType is ignored; nothing is routed)
    function assertParam(InputParam calldata param) external view {
        param.resolve("PARAM", 0, 0);
    }

    /// @notice Assert one ERC-8211 input parameter with a custom message
    /// @param param The input parameter (paramType is ignored; nothing is routed)
    /// @param message Custom error message on constraint failure
    function assertParam(InputParam calldata param, string calldata message) external view {
        param.resolve(message, 0, 0);
    }

    // ============ Internal Judges ============

    /// @dev The ERC-8211 execution algorithm, view-restricted. Per entry:
    ///      resolve each input parameter (fetcher), validate its
    ///      constraints, route it (TARGET or CALL_DATA; VALUE and
    ///      outputParams revert), then — when a TARGET resolved to a
    ///      non-zero address — STATICCALL the constructed call and require
    ///      success. Entries without a TARGET parameter are predicate
    ///      entries: resolve and validate only, no call.
    function _judge(ComposableExecution[] calldata executions, string memory message) internal view {
        for (uint256 i = 0; i < executions.length; i++) {
            ComposableExecution calldata entry = executions[i];
            if (entry.outputParams.length != 0) revert OutputParamsNotSupported(i);

            address target;
            bool hasTarget;
            bytes memory callData = abi.encodePacked(entry.functionSig);

            for (uint256 j = 0; j < entry.inputParams.length; j++) {
                InputParam calldata param = entry.inputParams[j];
                if (param.paramType == InputParamType.VALUE) revert ValueParamNotSupported(i, j);
                if (param.paramType == InputParamType.TARGET) {
                    if (hasTarget) revert DuplicateTargetParam(i);
                    if (param.fetcherType == InputParamFetcherType.BALANCE) revert BalanceCannotBeTarget(i, j);
                    hasTarget = true;
                    bytes memory resolved = param.resolve(message, i, j);
                    target = ComposableLib.asAddress(ComposableLib.firstWord(resolved), j);
                } else {
                    // CALL_DATA: appended in parameter order, per the standard
                    callData = bytes.concat(callData, param.resolve(message, i, j));
                }
            }

            if (target != address(0)) {
                // The constructed call is itself an assertion: it must not revert.
                ComposableLib.staticCall(target, callData);
            }
        }
    }

    /// @dev The literal static call to an ERC-8211 implementation. Reverts
    ///      with CallFailed when `composable` has no code (a staticcall to
    ///      a code-less address would succeed vacuously and turn every
    ///      assertion into a false pass), and with ComposableFailed —
    ///      carrying the implementation's raw revert data — when the
    ///      wrapped executeComposable rejects the batch.
    function _judgeWrapped(
        address composable,
        ComposableExecution[] calldata executions,
        string memory message
    ) internal view {
        bytes memory callData = abi.encodeCall(IComposableExecution.executeComposable, (executions));
        if (composable.code.length == 0) revert CallFailed(composable, callData);
        (bool success, bytes memory revertData) = composable.staticcall(callData);
        if (!success) revert ComposableFailed(message, composable, revertData);
    }
}
