// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {AbiCodec} from "./AbiCodec.sol";

/// @notice Generic ABI-valued collection operations. Callbacks must be consistent and side-effect free.
contract CollectionOperators {
    /// @dev Argument descriptor is a tuple. constants contains one single-value ABI envelope per slot.
    /// first is the element slot (or fold accumulator); second is the other element/fold element slot.
    /// Unary callbacks ignore second; substituted slots may contain empty placeholders.
    struct Callback {
        address target;
        bytes4 selector;
        string arguments;
        bytes[] constants;
        uint256 first;
        uint256 second;
    }
    error InvalidCallback();
    error CallbackFailed(bytes4 operation, uint256 index, uint256 other, address target, bytes reason);

    /// @notice Validate a single canonical ABI value.
    function validateValue(string calldata valueType, bytes calldata value) external pure {
        AbiCodec.validate(bytes(valueType), value);
    }

    function validateResult(string calldata valueType, bytes memory value, Callback calldata cb, uint256 i)
        private
        pure
    {
        AbiCodec.validate(bytes(valueType), value, AbiCodec.Context(1, msg.sig, i, 0, cb.target));
    }

    /// @notice Assemble canonical abi.encode(T[]) from canonical abi.encode(T) elements.
    function packArray(string calldata elementType, bytes[] calldata values) external pure returns (bytes memory) {
        return AbiCodec.pack(bytes(elementType), values);
    }

    /// @notice Extract canonical abi.encode(T) elements from canonical abi.encode(T[]).
    function unpackArray(string calldata elementType, bytes calldata encoded) external pure returns (bytes[] memory) {
        return AbiCodec.unpack(bytes(elementType), encoded);
    }

    struct PreparedCallback {
        AbiCodec.TupleLayout plan;
        bytes[] args;
    }

    function prepareCallback(Callback calldata cb, bool binary) private pure returns (PreparedCallback memory prepared) {
        if (cb.first >= cb.constants.length ||
            (binary && (cb.second >= cb.constants.length || cb.first == cb.second))) revert InvalidCallback();
        bytes calldata descriptor = bytes(cb.arguments);
        if (descriptor.length != 0 && (descriptor[0] != "(" || descriptor[descriptor.length - 1] != ")")) {
            AbiCodec.shape(descriptor);
            revert InvalidCallback();
        }
        prepared.plan = AbiCodec.tupleLayout(descriptor);
        if (prepared.plan.starts.length != cb.constants.length) revert InvalidCallback();
        prepared.args = cb.constants;
        for (uint256 i; i < cb.constants.length; i++) {
            if (i != cb.first && (!binary || i != cb.second)) {
                AbiCodec.validateComponent(descriptor[prepared.plan.starts[i]:prepared.plan.ends[i]], prepared.args[i], i);
            }
        }
    }

    function bindValue(Callback calldata cb, PreparedCallback memory prepared, uint256 slot, bytes memory value) private pure {
        AbiCodec.validateComponent(bytes(cb.arguments)[prepared.plan.starts[slot]:prepared.plan.ends[slot]], value, slot);
        prepared.args[slot] = value;
    }

    function callValue(Callback calldata cb, PreparedCallback memory prepared, bytes memory a, bytes memory b, bool binary, uint256 i, uint256 j)
        private view returns (bytes memory out)
    {
        bindValue(cb, prepared, cb.first, a);
        if (binary) bindValue(cb, prepared, cb.second, b);
        bytes memory data = bytes.concat(cb.selector, AbiCodec.assemble(prepared.plan.dynamic, prepared.plan.headSize, prepared.args, false));
        bool ok;
        (ok, out) = cb.target.staticcall(data);
        if (!ok) revert CallbackFailed(msg.sig, i, j, cb.target, out);
    }

    function predicate(Callback calldata cb, PreparedCallback memory prepared, bytes memory a, bytes memory b, bool binary, uint256 i, uint256 j)
        private
        view
        returns (bool)
    {
        bytes memory out = callValue(cb, prepared, a, b, binary, i, j);
        if (out.length != 32 || AbiCodec.word(out, 0) > 1) revert AbiCodec.InvalidCallbackResult(msg.sig, i, j, cb.target);
        return AbiCodec.word(out, 0) == 1;
    }

    /// @notice Map each encoded input to one encoded output of outputType, preserving order.
    function mapValues(
        string calldata inputType,
        string calldata outputType,
        bytes[] calldata values,
        Callback calldata cb
    ) external view returns (bytes[] memory out) {
        PreparedCallback memory prepared = prepareCallback(cb, false);
        AbiCodec.shape(bytes(inputType));
        AbiCodec.shape(bytes(outputType));
        out = new bytes[](values.length);
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            out[i] = callValue(cb, prepared, values[i], "", false, i, 0);
            validateResult(outputType, out[i], cb, i);
        }
    }

    /// @notice Keep inputs whose callback returns true, preserving order.
    function filterValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        PreparedCallback memory prepared = prepareCallback(cb, false);
        AbiCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            if (predicate(cb, prepared, values[i], "", false, i, 0)) out[count++] = values[i];
        }
        assembly { mstore(out, count) }
    }

    /// @notice Left fold with an explicit initial accumulator; empty input returns initial.
    function foldValues(
        string calldata inputType,
        string calldata accumulatorType,
        bytes[] calldata values,
        bytes calldata initial,
        Callback calldata cb
    ) external view returns (bytes memory result) {
        PreparedCallback memory prepared = prepareCallback(cb, true);
        AbiCodec.shape(bytes(inputType));
        AbiCodec.validate(bytes(accumulatorType), initial);
        result = initial;
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            result = callValue(cb, prepared, result, values[i], true, i, 0);
            validateResult(accumulatorType, result, cb, i);
        }
    }

    /// @notice Stable ascending merge sort; callback compares two values and returns signed ordering.
    function sortValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        PreparedCallback memory prepared = prepareCallback(cb, true);
        AbiCodec.shape(bytes(inputType));
        out = values;
        SortCursor memory c;
        c.n = out.length;
        bytes[] memory scratch = new bytes[](c.n);
        for (uint256 i; i < c.n; i++) AbiCodec.validate(bytes(inputType), out[i]);
        for (c.width = 1; c.width < c.n; c.width *= 2) {
            for (c.start = 0; c.start < c.n; c.start += 2 * c.width) {
                c.middle = c.start + c.width < c.n ? c.start + c.width : c.n;
                c.end = c.start + 2 * c.width < c.n ? c.start + 2 * c.width : c.n;
                c.a = c.start;
                c.b = c.middle;
                for (uint256 dest = c.start; dest < c.end; dest++) {
                    bool takeA = c.b == c.end;
                    if (c.a < c.middle && c.b < c.end) {
                        bytes memory answer = callValue(cb, prepared, out[c.a], out[c.b], true, c.a, c.b);
                        if (answer.length != 32) revert AbiCodec.InvalidCallbackResult(msg.sig, c.a, c.b, cb.target);
                        takeA = int256(AbiCodec.word(answer, 0)) <= 0;
                    }
                    if (c.a == c.middle) takeA = false;
                    scratch[dest] = takeA ? out[c.a++] : out[c.b++];
                }
            }
            bytes[] memory previous = out;
            out = scratch;
            scratch = previous;
        }
    }

    struct SortCursor {
        uint256 n;
        uint256 width;
        uint256 start;
        uint256 middle;
        uint256 end;
        uint256 a;
        uint256 b;
    }

    /// @notice Keep the first representative of each callback-defined equality class.
    function distinctValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        PreparedCallback memory prepared = prepareCallback(cb, true);
        AbiCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            bool duplicate;
            for (uint256 j; j < count; j++) {
                if (predicate(cb, prepared, out[j], values[i], true, i, j)) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) out[count++] = values[i];
        }
        assembly { mstore(out, count) }
    }

    /// @notice Flatten one level while preserving outer and inner ordering.
    function flattenValues(bytes[][] calldata values) external pure returns (bytes[] memory out) {
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            count += values[i].length;
        }
        out = new bytes[](count);
        uint256 k;
        for (uint256 i; i < values.length; i++) {
            for (uint256 j; j < values[i].length; j++) {
                out[k++] = values[i][j];
            }
        }
    }
}
