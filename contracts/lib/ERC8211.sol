// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title ERC8211
 * @author Sembrestels
 * @notice The ERC-8211 (Smart Batching) wire format: the canonical batch
 *         encoding (`ComposableExecution`, `InputParam`, `Constraint`), the
 *         standard `IComposableExecution` interface, and the shared errors
 *         of the standard's resolution semantics. Pure vocabulary, no code:
 *         the Assertions core implements resolution and constraint
 *         validation internally, and the periphery contracts speak plain
 *         ABI types and need none of this.
 * @dev The structs and enums mirror the ERC-8211 wire format byte-for-byte,
 *      so batches produced by any ERC-8211 SDK decode here unchanged, and
 *      predicate entries encoded for this repo's contracts are valid
 *      ERC-8211 entries.
 */

// ============ ERC-8211 Encoding ============

/**
 * @notice Where a resolved input parameter is routed
 * @dev ABI-encoded as uint8: TARGET = 0 (call target address, at most one
 *      per entry), VALUE = 1 (ETH to forward, at most one per entry),
 *      CALL_DATA = 2 (appended to the calldata being built)
 */
enum InputParamType {
    TARGET,
    VALUE,
    CALL_DATA
}

/**
 * @notice How an input parameter's value is obtained at execution time
 * @dev ABI-encoded as uint8: RAW_BYTES = 0 (paramData used as-is),
 *      STATIC_CALL = 1 (paramData is abi.encode(address, bytes); the raw
 *      returndata of the staticcall is the value), BALANCE = 2 (paramData
 *      is abi.encodePacked(address token, address account), exactly 40
 *      bytes; token == address(0) reads the native balance, otherwise
 *      IERC20(token).balanceOf(account); the result is abi.encode(uint256))
 */
enum InputParamFetcherType {
    RAW_BYTES,
    STATIC_CALL,
    BALANCE
}

/**
 * @notice Where an output parameter's captured data comes from
 * @dev ABI-encoded as uint8: EXEC_RESULT = 0, STATIC_CALL = 1. Output
 *      parameters write to the ERC-8211 Storage contract and therefore
 *      cannot appear in view-mode assertion batches: the Assertions judge
 *      rejects entries that carry them.
 */
enum OutputParamFetcherType {
    EXEC_RESULT,
    STATIC_CALL
}

/**
 * @notice Inline predicate kinds validated against a resolved value
 * @dev ABI-encoded as uint8: EQ = 0, GTE = 1, LTE = 2 (referenceData is a
 *      single 32-byte word), IN = 3 (referenceData is
 *      abi.encode(bytes32 lowerBound, bytes32 upperBound), 64 bytes;
 *      bounds are inclusive). Constraint i checks resolved word i. The
 *      Biconomy reference IDs are preserved: signed comparisons 4/5,
 *      OR 6 (abi.encode(Constraint[]) of non-OR leaves), SKIP 7 (empty
 *      referenceData), and IN_SIGNED 8 (two signed bounds). Signed kinds
 *      reinterpret complete words as int256; unsigned kinds use uint256.
 */
enum ConstraintType {
    EQ,
    GTE,
    LTE,
    IN,
    GTE_SIGNED,
    LTE_SIGNED,
    OR,
    SKIP,
    IN_SIGNED
}

/**
 * @notice An inline predicate attached to an input parameter
 */
struct Constraint {
    ConstraintType constraintType;
    bytes referenceData;
}

/**
 * @notice A single runtime-resolved parameter: how to obtain the value
 *         (fetcherType + paramData), what it must satisfy (constraints),
 *         and where it goes (paramType)
 */
struct InputParam {
    InputParamType paramType;
    InputParamFetcherType fetcherType;
    bytes paramData;
    Constraint[] constraints;
}

/**
 * @notice A return-data capture instruction (Storage-contract writes;
 *         unsupported in view-mode assertion batches)
 */
struct OutputParam {
    OutputParamFetcherType fetcherType;
    bytes paramData;
}

