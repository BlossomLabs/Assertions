// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title ERC8211
 * @author Sembrestels
 * @notice The ERC-8211 (Smart Batching) vocabulary shared by the Assertions
 *         core and the Combinators periphery: the canonical batch encoding
 *         (`ComposableExecution`, `InputParam`, `Constraint`), the standard
 *         `IComposableExecution` interface, and a shared library implementing
 *         the standard's input-parameter resolution and constraint
 *         validation semantics over `staticcall`.
 * @dev The structs and enums mirror the ERC-8211 wire format byte-for-byte,
 *      so batches produced by any ERC-8211 SDK decode here unchanged, and
 *      predicate entries encoded for this repo's contracts are valid
 *      ERC-8211 entries. Per the standard's shared-library guidance, all
 *      fetcher resolution and constraint evaluation lives in ComposableLib
 *      so the Assertions judge, the Combinators expression layer, and any
 *      local `IComposableExecution` implementation behave identically.
 */

// ============ ERC-8211 Encoding ============

/// @notice Where a resolved input parameter is routed
/// @dev ABI-encoded as uint8: TARGET = 0 (call target address, at most one
///      per entry), VALUE = 1 (ETH to forward, at most one per entry),
///      CALL_DATA = 2 (appended to the calldata being built)
enum InputParamType {
    TARGET,
    VALUE,
    CALL_DATA
}

/// @notice How an input parameter's value is obtained at execution time
/// @dev ABI-encoded as uint8: RAW_BYTES = 0 (paramData used as-is),
///      STATIC_CALL = 1 (paramData is abi.encode(address, bytes); the raw
///      returndata of the staticcall is the value), BALANCE = 2 (paramData
///      is abi.encodePacked(address token, address account), exactly 40
///      bytes; token == address(0) reads the native balance, otherwise
///      IERC20(token).balanceOf(account); the result is abi.encode(uint256))
enum InputParamFetcherType {
    RAW_BYTES,
    STATIC_CALL,
    BALANCE
}

/// @notice Where an output parameter's captured data comes from
/// @dev ABI-encoded as uint8: EXEC_RESULT = 0, STATIC_CALL = 1. Output
///      parameters write to the ERC-8211 Storage contract and therefore
///      cannot appear in view-mode assertion batches — the Assertions judge
///      rejects entries that carry them.
enum OutputParamFetcherType {
    EXEC_RESULT,
    STATIC_CALL
}

/// @notice Inline predicate kinds validated against a resolved value
/// @dev ABI-encoded as uint8: EQ = 0, GTE = 1, LTE = 2 (referenceData is a
///      single 32-byte word), IN = 3 (referenceData is
///      abi.encode(bytes32 lowerBound, bytes32 upperBound), 64 bytes;
///      bounds are inclusive). Comparisons are unsigned over the value's
///      first 32-byte word, which covers uint256, address, bool and other
///      left-padded 32-byte representations.
enum ConstraintType {
    EQ,
    GTE,
    LTE,
    IN
}

/// @notice An inline predicate attached to an input parameter
struct Constraint {
    ConstraintType constraintType;
    bytes referenceData;
}

/// @notice A single runtime-resolved parameter: how to obtain the value
///         (fetcherType + paramData), what it must satisfy (constraints),
///         and where it goes (paramType)
struct InputParam {
    InputParamType paramType;
    InputParamFetcherType fetcherType;
    bytes paramData;
    Constraint[] constraints;
}

/// @notice A return-data capture instruction (Storage-contract writes;
///         unsupported in view-mode assertion batches)
struct OutputParam {
    OutputParamFetcherType fetcherType;
    bytes paramData;
}

/// @notice One step of a smart batch: the call is CONSTRUCTED at execution
///         time by routing each resolved input parameter; an entry with no
///         TARGET parameter is a predicate entry (resolve + validate only,
///         no call)
struct ComposableExecution {
    bytes4 functionSig;
    InputParam[] inputParams;
    OutputParam[] outputParams;
}

