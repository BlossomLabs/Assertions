// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Operators.sol";
import "../CollectionOperators.sol";
import "../AbiCodec.sol";

contract AbiCodecTest is Test {
    Operators ops;
    CollectionOperators collections;

    function setUp() public {
        ops = new Operators();
        collections = new CollectionOperators();
    }

    function assertRejected(bytes memory value, string memory descriptor) private view {
        bytes[] memory args = new bytes[](1);
        args[0] = value;
        (bool rawOK, bytes memory rawError) = address(ops).staticcall(abi.encodeCall(Operators.encode, (descriptor, args)));
        (bool bytesOK, bytes memory bytesError) = address(ops).staticcall(abi.encodeCall(Operators.encodeBytes, (descriptor, args)));
        assertFalse(rawOK);
        assertFalse(bytesOK);
        assertEq(rawError, bytesError);
        assertEq(bytes4(rawError), AbiCodec.InvalidComponentValue.selector);
    }

    function testEncodingRejectsMalformedNestedValues() public view {
        string[] memory strings = new string[](1);
        strings[0] = "hello";
        bytes memory value = abi.encode(strings);
        assertRejected(bytes.concat(value, abi.encode(uint256(0))), "(string[])");
        // Find the nested string's canonical head offset independently.
        bytes memory badOffset = abi.encode(strings);
        uint256 matches;
        for (uint256 p = 32; p < badOffset.length; p += 32) {
            uint256 w;
            assembly { w := mload(add(add(badOffset, 32), p)) }
            if (w == 32) {
                assembly { mstore(add(add(badOffset, 32), p), 0) }
                matches++;
            }
        }
        assertEq(matches, 1);
        assertRejected(badOffset, "(string[])");
        value[value.length - 1] = 0x01;
        assertRejected(value, "(string[])");
    }

    function testEncodingRejectsOverflowingAndTruncatedLengths() public view {
        assertRejected(abi.encode(uint256(32), type(uint256).max), "(bytes)");
        assertRejected(abi.encode(uint256(32), type(uint256).max), "(uint256[])");
        assertRejected(abi.encode(uint256(32), uint256(33), uint256(0)), "(bytes)");
    }

    function testEncodingNamesMalformedComponent() public {
        bytes[] memory args = new bytes[](2);
        args[0] = abi.encode(uint256(7));
        args[1] = abi.encode(uint256(32), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(32)));
        ops.encodeBytes("(uint256,bytes)", args);
    }

    function extremeResult(uint256 mode) external pure returns (bytes memory) {
        if (mode == 0) return "ok";
        assembly {
            mstore(0, 32)
            mstore(32, not(0))
            return(0, 64)
        }
    }

    function testMalformedResultKeepsCallbackContextWithoutSelfCall() public {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(0));
        values[1] = abi.encode(uint256(1));
        CollectionOperators.Callback memory cb = CollectionOperators.Callback(
            address(this), this.extremeResult.selector, "(uint256)", new bytes[](1), 0, 0
        );
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector,
            collections.mapValues.selector, uint256(1), uint256(0), address(this)));
        collections.mapValues("uint256", "bytes", values, cb);
    }

    function testEncodingAcceptsWordBoundaryPayloadsAndNestedFixedArrays() public view {
        for (uint256 n = 31; n <= 33; n++) {
            bytes memory payload = new bytes(n);
            for (uint256 i; i < n; i++) payload[i] = bytes1(uint8(i + 1));
            bytes[2] memory pair = [payload, bytes("")];
            bytes[] memory args = new bytes[](2);
            args[0] = abi.encode(uint256(9));
            args[1] = abi.encode(pair);
            bytes memory expected = abi.encode(uint256(9), pair);
            assertEq(ops.encodeBytes("(uint256,bytes[2])", args), expected);
            (bool ok, bytes memory raw) = address(ops).staticcall(abi.encodeCall(Operators.encode, ("(uint256,bytes[2])", args)));
            assertTrue(ok);
            assertEq(raw, expected);
        }
    }
}
