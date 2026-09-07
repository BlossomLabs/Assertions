// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "./Expressions.sol";
import {AbiCodec} from "./lib/AbiCodec.sol";

/**
 * @title Collections
 * @author Sembrestels
 * @notice Iteration and collection processing for the Assertions core, in
 *         two families. The WORD family works on payloads: a `bytes` value
 *         holding N packed 32-byte words (an array's elements without the
 *         envelope, as `nav` returns them or a fold builds them), with
 *         lambdas expressed as a calldata template whose 32-byte windows
 *         are rewritten per element. The VALUES family works on `bytes[]`
 *         of canonical single-value ABI encodings of any type, with
 *         callbacks bound through a `Callback` descriptor. Both are single
 *         staticcalls: the loop that would otherwise cost one core
 *         resolution per element runs here.
 * @dev Plain ABI in, plain ABI out, no ERC-8211: composition happens in
 *      the core, whose `read` splices resolved operands into this
 *      contract's calldata. Every lambda and callback application is a
 *      staticcall, so callbacks cannot have side effects, and they are
 *      trusted to be consistent (a comparator that is not a total order,
 *      or an equality that is not transitive, produces unspecified
 *      orderings, never a revert). Gas is the loop bound: every application
 *      pays real call overhead, so domain sizes are naturally limited by
 *      the block gas limit. Silent truncation is always a bug here:
 *      UnalignedWords and WordCountMismatch exist so a partial word or a
 *      length mismatch reverts instead of producing a plausible answer.
 * @custom:version 1.0
 */