/// @notice The single normative ERC-8211 interface
interface IComposableExecution {
    /// @notice Executes a composable batch
    /// @param executions The ordered array of composable execution entries
    function executeComposable(ComposableExecution[] calldata executions) external payable;
}

/// @notice Minimal ERC-20 surface the BALANCE fetcher needs
interface IERC20Balance {
    function balanceOf(address account) external view returns (uint256);
}

// ============ Shared Errors ============

/// @notice Thrown when a staticcall to a target contract fails or the
///         target has no code
/// @param target The contract address that was called
/// @param data The calldata that was sent
error CallFailed(address target, bytes data);

/// @notice Thrown when a resolved value violates one of its inline
///         constraints — THE assertion failure
/// @param assertion The assertion message ("" when the constraint sits on a
///        combinator operand rather than a judged batch)
/// @param entryIndex The batch entry the parameter belongs to (0 outside a
///        batch context)
/// @param paramIndex The input parameter's position within the entry (or
///        the operand's position within a combinator)
/// @param constraintIndex The failing constraint's position on the parameter
/// @param constraintType The constraint kind that failed (see ConstraintType)
/// @param actual The resolved value's first 32-byte word, as compared
/// @param referenceData The constraint's reference data, echoed as given
error ConstraintFailed(
    string assertion,
    uint256 entryIndex,
    uint256 paramIndex,
    uint256 constraintIndex,
    ConstraintType constraintType,
    bytes32 actual,
    bytes referenceData
);

/// @notice Thrown when a BALANCE fetcher's paramData is not exactly 40
///         bytes (two packed addresses)
/// @param entryIndex The batch entry the parameter belongs to
/// @param paramIndex The input parameter's position within the entry
/// @param length The length of the paramData that was passed
error InvalidBalanceData(uint256 entryIndex, uint256 paramIndex, uint256 length);

/// @notice Thrown when a constraint's referenceData has the wrong length
///         (32 bytes for EQ/GTE/LTE, 64 bytes for IN)
/// @param entryIndex The batch entry the parameter belongs to
/// @param paramIndex The input parameter's position within the entry
/// @param constraintIndex The malformed constraint's position on the parameter
/// @param length The length of the referenceData that was passed
error InvalidConstraintData(uint256 entryIndex, uint256 paramIndex, uint256 constraintIndex, uint256 length);

/// @notice Thrown when resolved data is too short (or a word index is
///         outside the data) for the requested read
/// @param index The requested word index as given (may be negative for
///        from-the-end indexing; 0 for first-word reads)
/// @param length The length of the resolved data in bytes
error ReturnDataOutOfBounds(int256 index, uint256 length);

/// @notice Thrown when a word that must hold an address has dirty upper bytes
/// @param index The position of the offending value (parameter index, chain
///        hop index, or 0 for single-operand uses)
/// @param word The raw 32-byte word that was selected
error InvalidAddressWord(uint256 index, bytes32 word);

// ============ Shared Library ============

