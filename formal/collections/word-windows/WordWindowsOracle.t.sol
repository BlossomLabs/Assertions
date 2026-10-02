// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract WordWindowsHashTarget {
    fallback() external {
        bytes32 value = keccak256(msg.data);
        assembly ("memory-safe") {
            mstore(0, value)
            return(0, 32)
        }
    }
}

contract WordWindowsOracleTest {
    Collections private c = new Collections();
    WordWindowsHashTarget private target = new WordWindowsHashTarget();

    function template(uint256 n) private pure returns (bytes memory b) {
        b = new bytes(n);
        for (uint256 i; i < n; i++) {
            b[i] = bytes1(uint8(i + 1));
        }
    }

    // Independent per-byte last-covering-window oracle; no mstore or round-trip.
    function expected(bytes memory original, uint256 accOffset, bytes32 acc, uint256[] memory offsets, bytes32 elem)
        private
        pure
        returns (bytes memory b)
    {
        b = new bytes(original.length);
        for (uint256 i; i < b.length; i++) {
            bytes1 value = original[i];
            if (accOffset <= i && i < accOffset + 32) value = acc[i - accOffset];
            for (uint256 j; j < offsets.length; j++) {
                if (offsets[j] <= i && i < offsets[j] + 32) value = elem[i - offsets[j]];
            }
            b[i] = value;
        }
    }

    function reject(bytes memory data, uint256 offset, uint256 length) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "accepted bad window");
        require(
            keccak256(ret)
                == keccak256(abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, offset, length)),
            "wrong window error"
        );
    }

    function testShortTemplateAccumulatorPrecedesElements() public view {
        uint256[] memory offsets = new uint256[](0);
        reject(
            abi.encodeCall(
                c.foldRange, (0, address(0), template(31), 7, offsets, bytes32(0), Collections.FoldExit.Full)
            ),
            7,
            31
        );
        reject(abi.encodeCall(c.mapWords, (bytes(""), address(0), template(31), offsets)), 0, 31);
    }

    function testFirstInvalidOffsetBeforeTarget() public view {
        uint256[] memory offsets = new uint256[](3);
        offsets[0] = 8;
        offsets[1] = 65;
        offsets[2] = 40;
        reject(
            abi.encodeCall(
                c.foldRange, (0, address(0), template(64), 0, offsets, bytes32(0), Collections.FoldExit.Full)
            ),
            65,
            64
        );
    }

    function testMaximumOffsetDoesNotOverflowCheck() public view {
        uint256[] memory offsets = new uint256[](1);
        offsets[0] = type(uint256).max;
        reject(
            abi.encodeCall(
                c.foldRange, (0, address(0), template(32), 0, offsets, bytes32(0), Collections.FoldExit.Full)
            ),
            type(uint256).max,
            32
        );
    }

    function testExactEndWindowEmptyDomain() public view {
        uint256[] memory offsets = new uint256[](1);
        offsets[0] = 32;
        bytes32 init = bytes32(uint256(19));
        require(
            c.foldRange(0, address(0), template(64), 32, offsets, init, Collections.FoldExit.Full) == init,
            "empty changed init"
        );
    }

    function testUnalignedOverlapsAndDuplicateOffsets() public view {
        uint256[] memory offsets = new uint256[](4);
        offsets[0] = 0;
        offsets[1] = 17;
        offsets[2] = 4;
        offsets[3] = 17;
        bytes memory original = template(80);
        bytes32 init = keccak256("accumulator");
        bytes32 want = keccak256(expected(original, 2, init, offsets, bytes32(uint256(171))));
        require(
            c.foldBytes(hex"ab", address(target), original, 2, offsets, init, Collections.FoldExit.Full) == want,
            "overlap order"
        );
    }

    function testAccumulatorOnlyPreservesOutsideBytes() public view {
        uint256[] memory offsets = new uint256[](0);
        bytes memory original = template(75);
        bytes32 init = keccak256("only accumulator");
        bytes32 want = keccak256(expected(original, 5, init, offsets, bytes32(0)));
        require(
            c.foldRange(1, address(target), original, 5, offsets, init, Collections.FoldExit.Full) == want,
            "outside changed"
        );
    }

    function testRepeatedStampPreservesPristineOutsideWindows() public view {
        uint256[] memory offsets = new uint256[](2);
        offsets[0] = 21;
        offsets[1] = 7;
        bytes memory original = template(90);
        bytes32 init = keccak256("initial");
        bytes32 first = keccak256(expected(original, 2, init, offsets, bytes32(uint256(165))));
        bytes32 second = keccak256(expected(original, 2, first, offsets, bytes32(uint256(90))));
        require(
            c.foldBytes(hex"a55a", address(target), original, 2, offsets, init, Collections.FoldExit.Full) == second,
            "persistent stamp"
        );
    }
}
