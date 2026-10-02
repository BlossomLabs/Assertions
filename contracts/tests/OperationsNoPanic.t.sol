// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import {Operations} from "../Operations.sol";

/**
 * @notice Bounded fuzz checks for selector-bearing failures in byte, string,
 *         search and number-text operations, with selected overflow and ABI
 *         decoder exceptions.
 * @dev Fuzzed rather than proved: these scan every byte, and a branch per
 *      symbolic byte explodes Halmos paths. Each call gets a fixed gas
 *      budget, so running out of it shows up as empty revert data. The
 *      index arithmetic (slice, byteAt, sliceRange and friends) is proved
 *      in OperationsNoPanicSymbolic. The search sweep caps inputs and
 *      replacement expansion and requires
 *      success or the exact EmptyNeedle error. A separate large-output regression pins an empty resource
 *      revert; the contract does not promise resource-independent success
 *      or errors.
 */
contract OperationsNoPanicTest is Test {
    bytes4 constant PANIC = 0x4e487b71;
    uint256 constant CALL_GAS = 10_000_000;

    Operations ops;

    function setUp() public {
        ops = new Operations();
    }

    // ============ Fuzz ============

    function testFuzzSlicesNeverPanic(bytes calldata data, uint256 start, uint256 len, int256 a, int256 b) public view {
        call(abi.encodeCall(Operations.slice, (data, start, len)), false);
        call(abi.encodeCall(Operations.sliceRange, (data, a, b)), false);
        call(abi.encodeCall(Operations.byteAt, (data, a)), false);
        call(abi.encodeCall(Operations.stringSlice, (data, a, b)), false);
        call(abi.encodeCall(Operations.stringAt, (data, a)), false);
        call(abi.encodeCall(Operations.byteLen, (data)), false);
        call(abi.encodeCall(Operations.hash, (data)), false);
    }

    function testFuzzBoundedSearchResults(
        bytes calldata s,
        bytes calldata needle,
        bytes calldata repl,
        int256 occurrence
    ) public view {
        // Cap the input geometry, including worst-case replacement expansion:
        // 256 one-byte matches with a 64-byte replacement emit at most 16 KiB.
        bytes memory haystack = s[:s.length > 256 ? 256 : s.length];
        bytes memory fullNeedle = needle[:needle.length > 64 ? 64 : needle.length];
        bytes memory replacement = repl[:repl.length > 64 ? 64 : repl.length];
        bytes memory shortNeedle = needle[:needle.length > 2 ? 2 : needle.length];
        for (uint256 i; i < 2; i++) {
            bytes memory n = i == 0 ? fullNeedle : shortNeedle;
            assertSuccess(abi.encodeCall(Operations.contains, (haystack, n)));
            assertSuccess(abi.encodeCall(Operations.indexOf, (haystack, n, occurrence)));
            if (n.length == 0) {
                assertEmptyNeedle(abi.encodeCall(Operations.split, (haystack, n)));
                assertEmptyNeedle(abi.encodeCall(Operations.replace, (haystack, n, replacement)));
            } else {
                assertSuccess(abi.encodeCall(Operations.split, (haystack, n)));
                assertSuccess(abi.encodeCall(Operations.replace, (haystack, n, replacement)));
            }
        }
    }

    function testBoundedSearchMaximumExpansionSucceeds() public view {
        bytes memory haystack = new bytes(256);
        bytes memory needle = new bytes(1);
        bytes memory replacement = new bytes(64);
        (bool ok, bytes memory out) =
            address(ops).staticcall{gas: CALL_GAS}(abi.encodeCall(Operations.replace, (haystack, needle, replacement)));
        assertTrue(ok);
        assertEq(abi.decode(out, (bytes)), new bytes(16_384));
        (ok, out) = address(ops).staticcall{gas: CALL_GAS}(abi.encodeCall(Operations.split, (haystack, needle)));
        assertTrue(ok);
        bytes[] memory parts = abi.decode(out, (bytes[]));
        assertEq(parts.length, 257);
        for (uint256 i; i < parts.length; i++) {
            assertEq(parts[i].length, 0);
        }
    }

    /**
     * @dev A valid replacement can require more gas than the fixed call budget.
     *      The same matching geometry with a small replacement must succeed.
     */
    function testReplacementExpansionExhaustsBudget() public view {
        bytes memory haystack = new bytes(900);
        bytes memory replacement = new bytes(9280);
        bytes memory needle = new bytes(1);
        (bool ok, bytes memory out) =
            address(ops).staticcall{gas: CALL_GAS}(abi.encodeCall(Operations.replace, (haystack, needle, replacement)));
        assertFalse(ok);
        assertEq(out, hex"", "resource exhaustion must return no data");
        assertEq(ops.replace(haystack, needle, bytes("x")), repeatedX(900));
    }

    function repeatedX(uint256 count) internal pure returns (bytes memory out) {
        out = new bytes(count);
        for (uint256 i; i < count; i++) {
            out[i] = 0x78;
        }
    }

    function assertEmptyNeedle(bytes memory data) internal view {
        (bool ok, bytes memory out) = address(ops).staticcall{gas: CALL_GAS}(data);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSignature("EmptyNeedle()"));
    }

    function assertSuccess(bytes memory data) internal view {
        (bool ok,) = address(ops).staticcall{gas: CALL_GAS}(data);
        assertTrue(ok, "bounded search must succeed");
    }

    function testFuzzTextNeverPanics(bytes calldata s, uint256 mask, bytes[] calldata parts) public view {
        call(abi.encodeCall(Operations.toLower, (s)), false);
        call(abi.encodeCall(Operations.toUpper, (s)), false);
        call(abi.encodeCall(Operations.charset, (s, mask)), false);
        // concat's cost is its output's: 254 parts around a 6.5 KB delimiter ask
        // for 1.66 MB, which no budget covers. Judge it where the output is sane.
        uint256 output = parts.length == 0 ? 0 : (parts.length - 1) * s.length;
        for (uint256 i; i < parts.length; i++) {
            output += parts[i].length;
        }
        if (output <= 100_000) call(abi.encodeCall(Operations.concat, (parts, s)), false);
    }

    function testFuzzNumbersNeverPanic(bytes calldata s, uint256 u, int256 i, uint256 decimals, uint8 rounding)
        public
        view
    {
        call(abi.encodeCall(Operations.parseUint, (s)), true);
        call(abi.encodeCall(Operations.parseInt, (s)), true);
        parseUnits(s, decimals, rounding);
        parseUnits(s, decimals % 80, rounding);
        call(abi.encodeWithSignature("toString(uint256)", u), false);
        call(abi.encodeWithSignature("toString(int256)", i), false);
        call(abi.encodeWithSignature("formatUnits(uint256,uint256)", u, decimals), false);
        call(abi.encodeWithSignature("formatUnits(int256,uint256)", i, decimals % 80), false);
    }

    // ============ Edges ============

    /**
     * @dev Number text at the edges of each type: digit runs past 2^256,
     *      signs alone, int256.min and one past it, and decimals around 77
     */
    function testNumberEdgesNeverPanic() public view {
        string[14] memory texts = [
            "",
            "-",
            "+",
            "0",
            "-0",
            ".",
            "1.",
            ".5",
            "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            "115792089237316195423570985008687907853269984665640564039457584007913129639936",
            "-57896044618658097711785492504343953926634992332820282019728792003956564819968",
            "-57896044618658097711785492504343953926634992332820282019728792003956564819969",
            "999999999999999999999999999999999999999999999999999999999999999999999999999999999999",
            "0.00000000000000000000000000000000000000000000000000000000000000000000000000000001"
        ];
        uint256[5] memory decimals = [uint256(0), 18, 77, 78, type(uint256).max];
        for (uint256 t; t < texts.length; t++) {
            bytes memory s = bytes(texts[t]);
            call(abi.encodeCall(Operations.parseUint, (s)), true);
            call(abi.encodeCall(Operations.parseInt, (s)), true);
            for (uint256 d; d < decimals.length; d++) {
                for (uint8 r; r < 4; r++) {
                    parseUnits(s, decimals[d], r);
                }
            }
        }
        int256[3] memory signed = [type(int256).min, type(int256).max, -1];
        for (uint256 v; v < signed.length; v++) {
            call(abi.encodeWithSignature("toString(int256)", signed[v]), false);
            for (uint256 d; d < decimals.length; d++) {
                call(abi.encodeWithSignature("formatUnits(int256,uint256)", signed[v], decimals[d]), false);
                call(abi.encodeWithSignature("formatUnits(uint256,uint256)", uint256(signed[v]), decimals[d]), false);
            }
        }
    }

    /**
     * @dev Index extremes against empty, one-byte and multi-byte UTF-8 data
     */
    function testIndexEdgesNeverPanic() public view {
        bytes[5] memory data = [bytes(""), bytes("a"), hex"c3a9", hex"f09f9880", hex"80ff"];
        int256[7] memory indices = [int256(0), 1, -1, 2, -3, type(int256).max, type(int256).min];
        for (uint256 d; d < data.length; d++) {
            for (uint256 x; x < indices.length; x++) {
                call(abi.encodeCall(Operations.byteAt, (data[d], indices[x])), false);
                call(abi.encodeCall(Operations.stringAt, (data[d], indices[x])), false);
                for (uint256 y; y < indices.length; y++) {
                    call(abi.encodeCall(Operations.sliceRange, (data[d], indices[x], indices[y])), false);
                    call(abi.encodeCall(Operations.stringSlice, (data[d], indices[x], indices[y])), false);
                    call(abi.encodeCall(Operations.indexOf, (data[d], bytes("a"), indices[y])), false);
                    call(abi.encodeCall(Operations.indexOf, (data[d], bytes(""), indices[y])), false);
                    call(abi.encodeCall(Operations.slice, (data[d], uint256(indices[x]), uint256(indices[y]))), false);
                }
            }
        }
    }

    // ============ Helpers ============

    /**
     * @dev parseUnits with a raw uint8 rounding, so an out-of-range mode reaches the contract
     */
    function parseUnits(bytes memory s, uint256 decimals, uint8 rounding) internal view {
        bytes memory args = abi.encode(s, decimals, rounding);
        call(bytes.concat(Operations.parseUnits.selector, args), true, rounding > 2);
        call(bytes.concat(Operations.parseUnitsUnsigned.selector, args), true, rounding > 2);
    }

    function call(bytes memory data, bool overflowPanics) internal view {
        call(data, overflowPanics, false);
    }

    /**
     * @dev A failure must carry a selector, except the ABI decoder's bare
     *      revert for an out-of-range rounding; a Panic only with code 0x11
     *      where the function parses a number
     */
    function call(bytes memory data, bool overflowPanics, bool badRounding) internal view {
        (bool ok, bytes memory out) = address(ops).staticcall{gas: CALL_GAS}(data);
        if (ok) return;
        if (badRounding) {
            assertEq(out.length, 0, "an out-of-range rounding passed the ABI decoder");
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
