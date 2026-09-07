// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AbiCodec} from "./lib/AbiCodec.sol";
import {Assertions} from "./Assertions.sol";
import {InputParam} from "./lib/ERC8211.sol";

/**
 * @title Expressions
 * @author Sembrestels
 * @notice Typed expression graphs for the Assertions core. A raw ERC-8211
 *         operand is a tree: it cannot name a subterm, so a value used
 *         twice is encoded and resolved twice. An `Expression` is a graph:
 *         nodes reference earlier nodes by index, every node evaluates at
 *         most once per evaluation, and every node's value is validated
 *         against its declared type. Lazy branches (`Select`) and guarded
 *         evaluation (`TryOrElse`, `IsValid`, `ProbeCall`) mirror the
 *         core's `cond`, `orElse`, `isValid` and `revertData` over graph
 *         nodes instead of unresolved operands.
 * @dev Stateless and view-only, like the core. Values are canonical
 *      single-value ABI encodings throughout (see AbiCodec): a Call node's
 *      arguments, a Tuple node's components and an Array node's elements
 *      all arrive that way, and each node's result must be one for its
 *      `valueType`. A graph costs about 10k gas fixed plus 3.5k per node
 *      plus 20k per Call (measured 2026-09-07, ExpressionsGas.t.sol), so
 *      it wins only when the resolutions it saves cost more than that;
 *      `Assertions.get` is the cheaper host for a single call with
 *      several dynamic arguments. Errors identify the node: InvalidNode for
 *      a structural fault, InvalidReference for a reference that is not
 *      strictly backwards (or a parameter index out of range),
 *      InvalidTarget for a code-less call target and NodeCallFailed carrying
 *      the target's revert reason, which the core's own CallFailed does not.
 * @custom:version 1.0
 */
