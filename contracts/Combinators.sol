// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {
    ComposableLib,
    InputParam,
    ReturnDataOutOfBounds
} from "./ERC8211.sol";

/**
 * @title Combinators
 * @author Sembrestels
 * @notice Composable building blocks for the Assertions core, redesigned
 *         around ERC-8211 (Smart Batching): every operand is an ERC-8211
 *         `InputParam` — a literal (RAW_BYTES), a live state read
 *         (STATIC_CALL), or a balance query (BALANCE) — resolved with the
 *         standard's exact fetcher semantics and validated against its own
 *         inline constraints. `resolve` passes a resolved value through,
 *         `pick` selects a raw 32-byte word from it, `nav` navigates typed
 *         returndata to an element (following runtime offsets through
 *         tuples and dynamic arrays), `chain` follows runtime-resolved
 *         addresses across staticcalls, `calc` combines two operands with
 *         an EVM-flavored opcode, `unary` transforms one, `data` operates
 *         on resolved returndata (string tests, hashing, lengths), and
 *         `env` supplies constants and environment values.
 *         Assertions judge, Combinators compute.
 * @dev Every function is a combinator — a building block that computes and
 *      returns a value, never an assertion (though operand constraints
 *      revert mid-expression when violated, like inline asserts). Because
 *      a STATIC_CALL operand may itself target this contract, nested
 *      InputParams compose the combinators into arbitrary expressions, and
 *      because every combinator returns plain returndata, each one is a
 *      valid STATIC_CALL fetcher target for any ERC-8211 batch — this
 *      contract fills the expressiveness gaps of the standard's constraint
 *      set (arithmetic, cross-value comparison, environment values, string
 *      operations) without extending it. The frozen Assertions core judges
 *      the final value: point a constrained STATIC_CALL fetcher at this
 *      contract's address with the encoded expression as calldata, e.g.
 *      assertParam(InputParam(CALL_DATA, STATIC_CALL,
 *      abi.encode(combinators, abi.encodeCall(calc, (...))), constraints)).
 *      Combinators is the versionable periphery to the frozen core — its
 *      functions are stateless view targets, so old versions never break
 *      and new versions deploy at new addresses without touching the core.
 * @custom:version 2.0
 */
