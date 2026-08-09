// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Combinators.sol";
import "../ERC8211.sol";
import "./Mocks.sol";

/// @notice Combinator composition tests. Every operand is an ERC-8211
///         InputParam; wherever it mirrors real usage, a value computed by
///         Combinators is judged THROUGH the core by pointing a constrained
///         STATIC_CALL parameter at the Combinators address.
contract CombinatorsTest is Test {
    Assertions public assertions;
    Combinators public combinators;
    MockTarget public target;
    MockToken public token;
    MockToken public underlyingToken;

    address constant TEST_EOA = address(0x1234);

    function setUp() public {
        assertions = new Assertions();
        combinators = new Combinators();
        target = new MockTarget();
        underlyingToken = new MockToken(address(0), "DAI");
        token = new MockToken(address(underlyingToken), "WETH");
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

    /// @dev A RAW_BYTES operand carrying a literal word
    function _lit(uint256 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    /// @dev A RAW_BYTES operand carrying a signed literal word
    function _slit(int256 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    /// @dev A STATIC_CALL operand
    function _call(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }

    /// @dev A STATIC_CALL operand targeting the combinators themselves (nesting)
    function _nested(bytes memory d) internal view returns (InputParam memory) {
        return _call(address(combinators), d);
    }

    /// @dev A BALANCE operand
    function _bal(address tok, address account) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.BALANCE, abi.encodePacked(tok, account), _none());
    }

    function _calls1(bytes memory a) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](1);
        calls[0] = a;
    }

    function _calls2(bytes memory a, bytes memory b) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](2);
        calls[0] = a;
        calls[1] = b;
    }

    function _args1(InputParam memory a) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](1);
        ps[0] = a;
    }

    function _args2(InputParam memory a, InputParam memory b) internal pure returns (InputParam[] memory ps) {
        ps = new InputParam[](2);
        ps[0] = a;
        ps[1] = b;
    }

    // ============ Resolve ============

    function test_resolve_rawBytes_passthrough() public view {
        bytes memory payload = hex"c0ffee";
        InputParam memory p = InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, payload, _none());
        (bool ok, bytes memory ret) = address(combinators).staticcall(abi.encodeCall(Combinators.resolve, (p)));
        assertTrue(ok);
        assertEq(ret, payload);
    }

    function test_resolve_staticCall_passthrough() public view {
        // resolving through the combinators is byte-identical to calling directly
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.resolve, (_call(address(target), abi.encodeCall(MockTarget.getString, ()))))
        );
        assertTrue(ok);
        assertEq(ret, abi.encode("hello"));
    }

    function test_resolve_balance() public view {
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.resolve, (_bal(address(token), TEST_EOA)))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1000);
    }

    function test_resolve_constraint_holds_and_reverts() public {
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        p.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1)));
        (bool ok, ) = address(combinators).staticcall(abi.encodeCall(Combinators.resolve, (p)));
        assertTrue(ok);

        p.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1000)));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "",
                0,
                0,
                0,
                ConstraintType.GTE,
                bytes32(uint256(42)),
                abi.encode(uint256(1000))
            )
        );
        combinators.resolve(p);
    }

    // ============ Pick ============

    function test_pick_multiValueReturn() public view {
        InputParam memory reserves = _call(address(token), abi.encodeCall(MockToken.getReserves, ()));
        assertEq(combinators.pick(reserves, 0), bytes32(uint256(5000e18)));
        assertEq(combinators.pick(reserves, 1), bytes32(uint256(1000e18)));
        assertEq(combinators.pick(reserves, -1), bytes32(uint256(123456)));
    }

    function test_pick_arrayWords() public view {
        // single dynamic array return: word 0 = head offset, word 1 = length, words 2+i = elements
        InputParam memory arr = _call(address(target), abi.encodeCall(MockTarget.getArray, ()));
        assertEq(combinators.pick(arr, 1), bytes32(uint256(5)));
        assertEq(combinators.pick(arr, 2), bytes32(uint256(10)));
        assertEq(combinators.pick(arr, -1), bytes32(uint256(50)));
    }

    function test_pick_outOfBounds() public {
        InputParam memory reserves = _call(address(token), abi.encodeCall(MockToken.getReserves, ()));
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 3, 96));
        combinators.pick(reserves, 3);
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, -4, 96));
        combinators.pick(reserves, -4);
    }

    // ============ Nav ============

    function _path1(int256 a) internal pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = a;
    }

    function _path2(int256 a, int256 b) internal pure returns (int256[] memory p) {
        p = new int256[](2);
        p[0] = a;
        p[1] = b;
    }

    function _path3(int256 a, int256 b, int256 c) internal pure returns (int256[] memory p) {
        p = new int256[](3);
        p[0] = a;
        p[1] = b;
        p[2] = c;
    }

    /// @dev Raw staticcall into nav (its result comes via assembly return)
    function _nav(InputParam memory p, string memory t, int256[] memory path)
        internal
        view
        returns (bool ok, bytes memory ret)
    {
        (ok, ret) = address(combinators).staticcall(abi.encodeCall(Combinators.nav, (p, t, path)));
    }

    function test_nav_emptyPath_passthrough() public view {
        (bool ok, bytes memory ret) = _nav(
            _call(address(target), abi.encodeCall(MockTarget.getTuple, ())),
            "(uint256,address,bool,bytes32)",
            new int256[](0)
        );
        assertTrue(ok);
        assertEq(ret, abi.encode(uint256(42), address(0xBEEF), true, keccak256("test")));
    }

    function test_nav_tupleWord() public view {
        (bool ok, bytes memory ret) = _nav(
            _call(address(target), abi.encodeCall(MockTarget.getTuple, ())),
            "(uint256,address,bool,bytes32)",
            _path1(1)
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xBEEF));
    }

    function test_nav_dynamicArrayElement() public view {
        // (address[],address): the trailing owner word and live-indexed elements
        InputParam memory signers = _call(address(token), abi.encodeCall(MockToken.signers, ()));
        (bool ok, bytes memory ret) = _nav(signers, "(address[],address)", _path1(1));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xb055));

        (ok, ret) = _nav(signers, "(address[],address)", _path2(0, 1));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xaaa2));

        (ok, ret) = _nav(signers, "(address[],address)", _path2(0, -1));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xaaa3));
    }

    function test_nav_nestedDynamicArrays() public view {
        // address[][] elements sit behind runtime offsets in both dimensions
        InputParam memory matrix = _call(address(token), abi.encodeCall(MockToken.matrix, ()));
        (bool ok, bytes memory ret) = _nav(matrix, "(address[][])", _path3(0, 1, 2));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xbbb3));

        (ok, ret) = _nav(matrix, "(address[][])", _path3(0, -2, 0));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xbbb1));
    }

    function test_nav_dynamicRowEnvelope() public view {
        // selecting a whole address[] row returns the canonical single-value envelope
        InputParam memory matrix = _call(address(token), abi.encodeCall(MockToken.matrix, ()));
        (bool ok, bytes memory ret) = _nav(matrix, "(address[][])", _path2(0, 1));
        assertTrue(ok);
        address[] memory row = abi.decode(ret, (address[]));
        assertEq(row.length, 3);
        assertEq(row[0], address(0xbbb1));
        assertEq(row[2], address(0xbbb3));

        address[] memory expected = new address[](3);
        expected[0] = address(0xbbb1);
        expected[1] = address(0xbbb2);
        expected[2] = address(0xbbb3);
        assertEq(ret, abi.encode(expected));
    }

    function test_nav_ownersMatrix_lensShapes() public view {
        // the "(address,address[][])" lens shapes: [_ [_ $]] = path [1,1]
        // (a whole address[] row) and [_ [_ [$]]] = path [1,1,0] (a word)
        InputParam memory p = _call(address(token), abi.encodeCall(MockToken.ownersMatrix, ()));
        (bool ok, bytes memory ret) = _nav(p, "(address,address[][])", _path2(1, 1));
        assertTrue(ok);
        address[] memory row = abi.decode(ret, (address[]));
        assertEq(row.length, 2);
        assertEq(row[0], address(0xbbb1));
        assertEq(row[1], address(0xbbb2));

        (ok, ret) = _nav(p, "(address,address[][])", _path3(1, 1, 0));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xbbb1));
    }

    function test_nav_structArraySteps() public view {
        InputParam memory props = _call(address(token), abi.encodeCall(MockToken.proposals, ()));
        (bool ok, bytes memory ret) = _nav(props, "((address,uint256,bool)[])", _path3(0, 1, 1));
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 99);

        (ok, ret) = _nav(props, "((address,uint256,bool)[])", _path3(0, 0, 2));
        assertTrue(ok);
        assertEq(abi.decode(ret, (bool)), false);
    }

    function test_nav_multiWordStaticHeads() public view {
        // (uint256[2],address[]): the fixed pair occupies two head words
        InputParam memory p = _call(address(token), abi.encodeCall(MockToken.mixed, ()));
        (bool ok, bytes memory ret) = _nav(p, "(uint256[2],address[])", _path2(0, 1));
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 22);

        (ok, ret) = _nav(p, "(uint256[2],address[])", _path2(1, 0));
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(0xddd1));
    }

    function test_nav_stringTerminal() public view {
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getTupleWithString, ()));
        (bool ok, bytes memory ret) = _nav(p, "(uint256,string,address)", _path1(1));
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "hello");
        assertEq(ret, abi.encode("hello"));

        // a string field inside a struct array
        InputParam memory items = _call(address(token), abi.encodeCall(MockToken.items, ()));
        (ok, ret) = _nav(items, "((string,uint256)[])", _path3(0, 1, 0));
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "Gauge Deposit");
    }

    function test_nav_lenSentinel() public view {
        InputParam memory arr = _call(address(target), abi.encodeCall(MockTarget.getArray, ()));
        int256[] memory path = _path2(0, combinators.LEN());
        (bool ok, bytes memory ret) = _nav(arr, "(uint256[])", path);
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 5);

        // byte length of a navigated string
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getTupleWithString, ()));
        (ok, ret) = _nav(p, "(uint256,string,address)", _path2(1, combinators.LEN()));
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 5);
    }

    function test_nav_indexOutOfBounds() public {
        InputParam memory signers = _call(address(token), abi.encodeCall(MockToken.signers, ()));
        vm.expectRevert(abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, 3, 3));
        combinators.nav(signers, "(address[],address)", _path2(0, 3));
        vm.expectRevert(abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, -4, 3));
        combinators.nav(signers, "(address[],address)", _path2(0, -4));
        vm.expectRevert(abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, 2, 2));
        combinators.nav(signers, "(address[],address)", _path1(2));
    }

    function test_nav_invalidSteps() public {
        // stepping into a base word
        InputParam memory tuple = _call(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, 1));
        combinators.nav(tuple, "(uint256,address,bool,bytes32)", _path2(0, 0));

        // a dynamic tuple terminal is not extractable as a single envelope
        InputParam memory items = _call(address(token), abi.encodeCall(MockToken.items, ()));
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, 1));
        combinators.nav(items, "((string,uint256)[])", _path2(0, 0));

        // malformed descriptor: not a parenthesized tuple
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, 0));
        combinators.nav(tuple, "uint256", _path1(0));
    }

    function test_nav_operandFailure_identified() public {
        InputParam memory bad = _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()));
        vm.expectRevert(
            abi.encodeWithSelector(CallFailed.selector, address(target), abi.encodeCall(MockTarget.revertingFunction, ()))
        );
        combinators.nav(bad, "(uint256)", _path1(0));
    }

    function test_nav_judgedThroughCore() public {
        // real usage: the core judges a nav selection through a constrained
        // STATIC_CALL fetcher pointed at the combinators
        InputParam memory signers = _call(address(token), abi.encodeCall(MockToken.signers, ()));
        bytes memory navCalldata = abi.encodeCall(Combinators.nav, (signers, "(address[],address)", _path2(0, -1)));
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(combinators), navCalldata),
            _c1(ConstraintType.EQ, abi.encode(address(0xaaa3)))
        );
        assertions.assertParam(judged);

        judged.constraints = _c1(ConstraintType.EQ, abi.encode(address(0xdead)));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(uint160(address(0xaaa3)))),
                abi.encode(address(0xdead))
            )
        );
        assertions.assertParam(judged);
    }

    function test_nav_asCalcOperand() public view {
        // nav nests like any combinator: proposals[1].votes + 1 = 100
        InputParam memory props = _call(address(token), abi.encodeCall(MockToken.proposals, ()));
        InputParam memory votes = _nested(
            abi.encodeCall(Combinators.nav, (props, "((address,uint256,bool)[])", _path3(0, 1, 1)))
        );
        assertEq(combinators.calc(Combinators.CalcOp.Add, votes, _lit(1)), 100);
    }

    // ============ Chain ============

    function test_chain_twoHops() public view {
        // target.token() -> token.decimals(): the mid-hop address is runtime-resolved
        InputParam memory start = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(address(target)),
            _none()
        );
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(
                Combinators.chain,
                (start, _calls2(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ())))
            )
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 18);
    }

    function test_chain_singleHop_stringReturn() public view {
        InputParam memory start = _call(address(target), abi.encodeCall(MockTarget.token, ()));
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.chain, (start, _calls1(abi.encodeCall(MockToken.symbol, ()))))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "WETH");
    }

    function test_chain_emptyCalls() public {
        vm.expectRevert(Combinators.EmptyCallChain.selector);
        combinators.chain(_lit(uint256(uint160(address(target)))), new bytes[](0));
    }

    function test_chain_dirtyStartWord() public {
        bytes32 dirty = bytes32(uint256(1) << 200);
        InputParam memory start = InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(dirty), _none());
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        combinators.chain(start, _calls1(abi.encodeCall(MockTarget.getValue, ())));
    }

    function test_chain_midHopReverts() public {
        InputParam memory start = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(address(token)),
            _none()
        );
        bytes memory hop = abi.encodeCall(MockToken.revertingHop, ());
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(token), hop));
        combinators.chain(start, _calls2(hop, abi.encodeCall(MockToken.decimals, ())));
    }

    function test_chain_midHopEmptyReturn() public {
        InputParam memory start = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(address(token)),
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 0, 0));
        combinators.chain(start, _calls2(abi.encodeCall(MockToken.emptyReturn, ()), abi.encodeCall(MockToken.decimals, ())));
    }

    // ============ Invoke ============

    function test_invoke_literalTargetAndArg() public view {
        // checkValue(42) constructed at judge time from a literal word segment
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(
                Combinators.invoke,
                (_lit(uint256(uint160(address(target)))), MockTarget.checkValue.selector, _args1(_lit(42)))
            )
        );
        assertTrue(ok);
        assertEq(ret.length, 0);
    }

    function test_invoke_constructedCallReverts() public {
        bytes memory callData = bytes.concat(abi.encodePacked(MockTarget.checkValue.selector), abi.encode(uint256(41)));
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), callData));
        combinators.invoke(_lit(uint256(uint160(address(target)))), MockTarget.checkValue.selector, _args1(_lit(41)));
    }

    function test_invoke_computedArgs() public view {
        // checkPair(40 + 2, getAddress()): one calc segment, one live read segment
        InputParam memory computed = _nested(
            abi.encodeCall(Combinators.calc, (Combinators.CalcOp.Add, _lit(40), _lit(2)))
        );
        InputParam memory liveAddress = _call(address(target), abi.encodeCall(MockTarget.getAddress, ()));
        (bool ok, ) = address(combinators).staticcall(
            abi.encodeCall(
                Combinators.invoke,
                (_lit(uint256(uint160(address(target)))), MockTarget.checkPair.selector, _args2(computed, liveAddress))
            )
        );
        assertTrue(ok);
    }

    function test_invoke_runtimeTarget() public view {
        // balanceOf on whatever token target.token() reports — computed args
        // against a computed target, which chain alone cannot express
        InputParam memory tokenAddr = _call(address(target), abi.encodeCall(MockTarget.token, ()));
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(
                Combinators.invoke,
                (tokenAddr, MockToken.balanceOf.selector, _args1(_lit(uint256(uint160(TEST_EOA)))))
            )
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1000);
    }

    function test_invoke_emptyArgs_rawReturnPassthrough() public view {
        // selector-only call; the raw return is byte-identical to calling directly
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(
                Combinators.invoke,
                (_lit(uint256(uint160(address(token)))), MockToken.symbol.selector, new InputParam[](0))
            )
        );
        assertTrue(ok);
        assertEq(ret, abi.encode("WETH"));
    }

    function test_invoke_codelessTarget() public {
        bytes memory callData = abi.encodePacked(MockTarget.getValue.selector);
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, TEST_EOA, callData));
        combinators.invoke(_lit(uint256(uint160(TEST_EOA))), MockTarget.getValue.selector, new InputParam[](0));
    }

    function test_invoke_dirtyTargetWord() public {
        bytes32 dirty = bytes32(uint256(1) << 200);
        InputParam memory targetParam = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(dirty),
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        combinators.invoke(targetParam, MockTarget.getValue.selector, new InputParam[](0));
    }

    function test_invoke_argConstraint_identifiesOperand() public {
        // a violated segment constraint names the arg as operand index + 1
        InputParam memory arg = _lit(42);
        arg.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1000)));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "",
                0,
                1,
                0,
                ConstraintType.GTE,
                bytes32(uint256(42)),
                abi.encode(uint256(1000))
            )
        );
        combinators.invoke(_lit(uint256(uint160(address(target)))), MockTarget.checkValue.selector, _args1(arg));
    }

    // ============ Calc: arithmetic ============

    function test_calc_add() public view {
        // live value + literal: getValue() + 8 = 50
        assertEq(combinators.calc(Combinators.CalcOp.Add, _call(address(target), abi.encodeCall(MockTarget.getValue, ())), _lit(8)), 50);
    }

    function test_calc_add_overflow() public {
        vm.expectRevert(stdError.arithmeticError);
        combinators.calc(Combinators.CalcOp.Add, _call(address(token), abi.encodeCall(MockToken.maxUint, ())), _lit(1));
    }

    function test_calc_sadd_negative() public view {
        // temperature() + 10 = 3
        assertEq(combinators.calc(Combinators.CalcOp.SAdd, _call(address(token), abi.encodeCall(MockToken.temperature, ())), _slit(10)), 3);
    }

    function test_calc_sub_and_underflow() public {
        assertEq(combinators.calc(Combinators.CalcOp.Sub, _lit(50), _lit(8)), 42);
        vm.expectRevert(stdError.arithmeticError);
        combinators.calc(Combinators.CalcOp.Sub, _lit(8), _lit(50));
    }

    function test_calc_ssub() public view {
        assertEq(int256(combinators.calc(Combinators.CalcOp.SSub, _slit(-7), _slit(3))), -10);
    }

    function test_calc_mul_div_mod() public {
        assertEq(combinators.calc(Combinators.CalcOp.Mul, _lit(6), _lit(7)), 42);
        assertEq(combinators.calc(Combinators.CalcOp.Div, _lit(85), _lit(2)), 42);
        assertEq(combinators.calc(Combinators.CalcOp.Mod, _lit(87), _lit(5)), 2);
        vm.expectRevert(stdError.divisionError);
        combinators.calc(Combinators.CalcOp.Div, _lit(1), _lit(0));
    }

    function test_calc_sdiv_smod() public view {
        assertEq(int256(combinators.calc(Combinators.CalcOp.SDiv, _slit(-42), _slit(5))), -8);
        assertEq(int256(combinators.calc(Combinators.CalcOp.SMod, _slit(-42), _slit(5))), -2);
    }

    function test_calc_exp_decimalsScaling() public view {
        // 5 * 10 ** token.decimals(): the canonical live-scaling expression, nested
        uint256 scale = combinators.calc(
            Combinators.CalcOp.Exp,
            _lit(10),
            _call(address(token), abi.encodeCall(MockToken.decimals, ()))
        );
        assertEq(scale, 1e18);
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Mul,
                _lit(5),
                _nested(abi.encodeCall(Combinators.calc, (Combinators.CalcOp.Exp, _lit(10), _call(address(token), abi.encodeCall(MockToken.decimals, ())))))
            ),
            5e18
        );
    }

    function test_calc_exp_zeroZero() public view {
        assertEq(combinators.calc(Combinators.CalcOp.Exp, _lit(0), _lit(0)), 1);
    }

    function test_calc_minMax() public view {
        assertEq(combinators.calc(Combinators.CalcOp.Min, _lit(3), _lit(9)), 3);
        assertEq(combinators.calc(Combinators.CalcOp.Max, _lit(3), _lit(9)), 9);
        // unsigned Min sees -1 as huge; SMin orders it correctly
        assertEq(combinators.calc(Combinators.CalcOp.Min, _slit(-1), _lit(9)), 9);
        assertEq(int256(combinators.calc(Combinators.CalcOp.SMin, _slit(-1), _lit(9))), -1);
        assertEq(combinators.calc(Combinators.CalcOp.SMax, _slit(-1), _lit(9)), 9);
    }

    function test_calc_absDiff() public view {
        assertEq(combinators.calc(Combinators.CalcOp.AbsDiff, _lit(3), _lit(9)), 6);
        assertEq(combinators.calc(Combinators.CalcOp.AbsDiff, _lit(9), _lit(3)), 6);
        assertEq(combinators.calc(Combinators.CalcOp.SAbsDiff, _slit(-42), _slit(7)), 49);
        // the widest span is total, not a revert
        assertEq(
            combinators.calc(Combinators.CalcOp.SAbsDiff, _slit(type(int256).min), _slit(type(int256).max)),
            type(uint256).max
        );
    }

    // ============ Calc: bitwise, shifts, comparisons ============

    function test_calc_bitwise() public view {
        assertEq(combinators.calc(Combinators.CalcOp.And, _lit(0xF0F0), _lit(0xFF00)), 0xF000);
        assertEq(combinators.calc(Combinators.CalcOp.Or, _lit(0xF0F0), _lit(0x0F00)), 0xFFF0);
        assertEq(combinators.calc(Combinators.CalcOp.Xor, _lit(0xFF), _lit(0x0F)), 0xF0);
    }

    function test_calc_shifts() public view {
        assertEq(combinators.calc(Combinators.CalcOp.Shl, _lit(1), _lit(4)), 16);
        assertEq(combinators.calc(Combinators.CalcOp.Shr, _lit(256), _lit(4)), 16);
        // EVM semantics: shifting by >= 256 yields 0, no revert
        assertEq(combinators.calc(Combinators.CalcOp.Shl, _lit(1), _lit(256)), 0);
        assertEq(combinators.calc(Combinators.CalcOp.Shr, _lit(1), _lit(300)), 0);
    }

    function test_calc_comparisons() public view {
        assertEq(combinators.calc(Combinators.CalcOp.Eq, _lit(42), _lit(42)), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Ne, _lit(42), _lit(42)), 0);
        assertEq(combinators.calc(Combinators.CalcOp.Lt, _lit(3), _lit(9)), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Gt, _lit(3), _lit(9)), 0);
        assertEq(combinators.calc(Combinators.CalcOp.Le, _lit(9), _lit(9)), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Ge, _lit(8), _lit(9)), 0);
        // signed variants order negative operands correctly
        assertEq(combinators.calc(Combinators.CalcOp.Lt, _slit(-1), _lit(9)), 0);
        assertEq(combinators.calc(Combinators.CalcOp.SLt, _slit(-1), _lit(9)), 1);
        assertEq(combinators.calc(Combinators.CalcOp.SGt, _slit(-1), _lit(9)), 0);
        assertEq(combinators.calc(Combinators.CalcOp.SLe, _slit(-9), _slit(-9)), 1);
        assertEq(combinators.calc(Combinators.CalcOp.SGe, _slit(-9), _slit(-8)), 0);
    }

    function test_calc_booleanComposition() public view {
        // active() AND NOT paused(), as nested 0/1 words
        uint256 result = combinators.calc(
            Combinators.CalcOp.And,
            _call(address(token), abi.encodeCall(MockToken.active, ())),
            _nested(abi.encodeCall(Combinators.unary, (Combinators.UnaryOp.IsZero, _call(address(token), abi.encodeCall(MockToken.paused, ())))))
        );
        assertEq(result, 1);
    }

    // ============ Calc: operand failures ============

    function test_calc_operandReverts() public {
        bytes memory callData = abi.encodeCall(MockTarget.revertingFunction, ());
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), callData));
        combinators.calc(Combinators.CalcOp.Add, _call(address(target), callData), _lit(1));
    }

    function test_calc_operandShortReturn() public {
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 0, 0));
        combinators.calc(Combinators.CalcOp.Add, _call(address(token), abi.encodeCall(MockToken.emptyReturn, ())), _lit(1));
    }

    function test_calc_operandConstraint_identifiesOperand() public {
        InputParam memory b = _lit(8);
        b.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(10)));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "",
                0,
                1, // second operand
                0,
                ConstraintType.GTE,
                bytes32(uint256(8)),
                abi.encode(uint256(10))
            )
        );
        combinators.calc(Combinators.CalcOp.Add, _lit(1), b);
    }

    // ============ Unary ============

    function test_unary_not() public view {
        assertEq(combinators.unary(Combinators.UnaryOp.Not, _lit(0)), type(uint256).max);
    }

    function test_unary_isZero() public view {
        assertEq(combinators.unary(Combinators.UnaryOp.IsZero, _call(address(token), abi.encodeCall(MockToken.paused, ()))), 1);
        assertEq(combinators.unary(Combinators.UnaryOp.IsZero, _call(address(token), abi.encodeCall(MockToken.active, ()))), 0);
    }

    function test_unary_balance() public {
        vm.deal(TEST_EOA, 3 ether);
        assertEq(combinators.unary(Combinators.UnaryOp.Balance, _lit(uint256(uint160(TEST_EOA)))), 3 ether);
    }

    function test_unary_codeHash() public view {
        // the underlying() address is runtime-resolved, then hashed
        uint256 hash = combinators.unary(Combinators.UnaryOp.CodeHash, _call(address(token), abi.encodeCall(MockToken.underlying, ())));
        assertEq(bytes32(hash), address(underlyingToken).codehash);
    }

    function test_unary_dirtyAddressWord() public {
        bytes32 dirty = bytes32(uint256(1) << 180);
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        combinators.unary(Combinators.UnaryOp.Balance, _lit(uint256(dirty)));
    }

    // ============ Env ============

    function test_env_constant() public view {
        assertEq(combinators.env(Combinators.EnvOp.Constant, 42), 42);
        assertEq(int256(combinators.env(Combinators.EnvOp.Constant, uint256(int256(-42)))), -42);
    }

    function test_env_blockValues() public {
        vm.warp(1_900_000_000);
        vm.roll(21_000_000);
        assertEq(combinators.env(Combinators.EnvOp.Timestamp, 0), 1_900_000_000);
        assertEq(combinators.env(Combinators.EnvOp.BlockNumber, 0), 21_000_000);
        assertEq(combinators.env(Combinators.EnvOp.ChainId, 0), block.chainid);
    }

    function test_env_balance_and_codeHash() public {
        vm.deal(TEST_EOA, 2 ether);
        assertEq(combinators.env(Combinators.EnvOp.Balance, uint256(uint160(TEST_EOA))), 2 ether);
        assertEq(bytes32(combinators.env(Combinators.EnvOp.CodeHash, uint256(uint160(address(token))))), address(token).codehash);
    }

    function test_env_dirtyAddressArg() public {
        uint256 dirty = uint256(1) << 170;
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, bytes32(dirty)));
        combinators.env(Combinators.EnvOp.Balance, dirty);
    }

    // ============ Data ============

    function test_data_hash() public view {
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Hash, _call(address(target), abi.encodeCall(MockTarget.getString, ())), "", 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (bytes32)), keccak256(abi.encode("hello")));
    }

    function test_data_byteLen() public view {
        // uint256[] with 5 items: offset word + length word + 5 items = 224 bytes
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.ByteLen, _call(address(target), abi.encodeCall(MockTarget.getArray, ())), "", 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 224);
    }

    function test_data_split() public view {
        InputParam memory name = _call(address(token), abi.encodeCall(MockToken.name, ()));
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Split, name, " ", 1))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "LP");

        (ok, ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Split, name, " ", -1))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "Token");
    }

    function test_data_split_errors() public {
        InputParam memory name = _call(address(token), abi.encodeCall(MockToken.name, ()));
        vm.expectRevert(Combinators.EmptyDelimiter.selector);
        combinators.data(Combinators.DataOp.Split, name, "", 0);
        vm.expectRevert(abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, 3, 3));
        combinators.data(Combinators.DataOp.Split, name, " ", 3);
        vm.expectRevert(abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, -4, 3));
        combinators.data(Combinators.DataOp.Split, name, " ", -4);
    }

    function test_data_includes() public {
        InputParam memory name = _call(address(token), abi.encodeCall(MockToken.name, ()));
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Includes, name, "LP", 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1);

        (ok, ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Includes, name, "xyz", 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 0);

        vm.expectRevert(Combinators.EmptySubstring.selector);
        combinators.data(Combinators.DataOp.Includes, name, "", 0);
    }

    function test_data_charset() public {
        // lowercase a-z mask: bits 97..122
        uint256 mask;
        for (uint256 i = 97; i <= 122; i++) {
            mask |= 1 << i;
        }
        InputParam memory hello = _call(address(target), abi.encodeCall(MockTarget.getString, ()));
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Charset, hello, abi.encodePacked(bytes32(mask)), 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1);

        // "Curve LP Token" contains uppercase and spaces: fails the a-z mask
        InputParam memory name = _call(address(token), abi.encodeCall(MockToken.name, ()));
        (ok, ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Charset, name, abi.encodePacked(bytes32(mask)), 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 0);

        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidMaskLength.selector, 3));
        combinators.data(Combinators.DataOp.Charset, name, hex"c0ffee", 0);
    }

    function test_data_overChain_nesting() public view {
        // symbol of the runtime-resolved token: data(Includes) over a nested chain
        InputParam memory start = _call(address(target), abi.encodeCall(MockTarget.token, ()));
        InputParam memory chained = _nested(
            abi.encodeCall(Combinators.chain, (start, _calls1(abi.encodeCall(MockToken.symbol, ()))))
        );
        (bool ok, bytes memory ret) = address(combinators).staticcall(
            abi.encodeCall(Combinators.data, (Combinators.DataOp.Includes, chained, "WET", 0))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1);
    }

    // ============ Judged through the core ============

    function test_core_judges_calcExpression() public view {
        // assert whaleBalance() / 10^decimals() == 7, judged by the core
        bytes memory expression = abi.encodeCall(
            Combinators.calc,
            (
                Combinators.CalcOp.Div,
                _call(address(token), abi.encodeCall(MockToken.whaleBalance, ())),
                _nested(abi.encodeCall(Combinators.calc, (Combinators.CalcOp.Exp, _lit(10), _call(address(token), abi.encodeCall(MockToken.decimals, ())))))
            )
        );
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(combinators), expression),
            _c1(ConstraintType.EQ, abi.encode(uint256(7)))
        );
        assertions.assertParam(judged);
    }

    function test_core_judges_pickedReserve_inRange() public view {
        bytes memory expression = abi.encodeCall(
            Combinators.pick,
            (_call(address(token), abi.encodeCall(MockToken.getReserves, ())), int256(1))
        );
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(combinators), expression),
            _c1(ConstraintType.IN, abi.encode(uint256(500e18), uint256(2000e18)))
        );
        assertions.assertParam(judged);
    }

    function test_core_judges_failingExpression() public {
        bytes memory expression = abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 41));
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(combinators), expression),
            _c1(ConstraintType.EQ, abi.encode(uint256(42)))
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "not the answer",
                0,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(41)),
                abi.encode(uint256(42))
            )
        );
        assertions.assertParam(judged, "not the answer");
    }

    function test_core_judges_invokeExpression() public view {
        // assert token.balanceOf(TEST_EOA) >= 1000 where the token address is
        // runtime-resolved and the holder is a computed segment
        bytes memory expression = abi.encodeCall(
            Combinators.invoke,
            (
                _call(address(target), abi.encodeCall(MockTarget.token, ())),
                MockToken.balanceOf.selector,
                _args1(_lit(uint256(uint160(TEST_EOA))))
            )
        );
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(combinators), expression),
            _c1(ConstraintType.GTE, abi.encode(uint256(1000)))
        );
        assertions.assertParam(judged);
    }
}
