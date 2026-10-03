// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Collections} from "../Collections.sol";
import {AbiCodec} from "../lib/AbiCodec.sol";

contract ReduceLambdas {
    uint256 public immutable seed;

    constructor(uint256 seed_) {
        seed = seed_;
    }

    /**
     * @dev A fixed but arbitrary word per element, so results are not the elements themselves
     */
    function mix(uint256 x) external view returns (uint256) {
        return uint256(keccak256(abi.encode(seed, x)));
    }

    function same(uint256 x) external pure returns (uint256) {
        return x;
    }

    function boom(uint256 x) external pure returns (uint256) {
        if (x == 7) revert("seven");
        return x;
    }

    function wide(uint256 x) external pure returns (uint256, uint256) {
        return (x, x);
    }
}

/**
 * @notice reduceWords against a reference written the long way: one call per
 *         element, then the comparison or the sum in plain Solidity
 */
contract ReduceWordsTest is Test {
    Collections collections;
    ReduceLambdas lambdas;

    function setUp() public {
        collections = new Collections();
        lambdas = new ReduceLambdas(1);
    }

    function offs(uint256 o) internal pure returns (uint256[] memory a) {
        a = new uint256[](1);
        a[0] = o;
    }

    function pack(uint256[] memory xs) internal pure returns (bytes memory p) {
        for (uint256 i; i < xs.length; i++) {
            p = bytes.concat(p, bytes32(xs[i]));
        }
    }

    function passes(uint256 a, Collections.Cmp cmp, uint256 b) internal pure returns (bool) {
        if (cmp == Collections.Cmp.EQ) return a == b;
        if (cmp == Collections.Cmp.NE) return a != b;
        if (cmp == Collections.Cmp.LT) return a < b;
        if (cmp == Collections.Cmp.LE) return a <= b;
        if (cmp == Collections.Cmp.GT) return a > b;
        if (cmp == Collections.Cmp.GE) return a >= b;
        if (cmp == Collections.Cmp.SLT) return int256(a) < int256(b);
        if (cmp == Collections.Cmp.SLE) return int256(a) <= int256(b);
        if (cmp == Collections.Cmp.SGT) return int256(a) > int256(b);
        return int256(a) >= int256(b);
    }

    function reduce(uint256[] memory xs, bytes4 lambda, Collections.Reduce mode, Collections.Cmp cmp, uint256 bound)
        internal
        view
        returns (uint256)
    {
        return collections.reduceWords(
            pack(xs), address(lambdas), abi.encodeWithSelector(lambda, uint256(0)), offs(4), mode, cmp, bytes32(bound)
        );
    }

    /**
     * @dev All, Any and Count agree with the reference for every comparison,
     *      over results spread across the whole word (so signed and unsigned
     *      orderings disagree) and bounds drawn from the results themselves
     *      (so equality and the boundary of each ordering are hit)
     */
    function testFuzz_reduceMatchesReference(uint256[] memory xs, uint8 cmpCase, uint256 boundSeed, bool fromResults)
        public
        view
    {
        vm.assume(xs.length <= 24);
        Collections.Cmp cmp = Collections.Cmp(cmpCase % 10);
        uint256 bound = fromResults && xs.length != 0 ? lambdas.mix(xs[boundSeed % xs.length]) : boundSeed;
        uint256 count;
        for (uint256 i; i < xs.length; i++) {
            if (passes(lambdas.mix(xs[i]), cmp, bound)) count++;
        }
        bytes4 mix = ReduceLambdas.mix.selector;
        assertEq(reduce(xs, mix, Collections.Reduce.Count, cmp, bound), count, "count");
        assertEq(reduce(xs, mix, Collections.Reduce.All, cmp, bound), count == xs.length ? 1 : 0, "all");
        assertEq(reduce(xs, mix, Collections.Reduce.Any, cmp, bound), count != 0 ? 1 : 0, "any");
    }

    function testFuzz_sumMatchesReference(uint128[] memory xs, uint8 cmpCase, bytes32 bound) public view {
        vm.assume(xs.length <= 24);
        uint256[] memory wide = new uint256[](xs.length);
        uint256 total;
        for (uint256 i; i < xs.length; i++) {
            wide[i] = xs[i];
            total += xs[i];
        }
        // The comparison and the bound are ignored by Sum.
        assertEq(
            reduce(
                wide, ReduceLambdas.same.selector, Collections.Reduce.Sum, Collections.Cmp(cmpCase % 10), uint256(bound)
            ),
            total
        );
    }

    /**
     * @dev Every comparison at its boundary, with hand-picked words: equal,
     *      one apart, and the pair unsigned and signed order disagree on
     */
    function test_everyComparisonAtItsBoundary() public view {
        uint256[] memory x = new uint256[](1);
        uint256 top = uint256(1) << 255; // the most negative int256, a large uint256
        bytes4 same = ReduceLambdas.same.selector;
        Collections.Reduce all = Collections.Reduce.All;
        x[0] = 5;
        assertEq(reduce(x, same, all, Collections.Cmp.EQ, 5), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.EQ, 6), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.NE, 5), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.NE, 6), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.LT, 5), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.LT, 6), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.LE, 5), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.LE, 4), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.GT, 5), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.GT, 4), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.GE, 5), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.GE, 6), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.SLT, 5), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.SLT, 6), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SLE, 5), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SLE, 4), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.SGT, 5), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.SGT, 4), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SGE, 5), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SGE, 6), 0);
        // 5 against the top-bit word: below it unsigned, above it signed.
        assertEq(reduce(x, same, all, Collections.Cmp.LT, top), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SLT, top), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.GT, top), 0);
        assertEq(reduce(x, same, all, Collections.Cmp.SGT, top), 1);
        x[0] = top;
        assertEq(reduce(x, same, all, Collections.Cmp.SLE, top), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SGE, top), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.SLT, 0), 1);
        assertEq(reduce(x, same, all, Collections.Cmp.LT, 0), 0);
    }

    function test_emptyPayloadTouchesNoTarget() public view {
        bytes memory tpl = abi.encodeWithSelector(ReduceLambdas.same.selector, uint256(0));
        // address(0) has no code: an empty payload must not look at it.
        assertEq(
            collections.reduceWords(
                "", address(0), tpl, offs(4), Collections.Reduce.All, Collections.Cmp.GE, bytes32(0)
            ),
            1
        );
        assertEq(
            collections.reduceWords(
                "", address(0), tpl, offs(4), Collections.Reduce.Any, Collections.Cmp.GE, bytes32(0)
            ),
            0
        );
        assertEq(
            collections.reduceWords(
                "", address(0), tpl, offs(4), Collections.Reduce.Count, Collections.Cmp.GE, bytes32(0)
            ),
            0
        );
        assertEq(
            collections.reduceWords(
                "", address(0), tpl, offs(4), Collections.Reduce.Sum, Collections.Cmp.GE, bytes32(0)
            ),
            0
        );
    }

    /**
     * @dev All stops at the first miss and Any at the first match: the
     *      element after it would revert the lambda and is never reached
     */
    function test_earlyExitSkipsLaterElements() public view {
        uint256[] memory x = new uint256[](3);
        x[0] = 1;
        x[1] = 9;
        x[2] = 7; // boom reverts on 7
        bytes4 boom = ReduceLambdas.boom.selector;
        assertEq(reduce(x, boom, Collections.Reduce.All, Collections.Cmp.LT, 5), 0);
        assertEq(reduce(x, boom, Collections.Reduce.Any, Collections.Cmp.GT, 5), 1);
    }

    function test_declaredErrors() public {
        uint256[] memory x = new uint256[](2);
        x[0] = 1;
        x[1] = 7;
        bytes memory tpl = abi.encodeWithSelector(ReduceLambdas.boom.selector, uint256(0));
        bytes4 op = Collections.reduceWords.selector;

        vm.expectRevert(abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(33)));
        collections.reduceWords(
            new bytes(33), address(lambdas), tpl, offs(4), Collections.Reduce.All, Collections.Cmp.EQ, 0
        );

        vm.expectRevert(abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(5), uint256(36)));
        collections.reduceWords(pack(x), address(lambdas), tpl, offs(5), Collections.Reduce.All, Collections.Cmp.EQ, 0);

        vm.expectRevert(abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0xdead)));
        collections.reduceWords(pack(x), address(0xdead), tpl, offs(4), Collections.Reduce.All, Collections.Cmp.EQ, 0);

        // The reverting element is named: element 1, with the calldata sent and the reason.
        vm.expectRevert(
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                op,
                uint256(1),
                uint256(0),
                address(lambdas),
                abi.encodeWithSelector(ReduceLambdas.boom.selector, uint256(7)),
                abi.encodeWithSignature("Error(string)", "seven")
            )
        );
        collections.reduceWords(
            pack(x), address(lambdas), tpl, offs(4), Collections.Reduce.Count, Collections.Cmp.EQ, 0
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, op, uint256(0), uint256(0), address(lambdas)
            )
        );
        collections.reduceWords(
            pack(x),
            address(lambdas),
            abi.encodeWithSelector(ReduceLambdas.wide.selector, uint256(0)),
            offs(4),
            Collections.Reduce.Count,
            Collections.Cmp.EQ,
            0
        );
    }

    function test_sumOverflowPanics() public {
        uint256[] memory x = new uint256[](2);
        x[0] = type(uint256).max;
        x[1] = 1;
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", uint256(0x11)));
        collections.reduceWords(
            pack(x),
            address(lambdas),
            abi.encodeWithSelector(ReduceLambdas.same.selector, uint256(0)),
            offs(4),
            Collections.Reduce.Sum,
            Collections.Cmp.EQ,
            0
        );
    }

    /**
     * @dev An out-of-range mode or comparison never reaches the code: the ABI
     *      decoder refuses it without data
     */
    function test_outOfRangeEnumsAreRefusedByTheDecoder() public view {
        uint256[] memory x = new uint256[](1);
        bytes memory tpl = abi.encodeWithSelector(ReduceLambdas.same.selector, uint256(0));
        bytes4 op = Collections.reduceWords.selector;
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(op, pack(x), address(lambdas), tpl, offs(4), uint8(4), uint8(0), bytes32(0))
            );
        assertFalse(ok);
        assertEq(out, "");
        (ok, out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(op, pack(x), address(lambdas), tpl, offs(4), uint8(0), uint8(10), bytes32(0))
            );
        assertFalse(ok);
        assertEq(out, "");
    }

    /**
     * @dev The element is written into every window, in the supplied order
     */
    function test_everyWindowReceivesTheElement() public view {
        uint256[] memory x = new uint256[](2);
        x[0] = 3;
        x[1] = 4;
        uint256[] memory two = new uint256[](2);
        two[0] = 4;
        two[1] = 36;
        // same(x) reads only the first window; the second must be in bounds and is stamped too.
        bytes memory tpl = abi.encodePacked(ReduceLambdas.same.selector, uint256(0), uint256(0));
        assertEq(
            collections.reduceWords(pack(x), address(lambdas), tpl, two, Collections.Reduce.Sum, Collections.Cmp.EQ, 0),
            7
        );
    }
}
