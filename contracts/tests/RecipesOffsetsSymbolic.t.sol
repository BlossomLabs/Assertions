// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import {Operations} from "../Operations.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties for the documented recipes and for exact error
 *         offsets: the signed-sort recipe, sumWords against its foldWords
 *         recipe, typed Operations parameters reached through the core, and
 *         the byte offsets InvalidValue, InvalidComponentValue and
 *         InvalidTypeDescriptor report. Run with `pnpm halmos`.
 * @dev Reported offsets are checked rather than recomputed where recomputing
 *      would branch on every byte. Halmos has no gas model, so the out-of-gas
 *      guard's SubcallOutOfGas can fire on any failing subcall it explores;
 *      that outcome is discarded (see outOfGasArtifact).
 */
contract RecipesOffsetsSymbolicTest is Test {
    uint256 constant SIGN = 1 << 255;

    Assertions core;
    Collections collections;
    Operations ops;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        ops = new Operations();
    }

    // ============ Recipes ============

    /**
     * @dev The documented signed sort: flip the sign bit with mapWords(bitXor),
     *      sortWords, flip back, over three symbolic words, equals the words
     *      in ascending int256 order. Two mapWords passes around a sort need
     *      more than the default solver limit.
     * @custom:halmos --solver-timeout-assertion 300000
     */
    function check_signedSortRecipe(int256 a, int256 b, int256 c) public view {
        bytes memory words = abi.encodePacked(a, b, c);
        bytes memory template = abi.encodeCall(Operations.bitXor, (uint256(0), SIGN));
        uint256[] memory offsets = new uint256[](1);
        offsets[0] = 4;
        bytes memory flipped = mapWords(words, template, offsets);
        (bool ok, bytes memory out) = address(collections).staticcall(abi.encodeCall(Collections.sortWords, (flipped)));
        assertTrue(ok);
        bytes memory sorted = mapWords(abi.decode(out, (bytes)), template, offsets);
        // Reference: a three-element sorting network over int256.
        if (a > b) (a, b) = (b, a);
        if (b > c) (b, c) = (c, b);
        if (a > b) (a, b) = (b, a);
        assertEq(sorted, abi.encodePacked(a, b, c), "the recipe is not a signed sort");
    }

    function mapWords(bytes memory words, bytes memory template, uint256[] memory offsets)
        internal
        view
        returns (bytes memory)
    {
        (bool ok, bytes memory out) = address(collections)
            .staticcall(abi.encodeCall(Collections.applyWords, (words, address(ops), template, offsets, false)));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "mapWords refused the recipe");
        return abi.decode(out, (bytes));
    }

    /**
     * @dev sumWords and the foldWords(add) recipe agree over three words: the
     *      same checked sum, and both refuse an overflow (a Panic from
     *      sumWords, the lambda's Panic wrapped in CallbackFailed from the fold)
     */
    function check_sumWordsMatchesTheFoldRecipe(uint256 a, uint256 b, uint256 c) public view {
        bytes memory words = abi.encodePacked(a, b, c);
        (bool sumOk, bytes memory sumOut) =
            address(collections).staticcall(abi.encodeCall(Collections.sumWords, (words)));
        uint256[] memory elem = new uint256[](1);
        elem[0] = 36;
        (bool foldOk, bytes memory foldOut) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.fold,
                    (
                        Collections.FoldDomain.Words,
                        0,
                        words,
                        address(ops),
                        abi.encodeWithSignature("add(uint256,uint256)", 0, 0),
                        4,
                        elem,
                        bytes32(0),
                        Collections.FoldExit.Full
                    )
                )
            );
        vm.assume(!outOfGasArtifact(foldOk, foldOut));
        assertEq(sumOk, foldOk, "sumWords and the fold recipe disagree on overflow");
        bool overflows = a > type(uint256).max - b || a + b > type(uint256).max - c;
        assertEq(sumOk, !overflows);
        if (sumOk) {
            assertEq(abi.decode(sumOut, (uint256)), abi.decode(foldOut, (uint256)));
        } else {
            assertEq(sumOut, abi.encodeWithSignature("Panic(uint256)", uint256(0x11)));
            assertEq(bytes4(foldOut), Collections.CallbackFailed.selector);
        }
    }

    // ============ Typed Operations parameters through the core ============

    /**
     * @dev A dirty word spliced into a typed Operations parameter fails the
     *      callee's ABI decoding, which the core reports as CallFailed with
     *      the exact calldata
     */
    function check_dirtyWordIntoTypedParameterIsCallFailed(bytes32 w) public view {
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(abi.encode(w));
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(Assertions.read, (raw(abi.encode(address(ops))), Operations.balance.selector, args))
            );
        vm.assume(!outOfGasArtifact(ok, out));
        if (uint256(w) >> 160 != 0) {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    CallFailed.selector, address(ops), abi.encodePacked(Operations.balance.selector, w)
                )
            );
        } else {
            assertTrue(ok, "a clean address word was refused");
        }
    }

    /**
     * @dev A string operand's resolved envelope splices into a bytes parameter
     *      unchanged, so byteLen sees the decoded payload
     */
    function check_stringEnvelopeSplicesIntoBytesParameters(bytes32 content, uint8 lengthCase) public view {
        uint256 length;
        if (lengthCase == 0) {
            length = 0;
        } else if (lengthCase == 1) {
            length = 5;
        } else {
            vm.assume(lengthCase == 2);
            length = 32;
        }
        bytes memory payload = abi.encodePacked(content);
        assembly ("memory-safe") { mstore(payload, length) }
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(abi.encode(string(payload)));
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(Assertions.read, (raw(abi.encode(address(ops))), Operations.byteLen.selector, args))
            );
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok);
        assertEq(abi.decode(out, (uint256)), length);
    }

    // ============ Error offsets ============

    /**
     * @dev InvalidValue names the byte offset of the first out-of-range word:
     *      unpackArray over three uint8 elements reports 64 + 32k for the
     *      first element k above 255
     */
    function check_invalidValueNamesTheWord(bytes32[3] memory w) public view {
        bytes memory encoded = abi.encodePacked(uint256(32), uint256(3), w);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("uint8", encoded)));
        uint256 bad = 3;
        if (uint256(w[2]) > 255) bad = 2;
        if (uint256(w[1]) > 255) bad = 1;
        if (uint256(w[0]) > 255) bad = 0;
        if (bad == 3) {
            assertTrue(ok);
        } else {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 64 + 32 * bad));
        }
    }

    /**
     * @dev InvalidComponentValue names the component and the byte offset
     *      inside it: encode("(uint256,uint8[])") over a two-element array
     *      argument reports (1, 64 + 32k) for its first element k above 255
     */
    function check_invalidComponentValueNamesTheWord(uint256 first, bytes32[2] memory e) public view {
        bytes[] memory args = new bytes[](2);
        args[0] = abi.encode(first);
        args[1] = abi.encodePacked(uint256(32), uint256(2), e);
        (bool ok, bytes memory out) =
            address(ops).staticcall(abi.encodeCall(Operations.encodeBytes, ("(uint256,uint8[])", args)));
        uint256 bad = 2;
        if (uint256(e[1]) > 255) bad = 1;
        if (uint256(e[0]) > 255) bad = 0;
        if (bad == 2) {
            assertTrue(ok);
        } else {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), 64 + 32 * bad));
        }
    }

    /**
     * @dev An oversized fixed length is refused at the byte right after the
     *      digit that carries its value past 2^32 - 1: uint8[d0..d10] with
     *      eleven symbolic digits, the position checked against the prefixes
     *      rather than recomputed. A zero length is refused at the bracket.
     */
    function check_oversizedLengthNamesItsDigit(uint8[11] memory d) public view {
        bytes memory text = "uint8[";
        for (uint256 i; i < 11; i++) {
            vm.assume(d[i] < 10);
            text = bytes.concat(text, bytes1(0x30 + d[i]));
        }
        text = bytes.concat(text, "]");
        bytes[] memory none = new bytes[](0);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.packArray, (string(text), none)));
        uint256 value;
        for (uint256 i; i < 11; i++) {
            value = value * 10 + d[i];
        }
        if (value == 0) {
            // A zero length is refused too (solc refuses T[0]), at the closing bracket.
            assertEq(out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(17)));
            return;
        }
        if (value <= type(uint32).max) {
            assertTrue(ok);
            return;
        }
        assertFalse(ok);
        assertEq(bytes4(out), InvalidTypeDescriptor.selector);
        uint256 position = abi.decode(slice(out, 4), (uint256));
        // Digits start at byte 6. The digits before `position` carry the value
        // past the bound, the digits before the last of them do not.
        uint256 m = position - 6;
        assertTrue(m >= 1 && m <= 11, "the position is outside the digits");
        uint256 prefix;
        for (uint256 i; i < m; i++) {
            prefix = prefix * 10 + d[i];
        }
        assertGt(prefix, type(uint32).max, "reported before the value crossed the bound");
        assertLe((prefix - d[m - 1]) / 10, type(uint32).max, "reported after the crossing digit");
    }

    // ============ Harness ============

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function slice(bytes memory b, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(b.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = b[from + i];
        }
    }

    /**
     * @dev Halmos has no gas model: gasleft() is a fresh symbol, so the
     *      out-of-gas guard can fire on any failing subcall it explores, which
     *      no real execution takes. That outcome is discarded.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
    }
}
