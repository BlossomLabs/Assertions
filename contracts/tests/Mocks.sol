// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title MockTarget
/// @notice Helper contract returning known values for testing call-based assertions
contract MockTarget {
    uint256 public storedValue = 42;
    int256 public storedInt = -42;
    address public storedAddress = address(0xBEEF);
    bool public storedBool = true;
    bytes32 public storedBytes32 = keccak256("test");
    string public storedString = "hello";

    function getValue() external view returns (uint256) {
        return storedValue;
    }

    function getInt() external view returns (int256) {
        return storedInt;
    }

    function setInt(int256 _int) external {
        storedInt = _int;
    }

    /// @notice Returns multiple int256 values for tuple-indexed int assertion tests
    function getIntTuple() external view returns (int256, int256) {
        return (storedInt, 7);
    }

    function getAddress() external view returns (address) {
        return storedAddress;
    }

    function getBool() external view returns (bool) {
        return storedBool;
    }

    function getBytes32() external view returns (bytes32) {
        return storedBytes32;
    }

    function getString() external view returns (string memory) {
        return storedString;
    }

    function setValue(uint256 _value) external {
        storedValue = _value;
    }

    function setAddress(address _addr) external {
        storedAddress = _addr;
    }

    function setBool(bool _bool) external {
        storedBool = _bool;
    }

    function setBytes32(bytes32 _b32) external {
        storedBytes32 = _b32;
    }

    function setString(string calldata _str) external {
        storedString = _str;
    }

    /// @notice Returns multiple values for tuple-indexed assertion tests
    function getTuple() external view returns (uint256, address, bool, bytes32) {
        return (storedValue, storedAddress, storedBool, storedBytes32);
    }

    /// @notice Returns tuple with string for string tuple tests
    function getTupleWithString() external view returns (uint256, string memory, address) {
        return (storedValue, storedString, storedAddress);
    }

    /// @notice Returns a dynamic array for array length tests
    function getArray() external pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        arr[4] = 50;
        return arr;
    }

    /// @notice Returns an empty array
    function getEmptyArray() external pure returns (uint256[] memory) {
        return new uint256[](0);
    }

    /// @notice Always reverts for CallFailed tests
    function revertingFunction() external pure {
        revert("MockTarget: intentional revert");
    }

    /// @notice Returns raw bytes for raw bytes comparison tests
    /// @dev Returns a simple uint256 so the raw return matches expected encoding
    function getRawUint() external pure returns (uint256) {
        return 12345;
    }

    address public storedToken;

    /// @notice Returns the mock token address for chained call tests
    function token() external view returns (address) {
        return storedToken;
    }

    /// @notice Multi-value return with the token at word 1, for chaining
    ///         through a selected return word
    function tokenInfo() external view returns (uint256 supply, address tokenAddr, uint256 decimals_) {
        return (1000, storedToken, 18);
    }

    function setToken(address _token) external {
        storedToken = _token;
    }
}

/// @title MockToken
/// @notice ERC20-ish helper contract for chained call assertion tests
contract MockToken {
    string public storedSymbol;
    address public storedUnderlying;

    constructor(address _underlying, string memory _symbol) {
        storedUnderlying = _underlying;
        storedSymbol = _symbol;
    }

    function symbol() external view returns (string memory) {
        return storedSymbol;
    }

    function underlying() external view returns (address) {
        return storedUnderlying;
    }

    function decimals() external pure returns (uint256) {
        return 18;
    }

    function balanceOf(address account) external pure returns (uint256) {
        return account == address(0) ? 0 : 1000;
    }

    function paused() external pure returns (bool) {
        return false;
    }

    function temperature() external pure returns (int256) {
        return -7;
    }

    function symbolHash() external view returns (bytes32) {
        return keccak256(bytes(storedSymbol));
    }

    /// @notice Returns a (min, max) pair for tuple-indexed chained assertions
    function limits() external pure returns (uint256 min, uint256 max) {
        return (1, 1000);
    }

    /// @notice Returns a fixed-size holder list for array-length chained assertions
    function holders() external pure returns (address[] memory list) {
        list = new address[](3);
    }

    /// @notice Multi-value return with a leading dynamic array, for elementCall tests
    function signers() external pure returns (address[] memory list, address owner) {
        list = new address[](3);
        list[0] = address(0xaaa1);
        list[1] = address(0xaaa2);
        list[2] = address(0xaaa3);
        owner = address(0xb055);
    }

    /// @notice Returns the maximum uint256, for arithmetic overflow tests
    function maxUint() external pure returns (uint256) {
        return type(uint256).max;
    }

    /// @notice Always true, for logic truth-table tests (paused() is the false source)
    function active() external pure returns (bool) {
        return true;
    }

    /// @notice Multi-word token name, for splitCall word tests
    function name() external pure returns (string memory) {
        return "Curve LP Token";
    }

    /// @notice Returns an address that has no code deployed
    function eoaPointer() external pure returns (address) {
        return address(0x1234);
    }

    /// @notice Whale-sized balance for decimals-scaling tests (7 * 10^18)
    function whaleBalance() external pure returns (uint256) {
        return 7e18;
    }

    /// @notice Uniswap-style reserves tuple for word-extraction tests
    function getReserves() external pure returns (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast) {
        return (5000e18, 1000e18, 123456);
    }

    /// @notice Returns no data, for malformed intermediate hop tests
    function emptyReturn() external pure {}

    /// @notice Always reverts, for intermediate hop failure tests
    function revertingHop() external pure {
        revert("MockToken: hop revert");
    }
}

/// @title AssertionsTest
/// @notice Comprehensive test suite for the Assertions contract
