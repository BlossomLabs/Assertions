// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Assertions} from "../../contracts/Assertions.sol";
import {
    Constraint,
    ConstraintType,
    ConstraintFailed,
    InvalidConstraintData,
    InvalidConstraintRange,
    InvalidOrConstraint,
    ReturnDataOutOfBounds
} from "../../contracts/lib/ERC8211.sol";

contract ConstraintHarness is Assertions {
    function validate(Constraint[] calldata cs, bytes memory data) external pure {
        _validateConstraints(cs, data, "constraint oracle", 17, 23);
    }
}

contract ConstraintOracleTest {
    ConstraintHarness private core = new ConstraintHarness();

    function run(Constraint[] memory cs, bytes memory data, bool expectedOk, bytes memory expected) private view {
        (bool ok, bytes memory result) =
            address(core).staticcall(abi.encodeCall(ConstraintHarness.validate, (cs, data)));
        require(ok == expectedOk, "wrong verdict");
        require(keccak256(result) == keccak256(expected), "wrong exact error");
    }

    function one(ConstraintType kind, bytes memory refData) private pure returns (Constraint[] memory cs) {
        cs = new Constraint[](1);
        cs[0] = Constraint(kind, refData);
    }

    function failed(uint256 i, Constraint memory c, uint256 actual) private pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            "constraint oracle",
            uint256(17),
            uint256(23),
            i,
            c.constraintType,
            bytes32(actual),
            c.referenceData
        );
    }

    function testBoundsBeforePredicatesAndSkip() public view {
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.EQ, hex"01");
        cs[1] = Constraint(ConstraintType.SKIP, "");
        run(cs, new bytes(63), false, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(63)));
        run(
            one(ConstraintType.SKIP, ""),
            new bytes(31),
            false,
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(31))
        );
        run(one(ConstraintType.SKIP, ""), new bytes(33), true, "");
        run(new Constraint[](0), hex"01", true, "");
    }

    function testExactFirstFailure() public view {
        Constraint[] memory cs = new Constraint[](3);
        cs[0] = Constraint(ConstraintType.SKIP, "");
        cs[1] = Constraint(ConstraintType.EQ, abi.encode(uint256(9)));
        cs[2] = Constraint(ConstraintType.IN, "");
        run(cs, abi.encode(uint256(88), uint256(8), uint256(9)), false, failed(1, cs[1], 8));
    }

    function testSignedExtremesAndRanges() public view {
        uint256 min = 1 << 255;
        run(one(ConstraintType.GTE_SIGNED, abi.encode(min)), abi.encode(type(uint256).max), true, "");
        run(one(ConstraintType.LTE_SIGNED, abi.encode(uint256(0))), abi.encode(type(uint256).max), true, "");
        run(one(ConstraintType.IN_SIGNED, abi.encode(min, min - 1)), abi.encode(type(uint256).max), true, "");
        run(
            one(ConstraintType.IN, abi.encode(min, min - 1)),
            abi.encode(min),
            false,
            abi.encodeWithSelector(InvalidConstraintRange.selector, uint256(17), uint256(23), uint256(0))
        );
        run(
            one(ConstraintType.IN_SIGNED, abi.encode(uint256(0), type(uint256).max)),
            abi.encode(uint256(0)),
            false,
            abi.encodeWithSelector(InvalidConstraintRange.selector, uint256(17), uint256(23), uint256(0))
        );
    }

    function testOrStructureBeforeShortCircuit() public view {
        Constraint[] memory leaves = new Constraint[](2);
        leaves[0] = Constraint(ConstraintType.SKIP, "");
        leaves[1] = Constraint(ConstraintType.OR, "");
        run(
            one(ConstraintType.OR, abi.encode(leaves)),
            abi.encode(uint256(4)),
            false,
            abi.encodeWithSelector(InvalidOrConstraint.selector, uint256(17), uint256(23), uint256(0))
        );
        run(
            one(ConstraintType.OR, abi.encode(new Constraint[](0))),
            abi.encode(uint256(4)),
            false,
            abi.encodeWithSelector(InvalidOrConstraint.selector, uint256(17), uint256(23), uint256(0))
        );
        run(one(ConstraintType.OR, hex"01"), abi.encode(uint256(4)), false, "");
    }

    function testOrShortCircuitAndErrors() public view {
        Constraint[] memory leaves = new Constraint[](2);
        leaves[0] = Constraint(ConstraintType.SKIP, "");
        leaves[1] = Constraint(ConstraintType.EQ, hex"01");
        run(one(ConstraintType.OR, abi.encode(leaves)), abi.encode(uint256(4)), true, "");
        leaves[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(5)));
        run(
            one(ConstraintType.OR, abi.encode(leaves)),
            abi.encode(uint256(4)),
            false,
            abi.encodeWithSelector(InvalidConstraintData.selector, uint256(17), uint256(23), uint256(0), uint256(1))
        );
        leaves[1] = Constraint(ConstraintType.EQ, abi.encode(uint256(6)));
        Constraint[] memory cs = one(ConstraintType.OR, abi.encode(leaves));
        run(cs, abi.encode(uint256(4)), false, failed(0, cs[0], 4));
    }

    function testReferenceLengths() public view {
        for (uint256 k; k < 9; ++k) {
            if (k == uint256(ConstraintType.OR)) continue;
            run(
                one(ConstraintType(k), hex"01"),
                abi.encode(uint256(0)),
                false,
                abi.encodeWithSelector(InvalidConstraintData.selector, uint256(17), uint256(23), uint256(0), uint256(1))
            );
        }
    }

    function testFuzzScalar(uint256 x, uint256 y, uint8 selector) public view {
        uint256 k = uint256(selector) % 5;
        ConstraintType kind = k == 0
            ? ConstraintType.EQ
            : k == 1
                ? ConstraintType.GTE
                : k == 2 ? ConstraintType.LTE : k == 3 ? ConstraintType.GTE_SIGNED : ConstraintType.LTE_SIGNED;
        bool expected = k == 0
            ? x == y
            : k == 1 ? x >= y : k == 2 ? x <= y : k == 3 ? int256(x) >= int256(y) : int256(x) <= int256(y);
        Constraint[] memory cs = one(kind, abi.encode(y));
        run(cs, abi.encode(x), expected, expected ? bytes("") : failed(0, cs[0], x));
    }

    function testInclusiveBoundaries() public view {
        for (uint256 k; k < 9; ++k) {
            if (k == uint256(ConstraintType.OR) || k == uint256(ConstraintType.SKIP)) continue;
            bytes memory refData = k == uint256(ConstraintType.IN) || k == uint256(ConstraintType.IN_SIGNED)
                ? abi.encode(uint256(7), uint256(7))
                : abi.encode(uint256(7));
            run(one(ConstraintType(k), refData), abi.encode(uint256(7)), true, "");
        }
    }

    function testLongListFirstFailure() public view {
        Constraint[] memory cs = new Constraint[](70);
        for (uint256 i; i < cs.length; ++i) {
            cs[i] = Constraint(ConstraintType.SKIP, "");
        }
        run(cs, new bytes(70 * 32 + 7), true, "");
        cs[65] = Constraint(ConstraintType.EQ, abi.encode(uint256(1)));
        run(cs, new bytes(70 * 32 + 7), false, failed(65, cs[65], 0));
    }
}
