// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @notice Thrown when an ABI type descriptor cannot be parsed: an empty or
 *         non-tuple descriptor, an unknown character where a type was
 *         expected, an unterminated array suffix, or trailing garbage
 * @param position The byte position in the descriptor where parsing failed
 */
error InvalidTypeDescriptor(uint256 position);

/**
 * @notice Thrown when an element index is outside the tuple or array it
 *         indexes into (in either direction for negative array indices)
 * @param index The requested element index, as given (may be negative)
 * @param count The number of components / elements available
 */
error ElementIndexOutOfBounds(int256 index, uint256 count);

/**
 * @title AbiShape
 * @author Sembrestels
 * @notice Shape-level grammar for ABI type descriptors written as
 *         parenthesized tuples, e.g. "(uint112,uint112,address)" or
 *         "(address,address[][])" (structs as parenthesized tuples). Only
 *         the SHAPE of a descriptor is parsed — dynamic vs static and head
 *         footprints; base type names beyond bytes/string are not
 *         interpreted.
 * @dev Shared vocabulary between the Assertions core (typed navigation) and
 *      the Operators periphery (runtime encoding). Deliberately free of any
 *      ERC-8211 coupling so either side imports it alone. Grammar: tuple
 *      `( type {"," type} )`, base identifier (bytes/string are dynamic,
 *      anything else is one static word), then any number of `[]` / `[k]`
 *      suffixes, the outermost binding last.
 */
library AbiShape {
    /**
     * @dev Parses the SHAPE of the type starting at `p` (bounded by `limit`):
     *      where it ends, whether it is dynamic, and its head footprint in
     *      words (1 for dynamic values — their head word is an offset).
     *      Reverts with InvalidTypeDescriptor at the offending position on
     *      any malformed descriptor.
     */
    function typeShape(bytes calldata t, uint256 p, uint256 limit) internal pure returns (uint256 end, bool dyn, uint256 words) {
        if (p >= limit) revert InvalidTypeDescriptor(p);
        if (t[p] == "(") {
            uint256 q = p + 1;
            uint256 sum;
            while (true) {
                (uint256 e, bool d, uint256 w) = typeShape(t, q, limit);
                if (d) dyn = true;
                sum += w;
                if (e >= limit) revert InvalidTypeDescriptor(e);
                if (t[e] == ",") {
                    q = e + 1;
                    continue;
                }
                if (t[e] == ")") {
                    end = e + 1;
                    break;
                }
                revert InvalidTypeDescriptor(e);
            }
            words = dyn ? 1 : sum;
        } else {
            uint256 q = p;
            while (q < limit && ((t[q] >= "a" && t[q] <= "z") || (t[q] >= "0" && t[q] <= "9"))) {
                q++;
            }
            if (q == p) revert InvalidTypeDescriptor(p);
            dyn = (q - p == 5 && t[p] == "b" && t[p + 1] == "y" && t[p + 2] == "t" && t[p + 3] == "e" && t[p + 4] == "s")
                || (q - p == 6 && t[p] == "s" && t[p + 1] == "t" && t[p + 2] == "r" && t[p + 3] == "i" && t[p + 4] == "n" && t[p + 5] == "g");
            words = 1;
            end = q;
        }
        while (end < limit && t[end] == "[") {
            uint256 q2 = end + 1;
            uint256 k;
            bool fixedSize;
            while (q2 < limit && t[q2] >= "0" && t[q2] <= "9") {
                k = k * 10 + (uint8(t[q2]) - 48);
                fixedSize = true;
                q2++;
            }
            if (q2 >= limit || t[q2] != "]") revert InvalidTypeDescriptor(q2);
            if (fixedSize) {
                if (!dyn) words = words * k;
            } else {
                dyn = true;
                words = 1;
            }
            end = q2 + 1;
        }
    }

    /**
     * @dev Position of the `[` opening the LAST suffix of the array type at
     *      [ts, te) — the outermost constructor (te - 1 must be `]`)
     */
    function suffixStart(bytes calldata t, uint256 ts, uint256 te) internal pure returns (uint256 j) {
        j = te - 2;
        while (j > ts && t[j] >= "0" && t[j] <= "9") {
            j--;
        }
        if (t[j] != "[") revert InvalidTypeDescriptor(j);
    }

    /**
     * @dev Normalizes a signed index against `count`, reverting with
     *      ElementIndexOutOfBounds outside -count .. count-1
     */
    function normalizeIndex(int256 index, uint256 count) internal pure returns (uint256) {
        if (index < 0) {
            // index == type(int256).min is caught here before -index could overflow.
            if (index < -int256(count)) revert ElementIndexOutOfBounds(index, count);
            return count - uint256(-index);
        }
        if (uint256(index) >= count) revert ElementIndexOutOfBounds(index, count);
        return uint256(index);
    }
}
