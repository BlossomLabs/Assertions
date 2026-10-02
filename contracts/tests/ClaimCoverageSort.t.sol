// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import {ClaimGapComparator} from "./ClaimEvidenceGaps.t.sol";

/// @dev Finite comparison observations, not a universal asymptotic or scratch-space proof.
contract ClaimCoverageSortTest is Test {
    function test_L23_OddLengthsReverseAndDuplicateComparisonCounts() public {
        Collections col = new Collections();
        uint256[7] memory sizes = [uint256(3), 5, 7, 9, 17, 31, 63];
        for (uint256 z; z < sizes.length; z++) {
            for (uint256 pattern; pattern < 3; pattern++) {
                uint256 n = sizes[z];
                Collections.Callback memory cb;
                cb.target = address(new ClaimGapComparator());
                cb.selector = ClaimGapComparator.compare.selector;
                cb.arguments = "(uint256,uint256)";
                cb.constants = new bytes[](2);
                cb.second = 1;
                bytes[] memory values = new bytes[](n);
                bytes memory words;
                bytes memory expected;
                for (uint256 i; i < n; i++) {
                    uint256 value = pattern == 0 ? i : pattern == 1 ? n - 1 - i : 0;
                    values[i] = abi.encode(value);
                    words = bytes.concat(words, values[i]);
                    expected = bytes.concat(expected, abi.encode(pattern == 2 ? uint256(0) : i));
                }
                uint256 count;
                uint256 levels;
                // In monotone runs comparisons exhaust one side of each merge.
                for (uint256 width = 1; width < n; width *= 2) {
                    levels++;
                    for (uint256 start; start + width < n; start += 2 * width) {
                        uint256 right = n - start - width;
                        count += pattern == 1 && right < width ? right : width;
                    }
                }
                assertLe(count, n * levels);
                vm.expectCall(cb.target, abi.encodePacked(cb.selector), uint64(count));
                bytes[] memory sorted = col.sortValues("uint256", values, cb);
                bytes memory result;
                for (uint256 i; i < n; i++) {
                    result = bytes.concat(result, sorted[i]);
                }
                assertEq(result, expected);
                assertEq(col.sortWords(words), expected);
            }
        }
    }
}
