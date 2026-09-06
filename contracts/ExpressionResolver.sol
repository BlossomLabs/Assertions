// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AbiCodec} from "./AbiCodec.sol";
import {Assertions} from "./Assertions.sol";
import {InputParam} from "./ERC8211.sol";

/// @notice Stateless typed expression graphs and resolve-once ABI call construction.
contract ExpressionResolver {
    enum Kind {
        Literal,
        Parameter,
        Resolve,
        Call,
        Select,
        Wrap,
        Array,
        Tuple,
        TryOrElse,
        IsValid,
        ProbeCall
    }

    struct Node {
        Kind kind;
        string valueType;
        bytes data;
        uint256[] refs;
        bytes4 selector;
        string arguments;
    }

    struct Program {
        address core;
        Node[] nodes;
        uint256 result;
    }

    struct Cache {
        bytes[] values;
        bool[] ready;
    }
    error InvalidNode(uint256 node);
    error InvalidReference(uint256 node, uint256 ref);
    error InvalidTarget(uint256 node, address target);
    error CallFailed(uint256 node, address target, bytes callData, bytes reason);

    /// @notice Resolve each supplied operand once, ABI-encode all arguments, and return raw returndata.
    /// @dev Sources must resolve to single-value canonical ABI envelopes matching argumentTypes.
    function resolveCall(
        address core,
        InputParam calldata target,
        bytes4 selector,
        string calldata argumentTypes,
        InputParam[] calldata args
    ) external view {
        bytes memory destination = _call(core, abi.encodeCall(Assertions.resolve, (target)), 0);
        address to = _address(destination, 0);
        bytes[] memory values = new bytes[](args.length);
        for (uint256 i; i < args.length; i++) {
            values[i] = _call(core, abi.encodeCall(Assertions.resolve, (args[i])), i + 1);
        }
        bytes memory result = _call(to, bytes.concat(selector, _arguments(argumentTypes, values)), args.length + 1);
        assembly ("memory-safe") { return(add(result, 32), mload(result)) }
    }

    /// @notice Resolve each argument once and return the canonical argument tuple without a bytes envelope.
    function resolveArguments(address core, string calldata argumentTypes, InputParam[] calldata args) external view {
        bytes[] memory values = new bytes[](args.length);
        for (uint256 i; i < args.length; i++) {
            values[i] = _call(core, abi.encodeCall(Assertions.resolve, (args[i])), i);
        }
        bytes memory result = _arguments(argumentTypes, values);
        assembly ("memory-safe") { return(add(result, 32), mload(result)) }
    }

    /// @notice Resolve each source once and wrap its raw result as a bytes-array element.
    function resolveValues(address core, InputParam[] calldata args) external view returns (bytes[] memory values) {
        values = new bytes[](args.length);
        for (uint256 i; i < args.length; i++) {
            values[i] = _call(core, abi.encodeCall(Assertions.resolve, (args[i])), i);
        }
    }

    /// @notice Evaluate a backwards-referencing graph, resolving shared nodes only once.
    /// @dev Select is lazy. Only reachable nodes execute. Parameters are canonical single-value envelopes.
    function evaluate(Program calldata program, bytes[] calldata parameters) external view {
        if (program.result >= program.nodes.length) revert InvalidNode(program.result);
        for (uint256 i; i < program.nodes.length; i++) {
            Node calldata node = program.nodes[i];
            AbiCodec.shape(bytes(node.valueType));
            for (uint256 j; j < node.refs.length; j++) {
                if (node.refs[j] >= i) revert InvalidReference(i, node.refs[j]);
            }
            if (node.kind == Kind.Call) {
                if (node.refs.length == 0) revert InvalidNode(i);
            } else if (node.kind == Kind.Select) {
                if (node.refs.length != 3) revert InvalidNode(i);
            } else if (node.kind == Kind.TryOrElse || node.kind == Kind.ProbeCall) {
                if (node.refs.length != 2) revert InvalidNode(i);
            } else if (node.kind == Kind.Wrap || node.kind == Kind.IsValid) {
                if (node.refs.length != 1) revert InvalidNode(i);
            } else if (node.kind != Kind.Array && node.kind != Kind.Tuple && node.refs.length != 0) {
                revert InvalidNode(i);
            }
        }
        Cache memory cache = Cache(new bytes[](program.nodes.length), new bool[](program.nodes.length));
        bytes memory result = _evaluate(program, parameters, cache, program.result);
        assembly ("memory-safe") { return(add(result, 32), mload(result)) }
    }

    function _evaluate(Program calldata p, bytes[] calldata parameters, Cache memory cache, uint256 index)
        private
        view
        returns (bytes memory result)
    {
        if (cache.ready[index]) return cache.values[index];
        Node calldata node = p.nodes[index];
        if (node.kind == Kind.Literal) {
            result = node.data;
        } else if (node.kind == Kind.Parameter) {
            if (node.data.length != 32) revert InvalidNode(index);
            uint256 parameter = abi.decode(node.data, (uint256));
            if (parameter >= parameters.length) revert InvalidReference(index, parameter);
            result = parameters[parameter];
        } else if (node.kind == Kind.Resolve) {
            InputParam memory source = abi.decode(node.data, (InputParam));
            result = _call(p.core, abi.encodeCall(Assertions.resolve, (source)), index);
        } else if (node.kind == Kind.Select) {
            bytes memory condition = _evaluate(p, parameters, cache, node.refs[0]);
            if (condition.length != 32 || AbiCodec.word(condition, 0) > 1) revert InvalidNode(index);
            result = _evaluate(p, parameters, cache, node.refs[AbiCodec.word(condition, 0) == 1 ? 1 : 2]);
        } else if (node.kind == Kind.TryOrElse || node.kind == Kind.IsValid) {
            (bool success, bytes memory attempted) = _tryEvaluate(p, parameters, cache, node.refs[0]);
            if (node.kind == Kind.IsValid) result = abi.encode(success);
            else result = success ? attempted : _evaluate(p, parameters, cache, node.refs[1]);
        } else if (node.kind == Kind.ProbeCall) {
            address target = _address(_evaluate(p, parameters, cache, node.refs[0]), index);
            bytes memory callData = abi.decode(_evaluate(p, parameters, cache, node.refs[1]), (bytes));
            result = abi.encode(_probe(target, callData, node.selector));
        } else if (node.kind == Kind.Wrap) {
            result = abi.encode(_evaluate(p, parameters, cache, node.refs[0]));
        } else if (node.kind == Kind.Array || node.kind == Kind.Tuple) {
            bytes[] memory values = new bytes[](node.refs.length);
            for (uint256 i; i < values.length; i++) {
                values[i] = _evaluate(p, parameters, cache, node.refs[i]);
            }
            if (node.kind == Kind.Array) {
                result = AbiCodec.pack(bytes(node.arguments), values);
            } else {
                result = _arguments(node.arguments, values);
                (bool dynamic,) = AbiCodec.shape(bytes(node.arguments));
                if (dynamic) result = bytes.concat(abi.encode(uint256(32)), result);
            }
        } else {
            address target = _address(_evaluate(p, parameters, cache, node.refs[0]), index);
            bytes[] memory args = new bytes[](node.refs.length - 1);
            for (uint256 i; i < args.length; i++) {
                args[i] = _evaluate(p, parameters, cache, node.refs[i + 1]);
            }
            result = _call(target, bytes.concat(node.selector, _arguments(node.arguments, args)), index);
        }
        AbiCodec.validate(bytes(node.valueType), result);
        cache.values[index] = result;
        cache.ready[index] = true;
    }

    /// @dev External self-frame gives guarded evaluation EVM rollback; callers cannot inject caches.
    function evaluateGuarded(
        Program calldata program,
        bytes[] calldata parameters,
        uint256 index,
        Cache calldata initial
    ) external view returns (bytes memory result, Cache memory updated) {
        if (msg.sender != address(this)) revert InvalidNode(index);
        updated = initial;
        result = _evaluate(program, parameters, updated, index);
    }

    function _tryEvaluate(Program calldata program, bytes[] calldata parameters, Cache memory cache, uint256 index)
        private
        view
        returns (bool success, bytes memory result)
    {
        try this.evaluateGuarded(program, parameters, index, cache) returns (bytes memory value, Cache memory updated) {
            cache.values = updated.values;
            cache.ready = updated.ready;
            return (true, value);
        } catch {
            return (false, "");
        }
    }

    /// @notice Bytes-program entry for collection callbacks; returns the same raw value as evaluate.
    function evaluateEncoded(bytes calldata program, bytes[] calldata parameters) external view {
        Program memory decoded = abi.decode(program, (Program));
        bytes memory result = _call(address(this), abi.encodeCall(this.evaluate, (decoded, parameters)), 0);
        assembly ("memory-safe") { return(add(result, 32), mload(result)) }
    }

    function _arguments(string calldata types, bytes[] memory values) private pure returns (bytes memory) {
        if (bytes(types).length == 2 && bytes(types)[0] == "(" && bytes(types)[1] == ")" && values.length == 0) {
            return "";
        }
        return AbiCodec.tuple(bytes(types), values);
    }

    function _probe(address target, bytes memory callData, bytes4 expected) private view returns (bytes memory reason) {
        if (target.code.length == 0) {
            if (expected != bytes4(0)) revert Assertions.UnexpectedRevertData(expected, bytes4(0));
            return "";
        }
        bool success;
        (success, reason) = target.staticcall(callData);
        if (success) revert Assertions.DidNotRevert(target, callData);
        if (expected == bytes4(0)) return reason;
        bytes4 actual;
        if (reason.length >= 4) {
            assembly ("memory-safe") { actual := mload(add(reason, 32)) }
        }
        if (actual != expected) revert Assertions.UnexpectedRevertData(expected, actual);
        return AbiCodec.slice(reason, 4, reason.length - 4);
    }

    function _address(bytes memory value, uint256 index) private pure returns (address) {
        if (value.length != 32 || AbiCodec.word(value, 0) > type(uint160).max) revert InvalidNode(index);
        return address(uint160(AbiCodec.word(value, 0)));
    }

    function _call(address target, bytes memory data, uint256 index) private view returns (bytes memory result) {
        if (target.code.length == 0) revert InvalidTarget(index, target);
        bool ok;
        (ok, result) = target.staticcall(data);
        if (!ok) revert CallFailed(index, target, data, result);
    }
}
