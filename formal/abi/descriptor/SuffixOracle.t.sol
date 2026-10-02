// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AbiCodec} from "../src/AbiCodec.sol";

contract SuffixHarness {
    function checked(bytes calldata descriptor, bytes memory value, uint256 count, uint256 position)
        external
        pure
        returns (uint256 end, uint256 words)
    {
        (bool dynamic, uint256 width) = AbiCodec.shape(descriptor);
        require(!dynamic && position <= value.length && count <= (value.length - position) / 32 / width);
        AbiCodec.Context memory context;
        return AbiCodec.checkWords(descriptor, 0, descriptor.length, count, value, position, context);
    }
}

contract SuffixOracleTest {
    SuffixHarness private target = new SuffixHarness();

    function emptyCheck(string memory descriptor, uint256 expected) private view {
        (bool ok, bytes memory result) =
            address(target).staticcall(abi.encodeCall(target.checked, (bytes(descriptor), new bytes(0), 0, 0)));
        require(ok && keccak256(result) == keccak256(abi.encode(bytes(descriptor).length, expected)), "shape");
    }

    function testStaticSuffixCountsAndEmptyRuns() public view {
        emptyCheck("uint8", 1);
        emptyCheck("uint8[1]", 1);
        emptyCheck("uint8[02][003]", 6);
        emptyCheck("bytes3[2][1][3]", 6);
        emptyCheck("(uint8,bool)[2][3]", 12);
        emptyCheck("((uint8,bool)[2],bytes3[3])[2]", 14);
    }

    function testLongDigitsAndManySuffixes() public view {
        bytes memory descriptor = bytes("uint8[");
        for (uint256 i; i < 130; ++i) {
            descriptor = bytes.concat(descriptor, "0");
        }
        descriptor = bytes.concat(descriptor, "2]");
        for (uint256 i; i < 24; ++i) {
            descriptor = bytes.concat(descriptor, "[1]");
        }
        emptyCheck(string(descriptor), 2);
    }

    function testMaximumStaticSuffixWithZeroCopies() public view {
        emptyCheck("uint8[4294967295]", type(uint32).max);
        emptyCheck("(uint8)[0004294967295]", type(uint32).max);
    }

    function testRepeatedNarrowWordsAndExactFirstFailure() public view {
        bytes memory data = new bytes(13 + 32 * 12 + 9);
        for (uint256 i; i < 12; ++i) {
            data[13 + i * 32 + 31] = bytes1(uint8(i % 2));
        }
        (bool ok, bytes memory result) =
            address(target).staticcall(abi.encodeCall(target.checked, (bytes("bool[02][3]"), data, 2, 13)));
        require(ok && keccak256(result) == keccak256(abi.encode(uint256(11), uint256(6))), "canonical");
        for (uint256 i; i < 12; ++i) {
            bytes1 previous = data[13 + i * 32];
            data[13 + i * 32] = 0xff;
            (ok, result) =
                address(target).staticcall(abi.encodeCall(target.checked, (bytes("bool[02][3]"), data, 2, 13)));
            require(
                !ok
                    && keccak256(result)
                        == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 13 + 32 * i)),
                "dirty"
            );
            data[13 + i * 32] = previous;
        }
    }

    function testNarrowBytesNestedArrays() public view {
        bytes memory data = abi.encode(bytes3("abc"), bytes3("def"), bytes3("ghi"), bytes3("jkl"));
        (bool ok, bytes memory result) =
            address(target).staticcall(abi.encodeCall(target.checked, (bytes("bytes3[2][2]"), data, 1, 0)));
        require(ok && keccak256(result) == keccak256(abi.encode(uint256(12), uint256(4))), "bytes");
        data[127] = 0x01;
        (ok, result) = address(target).staticcall(abi.encodeCall(target.checked, (bytes("bytes3[2][2]"), data, 1, 0)));
        require(
            !ok && keccak256(result) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 96)),
            "bytes dirty"
        );
    }

    function testTupleCopiesReachEveryWord() public view {
        bytes memory data = abi.encode(uint8(1), true, uint8(2), false, uint8(3), true, uint8(4), false);
        (bool ok, bytes memory result) =
            address(target).staticcall(abi.encodeCall(target.checked, (bytes("(uint8,bool)[2][2]"), data, 1, 0)));
        require(ok && keccak256(result) == keccak256(abi.encode(uint256(18), uint256(8))), "tuple");
        data[7 * 32 + 31] = 0x02;
        (ok, result) =
            address(target).staticcall(abi.encodeCall(target.checked, (bytes("(uint8,bool)[2][2]"), data, 1, 0)));
        require(
            !ok && keccak256(result) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 224)),
            "tuple dirty"
        );
    }
}
