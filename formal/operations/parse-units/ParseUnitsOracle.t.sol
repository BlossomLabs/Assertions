// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsParseUnitsOracleTest {
    Operations private op = new Operations();

    function failure(
        string memory signature,
        bytes memory value,
        uint256 decimals,
        Operations.Rounding rounding,
        bytes memory expected
    ) private view {
        (bool ok, bytes memory result) = address(op)
            .staticcall(abi.encodeWithSignature(signature, value, decimals, rounding));
        require(!ok && keccak256(result) == keccak256(expected), "error");
    }

    function testUnsignedUnitParsing() public view {
        require(op.parseUnitsUnsigned(bytes("1.5"), 6, Operations.Rounding.Trunc) == 1500000, "scale");
        require(op.parseUnitsUnsigned(bytes("+000.00123"), 2, Operations.Rounding.Ceil) == 1, "sticky");
        require(op.parseUnitsUnsigned(bytes("1.2300"), 2, Operations.Rounding.Ceil) == 123, "zeros");
        require(op.parseUnitsUnsigned(bytes(".5"), 0, Operations.Rounding.Trunc) == 0, "point");
        require(op.parseUnitsUnsigned(bytes("5."), 0, Operations.Rounding.Ceil) == 5, "trailing");
        require(op.parseUnitsUnsigned(bytes("1"), 77, Operations.Rounding.Trunc) == 10 ** 77, "precision");
        require(
            op.parseUnitsUnsigned(
                bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935"),
                0,
                Operations.Rounding.Trunc
            ) == type(uint256).max,
            "max"
        );
        failure(
            "parseUnitsUnsigned(bytes,uint256,uint8)",
            bytes("-0"),
            0,
            Operations.Rounding.Trunc,
            abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, uint256(0), bytes1("-"))
        );
        failure(
            "parseUnitsUnsigned(bytes,uint256,uint8)",
            bytes("1.2.3"),
            2,
            Operations.Rounding.Trunc,
            abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, uint256(3), bytes1("."))
        );
        failure(
            "parseUnitsUnsigned(bytes,uint256,uint8)",
            bytes("."),
            2,
            Operations.Rounding.Trunc,
            abi.encodeWithSelector(Operations.EmptyNumber.selector)
        );
        failure(
            "parseUnitsUnsigned(bytes,uint256,uint8)",
            bytes("1"),
            78,
            Operations.Rounding.Trunc,
            abi.encodeWithSelector(Operations.InvalidPrecision.selector, uint256(78))
        );
        failure(
            "parseUnitsUnsigned(bytes,uint256,uint8)",
            bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935.1"),
            0,
            Operations.Rounding.Ceil,
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
    }

    function testSignedUnitParsing() public view {
        require(op.parseUnits(bytes("-1.234"), 2, Operations.Rounding.Floor) == -124, "floor");
        require(op.parseUnits(bytes("-1.234"), 2, Operations.Rounding.Ceil) == -123, "ceil");
        require(op.parseUnits(bytes("+1.234"), 2, Operations.Rounding.Ceil) == 124, "positive");
        require(op.parseUnits(bytes("-0.001"), 2, Operations.Rounding.Floor) == -1, "negativezero");
        require(
            op.parseUnits(
                bytes("-57896044618658097711785492504343953926634992332820282019728792003956564819968"),
                0,
                Operations.Rounding.Trunc
            ) == type(int256).min,
            "min"
        );
        failure(
            "parseUnits(bytes,uint256,uint8)",
            bytes("+"),
            2,
            Operations.Rounding.Trunc,
            abi.encodeWithSelector(Operations.EmptyNumber.selector)
        );
        failure(
            "parseUnits(bytes,uint256,uint8)",
            bytes("57896044618658097711785492504343953926634992332820282019728792003956564819968"),
            0,
            Operations.Rounding.Trunc,
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
        failure(
            "parseUnits(bytes,uint256,uint8)",
            bytes("-1x"),
            0,
            Operations.Rounding.Trunc,
            abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, uint256(2), bytes1("x"))
        );
    }
}