contract Combinators {
    // ============ Custom Errors ============
    //
    // CallFailed, ConstraintFailed, InvalidBalanceData, InvalidConstraintData,
    // ReturnDataOutOfBounds and InvalidAddressWord are shared with the
    // resolution library and declared in ERC8211.sol.

    /// @notice Thrown when chain receives an empty calls array
    error EmptyCallChain();

    /// @notice Thrown when data(Split) receives an empty delimiter
    error EmptyDelimiter();

    /// @notice Thrown when data(Split)'s segment index is outside the segments
    ///         the split produced (in either direction for negative indices)
    /// @param index The requested segment index, as given (may be negative)
    /// @param segments The number of segments the split produced
    error SegmentIndexOutOfBounds(int256 index, uint256 segments);

    /// @notice Thrown when data(Includes) receives an empty search string —
    ///         every string vacuously contains "", so the test would always
    ///         pass and is certainly a mistake
    error EmptySubstring();

    /// @notice Thrown when data(Charset) receives a mask that is not exactly
    ///         32 bytes — the character-class bitmap is a full uint256 word
    /// @param length The length of the mask that was passed
    error InvalidMaskLength(uint256 length);

    /// @notice Thrown when a nav path index is outside the tuple or array it
    ///         indexes into (in either direction for negative array indices)
    /// @param index The requested element index, as given (may be negative)
    /// @param count The number of components / elements available
    error ElementIndexOutOfBounds(int256 index, uint256 count);

    /// @notice Thrown when nav cannot proceed: the type descriptor is
    ///         malformed, a path step indexes into a non-composite value, or
    ///         the terminal cannot be represented as a single return
    /// @param position The byte position in the descriptor where navigation
    ///        failed (0 when the descriptor itself is unusable)
    error InvalidNavigation(uint256 position);

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
    ///      operand resolves to)
    enum UnaryOp {
        Not,
        IsZero,
        Balance,
        CodeHash
    }

    /// @notice Returndata operations for data
    /// @dev ABI-encoded as uint8: Split = 0, Includes = 1, Charset = 2
    ///      (string ops — the resolved value is decoded as a single
    ///      ABI-encoded string first), Hash = 3, ByteLen = 4 (raw ops over
    ///      the resolved bytes)
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
    ///      (`arg` is the address as a uint256). Timestamp is the
    ///      "timestamp helper" ERC-8211 predicate entries reference.
    enum EnvOp {
        Constant,
        Timestamp,
        BlockNumber,
        ChainId,
        Balance,
        CodeHash
    }

    // ============ Resolve ============

    /// @notice Resolves an ERC-8211 input parameter and returns the
    ///         resolved bytes unchanged
    /// @dev THE primitive — the ERC-8211 static call, exposed as a
    ///      combinator. The value is returned via a raw assembly return,
    ///      indistinguishable from a contract returning it directly, so
    ///      nesting a resolve inside any operand behaves exactly like
    ///      calling the underlying target. Constraints on `param` are
    ///      validated before returning (a violation reverts with
    ///      ConstraintFailed identifying the constraint), which turns any
    ///      expression node into an inline assert.
    /// @param param The input parameter to resolve (paramType is ignored;
    ///        nothing is routed)
    function resolve(InputParam calldata param) external view {
        bytes memory value = ComposableLib.resolve(param, "", 0, 0);
        assembly {
            return(add(value, 32), mload(value))
        }
    }

    // ============ Pick ============

    /// @notice Resolves an input parameter and returns one raw 32-byte word
    ///         of the resolved bytes
    /// @dev The word extractor for multi-value returns: word positions
    ///      follow the raw ABI encoding of the resolved data (so dynamic
    ///      types contribute head offsets, a single dynamic array's length
    ///      sits at word 1 and its elements at words 2+i). `wordIndex` is
    ///      0-based; negative counts from the end (-1 = last word),
    ///      resolved against the live data. Reverts with
    ///      ReturnDataOutOfBounds outside the full words in either
    ///      direction.
    /// @param param The input parameter to resolve
    /// @param wordIndex The word to select (signed; negative from the end)
    /// @return The selected 32-byte word
    function pick(InputParam calldata param, int256 wordIndex) external view returns (bytes32) {
        bytes memory value = ComposableLib.resolve(param, "", 0, 0);
        return _rawWord(value, wordIndex);
    }

    // ============ Nav ============

    /// @notice Sentinel path entry for nav: as the LAST entry of a path it
    ///         selects the decoded LENGTH of the dynamic value the preceding
    ///         steps navigate to (array element count, or string/bytes byte
    ///         length) instead of the value itself
    /// @dev type(int256).min is unusable as an index (any real index bound
    ///      catches it first), so the sentinel is unambiguous
    int256 public constant LEN = type(int256).min;

    /// @notice Resolves an input parameter, interprets the resolved bytes as
    ///         ABI-encoded `retTypes`, and navigates `path` to an element —
    ///         following runtime offsets and lengths through tuples and
    ///         dynamic arrays, which raw word positions cannot express
    /// @dev The typed selector: `retTypes` is the value's type written as a
    ///      parenthesized tuple, e.g. "(uint112,uint112,address)" or
    ///      "(address,address[][])" (structs as parenthesized tuples), and
    ///      `path` walks it — the first step selects a tuple component
    ///      (non-negative), each further step indexes the current tuple or
    ///      array (array steps accept negative indices, resolved against the
    ///      live length, -1 = last). Only the SHAPE of the descriptor is
    ///      parsed (dynamic vs static, head footprints); base type names
    ///      beyond bytes/string are not interpreted. The declared type is
    ///      the author's claim about the encoder, like an inline ABI: a
    ///      wrong claim reverts loudly in almost all cases, but a
    ///      shape-compatible wrong type can read the wrong value.
    ///
    ///      The selection is returned via a raw assembly return,
    ///      indistinguishable from a contract returning that value directly,
    ///      so a nav nests inside any operand and any constrained fetcher
    ///      consumes it exactly as if it had called a contract returning
    ///      the element itself:
    ///      - empty path: the resolved bytes pass through byte-for-byte
    ///        (nav degenerates to resolve);
    ///      - word terminal (static single-word value): the 32-byte word;
    ///      - dynamic terminal (string/bytes/array): the canonical
    ///        single-value envelope [0x20][length][payload]. Arrays must
    ///        have single-word static elements; dynamic tuples and arrays
    ///        of dynamic elements revert with InvalidNavigation (their
    ///        extent would require a recursive re-encoder);
    ///      - a path ending in the LEN sentinel: the decoded length of the
    ///        dynamic value the preceding steps navigate to, as a uint256
    ///        word (element count for arrays, byte length for string/bytes
    ///        — UTF-8 characters may span multiple bytes).
    ///
    ///      Operand failures revert with CallFailed / ConstraintFailed
    ///      identifying them; a malformed descriptor, a step into a
    ///      non-composite or an unrepresentable terminal reverts with
    ///      InvalidNavigation, a path index outside its tuple or array with
    ///      ElementIndexOutOfBounds, and data that does not match the
    ///      declared shape (truncated returndata, out-of-range offsets)
    ///      with ReturnDataOutOfBounds.
    /// @param a The input parameter whose resolved bytes are navigated
    /// @param retTypes The resolved value's type as a parenthesized tuple
    /// @param path The navigation path (see modes above)
    function nav(InputParam calldata a, string calldata retTypes, int256[] calldata path) external view {
        bytes memory result = ComposableLib.resolve(a, "", 0, 0);
        bytes calldata t = bytes(retTypes);

        if (path.length == 0) {
            // Passthrough: any consumer decodes the resolved bytes as if it
            // had resolved the operand directly.
            assembly {
                return(add(result, 32), mload(result))
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

    // ============ Chain ============

    /// @notice Follows a chain of staticcalls whose targets are resolved at
    ///         execution time, and returns the final call's raw returndata
    /// @dev The runtime-target primitive ERC-8211 fetchers cannot express
    ///      (a STATIC_CALL fetcher's target is fixed at encoding time).
    ///      `start` must resolve to a clean address word — the first hop's
    ///      target. Each hop is a plain abi.encodeCall entry; every hop
    ///      except the last must return an address as its first word, which
    ///      becomes the next hop's target. The final hop's returndata is
    ///      returned via a raw assembly return, so a chain nests inside any
    ///      operand (wrap it in pick / data / calc to extract or transform),
    ///      e.g. balanceOf on the token address a vault reports:
    ///      chain(vaultAddressParam, [token(), balanceOf(vault)]).
    ///      Reverts with EmptyCallChain when `calls` is empty, CallFailed
    ///      identifying the exact failing hop, ReturnDataOutOfBounds when a
    ///      mid-chain hop returns fewer than 32 bytes, and
    ///      InvalidAddressWord (index 0 for `start`, hop index + 1 for
    ///      mid-chain hops) when an address word has dirty upper bytes.
    /// @param start The input parameter resolving to the first hop's target
    ///        address
    /// @param calls One plain abi.encodeCall entry per hop
    function chain(InputParam calldata start, bytes[] calldata calls) external view {
        if (calls.length == 0) revert EmptyCallChain();
        address current = ComposableLib.asAddress(
            ComposableLib.firstWord(ComposableLib.resolve(start, "", 0, 0)),
            0
        );
        uint256 last = calls.length - 1;
        for (uint256 i = 0; i < last; i++) {
            bytes memory hopResult = ComposableLib.staticCall(current, calls[i]);
            current = ComposableLib.asAddress(ComposableLib.firstWord(hopResult), i + 1);
        }
        bytes memory result = ComposableLib.staticCall(current, calls[last]);
        assembly {
            return(add(result, 32), mload(result))
        }
    }

    // ============ Calc ============

    /// @notice Combines two resolved operands with a binary word operation
    ///         and returns the resulting word
    /// @dev Composition primitive: operands are ERC-8211 InputParams and a
    ///      STATIC_CALL operand may itself target this contract (resolve,
    ///      pick, chain, calc, unary, env, ...), enabling recursive
    ///      expressions such as (a.x() + b.y()) * c.z(). Operands are read
    ///      as their resolved value's first 32-byte word — bools arrive as
    ///      0/1 words, signed values as two's complement — and the result
    ///      is a word, so any constrained fetcher consumes calc calldata
    ///      directly.
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
    ///      An operand whose staticcall reverts or targets a code-less
    ///      address reverts with CallFailed identifying it; an operand
    ///      resolving to fewer than 32 bytes reverts with
    ///      ReturnDataOutOfBounds; operand constraint violations revert
    ///      with ConstraintFailed (paramIndex 0 or 1 names the operand).
    /// @param op The operation to apply (see CalcOp)
    /// @param a The first operand
    /// @param b The second operand
    /// @return The resulting 32-byte word as a uint256
    function calc(CalcOp op, InputParam calldata a, InputParam calldata b) external view returns (uint256) {
        uint256 x = _word(a, 0);
        uint256 y = _word(b, 1);
        if (op == CalcOp.Add) return x + y;
        if (op == CalcOp.SAdd) return uint256(int256(x) + int256(y));
        if (op == CalcOp.Sub) return x - y;
        if (op == CalcOp.SSub) return uint256(int256(x) - int256(y));
        if (op == CalcOp.Mul) return x * y;
        if (op == CalcOp.SMul) return uint256(int256(x) * int256(y));
        if (op == CalcOp.Div) return x / y;
        if (op == CalcOp.SDiv) return uint256(int256(x) / int256(y));
        if (op == CalcOp.Mod) return x % y;
        if (op == CalcOp.SMod) return uint256(int256(x) % int256(y));
        if (op == CalcOp.Exp) return x ** y;
        if (op == CalcOp.Min) return x < y ? x : y;
        if (op == CalcOp.SMin) return int256(x) < int256(y) ? x : y;
        if (op == CalcOp.Max) return x > y ? x : y;
        if (op == CalcOp.SMax) return int256(x) > int256(y) ? x : y;
        if (op == CalcOp.AbsDiff) return x > y ? x - y : y - x;
        if (op == CalcOp.SAbsDiff) {
            // Signed compare, wrapping subtract: the two's-complement
            // difference of the raw words IS the distance, for any span.
            unchecked {
                return int256(x) > int256(y) ? x - y : y - x;
            }
        }
        if (op == CalcOp.And) return x & y;
        if (op == CalcOp.Or) return x | y;
        if (op == CalcOp.Xor) return x ^ y;
        if (op == CalcOp.Shl) return x << y;
        if (op == CalcOp.Shr) return x >> y;
        if (op == CalcOp.Eq) return x == y ? 1 : 0;
        if (op == CalcOp.Ne) return x != y ? 1 : 0;
        if (op == CalcOp.Lt) return x < y ? 1 : 0;
        if (op == CalcOp.SLt) return int256(x) < int256(y) ? 1 : 0;
        if (op == CalcOp.Gt) return x > y ? 1 : 0;
        if (op == CalcOp.SGt) return int256(x) > int256(y) ? 1 : 0;
        if (op == CalcOp.Le) return x <= y ? 1 : 0;
        if (op == CalcOp.SLe) return int256(x) <= int256(y) ? 1 : 0;
        if (op == CalcOp.Ge) return x >= y ? 1 : 0;
        return int256(x) >= int256(y) ? 1 : 0; // SGe
    }

    // ============ Unary ============

    /// @notice Transforms one resolved operand with a unary word operation
    ///         and returns the resulting word
    /// @dev Operand semantics are calc's (first-word read, nesting,
    ///      CallFailed / ReturnDataOutOfBounds / ConstraintFailed on
    ///      operand failure). Ops:
    ///      - Not: bitwise complement ~x;
    ///      - IsZero: 1 when the word is zero, 0 otherwise — logical
    ///        negation for bool operands (EVM ISZERO);
    ///      - Balance / CodeHash: the operand must resolve to an address (a
    ///        word with dirty upper bytes reverts with InvalidAddressWord);
    ///        returns its native balance in wei, or its code hash with
    ///        EXTCODEHASH semantics (nonexistent account: 0; existing
    ///        code-less account: keccak256("")). This is how the balance or
    ///        code hash of a runtime-resolved address is read — for a
    ///        literal address use env(Balance/CodeHash), and for an
    ///        ERC-20 balance use the BALANCE fetcher directly.
    /// @param op The operation to apply (see UnaryOp)
    /// @param a The operand
    /// @return The resulting 32-byte word as a uint256
    function unary(UnaryOp op, InputParam calldata a) external view returns (uint256) {
        uint256 word = _word(a, 0);
        if (op == UnaryOp.Not) return ~word;
        if (op == UnaryOp.IsZero) return word == 0 ? 1 : 0;
        address account = ComposableLib.asAddress(bytes32(word), 0);
        if (op == UnaryOp.Balance) return account.balance;
        return uint256(account.codehash);
    }

    // ============ Data ============

    /// @notice Resolves an operand and applies a returndata operation to
    ///         the resolved bytes
    /// @dev String ops decode the resolved value as a single ABI-encoded
    ///      string first (validating the head offset and length), so a
    ///      STATIC_CALL operand can point at any string getter and a
    ///      RAW_BYTES literal must carry abi.encode(string):
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
    ///      Raw ops consume the resolved bytes as-is (`arg` and `index`
    ///      are ignored — pass "" and 0):
    ///      - Hash: keccak256 of the resolved bytes, letting an EQ
    ///        constraint pin complex or hard-to-decode returns;
    ///      - ByteLen: the raw byte length (a uint256[] with n items is
    ///        64 + n * 32: offset word + length word + items).
    ///      Results return via raw assembly return: Split as a string
    ///      envelope, the others as a single word (Includes/Charset as 0/1).
    ///      Operand failures revert with CallFailed / ReturnDataOutOfBounds
    ///      / ConstraintFailed identifying them.
    /// @param op The operation to apply (see DataOp)
    /// @param a The operand whose resolved bytes are operated on
    /// @param arg The operation's byte argument (delimiter / needle / mask;
    ///        "" for Hash and ByteLen)
    /// @param index The segment index for Split (0 for the other ops)
    function data(DataOp op, InputParam calldata a, bytes calldata arg, int256 index) external view {
        bytes memory result = ComposableLib.resolve(a, "", 0, 0);
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
    ///      time — pointing a constrained STATIC_CALL fetcher here is how
    ///      an ERC-8211 predicate gates on time, block height or chain;
    ///      Balance / CodeHash read the native balance in wei or the code
    ///      hash (EXTCODEHASH semantics, as in unary) of the address `arg`,
    ///      which must fit 160 bits (reverts with InvalidAddressWord
    ///      otherwise). For addresses only known at assertion time, use
    ///      unary(Balance/CodeHash) over the resolving operand instead.
    /// @param op The value to return (see EnvOp)
    /// @param arg The literal for Constant, the address as uint256 for
    ///        Balance / CodeHash, 0 otherwise
    /// @return The requested value as a 32-byte word
    function env(EnvOp op, uint256 arg) external view returns (uint256) {
        if (op == EnvOp.Constant) return arg;
        if (op == EnvOp.Timestamp) return block.timestamp;
        if (op == EnvOp.BlockNumber) return block.number;
        if (op == EnvOp.ChainId) return block.chainid;
        address account = ComposableLib.asAddress(bytes32(arg), 0);
        if (op == EnvOp.Balance) return account.balance;
        return uint256(account.codehash);
    }

    // ============ Internal Helpers ============

    /// @dev Resolves an operand (validating its constraints) and returns
    ///      its first 32-byte word; `operandIndex` names the operand in
    ///      resolution errors
    function _word(InputParam calldata param, uint256 operandIndex) internal view returns (uint256) {
        return uint256(ComposableLib.firstWord(ComposableLib.resolve(param, "", 0, operandIndex)));
    }

    /// @dev Reads the wordIndex-th 32-byte word of the raw bytes
    ///      (0-based; negative from the end, -1 = last word), reverting with
    ///      ReturnDataOutOfBounds outside the full words in either direction
    function _rawWord(bytes memory result, int256 wordIndex) internal pure returns (bytes32 word) {
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

    // ---- Typed navigation internals ----

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

    /// @dev Reads the 32-byte word at byte offset `pos` of `result`, reverting
    ///      with ReturnDataOutOfBounds when it lies outside the data
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
    ///      the descriptor, its byte position in the data, and — after
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
    ///      `t` (which must be a parenthesized tuple). Returns the byte
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
    ///      offset and length against the actual data. The copy zeroes the
    ///      final word's padding so no dirty bytes remain.
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
