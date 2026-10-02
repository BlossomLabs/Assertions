// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Expressions.sol";
import "../Assertions.sol";

/**
 * @dev Returns (caller, calldata) as the canonical single value of the
 *      dynamic tuple (address,bytes): the 0x20 envelope, then the body
 */
contract Reflector {
    fallback(bytes calldata data) external returns (bytes memory) {
        return bytes.concat(abi.encode(uint256(32)), abi.encode(msg.sender, data));
    }
}

/**
 * @dev Returns its first argument word as-is, whatever type the caller declares
 */
contract WordSource {
    function get(bytes32 w) external pure returns (bytes32) {
        return w;
    }

    function boom(bytes32) external pure returns (bytes32) {
        revert("boom");
    }
}

/**
 * @dev Reverts with exactly the calldata it receives
 */
contract ProbeReverter {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            revert(0, calldatasize())
        }
    }
}

/**
 * @notice Halmos properties for the Expressions node kinds that call out:
 *         Call, ProbeCall and Resolve. Run with `pnpm halmos`.
 * @dev The oracle for Call is solc: the target must receive the selector
 *      followed by abi.encode of the argument values, from Expressions.
 *      ProbeCall is held to the core's revertData rules. Every evaluation
 *      checks its success explicitly: Halmos discards reverting paths.
 */
