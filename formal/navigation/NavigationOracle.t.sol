// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Assertions, ElementIndexOutOfBounds} from "../../contracts/Assertions.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../contracts/lib/AbiCodec.sol";
import {
    InputParam,
    InputParamType,
    InputParamFetcherType,
    Constraint,
    ConstraintType,
    ConstraintFailed,
    ReturnDataOutOfBounds
} from "../../contracts/lib/ERC8211.sol";

contract NavigationHarness is Assertions {
    function normalize(int256 index, uint256 count) external pure returns (uint256) {
        return _normalizeIndex(index, count);
    }

    function readWord(bytes memory data, uint256 pos) external pure returns (uint256) {
        return _navWord(data, pos);
    }
}

contract NavigationOracleTest {
    NavigationHarness private core = new NavigationHarness();

    struct StaticPair {
        uint8 number;
        bool flag;
    }

    struct DynamicPair {
        uint8 number;
        string text;
    }

    function path(int256 a) private pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = a;
    }

    function path(int256 a, int256 b) private pure returns (int256[] memory p) {
        p = new int256[](2);
        p[0] = a;
        p[1] = b;
    }

    function path(int256 a, int256 b, int256 c) private pure returns (int256[] memory p) {
        p = new int256[](3);
        p[0] = a;
        p[1] = b;
        p[2] = c;
    }

    function run(bytes memory data, string memory types, int256[] memory p) private view returns (bool, bytes memory) {
        InputParam memory input =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
        return address(core).staticcall(abi.encodeCall(Assertions.nav, (input, types, p)));
    }

    function succeeds(bytes memory data, string memory types, int256[] memory p, bytes memory expected) private view {
        (bool ok, bytes memory out) = run(data, types, p);
        require(ok, "expected navigation success");
        require(keccak256(out) == keccak256(expected), "navigation bytes differ from solc oracle");
    }

    function rejects(bytes memory data, string memory types, int256[] memory p, bytes memory expected) private view {
        (bool ok, bytes memory out) = run(data, types, p);
        require(!ok, "expected navigation rejection");
        require(keccak256(out) == keccak256(expected), "navigation error fields differ");
    }

    function testEmptyPathBypassesDescriptor() public view {
        succeeds(hex"112233", "((", new int256[](0), hex"112233");
    }

    function testResolutionFailurePrecedesEmptyPathAndModeDispatch() public view {
        Constraint[] memory constraints = new Constraint[](1);
        constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(74)));
        InputParam memory input =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(uint256(73)), constraints);
        bytes memory expected = abi.encodeWithSelector(
            ConstraintFailed.selector,
            "",
            uint256(0),
            uint256(0),
            uint256(0),
            ConstraintType.EQ,
            bytes32(uint256(73)),
            abi.encode(uint256(74))
        );
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.nav, (input, "((", new int256[](0))));
        require(!ok && keccak256(out) == keccak256(expected));
        (ok, out) = address(core).staticcall(abi.encodeCall(Assertions.nav, (input, "((", path(type(int256).min))));
        require(!ok && keccak256(out) == keccak256(expected));
    }

    function testTupleArrayRootIsAccepted() public view {
        StaticPair[2] memory pairs = [StaticPair(19, false), StaticPair(73, true)];
        succeeds(abi.encode(pairs), "(uint8,bool)[2]", path(-1), abi.encode(pairs[1]));
        succeeds(abi.encode(pairs), "(uint8,bool)[2]", path(1, 0), abi.encode(pairs[1].number));
    }

    function testWrongDynamicModeReadOrder() public view {
        bytes memory truncated = abi.encode(uint256(32));
        bytes memory bounds = abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), truncated.length);
        bytes memory wrongMode = abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1));
        rejects(truncated, "(string[2])", path(0, type(int256).min), bounds);
        rejects(truncated, "(string[2])", path(0, type(int256).min + 1), wrongMode);
        rejects(truncated, "((string,uint8))", path(0, type(int256).min), bounds);
        rejects(truncated, "((string,uint8))", path(0, type(int256).min + 1), wrongMode);
    }

    function testNestedSelectedArrayValidatesDirtyWord() public view {
        uint8[][] memory values = new uint8[][](1);
        values[0] = new uint8[](1);
        values[0][0] = 73;
        bytes memory raw = abi.encode(values);
        uint256 location = type(uint256).max;
        for (uint256 i; i + 32 <= raw.length; i += 32) {
            bytes32 word;
            assembly ("memory-safe") { word := mload(add(add(raw, 32), i)) }
            if (word == bytes32(uint256(73))) {
                require(location == type(uint256).max, "sentinel is not unique");
                location = i;
            }
        }
        require(location != type(uint256).max, "sentinel missing");
        raw[location] = 0x01;
        bytes memory expected = abi.encodeWithSelector(AbiCodec.InvalidValue.selector, location);
        rejects(raw, "(uint8[][])", path(0), expected);
        rejects(raw, "(uint8[][])", path(0, 0, 0), expected);
    }

    function testStaticScalar() public view {
        succeeds(abi.encode(uint256(71), uint8(13)), "(uint256,uint8)", path(1), abi.encode(uint8(13)));
    }

    function testWholeStaticTuple() public view {
        StaticPair memory pair = StaticPair(19, true);
        succeeds(abi.encode(uint256(71), pair), "(uint256,(uint8,bool))", path(1), abi.encode(pair));
    }

    function testWholeDynamicTuple() public view {
        DynamicPair memory pair = DynamicPair(19, "navigation");
        succeeds(abi.encode(pair), "((uint8,string))", path(0), abi.encode(pair));
    }

    function testNestedTupleField() public view {
        DynamicPair memory pair = DynamicPair(19, "navigation");
        succeeds(abi.encode(pair), "((uint8,string))", path(0, 1), abi.encode(pair.text));
    }

    function testStaticFixedArrayTerminal() public view {
        uint8[2] memory values = [uint8(19), uint8(73)];
        succeeds(abi.encode(values), "(uint8[2])", path(0), abi.encode(values));
    }

    function testFixedArrayNegativeIndex() public view {
        uint8[2] memory values = [uint8(19), uint8(73)];
        succeeds(abi.encode(values), "(uint8[2])", path(0, -1), abi.encode(values[1]));
    }

    function testDynamicArrayNegativeIndex() public view {
        uint8[] memory values = new uint8[](2);
        values[0] = 19;
        values[1] = 73;
        succeeds(abi.encode(values), "(uint8[])", path(0, -2), abi.encode(values[0]));
    }

    function testArrayOfDynamicElements() public view {
        string[] memory values = new string[](2);
        values[0] = "left";
        values[1] = "right";
        succeeds(abi.encode(values), "(string[])", path(0, -1), abi.encode(values[1]));
        succeeds(abi.encode(values), "(string[])", path(0), abi.encode(values));
    }

    function testDynamicFixedArray() public view {
        string[2] memory values = [string("left"), string("right")];
        succeeds(abi.encode(values), "(string[2])", path(0), abi.encode(values));
        succeeds(abi.encode(values), "(string[2])", path(0, 1), abi.encode(values[1]));
    }

    function testNestedArray() public view {
        uint8[][] memory values = new uint8[][](2);
        values[0] = new uint8[](0);
        values[1] = new uint8[](1);
        values[1][0] = 73;
        succeeds(abi.encode(values), "(uint8[][])", path(0, 1, 0), abi.encode(values[1][0]));
        succeeds(abi.encode(values), "(uint8[][])", path(0), abi.encode(values));
    }

    function testEmptyArrayTerminalAndLength() public view {
        uint8[] memory values = new uint8[](0);
        succeeds(abi.encode(values), "(uint8[])", path(0), abi.encode(values));
        succeeds(abi.encode(values), "(uint8[])", path(0, type(int256).min), abi.encode(uint256(0)));
    }

    function testByteLengthAndPayload() public view {
        bytes memory value = hex"112233";
        succeeds(abi.encode(value), "(bytes)", path(0, type(int256).min), abi.encode(value.length));
        succeeds(abi.encode(value), "(bytes)", path(0, type(int256).min + 1), value);
    }

    function testLengthSkipsArrayTailsAndNarrowRules() public view {
        succeeds(
            abi.encode(uint256(32), uint256(1), type(uint256).max),
            "(string[])",
            path(0, type(int256).min),
            abi.encode(uint256(1))
        );
        succeeds(
            abi.encode(uint256(32), uint256(1), uint256(256)),
            "(uint8[])",
            path(0, type(int256).min),
            abi.encode(uint256(1))
        );
    }

    function testLengthRequiresWholeElementHead() public view {
        bytes memory raw = bytes.concat(abi.encode(uint256(32), uint256(1)), new bytes(31));
        rejects(
            raw,
            "(uint8[])",
            path(0, type(int256).min),
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), raw.length)
        );
    }

    function testPayloadAcceptsUnpaddedBytes() public view {
        bytes memory raw = bytes.concat(abi.encode(uint256(32), uint256(1)), hex"aa");
        succeeds(raw, "(bytes)", path(0, type(int256).min + 1), hex"aa");
        rejects(
            raw,
            "(bytes)",
            path(0, type(int256).min),
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), raw.length)
        );
    }

    function testDirtyPaddingModeDistinction() public view {
        bytes memory raw = abi.encode(bytes(hex"aa"));
        raw[raw.length - 1] = 0x7f;
        succeeds(raw, "(bytes)", path(0, type(int256).min + 1), hex"aa");
        succeeds(raw, "(bytes)", path(0, type(int256).min), abi.encode(uint256(1)));
        rejects(raw, "(bytes)", path(0), abi.encodeWithSelector(AbiCodec.InvalidValue.selector, raw.length - 1));
    }

    function testUnvisitedSiblingMayBeDirty() public view {
        bytes memory raw = abi.encode(uint256(256), uint8(19));
        succeeds(raw, "(uint8,uint8)", path(1), abi.encode(uint8(19)));
        rejects(raw, "(uint8,uint8)", path(0), abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
    }

    function testLooseParentOffsetMayBeSelected() public view {
        bytes memory body = abi.encode(uint256(1), bytes32(hex"aa"));
        bytes memory raw = bytes.concat(abi.encode(uint256(64), uint256(777)), body);
        succeeds(raw, "(bytes)", path(0), abi.encode(bytes(hex"aa")));
    }

    function testTupleNegativeIndexRejected() public view {
        rejects(
            abi.encode(uint256(19)),
            "(uint256)",
            path(-1),
            abi.encodeWithSelector(ElementIndexOutOfBounds.selector, int256(-1), uint256(1))
        );
    }

    function testArrayIndexBounds() public view {
        uint8[2] memory values = [uint8(19), uint8(73)];
        rejects(
            abi.encode(values),
            "(uint8[2])",
            path(0, -3),
            abi.encodeWithSelector(ElementIndexOutOfBounds.selector, int256(-3), uint256(2))
        );
        rejects(
            abi.encode(values),
            "(uint8[2])",
            path(0, 2),
            abi.encodeWithSelector(ElementIndexOutOfBounds.selector, int256(2), uint256(2))
        );
    }

    function testNonfinalSentinelIsAnIndex() public view {
        rejects(
            abi.encode(uint256(19)),
            "(uint256)",
            path(type(int256).min, 0),
            abi.encodeWithSelector(ElementIndexOutOfBounds.selector, type(int256).min, uint256(1))
        );
    }

    function testBareSentinelsRejectedBeforeDescriptor() public view {
        rejects(
            hex"",
            "((",
            path(type(int256).min),
            abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(0))
        );
        rejects(
            hex"",
            "((",
            path(type(int256).min + 1),
            abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(0))
        );
    }

    function testDescriptorFailurePrecedesDataRead() public view {
        rejects(hex"", "uint256", path(0), abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(0)));
        rejects(hex"", "()", path(0), abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1)));
    }

    function testScalarCannotBeIndexed() public view {
        rejects(
            abi.encode(uint256(19)),
            "(uint256)",
            path(0, 0),
            abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1))
        );
    }

    function testWrongTerminalModes() public view {
        uint8[2] memory values = [uint8(19), uint8(73)];
        rejects(
            abi.encode(values),
            "(uint8[2])",
            path(0, type(int256).min),
            abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1))
        );
        rejects(
            abi.encode(values),
            "(uint8[2])",
            path(0, type(int256).min + 1),
            abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1))
        );
    }

    function testOffsetWordBounds() public view {
        rejects(
            hex"", "(bytes)", path(0), abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(0))
        );
        rejects(
            abi.encode(type(uint256).max),
            "(bytes)",
            path(0),
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(32))
        );
    }

    function testHostileArrayCountRejectedBeforeIndex() public view {
        bytes memory raw = abi.encode(uint256(32), type(uint256).max);
        rejects(
            raw, "(uint8[])", path(0, -1), abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), raw.length)
        );
    }

    function testIndexHelperFullWidthCastBoundary() public view {
        uint256 half = uint256(1) << 255;
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(core.normalize, (int256(-1), half)));
        require(!ok && keccak256(out) == keccak256(abi.encodeWithSignature("Panic(uint256)", 17)));
        (ok, out) = address(core).staticcall(abi.encodeCall(core.normalize, (int256(-1), half + 1)));
        require(
            !ok
                && keccak256(out)
                    == keccak256(abi.encodeWithSelector(ElementIndexOutOfBounds.selector, int256(-1), half + 1))
        );
        require(core.normalize(0, half) == 0);
    }

    function testUnalignedWordRead() public view {
        bytes memory raw = bytes.concat(hex"aabbcc", abi.encode(uint256(73)), hex"dd");
        require(core.readWord(raw, 3) == 73);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(core.readWord, (raw, type(uint256).max)));
        require(
            !ok
                && keccak256(out)
                    == keccak256(
                        abi.encodeWithSelector(
                            ReturnDataOutOfBounds.selector, int256(type(uint256).max / 32), raw.length
                        )
                    )
        );
    }

    function testWordReadRequiresAll32Bytes() public view {
        bytes memory raw = new bytes(31);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(core.readWord, (raw, uint256(0))));
        require(
            !ok
                && keccak256(out)
                    == keccak256(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(31)))
        );
        require(core.readWord(abi.encode(uint256(73)), 0) == 73);
    }
}
