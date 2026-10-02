// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";

/**
 * @dev Lambda targets for the word folds, maps and filters
 */
contract WordLambdas {
    /**
     * @dev Non-commutative, so the accumulator and element windows are observable
     */
    function step(uint256 acc, uint256 x) external pure returns (uint256) {
        unchecked {
            return acc * 3 + x;
        }
    }

    /**
     * @dev The accumulator becomes the element: exposes the early exits
     */
    function take(uint256, uint256 x) external pure returns (uint256) {
        return x;
    }

    /**
     * @dev `tag` lives outside every window: the result proves it stayed pristine
     */
    function mix(uint256 x, uint256 tag) external pure returns (uint256) {
        return x ^ tag;
    }

    /**
     * @dev 0 or 1 for odd; 2 when x is 5, a non-canonical predicate result
     */
    function oddOrTwo(uint256 x) external pure returns (uint256) {
        return x == 5 ? 2 : x & 1;
    }

    function boom(uint256 x) external pure returns (uint256) {
        if (x == 7) revert("seven");
        return x;
    }

    /**
     * @dev Returns two words: not a single-word lambda
     */
    function wide(uint256 x) external pure returns (uint256, uint256) {
        return (x, x);
    }
}

/**
 * @notice Halmos properties for the word-lambda operations: foldRange,
 *         foldBytes, foldWords, mapWords and filterWords, their exits, their
 *         window rules and their error surface. Run with `pnpm halmos`.
 * @dev Up to three symbolic words or bytes; counts and offsets are
 *      case-split. Every call expected to succeed checks its success
 *      explicitly: Halmos discards reverting paths.
 */
