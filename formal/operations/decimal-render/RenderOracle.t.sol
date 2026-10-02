// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsDecimalRenderOracleTest {
    Operations private op = new Operations();

    function same(string memory a, string memory b) private pure {
        require(keccak256(bytes(a)) == keccak256(bytes(b)), "decimal");
    }

    function testUnsignedRendering() public view {
        same(op.toString(uint256(0)), "0");
        same(op.toString(uint256(1)), "1");
        same(op.toString(uint256(10)), "10");
        same(op.toString(uint256(100200)), "100200");
        same(
            op.toString(type(uint256).max),
            "115792089237316195423570985008687907853269984665640564039457584007913129639935"
        );
    }

    function testSignedRendering() public view {
        same(op.toString(int256(0)), "0");
        same(op.toString(int256(-120)), "-120");
        same(op.toString(int256(123)), "123");
        same(
            op.toString(type(int256).min),
            "-57896044618658097711785492504343953926634992332820282019728792003956564819968"
        );
        same(
            op.toString(type(int256).max),
            "57896044618658097711785492504343953926634992332820282019728792003956564819967"
        );
    }
}
