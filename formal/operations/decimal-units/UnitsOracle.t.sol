// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsDecimalUnitsOracleTest {
    Operations private op = new Operations();

    function same(string memory a, string memory b) private pure {
        require(keccak256(bytes(a)) == keccak256(bytes(b)), "units");
    }

    function testUnsignedUnits() public view {
        same(op.formatUnits(uint256(0), 6), "0");
        same(op.formatUnits(uint256(1500000), 6), "1.5");
        same(op.formatUnits(uint256(1000000), 6), "1");
        same(op.formatUnits(uint256(123), 5), "0.00123");
        same(op.formatUnits(uint256(120), 0), "120");
        same(op.formatUnits(uint256(10 ** 77), 77), "1");
        same(
            op.formatUnits(type(uint256).max, 0),
            "115792089237316195423570985008687907853269984665640564039457584007913129639935"
        );
        same(
            op.formatUnits(type(uint256).max, 77),
            "1.15792089237316195423570985008687907853269984665640564039457584007913129639935"
        );
        (bool ok, bytes memory reason) =
            address(op).staticcall(abi.encodeWithSignature("formatUnits(uint256,uint256)", uint256(1), uint256(78)));
        require(
            !ok
                && keccak256(reason)
                    == keccak256(abi.encodeWithSelector(Operations.InvalidPrecision.selector, uint256(78))),
            "precision"
        );
    }

    function testSignedUnits() public view {
        same(op.formatUnits(int256(0), 6), "0");
        same(op.formatUnits(int256(-1500000), 6), "-1.5");
        same(op.formatUnits(int256(-123), 5), "-0.00123");
        same(
            op.formatUnits(type(int256).min, 0),
            "-57896044618658097711785492504343953926634992332820282019728792003956564819968"
        );
        same(
            op.formatUnits(type(int256).max, 77),
            "0.57896044618658097711785492504343953926634992332820282019728792003956564819967"
        );
        (bool ok, bytes memory reason) =
            address(op).staticcall(abi.encodeWithSignature("formatUnits(int256,uint256)", int256(-1), uint256(78)));
        require(
            !ok
                && keccak256(reason)
                    == keccak256(abi.encodeWithSelector(Operations.InvalidPrecision.selector, uint256(78))),
            "precision"
        );
    }
}
