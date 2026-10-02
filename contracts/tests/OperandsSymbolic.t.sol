// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";

/**
 *  @dev Reverts with exactly the calldata it receives
 */
contract CalldataReverter {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            revert(0, calldatasize())
        }
    }
}

/**
 *  @dev Succeeds with no returndata, whatever the call
 */
contract Silent {
    fallback() external {}
}

/**
 *  @dev Returns five bytes, whatever the call: too short to be a word
 */
contract ShortReturner {
    fallback() external {
        assembly {
            mstore(0, 0x0102030405000000000000000000000000000000000000000000000000000000)
            return(0, 5)
        }
    }
}

/**
 *  @dev Returns the word it is given: a chain hop with a chosen next target
 */
contract WordHop {
    function hop(bytes32 w) external pure returns (bytes32) {
        return w;
    }
}

/**
 *  @dev Returns its caller and the exact calldata it received
 */
contract CallEcho {
    fallback() external {
        assembly {
            mstore(0, caller())
            calldatacopy(32, 0, calldatasize())
            return(0, add(32, calldatasize()))
        }
    }
}

/**
 * @notice Halmos properties: every core primitive names the operand that
 *         failed, evaluates its operands in the documented order, and checks
 *         what it documents before what it judges. Run with `pnpm halmos`.
 * @dev Errors are compared byte for byte. The core guards failed subcalls
 *      against out-of-gas, and Halmos has no gas model (gasleft() is a fresh
 *      symbol), so a SubcallOutOfGas outcome on a failing path is discarded
 *      (see outOfGasArtifact); CoreReads.t.sol pins the guard at real gas.
 */