contract WordLambdasSymbolicTest is Test {
    Collections collections;
    WordLambdas lambdas;

    uint8 constant FULL = 0;
    uint8 constant ANY = 1;
    uint8 constant ALL = 2;

    function setUp() public {
        collections = new Collections();
        lambdas = new WordLambdas();
    }

    // ============ Folds ============

    /**
     * @dev foldWords is a left fold: accumulator window at 4, element at 36
     */
    function check_foldWordsIsLeftFold(uint8 countCase, bytes32[3] memory w, bytes32 init) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        uint256 expected = uint256(init);
        for (uint256 i; i < n; i++) {
            unchecked {
                expected = expected * 3 + uint256(w[i]);
            }
        }
        bytes32 got = fold(
            abi.encodeCall(
                Collections.foldWords,
                (s, address(lambdas), stepTemplate(), 4, offsets(36), init, Collections.FoldExit.Full)
            )
        );
        assertEq(uint256(got), expected);
    }

    /**
     * @dev foldRange substitutes the index, foldBytes the byte value
     */
    function check_foldRangeAndBytes(uint8 countCase, bytes3 raw, bytes32 init) public view {
        vm.assume(countCase < 4);
        uint256 n = countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : 3;
        uint256 byIndex = uint256(init);
        uint256 byByte = uint256(init);
        bytes memory s = abi.encodePacked(raw);
        assembly ("memory-safe") { mstore(s, n) }
        for (uint256 i; i < n; i++) {
            unchecked {
                byIndex = byIndex * 3 + i;
                byByte = byByte * 3 + uint8(raw[i]);
            }
        }
        bytes32 got = fold(
            abi.encodeCall(
                Collections.foldRange,
                (n, address(lambdas), stepTemplate(), 4, offsets(36), init, Collections.FoldExit.Full)
            )
        );
        assertEq(uint256(got), byIndex, "foldRange");
        got = fold(
            abi.encodeCall(
                Collections.foldBytes,
                (s, address(lambdas), stepTemplate(), 4, offsets(36), init, Collections.FoldExit.Full)
            )
        );
        assertEq(uint256(got), byByte, "foldBytes");
    }

    /**
     * @dev With acc' = element: Full ends on the last element, Any stops at
     *      the first nonzero, All at the first zero; an empty domain is init
     */
    function check_foldExits(uint8 countCase, bytes32[3] memory w, bytes32 init, uint8 exitCase) public view {
        vm.assume(exitCase < 3);
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes32 expected = init;
        for (uint256 i; i < n; i++) {
            expected = w[i];
            if (exitCase == ANY && expected != bytes32(0)) break;
            if (exitCase == ALL && expected == bytes32(0)) break;
        }
        Collections.FoldExit exit = exitCase == FULL
            ? Collections.FoldExit.Full
            : exitCase == ANY ? Collections.FoldExit.Any : Collections.FoldExit.All;
        bytes32 got = fold(
            abi.encodeCall(
                Collections.foldWords,
                (s, address(lambdas), abi.encodeCall(WordLambdas.take, (0, 0)), 4, offsets(36), init, exit)
            )
        );
        assertEq(got, expected);
    }

    /**
     * @dev The element window wins where it overlaps the accumulator's
     */
    function check_elementWinsOverlap(bytes32 w, bytes32 init) public view {
        bytes memory s = abi.encodePacked(w);
        uint256[] memory both = new uint256[](2);
        both[0] = 4;
        both[1] = 36;
        bytes32 got = fold(
            abi.encodeCall(
                Collections.foldWords, (s, address(lambdas), stepTemplate(), 4, both, init, Collections.FoldExit.Full)
            )
        );
        unchecked {
            assertEq(uint256(got), uint256(w) * 3 + uint256(w));
        }
    }

    // ============ Maps and filters ============

    /**
     * @dev Bytes outside the windows stay pristine template: the tag reaches every call
     */
    function check_mapWordsKeepsTemplatePristine(uint8 countCase, bytes32[3] memory w, uint256 tag) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes memory out = abi.decode(
            call(
                abi.encodeCall(
                    Collections.mapWords, (s, address(lambdas), abi.encodeCall(WordLambdas.mix, (0, tag)), offsets(4))
                )
            ),
            (bytes)
        );
        assertEq(out.length, n * 32);
        for (uint256 i; i < n; i++) {
            assertEq(word(out, i), uint256(w[i]) ^ tag);
        }
    }

    /**
     * @dev filterWords keeps the elements whose result is 1, in order, and
     *      refuses any result other than a canonical 0 or 1
     */
    function check_filterWordsNeedsCanonicalBool(uint8 countCase, bytes32[3] memory w) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.filterWords,
                    (s, address(lambdas), abi.encodeCall(WordLambdas.oddOrTwo, (0)), offsets(4))
                )
            );
        uint256 five = type(uint256).max;
        for (uint256 i; i < n && five == type(uint256).max; i++) {
            if (uint256(w[i]) == 5) five = i;
        }
        if (five != type(uint256).max) {
            assertFalse(ok, "a result of 2 is read as true");
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    Collections.filterWords.selector,
                    five,
                    uint256(0),
                    address(lambdas)
                )
            );
            return;
        }
        assertTrue(ok, "filterWords reverted on canonical results");
        bytes memory kept = abi.decode(out, (bytes));
        uint256 k;
        for (uint256 i; i < n; i++) {
            if (uint256(w[i]) & 1 == 1) assertEq(word(kept, k++), uint256(w[i]));
        }
        assertEq(kept.length, k * 32, "an even word was kept");
    }

    // ============ Errors ============

    /**
     * @dev Windows are validated even on an empty domain; a code-less target
     *      is refused before the first call; a revert surfaces as
     *      CallbackFailed naming the element with its calldata and reason; a
     *      return other than one word is InvalidCallbackResult
     */
    function check_lambdaErrors(uint8 caseId, bytes32[3] memory w, uint8 countCase) public view {
        vm.assume(caseId < 4);
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes memory data;
        bytes memory want;
        bool shouldFail;
        if (caseId == 0) {
            // A window past the template, even with nothing to fold.
            data = abi.encodeCall(
                Collections.foldWords,
                (s, address(lambdas), stepTemplate(), 4, offsets(60), bytes32(0), Collections.FoldExit.Full)
            );
            want = abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(60), uint256(68));
            shouldFail = true;
        } else if (caseId == 1) {
            data = abi.encodeCall(
                Collections.mapWords, (s, address(0xE0A), abi.encodeCall(WordLambdas.boom, (0)), offsets(4))
            );
            want = abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0xE0A));
            shouldFail = n != 0;
        } else if (caseId == 2) {
            data = abi.encodeCall(
                Collections.mapWords, (s, address(lambdas), abi.encodeCall(WordLambdas.boom, (0)), offsets(4))
            );
            uint256 seven = type(uint256).max;
            for (uint256 i; i < n && seven == type(uint256).max; i++) {
                if (uint256(w[i]) == 7) seven = i;
            }
            shouldFail = seven != type(uint256).max;
            want = abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                Collections.mapWords.selector,
                seven,
                uint256(0),
                address(lambdas),
                abi.encodeCall(WordLambdas.boom, (uint256(7))),
                abi.encodeWithSignature("Error(string)", "seven")
            );
        } else {
            data = abi.encodeCall(
                Collections.mapWords, (s, address(lambdas), abi.encodeCall(WordLambdas.wide, (0)), offsets(4))
            );
            want = abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                Collections.mapWords.selector,
                uint256(0),
                uint256(0),
                address(lambdas)
            );
            shouldFail = n != 0;
        }
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        // Halmos has no gas model: exclude the symbolic exhaustion artifact.
        // Concrete GasPropagationTest sweeps establish gas behavior separately.
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Collections.SubcallOutOfGas.selector)));
        if (shouldFail) {
            assertFalse(ok, "an invalid lambda operation passes");
            assertEq(out, want);
        } else {
            assertTrue(ok, "a valid lambda operation reverts");
        }
    }

    // ============ Harness ============

    function stepTemplate() internal pure returns (bytes memory) {
        return abi.encodeCall(WordLambdas.step, (0, 0));
    }

    function offsets(uint256 a) internal pure returns (uint256[] memory o) {
        o = new uint256[](1);
        o[0] = a;
    }

    function call(bytes memory data) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = address(collections).staticcall(data);
        assertTrue(ok, "reverted on valid input");
    }

    function fold(bytes memory data) internal view returns (bytes32) {
        return abi.decode(call(data), (bytes32));
    }

    function payload(uint8 countCase, bytes32[3] memory w) internal pure returns (bytes memory s, uint256 n) {
        vm.assume(countCase < 4);
        n = countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : 3;
        s = abi.encodePacked(w);
        assembly ("memory-safe") { mstore(s, mul(n, 32)) }
    }

    function word(bytes memory s, uint256 i) internal pure returns (uint256 v) {
        assembly ("memory-safe") { v := mload(add(add(s, 32), mul(i, 32))) }
    }
}
