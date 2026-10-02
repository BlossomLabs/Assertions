// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections, IExpressions} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract WireOracleTest {
    function blob(bytes memory value) private pure returns (bytes memory) {
        bytes memory padded = new bytes((value.length + 31) / 32 * 32);
        for (uint256 i; i < value.length; i++) {
            padded[i] = value[i];
        }
        return bytes.concat(abi.encode(value.length), padded);
    }

    function arrayBody(bytes[] memory values) private pure returns (bytes memory) {
        bytes memory heads;
        bytes memory tails;
        for (uint256 i; i < values.length; i++) {
            heads = bytes.concat(heads, abi.encode(values.length * 32 + tails.length));
            tails = bytes.concat(tails, blob(values[i]));
        }
        return bytes.concat(abi.encode(values.length), heads, tails);
    }

    function expression(bytes memory expr, bytes[] memory values) private pure {
        bytes memory payload = blob(expr);
        bytes memory actual = bytes.concat(
            hex"8f1ea4ef", abi.encode(uint256(64), uint256(64 + payload.length)), payload, arrayBody(values)
        );
        bytes memory expected = abi.encodeCall(IExpressions.evaluateEncoded, (expr, values));
        require(keccak256(actual) == keccak256(expected), "expression ABI mismatch");
    }

    function testEmptyExpressionAndArguments() public pure {
        expression(hex"", new bytes[](0));
    }

    function testMixedExpressionArgumentLengths() public pure {
        bytes[] memory values = new bytes[](4);
        values[0] = hex"";
        values[1] = new bytes(31);
        values[2] = new bytes(32);
        values[3] = new bytes(65);
        values[1][30] = 0xaa;
        values[2][31] = 0xbb;
        values[3][64] = 0xcc;
        expression(hex"aabbcc", values);
    }

    function testLongExpressionAndEmptyValues() public pure {
        bytes[] memory values = new bytes[](3);
        expression(new bytes(257), values);
    }

    function failure(bytes memory data, bytes memory reason) private pure {
        bytes4 operation = 0x12345678;
        uint256 index = type(uint256).max;
        uint256 other = 17;
        address target = address(0x123456);
        bytes memory a = blob(data);
        bytes memory actual = bytes.concat(
            hex"117cf6f6",
            abi.encode(operation, index, other, target, uint256(192), uint256(192 + a.length)),
            a,
            blob(reason)
        );
        bytes memory expected =
            abi.encodeWithSelector(Collections.CallbackFailed.selector, operation, index, other, target, data, reason);
        require(keccak256(actual) == keccak256(expected), "failure ABI mismatch");
    }

    function testCallbackFailureEmptyBytes() public pure {
        failure(hex"", hex"");
    }

    function testCallbackFailureUnequalPaddedLengths() public pure {
        failure(new bytes(33), hex"abcdef");
        failure(hex"01", new bytes(65));
    }

    function testFixedErrorSelectorsAndFields() public pure {
        require(
            keccak256(abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0x123)))
                == keccak256(bytes.concat(hex"54b3288a", abi.encode(address(0x123))))
        );
        require(keccak256(abi.encodeWithSelector(Collections.SubcallOutOfGas.selector)) == keccak256(hex"d271060e"));
        require(
            keccak256(
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    bytes4(0x12345678),
                    uint256(11),
                    uint256(12),
                    address(0x456)
                )
            )
            == keccak256(
                bytes.concat(hex"24448a11", abi.encode(bytes4(0x12345678), uint256(11), uint256(12), address(0x456)))
            )
        );
    }
}