/// @notice ERC-8211 input-parameter resolution and constraint validation,
///         shared by the Assertions judge and the Combinators periphery per
///         the standard's shared-library guidance
library ComposableLib {
    /// @dev Resolves an input parameter per the ERC-8211 fetcher semantics
    ///      and validates its inline constraints against the resolved value.
    ///      RAW_BYTES echoes paramData; STATIC_CALL returns the raw
    ///      returndata of the encoded call; BALANCE returns
    ///      abi.encode(uint256 balance). `assertion`, `entryIndex` and
    ///      `paramIndex` are error-reporting context only.
    function resolve(
        InputParam calldata param,
        string memory assertion,
        uint256 entryIndex,
        uint256 paramIndex
    ) internal view returns (bytes memory value) {
        if (param.fetcherType == InputParamFetcherType.RAW_BYTES) {
            value = param.paramData;
        } else if (param.fetcherType == InputParamFetcherType.STATIC_CALL) {
            (address callTarget, bytes memory callData) = abi.decode(param.paramData, (address, bytes));
            value = staticCall(callTarget, callData);
        } else {
            // BALANCE
            if (param.paramData.length != 40) {
                revert InvalidBalanceData(entryIndex, paramIndex, param.paramData.length);
            }
            address token = address(bytes20(param.paramData[0:20]));
            address account = address(bytes20(param.paramData[20:40]));
            if (token == address(0)) {
                value = abi.encode(account.balance);
            } else {
                bytes memory ret = staticCall(token, abi.encodeCall(IERC20Balance.balanceOf, (account)));
                value = abi.encode(uint256(firstWord(ret)));
            }
        }
        validateConstraints(param.constraints, value, assertion, entryIndex, paramIndex);
    }

    /// @dev Executes a staticcall and returns the raw result bytes.
    ///      Reverts with CallFailed when the target has no code, since a
    ///      staticcall to a code-less address succeeds with empty returndata
    ///      and would otherwise surface as a silent wrong value.
    function staticCall(address target, bytes memory callData) internal view returns (bytes memory) {
        if (target.code.length == 0) revert CallFailed(target, callData);
        (bool success, bytes memory result) = target.staticcall(callData);
        if (!success) revert CallFailed(target, callData);
        return result;
    }

    /// @dev The first 32-byte word of `value` — the word constraints compare
    ///      and words are routed from. Reverts with ReturnDataOutOfBounds
    ///      when fewer than 32 bytes are available.
    function firstWord(bytes memory value) internal pure returns (bytes32 word) {
        if (value.length < 32) revert ReturnDataOutOfBounds(0, value.length);
        assembly {
            word := mload(add(value, 32))
        }
    }

    /// @dev Interprets a word as an address, reverting with
    ///      InvalidAddressWord when the upper 96 bits are dirty
    function asAddress(bytes32 word, uint256 index) internal pure returns (address) {
        if (uint256(word) >> 160 != 0) revert InvalidAddressWord(index, word);
        return address(uint160(uint256(word)));
    }

    /// @dev Validates every constraint against the resolved value's first
    ///      32-byte word (unsigned comparisons, per the standard). Reverts
    ///      with InvalidConstraintData on malformed referenceData and
    ///      ConstraintFailed on the first violated constraint.
    function validateConstraints(
        Constraint[] calldata constraints,
        bytes memory value,
        string memory assertion,
        uint256 entryIndex,
        uint256 paramIndex
    ) internal pure {
        if (constraints.length == 0) return;
        bytes32 actual = firstWord(value);
        for (uint256 i = 0; i < constraints.length; i++) {
            Constraint calldata c = constraints[i];
            bool ok;
            if (c.constraintType == ConstraintType.IN) {
                if (c.referenceData.length != 64) {
                    revert InvalidConstraintData(entryIndex, paramIndex, i, c.referenceData.length);
                }
                (bytes32 lower, bytes32 upper) = abi.decode(c.referenceData, (bytes32, bytes32));
                ok = uint256(actual) >= uint256(lower) && uint256(actual) <= uint256(upper);
            } else {
                if (c.referenceData.length != 32) {
                    revert InvalidConstraintData(entryIndex, paramIndex, i, c.referenceData.length);
                }
                bytes32 bound = bytes32(c.referenceData);
                if (c.constraintType == ConstraintType.EQ) {
                    ok = actual == bound;
                } else if (c.constraintType == ConstraintType.GTE) {
                    ok = uint256(actual) >= uint256(bound);
                } else {
                    // LTE
                    ok = uint256(actual) <= uint256(bound);
                }
            }
            if (!ok) {
                revert ConstraintFailed(assertion, entryIndex, paramIndex, i, c.constraintType, actual, c.referenceData);
            }
        }
    }
}
