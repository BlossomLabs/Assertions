// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AbiCodec, InvalidTypeDescriptor} from "../src/AbiCodec.sol";

contract ConnectionHarness {
    function suffix(bytes calldata t, uint256 start, uint256 end) external pure returns (uint256) {
        return AbiCodec.suffixStart(t, start, end);
    }

    function validate(bytes calldata t, bytes memory v) external pure returns (bool) {
        return AbiCodec.validate(t, v);
    }

    function body(bytes calldata t, bytes memory v, uint256 p) external pure returns (uint256) {
        (bool dynamic,) = AbiCodec.shape(t);
        require(dynamic);
        AbiCodec.Context memory context;
        return AbiCodec.body(t, 0, t.length, v, p, context);
    }
}

contract ConnectionOracleTest {
    ConnectionHarness private target = new ConnectionHarness();

    struct Pair {
        uint8 number;
        bool flag;
    }

    struct Nested {
        Pair[2] pairs;
        bytes3 tag;
        int8 signed;
    }

    function forwardOpening(bytes memory t, uint256 start, uint256 end) private pure returns (uint256 found) {
        bool seen;
        for (uint256 i = start; i < end; i++) {
            if (t[i] == "[") {
                found = i;
                seen = true;
            }
        }
        require(seen);
    }

    function marker(bytes memory t, bytes1 c) private pure returns (uint256) {
        for (uint256 i; i < t.length; i++) {
            if (t[i] == c) return i;
        }
        revert("missing sentinel");
    }

    function valid(bytes memory t, bytes memory v, bool dynamic) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.validate, (t, v)));
        require(ok && keccak256(out) == keccak256(abi.encode(dynamic)), "valid value rejected");
    }

    function invalid(bytes memory t, bytes memory v, uint256 offset) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.validate, (t, v)));
        require(
            !ok && keccak256(out) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset)),
            "wrong value rejection"
        );
    }

    function bodyValid(bytes memory t, bytes memory v, uint256 p, uint256 used) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.body, (t, v, p)));
        require(ok && keccak256(out) == keccak256(abi.encode(used)), "wrong body extent");
    }

    function bodyInvalid(bytes memory t, bytes memory v, uint256 p, uint256 offset) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.body, (t, v, p)));
        require(
            !ok && keccak256(out) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset)),
            "wrong body rejection"
        );
    }

    function changed(bytes memory data, uint256 p, uint256 word) private pure returns (bytes memory copy) {
        copy = bytes.concat(data);
        assembly ("memory-safe") { mstore(add(add(copy, 32), p), word) }
    }

    function prefix(bytes memory data, uint256 length) private pure returns (bytes memory copy) {
        copy = new bytes(length);
        for (uint256 i; i < length && i < data.length; i++) {
            copy[i] = data[i];
        }
    }

    function testLastSuffixMatchesForwardScan() public view {
        string[8] memory cases = [
            "uint8[]",
            "uint8[09]",
            "bytes[12][003]",
            "(uint8[2],bytes)[]",
            "((bool)[2],string[])[9][02]",
            "foo[00019]",
            "bytes[][2][]",
            "(bool,address)[4294967295]"
        ];
        for (uint256 i; i < cases.length; i++) {
            bytes memory t = bytes(cases[i]);
            (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.suffix, (t, 0, t.length)));
            require(ok && keccak256(out) == keccak256(abi.encode(forwardOpening(t, 0, t.length))), "suffix mismatch");
        }
    }

    function testSuffixRespectsDescriptorSubspan() public view {
        bytes memory t = bytes("!![(uint8[2],bytes)[003],bytes[]");
        uint256 start = 3;
        // The unique '3' sentinel precedes the closing bracket of this subspan.
        uint256 end = marker(t, "3") + 2;
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.suffix, (t, start, end)));
        require(ok && keccak256(out) == keccak256(abi.encode(forwardOpening(t, start, end))), "subspan mismatch");
    }

    function testMalformedSuffixNamesFirstStoppedByte() public view {
        bytes memory t = bytes("uint8[12x]");
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.suffix, (t, 0, t.length)));
        require(
            !ok && keccak256(out) == keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, marker(t, "x"))),
            "wrong suffix error"
        );
    }

    function testLongLeadingZeroFixedCountMatchesSolidity() public view {
        bytes[12] memory values;
        values[1] = hex"a1b2";
        values[11] = hex"ffeeddcc";
        bytes memory zeros = new bytes(120);
        for (uint256 i; i < zeros.length; i++) {
            zeros[i] = "0";
        }
        bytes memory t = bytes.concat("bytes[", zeros, "12]");
        bytes memory v = abi.encode(values);
        valid(t, v, true);
        bodyValid(t, v, 32, v.length - 32);
    }

    function testFixedCountNineMatchesSolidity() public view {
        bytes[9] memory values;
        values[0] = hex"00";
        values[8] = hex"1234";
        bytes memory v = abi.encode(values);
        valid("bytes[9]", v, true);
        bodyValid("bytes[9]", v, 32, v.length - 32);
    }

    function testStaticValidationMatchesNestedSolidityValue() public view {
        Nested[3] memory values;
        values[1].pairs[1] = Pair(255, true);
        values[2].tag = "abc";
        values[0].signed = -19;
        valid("((uint8,bool)[2],bytes3,int8)[3]", abi.encode(values), false);
        valid("(foo,uint8)[2]", abi.encode(type(uint256).max, uint256(255), type(uint256).max, uint256(1)), false);
    }

    function testStaticValidationChecksEveryWordAndFirstError() public view {
        Pair[3] memory values;
        values[1] = Pair(13, true);
        bytes memory v = abi.encode(values);
        for (uint256 i; i < 6; i++) {
            bytes memory bad = changed(v, i * 32, i % 2 == 0 ? 256 : 2);
            invalid("(uint8,bool)[3]", bad, i * 32);
        }
        invalid("(uint8,bool)[3]", changed(changed(v, 32, 2), 160, 2), 32);
    }

    function testStaticValidationRejectsWrongLengths() public view {
        bytes memory v = abi.encode(uint8(3), true);
        uint256[7] memory lengths = [uint256(0), 1, 31, 32, 63, 65, 96];
        for (uint256 i; i < lengths.length; i++) {
            invalid("(uint8,bool)", prefix(v, lengths[i]), 0);
        }
        valid("(uint8,bool)", v, false);
    }

    function testEmptyAndNonemptyArraysOfStaticTuples() public view {
        Pair[] memory empty = new Pair[](0);
        bytes memory v = abi.encode(empty);
        valid("(uint8,bool)[]", v, true);
        bodyValid("(uint8,bool)[]", v, 32, v.length - 32);
        Pair[] memory values = new Pair[](3);
        values[2] = Pair(42, true);
        v = abi.encode(values);
        bodyValid("(uint8,bool)[]", v, 32, v.length - 32);
    }

    function testTupleHeadBoundsAtUnalignedOrigin() public view {
        uint8[2] memory numbers = [uint8(13), 29];
        bytes memory body = abi.encode(numbers, hex"aabbcc");
        bytes memory v = bytes.concat(new bytes(13), body);
        bodyValid("(uint8[2],bytes)", v, 13, body.length);
        bodyInvalid("(uint8[2],bytes)", prefix(v, 13 + 95), 13, 13);
    }

    function testTupleHeadEnumeratesMixedComponents() public view {
        bytes memory v = abi.encode(hex"1234", uint8(42), true, "tail");
        bodyValid("(bytes,uint8,bool,string)", v, 0, v.length);
    }

    function testArrayHeadRejectsHostileAndMissingCounts() public view {
        bodyInvalid("(uint8,bool)[]", new bytes(31), 0, 0);
        bodyInvalid("(uint8,bool)[]", abi.encode(type(uint256).max), 0, 32);
        bodyInvalid("(uint8,bool)[]", abi.encode(uint256(1), uint256(0)), 0, 32);
        bodyInvalid("(uint8,bool)[]", new bytes(0), 1, 1);
    }
}
