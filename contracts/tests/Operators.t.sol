// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operators.sol";
import "../ERC8211.sol";
import "../AbiShape.sol";
import "./Mocks.sol";

/**
 * @notice Operators periphery tests: plain-typed word ops (with the int256
 *         overloads), environment reads, bytes/search ops, the runtime
 *         encoder and the folds — plus compositions where the core's read
 *         splices live operands into Operators calldata and judges the
 *         result.
 */
contract OperatorsTest is Test {
    Assertions public assertions;
    Operators public ops;
    MockTarget public target;
    MockToken public token;

    address constant TEST_EOA = address(0x1234);

    // Overloaded selectors (abi.encodeCall cannot disambiguate overloads)
    bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
    bytes4 constant DIV_U = bytes4(keccak256("div(uint256,uint256)"));
    bytes4 constant MOD_U = bytes4(keccak256("mod(uint256,uint256)"));

    function setUp() public {
        assertions = new Assertions();
        ops = new Operators();
        target = new MockTarget();
        token = new MockToken(address(0), "WETH");
        target.setToken(address(token));
    }

    // ============ Test Helpers ============

    function _none() internal pure returns (Constraint[] memory cs) {
        cs = new Constraint[](0);
    }

    function _c1(ConstraintType t, bytes memory ref) internal pure returns (Constraint[] memory cs) {
        cs = new Constraint[](1);
        cs[0] = Constraint(t, ref);
    }

    /**
     * @dev A RAW_BYTES operand carrying a literal word
     */
    function _lit(uint256 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    /**
     * @dev A STATIC_CALL operand
     */
    function _call(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }

    function _args1(InputParam memory a) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](1);
        ps[0] = a;
    }

    function _args2(InputParam memory a, InputParam memory b) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](2);
        ps[0] = a;
        ps[1] = b;
    }

    /**
     * @dev Core read calldata splicing two operands into a binary operator
     */
    function _read2(bytes4 sel, InputParam memory a, InputParam memory b) internal view returns (bytes memory) {
        return abi.encodeCall(Assertions.read, (_lit(uint256(uint160(address(ops)))), sel, _args2(a, b)));
    }

    // ============ Arithmetic ============

    function test_add_and_overflow() public {
        assertEq(ops.add(uint256(42), uint256(8)), 50);
        vm.expectRevert(stdError.arithmeticError);
        ops.add(type(uint256).max, uint256(1));
    }

    function test_add_signed() public view {
        assertEq(ops.add(int256(-7), int256(10)), 3);
    }

    function test_sub_and_underflow() public {
        assertEq(ops.sub(uint256(50), uint256(8)), 42);
        vm.expectRevert(stdError.arithmeticError);
        ops.sub(uint256(8), uint256(50));
    }

    function test_sub_signed() public view {
        assertEq(ops.sub(int256(-7), int256(3)), -10);
    }

    function test_mul_div_mod() public {
        assertEq(ops.mul(uint256(6), uint256(7)), 42);
        assertEq(ops.div(uint256(85), uint256(2)), 42);
        assertEq(ops.mod(uint256(87), uint256(5)), 2);
        vm.expectRevert(stdError.divisionError);
        ops.div(uint256(1), uint256(0));
    }

    function test_div_mod_signed_truncation() public view {
        // truncation toward zero; mod takes the dividend's sign
        assertEq(ops.div(int256(-42), int256(5)), -8);
        assertEq(ops.mod(int256(-42), int256(5)), -2);
    }

    function test_div_signed_minByMinusOne() public {
        vm.expectRevert(stdError.arithmeticError);
        ops.div(type(int256).min, int256(-1));
    }

    function test_exp() public view {
        assertEq(ops.exp(10, 18), 1e18);
        assertEq(ops.exp(0, 0), 1);
    }

    function test_minMax() public view {
        assertEq(ops.min(uint256(3), uint256(9)), 3);
        assertEq(ops.max(uint256(3), uint256(9)), 9);
        // unsigned min sees -1 as huge; the int256 overload orders it correctly
        assertEq(ops.min(uint256(int256(-1)), uint256(9)), 9);
        assertEq(ops.min(int256(-1), int256(9)), -1);
        assertEq(ops.max(int256(-1), int256(9)), 9);
    }

    function test_absDiff() public view {
        assertEq(ops.absDiff(uint256(3), uint256(9)), 6);
        assertEq(ops.absDiff(uint256(9), uint256(3)), 6);
        assertEq(ops.absDiff(int256(-42), int256(7)), 49);
        // the widest span is total, not a revert
        assertEq(ops.absDiff(type(int256).min, type(int256).max), type(uint256).max);
    }

    function test_mulDiv() public {
        assertEq(ops.mulDiv(6, 7, 2), 21);
        // the intermediate product needs 512 bits; div(mul(a,b), d) would revert
        assertEq(ops.mulDiv(type(uint256).max, 2, 4), type(uint256).max / 2);
        assertEq(ops.mulDiv(type(uint256).max, type(uint256).max, type(uint256).max), type(uint256).max);
        // result past 256 bits: overflow panic, like the checked operators
        vm.expectRevert(stdError.arithmeticError);
        ops.mulDiv(type(uint256).max, 2, 1);
    }

    function test_mulDiv_zeroDenominator() public {
        vm.expectRevert(stdError.divisionError);
        ops.mulDiv(1, 1, 0);
        // the 512-bit path panics identically
        vm.expectRevert(stdError.divisionError);
        ops.mulDiv(type(uint256).max, type(uint256).max, 0);
    }

    function test_mulDivUp() public view {
        assertEq(ops.mulDivUp(10, 10, 3), 34);
        // exact division: no rounding
        assertEq(ops.mulDivUp(10, 10, 4), 25);
        assertEq(ops.mulDivUp(type(uint256).max, 2, 4), type(uint256).max / 2 + 1);
    }

    function test_addMod_mulMod() public {
        // the 512-bit intermediates do not wrap at 2^256
        assertEq(ops.addMod(type(uint256).max, 5, type(uint256).max), 5);
        assertEq(ops.mulMod(type(uint256).max, 2, 7), 2);
        vm.expectRevert(stdError.divisionError);
        ops.addMod(1, 1, 0);
        vm.expectRevert(stdError.divisionError);
        ops.mulMod(1, 1, 0);
    }

    function test_sqrt() public view {
        assertEq(ops.sqrt(0), 0);
        assertEq(ops.sqrt(1), 1);
        assertEq(ops.sqrt(3), 1);
        assertEq(ops.sqrt(4), 2);
        assertEq(ops.sqrt(99), 9);
        assertEq(ops.sqrt(100), 10);
        uint256 x = (1 << 128) - 1;
        assertEq(ops.sqrt(x * x), x);
        assertEq(ops.sqrt(x * x + 2 * x), x);
        assertEq(ops.sqrt(type(uint256).max), x);
    }

    // ============ Comparisons ============

    function test_comparisons() public view {
        assertTrue(ops.eq(uint256(42), uint256(42)));
        assertFalse(ops.ne(uint256(42), uint256(42)));
        assertTrue(ops.lt(uint256(3), uint256(9)));
        assertFalse(ops.gt(uint256(3), uint256(9)));
        assertTrue(ops.le(uint256(9), uint256(9)));
        assertFalse(ops.ge(uint256(8), uint256(9)));
    }

    function test_comparisons_signed() public view {
        // unsigned sees -1 as huge; the int256 overloads order it correctly
        assertFalse(ops.lt(uint256(int256(-1)), uint256(9)));
        assertTrue(ops.lt(int256(-1), int256(9)));
        assertFalse(ops.gt(int256(-1), int256(9)));
        assertTrue(ops.le(int256(-9), int256(-9)));
        assertFalse(ops.ge(int256(-9), int256(-8)));
    }

    // ============ Bitwise ============

    function test_bitwise() public view {
        assertEq(ops.bitAnd(0xF0F0, 0xFF00), 0xF000);
        assertEq(ops.bitOr(0xF0F0, 0x0F00), 0xFFF0);
        assertEq(ops.bitXor(0xFF, 0x0F), 0xF0);
        // bitXor against all-ones is bitwise NOT
        assertEq(ops.bitXor(0, type(uint256).max), type(uint256).max);
    }

    function test_shifts() public view {
        assertEq(ops.shl(1, 4), 16);
        assertEq(ops.shr(uint256(256), 4), 16);
        // EVM semantics: shifting by >= 256 yields 0, no revert
        assertEq(ops.shl(1, 256), 0);
        assertEq(ops.shr(uint256(1), 300), 0);
    }

    function test_shr_signed() public view {
        assertEq(ops.shr(int256(16), 2), 4);
        assertEq(ops.shr(int256(-16), 2), -4);
        // SAR rounds toward negative infinity, not toward zero
        assertEq(ops.shr(int256(-15), 2), -4);
        // shifts >= 256: the sign fills everything
        assertEq(ops.shr(int256(1), 300), 0);
        assertEq(ops.shr(int256(-1), 300), -1);
        // the sign-extension recipe: re-widen an int16 field (0xfffe = -2)
        assertEq(ops.shr(int256(ops.shl(0xfffe, 240)), 240), -2);
    }

    function test_bitSet() public view {
        assertTrue(ops.bitSet(1 << 97, 97));
        assertFalse(ops.bitSet(1 << 97, 98));
        // indices past 255 are never set (shift semantics, no revert)
        assertFalse(ops.bitSet(type(uint256).max, 256));
    }

    // ============ Environment ============

    function test_balance() public {
        vm.deal(TEST_EOA, 3 ether);
        assertEq(ops.balance(TEST_EOA), 3 ether);
    }

    function test_codehash() public view {
        assertEq(ops.codehash(address(token)), address(token).codehash);
        assertEq(ops.codehash(address(0xdead)), bytes32(0));
    }

    function test_blockValues() public {
        vm.warp(1_900_000_000);
        vm.roll(21_000_000);
        assertEq(ops.timestamp(), 1_900_000_000);
        assertEq(ops.blockNumber(), 21_000_000);
        assertEq(ops.chainId(), block.chainid);
    }

    function test_feeAndProposerValues() public {
        vm.fee(7 gwei);
        assertEq(ops.baseFee(), 7 gwei);
        vm.prevrandao(bytes32(uint256(0xbeef)));
        assertEq(ops.prevRandao(), 0xbeef);
        vm.coinbase(address(0xC0FFEE));
        assertEq(ops.coinbase(), address(0xC0FFEE));
        assertEq(ops.gasLimit(), block.gaslimit);
        assertEq(ops.blobBaseFee(), block.blobbasefee);
    }

    function test_blockHash() public {
        vm.roll(21_000_000);
        assertEq(ops.blockHash(block.number - 1), blockhash(block.number - 1));
        // BLOCKHASH semantics: current block, the future and blocks older
        // than 256 are all 0
        assertEq(ops.blockHash(block.number), bytes32(0));
        assertEq(ops.blockHash(block.number + 1), bytes32(0));
        assertEq(ops.blockHash(block.number - 300), bytes32(0));
    }

    function test_origin() public {
        vm.prank(address(this), TEST_EOA);
        assertEq(ops.origin(), TEST_EOA);
    }

    // ============ Bytes ============

    function test_concat() public view {
        bytes[] memory parts = new bytes[](3);
        parts[0] = "ab";
        parts[1] = "";
        parts[2] = "cd";
        assertEq(ops.concat(parts), bytes("abcd"));
        assertEq(ops.concat(new bytes[](0)), bytes(""));
    }

    function test_slice() public {
        bytes memory data = bytes("Curve LP Token");
        assertEq(ops.slice(data, 6, 2), bytes("LP"));
        assertEq(ops.slice(data, 0, 0), bytes(""));
        assertEq(ops.slice(data, 14, 0), bytes(""));
        vm.expectRevert(abi.encodeWithSelector(Operators.SliceOutOfBounds.selector, 15, 0, 14));
        ops.slice(data, 15, 0);
        vm.expectRevert(abi.encodeWithSelector(Operators.SliceOutOfBounds.selector, 6, 9, 14));
        ops.slice(data, 6, 9);
    }

    function test_byteLen_and_hash() public view {
        bytes memory data = abi.encode("hello");
        assertEq(ops.byteLen(data), 96);
        assertEq(ops.hash(data), keccak256(data));
        assertEq(ops.byteLen(""), 0);
    }

    // ============ Search ============

    function test_indexOf_forward() public view {
        bytes memory name = bytes("Curve LP Token");
        assertEq(ops.indexOf(name, "LP", 0), 6);
        assertEq(ops.indexOf(name, "Curve", 0), 0);
        // occurrence ordinals: spaces sit at 5 and 8
        assertEq(ops.indexOf(name, " ", 0), 5);
        assertEq(ops.indexOf(name, " ", 1), 8);
        assertEq(ops.indexOf(name, " ", 2), 14);
        // not found / needle longer than haystack: the sentinel
        assertEq(ops.indexOf(name, "xyz", 0), 14);
        assertEq(ops.indexOf(name, "LP", 1), 14);
        assertEq(ops.indexOf("ab", "abc", 0), 2);
        // occurrences are non-overlapping (delimiter semantics)
        assertEq(ops.indexOf("aaaa", "aa", 0), 0);
        assertEq(ops.indexOf("aaaa", "aa", 1), 2);
        assertEq(ops.indexOf("aaaa", "aa", 2), 4);
        // empty needle: vacuous match at every position 0 .. length
        assertEq(ops.indexOf(name, "", 3), 3);
        assertEq(ops.indexOf(name, "", 14), 14);
        assertEq(ops.indexOf(name, "", 100), 14);
    }

    function test_indexOf_backward() public view {
        bytes memory name = bytes("Curve LP Token");
        // ordinals from the end: -1 = last, -2 = second-last
        assertEq(ops.indexOf(name, " ", -1), 8);
        assertEq(ops.indexOf(name, " ", -2), 5);
        assertEq(ops.indexOf(name, " ", -3), 14);
        // not found backward: the sentinel
        assertEq(ops.indexOf("hello", "x", -1), 5);
        // type(int256).min cannot overflow the negation
        assertEq(ops.indexOf(name, " ", type(int256).min), 14);
        // non-overlapping from the end too: "aa" occurs at 0 and 2
        assertEq(ops.indexOf("aaaa", "aa", -1), 2);
        assertEq(ops.indexOf("aaaa", "aa", -2), 0);
        // empty needle: position s.length is the last vacuous match
        assertEq(ops.indexOf(name, "", -1), 14);
        assertEq(ops.indexOf(name, "", -15), 0);
        assertEq(ops.indexOf(name, "", -16), 14);
    }

    function test_matchAt() public view {
        bytes memory name = bytes("Curve LP Token");
        assertEq(ops.matchAt(name, "LP", 6), 1);
        assertEq(ops.matchAt(name, "LP", 5), 0);
        assertEq(ops.matchAt("abc", "c", 2), 1);
        // a match that would run past the end is 0, not a revert
        assertEq(ops.matchAt("abc", "cd", 2), 0);
        assertEq(ops.matchAt("abc", "", 3), 1);
        assertEq(ops.matchAt("abc", "", 4), 0);
    }

    // ============ Parse ============

    function test_parseUint() public view {
        assertEq(ops.parseUint("0"), 0);
        assertEq(ops.parseUint("123"), 123);
        // leading zeros are accepted
        assertEq(ops.parseUint("007"), 7);
        assertEq(
            ops.parseUint("115792089237316195423570985008687907853269984665640564039457584007913129639935"),
            type(uint256).max
        );
    }

    function test_parseUint_rejects() public {
        vm.expectRevert(abi.encodeWithSelector(Operators.EmptyNumber.selector));
        ops.parseUint("");
        vm.expectRevert(abi.encodeWithSelector(Operators.InvalidDecimalDigit.selector, 2, bytes1("a")));
        ops.parseUint("12a");
        // no signs, no whitespace
        vm.expectRevert(abi.encodeWithSelector(Operators.InvalidDecimalDigit.selector, 0, bytes1("-")));
        ops.parseUint("-1");
        // one past type(uint256).max: the checked accumulator panics
        vm.expectRevert(stdError.arithmeticError);
        ops.parseUint("115792089237316195423570985008687907853269984665640564039457584007913129639936");
    }

    function test_toString() public view {
        assertEq(ops.toString(0), "0");
        assertEq(ops.toString(123), "123");
        assertEq(
            ops.toString(type(uint256).max),
            "115792089237316195423570985008687907853269984665640564039457584007913129639935"
        );
        // roundtrip, with normalization of leading zeros
        assertEq(ops.parseUint(bytes(ops.toString(ops.parseUint("0042")))), 42);
    }

    // ============ Encode ============

    /**
     * @dev Raw staticcall into encode (its result comes via assembly
     *      return, with no bytes envelope)
     */
    function _encode(string memory types, bytes[] memory values) internal view returns (bool ok, bytes memory ret) {
        (ok, ret) = address(ops).staticcall(abi.encodeCall(Operators.encode, (types, values)));
    }

    function test_encode_singleWord() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(42));
        (bool ok, bytes memory ret) = _encode("(uint256)", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(uint256(42)));
    }

    function test_encode_multiStatic() public view {
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(uint256(42));
        values[1] = abi.encode(address(0xBEEF));
        values[2] = abi.encode(true);
        (bool ok, bytes memory ret) = _encode("(uint256,address,bool)", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(uint256(42), address(0xBEEF), true));
    }

    function test_encode_staticTupleFlattened() public view {
        // a static tuple's value is its flattened words (w * 32 bytes)
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(1), uint256(2));
        values[1] = abi.encode(true);
        (bool ok, bytes memory ret) = _encode("((uint256,uint256),bool)", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(uint256(1), uint256(2), true));
    }

    function test_encode_string() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(7));
        values[1] = abi.encode("hi");
        (bool ok, bytes memory ret) = _encode("(uint256,string)", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(uint256(7), "hi"));
    }

    function test_encode_arrayRoundtrip() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(arr);
        (bool ok, bytes memory ret) = _encode("(uint256[])", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(arr));
    }

    function test_encode_nestedDynamics() public view {
        // string[]: internal offsets are frame-relative, so the envelope
        // tail splices verbatim
        string[] memory strs = new string[](2);
        strs[0] = "Gauge";
        strs[1] = "Deposit";
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(strs);
        (bool ok, bytes memory ret) = _encode("(string[])", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(strs));
    }

    function test_encode_mixed() public view {
        uint256[] memory arr = new uint256[](2);
        arr[0] = 1;
        arr[1] = 2;
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(uint256(9));
        values[1] = abi.encode(bytes(hex"c0ffee"));
        values[2] = abi.encode(arr);
        (bool ok, bytes memory ret) = _encode("(uint256,bytes,uint256[])", values);
        assertTrue(ok);
        assertEq(ret, abi.encode(uint256(9), bytes(hex"c0ffee"), arr));
    }

    function test_encode_countMismatch() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1));
        vm.expectRevert(abi.encodeWithSelector(Operators.ComponentCountMismatch.selector, 2, 1));
        ops.encode("(uint256,uint256)", values);
    }

    function test_encode_badStaticLength() public {
        bytes[] memory values = new bytes[](1);
        values[0] = hex"01";
        vm.expectRevert(abi.encodeWithSelector(Operators.InvalidComponentLength.selector, 0, 32, 1));
        ops.encode("(uint256)", values);
    }

    function test_encode_badEnvelope() public {
        // a bare word is not an envelope for a dynamic component
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(0x40));
        vm.expectRevert(
            abi.encodeWithSelector(Operators.InvalidComponentEnvelope.selector, 0, 32, bytes32(uint256(0x40)))
        );
        ops.encode("(bytes)", values);
    }

    function test_encode_malformedDescriptor() public {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1));
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, 0));
        ops.encode("uint256", values);
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, 9));
        ops.encode("(uint256)x", values);
    }

    // ============ Folds ============

    function test_foldRange_sum() public view {
        // add(acc, i) over 0..4 = 10
        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        assertEq(uint256(ops.foldRange(5, address(ops), template, 4, 36, bytes32(0), Operators.FoldExit.Full)), 10);
    }

    function test_foldWords_sum() public view {
        bytes memory payload = abi.encodePacked(uint256(10), uint256(20), uint256(30), uint256(40), uint256(50));
        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        assertEq(uint256(ops.foldWords(payload, address(ops), template, 4, 36, bytes32(0), Operators.FoldExit.Full)), 150);
    }

    function test_foldBytes_charsetRecipe() public view {
        // all-fold with a bitSet(mask, byte) lambda = the character-set
        // test. bitSet ignores the accumulator, so both windows share the
        // element offset (the element wins on overlap).
        uint256 mask;
        for (uint256 i = 97; i <= 122; i++) {
            mask |= 1 << i;
        }
        bytes memory template = abi.encodeWithSelector(Operators.bitSet.selector, mask, uint256(0));
        assertEq(
            uint256(ops.foldBytes("hello", address(ops), template, 36, 36, bytes32(uint256(1)), Operators.FoldExit.All)),
            1
        );
        // "Curve LP Token" has uppercase and spaces: fails the a-z mask
        assertEq(
            uint256(
                ops.foldBytes(
                    "Curve LP Token", address(ops), template, 36, 36, bytes32(uint256(1)), Operators.FoldExit.All
                )
            ),
            0
        );
    }

    function test_foldRange_includesRecipe() public view {
        // exists-fold with a matchAt(s, needle, pos) lambda = substring
        // search: positions 0 .. len(s) - len(needle)
        bytes memory s = bytes("Curve LP Token");
        bytes memory template = abi.encodeWithSelector(Operators.matchAt.selector, s, bytes("LP"), uint256(0));
        // matchAt's pos is the third head word: byte 4 + 64 = 68
        assertEq(
            uint256(ops.foldRange(13, address(ops), template, 68, 68, bytes32(0), Operators.FoldExit.Any)),
            1
        );
        bytes memory missing = abi.encodeWithSelector(Operators.matchAt.selector, s, bytes("XY"), uint256(0));
        assertEq(
            uint256(ops.foldRange(13, address(ops), missing, 68, 68, bytes32(0), Operators.FoldExit.Any)),
            0
        );
    }

    function test_splitRecipe() public view {
        // Segment k spans [indexOf(s, d, k-1) + dlen, indexOf(s, d, k))
        // (0 for k == 0; the sentinel ends the trailing segment for free)
        bytes memory name = bytes("Curve LP Token");
        assertEq(ops.slice(name, 0, ops.indexOf(name, " ", 0)), bytes("Curve"));
        // middle segment via forward ordinals
        uint256 start = ops.indexOf(name, " ", 0) + 1;
        uint256 end = ops.indexOf(name, " ", 1);
        assertEq(ops.slice(name, start, end - start), bytes("LP"));
        // trailing segment: end is the sentinel = byteLen
        start = ops.indexOf(name, " ", 1) + 1;
        assertEq(ops.slice(name, start, ops.indexOf(name, " ", 2) - start), bytes("Token"));
        // same segments via ordinals from the end
        uint256 lastSpace = ops.indexOf(name, " ", -1);
        assertEq(ops.slice(name, lastSpace + 1, name.length - lastSpace - 1), bytes("Token"));
        start = ops.indexOf(name, " ", -2) + 1;
        assertEq(ops.slice(name, start, ops.indexOf(name, " ", -1) - start), bytes("LP"));
    }

    function test_fold_anyShortCircuits() public {
        // div(6, elem) over [3, 6, 0]: Any stops at elem 3 (acc = 2), never
        // reaching the div-by-zero at index 2 — Full does and reverts
        bytes memory payload = abi.encodePacked(uint256(3), uint256(6), uint256(0));
        bytes memory template = abi.encodeWithSelector(DIV_U, uint256(6), uint256(0));
        assertEq(uint256(ops.foldWords(payload, address(ops), template, 36, 36, bytes32(0), Operators.FoldExit.Any)), 2);

        vm.expectRevert(
            abi.encodeWithSelector(
                Operators.LambdaCallFailed.selector,
                2,
                address(ops),
                abi.encodeWithSelector(DIV_U, uint256(6), uint256(0))
            )
        );
        ops.foldWords(payload, address(ops), template, 36, 36, bytes32(0), Operators.FoldExit.Full);
    }

    function test_fold_allShortCircuits() public {
        // mod(6, elem) over [1, 0]: All stops at elem 1 (acc = 0), never
        // reaching the mod-by-zero at index 1 — Full does and reverts
        bytes memory payload = abi.encodePacked(uint256(1), uint256(0));
        bytes memory template = abi.encodeWithSelector(MOD_U, uint256(6), uint256(0));
        assertEq(uint256(ops.foldWords(payload, address(ops), template, 36, 36, bytes32(0), Operators.FoldExit.All)), 0);

        vm.expectRevert(
            abi.encodeWithSelector(
                Operators.LambdaCallFailed.selector,
                1,
                address(ops),
                abi.encodeWithSelector(MOD_U, uint256(6), uint256(0))
            )
        );
        ops.foldWords(payload, address(ops), template, 36, 36, bytes32(0), Operators.FoldExit.Full);
    }

    function test_fold_emptyDomainReturnsInit() public view {
        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        // the lambda target is never inspected on an empty domain
        assertEq(
            uint256(ops.foldRange(0, address(0xdead), template, 4, 36, bytes32(uint256(77)), Operators.FoldExit.Full)),
            77
        );
    }

    function test_fold_offsetOutOfBounds() public {
        vm.expectRevert(abi.encodeWithSelector(Operators.LambdaOffsetOutOfBounds.selector, 0, 0));
        ops.foldRange(1, address(ops), "", 0, 0, bytes32(0), Operators.FoldExit.Full);

        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        vm.expectRevert(abi.encodeWithSelector(Operators.LambdaOffsetOutOfBounds.selector, 37, 68));
        ops.foldRange(1, address(ops), template, 4, 37, bytes32(0), Operators.FoldExit.Full);
    }

    function test_fold_codelessTarget() public {
        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        vm.expectRevert(abi.encodeWithSelector(Operators.LambdaCallFailed.selector, 0, TEST_EOA, bytes("")));
        ops.foldRange(1, TEST_EOA, template, 4, 36, bytes32(0), Operators.FoldExit.Full);
    }

    function test_fold_lambdaReturnTooShort() public {
        // checkValue(42) succeeds but returns nothing: byte 0x2a substitutes
        // elem 42 into the void-returning lambda
        bytes memory template = abi.encodeCall(MockTarget.checkValue, (0));
        vm.expectRevert(abi.encodeWithSelector(Operators.LambdaReturnTooShort.selector, 0, 0));
        ops.foldBytes(hex"2a", address(target), template, 4, 4, bytes32(0), Operators.FoldExit.Full);
    }

    function test_foldWords_unaligned() public {
        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        vm.expectRevert(abi.encodeWithSelector(Operators.UnalignedWords.selector, 33));
        ops.foldWords(new bytes(33), address(ops), template, 4, 36, bytes32(0), Operators.FoldExit.Full);
    }

    // ============ Judged through the core ============

    function test_core_judges_readExpression() public view {
        // assert whaleBalance() / 10^decimals() == 7, composed by the
        // core's read and judged through its own address
        bytes memory scale = abi.encodeCall(
            Assertions.read,
            (
                _lit(uint256(uint160(address(ops)))),
                Operators.exp.selector,
                _args2(_lit(10), _call(address(token), abi.encodeCall(MockToken.decimals, ())))
            )
        );
        bytes memory expression = _read2(
            DIV_U,
            _call(address(token), abi.encodeCall(MockToken.whaleBalance, ())),
            _call(address(assertions), scale)
        );
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), expression),
            _c1(ConstraintType.EQ, abi.encode(uint256(7)))
        );
        assertions.assertParam(judged);
    }

    function test_core_judges_foldExpression() public {
        // the charset recipe judged end-to-end: symbol() is all-uppercase,
        // so the a-z mask fails and the A-Z mask holds
        uint256 lower;
        uint256 upper;
        for (uint256 i = 0; i < 26; i++) {
            lower |= 1 << (97 + i);
            upper |= 1 << (65 + i);
        }
        bytes memory template = abi.encodeWithSelector(Operators.bitSet.selector, upper, uint256(0));
        bytes memory foldCalldata = abi.encodeCall(
            Operators.foldBytes,
            (bytes("WETH"), address(ops), template, 36, 36, bytes32(uint256(1)), Operators.FoldExit.All)
        );
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(ops), foldCalldata),
            _c1(ConstraintType.EQ, abi.encode(uint256(1)))
        );
        assertions.assertParam(judged);

        bytes memory lowerTemplate = abi.encodeWithSelector(Operators.bitSet.selector, lower, uint256(0));
        bytes memory failingFold = abi.encodeCall(
            Operators.foldBytes,
            (bytes("WETH"), address(ops), lowerTemplate, 36, 36, bytes32(uint256(1)), Operators.FoldExit.All)
        );
        InputParam memory failing = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(ops), failingFold),
            _c1(ConstraintType.EQ, abi.encode(uint256(1)))
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(0)),
                abi.encode(uint256(1))
            )
        );
        assertions.assertParam(failing);
    }

    function test_core_judges_failingExpression_withMessage() public {
        bytes memory expression = _read2(ADD_U, _lit(20), _lit(21));
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), expression),
            _c1(ConstraintType.EQ, abi.encode(uint256(42)))
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "not the answer",
                0,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(41)),
                abi.encode(uint256(42))
            )
        );
        assertions.assertParam(judged, "not the answer");
    }

    function test_dirtyAddressArg_revertsInsideCall() public {
        // a dirty word spliced into an address argument fails the callee's
        // ABI decoding, surfacing as CallFailed on the constructed call
        bytes memory callData = bytes.concat(
            abi.encodePacked(Operators.balance.selector),
            abi.encode(bytes32(uint256(1) << 170))
        );
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(ops), callData));
        assertions.read(
            _lit(uint256(uint160(address(ops)))),
            Operators.balance.selector,
            _args1(InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(bytes32(uint256(1) << 170)), _none()))
        );
    }
}
