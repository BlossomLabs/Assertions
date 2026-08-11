// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {
    CallFailed,
    ComposableExecution,
    Constraint,
    ConstraintFailed,
    ConstraintType,
    InputParam,
    InputParamFetcherType,
    InputParamType,
    InvalidAddressWord,
    InvalidBalanceData,
    InvalidConstraintData,
    ReturnDataOutOfBounds
} from "./ERC8211.sol";
import {AbiShape, ElementIndexOutOfBounds, InvalidTypeDescriptor} from "./AbiShape.sol";

/**
 * @notice Minimal ERC-20 surface the BALANCE fetcher needs
 */
interface IERC20Balance {
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title Assertions
 * @author Sembrestels
 * @notice On-chain assertion contract for verifying blockchain state,
 *         designed around a static call to ERC-8211 (Smart Batching).
 *         An assertion IS an ERC-8211 predicate batch: entries whose input
 *         parameters resolve live on-chain values (staticcalls, balances,
 *         literals) and validate them against inline constraints. Batch
 *         assertion calls alongside the transactions they guard (DAO
 *         proposals, Safe batches, upgrades): if any constraint fails, the
 *         entire transaction reverts, atomically. Beyond the judge, this
 *         contract owns every primitive that speaks the ERC-8211 wire
 *         format: selection (`resolve`, `pick`, `nav`), call construction
 *         (`chain`, `read`) and resolution control (`cond`, `orElse`,
 *         `isValid`, `revertData`).
 * @dev The judge is view-only: assertComposable(executions) evaluates the
 *      ERC-8211 execution algorithm directly, restricted to what a view
 *      context can express: every fetcher resolution is a staticcall,
 *      entries with a TARGET parameter execute the constructed call via
 *      STATICCALL (the call itself becomes an assertion — it must not
 *      revert), VALUE parameters and outputParams are rejected (no ETH
 *      forwarding, no Storage writes in view). Entries without a TARGET
 *      parameter are standard ERC-8211 predicate entries. The encoding is
 *      the unmodified ERC-8211 wire format, so batches built by any
 *      ERC-8211 SDK judge here unchanged.
 *
 *      assertParam(param) is sugar for the 90% case: resolve one input
 *      parameter and validate its constraints, no batch scaffolding.
 *
 *      The admission test for this contract is resolution control: only
 *      what needs operands to arrive UNRESOLVED lives here. Every
 *      primitive holds InputParams and decides how (or whether) to
 *      resolve them; a STATIC_CALL operand may target this contract
 *      itself, so the primitives nest into arbitrary expressions.
 *      Computation over resolved values belongs to the versionable
 *      periphery: `read` resolves operand expressions and splices the
 *      values into plain calldata for any deployed view or pure contract
 *      — canonically the Operators contract, whose word arithmetic,
 *      comparisons, bytes operations, runtime encoder and bounded folds
 *      extend the vocabulary without touching this frozen core. The core
 *      reads and judges; Operators compute.
 * @custom:version 2.0
 */
contract Assertions {
    // ============ Custom Errors ============
    //
    // ConstraintFailed, CallFailed, InvalidBalanceData, InvalidConstraintData,
    // ReturnDataOutOfBounds and InvalidAddressWord are the standard's shared
    // errors, declared in ERC8211.sol; ElementIndexOutOfBounds and
    // InvalidTypeDescriptor come from AbiShape.sol with the descriptor
    // grammar that raises them.

    /**
     * @notice Thrown when an entry carries output parameters — Storage
     *         writes are impossible in a view-mode judge
     * @param entryIndex The offending entry's position in the batch
     */
    error OutputParamsNotSupported(uint256 entryIndex);

    /**
     * @notice Thrown when an entry carries a VALUE input parameter — ETH
     *         cannot be forwarded through a STATICCALL judge
     * @param entryIndex The offending entry's position in the batch
     * @param paramIndex The VALUE parameter's position within the entry
     */
    error ValueParamNotSupported(uint256 entryIndex, uint256 paramIndex);

    /**
     * @notice Thrown when an entry carries more than one TARGET input
     *         parameter (the standard allows at most one)
     * @param entryIndex The offending entry's position in the batch
     */
    error DuplicateTargetParam(uint256 entryIndex);

    /**
     * @notice Thrown when a TARGET input parameter uses the BALANCE
     *         fetcher (a balance cannot be a call target address)
     * @param entryIndex The offending entry's position in the batch
     * @param paramIndex The TARGET parameter's position within the entry
     */
    error BalanceCannotBeTarget(uint256 entryIndex, uint256 paramIndex);

    /**
     * @notice Thrown when chain receives an empty calls array
     */
    error EmptyCallChain();

    /**
     * @notice Thrown when nav cannot proceed: a path step indexes into a
     *         non-composite value, or the terminal cannot be represented as
     *         a single return (descriptor parse failures revert with
     *         InvalidTypeDescriptor instead)
     * @param position The byte position in the descriptor where navigation
     *        failed
     */
    error InvalidNavigation(uint256 position);

    /**
     * @notice Thrown when revertData's operand is not a STATIC_CALL
     *         parameter — only a call has a target whose revert reason
     *         could be reported
     * @param fetcherType The operand's fetcher type
     */
    error RevertProbeNotACall(uint8 fetcherType);

    /**
     * @notice Thrown when revertData's operand carries constraints. The
     *         probed call never produces a value, so a constraint on it
     *         could never be checked; rejecting it beats passing it over
     *         in silence
     * @param count The number of constraints on the operand
     */
    error RevertProbeConstrained(uint256 count);

    /**
     * @notice Thrown when revertData's operand did NOT revert
     * @param target The call target
     * @param callData The calldata that unexpectedly succeeded
     */
    error DidNotRevert(address target, bytes callData);

    /**
     * @notice Thrown when the revert data does not begin with the required
     *         error selector
     * @param expected The selector the caller required
     * @param actual The selector the call actually reverted with (zero when
     *        the revert carried fewer than four bytes)
     */
    error UnexpectedRevertData(bytes4 expected, bytes4 actual);

    // ============ Composable Batch Assertions ============

    /**
     * @notice Assert that an ERC-8211 composable batch passes under
     *         view-mode evaluation: every input parameter resolves, every
     *         constraint holds, and every constructed call succeeds as a
     *         staticcall
     * @param executions The ERC-8211 batch entries (standard wire format)
     */
    function assertComposable(ComposableExecution[] calldata executions) external view {
        _judge(executions, "COMPOSABLE");
    }

    /**
     * @notice Assert that an ERC-8211 composable batch passes under
     *         view-mode evaluation
     * @param executions The ERC-8211 batch entries (standard wire format)
     * @param message Custom error message on constraint failure
     */
    function assertComposable(ComposableExecution[] calldata executions, string calldata message) external view {
        _judge(executions, message);
    }

    // ============ Single-Parameter Assertions ============

    /**
     * @notice Assert one ERC-8211 input parameter: resolve its value via
     *         the fetcher and validate its inline constraints — the
     *         single-check shorthand for a one-parameter predicate entry
     * @param param The input parameter (paramType is ignored; nothing is routed)
     */
    function assertParam(InputParam calldata param) external view {
        _resolve(param, "PARAM", 0, 0);
    }

    /**
     * @notice Assert one ERC-8211 input parameter with a custom message
     * @param param The input parameter (paramType is ignored; nothing is routed)
     * @param message Custom error message on constraint failure
     */
    function assertParam(InputParam calldata param, string calldata message) external view {
        _resolve(param, message, 0, 0);
    }

    // ============ Resolve ============

    /**
     * @notice Resolves an ERC-8211 input parameter and returns the
     *         resolved bytes unchanged
     * @dev THE primitive — the ERC-8211 static call, exposed as a read.
     *      The value is returned via a raw assembly return,
     *      indistinguishable from a contract returning it directly, so
     *      nesting a resolve inside any operand behaves exactly like
     *      calling the underlying target. Constraints on `param` are
     *      validated before returning (a violation reverts with
     *      ConstraintFailed identifying the constraint), which turns any
     *      expression node into an inline assert.
     * @param param The input parameter to resolve (paramType is ignored;
     *        nothing is routed)
     */
    function resolve(InputParam calldata param) external view {
        bytes memory value = _resolve(param, "", 0, 0);
        assembly {
            return(add(value, 32), mload(value))
        }
    }

    // ============ Pick ============

    /**
     * @notice Resolves an input parameter and returns one raw 32-byte word
     *         of the resolved bytes
     * @dev The word extractor for multi-value returns: word positions
     *      follow the raw ABI encoding of the resolved data (so dynamic
     *      types contribute head offsets, a single dynamic array's length
     *      sits at word 1 and its elements at words 2+i). `wordIndex` is
     *      0-based; negative counts from the end (-1 = last word),
     *      resolved against the live data. Reverts with
     *      ReturnDataOutOfBounds outside the full words in either
     *      direction.
     * @param param The input parameter to resolve
     * @param wordIndex The word to select (signed; negative from the end)
     * @return The selected 32-byte word
     */
    function pick(InputParam calldata param, int256 wordIndex) external view returns (bytes32) {
        bytes memory value = _resolve(param, "", 0, 0);
        return _rawWord(value, wordIndex);
    }

    // ============ Nav ============

    /**
     * @notice Sentinel path entry for nav: as the LAST entry of a path it
     *         selects the decoded LENGTH of the dynamic value the preceding
     *         steps navigate to (array element count, or string/bytes byte
     *         length) instead of the value itself
     * @dev The sentinels sit at the bottom of the int256 range, where no
     *      value is usable as an index (any real index bound catches them
     *      first), so both are unambiguous
     */
    int256 public constant LEN = type(int256).min;

    /**
     * @notice Sentinel path entry for nav: as the LAST entry of a path it
     *         selects the raw PAYLOAD of the string or bytes value the
     *         preceding steps navigate to — exactly its byte length, no
     *         envelope, no padding. The typed-bytes re-entry point: a nav
     *         over THIS result claims the payload's encoding with an
     *         ordinary descriptor, so an encoded blob's content is
     *         reachable without the descriptor grammar leaving ABI syntax
     * @dev type(int256).min + 1, unusable as an index like LEN
     */
    int256 public constant PAYLOAD = type(int256).min + 1;

    /**
     * @notice Resolves an input parameter, interprets the resolved bytes as
     *         ABI-encoded `retTypes`, and navigates `path` to an element —
     *         following runtime offsets and lengths through tuples and
     *         dynamic arrays, which raw word positions cannot express
     * @dev The typed selector: `retTypes` is the value's type written as a
     *      parenthesized tuple, e.g. "(uint112,uint112,address)" or
     *      "(address,address[][])" (structs as parenthesized tuples), and
     *      `path` walks it — the first step selects a tuple component
     *      (non-negative), each further step indexes the current tuple or
     *      array (array steps accept negative indices, resolved against the
     *      live length, -1 = last). Only the SHAPE of the descriptor is
     *      parsed (dynamic vs static, head footprints); base type names
     *      beyond bytes/string are not interpreted. The declared type is
     *      the author's claim about the encoder, like an inline ABI: a
     *      wrong claim reverts loudly in almost all cases, but a
     *      shape-compatible wrong type can read the wrong value.
     *
     *      The selection is returned via a raw assembly return,
     *      indistinguishable from a contract returning that value directly,
     *      so a nav nests inside any operand and any constrained fetcher
     *      consumes it exactly as if it had called a contract returning
     *      the element itself:
     *      - empty path: the resolved bytes pass through byte-for-byte
     *        (nav degenerates to resolve);
     *      - word terminal (static single-word value): the 32-byte word;
     *      - dynamic terminal (string/bytes/array): the canonical
     *        single-value envelope [0x20][length][payload]. Arrays must
     *        have single-word static elements; dynamic tuples and arrays
     *        of dynamic elements revert with InvalidNavigation (their
     *        extent would require a recursive re-encoder);
     *      - a path ending in the LEN sentinel: the decoded length of the
     *        dynamic value the preceding steps navigate to, as a uint256
     *        word (element count for arrays, byte length for string/bytes
     *        — UTF-8 characters may span multiple bytes);
     *      - a path ending in the PAYLOAD sentinel: the raw payload of the
     *        string or bytes value the preceding steps navigate to —
     *        exactly its byte length, unpadded, no envelope. This is the
     *        typed-bytes re-entry point: a blob's content is opaque to
     *        THIS descriptor (bytes is a sealed leaf, and the grammar
     *        stays plain ABI), but a nav over the PAYLOAD result claims
     *        its encoding with an ordinary descriptor, same author's-claim
     *        status as any other. Arrays and dynamic tuples revert with
     *        InvalidNavigation — their payload's extent would require the
     *        recursive re-encoder the core deliberately lacks.
     *
     *      Operand failures revert with CallFailed / ConstraintFailed
     *      identifying them; a malformed descriptor reverts with
     *      InvalidTypeDescriptor, a step into a non-composite or an
     *      unrepresentable terminal with InvalidNavigation, a path index
     *      outside its tuple or array with ElementIndexOutOfBounds, and
     *      data that does not match the declared shape (truncated
     *      returndata, out-of-range offsets) with ReturnDataOutOfBounds.
     * @param a The input parameter whose resolved bytes are navigated
     * @param retTypes The resolved value's type as a parenthesized tuple
     * @param path The navigation path (see modes above)
     */
    function nav(InputParam calldata a, string calldata retTypes, int256[] calldata path) external view {
        bytes memory result = _resolve(a, "", 0, 0);
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
        if (path[path.length - 1] == PAYLOAD) {
            (uint256 start, uint256 length) = _navPayload(result, t, path[:path.length - 1]);
            assembly {
                return(add(add(result, 32), start), length)
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

    /**
     * @notice Follows a chain of staticcalls whose targets are resolved at
     *         execution time, and returns the final call's raw returndata
     * @dev The runtime-target primitive ERC-8211 fetchers cannot express
     *      (a STATIC_CALL fetcher's target is fixed at encoding time).
     *      `start` must resolve to a clean address word — the first hop's
     *      target. Each hop is a plain abi.encodeCall entry; every hop
     *      except the last must return an address as its first word, which
     *      becomes the next hop's target. The final hop's returndata is
     *      returned via a raw assembly return, so a chain nests inside any
     *      operand (wrap it in pick / nav / read to extract or transform),
     *      e.g. balanceOf on the token address a vault reports:
     *      chain(vaultAddressParam, [token(), balanceOf(vault)]).
     *      Reverts with EmptyCallChain when `calls` is empty, CallFailed
     *      identifying the exact failing hop, ReturnDataOutOfBounds when a
     *      mid-chain hop returns fewer than 32 bytes, and
     *      InvalidAddressWord (index 0 for `start`, hop index + 1 for
     *      mid-chain hops) when an address word has dirty upper bytes.
     * @param start The input parameter resolving to the first hop's target
     *        address
     * @param calls One plain abi.encodeCall entry per hop
     */
    function chain(InputParam calldata start, bytes[] calldata calls) external view {
        if (calls.length == 0) revert EmptyCallChain();
        address current = _asAddress(
            _firstWord(_resolve(start, "", 0, 0)),
            0
        );
        uint256 last = calls.length - 1;
        for (uint256 i = 0; i < last; i++) {
            bytes memory hopResult = _staticCall(current, calls[i]);
            current = _asAddress(_firstWord(hopResult), i + 1);
        }
        bytes memory result = _staticCall(current, calls[last]);
        assembly {
            return(add(result, 32), mload(result))
        }
    }

    // ============ Read ============

    /**
     * @notice Constructs a staticcall from runtime-resolved calldata
     *         segments — selector ++ each resolved arg in order — executes
     *         it against a runtime-resolved target, and returns the call's
     *         raw returndata
     * @dev The runtime-argument primitive ERC-8211 fetchers cannot express
     *      (a STATIC_CALL fetcher's calldata is fixed at encoding time):
     *      any external function becomes callable with computed arguments,
     *      so any deployed view or pure contract extends the assertion
     *      vocabulary without touching this contract. `target` must
     *      resolve to a clean address word. `args` are calldata SEGMENTS,
     *      not necessarily one per Solidity argument: each resolved
     *      value's FULL bytes are appended in order, exactly the
     *      standard's CALL_DATA routing — a RAW_BYTES segment carries any
     *      literal span (head words, pre-encoded tails), a STATIC_CALL
     *      segment computes a span at judge time (word-returning
     *      expressions contribute exactly 32 bytes; a segment resolving
     *      to any other length shifts everything after it, so the encoder
     *      owns the layout). Segment constraints are validated on the
     *      resolved values, turning any argument into an inline assert.
     *      The returndata is returned via a raw assembly return, so a
     *      read nests inside any operand exactly like the call it
     *      constructed. Reverts with InvalidAddressWord (index 0) when
     *      the target word has dirty upper bytes, CallFailed when the
     *      target has no code or the constructed call reverts, and
     *      ConstraintFailed identifying the operand (target is operand 0,
     *      args follow at their index + 1) on a violated constraint.
     * @param target The input parameter resolving to the call's target
     *        address
     * @param selector The 4-byte function selector the segments follow
     * @param args The calldata segments, appended in order after the
     *        selector (may be empty for a selector-only call)
     */
    function read(InputParam calldata target, bytes4 selector, InputParam[] calldata args) external view {
        address callTarget = _asAddress(
            _firstWord(_resolve(target, "", 0, 0)),
            0
        );
        bytes memory callData = abi.encodePacked(selector);
        for (uint256 i = 0; i < args.length; i++) {
            callData = bytes.concat(callData, _resolve(args[i], "", 0, i + 1));
        }
        bytes memory result = _staticCall(callTarget, callData);
        assembly {
            return(add(result, 32), mload(result))
        }
    }

    // ============ Cond ============

    /**
     * @notice Resolves the condition, then resolves and returns ONLY the
     *         winning branch — the losing branch is never resolved, so its
     *         calls never happen
     * @dev The lazy conditional, and the reason it must live in the core:
     *      branches arrive as unresolved InputParams, which only
     *      ERC-8211-speaking code can hold without evaluating. The
     *      condition resolves normally — fetcher plus full constraint
     *      validation; a violated condition constraint reverts the whole
     *      cond (branching on FAILURE is orElse's job, branching on a
     *      VALUE is cond's). Truth is EVM truthiness: the first 32-byte
     *      word of the resolved condition, nonzero = true (comparison
     *      results are 0/1 words, so they compose directly); fewer than
     *      32 bytes reverts with ReturnDataOutOfBounds. The winning
     *      branch is resolved (constraints validated) and returned via a
     *      raw assembly return, indistinguishable from resolving that
     *      branch directly. In resolution errors the condition is operand
     *      0, the then-branch operand 1, the else-branch operand 2.
     * @param c The condition operand (first resolved word judges truth)
     * @param then_ Resolved and returned when the condition is nonzero
     * @param else_ Resolved and returned when the condition is zero
     */
    function cond(InputParam calldata c, InputParam calldata then_, InputParam calldata else_) external view {
        bytes memory cValue = _resolve(c, "", 0, 0);
        bytes memory value = _firstWord(cValue) != bytes32(0)
            ? _resolve(then_, "", 0, 1)
            : _resolve(else_, "", 0, 2);
        assembly {
            return(add(value, 32), mload(value))
        }
    }

    // ============ OrElse / IsValid ============

    /**
     * @notice Resolves `a`; if that reverts for ANY reason, resolves and
     *         returns `b` instead
     * @dev The composable try/catch. The attempt runs behind an external
     *      self-staticcall boundary (the EVM's only catch primitive), so
     *      ALL failures of `a` select the fallback: a reverting or
     *      code-less call target, a violated constraint (constraints
     *      double as guards here), malformed data, even out-of-gas inside
     *      the subframe. The 63/64 rule makes a genuine OOG usually
     *      re-revert in the outer frame, but with a large gas limit and a
     *      cheap `b` an OOG deep inside `a` can masquerade as "a failed" —
     *      do not use orElse to distinguish failure causes. On success the
     *      attempt's bytes pass through byte-identically. `b` resolves
     *      in-frame: its failures propagate; chain further orElse operands
     *      for more fallbacks. In resolution errors `b` is operand 1.
     * @param a The attempt (any failure selects the fallback)
     * @param b The fallback, resolved only when the attempt failed
     */
    function orElse(InputParam calldata a, InputParam calldata b) external view {
        (bool success, bytes memory value) = address(this).staticcall(abi.encodeCall(this.resolve, (a)));
        if (!success) {
            value = _resolve(b, "", 0, 1);
        }
        assembly {
            return(add(value, 32), mload(value))
        }
    }

    /**
     * @notice Returns 1 when `a` resolves AND passes its constraints, 0
     *         otherwise
     * @dev The failure probe, collapsed to a word: validity covers the
     *      WHOLE resolution — the fetch succeeding (a reverting or
     *      code-less target, malformed data all count as invalid) and any
     *      inline constraints passing (they double as guards here). The
     *      attempt runs behind the same external self-staticcall boundary
     *      as orElse, with the same all-reverts-count caveat including the
     *      subframe-OOG edge. Point a constrained fetcher here to assert
     *      that a call succeeds (EQ 1) or that it fails (EQ 0), or feed it
     *      to cond to branch on resolvability. Compose it over
     *      `revertData` to get "reverted with this reason" as a word.
     * @param a The attempt to probe
     * @return 1 if `a` resolved (constraints included), else 0
     */
    function isValid(InputParam calldata a) external view returns (uint256) {
        (bool success, ) = address(this).staticcall(abi.encodeCall(this.resolve, (a)));
        return success ? 1 : 0;
    }

    /**
     * @notice Returns the revert data of a call that must fail, optionally
     *         requiring a specific error selector
     * @dev The reason-carrying probe. `isValid` and `orElse` route the
     *      attempt through `resolve`, where `_staticCall` converts a
     *      target's revert into this contract's own CallFailed and the
     *      reason is lost; this performs the operand's staticcall IN-FRAME
     *      so the target's revert data survives. That is what restricts it
     *      to a STATIC_CALL operand — a literal or a balance read has no
     *      call whose reason could be reported, and is rejected. A nested
     *      core expression IS a staticcall (back into this contract), so
     *      it is accepted — but the reason observed is then the core's own
     *      error, not the inner target's, which is why reason MATCHING
     *      only makes sense on a direct target call; composers must keep
     *      the operand direct when expectedSelector is non-zero. An OOG
     *      inside the probed frame counts as a revert here too (63/64
     *      caveat, as with orElse) — with no reason to match.
     *
     *      With `expectedSelector` non-zero the first four bytes of the
     *      revert data must match, and THE SELECTOR IS STRIPPED from the
     *      result: what returns is the error's ABI-encoded arguments,
     *      word-aligned, so `pick` and `nav` navigate them exactly as they
     *      navigate a call's return. Leaving the four bytes in place would
     *      misalign every word after them. A zero selector accepts any
     *      revert and passes the data through whole, selector included.
     *
     *      A mismatch REVERTS rather than resolving to a value: an
     *      assertion that a call fails for a specific reason is not
     *      satisfied by it failing for a different one, and answering
     *      otherwise would let an unrelated revert stand in for the
     *      expected one. Same for a call that succeeds.
     *
     *      A code-less target counts as a failure, as it does for
     *      `isValid` — but it carries no reason. A staticcall into an
     *      empty account
     *      succeeds with empty returndata, so there is nothing for an
     *      expectation to match and one fails here.
     * @param a The call operand, which must revert (STATIC_CALL fetcher,
     *        no constraints)
     * @param expectedSelector Required error selector, or 0x00000000 to
     *        accept any revert and return the data unstripped
     */
    function revertData(InputParam calldata a, bytes4 expectedSelector) external view {
        if (a.fetcherType != InputParamFetcherType.STATIC_CALL) {
            revert RevertProbeNotACall(uint8(a.fetcherType));
        }
        if (a.constraints.length != 0) {
            revert RevertProbeConstrained(a.constraints.length);
        }
        (address target, bytes memory callData) = abi.decode(a.paramData, (address, bytes));

        if (target.code.length == 0) {
            // Agrees with isValid(), which counts a code-less target a failure
            // (there is no word to splice). But an empty account produces no
            // revert data, so no expectation can be satisfied here.
            if (expectedSelector != bytes4(0)) {
                revert UnexpectedRevertData(expectedSelector, bytes4(0));
            }
            assembly {
                return(0, 0)
            }
        }

        (bool success, bytes memory ret) = target.staticcall(callData);
        if (success) revert DidNotRevert(target, callData);

        if (expectedSelector == bytes4(0)) {
            assembly {
                return(add(ret, 32), mload(ret))
            }
        }

        // bytes4 takes the high four bytes of the loaded word; a revert
        // shorter than a selector leaves `got` zero, which cannot match a
        // non-zero expectation.
        bytes4 got;
        if (ret.length >= 4) {
            assembly {
                got := mload(add(ret, 32))
            }
        }
        if (got != expectedSelector) revert UnexpectedRevertData(expectedSelector, got);
        assembly {
            return(add(ret, 36), sub(mload(ret), 4))
        }
    }

    // ============ Internal Judge ============

    /**
     * @dev The ERC-8211 execution algorithm, view-restricted. Per entry:
     *      resolve each input parameter (fetcher), validate its
     *      constraints, route it (TARGET or CALL_DATA; VALUE and
     *      outputParams revert), then — when a TARGET resolved to a
     *      non-zero address — STATICCALL the constructed call and require
     *      success. Entries without a TARGET parameter are predicate
     *      entries: resolve and validate only, no call.
     */
    function _judge(ComposableExecution[] calldata executions, string memory message) internal view {
        for (uint256 i = 0; i < executions.length; i++) {
            ComposableExecution calldata entry = executions[i];
            if (entry.outputParams.length != 0) revert OutputParamsNotSupported(i);

            address target;
            bool hasTarget;
            bytes memory callData = abi.encodePacked(entry.functionSig);

            for (uint256 j = 0; j < entry.inputParams.length; j++) {
                InputParam calldata param = entry.inputParams[j];
                if (param.paramType == InputParamType.VALUE) revert ValueParamNotSupported(i, j);
                if (param.paramType == InputParamType.TARGET) {
                    if (hasTarget) revert DuplicateTargetParam(i);
                    if (param.fetcherType == InputParamFetcherType.BALANCE) revert BalanceCannotBeTarget(i, j);
                    hasTarget = true;
                    bytes memory resolved = _resolve(param, message, i, j);
                    target = _asAddress(_firstWord(resolved), j);
                } else {
                    // CALL_DATA: appended in parameter order, per the standard
                    callData = bytes.concat(callData, _resolve(param, message, i, j));
                }
            }

            if (target != address(0)) {
                // The constructed call is itself an assertion: it must not revert.
                _staticCall(target, callData);
            }
        }
    }

    // ============ Internal Resolution (ERC-8211) ============

    /**
     * @dev Resolves an input parameter per the ERC-8211 fetcher semantics
     *      and validates its inline constraints against the resolved value.
     *      RAW_BYTES echoes paramData; STATIC_CALL returns the raw
     *      returndata of the encoded call; BALANCE returns
     *      abi.encode(uint256 balance). `assertion`, `entryIndex` and
     *      `paramIndex` are error-reporting context only.
     */
    function _resolve(
        InputParam calldata param,
        string memory assertion,
        uint256 entryIndex,
        uint256 paramIndex
    ) internal view returns (bytes memory value) {
        if (param.fetcherType == InputParamFetcherType.RAW_BYTES) {
            value = param.paramData;
        } else if (param.fetcherType == InputParamFetcherType.STATIC_CALL) {
            (address callTarget, bytes memory callData) = abi.decode(param.paramData, (address, bytes));
            value = _staticCall(callTarget, callData);
        } else {
            // BALANCE
            if (param.paramData.length != 40) {
                revert InvalidBalanceData(entryIndex, paramIndex, param.paramData.length);
            }
            address token = address(bytes20(param.paramData[0:20]));
            address account = address(bytes20(param.paramData[20:40]));
            if (token == address(0)) {
                value = abi.encode(account.balance);
            } else {
                bytes memory ret = _staticCall(token, abi.encodeCall(IERC20Balance.balanceOf, (account)));
                value = abi.encode(uint256(_firstWord(ret)));
            }
        }
        _validateConstraints(param.constraints, value, assertion, entryIndex, paramIndex);
    }

    /**
     * @dev Executes a staticcall and returns the raw result bytes.
     *      Reverts with CallFailed when the target has no code, since a
     *      staticcall to a code-less address succeeds with empty returndata
     *      and would otherwise surface as a silent wrong value.
     */
    function _staticCall(address target, bytes memory callData) internal view returns (bytes memory) {
        if (target.code.length == 0) revert CallFailed(target, callData);
        (bool success, bytes memory result) = target.staticcall(callData);
        if (!success) revert CallFailed(target, callData);
        return result;
    }

    /**
     * @dev The first 32-byte word of `value` — the word constraints compare
     *      and words are routed from. Reverts with ReturnDataOutOfBounds
     *      when fewer than 32 bytes are available.
     */
    function _firstWord(bytes memory value) internal pure returns (bytes32 word) {
        if (value.length < 32) revert ReturnDataOutOfBounds(0, value.length);
        assembly {
            word := mload(add(value, 32))
        }
    }

    /**
     * @dev Interprets a word as an address, reverting with
     *      InvalidAddressWord when the upper 96 bits are dirty
     */
    function _asAddress(bytes32 word, uint256 index) internal pure returns (address) {
        if (uint256(word) >> 160 != 0) revert InvalidAddressWord(index, word);
        return address(uint160(uint256(word)));
    }

    /**
     * @dev Validates every constraint against the resolved value's first
     *      32-byte word (unsigned comparisons, per the standard). Reverts
     *      with InvalidConstraintData on malformed referenceData and
     *      ConstraintFailed on the first violated constraint.
     */
    function _validateConstraints(
        Constraint[] calldata constraints,
        bytes memory value,
        string memory assertion,
        uint256 entryIndex,
        uint256 paramIndex
    ) internal pure {
        if (constraints.length == 0) return;
        bytes32 actual = _firstWord(value);
        for (uint256 i = 0; i < constraints.length; i++) {
            Constraint calldata c = constraints[i];
            bool ok_;
            if (c.constraintType == ConstraintType.IN) {
                if (c.referenceData.length != 64) {
                    revert InvalidConstraintData(entryIndex, paramIndex, i, c.referenceData.length);
                }
                (bytes32 lower, bytes32 upper) = abi.decode(c.referenceData, (bytes32, bytes32));
                ok_ = uint256(actual) >= uint256(lower) && uint256(actual) <= uint256(upper);
            } else {
                if (c.referenceData.length != 32) {
                    revert InvalidConstraintData(entryIndex, paramIndex, i, c.referenceData.length);
                }
                bytes32 bound = bytes32(c.referenceData);
                if (c.constraintType == ConstraintType.EQ) {
                    ok_ = actual == bound;
                } else if (c.constraintType == ConstraintType.GTE) {
                    ok_ = uint256(actual) >= uint256(bound);
                } else {
                    // LTE
                    ok_ = uint256(actual) <= uint256(bound);
                }
            }
            if (!ok_) {
                revert ConstraintFailed(assertion, entryIndex, paramIndex, i, c.constraintType, actual, c.referenceData);
            }
        }
    }

    // ============ Internal Read Helpers ============

    /**
     * @dev Reads the wordIndex-th 32-byte word of the raw bytes
     *      (0-based; negative from the end, -1 = last word), reverting with
     *      ReturnDataOutOfBounds outside the full words in either direction
     */
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

    /**
     * @dev Resolves a LEN-terminated path: navigates the non-sentinel steps
     *      to a dynamic value and returns its length word. Static values,
     *      dynamic tuples and empty paths revert with InvalidNavigation
     *      (a fixed array's length is known at composition time).
     */
    function _navLength(bytes memory result, bytes calldata t, int256[] calldata path) internal pure returns (uint256) {
        if (path.length == 0) revert InvalidNavigation(0);
        (uint256 pos, bool isWord, uint256 ts, uint256 te) = _navigate(result, t, path);
        if (isWord) revert InvalidNavigation(ts);
        // Dynamic arrays and bytes/string sit on their length word; a
        // dynamic tuple's position is its first head word — no length there.
        if (t[te - 1] != "]" && t[ts] == "(") revert InvalidNavigation(ts);
        return _navWord(result, pos);
    }

    /**
     * @dev Resolves a PAYLOAD-terminated path: navigates the non-sentinel
     *      steps to a string or bytes value and returns the span of its raw
     *      payload — start offset into `result` and exact byte length, no
     *      envelope, no padding. Static values, arrays, dynamic tuples and
     *      empty paths revert with InvalidNavigation: an array or tuple
     *      payload's extent would require the recursive re-encoder the
     *      core deliberately lacks. A length word overrunning the data
     *      reverts with ReturnDataOutOfBounds.
     */
    function _navPayload(bytes memory result, bytes calldata t, int256[] calldata path)
        internal
        pure
        returns (uint256 start, uint256 length)
    {
        if (path.length == 0) revert InvalidNavigation(0);
        (uint256 pos, bool isWord, uint256 ts, uint256 te) = _navigate(result, t, path);
        if (isWord) revert InvalidNavigation(ts);
        // Only bytes/string base terminals carry a byte-counted payload
        // behind their length word.
        if (t[te - 1] == "]" || t[ts] == "(") revert InvalidNavigation(ts);
        length = _navWord(result, pos);
        // _navWord guarantees pos + 32 <= result.length, so the
        // subtraction cannot underflow.
        if (length > result.length - pos - 32) {
            revert ReturnDataOutOfBounds(int256(pos / 32), result.length);
        }
        start = pos + 32;
    }

    /**
     * @dev Returns a navigated dynamic terminal re-encoded as a canonical
     *      single-value return: [0x20][length][payload], indistinguishable
     *      from a contract returning that value directly. Terminals may be
     *      string, bytes, or a dynamic array of single-word static
     *      elements; dynamic tuples and arrays of dynamic elements revert
     *      with InvalidNavigation (their extent would require a recursive
     *      re-encoder).
     */
    function _returnDynamic(bytes memory result, bytes calldata t, uint256 pos, uint256 ts, uint256 te) internal pure {
        uint256 len = _navWord(result, pos);
        uint256 payloadBytes;
        if (t[te - 1] == "]") {
            uint256 suffix = AbiShape.suffixStart(t, ts, te);
            (, bool elemDyn, uint256 elemWords) = AbiShape.typeShape(t, ts, suffix);
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

    /**
     * @dev Reads the 32-byte word at byte offset `pos` of `result`, reverting
     *      with ReturnDataOutOfBounds when it lies outside the data
     */
    function _navWord(bytes memory result, uint256 pos) internal pure returns (uint256 word) {
        if (pos > result.length || result.length - pos < 32) {
            revert ReturnDataOutOfBounds(int256(pos / 32), result.length);
        }
        assembly {
            word := mload(add(add(result, 32), pos))
        }
    }

    /**
     * @dev Navigation cursor: the current value's type bounds [ts, te) in
     *      the descriptor, its byte position in the data, and — after
     *      a step — whether the value just selected is dynamic and its head
     *      footprint. Position semantics: a tuple's position is its first
     *      head word; a dynamic array's is its length word; a fixed array's
     *      is its first element or offset word.
     */
    struct NavCursor {
        uint256 ts;
        uint256 te;
        uint256 base;
        bool dyn;
        uint256 words;
    }

    /**
     * @dev Walks `path` through `result` as described by the type descriptor
     *      `t` (which must be a parenthesized tuple). Returns the byte
     *      position of the terminal — the value word itself when `isWord`,
     *      otherwise the length word / head of the selected dynamic value —
     *      plus the terminal's type bounds [ts, te) for the callers' checks.
     *      Offsets are followed relative to their enclosing frame per ABI
     *      encoding rules.
     */
    function _navigate(bytes memory result, bytes calldata t, int256[] calldata path)
        internal
        pure
        returns (uint256 pos, bool isWord, uint256 ts, uint256 te)
    {
        if (t.length == 0 || t[0] != "(") revert InvalidTypeDescriptor(0);
        if (path.length == 0) revert InvalidNavigation(0);
        {
            (uint256 topEnd,,) = AbiShape.typeShape(t, 0, t.length);
            if (topEnd != t.length) revert InvalidTypeDescriptor(topEnd);
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

    /**
     * @dev One array step: bounds-checks the signed index against the live
     *      (or fixed) length and advances the cursor to the element
     */
    function _navArrayStep(bytes memory result, bytes calldata t, NavCursor memory c, int256 idx) private pure {
        uint256 suffix = AbiShape.suffixStart(t, c.ts, c.te);
        (, bool elemDyn, uint256 elemWords) = AbiShape.typeShape(t, c.ts, suffix);
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
        uint256 wanted = AbiShape.normalizeIndex(idx, count);
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

    /**
     * @dev One tuple step: accumulates head footprints of the preceding
     *      components (derived from the descriptor) and advances the cursor
     *      to component `idx`
     */
    function _navTupleStep(bytes memory result, bytes calldata t, NavCursor memory c, int256 idx) private pure {
        uint256 q = c.ts + 1;
        uint256 acc;
        uint256 j;
        if (idx < 0) {
            while (true) {
                (uint256 e,,) = AbiShape.typeShape(t, q, c.te);
                j++;
                if (t[e] == ")") break;
                q = e + 1;
            }
            revert ElementIndexOutOfBounds(idx, j);
        }
        while (true) {
            (uint256 e, bool d, uint256 w) = AbiShape.typeShape(t, q, c.te);
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
}
