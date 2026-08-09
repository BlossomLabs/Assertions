// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {
    ComposableExecution,
    ComposableLib,
    InputParam,
    InputParamFetcherType,
    InputParamType
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
 * @dev The judge is view-only: assertComposable(executions) evaluates the
 *      ERC-8211 execution algorithm directly, restricted to what a view
 *      context can express: every fetcher resolution is a staticcall,
 *      entries with a TARGET parameter execute the constructed call via
 *      STATICCALL (the call itself becomes an assertion — it must not
 *      revert), VALUE parameters and outputParams are rejected (no ETH
 *      forwarding, no Storage writes in view). Entries without a TARGET
 *      parameter are standard ERC-8211 predicate entries. The encoding is
 *      the unmodified ERC-8211 wire format, so batches built by any
 *      ERC-8211 SDK judge here unchanged.
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

    // ============ Composable Batch Assertions ============

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

    // ============ Internal Judge ============

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
}
