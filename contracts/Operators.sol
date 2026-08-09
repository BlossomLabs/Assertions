// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AbiShape, InvalidTypeDescriptor} from "./AbiShape.sol";

/**
 * @title Operators
 * @author Sembrestels
 * @notice Plain-Solidity operator vocabulary for the Assertions core: word
 *         arithmetic and comparisons (with int256 overloads for signed
 *         semantics, and 512-bit mulDiv for overflow-free mul-then-div),
 *         bitwise operations, environment reads, bytes and string
 *         operations including decimal parsing, a runtime ABI encoder,
 *         and a bounded fold.
 *         Every function takes and returns plain ABI types — no ERC-8211
 *         anywhere. Composition happens in the core: its `read` primitive
 *         resolves operand expressions and splices the resolved values
 *         into this contract's calldata, so an operator call IS the
 *         composed expression. Any deployed view or pure contract extends
 *         the vocabulary through the same socket; Operators is just the
 *         canonical first extension.
 * @dev Named functions instead of op-code enums so decoded calldata reads
 *      on explorers: `ge(balance, 100e18)` needs no docs open. Signedness
 *      rides on the int256 overloads (decoders display negative operands
 *      correctly; int256 spans the full word, so raw spliced words pass
 *      through unchanged). Arithmetic uses Solidity 0.8 checked semantics
 *      (overflow reverts with Panic(0x11), division by zero with
 *      Panic(0x12)); shifts follow EVM semantics (256 or more yields 0).
 *      Operators is the versionable periphery to the frozen core: old
 *      versions never break, new versions deploy at new addresses.
 * @custom:version 1.0
 */
