// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties for `tupleLayout` against an independent table:
 *         every two-component tuple over eight component shapes yields the
 *         expected spans, dynamic flags, word footprints and head size; any
 *         byte outside the descriptor alphabet is refused at its position;
 *         and the malformed shapes (stray `)`, trailing text, an empty
 *         component, a missing comma, a bare name and `()`) are refused at
 *         the documented byte. Run with `pnpm halmos`.
 * @dev No production parser computes an expectation here: the component
 *      table is written by hand. `()` is refused at position 1, not parsed
 *      as an empty layout; the callers special-case the empty tuple.
 */
contract TupleLayoutSymbolicTest is Test {
    function tupleLayoutOf(string calldata t) external pure returns (AbiCodec.TupleLayout memory) {
        return AbiCodec.tupleLayout(bytes(t));
    }

    function component(uint8 c) internal pure returns (string memory, bool, uint256) {
        if (c == 0) return ("uint8", false, 1);
        if (c == 1) return ("bytes", true, 1);
        if (c == 2) return ("uint8[2]", false, 2);
        if (c == 3) return ("(bool,address)", false, 2);
        if (c == 4) return ("(uint8,bytes)", true, 1);
        if (c == 5) return ("bytes[2]", true, 1);
        if (c == 6) return ("(uint8,bool)[2]", false, 4);
        return ("uint8[][2]", true, 1);
    }

    /**
     * @dev `(A,B)` for every pair from the component table equals the
     *      hand-written layout: starts, ends, dynamic flags, words, head size
     */
    function check_tupleLayoutSpans(uint8 first, uint8 second) public view {
        vm.assume(first < 8 && second < 8);
        (string memory a, bool ad, uint256 aw) = component(first);
        (string memory b, bool bd, uint256 bw) = component(second);
        (bool ok, bytes memory out) =
            address(this).staticcall(abi.encodeCall(this.tupleLayoutOf, (string.concat("(", a, ",", b, ")"))));
        assertTrue(ok);
        AbiCodec.TupleLayout memory got = abi.decode(out, (AbiCodec.TupleLayout));
        uint256[] memory starts = new uint256[](2);
        starts[0] = 1;
        starts[1] = bytes(a).length + 2;
        uint256[] memory ends = new uint256[](2);
        ends[0] = bytes(a).length + 1;
        ends[1] = bytes(a).length + bytes(b).length + 2;
        bool[] memory dynamic = new bool[](2);
        dynamic[0] = ad;
        dynamic[1] = bd;
        uint256[] memory words = new uint256[](2);
        words[0] = aw;
        words[1] = bw;
        assertEq(abi.encode(got), abi.encode(AbiCodec.TupleLayout(starts, ends, dynamic, words, (aw + bw) * 32)));
    }

    /**
     * @dev Every byte outside `[a-z0-9]` and the punctuation `(),[]`, placed
     *      after `(uint8`, reverts InvalidTypeDescriptor(6): uppercase,
     *      whitespace and non-ASCII included
     */
    function check_tupleLayoutInvalidCharacter(bytes1 bad) public view {
        // Any byte outside the name alphabet and descriptor punctuation.
        uint8 c = uint8(bad);
        vm.assume(!(c >= 97 && c <= 122) && !(c >= 48 && c <= 57));
        vm.assume(c != 40 && c != 41 && c != 44 && c != 91 && c != 93);
        (bool ok, bytes memory out) = address(this)
            .staticcall(abi.encodeCall(this.tupleLayoutOf, (string(bytes.concat("(uint8", bad, ",bool)")))));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(6)));
    }

    /**
     * @dev Each malformed shape reverts InvalidTypeDescriptor at its byte
     */
    function check_tupleLayoutMalformed(uint8 geometry) public view {
        vm.assume(geometry < 6);
        string memory t;
        uint256 position;
        if (geometry == 0) {
            t = "(uint8))";
            position = 6;
        } else if (geometry == 1) {
            t = "(uint8)junk";
            position = 7;
        } else if (geometry == 2) {
            t = "(uint8,,bool)";
            position = 7;
        } else if (geometry == 3) {
            t = "(uint8 bool)";
            position = 6;
        } else if (geometry == 4) {
            t = "uint8";
            position = 0;
        } else {
            t = "()";
            position = 1;
        }
        (bool ok, bytes memory out) = address(this).staticcall(abi.encodeCall(this.tupleLayoutOf, (t)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, position));
    }

    /**
     * @dev Every case on a real EVM
     */
    function test_tupleLayoutGeometries() public view {
        for (uint8 a; a < 8; a++) {
            for (uint8 b; b < 8; b++) {
                check_tupleLayoutSpans(a, b);
            }
        }
        for (uint8 g; g < 6; g++) {
            check_tupleLayoutMalformed(g);
        }
        check_tupleLayoutInvalidCharacter("A");
        check_tupleLayoutInvalidCharacter(" ");
        check_tupleLayoutInvalidCharacter("_");
        check_tupleLayoutInvalidCharacter(0x80);
        check_tupleLayoutInvalidCharacter(0xff);
    }
}
