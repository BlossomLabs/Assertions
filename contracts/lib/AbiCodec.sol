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
 *      `[]` or `[k]` suffixes. `bytes` and `string` are the dynamic base
 *      names, every other name is one 32-byte word. Validation also holds
 *      each static word to its base name's range, as solc's decoder does:
 *      uintN, address and bool words leave their high bits clear, intN
 *      words are sign-extended, bytesN and function words leave their low
 *      bits clear. The 256-bit types, and names that are not well-formed
 *      narrow ABI types, admit every word; their meaning stays the
 *      caller's claim. A "canonical single-value encoding" throughout
 *      this repo means abi.encode(value) of exactly one value: the bare
 *      static footprint (one word for a scalar, multiple for static tuples
 *      and fixed arrays), [0x20][tail] for a dynamic one, with tight
 *      offsets, zero padding and in-range words. Every function is
 *      internal and knows nothing of ERC-8211.
 */
library AbiCodec {
    // ============ Errors ============

    /**
     * @notice Thrown when an encoded value is not in canonical form at the
     *         given byte offset (a short buffer, a non-tight offset, a
     *         length overrunning the data, nonzero padding, a static word
     *         outside its type's range, or trailing bytes after the last
     *         tail)
     * @param offset The offending byte offset within the value (a word
     *        start, a dirty padding byte, or the expected end)
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
     *         envelope but a non-canonical body, or a static component
     *         has a word outside its type's range
     * @param index The component's position in the tuple
     * @param offset The offending byte offset within the value (a word
     *        start, a dirty padding byte, or the expected end)
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
            // The commonest names are recognised as one word and skipped whole;
            // the loop below still decides where the run ends, so the result
            // is the same position a byte-by-byte scan reaches.
            let head := calldataload(add(t.offset, p))
            if iszero(gt(add(p, 7), limit)) {
                let name := shr(200, head)
                // "uint256", "address", "bytes32"
                if or(eq(name, 0x75696e74323536), or(eq(name, 0x61646472657373), eq(name, 0x62797465733332))) {
                    q := add(p, 7)
                }
            }
            if eq(q, p) {
                // "string", "bytes", "bool"
                if and(iszero(gt(add(p, 6), limit)), eq(shr(208, head), 0x737472696e67)) { q := add(p, 6) }
                if and(iszero(gt(add(p, 5), limit)), eq(shr(216, head), 0x6279746573)) { q := add(p, 5) }
                if and(iszero(gt(add(p, 4), limit)), eq(shr(224, head), 0x626f6f6c)) { q := add(p, 4) }
            }
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
            while (q2 < limit) {
                uint8 c = byteAt(t, q2);
                if (c < 0x30 || c > 0x39 || k > type(uint32).max) break;
                k = k * 10 + (c - 0x30);
                q2++;
            }
            if (q2 == end + 1) {
                dyn = true;
                words = 1;
            } else if (!dyn) {
                words = words * k;
            }
            // A fixed length is 1 to 2^32 - 1 (solc refuses T[0]), and so is a static footprint.
            if (q2 >= limit || byteAt(t, q2) != RBRACKET || (k | words) > type(uint32).max || (k == 0 && q2 != end + 1))
            {
                revert InvalidTypeDescriptor(q2);
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
     *      parsed type. The commonest bare names are answered from one
     *      word compare of the whole descriptor, without the parse.
     */
    function shape(bytes calldata t) internal pure returns (bool dynamic, uint256 words) {
        // 1 for a static one-word name, 2 for a dynamic one. The length decides
        // which names can match, so padding past the descriptor is never read as one.
        uint256 hit;
        assembly ("memory-safe") {
            let w := calldataload(t.offset)
            switch t.length
            // "uint256", "address", "bytes32"
            case 7 {
                let n := shr(200, w)
                hit := or(eq(n, 0x75696e74323536), or(eq(n, 0x61646472657373), eq(n, 0x62797465733332)))
            }
            // "int256", "string"
            case 6 {
                let n := shr(208, w)
                hit := eq(n, 0x696e74323536)
                if eq(n, 0x737472696e67) { hit := 2 }
            }
            // "bytes"
            case 5 { if eq(shr(216, w), 0x6279746573) { hit := 2 } }
            // "bool"
            case 4 { hit := eq(shr(224, w), 0x626f6f6c) }
        }
        if (hit != 0) return (hit == 2, 1);
        uint256 end;
        (end, dynamic, words) = typeShape(t, 0, t.length);
        if (end != t.length) revert InvalidTypeDescriptor(end);
    }

    /**
     * @dev The base name starting at t[s] (bounded by `limit`): the
     *      position just past it and its canonical-word rule, as solc's
     *      decoder applies it. Kind 1 admits `bits` low bits (uintN,
     *      address, bool), kind 2 a value sign-extended from `bits` (intN),
     *      kind 3 `bits` high bits (bytesN, function). Kind 0 admits every
     *      word: the 256-bit types, and any name that is not a well-formed
     *      narrow ABI type, whose meaning stays the caller's claim. The
     *      recognised names are matched as one word and their width digits
     *      parsed in the same pass; only other names fall back to scanName.
     */
    function wordRule(bytes calldata t, uint256 s, uint256 limit)
        private
        pure
        returns (uint256 end, uint256 kind, uint256 bits)
    {
        assembly ("memory-safe") {
            let w := calldataload(add(t.offset, s))
            let w7 := shr(200, w)
            let p
            // The full-width names dominate word workloads and match first, loop-free:
            // "uint256", "bytes32", "int256".
            // Calldata padding may contain name bytes: match only inside the descriptor.
            if and(gt(sub(limit, s), 6), or(eq(w7, 0x75696e74323536), eq(w7, 0x62797465733332))) { p := 7 }
            if eq(shr(208, w), 0x696e74323536) { p := 6 }
            if iszero(p) {
                // "address"
                if eq(w7, 0x61646472657373) {
                    p := 7
                    kind := 1
                    bits := 160
                }
                // "function"
                if eq(shr(192, w), 0x66756e6374696f6e) {
                    p := 8
                    kind := 3
                    bits := 192
                }
                // "bool"
                if eq(shr(224, w), 0x626f6f6c) {
                    p := 4
                    kind := 1
                    bits := 1
                }
            }
            // The width families: "uint", "int", "bytes".
            if iszero(p) {
                if eq(shr(224, w), 0x75696e74) {
                    p := 4
                    kind := 1
                }
                if eq(shr(232, w), 0x696e74) {
                    p := 3
                    kind := 2
                }
                if eq(shr(216, w), 0x6279746573) {
                    p := 5
                    kind := 3
                }
            }
            end := add(s, p)
            // A match that reads past `limit` saw bytes of something else.
            if gt(end, limit) {
                end := s
                kind := 0
            }
            if and(gt(kind, 0), iszero(bits)) {
                for {} lt(end, limit) { end := add(end, 1) } {
                    let c := sub(byte(0, calldataload(add(t.offset, end))), 0x30)
                    // A leading zero or an oversized width stops here, where the
                    // digit left over makes the whole a name with no rule.
                    if or(gt(c, 9), or(gt(bits, 99), iszero(or(bits, c)))) { break }
                    bits := add(mul(bits, 10), c)
                }
                if eq(kind, 3) { bits := mul(bits, 8) }
                // No digits leaves zero width: bare "uint" and "int" are full-width.
                if or(or(iszero(bits), gt(bits, 248)), mod(bits, 8)) { kind := 0 }
            }
            // Any further name byte makes this another name, found by scanName.
            if lt(end, limit) {
                let c := byte(0, calldataload(add(t.offset, end)))
                if or(lt(sub(c, 0x30), 10), lt(sub(c, 0x61), 26)) { end := s }
            }
            if eq(end, s) { kind := 0 }
        }
        if (end == s) end = scanName(t, s, limit);
    }

    /**
     * @dev Walks `count` consecutive values of the STATIC type starting at
     *      t[s] (bounded by `limit`) encoded from `p` of `v`, checking every
     *      word against its base name's canonical-word rule (see wordRule)
     *      and reverting through `context` at the offending word. Parsing
     *      and checking share one pass over the descriptor; a base name
     *      under [k] suffixes resolves its rule once for all its words.
     *      Returns the position just past the type and the head footprint
     *      of one value in words. The caller has validated the descriptor
     *      and bounded the footprint against `v`. A zero `context` reports
     *      InvalidValue at the offending word's offset in `v`.
     */
    function checkWords(
        bytes calldata t,
        uint256 s,
        uint256 limit,
        uint256 count,
        bytes memory v,
        uint256 p,
        Context memory context
    ) internal pure returns (uint256 end, uint256 words) {
        if (byteAt(t, s) == LPAREN) {
            end = s;
            do {
                (uint256 next, uint256 w) =
                    checkWords(t, end + 1, limit, count == 0 ? 0 : 1, v, p + words * 32, context);
                words += w;
                end = next;
            } while (byteAt(t, end) == COMMA);
            uint256 copies;
            uint256 close = ++end;
            (end, copies) = suffixes(t, end, limit);
            // The first tuple was checked while parsing; walk its copies,
            // bounded at the tuple's own `)` so no copy re-reads the suffixes.
            for (uint256 i = 1; i < copies * count; i++) {
                checkWords(t, s, close, 1, v, p + i * words * 32, context);
            }
            words *= copies;
        } else {
            uint256 kind;
            uint256 bits;
            (end, kind, bits) = wordRule(t, s, limit);
            words = 1;
            if (end < limit) (end, words) = suffixes(t, end, limit);
            if (kind != 0) checkRule(kind, bits, words * count, v, p, context);
        }
    }

    /**
     * @dev The [k] suffixes from `end` of an already validated static
     *      type: the position past them and the product of their sizes
     */
    function suffixes(bytes calldata t, uint256 end, uint256 limit) private pure returns (uint256, uint256 product) {
        product = 1;
        unchecked {
            while (end < limit && byteAt(t, end) == LBRACKET) {
                uint256 k;
                while (byteAt(t, ++end) != RBRACKET) {
                    k = k * 10 + byteAt(t, end) - 0x30;
                }
                end++;
                product *= k;
            }
        }
        return (end, product);
    }

    /**
     * @dev Checks `n` consecutive words from `p` of `v` against one
     *      canonical-word rule (see wordRule), reverting through `context`
     *      at the first offending word. The words are read unchecked:
     *      every caller of checkWords has bounded the span against `v`.
     */
    function checkRule(uint256 kind, uint256 bits, uint256 n, bytes memory v, uint256 p, Context memory context)
        private
        pure
    {
        uint256 bad = n;
        assembly ("memory-safe") {
            let src := add(add(v, 32), p)
            for { let i := 0 } lt(i, n) { i := add(i, 1) } {
                let x := mload(add(src, shl(5, i)))
                let ok
                switch kind
                case 1 { ok := iszero(shr(bits, x)) }
                case 2 { ok := eq(signextend(sub(shr(3, bits), 1), x), x) }
                default { ok := iszero(shl(bits, x)) }
                if iszero(ok) {
                    bad := i
                    break
                }
            }
        }
        if (!(bad == n)) fail(p + bad * 32, context);
    }

    // ============ Values ============

    /**
     * @dev Reverts with the error `context` selects (see Context);
     *      `offset` is reported by the value-shaped errors. Callers test
     *      their condition inline and call this only on failure, so a
     *      passing check costs no call.
     */
    function fail(uint256 offset, Context memory context) private pure {
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
    function word(bytes memory data, uint256 p) internal pure returns (uint256 v) {
        if (p > data.length || data.length - p < 32) revert InvalidValue(p);
        assembly ("memory-safe") { v := mload(add(add(data, 32), p)) }
    }

    /**
     * @dev `word` reporting through `context` instead of InvalidValue
     */
    function word(bytes memory data, uint256 p, Context memory context) private pure returns (uint256 v) {
        if (!(p <= data.length && data.length - p >= 32)) fail(p, context);
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
        else validateStatic(t, v, words, context);
    }

    /**
     * @dev Whether `t` is one of the commonest one-word names and the
     *      first word of `v` is canonical for it, decided without a loop.
     *      False means "not decided here", for another type or a word out
     *      of range: the caller falls through to the general walk, which
     *      reports the error. The caller has established that `v` is
     *      exactly one word.
     */
    function wordOk(bytes calldata t, bytes memory v) private pure returns (bool ok) {
        assembly ("memory-safe") {
            let w := calldataload(t.offset)
            let x := mload(add(v, 32))
            switch t.length
            // "uint256" and "bytes32" admit every word, "address" 160 low bits
            case 7 {
                let n := shr(200, w)
                ok := or(
                    or(eq(n, 0x75696e74323536), eq(n, 0x62797465733332)),
                    and(eq(n, 0x61646472657373), iszero(shr(160, x)))
                )
            }
            // "bool"
            case 4 { ok := and(eq(shr(224, w), 0x626f6f6c), lt(x, 2)) }
        }
    }

    /**
     * @dev `validate` for a caller that already parsed `t` into
     *      (dynamic, words) and keeps that shape across values instead of
     *      re-parsing per value
     */
    function validate(bytes calldata t, bytes memory v, bool dynamic, uint256 words) internal pure {
        // Decided before a context is allocated: the commonest values need none.
        if (!dynamic && words == 1 && v.length == 32 && wordOk(t, v)) return;
        Context memory context;
        validate(t, v, dynamic, words, context);
    }

    /**
     * @dev The cached-shape `validate` reporting through `context`
     */
    function validate(bytes calldata t, bytes memory v, bool dynamic, uint256 words, Context memory context)
        internal
        pure
    {
        if (dynamic) validateDynamic(t, v, context);
        else validateStatic(t, v, words, context);
    }

    /**
     * @dev The static half of `validate`: exactly the head footprint, every
     *      word canonical for its base name
     */
    function validateStatic(bytes calldata t, bytes memory v, uint256 words, Context memory context) private pure {
        if (!(v.length % 32 == 0 && words == v.length / 32)) fail(0, context);
        if (words == 1 && wordOk(t, v)) return;
        checkWords(t, 0, t.length, 1, v, 0, context);
    }

    /**
     * @dev The dynamic half of `validate`: the envelope word must be 0x20
     *      and the body walk must consume the value exactly
     */
    function validateDynamic(bytes calldata t, bytes memory v, Context memory context) private pure {
        if (!(word(v, 0, context) == 32)) fail(0, context);
        uint256 end = 32 + body(t, 0, t.length, v, 32, context);
        if (!(end == v.length)) fail(end, context);
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
     *      data, bytes/string padding is zero and static words are in
     *      range (see checkWords). Only dynamic types reach
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
        if (!(p <= v.length)) fail(p, context);
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
            if (!(x.count <= (v.length - x.base) / 32 / x.words)) fail(x.base, context);
            x.tail = x.count * x.words * 32;
            // Static bodies contain no offsets or byte padding: the bounded head is the complete body.
            if (!x.dynamic) {
                checkWords(t, s, x.j, x.count, v, x.base, context);
                return x.base - p + x.tail;
            }
            for (uint256 i; i < x.count; i++) {
                uint256 position = x.base + i * x.words * 32;
                if (!(word(v, position, context) == x.tail)) fail(position, context);
                x.tail += body(t, s, x.j, v, x.base + x.tail, context);
            }
            return x.base - p + x.tail;
        }
        if (t[s] == "(") {
            ArrayState memory x;
            x.j = s + 1;
            while (x.j < e - 1) {
                (uint256 next,, uint256 w) = typeShape(t, x.j, e - 1);
                if (!(w <= (v.length - p - x.tail) / 32)) fail(p, context);
                x.tail += w * 32;
                x.j = next + 1;
            }
            x.j = s + 1;
            while (x.j < e - 1) {
                (uint256 next, bool dynamic, uint256 w) = typeShape(t, x.j, e - 1);
                if (dynamic) {
                    if (!(word(v, p + x.base, context) == x.tail)) fail(p + x.base, context);
                    x.tail += body(t, x.j, next, v, p + x.tail, context);
                } else {
                    checkWords(t, x.j, next, 1, v, p + x.base, context);
                }
                x.base += w * 32;
                x.j = next + 1;
            }
            return x.tail;
        }
        // Only dynamic children reach this function; a base type here is bytes/string.
        uint256 n = word(v, p, context);
        if (!(n <= v.length - p - 32)) fail(p, context);
        uint256 padded = (n + 31) / 32 * 32;
        if (!(padded <= v.length - p - 32)) fail(p, context);
        uint256 padding = padded - n;
        if (padding != 0 && word(v, p + padded, context) & (type(uint256).max >> ((32 - padding) * 8)) != 0) {
            // The common canonical case checks one word; scan only to locate an error.
            for (uint256 i = n; i < padded; i++) {
                if (!(v[p + 32 + i] == 0)) fail(p + 32 + i, context);
            }
        }
        return 32 + padded;
    }

    // ============ Tuples and Arrays ============

    /**
     * @dev Parses a parenthesized tuple descriptor into a TupleLayout in a
     *      single pass: `typeShape` runs once per component, each followed
     *      by a comma or by the tuple's closing parenthesis. Reverts with
     *      InvalidTypeDescriptor when `t` is not a parenthesized tuple (a
     *      well-formed non-tuple at position 0, a malformed one at its own
     *      byte) or at the first byte the parse cannot accept: a malformed
     *      component, or a stray `)` where a comma or the end belongs.
     *      "()" reverts with InvalidTypeDescriptor(1); call constructors
     *      handle their empty argument lists before calling this helper.
     *      The component count is not known before the parse, so the four
     *      arrays are allocated for the most the descriptor could hold and
     *      their lengths set afterwards: k components take at least 2k - 1
     *      bytes (a byte each and the commas) of the t.length - 2 between
     *      the parentheses, so k is at most (t.length - 1) / 2, rounded
     *      down.
     */
    function tupleLayout(bytes calldata t) internal pure returns (TupleLayout memory plan) {
        if (t.length < 2 || byteAt(t, 0) != LPAREN || byteAt(t, t.length - 1) != RPAREN) {
            // Not a parenthesized tuple. `shape` reports a malformed descriptor at
            // its own byte; a well-formed non-tuple is rejected at position 0.
            shape(t);
            revert InvalidTypeDescriptor(0);
        }
        uint256 limit = t.length - 1;
        uint256 cap = limit / 2;
        // One allocation for the four arrays, each `cap` elements after its length word.
        assembly ("memory-safe") {
            let size := shl(5, add(cap, 1))
            let a := mload(0x40)
            for { let k := 0 } lt(k, 4) { k := add(k, 1) } {
                mstore(add(plan, shl(5, k)), add(a, mul(k, size)))
            }
            mstore(0x40, add(a, shl(2, size)))
        }
        uint256 p = 1;
        uint256 count;
        uint256 head;
        while (true) {
            (uint256 end, bool dynamic, uint256 words) = typeShape(t, p, limit);
            count++;
            // `count` is at most `cap`, the capacity of all four arrays.
            assembly ("memory-safe") {
                let slot := shl(5, count)
                mstore(add(mload(plan), slot), p)
                mstore(add(mload(add(plan, 0x20)), slot), end)
                mstore(add(mload(add(plan, 0x40)), slot), dynamic)
                mstore(add(mload(add(plan, 0x60)), slot), words)
            }
            head += words * 32;
            if (end == limit) break;
            if (byteAt(t, end) != COMMA) revert InvalidTypeDescriptor(end);
            p = end + 1;
        }
        plan.headSize = head;
        // The lengths, now that the count is known.
        assembly ("memory-safe") {
            mstore(mload(plan), count)
            mstore(mload(add(plan, 0x20)), count)
            mstore(mload(add(plan, 0x40)), count)
            mstore(mload(add(plan, 0x60)), count)
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
        } else if (value.length != words * 32) {
            // Fixed-array footprints are capped; bare tuple widths sum their components.
            // A parsed descriptor cannot express enough words to overflow this byte size.
            revert InvalidComponentLength(index, words * 32, value.length);
        }
        if (!dynamic && words == 1 && wordOk(t, value)) return;
        Context memory context = Context(ContextKind.TupleComponent, bytes4(0), index, 0, address(0));
        if (dynamic) validateDynamic(t, value, context);
        else checkWords(t, 0, t.length, 1, value, 0, context);
    }

    /**
     * @dev The descriptor of component `index` of the tuple `plan` was
     *      parsed from: `tupleLayout` set its span inside `t`, so the slice
     *      needs no second bounds check. `index` is checked against the
     *      component count.
     */
    function component(TupleLayout memory plan, bytes calldata t, uint256 index)
        internal
        pure
        returns (bytes calldata c)
    {
        uint256 start = plan.starts[index];
        uint256 end = plan.ends[index];
        assembly ("memory-safe") {
            c.offset := add(t.offset, start)
            c.length := sub(end, start)
        }
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
            validateComponent(component(plan, t, i), args[i], i, plan.dynamic[i], plan.words[i]);
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
     *      every value against the plan and passes one flag per value (or
     *      the single shared flag of an array); nothing is checked here.
     */
    function assemble(bool[] memory dynamic, uint256 headSize, bytes[] memory values, bool array)
        internal
        pure
        returns (bytes memory out)
    {
        return assemble(dynamic, headSize, values, array, 0);
    }

    /**
     * @dev `assemble` with `lead` zeroed bytes before the frame (at most
     *      32), where a caller copies a selector without copying the
     *      frame again. One pass: the head size is known, so each value is
     *      copied straight to its place and the length written last. Every
     *      value is whole words (the caller validated them), so the frame
     *      has no gaps; the word after it is zeroed so no stale memory
     *      follows a length that `lead` leaves unaligned.
     */
    function assemble(bool[] memory dynamic, uint256 headSize, bytes[] memory values, bool array, uint256 lead)
        internal
        pure
        returns (bytes memory out)
    {
        assembly ("memory-safe") {
            out := mload(0x40)
            let count := mload(values)
            let start := add(add(out, 32), lead)
            // Zeroes the lead; the frame overwrites the rest of this word.
            mstore(add(out, 32), 0)
            if array {
                mstore(start, 32)
                mstore(add(start, 32), count)
                start := add(start, 64)
            }
            let head := start
            let tail := add(start, headSize)
            // `dynamic` holds one flag per value, or a single flag for an array.
            let single := iszero(array)
            for { let i := 0 } lt(i, count) { i := add(i, 1) } {
                let v := mload(add(add(values, 32), shl(5, i)))
                let n := mload(v)
                switch mload(add(add(dynamic, 32), shl(5, mul(i, single))))
                case 0 {
                    mcopy(head, add(v, 32), n)
                    head := add(head, n)
                }
                default {
                    mstore(head, sub(tail, start))
                    n := sub(n, 32)
                    mcopy(tail, add(v, 64), n)
                    head := add(head, 32)
                    tail := add(tail, n)
                }
            }
            mstore(tail, 0)
            let size := sub(tail, add(out, 32))
            mstore(out, size)
            // The free pointer stays word-aligned whatever `lead` is.
            mstore(0x40, add(add(out, 32), and(add(size, 31), not(31))))
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
        Context memory context;
        for (uint256 i; i < values.length; i++) {
            validate(t, values[i], dynamic, words, context);
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
        if (x.count > (encoded.length - 64) / 32 / x.words) revert InvalidValue(64);
        x.tail = x.count * x.words * 32;
        values = new bytes[](x.count);
        Context memory context;
        if (!x.dynamic) checkWords(t, 0, t.length, x.count, encoded, 64, context);
        for (uint256 i; i < x.count; i++) {
            uint256 p = 64 + i * x.words * 32;
            if (x.dynamic) {
                if (word(encoded, p) != x.tail) revert InvalidValue(p);
                uint256 n = body(t, 0, t.length, encoded, 64 + x.tail, context);
                values[i] = bytes.concat(abi.encode(uint256(32)), slice(encoded, 64 + x.tail, n));
                x.tail += n;
            } else {
                values[i] = slice(encoded, p, x.words * 32);
            }
        }
        if (64 + x.tail != encoded.length) revert InvalidValue(64 + x.tail);
    }
}
