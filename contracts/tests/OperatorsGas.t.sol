// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operators.sol";
import "../ERC8211.sol";

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
contract OperatorsGasTest is Test {
    Assertions public assertions;
    Operators public ops;

    bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
    bytes4 constant BITAND_U = bytes4(keccak256("bitAnd(uint256,uint256)"));
    bytes4 constant SHR_U = bytes4(keccak256("shr(uint256,uint256)"));

    uint256 constant RAY = 1e27;
    uint256 constant WAD = 1e18;
    uint256 constant SPY = 31_536_000;

    function setUp() public {
        assertions = new Assertions();
        ops = new Operators();
    }

    /** Gas consumed by one staticcall, the unit both shapes are billed in. */
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

        uint256 native = _cost(address(ops), abi.encodeCall(Operators.charset, (s, mask)));

        bytes memory template = abi.encodeWithSelector(Operators.bitSet.selector, mask, uint256(0));
        uint256 fold = _cost(
            address(ops),
            abi.encodeCall(
                Operators.foldBytes,
                (s, address(ops), template, 36, 36, bytes32(uint256(1)), Operators.FoldExit.All)
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

        uint256 native = _cost(address(ops), abi.encodeCall(Operators.sumWords, (payload)));

        bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
        uint256 fold = _cost(
            address(ops),
            abi.encodeCall(
                Operators.foldWords,
                (payload, address(ops), template, 4, 36, bytes32(0), Operators.FoldExit.Full)
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
        uint256 native = _cost(address(ops), abi.encodeCall(Operators.bitSet, (mask, ch)));

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

        uint256 native = _cost(address(ops), abi.encodeCall(Operators.hashPairSorted, (a, b)));

        // Composed: hash(sortWords([a, b])) — two nested Operators calls
        // through the core per Merkle level.
        bytes memory payload = abi.encodePacked(a, b);
        InputParam memory sorted = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(ops), abi.encodeCall(Operators.sortWords, (payload))),
            _none()
        );
        InputParam[] memory one = new InputParam[](1);
        one[0] = sorted;
        uint256 composed =
            _cost(address(assertions), _opsRead(bytes4(keccak256("hash(bytes)")), one));

        emit log_named_uint("hashPairSorted native  /level", native);
        emit log_named_uint("hashPairSorted composed/level", composed);
        emit log_named_uint("hashPairSorted extra   /level", composed - native);
        // Measured ~3x per level.
        assertGt(composed * 2, native * 3, "the composed Merkle step must cost multiples of the native one");
    }

    // ============ Test 1: the fixed-point family ============

    function test_gas_fixedPoint() public {
        uint256 ratePerSecond = 5e25 / SPY;
        uint256 rpowApy = _cost(address(ops), abi.encodeCall(Operators.rpow, (RAY + ratePerSecond, SPY, RAY)));
        uint256 rpowSmall = _cost(address(ops), abi.encodeCall(Operators.rpow, (15e26, 2, RAY)));
        uint256 expCost = _cost(address(ops), abi.encodeCall(Operators.expWad, (int256(WAD))));
        uint256 lnCost = _cost(address(ops), abi.encodeCall(Operators.lnWad, (2 * int256(WAD))));
        uint256 log2Cost = _cost(address(ops), abi.encodeCall(Operators.log2, (type(uint256).max)));

        emit log_named_uint("rpow  (APY exponent, 2^25)", rpowApy);
        emit log_named_uint("rpow  (squaring)          ", rpowSmall);
        emit log_named_uint("expWad(1e18)              ", expCost);
        emit log_named_uint("lnWad (2e18)              ", lnCost);
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

    // ============ Size ============

    function test_runtimeSizeWithinEip170() public {
        uint256 size = address(ops).code.length;
        emit log_named_uint("Operators runtime bytes", size);
        emit log_named_uint("EIP-170 headroom       ", 24576 - size);
        // Nothing else in the repo checks this, and the periphery is the
        // contract that grows.
        assertLt(size, 24576, "Operators must stay deployable under EIP-170");
    }
}