contract Expressions {
    // ============ Types ============

    /**
     * @notice The node kinds of an expression graph
     * @dev ABI-encoded as uint8. What each kind reads from its Node:
     *      Literal (`data` is the value); Parameter (`data` is
     *      abi.encode(uint256 index) into the evaluation's parameters);
     *      Resolve (`data` is abi.encode(InputParam), resolved through the
     *      expression's core); Call (`refs[0]` is the target address word,
     *      `refs[1..]` the arguments encoded as the tuple `arguments`
     *      describes, prefixed by `selector`); Select (`refs` are condition,
     *      then-branch, else-branch); Wrap (`refs[0]`'s value wrapped as a
     *      bytes envelope, abi.encode(bytes)); Array (`refs` are the
     *      elements, `arguments` the element type, the value
     *      abi.encode(T[])); Tuple (`refs` are the components, `arguments`
     *      the tuple descriptor); TryOrElse (`refs` are attempt and
     *      fallback); IsValid (`refs[0]` is the attempt, the value
     *      abi.encode(bool)); ProbeCall (`refs` are the target address word
     *      and the calldata as a bytes envelope, `selector` the required
     *      error selector or zero, the value abi.encode(bytes reason))
     */
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

    /**
     * @notice One node of an expression graph
     * @dev `valueType` is the descriptor every evaluated value is validated
     *      against. `refs` index earlier nodes only; the fields a kind does
     *      not read (see Kind) are ignored and may be left empty.
     */
    struct Node {
        Kind kind;
        string valueType;
        bytes data;
        uint256[] refs;
        bytes4 selector;
        string arguments;
    }

    /**
     * @notice An expression graph: the core that resolves its Resolve
     *         nodes, the nodes in evaluation order and the index of the
     *         node whose value is the expression's result
     */
    struct Expression {
        address core;
        Node[] nodes;
        uint256 result;
    }

    /**
     * @dev Per-evaluation memo: each node's value and whether it is ready,
     *      plus each node's parsed `valueType` shape so a descriptor is
     *      parsed once per evaluation rather than once per visit. Public
     *      only because guarded evaluation hands it across an external
     *      self-call; nothing outside this contract can inject one.
     */
    struct Cache {
        bytes[] values;
        bool[] ready;
        bool[] dynamic;
        uint256[] words;
    }

    // ============ Custom Errors ============

    /**
     * @notice Thrown when a node is structurally invalid: the wrong number
     *         of refs for its kind, a result index past the last node, a
     *         Parameter whose data is not one word, a Select condition
     *         shorter than a word, or an address word with dirty upper bytes
     * @param node The offending node's index (the result index when it is
     *        out of range)
     */
    error InvalidNode(uint256 node);

    /**
     * @notice Thrown when a node references a node at or after itself, or
     *         a Parameter node names an index past the supplied parameters
     * @param node The referencing node's index
     * @param ref The offending reference
     */
    error InvalidReference(uint256 node, uint256 ref);

    /**
     * @notice Thrown when a call target has no code (a staticcall there
     *         would succeed with empty returndata and surface as a silent
     *         wrong value)
     * @param node The node making the call
     * @param target The code-less address
     */
    error InvalidTarget(uint256 node, address target);

    /**
     * @notice Thrown when a staticcall reverts, carrying the target's revert
     *         data so the inner reason is not lost (a different error from
     *         the core's two-argument CallFailed)
     * @param node The node making the call
     * @param target The called address
     * @param callData The calldata that was sent
     * @param reason The raw revert data
     */
    error NodeCallFailed(uint256 node, address target, bytes callData, bytes reason);

    /**
     * @notice Thrown when evaluateGuarded is called by anyone other than
     *         this contract
     * @param caller The offending msg.sender
     */
    error NotSelf(address caller);

    // ============ Evaluate ============

    /**
     * @notice Evaluates an expression graph and returns the result node's
     *         value
     * @dev Every node is checked up front (reference direction, ref count
     *      per kind, descriptor shape); then evaluation proceeds from the
     *      result node on demand, so only reachable nodes execute and a
     *      node shared by several references evaluates once. Select judges
     *      truth like the core's `cond`: the first word of a condition of
     *      at least 32 bytes, nonzero evaluates refs[1] and zero refs[2],
     *      and only the chosen branch executes (a shorter condition reverts
     *      with InvalidNode). TryOrElse and IsValid run their attempt in an
     *      external self-call so that ANY failure inside it, a reverting
     *      target, a type mismatch or an out-of-gas in the subframe, rolls
     *      back and selects the fallback (the same 63/64 caveat as the
     *      core's `orElse` applies: do not use them to distinguish failure
     *      causes). Values memoized inside a successful attempt are kept.
     *      Every node's value is validated against its `valueType` and a
     *      mismatch reverts with AbiCodec's InvalidValue at the offending
     *      offset. The result is returned via a
     *      raw assembly return, so an expression nests inside any operand
     *      like the value it computes.
     * @param expression The graph to evaluate
     * @param parameters The values Parameter nodes read, as canonical
     *        single-value encodings
     */
    function evaluate(Expression calldata expression, bytes[] calldata parameters) external view {
        uint256 count = expression.nodes.length;
        if (expression.result >= count) revert InvalidNode(expression.result);
        Cache memory cache = Cache(new bytes[](count), new bool[](count), new bool[](count), new uint256[](count));
        for (uint256 i; i < count; i++) {
            Node calldata node = expression.nodes[i];
            (cache.dynamic[i], cache.words[i]) = AbiCodec.shape(bytes(node.valueType));
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
        bytes memory result = _evaluate(expression, parameters, cache, expression.result);
        assembly ("memory-safe") { return(add(result, 32), mload(result)) }
    }

    /**
     * @notice Internal entry point for guarded evaluation; reverts with
     *         NotSelf for any caller other than this contract
     * @dev External only because the EVM's sole catch primitive is a call
     *      boundary: TryOrElse and IsValid evaluate their attempt through
     *      it so a failure rolls back cleanly. The msg.sender check keeps
     *      outside callers from injecting a cache. Returns the node's value
     *      and the cache as extended by the attempt, which the caller
     *      adopts on success.
     * @param expression The graph being evaluated
     * @param parameters The evaluation's parameters
     * @param index The node to evaluate
     * @param initial The cache as it stood when the attempt began
     * @return result The evaluated node's value
     * @return updated The cache after the attempt
     */
    function evaluateGuarded(
        Expression calldata expression,
        bytes[] calldata parameters,
        uint256 index,
        Cache calldata initial
    ) external view returns (bytes memory result, Cache memory updated) {
        if (msg.sender != address(this)) revert NotSelf(msg.sender);
        updated = initial;
        result = _evaluate(expression, parameters, updated, index);
    }

    /**
     * @notice `evaluate` over an abi-encoded Expression, for callers that
     *         hold the graph as opaque bytes
     * @dev The Collections callback socket: a `Callback` whose `expression`
     *      is non-empty is applied by calling this with the substituted
     *      slots as `parameters`. Evaluation happens through an external
     *      self-call, so a failure inside the graph surfaces as
     *      NodeCallFailed(0, this, callData, reason) with the inner error as
     *      the reason. Returns the same raw value as `evaluate`.
     * @param expression abi.encode(Expression)
     * @param parameters The values Parameter nodes read
     */
    function evaluateEncoded(bytes calldata expression, bytes[] calldata parameters) external view {
        Expression memory decoded = abi.decode(expression, (Expression));
        bytes memory result = _call(address(this), abi.encodeCall(this.evaluate, (decoded, parameters)), 0);
        assembly ("memory-safe") { return(add(result, 32), mload(result)) }
    }

    // ============ Internal Helpers ============

    /**
     * @dev Evaluates node `index`, memoizing into `cache`. The caller has
     *      run `evaluate`'s structural checks, so refs are in range and
     *      backwards; kinds dispatch as documented on Kind.
     */
    function _evaluate(Expression calldata p, bytes[] calldata parameters, Cache memory cache, uint256 index)
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
            if (condition.length < 32) revert InvalidNode(index);
            result = _evaluate(p, parameters, cache, node.refs[AbiCodec.word(condition, 0) != 0 ? 1 : 2]);
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
                bool dynamic;
                (result, dynamic) = _arguments(node.arguments, values);
                if (dynamic) result = bytes.concat(abi.encode(uint256(32)), result);
            }
        } else {
            address target = _address(_evaluate(p, parameters, cache, node.refs[0]), index);
            bytes[] memory args = new bytes[](node.refs.length - 1);
            for (uint256 i; i < args.length; i++) {
                args[i] = _evaluate(p, parameters, cache, node.refs[i + 1]);
            }
            (bytes memory encoded,) = _arguments(node.arguments, args);
            result = _call(target, bytes.concat(node.selector, encoded), index);
        }
        AbiCodec.validate(bytes(node.valueType), result, cache.dynamic[index], cache.words[index]);
        cache.values[index] = result;
        cache.ready[index] = true;
    }

    /**
     * @dev Evaluates node `index` behind the `evaluateGuarded` boundary:
     *      on success adopts the attempt's memoized values into `cache`
     *      and returns them, on any failure leaves `cache` untouched and
     *      returns (false, "").
     */
    function _tryEvaluate(
        Expression calldata expression,
        bytes[] calldata parameters,
        Cache memory cache,
        uint256 index
    ) private view returns (bool success, bytes memory result) {
        try this.evaluateGuarded(expression, parameters, index, cache) returns (
            bytes memory value, Cache memory updated
        ) {
            cache.values = updated.values;
            cache.ready = updated.ready;
            return (true, value);
        } catch {
            return (false, "");
        }
    }

    /**
     * @dev The canonical argument tuple for `types` over resolved values,
     *      and whether that tuple is dynamic (a Tuple node then prefixes
     *      the 0x20 word). "()" with no values is the empty tuple; the
     *      grammar has no empty-tuple production, so it is special-cased
     *      here exactly as the core does. The descriptor is parsed once.
     */
    function _arguments(string calldata types, bytes[] memory values)
        private
        pure
        returns (bytes memory encoded, bool dynamic)
    {
        if (bytes(types).length == 2 && bytes(types)[0] == "(" && bytes(types)[1] == ")" && values.length == 0) {
            return ("", false);
        }
        AbiCodec.TupleLayout memory plan = AbiCodec.tupleLayout(bytes(types));
        encoded = AbiCodec.tuple(plan, bytes(types), values);
        dynamic = AbiCodec.isDynamic(plan);
    }

    /**
     * @dev The ProbeCall engine, with the core's `revertData` semantics: the
     *      call must revert (DidNotRevert otherwise), a code-less target
     *      counts as a reason-less failure, and a non-zero `expected`
     *      selector must match the revert's first four bytes and is
     *      stripped from the returned reason (UnexpectedRevertData on a
     *      mismatch). The core's errors are reused so both probes decode
     *      alike.
     */
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

    /**
     * @dev Interprets a value as an address: exactly one word with clean
     *      upper bytes, or InvalidNode(index)
     */
    function _address(bytes memory value, uint256 index) private pure returns (address) {
        if (value.length != 32 || AbiCodec.word(value, 0) > type(uint160).max) revert InvalidNode(index);
        return address(uint160(AbiCodec.word(value, 0)));
    }

    /**
     * @dev Executes a staticcall and returns the raw result bytes. A
     *      code-less target reverts with InvalidTarget(index) and a revert
     *      with NodeCallFailed(index, ...) carrying the reason.
     */
    function _call(address target, bytes memory data, uint256 index) private view returns (bytes memory result) {
        if (target.code.length == 0) revert InvalidTarget(index, target);
        bool ok;
        (ok, result) = target.staticcall(data);
        if (!ok) revert NodeCallFailed(index, target, data, result);
    }
}