contract OperandsSymbolicTest is Test {
    Assertions core;
    CalldataReverter reverter;
    Silent silent;
    ShortReturner shortReturner;
    WordHop hopper;
    CallEcho echo;

    function setUp() public {
        core = new Assertions();
        reverter = new CalldataReverter();
        silent = new Silent();
        shortReturner = new ShortReturner();
        hopper = new WordHop();
        echo = new CallEcho();
    }

    // ============ cond ============

    /**
     * @dev cond resolves the condition (operand 0), then ONLY the chosen
     *      branch (then 1, else 2), and a violated constraint names that
     *      operand; the other branch's constraint never runs
     */
    function check_condNamesItsOperandsAndIsLazy(
        uint256 c,
        uint256 cRef,
        bool constrainCondition,
        uint256 t,
        uint256 tRef,
        uint256 e,
        uint256 eRef
    ) public view {
        InputParam memory pc = constrainCondition ? eq(abi.encode(c), cRef) : raw(abi.encode(c));
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.cond, (pc, eq(abi.encode(t), tRef), eq(abi.encode(e), eRef))));
        if (constrainCondition && c != cRef) {
            assertEq(out, failed(0, c, cRef), "cond does not name its condition");
            return;
        }
        (uint256 index, uint256 value, uint256 ref) = c != 0 ? (uint256(1), t, tRef) : (uint256(2), e, eRef);
        if (value != ref) {
            assertFalse(ok);
            assertEq(out, failed(index, value, ref), "cond does not name the chosen branch");
        } else {
            assertTrue(ok, "cond judged the branch it did not choose");
            assertEq(out, abi.encode(value));
        }
    }

    // ============ orElse ============

    /**
     * @dev orElse yields `a` when it resolves; otherwise it resolves `b`
     *      in-frame, as operand 1, and `b`'s failure propagates naming it
     */
    function check_orElseFallbackIsOperandOne(uint256 a, uint256 aRef, uint256 b, uint256 bRef) public view {
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.orElse, (eq(abi.encode(a), aRef), eq(abi.encode(b), bRef))));
        vm.assume(!outOfGasArtifact(ok, out));
        if (a == aRef) {
            assertTrue(ok);
            assertEq(out, abi.encode(a));
        } else if (b == bRef) {
            assertTrue(ok);
            assertEq(out, abi.encode(b));
        } else {
            assertFalse(ok);
            assertEq(out, failed(1, b, bRef), "orElse does not name its fallback operand 1");
        }
    }

    /**
     * @dev orElse(a, orElse(b, c)) tries the sources in order and yields the
     *      first that resolves; when none does, the outer frame reports the
     *      inner orElse call that failed
     */
    function check_orElseChainTriesInOrder(uint256 a, uint256 aRef, uint256 b, uint256 bRef, uint256 c, uint256 cRef)
        public
        view
    {
        bytes memory innerCall = abi.encodeCall(Assertions.orElse, (eq(abi.encode(b), bRef), eq(abi.encode(c), cRef)));
        InputParam memory inner = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(core), innerCall),
            new Constraint[](0)
        );
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.orElse, (eq(abi.encode(a), aRef), inner)));
        vm.assume(!outOfGasArtifact(ok, out));
        if (a == aRef) {
            assertEq(out, abi.encode(a));
        } else if (b == bRef) {
            assertEq(out, abi.encode(b));
        } else if (c == cRef) {
            assertEq(out, abi.encode(c));
        } else {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(CallFailed.selector, address(core), innerCall));
            return;
        }
        assertTrue(ok, "orElse skipped a source that resolves");
    }

    // ============ isValid over revertData ============

    /**
     * @dev isValid(revertData(a, sel)) is 1 exactly when `a` reverts and,
     *      for a nonzero sel, its revert data starts with sel
     */
    function check_isValidOfRevertDataMatchesTheSelector(uint8 lengthCase, bytes32 d, bytes4 sel, bool succeeds)
        public
        view
    {
        uint256 length;
        if (lengthCase == 0) {
            length = 0;
        } else if (lengthCase == 1) {
            length = 3;
        } else if (lengthCase == 2) {
            length = 4;
        } else {
            vm.assume(lengthCase == 3);
            length = 32;
        }
        bytes memory data = abi.encodePacked(d);
        assembly ("memory-safe") { mstore(data, length) }
        address target = succeeds ? address(silent) : address(reverter);
        InputParam memory a = InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(target, data), new Constraint[](0)
        );
        InputParam memory probe = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(core), abi.encodeCall(Assertions.revertData, (a, sel))),
            new Constraint[](0)
        );
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (probe)));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "isValid reverted");
        bool expected = !succeeds && (sel == bytes4(0) || (length >= 4 && bytes4(d) == sel));
        assertEq(abi.decode(out, (uint256)), expected ? 1 : 0);
    }

    // ============ chain ============

    /**
     * @dev chain names what failed: no hops (EmptyCallChain), a hop whose
     *      word is not a clean address (InvalidAddressWord at the next hop's
     *      index), a result shorter than a word (ReturnDataOutOfBounds), a
     *      code-less or reverting hop (CallFailed with that hop's target and
     *      calldata); otherwise it returns the last hop's raw result
     */
    function check_chainNamesTheHop(uint8 hopCase, bytes32 w) public view {
        bytes memory ping = abi.encodeWithSignature("ping()");
        address start = address(hopper);
        bytes[] memory calls = new bytes[](2);
        calls[1] = ping;
        bytes memory expected;
        bool succeeds;
        if (hopCase == 0) {
            calls[0] = abi.encodeCall(WordHop.hop, (bytes32(uint256(uint160(address(echo))))));
            succeeds = true;
            expected = bytes.concat(bytes32(uint256(uint160(address(core)))), ping);
        } else if (hopCase == 1) {
            vm.assume(uint256(w) >> 160 != 0);
            calls[0] = abi.encodeCall(WordHop.hop, (w));
            expected = abi.encodeWithSelector(InvalidAddressWord.selector, uint256(1), w);
        } else if (hopCase == 2) {
            start = address(shortReturner);
            calls[0] = ping;
            expected = abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(5));
        } else if (hopCase == 3) {
            calls[0] = abi.encodeCall(WordHop.hop, (bytes32(uint256(0xC0DE))));
            expected = abi.encodeWithSelector(CallFailed.selector, address(0xC0DE), ping);
        } else if (hopCase == 4) {
            start = address(reverter);
            calls[0] = ping;
            expected = abi.encodeWithSelector(CallFailed.selector, address(reverter), ping);
        } else {
            vm.assume(hopCase == 5);
            calls = new bytes[](0);
            expected = abi.encodeWithSelector(Assertions.EmptyCallChain.selector);
        }
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.chain, (raw(abi.encode(start)), calls)));
        vm.assume(!outOfGasArtifact(ok, out));
        assertEq(ok, succeeds);
        assertEq(out, expected);
    }

    // ============ read ============

    /**
     * @dev read names its target as operand 0 and argument i as operand i + 1:
     *      a dirty target word, then the first argument whose constraint
     *      fails, in that order
     */
    function check_readNamesItsOperands(
        bytes32 targetWord,
        bool dirtyTarget,
        uint256 a0,
        uint256 r0,
        uint256 a1,
        uint256 r1
    ) public view {
        if (dirtyTarget) vm.assume(uint256(targetWord) >> 160 != 0);
        else targetWord = bytes32(uint256(uint160(address(echo))));
        InputParam[] memory args = new InputParam[](2);
        args[0] = eq(abi.encode(a0), r0);
        args[1] = eq(abi.encode(a1), r1);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.read, (raw(abi.encode(targetWord)), bytes4(0), args)));
        if (dirtyTarget) {
            assertEq(out, abi.encodeWithSelector(InvalidAddressWord.selector, uint256(0), targetWord));
        } else if (a0 != r0) {
            assertEq(out, failed(1, a0, r0), "read does not name argument 0 as operand 1");
        } else if (a1 != r1) {
            assertEq(out, failed(2, a1, r1), "read does not name argument 1 as operand 2");
        } else {
            assertTrue(ok);
            return;
        }
        assertFalse(ok);
    }

    // ============ nav ============

    /**
     * @dev nav range-checks the word it returns and never the siblings its
     *      path skips: selecting one uint8 of two succeeds exactly when THAT
     *      word is in range, whatever the other holds
     */
    function check_navSkipsSiblings(bytes32 first, bytes32 second, bool pickSecond) public view {
        int256[] memory path = new int256[](1);
        path[0] = pickSecond ? int256(1) : int256(0);
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.nav, (raw(abi.encode(first, second)), "(uint8,uint8)", path)));
        bytes32 selected = pickSecond ? second : first;
        assertEq(ok, uint256(selected) < 256, "nav judged a word its path skips");
        if (ok) assertEq(out, abi.encode(selected));
    }

    // ============ Constraint order ============

    /**
     * @dev Every word bound is checked before any predicate: two constraints
     *      over a one-word value revert ReturnDataOutOfBounds even when the
     *      first constraint would fail
     */
    function check_constraintBoundsComeFirst(uint256 value, uint256 ref) public view {
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(ref));
        cs[1] = Constraint(ConstraintType.EQ, abi.encode(ref));
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(value), cs);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(32)));
    }

    /**
     * @dev OR leaves are evaluated in order and stop at the first match: a
     *      malformed leaf after a matching one is never read, one before it
     *      rejects the whole OR
     */
    function check_orLeavesShortCircuitInOrder(uint256 value, uint256 ref, bool malformedFirst) public view {
        Constraint[] memory leaves = new Constraint[](2);
        Constraint memory good = Constraint(ConstraintType.EQ, abi.encode(ref));
        Constraint memory bad = Constraint(ConstraintType.EQ, abi.encodePacked(ref, bytes1(0)));
        leaves[0] = malformedFirst ? bad : good;
        leaves[1] = malformedFirst ? good : bad;
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.OR, abi.encode(leaves));
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(value), cs);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
        if (!malformedFirst && value == ref) {
            assertTrue(ok, "a matching first leaf did not short-circuit");
        } else {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(InvalidConstraintData.selector, uint256(0), uint256(0), uint256(0), uint256(33))
            );
        }
    }

    // ============ paramType ============

    /**
     * @dev resolve routes nothing: TARGET, VALUE and CALL_DATA resolve alike
     */
    function check_resolveIgnoresParamType(uint8 paramType, bytes32 w) public view {
        vm.assume(paramType < 3);
        bytes memory data = abi.encode(w);
        bytes memory param = abi.encode(paramType, uint8(InputParamFetcherType.RAW_BYTES), data, new Constraint[](0));
        (bool ok, bytes memory out) =
            address(core).staticcall(bytes.concat(Assertions.resolve.selector, abi.encode(uint256(32)), param));
        assertTrue(ok, "resolve refused a parameter type");
        assertEq(out, data);
    }

    // ============ Messages and batches ============

    string constant BATCH = "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])";
    string constant BATCH_MESSAGE =
        "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[],string)";

    /**
     * @dev One predicate entry holding `p`, or a TARGET entry calling `target` with `p` as calldata
     */
    function entry(InputParam memory p, address target, bytes4 sig)
        internal
        pure
        returns (ComposableExecution[] memory b)
    {
        b = new ComposableExecution[](1);
        b[0].functionSig = sig;
        if (target == address(0)) {
            b[0].inputParams = new InputParam[](1);
            b[0].inputParams[0] = p;
        } else {
            b[0].inputParams = new InputParam[](2);
            b[0].inputParams[0] = InputParam(
                InputParamType.TARGET, InputParamFetcherType.RAW_BYTES, abi.encode(target), new Constraint[](0)
            );
            b[0].inputParams[1] = p;
        }
    }

    function judgeFailure(string memory assertion, uint256 value, uint256 ref) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            assertion,
            uint256(0),
            uint256(0),
            uint256(0),
            ConstraintType.EQ,
            bytes32(value),
            abi.encode(ref)
        );
    }

    /**
     * @dev Every judge reports its assertion name in ConstraintFailed: the
     *      custom message when given, "PARAM" for assertParam and "COMPOSABLE"
     *      for assertBatch by default, "" on a primitive's operand
     */
    function check_judgesEchoTheirMessage(uint256 value, uint256 ref, uint8 judge) public view {
        vm.assume(value != ref);
        InputParam memory p = eq(abi.encode(value), ref);
        bytes memory data;
        string memory expected;
        if (judge == 0) {
            data = abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p);
            expected = "PARAM";
        } else if (judge == 1) {
            data = abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]),string)", p, "custom");
            expected = "custom";
        } else if (judge == 2) {
            data = abi.encodeWithSignature(BATCH, entry(p, address(0), bytes4(0)));
            expected = "COMPOSABLE";
        } else if (judge == 3) {
            data = abi.encodeWithSignature(BATCH_MESSAGE, entry(p, address(0), bytes4(0)), "custom");
            expected = "custom";
        } else {
            vm.assume(judge == 4);
            data = abi.encodeCall(Assertions.resolve, (p));
            expected = "";
        }
        (bool ok, bytes memory out) = address(core).staticcall(data);
        assertFalse(ok);
        assertEq(out, judgeFailure(expected, value, ref), "the judge does not report its message");
    }

    /**
     * @dev A batch entry with a TARGET builds functionSig ++ calldata operands
     *      and staticcalls it: a reverting target reverts CallFailed with that
     *      exact calldata, a quiet one passes
     */
    function check_batchConstructedCallFailure(bytes4 sig, bytes32 w, bool reverts) public view {
        address target = reverts ? address(reverter) : address(silent);
        bytes memory data = abi.encodeWithSignature(BATCH, entry(raw(abi.encode(w)), target, sig));
        (bool ok, bytes memory out) = address(core).staticcall(data);
        vm.assume(!outOfGasArtifact(ok, out));
        if (reverts) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(CallFailed.selector, target, abi.encodePacked(sig, w)));
        } else {
            assertTrue(ok, "a quiet constructed call failed the batch");
        }
    }

    /**
     * @dev A whole batch is an operand: isValid over an assertBatch self-call is 1 exactly when it passes
     */
    function check_batchIsAnOperand(uint256 value, uint256 ref) public view {
        bytes memory call = abi.encodeWithSignature(BATCH, entry(eq(abi.encode(value), ref), address(0), bytes4(0)));
        InputParam memory probe = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(core), call),
            new Constraint[](0)
        );
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (probe)));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok);
        assertEq(abi.decode(out, (uint256)), value == ref ? 1 : 0);
    }

    // ============ gather, read and get ============

    /**
     * @dev gather resolves every operand in order and names the first failing one by its list index
     */
    function check_gatherNamesByIndex(uint256[3] memory values, uint256[3] memory refs) public view {
        InputParam[] memory args = new InputParam[](3);
        for (uint256 i; i < 3; i++) {
            args[i] = eq(abi.encode(values[i]), refs[i]);
        }
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.gather, (args)));
        for (uint256 i; i < 3; i++) {
            if (values[i] != refs[i]) {
                assertFalse(ok);
                assertEq(out, failed(i, values[i], refs[i]), "gather does not name the failing operand by index");
                return;
            }
        }
        assertTrue(ok);
        bytes[] memory got = abi.decode(out, (bytes[]));
        for (uint256 i; i < 3; i++) {
            assertEq(got[i], abi.encode(values[i]));
        }
    }

    /**
     * @dev read and get revert CallFailed with the exact constructed calldata
     *      on a code-less or reverting target, and get with "()" and no
     *      arguments sends the bare selector
     */
    function check_readAndGetReportTheirCall(bytes4 sel, bytes32 w, uint8 targetCase, bool useGet) public view {
        address target;
        if (targetCase == 0) {
            target = address(0xC0DE);
        } else if (targetCase == 1) {
            target = address(reverter);
        } else {
            vm.assume(targetCase == 2);
            target = address(echo);
        }
        InputParam[] memory args;
        bytes memory callData;
        bytes memory data;
        if (useGet) {
            args = new InputParam[](0);
            callData = abi.encodePacked(sel);
            data = abi.encodeCall(Assertions.get, (raw(abi.encode(target)), sel, "()", args));
        } else {
            args = new InputParam[](1);
            args[0] = raw(abi.encode(w));
            callData = abi.encodePacked(sel, w);
            data = abi.encodeCall(Assertions.read, (raw(abi.encode(target)), sel, args));
        }
        (bool ok, bytes memory out) = address(core).staticcall(data);
        vm.assume(!outOfGasArtifact(ok, out));
        if (target == address(echo)) {
            assertTrue(ok);
            assertEq(out, bytes.concat(bytes32(uint256(uint160(address(core)))), callData));
        } else {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(CallFailed.selector, target, callData));
        }
    }

    // ============ Positional constraints on primitives ============

    /**
     * @dev On a primitive's operand constraint i judges word i, as in the
     *      judge: [SKIP, EQ ref] over two words tests only the second, and a
     *      malformed constraint names its own index
     */
    function check_primitiveConstraintsArePositional(bytes32 w0, bytes32 w1, uint256 ref, bool malformed) public view {
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.SKIP, "");
        cs[1] = malformed
            ? Constraint(ConstraintType.EQ, abi.encodePacked(ref, bytes1(0)))
            : Constraint(ConstraintType.EQ, abi.encode(ref));
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(w0, w1), cs);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.resolve, (p)));
        if (malformed) {
            assertEq(
                out,
                abi.encodeWithSelector(InvalidConstraintData.selector, uint256(0), uint256(0), uint256(1), uint256(33))
            );
        } else if (uint256(w1) != ref) {
            assertEq(
                out,
                abi.encodeWithSelector(
                    ConstraintFailed.selector,
                    "",
                    uint256(0),
                    uint256(0),
                    uint256(1),
                    ConstraintType.EQ,
                    w1,
                    abi.encode(ref)
                )
            );
        } else {
            assertTrue(ok, "a SKIP judged its word");
            assertEq(out, abi.encode(w0, w1));
            return;
        }
        assertFalse(ok);
    }

    // ============ Harness ============

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function eq(bytes memory data, uint256 ref) internal pure returns (InputParam memory p) {
        p = raw(data);
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(ref));
    }

    /**
     * @dev The core's ConstraintFailed for an EQ on operand `index` of a primitive (no assertion name, entry 0)
     */
    function failed(uint256 index, uint256 value, uint256 ref) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            "",
            uint256(0),
            index,
            uint256(0),
            ConstraintType.EQ,
            bytes32(value),
            abi.encode(ref)
        );
    }

    /**
     * @dev Halmos has no gas model: gasleft() is a fresh symbol, so the core's
     *      out-of-gas guard can fire on any failing path it explores, which no
     *      real execution takes. That outcome is discarded.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
    }
}