contract ExpressionsCallsSymbolicTest is Test {
    Expressions xp;
    Assertions core;
    Reflector reflector;
    WordSource source;
    ProbeReverter reverter;

    function setUp() public {
        xp = new Expressions();
        core = new Assertions();
        reflector = new Reflector();
        source = new WordSource();
        reverter = new ProbeReverter();
    }

    // ============ Call ============

    /**
     * @dev A Call node sends selector ++ abi.encode(args) from Expressions,
     *      and accepts exactly the arguments solc would decode
     */
    function check_callBuildsSolcCalldata(
        bytes32 small,
        bytes32 word,
        uint8 lengthCase,
        bytes32 payload,
        bytes4 selector
    ) public view {
        vm.assume(lengthCase < 3);
        uint256 len = lengthCase == 0 ? 0 : lengthCase == 1 ? 5 : 32;
        bytes memory str = new bytes(len);
        for (uint256 i; i < len; i++) {
            str[i] = payload[i];
        }
        bytes[] memory params = new bytes[](2);
        params[0] = abi.encode(small);
        params[1] = abi.encode(word);
        Expressions.Expression memory e = expression(5);
        e.nodes[0] = literal("address", abi.encode(address(reflector)));
        e.nodes[1] = param("uint8", 0);
        e.nodes[2] = param("bytes32", 1);
        e.nodes[3] = literal("string", abi.encode(string(str)));
        e.nodes[4] = callNode("(address,bytes)", selector, "(uint8,bytes32,string)", refs4(0, 1, 2, 3));
        (bool ok, bytes memory out) = evaluate(e, params);
        bool valid = uint256(small) < 256;
        assertEq(ok, valid, "Call and solc disagree on the arguments");
        if (ok) {
            bytes memory sent = bytes.concat(selector, abi.encode(uint8(uint256(small)), word, string(str)));
            assertEq(out, bytes.concat(abi.encode(uint256(32)), abi.encode(address(xp), sent)));
        }
    }

    /**
     * @dev The target word must be a clean address (InvalidNode), have code
     *      (InvalidTarget) and not revert (NodeCallFailed with the reason)
     */
    function check_callTargetRules(uint96 upper, uint8 caseId, bytes32 w) public view {
        vm.assume(caseId < 3);
        address target = caseId == 0 ? address(source) : caseId == 1 ? address(0xE0A) : address(source);
        bytes4 selector = caseId == 2 ? WordSource.boom.selector : WordSource.get.selector;
        bytes32 targetWord = bytes32(uint256(uint160(target)) | (uint256(upper) << 160));
        bytes[] memory params = new bytes[](1);
        params[0] = abi.encode(w);
        Expressions.Expression memory e = expression(3);
        e.nodes[0] = literal("bytes32", abi.encode(targetWord));
        e.nodes[1] = param("bytes32", 0);
        e.nodes[2] = callNode("bytes32", selector, "(bytes32)", refs2(0, 1));
        (bool ok, bytes memory out) = evaluate(e, params);
        vm.assume(!outOfGasArtifact(ok, out));
        if (upper != 0) {
            assertFalse(ok, "a dirty target word is called");
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(2)));
        } else if (caseId == 1) {
            assertFalse(ok, "a code-less target is called");
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidTarget.selector, uint256(2), address(0xE0A)));
        } else if (caseId == 2) {
            assertFalse(ok, "a reverting call succeeds");
            assertEq(
                out,
                abi.encodeWithSelector(
                    Expressions.NodeCallFailed.selector,
                    uint256(2),
                    address(source),
                    abi.encodeCall(WordSource.boom, (w)),
                    abi.encodeWithSignature("Error(string)", "boom")
                )
            );
        } else {
            assertTrue(ok, "a clean call is refused");
            assertEq(out, abi.encode(w));
        }
    }

    /**
     * @dev A Call's result is validated against the node's own valueType
     */
    function check_callResultIsValidated(bytes32 w) public view {
        bytes[] memory params = new bytes[](1);
        params[0] = abi.encode(w);
        Expressions.Expression memory e = expression(3);
        e.nodes[0] = literal("address", abi.encode(address(source)));
        e.nodes[1] = param("bytes32", 0);
        e.nodes[2] = callNode("uint8", WordSource.get.selector, "(bytes32)", refs2(0, 1));
        (bool ok, bytes memory out) = evaluate(e, params);
        if (uint256(w) < 256) {
            assertTrue(ok, "a canonical result is refused");
            assertEq(out, abi.encode(w));
        } else {
            assertFalse(ok, "a non-canonical result is accepted");
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        }
    }

    // ============ ProbeCall ============

    /**
     * @dev ProbeCall follows the core's revertData: whole reason, stripped selector, or UnexpectedRevertData
     */
    function check_probeCallMatchesRevertData(uint8 lengthCase, bytes32 d0, bytes32 d1, bytes4 expected) public view {
        vm.assume(lengthCase < 5);
        uint256 length = lengthCase == 0 ? 0 : lengthCase == 1 ? 3 : lengthCase == 2 ? 4 : lengthCase == 3 ? 36 : 64;
        bytes memory data = abi.encodePacked(d0, d1);
        assembly ("memory-safe") { mstore(data, length) }
        Expressions.Expression memory e = expression(3);
        e.nodes[0] = literal("address", abi.encode(address(reverter)));
        e.nodes[1] = literal("bytes", abi.encode(data));
        e.nodes[2] = composite(Expressions.Kind.ProbeCall, "bytes", refs2(0, 1));
        e.nodes[2].selector = expected;
        (bool ok, bytes memory out) = evaluate(e, new bytes[](0));
        vm.assume(!outOfGasArtifact(ok, out));
        bytes4 got = length >= 4 ? bytes4(d0) : bytes4(0);
        if (expected == bytes4(0)) {
            assertTrue(ok, "a zero expectation is refused");
            assertEq(out, abi.encode(data));
        } else if (got == expected) {
            assertTrue(ok, "a matching selector is refused");
            bytes memory rest = new bytes(length - 4);
            for (uint256 i; i < rest.length; i++) {
                rest[i] = data[4 + i];
            }
            assertEq(out, abi.encode(rest));
        } else {
            assertFalse(ok, "a mismatched selector is accepted");
            assertEq(out, abi.encodeWithSelector(Expressions.UnexpectedRevertData.selector, expected, got));
        }
    }

    /**
     * @dev A call that succeeds is DidNotRevert; a code-less target meets only a zero expectation
     */
    function check_probeCallRefusals(bool codeless, bytes4 expected, bytes32 w) public view {
        address target = codeless ? address(0xE0A) : address(source);
        bytes memory data = abi.encodeCall(WordSource.get, (w));
        Expressions.Expression memory e = expression(3);
        e.nodes[0] = literal("address", abi.encode(target));
        e.nodes[1] = literal("bytes", abi.encode(data));
        e.nodes[2] = composite(Expressions.Kind.ProbeCall, "bytes", refs2(0, 1));
        e.nodes[2].selector = expected;
        (bool ok, bytes memory out) = evaluate(e, new bytes[](0));
        if (!codeless) {
            assertFalse(ok, "a successful call passes as a probe");
            assertEq(out, abi.encodeWithSelector(Expressions.DidNotRevert.selector, address(source), data));
        } else if (expected == bytes4(0)) {
            assertTrue(ok, "an empty account with no expectation is refused");
            assertEq(out, abi.encode(bytes("")));
        } else {
            assertFalse(ok, "an empty account meets an expectation");
            assertEq(out, abi.encodeWithSelector(Expressions.UnexpectedRevertData.selector, expected, bytes4(0)));
        }
    }

    // ============ Resolve ============

    /**
     * @dev A Resolve node's value is what the core resolves, validated as the node's type
     */
    function check_resolveGoesThroughTheCore(bytes32 w) public view {
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(w), new Constraint[](0));
        Expressions.Expression memory e = expression(1);
        e.core = address(core);
        e.nodes[0] = node(Expressions.Kind.Resolve, "address", abi.encode(p), new uint256[](0), "");
        (bool ok, bytes memory out) = evaluate(e, new bytes[](0));
        if (uint256(w) >> 160 == 0) {
            assertTrue(ok, "a resolved address is refused");
            assertEq(out, abi.encode(w));
        } else {
            assertFalse(ok, "a dirty resolved address is accepted");
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        }
    }

    // ============ Harness ============

    function evaluate(Expressions.Expression memory e, bytes[] memory params)
        internal
        view
        returns (bool ok, bytes memory out)
    {
        (ok, out) = address(xp).staticcall(abi.encodeCall(Expressions.evaluate, (e, params)));
    }

    function expression(uint256 n) internal view returns (Expressions.Expression memory e) {
        e.core = address(core);
        e.nodes = new Expressions.Node[](n);
        e.result = n - 1;
    }

    function node(
        Expressions.Kind kind,
        string memory valueType,
        bytes memory data,
        uint256[] memory refs,
        string memory arguments
    ) internal pure returns (Expressions.Node memory) {
        return Expressions.Node(kind, valueType, data, refs, bytes4(0), arguments);
    }

    function param(string memory valueType, uint256 index) internal pure returns (Expressions.Node memory) {
        return node(Expressions.Kind.Parameter, valueType, abi.encode(index), new uint256[](0), "");
    }

    function literal(string memory valueType, bytes memory value) internal pure returns (Expressions.Node memory) {
        return node(Expressions.Kind.Literal, valueType, value, new uint256[](0), "");
    }

    function composite(Expressions.Kind kind, string memory valueType, uint256[] memory refs)
        internal
        pure
        returns (Expressions.Node memory)
    {
        return node(kind, valueType, "", refs, "");
    }

    function callNode(string memory valueType, bytes4 selector, string memory arguments, uint256[] memory refs)
        internal
        pure
        returns (Expressions.Node memory n)
    {
        n = node(Expressions.Kind.Call, valueType, "", refs, arguments);
        n.selector = selector;
    }

    function refs2(uint256 a, uint256 b) internal pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[0] = a;
        r[1] = b;
    }

    function refs4(uint256 a, uint256 b, uint256 c, uint256 d) internal pure returns (uint256[] memory r) {
        r = new uint256[](4);
        r[0] = a;
        r[1] = b;
        r[2] = c;
        r[3] = d;
    }

    /**
     * @dev Halmos does not model gas: gasleft() is a fresh symbol each time,
     *      so the out-of-gas guard can fire on any failed subcall, a path no
     *      real execution takes. Such a SubcallOutOfGas outcome is discarded
     *      here; Expressions.t.sol pins the guard at real gas values.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector));
    }
}
