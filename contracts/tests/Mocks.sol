// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title MockTarget
 * @notice Helper contract returning known values for testing call-based assertions
 */
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

    /**
     * @notice Returns multiple int256 values for tuple-indexed int assertion tests
     */
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

    /**
     * @notice Returns multiple values for tuple-indexed assertion tests
     */
    function getTuple() external view returns (uint256, address, bool, bytes32) {
        return (storedValue, storedAddress, storedBool, storedBytes32);
    }

    /**
     * @notice Returns tuple with string for string tuple tests
     */
    function getTupleWithString() external view returns (uint256, string memory, address) {
        return (storedValue, storedString, storedAddress);
    }

    /**
     * @notice Returns a dynamic array for array length tests
     */
    function getArray() external pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        arr[4] = 50;
        return arr;
    }

    /**
     * @notice Returns an empty array
     */
    function getEmptyArray() external pure returns (uint256[] memory) {
        return new uint256[](0);
    }

    /**
     * @notice Always reverts for CallFailed tests
     */
    function revertingFunction() external pure {
        revert("MockTarget: intentional revert");
    }

    /**
     * @notice Custom error carrying two words, for revertData tests: the
     *         args are what a lens navigates once the selector is stripped
     */
    error InsufficientBalance(uint256 available, uint256 required);

    /**
     * @notice A no-argument custom error, for selector-only matching
     */
    error Unauthorized();

    /**
     * @notice Always reverts with InsufficientBalance(7, 100)
     */
    function revertsWithArgs() external pure {
        revert InsufficientBalance(7, 100);
    }

    /**
     * @notice Always reverts with Unauthorized()
     */
    function revertsUnauthorized() external pure {
        revert Unauthorized();
    }

    /**
     * @notice Always reverts with NO data at all — the case an expected
     *         selector can never match
     */
    function revertsBare() external pure {
        // solhint-disable-next-line reason-string
        revert();
    }

    /**
     * @notice Error carrying a dynamic array, for lens navigation into a
     *         revert payload: alternates[0] is meant to be read from next
     */
    error Redirect(address hint, address[] alternates);

    /**
     * @notice Always reverts with Redirect(0xBEEF, [this, 0xCAFE]) — the
     *         first alternate is this contract itself, so a probe that
     *         selects it can continue reading from a live address
     */
    function revertsWithRedirect() external view {
        address[] memory alternates = new address[](2);
        alternates[0] = address(this);
        alternates[1] = address(0xCAFE);
        revert Redirect(address(0xBEEF), alternates);
    }

    /**
     * @notice Reverts unless called with exactly 42 — verifies calldata
     *         constructed by the ERC-8211 judge arrives intact
     */
    function checkValue(uint256 v) external pure {
        require(v == 42, "wrong value");
    }

    /**
     * @notice Two-argument variant for multi-CALL_DATA construction tests
     */
    function checkPair(uint256 a, address b) external pure {
        require(a == 42 && b == address(0xBEEF), "wrong pair");
    }

    /**
     * @notice Returns raw bytes for raw bytes comparison tests
     * @dev Returns a simple uint256 so the raw return matches expected encoding
     */
    function getRawUint() external pure returns (uint256) {
        return 12345;
    }

    address public storedToken;

    /**
     * @notice Returns the mock token address for chained call tests
     */
    function token() external view returns (address) {
        return storedToken;
    }

    /**
     * @notice Multi-value return with the token at word 1, for chaining
     *         through a selected return word
     */
    function tokenInfo() external view returns (uint256 supply, address tokenAddr, uint256 decimals_) {
        return (1000, storedToken, 18);
    }

    function setToken(address _token) external {
        storedToken = _token;
    }
}

