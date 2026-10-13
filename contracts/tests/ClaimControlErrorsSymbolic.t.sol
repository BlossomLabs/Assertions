// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Expressions.sol";
import "../Collections.sol";
import "../Operations.sol";
import "./ClaimConstructionSymbolic.t.sol";

contract ClaimBehaviorReverter {
    function word(bytes32 value) external pure returns (bytes32) {
        return value;
    }

    function fail(bytes calldata reason) external pure {
        assembly ("memory-safe") {
            calldatacopy(0, reason.offset, reason.length)
            revert(0, reason.length)
        }
    }

    function reply(uint256 lane, uint256, uint256 failingLane, uint256 fault, bytes calldata reason)
        external
        pure
        returns (uint256)
    {
        if (lane != failingLane) return 1;
        if (fault == 0) {
            assembly ("memory-safe") {
                calldatacopy(0, reason.offset, reason.length)
                revert(0, reason.length)
            }
        }
        if (fault == 1) assembly ("memory-safe") { return(0, 0) }
        if (fault == 2) {
            assembly ("memory-safe") {
                mstore(0, 1)
                return(0, 31)
            }
        }
        if (fault == 3) {
            assembly ("memory-safe") {
                mstore(0, 1)
                mstore(32, 1)
                return(0, 64)
            }
        }
        if (fault == 4) return 2;
        revert Assertions.SubcallOutOfGas();
    }
}

/**
 * @notice Ordinary control outcomes, complete callback wrappers and raw enum
 *         refusal. Exact reserved-signal cases never exclude their signal path.
 */