contract Collections {
    // ============ Custom Errors ============

    /**
     * @notice Thrown when a fold lambda offset does not leave room for a
     *         32-byte word inside the template
     * @param offset The offending offset
     * @param templateLength The template's byte length
     */
    error LambdaOffsetOutOfBounds(uint256 offset, uint256 templateLength);

    /**
     * @notice Thrown when a word payload is not a whole number of 32-byte
     *         words (silent truncation of a partial trailing word would be
     *         a wrong-answer machine)
     * @param length The offending data length
     */
    error UnalignedWords(uint256 length);

    /**
     * @notice Thrown when zipWords receives payloads of different word
     *         counts, or zipValues arrays of different lengths (silent
     *         truncation would be a wrong-answer machine)
     * @param aWords The first payload's word count (or array's length)
     * @param bWords The second payload's word count (or array's length)
     */
    error WordCountMismatch(uint256 aWords, uint256 bWords);

    /**
     * @notice Thrown when unzipWords or unzipValues receives a lane other
     *         than 0 or 1
     * @param which The offending lane
     */
    error InvalidLane(uint256 which);

    // InvalidCallbackResult is shared with the codec and declared in
    // AbiCodec; the callback errors below sit with the Callback type.

    // ============ Types ============

    /**
     * @notice Early-exit modes for the folds
     * @dev ABI-encoded as uint8: Full = 0 (scan every element), Any = 1
     *      (stop at the first nonzero accumulator: exists), All = 2 (stop
     *      at the first zero accumulator: forall). An out-of-range value
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
     *      once `elemOffsets` became a dynamic array
     */
    struct FoldRun {
        FoldDomain domain;
        uint256 count;
        address target;
        uint256 accOffset;
        bytes32 acc;
        FoldExit exit;
    }

    /**
     * @notice How the values family applies a callback: `target` is called
     *         with `selector` and the arguments the tuple descriptor
     *         `arguments` describes; `constants` holds one canonical
     *         single-value encoding per argument slot, of which slot
     *         `first` receives the element (or the accumulator, for folds)
     *         and slot `second` the other element (or the fold element)
     *         at each application. Unary callbacks ignore `second`.
     * @dev Substituted slots may hold empty placeholders; every other slot
     *      is validated against its declared type once, up front. A
     *      non-empty `expression` is an abi-encoded Expressions.Expression
     *      that `target` (an Expressions deployment) evaluates through
     *      `evaluateEncoded` with the substituted slots as its parameters;
     *      `selector` is then ignored.
     */
    struct Callback {
        address target;
        bytes4 selector;
        string arguments;
        bytes[] constants;
        uint256 first;
        uint256 second;
        bytes expression;
    }

    /**
     * @notice Thrown when a Callback descriptor is inconsistent: a slot
     *         index past the constants, a binary callback binding both
     *         elements to the same slot, an argument descriptor that is
     *         not a parenthesized tuple, or a constants count that differs
     *         from the descriptor's component count
     */
    error InvalidCallback();

    /**
     * @notice Thrown when a lambda or callback target has no code (a
     *         staticcall there would succeed with empty returndata and
     *         surface as a silent wrong value; precompiles are not
     *         callbacks)
     * @param target The code-less address
     */
    error InvalidCallbackTarget(address target);

    /**
     * @notice Thrown when a lambda or callback application reverts: an
     *         assertion failure inside the loop, reported with the revert
     *         reason preserved
     * @param operation The selector of the Collections operation that ran
     *        the callback
     * @param index The element the callback was applied to
     * @param other The second element for binary callbacks (0 otherwise)
     * @param target The callback contract
     * @param callData The calldata that was sent
     * @param reason The raw revert data
     */
    error CallbackFailed(bytes4 operation, uint256 index, uint256 other, address target, bytes callData, bytes reason);

    /**
     * @dev A Callback checked and parsed once per operation: the argument
     *      tuple layout, the argument slots (constants with the element
     *      slots overwritten per application) and whether the target's code
     *      has been checked yet (lazily, so an operation with nothing to
     *      call never touches the target)
     */
    struct PreparedCallback {
        AbiCodec.TupleLayout plan;
        bytes[] args;
        bool targetChecked;
    }

    /**
     * @dev Merge-sort cursor for sortValues: a memory struct keeps the
     *      nested loops under the stack limit
     */
    struct SortCursor {
        uint256 n;
        uint256 width;
        uint256 start;
        uint256 middle;
        uint256 end;
        uint256 a;
        uint256 b;
    }

    // ============ Word Folds ============

    /**
     * @notice Folds the lambda over the index range 0 .. n-1 (the element
     *         substituted into the template is the index itself)
     * @dev The one loop primitive; foldBytes and foldWords share its
     *      engine and rules. The lambda is a single staticcall: `template`
     *      is complete calldata for `target` in which 32-byte windows are
     *      rewritten per element, the accumulator at `accOffset` first,
     *      then the element at each offset in `elemOffsets` in the supplied
     *      order (the element wins on overlap with the accumulator, later
     *      element windows win on mutual overlap, and every byte outside
     *      the windows stays pristine template). The single returned word
     *      becomes the new accumulator; `Any` stops at the first nonzero
     *      accumulator, `All` at the first zero, `Full` scans everything;
     *      the final accumulator is returned either way. An empty domain
     *      validates the template windows, then returns `init` without
     *      inspecting or calling the target. A lambda revert is an
     *      assertion failure: it reverts the fold with CallbackFailed
     *      carrying the operation, element, calldata and revert reason.
     *      Offsets must leave room for a word inside the template
     *      (LambdaOffsetOutOfBounds), a code-less target reverts with
     *      InvalidCallbackTarget, and a lambda returning other than 32
     *      bytes with InvalidCallbackResult.
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
     *         byte VALUE as a word): with bitSet(mask, elem) as the lambda
     *         and the All exit, this is the character-set test
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
     *         is the word): feed it an array PAYLOAD, the elements without
     *         the envelope, e.g. sliced out of a returned array
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

    // ============ Word Maps and Filters ============

    /**
     * @notice Applies a single-staticcall lambda to every word of `s` and
     *         returns the transformed payload: the bytes-producing map the
     *         scalar folds cannot express
     * @dev Lambda conventions match the folds: `template` is complete
     *      calldata for `target` whose 32-byte windows at `elemOffsets`
     *      are rewritten per element (supplied order; later windows win on
     *      mutual overlap), and the lambda must return exactly one word,
     *      the mapped element. An empty payload validates the template
     *      windows, then returns empty without inspecting the target. A
     *      code-less target reverts with InvalidCallbackTarget, a
     *      reverting application with CallbackFailed preserving calldata
     *      and reason, and a return other than one word with
     *      InvalidCallbackResult. One call per word.
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
     * @notice The words of `s` whose lambda application returns canonical
     *         ABI true, in order: the variable-length sibling of mapWords
     * @dev Lambda conventions and errors match mapWords, with one more
     *      rule: the returned word must be a canonical 0 or 1
     *      (InvalidCallbackResult otherwise). The output length is the
     *      kept count, so filters nest into byteLen, folds and further
     *      word operations.
     */
    function filterWords(bytes calldata s, address target, bytes calldata template, uint256[] calldata elemOffsets)
        external
        view
        returns (bytes memory)
    {
        return _applyWords(s, target, template, elemOffsets, true);
    }

    // ============ Word Payloads ============

    /**
     * @notice The payload 0, 1, 2, ..., n-1: the index generator that
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
     * @dev A payload that is not whole words reverts with UnalignedWords,
     *      as for every word operation below
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
            assembly ("memory-safe") {
                mstore(add(add(out, 32), mul(sub(sub(count, 1), i), 32)), w)
            }
        }
    }

    /**
     * @notice The two payloads interleaved, a0, b0, a1, b1, ...: pairs for
     *         a fold, or for unzipWords to split back
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
            assembly ("memory-safe") {
                mstore(add(add(out, 32), mul(mul(i, 2), 32)), wa)
                mstore(add(add(out, 32), mul(add(mul(i, 2), 1), 32)), wb)
            }
        }
    }

    /**
     * @notice Every second word of the payload, lane 0 (words 0, 2, 4, ...)
     *         or lane 1 (words 1, 3, 5, ...): zipWords' inverse
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
            assembly ("memory-safe") {
                mstore(add(add(out, 32), mul(i, 32)), w)
            }
        }
    }

    /**
     * @notice The payload sorted ascending as unsigned words
     * @dev Stable bottom-up merge sort: O(n log n) comparisons and moves,
     *      with O(n) scratch memory. Signed sorting is a three-node recipe
     *      instead of an overload: flip the sign bit (mapWords with
     *      bitXor(2^255, elem)), sort, flip back.
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
     * @notice The checked sum of the payload's 32-byte words: a native
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
     * @notice The payload with duplicate words removed, keeping the first
     *         occurrence of each in its original position
     * @param s The word payload
     * @param ordered Whether equal words are already grouped together (as
     *        after sortWords). When true only adjacent duplicates are
     *        compared, O(n); otherwise every retained word is checked, O(n
     *        squared). The grouping is trusted, not validated: an ungrouped
     *        payload declared ordered keeps non-adjacent duplicates.
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
        assembly ("memory-safe") {
            mstore(out, mul(kept, 32))
        }
    }

    // ============ Value Codec ============

    /**
     * @notice Asserts that `value` is the canonical single-value encoding
     *         of `valueType`, reverting with AbiCodec's InvalidValue at the
     *         offending offset otherwise (InvalidTypeDescriptor for a
     *         malformed descriptor)
     * @param valueType The value's type descriptor
     * @param value The encoding to check
     */
    function validateValue(string calldata valueType, bytes calldata value) external pure {
        AbiCodec.validate(bytes(valueType), value);
    }

    /**
     * @notice The canonical abi.encode(T[]) assembled from canonical
     *         abi.encode(T) elements: the bridge from a values array back
     *         to a single array value (unpackArray's inverse)
     * @dev Every element is validated against `elementType`; a mismatch
     *      reverts with AbiCodec's InvalidValue
     * @param elementType The element type descriptor
     * @param values One canonical single-value encoding per element
     */
    function packArray(string calldata elementType, bytes[] calldata values) external pure returns (bytes memory) {
        return AbiCodec.pack(bytes(elementType), values);
    }

    /**
     * @notice The canonical abi.encode(T) elements of a canonical
     *         abi.encode(T[]): the bridge from an array value (a `nav`
     *         terminal, a call return) into the values family
     * @dev The whole input is validated on the way; a non-canonical
     *      encoding reverts with AbiCodec's InvalidValue at the offending
     *      offset
     * @param elementType The element type descriptor
     * @param encoded The array value
     */
    function unpackArray(string calldata elementType, bytes calldata encoded) external pure returns (bytes[] memory) {
        return AbiCodec.unpack(bytes(elementType), encoded);
    }

    // ============ Value Traversals ============

    /**
     * @notice Applies the callback to every value and returns the results
     *         in order, each validated as a canonical `outputType`
     * @dev The rules shared by every callback operation below: the
     *      Callback is checked once up front (InvalidCallback), its
     *      constant slots validated against their declared types, every
     *      input validated as a canonical `inputType` (AbiCodec's
     *      InvalidValue), and the target's code checked lazily before the
     *      first application (InvalidCallbackTarget), so an empty input
     *      never touches the target. Each application is one staticcall
     *      with the element bound into slot `first`; a revert surfaces as
     *      CallbackFailed with the reason preserved, and a result that is
     *      not a canonical `outputType` as InvalidCallbackResult.
     * @param inputType The input element type descriptor
     * @param outputType The result element type descriptor
     * @param values The input elements
     * @param cb The unary callback
     */
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

    /**
     * @notice The values whose callback application returns true, in order
     * @dev Rules as mapValues. A predicate callback must return exactly one
     *      word holding a canonical 0 or 1; anything else reverts with
     *      InvalidCallbackResult.
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param cb The unary predicate callback
     */
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
        assembly ("memory-safe") { mstore(out, count) }
    }

    /**
     * @notice Left fold: the callback receives the accumulator in slot
     *         `first` and the element in slot `second`, and its result,
     *         validated as a canonical `accumulatorType`, becomes the next
     *         accumulator. An empty input returns `initial`
     * @dev Rules as mapValues. Unlike the word folds there is no early
     *      exit: an arbitrary ABI accumulator has no implicit truth value,
     *      so every element is visited.
     * @param inputType The element type descriptor
     * @param accumulatorType The accumulator type descriptor
     * @param values The input elements
     * @param initial The initial accumulator, a canonical `accumulatorType`
     * @param cb The binary callback
     */
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

    /**
     * @notice The values sorted ascending by a comparator callback, stably
     * @dev Rules as mapValues. The comparator receives two elements in
     *      slots `first` and `second` and returns one word read as a
     *      signed ordering: at most zero keeps `first` ahead, positive
     *      puts `second` ahead (a return other than one word reverts with
     *      InvalidCallbackResult). Bottom-up merge sort, O(n log n)
     *      comparator calls; the comparator is trusted to be a total
     *      order.
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param cb The binary comparator callback
     */
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

    /**
     * @notice The values with duplicates removed under a callback-defined
     *         equality, keeping the first representative of each class in
     *         its original position
     * @dev Rules as mapValues; the equality callback is a binary predicate
     *      (slot `first` a retained value, slot `second` the candidate)
     *      returning a canonical 0 or 1
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param cb The binary equality callback
     * @param ordered Whether equal values are already grouped together (as
     *        after sortValues). When true only the last retained value is
     *        compared, O(n) calls; otherwise every retained value is, O(n
     *        squared). The grouping is trusted, not validated.
     */
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
        assembly ("memory-safe") { mstore(out, count) }
    }

    /**
     * @notice The inner arrays concatenated in order: one level of
     *         flattening, every element validated as a canonical
     *         `inputType`
     * @param inputType The element type descriptor
     * @param values The arrays to concatenate
     */
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

    /**
     * @notice The values in reverse order, each validated as a canonical
     *         `inputType` and otherwise untouched
     * @param inputType The element type descriptor
     * @param values The input elements
     */
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

    /**
     * @notice values[start .. end) with JavaScript Array.slice semantics:
     *         signed indices, negative counting from the end, both clamped
     *         to the array bounds, end exclusive, and an empty result when
     *         end does not exceed start. Never reverts on the range
     * @dev Only the selected elements are validated as canonical
     *      `inputType` values
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param start The signed start index, inclusive
     * @param end The signed end index, exclusive
     */
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

    /**
     * @notice The index of the first value the equality callback matches
     *         against `needle`, or type(uint256).max when there is none
     * @dev Rules as mapValues; the callback is a binary predicate (slot
     *      `first` the element, slot `second` the needle) returning a
     *      canonical 0 or 1. Scanning stops at the first match. The needle
     *      is validated as a canonical `inputType` too.
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param needle The value to find, a canonical `inputType`
     * @param cb The binary equality callback
     */
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

    /**
     * @notice Whether the predicate holds for at least one value; false on
     *         an empty input
     * @dev Rules as filterValues; scanning stops at the first match
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param cb The unary predicate callback
     */
    function anyValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bool)
    {
        return _findValue(inputType, values, cb, true) != type(uint256).max;
    }

    /**
     * @notice Whether the predicate holds for every value; true on an
     *         empty input
     * @dev Rules as filterValues; scanning stops at the first miss
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param cb The unary predicate callback
     */
    function allValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (bool)
    {
        return _findValue(inputType, values, cb, false) == type(uint256).max;
    }

    /**
     * @notice The index of the first value the predicate holds for, or
     *         type(uint256).max when there is none
     * @dev Rules as filterValues; scanning stops at the first match
     * @param inputType The element type descriptor
     * @param values The input elements
     * @param cb The unary predicate callback
     */
    function findValues(string calldata inputType, bytes[] calldata values, Callback calldata cb)
        external
        view
        returns (uint256)
    {
        return _findValue(inputType, values, cb, true);
    }

    /**
     * @notice The two arrays paired element-wise into canonical values of
     *         the tuple type (leftType, rightType): the values-family
     *         zipWords
     * @dev Different lengths revert with WordCountMismatch; every element
     *      is validated as a canonical value of its side's type. A pair
     *      with a dynamic side is a dynamic tuple and carries the 0x20
     *      envelope, a static pair is its bare words.
     * @param leftType The left element type descriptor
     * @param rightType The right element type descriptor
     * @param left The left elements
     * @param right The right elements
     */
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

    /**
     * @notice One side of an array of canonical (leftType, rightType) pairs,
     *         lane 0 for the left and lane 1 for the right: zipValues'
     *         inverse
     * @dev A lane past 1 reverts with InvalidLane. Each pair is split
     *      against the tuple layout and BOTH sides are validated, so a
     *      malformed pair reverts with AbiCodec's InvalidValue even when
     *      the requested lane is well-formed.
     * @param leftType The left element type descriptor
     * @param rightType The right element type descriptor
     * @param pairs The pair values
     * @param lane 0 for the left elements, 1 for the right
     */
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

    // ============ Internal Word Helpers ============

    /**
     * @dev The shared map/filter engine: one staticcall per word with the
     *      element windows rewritten. Filtering keeps the ELEMENT when the
     *      lambda returns a canonical 1 (and rejects anything but 0 or 1);
     *      mapping stores the lambda's word itself.
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
            assembly ("memory-safe") {
                mstore(out, mul(kept, 32))
            }
        }
    }

    /**
     * @dev The i-th 32-byte word of a memory payload (caller bounds-checks)
     */
    function _wordAt(bytes memory b, uint256 i) private pure returns (uint256 w) {
        assembly ("memory-safe") {
            w := mload(add(add(b, 32), mul(i, 32)))
        }
    }

    /**
     * @dev Writes the i-th 32-byte word of a memory payload (caller
     *      bounds-checks)
     */
    function _setWord(bytes memory b, uint256 i, uint256 w) private pure {
        assembly ("memory-safe") {
            mstore(add(add(b, 32), mul(i, 32)), w)
        }
    }

    /**
     * @dev Bounds-checks the accumulator window and every element window.
     *      Hoisted out of the element loop so a bad offset fails before
     *      any call.
     */
    function _checkWindows(bytes calldata template, uint256 accOffset, uint256[] calldata elemOffsets) private pure {
        if (template.length < 32 || accOffset > template.length - 32) {
            revert LambdaOffsetOutOfBounds(accOffset, template.length);
        }
        _checkElementWindows(template, elemOffsets);
    }

    /**
     * @dev The element-window half of `_checkWindows`, for the maps and
     *      filters that have no accumulator
     */
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
     *      value (Bytes), or the 32-byte word (Words)
     */
    function _domainElem(FoldDomain domain, uint256 i, bytes calldata s) private pure returns (bytes32) {
        if (domain == FoldDomain.Range) return bytes32(i);
        if (domain == FoldDomain.Bytes) return bytes32(uint256(uint8(s[i])));
        return bytes32(s[i * 32:i * 32 + 32]);
    }

    /**
     * @dev Writes the accumulator first, then every element window in the
     *      order of `elemOffsets` (the element wins on overlap with the
     *      accumulator; later element windows win on mutual overlap)
     */
    function _stampWindows(
        bytes memory callData,
        uint256 accOffset,
        bytes32 acc,
        uint256[] calldata elemOffsets,
        bytes32 elem
    ) private pure {
        assembly ("memory-safe") {
            mstore(add(add(callData, 32), accOffset), acc)
        }
        _stampElements(callData, elemOffsets, elem);
    }

    /**
     * @dev Writes `elem` into every element window, in `elemOffsets` order
     */
    function _stampElements(bytes memory callData, uint256[] calldata elemOffsets, bytes32 elem) private pure {
        for (uint256 j = 0; j < elemOffsets.length; j++) {
            uint256 elemOffset = elemOffsets[j];
            assembly ("memory-safe") {
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

    /**
     * @dev Requires a lambda or callback target to carry code; precompiles
     *      are not callbacks (InvalidCallbackTarget)
     */
    function _checkTarget(address target) private view {
        if (target.code.length == 0) revert InvalidCallbackTarget(target);
    }

    /**
     * @dev One lambda application: the staticcall, CallbackFailed with the
     *      reason on a revert, InvalidCallbackResult unless exactly one
     *      word came back
     */
    function _callWord(address target, bytes memory callData, uint256 index) private view returns (bytes32 word) {
        (bool success, bytes memory ret) = target.staticcall(callData);
        if (!success) revert CallbackFailed(msg.sig, index, 0, target, callData, ret);
        if (ret.length != 32) revert AbiCodec.InvalidCallbackResult(msg.sig, index, 0, target);
        assembly ("memory-safe") { word := mload(add(ret, 32)) }
    }

    /**
     * @dev The fold loop proper: stamp, call, replace the accumulator,
     *      honour the exit mode
     */
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

    // ============ Internal Value Helpers ============

    /**
     * @dev Clamps a signed slice index into 0 .. length (negative counts
     *      from the end; out-of-range indices clamp to the nearest bound)
     */
    function _sliceIndex(int256 index, uint256 length) private pure returns (uint256) {
        if (index < 0) return index < -int256(length) ? 0 : uint256(int256(length) + index);
        return uint256(index) > length ? length : uint256(index);
    }

    /**
     * @dev The shared engine of anyValues, allValues and findValues: the
     *      index of the first value whose predicate result equals
     *      `wanted`, or type(uint256).max
     */
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

    /**
     * @dev Splits one canonical pair value into its two canonical
     *      single-value encodings against the pair's layout, checking the
     *      envelope word, both offsets and exact consumption
     *      (AbiCodec.InvalidValue at the offending offset)
     */
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

    /**
     * @dev The layout of the pair tuple (leftType, rightType), built from
     *      the two shapes directly (no descriptor spans, which the pair
     *      operations never need)
     */
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

    /**
     * @dev Validates a callback result as a canonical `valueType`,
     *      reporting a mismatch as InvalidCallbackResult for element `i`
     */
    function _validateResult(string calldata valueType, bytes memory value, Callback calldata cb, uint256 i)
        private
        pure
    {
        AbiCodec.validate(bytes(valueType), value, AbiCodec.Context(1, msg.sig, i, 0, cb.target));
    }

    /**
     * @dev Checks a Callback once and parses its argument tuple: the slot
     *      indices must be in range (and distinct for a binary callback),
     *      the descriptor must be a parenthesized tuple with exactly one
     *      constant per component (InvalidCallback otherwise), and every
     *      constant outside the substituted slots must be a canonical
     *      value of its component type
     */
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

    /**
     * @dev Binds `value` into argument slot `slot`, validating it against
     *      the slot's component type first
     */
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

    /**
     * @dev One callback application over elements `i` (bound to slot
     *      `first`) and, when `binary`, `j` (bound to slot `second`):
     *      either a direct call of `selector` over the assembled argument
     *      tuple, or `Expressions.evaluateEncoded` over the slots when the
     *      Callback carries an expression. Returns the raw result; a revert
     *      surfaces as CallbackFailed with the reason.
     */
    function _callValue(
        Callback calldata cb,
        PreparedCallback memory prepared,
        bytes memory a,
        bytes memory b,
        bool binary,
        uint256 i,
        uint256 j
    ) private view returns (bytes memory out) {
        // The target is checked lazily so operations with nothing to call
        // never touch it; every application is a staticcall, so its code
        // cannot change mid-operation.
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

    /**
     * @dev `_callValue` read as a predicate: the result must be exactly one
     *      word holding a canonical 0 or 1 (InvalidCallbackResult
     *      otherwise). Stricter than the core's `cond`, which accepts any
     *      nonzero first word: a callback RESULT is a declared bool, not a
     *      condition operand.
     */
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
