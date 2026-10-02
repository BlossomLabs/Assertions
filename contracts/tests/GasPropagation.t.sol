// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";
import "../Collections.sol";
import "../Expressions.sol";

contract GasPropagationTarget {
    error Ordinary(uint256 value);

    function work(uint256) external pure returns (uint256) {
        bytes32 acc;
        for (uint256 i; i < 6000; i++) {
            acc = keccak256(abi.encode(acc, i));
        }
        return acc == bytes32(0) ? 0 : 1;
    }

    function fail(uint256 mode) external pure returns (uint256) {
        if (mode == 0) assembly { revert(0, 0) }
        if (mode == 1) revert Ordinary(7);
        bytes memory reason = abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
        if (mode == 3) reason = bytes.concat(reason, abi.encode(uint256(7)));
        assembly { revert(add(reason, 32), mload(reason)) }
    }
}

/**
 * @notice Gas exhaustion cannot become an accepted failure across toolkit wrappers.
 * @dev Every graph and operand is called through an explicit gas boundary. These
 *      tests complement symbolic properties, whose gasleft has no concrete model.
 */
contract GasPropagationTest is Test {
    Assertions core;
    Operations ops;
    Collections collections;
    Expressions expressions;
    GasPropagationTarget target;

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
        collections = new Collections();
        expressions = new Expressions();
        target = new GasPropagationTarget();
    }

    function operand(address a, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(a, data), new Constraint[](0)
        );
    }

    function literal(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function node(Expressions.Kind kind, string memory t, bytes memory data, uint256[] memory refs)
        internal
        pure
        returns (Expressions.Node memory)
    {
        return Expressions.Node(kind, t, data, refs, bytes4(0), "");
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

    function callback(bytes4 selector, bool graph) internal view returns (Collections.Callback memory cb) {
        cb.target = graph ? address(expressions) : address(target);
        cb.selector = selector;
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
        cb.constants[0] = abi.encode(uint256(0));
        if (graph) {
            Expressions.Node[] memory nodes = new Expressions.Node[](3);
            nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(target)), new uint256[](0));
            nodes[1] = node(Expressions.Kind.Parameter, "uint256", abi.encode(uint256(0)), new uint256[](0));
            nodes[2] = node(Expressions.Kind.Call, "uint256", "", refs2(0, 1));
            nodes[2].selector = selector;
            nodes[2].arguments = "(uint256)";
            cb.expression = abi.encode(Expressions.Expression(address(core), nodes, 2));
        }
    }

    // 0 direct, 1 rawCall, 2 word, 3 values, 4 expression callback, 5 nested rawCall/core.
    function attempt(uint256 route, bytes4 selector, uint256 value)
        internal
        view
        returns (InputParam memory p, string memory valueType)
    {
        bytes memory data = abi.encodeWithSelector(selector, value);
        if (route == 0) return (operand(address(target), data), "uint256");
        if (route == 1) {
            return (operand(address(ops), abi.encodeCall(Operations.rawCall, (address(target), data))), "bytes");
        }
        if (route == 2) {
            return (
                operand(
                    address(collections),
                    abi.encodeCall(Collections.mapWords, (abi.encode(value), address(target), data, new uint256[](0)))
                ),
                "bytes"
            );
        }
        if (route == 5) {
            InputParam memory inner = operand(address(target), data);
            return (
                operand(
                    address(ops),
                    abi.encodeCall(Operations.rawCall, (address(core), abi.encodeCall(Assertions.resolve, (inner))))
                ),
                "bytes"
            );
        }
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(value);
        return (
            operand(
                address(collections),
                abi.encodeCall(Collections.mapValues, ("uint256", "uint256", values, callback(selector, route == 4)))
            ),
            "bytes[]"
        );
    }

    function graphProbe(InputParam memory p, string memory valueType, uint256 probe)
        internal
        view
        returns (bytes memory)
    {
        Expressions.Node[] memory nodes;
        if (probe == 2) {
            (address to, bytes memory data) = abi.decode(p.paramData, (address, bytes));
            nodes = new Expressions.Node[](3);
            nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(to), new uint256[](0));
            nodes[1] = node(Expressions.Kind.Literal, "bytes", abi.encode(data), new uint256[](0));
            nodes[2] = node(Expressions.Kind.ProbeCall, "bytes", "", refs2(0, 1));
        } else {
            nodes = new Expressions.Node[](probe == 0 ? 2 : 4);
            nodes[0] = node(Expressions.Kind.Resolve, valueType, abi.encode(p), new uint256[](0));
            if (probe == 0) {
                nodes[1] = node(Expressions.Kind.IsValid, "bool", "", refs1(0));
            } else {
                nodes[1] = node(Expressions.Kind.Wrap, "bytes", "", refs1(0));
                nodes[2] = node(Expressions.Kind.Literal, "bytes", abi.encode(bytes("fallback")), new uint256[](0));
                nodes[3] = node(Expressions.Kind.TryOrElse, "bytes", "", refs2(1, 2));
            }
        }
        return abi.encodeCall(
            Expressions.evaluate, (Expressions.Expression(address(core), nodes, nodes.length - 1), new bytes[](0))
        );
    }

    function coreProbe(InputParam memory p, uint256 probe) internal pure returns (bytes memory) {
        if (probe == 0) return abi.encodeCall(Assertions.isValid, (p));
        if (probe == 1) return abi.encodeCall(Assertions.orElse, (p, literal(hex"deadbeef")));
        return abi.encodeCall(Assertions.revertData, (p, bytes4(0)));
    }

    function checkRoute(uint256 route, bool graph, bool sweep) internal view {
        (InputParam memory p, string memory t) = attempt(route, GasPropagationTarget.work.selector, 0);
        (bool resolved, bytes memory expected) =
            address(core).staticcall{gas: 5_000_000}(abi.encodeCall(Assertions.resolve, (p)));
        assertTrue(resolved, "generous gas must cover workload");
        for (uint256 probe; probe < 3; probe++) {
            bytes memory data = graph ? graphProbe(p, t, probe) : coreProbe(p, probe);
            address host = graph ? address(expressions) : address(core);
            (bool hi, bytes memory high) = host.staticcall{gas: 5_000_000}(data);
            if (probe == 2) {
                assertFalse(hi);
                (address to, bytes memory callData) = abi.decode(p.paramData, (address, bytes));
                assertEq(high, abi.encodeWithSelector(Assertions.DidNotRevert.selector, to, callData));
            } else {
                assertTrue(hi);
                assertEq(high, probe == 0 ? abi.encode(uint256(1)) : graph ? abi.encode(expected) : expected);
            }
            uint256 start = sweep ? 100_000 : 1_000_000;
            uint256 end = sweep ? 3_000_000 : 1_000_000;
            for (uint256 gasLimit = start; gasLimit <= end; gasLimit += 50_000) {
                (bool ok, bytes memory out) = host.staticcall{gas: gasLimit}(data);
                if (ok) {
                    assertLt(probe, 2, "exhaustion accepted as revert data");
                    assertEq(out, high, "gas selected false validity or fallback");
                    assertTrue(sweep, "tight gas must refuse workload");
                } else {
                    assertTrue(
                        out.length == 0
                            || keccak256(out) == keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector))
                            || (probe == 2 && keccak256(out) == keccak256(high)),
                        "unexpected failure"
                    );
                }
            }
        }
        // Full failure assertion: neither ample nor squeezed gas may satisfy EQ 0.
        InputParam memory judged = operand(address(core), abi.encodeCall(Assertions.isValid, (p)));
        judged.constraints = new Constraint[](1);
        judged.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(0)));
        bytes memory judge = abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", judged);
        (bool success, bytes memory reason) = address(core).staticcall{gas: 5_000_000}(judge);
        assertFalse(success);
        assertEq(bytes4(reason), ConstraintFailed.selector);
        (success, reason) = address(core).staticcall{gas: 1_000_000}(judge);
        assertFalse(success, "gas alone satisfied failure assertion");
        assertEq(reason, abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
    }

    function test_directAndRawCallGasSweeps() public view {
        for (uint256 route; route < 2; route++) {
            for (uint256 graph; graph < 2; graph++) {
                checkRoute(route, graph == 1, true);
            }
        }
    }

    function test_wordCallbackGasSweeps() public view {
        checkRoute(2, false, true);
        checkRoute(2, true, true);
    }

    function test_valueCallbackGasSweeps() public view {
        checkRoute(3, false, true);
        checkRoute(3, true, true);
    }

    function test_expressionCallbackGasSweeps() public view {
        checkRoute(4, false, true);
        checkRoute(4, true, true);
    }

    function test_nestedCoreRawCallGasSweeps() public view {
        checkRoute(5, false, true);
        checkRoute(5, true, true);
    }

    function test_exactSignalSurvivesEveryWrapperAndProbe() public view {
        assertEq(Operations.SubcallOutOfGas.selector, Assertions.SubcallOutOfGas.selector);
        assertEq(Collections.SubcallOutOfGas.selector, Assertions.SubcallOutOfGas.selector);
        assertEq(Expressions.SubcallOutOfGas.selector, Assertions.SubcallOutOfGas.selector);
        for (uint256 route; route < 6; route++) {
            (InputParam memory p, string memory t) = attempt(route, GasPropagationTarget.fail.selector, 2);
            for (uint256 probe; probe < 3; probe++) {
                (bool ok, bytes memory out) = address(core).staticcall(coreProbe(p, probe));
                assertFalse(ok);
                assertEq(out, abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
                (ok, out) = address(expressions).staticcall(graphProbe(p, t, probe));
                assertFalse(ok);
                assertEq(out, abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
            }
        }
    }

    function test_ordinaryErrorsKeepExactWrappers() public view {
        for (uint256 mode; mode < 4; mode++) {
            if (mode == 2) continue;
            bytes memory data = abi.encodeCall(GasPropagationTarget.fail, (mode));
            bytes memory reason = mode == 0
                ? bytes("")
                : mode == 1
                    ? abi.encodeWithSelector(GasPropagationTarget.Ordinary.selector, uint256(7))
                    : abi.encodePacked(Assertions.SubcallOutOfGas.selector, uint256(7));
            for (uint256 route = 1; route < 4; route++) {
                (InputParam memory p,) = attempt(route, GasPropagationTarget.fail.selector, mode);
                (address to, bytes memory callData) = abi.decode(p.paramData, (address, bytes));
                (bool ok, bytes memory out) = to.staticcall(callData);
                assertFalse(ok);
                bytes memory wanted = route == 1
                    ? abi.encodeWithSelector(Operations.RawCallFailed.selector, address(target), data)
                    : abi.encodeWithSelector(
                        Collections.CallbackFailed.selector,
                        route == 2 ? Collections.mapWords.selector : Collections.mapValues.selector,
                        uint256(0),
                        uint256(0),
                        address(target),
                        data,
                        reason
                    );
                assertEq(out, wanted);
                assertEq(core.isValid(p), 0);
                (ok, out) = address(core).staticcall(coreProbe(p, 1));
                assertTrue(ok);
                assertEq(out, hex"deadbeef");
                (ok, out) = address(core).staticcall(coreProbe(p, 2));
                assertTrue(ok);
                assertEq(out, wanted);
            }
        }
    }
}
