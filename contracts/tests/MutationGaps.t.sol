// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import "../Operations.sol";
import "../Expressions.sol";
import "../lib/AbiCodec.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";

/**
 * @dev Callback targets for the gap tests
 */
contract GapLambdas {
    function id(uint256 x) external pure returns (uint256) {
        return x;
    }

    function odd(uint256 x) external pure returns (bool) {
        return x & 1 == 1;
    }

    function add(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }

    function same(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }

    /**
     * @dev A predicate that answers with two words
     */
    function wide(uint256 x) external pure returns (uint256, uint256) {
        return (x & 1, 0);
    }
}

/**
 * @notice Concrete tests closing the gaps a Gambit mutation pass found: each
 *         pins a behaviour that some surviving mutant changed while every
 *         other test and Halmos property still passed. The mutant each test
 *         kills is named in its comment (Gambit ids per contract).
 */
contract MutationGapsTest is Test {
    Collections collections;
    Operations ops;
    Expressions xp;
    Assertions core;
    GapLambdas lambdas;

    uint256 constant DIRTY = 0x100;

    function setUp() public {
        collections = new Collections();
        ops = new Operations();
        xp = new Expressions();
        core = new Assertions();
        lambdas = new GapLambdas();
    }

    // ============ Codec: static length and dynamic form (AbiCodec #295, #294) ============

    function test_packRejectsStaticValueOfWrongLength() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1), uint256(2));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        collections.packArray("uint256", values);
    }

    function test_packRejectsMalformedDynamicValue() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(0x40), uint256(3), bytes32("abc"));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        collections.packArray("string", values);
    }

    // ============ Codec: range checks through nesting (AbiCodec #216, #237) ============

    /**
     * @dev A tuple array inside a tuple: the component after it sits past both copies
     */
    function test_rangeCheckAfterNestedTupleArray() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1), uint256(2), DIRTY);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        collections.packArray("((uint8)[2],uint8)", values);
    }

    /**
     * @dev A two-digit fixed size: the dirty word is the tenth
     */
    function test_rangeCheckInTwoDigitFixedArray() public {
        uint256[10] memory words;
        words[9] = DIRTY;
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(words);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(9 * 32)));
        collections.packArray("uint8[10]", values);
    }

    // ============ Codec: stray parenthesis (AbiCodec #737) ============

    function test_encodeRejectsStrayParenthesis() public {
        bytes[] memory args = new bytes[](1);
        args[0] = abi.encode(uint256(1));
        // The last byte is read as the tuple's own ")", so the first one, at 8, closes nothing.
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        ops.encodeBytes("(uint256))", args);
        // Two faults: the parse reports the first it reaches, the empty "()" at 2, not the stray at 3.
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(2)));
        ops.encodeBytes("(()))", args);
    }

    // ============ Collections: every traversal validates its inputs ============

    function unary(bytes4 selector) internal view returns (Collections.Callback memory) {
        return Collections.Callback(address(lambdas), selector, "(uint256)", new bytes[](1), 0, 0, "");
    }

    function binary(bytes4 selector) internal view returns (Collections.Callback memory) {
        return Collections.Callback(address(lambdas), selector, "(uint256,uint256)", new bytes[](2), 0, 1, "");
    }

    function dirtyList() internal pure returns (bytes[] memory v) {
        v = new bytes[](2);
        v[0] = abi.encode(uint256(1));
        v[1] = abi.encode(DIRTY);
    }

    /**
     * @dev Collections #435, #437, #426, #618, #537, #605: a dirty uint8 input is refused everywhere
     */
    function test_traversalsValidateNarrowInputs() public {
        bytes memory invalid = abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0));
        vm.expectRevert(invalid);
        collections.foldValues("uint8", "uint256", dirtyList(), abi.encode(uint256(0)), binary(GapLambdas.add.selector));
        vm.expectRevert(invalid);
        collections.foldValues("uint256", "uint8", new bytes[](0), abi.encode(DIRTY), binary(GapLambdas.add.selector));
        vm.expectRevert(invalid);
        collections.filterValues("uint8", dirtyList(), unary(GapLambdas.odd.selector));
        vm.expectRevert(invalid);
        collections.indexOfValues("uint8", new bytes[](0), abi.encode(DIRTY), binary(GapLambdas.same.selector));
        vm.expectRevert(invalid);
        collections.uniqueValues("uint8", dirtyList(), binary(GapLambdas.same.selector), false);
        vm.expectRevert(invalid);
        collections.sliceValues("uint8", dirtyList(), 1, 2);
    }

    /**
     * @dev Collections #415, #535, #575, #778: a malformed descriptor is refused even with nothing to traverse
     */
    function test_emptyTraversalsStillParseTheDescriptor() public {
        bytes memory bad = abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(5));
        bytes[] memory none = new bytes[](0);
        vm.expectRevert(bad);
        collections.mapValues("uint8(", "uint256", none, unary(GapLambdas.id.selector));
        vm.expectRevert(bad);
        collections.uniqueValues("uint8(", none, binary(GapLambdas.same.selector), false);
        vm.expectRevert(bad);
        collections.reverseValues("uint8(", none);
        vm.expectRevert(bad);
        collections.findValues("uint8(", none, unary(GapLambdas.odd.selector));
    }

    // ============ Collections: callback descriptor refusals (#907, #917) ============

    function test_callbackDescriptorMustBeAMatchingTuple() public {
        Collections.Callback memory cb = unary(GapLambdas.id.selector);
        cb.arguments = "uint256";
        vm.expectRevert(Collections.InvalidCallback.selector);
        collections.mapValues("uint256", "uint256", new bytes[](0), cb);
        cb.arguments = "(uint256,uint256)";
        vm.expectRevert(Collections.InvalidCallback.selector);
        collections.mapValues("uint256", "uint256", new bytes[](0), cb);
    }

    // ============ Collections: unzip envelope (#786) ============

    /**
     * @dev A dynamic pair must carry the 0x20 envelope; a bare body is refused at offset 0
     */
    function test_unzipRequiresTheEnvelope() public {
        bytes[] memory pairs = new bytes[](1);
        pairs[0] = abi.encode(uint256(7), string("hi"));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        collections.unzipValues("uint256", "string", pairs, 0);
    }

    // ============ Expressions: reference counts and result index (#22, #2) ============

    function node(Expressions.Kind kind, string memory valueType, bytes memory data, uint256[] memory refs)
        internal
        pure
        returns (Expressions.Node memory)
    {
        return Expressions.Node(kind, valueType, data, refs, bytes4(0), "");
    }

    function test_wrapNeedsExactlyOneReference() public {
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](3);
        e.nodes[0] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(1)), new uint256[](0));
        e.nodes[1] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(2)), new uint256[](0));
        uint256[] memory two = new uint256[](2);
        two[1] = 1;
        e.nodes[2] = node(Expressions.Kind.Wrap, "bytes", "", two);
        e.result = 2;
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(2)));
        xp.evaluate(e, new bytes[](0));
    }

    /**
     * @dev AbiCodec #294: a node's value is validated through the cached-shape overload, dynamic types included
     */
    function test_nodeValidatesDynamicValues() public {
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](1);
        e.nodes[0] = node(
            Expressions.Kind.Literal, "string", abi.encode(uint256(0x40), uint256(3), bytes32("abc")), new uint256[](0)
        );
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        xp.evaluate(e, new bytes[](0));
    }

    function test_resultIndexMustExist() public {
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](1);
        e.nodes[0] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(1)), new uint256[](0));
        e.result = 1;
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
        xp.evaluate(e, new bytes[](0));
    }

    // ============ nav: bounds and the word each error names (Assertions) ============

    int256 constant LEN = type(int256).min;
    int256 constant PAYLOAD = type(int256).min + 1;

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function path1(int256 a) internal pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = a;
    }

    function path2(int256 a, int256 b) internal pure returns (int256[] memory p) {
        p = new int256[](2);
        p[0] = a;
        p[1] = b;
    }

    /**
     * @dev The word index of the first word equal to `sentinel`
     */
    function wordOf(bytes memory data, uint256 sentinel) internal pure returns (int256) {
        for (uint256 p; p + 32 <= data.length; p += 32) {
            uint256 w;
            assembly { w := mload(add(add(data, 32), p)) }
            if (w == sentinel) return int256(p / 32);
        }
        revert("sentinel not found");
    }

    function expectOutOfBounds(bytes memory data, uint256 sentinel) internal {
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, wordOf(data, sentinel), data.length));
    }

    /**
     * @dev #692-694, #702, #703: a count above the data's whole word count is
     *      refused at its length word (the coarse anti-overflow bound; a count
     *      that passes it fails later, at the missing element's own word)
     */
    function test_navArrayCountNamesItsWord() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(4));
        expectOutOfBounds(data, 4);
        core.nav(raw(data), "(uint256,uint256[])", path2(1, 0));
    }

    /**
     * @dev #743, #745, #752, #755: an element offset past the data names its offset word
     */
    function test_navElementOffsetNamesItsWord() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(1), type(uint256).max);
        expectOutOfBounds(data, type(uint256).max);
        core.nav(raw(data), "(uint256,bytes[])", path2(1, 0));
    }

    /**
     * @dev #544, #555, #562, #572-574: a static-element array terminal too long for the data
     */
    function test_navStaticArrayTerminalBounded() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(2), uint256(0xE0));
        expectOutOfBounds(data, 2);
        core.nav(raw(data), "(uint256,uint256[])", path1(1));
    }

    /**
     * @dev #422, #442, #444: a bytes terminal whose length overruns the data
     */
    function test_navBytesTerminalBounded() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(100), bytes32("x"));
        expectOutOfBounds(data, 100);
        core.nav(raw(data), "(uint256,bytes)", path1(1));
    }

    /**
     * @dev #462, #464: the padded payload must fit too, or nav would copy
     *      bytes from past the end of non-word-aligned data
     */
    function test_navBytesPaddingMustFit() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(33), bytes32("x"), bytes8(0));
        expectOutOfBounds(data, 33);
        core.nav(raw(data), "(uint256,bytes)", path1(1));
    }

    /**
     * @dev #332, #333, #364, #365: LEN bounds the value it measures and names its length word
     */
    function test_navLengthBounded() public {
        bytes memory arrayData = abi.encodePacked(uint256(7), uint256(0x40), uint256(5));
        expectOutOfBounds(arrayData, 5);
        core.nav(raw(arrayData), "(uint256,uint256[])", path2(1, LEN));
        bytes memory bytesData = abi.encodePacked(uint256(7), uint256(0x40), uint256(100));
        expectOutOfBounds(bytesData, 100);
        core.nav(raw(bytesData), "(uint256,bytes)", path2(1, LEN));
    }

    /**
     * @dev #394, #405: PAYLOAD never reads past the data
     */
    function test_navPayloadBounded() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(100), bytes32("x"));
        expectOutOfBounds(data, 100);
        core.nav(raw(data), "(uint256,bytes)", path2(1, PAYLOAD));
    }

    // ============ Codec: counts, heads and the offset each error names (AbiCodec) ============

    function packOne(string memory t, bytes memory value) internal {
        bytes[] memory values = new bytes[](1);
        values[0] = value;
        collections.packArray(t, values);
    }

    /**
     * @dev #404, #406, #416, #417: an element count the data cannot hold is refused at the array's base
     */
    function test_bodyBoundsElementCount() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        packOne("uint256[]", abi.encodePacked(uint256(32), uint256(2), uint256(5)));
        // Two-word elements: three words hold one element, not two.
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        packOne("(uint256,uint256)[]", abi.encodePacked(uint256(32), uint256(2), uint256(5), uint256(6), uint256(7)));
    }

    /**
     * @dev #934, #936, #946, #947: unpack bounds the count the same way
     */
    function test_unpackBoundsElementCount() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        collections.unpackArray(
            "(uint256,uint256)", abi.encodePacked(uint256(32), uint256(2), uint256(5), uint256(6), uint256(7))
        );
    }

    /**
     * @dev #505, #507, #517: a tuple head that overruns the data is refused at the tuple
     */
    function test_bodyBoundsTupleHead() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
        packOne("((uint256,uint256),string)", abi.encodePacked(uint256(32), uint256(1)));
    }

    /**
     * @dev #575: a non-tight offset names its own head word
     */
    function test_bodyNamesTheBadOffset() public {
        bytes memory value = abi.encodePacked(uint256(32), uint256(7), uint256(0x60), uint256(0), uint256(0));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        packOne("(uint256,string)", value);
    }

    /**
     * @dev #704, #705, #707: dirty padding names its first dirty byte
     */
    function test_bodyNamesTheDirtyPaddingByte() public {
        bytes memory value = abi.encodePacked(uint256(32), uint256(3), bytes32("abc"));
        value[64 + 5] = 0x01;
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64 + 5)));
        packOne("string", value);
    }

    /**
     * @dev #807: a large but representable fixed size encodes. (A footprint
     *      past uint256 bytes panics in the tuple parse before
     *      validateComponent's own guard can name it: a known finding, not
     *      pinned here.)
     */
    function test_largeRepresentableFixedArrayEncodes() public {
        bytes[] memory args = new bytes[](1);
        args[0] = new bytes(40 * 32);
        assertEq(ops.encodeBytes("(uint256[40])", args).length, 40 * 32);
        // Wrong length for a large representable footprint: a component length error, not a descriptor one.
        args[0] = new bytes(39 * 32);
        vm.expectRevert(
            abi.encodeWithSelector(
                AbiCodec.InvalidComponentLength.selector, uint256(0), uint256(40 * 32), uint256(39 * 32)
            )
        );
        ops.encodeBytes("(uint256[40])", args);
    }

    // ============ Operations: expWad / lnWad values (87 expWad survivors) ============

    /**
     * @dev References are e^x and ln(x) at 80 significant digits (Python
     *      decimal), truncated to wad. expWad was exact through e^2 and within
     *      1.2e-20 relative beyond (measured 2026-09-26); the bound allows 1e-19
     *      relative plus one wei. lnWad was within one wei everywhere.
     */
    function test_expWadMatchesReference() public view {
        assertWadClose(ops.expWad(-42139678854452767550), 0, 19);
        assertWadClose(ops.expWad(-41446531673892822313), 0, 19);
        assertWadClose(ops.expWad(-20000000000000000000), 2061153622, 19);
        assertWadClose(ops.expWad(-1000000000000000000), 367879441171442321, 19);
        assertWadClose(ops.expWad(-693147180559945309), 500000000000000000, 19);
        assertWadClose(ops.expWad(-1), 999999999999999999, 19);
        assertWadClose(ops.expWad(0), 1000000000000000000, 19);
        assertWadClose(ops.expWad(1), 1000000000000000001, 19);
        assertWadClose(ops.expWad(100000000000000000), 1105170918075647624, 19);
        assertWadClose(ops.expWad(500000000000000000), 1648721270700128146, 19);
        assertWadClose(ops.expWad(693147180559945309), 1999999999999999999, 19);
        assertWadClose(ops.expWad(1000000000000000000), 2718281828459045235, 19);
        assertWadClose(ops.expWad(2000000000000000000), 7389056098930650227, 19);
        assertWadClose(ops.expWad(10000000000000000000), 22026465794806716516957, 19);
        assertWadClose(ops.expWad(50000000000000000000), 5184705528587072464087453322933485384827, 19);
        assertWadClose(
            ops.expWad(100000000000000000000), 26881171418161354484126255515800135873611118773741922415191608, 19
        );
        assertWadClose(
            ops.expWad(135305999368893231588),
            57896044618658097649816762928942336782129491980154662247847962410455084893091,
            19
        );
    }

    /**
     * @dev #379, #381: at and below the underflow cutoff the result is exactly 0
     */
    function test_expWadUnderflowsToZero() public view {
        assertEq(ops.expWad(-42139678854452767551), 0);
        assertEq(ops.expWad(-100e18), 0);
        assertEq(ops.expWad(type(int256).min), 0);
    }

    function test_lnWadMatchesReference() public view {
        assertWadClose(ops.lnWad(1), -41446531673892822312, 0);
        assertWadClose(ops.lnWad(1000000000), -20723265836946411156, 0);
        assertWadClose(ops.lnWad(100000000000000000), -2302585092994045684, 0);
        assertWadClose(ops.lnWad(500000000000000000), -693147180559945309, 0);
        assertWadClose(ops.lnWad(999999999999999999), -1, 0);
        assertWadClose(ops.lnWad(1000000000000000000), 0, 0);
        assertWadClose(ops.lnWad(1000000000000000001), 0, 0);
        assertWadClose(ops.lnWad(2000000000000000000), 693147180559945309, 0);
        assertWadClose(ops.lnWad(2718281828459045235), 999999999999999999, 0);
        assertWadClose(ops.lnWad(1000000000000000000000), 6907755278982137052, 0);
        assertWadClose(ops.lnWad(1000000000000000000000000000000000000), 41446531673892822312, 0);
        assertWadClose(
            ops.lnWad(57896044618658097711785492504343953926634992332820282019728792003956564819967),
            135305999368893231589,
            0
        );
    }

    /**
     * @dev |got - want| <= |want| / 10^relDigits + 1 (relDigits 0: one wei)
     */
    function assertWadClose(int256 got, int256 want, uint256 relDigits) internal pure {
        uint256 diff = got > want ? uint256(got - want) : uint256(want - got);
        uint256 magnitude = want < 0 ? uint256(-want) : uint256(want);
        uint256 bound = relDigits == 0 ? 1 : magnitude / 10 ** relDigits + 1;
        assertLe(diff, bound, "outside the measured precision");
    }

    // ============ Operations: UTF-8, slicing, search, bounds ============

    function expectUtf8Error(bytes memory data, uint256 index) internal {
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidUtf8.selector, index));
        ops.stringSlice(data, 0, 0);
    }

    /**
     * @dev #1767: only C2-F4 lead a sequence; any other non-ASCII lead is refused at itself
     */
    function test_utf8RefusesInvalidLeads() public {
        expectUtf8Error(hex"61f5808080", 1);
        expectUtf8Error(hex"61ff", 1);
        expectUtf8Error(hex"61c0af", 1);
        expectUtf8Error(hex"6180", 1);
    }

    /**
     * @dev #1793, #1794, #1796, #1797, #1798: overlong forms, surrogates and
     *      code points past U+10FFFF are refused at the second byte, and the
     *      boundary sequences just inside each range are accepted
     */
    function test_utf8SecondByteRanges() public {
        expectUtf8Error(hex"6162e08080", 3);
        expectUtf8Error(hex"6162eda080", 3);
        expectUtf8Error(hex"6162f0808080", 3);
        expectUtf8Error(hex"6162f4908080", 3);
        bytes[4] memory valid = [bytes(hex"e0a080"), bytes(hex"ed9fbf"), bytes(hex"f0908080"), bytes(hex"f48fbfbf")];
        for (uint256 i; i < valid.length; i++) {
            assertEq(ops.stringSlice(valid[i], 0, int256(valid[i].length)), valid[i]);
        }
    }

    /**
     * @dev #1803, #1815, #1816: a bad continuation byte is refused at itself
     */
    function test_utf8RefusesBadContinuation() public {
        expectUtf8Error(hex"616263e4b828", 5);
    }

    /**
     * @dev #1086: stringAt validates the whole string, not just the selected byte
     */
    function test_stringAtValidatesTheWholeString() public {
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidUtf8.selector, uint256(1)));
        ops.stringAt(hex"61ff", 0);
    }

    /**
     * @dev #1066, #1083, #1084: an empty range is empty; a boundary inside a character is refused
     */
    function test_stringSliceRangesAndBoundaries() public {
        assertEq(ops.stringSlice("abc", 2, 1).length, 0);
        // "x" then U+00E9 (C3 A9): ending at 2 cuts the character after its lead byte.
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidUtf8.selector, uint256(2)));
        ops.stringSlice(hex"78c3a9", 0, 2);
    }

    /**
     * @dev #1104: contains is false when the needle is absent
     */
    function test_containsFalseWhenAbsent() public view {
        assertFalse(ops.contains("abcdef", "xy"));
        assertTrue(ops.contains("abcdef", "cd"));
    }

    /**
     * @dev #1894: a precision past 77 decimals is refused, not overflowed
     */
    function test_parseUnitsRefusesExcessPrecision() public {
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidPrecision.selector, uint256(78)));
        ops.parseUnits("1", 78, Operations.Rounding.Trunc);
    }

    /**
     * @dev #1745: byteAt names an index outside the data
     */
    function test_byteAtNamesOutOfRangeIndex() public {
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidByteIndex.selector, int256(3), uint256(3)));
        ops.byteAt("abc", 3);
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidByteIndex.selector, int256(-4), uint256(3)));
        ops.byteAt("abc", -4);
    }

    /**
     * @dev #1335, #1587: zero decimals format plainly; a modulus of one yields 0 even for inverse powers
     */
    function test_formatZeroDecimalsAndInverseModOne() public view {
        assertEq(ops.formatUnits(uint256(123), 0), "123");
        assertEq(ops.powMod(uint256(5), int256(-3), uint256(1)), 0);
    }

    // ============ Second sweep: residue of the first gap tests ============

    /**
     * @dev AbiCodec #640-649: the padded payload must fit even when the value is not word-aligned
     */
    function test_bodyBoundsPaddedPayloadOnUnalignedValue() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
        packOne("string", abi.encodePacked(uint256(32), uint256(5), bytes5("hello")));
    }

    /**
     * @dev AbiCodec #363 and Assertions #668: two-digit fixed sizes of dynamic elements, in body and in nav
     */
    function test_twoDigitFixedSizes() public {
        string[10] memory strings;
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(strings);
        string[10][] memory outer = new string[10][](1);
        outer[0] = strings;
        assertEq(collections.packArray("string[10]", values), abi.encode(outer));
        uint256[12] memory words;
        words[11] = 0xBEEF;
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.nav, (raw(abi.encode(words)), "(uint256[12])", path2(0, 11))));
        assertTrue(ok, "a two-digit fixed size is misread");
        assertEq(out, abi.encode(uint256(0xBEEF)));
    }

    /**
     * @dev AbiCodec #511: a head that fits after one component but not the next
     */
    function test_bodyBoundsHeadAfterAComponent() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
        packOne("(uint256,(uint256,uint256),string)", abi.encodePacked(uint256(32), uint256(1), uint256(2)));
    }

    /**
     * @dev AbiCodec #781: nothing may follow a tuple's last component
     */
    function test_tupleRefusesTrailingComponentText() public {
        bytes[] memory args = new bytes[](1);
        args[0] = abi.encode(uint256(1));
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        ops.encodeBytes("(uint256 x)", args);
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        ops.encodeBytes("((uint8)uint8)", args);
    }

    /**
     * @dev AbiCodec #146, #147: after an unrecognised name the walk still checks the next component
     */
    function test_rangeCheckAfterUnrecognisedName() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        packOne("(foo[2],uint8)", abi.encodePacked(uint256(5), uint256(DIRTY), uint256(DIRTY)));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
        packOne("(foo,(uint8,bool))", abi.encodePacked(uint256(5), uint256(DIRTY), uint256(0)));
    }

    /**
     * @dev AbiCodec #1019, #1020: trailing bytes after an unpacked array are named at their offset
     */
    function test_unpackNamesTrailingBytes() public {
        bytes memory data = abi.encodePacked(uint256(32), uint256(1), uint256(7), uint256(0));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(96)));
        collections.unpackArray("uint256", data);
    }

    /**
     * @dev Collections #802-#871: unzip refuses non-canonical dynamic pairs, naming the offending word
     */
    function test_unzipRefusesNonCanonicalPairs() public {
        bytes[] memory pairs = new bytes[](1);
        // A loose offset for the string.
        pairs[0] = abi.encodePacked(uint256(32), uint256(7), uint256(0x60), uint256(0), uint256(2), bytes32("hi"));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        collections.unzipValues("uint256", "string", pairs, 0);
        // The second string starts before the first one's tail.
        pairs[0] = abi.encodePacked(uint256(32), uint256(0x40), uint256(0x20), uint256(0), uint256(0));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
        collections.unzipValues("string", "string", pairs, 0);
        // Trailing bytes: a dynamic last part extends to the end, so its own validation refuses them
        // (offset relative to the part); a static pair has no such part and the pair check names them.
        pairs[0] = bytes.concat(abi.encode(uint256(32)), abi.encode(uint256(7), string("hi")), abi.encode(uint256(0)));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, abi.encode(string("hi")).length));
        collections.unzipValues("uint256", "string", pairs, 0);
        pairs[0] = abi.encode(uint256(1), uint256(2), uint256(3));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(64)));
        collections.unzipValues("uint256", "uint256", pairs, 0);
    }

    /**
     * @dev Collections #640: unzip validates each part against its declared type
     */
    function test_unzipValidatesParts() public {
        bytes[] memory pairs = new bytes[](1);
        pairs[0] = abi.encode(DIRTY, uint256(1));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        collections.unzipValues("uint8", "uint256", pairs, 1);
    }

    /**
     * @dev Collections #898, #901: multi-word static sides zip and unzip exactly
     */
    function test_zipMultiWordStaticSides() public view {
        bytes[] memory left = new bytes[](1);
        bytes[] memory right = new bytes[](1);
        left[0] = abi.encode(uint256(1), uint256(2));
        right[0] = abi.encode(uint256(3), uint256(4), uint256(5));
        bytes[] memory zipped = collections.zipValues("(uint256,uint256)", "uint256[3]", left, right);
        assertEq(zipped[0], abi.encode(uint256(1), uint256(2), uint256(3), uint256(4), uint256(5)));
        assertEq(collections.unzipValues("(uint256,uint256)", "uint256[3]", zipped, 1)[0], right[0]);
    }

    /**
     * @dev Collections #93, #101: each side of zipWords is checked for alignment on its own
     */
    function test_zipWordsChecksEachSide() public {
        bytes memory aligned = abi.encode(uint256(1));
        bytes memory odd = hex"01";
        vm.expectRevert(abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(1)));
        collections.zipWords(odd, aligned);
        vm.expectRevert(abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(1)));
        collections.zipWords(aligned, odd);
    }

    /**
     * @dev Collections #700, #703: the accumulator window must fit the template
     */
    function test_foldAccumulatorWindowBounded() public {
        bytes memory template = abi.encodeCall(GapLambdas.add, (0, 0));
        uint256[] memory elem = new uint256[](1);
        elem[0] = 36;
        vm.expectRevert(abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(40), uint256(68)));
        collections.foldRange(0, address(lambdas), template, 40, elem, bytes32(0), Collections.FoldExit.Full);
    }

    /**
     * @dev Collections #434, #439, #443, #448, #418, #594, #619, #783, #914,
     *      #920: the remaining traversal validations and refusals
     */
    function test_remainingTraversalValidations() public {
        bytes memory invalid = abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0));
        bytes memory badDescriptor = abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(5));
        bytes[] memory none = new bytes[](0);
        vm.expectRevert(badDescriptor);
        collections.foldValues("uint8(", "uint256", none, abi.encode(uint256(0)), binary(GapLambdas.add.selector));
        vm.expectRevert(badDescriptor);
        collections.sortValues("uint8(", none, binary(GapLambdas.same.selector));
        vm.expectRevert(badDescriptor);
        collections.sliceValues("uint8(", none, 0, 0);
        vm.expectRevert(invalid);
        collections.sortValues("uint8", dirtyList(), binary(GapLambdas.same.selector));
        vm.expectRevert(invalid);
        collections.mapValues("uint8", "uint256", dirtyList(), unary(GapLambdas.id.selector));
        vm.expectRevert(invalid);
        collections.indexOfValues("uint8", dirtyList(), abi.encode(uint256(9)), binary(GapLambdas.same.selector));
        // A fold result that is not a canonical accumulatorType names its element.
        bytes[] memory big = new bytes[](1);
        big[0] = abi.encode(uint256(300));
        vm.expectRevert(
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                Collections.foldValues.selector,
                uint256(0),
                uint256(0),
                address(lambdas)
            )
        );
        collections.foldValues("uint256", "uint8", big, abi.encode(uint256(0)), binary(GapLambdas.add.selector));
        // No match: find returns the sentinel instead of scanning forever.
        bytes[] memory evens = new bytes[](2);
        evens[0] = abi.encode(uint256(2));
        evens[1] = abi.encode(uint256(4));
        assertEq(collections.findValues("uint256", evens, unary(GapLambdas.odd.selector)), type(uint256).max);
        // A malformed non-tuple callback descriptor names its byte; a dirty constant slot is refused.
        Collections.Callback memory cb = unary(GapLambdas.id.selector);
        cb.arguments = "uint256[";
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        collections.mapValues("uint256", "uint256", none, cb);
        cb = binary(GapLambdas.add.selector);
        cb.arguments = "(uint256,uint8)";
        cb.second = 0;
        cb.constants[1] = abi.encode(DIRTY);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0)));
        collections.mapValues("uint256", "uint256", none, cb);
    }

    /**
     * @dev Expressions #20, #24, #26: every kind is held to its exact reference count
     */
    function test_nodeReferenceCounts() public {
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](4);
        for (uint256 i; i < 3; i++) {
            e.nodes[i] = node(Expressions.Kind.Literal, "uint256", abi.encode(i), new uint256[](0));
        }
        uint256[] memory two = new uint256[](2);
        two[1] = 1;
        uint256[] memory three = new uint256[](3);
        three[1] = 1;
        three[2] = 2;
        e.result = 3;
        e.nodes[3] = node(Expressions.Kind.Select, "uint256", "", two);
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(3)));
        xp.evaluate(e, new bytes[](0));
        e.nodes[3] = node(Expressions.Kind.TryOrElse, "uint256", "", three);
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(3)));
        xp.evaluate(e, new bytes[](0));
        e.nodes[3] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(9)), two);
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(3)));
        xp.evaluate(e, new bytes[](0));
    }

    /**
     * @dev Assertions #826, #831-#842, #751, #759, #618, #619, #425, #348: nav errors with nonzero positions
     */
    function test_navErrorsAtNonzeroPositions() public {
        // A tuple's dynamic component offset past the data, behind two static words.
        bytes memory data = abi.encodePacked(uint256(7), uint256(8), type(uint256).max);
        expectOutOfBounds(data, type(uint256).max);
        core.nav(raw(data), "(uint256,uint256,bytes)", path1(2));
        // The second element's offset past the data.
        data = abi.encodePacked(uint256(7), uint256(0x40), uint256(2), uint256(0x40), type(uint256).max);
        expectOutOfBounds(data, type(uint256).max);
        core.nav(raw(data), "(uint256,bytes[])", path2(1, 1));
        // An offset word missing entirely: _navWord names its position.
        data = abi.encodePacked(uint256(7));
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(32)));
        core.nav(raw(data), "(uint256,bytes)", path1(1));
        // A bytes length of 2^256 - 1 is refused before any rounding can overflow.
        data = abi.encodePacked(uint256(7), uint256(0x40), type(uint256).max);
        expectOutOfBounds(data, type(uint256).max);
        core.nav(raw(data), "(uint256,bytes)", path1(1));
        // Zero-size elements never reach LEN: the grammar refuses T[0] at its closing bracket.
        data = abi.encodePacked(uint256(0x20), uint256(3));
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(10)));
        core.nav(raw(data), "(uint256[0][])", path2(0, LEN));
    }

    /**
     * @dev Operations #1780, #1782, #1100, #1109, #1332, #357, #1549, #1897, #1302, #1937
     */
    function test_remainingOperationsEdges() public {
        expectUtf8Error(hex"61e4b8", 1);
        assertTrue(ops.contains("abc", ""));
        assertTrue(ops.contains("xxxxab", "ab"));
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidPrecision.selector, uint256(78)));
        ops.formatUnits(uint256(1), 78);
        assertEq(ops.rpow(0, 0, 1e18), 1e18);
        assertEq(ops.rpow(0, 3, 1e18), 0);
        assertEq(ops.powMod(uint256(5), uint256(0), uint256(1)), 0);
        vm.expectRevert(Operations.EmptyNumber.selector);
        ops.parseUnits("", 18, Operations.Rounding.Trunc);
        vm.expectRevert(Operations.EmptyNumber.selector);
        ops.parseInt("");
        assertEq(ops.parseUnits("1.000", 0, Operations.Rounding.Ceil), 1);
    }

    // ============ Third sweep: the final residue ============

    /**
     * @dev Operations #1738: a start far before the beginning clamps to 0
     */
    function test_stringSliceClampsFarNegativeStart() public view {
        assertEq(ops.stringSlice("abc", -4, 3), bytes("abc"));
        assertEq(ops.stringSlice("abc", type(int256).min, 3), bytes("abc"));
    }

    /**
     * @dev UTF-8 validation skips ASCII a word at a time. One offending byte
     *      at every position of strings shorter than a word, exactly one or
     *      two words long, and just past each boundary is still reported at
     *      its own offset, and a well-formed two-byte character is accepted
     *      wherever it falls.
     */
    function test_utf8WordSkipFindsEveryPosition() public view {
        uint8[11] memory lengths = [1, 2, 31, 32, 33, 34, 63, 64, 65, 66, 70];
        for (uint256 k; k < lengths.length; k++) {
            uint256 length = lengths[k];
            for (uint256 i; i < length; i++) {
                bytes memory s = new bytes(length);
                for (uint256 j; j < length; j++) {
                    s[j] = "a";
                }
                s[i] = 0xff; // never valid
                utf8Refused(s, i);
                s[i] = 0x80; // a continuation byte with no lead
                utf8Refused(s, i);
                s[i] = 0xc3; // a lead byte
                if (i + 1 == length) {
                    utf8Refused(s, i); // truncated
                    continue;
                }
                utf8Refused(s, i + 1); // followed by ASCII, not a continuation
                s[i + 1] = 0xa9; // "e" with an acute accent
                assertEq(ops.stringSlice(s, 0, int256(length)), s);
                (bool ok, bytes memory out) =
                    address(ops).staticcall(abi.encodeCall(Operations.stringAt, (s, int256(i))));
                assertFalse(ok);
                assertEq(out, abi.encodeWithSelector(Operations.InvalidUtf8.selector, i));
            }
        }
    }

    function utf8Refused(bytes memory s, uint256 at) internal view {
        (bool ok, bytes memory out) =
            address(ops).staticcall(abi.encodeCall(Operations.stringSlice, (s, int256(0), int256(s.length))));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Operations.InvalidUtf8.selector, at));
    }

    /**
     * @dev foldValues binds the accumulator into slot `first`. A slot declared
     *      with the INPUT type's text does not excuse an accumulator of
     *      another type from validation: a two-word accumulator is refused
     *      for a one-word slot.
     */
    function test_foldValuesValidatesAccumulatorAgainstItsOwnSlot() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1));
        vm.expectRevert(
            abi.encodeWithSelector(AbiCodec.InvalidComponentLength.selector, uint256(0), uint256(32), uint256(64))
        );
        collections.foldValues(
            "uint256", "(uint256,uint256)", values, abi.encode(uint256(1), uint256(2)), binary(GapLambdas.add.selector)
        );
    }

    /**
     * @dev Case folding touches exactly A-Z or a-z: the first and last letter
     *      fold, the bytes on either side of each range do not
     */
    function test_caseFoldBoundaryLetters() public view {
        assertEq(ops.toLower("@AMZ[`amz{"), bytes("@amz[`amz{"));
        assertEq(ops.toUpper("@AMZ[`amz{"), bytes("@AMZ[`AMZ{"));
    }

    /**
     * @dev Assertions #627: nav refuses a descriptor with text after the type
     */
    function test_navRefusesTrailingDescriptorText() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(9)));
        core.nav(raw(abi.encode(uint256(1))), "(uint256)x", path1(0));
    }

    /**
     * @dev Assertions #601: an array of multi-word elements returns every word of every element
     */
    function test_navReturnsMultiWordElementArrays() public view {
        // Three two-word elements: 3 * 2 words, which no other combination of the two numbers gives.
        uint256[2][] memory pairs = new uint256[2][](3);
        pairs[0] = [uint256(1), 2];
        pairs[1] = [uint256(3), 4];
        pairs[2] = [uint256(5), 6];
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.nav, (raw(abi.encode(pairs)), "(uint256[2][])", path1(0))));
        assertTrue(ok);
        assertEq(out, abi.encode(pairs));
    }

    /**
     * @dev Assertions #388: PAYLOAD refuses a length just past the data
     */
    function test_navPayloadRefusesLengthJustPast() public {
        bytes memory data = abi.encodePacked(uint256(7), uint256(0x40), uint256(90), bytes32("x"), bytes32("y"));
        expectOutOfBounds(data, 90);
        core.nav(raw(data), "(uint256,bytes)", path2(1, PAYLOAD));
    }

    /**
     * @dev Assertions #788: a negative tuple index reports the tuple's full component count
     */
    function test_navNegativeTupleIndexCountsComponents() public {
        vm.expectRevert(abi.encodeWithSelector(ElementIndexOutOfBounds.selector, int256(-1), uint256(3)));
        core.nav(raw(abi.encode(uint256(1), uint256(2), uint256(3))), "(uint256,uint256,uint256)", path1(-1));
    }

    /**
     * @dev AbiCodec #770: text between components is named where it starts
     */
    function test_tupleNamesTextBetweenComponents() public {
        bytes[] memory args = new bytes[](2);
        args[0] = abi.encode(uint256(1));
        args[1] = abi.encode(uint256(1));
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        ops.encodeBytes("(uint256(uint8),uint8)", args);
    }

    /**
     * @dev Collections #628, #629, #779: zip and find validate their elements
     */
    function test_zipAndFindValidateElements() public {
        bytes memory invalid = abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0));
        bytes[] memory dirty = new bytes[](1);
        dirty[0] = abi.encode(DIRTY);
        bytes[] memory clean = new bytes[](1);
        clean[0] = abi.encode(uint256(1));
        vm.expectRevert(invalid);
        collections.zipValues("uint8", "uint256", dirty, clean);
        vm.expectRevert(invalid);
        collections.zipValues("uint256", "uint8", clean, dirty);
        vm.expectRevert(invalid);
        collections.findValues("uint8", dirty, unary(GapLambdas.odd.selector));
    }

    /**
     * @dev Collections #941: a predicate must answer with exactly one word
     */
    function test_predicateNeedsOneWord() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1));
        vm.expectRevert(
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                Collections.filterValues.selector,
                uint256(0),
                uint256(0),
                address(lambdas)
            )
        );
        collections.filterValues("uint256", values, unary(GapLambdas.wide.selector));
    }

    /**
     * @dev Expressions #93, #28: a Parameter's data is one word; a Call needs its target reference
     */
    function test_parameterDataAndCallTarget() public {
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](1);
        e.nodes[0] = node(Expressions.Kind.Parameter, "uint256", abi.encode(uint256(0), uint256(0)), new uint256[](0));
        bytes[] memory params = new bytes[](1);
        params[0] = abi.encode(uint256(5));
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(0)));
        xp.evaluate(e, params);
        e.nodes[0] = node(Expressions.Kind.Call, "uint256", "", new uint256[](0));
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(0)));
        xp.evaluate(e, params);
    }

    // ============ Rerun after the word-compare search, 2026-09-26 ============

    /**
     * @dev Operations #937: contains' last start position is s.length -
     *      needle.length. The word compare reads calldata directly, so a start
     *      past it would compare the zero padding after `s` and find "b\0" in
     *      "ab"; the byte loop it replaced reverted there instead.
     */
    function test_containsStopsAtTheLastWholeWindow() public view {
        assertFalse(ops.contains("ab", hex"6200"));
        assertFalse(ops.contains("ab", hex"620000"));
        assertTrue(ops.contains("ab", "b"));
    }

    /**
     * @dev Collections #416: mapValues parses outputType up front, so a
     *      malformed one fails on an empty input too, before any result
     *      would ever be validated against it
     */
    function test_mapValuesRefusesAMalformedOutputTypeOnEmptyInput() public {
        Collections.Callback memory cb;
        cb.target = address(ops);
        cb.selector = bytes4(keccak256("add(uint256,uint256)"));
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
        cb.constants[0] = abi.encode(uint256(0));
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(2)));
        collections.mapValues("uint256", "((", new bytes[](0), cb);
    }

    // ============ reduceWords and the unchecked word-engine reads, 2026-10-08 ============

    /**
     * @dev Hand-written mutant of `_checkElementWindows` (inline assembly,
     *      which Gambit does not mutate): reading the first offset for every
     *      window. Each window is bounded on its own, and the error names
     *      the offending one.
     */
    function test_everyElementWindowIsBounded() public {
        bytes memory tpl = abi.encodeWithSelector(GapLambdas.id.selector, uint256(0));
        uint256[] memory offsets = new uint256[](3);
        offsets[0] = 4;
        offsets[1] = 4;
        offsets[2] = 5;
        bytes memory refused =
            abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(5), uint256(36));
        vm.expectRevert(refused);
        collections.mapWords(abi.encode(uint256(1)), address(lambdas), tpl, offsets);
        vm.expectRevert(refused);
        collections.foldWords(abi.encode(uint256(1)), address(lambdas), tpl, 4, offsets, 0, Collections.FoldExit.Full);
        vm.expectRevert(refused);
        collections.reduceWords(
            abi.encode(uint256(1)), address(lambdas), tpl, offsets, Collections.Reduce.Sum, Collections.Cmp.EQ, 0
        );
    }

    /**
     * @dev Hand-written mutant of `_domainElem`: reading byte 0 for every
     *      index. A Bytes fold hands the lambda each byte of the subject in
     *      turn, so a sum over distinct bytes tells them apart.
     */
    function test_foldBytesVisitsEveryByte() public view {
        bytes memory tpl = abi.encodeWithSelector(GapLambdas.add.selector, uint256(0), uint256(0));
        uint256[] memory offsets = new uint256[](1);
        offsets[0] = 36;
        assertEq(
            collections.foldBytes(hex"0a0305", address(lambdas), tpl, 4, offsets, 0, Collections.FoldExit.Full),
            bytes32(uint256(0x0a + 0x03 + 0x05))
        );
    }

    // ============ The gas pass, 2026-10-08 ============

    /**
     * @dev Hand-written mutants of `_foldCase` (inline assembly): stepping
     *      two words, stopping after the first word, and leaving a byte's
     *      top bit in the range sum, where it carries into the byte before
     *      it. Every word is folded, and a non-ASCII byte changes neither
     *      itself nor its neighbour: 0x40 and 0x60 sit one below the letters.
     */
    function test_caseFoldCoversEveryWordAndSparesNonAscii() public view {
        bytes memory s = new bytes(70);
        bytes memory lower = new bytes(70);
        for (uint256 i; i < 70; i++) {
            s[i] = bytes1(uint8(0x41 + (i % 26)));
            lower[i] = bytes1(uint8(0x61 + (i % 26)));
        }
        assertEq(ops.toLower(s), lower);
        assertEq(ops.toUpper(lower), s);
        assertEq(ops.toLower(hex"40c3415bc3"), hex"40c3615bc3");
        assertEq(ops.toUpper(hex"60c3617bc3"), hex"60c3417bc3");
    }

    /**
     * @dev Operations #24 and #28 and a hand-written mutant of
     *      `_parseDigits`. Inputs of up to 77 digits take the loop without
     *      the overflow check, so the checked loop only sees longer ones:
     *      both refuse a non-digit, by position, and ":" follows "9".
     */
    function test_parseUintRefusesNonDigitsOnBothPaths() public {
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, uint256(1), bytes1(":")));
        ops.parseUint("1:");
        bytes memory long = new bytes(78);
        for (uint256 i; i < 78; i++) {
            long[i] = "0";
        }
        long[0] = "1";
        assertEq(ops.parseUint(long), 10 ** 77);
        long[40] = "a";
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, uint256(40), bytes1("a")));
        ops.parseUint(long);
        long[40] = ":";
        vm.expectRevert(abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, uint256(40), bytes1(":")));
        ops.parseUint(long);
    }

    /**
     * @dev AbiCodec #24 and #27, `word`'s bounds check: an array encoding
     *      that ends after its envelope word has no count to read
     */
    function test_unpackRefusesAMissingCount() public {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
        collections.unpackArray("uint256", abi.encode(uint256(32)));
    }

    /**
     * @dev Collections #42 and #44, the second slot of a binary callback
     *      declared with other text than the input type: the value is
     *      still bound, and still validated against the slot's own type
     */
    function test_secondSlotOfAnotherTypeIsBoundAndValidated() public {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(5));
        values[1] = abi.encode(uint256(7));
        Collections.Callback memory cb = Collections.Callback(
            address(lambdas), GapLambdas.same.selector, "(uint256,uint)", new bytes[](2), 0, 1, ""
        );
        assertEq(collections.indexOfValues("uint256", values, abi.encode(uint256(7)), cb), 1);
        cb.arguments = "(uint256,uint8)";
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0)));
        collections.indexOfValues("uint256", values, abi.encode(uint256(300)), cb);
    }

    /**
     * @dev Hand-written mutants of `tupleLayout`'s allocation (inline
     *      assembly): a smaller capacity, and arrays without their length
     *      word. One-byte names make a descriptor hold as many components
     *      as its length allows, which is the capacity the arrays get.
     */
    function test_tupleLayoutHoldsTheDensestDescriptor() public view {
        bytes[] memory args = new bytes[](8);
        bytes memory expected;
        for (uint256 i; i < 8; i++) {
            args[i] = abi.encode(uint256(0x1111 * (i + 1)));
            expected = bytes.concat(expected, args[i]);
        }
        assertEq(ops.encodeBytes("(a,a,a,a,a,a,a,a)", args), expected);
    }
}
