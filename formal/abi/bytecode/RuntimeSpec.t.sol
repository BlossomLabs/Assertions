// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {PinnedRuntime} from "./PinnedRuntime.sol";

interface Vm {
    function etch(address, bytes calldata) external;
    function assume(bool) external pure;
}

interface ICollections {
    function unpackArray(string calldata, bytes calldata) external pure returns (bytes[] memory);
}

contract AbiRuntimeSpec {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    address constant TARGET = address(0xabc123);
    error InvalidValue(uint256 offset);

    struct Entry {
        uint8 tag;
        bytes data;
    }

    struct FixedString {
        uint8[2] numbers;
        string text;
    }

    function setUp() public {
        vm.etch(TARGET, PinnedRuntime.code());
    }

    // Exact bytes, without a cryptographic collision-freedom assumption.
    function same(bytes memory a, bytes memory b) internal pure returns (bool) {
        if (a.length != b.length) return false;
        uint256 i;
        for (; i + 32 <= a.length; i += 32) {
            bytes32 x;
            bytes32 y;
            assembly ("memory-safe") {
                x := mload(add(add(a, 32), i))
                y := mload(add(add(b, 32), i))
            }
            if (x != y) return false;
        }
        for (; i < a.length; ++i) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }

    function unpack(string memory t, bytes memory data) internal view returns (bool, bytes memory) {
        return TARGET.staticcall(abi.encodeCall(ICollections.unpackArray, (t, data)));
    }

    function accepts(string memory t, bytes memory data, bytes[] memory expected) internal view {
        (bool ok, bytes memory result) = unpack(t, data);
        assert(ok && same(result, abi.encode(expected)));
    }

    function rejects(string memory t, bytes memory data, uint256 offset) internal view {
        (bool ok, bytes memory result) = unpack(t, data);
        assert(!ok && same(result, abi.encodeWithSelector(InvalidValue.selector, offset)));
    }

    function decodeFixed(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (uint8[2][])));
    }

    function decodeTuple(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (FixedString[])));
    }

    function decodeStrings(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (string[])));
    }

    function decodeDynamicFixed(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (bytes[2][])));
    }

    function canonical(bytes4 decoder, bytes memory data) internal view returns (bool) {
        (bool ok, bytes memory out) = address(this).staticcall(abi.encodeWithSelector(decoder, data));
        return ok && same(abi.decode(out, (bytes)), data);
    }

    function check_fixedArrayCanonical(bytes32 a, bytes32 b, uint8 geometry) public view {
        vm.assume(geometry < 3);
        uint256 count;
        if (geometry == 0) count = 1;
        else if (geometry == 1) count = 0;
        else count = type(uint256).max;
        bytes memory data = abi.encode(uint256(32), count, a, b);
        (bool ok, bytes memory out) = unpack("uint8[2]", data);
        assert(ok == canonical(this.decodeFixed.selector, data));
        if (ok) {
            bytes[] memory expected = new bytes[](1);
            expected[0] = abi.encode(a, b);
            assert(same(out, abi.encode(expected)));
        }
    }

    function check_tupleCanonical(bytes32 a, bytes32 b, bytes32 text, uint8 geometry) public view {
        vm.assume(geometry < 5);
        bytes memory data;
        if (geometry == 0) {
            data = abi.encode(uint256(32), uint256(1), uint256(32), a, b, uint256(96), uint256(2), text);
        } else if (geometry == 1) {
            data = abi.encode(uint256(32), uint256(1), uint256(32), a, b, uint256(128), uint256(0), uint256(2), text);
        } else if (geometry == 2) {
            data = abi.encode(uint256(32), uint256(1), uint256(32), a, b, uint256(96), uint256(33), text);
        } else if (geometry == 3) {
            data = bytes.concat(
                abi.encode(uint256(32), uint256(1), uint256(32), a, b, uint256(96), uint256(2), text), hex"00"
            );
        } else {
            data = abi.encode(uint256(32), uint256(1), uint256(32), a, b, uint256(64), uint256(2), text);
        }
        (bool ok,) = unpack("(uint8[2],string)", data);
        assert(ok == canonical(this.decodeTuple.selector, data));
    }

    function check_stringsCanonical(bytes32 a, bytes32 b, uint8 geometry) public view {
        vm.assume(geometry < 4);
        bytes memory data;
        if (geometry == 0) {
            data = abi.encode(uint256(32), uint256(2), uint256(64), uint256(128), uint256(2), a, uint256(2), b);
        } else if (geometry == 1) {
            data = abi.encode(
                uint256(32), uint256(2), uint256(64), uint256(160), uint256(2), a, uint256(0), uint256(2), b
            );
        } else if (geometry == 2) {
            data = abi.encode(uint256(32), uint256(2), uint256(64), uint256(64), uint256(2), a, uint256(2), b);
        } else {
            data = bytes.concat(
                abi.encode(uint256(32), uint256(2), uint256(64), uint256(128), uint256(2), a, uint256(2), b), hex"00"
            );
        }
        (bool ok,) = unpack("string", data);
        assert(ok == canonical(this.decodeStrings.selector, data));
    }

    function check_hostileCount(uint256 count) public view {
        vm.assume(count > 2);
        rejects("uint8", abi.encode(uint256(32), count, uint256(0), uint256(0)), 64);
    }

    function check_nestedHostileCount(uint256 count) public view {
        vm.assume(count > 2);
        rejects("uint8[]", abi.encode(uint256(32), uint256(1), uint256(32), count, uint256(0), uint256(0)), 128);
    }

    function check_tupleHeadTruncated(bytes32 word) public view {
        rejects("(uint8[2],string)", abi.encode(uint256(32), uint256(1), uint256(32), word), 96);
    }

    function check_tupleValues(uint8 a, bytes2 b, uint8 c, bytes2 d) public view {
        Entry[] memory entries = new Entry[](2);
        entries[0] = Entry(a, abi.encodePacked(b));
        entries[1] = Entry(c, abi.encodePacked(d));
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(entries[0]);
        expected[1] = abi.encode(entries[1]);
        accepts("(uint8,bytes)", abi.encode(entries), expected);
    }

    function check_nestedArrays(uint8 a, uint8 b) public view {
        uint8[][] memory values = new uint8[][](2);
        values[0] = new uint8[](0);
        values[1] = new uint8[](2);
        values[1][0] = a;
        values[1][1] = b;
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(values[0]);
        expected[1] = abi.encode(values[1]);
        accepts("uint8[]", abi.encode(values), expected);
    }

    function check_dynamicFixedArray(bytes2 a, bytes2 b) public view {
        bytes[2][] memory values = new bytes[2][](1);
        values[0][0] = abi.encodePacked(a);
        values[0][1] = abi.encodePacked(b);
        bytes[] memory expected = new bytes[](1);
        expected[0] = abi.encode(values[0]);
        accepts("bytes[2]", abi.encode(values), expected);
    }

    function check_emptyArrays() public view {
        bytes memory data = abi.encode(new uint8[](0));
        bytes[] memory expected = new bytes[](0);
        accepts("uint8[2]", data, expected);
        accepts("(uint8,bytes)", data, expected);
        accepts("bytes[2]", data, expected);
    }

    function check_dynamicFixedOffsets(bytes32 a, bytes32 b, bool backward) public view {
        uint256 offset = backward ? 64 : 128;
        bytes memory data =
            abi.encode(uint256(32), uint256(1), uint256(32), uint256(64), offset, uint256(2), a, uint256(2), b);
        (bool ok,) = unpack("bytes[2]", data);
        assert(ok == canonical(this.decodeDynamicFixed.selector, data));
    }

    function check_envelopeAndTrailing(uint8 value, bool envelope) public view {
        uint8[] memory values = new uint8[](1);
        values[0] = value;
        bytes memory data = abi.encode(values);
        if (envelope) {
            data[31] = hex"40";
            rejects("uint8", data, 0);
        } else {
            rejects("uint8", bytes.concat(data, hex"00"), 96);
        }
    }

    function testConcreteGeometries() public view {
        for (uint8 g; g < 4; ++g) {
            check_tupleCanonical(bytes32(uint256(7)), bytes32(uint256(8)), bytes32("ab"), g);
            check_tupleCanonical(bytes32(uint256(256)), bytes32(uint256(8)), bytes32("ab"), g);
            check_stringsCanonical(bytes32("ab"), bytes32("cd"), g);
            check_stringsCanonical(bytes32(uint256(1)), bytes32("cd"), g);
            if (g < 3) check_fixedArrayCanonical(bytes32(uint256(7)), bytes32(uint256(8)), g);
        }
        check_hostileCount(type(uint256).max);
        check_nestedHostileCount(type(uint256).max);
        check_tupleHeadTruncated(bytes32(uint256(7)));
        check_tupleCanonical(bytes32(uint256(7)), bytes32(uint256(8)), bytes32("ab"), 4);
        check_dynamicFixedOffsets(bytes32("ab"), bytes32("cd"), false);
        check_dynamicFixedOffsets(bytes32("ab"), bytes32("cd"), true);
        check_tupleValues(7, "ab", 8, "cd");
        check_nestedArrays(7, 255);
        check_dynamicFixedArray("ab", "cd");
        check_emptyArrays();
        check_envelopeAndTrailing(7, true);
        check_envelopeAndTrailing(7, false);
    }
}
