// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @notice Thrown when a type descriptor does not parse
 * @param position The byte position in the descriptor where parsing failed
 */
error InvalidTypeDescriptor(uint256 position);

/**
 * @title AbiCodec
 * @author Sembrestels
 * @notice The shared type-descriptor grammar and the canonical ABI codec
 *         built on it: shape parsing (dynamic or static, head footprint),
 *         canonical-form validation of encoded values, tuple and array
 *         assembly from pre-encoded components, and the inverse unpacking.
 *         The core's `nav` and `get`, Operations' `encode`, every
 *         Expressions node and the Collections `*Values` family all read
 *         descriptors through this one grammar.
 * @dev A descriptor is plain ABI type syntax: a name matching [a-z0-9]+ or
 *      a parenthesized, comma-separated tuple, followed by any number of
 *      `[]` or `[k]` suffixes. Only the SHAPE is interpreted: `bytes` and
 *      `string` are the dynamic base names, every other name is one
 *      32-byte word whose meaning stays the caller's claim (a `uint8`
 *      and an `address` parse identically). A "canonical single-value
 *      encoding" throughout this repo means abi.encode(value) of exactly
 *      one value: the bare word for a static type, [0x20][tail] for a
 *      dynamic one, with tight offsets and zero padding. Every function
 *      is internal and knows nothing of ERC-8211.
 */
