// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";

/**
 * @notice Halmos properties for the Collections word-payload operations,
 *         stated as specifications rather than re-implementations: sorted
 *         permutation, reversal, zip/unzip inverses, first-occurrence
 *         dedup, least index, exact checked sum. Run with `pnpm halmos`.
 * @dev Every call expected to succeed goes through `ok`, which fails the
 *      property on a revert: Halmos discards reverting paths, so a direct call
 *      would let a bug that reverts on valid input pass unseen. Up to four
 *      symbolic words; byte lengths are case-split, unaligned
 *      ones included, so every operation's UnalignedWords guard is covered.
 */
contract WordsSymbolicTest is Test {
    Collections collections;

    function setUp() public {
        collections = new Collections();
    }

    function check_sortWordsIsSortedPermutation(uint8 countCase, bytes32[4] memory w) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes memory out = ok(abi.encodeCall(Collections.sortWords, (s)));
        assertEq(out.length, s.length);
        for (uint256 i = 1; i < n; i++) {
            assertLe(uint256(at(out, i - 1)), uint256(at(out, i)), "not ascending");
        }
        for (uint256 i; i < n; i++) {
            assertEq(occurrences(out, n, at(s, i)), occurrences(s, n, at(s, i)), "not a permutation");
        }
    }

    function check_reverseWords(uint8 countCase, bytes32[4] memory w) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes memory out = ok(abi.encodeCall(Collections.reverseWords, (s)));
        assertEq(out.length, s.length);
        for (uint256 i; i < n; i++) {
            assertEq(at(out, i), at(s, n - 1 - i));
        }
    }

    function check_zipUnzipAreInverse(uint8 countCase, bytes32[4] memory a, bytes32[4] memory b) public view {
        (bytes memory sa,) = payload(countCase, a);
        (bytes memory sb,) = payload(countCase, b);
        bytes memory zipped = ok(abi.encodeCall(Collections.zipWords, (sa, sb)));
        assertEq(zipped.length, sa.length * 2);
        assertEq(ok(abi.encodeCall(Collections.unzipWords, (zipped, 0))), sa);
        assertEq(ok(abi.encodeCall(Collections.unzipWords, (zipped, 1))), sb);
    }

    function check_zipRejectsMismatchAndUnzipBadLane(uint8 aCase, uint8 bCase, uint256 lane, bytes32[4] memory w)
        public
        view
    {
        (bytes memory sa, uint256 na) = payload(aCase, w);
        (bytes memory sb, uint256 nb) = payload(bCase, w);
        vm.assume(na != nb);
        (bool ok, bytes memory out) = address(collections).staticcall(abi.encodeCall(Collections.zipWords, (sa, sb)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Collections.WordCountMismatch.selector, na, nb));
        vm.assume(lane > 1);
        (ok, out) = address(collections).staticcall(abi.encodeCall(Collections.unzipWords, (sa, lane)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Collections.InvalidLane.selector, lane));
    }

    /**
     * @dev An odd count leaves the extra word in lane 0
     */
    function check_unzipLanes(uint8 countCase, bytes32[4] memory w) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes memory lane0 = ok(abi.encodeCall(Collections.unzipWords, (s, 0)));
        bytes memory lane1 = ok(abi.encodeCall(Collections.unzipWords, (s, 1)));
        assertEq(lane0.length / 32, (n + 1) / 2);
        assertEq(lane1.length / 32, n / 2);
        for (uint256 i; i < n; i++) {
            assertEq(at(i % 2 == 0 ? lane0 : lane1, i / 2), at(s, i));
        }
    }

    function check_uniqueWordsKeepsFirstOccurrences(uint8 countCase, bytes32[4] memory w) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        bytes memory out = ok(abi.encodeCall(Collections.uniqueWords, (s, false)));
        uint256 k;
        for (uint256 i; i < n; i++) {
            if (firstIndex(s, n, at(s, i)) == i) {
                assertEq(at(out, k), at(s, i), "a first occurrence is missing or misplaced");
                k++;
            }
        }
        assertEq(out.length, k * 32, "duplicates kept");
        // Declared ordered, a sorted payload gives the same answer.
        bytes memory sorted = ok(abi.encodeCall(Collections.sortWords, (s)));
        assertEq(
            ok(abi.encodeCall(Collections.uniqueWords, (sorted, true))),
            ok(abi.encodeCall(Collections.uniqueWords, (sorted, false)))
        );
    }

    function check_wordIndexOfIsLeastIndex(uint8 countCase, bytes32[4] memory w, bytes32 needle) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        uint256 got = abi.decode(call(abi.encodeCall(Collections.wordIndexOf, (s, needle))), (uint256));
        assertLe(got, n);
        for (uint256 j; j < got; j++) {
            assertTrue(at(s, j) != needle, "an earlier match was skipped");
        }
        if (got < n) assertEq(at(s, got), needle, "the index does not match");
    }

    function check_sumWordsIsExactOrReverts(uint8 countCase, bytes32[4] memory w) public view {
        (bytes memory s, uint256 n) = payload(countCase, w);
        uint256 low;
        uint256 carry;
        for (uint256 i; i < n; i++) {
            unchecked {
                uint256 next = low + uint256(at(s, i));
                if (next < low) carry++;
                low = next;
            }
        }
        (bool ok, bytes memory out) = address(collections).staticcall(abi.encodeCall(Collections.sumWords, (s)));
        if (carry == 0) {
            assertTrue(ok, "an in-range sum reverts");
            assertEq(abi.decode(out, (uint256)), low);
        } else {
            assertFalse(ok, "an overflowing sum returns");
        }
    }

    /**
     * @dev Every word operation refuses a payload that is not whole words
     */
    function check_unalignedPayloadsRevert(uint8 lengthCase, bytes32[4] memory w, uint8 op) public view {
        vm.assume(lengthCase < 4 && op < 7);
        uint256 length = lengthCase == 0 ? 1 : lengthCase == 1 ? 31 : lengthCase == 2 ? 33 : 127;
        bytes memory s = abi.encodePacked(w);
        assembly ("memory-safe") { mstore(s, length) }
        bytes memory call;
        if (op == 0) call = abi.encodeCall(Collections.sortWords, (s));
        else if (op == 1) call = abi.encodeCall(Collections.reverseWords, (s));
        else if (op == 2) call = abi.encodeCall(Collections.zipWords, (s, s));
        else if (op == 3) call = abi.encodeCall(Collections.unzipWords, (s, 0));
        else if (op == 4) call = abi.encodeCall(Collections.uniqueWords, (s, false));
        else if (op == 5) call = abi.encodeCall(Collections.wordIndexOf, (s, bytes32(0)));
        else call = abi.encodeCall(Collections.sumWords, (s));
        (bool ok, bytes memory out) = address(collections).staticcall(call);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Collections.UnalignedWords.selector, length));
    }

    function check_iotaWords(uint8 countCase) public view {
        vm.assume(countCase < 5);
        uint256 n = countCase;
        bytes memory out =
            ok(abi.encodeCall(Collections.iotaWords, (n == 0 ? 0 : n == 1 ? 1 : n == 2 ? 2 : n == 3 ? 3 : 4)));
        assertEq(out.length, n * 32);
        for (uint256 i; i < n; i++) {
            assertEq(uint256(at(out, i)), i);
        }
    }

    // ============ Harness ============

    /**
     * @dev The raw returndata of a call that must succeed
     */
    function call(bytes memory data) internal view returns (bytes memory out) {
        bool success;
        (success, out) = address(collections).staticcall(data);
        assertTrue(success, "reverted on a valid payload");
    }

    /**
     * @dev The decoded bytes result of a call that must succeed
     */
    function ok(bytes memory data) internal view returns (bytes memory) {
        return abi.decode(call(data), (bytes));
    }

    /**
     * @dev The first 0..4 words of `w` as a payload, the count a literal per path
     */
    function payload(uint8 countCase, bytes32[4] memory w) internal pure returns (bytes memory s, uint256 n) {
        vm.assume(countCase < 5);
        n = countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : countCase == 3 ? 3 : 4;
        s = abi.encodePacked(w);
        assembly ("memory-safe") { mstore(s, mul(n, 32)) }
    }

    function at(bytes memory s, uint256 i) internal pure returns (bytes32 v) {
        assembly ("memory-safe") { v := mload(add(add(s, 32), mul(i, 32))) }
    }

    function occurrences(bytes memory s, uint256 n, bytes32 v) internal pure returns (uint256 c) {
        for (uint256 i; i < n; i++) {
            if (at(s, i) == v) c++;
        }
    }

    function firstIndex(bytes memory s, uint256 n, bytes32 v) internal pure returns (uint256) {
        for (uint256 i; i < n; i++) {
            if (at(s, i) == v) return i;
        }
        return n;
    }
}
