// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsDecimalDigitsOracleTest {
    Operations private op = new Operations();

    function _error(bytes memory input, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(op).staticcall(input);
        require(!ok && keccak256(ret) == keccak256(expected));
    }

    function testParseUint() public view {
        require(op.parseUint(bytes("000123")) == 123);
        require(
            op.parseUint(bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935"))
                == type(uint256).max
        );
        _error(
            abi.encodeWithSignature("parseUint(bytes)", bytes("")),
            abi.encodeWithSelector(Operations.EmptyNumber.selector)
        );
        _error(
            abi.encodeWithSignature("parseUint(bytes)", bytes("1a")),
            abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, 1, bytes1("a"))
        );
        _error(
            abi.encodeWithSignature(
                "parseUint(bytes)",
                bytes("115792089237316195423570985008687907853269984665640564039457584007913129639936")
            ),
            abi.encodeWithSignature("Panic(uint256)", uint256(0x11))
        );
    }

    function testParseInt() public view {
        require(op.parseInt(bytes("+000123")) == 123 && op.parseInt(bytes("-000123")) == -123);
        require(
            op.parseInt(bytes("-57896044618658097711785492504343953926634992332820282019728792003956564819968"))
                == type(int256).min
        );
        require(
            op.parseInt(bytes("57896044618658097711785492504343953926634992332820282019728792003956564819967"))
                == type(int256).max
        );
        _error(
            abi.encodeWithSignature("parseInt(bytes)", bytes("+")),
            abi.encodeWithSelector(Operations.EmptyNumber.selector)
        );
        _error(
            abi.encodeWithSignature("parseInt(bytes)", bytes("--1")),
            abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, 1, bytes1("-"))
        );
        _error(
            abi.encodeWithSignature(
                "parseInt(bytes)",
                bytes("57896044618658097711785492504343953926634992332820282019728792003956564819968")
            ),
            abi.encodeWithSignature("Panic(uint256)", uint256(0x11))
        );
    }
}
