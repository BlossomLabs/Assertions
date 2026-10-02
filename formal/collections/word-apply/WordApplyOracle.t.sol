// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract WordApplyTarget {
    uint256 private immutable mode;

    constructor(uint256 m) {
        mode = m;
    }

    fallback() external {
        uint256 value;
        assembly ("memory-safe") {
            value := calldataload(0)
        }
        if (mode == 1) value = value % 2;
        if (mode == 2) value = uint256(keccak256(msg.data));
        if (mode == 3 && value == 9) revert("nine");
        if (mode == 4) {
            assembly ("memory-safe") {
                mstore(0, value)
                return(0, 31)
            }
        }
        assembly ("memory-safe") {
            mstore(0, value)
            return(0, 32)
        }
    }
}

contract WordApplyOracleTest {
    Collections private c = new Collections();
    WordApplyTarget private identity = new WordApplyTarget(0);
    WordApplyTarget private odd = new WordApplyTarget(1);
    WordApplyTarget private hashTarget = new WordApplyTarget(2);
    WordApplyTarget private failing = new WordApplyTarget(3);
    WordApplyTarget private shortTarget = new WordApplyTarget(4);

    function slots() private pure returns (uint256[] memory a) {
        a = new uint256[](1);
    }

    function same(bytes memory actual, bytes memory expected) private pure {
        require(keccak256(actual) == keccak256(expected), "wrong bytes");
    }

    function reject(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected rejection");
        same(ret, expected);
    }

    function testAlignmentPrecedesWindowsForBothWrappers() public view {
        bytes memory want = abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(1));
        reject(abi.encodeCall(c.mapWords, (hex"01", address(0), bytes(""), slots())), want);
        reject(abi.encodeCall(c.filterWords, (hex"01", address(0), bytes(""), slots())), want);
    }

    function testEmptyStillRejectsShortTemplateWithNoOffsets() public view {
        uint256[] memory none = new uint256[](0);
        bytes memory want =
            abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(0), uint256(31));
        reject(abi.encodeCall(c.mapWords, (bytes(""), address(0), new bytes(31), none)), want);
        reject(abi.encodeCall(c.filterWords, (bytes(""), address(0), new bytes(31), none)), want);
    }

    function testFirstInvalidWindowBeforeTargetAndEmpty() public view {
        uint256[] memory a = new uint256[](3);
        a[0] = 32;
        a[1] = 33;
        a[2] = type(uint256).max;
        bytes memory want =
            abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(33), uint256(64));
        reject(abi.encodeCall(c.mapWords, (new bytes(32), address(0), new bytes(64), a)), want);
        reject(abi.encodeCall(c.filterWords, (bytes(""), address(0), new bytes(64), a)), want);
    }

    function testEmptySkipsTargetForBothWrappers() public view {
        same(c.mapWords(bytes(""), address(0), new bytes(32), slots()), bytes(""));
        same(c.filterWords(bytes(""), address(0), new bytes(32), slots()), bytes(""));
    }

    function testNonemptyCodeLessTargetForBothWrappers() public view {
        bytes memory want = abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0));
        reject(abi.encodeCall(c.mapWords, (new bytes(32), address(0), new bytes(32), slots())), want);
        reject(abi.encodeCall(c.filterWords, (new bytes(32), address(0), new bytes(32), slots())), want);
    }

    function testMapPreservesAll256BitsAndPosition() public view {
        bytes memory input = abi.encode(uint256(0), type(uint256).max, uint256(1) << 255, uint256(17));
        same(c.mapWords(input, address(identity), new bytes(32), slots()), input);
    }

    function testMapEmitsCallbackWordRatherThanElement() public view {
        bytes memory input = abi.encode(uint256(5), uint256(8), uint256(7));
        same(c.mapWords(input, address(odd), new bytes(32), slots()), abi.encode(uint256(1), uint256(0), uint256(1)));
    }

    function testFilterStableDuplicateOriginalWordsAndShrink() public view {
        bytes memory input = abi.encode(uint256(2), uint256(5), uint256(8), uint256(5));
        same(c.filterWords(input, address(odd), new bytes(32), slots()), abi.encode(uint256(5), uint256(5)));
    }

    function testFilterAllAndNone() public view {
        bytes memory input = abi.encode(uint256(0), uint256(0), uint256(0));
        same(c.filterWords(input, address(identity), new bytes(32), slots()), bytes(""));
        input = abi.encode(uint256(1), uint256(1), uint256(1));
        same(c.filterWords(input, address(identity), new bytes(32), slots()), input);
    }

    function testFilterRejectsNoncanonicalAtExactIndex() public view {
        reject(
            abi.encodeCall(
                c.filterWords,
                (abi.encode(uint256(0), uint256(2), uint256(1)), address(identity), new bytes(32), slots())
            ),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.filterWords.selector, 1, 0, address(identity)
            )
        );
    }

    function testMalformedResultBindsBothOperationSelectors() public view {
        reject(
            abi.encodeCall(c.mapWords, (new bytes(32), address(shortTarget), new bytes(32), slots())),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.mapWords.selector, 0, 0, address(shortTarget)
            )
        );
        reject(
            abi.encodeCall(c.filterWords, (new bytes(32), address(shortTarget), new bytes(32), slots())),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.filterWords.selector, 0, 0, address(shortTarget)
            )
        );
    }

    function testCallbackFailureBeforePredicateAtExactIndex() public view {
        bytes memory input = abi.encode(uint256(0), uint256(9), uint256(1));
        bytes memory reason = abi.encodeWithSignature("Error(string)", "nine");
        reject(
            abi.encodeCall(c.filterWords, (input, address(failing), new bytes(32), slots())),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                c.filterWords.selector,
                1,
                0,
                address(failing),
                abi.encode(uint256(9)),
                reason
            )
        );
    }

    // Byte-by-byte oracle uses the original template for each element and
    // writes offsets in list order, independently of the production assembly.
    function patch(bytes memory original, uint256[] memory a, uint256 value) private pure returns (bytes memory out) {
        out = new bytes(original.length);
        for (uint256 i; i < original.length; i++) {
            out[i] = original[i];
        }
        bytes memory word = abi.encode(value);
        for (uint256 j; j < a.length; j++) {
            for (uint256 b; b < 32; b++) {
                out[a[j] + b] = word[b];
            }
        }
    }

    function testUnalignedOverlappingDuplicateWindowsAndPristineBytes() public view {
        bytes memory original = new bytes(70);
        for (uint256 i; i < original.length; i++) {
            original[i] = bytes1(uint8(i + 3));
        }
        uint256[] memory a = new uint256[](4);
        a[0] = 4;
        a[1] = 7;
        a[2] = 4;
        a[3] = 38;
        uint256 first = type(uint256).max - 19;
        uint256 second = 1 << 255;
        same(
            c.mapWords(abi.encode(first, second), address(hashTarget), original, a),
            abi.encode(keccak256(patch(original, a, first)), keccak256(patch(original, a, second)))
        );
    }

    function testNoElementWindowsKeepsOriginalTemplate() public view {
        uint256[] memory none = new uint256[](0);
        bytes memory original = abi.encode(uint256(19), uint256(27));
        same(
            c.mapWords(abi.encode(uint256(4), uint256(8)), address(identity), original, none),
            abi.encode(uint256(19), uint256(19))
        );
    }
}
