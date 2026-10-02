// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsFixedPointOracleTest {
    Operations private ops = new Operations();

    function testExpQuantizedKernelAndExactGuards() public view {
        require(ops.expWad(-57896044618658097711785492504343953926634992332820282019728792003956564819968) == 0);
        require(ops.expWad(-42139678854452767551) == 0);
        require(ops.expWad(-42139678854452767550) == 0);
        require(ops.expWad(-1000000000000000000) == 367879441171442321);
        require(ops.expWad(0) == 1000000000000000000);
        require(ops.expWad(1) == 1000000000000000001);
        require(ops.expWad(1000000000000000000) == 2718281828459045235);
        require(ops.expWad(2000000000000000000) == 7389056098930650227);
        require(
            ops.expWad(135305999368893231588)
                == 57896044618658097650144101621524338577433870140581303254786265309376407432913
        );
        checkError("expWad(int256)", 135305999368893231589, abi.encodeWithSignature("Panic(uint256)", uint256(17)));
        checkError(
            "expWad(int256)",
            57896044618658097711785492504343953926634992332820282019728792003956564819967,
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
    }

    function testLnQuantizedKernelAndExactErrors() public view {
        checkError(
            "lnWad(int256)",
            -57896044618658097711785492504343953926634992332820282019728792003956564819968,
            abi.encodeWithSignature(
                "LogarithmUndefined(int256)",
                int256(-57896044618658097711785492504343953926634992332820282019728792003956564819968)
            )
        );
        checkError("lnWad(int256)", -1, abi.encodeWithSignature("LogarithmUndefined(int256)", int256(-1)));
        checkError("lnWad(int256)", 0, abi.encodeWithSignature("LogarithmUndefined(int256)", int256(0)));
        require(ops.lnWad(1) == -41446531673892822313);
        require(ops.lnWad(1000000000) == -20723265836946411157);
        require(ops.lnWad(500000000000000000) == -693147180559945310);
        require(ops.lnWad(1000000000000000000) == 0);
        require(ops.lnWad(2000000000000000000) == 693147180559945309);
        require(
            ops.lnWad(57896044618658097711785492504343953926634992332820282019728792003956564819967)
                == 135305999368893231589
        );
    }

    function checkError(string memory signature, int256 input, bytes memory expected) private view {
        (bool success, bytes memory reason) = address(ops).staticcall(abi.encodeWithSignature(signature, input));
        require(!success && keccak256(reason) == keccak256(expected));
    }
}
