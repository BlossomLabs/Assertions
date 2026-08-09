// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operators.sol";
import "../ERC8211.sol";
import "../AbiShape.sol";
import "./Mocks.sol";

/**
 * @notice Core read-primitive tests: resolve, pick, nav, chain and read
 *         live on the frozen Assertions core and are exercised directly
 *         against it, including nesting expressions through the core
 *         itself (a STATIC_CALL operand may target the core's own
 *         primitives).
 */
contract CoreReadsTest is Test {
    Assertions public assertions;
    Operators public ops;
    MockTarget public target;
    MockToken public token;
    MockToken public underlyingToken;

    address constant TEST_EOA = address(0x1234);
    bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));

    function setUp() public {
        assertions = new Assertions();
        ops = new Operators();
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

    /**
     * @dev A RAW_BYTES operand carrying a literal word
     */
    function _lit(uint256 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    /**
     * @dev A STATIC_CALL operand
     */
    function _call(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }

    /**
     * @dev A STATIC_CALL operand targeting the core itself (self-nesting)
     */
    function _nested(bytes memory d) internal view returns (InputParam memory) {
        return _call(address(assertions), d);
    }

    /**
     * @dev A BALANCE operand
     */
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
        (bool ok, bytes memory ret) = address(assertions).staticcall(abi.encodeCall(Assertions.resolve, (p)));
        assertTrue(ok);
        assertEq(ret, payload);
    }

    function test_resolve_staticCall_passthrough() public view {
        // resolving through the core is byte-identical to calling directly
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(Assertions.resolve, (_call(address(target), abi.encodeCall(MockTarget.getString, ()))))
        );
        assertTrue(ok);
        assertEq(ret, abi.encode("hello"));
    }

    function test_resolve_balance() public view {
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(Assertions.resolve, (_bal(address(token), TEST_EOA)))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1000);
    }

    function test_resolve_constraint_holds_and_reverts() public {
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        p.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1)));
        (bool ok, ) = address(assertions).staticcall(abi.encodeCall(Assertions.resolve, (p)));
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
        assertions.resolve(p);
    }

    // ============ Pick ============

    function test_pick_multiValueReturn() public view {
        InputParam memory reserves = _call(address(token), abi.encodeCall(MockToken.getReserves, ()));
        assertEq(assertions.pick(reserves, 0), bytes32(uint256(5000e18)));
        assertEq(assertions.pick(reserves, 1), bytes32(uint256(1000e18)));
        assertEq(assertions.pick(reserves, -1), bytes32(uint256(123456)));
    }

    function test_pick_arrayWords() public view {
        // single dynamic array return: word 0 = head offset, word 1 = length, words 2+i = elements
        InputParam memory arr = _call(address(target), abi.encodeCall(MockTarget.getArray, ()));
        assertEq(assertions.pick(arr, 1), bytes32(uint256(5)));
        assertEq(assertions.pick(arr, 2), bytes32(uint256(10)));
        assertEq(assertions.pick(arr, -1), bytes32(uint256(50)));
    }

    function test_pick_outOfBounds() public {
        InputParam memory reserves = _call(address(token), abi.encodeCall(MockToken.getReserves, ()));
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 3, 96));
        assertions.pick(reserves, 3);
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, -4, 96));
        assertions.pick(reserves, -4);
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

    /**
     * @dev Raw staticcall into nav (its result comes via assembly return)
     */
    function _nav(InputParam memory p, string memory t, int256[] memory path)
        internal
        view
        returns (bool ok, bytes memory ret)
    {
        (ok, ret) = address(assertions).staticcall(abi.encodeCall(Assertions.nav, (p, t, path)));
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
        int256[] memory path = _path2(0, assertions.LEN());
        (bool ok, bytes memory ret) = _nav(arr, "(uint256[])", path);
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 5);

        // byte length of a navigated string
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.getTupleWithString, ()));
        (ok, ret) = _nav(p, "(uint256,string,address)", _path2(1, assertions.LEN()));
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 5);
    }

    function test_nav_indexOutOfBounds() public {
        InputParam memory signers = _call(address(token), abi.encodeCall(MockToken.signers, ()));
        vm.expectRevert(abi.encodeWithSelector(ElementIndexOutOfBounds.selector, 3, 3));
        assertions.nav(signers, "(address[],address)", _path2(0, 3));
        vm.expectRevert(abi.encodeWithSelector(ElementIndexOutOfBounds.selector, -4, 3));
        assertions.nav(signers, "(address[],address)", _path2(0, -4));
        vm.expectRevert(abi.encodeWithSelector(ElementIndexOutOfBounds.selector, 2, 2));
        assertions.nav(signers, "(address[],address)", _path1(2));
    }

    function test_nav_invalidSteps() public {
        // stepping into a base word
        InputParam memory tuple = _call(address(target), abi.encodeCall(MockTarget.getTuple, ()));
        vm.expectRevert(abi.encodeWithSelector(Assertions.InvalidNavigation.selector, 1));
        assertions.nav(tuple, "(uint256,address,bool,bytes32)", _path2(0, 0));

        // a dynamic tuple terminal is not extractable as a single envelope
        InputParam memory items = _call(address(token), abi.encodeCall(MockToken.items, ()));
        vm.expectRevert(abi.encodeWithSelector(Assertions.InvalidNavigation.selector, 1));
        assertions.nav(items, "((string,uint256)[])", _path2(0, 0));

        // malformed descriptor: not a parenthesized tuple
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, 0));
        assertions.nav(tuple, "uint256", _path1(0));
    }

    function test_nav_operandFailure_identified() public {
        InputParam memory bad = _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()));
        vm.expectRevert(
            abi.encodeWithSelector(CallFailed.selector, address(target), abi.encodeCall(MockTarget.revertingFunction, ()))
        );
        assertions.nav(bad, "(uint256)", _path1(0));
    }

    function test_nav_judgedThroughCore_selfNested() public {
        // real usage: the core judges a nav selection through a constrained
        // STATIC_CALL fetcher pointed at the core's own nav primitive
        InputParam memory signers = _call(address(token), abi.encodeCall(MockToken.signers, ()));
        bytes memory navCalldata = abi.encodeCall(Assertions.nav, (signers, "(address[],address)", _path2(0, -1)));
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), navCalldata),
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

    function test_nav_asReadOperand() public view {
        // a core nav nests as an operand of a read-spliced computation:
        // proposals[1].votes + 1 = 100
        InputParam memory props = _call(address(token), abi.encodeCall(MockToken.proposals, ()));
        InputParam memory votes = _nested(
            abi.encodeCall(Assertions.nav, (props, "((address,uint256,bool)[])", _path3(0, 1, 1)))
        );
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(Assertions.read, (_lit(uint256(uint160(address(ops)))), ADD_U, _args2(votes, _lit(1))))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 100);
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
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(
                Assertions.chain,
                (start, _calls2(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ())))
            )
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 18);
    }

    function test_chain_singleHop_stringReturn() public view {
        InputParam memory start = _call(address(target), abi.encodeCall(MockTarget.token, ()));
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(Assertions.chain, (start, _calls1(abi.encodeCall(MockToken.symbol, ()))))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "WETH");
    }

    function test_chain_emptyCalls() public {
        vm.expectRevert(Assertions.EmptyCallChain.selector);
        assertions.chain(_lit(uint256(uint160(address(target)))), new bytes[](0));
    }

    function test_chain_dirtyStartWord() public {
        bytes32 dirty = bytes32(uint256(1) << 200);
        InputParam memory start = InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(dirty), _none());
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        assertions.chain(start, _calls1(abi.encodeCall(MockTarget.getValue, ())));
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
        assertions.chain(start, _calls2(hop, abi.encodeCall(MockToken.decimals, ())));
    }

    function test_chain_midHopEmptyReturn() public {
        InputParam memory start = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(address(token)),
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 0, 0));
        assertions.chain(start, _calls2(abi.encodeCall(MockToken.emptyReturn, ()), abi.encodeCall(MockToken.decimals, ())));
    }

    // ============ Read ============

    function test_read_literalTargetAndArg() public view {
        // checkValue(42) constructed at judge time from a literal word segment
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(
                Assertions.read,
                (_lit(uint256(uint160(address(target)))), MockTarget.checkValue.selector, _args1(_lit(42)))
            )
        );
        assertTrue(ok);
        assertEq(ret.length, 0);
    }

    function test_read_constructedCallReverts() public {
        bytes memory callData = bytes.concat(abi.encodePacked(MockTarget.checkValue.selector), abi.encode(uint256(41)));
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), callData));
        assertions.read(_lit(uint256(uint160(address(target)))), MockTarget.checkValue.selector, _args1(_lit(41)));
    }

    function test_read_computedArgs() public view {
        // checkPair(40 + 2, getAddress()): one computed segment, one live read segment
        InputParam memory computed = _call(
            address(ops),
            abi.encodeWithSelector(ADD_U, uint256(40), uint256(2))
        );
        InputParam memory liveAddress = _call(address(target), abi.encodeCall(MockTarget.getAddress, ()));
        (bool ok, ) = address(assertions).staticcall(
            abi.encodeCall(
                Assertions.read,
                (_lit(uint256(uint160(address(target)))), MockTarget.checkPair.selector, _args2(computed, liveAddress))
            )
        );
        assertTrue(ok);
    }

    function test_read_runtimeTarget() public view {
        // balanceOf on whatever token target.token() reports — computed args
        // against a computed target, which chain alone cannot express
        InputParam memory tokenAddr = _call(address(target), abi.encodeCall(MockTarget.token, ()));
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(
                Assertions.read,
                (tokenAddr, MockToken.balanceOf.selector, _args1(_lit(uint256(uint160(TEST_EOA)))))
            )
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1000);
    }

    function test_read_emptyArgs_rawReturnPassthrough() public view {
        // selector-only call; the raw return is byte-identical to calling directly
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(
                Assertions.read,
                (_lit(uint256(uint160(address(token)))), MockToken.symbol.selector, new InputParam[](0))
            )
        );
        assertTrue(ok);
        assertEq(ret, abi.encode("WETH"));
    }

    function test_read_codelessTarget() public {
        bytes memory callData = abi.encodePacked(MockTarget.getValue.selector);
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, TEST_EOA, callData));
        assertions.read(_lit(uint256(uint160(TEST_EOA))), MockTarget.getValue.selector, new InputParam[](0));
    }

    function test_read_dirtyTargetWord() public {
        bytes32 dirty = bytes32(uint256(1) << 200);
        InputParam memory targetParam = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(dirty),
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        assertions.read(targetParam, MockTarget.getValue.selector, new InputParam[](0));
    }

    function test_read_argConstraint_identifiesOperand() public {
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
        assertions.read(_lit(uint256(uint160(address(target)))), MockTarget.checkValue.selector, _args1(arg));
    }

    // ============ Self-Nesting Through the Core ============

    function test_selfNesting_pickOverChain() public view {
        // pick(chain(target, [token(), getReserves()]), 1): a chain nested
        // as pick's operand through the core's own address
        InputParam memory start = _lit(uint256(uint160(address(target))));
        bytes memory chainCalldata = abi.encodeCall(
            Assertions.chain,
            (start, _calls2(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.getReserves, ())))
        );
        assertEq(assertions.pick(_nested(chainCalldata), 1), bytes32(uint256(1000e18)));
    }

    function test_selfNesting_readOverNav() public view {
        // read(balanceOf, [nav(signers, path [0,-1])]): the last signer's
        // balance, the nav selection spliced as the read's argument
        InputParam memory signers = _call(address(token), abi.encodeCall(MockToken.signers, ()));
        InputParam memory lastSigner = _nested(
            abi.encodeCall(Assertions.nav, (signers, "(address[],address)", _path2(0, -1)))
        );
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(
                Assertions.read,
                (_lit(uint256(uint160(address(token)))), MockToken.balanceOf.selector, _args1(lastSigner))
            )
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 1000);
    }

    function test_selfNesting_judgedResolveOverRead() public {
        // assertParam judges a read whose result routes through resolve —
        // three self-frames deep, constraints validated at the leaf
        InputParam memory tokenAddr = _call(address(target), abi.encodeCall(MockTarget.token, ()));
        bytes memory readCalldata = abi.encodeCall(
            Assertions.read,
            (tokenAddr, MockToken.decimals.selector, new InputParam[](0))
        );
        bytes memory resolveCalldata = abi.encodeCall(Assertions.resolve, (_nested(readCalldata)));
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), resolveCalldata),
            _c1(ConstraintType.EQ, abi.encode(uint256(18)))
        );
        assertions.assertParam(judged);
    }

    // ============ Cond ============

    /**
     * @dev Raw staticcall into cond (its result comes via assembly return)
     */
    function _cond(InputParam memory c, InputParam memory then_, InputParam memory else_)
        internal
        view
        returns (bool ok_, bytes memory ret)
    {
        (ok_, ret) = address(assertions).staticcall(abi.encodeCall(Assertions.cond, (c, then_, else_)));
    }

    function test_cond_true_selectsThen() public view {
        // live condition word: getValue() = 42 is truthy
        (bool ok_, bytes memory ret) = _cond(
            _call(address(target), abi.encodeCall(MockTarget.getValue, ())),
            _call(address(token), abi.encodeCall(MockToken.decimals, ())),
            _lit(7)
        );
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 18);
    }

    function test_cond_false_selectsElse() public view {
        (bool ok_, bytes memory ret) = _cond(_lit(0), _lit(5), _lit(7));
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 7);
    }

    function test_cond_losingBranchNeverResolved() public view {
        // the losing branch contains a reverting call — laziness means it never fires
        InputParam memory bomb = _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()));
        (bool ok_, bytes memory ret) = _cond(_lit(1), _lit(5), bomb);
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 5);

        (ok_, ret) = _cond(_lit(0), bomb, _lit(7));
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 7);
    }

    function test_cond_dynamicWinnerPassthrough() public view {
        // a string-returning winner passes through as the canonical envelope
        (bool ok_, bytes memory ret) = _cond(
            _lit(1),
            _call(address(target), abi.encodeCall(MockTarget.getString, ())),
            _lit(0)
        );
        assertTrue(ok_);
        assertEq(ret, abi.encode("hello"));
    }

    function test_cond_conditionConstraintValidated() public {
        // a violated condition constraint reverts the whole cond (operand 0)
        InputParam memory c = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        c.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1000)));
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
        assertions.cond(c, _lit(5), _lit(7));
    }

    function test_cond_winnerConstraintValidated() public {
        // the winning branch's constraints are live (operand 1 = then)
        InputParam memory then_ = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        then_.constraints = _c1(ConstraintType.EQ, abi.encode(uint256(41)));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "",
                0,
                1,
                0,
                ConstraintType.EQ,
                bytes32(uint256(42)),
                abi.encode(uint256(41))
            )
        );
        assertions.cond(_lit(1), then_, _lit(7));
    }

    function test_cond_shortConditionReverts() public {
        InputParam memory shortRaw = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            hex"c0",
            _none()
        );
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, 0, 1));
        assertions.cond(shortRaw, _lit(5), _lit(7));
    }

    // ============ OrElse ============

    /**
     * @dev Raw staticcall into orElse (its result comes via assembly return)
     */
    function _orElse(InputParam memory a, InputParam memory b)
        internal
        view
        returns (bool ok_, bytes memory ret)
    {
        (ok_, ret) = address(assertions).staticcall(abi.encodeCall(Assertions.orElse, (a, b)));
    }

    function test_orElse_successPassesThrough() public view {
        (bool ok_, bytes memory ret) = _orElse(
            _call(address(target), abi.encodeCall(MockTarget.getString, ())),
            _lit(0)
        );
        assertTrue(ok_);
        assertEq(ret, abi.encode("hello"));
    }

    function test_orElse_revertSelectsFallback() public view {
        (bool ok_, bytes memory ret) = _orElse(
            _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ())),
            _call(address(token), abi.encodeCall(MockToken.decimals, ()))
        );
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 18);
    }

    function test_orElse_codelessTargetSelectsFallback() public view {
        (bool ok_, bytes memory ret) = _orElse(
            _call(TEST_EOA, abi.encodeCall(MockTarget.getValue, ())),
            _lit(7)
        );
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 7);
    }

    function test_orElse_constraintViolationIsFailure() public view {
        // constraints double as guards: a violated constraint on the
        // attempt selects the fallback instead of reverting
        InputParam memory guarded = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        guarded.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1000)));
        (bool ok_, bytes memory ret) = _orElse(guarded, _lit(7));
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 7);
    }

    function test_orElse_fallbackFailurePropagates() public {
        bytes memory bombCalldata = abi.encodeCall(MockTarget.revertingFunction, ());
        InputParam memory bomb = _call(address(target), bombCalldata);
        vm.expectRevert(abi.encodeWithSelector(CallFailed.selector, address(target), bombCalldata));
        assertions.orElse(bomb, bomb);
    }

    function test_orElse_chainedFallbacks() public view {
        // orElse(fail, orElse(fail, 7)): fallbacks chain by self-nesting
        InputParam memory bomb = _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()));
        InputParam memory inner = _nested(abi.encodeCall(Assertions.orElse, (bomb, _lit(7))));
        (bool ok_, bytes memory ret) = _orElse(bomb, inner);
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 7);
    }

    // ============ Ok ============

    function test_ok_success() public view {
        assertEq(assertions.ok(_call(address(target), abi.encodeCall(MockTarget.getValue, ()))), 1);
    }

    function test_ok_revertingCall() public view {
        assertEq(assertions.ok(_call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()))), 0);
    }

    function test_ok_constraintViolation() public view {
        InputParam memory guarded = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        guarded.constraints = _c1(ConstraintType.GTE, abi.encode(uint256(1000)));
        assertEq(assertions.ok(guarded), 0);
    }

    function test_ok_judgedThroughCore() public {
        // assert "this call fails" by judging ok(...) EQ 0 through the core
        InputParam memory bomb = _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()));
        bytes memory okCalldata = abi.encodeCall(Assertions.ok, (bomb));
        InputParam memory judged = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(assertions), okCalldata),
            _c1(ConstraintType.EQ, abi.encode(uint256(0)))
        );
        assertions.assertParam(judged);

        // and the inverse: expecting success from the bomb fails the judge
        judged.constraints = _c1(ConstraintType.EQ, abi.encode(uint256(1)));
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                0,
                ConstraintType.EQ,
                bytes32(uint256(0)),
                abi.encode(uint256(1))
            )
        );
        assertions.assertParam(judged);
    }

    function test_ok_feedsCond() public view {
        // cond(ok(failing), never, fallbackValue): branch on resolvability
        InputParam memory bomb = _call(address(target), abi.encodeCall(MockTarget.revertingFunction, ()));
        InputParam memory probe = _nested(abi.encodeCall(Assertions.ok, (bomb)));
        (bool ok_, bytes memory ret) = _cond(probe, bomb, _lit(7));
        assertTrue(ok_);
        assertEq(abi.decode(ret, (uint256)), 7);
    }
}
