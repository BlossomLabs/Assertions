// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../lib/AbiCodec.sol";

/**
 *  @dev Exposes the internal descriptor parser
 */
contract LengthShapeHarness {
    function shape(string calldata t) external pure returns (bool, uint256) {
        return AbiCodec.shape(bytes(t));
    }
}

/**
 * @notice Halmos property: the descriptor parser bounds fixed lengths and
 *         never panics on them. Run with `pnpm halmos`.
 * @dev Each descriptor is base[x][y] with ONE symbolic length, a concrete
 *      prefix and two symbolic digits (see digits), so this reaches the
 *      lengths ParserSymbolic's token grammar never spells: both sides of
 *      2^32 - 1, with leading zeros and far past it. The other length is a
 *      concrete case, so every footprint is a symbolic length times a
 *      constant: two symbolic lengths make the product nonlinear, and one
 *      configuration took nine minutes. An optional concrete tail of seven
 *      [4294967295] suffixes carries a product past 2^256, the overflow an
 *      unbounded multiply panics on, while every loop stays well under
 *      `--loop 70` (a path past the bound is dropped, not failed, so a
 *      78-digit length could never have shown the digit overflow). The
 *      walkers that consume an accepted length (packArray, unpackArray,
 *      nav) are swept concretely in NoPanic.t.sol: a symbolic length there
 *      becomes a symbolic copy size or a loop past the bound.
 */
contract NoPanicSymbolicTest is Test {
    uint256 constant MAX_LENGTH = type(uint32).max;
    string constant TAIL = "[4294967295][4294967295][4294967295][4294967295][4294967295][4294967295][4294967295]";

    LengthShapeHarness harness;

    /**
     * @dev One descriptor under test and what the length bound says of it
     */
    struct Case {
        string descriptor;
        bool dyn;
        uint256 words;
        bool accepted;
    }

    function setUp() public {
        harness = new LengthShapeHarness();
    }

    // ============ Shape ============

    /**
     * @dev The parser accepts exactly when each length is 1 to 2^32 - 1
     *      and every static footprint on the way is at most 2^32 - 1, agrees
     *      on the footprint, and rejects otherwise with InvalidTypeDescriptor
     */
    function check_shapeFixedLengths(
        uint8 baseCase,
        bytes32 digitBytes,
        uint8 digitCase,
        uint8 fixedCase,
        bool symbolicOuter,
        bool tail
    ) public view {
        Case memory c = build(baseCase, digitBytes, digitCase, fixedCase, symbolicOuter, tail);
        (bool ok, bytes memory out) =
            address(harness).staticcall(abi.encodeCall(LengthShapeHarness.shape, (c.descriptor)));
        assertEq(ok, c.accepted, "parser and the length bound disagree");
        if (ok) {
            (bool gotDyn, uint256 gotWords) = abi.decode(out, (bool, uint256));
            assertEq(gotDyn, c.dyn, "a fixed length changed dynamic");
            assertEq(gotWords, c.words, "parser and the length bound disagree on head words");
        } else {
            assertEq(bytes4(out), InvalidTypeDescriptor.selector, "a length rejection is not InvalidTypeDescriptor");
        }
    }

    // ============ Helpers ============

    /**
     * @dev base[x][y] plus the optional tail, where one of x and y is the
     *      symbolic length and the other the concrete case, with the
     *      reference verdict: each length 1 to 2^32 - 1 (solc refuses T[0]),
     *      and for a static base each running footprint at most 2^32 - 1
     */
    function build(uint8 baseCase, bytes32 digitBytes, uint8 digitCase, uint8 fixedCase, bool symbolicOuter, bool tail)
        internal
        pure
        returns (Case memory c)
    {
        string memory base;
        (base, c.dyn, c.words) = pickBase(baseCase);
        (bytes memory text, uint256 k) = digits(digitBytes, digitCase);
        (string memory fixedText, uint256 f) = pickFixed(fixedCase);
        string memory symbolic = string(text);
        c.descriptor = symbolicOuter
            ? string.concat(base, "[", fixedText, "][", symbolic, "]", tail ? TAIL : "")
            : string.concat(base, "[", symbolic, "][", fixedText, "]", tail ? TAIL : "");
        c.accepted = k != 0 && k <= MAX_LENGTH && f != 0 && f <= MAX_LENGTH;
        if (!c.dyn) {
            // The inner length multiplies first; both orders reach the same product.
            c.words *= symbolicOuter ? f : k;
            c.accepted = c.accepted && c.words <= MAX_LENGTH;
            c.words *= symbolicOuter ? k : f;
            c.accepted = c.accepted && c.words <= MAX_LENGTH;
            // Each tail suffix multiplies by 2^32 - 1, and no static footprint is zero.
            if (tail) c.accepted = false;
        }
    }

    function pickBase(uint8 c) internal pure returns (string memory, bool, uint256) {
        if (c == 0) return ("uint8", false, 1);
        if (c == 1) return ("string", true, 1);
        if (c == 2) return ("(bool,string)", true, 1);
        vm.assume(c == 3);
        return ("(uint256,int8)", false, 2);
    }

    function pickFixed(uint8 c) internal pure returns (string memory, uint256) {
        if (c == 0) return ("0", 0);
        if (c == 1) return ("1", 1);
        if (c == 2) return ("2", 2);
        if (c == 3) return ("4294967295", MAX_LENGTH);
        vm.assume(c == 4);
        return ("4294967296", MAX_LENGTH + 1);
    }

    /**
     * @dev A concrete prefix and two symbolic decimal digits. The prefix
     *      "42949672" puts the length at 4294967200..4294967299, straddling
     *      2^32 - 1; the others give a short length, the same straddle
     *      behind 20 leading zeros, and one that is always past the bound.
     *      Symbolic digits cost a branch each in the parser and in the
     *      reference: ten of them took two minutes for one configuration.
     */
    function digits(bytes32 d, uint8 digitCase) internal pure returns (bytes memory text, uint256 value) {
        string memory prefix;
        if (digitCase == 0) {
            prefix = "";
        } else if (digitCase == 1) {
            prefix = "42949672";
        } else if (digitCase == 2) {
            prefix = "0000000000000000000042949672";
        } else {
            vm.assume(digitCase == 3);
            prefix = "99999999999";
        }
        bytes1 a = d[0];
        bytes1 b = d[1];
        vm.assume(a >= "0" && a <= "9" && b >= "0" && b <= "9");
        text = bytes.concat(bytes(prefix), a, b);
        for (uint256 i; i < text.length; i++) {
            value = value * 10 + uint8(text[i]) - 48;
        }
    }
}
