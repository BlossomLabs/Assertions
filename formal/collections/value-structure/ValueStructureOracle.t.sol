// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract ValueStructureOracleTest {
    Collections private c = new Collections();

    function same(bytes memory actual, bytes memory expected) private pure {
        require(keccak256(actual) == keccak256(expected), "wrong bytes or error");
    }

    function fail(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected rejection");
        same(ret, expected);
    }

    function words() private pure returns (bytes[] memory v) {
        v = new bytes[](4);
        v[0] = abi.encode(uint256(7));
        v[1] = abi.encode(type(uint256).max);
        v[2] = abi.encode(uint256(7));
        v[3] = abi.encode(uint256(1) << 255);
    }

    function testEmptyAllThree() public view {
        bytes[] memory empty = new bytes[](0);
        same(abi.encode(c.reverseValues("uint8", empty)), abi.encode(empty));
        same(abi.encode(c.sliceValues("uint8", empty, type(int256).min, type(int256).max)), abi.encode(empty));
        same(abi.encode(c.flattenValues("uint8", new bytes[][](0))), abi.encode(empty));
    }

    function testDescriptorCheckedEvenWithoutValues() public view {
        bytes[] memory empty = new bytes[](0);
        bytes memory err = abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1));
        fail(abi.encodeCall(c.reverseValues, ("()", empty)), err);
        fail(abi.encodeCall(c.sliceValues, ("()", empty, int256(0), int256(0))), err);
        fail(abi.encodeCall(c.flattenValues, ("()", new bytes[][](0))), err);
    }

    function testReverseFullWidthOriginalBytes() public view {
        bytes[] memory v = words();
        bytes[] memory expected = new bytes[](4);
        for (uint256 i; i < 4; i++) {
            expected[i] = v[3 - i];
        }
        same(abi.encode(c.reverseValues("uint256", v)), abi.encode(expected));
        same(abi.encode(c.reverseValues("uint256", c.reverseValues("uint256", v))), abi.encode(v));
    }

    function testReverseValidatesInOriginalOrder() public view {
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(uint256(1), uint256(2));
        v[1] = abi.encode(uint256(256), uint256(0));
        fail(
            abi.encodeCall(c.reverseValues, ("(uint8,bool)", v)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32))
        );
    }

    function testReverseChecksEveryNarrowValue() public view {
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(uint256(1));
        v[1] = abi.encode(uint256(256));
        fail(
            abi.encodeCall(c.reverseValues, ("uint8", v)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
        );
    }

    function testSliceSignedClampsAndEndExclusive() public view {
        bytes[] memory v = words();
        bytes[] memory expected = new bytes[](2);
        expected[0] = v[1];
        expected[1] = v[2];
        same(abi.encode(c.sliceValues("uint256", v, -3, -1)), abi.encode(expected));
        same(abi.encode(c.sliceValues("uint256", v, 1, 3)), abi.encode(expected));
        same(abi.encode(c.sliceValues("uint256", v, type(int256).min, type(int256).max)), abi.encode(v));
        same(abi.encode(c.sliceValues("uint256", v, 3, 1)), abi.encode(new bytes[](0)));
        same(abi.encode(c.sliceValues("uint256", v, -99, -99)), abi.encode(new bytes[](0)));
        same(abi.encode(c.sliceValues("uint256", v, 99, 100)), abi.encode(new bytes[](0)));
    }

    function testSliceValidatesOnlySelectedValues() public view {
        bytes[] memory v = new bytes[](3);
        v[0] = abi.encode(uint256(256));
        v[1] = abi.encode(uint256(7));
        v[2] = bytes("");
        bytes[] memory expected = new bytes[](1);
        expected[0] = v[1];
        same(abi.encode(c.sliceValues("uint8", v, 1, 2)), abi.encode(expected));
        same(abi.encode(c.sliceValues("uint8", v, 2, 1)), abi.encode(new bytes[](0)));
        fail(
            abi.encodeCall(c.sliceValues, ("uint8", v, int256(0), int256(2))),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
        );
    }

    function testFlattenRowMajorWithEmptyRows() public view {
        bytes[] memory v = words();
        bytes[][] memory groups = new bytes[][](4);
        groups[0] = new bytes[](0);
        groups[1] = new bytes[](2);
        groups[1][0] = v[0];
        groups[1][1] = v[1];
        groups[2] = new bytes[](0);
        groups[3] = new bytes[](2);
        groups[3][0] = v[2];
        groups[3][1] = v[3];
        same(abi.encode(c.flattenValues("uint256", groups)), abi.encode(v));
    }

    function testFlattenFirstInvalidRowMajor() public view {
        bytes[][] memory groups = new bytes[][](2);
        groups[0] = new bytes[](1);
        groups[0][0] = abi.encode(uint256(1), uint256(2));
        groups[1] = new bytes[](1);
        groups[1][0] = abi.encode(uint256(256), uint256(0));
        fail(
            abi.encodeCall(c.flattenValues, ("(uint8,bool)", groups)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32))
        );
    }

    function testFlattenChecksEveryNarrowValue() public view {
        bytes[][] memory groups = new bytes[][](1);
        groups[0] = new bytes[](2);
        groups[0][0] = abi.encode(uint256(1));
        groups[0][1] = abi.encode(uint256(256));
        fail(
            abi.encodeCall(c.flattenValues, ("uint8", groups)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
        );
    }

    function testDynamicCanonicalEncodingsUnchanged() public view {
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(bytes(hex"abcdef"));
        v[1] = abi.encode(bytes(""));
        bytes[] memory expected = new bytes[](2);
        expected[0] = v[1];
        expected[1] = v[0];
        same(abi.encode(c.reverseValues("bytes", v)), abi.encode(expected));
        same(abi.encode(c.sliceValues("bytes", v, 0, 2)), abi.encode(v));
        bytes[][] memory groups = new bytes[][](1);
        groups[0] = v;
        same(abi.encode(c.flattenValues("bytes", groups)), abi.encode(v));
    }
}
