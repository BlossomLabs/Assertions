// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operators.sol";
import "../ERC8211.sol";
import "./Mocks.sol";

/**
 * @notice Test suite for the ERC-8211-based Assertions core: single-param
 *         assertions, the view-mode batch judge, and a
 *         parity section proving every v1 core use case (Ne / strict
 *         Gt/Lt, signed ints, tuple indexing, strings, array lengths,
 *         approx equality, balances, block env, chain id, code checks) is
 *         still expressible and judged through the core.
 */
contract AssertionsTest is Test {
    Assertions public assertions;
    Operators public ops;
    MockTarget public target;
    MockToken public token;

    address constant TEST_EOA = address(0x1234);

    // Selectors of the overloaded Operators word ops (abi.encodeCall cannot
    // disambiguate overloads, so the read-splicing helpers take selectors)
    bytes4 constant EQ_U = bytes4(keccak256("eq(uint256,uint256)"));
    bytes4 constant NE_U = bytes4(keccak256("ne(uint256,uint256)"));
    bytes4 constant GT_U = bytes4(keccak256("gt(uint256,uint256)"));
    bytes4 constant LT_U = bytes4(keccak256("lt(uint256,uint256)"));
    bytes4 constant GT_S = bytes4(keccak256("gt(int256,int256)"));
    bytes4 constant LT_S = bytes4(keccak256("lt(int256,int256)"));
    bytes4 constant GE_S = bytes4(keccak256("ge(int256,int256)"));
    bytes4 constant LE_S = bytes4(keccak256("le(int256,int256)"));
    bytes4 constant ABS_U = bytes4(keccak256("absDiff(uint256,uint256)"));
    bytes4 constant ABS_S = bytes4(keccak256("absDiff(int256,int256)"));

    function setUp() public {
        assertions = new Assertions();
        ops = new Operators();
        target = new MockTarget();
        token = new MockToken(address(0), "WETH");
        target.setToken(address(token));
    }

    // ============ Test Helpers ============

    function _none() internal pure returns (Constraint[] memory cs) {
        cs = new Constraint[](0);
    }

    function _c1(ConstraintType t, bytes memory ref) internal pure returns (Constraint[] memory cs) {
        cs = new Constraint[](1);
        cs[0] = Constraint(t, ref);
    }

    function _c2(
        ConstraintType t1,
        bytes memory ref1,
        ConstraintType t2,
        bytes memory ref2
    ) internal pure returns (Constraint[] memory cs) {
        cs = new Constraint[](2);
        cs[0] = Constraint(t1, ref1);
        cs[1] = Constraint(t2, ref2);
    }

    /**
     * @dev A RAW_BYTES CALL_DATA parameter
     */
    function _raw(bytes memory v, Constraint[] memory cs) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, v, cs);
    }

    /**
     * @dev A STATIC_CALL CALL_DATA parameter
     */
    function _call(address t, bytes memory d, Constraint[] memory cs) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), cs);
    }

    /**
     * @dev A BALANCE CALL_DATA parameter
     */
    function _bal(address tok, address account, Constraint[] memory cs) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.BALANCE, abi.encodePacked(tok, account), cs);
    }

    /**
     * @dev A RAW_BYTES TARGET parameter
     */
    function _target(address t) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.TARGET, InputParamFetcherType.RAW_BYTES, abi.encode(t), _none());
    }

    function _params1(InputParam memory a) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](1);
        ps[0] = a;
    }

    function _params2(InputParam memory a, InputParam memory b) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](2);
        ps[0] = a;
        ps[1] = b;
    }

    function _params3(
        InputParam memory a,
        InputParam memory b,
        InputParam memory c
    ) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](3);
        ps[0] = a;
        ps[1] = b;
        ps[2] = c;
    }

    function _entry(bytes4 sig, InputParam[] memory ps) internal pure returns (ComposableExecution memory) {
        return ComposableExecution(sig, ps, new OutputParam[](0));
    }

    function _batch1(ComposableExecution memory e) internal pure returns (ComposableExecution[] memory ex) {
        ex = new ComposableExecution[](1);
        ex[0] = e;
    }

    function _batch2(
        ComposableExecution memory e1,
        ComposableExecution memory e2
    ) internal pure returns (ComposableExecution[] memory ex) {
        ex = new ComposableExecution[](2);
        ex[0] = e1;
        ex[1] = e2;
    }

    /**
     * @dev A single predicate entry (no TARGET) wrapping one parameter
     */
    function _predicate(InputParam memory p) internal pure returns (ComposableExecution[] memory) {
        return _batch1(_entry(bytes4(0), _params1(p)));
    }

    function _getValue() internal view returns (bytes memory) {
        return abi.encode(address(target), abi.encodeCall(MockTarget.getValue, ()));
    }

    // ============ assertParam: constraint types ============

    function test_assertParam_eq_success() public view {
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.EQ, abi.encode(uint256(42)))));
    }

    function test_assertParam_eq_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(42)),
                abi.encode(uint256(100))
            )
        );
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.EQ, abi.encode(uint256(100)))));
    }

    function test_assertParam_gte_success() public view {
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(42)))));
    }

    function test_assertParam_gte_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.GTE,
                bytes32(uint256(42)),
                abi.encode(uint256(43))
            )
        );
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(43)))));
    }

    function test_assertParam_lte_success() public view {
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.LTE, abi.encode(uint256(42)))));
    }

    function test_assertParam_lte_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.LTE,
                bytes32(uint256(42)),
                abi.encode(uint256(41))
            )
        );
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.LTE, abi.encode(uint256(41)))));
    }

    function test_assertParam_in_success_interior_and_bounds() public view {
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.IN, abi.encode(uint256(1), uint256(100))));
        assertions.assertParam(p);
        // inclusive bounds
        p.constraints[0].referenceData = abi.encode(uint256(42), uint256(42));
        assertions.assertParam(p);
    }

    function test_assertParam_in_reverts_below_and_above() public {
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.IN, abi.encode(uint256(43), uint256(100))));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.IN,
                bytes32(uint256(42)),
                abi.encode(uint256(43), uint256(100))
            )
        );
        assertions.assertParam(p);

        p.constraints[0].referenceData = abi.encode(uint256(1), uint256(41));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.IN,
                bytes32(uint256(42)),
                abi.encode(uint256(1), uint256(41))
            )
        );
        assertions.assertParam(p);
    }

    function test_assertParam_secondConstraint_reverts_withIndex() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                1,
                ConstraintType.LTE,
                bytes32(uint256(42)),
                abi.encode(uint256(41))
            )
        );
        assertions.assertParam(
            _call(
                address(target),
                abi.encodeCall(MockTarget.getValue, ()),
                _c2(ConstraintType.GTE, abi.encode(uint256(1)), ConstraintType.LTE, abi.encode(uint256(41)))
            )
        );
    }

    function test_assertParam_withMessage() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "Treasury balance too low",
                0,
                0,
                0,
                ConstraintType.GTE,
                bytes32(uint256(42)),
                abi.encode(uint256(1000))
            )
        );
        assertions.assertParam(
            _call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(1000)))),
            "Treasury balance too low"
        );
    }

    // ============ assertParam: fetcher types ============

    function test_assertParam_rawBytes_literal() public view {
        assertions.assertParam(_raw(abi.encode(uint256(7)), _c1(ConstraintType.EQ, abi.encode(uint256(7)))));
    }

    function test_assertParam_balance_erc20() public view {
        // MockToken.balanceOf returns 1000 for any non-zero account
        assertions.assertParam(_bal(address(token), TEST_EOA, _c1(ConstraintType.EQ, abi.encode(uint256(1000)))));
    }

    function test_assertParam_balance_native() public {
        vm.deal(TEST_EOA, 5 ether);
        assertions.assertParam(_bal(address(0), TEST_EOA, _c1(ConstraintType.GTE, abi.encode(uint256(5 ether)))));
    }

    function test_assertParam_balance_reverts() public {
        vm.deal(TEST_EOA, 1 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.GTE,
                bytes32(uint256(1 ether)),
                abi.encode(uint256(2 ether))
            )
        );
        assertions.assertParam(_bal(address(0), TEST_EOA, _c1(ConstraintType.GTE, abi.encode(uint256(2 ether)))));
    }

    function test_assertParam_addressWord_constraint() public view {
        // addresses compare as left-padded words
        assertions.assertParam(
            _call(address(target), abi.encodeCall(MockTarget.getAddress, ()), _c1(ConstraintType.EQ, abi.encode(address(0xBEEF))))
        );
    }

    function test_assertParam_noConstraints_isCallSuccessAssert() public view {
        // no constraints: the assertion is just "this staticcall succeeds"
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _none()));
    }

    // ============ assertParam: malformed inputs and call failures ============

    function test_assertParam_invalidBalanceData() public {
        InputParam memory p = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.BALANCE,
            abi.encodePacked(address(token)), // 20 bytes, not 40
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(InvalidBalanceData.selector, 0, 0, 20));
        assertions.assertParam(p);
    }

    function test_assertParam_invalidConstraintData_word() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidConstraintData.selector, 0, 0, 0, 31));
        assertions.assertParam(_raw(abi.encode(uint256(7)), _c1(ConstraintType.EQ, new bytes(31))));
    }

    function test_assertParam_invalidConstraintData_range() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidConstraintData.selector, 0, 0, 0, 32));
        assertions.assertParam(_raw(abi.encode(uint256(7)), _c1(ConstraintType.IN, abi.encode(uint256(1)))));
    }

    function test_assertParam_callReverts() public {
        bytes memory callData = abi.encodeCall(MockTarget.revertingFunction, ());
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), callData));
        assertions.assertParam(_call(address(target), callData, _none()));
    }

    function test_assertParam_codelessTarget() public {
        bytes memory callData = abi.encodeCall(MockTarget.getValue, ());
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, TEST_EOA, callData));
        assertions.assertParam(_call(TEST_EOA, callData, _none()));
    }

    function test_assertParam_shortReturn_withConstraint() public {
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 0, 0));
        assertions.assertParam(
            _call(address(token), abi.encodeCall(MockToken.emptyReturn, ()), _c1(ConstraintType.EQ, abi.encode(uint256(0))))
        );
    }

    // ============ assertComposable (native judge): predicate entries ============

    function test_assertComposable_predicate_success() public view {
        assertions.assertComposable(
            _predicate(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(1)))))
        );
    }

    function test_assertComposable_predicate_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "COMPOSABLE",
                0,
                0,
                0,
                ConstraintType.GTE,
                bytes32(uint256(42)),
                abi.encode(uint256(1000))
            )
        );
        assertions.assertComposable(
            _predicate(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(1000)))))
        );
    }

    function test_assertComposable_secondEntry_reverts_withEntryIndex() public {
        ComposableExecution[] memory ex = _batch2(
            _entry(bytes4(0), _params1(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.EQ, abi.encode(uint256(42)))))),
            _entry(bytes4(0), _params1(_call(address(target), abi.encodeCall(MockTarget.getBool, ()), _c1(ConstraintType.EQ, abi.encode(false)))))
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "COMPOSABLE",
                1,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(1)),
                abi.encode(false)
            )
        );
        assertions.assertComposable(ex);
    }

    function test_assertComposable_multiParam_and_composition() public {
        // both parameters on one predicate entry must pass; second fails
        ComposableExecution[] memory ex = _batch1(
            _entry(
                bytes4(0),
                _params2(
                    _call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.EQ, abi.encode(uint256(42)))),
                    _bal(address(token), TEST_EOA, _c1(ConstraintType.GTE, abi.encode(uint256(1001))))
                )
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "COMPOSABLE",
                0,
                1,
                0,
                ConstraintType.GTE,
                bytes32(uint256(1000)),
                abi.encode(uint256(1001))
            )
        );
        assertions.assertComposable(ex);
    }

    function test_assertComposable_withMessage() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "swap output too low",
                0,
                0,
                0,
                ConstraintType.GTE,
                bytes32(uint256(1000)),
                abi.encode(uint256(2500))
            )
        );
        assertions.assertComposable(
            _predicate(_bal(address(token), TEST_EOA, _c1(ConstraintType.GTE, abi.encode(uint256(2500))))),
            "swap output too low"
        );
    }

    function test_assertComposable_emptyBatch_passes() public view {
        assertions.assertComposable(new ComposableExecution[](0));
    }

    // ============ assertComposable (native judge): constructed calls ============

    function test_assertComposable_constructedCall_success() public view {
        // calldata is built as functionSig ++ resolved CALL_DATA params
        assertions.assertComposable(
            _batch1(
                _entry(
                    MockTarget.checkValue.selector,
                    _params2(_target(address(target)), _raw(abi.encode(uint256(42)), _none()))
                )
            )
        );
    }

    function test_assertComposable_constructedCall_multiParam_success() public view {
        assertions.assertComposable(
            _batch1(
                _entry(
                    MockTarget.checkPair.selector,
                    _params3(
                        _target(address(target)),
                        _raw(abi.encode(uint256(42)), _none()),
                        // second arg resolved live: getAddress() returns 0xBEEF
                        _call(address(target), abi.encodeCall(MockTarget.getAddress, ()), _none())
                    )
                )
            )
        );
    }

    function test_assertComposable_constructedCall_reverts_withBuiltCalldata() public {
        bytes memory builtCalldata = abi.encodePacked(MockTarget.checkValue.selector, abi.encode(uint256(41)));
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), builtCalldata));
        assertions.assertComposable(
            _batch1(
                _entry(
                    MockTarget.checkValue.selector,
                    _params2(_target(address(target)), _raw(abi.encode(uint256(41)), _none()))
                )
            )
        );
    }

    function test_assertComposable_runtimeResolvedTarget() public view {
        // TARGET fetched via STATIC_CALL: target.token() resolves the token address
        InputParam memory runtimeTarget = InputParam(
            InputParamType.TARGET,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(target), abi.encodeCall(MockTarget.token, ())),
            _none()
        );
        assertions.assertComposable(_batch1(_entry(MockToken.decimals.selector, _params1(runtimeTarget))));
    }

    function test_assertComposable_zeroTarget_skipsCall() public view {
        // per the standard, target == address(0) skips the call (even with a garbage selector)
        InputParam memory zeroTarget = InputParam(
            InputParamType.TARGET,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(address(0)),
            _none()
        );
        assertions.assertComposable(_batch1(_entry(0xdeadbeef, _params1(zeroTarget))));
    }

    // ============ assertComposable (native judge): malformed batches ============

    function test_assertComposable_dirtyTargetWord() public {
        bytes32 dirty = bytes32(uint256(1) << 200 | uint256(uint160(address(target))));
        InputParam memory p = InputParam(InputParamType.TARGET, InputParamFetcherType.RAW_BYTES, abi.encode(dirty), _none());
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        assertions.assertComposable(_batch1(_entry(MockTarget.getValue.selector, _params1(p))));
    }

    function test_assertComposable_duplicateTarget() public {
        vm.expectRevert(abi.encodeWithSelector(Assertions.DuplicateTargetParam.selector, 0));
        assertions.assertComposable(
            _batch1(_entry(MockTarget.getValue.selector, _params2(_target(address(target)), _target(address(target)))))
        );
    }

    function test_assertComposable_valueParam() public {
        InputParam memory valueParam = InputParam(
            InputParamType.VALUE,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(uint256(1 ether)),
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(Assertions.ValueParamNotSupported.selector, 0, 1));
        assertions.assertComposable(
            _batch1(_entry(MockTarget.getValue.selector, _params2(_target(address(target)), valueParam)))
        );
    }

    function test_assertComposable_outputParams() public {
        OutputParam[] memory outs = new OutputParam[](1);
        outs[0] = OutputParam(OutputParamFetcherType.EXEC_RESULT, "");
        ComposableExecution[] memory ex = new ComposableExecution[](1);
        ex[0] = ComposableExecution(bytes4(0), _params1(_raw(abi.encode(uint256(1)), _none())), outs);
        vm.expectRevert(abi.encodeWithSelector(Assertions.OutputParamsNotSupported.selector, 0));
        assertions.assertComposable(ex);
    }

    function test_assertComposable_balanceAsTarget() public {
        InputParam memory p = InputParam(
            InputParamType.TARGET,
            InputParamFetcherType.BALANCE,
            abi.encodePacked(address(token), TEST_EOA),
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(Assertions.BalanceCannotBeTarget.selector, 0, 0));
        assertions.assertComposable(_batch1(_entry(bytes4(0), _params1(p))));
    }

    // ════════════ V1 use-case parity ════════════
    //
    // Every assertion family the v1 core exposed as a dedicated function,
    // recovered in the ERC-8211 design and judged through the core.
    // Direct EQ / GTE / LTE / IN checks are plain constraints; everything
    // the constraint set cannot say (Ne, strict Gt/Lt, signed comparisons,
    // tuple indexing, strings, approx deltas, block env, code checks) is
    // the core's read splicing resolved operands into a plain Operators
    // call, judged through a constrained STATIC_CALL fetcher pointed at
    // the core itself (or directly at Operators for argument-free reads).

    // ---- Parity helpers ----

    /**
     * @dev An unconstrained STATIC_CALL operand
     */
    function _op(address t, bytes memory d) internal pure returns (InputParam memory) {
        return _call(t, d, _none());
    }

    /**
     * @dev A literal word operand
     */
    function _lit(uint256 v) internal pure returns (InputParam memory) {
        return _raw(abi.encode(v), _none());
    }

    /**
     * @dev A signed literal word operand
     */
    function _slit(int256 v) internal pure returns (InputParam memory) {
        return _raw(abi.encode(v), _none());
    }

    /**
     * @dev A read-spliced expression (core calldata) judged by the core
     *      under one constraint — the fetcher targets the core itself
     */
    function _expr(bytes memory exprCalldata, ConstraintType t, bytes memory ref) internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), exprCalldata),
            _c1(t, ref)
        );
    }

    /**
     * @dev An argument-free Operators read judged under one constraint —
     *      the fetcher targets Operators directly, no splicing needed
     */
    function _opsExpr(bytes memory opsCalldata, ConstraintType t, bytes memory ref) internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(ops), opsCalldata),
            _c1(t, ref)
        );
    }

    /**
     * @dev read calldata splicing two operands into a binary Operators call
     */
    function _read2(bytes4 sel, InputParam memory a, InputParam memory b) internal view returns (bytes memory) {
        return abi.encodeCall(Assertions.read, (_lit(uint256(uint160(address(ops)))), sel, _params2(a, b)));
    }

    /**
     * @dev read calldata splicing one operand into a unary Operators call
     */
    function _read1(bytes4 sel, InputParam memory a) internal view returns (bytes memory) {
        return abi.encodeCall(Assertions.read, (_lit(uint256(uint160(address(ops)))), sel, _params1(a)));
    }

    /**
     * @dev Asserts a read-spliced boolean expression evaluates to 1, judged
     *      by the core (the v1 pattern for every non-EQ/GTE/LTE check)
     */
    function _assertHolds(bytes memory exprCalldata) internal view {
        assertions.assertParam(_expr(exprCalldata, ConstraintType.EQ, abi.encode(uint256(1))));
    }

    /**
     * @dev Expects the next assertParam to fail its (single) constraint
     */
    function _expectParamFail(ConstraintType t, bytes32 actual, bytes memory ref) internal {
        vm.expectRevert(abi.encodeWithSelector(ConstraintFailed.selector, "PARAM", 0, 0, 0, t, actual, ref));
    }

    /**
     * @dev Expects the next _assertHolds to fail (expression yielded 0)
     */
    function _expectHoldsFail() internal {
        _expectParamFail(ConstraintType.EQ, bytes32(uint256(0)), abi.encode(uint256(1)));
    }

    function _getValueOp() internal view returns (InputParam memory) {
        return _op(address(target), abi.encodeCall(MockTarget.getValue, ()));
    }

    function _getIntOp() internal view returns (InputParam memory) {
        return _op(address(target), abi.encodeCall(MockTarget.getInt, ()));
    }

    /**
     * @dev pick(operand, wordIndex) as a nested-expression operand
     */
    function _pickOp(InputParam memory operand, int256 wordIndex) internal view returns (InputParam memory) {
        return _op(address(assertions), abi.encodeCall(Assertions.pick, (operand, wordIndex)));
    }

    // ---- Parity: uint calls (v1 assertNe/Gt/Lt/Ge/LeCallUint) ----

    function test_parity_neCallUint() public {
        _assertHolds(_read2(NE_U, _getValueOp(), _lit(100)));
        _expectHoldsFail();
        _assertHolds(_read2(NE_U, _getValueOp(), _lit(42)));
    }

    function test_parity_gtCallUint_viaGtePlusOne() public {
        // actual > expected  <=>  actual GTE expected + 1 (uint idiom)
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(41 + 1)))));
        _expectParamFail(ConstraintType.GTE, bytes32(uint256(42)), abi.encode(uint256(43)));
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getValue, ()), _c1(ConstraintType.GTE, abi.encode(uint256(42 + 1)))));
    }

    function test_parity_gtCallUint_viaRead() public {
        _assertHolds(_read2(GT_U, _getValueOp(), _lit(41)));
        _expectHoldsFail();
        _assertHolds(_read2(GT_U, _getValueOp(), _lit(42)));
    }

    function test_parity_ltCallUint() public {
        _assertHolds(_read2(LT_U, _getValueOp(), _lit(43)));
        _expectHoldsFail();
        _assertHolds(_read2(LT_U, _getValueOp(), _lit(42)));
    }

    // ---- Parity: int calls (v1 assertEq/Ne/Gt/Lt/Ge/LeCallInt) ----

    function test_parity_eqCallInt() public view {
        // two's-complement bit equality: a plain EQ constraint
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getInt, ()), _c1(ConstraintType.EQ, abi.encode(int256(-42)))));
    }

    function test_parity_eqCallInt_minMax() public view {
        assertions.assertParam(_raw(abi.encode(type(int256).min), _c1(ConstraintType.EQ, abi.encode(type(int256).min))));
        assertions.assertParam(_raw(abi.encode(type(int256).max), _c1(ConstraintType.EQ, abi.encode(type(int256).max))));
    }

    function test_parity_neCallInt() public {
        _assertHolds(_read2(NE_U, _getIntOp(), _slit(0)));
        _expectHoldsFail();
        _assertHolds(_read2(NE_U, _getIntOp(), _slit(-42)));
    }

    function test_parity_gtCallInt_signed() public {
        // temperature() == -7: the int256 gt overload orders negatives
        // correctly where an unsigned constraint could not
        InputParam memory temperature = _op(address(token), abi.encodeCall(MockToken.temperature, ()));
        _assertHolds(_read2(GT_S, temperature, _slit(-10)));
        _expectHoldsFail();
        _assertHolds(_read2(GT_S, temperature, _slit(-7)));
    }

    function test_parity_gtCallInt_minToMax() public view {
        _assertHolds(_read2(GT_S, _slit(type(int256).max), _slit(type(int256).min)));
    }

    function test_parity_ltCallInt_signed() public {
        _assertHolds(_read2(LT_S, _getIntOp(), _slit(0)));
        _expectHoldsFail();
        _assertHolds(_read2(LT_S, _slit(type(int256).max), _slit(type(int256).min)));
    }

    function test_parity_geLeCallInt_signed() public view {
        _assertHolds(_read2(GE_S, _getIntOp(), _slit(-42)));
        _assertHolds(_read2(LE_S, _getIntOp(), _slit(-42)));
    }

    // ---- Parity: address / bool / bytes32 ----

    function test_parity_neCallAddress() public {
        InputParam memory getAddr = _op(address(target), abi.encodeCall(MockTarget.getAddress, ()));
        _assertHolds(_read2(NE_U, getAddr, _lit(uint256(uint160(address(0x5678))))));
        _expectHoldsFail();
        _assertHolds(_read2(NE_U, getAddr, _lit(uint256(uint160(address(0xBEEF))))));
    }

    function test_parity_assertTrue() public {
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getBool, ()), _c1(ConstraintType.EQ, abi.encode(true))));
        _expectParamFail(ConstraintType.EQ, bytes32(0), abi.encode(true));
        assertions.assertParam(_call(address(token), abi.encodeCall(MockToken.paused, ()), _c1(ConstraintType.EQ, abi.encode(true))));
    }

    function test_parity_assertFalse() public {
        assertions.assertParam(_call(address(token), abi.encodeCall(MockToken.paused, ()), _c1(ConstraintType.EQ, abi.encode(false))));
        _expectParamFail(ConstraintType.EQ, bytes32(uint256(1)), abi.encode(false));
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getBool, ()), _c1(ConstraintType.EQ, abi.encode(false))));
    }

    function test_parity_eqCallBytes32() public view {
        assertions.assertParam(_call(address(target), abi.encodeCall(MockTarget.getBytes32, ()), _c1(ConstraintType.EQ, abi.encode(keccak256("test")))));
    }

    function test_parity_neCallBytes32() public {
        InputParam memory getB32 = _op(address(target), abi.encodeCall(MockTarget.getBytes32, ()));
        _assertHolds(_read2(NE_U, getB32, _raw(abi.encode(keccak256("other")), _none())));
        _expectHoldsFail();
        _assertHolds(_read2(NE_U, getB32, _raw(abi.encode(keccak256("test")), _none())));
    }

    // ---- Parity: raw bytes and strings (v1 assertEq/NeCallBytes, StringN) ----

    function test_parity_eqCallBytes_viaHash() public {
        // pin a string return with hash + EQ, the v1 raw-bytes compare: the
        // resolved envelope IS hash(bytes)'s calldata, so the digest covers
        // the decoded PAYLOAD — keccak256("hello"), the string itself
        InputParam memory getString = _op(address(target), abi.encodeCall(MockTarget.getString, ()));
        assertions.assertParam(
            _expr(
                _read1(Operators.hash.selector, getString),
                ConstraintType.EQ,
                abi.encode(keccak256("hello"))
            )
        );
        _expectParamFail(ConstraintType.EQ, keccak256("hello"), abi.encode(keccak256("other")));
        assertions.assertParam(
            _expr(
                _read1(Operators.hash.selector, getString),
                ConstraintType.EQ,
                abi.encode(keccak256("other"))
            )
        );
    }

    function test_parity_neCallBytes_viaHash() public view {
        InputParam memory hashOp = _op(
            address(assertions),
            _read1(Operators.hash.selector, _op(address(target), abi.encodeCall(MockTarget.getString, ())))
        );
        _assertHolds(_read2(NE_U, hashOp, _raw(abi.encode(keccak256("other")), _none())));
    }

    // ---- Parity: tuple-indexed reads (v1 assertXxCallYyyN) ----

    function test_parity_uintN() public view {
        // getTuple() = (42, 0xBEEF, true, keccak("test")): static words 0..3
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(0))), ConstraintType.EQ, abi.encode(uint256(42))));
    }

    function test_parity_addressN() public view {
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(1))), ConstraintType.EQ, abi.encode(address(0xBEEF))));
    }

    function test_parity_boolN() public view {
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(2))), ConstraintType.EQ, abi.encode(true)));
    }

    function test_parity_bytes32N() public view {
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(3))), ConstraintType.EQ, abi.encode(keccak256("test"))));
    }

    function test_parity_intN() public view {
        // getIntTuple() = (-42, 7)
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getIntTuple, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(0))), ConstraintType.EQ, abi.encode(int256(-42))));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(1))), ConstraintType.EQ, abi.encode(int256(7))));
    }

    function test_parity_tupleIndexOutOfRange() public {
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 4, 128));
        assertions.pick(tuple, 4);
    }

    function test_parity_stringN() public view {
        // getTupleWithString() = (42, "hello", 0xBEEF): head words 0..2,
        // then the string's length word (3) and payload word (4)
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTupleWithString, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(3))), ConstraintType.EQ, abi.encode(uint256(5))));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(4))), ConstraintType.EQ, abi.encode(bytes32("hello"))));
    }

    function test_parity_stringN_failure() public {
        InputParam memory tuple = _op(address(target), abi.encodeCall(MockTarget.getTupleWithString, ()));
        _expectParamFail(ConstraintType.EQ, bytes32("hello"), abi.encode(bytes32("world")));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(tuple, int256(4))), ConstraintType.EQ, abi.encode(bytes32("world"))));
    }

    // ---- Parity: array lengths (v1 assertXxCallArrayLength) ----

    function test_parity_arrayLength_eq() public view {
        // a single dynamic-array return keeps its length at word 1
        InputParam memory arr = _op(address(target), abi.encodeCall(MockTarget.getArray, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(arr, int256(1))), ConstraintType.EQ, abi.encode(uint256(5))));
        InputParam memory empty = _op(address(target), abi.encodeCall(MockTarget.getEmptyArray, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(empty, int256(1))), ConstraintType.EQ, abi.encode(uint256(0))));
    }

    function test_parity_arrayLength_ne() public {
        InputParam memory lenOp = _pickOp(_op(address(target), abi.encodeCall(MockTarget.getArray, ())), 1);
        _assertHolds(_read2(NE_U, lenOp, _lit(0)));

        InputParam memory emptyLenOp = _pickOp(_op(address(target), abi.encodeCall(MockTarget.getEmptyArray, ())), 1);
        _expectHoldsFail();
        _assertHolds(_read2(NE_U, emptyLenOp, _lit(0)));
    }

    function test_parity_arrayLength_bounds() public {
        InputParam memory arr = _op(address(target), abi.encodeCall(MockTarget.getArray, ()));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(arr, int256(1))), ConstraintType.GTE, abi.encode(uint256(5))));
        assertions.assertParam(_expr(abi.encodeCall(Assertions.pick,(arr, int256(1))), ConstraintType.LTE, abi.encode(uint256(5))));
        // strict comparisons via read-spliced operators
        InputParam memory lenOp = _pickOp(arr, 1);
        _assertHolds(_read2(GT_U, lenOp, _lit(4)));
        _assertHolds(_read2(LT_U, lenOp, _lit(6)));
        _expectHoldsFail();
        _assertHolds(_read2(LT_U, lenOp, _lit(5)));
    }

    // ---- Parity: approximate equality (v1 assertApproxEqCallUint/Int) ----

    function test_parity_approxEqCallUint() public {
        // |getValue() - 45| = 3, judged against maxDelta via LTE
        bytes memory delta = _read2(ABS_U, _getValueOp(), _lit(45));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(5))));
        // exact
        bytes memory exact = _read2(ABS_U, _getValueOp(), _lit(42));
        assertions.assertParam(_expr(exact, ConstraintType.LTE, abi.encode(uint256(0))));
        // out of tolerance
        _expectParamFail(ConstraintType.LTE, bytes32(uint256(3)), abi.encode(uint256(2)));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(2))));
    }

    function test_parity_approxEqCallUint_withMessage() public {
        bytes memory delta = _read2(ABS_U, _getValueOp(), _lit(45));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "price drifted",
                0,
                0,
                0,
                ConstraintType.LTE,
                bytes32(uint256(3)),
                abi.encode(uint256(2))
            )
        );
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(2))), "price drifted");
    }

    function test_parity_approxEqCallInt_crossingZero() public {
        // |temperature() - 3| = |-7 - 3| = 10
        InputParam memory temperature = _op(address(token), abi.encodeCall(MockToken.temperature, ()));
        bytes memory delta = _read2(ABS_S, temperature, _slit(3));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(10))));
        _expectParamFail(ConstraintType.LTE, bytes32(uint256(10)), abi.encode(uint256(9)));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(9))));
    }

    function test_parity_approxEqCallInt_fullRange() public view {
        // the widest signed span is total (no revert) and judged unsigned
        bytes memory delta = _read2(ABS_S, _slit(type(int256).min), _slit(type(int256).max));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(type(uint256).max)));
    }

    function test_parity_approxEqCallIntN() public view {
        // approx over a tuple element: signed absDiff composed over a nested pick
        InputParam memory secondInt = _pickOp(_op(address(target), abi.encodeCall(MockTarget.getIntTuple, ())), 1);
        bytes memory delta = _read2(ABS_S, secondInt, _slit(5));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(2))));
    }

    function test_parity_approxEqBalance() public {
        vm.deal(TEST_EOA, 5 ether + 3 wei);
        bytes memory delta = _read2(ABS_U, _bal(address(0), TEST_EOA, _none()), _lit(5 ether));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(1 gwei))));
        _expectParamFail(ConstraintType.LTE, bytes32(uint256(3)), abi.encode(uint256(2)));
        assertions.assertParam(_expr(delta, ConstraintType.LTE, abi.encode(uint256(2))));
    }

    // ---- Parity: native balance comparisons (v1 assertXxBalance) ----

    function test_parity_balance_family() public {
        vm.deal(TEST_EOA, 5 ether);
        // Eq / Ge / Le as plain constraints
        assertions.assertParam(_bal(address(0), TEST_EOA, _c1(ConstraintType.EQ, abi.encode(uint256(5 ether)))));
        assertions.assertParam(_bal(address(0), TEST_EOA, _c1(ConstraintType.GTE, abi.encode(uint256(5 ether)))));
        assertions.assertParam(_bal(address(0), TEST_EOA, _c1(ConstraintType.LTE, abi.encode(uint256(5 ether)))));
        // strict Gt / Lt via read-spliced operators over a BALANCE operand
        _assertHolds(_read2(GT_U, _bal(address(0), TEST_EOA, _none()), _lit(4 ether)));
        _assertHolds(_read2(LT_U, _bal(address(0), TEST_EOA, _none()), _lit(6 ether)));
        _expectHoldsFail();
        _assertHolds(_read2(GT_U, _bal(address(0), TEST_EOA, _none()), _lit(5 ether)));
    }

    // ---- Parity: block environment (v1 assertXxBlockNumber/Timestamp, ChainId) ----

    function test_parity_blockTimestamp_family() public {
        vm.warp(1_900_000_000);
        bytes memory ts = abi.encodeCall(Operators.timestamp, ());
        assertions.assertParam(_opsExpr(ts, ConstraintType.EQ, abi.encode(uint256(1_900_000_000))));
        assertions.assertParam(_opsExpr(ts, ConstraintType.GTE, abi.encode(uint256(1_899_999_999))));
        assertions.assertParam(_opsExpr(ts, ConstraintType.LTE, abi.encode(uint256(1_900_000_001))));
        // strict
        _assertHolds(_read2(GT_U, _op(address(ops), ts), _lit(1_899_999_999)));
        _expectParamFail(ConstraintType.EQ, bytes32(uint256(1_900_000_000)), abi.encode(uint256(1_900_000_001)));
        assertions.assertParam(_opsExpr(ts, ConstraintType.EQ, abi.encode(uint256(1_900_000_001))));
    }

    function test_parity_blockNumber_family() public {
        vm.roll(21_000_000);
        bytes memory bn = abi.encodeCall(Operators.blockNumber, ());
        assertions.assertParam(_opsExpr(bn, ConstraintType.EQ, abi.encode(uint256(21_000_000))));
        assertions.assertParam(_opsExpr(bn, ConstraintType.IN, abi.encode(uint256(20_000_000), uint256(22_000_000))));
        _expectParamFail(ConstraintType.GTE, bytes32(uint256(21_000_000)), abi.encode(uint256(21_000_001)));
        assertions.assertParam(_opsExpr(bn, ConstraintType.GTE, abi.encode(uint256(21_000_001))));
    }

    function test_parity_chainId() public {
        bytes memory cid = abi.encodeCall(Operators.chainId, ());
        assertions.assertParam(_opsExpr(cid, ConstraintType.EQ, abi.encode(block.chainid)));
        _expectParamFail(ConstraintType.EQ, bytes32(block.chainid), abi.encode(block.chainid + 1));
        assertions.assertParam(_opsExpr(cid, ConstraintType.EQ, abi.encode(block.chainid + 1)));
    }

    // ---- Parity: code checks (v1 assertEqCodeHash, assertHasCode, assertNoCode) ----

    function _codeHashExpr(address account) internal pure returns (bytes memory) {
        return abi.encodeCall(Operators.codeHash, (account));
    }

    /**
     * @dev hasCode(a) := codeHash != 0 && codeHash != keccak256("")
     */
    function _hasCodeExpr(address account) internal view returns (bytes memory) {
        InputParam memory hashOp = _op(address(ops), _codeHashExpr(account));
        bytes memory neZero = _read2(NE_U, hashOp, _raw(abi.encode(bytes32(0)), _none()));
        bytes memory neEmpty = _read2(NE_U, hashOp, _raw(abi.encode(keccak256("")), _none()));
        return _read2(Operators.bitAnd.selector, _op(address(assertions), neZero), _op(address(assertions), neEmpty));
    }

    function test_parity_eqCodeHash() public {
        assertions.assertParam(_opsExpr(_codeHashExpr(address(target)), ConstraintType.EQ, abi.encode(address(target).codehash)));
        _expectParamFail(ConstraintType.EQ, address(target).codehash, abi.encode(keccak256("")));
        assertions.assertParam(_opsExpr(_codeHashExpr(address(target)), ConstraintType.EQ, abi.encode(keccak256(""))));
    }

    function test_parity_hasCode() public {
        _assertHolds(_hasCodeExpr(address(target)));
        _expectHoldsFail();
        _assertHolds(_hasCodeExpr(TEST_EOA));
    }

    function test_parity_noCode() public {
        // noCode(a) := codeHash == 0 || codeHash == keccak256("")
        vm.deal(TEST_EOA, 1 wei); // funded EOA: codehash == keccak256("")
        InputParam memory eoaHash = _op(address(ops), _codeHashExpr(TEST_EOA));
        bytes memory eqZero = _read2(EQ_U, eoaHash, _raw(abi.encode(bytes32(0)), _none()));
        bytes memory eqEmpty = _read2(EQ_U, eoaHash, _raw(abi.encode(keccak256("")), _none()));
        _assertHolds(_read2(Operators.bitOr.selector, _op(address(assertions), eqZero), _op(address(assertions), eqEmpty)));

        // a contract fails the same expression
        InputParam memory contractHash = _op(address(ops), _codeHashExpr(address(target)));
        bytes memory cEqZero = _read2(EQ_U, contractHash, _raw(abi.encode(bytes32(0)), _none()));
        bytes memory cEqEmpty = _read2(EQ_U, contractHash, _raw(abi.encode(keccak256("")), _none()));
        _expectHoldsFail();
        _assertHolds(_read2(Operators.bitOr.selector, _op(address(assertions), cEqZero), _op(address(assertions), cEqEmpty)));
    }

    // ---- Parity: call failures ----

    function test_parity_callFailed_nonExistentFunction() public {
        bytes memory callData = abi.encodeWithSignature("doesNotExist()");
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), callData));
        assertions.assertParam(_call(address(target), callData, _none()));
    }

    // ════════════ Runtime-resolved call arguments ════════════
    //
    // The EVMcrispr-style composition  $c::balanceOf($d::token())  — a call
    // whose ARGUMENT (not target) is resolved on-chain at execution time.

    /**
     * @dev The byte offset of the first occurrence of `word` in `haystack`
     */
    function _find(bytes memory haystack, bytes32 word) internal pure returns (uint256) {
        for (uint256 i = 0; i + 32 <= haystack.length; i++) {
            bytes32 candidate;
            assembly {
                candidate := mload(add(add(haystack, 32), i))
            }
            if (candidate == word) return i;
        }
        revert("placeholder not found");
    }

    function _sliceBytes(bytes memory b, uint256 start, uint256 end) internal pure returns (bytes memory out) {
        out = new bytes(end - start);
        for (uint256 i = 0; i < out.length; i++) {
            out[i] = b[start + i];
        }
    }

    function _params4(
        InputParam memory a,
        InputParam memory b,
        InputParam memory c,
        InputParam memory d
    ) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](4);
        ps[0] = a;
        ps[1] = b;
        ps[2] = c;
        ps[3] = d;
    }

    function test_runtimeArg_constructedCall() public view {
        // token.balanceOf(target.token()): the argument is fetched live and
        // spliced into the calldata after the selector. The entry asserts
        // the constructed call succeeds; the argument itself can carry
        // constraints (here: the resolved token address must be non-zero).
        InputParam memory runtimeArg = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(target), abi.encodeCall(MockTarget.token, ())),
            _c1(ConstraintType.GTE, abi.encode(uint256(1)))
        );
        assertions.assertComposable(
            _batch1(_entry(MockToken.balanceOf.selector, _params2(_target(address(token)), runtimeArg)))
        );
    }

    function test_runtimeArg_judgedResult_viaSplicedInnerAssert() public {
        // Judge the RESULT of token.balanceOf(target.token()) against a
        // constraint. Calldata construction is byte-level concatenation, so
        // the entry builds a call to assertions.assertParam(...) itself,
        // splicing the runtime-resolved token address into the pre-encoded
        // inner parameter: RAW(prefix) ++ STATIC_CALL(target.token()) ++
        // RAW(suffix). The entry call then succeeds iff the inner
        // constraint holds — assertions judging assertions.
        address placeholder = address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa);
        InputParam memory inner = _call(
            address(token),
            abi.encodeCall(MockToken.balanceOf, (placeholder)),
            _c1(ConstraintType.GTE, abi.encode(uint256(1000)))
        );
        bytes memory body = abi.encode(inner); // assertParam's argument encoding
        uint256 pos = _find(body, bytes32(uint256(uint160(placeholder))));
        bytes4 assertParamSelector = bytes4(keccak256("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))"));

        InputParam memory runtimeWord = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(target), abi.encodeCall(MockTarget.token, ())),
            _none()
        );
        ComposableExecution[] memory ex = _batch1(
            _entry(
                assertParamSelector,
                _params4(
                    _target(address(assertions)),
                    _raw(_sliceBytes(body, 0, pos), _none()),
                    runtimeWord,
                    _raw(_sliceBytes(body, pos + 32, body.length), _none())
                )
            )
        );
        // balanceOf(token()) = 1000, inner GTE(1000) holds
        assertions.assertComposable(ex);

        // raise the inner bound: the spliced assertion fails, so the
        // constructed entry call fails with the fully reassembled calldata
        inner.constraints[0].referenceData = abi.encode(uint256(1001));
        bytes memory failBody = abi.encode(inner);
        ex[0].inputParams[1].paramData = _sliceBytes(failBody, 0, pos);
        ex[0].inputParams[3].paramData = _sliceBytes(failBody, pos + 32, failBody.length);
        bytes memory rebuilt = bytes.concat(
            assertParamSelector,
            _sliceBytes(failBody, 0, pos),
            abi.encode(address(token)),
            _sliceBytes(failBody, pos + 32, failBody.length)
        );
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(assertions), rebuilt));
        assertions.assertComposable(ex);
    }
}
