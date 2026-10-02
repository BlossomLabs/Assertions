// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "../Operations.sol";
import "../lib/ERC8211.sol";

/// @dev Concrete evidence for the ledger's previously untested boundary claims.
contract ClaimGapComparator {
    function compare(uint256 a, uint256 b) external pure returns (int256) {
        return a < b ? int256(-1) : a > b ? int256(1) : int256(0);
    }
}

contract ClaimEvidenceGapsTest is Test {
    Assertions core;
    Collections collections;
    Expressions expressions;
    Operations operations;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        expressions = new Expressions();
        operations = new Operations();
    }

    function test_A29_ShapeCompatibleWrongDescriptorReinterpretsWord() public view {
        InputParam memory value = InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(int256(-1)), new Constraint[](0)
        );
        int256[] memory path = new int256[](1);
        (bool ok, bytes memory result) =
            address(core).staticcall(abi.encodeCall(Assertions.nav, (value, "(uint256)", path)));
        assertTrue(ok);
        assertEq(abi.decode(result, (uint256)), type(uint256).max);
        assertEq(abi.decode(result, (int256)), -1);
        (ok, result) = address(core).staticcall(abi.encodeCall(Assertions.nav, (value, "(int256)", path)));
        assertTrue(ok);
        assertEq(abi.decode(result, (int256)), -1);
    }

    function test_O17_ModexpAcceptsExactlyOneWordAndFallsBackOtherwise() public {
        uint256 exponent = uint256(1) << 32;
        bytes memory request = abi.encode(uint256(32), uint256(32), uint256(32), uint256(3), exponent, uint256(11));
        // 3 has period five modulo eleven; 2^32 mod 5 is one.
        uint256 expected = 3;
        vm.mockCall(address(5), request, abi.encode(uint256(123)));
        _assertAllPowModOverloads(exponent, 123);
        vm.clearMockedCalls();
        vm.mockCallRevert(address(5), request, hex"deadbeef");
        _assertAllPowModOverloads(exponent, expected);
        vm.clearMockedCalls();
        vm.mockCall(address(5), request, "");
        _assertAllPowModOverloads(exponent, expected);
        vm.clearMockedCalls();
        vm.mockCall(address(5), request, hex"ff");
        _assertAllPowModOverloads(exponent, expected);
        vm.clearMockedCalls();
        vm.mockCall(address(5), request, new bytes(31));
        _assertAllPowModOverloads(exponent, expected);
        vm.clearMockedCalls();
        vm.mockCall(address(5), request, abi.encode(uint256(123), uint256(456)));
        _assertAllPowModOverloads(exponent, expected);
    }

    function _assertAllPowModOverloads(uint256 exponent, uint256 expected) private view {
        assertEq(operations.powMod(uint256(3), exponent, 11), expected);
        assertEq(operations.powMod(uint256(3), int256(exponent), 11), expected);
        assertEq(operations.powMod(int256(3), exponent, int256(11)), int256(expected));
        assertEq(operations.powMod(int256(3), int256(exponent), int256(11)), int256(expected));
    }

    function test_L16_IotaAllocationOverflowAndGasExhaustion() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", uint256(0x11)));
        collections.iotaWords(type(uint256).max / 32 + 1);
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", uint256(0x41)));
        collections.iotaWords(uint256(1) << 59);
        (bool ok, bytes memory reason) =
            address(collections).staticcall{gas: 50_000}(abi.encodeCall(Collections.iotaWords, (uint256(100_000))));
        assertFalse(ok);
        assertEq(reason.length, 0, "memory expansion exceeds the bounded call budget");
        assertEq(collections.iotaWords(3), abi.encode(uint256(0), uint256(1), uint256(2)));
    }

    /// @dev Selected sorted powers of two require n/2 * log2(n) comparisons.
    /// This checks finite comparison counts, not a general asymptotic or memory proof.
    function test_L23_MergeSortComparisonCountsOnPowersOfTwo() public {
        Collections.Callback memory callback;
        callback.selector = ClaimGapComparator.compare.selector;
        callback.arguments = "(uint256,uint256)";
        callback.constants = new bytes[](2);
        callback.second = 1;
        for (uint256 level = 1; level <= 6; level++) {
            callback.target = address(new ClaimGapComparator());
            uint256 n = uint256(1) << level;
            bytes[] memory values = new bytes[](n);
            for (uint256 i; i < n; i++) {
                values[i] = abi.encode(i);
            }
            vm.expectCall(callback.target, abi.encodePacked(callback.selector), uint64(n / 2 * level));
            bytes[] memory sorted = collections.sortValues("uint256", values, callback);
            assertEq(sorted.length, n);
            for (uint256 i; i < n; i++) {
                assertEq(sorted[i], values[i]);
            }
        }
    }

    function source() external pure returns (uint256) {
        return 17;
    }

    function _sharedGraph() private view returns (Expressions.Expression memory p) {
        p.core = address(core);
        p.nodes = new Expressions.Node[](2);
        InputParam memory value = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(this), abi.encodeCall(this.source, ())),
            new Constraint[](0)
        );
        p.nodes[0] =
            Expressions.Node(Expressions.Kind.Resolve, "uint256", abi.encode(value), new uint256[](0), bytes4(0), "");
        uint256[] memory refs = new uint256[](2);
        p.nodes[1] =
            Expressions.Node(Expressions.Kind.Tuple, "(uint256,uint256)", "", refs, bytes4(0), "(uint256,uint256)");
        p.result = 1;
    }

    function test_E41_EvaluateAndEncodedCallsStartFreshCaches() public {
        Expressions.Expression memory p = _sharedGraph();
        vm.expectCall(address(this), abi.encodeCall(this.source, ()), uint64(4));
        for (uint256 i; i < 2; i++) {
            (bool ok, bytes memory result) =
                address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (p, new bytes[](0))));
            assertTrue(ok);
            assertEq(result, abi.encode(uint256(17), uint256(17)));
            (ok, result) = address(expressions)
                .staticcall(abi.encodeCall(Expressions.evaluateEncoded, (abi.encode(p), new bytes[](0))));
            assertTrue(ok);
            assertEq(result, abi.encode(uint256(17), uint256(17)));
        }
    }

    function test_L60_CollectionCallbacksDoNotShareEvaluationCaches() public {
        Collections.Callback memory callback;
        callback.target = address(expressions);
        callback.arguments = "(uint256)";
        callback.constants = new bytes[](1);
        callback.expression = abi.encode(_sharedGraph());
        bytes[] memory values = new bytes[](3);
        for (uint256 i; i < values.length; i++) {
            values[i] = abi.encode(i);
        }
        vm.expectCall(address(this), abi.encodeCall(this.source, ()), uint64(3));
        bytes[] memory result = collections.mapValues("uint256", "(uint256,uint256)", values, callback);
        assertEq(result.length, values.length);
        for (uint256 i; i < result.length; i++) {
            assertEq(result[i], abi.encode(uint256(17), uint256(17)));
        }
    }
}
