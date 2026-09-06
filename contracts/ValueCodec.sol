// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {AbiShape, InvalidTypeDescriptor} from "./AbiShape.sol";

/// @notice Strict canonical ABI envelope codec; descriptors describe shapes, not scalar semantics.
library ValueCodec {
    error InvalidValue(uint256 offset);

    function word(bytes memory data, uint256 p) internal pure returns (uint256 v) {
        if (p > data.length || data.length - p < 32) revert InvalidValue(p);
        assembly { v := mload(add(add(data, 32), p)) }
    }

    function slice(bytes memory data, uint256 p, uint256 n) internal pure returns (bytes memory out) {
        if (p > data.length || n > data.length - p) revert InvalidValue(p);
        out = new bytes(n);
        assembly ("memory-safe") {
            mcopy(add(out, 32), add(add(data, 32), p), n)
        }
    }

    function shape(bytes calldata t) internal pure returns (bool dyn, uint256 words) {
        uint256 e;
        (e, dyn, words) = AbiShape.typeShape(t, 0, t.length);
        if (e != t.length) revert InvalidTypeDescriptor(e);
    }

    function validate(bytes calldata t, bytes memory v) internal pure returns (bool dyn) {
        (dyn,) = shape(t);
        uint256 start;
        if (dyn) {
            if (word(v, 0) != 32) revert InvalidValue(0);
            start = 32;
        }
        if (body(t, 0, t.length, v, start) != v.length - start) revert InvalidValue(start);
    }

    struct ArrayState {
        uint256 j;
        uint256 count;
        uint256 base;
        uint256 words;
        uint256 tail;
        bool dynamic;
    }

    function body(bytes calldata t, uint256 s, uint256 e, bytes memory v, uint256 p)
        private
        pure
        returns (uint256 used)
    {
        if (t[e - 1] == "]") {
            ArrayState memory x;
            x.j = AbiShape.suffixStart(t, s, e);
            x.base = p;
            if (x.j + 1 == e - 1) {
                x.count = word(v, p);
                x.base += 32;
            } else {
                for (uint256 k = x.j + 1; k < e - 1; k++) {
                    x.count = x.count * 10 + uint8(t[k]) - 48;
                }
            }
            (, x.dynamic, x.words) = AbiShape.typeShape(t, s, x.j);
            x.tail = x.count * x.words * 32;
            if (x.base > v.length || x.tail > v.length - x.base) revert InvalidValue(x.base);
            for (uint256 i; i < x.count; i++) {
                uint256 at = x.base + i * x.words * 32;
                if (x.dynamic) {
                    if (word(v, at) != x.tail) revert InvalidValue(at);
                    x.tail += body(t, s, x.j, v, x.base + x.tail);
                } else if (body(t, s, x.j, v, at) != x.words * 32) {
                    revert InvalidValue(at);
                }
            }
            return x.base - p + x.tail;
        }
        if (t[s] == "(") {
            ArrayState memory x;
            x.j = s + 1;
            while (x.j < e - 1) {
                (uint256 next,, uint256 w) = AbiShape.typeShape(t, x.j, e - 1);
                x.tail += w * 32;
                x.j = next + 1;
            }
            x.j = s + 1;
            while (x.j < e - 1) {
                (uint256 next, bool dynamic, uint256 w) = AbiShape.typeShape(t, x.j, e - 1);
                if (dynamic) {
                    if (word(v, p + x.base) != x.tail) revert InvalidValue(p + x.base);
                    x.tail += body(t, x.j, next, v, p + x.tail);
                } else if (body(t, x.j, next, v, p + x.base) != w * 32) {
                    revert InvalidValue(p + x.base);
                }
                x.base += w * 32;
                x.j = next + 1;
            }
            return x.tail;
        }
        (, bool dynamic,) = AbiShape.typeShape(t, s, e);
        if (!dynamic) {
            word(v, p);
            return 32;
        }
        uint256 n = word(v, p);
        uint256 padded = (n + 31) / 32 * 32;
        if (p + 32 > v.length || padded > v.length - p - 32) revert InvalidValue(p);
        for (uint256 i = n; i < padded; i++) {
            if (v[p + 32 + i] != 0) revert InvalidValue(p + 32 + i);
        }
        return 32 + padded;
    }

    function pack(bytes calldata t, bytes[] memory values) internal pure returns (bytes memory result) {
        (bool dynamic, uint256 words) = shape(t);
        bytes memory heads;
        bytes memory tails;
        uint256 headSize = values.length * words * 32;
        for (uint256 i; i < values.length; i++) {
            validate(t, values[i]);
            if (dynamic) {
                heads = bytes.concat(heads, abi.encode(headSize + tails.length));
                tails = bytes.concat(tails, slice(values[i], 32, values[i].length - 32));
            } else {
                heads = bytes.concat(heads, values[i]);
            }
        }
        return bytes.concat(abi.encode(uint256(32), values.length), heads, tails);
    }

    function unpack(bytes calldata t, bytes memory encoded) internal pure returns (bytes[] memory values) {
        (bool dynamic, uint256 words) = shape(t);
        if (word(encoded, 0) != 32) revert InvalidValue(0);
        uint256 count = word(encoded, 32);
        uint256 head = count * words * 32;
        if (encoded.length < 64 || head > encoded.length - 64) revert InvalidValue(64);
        values = new bytes[](count);
        uint256 tail = head;
        for (uint256 i; i < count; i++) {
            uint256 p = 64 + i * words * 32;
            if (dynamic) {
                if (word(encoded, p) != tail) revert InvalidValue(p);
                uint256 n = body(t, 0, t.length, encoded, 64 + tail);
                values[i] = bytes.concat(abi.encode(uint256(32)), slice(encoded, 64 + tail, n));
                tail += n;
            } else {
                values[i] = slice(encoded, p, words * 32);
                validate(t, values[i]);
            }
        }
        if (64 + tail != encoded.length) revert InvalidValue(64 + tail);
    }

    function tuple(bytes calldata t, bytes[] memory args) internal pure returns (bytes memory result) {
        shape(t);
        if (t[0] != "(" || t[t.length - 1] != ")") revert InvalidTypeDescriptor(0);
        ArrayState memory x;
        x.j = 1;
        while (x.j < t.length - 1) {
            (uint256 e,, uint256 w) = AbiShape.typeShape(t, x.j, t.length - 1);
            x.tail += w * 32;
            x.count++;
            x.j = e + 1;
        }
        if (x.count != args.length) revert InvalidValue(x.count);
        bytes memory heads;
        bytes memory tails;
        x.j = 1;
        for (uint256 i; i < x.count; i++) {
            (uint256 e, bool dynamic,) = AbiShape.typeShape(t, x.j, t.length - 1);
            validate(t[x.j:e], args[i]);
            if (dynamic) {
                heads = bytes.concat(heads, abi.encode(x.tail + tails.length));
                tails = bytes.concat(tails, slice(args[i], 32, args[i].length - 32));
            } else {
                heads = bytes.concat(heads, args[i]);
            }
            x.j = e + 1;
        }
        return bytes.concat(heads, tails);
    }
}
