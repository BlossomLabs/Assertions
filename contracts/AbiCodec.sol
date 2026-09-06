// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error InvalidTypeDescriptor(uint256 position);

/// @notice Shared ABI shape grammar, canonical validation, and encoding.
/// @dev Base names other than bytes/string are single words; scalar semantics
/// remain the caller's claim. All functions are internal and ERC-8211 independent.
library AbiCodec {
    error InvalidValue(uint256 offset);
    error InvalidComponentLength(uint256 index, uint256 expectedBytes, uint256 actualBytes);
    error InvalidComponentEnvelope(uint256 index, uint256 length, bytes32 head);
    error InvalidComponentValue(uint256 index, uint256 offset);
    error ComponentCountMismatch(uint256 expected, uint256 actual);
    error InvalidCallbackResult(bytes4 operation, uint256 index, uint256 other, address target);

    struct Context {
        uint8 kind; // 0: value, 1: callback result, 2: tuple component
        bytes4 operation;
        uint256 index;
        uint256 other;
        address target;
    }

    struct TupleLayout {
        uint256[] starts;
        uint256[] ends;
        bool[] dynamic;
        uint256 headSize;
    }

    function typeShape(bytes calldata t, uint256 p, uint256 limit) internal pure returns (uint256 end, bool dyn, uint256 words) {
        if (p >= limit) revert InvalidTypeDescriptor(p);
        if (t[p] == "(") {
            uint256 q = p + 1;
            uint256 sum;
            while (true) {
                (uint256 e, bool d, uint256 w) = typeShape(t, q, limit);
                if (d) dyn = true;
                sum += w;
                if (e >= limit) revert InvalidTypeDescriptor(e);
                if (t[e] == ",") {
                    q = e + 1;
                    continue;
                }
                if (t[e] == ")") {
                    end = e + 1;
                    break;
                }
                revert InvalidTypeDescriptor(e);
            }
            words = dyn ? 1 : sum;
        } else {
            uint256 q = p;
            while (q < limit && ((t[q] >= "a" && t[q] <= "z") || (t[q] >= "0" && t[q] <= "9"))) {
                q++;
            }
            if (q == p) revert InvalidTypeDescriptor(p);
            dyn = (q - p == 5 && t[p] == "b" && t[p + 1] == "y" && t[p + 2] == "t" && t[p + 3] == "e" && t[p + 4] == "s")
                || (q - p == 6 && t[p] == "s" && t[p + 1] == "t" && t[p + 2] == "r" && t[p + 3] == "i" && t[p + 4] == "n" && t[p + 5] == "g");
            words = 1;
            end = q;
        }
        while (end < limit && t[end] == "[") {
            uint256 q2 = end + 1;
            uint256 k;
            bool fixedSize;
            while (q2 < limit && t[q2] >= "0" && t[q2] <= "9") {
                k = k * 10 + (uint8(t[q2]) - 48);
                fixedSize = true;
                q2++;
            }
            if (q2 >= limit || t[q2] != "]") revert InvalidTypeDescriptor(q2);
            if (fixedSize) {
                if (!dyn) words = words * k;
            } else {
                dyn = true;
                words = 1;
            }
            end = q2 + 1;
        }
    }

    /**
     * @dev Position of the `[` opening the LAST suffix of the array type position
     *      [ts, te) — the outermost constructor (te - 1 must be `]`)
     */
    function suffixStart(bytes calldata t, uint256 ts, uint256 te) internal pure returns (uint256 j) {
        j = te - 2;
        while (j > ts && t[j] >= "0" && t[j] <= "9") {
            j--;
        }
        if (t[j] != "[") revert InvalidTypeDescriptor(j);
    }


    function shape(bytes calldata t) internal pure returns (bool dynamic, uint256 words) {
        uint256 end;
        (end, dynamic, words) = typeShape(t, 0, t.length);
        if (end != t.length) revert InvalidTypeDescriptor(end);
    }

    function requireValue(bool valid, uint256 offset, Context memory context) private pure {
        if (valid) return;
        if (context.kind == 1) revert InvalidCallbackResult(context.operation, context.index, context.other, context.target);
        if (context.kind == 2) revert InvalidComponentValue(context.index, offset);
        revert InvalidValue(offset);
    }

    function word(bytes memory data, uint256 p) internal pure returns (uint256) {
        Context memory context;
        return word(data, p, context);
    }

    function word(bytes memory data, uint256 p, Context memory context) private pure returns (uint256 v) {
        requireValue(p <= data.length && data.length - p >= 32, p, context);
        assembly ("memory-safe") { v := mload(add(add(data, 32), p)) }
    }

    function copy(bytes memory out, uint256 dest, bytes memory data, uint256 start, uint256 n) private pure {
        assembly ("memory-safe") { mcopy(add(add(out, 32), dest), add(add(data, 32), start), n) }
    }

    function store(bytes memory out, uint256 p, uint256 v) private pure {
        assembly ("memory-safe") { mstore(add(add(out, 32), p), v) }
    }

    function slice(bytes memory data, uint256 p, uint256 n) internal pure returns (bytes memory out) {
        if (p > data.length || n > data.length - p) revert InvalidValue(p);
        out = new bytes(n);
        copy(out, 0, data, p, n);
    }

    function validate(bytes calldata t, bytes memory v) internal pure returns (bool dynamic) {
        Context memory context;
        return validate(t, v, context);
    }

    function validate(bytes calldata t, bytes memory v, Context memory context) internal pure returns (bool dynamic) {
        uint256 words;
        (dynamic, words) = shape(t);
        if (dynamic) validateDynamic(t, v, context);
        else requireValue(v.length % 32 == 0 && words == v.length / 32, 0, context);
    }

    function validateDynamic(bytes calldata t, bytes memory v, Context memory context) private pure {
        requireValue(word(v, 0, context) == 32, 0, context);
        requireValue(body(t, 0, t.length, v, 32, context) == v.length - 32, 32, context);
    }

    struct ArrayState {
        uint256 j;
        uint256 count;
        uint256 base;
        uint256 words;
        uint256 tail;
        bool dynamic;
    }

    function body(bytes calldata t, uint256 s, uint256 e, bytes memory v, uint256 p, Context memory context)
        private pure returns (uint256)
    {
        requireValue(p <= v.length, p, context);
        if (t[e - 1] == "]") {
            ArrayState memory x;
            x.j = suffixStart(t, s, e);
            x.base = p;
            if (x.j + 1 == e - 1) {
                x.count = word(v, p, context);
                x.base += 32;
            } else {
                for (uint256 k = x.j + 1; k < e - 1; k++) x.count = x.count * 10 + uint8(t[k]) - 48;
            }
            (, x.dynamic, x.words) = typeShape(t, s, x.j);
            // Bound multiplication and traversal before trusting an encoded length.
            requireValue(x.words <= (v.length - x.base) / 32 || x.count == 0, x.base, context);
            if (x.words != 0) requireValue(x.count <= (v.length - x.base) / 32 / x.words, x.base, context);
            x.tail = x.count * x.words * 32;
            // Static bodies contain no offsets or byte padding: the bounded head is the complete body.
            if (!x.dynamic) return x.base - p + x.tail;
            for (uint256 i; i < x.count; i++) {
                uint256 position = x.base + i * x.words * 32;
                requireValue(word(v, position, context) == x.tail, position, context);
                x.tail += body(t, s, x.j, v, x.base + x.tail, context);
            }
            return x.base - p + x.tail;
        }
        if (t[s] == "(") {
            ArrayState memory x;
            x.j = s + 1;
            while (x.j < e - 1) {
                (uint256 next,, uint256 w) = typeShape(t, x.j, e - 1);
                requireValue(w <= (v.length - p - x.tail) / 32, p, context);
                x.tail += w * 32;
                x.j = next + 1;
            }
            x.j = s + 1;
            while (x.j < e - 1) {
                (uint256 next, bool dynamic, uint256 w) = typeShape(t, x.j, e - 1);
                if (dynamic) {
                    requireValue(word(v, p + x.base, context) == x.tail, p + x.base, context);
                    x.tail += body(t, x.j, next, v, p + x.tail, context);
                }
                x.base += w * 32;
                x.j = next + 1;
            }
            return x.tail;
        }
        // Only dynamic children reach this function; a base type here is bytes/string.
        uint256 n = word(v, p, context);
        requireValue(n <= v.length - p - 32, p, context);
        uint256 padded = (n + 31) / 32 * 32;
        requireValue(padded <= v.length - p - 32, p, context);
        uint256 padding = padded - n;
        if (padding != 0 && word(v, p + padded, context) & (type(uint256).max >> ((32 - padding) * 8)) != 0) {
            // The common canonical case checks one word; scan only to locate an error.
            for (uint256 i = n; i < padded; i++) requireValue(v[p + 32 + i] == 0, p + 32 + i, context);
        }
        return 32 + padded;
    }

    function tupleLayout(bytes calldata t) internal pure returns (TupleLayout memory plan) {
        shape(t);
        if (t[0] != "(" || t[t.length - 1] != ")") revert InvalidTypeDescriptor(0);
        uint256 count;
        uint256 p = 1;
        while (p < t.length - 1) {
            (uint256 end,, uint256 words) = typeShape(t, p, t.length - 1);
            plan.headSize += words * 32;
            count++;
            p = end + 1;
        }
        plan.starts = new uint256[](count);
        plan.ends = new uint256[](count);
        plan.dynamic = new bool[](count);
        p = 1;
        for (uint256 i; i < count; i++) {
            (uint256 end, bool dynamic,) = typeShape(t, p, t.length - 1);
            plan.starts[i] = p;
            plan.ends[i] = end;
            plan.dynamic[i] = dynamic;
            p = end + 1;
        }
    }

    /// @dev Preserve component-level diagnostics before recursively validating the body.
    function validateComponent(bytes calldata t, bytes memory value, uint256 index) internal pure {
        (bool dynamic, uint256 words) = shape(t);
        if (dynamic) {
            bytes32 head = value.length >= 32 ? bytes32(word(value, 0)) : bytes32(0);
            if (value.length < 64 || value.length % 32 != 0 || head != bytes32(uint256(32))) {
                revert InvalidComponentEnvelope(index, value.length, head);
            }
        } else if (words > type(uint256).max / 32 || value.length != words * 32) {
            // A descriptor whose footprint cannot be represented is malformed.
            if (words > type(uint256).max / 32) revert InvalidTypeDescriptor(0);
            revert InvalidComponentLength(index, words * 32, value.length);
        }
        if (dynamic) validateDynamic(t, value, Context(2, bytes4(0), index, 0, address(0)));
    }

    function tuple(bytes calldata t, bytes[] memory args) internal pure returns (bytes memory) {
        TupleLayout memory plan = tupleLayout(t);
        if (args.length != plan.starts.length) revert ComponentCountMismatch(plan.starts.length, args.length);
        for (uint256 i; i < args.length; i++) validateComponent(t[plan.starts[i]:plan.ends[i]], args[i], i);
        return assemble(plan.dynamic, plan.headSize, args, false);
    }

    /// @dev Caller has validated every value against the prepared plan.
    /// Array encodings prepend offset/length; offsets remain relative to their element head.
    function assemble(bool[] memory dynamic, uint256 headSize, bytes[] memory values, bool array)
        internal pure returns (bytes memory out)
    {
        uint256 prefix = array ? 64 : 0;
        uint256 size = headSize;
        for (uint256 i; i < values.length; i++) {
            if (dynamic[array ? 0 : i]) size += values[i].length - 32;
        }
        out = new bytes(prefix + size);
        if (array) {
            store(out, 0, 32);
            store(out, 32, values.length);
        }
        uint256 head;
        uint256 tail = headSize;
        for (uint256 i; i < values.length; i++) {
            bytes memory v = values[i];
            if (dynamic[array ? 0 : i]) {
                store(out, prefix + head, tail);
                copy(out, prefix + tail, v, 32, v.length - 32);
                head += 32;
                tail += v.length - 32;
            } else {
                copy(out, prefix + head, v, 0, v.length);
                head += v.length;
            }
        }
    }

    function pack(bytes calldata t, bytes[] memory values) internal pure returns (bytes memory) {
        (bool dynamic, uint256 words) = shape(t);
        for (uint256 i; i < values.length; i++) validate(t, values[i]);
        bool[] memory dynamics = new bool[](1);
        dynamics[0] = dynamic;
        return assemble(dynamics, values.length * words * 32, values, true);
    }

    function unpack(bytes calldata t, bytes memory encoded) internal pure returns (bytes[] memory values) {
        ArrayState memory x;
        (x.dynamic, x.words) = shape(t);
        if (word(encoded, 0) != 32) revert InvalidValue(0);
        x.count = word(encoded, 32);
        if (x.words != 0 && x.count > (encoded.length - 64) / 32 / x.words) revert InvalidValue(64);
        x.tail = x.count * x.words * 32;
        values = new bytes[](x.count);
        Context memory context;
        for (uint256 i; i < x.count; i++) {
            uint256 p = 64 + i * x.words * 32;
            if (x.dynamic) {
                if (word(encoded, p) != x.tail) revert InvalidValue(p);
                uint256 n = body(t, 0, t.length, encoded, 64 + x.tail, context);
                values[i] = bytes.concat(abi.encode(uint256(32)), slice(encoded, 64 + x.tail, n));
                x.tail += n;
            } else {
                values[i] = slice(encoded, p, x.words * 32);
                validate(t, values[i]);
            }
        }
        if (64 + x.tail != encoded.length) revert InvalidValue(64 + x.tail);
    }
}
