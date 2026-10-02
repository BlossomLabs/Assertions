// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsFullMulDivOracleTest {
    Operations private ops = new Operations();

    function panic(bytes memory data, uint256 code) private view {
        (bool success, bytes memory reason) = address(ops).staticcall(data);
        require(!success && keccak256(reason) == keccak256(abi.encodeWithSignature("Panic(uint256)", code)));
    }

    function testUnsignedFullWidthAndRounding() public view {
        uint256 maximum = type(uint256).max;
        uint256 half = uint256(1) << 255;
        require(ops.mulDiv(maximum, maximum, maximum, Operations.Rounding.Trunc) == maximum);
        require(ops.mulDiv(half, half, half, Operations.Rounding.Trunc) == half);
        require(ops.mulDiv(maximum, uint256(2), uint256(3), Operations.Rounding.Trunc) == (maximum / 3) * 2);
        require(ops.mulDiv(maximum, uint256(2), uint256(4), Operations.Rounding.Trunc) == half - 1);
        require(ops.mulDiv(maximum, uint256(2), uint256(4), Operations.Rounding.Floor) == half - 1);
        require(ops.mulDiv(maximum, uint256(2), uint256(4), Operations.Rounding.Ceil) == half);
        require(ops.mulDiv(maximum - 1, maximum - 1, maximum - 2, Operations.Rounding.Trunc) == maximum);
        panic(
            abi.encodeWithSignature(
                "mulDiv(uint256,uint256,uint256,uint8)", maximum - 1, maximum - 1, maximum - 2, uint8(2)
            ),
            17
        );
        panic(
            abi.encodeWithSignature("mulDiv(uint256,uint256,uint256,uint8)", maximum, maximum, maximum - 1, uint8(0)),
            17
        );
        panic(
            abi.encodeWithSignature(
                "mulDiv(uint256,uint256,uint256,uint8)", uint256(0), uint256(0), uint256(0), uint8(0)
            ),
            18
        );
        panic(
            abi.encodeWithSignature("mulDiv(uint256,uint256,uint256,uint8)", maximum, maximum, uint256(0), uint8(0)), 18
        );
    }

    function testSignedFullWidthAndDirectedRounding() public view {
        for (int256 a = -5; a <= 5; a++) {
            for (int256 b = -5; b <= 5; b++) {
                for (int256 d = -3; d <= 3; d++) {
                    if (d == 0) continue;
                    for (uint8 mode = 0; mode < 3; mode++) {
                        int256 expected = (a * b) / d;
                        if ((a * b) % d != 0) {
                            bool negative = ((a < 0) != (b < 0)) != (d < 0);
                            if (negative && mode == 1) expected--;
                            if (!negative && mode == 2) expected++;
                        }
                        require(ops.mulDiv(a, b, d, Operations.Rounding(mode)) == expected);
                    }
                }
            }
        }
        int256 minimum = type(int256).min;
        int256 maximum = type(int256).max;
        require(ops.mulDiv(minimum, minimum, minimum, Operations.Rounding.Trunc) == minimum);
        require(ops.mulDiv(maximum, maximum, minimum, Operations.Rounding.Trunc) == minimum + 2);
        require(ops.mulDiv(maximum, maximum, minimum, Operations.Rounding.Floor) == minimum + 1);
        require(ops.mulDiv(maximum, maximum, minimum, Operations.Rounding.Ceil) == minimum + 2);
        panic(
            abi.encodeWithSignature("mulDiv(int256,int256,int256,uint8)", minimum, int256(-1), int256(1), uint8(0)), 17
        );
        panic(
            abi.encodeWithSignature("mulDiv(int256,int256,int256,uint8)", maximum, maximum, maximum - 1, uint8(0)), 17
        );
        panic(abi.encodeWithSignature("mulDiv(int256,int256,int256,uint8)", minimum, minimum, int256(0), uint8(0)), 18);
    }
}
