// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import {Operations} from "../Operations.sol";
import {IExpressions} from "../Collections.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

/**
 *  @dev Reverts with exactly the calldata it receives
 */
contract RevertsWithCalldata {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            revert(0, calldatasize())
        }
    }
}

/**
 *  @dev Returns its caller and the exact calldata it received
 */
contract CallerEcho {
    fallback() external {
        assembly {
            mstore(0, caller())
            calldatacopy(32, 0, calldatasize())
            return(0, add(32, calldatasize()))
        }
    }
}

/**
 *  @dev A binary lambda that adds, wrapping, so results can leave a narrow type
 */
contract Adder {
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }

    function same(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }
}

/**
 * @notice Halmos properties for the reads and callbacks left after the operand
 *         and structure suites: nav's LEN and PAYLOAD bounds, get's codec
 *         errors and a gathered bytes[] argument, rawCall and code, the UTF-8
 *         table, and the Collections callback rules (fold validation, slice
 *         validation, InvalidCallback, expression failures). Run with
 *         `pnpm halmos`.
 * @dev Errors are compared byte for byte. Halmos has no gas model, so the
 *      out-of-gas guard's SubcallOutOfGas can fire on any failing subcall it
 *      explores; that outcome is discarded (see outOfGasArtifact).
 */
contract ReadsCallbacksSymbolicTest is Test {
    int256 constant LEN = type(int256).min;
    int256 constant PAYLOAD = type(int256).min + 1;

    Assertions core;
    Collections collections;
    Expressions expressions;
    Operations ops;
    RevertsWithCalldata reverter;
    CallerEcho echo;
    Adder adder;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        expressions = new Expressions();
        ops = new Operations();
        reverter = new RevertsWithCalldata();
        echo = new CallerEcho();
        adder = new Adder();
    }

    // ============ nav LEN and PAYLOAD ============

    function nav(bytes memory data, string memory types, int256 last)
        internal
        view
        returns (bool ok, bytes memory out)
    {
        int256[] memory path = new int256[](2);
        path[1] = last;
        (ok, out) = address(core).staticcall(abi.encodeCall(Assertions.nav, (raw(data), types, path)));
    }

    function pickLength(uint8 c) internal pure returns (uint256) {
        if (c == 0) return 0;
        if (c == 1) return 5;
        if (c == 2) return 32;
        if (c == 3) return 33;
        if (c == 4) return 64;
        if (c == 5) return 65;
        vm.assume(c == 6);
        return type(uint256).max;
    }

    /**
     * @dev Over a bytes value with two words of payload room: LEN answers the
     *      length when it fits in whole words, PAYLOAD returns exactly the
     *      payload bytes when they fit, and a length past the data reverts
     *      ReturnDataOutOfBounds; nothing past the data is ever returned
     */
    function check_lenAndPayloadStayInsideTheData(uint8 lengthCase, bytes32 w0, bytes32 w1, bool payload) public view {
        uint256 length = pickLength(lengthCase);
        bytes memory data = abi.encodePacked(uint256(32), length, w0, w1);
        (bool ok, bytes memory out) = nav(data, "(bytes)", payload ? PAYLOAD : LEN);
        if (length > 64) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(128)));
        } else if (payload) {
            assertTrue(ok);
            bytes memory expected = abi.encodePacked(w0, w1);
            assembly ("memory-safe") { mstore(expected, length) }
            assertEq(out, expected, "PAYLOAD is not the payload bytes");
        } else {
            assertTrue(ok);
            assertEq(out, abi.encode(length));
        }
    }

    /**
     * @dev LEN over string[] checks that the element heads fit and nothing
     *      more: whatever the heads hold, it answers the count
     */
    function check_lenDoesNotTraverseTails(bytes32 head0, bytes32 head1, uint8 countCase) public view {
        uint256 count = countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : 3;
        vm.assume(countCase < 4);
        bytes memory data = abi.encodePacked(uint256(32), count, head0, head1);
        (bool ok, bytes memory out) = nav(data, "(string[])", LEN);
        if (count > 2) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(128)));
        } else {
            assertTrue(ok, "LEN traversed a tail");
            assertEq(out, abi.encode(count));
        }
    }

    // ============ get ============

    /**
     * @dev get names the offending argument in its codec errors: a count that
     *      differs, a static argument of the wrong length, a dynamic one
     *      without an envelope, and a dirty narrow word
     */
    function check_getNamesArgumentsInCodecErrors(uint8 errorCase, bytes32 w) public view {
        InputParam[] memory args;
        bytes memory expected;
        if (errorCase == 0) {
            args = new InputParam[](1);
            args[0] = raw(abi.encode(uint8(1)));
            expected = abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, uint256(2), uint256(1));
        } else if (errorCase == 1) {
            args = new InputParam[](2);
            args[0] = raw(abi.encode(w, w));
            args[1] = raw(abi.encode("ab"));
            expected =
                abi.encodeWithSelector(AbiCodec.InvalidComponentLength.selector, uint256(0), uint256(32), uint256(64));
        } else if (errorCase == 2) {
            args = new InputParam[](2);
            args[0] = raw(abi.encode(uint8(1)));
            args[1] = raw(abi.encode(w));
            expected = abi.encodeWithSelector(AbiCodec.InvalidComponentEnvelope.selector, uint256(1), uint256(32), w);
        } else {
            vm.assume(errorCase == 3 && uint256(w) > 255);
            args = new InputParam[](2);
            args[0] = raw(abi.encode(w));
            args[1] = raw(abi.encode("ab"));
            expected = abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0));
        }
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(
                    Assertions.get, (raw(abi.encode(address(echo))), bytes4(0x12345678), "(uint8,string)", args)
                )
            );
        assertFalse(ok);
        assertEq(out, expected, "get does not name the argument");
    }

    /**
     * @dev A gathered bytes[] feeds a bytes[] position of get as one whole
     *      argument: the target receives exactly selector ++ abi.encode(values)
     */
    function check_gatheredValuesFeedGet(bytes32 a, bytes32 b, bytes4 sel) public view {
        InputParam[] memory parts = new InputParam[](2);
        parts[0] = raw(abi.encode(a));
        parts[1] = raw(abi.encode(b));
        InputParam[] memory args = new InputParam[](1);
        args[0] = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(core), abi.encodeCall(Assertions.gather, (parts))),
            new Constraint[](0)
        );
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.get, (raw(abi.encode(address(echo))), sel, "(bytes[])", args)));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "get refused a gathered argument");
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        assertEq(out, bytes.concat(bytes32(uint256(uint160(address(core)))), sel, abi.encode(values)));
    }

    // ============ rawCall and code ============

    /**
     * @dev A reverting rawCall target reverts RawCallFailed(target, data); the reason is not carried
     */
    function check_rawCallRevertNamesTheCall(bytes32 w) public view {
        bytes memory data = abi.encode(w);
        (bool ok, bytes memory out) =
            address(ops).staticcall(abi.encodeCall(Operations.rawCall, (address(reverter), data)));
        // Halmos has no gas model: exclude the symbolic exhaustion artifact.
        // Concrete GasPropagationTest sweeps establish gas behavior separately.
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Operations.SubcallOutOfGas.selector)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Operations.RawCallFailed.selector, address(reverter), data));
    }

    /**
     * @dev code returns an account's full runtime code, empty for a code-less one
     */
    function check_codeReturnsTheRuntime(bool codeless) public view {
        address account = codeless ? address(0xC0DE) : address(echo);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.code, (account)));
        assertTrue(ok);
        assertEq(abi.decode(out, (bytes)), account.code);
    }

    // ============ UTF-8 ============

    /**
     * @dev The Unicode well-formed table (Table 3-7), written out: a
     *      different formulation from the contract's lead-then-continuations
     *      loop, byte ranges per lead
     */
    function wellFormed(bytes memory s) internal pure returns (bool) {
        uint256 i;
        while (i < s.length) {
            uint8 b0 = uint8(s[i]);
            if (b0 <= 0x7f) {
                i += 1;
                continue;
            }
            uint256 n;
            uint8 lo = 0x80;
            uint8 hi = 0xbf;
            if (b0 >= 0xc2 && b0 <= 0xdf) n = 2;
            else if (b0 == 0xe0) (n, lo) = (3, 0xa0);
            else if ((b0 >= 0xe1 && b0 <= 0xec) || b0 == 0xee || b0 == 0xef) n = 3;
            else if (b0 == 0xed) (n, hi) = (3, 0x9f);
            else if (b0 == 0xf0) (n, lo) = (4, 0x90);
            else if (b0 >= 0xf1 && b0 <= 0xf3) n = 4;
            else if (b0 == 0xf4) (n, hi) = (4, 0x8f);
            else return false;
            if (i + n > s.length) return false;
            uint8 b1 = uint8(s[i + 1]);
            if (b1 < lo || b1 > hi) return false;
            for (uint256 k = 2; k < n; k++) {
                uint8 bk = uint8(s[i + k]);
                if (bk < 0x80 || bk > 0xbf) return false;
            }
            i += n;
        }
        return true;
    }

    /**
     * @dev stringSlice over a whole string of one to four bytes succeeds
     *      exactly when the bytes are well-formed UTF-8 per the Unicode table:
     *      every lead, overlong form, surrogate and code point past U+10FFFF
     */
    function check_utf8MatchesTheUnicodeTable(bytes4 raw4, uint8 lengthCase) public view {
        uint256 length;
        if (lengthCase == 1) {
            length = 1;
        } else if (lengthCase == 2) {
            length = 2;
        } else if (lengthCase == 3) {
            length = 3;
        } else {
            vm.assume(lengthCase == 4);
            length = 4;
        }
        bytes memory data = new bytes(length);
        for (uint256 i; i < length; i++) {
            data[i] = raw4[i];
        }
        (bool ok,) = address(ops).staticcall(abi.encodeCall(Operations.stringSlice, (data, int256(0), int256(length))));
        assertEq(ok, wellFormed(data), "the validator and the Unicode table disagree");
    }

    // ============ Collections callbacks ============

    function binary(bytes4 selector, uint256 first, uint256 second, string memory arguments, uint256 constants)
        internal
        view
        returns (Collections.Callback memory cb)
    {
        cb.target = address(adder);
        cb.selector = selector;
        cb.arguments = arguments;
        cb.constants = new bytes[](constants);
        for (uint256 i; i < constants; i++) {
            cb.constants[i] = abi.encode(uint256(0));
        }
        cb.first = first;
        cb.second = second;
    }

    /**
     * @dev foldValues validates `initial` as a canonical accumulatorType before
     *      any call, and every result as one after it
     */
    function check_foldValidatesInitialAndResults(uint256 initial, uint256 x) public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(x);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.foldValues,
                    (
                        "uint256",
                        "uint8",
                        values,
                        abi.encode(initial),
                        binary(Adder.add.selector, 0, 1, "(uint256,uint256)", 2)
                    )
                )
            );
        if (initial > 255) {
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        } else {
            uint256 result;
            unchecked {
                result = initial + x;
            }
            if (result > 255) {
                assertEq(
                    out,
                    abi.encodeWithSelector(
                        AbiCodec.InvalidCallbackResult.selector,
                        Collections.foldValues.selector,
                        uint256(0),
                        uint256(0),
                        address(adder)
                    )
                );
            } else {
                assertTrue(ok);
                assertEq(abi.decode(out, (bytes)), abi.encode(result));
                return;
            }
        }
        assertFalse(ok);
    }

    /**
     * @dev sliceValues validates only the elements it selects
     */
    function check_sliceValidatesOnlySelected(bytes32 junk, uint8 x, bool selectJunk) public view {
        vm.assume(uint256(junk) > 255);
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(junk);
        values[1] = abi.encode(x);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.sliceValues,
                    ("uint8", values, selectJunk ? int256(0) : int256(1), selectJunk ? int256(1) : int256(2))
                )
            );
        if (selectJunk) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
        } else {
            assertTrue(ok, "an unselected element was validated");
            bytes[] memory kept = abi.decode(out, (bytes[]));
            assertEq(kept.length, 1);
            assertEq(kept[0], values[1]);
        }
    }

    /**
     * @dev InvalidCallback before any call: a slot past the constants, a
     *      binary callback naming one slot twice, a non-tuple descriptor, and a
     *      constant count that differs from the components
     */
    function check_invalidCallbackRules(uint8 ruleCase) public view {
        Collections.Callback memory cb;
        if (ruleCase == 0) {
            cb = binary(Adder.same.selector, 2, 1, "(uint256,uint256)", 2);
        } else if (ruleCase == 1) {
            cb = binary(Adder.same.selector, 1, 1, "(uint256,uint256)", 2);
        } else if (ruleCase == 2) {
            cb = binary(Adder.same.selector, 0, 1, "uint256", 2);
        } else {
            vm.assume(ruleCase == 3);
            cb = binary(Adder.same.selector, 0, 1, "(uint256,uint256,uint256)", 2);
        }
        bytes[] memory values = new bytes[](0);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.uniqueValues, ("uint256", values, cb, false)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    /**
     * @dev A failing expression callback surfaces as CallbackFailed carrying
     *      the evaluateEncoded call and, as its reason, exactly what
     *      evaluateEncoded reverts with on its own
     */
    function check_expressionCallbackFailureIsWrapped(uint256 x) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] = Expressions.Node(
            Expressions.Kind.Parameter, "uint8", abi.encode(uint256(0)), new uint256[](0), bytes4(0), ""
        );
        bytes memory expression = abi.encode(Expressions.Expression(address(core), nodes, 0));
        Collections.Callback memory cb;
        cb.target = address(expressions);
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
        cb.constants[0] = abi.encode(uint256(0));
        cb.expression = expression;
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(x);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.mapValues, ("uint256", "uint8", values, cb)));
        vm.assume(!outOfGasArtifact(ok, out));
        bytes[] memory bound = new bytes[](1);
        bound[0] = values[0];
        bytes memory callData = abi.encodeCall(IExpressions.evaluateEncoded, (expression, bound));
        (bool innerOk, bytes memory reason) = address(expressions).staticcall(callData);
        vm.assume(!outOfGasArtifact(innerOk, reason));
        if (x > 255) {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    Collections.CallbackFailed.selector,
                    Collections.mapValues.selector,
                    uint256(0),
                    uint256(0),
                    address(expressions),
                    callData,
                    reason
                )
            );
        } else {
            assertTrue(ok);
        }
    }

    // ============ Harness ============

    function slice(bytes memory b, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(b.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = b[from + i];
        }
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    /**
     * @dev Halmos has no gas model: gasleft() is a fresh symbol, so the
     *      out-of-gas guard can fire on any failing subcall it explores, which
     *      no real execution takes. That outcome is discarded (matched by
     *      selector, shared by the core and Expressions).
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
    }
}
