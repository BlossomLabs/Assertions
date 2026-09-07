// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "./Expressions.sol";
import {AbiCodec} from "./AbiCodec.sol";

/// @notice Word and ABI-valued collection operations, including folds and stable merge sorting.
/// Callbacks must be consistent and side-effect free.
contract Collections {
    // ============ Types and errors ============

    /**
     * @notice Thrown when a fold lambda offset does not leave room for a
     *         32-byte word inside the template
     * @param offset The offending offset
     * @param templateLength The template's byte length
     */
    error LambdaOffsetOutOfBounds(uint256 offset, uint256 templateLength);

    /**
     * @notice Thrown when foldWords receives data that is not a whole
     *         number of 32-byte words — silent truncation of a partial
     *         trailing word would be a wrong-answer machine
     * @param length The offending data length
     */
    error UnalignedWords(uint256 length);

    /**
     * @notice Thrown when zipWords receives payloads of different word
     *         counts — silent truncation would be a wrong-answer machine
     * @param aWords The first payload's word count
     * @param bWords The second payload's word count
     */
    error WordCountMismatch(uint256 aWords, uint256 bWords);

    /**
     * @notice Thrown when unzipWords receives a lane other than 0 or 1
     * @param which The offending lane
     */
    error InvalidLane(uint256 which);

    /**
     * @notice Early-exit modes for the folds
     * @dev ABI-encoded as uint8: Full = 0 (scan every element), Any = 1
     *      (stop at the first nonzero accumulator — exists), All = 2 (stop
     *      at the first zero accumulator — forall). An out-of-range value
     *      reverts with Panic(0x21).
     */
    enum FoldExit {
        Full,
        Any,
        All
    }

    /**
     * @dev Fold iteration domains: Range substitutes the index, Bytes the
     *      byte value at the index, Words the 32-byte word at the index
     */
    enum FoldDomain {
        Range,
        Bytes,
        Words
    }

    /**
     * @dev Stack-friendly bundle for the fold loop: a memory struct is one
     *      slot, where the same fields as free parameters blew the frame
     *      once `elemOffsets` became a dynamic array.
     */
    struct FoldRun {
        FoldDomain domain;
        uint256 count;
        address target;
        uint256 accOffset;
        bytes32 acc;
        FoldExit exit;
    }

    /// @dev Argument descriptor is a tuple. constants contains one single-value ABI envelope per slot.
    /// first is the element slot (or fold accumulator); second is the other element/fold element slot.
    /// Unary callbacks ignore second; substituted slots may contain empty placeholders.
    /// A non-empty expression is an abi-encoded Expressions.Expression that target evaluates through
    /// evaluateEncoded with the substituted slots as its parameters; selector is then ignored.
    struct Callback {
        address target;
        bytes4 selector;
        string arguments;
        bytes[] constants;
        uint256 first;
        uint256 second;
        bytes expression;
    }

    error InvalidCallback();

    error InvalidCallbackTarget(address target);

    error CallbackFailed(bytes4 operation, uint256 index, uint256 other, address target, bytes callData, bytes reason);

    struct PreparedCallback {
        AbiCodec.TupleLayout plan;
        bytes[] args;
        bool targetChecked;
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

    // ============ Public collection operations ============

    /**
     * @notice Folds the lambda over the index range 0 .. n-1 (the element
     *         substituted into the template is the index itself)
     * @dev The one loop primitive; foldBytes and foldWords share its
     *      engine and rules. The lambda is a single staticcall: `template`
     *      is complete calldata for `target` in which 32-byte windows are
     *      rewritten per element — the accumulator at `accOffset` first,
     *      then the element at each offset in `elemOffsets` in the supplied
     *      order (the element wins on overlap with the accumulator, and
     *      later element windows win on mutual overlap; every byte
     *      outside the windows stays pristine template). The single returned
     *      word becomes the new accumulator; `Any` stops at the first
     *      nonzero accumulator, `All` at the first zero, `Full` scans
     *      everything; the final accumulator is returned either way. An
     *      empty domain validates template windows, then returns `init`
     *      without inspecting or calling the target. A
     *      lambda revert is an assertion failure: it reverts the fold with
     *      CallbackFailed with the operation, element, calldata and revert reason. Offsets must leave room
     *      for a word inside the template (LambdaOffsetOutOfBounds), a
     *      code-less target reverts with InvalidCallbackTarget,
     *      and a lambda returning other than 32 bytes with
     *      InvalidCallbackResult. Gas is the loop bound: every application
     *      pays real call overhead, so domain sizes are naturally limited
     *      by the block gas limit.
     * @param n The number of iterations
     * @param target The lambda contract
     * @param template Complete calldata for `target`, with the windows
     * @param accOffset Byte offset of the accumulator window
     * @param elemOffsets Byte offsets of the element windows (N=1 is the
     *        common case; an empty array writes only the accumulator)
     * @param init The initial accumulator
     * @param exit The early-exit mode (see FoldExit)
     * @return The final accumulator
     */
    function foldRange(
        uint256 n,
        address target,
        bytes calldata template,
        uint256 accOffset,
        uint256[] calldata elemOffsets,
        bytes32 init,
        FoldExit exit
    ) external view returns (bytes32) {
        return _fold(FoldDomain.Range, n, msg.data[0:0], target, template, accOffset, elemOffsets, init, exit);
    }

    /**
     * @notice Folds the lambda over the bytes of `s` (the element is the
     *         byte VALUE as a word) — with bitSet(mask, elem) as the
     *         lambda and All exit, this is the character-set test
     * @dev Engine and rules as foldRange
     */
    function foldBytes(
        bytes calldata s,
        address target,
        bytes calldata template,
        uint256 accOffset,
        uint256[] calldata elemOffsets,
        bytes32 init,
        FoldExit exit
    ) external view returns (bytes32) {
        return _fold(FoldDomain.Bytes, s.length, s, target, template, accOffset, elemOffsets, init, exit);
    }

    /**
     * @notice Folds the lambda over the 32-byte words of `s` (the element
     *         is the word) — feed it an array PAYLOAD (elements without
     *         the envelope), e.g. sliced out of a returned array
     * @dev Engine and rules as foldRange; s.length must be a multiple of
     *      32 or the fold reverts with UnalignedWords
     */
    function foldWords(
        bytes calldata s,
        address target,
        bytes calldata template,
        uint256 accOffset,
        uint256[] calldata elemOffsets,
        bytes32 init,
        FoldExit exit
    ) external view returns (bytes32) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        return _fold(FoldDomain.Words, s.length / 32, s, target, template, accOffset, elemOffsets, init, exit);
    }

    /**
     * @notice Applies a single-staticcall lambda to every word of `s` and
     *         returns the transformed payload — the bytes-producing map
     *         the scalar folds cannot express
     * @dev Lambda conventions match the folds: `template` is complete
     *      calldata for `target` whose 32-byte windows at `elemOffsets`
     *      are rewritten per element (supplied order; later windows win
     *      on mutual overlap); the lambda must return exactly one word: the
     *      mapped element. An empty payload validates template windows
     *      before returning empty without inspecting the target; a code-less target reverts with
     *      InvalidCallbackTarget, a reverting application with CallbackFailed
     *      preserving calldata and reason, and an invalid return with InvalidCallbackResult. Gas is the loop bound, one call per word.
     * @param s The word payload to map
     * @param target The lambda contract
     * @param template Complete calldata for `target` with the element windows
     * @param elemOffsets Byte offsets of the element windows
     * @return The mapped payload, same word count as `s`
     */
    function mapWords(bytes calldata s, address target, bytes calldata template, uint256[] calldata elemOffsets)
        external
        view
        returns (bytes memory)
    {
        return _applyWords(s, target, template, elemOffsets, false);
    }

    /**
     * @notice The words of `s` whose lambda application returns canonical ABI true,
     *         in order — the variable-length sibling of mapWords
     * @dev Lambda conventions and errors match mapWords exactly; the
     *      output length is the kept count, so filters nest into len, at,
     *      folds and further word ops
     */
    function filterWords(bytes calldata s, address target, bytes calldata template, uint256[] calldata elemOffsets)
        external
        view
        returns (bytes memory)
    {
        return _applyWords(s, target, template, elemOffsets, true);
    }

    /**
     * @notice The payload 0, 1, 2, ..., n-1 — the index generator that
     *         pairs with zipWords for enumerations
     */
    function iotaWords(uint256 n) external pure returns (bytes memory out) {
        out = new bytes(n * 32);
        for (uint256 i = 0; i < n; i++) {
            _setWord(out, i, i);
        }
    }

    /**
     * @notice The index of the first word of `s` equal to `w`, or the
     *         word COUNT as the not-found sentinel (it composes:
     *         contains = lt(wordIndexOf(s, w), div(byteLen(s), 32)))
     */
    function wordIndexOf(bytes calldata s, bytes32 w) external pure returns (uint256) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        uint256 count = s.length / 32;
        for (uint256 i = 0; i < count; i++) {
            if (bytes32(s[i * 32:i * 32 + 32]) == w) return i;
        }
        return count;
    }

    /**
     * @notice The payload with its word order reversed
     */
    function reverseWords(bytes calldata s) external pure returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        uint256 count = s.length / 32;
        out = new bytes(s.length);
        for (uint256 i = 0; i < count; i++) {
            bytes32 w = bytes32(s[i * 32:i * 32 + 32]);
            assembly {
                mstore(add(add(out, 32), mul(sub(sub(count, 1), i), 32)), w)
            }
        }
    }

    /**
     * @notice The two payloads interleaved: a0, b0, a1, b1, ... — pairs
     *         for a fold or for unzipWords to split back
     * @dev Different word counts revert with WordCountMismatch (silent
     *      truncation would be a wrong-answer machine)
     */
    function zipWords(bytes calldata a, bytes calldata b) external pure returns (bytes memory out) {
        if (a.length % 32 != 0) revert UnalignedWords(a.length);
        if (b.length % 32 != 0) revert UnalignedWords(b.length);
        if (a.length != b.length) revert WordCountMismatch(a.length / 32, b.length / 32);
        uint256 count = a.length / 32;
        out = new bytes(a.length * 2);
        for (uint256 i = 0; i < count; i++) {
            bytes32 wa = bytes32(a[i * 32:i * 32 + 32]);
            bytes32 wb = bytes32(b[i * 32:i * 32 + 32]);
            assembly {
                mstore(add(add(out, 32), mul(mul(i, 2), 32)), wa)
                mstore(add(add(out, 32), mul(add(mul(i, 2), 1), 32)), wb)
            }
        }
    }

    /**
     * @notice Every second word of the payload: lane 0 (words 0, 2, 4, …)
     *         or lane 1 (words 1, 3, 5, …) — zipWords' inverse
     * @dev A lane past 1 reverts with InvalidLane; an odd word count
     *      leaves the extra word in lane 0
     */
    function unzipWords(bytes calldata s, uint256 which) external pure returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        if (which > 1) revert InvalidLane(which);
        uint256 count = s.length / 32;
        uint256 laneCount = which == 0 ? (count + 1) / 2 : count / 2;
        out = new bytes(laneCount * 32);
        for (uint256 i = 0; i < laneCount; i++) {
            bytes32 w = bytes32(s[(i * 2 + which) * 32:(i * 2 + which) * 32 + 32]);
            assembly {
                mstore(add(add(out, 32), mul(i, 32)), w)
            }
        }
    }

    /**
     * @notice The payload sorted ascending as unsigned words
     * @dev Stable bottom-up merge sort: O(n log n) comparisons and moves,
     *      with O(n) scratch memory. Signed sorting is
     *      a three-node recipe instead of an overload: flip the sign bit
     *      (mapWords with bitXor(2^255, elem)), sort, flip back
     */
    function sortWords(bytes calldata s) external pure returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        out = s;
        uint256 count = s.length / 32;
        bytes memory scratch = new bytes(s.length);
        for (uint256 width = 1; width < count; width *= 2) {
            for (uint256 start = 0; start < count; start += 2 * width) {
                uint256 middle = start + width < count ? start + width : count;
                uint256 end = start + 2 * width < count ? start + 2 * width : count;
                uint256 a = start;
                uint256 b = middle;
                for (uint256 dest = start; dest < end; dest++) {
                    bool takeA = b == end;
                    if (a < middle && b < end) takeA = _wordAt(out, a) <= _wordAt(out, b);
                    if (a == middle) takeA = false;
                    _setWord(scratch, dest, _wordAt(out, takeA ? a++ : b++));
                }
            }
            bytes memory previous = out;
            out = scratch;
            scratch = previous;
        }
    }

    /**
     * @notice The checked sum of the payload's 32-byte words — a native
     *         single-call loop, the fixed-operation form of the
     *         foldWords(add) recipe (overflow reverts with Panic(0x11))
     */
    function sumWords(bytes calldata s) external pure returns (uint256 total) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        uint256 count = s.length / 32;
        for (uint256 i = 0; i < count; i++) {
            total += uint256(bytes32(s[i * 32:i * 32 + 32]));
        }
    }

    /**
     * @notice Remove duplicate words, preserving first-occurrence order.
     * @param ordered Whether equal values are already grouped together. When true,
     *        only adjacent duplicates are compared (O(n)); otherwise every retained
     *        word is checked (O(n squared)). Ordering is trusted, not validated.
     */
    function uniqueWords(bytes calldata s, bool ordered) external pure returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        out = new bytes(s.length);
        uint256 kept;
        for (uint256 i = 0; i < s.length / 32; i++) {
            uint256 word = uint256(bytes32(s[i * 32:i * 32 + 32]));
            bool seen;
            if (ordered) {
                seen = kept != 0 && _wordAt(out, kept - 1) == word;
            } else {
                for (uint256 j = 0; j < kept; j++) {
                    if (_wordAt(out, j) == word) {
                        seen = true;
                        break;
                    }
                }
            }
            if (!seen) _setWord(out, kept++, word);
        }
        assembly {
            mstore(out, mul(kept, 32))
        }
    }

    /// @notice Validate a single canonical ABI value.
    function validateValue(string calldata valueType, bytes calldata value) external pure {
        AbiCodec.validate(bytes(valueType), value);
    }

    /// @notice Assemble canonical abi.encode(T[]) from canonical abi.encode(T) elements.
    function packArray(string calldata elementType, bytes[] calldata values) external pure returns (bytes memory) {
        return AbiCodec.pack(bytes(elementType), values);
    }

    /// @notice Extract canonical abi.encode(T) elements from canonical abi.encode(T[]).
    function unpackArray(string calldata elementType, bytes calldata encoded) external pure returns (bytes[] memory) {
        return AbiCodec.unpack(bytes(elementType), encoded);
    }

    /// @notice Map each encoded input to one encoded output of outputType, preserving order.
    function mapValues(
        string calldata inputType,
        string calldata outputType,
        bytes[] calldata values,
        Callback calldata cb
    ) external view returns (bytes[] memory out) {
        PreparedCallback memory prepared = _prepareCallback(cb, false);
        AbiCodec.shape(bytes(inputType));
        AbiCodec.shape(bytes(outputType));
        out = new bytes[](values.length);
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            out[i] = _callValue(cb, prepared, values[i], "", false, i, 0);
            _validateResult(outputType, out[i], cb, i);
        }
    }

    /// @notice Keep inputs whose callback returns true, preserving order.
    function filterValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        PreparedCallback memory prepared = _prepareCallback(cb, false);
        AbiCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            if (_predicate(cb, prepared, values[i], "", false, i, 0)) out[count++] = values[i];
        }
        assembly { mstore(out, count) }
    }

    /// @notice Left fold with an explicit initial accumulator; empty input returns initial.
    /// @dev Always visits every element: an arbitrary ABI accumulator has no implicit truth value.
    function foldValues(
        string calldata inputType,
        string calldata accumulatorType,
        bytes[] calldata values,
        bytes calldata initial,
        Callback calldata cb
    ) external view returns (bytes memory result) {
        PreparedCallback memory prepared = _prepareCallback(cb, true);
        AbiCodec.shape(bytes(inputType));
        AbiCodec.validate(bytes(accumulatorType), initial);
        result = initial;
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            result = _callValue(cb, prepared, result, values[i], true, i, 0);
            _validateResult(accumulatorType, result, cb, i);
        }
    }

    /// @notice Stable ascending merge sort; callback compares two values and returns signed ordering.
    function sortValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bytes[] memory out)
    {
        PreparedCallback memory prepared = _prepareCallback(cb, true);
        AbiCodec.shape(bytes(inputType));
        out = values;
        SortCursor memory c;
        c.n = out.length;
        bytes[] memory scratch = new bytes[](c.n);
        for (uint256 i; i < c.n; i++) {
            AbiCodec.validate(bytes(inputType), out[i]);
        }
        for (c.width = 1; c.width < c.n; c.width *= 2) {
            for (c.start = 0; c.start < c.n; c.start += 2 * c.width) {
                c.middle = c.start + c.width < c.n ? c.start + c.width : c.n;
                c.end = c.start + 2 * c.width < c.n ? c.start + 2 * c.width : c.n;
                c.a = c.start;
                c.b = c.middle;
                for (uint256 dest = c.start; dest < c.end; dest++) {
                    bool takeA = c.b == c.end;
                    if (c.a < c.middle && c.b < c.end) {
                        bytes memory answer = _callValue(cb, prepared, out[c.a], out[c.b], true, c.a, c.b);
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

    /// @notice Keep the first representative of each callback-defined equality class.
    /// @param ordered Whether equal values are already grouped: compare only the last
    /// retained value when true, or every retained value when false. Grouping is trusted.
    function uniqueValues(string calldata inputType, bytes[] calldata values, Callback calldata cb, bool ordered)
        external
        view
        returns (bytes[] memory out)
    {
        PreparedCallback memory prepared = _prepareCallback(cb, true);
        AbiCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            bool duplicate;
            for (uint256 j = ordered && count != 0 ? count - 1 : 0; j < count; j++) {
                if (_predicate(cb, prepared, out[j], values[i], true, i, j)) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) out[count++] = values[i];
        }
        assembly { mstore(out, count) }
    }

    /// @notice Flatten one level of canonical ABI values, validating inputType and preserving order.
    function flattenValues(string calldata inputType, bytes[][] calldata values)
        external
        pure
        returns (bytes[] memory out)
    {
        AbiCodec.shape(bytes(inputType));
        uint256 count;
        for (uint256 i; i < values.length; i++) {
            count += values[i].length;
        }
        out = new bytes[](count);
        uint256 k;
        for (uint256 i; i < values.length; i++) {
            for (uint256 j; j < values[i].length; j++) {
                AbiCodec.validate(bytes(inputType), values[i][j]);
                out[k++] = values[i][j];
            }
        }
    }

    /// @notice Reverse canonical values without changing their encodings.
    function reverseValues(string calldata inputType, bytes[] calldata values)
        external
        pure
        returns (bytes[] memory out)
    {
        AbiCodec.shape(bytes(inputType));
        out = new bytes[](values.length);
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            out[values.length - i - 1] = values[i];
        }
    }

    /// @notice Slice using clamped signed start/end indexes, with end exclusive, as Array.slice.
    function sliceValues(string calldata inputType, bytes[] calldata values, int256 start, int256 end)
        external
        pure
        returns (bytes[] memory out)
    {
        AbiCodec.shape(bytes(inputType));
        uint256 a = _sliceIndex(start, values.length);
        uint256 b = _sliceIndex(end, values.length);
        out = new bytes[](b > a ? b - a : 0);
        for (uint256 i; i < out.length; i++) {
            AbiCodec.validate(bytes(inputType), values[a + i]);
            out[i] = values[a + i];
        }
    }

    /// @notice First equality match, or uint256.max; calls stop immediately at a match.
    function indexOfValues(
        string calldata inputType,
        bytes[] calldata values,
        bytes calldata needle,
        Callback calldata cb
    ) external view returns (uint256) {
        PreparedCallback memory prepared = _prepareCallback(cb, true);
        AbiCodec.validate(bytes(inputType), needle);
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            if (_predicate(cb, prepared, values[i], needle, true, i, 0)) return i;
        }
        return type(uint256).max;
    }

    /// @notice Whether any value matches; empty input is false. Predicate calls short circuit.
    function anyValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bool)
    {
        return _findValue(inputType, values, cb, true) != type(uint256).max;
    }

    /// @notice Whether all values match; empty input is true. Predicate calls short circuit.
    function allValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bool)
    {
        return _findValue(inputType, values, cb, false) == type(uint256).max;
    }

    /// @notice Index of the first predicate match, or uint256.max when absent.
    function findValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (uint256)
    {
        return _findValue(inputType, values, cb, true);
    }

    /// @notice Pair equally sized arrays into canonical single tuple envelopes, preserving order.
    function zipValues(
        string calldata leftType,
        string calldata rightType,
        bytes[] calldata left,
        bytes[] calldata right
    ) external pure returns (bytes[] memory out) {
        if (left.length != right.length) revert WordCountMismatch(left.length, right.length);
        AbiCodec.TupleLayout memory plan = _zipPlan(leftType, rightType);
        out = new bytes[](left.length);
        bytes[] memory pair = new bytes[](2);
        for (uint256 i; i < left.length; i++) {
            AbiCodec.validate(bytes(leftType), left[i]);
            AbiCodec.validate(bytes(rightType), right[i]);
            pair[0] = left[i];
            pair[1] = right[i];
            bytes memory tuple = AbiCodec.assemble(plan.dynamic, plan.headSize, pair, false);
            out[i] = plan.dynamic[0] || plan.dynamic[1] ? bytes.concat(abi.encode(uint256(32)), tuple) : tuple;
        }
    }

    /// @notice Extract lane 0 or 1 from canonical pair tuples, validating both component envelopes.
    function unzipValues(string calldata leftType, string calldata rightType, bytes[] calldata pairs, uint256 lane)
        external
        pure
        returns (bytes[] memory out)
    {
        if (lane > 1) revert InvalidLane(lane);
        AbiCodec.TupleLayout memory plan = _zipPlan(leftType, rightType);
        out = new bytes[](pairs.length);
        for (uint256 i; i < pairs.length; i++) {
            bytes[] memory parts = _unzipPair(pairs[i], plan);
            AbiCodec.validate(bytes(leftType), parts[0]);
            AbiCodec.validate(bytes(rightType), parts[1]);
            out[i] = parts[lane];
        }
    }

    // ============ Internal helpers ============

    /**
     * @dev The shared map/filter engine: one staticcall per word with the
     *      element windows rewritten; filtering keeps the ELEMENT when the
     *      lambda returns canonical ABI true, mapping stores the lambda word itself
     */
    function _applyWords(
        bytes calldata s,
        address target,
        bytes calldata template,
        uint256[] calldata elemOffsets,
        bool filterMode
    ) private view returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        _checkElementWindows(template, elemOffsets);
        uint256 count = s.length / 32;
        out = new bytes(s.length);
        uint256 kept;
        if (count != 0) {
            _checkTarget(target);
            bytes memory callData = template;
            for (uint256 i = 0; i < count; i++) {
                bytes32 elem = bytes32(s[i * 32:i * 32 + 32]);
                _stampElements(callData, elemOffsets, elem);
                bytes32 word = _callWord(target, callData, i);
                if (filterMode) {
                    if (uint256(word) > 1) revert AbiCodec.InvalidCallbackResult(msg.sig, i, 0, target);
                    if (word != bytes32(0)) {
                        _setWord(out, kept, uint256(elem));
                        kept++;
                    }
                } else {
                    _setWord(out, i, uint256(word));
                    kept++;
                }
            }
        }
        if (filterMode) {
            assembly {
                mstore(out, mul(kept, 32))
            }
        }
    }

    /**
     * @dev The i-th 32-byte word of a memory payload (caller bounds-checks)
     */
    function _sliceIndex(int256 index, uint256 length) private pure returns (uint256) {
        if (index < 0) return index < -int256(length) ? 0 : uint256(int256(length) + index);
        return uint256(index) > length ? length : uint256(index);
    }

    function _findValue(string calldata inputType, bytes[] calldata values, Callback calldata cb, bool wanted)
        private
        view
        returns (uint256)
    {
        PreparedCallback memory prepared = _prepareCallback(cb, false);
        AbiCodec.shape(bytes(inputType));
        for (uint256 i; i < values.length; i++) {
            AbiCodec.validate(bytes(inputType), values[i]);
            if (_predicate(cb, prepared, values[i], "", false, i, 0) == wanted) return i;
        }
        return type(uint256).max;
    }

    function _unzipPair(bytes memory pair, AbiCodec.TupleLayout memory plan)
        private
        pure
        returns (bytes[] memory parts)
    {
        uint256 base = plan.dynamic[0] || plan.dynamic[1] ? 32 : 0;
        if (base != 0 && AbiCodec.word(pair, 0) != 32) revert AbiCodec.InvalidValue(0);
        parts = new bytes[](2);
        uint256 head;
        uint256 tail = plan.headSize;
        for (uint256 i; i < 2; i++) {
            if (plan.dynamic[i]) {
                if (AbiCodec.word(pair, base + head) != tail) revert AbiCodec.InvalidValue(base + head);
                uint256 end = i == 0 && plan.dynamic[1] ? AbiCodec.word(pair, base + head + 32) : pair.length - base;
                if (end < tail) revert AbiCodec.InvalidValue(base + head);
                parts[i] = bytes.concat(abi.encode(uint256(32)), AbiCodec.slice(pair, base + tail, end - tail));
                tail = end;
            } else {
                parts[i] = AbiCodec.slice(pair, base + head, plan.words[i] * 32);
            }
            head += plan.words[i] * 32;
        }
        if (base + tail != pair.length) revert AbiCodec.InvalidValue(base + tail);
    }

    function _zipPlan(string calldata leftType, string calldata rightType)
        private
        pure
        returns (AbiCodec.TupleLayout memory plan)
    {
        (bool a, uint256 aw) = AbiCodec.shape(bytes(leftType));
        (bool b, uint256 bw) = AbiCodec.shape(bytes(rightType));
        plan.dynamic = new bool[](2);
        plan.dynamic[0] = a;
        plan.dynamic[1] = b;
        plan.headSize = (aw + bw) * 32;
        plan.words = new uint256[](2);
        plan.words[0] = aw;
        plan.words[1] = bw;
    }

    function _wordAt(bytes memory b, uint256 i) private pure returns (uint256 w) {
        assembly {
            w := mload(add(add(b, 32), mul(i, 32)))
        }
    }

    /**
     * @dev Writes the i-th 32-byte word of a memory payload (caller bounds-checks)
     */
    function _setWord(bytes memory b, uint256 i, uint256 w) private pure {
        assembly {
            mstore(add(add(b, 32), mul(i, 32)), w)
        }
    }

    /**
     * @dev Bounds-check the accumulator and every element window. Hoisted
     *      out of the element loop so a bad offset fails before any call.
     */
    function _checkWindows(bytes calldata template, uint256 accOffset, uint256[] calldata elemOffsets) private pure {
        if (template.length < 32 || accOffset > template.length - 32) {
            revert LambdaOffsetOutOfBounds(accOffset, template.length);
        }
        _checkElementWindows(template, elemOffsets);
    }

    function _checkElementWindows(bytes calldata template, uint256[] calldata elemOffsets) private pure {
        if (template.length < 32) revert LambdaOffsetOutOfBounds(0, template.length);
        for (uint256 j = 0; j < elemOffsets.length; j++) {
            if (elemOffsets[j] > template.length - 32) {
                revert LambdaOffsetOutOfBounds(elemOffsets[j], template.length);
            }
        }
    }

    /**
     * @dev The i-th domain element: the index itself (Range), the byte
     *      value (Bytes), or the 32-byte word (Words).
     */
    function _domainElem(FoldDomain domain, uint256 i, bytes calldata s) private pure returns (bytes32) {
        if (domain == FoldDomain.Range) return bytes32(i);
        if (domain == FoldDomain.Bytes) return bytes32(uint256(uint8(s[i])));
        return bytes32(s[i * 32:i * 32 + 32]);
    }

    /**
     * @dev Write the accumulator first, then every element window in the
     *      order of `elemOffsets` (element wins on overlap with acc; later
     *      element windows win on mutual overlap).
     */
    function _stampWindows(
        bytes memory callData,
        uint256 accOffset,
        bytes32 acc,
        uint256[] calldata elemOffsets,
        bytes32 elem
    ) private pure {
        assembly {
            mstore(add(add(callData, 32), accOffset), acc)
        }
        _stampElements(callData, elemOffsets, elem);
    }

    function _stampElements(bytes memory callData, uint256[] calldata elemOffsets, bytes32 elem) private pure {
        for (uint256 j = 0; j < elemOffsets.length; j++) {
            uint256 elemOffset = elemOffsets[j];
            assembly {
                mstore(add(add(callData, 32), elemOffset), elem)
            }
        }
    }

    /**
     * @dev The shared fold engine (see foldRange for the full rules).
     *      `count` is the domain size; `s` carries the subject bytes for
     *      the Bytes/Words domains and is empty for Range.
     */
    function _fold(
        FoldDomain domain,
        uint256 count,
        bytes calldata s,
        address target,
        bytes calldata template,
        uint256 accOffset,
        uint256[] calldata elemOffsets,
        bytes32 init,
        FoldExit exit
    ) private view returns (bytes32) {
        _checkWindows(template, accOffset, elemOffsets);
        if (count == 0) return init;
        _checkTarget(target);
        FoldRun memory run = FoldRun(domain, count, target, accOffset, init, exit);
        return _foldLoop(run, s, template, elemOffsets);
    }

    /// @dev Callback targets must contain EVM bytecode; precompiles are not callbacks.
    function _checkTarget(address target) private view {
        if (target.code.length == 0) revert InvalidCallbackTarget(target);
    }

    function _callWord(address target, bytes memory callData, uint256 index) private view returns (bytes32 word) {
        (bool success, bytes memory ret) = target.staticcall(callData);
        if (!success) revert CallbackFailed(msg.sig, index, 0, target, callData, ret);
        if (ret.length != 32) revert AbiCodec.InvalidCallbackResult(msg.sig, index, 0, target);
        assembly ("memory-safe") { word := mload(add(ret, 32)) }
    }

    function _foldLoop(FoldRun memory run, bytes calldata s, bytes calldata template, uint256[] calldata elemOffsets)
        private
        view
        returns (bytes32)
    {
        bytes memory callData = template;
        for (uint256 i = 0; i < run.count;) {
            {
                bytes32 elem = _domainElem(run.domain, i, s);
                _stampWindows(callData, run.accOffset, run.acc, elemOffsets, elem);
            }
            bytes32 next = _callWord(run.target, callData, i);
            run.acc = next;
            if (run.exit == FoldExit.Any && next != bytes32(0)) break;
            if (run.exit == FoldExit.All && next == bytes32(0)) break;
            unchecked {
                i++;
            }
        }
        return run.acc;
    }

    function _validateResult(string calldata valueType, bytes memory value, Callback calldata cb, uint256 i)
        private
        pure
    {
        AbiCodec.validate(bytes(valueType), value, AbiCodec.Context(1, msg.sig, i, 0, cb.target));
    }

    function _prepareCallback(Callback calldata cb, bool binary)
        private
        pure
        returns (PreparedCallback memory prepared)
    {
        if (cb.first >= cb.constants.length || (binary && (cb.second >= cb.constants.length || cb.first == cb.second))) revert InvalidCallback();
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
                AbiCodec.validateComponent(
                    descriptor[prepared.plan.starts[i]:prepared.plan.ends[i]],
                    prepared.args[i],
                    i,
                    prepared.plan.dynamic[i],
                    prepared.plan.words[i]
                );
            }
        }
    }

    function _bindValue(Callback calldata cb, PreparedCallback memory prepared, uint256 slot, bytes memory value)
        private
        pure
    {
        AbiCodec.validateComponent(
            bytes(cb.arguments)[prepared.plan.starts[slot]:prepared.plan.ends[slot]],
            value,
            slot,
            prepared.plan.dynamic[slot],
            prepared.plan.words[slot]
        );
        prepared.args[slot] = value;
    }

    function _callValue(
        Callback calldata cb,
        PreparedCallback memory prepared,
        bytes memory a,
        bytes memory b,
        bool binary,
        uint256 i,
        uint256 j
    ) private view returns (bytes memory out) {
        // Validate lazily so empty and singleton operations retain their no-call behavior.
        // All applications are staticcalls, so the target code cannot change during this operation.
        if (!prepared.targetChecked) {
            _checkTarget(cb.target);
            prepared.targetChecked = true;
        }
        _bindValue(cb, prepared, cb.first, a);
        if (binary) _bindValue(cb, prepared, cb.second, b);
        bytes memory data;
        if (cb.expression.length == 0) {
            data = bytes.concat(
                cb.selector, AbiCodec.assemble(prepared.plan.dynamic, prepared.plan.headSize, prepared.args, false)
            );
        } else {
            data = abi.encodeCall(Expressions.evaluateEncoded, (cb.expression, prepared.args));
        }
        bool ok;
        (ok, out) = cb.target.staticcall(data);
        if (!ok) revert CallbackFailed(msg.sig, i, j, cb.target, data, out);
    }

    function _predicate(
        Callback calldata cb,
        PreparedCallback memory prepared,
        bytes memory a,
        bytes memory b,
        bool binary,
        uint256 i,
        uint256 j
    ) private view returns (bool) {
        bytes memory out = _callValue(cb, prepared, a, b, binary, i, j);
        if (out.length != 32) revert AbiCodec.InvalidCallbackResult(msg.sig, i, j, cb.target);
        uint256 answer = AbiCodec.word(out, 0);
        if (answer > 1) revert AbiCodec.InvalidCallbackResult(msg.sig, i, j, cb.target);
        return answer == 1;
    }
}
