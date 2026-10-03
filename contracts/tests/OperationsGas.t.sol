// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";
import "../Collections.sol";
import "../lib/ERC8211.sol";

/**
 * @notice The measurements behind the admission doctrine in
 *         docs/operators/index.md. Every figure that document quotes to
 *         justify a slot is produced here, so the argument for keeping a
 *         function stays checkable instead of decaying into folklore.
 *
 * @dev Costs are taken with gasleft() around a raw staticcall, which is
 *      what a fold and the core's read both do per element, so the
 *      numbers are directly comparable across the native and composed
 *      shapes. They move with the compiler and the optimizer settings —
 *      the assertions below bound the RATIO the doctrine argues from, not
 *      the absolute gas, so a few percent of drift does not fail the
 *      suite while a lost order of magnitude does.
 *
 *      Run with `pnpm test` and read the emitted log lines to refresh the
 *      tables in the docs.
 */
contract OperationsGasTest is Test {
    Assertions public assertions;
    Operations public ops;
    Collections cols;

    bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
    bytes4 constant BITAND_U = bytes4(keccak256("bitAnd(uint256,uint256)"));
    bytes4 constant SHR_U = bytes4(keccak256("shr(uint256,uint256)"));

    uint256 constant RAY = 1e27;
    uint256 constant SPY = 31_536_000;

    function setUp() public {
        assertions = new Assertions();
        ops = new Operations();
        cols = new Collections();
    }

    /**
     * One-element elemOffsets array — the N=1 shape every pre-C caller uses.
     */
    function _offs(uint256 o) internal pure returns (uint256[] memory a) {
        a = new uint256[](1);
        a[0] = o;
    }

    /**
     * Gas consumed by one staticcall, the unit both shapes are billed in.
     */
    function _cost(address target, bytes memory data) internal view returns (uint256) {
        uint256 before = gasleft();
        (bool okCall,) = target.staticcall(data);
        uint256 spent = before - gasleft();
        require(okCall, "measured call reverted");
        return spent;
    }

    function _none() internal pure returns (Constraint[] memory) {}

    function _lit(uint256 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    function _opsRead(bytes4 selector, InputParam[] memory args) internal view returns (bytes memory) {
        return abi.encodeCall(Assertions.read, (_lit(uint256(uint160(address(ops)))), selector, args));
    }

    function _args2(InputParam memory a, InputParam memory b) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](2);
        ps[0] = a;
        ps[1] = b;
    }

    // ============ Test 3: native loop vs fold ============

    function test_gas_charset_nativeVsFold() public {
        // The doctrine's 21-byte string.
        bytes memory s = "abcdefghijklmnopqrstu";
        uint256 mask;
        for (uint256 i = 97; i <= 122; i++) {
            mask |= 1 << i;
        }

        uint256 native = _cost(address(ops), abi.encodeCall(Operations.charset, (s, mask)));

        bytes memory template = abi.encodeWithSelector(Operations.bitSet.selector, mask, uint256(0));
        uint256 fold = _cost(
            address(cols),
            abi.encodeCall(
                Collections.fold,
                (
                    Collections.FoldDomain.Bytes,
                    0,
                    s,
                    address(ops),
                    template,
                    36,
                    _offs(36),
                    bytes32(uint256(1)),
                    Collections.FoldExit.All
                )
            )
        );

        emit log_named_uint("charset native (21 bytes)", native);
        emit log_named_uint("charset fold   (21 bytes)", fold);
        emit log_named_uint("charset saved            ", fold - native);
        // A fold pays one external call per byte; the native loop pays one
        // in total. The doctrine claims ~8x on this input.
        // Measured ~4.6x; the bound leaves room for compiler drift and
        // fails only if the native loop stops being an order-of-magnitude
        // argument.
        assertGt(fold, native * 3, "the native loop must stay far cheaper than the fold");
    }

    function test_gas_sumWords_nativeVsFold() public {
        bytes memory payload = abi.encodePacked(
            uint256(1),
            uint256(2),
            uint256(3),
            uint256(4),
            uint256(5),
            uint256(6),
            uint256(7),
            uint256(8),
            uint256(9),
            uint256(10),
            uint256(11),
            uint256(12)
        );

        uint256 native = _cost(address(cols), abi.encodeCall(Collections.sumWords, (payload)));

        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        uint256 fold = _cost(
            address(cols),
            abi.encodeCall(
                Collections.fold,
                (
                    Collections.FoldDomain.Words,
                    0,
                    payload,
                    address(ops),
                    template,
                    4,
                    _offs(36),
                    bytes32(0),
                    Collections.FoldExit.Full
                )
            )
        );

        emit log_named_uint("sumWords native (12 words)", native);
        emit log_named_uint("sumWords fold   (12 words)", fold);
        emit log_named_uint("sumWords saved            ", fold - native);
        // Measured ~2.3x (the fold's per-element calls against one call).
        assertGt(fold * 2, native * 3, "the native loop must stay materially cheaper than the fold");
    }

    // ============ Test 2: native lambda vs composed lambda ============

    function test_gas_bitSet_nativeVsComposedLambda() public {
        uint256 mask;
        for (uint256 i = 97; i <= 122; i++) {
            mask |= 1 << i;
        }
        uint256 ch = uint256(uint8(bytes1("h")));

        // What a fold pays per element with bitSet as the lambda.
        uint256 native = _cost(address(ops), abi.encodeCall(Operations.bitSet, (mask, ch)));

        // The same predicate composed: bitAnd(shr(mask, ch), 1), routed
        // through the core's read with a nested read inside it — the shape
        // the lambda would take if bitSet did not exist.
        InputParam memory shifted = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), _opsRead(SHR_U, _args2(_lit(mask), _lit(ch)))),
            _none()
        );
        uint256 composed = _cost(address(assertions), _opsRead(BITAND_U, _args2(shifted, _lit(1))));

        emit log_named_uint("bitSet native lambda  /element", native);
        emit log_named_uint("bitSet composed lambda/element", composed);
        emit log_named_uint("bitSet extra          /element", composed - native);
        // The doctrine argues roughly nine times the gas per element.
        // Measured ~5x per element.
        assertGt(composed, native * 3, "composing the lambda must cost multiples of the native call");
    }

    function test_gas_hashPairSorted_nativeVsComposed() public {
        bytes32 a = keccak256("left");
        bytes32 b = keccak256("right");

        uint256 native = _cost(address(ops), abi.encodeCall(Operations.hashPairSorted, (a, b)));

        // Composed: hash(sortWords([a, b])) — two nested Operations calls
        // through the core per Merkle level.
        bytes memory payload = abi.encodePacked(a, b);
        InputParam memory sorted = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(cols), abi.encodeCall(Collections.sortWords, (payload))),
            _none()
        );
        InputParam[] memory one = new InputParam[](1);
        one[0] = sorted;
        uint256 composed = _cost(address(assertions), _opsRead(bytes4(keccak256("hash(bytes)")), one));

        emit log_named_uint("hashPairSorted native  /level", native);
        emit log_named_uint("hashPairSorted composed/level", composed);
        emit log_named_uint("hashPairSorted extra   /level", composed - native);
        // Measured ~3x per level.
        assertGt(composed * 2, native * 3, "the composed Merkle step must cost multiples of the native one");
    }

    // ============ Test 1: the fixed-point family ============

    function test_gas_fixedPoint() public {
        uint256 ratePerSecond = 5e25 / SPY;
        uint256 rpowApy = _cost(address(ops), abi.encodeCall(Operations.rpow, (RAY + ratePerSecond, SPY, RAY)));
        uint256 rpowSmall = _cost(address(ops), abi.encodeCall(Operations.rpow, (15e26, 2, RAY)));
        uint256 log2Cost = _cost(address(ops), abi.encodeCall(Operations.log2, (type(uint256).max)));

        emit log_named_uint("rpow  (APY exponent, 2^25)", rpowApy);
        emit log_named_uint("rpow  (squaring)          ", rpowSmall);
        emit log_named_uint("log2  (2^255)             ", log2Cost);

        // rpow over the APY exponent is ~25 squarings INSIDE one call. The
        // composed form is not measurable here and that is the admission
        // argument: an expression is a tree with no way to name a subterm,
        // so each squaring duplicates its operand's calldata subtree and
        // the composed shape is 2^25 copies of the base read. One call
        // that stays well inside a block's budget replaces something that
        // cannot be encoded at all.
        assertLt(rpowApy, 100_000, "the whole compounding must stay cheap enough to sit inside an assertion");
    }

    // ============ Composed fold with a realistic B1 template ============

    // The SDK fixture from CoreTargetLambda.t.sol (~964 bytes): a core-target
    // `gt(<element>, tgt.getValue())` read. Measured here so the doctrine
    // cap quotes a real composed-lambda cost at B1 template size, not the
    // harness's minimal Operations templates.
    bytes constant SDK_TEMPLATE =
        hex"3efa16b7000000000000000000000000000000000000000000000000000000000000006021e5749b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000097e7a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000007a49e70000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000420965255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    uint256 constant SDK_ELEM_OFFSET = 580;

    function test_gas_composedFold_realisticB1Template() public {
        address core_ = address(uint160(0xA55E7));
        address ops_ = address(uint160(0x97E7A7));
        address tgt_ = address(uint160(0x7A49E7));
        vm.etch(core_, address(assertions).code);
        vm.etch(ops_, address(ops).code);
        // Minimal getValue() stand-in: ignore calldata, return word 100.
        vm.etch(tgt_, hex"606460005260206000f3");

        bytes memory payload = abi.encodePacked(uint256(10), uint256(200), uint256(30));
        uint256 composed = _cost(
            address(cols),
            abi.encodeCall(
                Collections.fold,
                (
                    Collections.FoldDomain.Words,
                    0,
                    payload,
                    core_,
                    SDK_TEMPLATE,
                    SDK_ELEM_OFFSET,
                    _offs(SDK_ELEM_OFFSET),
                    bytes32(0),
                    Collections.FoldExit.Any
                )
            )
        );

        // Same domain, tiny Operations lambda (gt(elem, 100)) for the ratio.
        bytes4 GT_U = bytes4(keccak256("gt(uint256,uint256)"));
        bytes memory tiny = abi.encodeWithSelector(GT_U, uint256(0), uint256(100));
        uint256 direct = _cost(
            address(cols),
            abi.encodeCall(
                Collections.fold,
                (
                    Collections.FoldDomain.Words,
                    0,
                    payload,
                    address(ops),
                    tiny,
                    4,
                    _offs(4),
                    bytes32(0),
                    Collections.FoldExit.Any
                )
            )
        );

        emit log_named_uint("composed B1 fold (~964B tpl, 3 elems)", composed);
        emit log_named_uint("direct Operations fold (tiny tpl, 3 elems)", direct);
        emit log_named_uint("composed/direct ratio x100", (composed * 100) / direct);
        // Calldata copying + core decode scale with template size; the
        // composed form must stay a clear multiple of the tiny fold.
        assertGt(composed, direct, "a ~1KB core-target fold must cost more than a tiny Operations fold");
    }

    // ============ Per-unit ceilings for the optimized loops ============

    // The marginal cost of one more element, byte or digit, taken between a
    // small and a large input so fixed costs cancel. The ceilings sit about
    // half again above the figures measured when the loops were optimized
    // (2026-10-03): they catch a loop that falls back to checked slices,
    // per-element descriptor parsing or a per-position search, not a few
    // percent of drift.
    uint256 constant SMALL = 10;
    uint256 constant LARGE = 50;

    function _perUnit(address target, bytes memory small, bytes memory large) internal view returns (uint256) {
        (bool warm,) = target.staticcall(small);
        require(warm, "measured call reverted");
        return (_cost(target, large) - _cost(target, small)) / (LARGE - SMALL);
    }

    function _wordsOf(uint256 n) internal pure returns (bytes memory p) {
        for (uint256 i; i < n; i++) {
            p = bytes.concat(p, abi.encode(1000 + i));
        }
    }

    function _valuesOf(uint256 n) internal pure returns (bytes[] memory v) {
        v = new bytes[](n);
        for (uint256 i; i < n; i++) {
            v[i] = abi.encode(1000 + i);
        }
    }

    function _text(uint256 n, bytes1 c) internal pure returns (bytes memory t) {
        t = new bytes(n);
        for (uint256 i; i < n; i++) {
            t[i] = c;
        }
    }

    function _addCallback() internal view returns (Collections.Callback memory x) {
        x.target = address(ops);
        x.selector = ADD_U;
        x.arguments = "(uint256,uint256)";
        x.constants = new bytes[](2);
        x.constants[1] = abi.encode(uint256(7));
        x.second = 1;
    }

    function _ceiling(string memory name, uint256 measured, uint256 ceiling) internal {
        emit log_named_uint(name, measured);
        assertLt(measured, ceiling, name);
    }

    function test_gas_perUnitCeilings() public {
        bytes memory tpl = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        _ceiling(
            "sumWords, per word",
            _perUnit(
                address(cols),
                abi.encodeCall(Collections.sumWords, (_wordsOf(SMALL))),
                abi.encodeCall(Collections.sumWords, (_wordsOf(LARGE)))
            ),
            CEIL_SUM_WORDS
        );
        _ceiling(
            "zipWords, per pair",
            _perUnit(
                address(cols),
                abi.encodeCall(Collections.zipWords, (_wordsOf(SMALL), _wordsOf(SMALL))),
                abi.encodeCall(Collections.zipWords, (_wordsOf(LARGE), _wordsOf(LARGE)))
            ),
            CEIL_ZIP_WORDS
        );
        _ceiling(
            "mapWords with an Operations lambda, per element",
            _perUnit(
                address(cols),
                abi.encodeCall(Collections.applyWords, (_wordsOf(SMALL), address(ops), tpl, _offs(4), false)),
                abi.encodeCall(Collections.applyWords, (_wordsOf(LARGE), address(ops), tpl, _offs(4), false))
            ),
            CEIL_MAP_WORDS
        );
        _ceiling(
            "reduceWords (All, GE) with an Operations lambda, per element",
            _perUnit(
                address(cols),
                abi.encodeCall(
                    Collections.reduceWords,
                    (
                        _wordsOf(SMALL),
                        address(ops),
                        tpl,
                        _offs(4),
                        Collections.Reduce.All,
                        Collections.Cmp.GE,
                        bytes32(0)
                    )
                ),
                abi.encodeCall(
                    Collections.reduceWords,
                    (
                        _wordsOf(LARGE),
                        address(ops),
                        tpl,
                        _offs(4),
                        Collections.Reduce.All,
                        Collections.Cmp.GE,
                        bytes32(0)
                    )
                )
            ),
            CEIL_REDUCE_WORDS
        );
        _ceiling(
            "reverseValues over addresses, per element",
            _perUnit(
                address(cols),
                abi.encodeCall(Collections.reverseValues, ("address", _valuesOf(SMALL))),
                abi.encodeCall(Collections.reverseValues, ("address", _valuesOf(LARGE)))
            ),
            CEIL_REVERSE_VALUES
        );
        _ceiling(
            "mapValues with an Operations callback, per element",
            _perUnit(
                address(cols),
                abi.encodeCall(Collections.mapValues, ("uint256", "uint256", _valuesOf(SMALL), _addCallback())),
                abi.encodeCall(Collections.mapValues, ("uint256", "uint256", _valuesOf(LARGE), _addCallback()))
            ),
            CEIL_MAP_VALUES
        );
        _ceiling(
            "packArray over addresses, per element",
            _perUnit(
                address(cols),
                abi.encodeCall(Collections.packArray, ("address", _valuesOf(SMALL))),
                abi.encodeCall(Collections.packArray, ("address", _valuesOf(LARGE)))
            ),
            CEIL_PACK_ARRAY
        );
        // Text loops are measured over ten times the length, so the unit is ten bytes.
        _ceiling(
            "contains with an absent needle, per ten bytes",
            _perUnit(
                address(ops),
                abi.encodeCall(Operations.contains, (_text(SMALL * 10, "a"), "b")),
                abi.encodeCall(Operations.contains, (_text(LARGE * 10, "a"), "b"))
            ),
            CEIL_CONTAINS
        );
        _ceiling(
            "stringSlice over ASCII, per ten bytes",
            _perUnit(
                address(ops),
                abi.encodeCall(Operations.stringSlice, (_text(SMALL * 10, "a"), 0, 1)),
                abi.encodeCall(Operations.stringSlice, (_text(LARGE * 10, "a"), 0, 1))
            ),
            CEIL_STRING_SLICE
        );
        _ceiling(
            "toLower, per ten bytes",
            _perUnit(
                address(ops),
                abi.encodeCall(Operations.toLower, (_text(SMALL * 10, "A"))),
                abi.encodeCall(Operations.toLower, (_text(LARGE * 10, "A")))
            ),
            CEIL_TO_LOWER
        );
        _ceiling(
            "parseUint, per digit",
            _perUnit(
                address(ops),
                abi.encodeCall(Operations.parseUint, (_text(SMALL, "1"))),
                abi.encodeCall(Operations.parseUint, (_text(LARGE, "1")))
            ),
            CEIL_PARSE_UINT
        );
    }

    uint256 constant CEIL_SUM_WORDS = 230;
    uint256 constant CEIL_ZIP_WORDS = 345;
    uint256 constant CEIL_MAP_WORDS = 1700;
    uint256 constant CEIL_REDUCE_WORDS = 2100;
    uint256 constant CEIL_REVERSE_VALUES = 3700;
    uint256 constant CEIL_MAP_VALUES = 9500;
    uint256 constant CEIL_PACK_ARRAY = 3700;
    uint256 constant CEIL_CONTAINS = 1300;
    uint256 constant CEIL_STRING_SLICE = 200;
    uint256 constant CEIL_TO_LOWER = 1600;
    uint256 constant CEIL_PARSE_UINT = 250;

    // ============ reduceWords against the composed fold it replaces ============

    bytes4 constant GT_U = bytes4(keccak256("gt(uint256,uint256)"));
    uint256 constant SENTINEL = uint256(keccak256("element window"));

    /**
     * @dev The byte offset of the sentinel word in `data`, found by scanning
     */
    function _find(bytes memory data) internal pure returns (uint256 at) {
        for (; at + 32 <= data.length; at++) {
            uint256 w;
            assembly ("memory-safe") {
                w := mload(add(add(data, 32), at))
            }
            if (w == SENTINEL) return at;
        }
        revert("no sentinel");
    }

    /**
     * @dev "every add(x, 7) is above 0", two ways: reduceWords (All, GT, 0)
     *      over the add lambda, against a fold with the All exit whose
     *      lambda is a core read of gt(add(x, 7), 0), the comparison
     *      composed around the call
     */
    function test_gas_reduceWordsAgainstComposedFold() public {
        bytes memory tpl = abi.encodeWithSelector(ADD_U, uint256(0), uint256(7));
        uint256 direct = _perUnit(
            address(cols),
            abi.encodeCall(
                Collections.reduceWords,
                (_wordsOf(SMALL), address(ops), tpl, _offs(4), Collections.Reduce.All, Collections.Cmp.GT, bytes32(0))
            ),
            abi.encodeCall(
                Collections.reduceWords,
                (_wordsOf(LARGE), address(ops), tpl, _offs(4), Collections.Reduce.All, Collections.Cmp.GT, bytes32(0))
            )
        );
        bytes memory composedTpl = _opsRead(
            GT_U,
            _args2(
                InputParam(
                    InputParamType.CALL_DATA,
                    InputParamFetcherType.STATIC_CALL,
                    abi.encode(address(ops), abi.encodeWithSelector(ADD_U, SENTINEL, uint256(7))),
                    _none()
                ),
                _lit(0)
            )
        );
        uint256 at = _find(composedTpl);
        uint256 composed = _perUnit(
            address(cols),
            abi.encodeCall(
                Collections.fold,
                (
                    Collections.FoldDomain.Words,
                    0,
                    _wordsOf(SMALL),
                    address(assertions),
                    composedTpl,
                    at,
                    _offs(at),
                    bytes32(uint256(1)),
                    Collections.FoldExit.All
                )
            ),
            abi.encodeCall(
                Collections.fold,
                (
                    Collections.FoldDomain.Words,
                    0,
                    _wordsOf(LARGE),
                    address(assertions),
                    composedTpl,
                    at,
                    _offs(at),
                    bytes32(uint256(1)),
                    Collections.FoldExit.All
                )
            )
        );
        emit log_named_uint("reduceWords (All, GT) over add, per element", direct);
        emit log_named_uint("fold (All) over a core read of gt(add), per element", composed);
        assertLt(direct * 3, composed, "reduceWords must stay well under the composed fold");
    }
}
