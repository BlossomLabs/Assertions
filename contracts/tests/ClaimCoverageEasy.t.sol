// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "../Operations.sol";
import "../lib/ERC8211.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract CoverageHost {
    function zero() external pure returns (uint256) {
        return 0;
    }

    function fail() external pure {
        revert("ordinary");
    }

    function pair(uint256 a, uint256 b) external pure returns (bytes32) {
        return a < b ? keccak256(abi.encode(a, b)) : keccak256(abi.encode(b, a));
    }

    function reply(uint256 mode) external pure returns (uint256) {
        if (mode == 1) revert("ordinary");
        if (mode == 2) assembly { return(0, 0) }
        if (mode == 3) {
            assembly {
                mstore(0, 1)
                mstore(32, 1)
                return(0, 64)
            }
        }
        if (mode == 4) return 2;
        if (mode == 5) return 0;
        return 1;
    }
}

contract ClaimCoverageEasyTest is Test {
    Assertions core;
    Operations ops;
    Collections col;
    Expressions graph;
    CoverageHost host;

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
        col = new Collections();
        graph = new Expressions();
        host = new CoverageHost();
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function callParam(address target, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(target, data), new Constraint[](0)
        );
    }

    function failed(address target, bytes memory data, bytes memory expected) internal view {
        (bool ok, bytes memory out) = target.staticcall(data);
        assertFalse(ok);
        assertEq(out, expected);
    }

    function test_C8_DirtyTargetNamesNonzeroIndex() public view {
        ComposableExecution[] memory e = new ComposableExecution[](1);
        e[0].inputParams = new InputParam[](4);
        e[0].outputParams = new OutputParam[](0);
        for (uint256 i; i < 4; i++) {
            e[0].inputParams[i] = raw(abi.encode(i));
        }
        bytes32 dirty = bytes32((uint256(1) << 200) | uint160(address(host)));
        e[0].inputParams[3] = raw(abi.encode(dirty));
        e[0].inputParams[3].paramType = InputParamType.TARGET;
        failed(
            address(core),
            abi.encodeWithSignature("assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", e),
            abi.encodeWithSelector(InvalidAddressWord.selector, 3, dirty)
        );
    }

    function test_C66_C70_ControlFailureMatrix() public {
        InputParam[] memory attempts = new InputParam[](5);
        attempts[0] = raw(abi.encode(uint256(0)));
        attempts[1] = callParam(address(host), abi.encodeCall(host.fail, ()));
        attempts[2] = callParam(address(0xdead), hex"12345678");
        attempts[3] = raw(abi.encode(uint256(7)));
        attempts[3].constraints = new Constraint[](1);
        attempts[3].constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(8)));
        attempts[4] =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, hex"01", new Constraint[](0));
        for (uint256 i; i < attempts.length; i++) {
            assertEq(core.isValid(attempts[i]), i == 0 ? 1 : 0);
            (bool ok, bytes memory result) =
                address(core).staticcall(abi.encodeCall(core.orElse, (attempts[i], raw(abi.encode(uint256(91))))));
            assertTrue(ok);
            assertEq(result, abi.encode(i == 0 ? uint256(0) : uint256(91)));
        }
        bytes memory signal = abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
        InputParam memory p = callParam(address(host), abi.encodeCall(host.zero, ()));
        vm.mockCallRevert(address(host), abi.encodeCall(host.zero, ()), signal);
        failed(address(core), abi.encodeCall(core.isValid, (p)), signal);
        failed(address(core), abi.encodeCall(core.orElse, (p, raw(abi.encode(uint256(91))))), signal);
        vm.clearMockedCalls();
    }

    function test_W3_NumericWireEnums() public pure {
        assertEq(uint8(InputParamType.TARGET), 0);
        assertEq(uint8(InputParamType.VALUE), 1);
        assertEq(uint8(InputParamType.CALL_DATA), 2);
        assertEq(uint8(InputParamFetcherType.RAW_BYTES), 0);
        assertEq(uint8(InputParamFetcherType.STATIC_CALL), 1);
        assertEq(uint8(InputParamFetcherType.BALANCE), 2);
        assertEq(uint8(OutputParamFetcherType.EXEC_RESULT), 0);
        assertEq(uint8(OutputParamFetcherType.STATIC_CALL), 1);
    }

    function test_O11_AllInvalidRoundingValuesAcrossMulDivOverloads() public view {
        for (uint256 i = 3; i <= 255; i++) {
            failed(address(ops), abi.encodeWithSignature("mulDiv(uint256,uint256,uint256,uint8)", 7, 2, 3, i), "");
            failed(
                address(ops),
                abi.encodeWithSignature("mulDiv(int256,int256,int256,uint8)", int256(-7), int256(2), int256(3), i),
                ""
            );
        }
    }

    function test_O37_FundedCodeLessAccount() public {
        address a = address(0xbeef1234);
        assertEq(ops.codeHash(a), bytes32(0));
        vm.deal(a, 1);
        assertEq(a.code.length, 0);
        assertEq(ops.codeHash(a), keccak256(""));
        assertEq(ops.codeHash(address(host)), keccak256(address(host).code));
    }

    function test_O51_OpenZeppelinCombinerAndFoldProof() public view {
        bytes32 leaf = keccak256("leaf");
        bytes32[] memory proof = new bytes32[](4);
        proof[0] = keccak256("b");
        proof[1] = leaf;
        proof[2] = keccak256("a");
        proof[3] = proof[2];
        bytes32 expected = MerkleProof.processProof(proof, leaf);
        bytes memory packed;
        for (uint256 i; i < proof.length; i++) {
            packed = bytes.concat(packed, proof[i]);
        }
        uint256[] memory offsets = new uint256[](1);
        offsets[0] = 36;
        assertEq(
            col.fold(
                Collections.FoldDomain.Words,
                0,
                packed,
                address(ops),
                abi.encodeCall(ops.hashPairSorted, (bytes32(0), bytes32(0))),
                4,
                offsets,
                leaf,
                Collections.FoldExit.Full
            ),
            expected
        );
        bytes32[] memory one = new bytes32[](1);
        one[0] = proof[0];
        assertEq(ops.hashPairSorted(leaf, proof[0]), MerkleProof.processProof(one, leaf));
        assertEq(ops.hashPairSorted(proof[0], leaf), MerkleProof.processProof(one, leaf));
    }

    function decimalError(uint256 p, bytes1 c) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(Operations.InvalidDecimalDigit.selector, p, c);
    }

    function test_O63_ParseIntGrammarAndExactErrors() public view {
        assertEq(ops.parseInt("+00012"), 12);
        assertEq(ops.parseInt("-00012"), -12);
        assertEq(ops.parseInt("-0"), 0);
        string[3] memory empty = [string(""), "+", "-"];
        for (uint256 i; i < 3; i++) {
            failed(
                address(ops),
                abi.encodeCall(ops.parseInt, (bytes(empty[i]))),
                abi.encodeWithSelector(Operations.EmptyNumber.selector)
            );
        }
        failed(address(ops), abi.encodeCall(ops.parseInt, (bytes("12x3"))), decimalError(2, "x"));
        failed(address(ops), abi.encodeCall(ops.parseInt, (bytes(" 1"))), decimalError(0, " "));
        assertEq(
            ops.parseInt("-57896044618658097711785492504343953926634992332820282019728792003956564819968"),
            type(int256).min
        );
        failed(
            address(ops),
            abi.encodeCall(
                ops.parseInt, (bytes("57896044618658097711785492504343953926634992332820282019728792003956564819968"))
            ),
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
    }

    function test_O64_ExactSignedCanonicalStrings() public view {
        assertEq(ops.toString(int256(0)), "0");
        assertEq(ops.toString(int256(12)), "12");
        assertEq(ops.toString(int256(-120)), "-120");
        assertEq(
            ops.toString(type(int256).min),
            "-57896044618658097711785492504343953926634992332820282019728792003956564819968"
        );
        assertEq(
            ops.toString(type(int256).max),
            "57896044618658097711785492504343953926634992332820282019728792003956564819967"
        );
    }

    function test_O65_UnitsGrammarExactErrorsAndOverflow() public view {
        assertEq(ops.parseUnits("+.1", 2, Operations.Rounding.Trunc), 10);
        assertEq(ops.parseUnits("1.", 2, Operations.Rounding.Trunc), 100);
        string[5] memory empty = [string(""), "+", "-", ".", "+."];
        for (uint256 i; i < 5; i++) {
            failed(
                address(ops),
                abi.encodeCall(ops.parseUnits, (bytes(empty[i]), 2, Operations.Rounding.Trunc)),
                abi.encodeWithSelector(Operations.EmptyNumber.selector)
            );
        }
        failed(
            address(ops),
            abi.encodeCall(ops.parseUnits, (bytes("1..2"), 2, Operations.Rounding.Trunc)),
            decimalError(2, ".")
        );
        failed(
            address(ops),
            abi.encodeCall(ops.parseUnits, (bytes("1e2"), 2, Operations.Rounding.Trunc)),
            decimalError(1, "e")
        );
        failed(
            address(ops),
            abi.encodeCall(ops.parseUnits, (bytes("1"), 78, Operations.Rounding.Trunc)),
            abi.encodeWithSelector(Operations.InvalidPrecision.selector, 78)
        );
        assertEq(ops.parseUnits("0", 77, Operations.Rounding.Trunc), 0);
        failed(
            address(ops),
            abi.encodeCall(ops.parseUnits, (bytes("6"), 77, Operations.Rounding.Trunc)),
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
    }

    function test_O67_UnsignedSignsAndBounds() public view {
        assertEq(ops.parseUnitsUnsigned("+12", 0, Operations.Rounding.Trunc), 12);
        failed(
            address(ops),
            abi.encodeCall(ops.parseUnitsUnsigned, (bytes("-0"), 0, Operations.Rounding.Trunc)),
            decimalError(0, "-")
        );
        failed(
            address(ops),
            abi.encodeCall(ops.parseUnitsUnsigned, (bytes("-1"), 0, Operations.Rounding.Trunc)),
            decimalError(0, "-")
        );
        assertEq(
            ops.parseUnitsUnsigned(
                "115792089237316195423570985008687907853269984665640564039457584007913129639935",
                0,
                Operations.Rounding.Trunc
            ),
            type(uint256).max
        );
        failed(
            address(ops),
            abi.encodeCall(
                ops.parseUnitsUnsigned,
                (
                    bytes("115792089237316195423570985008687907853269984665640564039457584007913129639936"),
                    0,
                    Operations.Rounding.Trunc
                )
            ),
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
    }

    function test_O68_CanonicalUnsignedUnitFormatting() public view {
        assertEq(ops.formatUnits(uint256(1500), 3), "1.5");
        assertEq(ops.formatUnits(uint256(1000), 3), "1");
        assertEq(ops.formatUnits(uint256(1), 3), "0.001");
        assertEq(ops.formatUnits(uint256(0), 77), "0");
        assertEq(ops.formatUnits(uint256(123), 0), "123");
        failed(
            address(ops),
            abi.encodeWithSignature("formatUnits(uint256,uint256)", 1, 78),
            abi.encodeWithSelector(Operations.InvalidPrecision.selector, 78)
        );
    }

    function test_L33_ExactWordFoldCallbackFailureMatrix() public view {
        uint256[] memory offsets = new uint256[](0);
        bytes memory template = abi.encodeCall(host.reply, (uint256(0)));
        for (uint256 mode = 1; mode <= 5; mode++) {
            bytes memory data = abi.encodeCall(
                col.fold,
                (
                    Collections.FoldDomain.Range,
                    uint256(1),
                    "",
                    address(host),
                    template,
                    uint256(4),
                    offsets,
                    bytes32(mode),
                    Collections.FoldExit.Full
                )
            );
            if (mode == 1) {
                failed(
                    address(col),
                    data,
                    abi.encodeWithSelector(
                        Collections.CallbackFailed.selector,
                        Collections.fold.selector,
                        uint256(0),
                        uint256(0),
                        address(host),
                        abi.encodeCall(host.reply, (mode)),
                        abi.encodeWithSignature("Error(string)", "ordinary")
                    )
                );
            } else if (mode == 2 || mode == 3) {
                failed(
                    address(col),
                    data,
                    abi.encodeWithSelector(
                        AbiCodec.InvalidCallbackResult.selector,
                        Collections.fold.selector,
                        uint256(0),
                        uint256(0),
                        address(host)
                    )
                );
            } else {
                (bool ok, bytes memory result) = address(col).staticcall(data);
                assertTrue(ok);
                assertEq(abi.decode(result, (bytes32)), bytes32(mode == 4 ? uint256(2) : uint256(0)));
            }
        }
    }

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

    function evaluateRaw(RawExpression memory e) internal view returns (bool, bytes memory) {
        return address(graph)
            .staticcall(
                abi.encodeWithSignature(
                    "evaluate((address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256),bytes[])",
                    e,
                    new bytes[](0)
                )
            );
    }

    function test_E7_UnreachableDescriptorFailsBeforeCalls() public {
        RawExpression memory e;
        e.core = address(core);
        e.nodes = new RawNode[](2);
        e.nodes[0] = RawNode(
            2,
            "uint256",
            abi.encode(callParam(address(host), abi.encodeCall(host.zero, ()))),
            new uint256[](0),
            bytes4(0),
            ""
        );
        e.nodes[1] = RawNode(0, "uint8[0]", abi.encode(uint256(0)), new uint256[](0), bytes4(0), "");
        vm.expectCall(address(host), abi.encodeCall(host.zero, ()), uint64(0));
        (bool ok, bytes memory out) = evaluateRaw(e);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(7)));
    }

    function test_E25_ResolveDecoderBareRevert() public view {
        RawExpression memory e;
        e.core = address(core);
        e.nodes = new RawNode[](1);
        e.nodes[0] = RawNode(2, "uint256", hex"01", new uint256[](0), bytes4(0), "");
        (bool ok, bytes memory out) = evaluateRaw(e);
        assertFalse(ok);
        assertEq(out, "");
    }

    /**
     * @dev The calldata `evaluateEncoded` forwards to `evaluate`: the two-word
     *      head, the encoded parameters, then the payload after its leading
     *      offset word
     */
    function forwarded(bytes memory payload, bytes[] memory parameters) internal pure returns (bytes memory) {
        uint256 first;
        assembly ("memory-safe") { first := mload(add(payload, 32)) }
        bytes memory body = new bytes(payload.length - 32);
        for (uint256 i; i < body.length; i++) {
            body[i] = payload[i + 32];
        }
        bytes memory tail = abi.encode(parameters);
        bytes memory params = new bytes(tail.length - 32);
        for (uint256 i; i < params.length; i++) {
            params[i] = tail[i + 32];
        }
        return
            bytes.concat(
                Expressions.evaluate.selector, bytes32(tail.length + first), bytes32(uint256(64)), params, body
            );
    }

    function test_E38_EncodedPayloadFailsWhereItIsRead() public view {
        bytes[] memory none = new bytes[](0);
        // shorter than the leading offset word, or an offset outside the payload: nothing to forward
        failed(address(graph), abi.encodeCall(graph.evaluateEncoded, (hex"01", none)), "");
        failed(address(graph), abi.encodeCall(graph.evaluateEncoded, (abi.encode(uint256(1024)), none)), "");
        failed(address(graph), abi.encodeCall(graph.evaluateEncoded, (abi.encode(uint256(0)), none)), "");
        failed(address(graph), abi.encodeCall(graph.evaluateEncoded, (abi.encode(uint256(31), uint256(0)), none)), "");
        // a nodes offset that points nowhere fails inside the self-call, wrapped with the forwarded calldata
        bytes memory payload = abi.encode(uint256(32), address(core), uint256(1024), uint256(0));
        failed(
            address(graph),
            abi.encodeCall(graph.evaluateEncoded, (payload, none)),
            abi.encodeWithSelector(
                Expressions.NodeCallFailed.selector, uint256(0), address(graph), forwarded(payload, none), bytes("")
            )
        );
    }

    /**
     * @dev The payload alone determines the graph. A payload holding no nodes,
     *      whose nodes offset points past its own end, cannot make `evaluate`
     *      read a node list out of the parameters: they sit before the payload
     *      in the forwarded calldata, and ABI offsets only point forward.
     */
    function test_E36_PayloadCannotReadItsGraphFromTheParameters() public view {
        Expressions.Node[] memory planted = new Expressions.Node[](1);
        planted[0].kind = Expressions.Kind.Literal;
        planted[0].valueType = "uint256";
        planted[0].data = abi.encode(uint256(0xdead));
        bytes[] memory parameters = new bytes[](1);
        parameters[0] = abi.encode(planted);
        // Every nodes offset from the end of the payload onwards, well past where the
        // parameters would sit if they followed it.
        for (uint256 offset = 96; offset <= 96 + 32 * 12; offset += 32) {
            bytes memory payload = abi.encode(uint256(32), address(core), offset, uint256(0));
            (bool ok, bytes memory out) =
                address(graph).staticcall(abi.encodeCall(graph.evaluateEncoded, (payload, parameters)));
            assertFalse(ok);
            assertEq(bytes4(out), Expressions.NodeCallFailed.selector);
        }
        // The same graph placed inside the payload evaluates.
        Expressions.Expression memory e;
        e.core = address(core);
        e.nodes = planted;
        (bool fine, bytes memory value) =
            address(graph).staticcall(abi.encodeCall(graph.evaluateEncoded, (abi.encode(e), parameters)));
        assertTrue(fine);
        assertEq(value, abi.encode(uint256(0xdead)));
    }

    /**
     * @dev A bad reference is reported before an out-of-range kind on the same node
     */
    function test_E1_BadReferencePrecedesInvalidKind() public view {
        RawExpression memory e;
        e.core = address(core);
        e.nodes = new RawNode[](1);
        uint256[] memory refs = new uint256[](1);
        refs[0] = 5;
        e.nodes[0] = RawNode(99, "uint256", "", refs, bytes4(0), "");
        (bool ok, bytes memory out) = evaluateRaw(e);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(0), uint256(5)));
    }

    /**
     * @dev A node nothing reaches may carry any `data` length word, even an
     *      impossible one: evaluation never reads it, so the result stands
     */
    function testFuzz_E38_UnreadNodeDataCannotChangeTheResult(bytes32 length) public view {
        bytes32 mark = keccak256("unread node data");
        Expressions.Expression memory e;
        e.core = address(core);
        e.nodes = new Expressions.Node[](2);
        e.nodes[0].kind = Expressions.Kind.Literal;
        e.nodes[0].valueType = "uint256";
        e.nodes[0].data = abi.encode(uint256(7));
        e.nodes[1].kind = Expressions.Kind.Literal;
        e.nodes[1].valueType = "bytes32";
        e.nodes[1].data = abi.encode(mark);
        bytes memory payload = abi.encode(e);
        // The word before the marker is the unread node's data length.
        uint256 at = type(uint256).max;
        for (uint256 i = 32; i + 32 <= payload.length; i += 32) {
            bytes32 w;
            assembly ("memory-safe") { w := mload(add(add(payload, 32), i)) }
            if (w == mark) at = i - 32;
        }
        assertTrue(at != type(uint256).max);
        assembly ("memory-safe") { mstore(add(add(payload, 32), at), length) }
        (bool ok, bytes memory out) =
            address(graph).staticcall(abi.encodeCall(graph.evaluateEncoded, (payload, new bytes[](0))));
        assertTrue(ok);
        assertEq(out, abi.encode(uint256(7)));
    }

    function test_E39_InvalidKindBareRevert() public view {
        RawExpression memory e;
        e.core = address(core);
        e.nodes = new RawNode[](1);
        for (uint256 i = 11; i <= 255; i++) {
            e.nodes[0] = RawNode(uint8(i), "uint256", abi.encode(uint256(0)), new uint256[](0), bytes4(0), "");
            (bool ok, bytes memory out) = evaluateRaw(e);
            assertFalse(ok);
            assertEq(out, "");
        }
    }

    function test_L33_ExactPredicateCallbackFailureMatrix() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(1));
        Collections.Callback memory cb;
        cb.target = address(host);
        cb.selector = host.reply.selector;
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
        for (uint256 mode = 1; mode <= 5; mode++) {
            values[0] = abi.encode(mode);
            bytes memory data = abi.encodeCall(col.filterValues, ("uint256", values, cb));
            if (mode == 1) {
                failed(
                    address(col),
                    data,
                    abi.encodeWithSelector(
                        Collections.CallbackFailed.selector,
                        Collections.filterValues.selector,
                        uint256(0),
                        uint256(0),
                        address(host),
                        abi.encodeCall(host.reply, (mode)),
                        abi.encodeWithSignature("Error(string)", "ordinary")
                    )
                );
            } else if (mode < 5) {
                failed(
                    address(col),
                    data,
                    abi.encodeWithSelector(
                        AbiCodec.InvalidCallbackResult.selector,
                        Collections.filterValues.selector,
                        uint256(0),
                        uint256(0),
                        address(host)
                    )
                );
            } else {
                assertEq(col.filterValues("uint256", values, cb).length, 0);
            }
        }
        cb.target = address(0xdead);
        failed(
            address(col),
            abi.encodeCall(col.filterValues, ("uint256", values, cb)),
            abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0xdead))
        );
    }
}
