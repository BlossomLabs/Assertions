// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";
import "../ERC8211.sol";

contract OperationsExtensionIntegrationTest is Test {
    Assertions core;
    Operations ops;

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
    }

    function literal(bytes memory value) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, value, new Constraint[](0));
    }

    function call(address target, bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(target, data), new Constraint[](0));
    }

    function evaluate(bytes memory data) private view returns (bytes memory result) {
        bool ok;
        (ok, result) = address(core).staticcall(data);
        assertTrue(ok);
    }

    function testRoundedReadWithLazyFallback() public view {
        InputParam[] memory args = new InputParam[](4);
        args[0] = literal(abi.encode(int256(-7)));
        args[1] = literal(abi.encode(int256(1)));
        args[2] = literal(abi.encode(int256(3)));
        args[3] = literal(abi.encode(Operations.Rounding.Floor));
        bytes memory read = abi.encodeCall(Assertions.read, (
            literal(abi.encode(address(ops))), bytes4(keccak256("mulDiv(int256,int256,int256,uint8)")), args));
        assertEq(abi.decode(evaluate(read), (int256)), -3);
        InputParam memory success = call(address(core), read);
        InputParam memory bomb = call(address(ops), abi.encodeWithSignature("div(uint256,uint256)", 1, 0));
        assertEq(abi.decode(evaluate(abi.encodeCall(Assertions.cond,
            (literal(abi.encode(true)), success, bomb))), (int256)), -3);
        assertEq(abi.decode(evaluate(abi.encodeCall(Assertions.orElse, (bomb, success))), (int256)), -3);
    }

    function testNavigateWholeSplitResult() public view {
        InputParam memory parts = call(address(ops), abi.encodeCall(Operations.split, (bytes("a::longer::"), bytes("::"))));
        int256[] memory path = new int256[](2);
        path[0] = 0;
        path[1] = 1;
        assertEq(abi.decode(evaluate(abi.encodeCall(Assertions.nav, (parts, "(bytes[])", path))), (bytes)), bytes("longer"));
    }
}