contract Operators {
    // ============ Custom Errors ============

    /**
     * @notice Thrown when slice bounds fall outside the data
     * @param start The requested start byte
     * @param len The requested length in bytes
     * @param dataLength The data's actual byte length
     */
    error SliceOutOfBounds(uint256 start, uint256 len, uint256 dataLength);

    /**
     * @notice Thrown when encode receives a values array whose length does
     *         not match the descriptor's component count
     * @param expected The component count the descriptor declares
     * @param actual The number of values passed
     */
    error ComponentCountMismatch(uint256 expected, uint256 actual);

    /**
     * @notice Thrown when a static component's value is not exactly its
     *         head footprint
     * @param index The component's position in the tuple
     * @param expectedBytes The component's head footprint in bytes
     * @param actualBytes The length of the value that was passed
     */
    error InvalidComponentLength(uint256 index, uint256 expectedBytes, uint256 actualBytes);

    /**
     * @notice Thrown when a dynamic component's value is not a canonical
     *         single-value envelope [0x20][tail]
     * @param index The component's position in the tuple
     * @param length The length of the value that was passed
     * @param head The value's first word (0x20 expected)
     */
    error InvalidComponentEnvelope(uint256 index, uint256 length, bytes32 head);

    /**
     * @notice Thrown when a fold lambda offset does not leave room for a
     *         32-byte word inside the template
     * @param offset The offending offset
     * @param templateLength The template's byte length
     */
    error LambdaOffsetOutOfBounds(uint256 offset, uint256 templateLength);

    /**
     * @notice Thrown when a fold lambda call reverts, or the lambda target
     *         has no code (index 0 with empty callData for the code check)
     * @param index The element index whose application failed
     * @param target The lambda target
     * @param callData The constructed lambda calldata
     */
    error LambdaCallFailed(uint256 index, address target, bytes callData);

    /**
     * @notice Thrown when a fold lambda returns fewer than 32 bytes
     * @param index The element index whose application returned short
     * @param length The returndata length
     */
    error LambdaReturnTooShort(uint256 index, uint256 length);

    /**
     * @notice Thrown when foldWords receives data that is not a whole
     *         number of 32-byte words — silent truncation of a partial
     *         trailing word would be a wrong-answer machine
     * @param length The offending data length
     */
    error UnalignedWords(uint256 length);

    /**
     * @notice Thrown when parseUint receives empty input — there is no
     *         number there, and 0 would be a silent wrong answer
     */
    error EmptyNumber();

    /**
     * @notice Thrown when parseUint meets a byte outside 0-9
     * @param position The byte position of the offending character
     * @param char The offending byte
     */
    error InvalidDecimalDigit(uint256 position, bytes1 char);

    /**
     * @notice Thrown when a rawCall staticcall reverts
     * @param target The called address
     * @param data The calldata that was sent
     */
    error RawCallFailed(address target, bytes data);

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
     * @notice Thrown when replace receives an empty needle — it would
     *         match everywhere, and inserting the replacement between
     *         every byte is certainly a mistake
     */
    error EmptyNeedle();

    // ============ Types ============

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

    // ============ Arithmetic ============

    /**
     * @notice a + b, checked
     */
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    /**
     * @notice a + b, signed, checked
     */
    function add(int256 a, int256 b) external pure returns (int256) {
        return a + b;
    }

    /**
     * @notice a - b, checked
     */
    function sub(uint256 a, uint256 b) external pure returns (uint256) {
        return a - b;
    }

    /**
     * @notice a - b, signed, checked
     */
    function sub(int256 a, int256 b) external pure returns (int256) {
        return a - b;
    }

    /**
     * @notice a * b, checked
     */
    function mul(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }

    /**
     * @notice a * b, signed, checked
     */
    function mul(int256 a, int256 b) external pure returns (int256) {
        return a * b;
    }

    /**
     * @notice a / b (division by zero reverts with Panic(0x12))
     */
    function div(uint256 a, uint256 b) external pure returns (uint256) {
        return a / b;
    }

    /**
     * @notice a / b, signed, truncating toward zero (type(int256).min / -1
     *         reverts with Panic(0x11))
     */
    function div(int256 a, int256 b) external pure returns (int256) {
        return a / b;
    }

    /**
     * @notice a % b (modulo by zero reverts with Panic(0x12))
     */
    function mod(uint256 a, uint256 b) external pure returns (uint256) {
        return a % b;
    }

    /**
     * @notice a % b, signed, taking the sign of the dividend
     */
    function mod(int256 a, int256 b) external pure returns (int256) {
        return a % b;
    }

    /**
     * @notice a ** b, checked (0 ** 0 == 1) — canonical use is live
     *         decimals scaling, e.g. mul(5, exp(10, token.decimals())).
     *         Unsigned only: Solidity defines ** for unsigned operands, so
     *         signed exponentiation is ill-defined
     */
    function exp(uint256 a, uint256 b) external pure returns (uint256) {
        return a ** b;
    }

    /**
     * @notice The smaller of a and b
     */
    function min(uint256 a, uint256 b) external pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @notice The smaller of a and b, signed
     */
    function min(int256 a, int256 b) external pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @notice The larger of a and b
     */
    function max(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @notice The larger of a and b, signed
     */
    function max(int256 a, int256 b) external pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @notice The magnitude |a - b|; total — never reverts
     */
    function absDiff(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    /**
     * @notice The magnitude |a - b| of two signed values as a uint256;
     *         total — a signed compare and a two's-complement wrapping
     *         subtract mean even the widest span (int256 min to max)
     *         yields its exact distance instead of reverting. Consume the
     *         result with unsigned comparisons
     */
    function absDiff(int256 a, int256 b) external pure returns (uint256) {
        unchecked {
            return a > b ? uint256(a) - uint256(b) : uint256(b) - uint256(a);
        }
    }

    /**
     * @notice floor(a * b / denominator) with a full 512-bit intermediate
     *         product — mul-then-div for values where the plain
     *         composition div(mul(a, b), d) would overflow, e.g.
     *         balance * price / 1e18
     * @dev Reverts with Panic(0x12) on a zero denominator and Panic(0x11)
     *      when the result does not fit 256 bits, matching the checked
     *      semantics of the plain operators
     */
    function mulDiv(uint256 a, uint256 b, uint256 denominator) external pure returns (uint256) {
        return _mulDiv(a, b, denominator);
    }

    /**
     * @notice ceil(a * b / denominator) with a full 512-bit intermediate
     *         product — mulDiv rounding up
     * @dev Revert semantics as mulDiv (a ceiling that lands on 2^256
     *      reverts with Panic(0x11))
     */
    function mulDivUp(uint256 a, uint256 b, uint256 denominator) external pure returns (uint256) {
        uint256 result = _mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @notice (a + b) % m over the full 512-bit sum (EVM ADDMOD —
     *         the addition does not wrap at 2^256)
     * @dev Modulo by zero reverts with Panic(0x12)
     */
    function addMod(uint256 a, uint256 b, uint256 m) external pure returns (uint256) {
        return addmod(a, b, m);
    }

    /**
     * @notice (a * b) % m over the full 512-bit product (EVM MULMOD —
     *         the multiplication does not wrap at 2^256)
     * @dev Modulo by zero reverts with Panic(0x12)
     */
    function mulMod(uint256 a, uint256 b, uint256 m) external pure returns (uint256) {
        return mulmod(a, b, m);
    }

    /**
     * @notice floor(sqrt(x)) — canonical use is AMM invariant checks,
     *         e.g. sqrt(mulDiv(x, y, 1e18))
     * @dev Babylonian method seeded by a bit scan: seven Newton
     *      iterations are exact for the full uint256 range
     */
    function sqrt(uint256 x) external pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x4) {
            r <<= 1;
        }
        unchecked {
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            uint256 r1 = x / r;
            return r < r1 ? r : r1;
        }
    }

    // ============ Comparisons ============

    /**
     * @notice a == b (bit-level, covers all word types)
     */
    function eq(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }

    /**
     * @notice a != b (bit-level, covers all word types)
     */
    function ne(uint256 a, uint256 b) external pure returns (bool) {
        return a != b;
    }

    /**
     * @notice a < b
     */
    function lt(uint256 a, uint256 b) external pure returns (bool) {
        return a < b;
    }

    /**
     * @notice a < b, signed
     */
    function lt(int256 a, int256 b) external pure returns (bool) {
        return a < b;
    }

    /**
     * @notice a > b
     */
    function gt(uint256 a, uint256 b) external pure returns (bool) {
        return a > b;
    }

    /**
     * @notice a > b, signed
     */
    function gt(int256 a, int256 b) external pure returns (bool) {
        return a > b;
    }

    /**
     * @notice a <= b
     */
    function le(uint256 a, uint256 b) external pure returns (bool) {
        return a <= b;
    }

    /**
     * @notice a <= b, signed
     */
    function le(int256 a, int256 b) external pure returns (bool) {
        return a <= b;
    }

    /**
     * @notice a >= b
     */
    function ge(uint256 a, uint256 b) external pure returns (bool) {
        return a >= b;
    }

    /**
     * @notice a >= b, signed
     */
    function ge(int256 a, int256 b) external pure returns (bool) {
        return a >= b;
    }

    // ============ Bitwise ============

    /**
     * @notice a & b — also conjoins comparison results, which splice as
     *         0/1 words
     */
    function bitAnd(uint256 a, uint256 b) external pure returns (uint256) {
        return a & b;
    }

    /**
     * @notice a | b — also disjoins comparison results
     */
    function bitOr(uint256 a, uint256 b) external pure returns (uint256) {
        return a | b;
    }

    /**
     * @notice a ^ b — bitXor(x, ~0) is bitwise NOT
     */
    function bitXor(uint256 a, uint256 b) external pure returns (uint256) {
        return a ^ b;
    }

    /**
     * @notice a << bits, EVM semantics (shifts of 256 or more yield 0)
     */
    function shl(uint256 a, uint256 bits) external pure returns (uint256) {
        return a << bits;
    }

    /**
     * @notice a >> bits, EVM semantics (shifts of 256 or more yield 0)
     */
    function shr(uint256 a, uint256 bits) external pure returns (uint256) {
        return a >> bits;
    }

    /**
     * @notice a >> bits, signed, arithmetic (EVM SAR): the sign fills in
     *         from the left, rounding toward negative infinity; shifts of
     *         256 or more yield 0 for non-negative a and -1 for negative
     * @dev With shl this is also the sign-extension recipe for narrow
     *      two's-complement fields sliced out of packed bytes:
     *      shr(int256(shl(x, 256 - bits)), 256 - bits) re-widens the low
     *      `bits` bits
     */
    function shr(int256 a, uint256 bits) external pure returns (int256) {
        return a >> bits;
    }

    /**
     * @notice Whether bit `index` of `mask` is set (indices past 255 are
     *         never set) — the character-class test: with a charset bitmap
     *         mask, bitSet(mask, byteValue) is a one-call fold lambda
     */
    function bitSet(uint256 mask, uint256 index) external pure returns (bool) {
        return (mask >> index) & 1 == 1;
    }

    // ============ Environment ============

    /**
     * @notice The native balance of `account` in wei, at judge time
     */
    function balance(address account) external view returns (uint256) {
        return account.balance;
    }

    /**
     * @notice The code hash of `account`, EXTCODEHASH semantics
     *         (nonexistent account: 0; existing code-less account:
     *         keccak256(""))
     */
    function codehash(address account) external view returns (bytes32) {
        return account.codehash;
    }

    /**
     * @notice The block timestamp at judge time — how an ERC-8211
     *         predicate gates on time
     */
    function timestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @notice The block number at judge time
     */
    function blockNumber() external view returns (uint256) {
        return block.number;
    }

    /**
     * @notice The chain id
     */
    function chainId() external view returns (uint256) {
        return block.chainid;
    }

    /**
     * @notice The block base fee in wei at judge time — how a predicate
     *         gates on fee conditions
     */
    function baseFee() external view returns (uint256) {
        return block.basefee;
    }

    /**
     * @notice The previous RANDAO mix of the block at judge time
     */
    function prevRandao() external view returns (uint256) {
        return block.prevrandao;
    }

    /**
     * @notice The block proposer's fee recipient at judge time
     */
    function coinbase() external view returns (address) {
        return block.coinbase;
    }

    /**
     * @notice The block gas limit at judge time
     */
    function gasLimit() external view returns (uint256) {
        return block.gaslimit;
    }

    /**
     * @notice The blob base fee in wei at judge time
     */
    function blobBaseFee() external view returns (uint256) {
        return block.blobbasefee;
    }

    /**
     * @notice The hash of block `n`, BLOCKHASH semantics: 0 for blocks
     *         older than 256 blocks, the current block, or the future
     */
    function blockHash(uint256 n) external view returns (bytes32) {
        return blockhash(n);
    }

    /**
     * @notice The transaction origin — lets an assertion gate on who is
     *         executing the batch it guards
     */
    function origin() external view returns (address) {
        return tx.origin;
    }

    /**
     * @notice The gas price of the transaction executing the batch, in wei
     *         (tx.gasprice) — gate a batch on the fee it is actually
     *         paying, e.g. le(gasPrice(), maxWei)
     */
    function gasPrice() external view returns (uint256) {
        return tx.gasprice;
    }

    /**
     * @notice The versioned hash of the executing transaction's index-th
     *         blob (BLOBHASH), or zero when the transaction carries no
     *         blob at that index — pin blob-carrying batches to the data
     *         they were built for (ne(blobHash(0), 0) asserts a blob is
     *         present at all)
     */
    function blobHash(uint256 index) external view returns (bytes32) {
        return blobhash(index);
    }

    // ============ Calls ============

    /**
     * @notice Executes a staticcall with raw calldata and returns the
     *         returndata as a bytes value
     * @dev The precompile reach-through: unlike the core's constructed
     *      calls, no selector is prepended and NO code-length check is
     *      performed, because precompiles (sha256 at 0x02, ecrecover at
     *      0x01, modexp at 0x05, ...) have no code and raw calldata is
     *      their entire input. The caveat is the flip side: a staticcall
     *      to a code-less non-precompile address "succeeds" with empty
     *      returndata — pin the result with byteLen or a constraint when
     *      that matters. A revert is wrapped as RawCallFailed carrying
     *      the calldata, consistent with the fold lambdas.
     * @param target The address to staticcall (precompiles included)
     * @param data The raw calldata
     * @return The raw returndata as a bytes value
     */
    function rawCall(address target, bytes calldata data) external view returns (bytes memory) {
        (bool success, bytes memory result) = target.staticcall(data);
        if (!success) revert RawCallFailed(target, data);
        return result;
    }

    /**
     * @notice The full runtime code of `account` as a bytes value —
     *         codehash's sibling for prefix/suffix/segment assertions
     *         (a code-less account yields empty bytes)
     */
    function code(address account) external view returns (bytes memory) {
        return account.code;
    }

    // ============ Bytes ============

    /**
     * @notice Concatenates the parts in order
     * @dev Returned as a normal bytes value (ABI envelope): the canonical
     *      form every consumer of a single bytes argument expects,
     *      including encode's values[]
     */
    function concat(bytes[] calldata parts) external pure returns (bytes memory out) {
        for (uint256 i = 0; i < parts.length; i++) {
            out = bytes.concat(out, parts[i]);
        }
    }

    /**
     * @notice data[start .. start + len), reverting with SliceOutOfBounds
     *         when the range leaves the data
     */
    function slice(bytes calldata data, uint256 start, uint256 len) external pure returns (bytes memory) {
        if (start > data.length || len > data.length - start) {
            revert SliceOutOfBounds(start, len, data.length);
        }
        return data[start:start + len];
    }

    /**
     * @notice The raw byte length of `data`
     */
    function byteLen(bytes calldata data) external pure returns (uint256) {
        return data.length;
    }

    /**
     * @notice keccak256 of `data` — lets an EQ constraint pin complex or
     *         hard-to-decode values (keccak is an opcode, not a precompile,
     *         so it must be a function here)
     */
    function hash(bytes calldata data) external pure returns (bytes32) {
        return keccak256(data);
    }


    /**
     * @notice keccak256 of the two words concatenated in ascending order —
     *         byte-identical to OpenZeppelin MerkleProof's node combiner,
     *         so a foldWords over a proof payload with this as the lambda
     *         and the leaf as the initial accumulator reproduces the root
     *         (order-preserving pair hashing composes as hash over concat)
     */
    function hashPairSorted(bytes32 a, bytes32 b) external pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    // ============ Search ============

    /**
     * @notice Position of the occurrence-th occurrence of `needle` in `s`,
     *         counted from the start (0, 1, 2, …) or from the end
     *         (-1 = last, -2 = second-last, …)
     * @dev The signed occurrence ordinal matches the repo-wide
     *      negative-index idiom (pick, nav). Occurrences are enumerated
     *      left to right and NON-overlapping — after a match the scan
     *      resumes past it, so in `aaaa` the needle `aa` occurs at 0 and
     *      2 — which is delimiter semantics: splitting and occurrence
     *      counting agree. Requesting an occurrence that does not exist
     *      (in either direction) returns the sentinel `s.length` (it
     *      composes: includes = lt(indexOf(s, n, 0), byteLen(s))).
     *      Split segments are two indexOf reads and a slice: segment
     *      k >= 0 spans [indexOf(s, d, k-1) + dlen, indexOf(s, d, k))
     *      (0 for k == 0; the sentinel ends the trailing segment for
     *      free), and segment -k spans
     *      [indexOf(s, d, -k) + dlen, indexOf(s, d, -k+1))
     *      (byteLen(s) for k == 1). Total by design — an empty needle
     *      vacuously matches at every position 0 .. s.length, and nothing
     *      here ever reverts.
     * @param s The haystack
     * @param needle The exact byte sequence to find
     * @param occurrence The signed occurrence ordinal (see above)
     * @return The match position, or s.length when there is none
     */
    function indexOf(bytes calldata s, bytes calldata needle, int256 occurrence) external pure returns (uint256) {
        if (needle.length == 0) {
            // Vacuous matches at every position 0 .. s.length.
            uint256 positions = s.length + 1;
            if (occurrence >= 0) {
                return uint256(occurrence) < positions ? uint256(occurrence) : s.length;
            }
            // occurrence == type(int256).min is caught here before
            // -occurrence could overflow.
            if (occurrence < -int256(positions)) return s.length;
            return positions - uint256(-occurrence);
        }
        uint256 wanted;
        if (occurrence < 0) {
            uint256 count = _countOccurrences(s, needle);
            // occurrence == type(int256).min is caught here before
            // -occurrence could overflow.
            if (occurrence < -int256(count)) return s.length;
            wanted = count - uint256(-occurrence);
        } else {
            wanted = uint256(occurrence);
        }
        uint256 seen;
        uint256 p;
        while (p + needle.length <= s.length) {
            if (_matchesAt(s, needle, p)) {
                if (seen == wanted) return p;
                seen++;
                p += needle.length;
            } else {
                p++;
            }
        }
        return s.length;
    }


    // ============ Strings ============

    /**
     * @notice `s` with every occurrence of `needle` replaced by `repl`
     * @dev Non-overlapping left-to-right scan, the same enumeration
     *      indexOf and occurrence counting use (in `aaaa` the needle `aa`
     *      is replaced at positions 0 and 2). An empty `repl` deletes;
     *      an empty needle reverts with EmptyNeedle (it would vacuously
     *      match everywhere)
     */
    function replace(bytes calldata s, bytes calldata needle, bytes calldata repl)
        external
        pure
        returns (bytes memory out)
    {
        if (needle.length == 0) revert EmptyNeedle();
        uint256 p;
        uint256 start;
        while (p + needle.length <= s.length) {
            if (_matchesAt(s, needle, p)) {
                out = bytes.concat(out, s[start:p], repl);
                p += needle.length;
                start = p;
            } else {
                p++;
            }
        }
        return bytes.concat(out, s[start:]);
    }

    /**
     * @notice `s` with ASCII A-Z folded to a-z; every other byte passes
     *         through verbatim (multi-byte UTF-8 units have the high bit
     *         set, so they are untouched — the fold is ASCII-only)
     */
    function toLower(bytes calldata s) external pure returns (bytes memory out) {
        out = s;
        for (uint256 i = 0; i < out.length; i++) {
            bytes1 c = out[i];
            if (c >= "A" && c <= "Z") out[i] = bytes1(uint8(c) + 32);
        }
    }

    /**
     * @notice `s` with ASCII a-z folded to A-Z; every other byte passes
     *         through verbatim (ASCII-only, like toLower)
     */
    function toUpper(bytes calldata s) external pure returns (bytes memory out) {
        out = s;
        for (uint256 i = 0; i < out.length; i++) {
            bytes1 c = out[i];
            if (c >= "a" && c <= "z") out[i] = bytes1(uint8(c) - 32);
        }
    }

    /**
     * @notice Whether every byte of `s` is a member of the 256-bit
     *         character-class `mask` (bit i set means byte value i is
     *         allowed) — a native single-call loop, the fixed-operation
     *         form of the foldBytes(bitSet, All) recipe. An empty string
     *         is vacuously in every set
     */
    function charset(bytes calldata s, uint256 mask) external pure returns (bool) {
        for (uint256 i = 0; i < s.length; i++) {
            if (mask & (uint256(1) << uint8(s[i])) == 0) return false;
        }
        return true;
    }

    // ============ Parse ============

    /**
     * @notice The uint256 a decimal ASCII string encodes — the bridge
     *         from string returns into arithmetic, e.g. comparing a
     *         version segment numerically:
     *         gt(parseUint(split-segment), 2)
     * @dev Strict by design: reverts with EmptyNumber on empty input and
     *      InvalidDecimalDigit on any byte outside 0-9 (no signs, no
     *      whitespace, no decimal points); a value past 2^256 - 1
     *      reverts with Panic(0x11) via the checked accumulator.
     *      Leading zeros are accepted ("007" is 7)
     */
    function parseUint(bytes calldata s) external pure returns (uint256 result) {
        if (s.length == 0) revert EmptyNumber();
        for (uint256 i = 0; i < s.length; i++) {
            bytes1 c = s[i];
            if (c < "0" || c > "9") revert InvalidDecimalDigit(i, c);
            result = result * 10 + (uint8(c) - 48);
        }
    }

    /**
     * @notice The decimal ASCII rendering of `v` — parseUint's inverse
     *         (no leading zeros, so toString(parseUint(s)) normalizes)
     */
    function toString(uint256 v) external pure returns (string memory) {
        if (v == 0) return "0";
        uint256 digits;
        for (uint256 t = v; t > 0; t /= 10) {
            digits++;
        }
        bytes memory buf = new bytes(digits);
        for (uint256 t = v; t > 0; t /= 10) {
            digits--;
            buf[digits] = bytes1(uint8(48 + (t % 10)));
        }
        return string(buf);
    }

    // ============ Encode ============

    /**
     * @notice Runtime abi.encode: assembles the canonical ABI encoding of
     *         a tuple from pre-encoded component values — nav's inverse
     * @dev `types` is the tuple's type as a parenthesized descriptor
     *      (nav's grammar, only the SHAPE is parsed). `values[i]` is the
     *      canonical single-value encoding of component i:
     *      - static component with head footprint w words: exactly w * 32
     *        bytes (one word for uint256/address/bool/bytes32, the
     *        flattened words for static tuples and fixed arrays), copied
     *        verbatim into the head;
     *      - dynamic component (bytes, string, T[], dynamic tuples): the
     *        canonical envelope [0x20][tail...] — exactly what a
     *        bytes-returning call, nav's dynamic terminal, or abi.encode
     *        of the single value produces. The leading offset word is
     *        stripped, the true top-level offset written into the head,
     *        and the tail appended verbatim. Because ABI offsets are
     *        frame-relative, verbatim tail splicing is correct at any
     *        nesting depth, so nested dynamics (string[], (uint,bytes)[])
     *        need no special handling.
     *      The output is returned via a raw assembly return with NO bytes
     *      envelope — deliberately the one raw-returning function here,
     *      because the output is a calldata SEGMENT for the core's read
     *      to splice, not a value to decode. Deep tail validation is
     *      skipped: like nav, the descriptor is the author's claim about
     *      the encoding, and a wrong claim about a tail travels as-is.
     *      Reverts with InvalidTypeDescriptor on a malformed descriptor,
     *      ComponentCountMismatch when values.length differs from the
     *      component count, InvalidComponentLength for a static component
     *      of the wrong size, and InvalidComponentEnvelope for a dynamic
     *      component that is not an envelope.
     * @param types The tuple type descriptor, e.g. "(address,uint256[])"
     * @param values One canonical single-value encoding per component
     */
    function encode(string calldata types, bytes[] calldata values) external pure {
        bytes calldata t = bytes(types);
        if (t.length == 0 || t[0] != "(") revert InvalidTypeDescriptor(0);
        {
            (uint256 topEnd,,) = AbiShape.typeShape(t, 0, t.length);
            if (topEnd != t.length) revert InvalidTypeDescriptor(topEnd);
        }

        (uint256 count, uint256 headBytes, uint256 tailBytes) = _measure(t, values);
        if (count != values.length) revert ComponentCountMismatch(count, values.length);

        bytes memory out = new bytes(headBytes + tailBytes);
        _assemble(t, values, out, headBytes);
        assembly {
            return(add(out, 32), mload(out))
        }
    }

    /**
     * @dev encode pass 1: walks the top-level components, validating each
     *      value against its component's shape and accumulating head and
     *      tail sizes. Returns the component count for the caller's
     *      count-mismatch check (validation is skipped past the end of
     *      `values` — the mismatch revert supersedes it).
     */
    function _measure(bytes calldata t, bytes[] calldata values)
        private
        pure
        returns (uint256 count, uint256 headBytes, uint256 tailBytes)
    {
        uint256 q = 1;
        while (true) {
            (uint256 e, bool dyn, uint256 words) = AbiShape.typeShape(t, q, t.length);
            if (count < values.length) {
                bytes calldata v = values[count];
                if (dyn) {
                    headBytes += 32;
                    if (v.length < 64 || v.length % 32 != 0 || bytes32(v[0:32]) != bytes32(uint256(0x20))) {
                        revert InvalidComponentEnvelope(count, v.length, v.length >= 32 ? bytes32(v[0:32]) : bytes32(0));
                    }
                    tailBytes += v.length - 32;
                } else {
                    headBytes += words * 32;
                    if (v.length != words * 32) {
                        revert InvalidComponentLength(count, words * 32, v.length);
                    }
                }
            }
            count++;
            if (t[e] == ")") break;
            q = e + 1;
        }
    }

    /**
     * @dev encode pass 2: emits heads and tails into the caller-sized
     *      allocation (values are pre-validated by _measure, so a static
     *      value's length IS its head footprint)
     */
    function _assemble(bytes calldata t, bytes[] calldata values, bytes memory out, uint256 headBytes) private pure {
        uint256 q = 1;
        uint256 headPos;
        uint256 tailPos = headBytes;
        for (uint256 i = 0; i < values.length; i++) {
            (uint256 e, bool dyn,) = AbiShape.typeShape(t, q, t.length);
            if (dyn) {
                assembly {
                    mstore(add(add(out, 32), headPos), tailPos)
                }
                _copy(out, tailPos, values[i][32:]);
                tailPos += values[i].length - 32;
                headPos += 32;
            } else {
                _copy(out, headPos, values[i]);
                headPos += values[i].length;
            }
            q = e + 1;
        }
    }



    // ============ Folds ============

    /**
     * @notice Folds the lambda over the index range 0 .. n-1 (the element
     *         substituted into the template is the index itself)
     * @dev The one loop primitive; foldBytes and foldWords share its
     *      engine and rules. The lambda is a single staticcall: `template`
     *      is complete calldata for `target` in which two 32-byte windows
     *      are rewritten per element — the accumulator at `accOffset`,
     *      then the element at `elemOffset` (the element wins on overlap;
     *      every byte outside the windows stays pristine template). The
     *      first return word becomes the new accumulator; `Any` stops at
     *      the first nonzero accumulator, `All` at the first zero, `Full`
     *      scans everything; the final accumulator is returned either
     *      way. An empty domain returns `init` without touching the
     *      lambda. A lambda revert is an assertion failure: it reverts
     *      the fold with LambdaCallFailed naming the element. Offsets
     *      must leave room for a word inside the template
     *      (LambdaOffsetOutOfBounds), a code-less target reverts with
     *      LambdaCallFailed(0, target, ""), and a lambda returning fewer
     *      than 32 bytes with LambdaReturnTooShort. Gas is the loop
     *      bound: every application pays real call overhead, so domain
     *      sizes are naturally limited by the block gas limit.
     * @param n The number of iterations
     * @param target The lambda contract
     * @param template Complete calldata for `target`, with the two windows
     * @param accOffset Byte offset of the accumulator window
     * @param elemOffset Byte offset of the element window
     * @param init The initial accumulator
     * @param exit The early-exit mode (see FoldExit)
     * @return The final accumulator
     */
    function foldRange(
        uint256 n,
        address target,
        bytes calldata template,
        uint256 accOffset,
        uint256 elemOffset,
        bytes32 init,
        FoldExit exit
    ) external view returns (bytes32) {
        return _fold(FoldDomain.Range, n, msg.data[0:0], target, template, accOffset, elemOffset, init, exit);
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
        uint256 elemOffset,
        bytes32 init,
        FoldExit exit
    ) external view returns (bytes32) {
        return _fold(FoldDomain.Bytes, s.length, s, target, template, accOffset, elemOffset, init, exit);
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
        uint256 elemOffset,
        bytes32 init,
        FoldExit exit
    ) external view returns (bytes32) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        return _fold(FoldDomain.Words, s.length / 32, s, target, template, accOffset, elemOffset, init, exit);
    }

    // ============ Word Arrays ============
    //
    // Pure shape operations over payloads of aligned 32-byte words (an
    // array's elements without the ABI envelope — slice one out of a
    // returned array, or feed the output of another word op). Every
    // function validates alignment first (UnalignedWords) and returns a
    // plain bytes payload, so they nest into each other, into the folds,
    // and into read splicing.

    /**
     * @notice Applies a single-staticcall lambda to every word of `s` and
     *         returns the transformed payload — the bytes-producing map
     *         the scalar folds cannot express
     * @dev Lambda conventions match the folds: `template` is complete
     *      calldata for `target` whose 32-byte window at `elemOffset` is
     *      rewritten per element; the lambda's FIRST return word is the
     *      mapped element. An empty payload returns empty without
     *      inspecting the lambda; a code-less target reverts with
     *      LambdaCallFailed(0, target, ""), a reverting application with
     *      LambdaCallFailed naming the element, a short return with
     *      LambdaReturnTooShort. Gas is the loop bound, one call per word.
     * @param s The word payload to map
     * @param target The lambda contract
     * @param template Complete calldata for `target` with the element window
     * @param elemOffset Byte offset of the element window
     * @return The mapped payload, same word count as `s`
     */
    function mapWords(bytes calldata s, address target, bytes calldata template, uint256 elemOffset)
        external
        view
        returns (bytes memory)
    {
        return _applyWords(s, target, template, elemOffset, false);
    }

    /**
     * @notice The words of `s` whose lambda application returns nonzero,
     *         in order — the variable-length sibling of mapWords
     * @dev Lambda conventions and errors match mapWords exactly; the
     *      output length is the kept count, so filters nest into len, at,
     *      folds and further word ops
     */
    function filterWords(bytes calldata s, address target, bytes calldata template, uint256 elemOffset)
        external
        view
        returns (bytes memory)
    {
        return _applyWords(s, target, template, elemOffset, true);
    }

    /**
     * @dev The shared map/filter engine: one staticcall per word with the
     *      element window rewritten; filtering keeps the ELEMENT when the
     *      lambda word is nonzero, mapping stores the lambda word itself
     */
    function _applyWords(
        bytes calldata s,
        address target,
        bytes calldata template,
        uint256 elemOffset,
        bool filterMode
    ) private view returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        if (template.length < 32 || elemOffset > template.length - 32) {
            revert LambdaOffsetOutOfBounds(elemOffset, template.length);
        }
        uint256 count = s.length / 32;
        out = new bytes(s.length);
        uint256 kept;
        if (count != 0) {
            if (target.code.length == 0) revert LambdaCallFailed(0, target, "");
            bytes memory callData = template;
            for (uint256 i = 0; i < count; i++) {
                bytes32 elem = bytes32(s[i * 32:i * 32 + 32]);
                assembly {
                    mstore(add(add(callData, 32), elemOffset), elem)
                }
                (bool success, bytes memory ret) = target.staticcall(callData);
                if (!success) revert LambdaCallFailed(i, target, callData);
                if (ret.length < 32) revert LambdaReturnTooShort(i, ret.length);
                bytes32 word;
                assembly {
                    word := mload(add(ret, 32))
                }
                if (filterMode) {
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
     * @dev Insertion sort: O(n^2) word moves, so gas caps practical
     *      inputs at hundreds of words, not thousands. Signed sorting is
     *      a three-node recipe instead of an overload: flip the sign bit
     *      (mapWords with bitXor(2^255, elem)), sort, flip back
     */
    function sortWords(bytes calldata s) external pure returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        out = s;
        uint256 count = s.length / 32;
        for (uint256 i = 1; i < count; i++) {
            uint256 key = _wordAt(out, i);
            uint256 j = i;
            while (j > 0 && _wordAt(out, j - 1) > key) {
                _setWord(out, j, _wordAt(out, j - 1));
                j--;
            }
            _setWord(out, j, key);
        }
    }

    /**
     * @notice The payload with ADJACENT duplicate words collapsed — O(n),
     *         so set-semantics deduplication is uniqueWords(sortWords(s));
     *         on unsorted input this is run-length deduplication, by design
     */
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

    function uniqueWords(bytes calldata s) external pure returns (bytes memory out) {
        if (s.length % 32 != 0) revert UnalignedWords(s.length);
        uint256 count = s.length / 32;
        out = new bytes(s.length);
        uint256 kept;
        for (uint256 i = 0; i < count; i++) {
            uint256 w = uint256(bytes32(s[i * 32:i * 32 + 32]));
            if (i == 0 || w != _wordAt(out, kept - 1)) {
                _setWord(out, kept, w);
                kept++;
            }
        }
        assembly {
            mstore(out, mul(kept, 32))
        }
    }

    // ============ Internal Helpers ============

    /**
     * @dev The i-th 32-byte word of a memory payload (caller bounds-checks)
     */
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
     * @dev Fold iteration domains: Range substitutes the index, Bytes the
     *      byte value at the index, Words the 32-byte word at the index
     */
    enum FoldDomain {
        Range,
        Bytes,
        Words
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
        uint256 elemOffset,
        bytes32 init,
        FoldExit exit
    ) private view returns (bytes32 acc) {
        if (template.length < 32 || accOffset > template.length - 32) {
            revert LambdaOffsetOutOfBounds(accOffset, template.length);
        }
        if (elemOffset > template.length - 32) {
            revert LambdaOffsetOutOfBounds(elemOffset, template.length);
        }
        acc = init;
        if (count == 0) return acc;
        if (target.code.length == 0) revert LambdaCallFailed(0, target, "");

        // One mutable copy; each iteration fully rewrites both windows.
        bytes memory callData = template;
        for (uint256 i = 0; i < count; i++) {
            bytes32 elem;
            if (domain == FoldDomain.Range) {
                elem = bytes32(i);
            } else if (domain == FoldDomain.Bytes) {
                elem = bytes32(uint256(uint8(s[i])));
            } else {
                elem = bytes32(s[i * 32:i * 32 + 32]);
            }
            assembly {
                mstore(add(add(callData, 32), accOffset), acc)
                mstore(add(add(callData, 32), elemOffset), elem)
            }
            (bool success, bytes memory ret) = target.staticcall(callData);
            if (!success) revert LambdaCallFailed(i, target, callData);
            if (ret.length < 32) revert LambdaReturnTooShort(i, ret.length);
            assembly {
                acc := mload(add(ret, 32))
            }
            if (exit == FoldExit.Any && acc != bytes32(0)) break;
            if (exit == FoldExit.All && acc == bytes32(0)) break;
        }
    }

    /**
     * @dev floor(a * b / denominator) over the 512-bit product
     *      [prod1 prod0], the classic Remco Bloemen construction: subtract
     *      the remainder, factor powers of two out of the denominator,
     *      then multiply by its inverse mod 2^256 (Newton doubles the
     *      correct low bits each step: 6 steps from a 4-bit seed cover
     *      all 256). Reverts with Panic(0x12) when denominator == 0 and
     *      Panic(0x11) when the result needs more than 256 bits.
     */
    function _mulDiv(uint256 a, uint256 b, uint256 denominator) private pure returns (uint256 result) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                // Plain division: Panic(0x12) on a zero denominator.
                return prod0 / denominator;
            }
            if (denominator <= prod1) {
                _panic(denominator == 0 ? 0x12 : 0x11);
            }
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (0 - denominator);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                // 2^256 / twos: flip the divided-out factor to the high side
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            result = prod0 * inverse;
        }
    }

    /**
     * @dev Reverts with the Solidity panic `code` (0x11 arithmetic
     *      overflow, 0x12 division by zero), byte-identical to the
     *      compiler's own checked-arithmetic reverts
     */
    function _panic(uint256 panicCode) private pure {
        assembly {
            mstore(0, 0x4e487b7100000000000000000000000000000000000000000000000000000000)
            mstore(4, panicCode)
            revert(0, 36)
        }
    }

    /**
     * @dev Number of non-overlapping occurrences of `needle` in `s`, left
     *      to right — the same scan the selection loop uses (caller
     *      guarantees a non-empty needle)
     */
    function _countOccurrences(bytes calldata s, bytes calldata needle) private pure returns (uint256 count) {
        uint256 p;
        while (p + needle.length <= s.length) {
            if (_matchesAt(s, needle, p)) {
                count++;
                p += needle.length;
            } else {
                p++;
            }
        }
    }

    /**
     * @dev Whether `needle` occurs in `s` at byte position `pos` (caller
     *      bounds-checks)
     */
    function _matchesAt(bytes calldata s, bytes calldata needle, uint256 pos) private pure returns (bool) {
        for (uint256 j = 0; j < needle.length; j++) {
            if (s[pos + j] != needle[j]) return false;
        }
        return true;
    }

    /**
     * @dev Copies `src` into `dst` starting at byte `at` (caller sizes dst)
     */
    function _copy(bytes memory dst, uint256 dstOffset, bytes calldata src) private pure {
        uint256 len = src.length;
        assembly {
            calldatacopy(add(add(dst, 32), dstOffset), src.offset, len)
        }
    }
}