library AbiCodec {
    // ============ Errors ============

    /**
     * @notice Thrown when an encoded value is not in canonical form at the
     *         given byte offset (a short buffer, a non-tight offset, a
     *         length overrunning the data, nonzero padding, or trailing
     *         bytes after the last tail)
     * @param offset The byte offset of the offending word within the value
     */
    error InvalidValue(uint256 offset);

    /**
     * @notice Thrown when a static tuple component does not have exactly
     *         the byte length its head footprint requires
     * @param index The component's position in the tuple
     * @param expectedBytes The footprint the descriptor requires
     * @param actualBytes The length of the value that was supplied
     */
    error InvalidComponentLength(uint256 index, uint256 expectedBytes, uint256 actualBytes);

    /**
     * @notice Thrown when a dynamic tuple component is not a canonical
     *         envelope: shorter than two words, not word-aligned, or not
     *         starting with the 0x20 offset word
     * @param index The component's position in the tuple
     * @param length The length of the value that was supplied
     * @param head The value's first word (zero when it had none)
     */
    error InvalidComponentEnvelope(uint256 index, uint256 length, bytes32 head);

    /**
     * @notice Thrown when a dynamic tuple component has a well-formed
     *         envelope but a non-canonical body
     * @param index The component's position in the tuple
     * @param offset The byte offset of the offending word within the value
     */
    error InvalidComponentValue(uint256 index, uint256 offset);

    /**
     * @notice Thrown when the number of values supplied to a tuple encoder
     *         differs from the descriptor's component count
     * @param expected The component count the descriptor declares
     * @param actual The number of values that were supplied
     */
    error ComponentCountMismatch(uint256 expected, uint256 actual);

    /**
     * @notice Thrown by the Collections operations when a callback returns
     *         a value that does not fit the declared result type (or, for
     *         word callbacks and predicates, is not exactly one word or a
     *         canonical 0/1)
     * @param operation The selector of the Collections operation running
     *        the callback
     * @param index The element the callback was applied to
     * @param other The second element for binary callbacks (0 otherwise)
     * @param target The callback contract
     */
    error InvalidCallbackResult(bytes4 operation, uint256 index, uint256 other, address target);

    // ============ Types ============

    /**
     * @dev Which error a validation failure raises (see Context): Value
     *      reverts InvalidValue(offset), CallbackResult reverts
     *      InvalidCallbackResult(operation, index, other, target),
     *      TupleComponent reverts InvalidComponentValue(index, offset)
     */
    enum ContextKind {
        Value,
        CallbackResult,
        TupleComponent
    }

    /**
     * @dev Error-reporting context threaded through validation so the
     *      caller's error, not the codec's, reaches the user. A
     *      zero-initialized context is the plain Value case; the other
     *      fields feed the error the kind selects.
     */
    struct Context {
        ContextKind kind;
        bytes4 operation;
        uint256 index;
        uint256 other;
        address target;
    }

    /**
     * @dev A parsed tuple descriptor: per component, its byte span
     *      [starts[i], ends[i]) in the descriptor, whether it is dynamic
     *      and its head footprint in words, plus the tuple's total head
     *      size in bytes. Computed once by `tupleLayout` and reused across
     *      values by the callers that encode the same tuple repeatedly.
     */
    struct TupleLayout {
        uint256[] starts;
        uint256[] ends;
        bool[] dynamic;
        uint256[] words;
        uint256 headSize;
    }

    // ============ Grammar ============

    // ASCII bytes the grammar recognises, compared as numbers. The scanners
    // read calldata bytes through `byteAt` because bounds-checked `t[i]`
    // indexing was the parse cost: four checked reads per character in the
    // name scan made a 17-character descriptor cost about 7k gas to parse
    // (measured 2026-09-07).
    uint8 private constant LPAREN = 0x28;
    uint8 private constant RPAREN = 0x29;
    uint8 private constant COMMA = 0x2c;
    uint8 private constant LBRACKET = 0x5b;
    uint8 private constant RBRACKET = 0x5d;
    uint256 private constant NAME_BYTES = 0x6279746573; // "bytes"
    uint256 private constant NAME_STRING = 0x737472696e67; // "string"

    /**
     * @dev Byte `i` of a descriptor, unchecked. Every caller bounds `i` by a
     *      `limit` that `typeShape` has checked against `t.length`.
     */
    function byteAt(bytes calldata t, uint256 i) private pure returns (uint8 c) {
        assembly ("memory-safe") {
            c := byte(0, calldataload(add(t.offset, i)))
        }
    }

    /**
     * @dev The end of the [a-z0-9]* run starting at `p`, bounded by `limit`
     *      (returns `p` itself when no name byte is there)
     */
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
     *      the position just past it, whether it is dynamic and its head
     *      footprint in words (1 for any dynamic type, the component sum for
     *      a static tuple, k times the element footprint for a static T[k]).
     *      Reverts with InvalidTypeDescriptor at the offending byte. `limit`
     *      must not exceed `t.length`; the scanners rely on it for bounds.
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
     * @dev Position of the `[` opening the LAST suffix of the array type at
     *      [ts, te), which is the outermost constructor. The caller has
     *      established that t[te - 1] is `]`.
     */
    function suffixStart(bytes calldata t, uint256 ts, uint256 te) internal pure returns (uint256 j) {
        j = te - 2;
        while (j > ts && t[j] >= "0" && t[j] <= "9") {
            j--;
        }
        if (t[j] != "[") revert InvalidTypeDescriptor(j);
    }

    /**
     * @dev The shape of a whole descriptor: `typeShape` over all of `t`,
     *      reverting with InvalidTypeDescriptor when anything follows the
     *      parsed type
     */
    function shape(bytes calldata t) internal pure returns (bool dynamic, uint256 words) {
        uint256 end;
        (end, dynamic, words) = typeShape(t, 0, t.length);
        if (end != t.length) revert InvalidTypeDescriptor(end);
    }

    // ============ Values ============

    /**
     * @dev Reverts with the error `context` selects when `valid` is false
     *      (see Context); `offset` is reported by the value-shaped errors
     */
    function requireValue(bool valid, uint256 offset, Context memory context) private pure {
        if (valid) return;
        if (context.kind == ContextKind.CallbackResult) {
            revert InvalidCallbackResult(context.operation, context.index, context.other, context.target);
        }
        if (context.kind == ContextKind.TupleComponent) revert InvalidComponentValue(context.index, offset);
        revert InvalidValue(offset);
    }

    /**
     * @dev The 32-byte word at byte offset `p` of `data`, reverting with
     *      InvalidValue(p) when it lies outside the data
     */
    function word(bytes memory data, uint256 p) internal pure returns (uint256) {
        Context memory context;
        return word(data, p, context);
    }

    /**
     * @dev `word` reporting through `context` instead of InvalidValue
     */
    function word(bytes memory data, uint256 p, Context memory context) private pure returns (uint256 v) {
        requireValue(p <= data.length && data.length - p >= 32, p, context);
        assembly ("memory-safe") { v := mload(add(add(data, 32), p)) }
    }

    /**
     * @dev Copies `n` bytes of `data` from `start` into `out` at `dest`
     *      (caller sizes `out` and bounds both spans)
     */
    function copy(bytes memory out, uint256 dest, bytes memory data, uint256 start, uint256 n) private pure {
        assembly ("memory-safe") { mcopy(add(add(out, 32), dest), add(add(data, 32), start), n) }
    }

    /**
     * @dev Writes the word `v` at byte offset `p` of `out` (caller sizes
     *      `out`)
     */
    function store(bytes memory out, uint256 p, uint256 v) private pure {
        assembly ("memory-safe") { mstore(add(add(out, 32), p), v) }
    }

    /**
     * @dev A fresh copy of data[p .. p + n), reverting with InvalidValue(p)
     *      when the span leaves the data
     */
    function slice(bytes memory data, uint256 p, uint256 n) internal pure returns (bytes memory out) {
        if (p > data.length || n > data.length - p) revert InvalidValue(p);
        out = new bytes(n);
        copy(out, 0, data, p, n);
    }

    // ============ Validation ============

    /**
     * @dev Requires `v` to be the canonical single-value encoding of type
     *      `t`: exactly the head footprint for a static type, or the 0x20
     *      envelope around a canonical body for a dynamic one. Reverts with
     *      InvalidTypeDescriptor on a malformed descriptor and InvalidValue
     *      at the offending offset otherwise. Returns whether `t` is dynamic
     *      for callers that need the shape anyway.
     */
    function validate(bytes calldata t, bytes memory v) internal pure returns (bool dynamic) {
        Context memory context;
        return validate(t, v, context);
    }

    /**
     * @dev `validate` reporting through `context` (see Context)
     */
    function validate(bytes calldata t, bytes memory v, Context memory context) internal pure returns (bool dynamic) {
        uint256 words;
        (dynamic, words) = shape(t);
        if (dynamic) validateDynamic(t, v, context);
        else requireValue(v.length % 32 == 0 && words == v.length / 32, 0, context);
    }

    /**
     * @dev `validate` for a caller that already parsed `t` into
     *      (dynamic, words) and keeps that shape across values instead of
     *      re-parsing per value
     */
    function validate(bytes calldata t, bytes memory v, bool dynamic, uint256 words) internal pure {
        Context memory context;
        if (dynamic) validateDynamic(t, v, context);
        else requireValue(v.length % 32 == 0 && words == v.length / 32, 0, context);
    }

    /**
     * @dev The dynamic half of `validate`: the envelope word must be 0x20
     *      and the body walk must consume the value exactly
     */
    function validateDynamic(bytes calldata t, bytes memory v, Context memory context) private pure {
        requireValue(word(v, 0, context) == 32, 0, context);
        requireValue(body(t, 0, t.length, v, 32, context) == v.length - 32, 32, context);
    }

    /**
     * @dev Cursor for the array and tuple walks in `body` and `unpack`: the
     *      descriptor position of the outermost suffix, the element count,
     *      the byte position where element heads begin, the element head
     *      footprint in words, the running tail size and whether elements
     *      are dynamic. A memory struct keeps the walk under the stack limit.
     */
    struct ArrayState {
        uint256 j;
        uint256 count;
        uint256 base;
        uint256 words;
        uint256 tail;
        bool dynamic;
    }

    /**
     * @dev Byte extent of the value of type t[s:e] encoded in place at `p`
     *      of `v`, validating canonical form on the way: every offset points
     *      exactly where the previous tail ended, every length fits the
     *      data, and bytes/string padding is zero. Only dynamic types reach
     *      the base-name branch (static children are covered by their
     *      parent's head footprint). Element counts are bounded against the
     *      remaining data before any multiplication, so a hostile length
     *      word cannot overflow the arithmetic.
     */
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

    // ============ Tuples and Arrays ============

    /**
     * @dev Parses a parenthesized tuple descriptor into a TupleLayout in a
     *      single pass: one byte scan counts the depth-0 components (and
     *      catches a stray `)`), then `typeShape` runs once per component.
     *      Reverts with InvalidTypeDescriptor when `t` is not a
     *      parenthesized tuple (a well-formed non-tuple at position 0, a
     *      malformed one at its own byte) or when a component is malformed.
     *      "()" yields an empty layout.
     */
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

    /**
     * @dev Requires `value` to be the canonical single-value encoding of
     *      tuple component `index`, whose descriptor is `t` and whose shape
     *      the caller already parsed into (dynamic, words). A static
     *      component must be exactly words * 32 bytes
     *      (InvalidComponentLength); a dynamic one must be a word-aligned
     *      envelope of at least two words starting with 0x20
     *      (InvalidComponentEnvelope) with a canonical body
     *      (InvalidComponentValue at the offending offset).
     */
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
        if (dynamic) validateDynamic(t, value, Context(ContextKind.TupleComponent, bytes4(0), index, 0, address(0)));
    }

    /**
     * @dev The canonical ABI encoding of the tuple `t` over one canonical
     *      single-value encoding per component: static components are
     *      copied into the head verbatim, dynamic ones have their 0x20
     *      envelope word stripped, the true offset written into the head
     *      and the tail appended. Because ABI offsets are frame-relative,
     *      verbatim tail splicing is correct at any nesting depth. Reverts
     *      with ComponentCountMismatch when args.length differs from the
     *      component count, and with validateComponent's errors when a
     *      value does not fit its declared type. The result has no
     *      envelope of its own: it is a calldata segment, or a tuple body
     *      the caller wraps.
     */
    function tuple(bytes calldata t, bytes[] memory args) internal pure returns (bytes memory) {
        return tuple(tupleLayout(t), t, args);
    }

    /**
     * @dev `tuple` over a layout the caller computed for `t` and may reuse
     *      across values
     */
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

    /**
     * @dev Whether a tuple with this layout is itself dynamic, which is the
     *      case as soon as one component is
     */
    function isDynamic(TupleLayout memory plan) internal pure returns (bool) {
        for (uint256 i; i < plan.dynamic.length; i++) {
            if (plan.dynamic[i]) return true;
        }
        return false;
    }

    /**
     * @dev Lays out already-validated values as one head-and-tail frame:
     *      `dynamic[i]` says whether values[i] is an envelope to splice or
     *      words to copy, and `headSize` is the head's byte length. With
     *      `array` set, every value shares dynamic[0] and the frame is
     *      prefixed by the 0x20 envelope word and the element count, which
     *      makes it abi.encode(T[]). Offsets inside the frame stay relative
     *      to the head start, as the ABI requires. The caller has validated
     *      every value against the plan; nothing is checked here.
     */
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

    /**
     * @dev The canonical abi.encode(T[]) of `values`, each of which must be
     *      the canonical single-value encoding of element type `t`
     *      (InvalidValue otherwise, InvalidTypeDescriptor for a malformed
     *      `t`). `unpack`'s inverse.
     */
    function pack(bytes calldata t, bytes[] memory values) internal pure returns (bytes memory) {
        (bool dynamic, uint256 words) = shape(t);
        for (uint256 i; i < values.length; i++) {
            validate(t, values[i]);
        }
        bool[] memory dynamics = new bool[](1);
        dynamics[0] = dynamic;
        return assemble(dynamics, values.length * words * 32, values, true);
    }

    /**
     * @dev Splits a canonical abi.encode(T[]) into one canonical
     *      single-value encoding per element, re-wrapping dynamic elements
     *      in their own 0x20 envelope. The whole input is validated on the
     *      way: the envelope word, the element count against the remaining
     *      data, every element offset and body, and exact consumption
     *      (InvalidValue at the offending offset). `pack`'s inverse.
     */
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
