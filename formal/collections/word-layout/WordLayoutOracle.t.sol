// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract WordLayoutOracleTest {
    Collections private c = new Collections();

    function same(bytes memory actual, bytes memory expected) private pure {
        require(keccak256(actual) == keccak256(expected), "wrong word layout");
    }

    function reject(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory result) = address(c).staticcall(data);
        require(!ok, "expected rejection");
        same(result, expected);
    }

    function testIotaEmptyAndSequence() public view {
        same(c.iotaWords(0), bytes(""));
        same(c.iotaWords(1), abi.encode(uint256(0)));
        same(c.iotaWords(4), abi.encode(uint256(0), uint256(1), uint256(2), uint256(3)));
    }

    function testIotaCheckedMultiplicationOverflow() public view {
        reject(abi.encodeCall(c.iotaWords, (uint256(1) << 251)), abi.encodeWithSignature("Panic(uint256)", uint256(17)));
    }

    // Compiler allocation-resource behavior is a concrete observation only;
    // the source theorem requires a successful allocation projection.
    function testIotaCompilerAllocationPanic() public view {
        reject(abi.encodeCall(c.iotaWords, (uint256(1) << 59)), abi.encodeWithSignature("Panic(uint256)", uint256(65)));
    }

    function testReverseEmptyAndFullWidthDuplicates() public view {
        same(c.reverseWords(bytes("")), bytes(""));
        same(
            c.reverseWords(abi.encode(uint256(3), type(uint256).max, uint256(3), uint256(1) << 255)),
            abi.encode(uint256(1) << 255, uint256(3), type(uint256).max, uint256(3))
        );
    }

    function testReverseUnalignedExactError() public view {
        reject(
            abi.encodeCall(c.reverseWords, (new bytes(31))),
            abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(31))
        );
    }

    function testZipEachAlignmentHasPriority() public view {
        reject(
            abi.encodeCall(c.zipWords, (hex"01", new bytes(3))),
            abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(1))
        );
        reject(
            abi.encodeCall(c.zipWords, (new bytes(32), new bytes(3))),
            abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(3))
        );
    }

    function testZipCountMismatchExactError() public view {
        reject(
            abi.encodeCall(c.zipWords, (new bytes(32), new bytes(64))),
            abi.encodeWithSelector(Collections.WordCountMismatch.selector, uint256(1), uint256(2))
        );
    }

    function testZipInterleavesAndBothLanesRecoverInputs() public view {
        bytes memory a = abi.encode(uint256(0), type(uint256).max, uint256(17));
        bytes memory b = abi.encode(uint256(5), uint256(1) << 255, uint256(5));
        bytes memory zipped = c.zipWords(a, b);
        same(zipped, abi.encode(uint256(0), uint256(5), type(uint256).max, uint256(1) << 255, uint256(17), uint256(5)));
        same(c.unzipWords(zipped, 0), a);
        same(c.unzipWords(zipped, 1), b);
        same(c.zipWords(bytes(""), bytes("")), bytes(""));
    }

    function testUnzipOddCountAndEmptyLanes() public view {
        bytes memory input = abi.encode(uint256(13), uint256(19), uint256(27), uint256(41), uint256(53));
        same(c.unzipWords(input, 0), abi.encode(uint256(13), uint256(27), uint256(53)));
        same(c.unzipWords(input, 1), abi.encode(uint256(19), uint256(41)));
        same(c.unzipWords(bytes(""), 0), bytes(""));
        same(c.unzipWords(bytes(""), 1), bytes(""));
    }

    function testUnzipAlignmentBeforeLaneAndExactInvalidLane() public view {
        reject(
            abi.encodeCall(c.unzipWords, (new bytes(33), uint256(9))),
            abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(33))
        );
        reject(
            abi.encodeCall(c.unzipWords, (bytes(""), type(uint256).max)),
            abi.encodeWithSelector(Collections.InvalidLane.selector, type(uint256).max)
        );
    }
}
