// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Combinators
 * @author Sembrestels
 * @notice Five composable building blocks for the Assertions core: `read`
 *         resolves navigated staticcall chains, `calc` combines two words
 *         with an EVM-flavored opcode, `unary` transforms one, `data`
 *         operates on raw returndata (string tests, hashing, lengths), and
 *         `env` supplies constants and environment values. Assertions
 *         judge, Combinators compute.
 * @dev Every function is a combinator — a building block that computes and
 *      returns a value, never an assertion. Operands are (target, data)
 *      pairs, and because an operand may itself be a call to this contract,
 *      nested operands in calldata compose the combinators into arbitrary
 *      expressions. The frozen Assertions core judges the final value:
 *      point any call assertion at this contract's address with the encoded
 *      expression as data, e.g.
 *      assertGtCallUint(combinators, abi.encodeCall(calc, (...)), 0).
 *      Combinators is the versionable periphery to the frozen core — its
 *      functions are stateless view targets, so old versions never break
 *      and new versions deploy at new addresses without touching the core.
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
    ///        decodes; may be negative for raw-mode from-the-end indexing)
    /// @param length The length of the returned data in bytes
    error ReturnDataOutOfBounds(int256 index, uint256 length);

    /// @notice Thrown when read or data receives an empty calls array
    error EmptyCallChain();

    /// @notice Thrown when read's per-hop arrays disagree in length —
    ///         calls, retTypes and paths must carry one entry per hop
    /// @param callsLength The length of the calls array
    /// @param typesLength The length of the retTypes array
    /// @param pathsLength The length of the paths array
    error ArgumentCountMismatch(uint256 callsLength, uint256 typesLength, uint256 pathsLength);

    /// @notice Thrown when a word that must hold an address has dirty upper
    ///         bytes (a chain hop's selected word, or the address operand of
    ///         a Balance / CodeHash operation)
    /// @param hopIndex The position of the hop in `calls` (0 for non-chain uses)
    /// @param word The raw 32-byte word that was selected
    error InvalidAddressWord(uint256 hopIndex, bytes32 word);

    /// @notice Thrown when data(Split) receives an empty delimiter
    error EmptyDelimiter();

    /// @notice Thrown when data(Split)'s segment index is outside the segments
    ///         the split produced (in either direction for negative indices)
    /// @param index The requested segment index, as given (may be negative)
    /// @param segments The number of segments the split produced
    error SegmentIndexOutOfBounds(int256 index, uint256 segments);

    /// @notice Thrown when data(Includes) receives an empty search string —
    ///         every string vacuously contains "", so the assertion would
    ///         always pass and is certainly a mistake
    error EmptySubstring();

    /// @notice Thrown when data(Charset) receives a mask that is not exactly
    ///         32 bytes — the character-class bitmap is a full uint256 word
    /// @param length The length of the mask that was passed
    error InvalidMaskLength(uint256 length);

    /// @notice Thrown when a navigation path index is outside the tuple or
    ///         array it steps into (in either direction for negative array
    ///         indices; tuple components only accept non-negative indices)
    /// @param index The requested index, as given (may be negative)
    /// @param elements The number of elements or components available
    error ElementIndexOutOfBounds(int256 index, uint256 elements);

    /// @notice Thrown when navigation cannot proceed: the type descriptor is
    ///         malformed at the given character position, a path step indexes
    ///         into a non-composite value, a raw-mode path has more than one
    ///         entry, or the terminal is not representable (multi-word static
    ///         value where a word is required, dynamic tuple or array of
    ///         dynamic elements where an envelope is required, LEN step on a
    ///         value without a length word)
    /// @param charPos The character position in the type descriptor
    error InvalidNavigation(uint256 charPos);

    // ============ Types ============

    /// @notice Binary word operations for calc, EVM-flavored: unsigned ops
    ///         and their signed variants sit side by side, like the EVM's
    ///         own DIV/SDIV or LT/SLT opcode pairs
    /// @dev ABI-encoded as uint8:
    ///      Add = 0, SAdd = 1, Sub = 2, SSub = 3, Mul = 4, SMul = 5,
    ///      Div = 6, SDiv = 7, Mod = 8, SMod = 9, Exp = 10,
    ///      Min = 11, SMin = 12, Max = 13, SMax = 14,
    ///      AbsDiff = 15, SAbsDiff = 16,
    ///      And = 17, Or = 18, Xor = 19, Shl = 20, Shr = 21,
    ///      Eq = 22, Ne = 23, Lt = 24, SLt = 25, Gt = 26, SGt = 27,
    ///      Le = 28, SLe = 29, Ge = 30, SGe = 31.
    ///      There is no SExp: Solidity defines `**` for unsigned operands
    ///      only, so signed exponentiation is ill-defined.
    enum CalcOp {
        Add,
        SAdd,
        Sub,
        SSub,
        Mul,
        SMul,
        Div,
        SDiv,
        Mod,
        SMod,
        Exp,
        Min,
        SMin,
        Max,
        SMax,
        AbsDiff,
        SAbsDiff,
        And,
        Or,
        Xor,
        Shl,
        Shr,
        Eq,
        Ne,
        Lt,
        SLt,
        Gt,
        SGt,
        Le,
        SLe,
        Ge,
        SGe
    }

    /// @notice Unary word operations for unary
    /// @dev ABI-encoded as uint8: Not = 0 (bitwise complement), IsZero = 1
    ///      (logical not: 1 for a zero word, 0 otherwise), Balance = 2 and
    ///      CodeHash = 3 (native balance / EXTCODEHASH of the address the
    ///      operand call returns)
    enum UnaryOp {
        Not,
        IsZero,
        Balance,
        CodeHash
    }

    /// @notice Returndata operations for data
    /// @dev ABI-encoded as uint8: Split = 0, Includes = 1, Charset = 2
    ///      (string ops — the final return is decoded as a string first),
    ///      Hash = 3, ByteLen = 4 (raw ops over the returndata bytes)
    enum DataOp {
        Split,
        Includes,
        Charset,
        Hash,
        ByteLen
    }

    /// @notice Value getters for env
    /// @dev ABI-encoded as uint8: Constant = 0 (echoes `arg`, covering both
    ///      uint and two's-complement int literals), Timestamp = 1,
    ///      BlockNumber = 2, ChainId = 3, Balance = 4 and CodeHash = 5
    ///      (`arg` is the address as a uint256)
    enum EnvOp {
        Constant,
        Timestamp,
        BlockNumber,
        ChainId,
        Balance,
        CodeHash
    }

    /// @notice Sentinel path entry for read: as the LAST entry of a typed
    ///         path it selects the decoded LENGTH of the dynamic value the
    ///         preceding steps navigate to (array element count, or
    ///         string/bytes byte length) instead of the value itself
    /// @dev type(int256).min is unusable as an index (any real index bound
    ///      catches it first), so the sentinel is unambiguous
    int256 public constant LEN = type(int256).min;

    // ============ Read ============

    /// @notice Resolves a chain of staticcalls with per-hop typed navigation
    ///         and returns the selected part of the final returndata.
    ///         calls[0] executes on `target`; for every earlier hop the value
    ///         its path selects (which must be a clean address word) becomes
    ///         the next hop's target; the final hop's path selects the result.
    /// @dev THE read primitive — every way of getting a value out of contract
    ///      state goes through it. `retTypes` and `paths` are parallel to
    ///      `calls`, one entry per hop, and each hop is in one of two modes:
    ///
    ///      TYPED — `retTypes[i]` is the hop's return tuple written as a
    ///      parenthesized type, e.g. "(uint112,uint112,address)" or
    ///      "((address,uint256)[])" (structs as parenthesized tuples), and
    ///      `paths[i]` walks it: the first step selects a return component
    ///      (non-negative), each further step indexes the current tuple or
    ///      array (array steps accept negative indices, resolved against the
    ///      live length, -1 = last). Only the SHAPE of the descriptor is
    ///      parsed (dynamic vs static, head footprints); base type names
    ///      beyond bytes/string are not interpreted. The declared type is
    ///      the author's claim about the encoder, like an inline ABI: a
    ///      wrong claim reverts loudly in almost all cases, but a
    ///      shape-compatible wrong type can read the wrong value.
    ///
    ///      RAW — `retTypes[i]` is "" and `paths[i]` holds at most one raw
    ///      word index into the returndata (signed; negative from the end,
    ///      -1 = last word; empty defaults to word 0 mid-chain). No decoding:
    ///      word positions follow the raw ABI encoding, so dynamic types
    ///      contribute head offsets, not their content.
    ///
    ///      The FINAL hop's selection is returned via a raw assembly return,
    ///      indistinguishable from a contract returning that value directly,
    ///      so every core call assertion (and every combinator consuming a
    ///      nested read) decodes it exactly as if it had called the final
    ///      target itself:
    ///      - empty path: the raw returndata passes through byte-for-byte;
    ///      - word terminal (typed or raw mode): the 32-byte word;
    ///      - dynamic terminal (typed string/bytes/array): the canonical
    ///        single-value envelope [0x20][length][payload]. Arrays must
    ///        have single-word static elements; dynamic tuples and arrays
    ///        of dynamic elements revert with InvalidNavigation (their
    ///        extent would require a recursive re-encoder);
    ///      - a typed path ending in the LEN sentinel: the decoded length
    ///        of the dynamic value the preceding steps navigate to, as a
    ///        uint256 word (element count for arrays, byte length for
    ///        string/bytes — UTF-8 characters may span multiple bytes).
    ///
    ///      Reverts with EmptyCallChain when `calls` is empty,
    ///      ArgumentCountMismatch when the arrays disagree in length,
    ///      CallFailed identifying the exact failing hop when a hop reverts
    ///      or targets a code-less address, InvalidNavigation on a malformed
    ///      descriptor / step into a non-composite / unrepresentable
    ///      terminal, ElementIndexOutOfBounds when a path index is outside
    ///      its tuple or array, ReturnDataOutOfBounds when the data does not
    ///      match the declared shape (truncated returndata, out-of-range
    ///      offsets or raw word indices), and InvalidAddressWord when a
    ///      mid-chain selection has dirty upper bytes.
    /// @param target The contract address the first call is executed on
    /// @param calls One plain abi.encodeCall entry per hop
    /// @param retTypes One return-type descriptor per hop ("" for raw mode)
    /// @param paths One navigation path per hop (see modes above)
    function read(
        address target,
        bytes[] calldata calls,
        string[] calldata retTypes,
        int256[][] calldata paths
    ) external view {
        if (calls.length == 0) revert EmptyCallChain();
        if (retTypes.length != calls.length || paths.length != calls.length) {
            revert ArgumentCountMismatch(calls.length, retTypes.length, paths.length);
        }

        address current = target;
        uint256 last = calls.length - 1;
        for (uint256 i = 0; i < last; i++) {
            bytes memory hopResult = _call(current, calls[i]);
            uint256 word = _hopWord(hopResult, bytes(retTypes[i]), paths[i]);
            if (word >> 160 != 0) revert InvalidAddressWord(i, bytes32(word));
            current = address(uint160(word));
        }

        bytes memory result = _call(current, calls[last]);
        bytes calldata t = bytes(retTypes[last]);
        int256[] calldata path = paths[last];

        if (path.length == 0) {
            // Raw passthrough: any assertion decodes the final hop's return
            // as if it had called the final target directly.
            assembly {
                return(add(result, 32), mload(result))
            }
        }
        if (t.length == 0) {
            if (path.length != 1) revert InvalidNavigation(0);
            uint256 word = _rawWord(result, path[0]);
            assembly {
                mstore(0, word)
                return(0, 32)
            }
        }
        if (path[path.length - 1] == LEN) {
            uint256 length = _navLength(result, t, path[:path.length - 1]);
            assembly {
                mstore(0, length)
                return(0, 32)
            }
        }
        (uint256 pos, bool isWord, uint256 ts, uint256 te) = _navigate(result, t, path);
        if (isWord) {
            uint256 word = _navWord(result, pos);
            assembly {
                mstore(0, word)
                return(0, 32)
            }
        }
        _returnDynamic(result, t, pos, ts, te);
    }

    // ============ Calc ============

    /// @notice Combines the results of two staticcalls with a binary word
    ///         operation and returns the resulting word
    /// @dev Composition primitive: operands are (target, data) pairs and may
    ///      themselves be calls to this contract (read, calc, unary, env, ...),
    ///      enabling recursive expressions such as (a.x() + b.y()) * c.z().
    ///      Operands are read as raw 32-byte words — bools arrive as 0/1
    ///      words, signed values as two's complement — and the result is a
    ///      word, so any core call assertion consumes calc calldata directly.
    ///
    ///      Signedness is chosen per opcode, EVM-style, not per function:
    ///      Add/Sub/Mul/Div/Mod/Min/Max/AbsDiff and the comparisons treat
    ///      words as uint256, their S-variants as int256. Arithmetic uses
    ///      Solidity 0.8 checked semantics for both (overflow/underflow
    ///      reverts with Panic(0x11), division or modulo by zero with
    ///      Panic(0x12); SDiv truncates toward zero, SMod takes the sign of
    ///      the dividend, type(int256).min / -1 reverts). Exceptions:
    ///      - Shl/Shr shift by operand2 with EVM semantics (shifts of 256 or
    ///        more yield 0, no revert);
    ///      - AbsDiff and SAbsDiff return the MAGNITUDE |a - b| as a uint256
    ///        and are total — SAbsDiff compares signed and subtracts with a
    ///        two's-complement wrap, so even the widest span (int256 min to
    ///        max) yields its exact distance instead of reverting. Consume
    ///        the result with unsigned comparisons.
    ///      - Eq/Ne/Lt/Gt/Le/Ge and S-variants return 1 or 0, composing with
    ///        And/Or/Xor/IsZero into boolean expressions (on 0/1 words the
    ///        bitwise ops coincide with logical ones).
    ///      For Exp, operand1 is the base and operand2 the exponent
    ///      (0 ** 0 == 1 per EVM semantics) — canonical use is live decimals
    ///      scaling, e.g. 5 * 10 ** token.decimals(). There is no SExp.
    ///      An operand that reverts or targets a code-less address reverts
    ///      with CallFailed identifying it; an operand returning fewer than
    ///      32 bytes reverts with ReturnDataOutOfBounds.
    /// @param op The operation to apply (see CalcOp)
    /// @param target1 The contract address of the first operand call
    /// @param data1 The encoded first operand call (use abi.encodeCall)
    /// @param target2 The contract address of the second operand call
    /// @param data2 The encoded second operand call (use abi.encodeCall)
    /// @return The resulting 32-byte word as a uint256
    function calc(
        CalcOp op,
        address target1,
        bytes calldata data1,
        address target2,
        bytes calldata data2
    ) external view returns (uint256) {
        uint256 a = uint256(_callWord(target1, data1));
        uint256 b = uint256(_callWord(target2, data2));
        if (op == CalcOp.Add) return a + b;
        if (op == CalcOp.SAdd) return uint256(int256(a) + int256(b));
        if (op == CalcOp.Sub) return a - b;
        if (op == CalcOp.SSub) return uint256(int256(a) - int256(b));
        if (op == CalcOp.Mul) return a * b;
        if (op == CalcOp.SMul) return uint256(int256(a) * int256(b));
        if (op == CalcOp.Div) return a / b;
        if (op == CalcOp.SDiv) return uint256(int256(a) / int256(b));
        if (op == CalcOp.Mod) return a % b;
        if (op == CalcOp.SMod) return uint256(int256(a) % int256(b));
        if (op == CalcOp.Exp) return a ** b;
        if (op == CalcOp.Min) return a < b ? a : b;
        if (op == CalcOp.SMin) return int256(a) < int256(b) ? a : b;
        if (op == CalcOp.Max) return a > b ? a : b;
        if (op == CalcOp.SMax) return int256(a) > int256(b) ? a : b;
        if (op == CalcOp.AbsDiff) return a > b ? a - b : b - a;
        if (op == CalcOp.SAbsDiff) {
            // Signed compare, wrapping subtract: the two's-complement
            // difference of the raw words IS the distance, for any span.
            unchecked {
                return int256(a) > int256(b) ? a - b : b - a;
            }
        }
        if (op == CalcOp.And) return a & b;
        if (op == CalcOp.Or) return a | b;
        if (op == CalcOp.Xor) return a ^ b;
        if (op == CalcOp.Shl) return a << b;
        if (op == CalcOp.Shr) return a >> b;
        if (op == CalcOp.Eq) return a == b ? 1 : 0;
        if (op == CalcOp.Ne) return a != b ? 1 : 0;
        if (op == CalcOp.Lt) return a < b ? 1 : 0;
        if (op == CalcOp.SLt) return int256(a) < int256(b) ? 1 : 0;
        if (op == CalcOp.Gt) return a > b ? 1 : 0;
        if (op == CalcOp.SGt) return int256(a) > int256(b) ? 1 : 0;
        if (op == CalcOp.Le) return a <= b ? 1 : 0;
        if (op == CalcOp.SLe) return int256(a) <= int256(b) ? 1 : 0;
        if (op == CalcOp.Ge) return a >= b ? 1 : 0;
        return int256(a) >= int256(b) ? 1 : 0; // SGe
    }

    // ============ Unary ============

    /// @notice Transforms the result of one staticcall with a unary word
    ///         operation and returns the resulting word
    /// @dev Operand semantics are calc's (raw word read, nesting, CallFailed /
    ///      ReturnDataOutOfBounds on operand failure). Ops:
    ///      - Not: bitwise complement ~x;
    ///      - IsZero: 1 when the word is zero, 0 otherwise — logical
    ///        negation for bool operands (EVM ISZERO);
    ///      - Balance / CodeHash: the operand must return an address (a
    ///        word with dirty upper bytes reverts with InvalidAddressWord);
    ///        returns its native balance in wei, or its code hash with
    ///        EXTCODEHASH semantics (nonexistent account: 0; existing
    ///        code-less account: keccak256("")). This is how the balance or
    ///        code hash of a call-resolved address is read — for a literal
    ///        address use env(Balance/CodeHash), and for a chained call
    ///        nest read calldata as the operand.
    /// @param op The operation to apply (see UnaryOp)
    /// @param target The contract address of the operand call
    /// @param callData The encoded operand call (use abi.encodeCall)
    /// @return The resulting 32-byte word as a uint256
    function unary(UnaryOp op, address target, bytes calldata callData) external view returns (uint256) {
        uint256 word = uint256(_callWord(target, callData));
        if (op == UnaryOp.Not) return ~word;
        if (op == UnaryOp.IsZero) return word == 0 ? 1 : 0;
        if (word >> 160 != 0) revert InvalidAddressWord(0, bytes32(word));
        if (op == UnaryOp.Balance) return address(uint160(word)).balance;
        return uint256(address(uint160(word)).codehash);
    }

    // ============ Data ============

    /// @notice Resolves a chain of staticcalls and applies a returndata
    ///         operation to the final call's return
    /// @dev Chain hops here are plain abi.encodeCall entries; every hop
    ///      except the last must return an address as its first word (for
    ///      multi-value or navigated hops, route through read by nesting its
    ///      calldata as a single-hop chain on this contract). A single call
    ///      is a one-element array.
    ///
    ///      String ops decode the final return as a single ABI-encoded
    ///      string first (validating the head offset and length the same way
    ///      the core's tuple-indexed string assertions do):
    ///      - Split: splits by `arg` (a non-empty exact byte sequence) and
    ///        returns the index-th segment as a canonical string return.
    ///        Segments are the maximal runs between occurrences, so adjacent
    ///        delimiters produce empty segments and a string without the
    ///        delimiter is one segment. `index` is 0-based; negative counts
    ///        from the end (-1 = last), resolved against the live segment
    ///        count. Reverts with EmptyDelimiter on an empty `arg` and
    ///        SegmentIndexOutOfBounds outside -segments .. segments-1.
    ///      - Includes: 1 when the string contains `arg` as a substring
    ///        (exact byte-sequence search — case-sensitive, no wildcards),
    ///        else 0. Reverts with EmptySubstring on an empty `arg`.
    ///      - Charset: 1 when every byte of the string is in the 256-bit
    ///        character set `arg` (a 32-byte mask, bit i covering byte value
    ///        i — lowercase a-z is bits 97..122, so an empty string is
    ///        vacuously 1). Reverts with InvalidMaskLength unless `arg` is
    ///        exactly 32 bytes. Multi-byte UTF-8 characters have bytes
    ///        >= 0x80 and fail any ASCII-only mask.
    ///      Raw ops consume the returndata bytes as-is (`arg` and `index`
    ///      are ignored — pass "" and 0):
    ///      - Hash: keccak256 of the raw returndata, letting the bytes32
    ///        assertions pin complex or hard-to-decode returns;
    ///      - ByteLen: the raw byte length (a uint256[] with n items is
    ///        64 + n * 32: offset word + length word + items).
    ///      Results return via raw assembly return: Split as a string
    ///      envelope, the others as a single word (Includes/Charset as 0/1).
    ///      Chain resolution failures revert with CallFailed / 
    ///      ReturnDataOutOfBounds / InvalidAddressWord identifying the hop.
    /// @param op The operation to apply (see DataOp)
    /// @param target The contract address the first call is executed on
    /// @param calls One plain abi.encodeCall entry per hop; every hop except
    ///        the last must return an address as its first word
    /// @param arg The operation's byte argument (delimiter / needle / mask;
    ///        "" for Hash and ByteLen)
    /// @param index The segment index for Split (0 for the other ops)
    function data(
        DataOp op,
        address target,
        bytes[] calldata calls,
        bytes calldata arg,
        int256 index
    ) external view {
        bytes memory result = _resolveChain(target, calls);
        if (op == DataOp.Hash) {
            bytes32 digest = keccak256(result);
            assembly {
                mstore(0, digest)
                return(0, 32)
            }
        }
        if (op == DataOp.ByteLen) {
            uint256 byteLength = result.length;
            assembly {
                mstore(0, byteLength)
                return(0, 32)
            }
        }

        bytes memory str = _decodeString(result);
        if (op == DataOp.Includes) {
            if (arg.length == 0) revert EmptySubstring();
            uint256 found = _includes(str, arg) ? 1 : 0;
            assembly {
                mstore(0, found)
                return(0, 32)
            }
        }
        if (op == DataOp.Charset) {
            if (arg.length != 32) revert InvalidMaskLength(arg.length);
            uint256 allowed = uint256(bytes32(arg));
            uint256 ok = 1;
            for (uint256 i = 0; i < str.length; i++) {
                if (allowed & (1 << uint8(str[i])) == 0) {
                    ok = 0;
                    break;
                }
            }
            assembly {
                mstore(0, ok)
                return(0, 32)
            }
        }

        // Split
        if (arg.length == 0) revert EmptyDelimiter();
        bytes memory out = abi.encode(_split(str, arg, index));
        assembly {
            return(add(out, 32), mload(out))
        }
    }

    // ============ Env ============

    /// @notice Returns a constant or an environment value as a word
    /// @dev The expression leaves: Constant echoes `arg` (both uint literals
    ///      and two's-complement int literals travel as the raw word),
    ///      turning any literal into a composition operand; Timestamp /
    ///      BlockNumber / ChainId read the block environment at assertion
    ///      time; Balance / CodeHash read the native balance in wei or the
    ///      code hash (EXTCODEHASH semantics, as in unary) of the address
    ///      `arg`, which must fit 160 bits (reverts with InvalidAddressWord
    ///      otherwise). For addresses only known at assertion time, use
    ///      unary(Balance/CodeHash) over the resolving call instead.
    /// @param op The value to return (see EnvOp)
    /// @param arg The literal for Constant, the address as uint256 for
    ///        Balance / CodeHash, 0 otherwise
    /// @return The requested value as a 32-byte word
    function env(EnvOp op, uint256 arg) external view returns (uint256) {
        if (op == EnvOp.Constant) return arg;
        if (op == EnvOp.Timestamp) return block.timestamp;
        if (op == EnvOp.BlockNumber) return block.number;
        if (op == EnvOp.ChainId) return block.chainid;
        if (arg >> 160 != 0) revert InvalidAddressWord(0, bytes32(arg));
        if (op == EnvOp.Balance) return address(uint160(arg)).balance;
        return uint256(address(uint160(arg)).codehash);
    }

    // ============ Internal Helpers ============

    /// @dev Executes a staticcall and returns the raw result bytes.
    ///      Reverts with CallFailed when the target has no code, since a staticcall
    ///      to a code-less address succeeds with empty returndata and would otherwise
    ///      surface as an opaque ABI decoding error.
    function _call(address target, bytes calldata callData) internal view returns (bytes memory) {
        if (target.code.length == 0) revert CallFailed(target, callData);
        (bool success, bytes memory result) = target.staticcall(callData);
        if (!success) revert CallFailed(target, callData);
        return result;
    }

    /// @dev Executes a staticcall and returns the first 32-byte word of the result,
    ///      reverting with ReturnDataOutOfBounds when fewer than 32 bytes come back.
    function _callWord(address target, bytes calldata callData) internal view returns (bytes32) {
        bytes memory result = _call(target, callData);
        if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
        return abi.decode(result, (bytes32));
    }

    /// @dev Executes data's call chain: every hop except the last must
    ///      return an address as its first word, which becomes the next
    ///      hop's target; the final hop's raw returndata is returned.
    function _resolveChain(address target, bytes[] calldata calls) internal view returns (bytes memory) {
        if (calls.length == 0) revert EmptyCallChain();
        address current = target;
        uint256 last = calls.length - 1;
        for (uint256 i = 0; i < last; i++) {
            bytes memory result = _call(current, calls[i]);
            if (result.length < 32) revert ReturnDataOutOfBounds(0, result.length);
            uint256 word;
            assembly {
                word := mload(add(result, 32))
            }
            if (word >> 160 != 0) revert InvalidAddressWord(i, bytes32(word));
            current = address(uint160(word));
        }
        return _call(current, calls[last]);
    }

    // ---- Read internals ----

    /// @dev Selects a mid-chain hop's address word: raw mode ("" descriptor)
    ///      reads the word at the path's single index (empty path = word 0),
    ///      typed mode navigates to a single-word terminal.
    function _hopWord(bytes memory result, bytes calldata t, int256[] calldata path) internal pure returns (uint256) {
        if (t.length == 0) {
            if (path.length == 0) return _rawWord(result, 0);
            if (path.length != 1) revert InvalidNavigation(0);
            return _rawWord(result, path[0]);
        }
        (uint256 pos, bool isWord, uint256 ts, ) = _navigate(result, t, path);
        if (!isWord) revert InvalidNavigation(ts);
        return _navWord(result, pos);
    }

    /// @dev Reads the wordIndex-th 32-byte word of the raw returndata
    ///      (0-based; negative from the end, -1 = last word), reverting with
    ///      ReturnDataOutOfBounds outside the full words in either direction
    function _rawWord(bytes memory result, int256 wordIndex) internal pure returns (uint256 word) {
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
        assembly {
            word := mload(add(add(result, 32), mul(wanted, 32)))
        }
    }

    /// @dev Resolves a LEN-terminated path: navigates the non-sentinel steps
    ///      to a dynamic value and returns its length word. Static values,
    ///      dynamic tuples and empty paths revert with InvalidNavigation
    ///      (a fixed array's length is known at composition time).
    function _navLength(bytes memory result, bytes calldata t, int256[] calldata path) internal pure returns (uint256) {
        if (path.length == 0) revert InvalidNavigation(0);
        (uint256 pos, bool isWord, uint256 ts, uint256 te) = _navigate(result, t, path);
        if (isWord) revert InvalidNavigation(ts);
        // Dynamic arrays and bytes/string sit on their length word; a
        // dynamic tuple's position is its first head word — no length there.
        if (t[te - 1] != "]" && t[ts] == "(") revert InvalidNavigation(ts);
        return _navWord(result, pos);
    }

    /// @dev Returns a navigated dynamic terminal re-encoded as a canonical
    ///      single-value return: [0x20][length][payload], indistinguishable
    ///      from a contract returning that value directly. Terminals may be
    ///      string, bytes, or a dynamic array of single-word static
    ///      elements; dynamic tuples and arrays of dynamic elements revert
    ///      with InvalidNavigation (their extent would require a recursive
    ///      re-encoder).
    function _returnDynamic(bytes memory result, bytes calldata t, uint256 pos, uint256 ts, uint256 te) internal pure {
        uint256 len = _navWord(result, pos);
        uint256 payloadBytes;
        if (t[te - 1] == "]") {
            uint256 suffix = _suffixStart(t, ts, te);
            (, bool elemDyn, uint256 elemWords) = _typeShape(t, ts, suffix);
            if (elemDyn) revert InvalidNavigation(ts);
            if (len > (result.length - pos - 32) / (elemWords * 32)) {
                revert ReturnDataOutOfBounds(int256(pos / 32), result.length);
            }
            payloadBytes = len * elemWords * 32;
        } else if (t[ts] == "(") {
            // dynamic tuple terminal: not extractable as a single envelope
            revert InvalidNavigation(ts);
        } else {
            // bytes / string: byte length, stored padded to full words
            payloadBytes = ((len + 31) / 32) * 32;
            if (len > result.length - pos - 32 || payloadBytes > result.length - pos - 32) {
                revert ReturnDataOutOfBounds(int256(pos / 32), result.length);
            }
        }
        assembly {
            let out := mload(0x40)
            mstore(out, 0x20)
            let src := add(add(result, 32), pos)
            let size := add(32, payloadBytes)
            for { let i := 0 } lt(i, size) { i := add(i, 32) } {
                mstore(add(add(out, 32), i), mload(add(src, i)))
            }
            return(out, add(32, size))
        }
    }

    // ---- Typed navigation internals ----

    /// @dev Reads the 32-byte word at byte offset `pos` of `result`, reverting
    ///      with ReturnDataOutOfBounds when it lies outside the returndata
    function _navWord(bytes memory result, uint256 pos) internal pure returns (uint256 word) {
        if (pos > result.length || result.length - pos < 32) {
            revert ReturnDataOutOfBounds(int256(pos / 32), result.length);
        }
        assembly {
            word := mload(add(add(result, 32), pos))
        }
    }

    /// @dev Parses the SHAPE of the type starting at `p` (bounded by `limit`):
    ///      where it ends, whether it is dynamic, and its head footprint in
    ///      words (1 for dynamic values — their head word is an offset).
    ///      Grammar: tuple `( type {"," type} )`, base identifier (bytes/string
    ///      are dynamic, anything else is one static word), then any number of
    ///      `[]` / `[k]` suffixes, the outermost binding last.
    function _typeShape(bytes calldata t, uint256 p, uint256 limit) internal pure returns (uint256 end, bool dyn, uint256 words) {
        if (p >= limit) revert InvalidNavigation(p);
        if (t[p] == "(") {
            uint256 q = p + 1;
            uint256 sum;
            while (true) {
                (uint256 e, bool d, uint256 w) = _typeShape(t, q, limit);
                if (d) dyn = true;
                sum += w;
                if (e >= limit) revert InvalidNavigation(e);
                if (t[e] == ",") {
                    q = e + 1;
                    continue;
                }
                if (t[e] == ")") {
                    end = e + 1;
                    break;
                }
                revert InvalidNavigation(e);
            }
            words = dyn ? 1 : sum;
        } else {
            uint256 q = p;
            while (q < limit && ((t[q] >= "a" && t[q] <= "z") || (t[q] >= "0" && t[q] <= "9"))) {
                q++;
            }
            if (q == p) revert InvalidNavigation(p);
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
            if (q2 >= limit || t[q2] != "]") revert InvalidNavigation(q2);
            if (fixedSize) {
                if (!dyn) words = words * k;
            } else {
                dyn = true;
                words = 1;
            }
            end = q2 + 1;
        }
    }

    /// @dev Position of the `[` opening the LAST suffix of the array type at
    ///      [ts, te) — the outermost constructor (te - 1 must be `]`)
    function _suffixStart(bytes calldata t, uint256 ts, uint256 te) internal pure returns (uint256 j) {
        j = te - 2;
        while (j > ts && t[j] >= "0" && t[j] <= "9") {
            j--;
        }
        if (t[j] != "[") revert InvalidNavigation(j);
    }

    /// @dev Normalizes a signed index against `count`, reverting with
    ///      ElementIndexOutOfBounds outside -count .. count-1
    function _navIndex(int256 index, uint256 count) internal pure returns (uint256) {
        if (index < 0) {
            // index == type(int256).min is caught here before -index could overflow.
            if (index < -int256(count)) revert ElementIndexOutOfBounds(index, count);
            return count - uint256(-index);
        }
        if (uint256(index) >= count) revert ElementIndexOutOfBounds(index, count);
        return uint256(index);
    }

    /// @dev Navigation cursor: the current value's type bounds [ts, te) in
    ///      the descriptor, its byte position in the returndata, and — after
    ///      a step — whether the value just selected is dynamic and its head
    ///      footprint. Position semantics: a tuple's position is its first
    ///      head word; a dynamic array's is its length word; a fixed array's
    ///      is its first element or offset word.
    struct NavCursor {
        uint256 ts;
        uint256 te;
        uint256 base;
        bool dyn;
        uint256 words;
    }

    /// @dev Walks `path` through `result` as described by the type descriptor
    ///      `t` (which must be a parenthesized return tuple). Returns the byte
    ///      position of the terminal — the value word itself when `isWord`,
    ///      otherwise the length word / head of the selected dynamic value —
    ///      plus the terminal's type bounds [ts, te) for the callers' checks.
    ///      Offsets are followed relative to their enclosing frame per ABI
    ///      encoding rules.
    function _navigate(bytes memory result, bytes calldata t, int256[] calldata path)
        internal
        pure
        returns (uint256 pos, bool isWord, uint256 ts, uint256 te)
    {
        if (t.length == 0 || t[0] != "(") revert InvalidNavigation(0);
        if (path.length == 0) revert InvalidNavigation(0);
        {
            (uint256 topEnd,,) = _typeShape(t, 0, t.length);
            if (topEnd != t.length) revert InvalidNavigation(topEnd);
        }

        NavCursor memory c = NavCursor(0, t.length, 0, true, 1);
        for (uint256 i = 0; i < path.length; i++) {
            if (t[c.te - 1] == "]") {
                _navArrayStep(result, t, c, path[i]);
            } else if (t[c.ts] == "(") {
                _navTupleStep(result, t, c, path[i]);
            } else {
                // base type (word, bytes or string): nothing to index into
                revert InvalidNavigation(c.ts);
            }
        }
        if (!c.dyn) {
            // multi-word static terminals (static tuples / fixed arrays)
            // have no single word to return
            if (c.words != 1) revert InvalidNavigation(c.ts);
            return (c.base, true, c.ts, c.te);
        }
        return (c.base, false, c.ts, c.te);
    }

    /// @dev One array step: bounds-checks the signed index against the live
    ///      (or fixed) length and advances the cursor to the element
    function _navArrayStep(bytes memory result, bytes calldata t, NavCursor memory c, int256 idx) private pure {
        uint256 suffix = _suffixStart(t, c.ts, c.te);
        (, bool elemDyn, uint256 elemWords) = _typeShape(t, c.ts, suffix);
        uint256 count;
        uint256 dataStart;
        if (suffix + 1 == c.te - 1) {
            // dynamic T[]: base is the length word, elements follow it
            count = _navWord(result, c.base);
            if (count > result.length / 32) {
                revert ReturnDataOutOfBounds(int256(c.base / 32), result.length);
            }
            dataStart = c.base + 32;
        } else {
            // fixed T[k]: no length word, k comes from the descriptor
            for (uint256 q = suffix + 1; t[q] != "]"; q++) {
                count = count * 10 + (uint8(t[q]) - 48);
            }
            dataStart = c.base;
        }
        uint256 wanted = _navIndex(idx, count);
        if (elemDyn) {
            uint256 off = _navWord(result, dataStart + wanted * 32);
            if (off > result.length) {
                revert ReturnDataOutOfBounds(int256((dataStart + wanted * 32) / 32), result.length);
            }
            c.base = dataStart + off;
        } else {
            c.base = dataStart + wanted * elemWords * 32;
        }
        c.te = suffix;
        c.dyn = elemDyn;
        c.words = elemWords;
    }

    /// @dev One tuple step: accumulates head footprints of the preceding
    ///      components (derived from the descriptor) and advances the cursor
    ///      to component `idx`
    function _navTupleStep(bytes memory result, bytes calldata t, NavCursor memory c, int256 idx) private pure {
        uint256 q = c.ts + 1;
        uint256 acc;
        uint256 j;
        if (idx < 0) {
            while (true) {
                (uint256 e,,) = _typeShape(t, q, c.te);
                j++;
                if (t[e] == ")") break;
                q = e + 1;
            }
            revert ElementIndexOutOfBounds(idx, j);
        }
        while (true) {
            (uint256 e, bool d, uint256 w) = _typeShape(t, q, c.te);
            if (j == uint256(idx)) {
                if (d) {
                    uint256 off = _navWord(result, c.base + acc * 32);
                    if (off > result.length) {
                        revert ReturnDataOutOfBounds(int256((c.base + acc * 32) / 32), result.length);
                    }
                    c.base = c.base + off;
                } else {
                    c.base = c.base + acc * 32;
                }
                c.ts = q;
                c.te = e;
                c.dyn = d;
                c.words = w;
                return;
            }
            acc += w;
            j++;
            if (t[e] == ")") revert ElementIndexOutOfBounds(idx, j);
            q = e + 1;
        }
    }

    // ---- String internals ----

    /// @dev Whether `str` contains `needle` as an exact byte sequence
    ///      (caller guarantees a non-empty needle)
    function _includes(bytes memory str, bytes memory needle) internal pure returns (bool) {
        if (needle.length > str.length) return false;
        for (uint256 i = 0; i + needle.length <= str.length; i++) {
            if (_matchesAt(str, needle, i)) return true;
        }
        return false;
    }

    /// @dev Splits `str` by `delim` and returns the index-th segment
    ///      (0-based; negative from the end, -1 = last). Caller guarantees a
    ///      non-empty delimiter; reverts with SegmentIndexOutOfBounds when
    ///      the index lies outside the segments in either direction.
    function _split(bytes memory str, bytes memory delim, int256 index) internal pure returns (bytes memory) {
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
                if (segment == wanted) return _slice(str, start, i);
                segment++;
                i += delim.length;
                start = i;
            } else {
                i++;
            }
        }
        // _countSegments guarantees `wanted` names the trailing segment here.
        return _slice(str, start, str.length);
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
