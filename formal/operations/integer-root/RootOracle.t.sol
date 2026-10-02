// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsIntegerRootOracleTest {
    Operations private ops = new Operations();

    function testSmallRootBounds() public view {
        for (uint256 a; a <= 256; ++a) {
            uint256 expected;
            while ((expected + 1) * (expected + 1) <= a) ++expected;
            require(ops.sqrt(a) == expected);
        }
    }

    function testFullWordSquareBoundaries() public view {
        uint256[8] memory roots =
            [uint256(2), 3, 16, 256, uint256(1) << 32, uint256(1) << 64, uint256(1) << 127, (uint256(1) << 128) - 1];
        for (uint256 i; i < roots.length; ++i) {
            uint256 r = roots[i];
            uint256 square = r * r;
            require(ops.sqrt(square) == r);
            require(ops.sqrt(square - 1) == r - 1);
            require(ops.sqrt(square + r) == r);
        }
        require(ops.sqrt(type(uint256).max) == (uint256(1) << 128) - 1);
        require(ops.sqrt(uint256(1) << 255) == 240615969168004511545033772477625056927);
    }
}
