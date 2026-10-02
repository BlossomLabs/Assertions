// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import {Collections} from "../Collections.sol";
import {Operations} from "../Operations.sol";

/**
 * @dev A lambda or callback target that misbehaves in one fixed way:
 *      0 answers the word 1, 1 reverts with a reason, 2 returns nothing,
 *      3 returns two words, 4 answers 2 (not a predicate verdict), 5
 *      answers 0, 6 burns all its gas, 7 returns 100 KB
 */
contract HostileTarget {
    uint256 immutable mode;

    constructor(uint256 mode_) {
        mode = mode_;
    }

    fallback(bytes calldata) external returns (bytes memory) {
        if (mode == 1) revert("hostile");
        if (mode == 2) return "";
        if (mode == 3) return abi.encode(uint256(1), uint256(1));
        if (mode == 4) return abi.encode(uint256(2));
        if (mode == 5) return abi.encode(uint256(0));
        if (mode == 6) {
            while (true) {}
        }
        if (mode == 7) return new bytes(100_000);
        return abi.encode(uint256(1));
    }
}

/**
 * @notice Collections never panics and never runs out of gas on hostile
 *         input or hostile targets: every failure carries a declared
 *         selector. The documented exceptions: Panic(0x11) when sumWords
 *         overflows, and the ABI decoder's bare revert for a FoldExit
 *         outside 0..2.
 * @dev Fuzzed with a fixed gas budget per call, like OperationsNoPanic.
 *      The targets misbehave in every way a lambda or callback can (see
 *      HostileTarget), plus a code-less address. Fold counts are bounded
 *      so a well-behaved target's honest cost stays inside the budget: a
 *      budget judges the algorithm, not a requested amount of work.
 */
