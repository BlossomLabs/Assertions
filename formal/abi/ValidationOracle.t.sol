// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AbiCodec} from "../src/AbiCodec.sol";

// Concrete correspondence checks only. The runner copies the pinned source
// into an isolated Forge project; this is not a general refinement proof.
contract AbiModelValidationOracleTest {
    struct Example {
        uint8[2] numbers;
        bytes[] payloads;
    }

    function validate(bytes calldata descriptor, bytes memory value) external pure returns (bool) {
        AbiCodec.validate(descriptor, value);
        return true;
    }

    function accepted(bytes memory descriptor, bytes memory value) private view {
        (bool ok, bytes memory result) = address(this).staticcall(abi.encodeCall(this.validate, (descriptor, value)));
        assert(ok && keccak256(result) == keccak256(abi.encode(true)));
    }

    function rejected(bytes memory descriptor, bytes memory value) private view {
        (bool ok, bytes memory result) = address(this).staticcall(abi.encodeCall(this.validate, (descriptor, value)));
        assert(!ok && result.length == 36 && bytes4(result) == AbiCodec.InvalidValue.selector);
    }

    function setWord(bytes memory value, uint256 offset, uint256 word) private pure {
        assert(offset + 32 <= value.length);
        assembly ("memory-safe") {
            mstore(add(add(value, 32), offset), word)
        }
    }

    function testBytesBoundaries() public view {
        uint256[5] memory lengths = [uint256(0), 1, 31, 32, 33];
        for (uint256 j; j < lengths.length; ++j) {
            bytes memory payload = new bytes(lengths[j]);
            for (uint256 i; i < payload.length; ++i) {
                payload[i] = bytes1(uint8(i + 1));
            }
            bytes memory value = abi.encode(payload);
            accepted("bytes", value);
            rejected("bytes", bytes.concat(value, hex"00"));
            if (payload.length % 32 != 0) {
                value[value.length - 1] = hex"01";
                rejected("bytes", value);
            }
        }
        rejected("bytes", abi.encode(uint256(32)));
        rejected("bytes", abi.encode(uint256(32), uint256(1)));
        rejected("bytes", abi.encode(uint256(32), type(uint256).max));
        rejected("bytes", abi.encode(uint256(32), type(uint256).max - 31));
        rejected("bytes", bytes.concat(abi.encode(uint256(32), uint256(1)), hex"ff"));
    }

    function testStringBytesAndPadding() public view {
        bytes memory value = abi.encode(hex"ff00fe");
        accepted("string", value);
        value[value.length - 1] = hex"01";
        rejected("string", value);
    }

    function testScalarRules() public view {
        accepted("uint8", abi.encode(uint256(255)));
        rejected("uint8", abi.encode(uint256(256)));
        accepted("int8", abi.encode(int256(-128)));
        rejected("int8", abi.encode(uint256(128)));
        accepted("address", abi.encode(type(uint160).max));
        rejected("address", abi.encode(uint256(1) << 160));
        accepted("bool", abi.encode(true));
        rejected("bool", abi.encode(uint256(2)));
        accepted("bytes3", abi.encode(bytes3(hex"010203")));
        rejected("bytes3", abi.encode(uint256(1)));
        accepted("function", abi.encode(uint256(1) << 64));
        rejected("function", abi.encode(uint256(1)));
        accepted("unknown", abi.encode(type(uint256).max));
    }

    function testStaticAggregates() public view {
        uint8[2][2] memory matrix = [[uint8(1), uint8(2)], [uint8(3), uint8(4)]];
        bytes memory value = abi.encode(matrix);
        accepted("uint8[2][2]", value);
        setWord(value, 96, 256);
        rejected("uint8[2][2]", value);
        accepted("(uint8[2],bool)", abi.encode([uint8(1), uint8(2)], true));
        rejected("(uint8[2],bool)", abi.encode(uint256(1), uint256(2), uint256(2)));
    }

    function testDynamicFixedArray() public view {
        bytes[2] memory values = [bytes(hex""), bytes(hex"ff")];
        bytes memory value = abi.encode(values);
        accepted("bytes[2]", value);
        // Locate the first offset by its unique sentinel value, rather than
        // reproducing the encoder's coordinate formula.
        uint256 position = findWord(value, 64);
        setWord(value, position, 96);
        rejected("bytes[2]", value);
    }

    function testDynamicArrays() public view {
        accepted("bytes[]", abi.encode(new bytes[](0)));
        bytes[] memory values = new bytes[](2);
        values[0] = hex"";
        values[1] = hex"ff";
        bytes memory value = abi.encode(values);
        accepted("bytes[]", value);
        setWord(value, findWord(value, 64), 96);
        rejected("bytes[]", value);
        rejected("bytes[]", abi.encode(uint256(32), type(uint256).max));
        accepted("uint8[]", abi.encode(new uint8[](0)));
        uint8[] memory numbers = new uint8[](1);
        numbers[0] = 17;
        accepted("uint8[]", abi.encode(numbers));
    }

    function testNestedTupleValidation() public view {
        bytes[] memory payloads = new bytes[](2);
        payloads[0] = hex"";
        payloads[1] = hex"ff";
        bytes memory value = abi.encode(Example([uint8(1), uint8(2)], payloads));
        accepted("(uint8[2],bytes[])", value);
        value[value.length - 1] = hex"01";
        rejected("(uint8[2],bytes[])", value);
    }

    function testEnvelopeAndTrailingBytes() public view {
        bytes memory value = abi.encode(hex"ff");
        setWord(value, 0, 64);
        rejected("bytes", value);
        rejected("uint256", bytes.concat(abi.encode(uint256(1)), hex"00"));
        rejected("uint256", hex"");
        rejected("bytes", hex"");
    }

    function findWord(bytes memory value, uint256 sentinel) private pure returns (uint256 position) {
        uint256 found;
        for (uint256 i; i + 32 <= value.length; i += 32) {
            uint256 word;
            assembly ("memory-safe") {
                word := mload(add(add(value, 32), i))
            }
            if (word == sentinel) {
                position = i;
                ++found;
            }
        }
        assert(found == 1);
    }
}
