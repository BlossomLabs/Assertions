// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsUtf8OracleTest {
    Operations private op = new Operations();

    function same(bytes memory a, bytes memory b) private pure {
        require(keccak256(a) == keccak256(b), "bytes");
    }

    function badSlice(bytes memory value, uint256 position) private view {
        (bool ok, bytes memory result) = address(op)
            .staticcall(
                abi.encodeWithSignature("stringSlice(bytes,int256,int256)", value, int256(0), int256(value.length))
            );
        require(
            !ok && keccak256(result) == keccak256(abi.encodeWithSelector(Operations.InvalidUtf8.selector, position)),
            "utf8"
        );
    }

    function testStringSlice() public view {
        same(op.stringSlice(bytes("abc"), 0, 3), bytes("abc"));
        same(op.stringSlice(hex"41c2a2e282acf48fbfbf42", 1, -1), hex"c2a2e282acf48fbfbf");
        same(op.stringSlice(hex"e282ac", 1, 1), hex"");
        same(op.stringSlice(bytes("abc"), type(int256).min, type(int256).max), bytes("abc"));
        badSlice(hex"c080", 0);
        badSlice(hex"e08080", 1);
        badSlice(hex"eda080", 1);
        badSlice(hex"f0808080", 1);
        badSlice(hex"f4908080", 1);
        badSlice(hex"f5808080", 0);
        badSlice(hex"f09f", 0);
        badSlice(hex"41e28220", 3);
        badSlice(hex"80", 0);
        (bool ok, bytes memory result) = address(op)
            .staticcall(abi.encodeWithSignature("stringSlice(bytes,int256,int256)", hex"e282ac", int256(1), int256(3)));
        require(
            !ok && keccak256(result) == keccak256(abi.encodeWithSelector(Operations.InvalidUtf8.selector, uint256(1))),
            "cut"
        );
    }

    function testStringAt() public view {
        same(op.stringAt(bytes("abc"), -1), bytes("c"));
        same(op.stringAt(hex"e282ac42", -1), bytes("B"));
        (bool ok, bytes memory result) =
            address(op).staticcall(abi.encodeWithSignature("stringAt(bytes,int256)", hex"e282ac", int256(1)));
        require(
            !ok && keccak256(result) == keccak256(abi.encodeWithSelector(Operations.InvalidUtf8.selector, uint256(1))),
            "multibyte"
        );
        (ok, result) =
            address(op).staticcall(abi.encodeWithSignature("stringAt(bytes,int256)", bytes("a"), type(int256).min));
        require(
            !ok
                && keccak256(result)
                    == keccak256(
                        abi.encodeWithSelector(Operations.InvalidByteIndex.selector, type(int256).min, uint256(1))
                    ),
            "index"
        );
        (ok, result) =
            address(op).staticcall(abi.encodeWithSignature("stringAt(bytes,int256)", hex"80", type(int256).max));
        require(
            !ok && keccak256(result) == keccak256(abi.encodeWithSelector(Operations.InvalidUtf8.selector, uint256(0))),
            "validation-order"
        );
    }
}
