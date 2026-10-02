// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {PinnedRuntime} from "./PinnedRuntime.sol";

interface VmWords {
    function etch(address, bytes calldata) external;
}

interface CollectionsWords {
    function unpackArray(string calldata, bytes calldata) external pure returns (bytes[] memory);
}

// The runner installs the exact canonical Hardhat runtime for the baseline.
// Candidate repairs are compiled separately and never substituted for baseline evidence.
contract AbiWordOracle {
    VmWords constant vm = VmWords(address(uint160(uint256(keccak256("hevm cheat code")))));
    address constant TARGET = address(0xabc123);
    error InvalidValue(uint256 offset);

    function setUp() public {
        vm.etch(TARGET, PinnedRuntime.code());
    }

    function same(bytes memory a, bytes memory b) private pure returns (bool) {
        if (a.length != b.length) return false;
        for (uint256 i; i < a.length; ++i) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }

    function callData(string memory name, uint256 word, bytes1 afterName) private pure returns (bytes memory data) {
        data = abi.encodeCall(CollectionsWords.unpackArray, (name, abi.encode(uint256(32), uint256(1), word)));
        // Find the supplied descriptor sentinel in the actual encoded calldata.
        // Its position is deliberately not derived from the ABI encoder's offsets.
        bytes memory needle = bytes(name);
        uint256 found;
        for (uint256 i = 4; i + needle.length < data.length; ++i) {
            bool match_ = true;
            for (uint256 j; j < needle.length; ++j) {
                if (data[i + j] != needle[j]) match_ = false;
            }
            if (match_) {
                data[i + needle.length] = afterName;
                ++found;
            }
        }
        assert(found == 1);
    }

    function rejected(string memory name, uint256 word, bytes1 afterName) private view {
        (bool ok, bytes memory result) = TARGET.staticcall(callData(name, word, afterName));
        assert(!ok && same(result, abi.encodeWithSelector(InvalidValue.selector, uint256(64))));
    }

    function accepted(string memory name, uint256 word, bytes1 afterName) private view {
        (bool ok, bytes memory result) = TARGET.staticcall(callData(name, word, afterName));
        bytes[] memory wanted = new bytes[](1);
        wanted[0] = abi.encode(word);
        assert(ok && same(result, abi.encode(wanted)));
    }

    function testDescriptorPaddingCannotDisableBytes3Rule() public view {
        for (uint256 i; i < 256; ++i) {
            rejected("bytes3", 1, bytes1(uint8(i)));
        }
    }

    function testCanonicalBytes3WithEveryFollowingByte() public view {
        for (uint256 i; i < 256; ++i) {
            accepted("bytes3", uint256(0x123456) << 232, bytes1(uint8(i)));
        }
    }

    function testOtherRuleFamiliesAndOpaqueNames() public view {
        rejected("uint8", 256, "0");
        rejected("int8", 128, "0");
        rejected("address", uint256(1) << 160, "0");
        rejected("bool", 2, "0");
        rejected("function", 1, "0");
        accepted("uint8", 255, "0");
        accepted("int8", type(uint256).max, "0");
        accepted("bytes32", type(uint256).max, "0");
        accepted("uint08", type(uint256).max, "0");
        accepted("uint7", type(uint256).max, "0");
        accepted("uint8x", type(uint256).max, "0");
        accepted("foo", type(uint256).max, "0");
        accepted("aaa", type(uint256).max, "0");
    }

    function decimal(uint256 n) private pure returns (string memory) {
        if (n < 10) return string(abi.encodePacked(bytes1(uint8(48 + n))));
        if (n < 100) return string(abi.encodePacked(bytes1(uint8(48 + n / 10)), bytes1(uint8(48 + n % 10))));
        return string(
            abi.encodePacked(bytes1(uint8(48 + n / 100)), bytes1(uint8(48 + n / 10 % 10)), bytes1(uint8(48 + n % 10)))
        );
    }

    function testEveryNarrowWidthBoundary() public view {
        for (uint256 bits = 8; bits < 256; bits += 8) {
            string memory unsignedName = string.concat("uint", decimal(bits));
            accepted(unsignedName, (uint256(1) << bits) - 1, hex"00");
            rejected(unsignedName, uint256(1) << bits, hex"00");
            string memory signedName = string.concat("int", decimal(bits));
            uint256 half = uint256(1) << (bits - 1);
            accepted(signedName, half - 1, hex"00");
            rejected(signedName, half, hex"00");
            accepted(signedName, type(uint256).max - half + 1, hex"00");
            rejected(signedName, type(uint256).max - half, hex"00");
            string memory bytesName = string.concat("bytes", decimal(bits / 8));
            accepted(bytesName, type(uint256).max << (256 - bits), hex"00");
            rejected(bytesName, 1, hex"00");
        }
    }
}
