// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Collections} from "../Collections.sol";
import {AbiCodec} from "../lib/AbiCodec.sol";

contract AbiWordBoundariesTest is Test {
    Collections collections;

    function setUp() public {
        collections = new Collections();
    }

    function request(uint256 word) private pure returns (bytes memory data, uint256 padding) {
        data = abi.encodeCall(Collections.unpackArray, ("bytes3", abi.encode(uint256(32), uint256(1), word)));
        bytes memory name = bytes("bytes3");
        // Locate the descriptor sentinel independently of the encoder's offsets.
        for (uint256 i = 4; i + name.length < data.length; ++i) {
            bool found = true;
            for (uint256 j; j < name.length; ++j) {
                if (data[i + j] != name[j]) found = false;
            }
            if (found) return (data, i + name.length);
        }
        assert(false);
    }

    function testBytes3RejectsDirtyWordWithEveryDescriptorPaddingByte() public view {
        (bytes memory data, uint256 padding) = request(1);
        bytes memory expected = abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64));
        for (uint256 i; i < 256; ++i) {
            // ASCII '2' makes the seven-byte load look like "bytes32", despite
            // the descriptor's declared length still being six. Solidity's
            // external ABI decoder permits this nonzero calldata padding.
            data[padding] = bytes1(uint8(i));
            (bool ok, bytes memory result) = address(collections).staticcall(data);
            assertFalse(ok, "descriptor lookahead disabled the narrow-word rule");
            assertEq(result, expected, "wrong rejection offset or error");
        }
    }

    /**
     * @dev A descriptor one byte short of a name the parser recognises as a
     *      word ("bool", "bytes", "string", "uint256", "address"), followed
     *      by every possible padding byte, including the one that would
     *      complete the name. The name ends where the descriptor ends, so the
     *      type stays the unknown one-word type it is and the value comes
     *      back unchanged.
     */
    function testNamesOneByteShortOfAFastPathIgnoreDescriptorPadding() public view {
        string[5] memory names = ["boo", "byte", "strin", "uint25", "addres"];
        uint256 word = uint256(keccak256("any word"));
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(word);
        bytes memory expected = abi.encode(values);
        for (uint256 k; k < names.length; ++k) {
            bytes memory name = bytes(names[k]);
            bytes memory data =
                abi.encodeCall(Collections.unpackArray, (names[k], abi.encode(uint256(32), uint256(1), word)));
            // Locate the descriptor independently of the encoder's offsets.
            uint256 padding;
            for (uint256 i = 4; i + name.length < data.length && padding == 0; ++i) {
                bool found = true;
                for (uint256 j; j < name.length; ++j) {
                    if (data[i + j] != name[j]) found = false;
                }
                if (found) padding = i + name.length;
            }
            assertTrue(padding != 0, "descriptor not found");
            for (uint256 i; i < 256; ++i) {
                data[padding] = bytes1(uint8(i));
                (bool ok, bytes memory result) = address(collections).staticcall(data);
                assertTrue(ok, string.concat(names[k], ": padding byte changed the outcome"));
                assertEq(result, expected, string.concat(names[k], ": padding byte changed the value"));
            }
        }
    }

    function testBytes3AcceptsCanonicalWordWithEveryDescriptorPaddingByte() public view {
        uint256 word = uint256(0x123456) << 232;
        (bytes memory data, uint256 padding) = request(word);
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(word);
        bytes memory expected = abi.encode(values);
        for (uint256 i; i < 256; ++i) {
            data[padding] = bytes1(uint8(i));
            (bool ok, bytes memory result) = address(collections).staticcall(data);
            assertTrue(ok, "canonical bytes3 rejected");
            assertEq(result, expected, "canonical value changed");
        }
    }
}