/**
 * @notice One step of a smart batch: the call is CONSTRUCTED at execution
 *         time by routing each resolved input parameter; an entry with no
 *         TARGET parameter is a predicate entry (resolve + validate only,
 *         no call)
 */
struct ComposableExecution {
    bytes4 functionSig;
    InputParam[] inputParams;
    OutputParam[] outputParams;
}

/**
 * @notice The single normative ERC-8211 interface. Assertions does not
 *         implement it: the judge is a view function over the same batch
 *         encoding, not a payable executor
 */
interface IComposableExecution {
    /**
     * @notice Executes a composable batch
     * @param executions The ordered array of composable execution entries
     */
    function executeComposable(ComposableExecution[] calldata executions) external payable;
}

// ============ Shared Errors ============

/**
 * @notice Thrown when a staticcall to a target contract fails or the
 *         target has no code
 * @param target The contract address that was called
 * @param data The calldata that was sent
 */
error CallFailed(address target, bytes data);

/**
 * @notice Thrown when a resolved value violates one of its inline
 *         constraints: THE assertion failure
 * @param assertion The assertion message ("" when the constraint sits on a
 *        primitive's operand rather than a judged batch)
 * @param entryIndex The batch entry the parameter belongs to (0 outside a
 *        batch context)
 * @param paramIndex The input parameter's position within the entry (or
 *        the operand's position within a read primitive)
 * @param constraintIndex The failing constraint's position on the parameter
 * @param constraintType The constraint kind that failed (see ConstraintType)
 * @param actual The resolved word at constraintIndex, as compared
 * @param referenceData The constraint's reference data, echoed as given
 */
error ConstraintFailed(
    string assertion,
    uint256 entryIndex,
    uint256 paramIndex,
    uint256 constraintIndex,
    ConstraintType constraintType,
    bytes32 actual,
    bytes referenceData
);

/**
 * @notice Thrown when a BALANCE fetcher's paramData is not exactly 40
 *         bytes (two packed addresses)
 * @param entryIndex The batch entry the parameter belongs to
 * @param paramIndex The input parameter's position within the entry
 * @param length The length of the paramData that was passed
 */
error InvalidBalanceData(uint256 entryIndex, uint256 paramIndex, uint256 length);

/**
 * @notice Thrown when a constraint's referenceData has the wrong length
 *         (32 bytes for equality/order, 64 bytes for ranges, empty for SKIP)
 * @param entryIndex The batch entry the parameter belongs to
 * @param paramIndex The input parameter's position within the entry
 * @param constraintIndex The malformed constraint's position on the parameter
 * @param length The length of the referenceData that was passed
 */
error InvalidConstraintData(uint256 entryIndex, uint256 paramIndex, uint256 constraintIndex, uint256 length);

/**
 * @notice Thrown when OR has no alternatives or contains another OR
 * @param entryIndex The batch entry
 * @param paramIndex The operand
 * @param constraintIndex The outer constraint (and resolved word) index
 */
error InvalidOrConstraint(uint256 entryIndex, uint256 paramIndex, uint256 constraintIndex);

/**
 * @notice Thrown when a range's lower bound exceeds its upper bound
 * @param entryIndex The batch entry
 * @param paramIndex The operand
 * @param constraintIndex The outer constraint (and resolved word) index
 */
error InvalidConstraintRange(uint256 entryIndex, uint256 paramIndex, uint256 constraintIndex);

/**
 * @notice Thrown when resolved data is too short (or a word index is
 *         outside the data) for the requested read
 * @param index The requested word index as given (may be negative for
 *        from-the-end indexing; 0 for first-word reads)
 * @param length The length of the resolved data in bytes
 */
error ReturnDataOutOfBounds(int256 index, uint256 length);

/**
 * @notice Thrown when a word that must hold an address has dirty upper bytes
 * @param index The position of the offending value (parameter index, chain
 *        hop index, or 0 for single-operand uses)
 * @param word The raw 32-byte word that was selected
 */
error InvalidAddressWord(uint256 index, bytes32 word);
