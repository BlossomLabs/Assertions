// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Operations} from "../Operations.sol";
import {AbiCodec} from "../lib/AbiCodec.sol";

contract AbiTrailingOffsetsTest is Test {
    Operations ops;

    struct Pair {
        uint256 number;
        string text;
    }

    function setUp() public {
        ops = new Operations();
    }

    function validate(string calldata descriptor, bytes memory value) external pure {
        AbiCodec.validate(bytes(descriptor), value);
    }

    function checkTrailing(string memory descriptor, bytes memory value) private view {
        (bool valid,) = address(this).staticcall(abi.encodeCall(this.validate, (descriptor, value)));
        assertTrue(valid, "canonical control failed");
        for (uint256 suffix = 1; suffix <= 32; suffix += 31) {
            bytes memory dirty = bytes.concat(value, new bytes(suffix));
            (bool ok, bytes memory error) = address(this).staticcall(abi.encodeCall(this.validate, (descriptor, dirty)));
            assertFalse(ok, "trailing bytes accepted");
            assertEq(error, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, value.length));
        }

        // A whole trailing word passes the component-envelope check and must
        // preserve the component index while naming its first trailing byte.
        bytes[] memory args = new bytes[](2);
        args[0] = abi.encode(uint256(7));
        args[1] = bytes.concat(value, new bytes(32));
        string memory tuple = string.concat("(uint256,", descriptor, ")");
        (bool encoded, bytes memory result) =
            address(ops).staticcall(abi.encodeCall(Operations.encodeBytes, (tuple, args)));
        assertFalse(encoded);
        assertEq(result, abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), value.length));
    }

    function testValidateReportsFirstTrailingByteAcrossDynamicShapes() public view {
        checkTrailing("bytes", abi.encode(bytes("")));
        checkTrailing("bytes", abi.encode(new bytes(33)));
        checkTrailing("string", abi.encode("hello"));
        uint256[] memory numbers = new uint256[](2);
        numbers[0] = 9;
        numbers[1] = 17;
        checkTrailing("uint256[]", abi.encode(numbers));
        string[] memory strings = new string[](2);
        strings[0] = "one";
        strings[1] = "two";
        checkTrailing("string[]", abi.encode(strings));
        checkTrailing("(uint256,string)", abi.encode(Pair(42, "tuple")));
        bytes[2] memory pair = [bytes("a"), bytes("bc")];
        checkTrailing("bytes[2]", abi.encode(pair));
    }
}