contract ClaimControlErrorsSymbolicTest is Test {
    Assertions core;
    Expressions expressions;
    Collections collections;
    Operations operations;
    ClaimBehaviorReverter host;
    ClaimConstructionObserver observer;

    struct RawNode {
        uint256 kind;
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

    function setUp() public {
        core = new Assertions();
        expressions = new Expressions();
        collections = new Collections();
        operations = new Operations();
        host = new ClaimBehaviorReverter();
        observer = new ClaimConstructionObserver();
    }

    function check_behaviorOrElseCallOutcomes(bytes32 word, bytes32 fallbackValue, uint8 shape) public {
        vm.assume(shape < 6);
        vm.warp(1000);
        InputParam memory attempt = raw(abi.encode(word));
        if (shape == 1) {
            attempt = operand(address(host), abi.encodeCall(ClaimBehaviorReverter.fail, (bytes("ordinary"))));
        } else if (shape == 2) {
            attempt = operand(address(0xE0A), bytes(""));
        } else if (shape == 3) {
            attempt.fetcherType = InputParamFetcherType.STATIC_CALL;
            attempt.paramData = hex"01";
        } else if (shape == 4) {
            attempt.constraints = new Constraint[](1);
            attempt.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(word ^ bytes32(uint256(1))));
        } else if (shape == 5) {
            attempt = operand(address(host), abi.encodeCall(ClaimBehaviorReverter.word, (word)));
        }
        InputParam memory fallbackParam =
            operand(address(observer), abi.encodeCall(ClaimConstructionObserver.word, (fallbackValue)));
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.orElse, (attempt, fallbackParam)));
        ordinary(ok, out);
        assertTrue(ok);
        bool success = shape == 0 || shape == 5;
        assertEq(out, abi.encode(success ? word : fallbackValue));
        assertEq(observer.count(), success ? 0 : 1, "fallback is lazy and executes once");
    }

    function check_behaviorExpressionGuardCallOutcomes(
        bytes32 word,
        bytes32 fallbackValue,
        bytes32 reason,
        uint8 lengthCase,
        bool failing,
        bool validity
    ) public view {
        bytes memory failure = reasonBytes(reason, lengthCase);
        vm.assume(keccak256(failure) != keccak256(signal()));
        Expressions.Expression memory e = graph(word, fallbackValue, failure, failing, validity);
        (bool ok, bytes memory out) =
            address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (e, new bytes[](0))));
        ordinary(ok, out);
        assertTrue(ok);
        assertEq(out, validity ? abi.encode(!failing) : abi.encode(failing ? fallbackValue : word));
    }

    function check_behaviorCallbacksExactFailures(
        bytes32 reason,
        uint8 lengthCase,
        uint8 fault,
        bool wordRoute,
        bool late
    ) public view {
        vm.assume(fault < 5);
        bytes memory why = reasonBytes(reason, lengthCase);
        vm.assume(keccak256(why) != keccak256(signal()));
        (bytes memory data, bytes memory expectedCall) = callbackData(why, fault, wordRoute, late);
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        ordinary(ok, out);
        if (wordRoute && fault == 4) {
            assertTrue(ok);
            assertEq(out, abi.encode(late ? uint256(2) : uint256(1)));
        } else {
            assertFalse(ok);
            bytes4 operation = wordRoute ? Collections.foldWords.selector : Collections.filterValues.selector;
            assertEq(
                out,
                fault == 0
                    ? abi.encodeWithSelector(
                        Collections.CallbackFailed.selector,
                        operation,
                        late ? uint256(1) : uint256(0),
                        uint256(0),
                        address(host),
                        expectedCall,
                        why
                    )
                    : abi.encodeWithSelector(
                        AbiCodec.InvalidCallbackResult.selector,
                        operation,
                        late ? uint256(1) : uint256(0),
                        uint256(0),
                        address(host)
                    )
            );
        }
    }

    function check_behaviorReservedSignalAcrossControlRoutes(uint8 route) public view {
        vm.assume(route < 5);
        bytes memory data;
        address target;
        if (route == 0) {
            target = address(core);
            data = abi.encodeCall(
                Assertions.orElse,
                (
                    operand(address(host), abi.encodeCall(ClaimBehaviorReverter.fail, (signal()))),
                    raw(abi.encode(uint256(7)))
                )
            );
        } else if (route < 3) {
            target = address(expressions);
            data = abi.encodeCall(
                Expressions.evaluate,
                (graph(bytes32(0), bytes32(uint256(7)), signal(), true, route == 2), new bytes[](0))
            );
        } else {
            target = address(collections);
            (data,) = callbackData(signal(), 5, route == 3, false);
        }
        (bool ok, bytes memory out) = target.staticcall(data);
        assertFalse(ok);
        assertEq(out, signal());
    }

    function check_behaviorInvalidRoundingWord(uint256 rounding, bool signed) public view {
        vm.assume(rounding > 2);
        bytes memory data = signed
            ? abi.encodeWithSignature("mulDiv(int256,int256,int256,uint8)", int256(-7), int256(2), int256(3), rounding)
            : abi.encodeWithSignature(
                "mulDiv(uint256,uint256,uint256,uint8)", uint256(7), uint256(2), uint256(3), rounding
            );
        (bool ok, bytes memory out) = address(operations).staticcall(data);
        assertFalse(ok);
        assertEq(out, bytes(""));
    }

    function check_behaviorInvalidKindWord(uint256 kind) public view {
        vm.assume(kind > 10);
        RawExpression memory e;
        e.nodes = new RawNode[](1);
        e.nodes[0] = RawNode(kind, "uint256", abi.encode(uint256(7)), new uint256[](0), bytes4(0), "");
        (bool ok, bytes memory out) =
            address(expressions).staticcall(abi.encodeWithSelector(Expressions.evaluate.selector, e, new bytes[](0)));
        assertFalse(ok);
        assertEq(out, bytes(""));
    }

    function callbackData(bytes memory why, uint256 fault, bool wordRoute, bool late)
        internal
        view
        returns (bytes memory data, bytes memory expected)
    {
        uint256 bad = late ? 1 : 0;
        if (wordRoute) {
            uint256[] memory windows = new uint256[](1);
            windows[0] = 4;
            bytes memory template = abi.encodeCall(ClaimBehaviorReverter.reply, (0, 0, bad, fault, why));
            data = abi.encodeCall(
                Collections.foldWords,
                (
                    abi.encode(uint256(0), uint256(1)),
                    address(host),
                    template,
                    36,
                    windows,
                    bytes32(uint256(77)),
                    Collections.FoldExit.Full
                )
            );
            expected = abi.encodeCall(ClaimBehaviorReverter.reply, (bad, late ? 1 : 77, bad, fault, why));
        } else {
            Collections.Callback memory cb;
            cb.target = address(host);
            cb.selector = ClaimBehaviorReverter.reply.selector;
            cb.arguments = "(uint256,uint256,uint256,uint256,bytes)";
            cb.constants = new bytes[](5);
            cb.constants[0] = abi.encode(uint256(0));
            cb.constants[1] = abi.encode(uint256(0));
            cb.constants[2] = abi.encode(bad);
            cb.constants[3] = abi.encode(fault);
            cb.constants[4] = abi.encode(why);
            bytes[] memory values = new bytes[](2);
            values[0] = abi.encode(uint256(0));
            values[1] = abi.encode(uint256(1));
            data = abi.encodeCall(Collections.filterValues, ("uint256", values, cb));
            expected = abi.encodeCall(ClaimBehaviorReverter.reply, (bad, 0, bad, fault, why));
        }
    }

    function graph(bytes32 word, bytes32 fallbackValue, bytes memory why, bool failing, bool validity)
        internal
        view
        returns (Expressions.Expression memory e)
    {
        e.nodes = new Expressions.Node[](5);
        e.result = 4;
        e.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(host)));
        e.nodes[1] =
            node(Expressions.Kind.Literal, failing ? "bytes" : "bytes32", failing ? abi.encode(why) : abi.encode(word));
        e.nodes[2] = node(Expressions.Kind.Call, "uint256", "");
        e.nodes[2].refs = new uint256[](2);
        e.nodes[2].refs[1] = 1;
        e.nodes[2].selector = failing ? ClaimBehaviorReverter.fail.selector : ClaimBehaviorReverter.word.selector;
        e.nodes[2].arguments = failing ? "(bytes)" : "(bytes32)";
        e.nodes[3] = node(Expressions.Kind.Literal, "uint256", abi.encode(fallbackValue));
        e.nodes[4] =
            node(validity ? Expressions.Kind.IsValid : Expressions.Kind.TryOrElse, validity ? "bool" : "uint256", "");
        e.nodes[4].refs = new uint256[](validity ? 1 : 2);
        e.nodes[4].refs[0] = 2;
        if (!validity) e.nodes[4].refs[1] = 3;
    }

    function node(Expressions.Kind k, string memory t, bytes memory data)
        internal
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = k;
        n.valueType = t;
        n.data = data;
        n.refs = new uint256[](0);
    }

    function reasonBytes(bytes32 word, uint8 size) internal pure returns (bytes memory data) {
        vm.assume(size < 5);
        data = abi.encodePacked(word, bytes1(0x7f));
        uint256 n = size == 0 ? 0 : size == 1 ? 3 : size == 2 ? 4 : size == 3 ? 32 : 33;
        assembly ("memory-safe") { mstore(data, n) }
    }

    function signal() internal pure returns (bytes memory) {
        return abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
    }

    function ordinary(bool ok, bytes memory out) internal pure {
        vm.assume(ok || keccak256(out) != keccak256(signal()));
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function operand(address target, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(target, data), new Constraint[](0)
        );
    }

    function test_behaviorControlOutcomeSamples() public {
        for (uint8 i; i < 6; i++) {
            check_behaviorOrElseCallOutcomes(bytes32(0), bytes32(uint256(93)), i);
        }
        for (uint8 i; i < 5; i++) {
            check_behaviorExpressionGuardCallOutcomes(
                bytes32(0), bytes32(uint256(93)), bytes32(uint256(42)), i, true, false
            );
            check_behaviorExpressionGuardCallOutcomes(
                bytes32(0), bytes32(uint256(93)), bytes32(uint256(42)), i, false, true
            );
            check_behaviorReservedSignalAcrossControlRoutes(i);
        }
    }

    function test_behaviorCallbackWrapperSamples() public view {
        for (uint8 i; i < 5; i++) {
            check_behaviorCallbacksExactFailures(bytes32(uint256(42)), 4, i, true, false);
            check_behaviorCallbacksExactFailures(bytes32(uint256(42)), 4, i, true, true);
            check_behaviorCallbacksExactFailures(bytes32(uint256(42)), 4, i, false, false);
            check_behaviorCallbacksExactFailures(bytes32(uint256(42)), 4, i, false, true);
        }
    }

    function test_behaviorRawEnumSamples() public view {
        check_behaviorInvalidRoundingWord(3, false);
        check_behaviorInvalidRoundingWord(type(uint256).max, true);
        check_behaviorInvalidKindWord(11);
        check_behaviorInvalidKindWord(type(uint256).max);
    }
}
