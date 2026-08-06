// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Assertions
 * @author Sembrestels
 * @notice On-chain assertion contract for verifying view function return values and blockchain state
 * @dev Uses staticcall to execute view functions and compares results against expected values.
 *      Each assertion function has an overloaded version that accepts a custom error message.
 *      All functions are view-only and revert with descriptive errors on assertion failure.
 *      This is the frozen CORE: composed expressions (chained reads, arithmetic, logic,
 *      string splitting, hashing) are computed by the separate Combinators contract
 *      and judged here by pointing any call assertion at the Combinators address.
 *      Assertions judge, Combinators compute.
 * @custom:version 1.1
 */
contract Assertions {
    // ============ Custom Errors ============

    /// @notice Thrown when a uint256 assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual value returned
    /// @param expected The expected value
    error AssertionFailedUint(string assertion, uint256 actual, uint256 expected);

    /// @notice Thrown when an address assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual address returned
    /// @param expected The expected address
    error AssertionFailedAddress(string assertion, address actual, address expected);

    /// @notice Thrown when a bool assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual bool returned
    /// @param expected The expected bool
    error AssertionFailedBool(string assertion, bool actual, bool expected);

    /// @notice Thrown when a bytes32 assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual bytes32 returned
    /// @param expected The expected bytes32
    error AssertionFailedBytes32(string assertion, bytes32 actual, bytes32 expected);

    /// @notice Thrown when a staticcall to a target contract fails
    /// @param target The contract address that was called
    /// @param data The calldata that was sent
    error CallFailed(address target, bytes data);

    /// @notice Thrown when raw bytes assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actualHash The keccak256 hash of actual bytes
    /// @param expectedHash The keccak256 hash of expected bytes
    error AssertionFailedBytes(string assertion, bytes32 actualHash, bytes32 expectedHash);

    /// @notice Thrown when approximate equality assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual value
    /// @param expected The expected value
    /// @param delta The actual delta between values
    /// @param maxDelta The maximum allowed delta
    error AssertionFailedApprox(string assertion, uint256 actual, uint256 expected, uint256 delta, uint256 maxDelta);

    /// @notice Thrown when an approximate int256 equality assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual value
    /// @param expected The expected value
    /// @param delta The actual absolute delta between values
    /// @param maxDelta The maximum allowed delta
    error AssertionFailedApproxInt(string assertion, int256 actual, int256 expected, uint256 delta, uint256 maxDelta);

    /// @notice Thrown when an int256 assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual value returned
    /// @param expected The expected value
    error AssertionFailedInt(string assertion, int256 actual, int256 expected);

    /// @notice Thrown when a string assertion fails
    /// @param assertion The assertion type or custom message
    /// @param actual The actual string returned
    /// @param expected The expected string
    error AssertionFailedString(string assertion, string actual, string expected);

    /// @notice Thrown when a tuple index points outside the returned data
    /// @param index The requested element index
    /// @param length The length of the returned data in bytes
    error ReturnDataOutOfBounds(uint256 index, uint256 length);

    // ============ Uint256 Call Assertions ============

    /// @notice Assert that a view call returns a uint256 equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected uint256 value
    function assertEqCallUint(address target, bytes calldata data, uint256 expected) external view {
        _assertEqCallUint(target, data, expected, "EQ");
    }

    /// @notice Assert that a view call returns a uint256 equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected uint256 value
    /// @param message Custom error message on failure
    function assertEqCallUint(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertEqCallUint(target, data, expected, message);
    }

    /// @notice Assert that a view call returns a uint256 not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    function assertNeCallUint(address target, bytes calldata data, uint256 expected) external view {
        _assertNeCallUint(target, data, expected, "NE");
    }

    /// @notice Assert that a view call returns a uint256 not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallUint(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertNeCallUint(target, data, expected, message);
    }

    /// @notice Assert that a view call returns a uint256 greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be greater than
    function assertGtCallUint(address target, bytes calldata data, uint256 expected) external view {
        _assertGtCallUint(target, data, expected, "GT");
    }

    /// @notice Assert that a view call returns a uint256 greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be greater than
    /// @param message Custom error message on failure
    function assertGtCallUint(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertGtCallUint(target, data, expected, message);
    }

    /// @notice Assert that a view call returns a uint256 less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be less than
    function assertLtCallUint(address target, bytes calldata data, uint256 expected) external view {
        _assertLtCallUint(target, data, expected, "LT");
    }

    /// @notice Assert that a view call returns a uint256 less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be less than
    /// @param message Custom error message on failure
    function assertLtCallUint(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertLtCallUint(target, data, expected, message);
    }

    /// @notice Assert that a view call returns a uint256 greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The minimum expected value (inclusive)
    function assertGeCallUint(address target, bytes calldata data, uint256 expected) external view {
        _assertGeCallUint(target, data, expected, "GE");
    }

    /// @notice Assert that a view call returns a uint256 greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The minimum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertGeCallUint(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertGeCallUint(target, data, expected, message);
    }

    /// @notice Assert that a view call returns a uint256 less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The maximum expected value (inclusive)
    function assertLeCallUint(address target, bytes calldata data, uint256 expected) external view {
        _assertLeCallUint(target, data, expected, "LE");
    }

    /// @notice Assert that a view call returns a uint256 less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The maximum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertLeCallUint(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertLeCallUint(target, data, expected, message);
    }

    // ============ Int256 Call Assertions ============

    /// @notice Assert that a view call returns an int256 equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected int256 value
    function assertEqCallInt(address target, bytes calldata data, int256 expected) external view {
        _assertEqCallInt(target, data, expected, "EQ");
    }

    /// @notice Assert that a view call returns an int256 equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected int256 value
    /// @param message Custom error message on failure
    function assertEqCallInt(address target, bytes calldata data, int256 expected, string calldata message) external view {
        _assertEqCallInt(target, data, expected, message);
    }

    /// @notice Assert that a view call returns an int256 not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    function assertNeCallInt(address target, bytes calldata data, int256 expected) external view {
        _assertNeCallInt(target, data, expected, "NE");
    }

    /// @notice Assert that a view call returns an int256 not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallInt(address target, bytes calldata data, int256 expected, string calldata message) external view {
        _assertNeCallInt(target, data, expected, message);
    }

    /// @notice Assert that a view call returns an int256 greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be greater than
    function assertGtCallInt(address target, bytes calldata data, int256 expected) external view {
        _assertGtCallInt(target, data, expected, "GT");
    }

    /// @notice Assert that a view call returns an int256 greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be greater than
    /// @param message Custom error message on failure
    function assertGtCallInt(address target, bytes calldata data, int256 expected, string calldata message) external view {
        _assertGtCallInt(target, data, expected, message);
    }

    /// @notice Assert that a view call returns an int256 less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be less than
    function assertLtCallInt(address target, bytes calldata data, int256 expected) external view {
        _assertLtCallInt(target, data, expected, "LT");
    }

    /// @notice Assert that a view call returns an int256 less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should be less than
    /// @param message Custom error message on failure
    function assertLtCallInt(address target, bytes calldata data, int256 expected, string calldata message) external view {
        _assertLtCallInt(target, data, expected, message);
    }

    /// @notice Assert that a view call returns an int256 greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The minimum expected value (inclusive)
    function assertGeCallInt(address target, bytes calldata data, int256 expected) external view {
        _assertGeCallInt(target, data, expected, "GE");
    }

    /// @notice Assert that a view call returns an int256 greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The minimum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertGeCallInt(address target, bytes calldata data, int256 expected, string calldata message) external view {
        _assertGeCallInt(target, data, expected, message);
    }

    /// @notice Assert that a view call returns an int256 less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The maximum expected value (inclusive)
    function assertLeCallInt(address target, bytes calldata data, int256 expected) external view {
        _assertLeCallInt(target, data, expected, "LE");
    }

    /// @notice Assert that a view call returns an int256 less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The maximum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertLeCallInt(address target, bytes calldata data, int256 expected, string calldata message) external view {
        _assertLeCallInt(target, data, expected, message);
    }

    // ============ Address Call Assertions ============

    /// @notice Assert that a view call returns an address equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected address value
    function assertEqCallAddress(address target, bytes calldata data, address expected) external view {
        _assertEqCallAddress(target, data, expected, "EQ");
    }

    /// @notice Assert that a view call returns an address equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected address value
    /// @param message Custom error message on failure
    function assertEqCallAddress(address target, bytes calldata data, address expected, string calldata message) external view {
        _assertEqCallAddress(target, data, expected, message);
    }

    /// @notice Assert that a view call returns an address not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    function assertNeCallAddress(address target, bytes calldata data, address expected) external view {
        _assertNeCallAddress(target, data, expected, "NE");
    }

    /// @notice Assert that a view call returns an address not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallAddress(address target, bytes calldata data, address expected, string calldata message) external view {
        _assertNeCallAddress(target, data, expected, message);
    }

    // ============ Bool Call Assertions ============

    /// @notice Assert that a view call returns a bool equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected bool value
    function assertEqCallBool(address target, bytes calldata data, bool expected) external view {
        _assertEqCallBool(target, data, expected, "EQ");
    }

    /// @notice Assert that a view call returns a bool equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected bool value
    /// @param message Custom error message on failure
    function assertEqCallBool(address target, bytes calldata data, bool expected, string calldata message) external view {
        _assertEqCallBool(target, data, expected, message);
    }

    /// @notice Assert that a view call returns true
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    function assertTrue(address target, bytes calldata data) external view {
        _assertEqCallBool(target, data, true, "TRUE");
    }

    /// @notice Assert that a view call returns true
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param message Custom error message on failure
    function assertTrue(address target, bytes calldata data, string calldata message) external view {
        _assertEqCallBool(target, data, true, message);
    }

    /// @notice Assert that a view call returns false
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    function assertFalse(address target, bytes calldata data) external view {
        _assertEqCallBool(target, data, false, "FALSE");
    }

    /// @notice Assert that a view call returns false
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param message Custom error message on failure
    function assertFalse(address target, bytes calldata data, string calldata message) external view {
        _assertEqCallBool(target, data, false, message);
    }

    // ============ Bytes32 Call Assertions ============

    /// @notice Assert that a view call returns a bytes32 equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected bytes32 value
    function assertEqCallBytes32(address target, bytes calldata data, bytes32 expected) external view {
        _assertEqCallBytes32(target, data, expected, "EQ");
    }

    /// @notice Assert that a view call returns a bytes32 equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected bytes32 value
    /// @param message Custom error message on failure
    function assertEqCallBytes32(address target, bytes calldata data, bytes32 expected, string calldata message) external view {
        _assertEqCallBytes32(target, data, expected, message);
    }

    /// @notice Assert that a view call returns a bytes32 not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    function assertNeCallBytes32(address target, bytes calldata data, bytes32 expected) external view {
        _assertNeCallBytes32(target, data, expected, "NE");
    }

    /// @notice Assert that a view call returns a bytes32 not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallBytes32(address target, bytes calldata data, bytes32 expected, string calldata message) external view {
        _assertNeCallBytes32(target, data, expected, message);
    }

    // ============ Tuple-Indexed Uint256 Assertions ============

    /// @notice Assert that a specific uint256 element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected uint256 value
    function assertEqCallUintN(address target, bytes calldata data, uint256 index, uint256 expected) external view {
        _assertEqCallUintN(target, data, index, expected, "EQ_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected uint256 value
    /// @param message Custom error message on failure
    function assertEqCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string calldata message) external view {
        _assertEqCallUintN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific uint256 element in a tuple is not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should not equal
    function assertNeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected) external view {
        _assertNeCallUintN(target, data, index, expected, "NE_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple is not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string calldata message) external view {
        _assertNeCallUintN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific uint256 element in a tuple is greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be greater than
    function assertGtCallUintN(address target, bytes calldata data, uint256 index, uint256 expected) external view {
        _assertGtCallUintN(target, data, index, expected, "GT_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple is greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be greater than
    /// @param message Custom error message on failure
    function assertGtCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string calldata message) external view {
        _assertGtCallUintN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific uint256 element in a tuple is less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be less than
    function assertLtCallUintN(address target, bytes calldata data, uint256 index, uint256 expected) external view {
        _assertLtCallUintN(target, data, index, expected, "LT_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple is less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be less than
    /// @param message Custom error message on failure
    function assertLtCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string calldata message) external view {
        _assertLtCallUintN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific uint256 element in a tuple is greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The minimum expected value (inclusive)
    function assertGeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected) external view {
        _assertGeCallUintN(target, data, index, expected, "GE_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple is greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The minimum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertGeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string calldata message) external view {
        _assertGeCallUintN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific uint256 element in a tuple is less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The maximum expected value (inclusive)
    function assertLeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected) external view {
        _assertLeCallUintN(target, data, index, expected, "LE_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple is less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The maximum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertLeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string calldata message) external view {
        _assertLeCallUintN(target, data, index, expected, message);
    }

    // ============ Tuple-Indexed Int256 Assertions ============

    /// @notice Assert that a specific int256 element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected int256 value
    function assertEqCallIntN(address target, bytes calldata data, uint256 index, int256 expected) external view {
        _assertEqCallIntN(target, data, index, expected, "EQ_N");
    }

    /// @notice Assert that a specific int256 element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected int256 value
    /// @param message Custom error message on failure
    function assertEqCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string calldata message) external view {
        _assertEqCallIntN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific int256 element in a tuple is not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should not equal
    function assertNeCallIntN(address target, bytes calldata data, uint256 index, int256 expected) external view {
        _assertNeCallIntN(target, data, index, expected, "NE_N");
    }

    /// @notice Assert that a specific int256 element in a tuple is not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string calldata message) external view {
        _assertNeCallIntN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific int256 element in a tuple is greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be greater than
    function assertGtCallIntN(address target, bytes calldata data, uint256 index, int256 expected) external view {
        _assertGtCallIntN(target, data, index, expected, "GT_N");
    }

    /// @notice Assert that a specific int256 element in a tuple is greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be greater than
    /// @param message Custom error message on failure
    function assertGtCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string calldata message) external view {
        _assertGtCallIntN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific int256 element in a tuple is less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be less than
    function assertLtCallIntN(address target, bytes calldata data, uint256 index, int256 expected) external view {
        _assertLtCallIntN(target, data, index, expected, "LT_N");
    }

    /// @notice Assert that a specific int256 element in a tuple is less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should be less than
    /// @param message Custom error message on failure
    function assertLtCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string calldata message) external view {
        _assertLtCallIntN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific int256 element in a tuple is greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The minimum expected value (inclusive)
    function assertGeCallIntN(address target, bytes calldata data, uint256 index, int256 expected) external view {
        _assertGeCallIntN(target, data, index, expected, "GE_N");
    }

    /// @notice Assert that a specific int256 element in a tuple is greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The minimum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertGeCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string calldata message) external view {
        _assertGeCallIntN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific int256 element in a tuple is less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The maximum expected value (inclusive)
    function assertLeCallIntN(address target, bytes calldata data, uint256 index, int256 expected) external view {
        _assertLeCallIntN(target, data, index, expected, "LE_N");
    }

    /// @notice Assert that a specific int256 element in a tuple is less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The maximum expected value (inclusive)
    /// @param message Custom error message on failure
    function assertLeCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string calldata message) external view {
        _assertLeCallIntN(target, data, index, expected, message);
    }

    // ============ Tuple-Indexed Address Assertions ============

    /// @notice Assert that a specific address element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected address value
    function assertEqCallAddressN(address target, bytes calldata data, uint256 index, address expected) external view {
        _assertEqCallAddressN(target, data, index, expected, "EQ_N");
    }

    /// @notice Assert that a specific address element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected address value
    /// @param message Custom error message on failure
    function assertEqCallAddressN(address target, bytes calldata data, uint256 index, address expected, string calldata message) external view {
        _assertEqCallAddressN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific address element in a tuple is not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should not equal
    function assertNeCallAddressN(address target, bytes calldata data, uint256 index, address expected) external view {
        _assertNeCallAddressN(target, data, index, expected, "NE_N");
    }

    /// @notice Assert that a specific address element in a tuple is not equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallAddressN(address target, bytes calldata data, uint256 index, address expected, string calldata message) external view {
        _assertNeCallAddressN(target, data, index, expected, message);
    }

    // ============ Tuple-Indexed Bool Assertions ============

    /// @notice Assert that a specific bool element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected bool value
    function assertEqCallBoolN(address target, bytes calldata data, uint256 index, bool expected) external view {
        _assertEqCallBoolN(target, data, index, expected, "EQ_N");
    }

    /// @notice Assert that a specific bool element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected bool value
    /// @param message Custom error message on failure
    function assertEqCallBoolN(address target, bytes calldata data, uint256 index, bool expected, string calldata message) external view {
        _assertEqCallBoolN(target, data, index, expected, message);
    }

    // ============ Tuple-Indexed Bytes32 Assertions ============

    /// @notice Assert that a specific bytes32 element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected bytes32 value
    function assertEqCallBytes32N(address target, bytes calldata data, uint256 index, bytes32 expected) external view {
        _assertEqCallBytes32N(target, data, index, expected, "EQ_N");
    }

    /// @notice Assert that a specific bytes32 element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected bytes32 value
    /// @param message Custom error message on failure
    function assertEqCallBytes32N(address target, bytes calldata data, uint256 index, bytes32 expected, string calldata message) external view {
        _assertEqCallBytes32N(target, data, index, expected, message);
    }

    /// @notice Assert that a specific bytes32 element in a tuple return value does not equal expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that the element should not equal
    function assertNeCallBytes32N(address target, bytes calldata data, uint256 index, bytes32 expected) external view {
        _assertNeCallBytes32N(target, data, index, expected, "NE_N");
    }

    /// @notice Assert that a specific bytes32 element in a tuple return value does not equal expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that the element should not equal
    /// @param message Custom error message on failure
    function assertNeCallBytes32N(address target, bytes calldata data, uint256 index, bytes32 expected, string calldata message) external view {
        _assertNeCallBytes32N(target, data, index, expected, message);
    }

    // ============ Tuple-Indexed String Assertions ============

    /// @notice Assert that a specific string element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected string value
    function assertEqCallStringN(address target, bytes calldata data, uint256 index, string calldata expected) external view {
        _assertEqCallStringN(target, data, index, expected, "EQ_N");
    }

    /// @notice Assert that a specific string element in a tuple return value equals expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected string value
    /// @param message Custom error message on failure
    function assertEqCallStringN(address target, bytes calldata data, uint256 index, string calldata expected, string calldata message) external view {
        _assertEqCallStringN(target, data, index, expected, message);
    }

    /// @notice Assert that a specific string element in a tuple return value does not equal expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that the element should not equal
    function assertNeCallStringN(address target, bytes calldata data, uint256 index, string calldata expected) external view {
        _assertNeCallStringN(target, data, index, expected, "NE_N");
    }

    /// @notice Assert that a specific string element in a tuple return value does not equal expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The value that the element should not equal
    /// @param message Custom error message on failure
    function assertNeCallStringN(address target, bytes calldata data, uint256 index, string calldata expected, string calldata message) external view {
        _assertNeCallStringN(target, data, index, expected, message);
    }

    // ============ Raw Bytes Comparison ============

    /// @notice Assert that the raw return bytes of a call match expected bytes exactly
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected raw return bytes (ABI-encoded)
    function assertEqCallBytes(address target, bytes calldata data, bytes calldata expected) external view {
        _assertEqCallBytes(target, data, expected, "EQ_BYTES");
    }

    /// @notice Assert that the raw return bytes of a call match expected bytes exactly
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected raw return bytes (ABI-encoded)
    /// @param message Custom error message on failure
    function assertEqCallBytes(address target, bytes calldata data, bytes calldata expected, string calldata message) external view {
        _assertEqCallBytes(target, data, expected, message);
    }

    /// @notice Assert that the raw return bytes of a call do not match expected bytes
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The raw return bytes that actual should not equal (ABI-encoded)
    function assertNeCallBytes(address target, bytes calldata data, bytes calldata expected) external view {
        _assertNeCallBytes(target, data, expected, "NE_BYTES");
    }

    /// @notice Assert that the raw return bytes of a call do not match expected bytes
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The raw return bytes that actual should not equal (ABI-encoded)
    /// @param message Custom error message on failure
    function assertNeCallBytes(address target, bytes calldata data, bytes calldata expected, string calldata message) external view {
        _assertNeCallBytes(target, data, expected, message);
    }

    // ============ Array Length Assertions ============

    /// @notice Assert that a call returning a dynamic array has exactly the expected length
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected array length
    /// @dev Works with functions returning dynamic arrays like uint256[], address[], etc.
    function assertEqCallArrayLength(address target, bytes calldata data, uint256 expected) external view {
        _assertEqCallArrayLength(target, data, expected, "EQ_LEN");
    }

    /// @notice Assert that a call returning a dynamic array has exactly the expected length
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected array length
    /// @param message Custom error message on failure
    function assertEqCallArrayLength(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertEqCallArrayLength(target, data, expected, message);
    }

    /// @notice Assert that a call returning a dynamic array does not have the given length
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The array length that actual should not equal
    /// @dev Works with functions returning dynamic arrays like uint256[], address[], etc.
    function assertNeCallArrayLength(address target, bytes calldata data, uint256 expected) external view {
        _assertNeCallArrayLength(target, data, expected, "NE_LEN");
    }

    /// @notice Assert that a call returning a dynamic array does not have the given length
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The array length that actual should not equal
    /// @param message Custom error message on failure
    function assertNeCallArrayLength(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertNeCallArrayLength(target, data, expected, message);
    }

    /// @notice Assert that a call returning a dynamic array has length greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that array length should be greater than
    function assertGtCallArrayLength(address target, bytes calldata data, uint256 expected) external view {
        _assertGtCallArrayLength(target, data, expected, "GT_LEN");
    }

    /// @notice Assert that a call returning a dynamic array has length greater than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that array length should be greater than
    /// @param message Custom error message on failure
    function assertGtCallArrayLength(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertGtCallArrayLength(target, data, expected, message);
    }

    /// @notice Assert that a call returning a dynamic array has length greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The minimum array length (inclusive)
    function assertGeCallArrayLength(address target, bytes calldata data, uint256 expected) external view {
        _assertGeCallArrayLength(target, data, expected, "GE_LEN");
    }

    /// @notice Assert that a call returning a dynamic array has length greater than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The minimum array length (inclusive)
    /// @param message Custom error message on failure
    function assertGeCallArrayLength(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertGeCallArrayLength(target, data, expected, message);
    }

    /// @notice Assert that a call returning a dynamic array has length less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that array length should be less than
    function assertLtCallArrayLength(address target, bytes calldata data, uint256 expected) external view {
        _assertLtCallArrayLength(target, data, expected, "LT_LEN");
    }

    /// @notice Assert that a call returning a dynamic array has length less than expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The value that array length should be less than
    /// @param message Custom error message on failure
    function assertLtCallArrayLength(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertLtCallArrayLength(target, data, expected, message);
    }

    /// @notice Assert that a call returning a dynamic array has length less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The maximum array length (inclusive)
    function assertLeCallArrayLength(address target, bytes calldata data, uint256 expected) external view {
        _assertLeCallArrayLength(target, data, expected, "LE_LEN");
    }

    /// @notice Assert that a call returning a dynamic array has length less than or equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The maximum array length (inclusive)
    /// @param message Custom error message on failure
    function assertLeCallArrayLength(address target, bytes calldata data, uint256 expected, string calldata message) external view {
        _assertLeCallArrayLength(target, data, expected, message);
    }

    // ============ Approximate Equality Assertions ============

    /// @notice Assert that a view call returns a uint256 approximately equal to expected (absolute tolerance)
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected uint256 value
    /// @param maxDelta The maximum allowed absolute difference
    function assertApproxEqCallUint(address target, bytes calldata data, uint256 expected, uint256 maxDelta) external view {
        _assertApproxEqCallUint(target, data, expected, maxDelta, "APPROX_EQ");
    }

    /// @notice Assert that a view call returns a uint256 approximately equal to expected (absolute tolerance)
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected uint256 value
    /// @param maxDelta The maximum allowed absolute difference
    /// @param message Custom error message on failure
    function assertApproxEqCallUint(address target, bytes calldata data, uint256 expected, uint256 maxDelta, string calldata message) external view {
        _assertApproxEqCallUint(target, data, expected, maxDelta, message);
    }

    /// @notice Assert that a specific uint256 element in a tuple is approximately equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected uint256 value
    /// @param maxDelta The maximum allowed absolute difference
    function assertApproxEqCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, uint256 maxDelta) external view {
        _assertApproxEqCallUintN(target, data, index, expected, maxDelta, "APPROX_EQ_N");
    }

    /// @notice Assert that a specific uint256 element in a tuple is approximately equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected uint256 value
    /// @param maxDelta The maximum allowed absolute difference
    /// @param message Custom error message on failure
    function assertApproxEqCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, uint256 maxDelta, string calldata message) external view {
        _assertApproxEqCallUintN(target, data, index, expected, maxDelta, message);
    }

    /// @notice Assert that a view call returns an int256 approximately equal to expected (absolute tolerance)
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected int256 value
    /// @param maxDelta The maximum allowed absolute difference
    function assertApproxEqCallInt(address target, bytes calldata data, int256 expected, uint256 maxDelta) external view {
        _assertApproxEqCallInt(target, data, expected, maxDelta, "APPROX_EQ");
    }

    /// @notice Assert that a view call returns an int256 approximately equal to expected (absolute tolerance)
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param expected The expected int256 value
    /// @param maxDelta The maximum allowed absolute difference
    /// @param message Custom error message on failure
    function assertApproxEqCallInt(address target, bytes calldata data, int256 expected, uint256 maxDelta, string calldata message) external view {
        _assertApproxEqCallInt(target, data, expected, maxDelta, message);
    }

    /// @notice Assert that a specific int256 element in a tuple is approximately equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected int256 value
    /// @param maxDelta The maximum allowed absolute difference
    function assertApproxEqCallIntN(address target, bytes calldata data, uint256 index, int256 expected, uint256 maxDelta) external view {
        _assertApproxEqCallIntN(target, data, index, expected, maxDelta, "APPROX_EQ_N");
    }

    /// @notice Assert that a specific int256 element in a tuple is approximately equal to expected
    /// @param target The contract address to call
    /// @param data The encoded function call data (use abi.encodeCall)
    /// @param index The 0-based index of the element in the return tuple
    /// @param expected The expected int256 value
    /// @param maxDelta The maximum allowed absolute difference
    /// @param message Custom error message on failure
    function assertApproxEqCallIntN(address target, bytes calldata data, uint256 index, int256 expected, uint256 maxDelta, string calldata message) external view {
        _assertApproxEqCallIntN(target, data, index, expected, maxDelta, message);
    }

    /// @notice Assert that an native balance is approximately equal to expected (absolute tolerance)
    /// @param account The address to check
    /// @param expected The expected native balance in wei
    /// @param maxDelta The maximum allowed absolute difference
    function assertApproxEqBalance(address account, uint256 expected, uint256 maxDelta) external view {
        _assertApproxEqBalance(account, expected, maxDelta, "APPROX_EQ_BAL");
    }

    /// @notice Assert that an native balance is approximately equal to expected (absolute tolerance)
    /// @param account The address to check
    /// @param expected The expected native balance in wei
    /// @param maxDelta The maximum allowed absolute difference
    /// @param message Custom error message on failure
    function assertApproxEqBalance(address account, uint256 expected, uint256 maxDelta, string calldata message) external view {
        _assertApproxEqBalance(account, expected, maxDelta, message);
    }

    // ============ ETH Balance Assertions ============

    /// @notice Assert that an address has native balance equal to expected
    /// @param account The address to check
    /// @param expected The expected native balance in wei
    function assertEqBalance(address account, uint256 expected) external view {
        _assertEqBalance(account, expected, "EQ_BAL");
    }

    /// @notice Assert that an address has native balance equal to expected
    /// @param account The address to check
    /// @param expected The expected native balance in wei
    /// @param message Custom error message on failure
    function assertEqBalance(address account, uint256 expected, string calldata message) external view {
        _assertEqBalance(account, expected, message);
    }

    /// @notice Assert that an address has native balance greater than expected
    /// @param account The address to check
    /// @param expected The value that balance should be greater than
    function assertGtBalance(address account, uint256 expected) external view {
        _assertGtBalance(account, expected, "GT_BAL");
    }

    /// @notice Assert that an address has native balance greater than expected
    /// @param account The address to check
    /// @param expected The value that balance should be greater than
    /// @param message Custom error message on failure
    function assertGtBalance(address account, uint256 expected, string calldata message) external view {
        _assertGtBalance(account, expected, message);
    }

    /// @notice Assert that an address has native balance less than expected
    /// @param account The address to check
    /// @param expected The value that balance should be less than
    function assertLtBalance(address account, uint256 expected) external view {
        _assertLtBalance(account, expected, "LT_BAL");
    }

    /// @notice Assert that an address has native balance less than expected
    /// @param account The address to check
    /// @param expected The value that balance should be less than
    /// @param message Custom error message on failure
    function assertLtBalance(address account, uint256 expected, string calldata message) external view {
        _assertLtBalance(account, expected, message);
    }

    /// @notice Assert that an address has native balance greater than or equal to expected
    /// @param account The address to check
    /// @param expected The minimum expected native balance (inclusive)
    function assertGeBalance(address account, uint256 expected) external view {
        _assertGeBalance(account, expected, "GE_BAL");
    }

    /// @notice Assert that an address has native balance greater than or equal to expected
    /// @param account The address to check
    /// @param expected The minimum expected native balance (inclusive)
    /// @param message Custom error message on failure
    function assertGeBalance(address account, uint256 expected, string calldata message) external view {
        _assertGeBalance(account, expected, message);
    }

    /// @notice Assert that an address has native balance less than or equal to expected
    /// @param account The address to check
    /// @param expected The maximum expected native balance (inclusive)
    function assertLeBalance(address account, uint256 expected) external view {
        _assertLeBalance(account, expected, "LE_BAL");
    }

    /// @notice Assert that an address has native balance less than or equal to expected
    /// @param account The address to check
    /// @param expected The maximum expected native balance (inclusive)
    /// @param message Custom error message on failure
    function assertLeBalance(address account, uint256 expected, string calldata message) external view {
        _assertLeBalance(account, expected, message);
    }

    // ============ Block Number Assertions ============

    /// @notice Assert that current block number equals expected
    /// @param expected The expected block number
    function assertEqBlockNumber(uint256 expected) external view {
        _assertEqBlockNumber(expected, "EQ_BLOCK");
    }

    /// @notice Assert that current block number equals expected
    /// @param expected The expected block number
    /// @param message Custom error message on failure
    function assertEqBlockNumber(uint256 expected, string calldata message) external view {
        _assertEqBlockNumber(expected, message);
    }

    /// @notice Assert that current block number is greater than expected
    /// @param expected The value that block number should be greater than
    function assertGtBlockNumber(uint256 expected) external view {
        _assertGtBlockNumber(expected, "GT_BLOCK");
    }

    /// @notice Assert that current block number is greater than expected
    /// @param expected The value that block number should be greater than
    /// @param message Custom error message on failure
    function assertGtBlockNumber(uint256 expected, string calldata message) external view {
        _assertGtBlockNumber(expected, message);
    }

    /// @notice Assert that current block number is less than expected
    /// @param expected The value that block number should be less than
    function assertLtBlockNumber(uint256 expected) external view {
        _assertLtBlockNumber(expected, "LT_BLOCK");
    }

    /// @notice Assert that current block number is less than expected
    /// @param expected The value that block number should be less than
    /// @param message Custom error message on failure
    function assertLtBlockNumber(uint256 expected, string calldata message) external view {
        _assertLtBlockNumber(expected, message);
    }

    /// @notice Assert that current block number is greater than or equal to expected
    /// @param expected The minimum block number (inclusive)
    function assertGeBlockNumber(uint256 expected) external view {
        _assertGeBlockNumber(expected, "GE_BLOCK");
    }

    /// @notice Assert that current block number is greater than or equal to expected
    /// @param expected The minimum block number (inclusive)
    /// @param message Custom error message on failure
    function assertGeBlockNumber(uint256 expected, string calldata message) external view {
        _assertGeBlockNumber(expected, message);
    }

    /// @notice Assert that current block number is less than or equal to expected
    /// @param expected The maximum block number (inclusive)
    function assertLeBlockNumber(uint256 expected) external view {
        _assertLeBlockNumber(expected, "LE_BLOCK");
    }

    /// @notice Assert that current block number is less than or equal to expected
    /// @param expected The maximum block number (inclusive)
    /// @param message Custom error message on failure
    function assertLeBlockNumber(uint256 expected, string calldata message) external view {
        _assertLeBlockNumber(expected, message);
    }

    // ============ Block Timestamp Assertions ============

    /// @notice Assert that current block timestamp equals expected
    /// @param expected The expected timestamp (unix seconds)
    function assertEqBlockTimestamp(uint256 expected) external view {
        _assertEqBlockTimestamp(expected, "EQ_TIME");
    }

    /// @notice Assert that current block timestamp equals expected
    /// @param expected The expected timestamp (unix seconds)
    /// @param message Custom error message on failure
    function assertEqBlockTimestamp(uint256 expected, string calldata message) external view {
        _assertEqBlockTimestamp(expected, message);
    }

    /// @notice Assert that current block timestamp is greater than expected
    /// @param expected The value that timestamp should be greater than
    function assertGtBlockTimestamp(uint256 expected) external view {
        _assertGtBlockTimestamp(expected, "GT_TIME");
    }

    /// @notice Assert that current block timestamp is greater than expected
    /// @param expected The value that timestamp should be greater than
    /// @param message Custom error message on failure
    function assertGtBlockTimestamp(uint256 expected, string calldata message) external view {
        _assertGtBlockTimestamp(expected, message);
    }

    /// @notice Assert that current block timestamp is less than expected
    /// @param expected The value that timestamp should be less than
    function assertLtBlockTimestamp(uint256 expected) external view {
        _assertLtBlockTimestamp(expected, "LT_TIME");
    }

    /// @notice Assert that current block timestamp is less than expected
    /// @param expected The value that timestamp should be less than
    /// @param message Custom error message on failure
    function assertLtBlockTimestamp(uint256 expected, string calldata message) external view {
        _assertLtBlockTimestamp(expected, message);
    }

    /// @notice Assert that current block timestamp is greater than or equal to expected
    /// @param expected The minimum timestamp (inclusive)
    function assertGeBlockTimestamp(uint256 expected) external view {
        _assertGeBlockTimestamp(expected, "GE_TIME");
    }

    /// @notice Assert that current block timestamp is greater than or equal to expected
    /// @param expected The minimum timestamp (inclusive)
    /// @param message Custom error message on failure
    function assertGeBlockTimestamp(uint256 expected, string calldata message) external view {
        _assertGeBlockTimestamp(expected, message);
    }

    /// @notice Assert that current block timestamp is less than or equal to expected
    /// @param expected The maximum timestamp (inclusive)
    function assertLeBlockTimestamp(uint256 expected) external view {
        _assertLeBlockTimestamp(expected, "LE_TIME");
    }

    /// @notice Assert that current block timestamp is less than or equal to expected
    /// @param expected The maximum timestamp (inclusive)
    /// @param message Custom error message on failure
    function assertLeBlockTimestamp(uint256 expected, string calldata message) external view {
        _assertLeBlockTimestamp(expected, message);
    }

    // ============ Chain ID Assertions ============

    /// @notice Assert that the current chain ID equals expected
    /// @param expected The expected chain ID (e.g., 1 for mainnet)
    function assertEqChainId(uint256 expected) external view {
        _assertEqChainId(expected, "EQ_CHAIN");
    }

    /// @notice Assert that the current chain ID equals expected
    /// @param expected The expected chain ID (e.g., 1 for mainnet)
    /// @param message Custom error message on failure
    function assertEqChainId(uint256 expected, string calldata message) external view {
        _assertEqChainId(expected, message);
    }

    // ============ Contract Existence Assertions ============

    /// @notice Assert that an address has deployed code (is a contract)
    /// @param account The address to check
    function assertHasCode(address account) external view {
        _assertHasCode(account, "HAS_CODE");
    }

    /// @notice Assert that an address has deployed code (is a contract)
    /// @param account The address to check
    /// @param message Custom error message on failure
    function assertHasCode(address account, string calldata message) external view {
        _assertHasCode(account, message);
    }

    /// @notice Assert that an address has no code (is an EOA or undeployed)
    /// @param account The address to check
    function assertNoCode(address account) external view {
        _assertNoCode(account, "NO_CODE");
    }

    /// @notice Assert that an address has no code (is an EOA or undeployed)
    /// @param account The address to check
    /// @param message Custom error message on failure
    function assertNoCode(address account, string calldata message) external view {
        _assertNoCode(account, message);
    }

    /// @notice Assert that an address has a specific code hash (verify exact bytecode)
    /// @param account The address to check
    /// @param expected The expected keccak256 hash of the deployed bytecode
    function assertEqCodeHash(address account, bytes32 expected) external view {
        _assertEqCodeHash(account, expected, "EQ_CODEHASH");
    }

    /// @notice Assert that an address has a specific code hash (verify exact bytecode)
    /// @param account The address to check
    /// @param expected The expected keccak256 hash of the deployed bytecode
    /// @param message Custom error message on failure
    function assertEqCodeHash(address account, bytes32 expected, string calldata message) external view {
        _assertEqCodeHash(account, expected, message);
    }

    // ============ Internal Helpers ============

    /// @dev Executes a staticcall and returns the raw result bytes.
    ///      Reverts with CallFailed when the target has no code, since a staticcall
    ///      to a code-less address succeeds with empty returndata and would otherwise
    ///      surface as an opaque ABI decoding error.
    function _call(address target, bytes calldata data) internal view returns (bytes memory) {
        if (target.code.length == 0) revert CallFailed(target, data);
        (bool success, bytes memory result) = target.staticcall(data);
        if (!success) revert CallFailed(target, data);
        return result;
    }

    // ============ Internal Uint256 Call Assertions ============

    function _assertEqCallUint(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertNeCallUint(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        if (actual == expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGtCallUint(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        if (actual <= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLtCallUint(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        if (actual >= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGeCallUint(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        if (actual < expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLeCallUint(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        if (actual > expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Int256 Call Assertions ============

    function _assertEqCallInt(address target, bytes calldata data, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        if (actual != expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertNeCallInt(address target, bytes calldata data, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        if (actual == expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertGtCallInt(address target, bytes calldata data, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        if (actual <= expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertLtCallInt(address target, bytes calldata data, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        if (actual >= expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertGeCallInt(address target, bytes calldata data, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        if (actual < expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertLeCallInt(address target, bytes calldata data, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        if (actual > expected) revert AssertionFailedInt(message, actual, expected);
    }

    // ============ Internal Address Call Assertions ============

    function _assertEqCallAddress(address target, bytes calldata data, address expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        address actual = abi.decode(result, (address));
        if (actual != expected) revert AssertionFailedAddress(message, actual, expected);
    }

    function _assertNeCallAddress(address target, bytes calldata data, address expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        address actual = abi.decode(result, (address));
        if (actual == expected) revert AssertionFailedAddress(message, actual, expected);
    }

    // ============ Internal Bool Call Assertions ============

    function _assertEqCallBool(address target, bytes calldata data, bool expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bool actual = abi.decode(result, (bool));
        if (actual != expected) revert AssertionFailedBool(message, actual, expected);
    }

    // ============ Internal Bytes32 Call Assertions ============

    function _assertEqCallBytes32(address target, bytes calldata data, bytes32 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bytes32 actual = abi.decode(result, (bytes32));
        if (actual != expected) revert AssertionFailedBytes32(message, actual, expected);
    }

    function _assertNeCallBytes32(address target, bytes calldata data, bytes32 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bytes32 actual = abi.decode(result, (bytes32));
        if (actual == expected) revert AssertionFailedBytes32(message, actual, expected);
    }

    // ============ Internal Tuple-Indexed Helpers ============

    /// @dev Reverts when `index` points past the head words of the returned data
    function _checkBounds(bytes memory result, uint256 index) internal pure {
        if (index >= result.length / 32) revert ReturnDataOutOfBounds(index, result.length);
    }

    /// @dev Extracts a uint256 at a specific index from ABI-encoded return data
    function _getUintN(bytes memory result, uint256 index) internal pure returns (uint256 value) {
        _checkBounds(result, index);
        assembly {
            value := mload(add(add(result, 32), mul(index, 32)))
        }
    }

    /// @dev Extracts an address at a specific index from ABI-encoded return data
    function _getAddressN(bytes memory result, uint256 index) internal pure returns (address value) {
        _checkBounds(result, index);
        assembly {
            value := mload(add(add(result, 32), mul(index, 32)))
        }
    }

    /// @dev Extracts a bool at a specific index from ABI-encoded return data
    function _getBoolN(bytes memory result, uint256 index) internal pure returns (bool value) {
        _checkBounds(result, index);
        assembly {
            value := mload(add(add(result, 32), mul(index, 32)))
        }
    }

    /// @dev Extracts a bytes32 at a specific index from ABI-encoded return data
    function _getBytes32N(bytes memory result, uint256 index) internal pure returns (bytes32 value) {
        _checkBounds(result, index);
        assembly {
            value := mload(add(add(result, 32), mul(index, 32)))
        }
    }

    /// @dev Extracts an int256 at a specific index from ABI-encoded return data
    function _getIntN(bytes memory result, uint256 index) internal pure returns (int256 value) {
        _checkBounds(result, index);
        assembly {
            value := mload(add(add(result, 32), mul(index, 32)))
        }
    }

    /// @dev Extracts a string at a specific index from ABI-encoded return data.
    ///      Validates the head offset and string length against the returned data
    ///      and copies into a properly allocated bytes array (padded free-memory
    ///      pointer, no writes past the allocation).
    function _getStringN(bytes memory result, uint256 index) internal pure returns (string memory) {
        _checkBounds(result, index);
        uint256 offset;
        assembly {
            offset := mload(add(add(result, 32), mul(index, 32)))
        }
        if (offset > result.length || result.length - offset < 32) {
            revert ReturnDataOutOfBounds(index, result.length);
        }
        uint256 strLen;
        assembly {
            strLen := mload(add(add(result, 32), offset))
        }
        if (result.length - offset - 32 < strLen) {
            revert ReturnDataOutOfBounds(index, result.length);
        }
        bytes memory strBytes = new bytes(strLen);
        assembly {
            let src := add(add(result, 64), offset)
            let dst := add(strBytes, 32)
            for { let i := 0 } lt(i, strLen) { i := add(i, 32) } {
                mstore(add(dst, i), mload(add(src, i)))
            }
            // Zero the padding of the final partial word so no dirty bytes remain
            let rem := mod(strLen, 32)
            if rem {
                let last := add(dst, sub(strLen, rem))
                mstore(last, and(mload(last), not(shr(mul(rem, 8), not(0)))))
            }
        }
        return string(strBytes);
    }

    /// @dev Gets the length of a dynamic array from ABI-encoded return data
    function _getArrayLength(bytes memory result) internal pure returns (uint256 length) {
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        uint256 offset;
        assembly {
            // First word is the offset to array data (always 32 for single array return)
            offset := mload(add(result, 32))
        }
        if (offset > result.length || result.length - offset < 32) {
            revert ReturnDataOutOfBounds(0, result.length);
        }
        assembly {
            // Length is at the offset position
            length := mload(add(add(result, 32), offset))
        }
    }

    // ============ Internal Tuple-Indexed Uint256 Assertions ============

    function _assertEqCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertNeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        if (actual == expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGtCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        if (actual <= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLtCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        if (actual >= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        if (actual < expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLeCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        if (actual > expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Tuple-Indexed Int256 Assertions ============

    function _assertEqCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        if (actual != expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertNeCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        if (actual == expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertGtCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        if (actual <= expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertLtCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        if (actual >= expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertGeCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        if (actual < expected) revert AssertionFailedInt(message, actual, expected);
    }

    function _assertLeCallIntN(address target, bytes calldata data, uint256 index, int256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        if (actual > expected) revert AssertionFailedInt(message, actual, expected);
    }

    // ============ Internal Tuple-Indexed Address Assertions ============

    function _assertEqCallAddressN(address target, bytes calldata data, uint256 index, address expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        address actual = _getAddressN(result, index);
        if (actual != expected) revert AssertionFailedAddress(message, actual, expected);
    }

    function _assertNeCallAddressN(address target, bytes calldata data, uint256 index, address expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        address actual = _getAddressN(result, index);
        if (actual == expected) revert AssertionFailedAddress(message, actual, expected);
    }

    // ============ Internal Tuple-Indexed Bool Assertions ============

    function _assertEqCallBoolN(address target, bytes calldata data, uint256 index, bool expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bool actual = _getBoolN(result, index);
        if (actual != expected) revert AssertionFailedBool(message, actual, expected);
    }

    // ============ Internal Tuple-Indexed Bytes32 Assertions ============

    function _assertEqCallBytes32N(address target, bytes calldata data, uint256 index, bytes32 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bytes32 actual = _getBytes32N(result, index);
        if (actual != expected) revert AssertionFailedBytes32(message, actual, expected);
    }

    function _assertNeCallBytes32N(address target, bytes calldata data, uint256 index, bytes32 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bytes32 actual = _getBytes32N(result, index);
        if (actual == expected) revert AssertionFailedBytes32(message, actual, expected);
    }

    // ============ Internal Tuple-Indexed String Assertions ============

    function _assertEqCallStringN(address target, bytes calldata data, uint256 index, string calldata expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        string memory actual = _getStringN(result, index);
        if (keccak256(bytes(actual)) != keccak256(bytes(expected))) revert AssertionFailedString(message, actual, expected);
    }

    function _assertNeCallStringN(address target, bytes calldata data, uint256 index, string calldata expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        string memory actual = _getStringN(result, index);
        if (keccak256(bytes(actual)) == keccak256(bytes(expected))) revert AssertionFailedString(message, actual, expected);
    }

    // ============ Internal Raw Bytes Assertions ============

    function _assertEqCallBytes(address target, bytes calldata data, bytes calldata expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bytes32 actualHash = keccak256(result);
        bytes32 expectedHash = keccak256(expected);
        if (actualHash != expectedHash) revert AssertionFailedBytes(message, actualHash, expectedHash);
    }

    function _assertNeCallBytes(address target, bytes calldata data, bytes calldata expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        bytes32 actualHash = keccak256(result);
        bytes32 expectedHash = keccak256(expected);
        if (actualHash == expectedHash) revert AssertionFailedBytes(message, actualHash, expectedHash);
    }

    // ============ Internal Array Length Assertions ============

    function _assertEqCallArrayLength(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getArrayLength(result);
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertNeCallArrayLength(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getArrayLength(result);
        if (actual == expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGtCallArrayLength(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getArrayLength(result);
        if (actual <= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGeCallArrayLength(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getArrayLength(result);
        if (actual < expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLtCallArrayLength(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getArrayLength(result);
        if (actual >= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLeCallArrayLength(address target, bytes calldata data, uint256 expected, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getArrayLength(result);
        if (actual > expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Approximate Equality Assertions ============

    function _assertApproxEqCallUint(address target, bytes calldata data, uint256 expected, uint256 maxDelta, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = abi.decode(result, (uint256));
        uint256 delta = actual > expected ? actual - expected : expected - actual;
        if (delta > maxDelta) revert AssertionFailedApprox(message, actual, expected, delta, maxDelta);
    }

    function _assertApproxEqCallUintN(address target, bytes calldata data, uint256 index, uint256 expected, uint256 maxDelta, string memory message) internal view {
        bytes memory result = _call(target, data);
        uint256 actual = _getUintN(result, index);
        uint256 delta = actual > expected ? actual - expected : expected - actual;
        if (delta > maxDelta) revert AssertionFailedApprox(message, actual, expected, delta, maxDelta);
    }

    function _assertApproxEqBalance(address account, uint256 expected, uint256 maxDelta, string memory message) internal view {
        uint256 actual = account.balance;
        uint256 delta = actual > expected ? actual - expected : expected - actual;
        if (delta > maxDelta) revert AssertionFailedApprox(message, actual, expected, delta, maxDelta);
    }

    function _assertApproxEqCallInt(address target, bytes calldata data, int256 expected, uint256 maxDelta, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = abi.decode(result, (int256));
        uint256 delta = _absDelta(actual, expected);
        if (delta > maxDelta) revert AssertionFailedApproxInt(message, actual, expected, delta, maxDelta);
    }

    function _assertApproxEqCallIntN(address target, bytes calldata data, uint256 index, int256 expected, uint256 maxDelta, string memory message) internal view {
        bytes memory result = _call(target, data);
        int256 actual = _getIntN(result, index);
        uint256 delta = _absDelta(actual, expected);
        if (delta > maxDelta) revert AssertionFailedApproxInt(message, actual, expected, delta, maxDelta);
    }

    /// @dev Absolute difference of two int256 values. Wrapping two's-complement
    ///      subtraction of the raw casts stays exact across the full
    ///      type(int256).min..max span, where checked int256 subtraction would
    ///      overflow (the true delta can exceed type(int256).max).
    function _absDelta(int256 a, int256 b) internal pure returns (uint256) {
        unchecked {
            return a > b ? uint256(a) - uint256(b) : uint256(b) - uint256(a);
        }
    }

    // ============ Internal ETH Balance Assertions ============

    function _assertEqBalance(address account, uint256 expected, string memory message) internal view {
        uint256 actual = account.balance;
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGtBalance(address account, uint256 expected, string memory message) internal view {
        uint256 actual = account.balance;
        if (actual <= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLtBalance(address account, uint256 expected, string memory message) internal view {
        uint256 actual = account.balance;
        if (actual >= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGeBalance(address account, uint256 expected, string memory message) internal view {
        uint256 actual = account.balance;
        if (actual < expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLeBalance(address account, uint256 expected, string memory message) internal view {
        uint256 actual = account.balance;
        if (actual > expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Block Number Assertions ============

    function _assertEqBlockNumber(uint256 expected, string memory message) internal view {
        uint256 actual = block.number;
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGtBlockNumber(uint256 expected, string memory message) internal view {
        uint256 actual = block.number;
        if (actual <= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLtBlockNumber(uint256 expected, string memory message) internal view {
        uint256 actual = block.number;
        if (actual >= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGeBlockNumber(uint256 expected, string memory message) internal view {
        uint256 actual = block.number;
        if (actual < expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLeBlockNumber(uint256 expected, string memory message) internal view {
        uint256 actual = block.number;
        if (actual > expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Block Timestamp Assertions ============

    function _assertEqBlockTimestamp(uint256 expected, string memory message) internal view {
        uint256 actual = block.timestamp;
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGtBlockTimestamp(uint256 expected, string memory message) internal view {
        uint256 actual = block.timestamp;
        if (actual <= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLtBlockTimestamp(uint256 expected, string memory message) internal view {
        uint256 actual = block.timestamp;
        if (actual >= expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertGeBlockTimestamp(uint256 expected, string memory message) internal view {
        uint256 actual = block.timestamp;
        if (actual < expected) revert AssertionFailedUint(message, actual, expected);
    }

    function _assertLeBlockTimestamp(uint256 expected, string memory message) internal view {
        uint256 actual = block.timestamp;
        if (actual > expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Chain ID Assertions ============

    function _assertEqChainId(uint256 expected, string memory message) internal view {
        uint256 actual = block.chainid;
        if (actual != expected) revert AssertionFailedUint(message, actual, expected);
    }

    // ============ Internal Contract Existence Assertions ============

    function _assertHasCode(address account, string memory message) internal view {
        uint256 size = account.code.length;
        if (size == 0) revert AssertionFailedUint(message, size, 1);
    }

    function _assertNoCode(address account, string memory message) internal view {
        uint256 size = account.code.length;
        if (size != 0) revert AssertionFailedUint(message, size, 0);
    }

    function _assertEqCodeHash(address account, bytes32 expected, string memory message) internal view {
        bytes32 actual = account.codehash;
        if (actual != expected) revert AssertionFailedBytes32(message, actual, expected);
    }
}
