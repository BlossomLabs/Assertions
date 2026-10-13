// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Expressions.sol";
import "../Collections.sol";

/**
 * @dev Test-only call observer. warp is a ghost event counter: unlike storage,
 *      the test environment's timestamp survives a reverted subcall. Neither
 *      Expressions nor AbiCodec reads timestamps. No gas conclusion follows.
 *      Concrete tests also pin counts with Foundry's independent expectCall.
 */
contract ClaimCacheObserver {
    Vm constant VM = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function word(bytes32 value) external returns (bytes32) {
        VM.warp(block.timestamp + 1);
        return value;
    }

    function blob(bytes32 value) external returns (bytes memory) {
        VM.warp(block.timestamp + 1);
        return abi.encodePacked(value, bytes1(0x7f));
    }

    function count() external view returns (uint256) {
        return block.timestamp - 1000;
    }
}

/**
 * @notice Bounded cache obligations over the actual Expressions bytecode.
 *         The ghost observer records executions, including reverted attempts;
 *         it does not model a stateful production callback or concrete gas.
 */
contract ClaimCacheSymbolicTest is Test {
    Expressions expressions;
    Collections collections;
    ClaimCacheObserver observer;

    function setUp() public {
        expressions = new Expressions();
        collections = new Collections();
        observer = new ClaimCacheObserver();
    }

    function check_cacheSharedNodeReuse(bytes32 value, bool dynamic) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(value, dynamic, 4);
        string memory t = dynamic ? "(bytes,bytes)" : "(bytes32,bytes32)";
        e.nodes[3] = composite(Expressions.Kind.Tuple, t, refs2(2, 2));
        bytes memory out = succeeds(e);
        assertEq(out, pair(value, dynamic));
        assertEq(observer.count(), 1, "shared leaf executes once");
    }

    function check_cacheSuccessfulGuardAdopts(bytes32 value, bool dynamic, bool validity) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(value, dynamic, 6);
        e.nodes[3] = literal(dynamic ? "bytes" : "bytes32", encoded(bytes32(0), dynamic));
        e.nodes[4] = composite(
            validity ? Expressions.Kind.IsValid : Expressions.Kind.TryOrElse,
            validity ? "bool" : dynamic ? "bytes" : "bytes32",
            validity ? refs1(2) : refs2(2, 3)
        );
        string memory t = validity
            ? (dynamic ? "(bool,bytes)" : "(bool,bytes32)")
            : (dynamic ? "(bytes,bytes)" : "(bytes32,bytes32)");
        e.nodes[5] = composite(Expressions.Kind.Tuple, t, refs2(4, 2));
        bytes memory out = succeeds(e);
        if (!validity) assertEq(out, pair(value, dynamic));
        else if (dynamic) assertEq(out, bytes.concat(abi.encode(uint256(32)), abi.encode(true, payload(value))));
        else assertEq(out, abi.encode(true, value));
        assertEq(observer.count(), 1, "successful attempt's leaf is adopted");
    }

    function check_cacheFailedGuardReexecutes(bytes32 value, bool validity) public {
        vm.warp(1000);
        Expressions.Expression memory e = failed(value, validity, 8);
        e.nodes[7] =
            composite(Expressions.Kind.Tuple, validity ? "(bool,bytes32)" : "((bytes32,uint8),bytes32)", refs2(6, 2));
        bytes memory out = succeedsOrdinarily(e);
        assertEq(out, validity ? abi.encode(false, value) : abi.encode(bytes32(0), uint8(7), value));
        assertEq(observer.count(), 2, "failed attempt's leaf executes again");
    }

    function check_cacheFailedGuardPreservesParent(bytes32 value, bool validity) public {
        vm.warp(1000);
        Expressions.Expression memory e = failed(value, validity, 8);
        e.nodes[7] = composite(
            Expressions.Kind.Tuple,
            validity ? "(bytes32,bool,bytes32)" : "(bytes32,(bytes32,uint8),bytes32)",
            refs3(2, 6, 2)
        );
        bytes memory out = succeedsOrdinarily(e);
        assertEq(out, validity ? abi.encode(value, false, value) : abi.encode(value, bytes32(0), uint8(7), value));
        assertEq(observer.count(), 1, "failed attempt preserves the existing parent cache");
    }

    function check_cacheSuccessfulGuardPreservesParent(bytes32 a, bytes32 b, bool validity) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(a, false, 8);
        e.nodes[3] = literal("bytes32", abi.encode(b));
        e.nodes[4] = composite(Expressions.Kind.Call, "bytes32", refs2(0, 3));
        e.nodes[4].selector = ClaimCacheObserver.word.selector;
        e.nodes[4].arguments = "(bytes32)";
        e.nodes[5] = literal("bytes32", abi.encode(bytes32(0)));
        e.nodes[6] = composite(
            validity ? Expressions.Kind.IsValid : Expressions.Kind.TryOrElse,
            validity ? "bool" : "bytes32",
            validity ? refs1(4) : refs2(4, 5)
        );
        e.nodes[7] = composite(
            Expressions.Kind.Tuple, validity ? "(bytes32,bool,bytes32)" : "(bytes32,bytes32,bytes32)", refs3(2, 6, 2)
        );
        assertEq(succeeds(e), validity ? abi.encode(a, true, a) : abi.encode(a, b, a));
        assertEq(observer.count(), 2, "successful attempt preserves preexisting entries");
    }

    function check_cacheNestedSuccessfulAdoption(bytes32 value, bool dynamic) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(value, dynamic, 7);
        string memory t = dynamic ? "bytes" : "bytes32";
        e.nodes[3] = literal(t, encoded(bytes32(0), dynamic));
        e.nodes[4] = composite(Expressions.Kind.TryOrElse, t, refs2(2, 3));
        e.nodes[5] = composite(Expressions.Kind.TryOrElse, t, refs2(4, 3));
        e.nodes[6] = composite(Expressions.Kind.Tuple, dynamic ? "(bytes,bytes)" : "(bytes32,bytes32)", refs2(5, 2));
        assertEq(succeeds(e), pair(value, dynamic));
        assertEq(observer.count(), 1, "nested successful guards adopt the leaf");
    }

    function check_cacheOuterFailureDiscardsInnerSuccess(bytes32 value) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(value, false, 8);
        e.nodes[3] = composite(Expressions.Kind.IsValid, "bool", refs1(2));
        e.nodes[4] = literal("uint8", abi.encode(uint256(256)));
        e.nodes[5] = composite(Expressions.Kind.Tuple, "(bool,uint8)", refs2(3, 4));
        e.nodes[6] = composite(Expressions.Kind.IsValid, "bool", refs1(5));
        e.nodes[7] = composite(Expressions.Kind.Tuple, "(bool,bytes32)", refs2(6, 2));
        assertEq(succeedsOrdinarily(e), abi.encode(false, value));
        assertEq(observer.count(), 2, "outer failure discards an inner successful adoption");
    }

    function check_cacheRepeatedFailedAttempts(bytes32 value) public {
        vm.warp(1000);
        Expressions.Expression memory e = failed(value, true, 9);
        e.nodes[7] = composite(Expressions.Kind.IsValid, "bool", refs1(4));
        e.nodes[8] = composite(Expressions.Kind.Tuple, "(bool,bool,bytes32)", refs3(6, 7, 2));
        assertEq(succeedsOrdinarily(e), abi.encode(false, false, value));
        assertEq(observer.count(), 3, "each failed attempt and the final use execute the leaf");
    }

    function check_cacheOnlyValidatedResultsReused(bytes32 value) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(value, false, 6);
        e.nodes[2].valueType = "uint8";
        e.nodes[3] = composite(Expressions.Kind.IsValid, "bool", refs1(2));
        e.nodes[4] = composite(Expressions.Kind.IsValid, "bool", refs1(2));
        e.nodes[5] = composite(Expressions.Kind.Tuple, "(bool,bool)", refs2(3, 4));
        bool valid = uint256(value) < 256;
        assertEq(succeedsOrdinarily(e), abi.encode(valid, valid));
        assertEq(observer.count(), valid ? 1 : 2, "only a validated result becomes reusable");
    }

    function check_cacheSeparateEvaluations(bytes32 value, bool encodedEntry) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(value, false, 4);
        e.nodes[3] = composite(Expressions.Kind.Tuple, "(bytes32,bytes32)", refs2(2, 2));
        assertEq(succeeds(e), abi.encode(value, value));
        bytes memory data = encodedEntry
            ? abi.encodeCall(Expressions.evaluateEncoded, (abi.encode(e), new bytes[](0)))
            : abi.encodeCall(Expressions.evaluate, (e, new bytes[](0)));
        (bool ok, bytes memory out) = address(expressions).staticcall(data);
        assertTrue(ok, "second evaluation reverted");
        assertEq(out, abi.encode(value, value));
        assertEq(observer.count(), 2, "separate evaluations have separate caches");
    }

    function check_cacheSeparateCollectionCallbacks(bytes32 a, bytes32 b) public {
        vm.warp(1000);
        Expressions.Expression memory e = leaf(bytes32(0), false, 4);
        e.nodes[1] = literal("bytes32", abi.encode(uint256(0)));
        e.nodes[1].kind = Expressions.Kind.Parameter;
        e.nodes[3] = composite(Expressions.Kind.Tuple, "(bytes32,bytes32)", refs2(2, 2));
        Collections.Callback memory cb;
        cb.target = address(expressions);
        cb.arguments = "(bytes32)";
        cb.constants = new bytes[](1);
        cb.constants[0] = abi.encode(bytes32(0));
        cb.expression = abi.encode(e);
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(abi.encodeCall(Collections.mapValues, ("bytes32", "(bytes32,bytes32)", values, cb)));
        assertTrue(ok, "callback evaluation reverted");
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(a, a);
        expected[1] = abi.encode(b, b);
        assertEq(out, abi.encode(expected));
        assertEq(observer.count(), 2, "sharing is per callback invocation");
    }

    function leaf(bytes32 value, bool dynamic, uint256 n) internal view returns (Expressions.Expression memory e) {
        e.nodes = new Expressions.Node[](n);
        e.result = n - 1;
        e.nodes[0] = literal("address", abi.encode(address(observer)));
        e.nodes[1] = literal("bytes32", abi.encode(value));
        e.nodes[2] = composite(Expressions.Kind.Call, dynamic ? "bytes" : "bytes32", refs2(0, 1));
        e.nodes[2].selector = dynamic ? ClaimCacheObserver.blob.selector : ClaimCacheObserver.word.selector;
        e.nodes[2].arguments = "(bytes32)";
    }

    function failed(bytes32 value, bool validity, uint256 n) internal view returns (Expressions.Expression memory e) {
        e = leaf(value, false, n);
        e.nodes[3] = literal("uint8", abi.encode(uint256(256)));
        e.nodes[4] = composite(Expressions.Kind.Tuple, "(bytes32,uint8)", refs2(2, 3));
        e.nodes[5] = literal("(bytes32,uint8)", abi.encode(bytes32(0), uint8(7)));
        e.nodes[6] = composite(
            validity ? Expressions.Kind.IsValid : Expressions.Kind.TryOrElse,
            validity ? "bool" : "(bytes32,uint8)",
            validity ? refs1(4) : refs2(4, 5)
        );
    }

    function literal(string memory t, bytes memory value) internal pure returns (Expressions.Node memory n) {
        n.kind = Expressions.Kind.Literal;
        n.valueType = t;
        n.data = value;
        n.refs = new uint256[](0);
    }

    function composite(Expressions.Kind kind, string memory t, uint256[] memory refs)
        internal
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = kind;
        n.valueType = t;
        n.refs = refs;
        n.arguments = t;
    }

    function refs1(uint256 a) internal pure returns (uint256[] memory r) {
        r = new uint256[](1);
        r[0] = a;
    }

    function refs2(uint256 a, uint256 b) internal pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[0] = a;
        r[1] = b;
    }

    function refs3(uint256 a, uint256 b, uint256 c) internal pure returns (uint256[] memory r) {
        r = new uint256[](3);
        r[0] = a;
        r[1] = b;
        r[2] = c;
    }

    function payload(bytes32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value, bytes1(0x7f));
    }

    function encoded(bytes32 value, bool dynamic) internal pure returns (bytes memory) {
        return dynamic ? abi.encode(payload(value)) : abi.encode(value);
    }

    function pair(bytes32 value, bool dynamic) internal pure returns (bytes memory) {
        return dynamic
            ? bytes.concat(abi.encode(uint256(32)), abi.encode(payload(value), payload(value)))
            : abi.encode(value, value);
    }

    function evaluate(Expressions.Expression memory e) internal view returns (bool ok, bytes memory out) {
        return address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (e, new bytes[](0))));
    }

    function succeeds(Expressions.Expression memory e) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = evaluate(e);
        assertTrue(ok, "valid graph reverted");
    }

    function succeedsOrdinarily(Expressions.Expression memory e) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = evaluate(e);
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector)));
        assertTrue(ok, "ordinary failed attempt escaped its guard");
    }

    function test_cacheObserverSharedAndSuccessfulSamples() public {
        bytes32 value = bytes32(uint256(42));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (value)), uint64(3));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.blob, (value)), uint64(3));
        check_cacheSharedNodeReuse(value, false);
        check_cacheSharedNodeReuse(value, true);
        check_cacheSuccessfulGuardAdopts(value, false, false);
        check_cacheSuccessfulGuardAdopts(value, false, true);
        check_cacheSuccessfulGuardAdopts(value, true, false);
        check_cacheSuccessfulGuardAdopts(value, true, true);
    }

    function test_cacheObserverFailedSample() public {
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (bytes32(uint256(42)))), uint64(4));
        check_cacheFailedGuardReexecutes(bytes32(uint256(42)), true);
        check_cacheFailedGuardReexecutes(bytes32(uint256(42)), false);
    }

    function test_cacheObserverParentAndNestedSamples() public {
        bytes32 a = bytes32(uint256(42));
        bytes32 b = bytes32(uint256(93));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (a)), uint64(7));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (b)), uint64(2));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.blob, (a)), uint64(1));
        check_cacheFailedGuardPreservesParent(a, true);
        check_cacheFailedGuardPreservesParent(a, false);
        check_cacheSuccessfulGuardPreservesParent(a, b, true);
        check_cacheSuccessfulGuardPreservesParent(a, b, false);
        check_cacheNestedSuccessfulAdoption(a, false);
        check_cacheNestedSuccessfulAdoption(a, true);
        check_cacheOuterFailureDiscardsInnerSuccess(a);
    }

    function test_cacheObserverRepeatedAndInvalidSamples() public {
        bytes32 value = bytes32(uint256(42));
        bytes32 dirty = bytes32(uint256(256));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (value)), uint64(4));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (dirty)), uint64(2));
        check_cacheRepeatedFailedAttempts(value);
        check_cacheOnlyValidatedResultsReused(value);
        check_cacheOnlyValidatedResultsReused(dirty);
    }

    function test_cacheObserverSeparateInvocationSamples() public {
        bytes32 a = bytes32(uint256(42));
        bytes32 b = bytes32(uint256(93));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (a)), uint64(5));
        vm.expectCall(address(observer), abi.encodeCall(ClaimCacheObserver.word, (b)), uint64(1));
        check_cacheSeparateEvaluations(a, false);
        check_cacheSeparateEvaluations(a, true);
        check_cacheSeparateCollectionCallbacks(a, b);
    }
}