contract CollectionsNoPanicTest is Test {
    bytes4 constant PANIC = 0x4e487b71;
    uint256 constant CALL_GAS = 10_000_000;

    Collections collections;
    Operations ops;
    address[10] targets;

    function setUp() public {
        collections = new Collections();
        ops = new Operations();
        for (uint256 m; m < 8; m++) {
            targets[m] = address(new HostileTarget(m));
        }
        targets[8] = address(ops);
        targets[9] = address(0xdead);
    }

    // ============ Word payloads ============

    function testFuzzWordPayloadsNeverPanic(bytes calldata s, bytes calldata t, bytes32 w, uint256 lane, bool ordered)
        public
        view
    {
        call(abi.encodeCall(Collections.wordIndexOf, (s, w)), false);
        call(abi.encodeCall(Collections.reverseWords, (s)), false);
        call(abi.encodeCall(Collections.zipWords, (s, t)), false);
        call(abi.encodeCall(Collections.zipWords, (s, s)), false);
        call(abi.encodeCall(Collections.unzipWords, (s, lane)), false);
        call(abi.encodeCall(Collections.unzipWords, (s, lane % 2)), false);
        call(abi.encodeCall(Collections.sortWords, (s)), false);
        call(abi.encodeCall(Collections.sumWords, (s)), true);
        call(abi.encodeCall(Collections.uniqueWords, (s, ordered)), false);
    }

    /**
     * @dev iotaWords' cost is its output's, like Operations.concat: a budget
     *      judges the algorithm, not a requested amount of memory, so only
     *      honest sizes are swept (its NatSpec documents the rest)
     */
    function testIotaNeverPanics() public view {
        uint256[4] memory ns = [uint256(0), 1, 1000, 10_000];
        for (uint256 i; i < ns.length; i++) {
            call(abi.encodeCall(Collections.iotaWords, (ns[i])), false);
        }
    }

    // ============ Lambdas ============

    /**
     * @dev The fold inputs as one struct: calldata arguments cost two stack slots each
     */
    struct FoldInput {
        bytes s;
        uint8 targetCase;
        bytes template;
        uint256 accOffset;
        uint256[] elemOffsets;
        bytes32 init;
        uint16 n;
        uint8 exit;
    }

    function testFuzzFoldsNeverPanic(FoldInput calldata f) public view {
        address target = targets[f.targetCase % targets.length];
        (uint256 acc, uint256[] memory offsets) =
            windows(f.template, f.accOffset, f.elemOffsets, f.targetCase & 0x80 != 0);
        folds(f, target, acc, offsets);
        call(abi.encodeCall(Collections.mapWords, (f.s, target, f.template, offsets)), false);
        call(abi.encodeCall(Collections.filterWords, (f.s, target, f.template, offsets)), false);
    }

    /**
     * @dev Half the time, windows that fit the template, so the calls happen.
     *      At most 16 windows per element: a budget judges the algorithm,
     *      not the requested work, and 284 elements stamped into 253
     *      windows each (71,652 bounds-checked writes at about 140 gas)
     *      exhausted the 10M budget honestly on 2026-09-29.
     */
    function windows(bytes calldata template, uint256 accOffset, uint256[] calldata elemOffsets, bool fit)
        internal
        pure
        returns (uint256, uint256[] memory offsets)
    {
        offsets = elemOffsets;
        if (offsets.length > 16) {
            assembly ("memory-safe") {
                mstore(offsets, 16)
            }
        }
        if (!fit || template.length < 32) return (accOffset, offsets);
        for (uint256 i; i < offsets.length; i++) {
            offsets[i] %= template.length - 31;
        }
        return (accOffset % (template.length - 31), offsets);
    }

    /**
     * @dev The three folds with a raw uint8 FoldExit, each encoded whole: a
     *      head spliced onto a separately encoded tail shifts every offset
     */
    function folds(FoldInput calldata f, address target, uint256 acc, uint256[] memory offsets) internal view {
        bool badExit = f.exit > 2;
        uint256 count = f.n % 300;
        call(
            abi.encodeWithSelector(
                Collections.foldRange.selector, count, target, f.template, acc, offsets, f.init, f.exit
            ),
            false,
            badExit
        );
        call(
            abi.encodeWithSelector(
                Collections.foldBytes.selector, f.s, target, f.template, acc, offsets, f.init, f.exit
            ),
            false,
            badExit
        );
        call(
            abi.encodeWithSelector(
                Collections.foldWords.selector, f.s, target, f.template, acc, offsets, f.init, f.exit
            ),
            false,
            badExit
        );
    }

    /**
     * @dev Every target through a fold and a predicate traversal with valid
     *      windows and callback, so each misbehaviour reaches the call:
     *      each fails with its declared error or succeeds
     */
    function testHostileTargetsFailDeclared() public {
        uint256[] memory elem = new uint256[](1);
        elem[0] = 32;
        bytes memory template = abi.encodeWithSignature("add(uint256,uint256)", 0, 0);
        bytes[] memory values = new bytes[](3);
        for (uint256 i; i < values.length; i++) {
            values[i] = abi.encode(i);
        }
        for (uint256 t; t < targets.length; t++) {
            bytes memory fold = abi.encodeWithSelector(
                Collections.foldRange.selector, 3, targets[t], template, 4, elem, bytes32(0), uint8(0)
            );
            emit log_named_bytes(string.concat("fold via target ", vm.toString(t)), outcome(fold));
            call(fold, false);
            Collections.Callback memory cb = callback(uint8(t), 0, 0, 0, "");
            bytes memory filter = abi.encodeCall(Collections.filterValues, ("uint256", values, cb));
            emit log_named_bytes(string.concat("filter via target ", vm.toString(t)), outcome(filter));
            call(filter, false);
        }
    }

    function outcome(bytes memory data) internal view returns (bytes memory) {
        (bool ok, bytes memory out) = address(collections).staticcall{gas: CALL_GAS}(data);
        return ok ? bytes("ok") : out.length >= 4 ? abi.encodePacked(bytes4(out)) : out;
    }

    // ============ Values ============

    struct ValuesInput {
        uint8 typeCase;
        uint256[] seeds;
        bytes[] junk;
        uint8 targetCase;
        uint8 argsCase;
        uint256 first;
        uint256 second;
        bytes expression;
        int256 start;
        int256 end;
        uint256 lane;
    }

    function testFuzzValuesNeverPanic(ValuesInput calldata v) public view {
        uint8 t = v.typeCase % 3;
        string memory inputType = t == 0 ? "uint256" : t == 1 ? "uint8" : "string";
        // Mostly valid uint256 values so callbacks run; sometimes raw junk.
        bytes[] memory values = new bytes[](v.seeds.length % 20);
        for (uint256 i; i < values.length; i++) {
            values[i] = abi.encode(v.seeds[i]);
        }
        if (v.typeCase & 0x80 != 0) values = v.junk;
        Collections.Callback memory cb = callback(v.targetCase, v.argsCase, v.first, v.second, v.expression);
        callbackTraversals(inputType, values, cb, v.typeCase & 1 == 0, abi.encode(v.seeds.length));
        call(abi.encodeCall(Collections.reverseValues, (inputType, values)), false);
        call(abi.encodeCall(Collections.sliceValues, (inputType, values, v.start, v.end)), false);
        call(abi.encodeCall(Collections.zipValues, (inputType, "uint256", values, values)), false);
        call(abi.encodeCall(Collections.unzipValues, (inputType, "uint256", values, v.lane)), false);
        call(abi.encodeCall(Collections.packArray, (inputType, values)), false);
        bytes[][] memory nested = new bytes[][](2);
        nested[0] = values;
        nested[1] = v.junk;
        call(abi.encodeCall(Collections.flattenValues, (inputType, nested)), false);
    }

    /**
     * @dev Every traversal that applies a callback
     */
    function callbackTraversals(
        string memory inputType,
        bytes[] memory values,
        Collections.Callback memory cb,
        bool ordered,
        bytes memory needle
    ) internal view {
        call(abi.encodeCall(Collections.mapValues, (inputType, "uint256", values, cb)), false);
        call(abi.encodeCall(Collections.filterValues, (inputType, values, cb)), false);
        call(abi.encodeCall(Collections.foldValues, (inputType, "uint256", values, abi.encode(uint256(0)), cb)), false);
        call(abi.encodeCall(Collections.sortValues, (inputType, values, cb)), false);
        call(abi.encodeCall(Collections.uniqueValues, (inputType, values, cb, ordered)), false);
        call(abi.encodeCall(Collections.indexOfValues, (inputType, values, needle, cb)), false);
        call(abi.encodeCall(Collections.anyValues, (inputType, values, cb)), false);
        call(abi.encodeCall(Collections.allValues, (inputType, values, cb)), false);
        call(abi.encodeCall(Collections.findValues, (inputType, values, cb)), false);
    }

    // ============ Helpers ============

    /**
     * @dev A callback that is well-formed about half the time (a binary or
     *      unary uint256 tuple with in-range slots) and otherwise carries a
     *      malformed descriptor, slot or expression
     */
    function callback(uint8 targetCase, uint8 argsCase, uint256 first, uint256 second, bytes memory expression)
        internal
        view
        returns (Collections.Callback memory cb)
    {
        cb.target = targets[targetCase % targets.length];
        cb.selector = bytes4(keccak256("add(uint256,uint256)"));
        uint8 shape = argsCase % 6;
        cb.arguments = shape == 0
            ? "(uint256,uint256)"
            : shape == 1
                ? "(uint256)"
                : shape == 2 ? "uint256" : shape == 3 ? "(uint256" : shape == 4 ? "(uint256[0],uint256)" : "()";
        cb.constants = new bytes[](shape == 1 ? 1 : 2);
        for (uint256 i; i < cb.constants.length; i++) {
            cb.constants[i] = abi.encode(uint256(0));
        }
        bool wellFormed = argsCase & 0x80 == 0;
        cb.first = wellFormed ? 0 : first;
        cb.second = wellFormed ? 1 : second;
        if (argsCase & 0x40 != 0) cb.expression = expression;
    }

    function call(bytes memory data, bool overflowPanics) internal view {
        call(data, overflowPanics, false);
    }

    /**
     * @dev A failure must carry a selector, except the ABI decoder's bare
     *      revert for an out-of-range FoldExit; a Panic only with code 0x11
     *      where the function sums words
     */
    function call(bytes memory data, bool overflowPanics, bool badExit) internal view {
        (bool ok, bytes memory out) = address(collections).staticcall{gas: CALL_GAS}(data);
        if (ok) return;
        if (badExit) {
            assertEq(out.length, 0, "an out-of-range FoldExit passed the ABI decoder");
            return;
        }
        assertGe(out.length, 4, "no selector (out of gas?)");
        if (bytes4(out) != PANIC) return;
        uint256 code = abi.decode(slice(out, 4), (uint256));
        assertTrue(code == 0x11 && overflowPanics, string.concat("undocumented panic ", vm.toString(code)));
    }

    function slice(bytes memory b, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(b.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = b[from + i];
        }
    }
}
