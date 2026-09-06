// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {AbiShape} from "./AbiShape.sol";
import {ValueCodec} from "./ValueCodec.sol";

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
    error InvalidCallbackResult(bytes4 operation, uint256 index, uint256 other, address target);

    /// @notice Validate a single canonical ABI value; also used to contextualize callback failures.
    function validateValue(string calldata valueType, bytes calldata value) external pure {
        ValueCodec.validate(bytes(valueType), value);
    }

    function validateResult(string calldata valueType, bytes memory value, Callback calldata cb, uint256 i)
        private
        view
    {
        try this.validateValue(valueType, value) {} catch {
            revert InvalidCallbackResult(msg.sig, i, 0, cb.target);
        }
    }

    /// @notice Assemble canonical abi.encode(T[]) from canonical abi.encode(T) elements.
    function packArray(string calldata elementType, bytes[] calldata values) external pure returns (bytes memory) {
        return ValueCodec.pack(bytes(elementType), values);
    }

    /// @notice Extract canonical abi.encode(T) elements from canonical abi.encode(T[]).
    function unpackArray(string calldata elementType, bytes calldata encoded) external pure returns (bytes[] memory) {
        return ValueCodec.unpack(bytes(elementType), encoded);
    }

    function validateCallback(Callback calldata cb, bool binary) private pure {
        if (cb.first >= cb.constants.length ||
            (binary && (cb.second >= cb.constants.length || cb.first == cb.second))) {
            revert InvalidCallback();
        }
        bytes calldata descriptor = bytes(cb.arguments);
        ValueCodec.shape(descriptor);
        if (descriptor[0] != "(" || descriptor[descriptor.length - 1] != ")") revert InvalidCallback();
        uint256 cursor = 1;
        uint256 count;
        while (cursor < descriptor.length - 1) {
            (uint256 end,,) = AbiShape.typeShape(descriptor, cursor, descriptor.length - 1);
            if (count >= cb.constants.length) revert InvalidCallback();
            if (count != cb.first && (!binary || count != cb.second)) {
                ValueCodec.validate(descriptor[cursor:end], cb.constants[count]);
            }
            count++;
            cursor = end + 1;
        }
        if (count != cb.constants.length || cb.first >= count || (binary && (cb.second >= count || cb.first == cb.second))) revert InvalidCallback();
    }

    function callValue(Callback calldata cb, bytes memory a, bytes memory b, bool binary, uint256 i, uint256 j)
        private
        view
        returns (bytes memory out)
    {
        bytes[] memory args = cb.constants;
        if (cb.first >= args.length || (binary && (cb.second >= args.length || cb.first == cb.second))) {
            revert InvalidCallback();
        }
        args[cb.first] = a;
        if (binary) args[cb.second] = b;
        bytes memory data = bytes.concat(cb.selector, ValueCodec.tuple(bytes(cb.arguments), args));
        bool ok;
        (ok, out) = cb.target.staticcall(data);
        if (!ok) revert CallbackFailed(msg.sig, i, j, cb.target, out);
    }

    function predicate(Callback calldata cb, bytes memory a, bytes memory b, bool binary, uint256 i, uint256 j)
        private
        view
        returns (bool)
    {
        bytes memory out = callValue(cb, a, b, binary, i, j);
        if (out.length != 32 || ValueCodec.word(out, 0) > 1) revert InvalidCallbackResult(msg.sig, i, j, cb.target);
        return ValueCodec.word(out, 0) == 1;
    }

    /// @notice Map each encoded input to one encoded output of outputType, preserving order.
    function mapValues(
        string calldata inputType,
        string calldata outputType,
        bytes[] calldata values,
        Callback calldata cb
    ) external view returns (bytes[] memory out) {
        validateCallback(cb, false);
        ValueCodec.shape(bytes(inputType));
        ValueCodec.shape(bytes(outputType));
        out = new bytes[](values.length);
        for (uint256 i; i < values.length; i++) {
            ValueCodec.validate(bytes(inputType), values[i]);
            out[i] = callValue(cb, values[i], "", false, i, 0);
            validateResult(outputType, out[i], cb, i);
        }
    }

    /// @notice Keep inputs whose callback returns true, preserving order.
    function filterValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        validateCallback(cb, false);
        ValueCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            ValueCodec.validate(bytes(inputType), values[i]);
            if (predicate(cb, values[i], "", false, i, 0)) out[count++] = values[i];
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
        validateCallback(cb, true);
        ValueCodec.shape(bytes(inputType));
        ValueCodec.validate(bytes(accumulatorType), initial);
        result = initial;
        for (uint256 i; i < values.length; i++) {
            ValueCodec.validate(bytes(inputType), values[i]);
            result = callValue(cb, result, values[i], true, i, 0);
            validateResult(accumulatorType, result, cb, i);
        }
    }

    /// @notice Stable ascending merge sort; callback compares two values and returns signed ordering.
    function sortValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        validateCallback(cb, true);
        ValueCodec.shape(bytes(inputType));
        out = values;
        uint256 n = out.length;
        bytes[] memory scratch = new bytes[](n);
        for (uint256 i; i < n; i++) {
            ValueCodec.validate(bytes(inputType), out[i]);
        }
        for (uint256 width = 1; width < n; width *= 2) {
            for (uint256 start; start < n; start += 2 * width) {
                uint256 middle = start + width < n ? start + width : n;
                uint256 end = start + 2 * width < n ? start + 2 * width : n;
                uint256 a = start;
                uint256 b = middle;
                for (uint256 dest = start; dest < end; dest++) {
                    bool takeA = b == end;
                    if (a < middle && b < end) {
                        bytes memory answer = callValue(cb, out[a], out[b], true, a, b);
                        if (answer.length != 32) revert InvalidCallbackResult(msg.sig, a, b, cb.target);
                        takeA = int256(ValueCodec.word(answer, 0)) <= 0;
                    }
                    if (a == middle) takeA = false;
                    scratch[dest] = takeA ? out[a++] : out[b++];
                }
            }
            bytes[] memory previous = out;
            out = scratch;
            scratch = previous;
        }
    }

    /// @notice Keep the first representative of each callback-defined equality class.
    function distinctValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        validateCallback(cb, true);
        ValueCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            ValueCodec.validate(bytes(inputType), values[i]);
            bool duplicate;
            for (uint256 j; j < count; j++) {
                if (predicate(cb, out[j], values[i], true, i, j)) {
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
