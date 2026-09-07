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
        uint256[] words;
        uint256 headSize;
    }

    // ASCII bytes the grammar recognises, compared as numbers. The scanners read
    // calldata bytes through `byteAt` because bounds-checked `t[i]` indexing was
    // the parse cost: four checked reads per character in the name scan made a
    // 17-character descriptor cost about 7k gas to parse (measured 2026-09-07).
    uint8 private constant LPAREN = 0x28;
    uint8 private constant RPAREN = 0x29;
    uint8 private constant COMMA = 0x2c;
    uint8 private constant LBRACKET = 0x5b;
    uint8 private constant RBRACKET = 0x5d;
    uint256 private constant NAME_BYTES = 0x6279746573; // "bytes"
    uint256 private constant NAME_STRING = 0x737472696e67; // "string"

    /// @dev Byte `i` of a descriptor. Every caller bounds `i` by a `limit` that
    ///      `typeShape` has checked against `t.length`, so no bounds check here.
    function byteAt(bytes calldata t, uint256 i) private pure returns (uint8 c) {
        assembly ("memory-safe") {
            c := byte(0, calldataload(add(t.offset, i)))
        }
    }

    /// @dev The end of the `[a-z0-9]*` run starting at `p`, bounded by `limit`.
    function scanName(bytes calldata t, uint256 p, uint256 limit) private pure returns (uint256 q) {
        assembly ("memory-safe") {
            q := p
            for {} lt(q, limit) {} {
                let c := byte(0, calldataload(add(t.offset, q)))
                if iszero(or(and(gt(c, 0x60), lt(c, 0x7b)), and(gt(c, 0x2f), lt(c, 0x3a)))) { break }
                q := add(q, 1)
            }
        }
    }

    /**
     * @dev Parses one type starting at `p` and ending before `limit`: returns
     *      where it ends, whether it is dynamic and its head footprint in words.
     *      Reverts InvalidTypeDescriptor at the offending byte. `limit` must not
     *      exceed `t.length`; the scanners rely on it for bounds.
     */
    function typeShape(bytes calldata t, uint256 p, uint256 limit)
        internal
        pure
        returns (uint256 end, bool dyn, uint256 words)
    {
        if (limit > t.length) revert InvalidTypeDescriptor(limit);
        if (p >= limit) revert InvalidTypeDescriptor(p);
        if (byteAt(t, p) == LPAREN) {
            uint256 q = p + 1;
            uint256 sum;
            while (true) {
                (uint256 e, bool d, uint256 w) = typeShape(t, q, limit);
                if (d) dyn = true;
                sum += w;
                if (e >= limit) revert InvalidTypeDescriptor(e);
                uint8 c = byteAt(t, e);
                if (c == COMMA) {
                    q = e + 1;
                    continue;
                }
                if (c == RPAREN) {
                    end = e + 1;
                    break;
                }
                revert InvalidTypeDescriptor(e);
            }
            words = dyn ? 1 : sum;
        } else {
            uint256 q = scanName(t, p, limit);
            if (q == p) revert InvalidTypeDescriptor(p);
            uint256 n = q - p;
            if (n == 5 || n == 6) {
                // The name as one right-aligned word, compared against "bytes" / "string".
                uint256 name;
                assembly ("memory-safe") {
                    name := shr(sub(256, mul(8, n)), calldataload(add(t.offset, p)))
                }
                dyn = name == (n == 5 ? NAME_BYTES : NAME_STRING);
            }
            words = 1;
            end = q;
        }
        while (end < limit && byteAt(t, end) == LBRACKET) {
            uint256 q2 = end + 1;
            uint256 k;
            bool fixedSize;
            while (q2 < limit) {
                uint8 c = byteAt(t, q2);
                if (c < 0x30 || c > 0x39) break;
                k = k * 10 + (c - 0x30);
                fixedSize = true;
                q2++;
            }
            if (q2 >= limit || byteAt(t, q2) != RBRACKET) revert InvalidTypeDescriptor(q2);
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
        if (context.kind == 1) {
            revert InvalidCallbackResult(context.operation, context.index, context.other, context.target);
        }
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

    /// @dev `validate` for a caller that already parsed `t` into `(dynamic, words)`
    ///      and keeps it across values instead of re-parsing per value.
    function validate(bytes calldata t, bytes memory v, bool dynamic, uint256 words) internal pure {
        Context memory context;
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

    /// @dev Byte extent of the value of type `t[s:e]` encoded in place at `p`,
    ///      validating canonical form on the way (tight offsets, zero padding).
    function body(bytes calldata t, uint256 s, uint256 e, bytes memory v, uint256 p, Context memory context)
        internal
        pure
        returns (uint256)
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
                for (uint256 k = x.j + 1; k < e - 1; k++) {
                    x.count = x.count * 10 + uint8(t[k]) - 48;
                }
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
            for (uint256 i = n; i < padded; i++) {
                requireValue(v[p + 32 + i] == 0, p + 32 + i, context);
            }
        }
        return 32 + padded;
    }

    function tupleLayout(bytes calldata t) internal pure returns (TupleLayout memory plan) {
        if (t.length < 2 || byteAt(t, 0) != LPAREN || byteAt(t, t.length - 1) != RPAREN) {
            // Not a parenthesized tuple. `shape` reports a malformed descriptor at
            // its own byte; a well-formed non-tuple is rejected at position 0.
            shape(t);
            revert InvalidTypeDescriptor(0);
        }
        uint256 limit = t.length - 1;
        // Components are the depth-0 comma-separated spans; count them with one
        // byte scan (a stray ")" surfaces here, everything else in the parse below).
        uint256 count = 1;
        uint256 stray;
        assembly ("memory-safe") {
            let depth := 0
            for { let i := 1 } lt(i, limit) { i := add(i, 1) } {
                let c := byte(0, calldataload(add(t.offset, i)))
                switch c
                case 0x28 { depth := add(depth, 1) }
                case 0x29 {
                    if iszero(depth) {
                        stray := i
                        i := limit
                    }
                    depth := sub(depth, 1)
                }
                case 0x2c { if iszero(depth) { count := add(count, 1) } }
            }
        }
        if (stray != 0) revert InvalidTypeDescriptor(stray);
        plan.starts = new uint256[](count);
        plan.ends = new uint256[](count);
        plan.dynamic = new bool[](count);
        plan.words = new uint256[](count);
        uint256 p = 1;
        for (uint256 i; i < count; i++) {
            (uint256 end, bool dynamic, uint256 words) = typeShape(t, p, limit);
            plan.starts[i] = p;
            plan.ends[i] = end;
            plan.dynamic[i] = dynamic;
            plan.words[i] = words;
            plan.headSize += words * 32;
            if (i + 1 == count) {
                if (end != limit) revert InvalidTypeDescriptor(end);
            } else {
                if (end >= limit || byteAt(t, end) != COMMA) revert InvalidTypeDescriptor(end);
                p = end + 1;
            }
        }
    }

    /// @dev Reuse a validated descriptor's shape; every value still receives full body validation.
    function validateComponent(bytes calldata t, bytes memory value, uint256 index, bool dynamic, uint256 words)
        internal
        pure
    {
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
        return tuple(tupleLayout(t), t, args);
    }

    /// @dev `tuple` over a layout the caller computed for `t` (and may reuse).
    function tuple(TupleLayout memory plan, bytes calldata t, bytes[] memory args)
        internal
        pure
        returns (bytes memory)
    {
        if (args.length != plan.starts.length) {
            revert ComponentCountMismatch(plan.starts.length, args.length);
        }
        for (uint256 i; i < args.length; i++) {
            validateComponent(t[plan.starts[i]:plan.ends[i]], args[i], i, plan.dynamic[i], plan.words[i]);
        }
        return assemble(plan.dynamic, plan.headSize, args, false);
    }

    /// @dev Whether a tuple with this layout is itself dynamic (any dynamic component).
    function isDynamic(TupleLayout memory plan) internal pure returns (bool) {
        for (uint256 i; i < plan.dynamic.length; i++) {
            if (plan.dynamic[i]) return true;
        }
        return false;
    }

    /// @dev Caller has validated every value against the prepared plan.
    /// Array encodings prepend offset/length; offsets remain relative to their element head.
    function assemble(bool[] memory dynamic, uint256 headSize, bytes[] memory values, bool array)
        internal
        pure
        returns (bytes memory out)
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
        for (uint256 i; i < values.length; i++) {
            validate(t, values[i]);
        }
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
