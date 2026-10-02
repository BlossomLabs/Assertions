// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AbiCodec} from "../src/AbiCodec.sol";

// Concrete checks of the same pinned source; the formal source proof is
// separate and is not inferred from the number of examples run here.
contract AbiBytesSourceOracleTest {
    function walk(bytes calldata descriptor, bytes memory value, uint256 position) external pure returns (uint256) {
        AbiCodec.Context memory context;
        return AbiCodec.body(descriptor, 0, descriptor.length, value, position, context);
    }

    function validate(bytes calldata descriptor, bytes memory value) external pure {
        AbiCodec.validate(descriptor, value);
    }

    function bodyOf(bytes memory payload) private pure returns (bytes memory body) {
        bytes memory encoded = abi.encode(payload);
        body = new bytes(encoded.length - 32);
        for (uint256 i; i < body.length; ++i) {
            body[i] = encoded[32 + i];
        }
    }

    function callWalk(bytes memory descriptor, bytes memory value, uint256 p, uint256 expected, bool success)
        private
        view
    {
        (bool ok, bytes memory result) = address(this).staticcall(abi.encodeCall(this.walk, (descriptor, value, p)));
        bytes memory wanted =
            success ? abi.encode(expected) : abi.encodeWithSelector(AbiCodec.InvalidValue.selector, expected);
        assert(ok == success && keccak256(result) == keccak256(wanted));
    }

    function callValidate(bytes memory descriptor, bytes memory value, uint256 expected, bool success) private view {
        (bool ok, bytes memory result) = address(this).staticcall(abi.encodeCall(this.validate, (descriptor, value)));
        bytes memory wanted = success ? bytes("") : abi.encodeWithSelector(AbiCodec.InvalidValue.selector, expected);
        assert(ok == success && keccak256(result) == keccak256(wanted));
    }

    function testAllPaddingBytesAndUnalignedFrames() public view {
        for (uint256 text; text < 2; ++text) {
            bytes memory descriptor = text == 0 ? bytes("bytes") : bytes("string");
            for (uint256 n; n <= 65; ++n) {
                bytes memory payload = new bytes(n);
                for (uint256 i; i < n; ++i) {
                    payload[i] = hex"ff";
                }
                bytes memory body = bodyOf(payload);
                // Prefixes deliberately put the frame at unaligned positions.
                uint256 p = (n * 7) % 33;
                bytes memory value = bytes.concat(new bytes(p), body, hex"deadbeef");
                callWalk(descriptor, value, p, body.length, true);
                for (uint256 offset = p + 32 + n; offset < p + body.length; ++offset) {
                    value[offset] = hex"01";
                    callWalk(descriptor, value, p, offset, false);
                    value[offset] = hex"00";
                }
            }
        }
    }

    function testFirstDirtyByteWins() public view {
        bytes memory value = bodyOf(hex"ff");
        value[35] = hex"01";
        value[63] = hex"02";
        callWalk("bytes", value, 0, 35, false);
        callWalk("string", value, 0, 35, false);
    }

    function testHostileLengthsAndTruncatedWords() public view {
        uint256[4] memory lengths = [type(uint256).max, type(uint256).max - 30, type(uint256).max - 31, uint256(33)];
        for (uint256 p; p < 4; ++p) {
            for (uint256 n; n < 32; ++n) {
                callWalk("bytes", new bytes(p + n), p, p, false);
            }
            for (uint256 j; j < lengths.length; ++j) {
                bytes memory value = bytes.concat(new bytes(p), abi.encode(lengths[j]), new bytes(32));
                callWalk("bytes", value, p, p, false);
                callWalk("string", value, p, p, false);
            }
        }
        callWalk("bytes", hex"00", type(uint256).max, type(uint256).max, false);
        callWalk("string", hex"", 1, 1, false);
    }

    function testPayloadFitsButPaddingDoesNot() public view {
        for (uint256 n = 1; n < 32; ++n) {
            bytes memory value = bytes.concat(abi.encode(n), new bytes(n));
            callWalk("bytes", value, 0, 0, false);
            callWalk("string", value, 0, 0, false);
        }
    }

    function testExactEnvelopeAndExtent() public view {
        for (uint256 n; n <= 65; ++n) {
            bytes memory value = abi.encode(new bytes(n));
            callValidate("bytes", value, 0, true);
            callValidate("string", value, 0, true);
            callValidate("bytes", bytes.concat(value, hex"00"), value.length, false);
            callValidate("string", bytes.concat(value, hex"00"), value.length, false);
            value[31] = hex"40";
            callValidate("bytes", value, 0, false);
        }
        callValidate("bytes", abi.encode(uint256(32)), 32, false);
        callValidate("bytes", hex"", 0, false);
    }

    function testLargeBodyAndIgnoredSuffix() public view {
        bytes memory payload = new bytes(4097);
        payload[0] = hex"ff";
        payload[4096] = hex"01";
        bytes memory body = bodyOf(payload);
        bytes memory value = bytes.concat(hex"aabbcc", body, abi.encode(type(uint256).max));
        callWalk("bytes", value, 3, body.length, true);
        callWalk("string", value, 3, body.length, true);
    }
}
