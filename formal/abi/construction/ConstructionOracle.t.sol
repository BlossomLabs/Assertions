// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {AbiCodec, InvalidTypeDescriptor} from "../src/AbiCodec.sol";

contract ConstructionHarness {
    function plan(bytes calldata t) external pure returns (AbiCodec.TupleLayout memory, bool) {
        AbiCodec.TupleLayout memory result = AbiCodec.tupleLayout(t);
        return (result, AbiCodec.isDynamic(result));
    }

    function tuple(bytes calldata t, bytes[] memory values) external pure returns (bytes memory) {
        return AbiCodec.tuple(t, values);
    }

    function cachedTuple(bytes calldata t, bytes[] memory values) external pure returns (bytes memory) {
        return AbiCodec.tuple(AbiCodec.tupleLayout(t), t, values);
    }

    function component(bytes calldata t, bytes memory value, uint256 index) external pure {
        (bool dynamic, uint256 words) = AbiCodec.shape(t);
        AbiCodec.validateComponent(t, value, index, dynamic, words);
    }

    function cached(bytes calldata t, bytes memory value) external pure {
        (bool dynamic, uint256 words) = AbiCodec.shape(t);
        AbiCodec.validate(t, value, dynamic, words);
    }

    function contextual(bytes calldata t, bytes memory value, AbiCodec.Context memory context) external pure {
        AbiCodec.validate(t, value, context);
    }

    function pack(bytes calldata t, bytes[] memory values) external pure returns (bytes memory) {
        return AbiCodec.pack(t, values);
    }

    function unpack(bytes calldata t, bytes memory value) external pure returns (bytes[] memory) {
        return AbiCodec.unpack(t, value);
    }

    function slice(bytes memory value, uint256 p, uint256 n) external pure returns (bytes memory) {
        return AbiCodec.slice(value, p, n);
    }
}

