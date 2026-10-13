// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Expressions.sol";
import "../Collections.sol";
import {ClaimCacheObserver} from "./ClaimCacheSymbolic.t.sol";

/**
 * @notice E41/L60 through filters, folds, reductions and early predicate scans.
 *         A four-node Select reads the same external leaf as condition and
 *         selected value. It executes once in each callback, with a fresh cache.
 */
contract ClaimCacheRoutesSymbolicTest is Test {
    Expressions expressions;
    Collections collections;
    ClaimCacheObserver observer;
    bytes32 constant MARK = 0xfedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210;
    bytes32 constant OTHER = 0xabcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789;

    function setUp() public {
        expressions = new Expressions();
        collections = new Collections();
        observer = new ClaimCacheObserver();
    }

    function check_routesFilterCaches(bool a, bool b, bool wordRoute) public {
        vm.warp(1000);
        bytes memory data;
        bytes memory expected;
        if (wordRoute) {
            (bytes memory template, uint256 offset,) = wordTemplate("bool", false);
            uint256[] memory offsets = new uint256[](1);
            offsets[0] = offset;
            data = abi.encodeCall(Collections.filterWords, (abi.encode(a, b), address(expressions), template, offsets));
            bytes memory kept;
            if (a) kept = bytes.concat(kept, abi.encode(a));
            if (b) kept = bytes.concat(kept, abi.encode(b));
            expected = abi.encode(kept);
        } else {
            bytes[] memory values = boolValues(a, b);
            data = abi.encodeCall(Collections.filterValues, ("bool", values, callback("bool", false)));
            bytes[] memory kept = new bytes[]((a ? 1 : 0) + (b ? 1 : 0));
            if (a) kept[0] = abi.encode(a);
            if (b) kept[a ? 1 : 0] = abi.encode(b);
            expected = abi.encode(kept);
        }
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertTrue(ok);
        assertEq(out, expected);
        assertEq(observer.count(), 2, "filter callbacks share internally but evaluate independently");
    }

    function check_routesFoldCaches(bytes32 a, bytes32 b, bytes32 initial, uint8 size, bool wordRoute) public {
        vm.assume(size < 4);
        uint256 n = size == 0 ? 0 : size == 1 ? 1 : size == 2 ? 2 : 3;
        vm.warp(1000);
        bytes[] memory values = new bytes[](n);
        bytes memory packed;
        for (uint256 i; i < n; i++) {
            bytes memory v = abi.encode(i == 1 ? b : a);
            values[i] = v;
            packed = bytes.concat(packed, v);
        }
        bytes memory data;
        if (wordRoute) {
            (bytes memory template, uint256 elementOffset, uint256 accOffset) = wordTemplate("bytes32", true);
            uint256[] memory offsets = new uint256[](1);
            offsets[0] = elementOffset;
            data = abi.encodeCall(
                Collections.foldWords,
                (packed, address(expressions), template, accOffset, offsets, initial, Collections.FoldExit.Full)
            );
        } else {
            data = abi.encodeCall(
                Collections.foldValues, ("bytes32", "bytes32", values, abi.encode(initial), callback("bytes32", true))
            );
        }
        bytes32 expected = n == 0 ? initial : n == 2 ? b : a;
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertTrue(ok);
        assertEq(out, wordRoute ? abi.encode(expected) : abi.encode(abi.encode(expected)));
        assertEq(observer.count(), n, "every fold callback starts cold");
    }

    function check_routesReductionCaches(bool a, bool b, uint8 modeCase) public {
        vm.assume(modeCase < 4);
        Collections.Reduce mode = modeCase == 0
            ? Collections.Reduce.All
            : modeCase == 1 ? Collections.Reduce.Any : modeCase == 2 ? Collections.Reduce.Count : Collections.Reduce.Sum;
        vm.warp(1000);
        (bytes memory template, uint256 offset,) = wordTemplate("bool", false);
        uint256[] memory offsets = new uint256[](1);
        offsets[0] = offset;
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.reduceWords,
                    (
                        abi.encode(a, b),
                        address(expressions),
                        template,
                        offsets,
                        mode,
                        Collections.Cmp.EQ,
                        bytes32(uint256(1))
                    )
                )
            );
        assertTrue(ok);
        uint256 expected =
            modeCase == 0 ? (a && b ? 1 : 0) : modeCase == 1 ? (a || b ? 1 : 0) : (a ? 1 : 0) + (b ? 1 : 0);
        assertEq(out, abi.encode(expected));
        uint256 calls = modeCase == 0 ? (a ? 2 : 1) : modeCase == 1 ? (a ? 1 : 2) : 2;
        assertEq(observer.count(), calls, "visited reduction callbacks have independent caches");
    }

    function check_routesPredicateScanCaches(bool a, bool b, uint8 route) public {
        vm.assume(route < 3);
        vm.warp(1000);
        bytes[] memory values = boolValues(a, b);
        Collections.Callback memory cb = callback("bool", false);
        bytes memory data = route == 0
            ? abi.encodeCall(Collections.anyValues, ("bool", values, cb))
            : route == 1
                ? abi.encodeCall(Collections.allValues, ("bool", values, cb))
                : abi.encodeCall(Collections.findValues, ("bool", values, cb));
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertTrue(ok);
        bytes memory expected = route == 0
            ? abi.encode(a || b)
            : route == 1 ? abi.encode(a && b) : abi.encode(a ? uint256(0) : b ? uint256(1) : type(uint256).max);
        assertEq(out, expected);
        assertEq(observer.count(), route == 1 ? (a ? uint256(2) : uint256(1)) : (a ? uint256(1) : uint256(2)));
    }

    function graph(string memory t, bool binary) internal view returns (Expressions.Expression memory e) {
        e.nodes = new Expressions.Node[](4);
        e.result = 3;
        e.nodes[0].kind = Expressions.Kind.Literal;
        e.nodes[0].valueType = "address";
        e.nodes[0].data = abi.encode(address(observer));
        e.nodes[1].kind = Expressions.Kind.Parameter;
        e.nodes[1].valueType = t;
        e.nodes[1].data = abi.encode(binary ? uint256(1) : uint256(0));
        e.nodes[2].kind = Expressions.Kind.Call;
        e.nodes[2].valueType = t;
        e.nodes[2].selector = ClaimCacheObserver.word.selector;
        e.nodes[2].arguments = "(bytes32)";
        e.nodes[2].refs = new uint256[](2);
        e.nodes[2].refs[1] = 1;
        e.nodes[3].kind = Expressions.Kind.Select;
        e.nodes[3].valueType = t;
        e.nodes[3].refs = new uint256[](3);
        e.nodes[3].refs[0] = 2;
        e.nodes[3].refs[1] = 2;
        e.nodes[3].refs[2] = 2;
    }

    function callback(string memory t, bool binary) internal view returns (Collections.Callback memory cb) {
        cb.target = address(expressions);
        cb.arguments = binary ? "(bytes32,bytes32)" : "(bool)";
        cb.constants = new bytes[](binary ? 2 : 1);
        cb.constants[0] = abi.encode(bytes32(0));
        if (binary) cb.constants[1] = abi.encode(bytes32(0));
        cb.second = binary ? 1 : 0;
        cb.expression = abi.encode(graph(t, binary));
    }

    function wordTemplate(string memory t, bool binary)
        internal
        view
        returns (bytes memory template, uint256 elementOffset, uint256 accOffset)
    {
        bytes[] memory parameters = new bytes[](binary ? 2 : 1);
        parameters[0] = abi.encode(binary ? OTHER : MARK);
        if (binary) parameters[1] = abi.encode(MARK);
        bytes memory expression = abi.encode(graph(t, binary));
        bytes memory fixture = abi.encodeCall(Expressions.evaluateEncoded, (expression, parameters));
        elementOffset = findWord(fixture, MARK);
        if (binary) accOffset = findWord(fixture, OTHER);
        parameters[0] = abi.encode(bytes32(0));
        if (binary) parameters[1] = abi.encode(bytes32(0));
        template = abi.encodeCall(Expressions.evaluateEncoded, (expression, parameters));
    }

    function boolValues(bool a, bool b) internal pure returns (bytes[] memory values) {
        values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
    }

    function findWord(bytes memory data, bytes32 sentinel) internal pure returns (uint256 found) {
        uint256 matches;
        for (uint256 i = 4; i + 32 <= data.length; i += 32) {
            bytes32 word;
            assembly ("memory-safe") { word := mload(add(add(data, 32), i)) }
            if (word == sentinel) {
                found = i;
                matches++;
            }
        }
        assertEq(matches, 1, "exactly one encoded parameter marker");
    }

    function test_routesFilterSamples() public {
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(uint256(1)))), uint64(2));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(0))), uint64(2));
        check_routesFilterCaches(true, false, false);
        check_routesFilterCaches(true, false, true);
    }

    function test_routesFoldSamples() public {
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(uint256(42)))), uint64(4));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(uint256(93)))), uint64(2));
        check_routesFoldCaches(bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(7)), 3, false);
        check_routesFoldCaches(bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(7)), 3, true);
        check_routesFoldCaches(bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(7)), 0, false);
    }

    function test_routesReductionSamples() public {
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(0))), uint64(4));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(uint256(1)))), uint64(3));
        for (uint8 i; i < 4; i++) {
            check_routesReductionCaches(false, true, i);
        }
    }

    function test_routesPredicateScanSamples() public {
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(0))), uint64(3));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(uint256(1)))), uint64(2));
        for (uint8 i; i < 3; i++) {
            check_routesPredicateScanCaches(false, true, i);
        }
    }
}
