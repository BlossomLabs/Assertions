// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";

/** @dev Callback targets with known meanings */
contract Lambdas {
    function scramble(uint256 x) external pure returns (uint256) {
        return x ^ 0xA5A5;
    }

    /** @dev Returns the whole word even when the caller declares a narrower result type */
    function identity(uint256 x) external pure returns (uint256) {
        return x;
    }

    function odd(uint256 x) external pure returns (bool) {
        return x & 1 == 1;
    }

    /** @dev Non-commutative, so the accumulator and element slots are observable */
    function step(uint256 acc, uint256 x) external pure returns (uint256) {
        unchecked {
            return acc * 3 + x;
        }
    }

    /** @dev Orders (key, tag) pairs by key only, so equal keys expose stability */
    function byKey(uint256 ka, uint256, uint256 kb, uint256) external pure returns (int256) {
        return ka > kb ? int256(1) : ka < kb ? -1 : int256(0);
    }

    function sameKey(uint256 ka, uint256, uint256 kb, uint256) external pure returns (bool) {
        return ka == kb;
    }

    function boom(uint256 x) external pure returns (uint256) {
        if (x == 7) revert("seven");
        return x;
    }
}

/**
 * @notice Halmos properties for the Collections callback traversals: map,
 *         filter, fold, sort, unique, any/all/find, slice and the callback
 *         error surface, each against a direct statement of its NatSpec.
 *         Run with `pnpm halmos`.
 * @dev Up to three symbolic elements; element counts and indices are
 *      case-split. Every call expected to succeed checks its success
 *      explicitly: Halmos discards reverting paths.
 */