contract ConstructionOracleTest {
    ConstructionHarness private target = new ConstructionHarness();

    struct Item {
        uint8 n;
        bytes payload;
    }

    function same(bytes memory a, bytes memory b) private pure {
        require(keccak256(a) == keccak256(b), "bytes differ");
    }

    function reject(bytes memory callData, bytes memory expected) private view {
        (bool ok, bytes memory out) = address(target).staticcall(callData);
        require(!ok, "accepted invalid input");
        same(out, expected);
    }

    function find(bytes memory text, bytes memory needle) private pure returns (uint256) {
        for (uint256 i; i + needle.length <= text.length; i++) {
            bool found = true;
            for (uint256 j; j < needle.length; j++) {
                if (text[i + j] != needle[j]) found = false;
            }
            if (found) return i;
        }
        revert("sentinel absent");
    }

    function put(bytes memory value, uint256 p, uint256 word) private pure returns (bytes memory out) {
        out = bytes.concat(value);
        assembly ("memory-safe") { mstore(add(add(out, 32), p), word) }
    }

    function testLayoutNestedSpans() public view {
        bytes memory text = "(uint8[2],(bytes,bool),bytes3[][4])";
        bytes[] memory parts = new bytes[](3);
        parts[0] = "uint8[2]";
        parts[1] = "(bytes,bool)";
        parts[2] = "bytes3[][4]";
        (AbiCodec.TupleLayout memory plan, bool dynamic) = target.plan(text);
        require(dynamic && plan.starts.length == 3 && plan.headSize == 128);
        for (uint256 i; i < parts.length; i++) {
            uint256 start = find(text, parts[i]);
            require(plan.starts[i] == start && plan.ends[i] == start + parts[i].length);
            require(plan.dynamic[i] == (i != 0) && plan.words[i] == (i == 0 ? 2 : 1));
        }
    }

    function testLayoutStaticTupleWidth() public view {
        (AbiCodec.TupleLayout memory plan, bool dynamic) = target.plan("(uint8[2],(bool,bytes3))");
        require(!dynamic && plan.headSize == abi.encode(uint8(17), uint8(29), true, bytes3(0xaabbcc)).length);
        require(plan.words[0] == 2 && plan.words[1] == 2);
    }

    function testLayoutEmptyTupleRefusedAtOne() public view {
        reject(abi.encodeCall(target.plan, (bytes("()"))), abi.encodeWithSelector(InvalidTypeDescriptor.selector, 1));
    }

    function testLayoutNonTupleRefusedAtZero() public view {
        reject(abi.encodeCall(target.plan, (bytes("uint8"))), abi.encodeWithSelector(InvalidTypeDescriptor.selector, 0));
    }

    function testLayoutStrayClosePrecedesBadName() public view {
        bytes memory t = "(@),uint8)";
        reject(abi.encodeCall(target.plan, (t)), abi.encodeWithSelector(InvalidTypeDescriptor.selector, 2));
    }

    function testLayoutMissingComponent() public view {
        reject(
            abi.encodeCall(target.plan, (bytes("(uint8,)"))), abi.encodeWithSelector(InvalidTypeDescriptor.selector, 7)
        );
    }

    function testTupleMixedSolcOracle() public view {
        bytes[] memory args = new bytes[](3);
        args[0] = abi.encode(uint8(17));
        args[1] = abi.encode(hex"deadbeef42");
        args[2] = abi.encode(true);
        bytes memory expected = abi.encode(uint8(17), hex"deadbeef42", true);
        same(target.tuple("(uint8,bytes,bool)", args), expected);
        same(target.cachedTuple("(uint8,bytes,bool)", args), expected);
    }

    function testTupleNestedSolcOracle() public view {
        Item memory item = Item(239, hex"cafebabe42");
        uint8[2] memory fixedValues = [uint8(17), uint8(29)];
        bytes[][] memory ragged = new bytes[][](2);
        ragged[0] = new bytes[](0);
        ragged[1] = new bytes[](1);
        ragged[1][0] = new bytes(33);
        bytes[] memory args = new bytes[](3);
        args[0] = abi.encode(fixedValues);
        args[1] = abi.encode(item);
        args[2] = abi.encode(ragged);
        same(target.tuple("(uint8[2],(uint8,bytes),bytes[][])", args), abi.encode(fixedValues, item, ragged));
    }

    function testTupleCountMismatch() public view {
        bytes[] memory args = new bytes[](0);
        reject(
            abi.encodeCall(target.tuple, (bytes("(uint8)"), args)),
            abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, 1, 0)
        );
    }

    function testComponentStaticLength() public view {
        reject(
            abi.encodeCall(target.component, (bytes("uint8[2]"), abi.encode(uint8(17)), 7)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentLength.selector, 7, 64, 32)
        );
    }

    function testComponentShortEnvelope() public view {
        reject(
            abi.encodeCall(target.component, (bytes("bytes"), hex"aa", 9)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentEnvelope.selector, 9, 1, bytes32(0))
        );
    }

    function testComponentWrongEnvelope() public view {
        bytes memory value = abi.encode(uint256(64), uint256(0));
        reject(
            abi.encodeCall(target.component, (bytes("bytes"), value, 9)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentEnvelope.selector, 9, 64, bytes32(uint256(64)))
        );
    }

    function testComponentDirtyStaticWord() public view {
        reject(
            abi.encodeCall(target.component, (bytes("uint8"), abi.encode(uint256(0x1234)), 7)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, 7, 0)
        );
    }

    function testComponentDirtyDynamicPadding() public view {
        bytes memory value = abi.encode(hex"aabbcc42");
        uint256 p = find(value, hex"aabbcc42") + 4;
        value[p] = 0x01;
        reject(
            abi.encodeCall(target.component, (bytes("bytes"), value, 11)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, 11, p)
        );
    }

    function testContextCallbackFields() public view {
        AbiCodec.Context memory c =
            AbiCodec.Context(AbiCodec.ContextKind.CallbackResult, 0x12345678, 7, 19, address(0x4242));
        reject(
            abi.encodeCall(target.contextual, (bytes("uint8"), abi.encode(uint256(999)), c)),
            abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector, c.operation, c.index, c.other, c.target)
        );
    }

    function testContextNestedComponent() public view {
        Item[] memory items = new Item[](1);
        items[0] = Item(239, hex"deadbeef");
        bytes memory value = abi.encode(items);
        uint256 p = find(value, abi.encode(uint256(239)));
        value = put(value, p, 999);
        AbiCodec.Context memory c = AbiCodec.Context(AbiCodec.ContextKind.TupleComponent, 0, 13, 0, address(0));
        reject(
            abi.encodeCall(target.contextual, (bytes("(uint8,bytes)[]"), value, c)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, 13, p)
        );
    }

    function testContextDescriptorFailureUnchanged() public view {
        AbiCodec.Context memory c =
            AbiCodec.Context(AbiCodec.ContextKind.CallbackResult, 0x12345678, 7, 19, address(0x4242));
        reject(
            abi.encodeCall(target.contextual, (bytes("uint8[0]"), new bytes(0), c)),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, find(bytes("uint8[0]"), bytes("]")))
        );
    }

    function testCachedValidationBothBranches() public view {
        target.cached("uint8", abi.encode(uint8(239)));
        target.cached("bytes", abi.encode(hex"abcdef42"));
        reject(
            abi.encodeCall(target.cached, (bytes("uint8"), abi.encode(uint256(999)))),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 0)
        );
    }

    function testPackStaticArraySolcOracle() public view {
        uint8[2][] memory array = new uint8[2][](2);
        array[0] = [uint8(17), uint8(29)];
        array[1] = [uint8(151), uint8(239)];
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(array[0]);
        values[1] = abi.encode(array[1]);
        same(target.pack("uint8[2]", values), abi.encode(array));
        same(abi.encode(target.unpack("uint8[2]", abi.encode(array))), abi.encode(values));
    }

    function testPackNestedDynamicSolcOracle() public view {
        Item[] memory array = new Item[](2);
        array[0] = Item(17, hex"abcdef42");
        array[1] = Item(239, new bytes(33));
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(array[0]);
        values[1] = abi.encode(array[1]);
        same(target.pack("(uint8,bytes)", values), abi.encode(array));
        same(abi.encode(target.unpack("(uint8,bytes)", abi.encode(array))), abi.encode(values));
    }

    function testEmptyPackBothElementKinds() public view {
        bytes[] memory values = new bytes[](0);
        uint8[] memory ints = new uint8[](0);
        bytes[] memory blobs = new bytes[](0);
        same(target.pack("uint8", values), abi.encode(ints));
        same(target.pack("bytes", values), abi.encode(blobs));
        require(
            target.unpack("uint8", abi.encode(ints)).length == 0
                && target.unpack("bytes", abi.encode(blobs)).length == 0
        );
    }

    function testUnpackRejectsTrailingBytes() public view {
        uint8[] memory ints = new uint8[](1);
        ints[0] = 239;
        bytes memory value = abi.encode(ints);
        reject(
            abi.encodeCall(target.unpack, (bytes("uint8"), bytes.concat(value, hex"aa"))),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, value.length)
        );
    }

    function testSliceUnalignedAndEmpty() public view {
        same(target.slice(hex"aabbccddeeff", 1, 4), hex"bbccddee");
        same(target.slice(hex"aabbcc", 3, 0), new bytes(0));
        reject(
            abi.encodeCall(target.slice, (hex"aabbcc", 2, 2)), abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 2)
        );
    }

    function testUnpackRejectsLooseOffset() public view {
        bytes[] memory array = new bytes[](1);
        array[0] = hex"abcdef42";
        bytes memory value = abi.encode(array);
        // Scan the independently encoded count followed by the unique first offset.
        uint256 p = find(value, bytes.concat(abi.encode(uint256(1)), abi.encode(uint256(32)))) + 32;
        reject(
            abi.encodeCall(target.unpack, (bytes("bytes"), put(value, p, 64))),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, p)
        );
    }
}
