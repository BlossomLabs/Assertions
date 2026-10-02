// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import {Operations} from "../Operations.sol";
import "../lib/AbiCodec.sol";

/**
 *  @dev Returns the exact calldata it received, as a canonical bytes value
 */
contract CalldataReturner {
    fallback(bytes calldata data) external returns (bytes memory) {
        return abi.encode(data);
    }
}

/**
 * @notice Halmos properties for the Collections callback slots and for split's
 *         composition: constants are validated before any call, a bound value
 *         at every binding, calldata is rebuilt for every application so a
 *         variable-length slot never leaves a stale tail, and split agrees
 *         with its indexOf and slice recipe. Run with `pnpm halmos`.
 */
contract SlotsSplitSymbolicTest is Test {
    Collections collections;
    Operations ops;
    CalldataReturner returner;

    function setUp() public {
        collections = new Collections();
        ops = new Operations();
        returner = new CalldataReturner();
    }

    function callback(string memory arguments, bytes[] memory constants, uint256 first)
        internal
        view
        returns (Collections.Callback memory cb)
    {
        cb.target = address(returner);
        cb.selector = bytes4(0xabcdef01);
        cb.arguments = arguments;
        cb.constants = constants;
        cb.first = first;
    }

    // ============ Slots ============

    /**
     * @dev A constant is validated against its component type before any call,
     *      even over an empty input, and a bound value at its binding against
     *      the slot's type; each names the slot
     */
    function check_constantsAndBindingsAreValidated(bytes32 constant_, uint256 x, bool bindNarrow) public view {
        bytes[] memory constants = new bytes[](2);
        constants[0] = abi.encode(constant_);
        constants[1] = abi.encode(uint256(0));
        bytes[] memory values = new bytes[](bindNarrow ? 1 : 0);
        if (bindNarrow) values[0] = abi.encode(x);
        // bindNarrow: slot 0 (uint8) takes the element, the uint256 slot keeps its constant.
        Collections.Callback memory cb = callback("(uint8,uint256)", constants, bindNarrow ? 0 : 1);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.mapValues, ("uint256", "bytes", values, cb)));
        bytes memory refused = abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0));
        if (!bindNarrow) {
            assertEq(ok, uint256(constant_) <= 255, "a constant slot is not validated up front");
            if (!ok) assertEq(out, refused);
        } else {
            assertEq(ok, x <= 255, "a bound value is not validated against its slot");
            if (!ok) assertEq(out, refused);
        }
    }

    /**
     * @dev Calldata is rebuilt for every application: a string slot bound to
     *      a two-byte and then a forty-byte element (and the reverse) yields
     *      exactly selector ++ abi.encode(element, 7) each time, never a stale
     *      tail from the other
     */
    function check_variableLengthSlotIsRebuilt(bytes32 a, bytes32[2] memory b, bool longFirst) public view {
        bytes memory shortS = abi.encodePacked(a);
        assembly ("memory-safe") { mstore(shortS, 2) }
        bytes memory longS = abi.encodePacked(b);
        assembly ("memory-safe") { mstore(longS, 40) }
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(string(longFirst ? longS : shortS));
        values[1] = abi.encode(string(longFirst ? shortS : longS));
        bytes[] memory constants = new bytes[](2);
        constants[0] = abi.encode("");
        constants[1] = abi.encode(uint256(7));
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.mapValues, ("string", "bytes", values, callback("(string,uint256)", constants, 0))
                )
            );
        assertTrue(ok);
        bytes[] memory results = abi.decode(out, (bytes[]));
        for (uint256 i; i < 2; i++) {
            bytes memory s = i == 0 ? (longFirst ? longS : shortS) : (longFirst ? shortS : longS);
            assertEq(results[i], abi.encode(bytes.concat(bytes4(0xabcdef01), abi.encode(string(s), uint256(7)))));
        }
    }

    // ============ split ============

    /**
     * @dev split over four symbolic bytes and a one-byte delimiter agrees with
     *      its recipe: as many parts as occurrences plus one, the first part
     *      is the slice before indexOf(s, d, 0), the last the slice after
     *      indexOf(s, d, -1)
     */
    function check_splitMatchesItsRecipe(bytes4 raw, bytes1 d) public view {
        bytes memory s = abi.encodePacked(raw);
        bytes memory delimiter = abi.encodePacked(d);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.split, (s, delimiter)));
        assertTrue(ok);
        bytes[] memory parts = abi.decode(out, (bytes[]));
        uint256 count;
        for (uint256 i; i < 4; i++) {
            if (s[i] == d) count++;
        }
        assertEq(parts.length, count + 1, "split's part count");
        uint256 firstAt = ops.indexOf(s, delimiter, 0);
        assertEq(parts[0], ops.slice(s, 0, firstAt), "split's first part");
        if (count > 0) {
            uint256 lastAt = ops.indexOf(s, delimiter, -1);
            assertEq(parts[count], ops.slice(s, lastAt + 1, 3 - lastAt), "split's last part");
        }
    }
}