contract ValuesSymbolicTest is Test {
    Collections collections;
    Lambdas lambdas;

    function setUp() public {
        collections = new Collections();
        lambdas = new Lambdas();
    }

    // ============ map / filter / fold ============

    function check_mapAppliesInOrder(uint8 countCase, bytes32[3] memory w) public view {
        bytes[] memory values = words(countCase, w);
        bytes[] memory out = abi.decode(
            call(abi.encodeCall(Collections.mapValues, ("uint256", "uint256", values, unary(Lambdas.scramble.selector)))),
            (bytes[])
        );
        assertEq(out.length, values.length);
        for (uint256 i; i < values.length; i++) {
            assertEq(out[i], abi.encode(uint256(w[i]) ^ 0xA5A5));
        }
    }

    /** @dev A result that is not a canonical outputType names its element */
    function check_mapValidatesResults(bytes32 v) public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(v);
        (bool ok, bytes memory out) = address(collections).staticcall(
            abi.encodeCall(Collections.mapValues, ("uint256", "uint8", values, unary(Lambdas.identity.selector)))
        );
        if (uint256(v) < 256) {
            assertTrue(ok, "a canonical result is refused");
        } else {
            assertFalse(ok, "a non-canonical result is accepted");
            assertEq(out, abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, Collections.mapValues.selector, uint256(0), uint256(0), address(lambdas)
            ));
        }
    }

    function check_filterKeepsMatchesInOrder(uint8 countCase, bytes32[3] memory w) public view {
        bytes[] memory values = words(countCase, w);
        bytes[] memory out = abi.decode(
            call(abi.encodeCall(Collections.filterValues, ("uint256", values, unary(Lambdas.odd.selector)))), (bytes[])
        );
        uint256 k;
        for (uint256 i; i < values.length; i++) {
            if (uint256(w[i]) & 1 == 1) assertEq(out[k++], values[i]);
        }
        assertEq(out.length, k, "an even value was kept");
    }

    /** @dev A left fold, accumulator in slot `first`, element in slot `second` */
    function check_foldIsLeftFold(uint8 countCase, bytes32[3] memory w, uint256 initial) public view {
        bytes[] memory values = words(countCase, w);
        uint256 expected = initial;
        for (uint256 i; i < values.length; i++) {
            unchecked {
                expected = expected * 3 + uint256(w[i]);
            }
        }
        bytes memory out = abi.decode(
            call(abi.encodeCall(
                Collections.foldValues, ("uint256", "uint256", values, abi.encode(initial), binary(Lambdas.step.selector, "(uint256,uint256)"))
            )),
            (bytes)
        );
        assertEq(out, abi.encode(expected));
    }

    // ============ sort / unique ============

    /** @dev Sorted by key, and STABLE: equal keys keep their input order (visible in the tags) */
    function check_sortIsStableByKey(uint8 countCase, uint8[3] memory keys) public view {
        bytes[] memory values = pairs(countCase, keys);
        uint256 n = values.length;
        bytes[] memory out = abi.decode(
            call(abi.encodeCall(Collections.sortValues, ("(uint256,uint256)", values, binary(Lambdas.byKey.selector, "((uint256,uint256),(uint256,uint256))")))),
            (bytes[])
        );
        assertEq(out.length, n);
        for (uint256 i = 1; i < n; i++) {
            (uint256 ka, uint256 ta) = abi.decode(out[i - 1], (uint256, uint256));
            (uint256 kb, uint256 tb) = abi.decode(out[i], (uint256, uint256));
            assertLe(ka, kb, "not sorted by key");
            if (ka == kb) assertLt(ta, tb, "equal keys reordered");
        }
        // A permutation: every input tag appears exactly once.
        for (uint256 t; t < n; t++) {
            uint256 seen;
            for (uint256 i; i < n; i++) {
                (, uint256 tag) = abi.decode(out[i], (uint256, uint256));
                if (tag == t) seen++;
            }
            assertEq(seen, 1, "not a permutation");
        }
    }

    /** @dev The first representative of each key class survives, in input order */
    function check_uniqueKeepsFirstRepresentatives(uint8 countCase, uint8[3] memory keys) public view {
        bytes[] memory values = pairs(countCase, keys);
        bytes[] memory out = abi.decode(
            call(abi.encodeCall(
                Collections.uniqueValues, ("(uint256,uint256)", values, binary(Lambdas.sameKey.selector, "((uint256,uint256),(uint256,uint256))"), false)
            )),
            (bytes[])
        );
        uint256 k;
        for (uint256 i; i < values.length; i++) {
            bool first = true;
            for (uint256 j; j < i; j++) {
                if (keys[j] == keys[i]) first = false;
            }
            if (first) assertEq(out[k++], values[i], "a first representative is missing");
        }
        assertEq(out.length, k, "a duplicate key survived");
    }

    /**
     * @dev ordered = true trusts that equal keys are grouped and compares each
     *      element only with the last one kept: an element survives exactly
     *      when its key differs from the last kept key, in input order
     */
    function check_uniqueOrderedComparesWithTheLastKept(uint8 countCase, uint8[3] memory keys) public view {
        bytes[] memory values = pairs(countCase, keys);
        bytes[] memory out = abi.decode(
            call(abi.encodeCall(
                Collections.uniqueValues, ("(uint256,uint256)", values, binary(Lambdas.sameKey.selector, "((uint256,uint256),(uint256,uint256))"), true)
            )),
            (bytes[])
        );
        uint256 k;
        uint8 lastKept;
        for (uint256 i; i < values.length; i++) {
            if (k == 0 || keys[i] != lastKept) {
                assertEq(out[k++], values[i], "an element whose key changed is missing");
                lastKept = keys[i];
            }
        }
        assertEq(out.length, k, "an element equal to the last kept survived");
    }

    // ============ any / all / find ============

    function check_findAnyAllAgree(uint8 countCase, bytes32[3] memory w) public view {
        bytes[] memory values = words(countCase, w);
        Collections.Callback memory cb = unary(Lambdas.odd.selector);
        uint256 found = type(uint256).max;
        bool every = true;
        for (uint256 i; i < values.length; i++) {
            bool isOdd = uint256(w[i]) & 1 == 1;
            if (isOdd && found == type(uint256).max) found = i;
            if (!isOdd) every = false;
        }
        assertEq(abi.decode(call(abi.encodeCall(Collections.findValues, ("uint256", values, cb))), (uint256)), found);
        assertEq(abi.decode(call(abi.encodeCall(Collections.anyValues, ("uint256", values, cb))), (bool)), found != type(uint256).max);
        assertEq(abi.decode(call(abi.encodeCall(Collections.allValues, ("uint256", values, cb))), (bool)), every);
    }

    // ============ slice ============

    /** @dev JavaScript Array.slice: signed, clamped, end exclusive, never reverting on the range */
    function check_sliceIsJsSlice(uint8 countCase, uint8 startCase, uint8 endCase, bytes32[3] memory w) public view {
        vm.assume(startCase < 7 && endCase < 7);
        bytes[] memory values = words(countCase, w);
        int256 n = int256(values.length);
        int256 start = index(startCase);
        int256 end = index(endCase);
        int256 a = start < 0 ? (start < -n ? int256(0) : n + start) : (start > n ? n : start);
        int256 b = end < 0 ? (end < -n ? int256(0) : n + end) : (end > n ? n : end);
        bytes[] memory out =
            abi.decode(call(abi.encodeCall(Collections.sliceValues, ("uint256", values, start, end))), (bytes[]));
        assertEq(out.length, b > a ? uint256(b - a) : 0);
        for (uint256 i; i < out.length; i++) {
            assertEq(out[i], values[uint256(a) + i]);
        }
    }

    // ============ Callback errors ============

    /**
     * @dev A reverting application surfaces as CallbackFailed naming the
     *      element and preserving the reason; an empty input never touches
     *      the target, and a code-less target is refused before the first
     *      application
     */
    function check_callbackErrors(uint8 countCase, bytes32[3] memory w, bool emptyTarget) public view {
        bytes[] memory values = words(countCase, w);
        Collections.Callback memory cb = unary(Lambdas.boom.selector);
        if (emptyTarget) cb.target = address(0xE0A);
        (bool ok, bytes memory out) = address(collections).staticcall(
            abi.encodeCall(Collections.mapValues, ("uint256", "uint256", values, cb))
        );
        // Halmos has no gas model: exclude the symbolic exhaustion artifact.
        // Concrete GasPropagationTest sweeps establish gas behavior separately.
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Collections.SubcallOutOfGas.selector)));
        if (values.length == 0) {
            assertTrue(ok, "an empty input touched the target");
            return;
        }
        if (emptyTarget) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0xE0A)));
            return;
        }
        uint256 seven = type(uint256).max;
        for (uint256 i; i < values.length && seven == type(uint256).max; i++) {
            if (uint256(w[i]) == 7) seven = i;
        }
        if (seven == type(uint256).max) {
            assertTrue(ok, "no application reverts, yet map does");
        } else {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                Collections.mapValues.selector,
                seven,
                uint256(0),
                address(lambdas),
                abi.encodeCall(Lambdas.boom, (uint256(7))),
                abi.encodeWithSignature("Error(string)", "seven")
            ));
        }
    }

    // ============ Callback-free traversals ============

    /** @dev reverse reverses and validates every element as the declared type */
    function check_reverseValues(uint8 countCase, bytes32[3] memory w) public view {
        bytes[] memory values = words(countCase, w);
        uint256 n = values.length;
        (bool ok, bytes memory raw) =
            address(collections).staticcall(abi.encodeCall(Collections.reverseValues, ("uint8", values)));
        uint256 dirty = type(uint256).max;
        for (uint256 i; i < n && dirty == type(uint256).max; i++) {
            if (uint256(w[i]) > 255) dirty = i;
        }
        if (dirty != type(uint256).max) {
            assertFalse(ok, "a dirty uint8 is reversed");
            assertEq(raw, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
            return;
        }
        assertTrue(ok, "reverse reverted on canonical values");
        bytes[] memory out = abi.decode(raw, (bytes[]));
        assertEq(out.length, n);
        for (uint256 i; i < n; i++) {
            assertEq(out[i], values[n - 1 - i]);
        }
    }

    /**
     * @dev zip pairs element-wise into canonical (uint256,string) values, the
     *      dynamic side giving each pair the 0x20 envelope; unzip inverts it
     */
    function check_zipUnzipValues(uint8 countCase, bytes32[3] memory w, uint8 lengthCase, bytes32 payload) public view {
        bytes[] memory left = words(countCase, w);
        uint256 n = left.length;
        vm.assume(lengthCase < 3);
        uint256 len = lengthCase == 0 ? 0 : lengthCase == 1 ? 5 : 33;
        bytes memory text = new bytes(len);
        for (uint256 i; i < len; i++) {
            text[i] = i < 32 ? payload[i] : bytes1(0x2a);
        }
        bytes[] memory right = new bytes[](n);
        for (uint256 i; i < n; i++) {
            right[i] = abi.encode(string(text));
        }
        bytes[] memory zipped = abi.decode(
            call(abi.encodeCall(Collections.zipValues, ("uint256", "string", left, right))), (bytes[])
        );
        assertEq(zipped.length, n);
        for (uint256 i; i < n; i++) {
            assertEq(zipped[i], bytes.concat(abi.encode(uint256(32)), abi.encode(uint256(w[i]), string(text))));
        }
        bytes[] memory lane0 = abi.decode(
            call(abi.encodeCall(Collections.unzipValues, ("uint256", "string", zipped, 0))), (bytes[])
        );
        bytes[] memory lane1 = abi.decode(
            call(abi.encodeCall(Collections.unzipValues, ("uint256", "string", zipped, 1))), (bytes[])
        );
        assertEq(abi.encode(lane0), abi.encode(left));
        assertEq(abi.encode(lane1), abi.encode(right));
    }

    function check_zipValuesRefusals(uint8 aCase, uint8 bCase, bytes32[3] memory w, uint256 lane) public view {
        bytes[] memory a = words(aCase, w);
        bytes[] memory b = words(bCase, w);
        vm.assume(a.length != b.length);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.zipValues, ("uint256", "uint256", a, b)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Collections.LengthMismatch.selector, a.length, b.length));
        vm.assume(lane > 1);
        (ok, out) = address(collections).staticcall(abi.encodeCall(Collections.unzipValues, ("uint256", "uint256", a, lane)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Collections.InvalidLane.selector, lane));
    }

    /**
     * @dev flatten concatenates the groups in order and validates every
     *      element: over uint8 a dirty word must be refused, not passed on
     */
    function check_flattenValues(uint8 splitCase, uint8 countCase, bytes32[3] memory w) public view {
        bytes[] memory values = words(countCase, w);
        uint256 n = values.length;
        vm.assume(splitCase < 4);
        uint256 split = splitCase > n ? n : splitCase;
        bytes[][] memory groups = new bytes[][](2);
        groups[0] = new bytes[](split);
        groups[1] = new bytes[](n - split);
        for (uint256 i; i < n; i++) {
            if (i < split) groups[0][i] = values[i];
            else groups[1][i - split] = values[i];
        }
        (bool ok, bytes memory raw) =
            address(collections).staticcall(abi.encodeCall(Collections.flattenValues, ("uint8", groups)));
        bool dirty;
        for (uint256 i; i < n; i++) {
            if (uint256(w[i]) > 255) dirty = true;
        }
        if (dirty) {
            assertFalse(ok, "a dirty uint8 is flattened");
            assertEq(raw, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        } else {
            assertTrue(ok, "flatten reverted on canonical values");
            assertEq(abi.encode(abi.decode(raw, (bytes[]))), abi.encode(values));
        }
    }

    /** @dev indexOf is the first element the equality callback matches, or max */
    function check_indexOfValues(uint8 countCase, uint8[3] memory keys, uint8 needleKey) public view {
        bytes[] memory values = pairs(countCase, keys);
        uint256 expected = type(uint256).max;
        for (uint256 i; i < values.length && expected == type(uint256).max; i++) {
            if (keys[i] == needleKey) expected = i;
        }
        uint256 got = abi.decode(
            call(abi.encodeCall(
                Collections.indexOfValues,
                ("(uint256,uint256)", values, abi.encode(uint256(needleKey), uint256(99)), binary(Lambdas.sameKey.selector, "((uint256,uint256),(uint256,uint256))"))
            )),
            (uint256)
        );
        assertEq(got, expected);
    }

    // ============ Harness ============

    function call(bytes memory data) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = address(collections).staticcall(data);
        assertTrue(ok, "reverted on valid input");
    }

    function unary(bytes4 selector) internal view returns (Collections.Callback memory) {
        return Collections.Callback(address(lambdas), selector, "(uint256)", new bytes[](1), 0, 0, "");
    }

    function binary(bytes4 selector, string memory arguments) internal view returns (Collections.Callback memory) {
        return Collections.Callback(address(lambdas), selector, arguments, new bytes[](2), 0, 1, "");
    }

    function words(uint8 countCase, bytes32[3] memory w) internal pure returns (bytes[] memory values) {
        vm.assume(countCase < 4);
        values = new bytes[](countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : 3);
        for (uint256 i; i < values.length; i++) {
            values[i] = abi.encode(w[i]);
        }
    }

    /** @dev (key, tag) pairs, the tag being the input position */
    function pairs(uint8 countCase, uint8[3] memory keys) internal pure returns (bytes[] memory values) {
        vm.assume(countCase < 4);
        values = new bytes[](countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : 3);
        for (uint256 i; i < values.length; i++) {
            values[i] = abi.encode(uint256(keys[i]), i);
        }
    }

    function index(uint8 c) internal pure returns (int256) {
        if (c == 0) return 0;
        if (c == 1) return 1;
        if (c == 2) return 3;
        if (c == 3) return 5;
        if (c == 4) return -1;
        if (c == 5) return -3;
        return type(int256).min;
    }
}
