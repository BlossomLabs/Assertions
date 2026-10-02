// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Expressions.sol";
import {Operations} from "../Operations.sol";
import {HostileTarget} from "./CollectionsNoPanic.t.sol";

/**
 * @notice Fuzz checks for declared failures on generated graphs, cores and
 *         targets, plus exact regressions for impossible decoder allocations.
 * @dev RawNode and RawExpression mirror the real structs with uint8 kinds.
 *      Graphs have up to six nodes and each call gets a fixed gas budget.
 *      Malformed payloads may fail with empty data or allocation Panic(0x41);
 *      other panics remain failures of the bounded fuzz check. These sweeps
 *      do not prove resource-independent success or selector-bearing errors.
 */
contract ExpressionsNoPanicTest is Test {
    bytes4 constant PANIC = 0x4e487b71;
    uint256 constant CALL_GAS = 10_000_000;
    string constant NODE = "(uint8,string,bytes,uint256[],bytes4,string)";
    string constant EXPRESSION = "(address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256)";

    struct RawNode {
        uint8 kind;
        string valueType;
        bytes data;
        uint256[] refs;
        bytes4 selector;
        string arguments;
    }

    struct RawExpression {
        address core;
        RawNode[] nodes;
        uint256 result;
    }

    /**
     * @dev One fuzzed node's raw material
     */
    struct NodeInput {
        uint8 kind;
        uint8 typeCase;
        uint8 refCase;
        bytes32 word;
        bytes junk;
    }

    Assertions core;
    Expressions expressions;
    address[11] targets;

    function setUp() public {
        core = new Assertions();
        expressions = new Expressions();
        for (uint256 m; m < 8; m++) {
            targets[m] = address(new HostileTarget(m));
        }
        targets[8] = address(new Operations());
        targets[9] = address(core);
        targets[10] = address(0xdead);
    }

    function testFuzzGraphsDocumentedFailures(
        NodeInput[] calldata inputs,
        uint8 coreCase,
        uint8 resultCase,
        bool junk,
        bytes[] calldata parameters,
        bytes calldata payload
    ) public view {
        (RawExpression memory e, bool malformed) = graph(inputs, coreCase, resultCase, junk);
        call(abi.encodeWithSignature(string.concat("evaluate(", EXPRESSION, ",bytes[])"), e, parameters), malformed);
        call(abi.encodeCall(Expressions.evaluateEncoded, (abi.encode(e), parameters)), malformed);
        call(abi.encodeCall(Expressions.evaluateEncoded, (payload, parameters)), true);
    }

    function testResolveRejectsImpossibleDecoderAllocation() public view {
        RawExpression memory e;
        e.core = address(core);
        e.nodes = new RawNode[](1);
        e.nodes[0].kind = uint8(Expressions.Kind.Resolve);
        e.nodes[0].valueType = "uint256";
        e.nodes[0].refs = new uint256[](0);
        // InputParam tuple: two enum words, data/constraints offsets, empty
        // data, then an impossible constraints count. The target is not called.
        e.nodes[0].data =
            abi.encode(uint256(32), uint256(2), uint256(0), uint256(128), uint256(160), uint256(0), type(uint256).max);
        assertAllocationPanic(
            abi.encodeWithSignature(string.concat("evaluate(", EXPRESSION, ",bytes[])"), e, new bytes[](0))
        );
    }

    function testEvaluateEncodedRejectsImpossibleDecoderAllocation() public view {
        // Expression tuple: core, nodes offset, result, impossible nodes count.
        bytes memory payload = abi.encode(uint256(32), address(core), uint256(96), uint256(0), type(uint256).max);
        assertAllocationPanic(abi.encodeCall(Expressions.evaluateEncoded, (payload, new bytes[](0))));
    }

    function assertAllocationPanic(bytes memory data) internal view {
        (bool ok, bytes memory out) = address(expressions).staticcall{gas: CALL_GAS}(data);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSignature("Panic(uint256)", uint256(0x41)));
    }

    // ============ Builders ============

    function graph(NodeInput[] calldata inputs, uint8 coreCase, uint8 resultCase, bool junk)
        internal
        view
        returns (RawExpression memory e, bool malformed)
    {
        uint256 n = inputs.length % 7;
        e.core = coreCase % 3 == 0 ? address(core) : targets[coreCase % targets.length];
        e.nodes = new RawNode[](n);
        e.result = n == 0 ? 0 : resultCase % 8 == 7 ? n : resultCase % n;
        for (uint256 i; i < n; i++) {
            bool bad;
            (e.nodes[i], bad) = node(inputs[i], i, junk);
            malformed = malformed || bad;
        }
    }

    /**
     * @dev A node of any kind with mostly valid references and data, and whether it is undecodable
     */
    function node(NodeInput calldata in_, uint256 index, bool junk)
        internal
        view
        returns (RawNode memory out, bool malformed)
    {
        out.kind = in_.kind % (junk ? 12 : 11);
        malformed = out.kind > 10;
        out.valueType = valueType(in_.typeCase);
        out.selector = in_.refCase & 1 == 0 ? bytes4(keccak256("add(uint256,uint256)")) : bytes4(in_.word);
        out.arguments = in_.refCase & 2 == 0 ? "(uint256,uint256)" : "(uint256)";
        if (out.kind == 0) {
            // Literal: a value of its type, an address of a target, or junk.
            uint8 v = in_.typeCase % 4;
            out.data = v == 0
                ? abi.encode(in_.word)
                : v == 1
                    ? abi.encode(targets[uint8(in_.word[0]) % targets.length])
                    : v == 2 ? abi.encode(abi.encode(in_.word)) : in_.junk;
        } else if (out.kind == 1) {
            out.data = in_.refCase & 4 == 0 ? abi.encode(uint256(uint8(in_.word[1]) % 3)) : in_.junk;
        } else if (out.kind == 2) {
            if (junk && in_.refCase & 4 != 0) {
                out.data = in_.junk;
                malformed = true;
            } else {
                out.data = abi.encode(
                    InputParam(
                        InputParamType.CALL_DATA,
                        InputParamFetcherType.RAW_BYTES,
                        abi.encode(in_.word),
                        new Constraint[](0)
                    )
                );
            }
        }
        out.refs = refs(out.kind, in_, index);
    }

    /**
     * @dev The kind's reference count over earlier nodes, sometimes wrong or pointing forward
     */
    function refs(uint8 kind, NodeInput calldata in_, uint256 index) internal pure returns (uint256[] memory r) {
        uint256 count = kind == 3
            ? 1 + in_.refCase % 3
            : kind == 4
                ? 3
                : kind == 8 || kind == 10
                    ? 2
                    : kind == 5 || kind == 9 ? 1 : kind == 6 || kind == 7 ? in_.refCase % 3 : 0;
        if (in_.refCase & 0x80 != 0) count = in_.refCase % 4;
        r = new uint256[](count);
        for (uint256 j; j < count; j++) {
            uint256 pick = uint8(in_.word[j + 2]);
            r[j] = index == 0 || in_.refCase & 0x40 != 0 ? pick % 8 : pick % index;
        }
    }

    function valueType(uint8 c) internal pure returns (string memory) {
        c %= 9;
        if (c == 0) return "uint256";
        if (c == 1) return "address";
        if (c == 2) return "bytes";
        if (c == 3) return "bool";
        if (c == 4) return "(uint256,uint256)";
        if (c == 5) return "string";
        if (c == 6) return "uint8";
        if (c == 7) return "uint256[0]";
        return "((";
    }

    // ============ Helpers ============

    /**
     * @dev Ordinary failures require a non-panic selector. Injected malformed
     *      payloads may additionally return empty data or exact allocation
     *      Panic(0x41), as pinned by the decoder regressions
     */
    function call(bytes memory data, bool malformed) internal view {
        (bool ok, bytes memory out) = address(expressions).staticcall{gas: CALL_GAS}(data);
        if (ok) return;
        if (out.length == 0 && malformed) return;
        if (malformed && keccak256(out) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(0x41)))) return;
        assertGe(out.length, 4, "no selector (out of gas?)");
        assertTrue(bytes4(out) != PANIC, "expressions panicked");
    }
}
