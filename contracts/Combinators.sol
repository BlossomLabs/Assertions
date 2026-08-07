// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Combinators
 * @author Sembrestels
 * @notice Small composable building blocks for the Assertions core: chained
 *         reads, arithmetic, bitwise, comparison and boolean logic over view
 *         call results, plus hashing, string splitting, constants and
 *         environment getters. Assertions judge, Combinators compute.
 * @dev Every function is a combinator — a building block that computes and
 *      returns a value, never an assertion. Operands are (target, data) pairs,
 *      and because an operand may itself be a call to this contract, nested
 *      operands in calldata compose the combinators into arbitrary expressions.
 *      The frozen Assertions core judges the final value: point any call
 *      assertion at this contract's address with the encoded expression as
 *      data, e.g. assertGtCallUint(combinators, abi.encodeCall(calcUint, (...)), 0).
 *      Combinators is the versionable periphery to the frozen core — its
 *      functions are stateless view targets, so old versions never break and
 *      new versions deploy at new addresses without touching the core.
 * @custom:version 1.0
 */
contract Combinators {
    // ============ Custom Errors ============

    /// @notice Thrown when a staticcall to a target contract fails
    ///         (within a chain or an operand, identifies the exact failing call)
    /// @param target The contract address that was called
    /// @param data The calldata that was sent
    error CallFailed(address target, bytes data);

    /// @notice Thrown when returndata is too short to decode the expected value
    /// @param index The requested element index as given (0 for single-value
    ///        decodes; may be negative for uintCall's from-the-end indexing)
    /// @param length The length of the returned data in bytes
    error ReturnDataOutOfBounds(int256 index, uint256 length);

    /// @notice Thrown when chainCall receives an empty calls array
    error EmptyCallChain();

    /// @notice Thrown when a non-final chain entry is shorter than its
    ///         32-byte word-index prefix
    /// @param hopIndex The position of the malformed entry in `calls`
    /// @param length The length of the entry in bytes
    error MalformedChainHop(uint256 hopIndex, uint256 length);

    /// @notice Thrown when the selected return word of a non-final chain hop
    ///         is not a clean address (upper 12 bytes non-zero)
    /// @param hopIndex The position of the hop in `calls`
    /// @param word The raw 32-byte word that was selected
    error InvalidChainAddress(uint256 hopIndex, bytes32 word);

    /// @notice Thrown when splitCall receives an empty delimiter
    error EmptyDelimiter();

    /// @notice Thrown when splitCall's segment index is outside the segments
    ///         the split produced (in either direction for negative indices)
    /// @param index The requested segment index, as given (may be negative)
    /// @param segments The number of segments the split produced
    error SegmentIndexOutOfBounds(int256 index, uint256 segments);

    /// @notice Thrown when includesCall receives an empty search string —
    ///         every string vacuously contains "", so the assertion would
    ///         always pass and is certainly a mistake
    error EmptySubstring();

    /// @notice Thrown when an operation is not supported for the value type,
    ///         currently only calcInt with ArithOp.Exp (Solidity defines `**`
    ///         for unsigned operands only, so signed exponentiation is ill-defined)
    error UnsupportedOp();

    // ============ Types ============

    /// @notice Arithmetic operations for calcUint / calcInt
    /// @dev ABI-encoded as uint8: Add = 0, Sub = 1, Mul = 2, Div = 3, Mod = 4,
    ///      Exp = 5 (calcUint only; calcInt reverts with UnsupportedOp on Exp),
    ///      Min = 6, Max = 7, AbsDiff = 8
    enum ArithOp {
        Add,
        Sub,
        Mul,
        Div,
        Mod,
        Exp,
        Min,
        Max,
        AbsDiff
    }

    /// @notice Logic operations for logicBool
    /// @dev ABI-encoded as uint8: And = 0, Or = 1, Xor = 2
    enum LogicOp {
        And,
        Or,
        Xor
    }

    /// @notice Comparison operations for cmpUint / cmpInt
    /// @dev ABI-encoded as uint8: Eq = 0, Ne = 1, Gt = 2, Lt = 3, Ge = 4, Le = 5
    enum CmpOp {
        Eq,
        Ne,
        Gt,
        Lt,
        Ge,
        Le
    }

    /// @notice Bitwise operations for bitUint
    /// @dev ABI-encoded as uint8: And = 0, Or = 1, Xor = 2, Shl = 3, Shr = 4
    enum BitOp {
        And,
        Or,
        Xor,
        Shl,
        Shr
    }

    // ============ Call Chaining ============

    /// @notice Resolves a chain of staticcalls: calls[0] is executed on `target`, each
    ///         intermediate return value is decoded as the next hop's target address,
    ///         and the FINAL call's returndata is returned verbatim.
    /// @dev The raw assembly return is intentional: the final hop's returndata passes
    ///      through byte-for-byte, so any call assertion (uint/int/address/bool/bytes32,
    ///      tuple-indexed, array-length, approx) can decode it exactly as if it had
    ///      called the final target directly. That is why the function declares no ABI
    ///      return type — an ABI-encoded `bytes` return would wrap the payload in an
    ///      extra offset/length envelope and break that transparency.
    ///      Point any core call assertion at this contract with chainCall calldata:
    ///      `core.assertEqCallStringN(combinators, abi.encodeCall(Combinators.chainCall, (pool, hops)), 0, "WETH")`.
    ///      Hop encoding: every entry except the last carries a 32-byte prefix —
    ///      `abi.encodePacked(uint256 wordIndex, abi.encodeCall(...))` — naming the
    ///      static return word that holds the next hop's address (0 for a plain
    ///      single-address return); the final entry is unprefixed abi.encodeCall
    ///      data. This lets a hop return several values and still chain, e.g.
    ///      selecting the token of a `(uint112, uint112, address)` pool getter.
    ///      Reverts with EmptyCallChain when `calls` is empty, MalformedChainHop
    ///      when a non-final entry is shorter than its prefix, CallFailed
    ///      identifying the exact failing hop when a hop reverts or targets a
    ///      code-less address, ReturnDataOutOfBounds when a non-final hop returns
    ///      fewer than the `wordIndex * 32 + 32` bytes needed to read the selected
    ///      word, and InvalidChainAddress when that word has dirty upper bytes.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        above); every hop except the last must expose an address at its
    ///        selected return word
    function chainCall(address target, bytes[] calldata calls) external view {
        bytes memory result = _resolveChain(target, calls);
        assembly {
            return(add(result, 32), mload(result))
        }
    }

    /// @notice Returns keccak256 of a resolved call chain's final returndata
    /// @dev Lets the existing bytes32 assertions check complex or hard-to-decode
    ///      returns (structs, arrays, long strings) against a precomputed hash:
    ///      `core.assertEqCallBytes32(combinators, abi.encodeCall(Combinators.hashCall,
    ///      (target, calls)), expectedHash)`. A single call is a one-element array.
    ///      Chain resolution and failure behavior are identical to chainCall.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word
    /// @return The keccak256 hash of the final call's raw returndata
    function hashCall(address target, bytes[] calldata calls) external view returns (bytes32) {
        return keccak256(_resolveChain(target, calls));
    }

    /// @notice Resolves a call chain, decodes the final return as a string, splits it by
    ///         a delimiter, and returns the index-th segment (0-based; negative
    ///         indices count from the end, -1 = last)
    /// @dev Returns a normal ABI-encoded string, so every string assertion and any
    ///      composition site consumes it directly, e.g. "the second word of name() is LP":
    ///      `core.assertEqCallStringN(combinators, abi.encodeCall(Combinators.splitCall,
    ///      (pool, calls, " ", 1)), 0, "LP")`. Negative indices resolve against the
    ///      segment count at execution time, so "the name ends with LP" is index -1
    ///      with delimiter " " — no composition-time segment counting required.
    ///      Split semantics: the delimiter is a non-empty exact byte sequence; segments
    ///      are the maximal runs between occurrences, so adjacent delimiters produce
    ///      empty segments and a string without the delimiter is one segment (index 0 =
    ///      -1 = the whole string). Reverts with EmptyDelimiter on an empty delimiter
    ///      and with SegmentIndexOutOfBounds(index, segments) when the index lies
    ///      outside the segments in either direction (valid range is
    ///      -segments .. segments-1). The final return value is validated (head offset
    ///      and length) the same way tuple-indexed string assertions validate
    ///      returndata, and chain resolution failures behave exactly as in chainCall.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word, and the last must return a string
    /// @param delimiter The non-empty byte sequence to split on
    /// @param index The segment index to return: 0-based from the start, or
    ///        negative from the end (-1 = last segment)
    /// @return The selected segment of the split string
    function splitCall(address target, bytes[] calldata calls, string calldata delimiter, int256 index) external view returns (string memory) {
        bytes memory delim = bytes(delimiter);
        if (delim.length == 0) revert EmptyDelimiter();
        bytes memory str = _decodeString(_resolveChain(target, calls));

        uint256 segments = _countSegments(str, delim);
        uint256 wanted;
        if (index < 0) {
            // index == type(int256).min is caught here before -index could overflow.
            if (index < -int256(segments)) revert SegmentIndexOutOfBounds(index, segments);
            wanted = segments - uint256(-index);
        } else {
            if (uint256(index) >= segments) revert SegmentIndexOutOfBounds(index, segments);
            wanted = uint256(index);
        }

        uint256 start = 0;
        uint256 segment = 0;
        uint256 i = 0;
        while (i + delim.length <= str.length) {
            if (_matchesAt(str, delim, i)) {
                if (segment == wanted) return string(_slice(str, start, i));
                segment++;
                i += delim.length;
                start = i;
            } else {
                i++;
            }
        }
        // _countSegments guarantees `wanted` names the trailing segment here.
        return string(_slice(str, start, str.length));
    }

    /// @notice Resolves a call chain, decodes the final return as a string, and
    ///         returns whether it contains `part` as a substring
    /// @dev Matching is an exact byte-sequence search — case-sensitive, no
    ///      wildcards; a multi-byte UTF-8 `part` matches its exact byte encoding.
    ///      Returns a bool so the outcome composes with logicBool / notBool
    ///      ("name does NOT mention X" is notBool over includesCall) and asserts
    ///      via assertTrue / assertFalse / assertEqCallBool, e.g. "the pool name
    ///      mentions LP": `core.assertTrue(combinators,
    ///      abi.encodeCall(Combinators.includesCall, (pool, calls, "LP")))`.
    ///      Reverts with EmptySubstring on an empty `part` (vacuously true —
    ///      certainly a mistake). The final return value is validated (head
    ///      offset and length) the same way splitCall validates it, and chain
    ///      resolution failures behave exactly as in chainCall. A single call is
    ///      a one-element array.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word, and the last must return a string
    /// @param part The non-empty byte sequence to search for
    /// @return Whether the decoded string contains `part`
    function includesCall(address target, bytes[] calldata calls, string calldata part) external view returns (bool) {
        bytes memory needle = bytes(part);
        if (needle.length == 0) revert EmptySubstring();
        bytes memory str = _decodeString(_resolveChain(target, calls));
        if (needle.length > str.length) return false;
        for (uint256 i = 0; i + needle.length <= str.length; i++) {
            if (_matchesAt(str, needle, i)) return true;
        }
        return false;
    }

    /// @notice Resolves a call chain, decodes the final return as a string, and
    ///         returns whether every byte of it is in the `allowed` character set
    /// @dev Character-class check without a regex engine: `allowed` is a 256-bit
    ///      set where bit i covers byte value i, so a single uint256 spans the
    ///      whole byte alphabet. Build the mask off-chain from ranges and
    ///      individual bytes — lowercase a-z is bits 97..122 (0x07fffffe << 96),
    ///      digits 0-9 bits 48..57, and OR in single bytes like "-" (bit 45).
    ///      The check is byte-level: every byte of a multi-byte UTF-8 character
    ///      is >= 0x80, so such characters fail any ASCII-only mask — the strict
    ///      reading of "only lowercase ASCII". An empty string is vacuously true
    ///      (combine with arrayLengthCall > 0 to also require non-empty). Returns
    ///      a bool for logicBool / notBool composition, asserted via assertTrue /
    ///      assertFalse / assertEqCallBool, e.g. "the symbol is lowercase":
    ///      `core.assertTrue(combinators, abi.encodeCall(Combinators.charsetCall,
    ///      (token, calls, 0x07fffffe << 96)))`. The final return value is
    ///      validated (head offset and length) the same way splitCall validates
    ///      it, and chain resolution failures behave exactly as in chainCall.
    ///      A single call is a one-element array.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word, and the last must return a string
    /// @param allowed Bitmap of permitted byte values (bit i set ⇔ byte i allowed)
    /// @return Whether every byte of the decoded string is in the allowed set
    function charsetCall(address target, bytes[] calldata calls, uint256 allowed) external view returns (bool) {
        bytes memory str = _decodeString(_resolveChain(target, calls));
        for (uint256 i = 0; i < str.length; i++) {
            if (allowed & (1 << uint8(str[i])) == 0) return false;
        }
        return true;
    }

    /// @notice Resolves a call chain and returns the wordIndex-th 32-byte word of the
    ///         final returndata as a uint256 (0-based; negative indices count from
    ///         the end, -1 = last word)
    /// @dev Raw word extraction for static-layout returns (multi-value tuples like
    ///      getReserves()), NOT an ABI decoder: word positions follow the raw encoding,
    ///      so dynamic types (strings, arrays) contribute head offsets, not their
    ///      content. The word is returned as uint256, which also covers bytes32 and
    ///      address words at the word level — compare or combine via cmpUint / calcUint.
    ///      Negative indices resolve against the word count at execution time, so
    ///      -1 selects the last word — for a single dynamic array return that is its
    ///      last element, whatever the live length. Reverts with
    ///      ReturnDataOutOfBounds(wordIndex, length) when the index lies outside the
    ///      full 32-byte words of the returndata in either direction (valid range is
    ///      -words .. words-1 with words = length / 32); chain resolution failures
    ///      behave exactly as in chainCall. A single call is a one-element array.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word
    /// @param wordIndex The index of the 32-byte word to extract: 0-based from the
    ///        start, or negative from the end (-1 = last word)
    /// @return The extracted word as a uint256
    function uintCall(address target, bytes[] calldata calls, int256 wordIndex) external view returns (uint256) {
        bytes memory result = _resolveChain(target, calls);
        uint256 words = result.length / 32;
        uint256 wanted;
        if (wordIndex < 0) {
            // wordIndex == type(int256).min is caught here before -wordIndex could overflow.
            if (wordIndex < -int256(words)) revert ReturnDataOutOfBounds(wordIndex, result.length);
            wanted = words - uint256(-wordIndex);
        } else {
            if (uint256(wordIndex) >= words) revert ReturnDataOutOfBounds(wordIndex, result.length);
            wanted = uint256(wordIndex);
        }
        uint256 word;
        assembly {
            word := mload(add(add(result, 32), mul(wanted, 32)))
        }
        return word;
    }

    /// @notice Resolves a call chain and returns the byte length of the final returndata
    /// @dev Length of the raw ABI-encoded return, not a decoded element count: a
    ///      uint256[] with n items returns 64 + n * 32 (offset word + length word +
    ///      items), so item counts derive arithmetically via calcUint. Chain resolution
    ///      failures behave exactly as in chainCall; a single call is a one-element array.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word
    /// @return The byte length of the final call's returndata
    function lengthCall(address target, bytes[] calldata calls) external view returns (uint256) {
        return _resolveChain(target, calls).length;
    }

    /// @notice Resolves a call chain and returns the decoded length of the final
    ///         dynamic return value (array element count, or string/bytes byte length)
    /// @dev Decoded counterpart of lengthCall for a single dynamic return value:
    ///      validates the head offset the same way the core's array-length assertions
    ///      do, then returns the length word. For a T[] return this is the element
    ///      count regardless of element size; string and bytes returns share the same
    ///      encoding, so their byte length comes back (UTF-8 characters may span
    ///      multiple bytes). Canonical use is a length as an expression operand, e.g.
    ///      "holder list is as long as reward list": cmpUint(Eq, combinators,
    ///      abi.encodeCall(Combinators.arrayLengthCall, (a, callsA)), combinators,
    ///      abi.encodeCall(Combinators.arrayLengthCall, (b, callsB))). Reverts with
    ///      ReturnDataOutOfBounds when the final return is not a single well-formed
    ///      dynamic value; chain resolution failures behave exactly as in chainCall.
    ///      A single call is a one-element array.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word, and the last must return a
    ///        single dynamic value (array, string, or bytes)
    /// @return The decoded length of the final call's dynamic return value
    function arrayLengthCall(address target, bytes[] calldata calls) external view returns (uint256) {
        return _dynLength(_resolveChain(target, calls));
    }

    // ============ Arithmetic Composition ============

    /// @notice Combines the uint256 results of two staticcalls with an arithmetic operation
    /// @dev Composition primitive: operands are (target, data) pairs and may themselves be
    ///      calls to this contract (chainCall, calcUint, calcInt, ethBalance, ...), enabling
    ///      recursive combinators such as (a.x() + b.y()) * c.z(). The result is returned as
    ///      a plain uint256, so any core call assertion can consume calcUint calldata directly:
    ///      `core.assertGtCallUint(combinators, abi.encodeCall(Combinators.calcUint, (...)), 0)`.
    ///      Uses Solidity 0.8 checked arithmetic: overflow/underflow reverts with Panic(0x11)
    ///      (including Exp overflow) and division or modulo by zero with Panic(0x12). An
    ///      operand that reverts or targets a code-less address reverts with CallFailed
    ///      identifying it; an operand returning fewer than 32 bytes reverts with
    ///      ReturnDataOutOfBounds. For Exp, operand1 is the base and operand2 the exponent
    ///      (0 ** 0 == 1 per EVM semantics) — canonical use is live decimals scaling,
    ///      e.g. 5 * 10 ** token.decimals() as nested calcUint(Mul, ..., calcUint(Exp, ...)).
    ///      AbsDiff is |a - b| and never underflows — combined with a Le assertion it
    ///      expresses live-vs-live approximate equality (|oracleA - oracleB| <= delta),
    ///      which the core's ApproxEq cannot (its expected side is a constant).
    /// @param op The operation to apply (Add = 0, Sub = 1, Mul = 2, Div = 3, Mod = 4,
    ///        Exp = 5, Min = 6, Max = 7, AbsDiff = 8)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The result of applying op to the two decoded uint256 operands
    function calcUint(ArithOp op, address target1, bytes calldata data1, address target2, bytes calldata data2) external view returns (uint256) {
        uint256 a = uint256(_callWord(target1, data1));
        uint256 b = uint256(_callWord(target2, data2));
        if (op == ArithOp.Add) return a + b;
        if (op == ArithOp.Sub) return a - b;
        if (op == ArithOp.Mul) return a * b;
        if (op == ArithOp.Div) return a / b;
        if (op == ArithOp.Mod) return a % b;
        if (op == ArithOp.Exp) return a ** b;
        if (op == ArithOp.Min) return a < b ? a : b;
        if (op == ArithOp.Max) return a > b ? a : b;
        return a > b ? a - b : b - a;
    }

    /// @notice Combines the int256 results of two staticcalls with an arithmetic operation
    /// @dev Signed counterpart of calcUint; see its documentation for the composition
    ///      pattern and revert behavior. Signed semantics follow Solidity 0.8: Sub may go
    ///      negative, Div truncates toward zero (so -7 / 2 == -3 and 45 / -7 == -6), Mod
    ///      takes the sign of the dividend (so 45 % -7 == 3 and -45 % 7 == -3), and
    ///      type(int256).min / -1 reverts with Panic(0x11). Exp reverts with UnsupportedOp:
    ///      Solidity defines `**` for unsigned operands only, so signed exponentiation is
    ///      ill-defined — use calcUint for power expressions. AbsDiff returns |a - b| as
    ///      an int256, so a span wider than type(int256).max (opposite-sign extremes)
    ///      overflows the checked subtraction and reverts with Panic(0x11).
    /// @param op The operation to apply (Add = 0, Sub = 1, Mul = 2, Div = 3, Mod = 4,
    ///        Min = 6, Max = 7, AbsDiff = 8; Exp = 5 reverts with UnsupportedOp)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The result of applying op to the two decoded int256 operands
    function calcInt(ArithOp op, address target1, bytes calldata data1, address target2, bytes calldata data2) external view returns (int256) {
        if (op == ArithOp.Exp) revert UnsupportedOp();
        int256 a = int256(uint256(_callWord(target1, data1)));
        int256 b = int256(uint256(_callWord(target2, data2)));
        if (op == ArithOp.Add) return a + b;
        if (op == ArithOp.Sub) return a - b;
        if (op == ArithOp.Mul) return a * b;
        if (op == ArithOp.Div) return a / b;
        if (op == ArithOp.Mod) return a % b;
        if (op == ArithOp.Min) return a < b ? a : b;
        if (op == ArithOp.Max) return a > b ? a : b;
        return a > b ? a - b : b - a;
    }

    // ============ Bitwise Composition ============

    /// @notice Combines the uint256 results of two staticcalls with a bitwise operation
    /// @dev Same composition pattern as calcUint (operands nest recursively). For Shl
    ///      and Shr, operand2 is the shift amount; shifts of 256 or more yield 0 per
    ///      EVM shift semantics (no revert). Canonical use is flag/bitmask checks on
    ///      packed config words, with constantUint supplying the mask or shift:
    ///      `config & MASK != 0` is assertNeCallUint over bitUint(And, ...), and
    ///      `(config >> N) & 1 == 1` nests a Shr inside an And.
    /// @param op The operation to apply (And = 0, Or = 1, Xor = 2, Shl = 3, Shr = 4)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call (shift amount for Shl/Shr)
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The result of applying op to the two decoded uint256 operands
    function bitUint(BitOp op, address target1, bytes calldata data1, address target2, bytes calldata data2) external view returns (uint256) {
        uint256 a = uint256(_callWord(target1, data1));
        uint256 b = uint256(_callWord(target2, data2));
        if (op == BitOp.And) return a & b;
        if (op == BitOp.Or) return a | b;
        if (op == BitOp.Xor) return a ^ b;
        if (op == BitOp.Shl) return a << b;
        return a >> b;
    }

    /// @notice Returns the bitwise complement of a staticcall's uint256 result
    /// @dev Unary NOT for bitwise composition; see bitUint for operand semantics.
    /// @param target The contract address of the operand call
    /// @param data The encoded operand call (use abi.encodeCall)
    /// @return The complement of the decoded uint256 result
    function bitNotUint(address target, bytes calldata data) external view returns (uint256) {
        return ~uint256(_callWord(target, data));
    }

    // ============ Logic & Comparison Composition ============

    /// @notice Combines the bool results of two staticcalls with a logic operation
    /// @dev Both operands are ALWAYS evaluated (no short-circuit) since they are view
    ///      calls executed before the operation is applied. Operands are decoded with
    ///      abi.decode, so a returned word that is not exactly 0 or 1 reverts. Operands
    ///      may themselves be calls to this contract (cmpUint, cmpInt, notBool,
    ///      logicBool, ...), enabling nested boolean combinators asserted via
    ///      assertEqCallBool / assertTrue / assertFalse.
    /// @param op The operation to apply (And = 0, Or = 1, Xor = 2)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The result of applying op to the two decoded bool operands
    function logicBool(LogicOp op, address target1, bytes calldata data1, address target2, bytes calldata data2) external view returns (bool) {
        bool a = _callBool(target1, data1);
        bool b = _callBool(target2, data2);
        if (op == LogicOp.And) return a && b;
        if (op == LogicOp.Or) return a || b;
        return a != b;
    }

    /// @notice Returns the negated bool result of a staticcall
    /// @dev Unary NOT for boolean composition; see logicBool for operand semantics.
    /// @param target The contract address of the operand call
    /// @param data The encoded operand call (use abi.encodeCall)
    /// @return The negation of the decoded bool result
    function notBool(address target, bytes calldata data) external view returns (bool) {
        return !_callBool(target, data);
    }

    /// @notice Returns 1 if the call returns true, 0 if it returns false
    /// @dev Bridge from boolean to arithmetic composition, enabling the
    ///      conditional-select idiom cond * a + (1 - cond) * b via nested calcUint —
    ///      an expression-level `if`. The operand is decoded strictly like logicBool
    ///      operands: a returned word that is not exactly 0 or 1 reverts.
    /// @param target The contract address of the operand call
    /// @param data The encoded operand call (use abi.encodeCall)
    /// @return 1 for true, 0 for false
    function boolToUint(address target, bytes calldata data) external view returns (uint256) {
        return _callBool(target, data) ? 1 : 0;
    }

    /// @notice Compares the uint256 results of two staticcalls and returns the outcome
    /// @dev Unlike the assert functions (which revert on failure), cmpUint RETURNS the
    ///      comparison result, so outcomes can be combined with logicBool / notBool.
    ///      Compare against a literal by using constantUint as the other operand.
    ///      Operand failures revert as described in calcUint.
    /// @param op The comparison to apply (Eq = 0, Ne = 1, Gt = 2, Lt = 3, Ge = 4, Le = 5)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The result of comparing the two decoded uint256 operands
    function cmpUint(CmpOp op, address target1, bytes calldata data1, address target2, bytes calldata data2) external view returns (bool) {
        uint256 a = uint256(_callWord(target1, data1));
        uint256 b = uint256(_callWord(target2, data2));
        if (op == CmpOp.Eq) return a == b;
        if (op == CmpOp.Ne) return a != b;
        if (op == CmpOp.Gt) return a > b;
        if (op == CmpOp.Lt) return a < b;
        if (op == CmpOp.Ge) return a >= b;
        return a <= b;
    }

    /// @notice Compares the int256 results of two staticcalls and returns the outcome
    /// @dev Signed counterpart of cmpUint (so -1 compares below 1, unlike a raw word
    ///      comparison); see cmpUint for the composition pattern.
    /// @param op The comparison to apply (Eq = 0, Ne = 1, Gt = 2, Lt = 3, Ge = 4, Le = 5)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The result of comparing the two decoded int256 operands
    function cmpInt(CmpOp op, address target1, bytes calldata data1, address target2, bytes calldata data2) external view returns (bool) {
        int256 a = int256(uint256(_callWord(target1, data1)));
        int256 b = int256(uint256(_callWord(target2, data2)));
        if (op == CmpOp.Eq) return a == b;
        if (op == CmpOp.Ne) return a != b;
        if (op == CmpOp.Gt) return a > b;
        if (op == CmpOp.Lt) return a < b;
        if (op == CmpOp.Ge) return a >= b;
        return a <= b;
    }

    // ============ Value Getters ============

    /// @notice Echoes a uint256 literal, turning it into a composition operand
    /// @dev Lets cmpUint / calcUint compare a call result against a constant, e.g.
    ///      cmpUint(Gt, combinators, abi.encodeCall(Combinators.ethBalance, (user)),
    ///      combinators, abi.encodeCall(Combinators.constantUint, (0))).
    /// @param x The literal value
    /// @return The same value
    function constantUint(uint256 x) external pure returns (uint256) {
        return x;
    }

    /// @notice Echoes an int256 literal, turning it into a composition operand
    /// @dev Signed counterpart of constantUint.
    /// @param x The literal value
    /// @return The same value
    function constantInt(int256 x) external pure returns (int256) {
        return x;
    }

    /// @notice Returns the native token balance of an account
    /// @dev Value getter that turns a non-call quantity into an arithmetic operand, e.g.
    ///      "ETH balance + WETH balance": calcUint(Add, combinators,
    ///      abi.encodeCall(Combinators.ethBalance, (user)), weth,
    ///      abi.encodeCall(IERC20.balanceOf, (user))).
    /// @param account The account whose native balance to return
    /// @return The account's balance in wei
    function ethBalance(address account) external view returns (uint256) {
        return account.balance;
    }

    /// @notice Resolves a call chain and returns the native balance of the address
    ///         the final call returns
    /// @dev Runtime counterpart of ethBalance for addresses not known at encoding
    ///      time — operands only flow between combinators as return values, so this
    ///      is the only way to read the balance of a call-resolved address, e.g.
    ///      "the registry's current treasury holds at least 100 ETH":
    ///      assertGeCallUint(combinators, abi.encodeCall(Combinators.ethBalanceCall,
    ///      (registry, [encodeCall(treasury)])), 100 ether). The final return must
    ///      decode as an address (short returndata reverts with
    ///      ReturnDataOutOfBounds); chain resolution failures behave exactly as in
    ///      chainCall. A single call is a one-element array.
    /// @param target The contract address the first call is executed on
    /// @param calls One entry per hop, word-index-prefixed except the last (see
    ///        chainCall); every hop except the last must expose an address at its
    ///        selected return word, and the last must return an address
    /// @return The native balance in wei of the address the final call returns
    function ethBalanceCall(address target, bytes[] calldata calls) external view returns (uint256) {
        bytes memory result = _resolveChain(target, calls);
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        return abi.decode(result, (address)).balance;
    }

    /// @notice Returns the current block timestamp
    /// @dev Value getter for time arithmetic, e.g. "seconds until unlock":
    ///      calcUint(Sub, vesting, abi.encodeCall(IVesting.unlockTime, ()),
    ///      combinators, abi.encodeCall(Combinators.blockTimestamp, ())).
    /// @return The current block timestamp in seconds
    function blockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /// @notice Returns the current block number
    /// @dev Value getter for block arithmetic composition with calcUint
    /// @return The current block number
    function blockNumber() external view returns (uint256) {
        return block.number;
    }

    // ============ Internal Helpers ============

    /// @dev Executes a staticcall and returns the raw result bytes.
    ///      Reverts with CallFailed when the target has no code, since a staticcall
    ///      to a code-less address succeeds with empty returndata and would otherwise
    ///      surface as an opaque ABI decoding error.
    function _call(address target, bytes calldata data) internal view returns (bytes memory) {
        if (target.code.length == 0) revert CallFailed(target, data);
        (bool success, bytes memory result) = target.staticcall(data);
        if (!success) revert CallFailed(target, data);
        return result;
    }

    /// @dev Executes a staticcall and returns the first 32-byte word of the result,
    ///      reverting with ReturnDataOutOfBounds when fewer than 32 bytes come back.
    function _callWord(address target, bytes calldata data) internal view returns (bytes32) {
        bytes memory result = _call(target, data);
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        return abi.decode(result, (bytes32));
    }

    /// @dev Executes a staticcall and decodes the result as a bool, reverting with
    ///      ReturnDataOutOfBounds on short returndata and via abi.decode validation
    ///      when the returned word is not exactly 0 or 1.
    function _callBool(address target, bytes calldata data) internal view returns (bool) {
        bytes memory result = _call(target, data);
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        return abi.decode(result, (bool));
    }

    /// @dev Decodes the length word of a single ABI-encoded dynamic return value
    ///      (array, string, or bytes), validating the head offset against the actual
    ///      returndata the same way the core's array-length assertions do
    function _dynLength(bytes memory result) internal pure returns (uint256 length) {
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        uint256 offset;
        assembly {
            offset := mload(add(result, 32))
        }
        if (offset > result.length || result.length - offset < 32) {
            revert ReturnDataOutOfBounds(0, result.length);
        }
        assembly {
            length := mload(add(add(result, 32), offset))
        }
    }

    /// @dev Number of segments splitting `str` by `delim` produces (>= 1; the
    ///      same left-to-right non-overlapping scan the selection loop uses)
    function _countSegments(bytes memory str, bytes memory delim) internal pure returns (uint256 segments) {
        segments = 1;
        uint256 i = 0;
        while (i + delim.length <= str.length) {
            if (_matchesAt(str, delim, i)) {
                segments++;
                i += delim.length;
            } else {
                i++;
            }
        }
    }

    /// @dev Whether `delim` occurs in `str` at byte position `pos` (caller bounds-checks)
    function _matchesAt(bytes memory str, bytes memory delim, uint256 pos) internal pure returns (bool) {
        for (uint256 j = 0; j < delim.length; j++) {
            if (str[pos + j] != delim[j]) return false;
        }
        return true;
    }

    /// @dev Copies str[start..end) into a fresh allocation (no dirty trailing bytes,
    ///      so the result is safe to feed into keccak-based string comparisons)
    function _slice(bytes memory str, uint256 start, uint256 end) internal pure returns (bytes memory out) {
        out = new bytes(end - start);
        for (uint256 j = 0; j < out.length; j++) {
            out[j] = str[start + j];
        }
    }

    /// @dev Executes a call chain. Every non-final entry of `calls` is
    ///      `abi.encodePacked(uint256 wordIndex, callData)`: the calldata suffix
    ///      is staticcalled on the current target and the static return word at
    ///      `wordIndex` becomes the address of the next hop (0 selects the first
    ///      word — a plain single-address return). The final entry is unprefixed
    ///      calldata whose raw returndata is returned. Reverts with EmptyCallChain
    ///      when `calls` is empty, MalformedChainHop when a non-final entry lacks
    ///      its 32-byte prefix, CallFailed (identifying the failing hop's target
    ///      and calldata) when any hop reverts or targets a code-less address,
    ///      ReturnDataOutOfBounds when the selected word lies past the hop's
    ///      returndata, and InvalidChainAddress when the selected word has dirty
    ///      upper bytes.
    function _resolveChain(address target, bytes[] calldata calls) internal view returns (bytes memory) {
        if (calls.length == 0) revert EmptyCallChain();
        address current = target;
        uint256 last = calls.length - 1;
        for (uint256 i = 0; i < last; i++) {
            bytes calldata hop = calls[i];
            if (hop.length < 32) revert MalformedChainHop(i, hop.length);
            uint256 wordIndex = uint256(bytes32(hop[:32]));
            bytes memory result = _call(current, hop[32:]);
            if (result.length < 32 || wordIndex > (result.length - 32) / 32) {
                revert ReturnDataOutOfBounds(int256(wordIndex), result.length);
            }
            uint256 word;
            assembly {
                word := mload(add(add(result, 32), mul(wordIndex, 32)))
            }
            if (word >> 160 != 0) revert InvalidChainAddress(i, bytes32(word));
            current = address(uint160(word));
        }
        return _call(current, calls[last]);
    }

    /// @dev Decodes a single ABI-encoded string return value, validating the head
    ///      offset and length against the actual returndata (the same validation
    ///      the core's tuple-indexed string assertions perform). The copy zeroes
    ///      the final word's padding so no dirty bytes remain.
    function _decodeString(bytes memory result) internal pure returns (bytes memory strBytes) {
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        uint256 offset;
        assembly {
            offset := mload(add(result, 32))
        }
        if (offset > result.length || result.length - offset < 32) {
            revert ReturnDataOutOfBounds(0, result.length);
        }
        uint256 strLen;
        assembly {
            strLen := mload(add(add(result, 32), offset))
        }
        if (result.length - offset - 32 < strLen) {
            revert ReturnDataOutOfBounds(0, result.length);
        }
        strBytes = new bytes(strLen);
        assembly {
            let src := add(add(result, 64), offset)
            let dst := add(strBytes, 32)
            for { let i := 0 } lt(i, strLen) { i := add(i, 32) } {
                mstore(add(dst, i), mload(add(src, i)))
            }
            // Zero the padding of the final partial word so no dirty bytes remain
            let rem := mod(strLen, 32)
            if rem {
                let last := add(dst, sub(strLen, rem))
                mstore(last, and(mload(last), not(shr(mul(rem, 8), not(0)))))
            }
        }
    }
}