/**
 * @title MockToken
 * @notice ERC20-ish helper contract for chained call assertion tests
 */
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

    /**
     * @notice Returns a (min, max) pair for tuple-indexed chained assertions
     */
    function limits() external pure returns (uint256 min, uint256 max) {
        return (1, 1000);
    }

    /**
     * @notice Returns a fixed-size holder list for array-length chained assertions
     */
    function holders() external pure returns (address[] memory list) {
        list = new address[](3);
    }

    /**
     * @notice Multi-value return with a leading dynamic array, for navigation tests
     */
    function signers() external pure returns (address[] memory list, address owner) {
        list = new address[](3);
        list[0] = address(0xaaa1);
        list[1] = address(0xaaa2);
        list[2] = address(0xaaa3);
        owner = address(0xb055);
    }

    /**
     * @notice Nested dynamic arrays (ragged, with an empty row), for navigation tests
     */
    function matrix() external pure returns (address[][] memory rows) {
        rows = new address[][](3);
        rows[0] = new address[](2);
        rows[0][0] = address(0xaaa1);
        rows[0][1] = address(0xaaa2);
        rows[1] = new address[](3);
        rows[1][0] = address(0xbbb1);
        rows[1][1] = address(0xbbb2);
        rows[1][2] = address(0xbbb3);
        rows[2] = new address[](0);
    }

    /**
     * @notice An owner word before nested dynamic rows — the
     *         "(address,address[][])" shape used by nav lens tests
     */
    function ownersMatrix() external pure returns (address owner, address[][] memory rows) {
        owner = address(0xb055);
        rows = new address[][](2);
        rows[0] = new address[](1);
        rows[0][0] = address(0xaaa1);
        rows[1] = new address[](2);
        rows[1][0] = address(0xbbb1);
        rows[1][1] = address(0xbbb2);
    }

    struct Proposal {
        address proposer;
        uint256 votes;
        bool executed;
    }

    /**
     * @notice Struct array, for tuple-step navigation tests
     */
    function proposals() external pure returns (Proposal[] memory list) {
        list = new Proposal[](2);
        list[0] = Proposal(address(0xcafe1), 41, false);
        list[1] = Proposal(address(0xcafe2), 99, true);
    }

    /**
     * @notice Multi-word static head value before a dynamic one, for
     *         head-accounting navigation tests
     */
    function mixed() external pure returns (uint256[2] memory pair, address[] memory list) {
        pair = [uint256(11), uint256(22)];
        list = new address[](2);
        list[0] = address(0xddd1);
        list[1] = address(0xddd2);
    }

    struct Item {
        string label;
        uint256 qty;
    }

    /**
     * @notice Struct array with a string field, for navDynCall composition tests
     */
    function items() external pure returns (Item[] memory list) {
        list = new Item[](2);
        list[0] = Item("Curve LP", 7);
        list[1] = Item("Gauge Deposit", 3);
    }

    /**
     * @notice Returns the maximum uint256, for arithmetic overflow tests
     */
    function maxUint() external pure returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @notice Always true, for logic truth-table tests (paused() is the false source)
     */
    function active() external pure returns (bool) {
        return true;
    }

    /**
     * @notice Multi-word token name, for splitCall word tests
     */
    function name() external pure returns (string memory) {
        return "Curve LP Token";
    }

    /**
     * @notice Returns an address that has no code deployed
     */
    function eoaPointer() external pure returns (address) {
        return address(0x1234);
    }

    /**
     * @notice Whale-sized balance for decimals-scaling tests (7 * 10^18)
     */
    function whaleBalance() external pure returns (uint256) {
        return 7e18;
    }

    /**
     * @notice Uniswap-style reserves tuple for word-extraction tests
     */
    function getReserves() external pure returns (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast) {
        return (5000e18, 1000e18, 123456);
    }

    /**
     * @notice Returns no data, for malformed intermediate hop tests
     */
    function emptyReturn() external pure {}

    /**
     * @notice Always reverts, for intermediate hop failure tests
     */
    function revertingHop() external pure {
        revert("MockToken: hop revert");
    }
}
