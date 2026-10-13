// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Expressions.sol";
import "./ClaimConstructionSymbolic.t.sol";

/**
 * @notice Relational unread-field properties and exact visited-error cases.
 *         Descriptor parentheses and layouts that locate read fields remain
 *         fixed. Dynamic byte-copy lengths and graph shapes are literal cases.
 */
contract ClaimUnreadSymbolicTest is Test {
    Assertions core;
    Expressions expressions;
    ClaimConstructionObserver observer;
    bytes32 constant MARK = 0xfedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210;

    function setUp() public {
        core = new Assertions();
        expressions = new Expressions();
        observer = new ClaimConstructionObserver();
    }

    function check_behaviorUnreachableTypesAdmittedFirst(bytes32 word, uint8 invalidType) public {
        vm.assume(invalidType < 3);
        vm.warp(1000);
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](4);
        e.result = 2;
        e.nodes[0] = literal("address", abi.encode(address(observer)));
        e.nodes[1] = literal("bytes32", abi.encode(word));
        e.nodes[2] = literal("bytes32", "");
        e.nodes[2].kind = Expressions.Kind.Call;
        e.nodes[2].refs = refs2(0, 1);
        e.nodes[2].selector = ClaimConstructionObserver.word.selector;
        e.nodes[2].arguments = "(bytes32)";
        e.nodes[3] = literal(invalidType == 0 ? "uint8[0]" : invalidType == 1 ? "()" : "(", abi.encode(uint256(0)));
        (bool ok, bytes memory out) = evaluate(e);
        assertFalse(ok);
        assertEq(
            out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, invalidType == 0 ? uint256(7) : uint256(1))
        );
        assertEq(observer.count(), 0, "admission must precede every leaf call");
    }

    function check_behaviorDanglingNodesNeverExecute(bytes32 word) public {
        vm.warp(1000);
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](4);
        e.nodes[0] = literal("bytes32", abi.encode(word));
        e.nodes[1] = literal("address", abi.encode(address(observer)));
        e.nodes[2] = literal("bytes32", abi.encode(uint256(256)));
        e.nodes[3] = literal("uint8", "");
        e.nodes[3].kind = Expressions.Kind.Call;
        e.nodes[3].refs = refs2(1, 2);
        e.nodes[3].selector = ClaimConstructionObserver.word.selector;
        e.nodes[3].arguments = "(bytes32)";
        (bool ok, bytes memory out) = evaluate(e);
        assertTrue(ok);
        assertEq(out, abi.encode(word));
        assertEq(observer.count(), 0, "a dangling invalid-result call is never reached");
    }

    function check_behaviorUnreadEncodedLengthIndependent(bytes32 word, uint256 first, uint256 second) public view {
        bytes memory fixture = abi.encode(unread(uint256(7)));
        uint256 offset = findWord(fixture, MARK) - 32;
        bytes memory payload = abi.encode(unread(uint256(word)));
        setWord(payload, offset, bytes32(first));
        (bool ok, bytes memory a) = encoded(payload);
        assertTrue(ok, "unread first length influenced decoding");
        setWord(payload, offset, bytes32(second));
        (ok, payload) = encoded(payload);
        assertTrue(ok, "unread second length influenced decoding");
        assertEq(a, payload);
        assertEq(a, abi.encode(word));
    }

    function check_behaviorEncodedLeadingHeaderRefusal(uint8 shape) public view {
        vm.assume(shape < 6);
        bytes memory payload;
        if (shape == 0) {
            payload = "";
        } else if (shape == 1) {
            payload = new bytes(31);
        } else {
            payload = abi.encode(
                shape == 2 ? uint256(0) : shape == 3 ? uint256(31) : shape == 4 ? uint256(1024) : type(uint256).max
            );
        }
        (bool ok, bytes memory out) = encoded(payload);
        assertFalse(ok);
        assertEq(out, bytes(""));
    }

    function check_behaviorConsumedEncodedFieldWrapsFailure() public view {
        bytes memory payload = abi.encode(uint256(32), address(core), uint256(1024), uint256(0));
        (bool ok, bytes memory out) = encoded(payload);
        excludeGasArtifact(ok, out);
        assertFalse(ok);
        // The independent parameter encoder supplies the empty array body.
        bytes memory expected = bytes.concat(
            Expressions.evaluate.selector,
            abi.encode(uint256(96), uint256(64), uint256(0)),
            abi.encode(address(core), uint256(1024), uint256(0))
        );
        assertEq(
            out,
            abi.encodeWithSelector(
                Expressions.NodeCallFailed.selector, uint256(0), address(expressions), expected, bytes("")
            )
        );
    }

    function check_behaviorUnreadDescriptorTextIndependent(bytes32 word, bytes32 first, bytes32 second, uint8 size)
        public
        view
    {
        vm.assume(size < 4);
        uint256 n = size == 0 ? 0 : size == 1 ? 1 : size == 2 ? 4 : 8;
        bytes memory a = new bytes(n);
        bytes memory b = new bytes(n);
        for (uint256 i; i < n; i++) {
            vm.assume(first[i] != bytes1("(") && first[i] != bytes1(")"));
            vm.assume(second[i] != bytes1("(") && second[i] != bytes1(")"));
            a[i] = first[i];
            b[i] = second[i];
        }
        int256[] memory path = new int256[](1);
        bytes memory data = abi.encode(word, uint256(9));
        (bool ok, bytes memory one) = nav(data, string(bytes.concat("(uint256,", a, ")")), path);
        assertTrue(ok);
        (ok, data) = nav(data, string(bytes.concat("(uint256,", b, ")")), path);
        assertTrue(ok);
        assertEq(one, data);
        assertEq(one, abi.encode(word));
    }

    function check_behaviorVisitedDescriptorErrorsBeforeData(bytes32 word, uint8 fault, bool emptyData) public view {
        vm.assume(fault < 6);
        string memory t;
        uint256 pos;
        int256[] memory path = new int256[](1);
        if (fault == 0) {
            t = "(uint256,uint8[0])";
            pos = 16;
            path[0] = 1;
        } else if (fault == 1) {
            t = "(uint8[0],uint256)";
            pos = 8;
            path[0] = 1;
        } else if (fault == 2) {
            t = "(uint256 uint8)";
            pos = 8;
        } else if (fault == 3) {
            t = "(uint256,uint256))";
            pos = 17;
        } else if (fault == 4) {
            t = "(uint256)[0]";
            pos = 11;
        } else {
            t = "(uint256)[99999999999]";
            pos = 20;
        }
        (bool ok, bytes memory out) = nav(emptyData ? bytes("") : abi.encode(word, word), t, path);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, pos));
    }

    function unread(uint256 word) internal pure returns (Expressions.Expression memory e) {
        e.nodes = new Expressions.Node[](2);
        e.nodes[0] = literal("uint256", abi.encode(word));
        e.nodes[1] = literal("bytes32", abi.encode(MARK));
    }

    function literal(string memory t, bytes memory data) internal pure returns (Expressions.Node memory n) {
        n.kind = Expressions.Kind.Literal;
        n.valueType = t;
        n.data = data;
        n.refs = new uint256[](0);
    }

    function refs2(uint256 a, uint256 b) internal pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[0] = a;
        r[1] = b;
    }

    function findWord(bytes memory data, bytes32 sentinel) internal pure returns (uint256 found) {
        uint256 matches;
        for (uint256 i; i + 32 <= data.length; i += 32) {
            bytes32 word;
            assembly ("memory-safe") { word := mload(add(add(data, 32), i)) }
            if (word == sentinel) {
                found = i;
                matches++;
            }
        }
        assertEq(matches, 1, "fixture must locate exactly one sentinel");
    }

    function setWord(bytes memory data, uint256 offset, bytes32 value) internal pure {
        assertTrue(offset + 32 <= data.length);
        assembly ("memory-safe") { mstore(add(add(data, 32), offset), value) }
    }

    function evaluate(Expressions.Expression memory e) internal view returns (bool, bytes memory) {
        return address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (e, new bytes[](0))));
    }

    function encoded(bytes memory payload) internal view returns (bool, bytes memory) {
        return address(expressions).staticcall(abi.encodeCall(Expressions.evaluateEncoded, (payload, new bytes[](0))));
    }

    function nav(bytes memory data, string memory t, int256[] memory path) internal view returns (bool, bytes memory) {
        return address(core).staticcall(abi.encodeCall(Assertions.nav, (raw(data), t, path)));
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function excludeGasArtifact(bool ok, bytes memory out) internal pure {
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector)));
    }

    function test_behaviorAdmissionAndReachabilitySamples() public {
        for (uint8 i; i < 3; i++) {
            check_behaviorUnreachableTypesAdmittedFirst(bytes32(uint256(42)), i);
        }
        check_behaviorDanglingNodesNeverExecute(bytes32(uint256(93)));
    }

    function test_behaviorEncodedUnreadSamples() public view {
        check_behaviorUnreadEncodedLengthIndependent(bytes32(uint256(42)), 0, type(uint256).max);
        for (uint8 i; i < 6; i++) {
            check_behaviorEncodedLeadingHeaderRefusal(i);
        }
        check_behaviorConsumedEncodedFieldWrapsFailure();
    }

    function test_behaviorDescriptorUnreadSamples() public view {
        for (uint8 i; i < 4; i++) {
            check_behaviorUnreadDescriptorTextIndependent(
                bytes32(uint256(42)), bytes32(uint256(7)), bytes32(uint256(9)), i
            );
        }
        for (uint8 i; i < 6; i++) {
            check_behaviorVisitedDescriptorErrorsBeforeData(bytes32(uint256(93)), i, false);
            check_behaviorVisitedDescriptorErrorsBeforeData(bytes32(uint256(93)), i, true);
        }
    }
}
