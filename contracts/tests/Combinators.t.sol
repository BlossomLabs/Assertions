// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Combinators.sol";
import "./Mocks.sol";

/// @notice Combinator composition tests. Wherever it mirrors real usage, a value
///         computed by Combinators is asserted THROUGH the core: the core
///         assertion's call target is the Combinators address.
contract CombinatorsTest is Test {
    Assertions public assertions;
    Combinators public combinators;
    MockTarget public target;
    MockToken public token;
    MockToken public underlyingToken;

    // Test addresses
    address constant TEST_EOA = address(0x1234);
    address constant ANOTHER_ADDRESS = address(0x5678);

    function setUp() public {
        assertions = new Assertions();
        combinators = new Combinators();
        target = new MockTarget();
        underlyingToken = new MockToken(address(0), "DAI");
        token = new MockToken(address(underlyingToken), "WETH");
        target.setToken(address(token));
    }

    // ============ Test Helpers ============

    /// @dev Encodes chainCall calldata for composing with core call assertions
    ///      (used as the `data` argument, with the combinators contract as `target`)
    function _chainData(address start, bytes[] memory calls) internal pure returns (bytes memory) {
        return abi.encodeCall(Combinators.chainCall, (start, calls));
    }

    /// @dev Prefixes a non-final hop with the return word index holding the
    ///      next hop's address (the _resolveChain hop encoding)
    function _hop(uint256 wordIndex, bytes memory data) internal pure returns (bytes memory) {
        return abi.encodePacked(wordIndex, data);
    }

    /// @dev Builds a two-hop call chain (non-final hop selects word 0)
    function _two(bytes memory a, bytes memory b) internal pure returns (bytes[] memory calls) {
        return _twoAt(0, a, b);
    }

    /// @dev Builds a two-hop call chain selecting `wordIndex` of the first hop
    function _twoAt(uint256 wordIndex, bytes memory a, bytes memory b) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](2);
        calls[0] = _hop(wordIndex, a);
        calls[1] = b;
    }

    /// @dev Builds a three-hop call chain (non-final hops select word 0)
    function _three(bytes memory a, bytes memory b, bytes memory c) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](3);
        calls[0] = _hop(0, a);
        calls[1] = _hop(0, b);
        calls[2] = c;
    }

    // ============ Chained Call Assertions (chainCall composition) ============

    function test_chainCall_uint_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            18
        );
    }

    function test_chainCall_uint_withArgs_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.balanceOf, (ANOTHER_ADDRESS)))
            ),
            1000
        );
    }

    function test_chainCall_uint_gt_success() public view {
        assertions.assertGtCallUint(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            10
        );
    }

    function test_chainCall_uint_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedUint.selector, "EQ", 18, 6)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            6
        );
    }

    function test_chainCall_uint_withMessage_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedUint.selector, "Wrong decimals", 18, 6)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            6,
            "Wrong decimals"
        );
    }

    function test_chainCall_string_success() public view {
        assertions.assertEqCallStringN(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbol, ()))
            ),
            0,
            "WETH"
        );
    }

    function test_chainCall_string_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedString.selector, "EQ_N", "WETH", "DAI")
        );
        assertions.assertEqCallStringN(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbol, ()))
            ),
            0,
            "DAI"
        );
    }

    function test_chainCall_threeHop_string_success() public view {
        assertions.assertEqCallStringN(
            address(combinators),
            _chainData(
                address(target),
                _three(
                    abi.encodeCall(MockTarget.token, ()),
                    abi.encodeCall(MockToken.underlying, ()),
                    abi.encodeCall(MockToken.symbol, ())
                )
            ),
            0,
            "DAI"
        );
    }

    function test_chainCall_threeHop_uint_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _chainData(
                address(target),
                _three(
                    abi.encodeCall(MockTarget.token, ()),
                    abi.encodeCall(MockToken.underlying, ()),
                    abi.encodeCall(MockToken.decimals, ())
                )
            ),
            18
        );
    }

    function test_chainCall_int_success() public view {
        assertions.assertEqCallInt(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.temperature, ()))
            ),
            -7
        );
    }

    function test_chainCall_address_success() public view {
        assertions.assertEqCallAddress(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.underlying, ()))
            ),
            address(underlyingToken)
        );
    }

    function test_chainCall_address_ne_success() public view {
        assertions.assertNeCallAddress(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.underlying, ()))
            ),
            ANOTHER_ADDRESS
        );
    }

    function test_chainCall_bool_assertFalse_success() public view {
        assertions.assertFalse(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.paused, ()))
            )
        );
    }

    function test_chainCall_bytes32_success() public view {
        assertions.assertEqCallBytes32(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbolHash, ()))
            ),
            keccak256("WETH")
        );
    }

    function test_chainCall_tupleIndexed_success() public view {
        assertions.assertEqCallUintN(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.limits, ()))
            ),
            1,
            1000
        );
    }

    function test_chainCall_arrayLength_success() public view {
        assertions.assertEqCallArrayLength(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.holders, ()))
            ),
            3
        );
    }

    function test_chainCall_approx_success() public view {
        assertions.assertApproxEqCallUint(
            address(combinators),
            _chainData(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            20,
            5
        );
    }

    function test_chainCall_emptyCalls_reverts() public {
        bytes[] memory calls = new bytes[](0);
        vm.expectRevert(Combinators.EmptyCallChain.selector);
        combinators.chainCall(address(target), calls);
    }

    function test_chainCall_failingHop_identifiesTarget() public {
        bytes memory hopData = abi.encodeCall(MockToken.revertingHop, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(token), hopData)
        );
        combinators.chainCall(
            address(target),
            _three(abi.encodeCall(MockTarget.token, ()), hopData, abi.encodeCall(MockToken.decimals, ()))
        );
    }

    function test_chainCall_codelessIntermediate_reverts() public {
        // eoaPointer() returns 0x1234, which has no code, so the next hop fails
        bytes memory hopData = abi.encodeCall(MockToken.decimals, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, TEST_EOA, hopData)
        );
        combinators.chainCall(
            address(target),
            _three(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.eoaPointer, ()), hopData)
        );
    }

    function test_chainCall_shortIntermediateReturn_reverts() public {
        // emptyReturn() returns no data, so the next hop's address cannot be decoded
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.chainCall(
            address(target),
            _three(
                abi.encodeCall(MockTarget.token, ()),
                abi.encodeCall(MockToken.emptyReturn, ()),
                abi.encodeCall(MockToken.decimals, ())
            )
        );
    }

    function test_chainCall_midChainWordSelection_success() public view {
        // tokenInfo() returns (uint256, address, uint256) — the token at word 1
        assertions.assertEqCallStringN(
            address(combinators),
            _chainData(
                address(target),
                _twoAt(1, abi.encodeCall(MockTarget.tokenInfo, ()), abi.encodeCall(MockToken.symbol, ()))
            ),
            0,
            "WETH"
        );
    }

    function test_chainCall_midChainWord_dirtyUpperBytes_reverts() public {
        // getTuple()'s word 3 is a bytes32 hash — not a clean address
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinators.InvalidChainAddress.selector, 0, keccak256("test")
            )
        );
        combinators.chainCall(
            address(target),
            _twoAt(3, abi.encodeCall(MockTarget.getTuple, ()), abi.encodeCall(MockToken.symbol, ()))
        );
    }

    function test_chainCall_midChainWord_pastReturndata_reverts() public {
        // tokenInfo() returns 96 bytes — word 5 lies past them
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 5, 96)
        );
        combinators.chainCall(
            address(target),
            _twoAt(5, abi.encodeCall(MockTarget.tokenInfo, ()), abi.encodeCall(MockToken.symbol, ()))
        );
    }

    function test_chainCall_unprefixedIntermediateHop_reverts() public {
        // A non-final entry without its 32-byte word-index prefix is malformed
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeCall(MockTarget.token, ());
        calls[1] = abi.encodeCall(MockToken.decimals, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.MalformedChainHop.selector, 0, 4)
        );
        combinators.chainCall(address(target), calls);
    }

    function test_chainCall_composedFailure_surfacesAsOuterCallFailed() public {
        // When a chain hop fails inside a composed assertion, the outer assertion
        // sees its staticcall to chainCall revert and wraps it in CallFailed
        // pointing at the assertions contract with the chainCall calldata.
        bytes memory chainData = _chainData(
            address(target),
            _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.revertingHop, ()))
        );
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(combinators), chainData)
        );
        assertions.assertEqCallUint(address(combinators), chainData, 0);
    }

    function test_chainCall_rawReturn_matchesFinalCallExactly() public view {
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.symbol, ())
        );
        (bool okChained, bytes memory chained) = address(combinators).staticcall(
            _chainData(address(target), calls)
        );
        (bool okDirect, bytes memory direct) = address(token).staticcall(
            abi.encodeCall(MockToken.symbol, ())
        );
        assertTrue(okChained);
        assertTrue(okDirect);
        assertEq(chained, direct);
    }

    // ============ Arithmetic Composition (calcUint / calcInt) ============

    /// @dev Encodes calcUint calldata for composition tests
    function _calcU(Combinators.ArithOp op, address t1, bytes memory d1, address t2, bytes memory d2)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(Combinators.calcUint, (op, t1, d1, t2, d2));
    }

    /// @dev Encodes cmpUint calldata for composition tests
    function _cmpU(Combinators.CmpOp op, address t1, bytes memory d1, address t2, bytes memory d2)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(Combinators.cmpUint, (op, t1, d1, t2, d2));
    }

    /// @dev Encodes a constantUint operand
    function _constU(uint256 x) internal pure returns (bytes memory) {
        return abi.encodeCall(Combinators.constantUint, (x));
    }

    function test_calcUint_canonicalExample_ethPlusTokenBalance() public {
        // balanceETH(addr) + WETH.balanceOf(addr) > 0
        vm.deal(ANOTHER_ADDRESS, 1 ether);
        assertions.assertGtCallUint(
            address(combinators),
            _calcU(
                Combinators.ArithOp.Add,
                address(combinators),
                abi.encodeCall(Combinators.ethBalance, (ANOTHER_ADDRESS)),
                address(token),
                abi.encodeCall(MockToken.balanceOf, (ANOTHER_ADDRESS))
            ),
            0
        );
    }

    function test_calcUint_allOps_success() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory b = abi.encodeCall(MockToken.decimals, ());  // 18
        assertEq(combinators.calcUint(Combinators.ArithOp.Add, address(target), a, address(token), b), 60);
        assertEq(combinators.calcUint(Combinators.ArithOp.Sub, address(target), a, address(token), b), 24);
        assertEq(combinators.calcUint(Combinators.ArithOp.Mul, address(target), a, address(token), b), 756);
        assertEq(combinators.calcUint(Combinators.ArithOp.Div, address(target), a, address(token), b), 2);
        assertEq(combinators.calcUint(Combinators.ArithOp.Mod, address(target), a, address(token), b), 6);
    }

    function test_calcUint_composed_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _calcU(
                Combinators.ArithOp.Add,
                address(target),
                abi.encodeCall(MockTarget.getValue, ()),
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            60
        );
    }

    function test_calcInt_allOps_success() public view {
        bytes memory a = abi.encodeCall(MockTarget.getInt, ());       // -42
        bytes memory b = abi.encodeCall(MockToken.temperature, ());   // -7
        assertEq(combinators.calcInt(Combinators.ArithOp.Add, address(target), a, address(token), b), -49);
        assertEq(combinators.calcInt(Combinators.ArithOp.Sub, address(target), a, address(token), b), -35);
        assertEq(combinators.calcInt(Combinators.ArithOp.Mul, address(target), a, address(token), b), 294);
        assertEq(combinators.calcInt(Combinators.ArithOp.Div, address(target), a, address(token), b), 6);
    }

    function test_calcInt_sub_goesNegative() public view {
        // temperature (-7) - decimals (18) = -25
        assertEq(
            combinators.calcInt(
                Combinators.ArithOp.Sub,
                address(token),
                abi.encodeCall(MockToken.temperature, ()),
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            -25
        );
    }

    function test_calcInt_div_truncatesTowardZero() public {
        // 45 / -7 = -6.43 -> truncates toward zero to -6 (not -7)
        target.setInt(45);
        assertEq(
            combinators.calcInt(
                Combinators.ArithOp.Div,
                address(target),
                abi.encodeCall(MockTarget.getInt, ()),
                address(token),
                abi.encodeCall(MockToken.temperature, ())
            ),
            -6
        );
    }

    function test_calcInt_mod_takesSignOfDividend() public {
        // 45 % -7 = 3 (sign of the dividend, positive)
        target.setInt(45);
        assertEq(
            combinators.calcInt(
                Combinators.ArithOp.Mod,
                address(target),
                abi.encodeCall(MockTarget.getInt, ()),
                address(token),
                abi.encodeCall(MockToken.temperature, ())
            ),
            3
        );
        // -45 % 7 = -3 (sign of the dividend, negative)
        target.setInt(-45);
        assertEq(
            combinators.calcInt(
                Combinators.ArithOp.Mod,
                address(target),
                abi.encodeCall(MockTarget.getInt, ()),
                address(combinators),
                abi.encodeCall(Combinators.constantInt, (7))
            ),
            -3
        );
    }

    function test_calcUint_overflow_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calcUint(
            Combinators.ArithOp.Add,
            address(token),
            abi.encodeCall(MockToken.maxUint, ()),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
    }

    function test_calcUint_underflow_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calcUint(
            Combinators.ArithOp.Sub,
            address(token),
            abi.encodeCall(MockToken.decimals, ()),
            address(target),
            abi.encodeCall(MockTarget.getValue, ())
        );
    }

    function test_calcUint_divByZero_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x12));
        combinators.calcUint(
            Combinators.ArithOp.Div,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.balanceOf, (address(0)))
        );
    }

    function test_calcUint_modByZero_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x12));
        combinators.calcUint(
            Combinators.ArithOp.Mod,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.balanceOf, (address(0)))
        );
    }

    function test_calc_malformedOperand_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.calcUint(
            Combinators.ArithOp.Add,
            address(token),
            abi.encodeCall(MockToken.emptyReturn, ()),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
    }

    function test_calc_failingOperand_reverts() public {
        bytes memory failing = abi.encodeCall(MockToken.revertingHop, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(token), failing)
        );
        combinators.calcUint(
            Combinators.ArithOp.Add,
            address(token),
            failing,
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
    }

    function test_calcUint_nested_calcOperand() public view {
        // (getValue + decimals) * decimals = (42 + 18) * 18 = 1080
        bytes memory inner = _calcU(
            Combinators.ArithOp.Add,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calcU(
                Combinators.ArithOp.Mul,
                address(combinators),
                inner,
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            1080
        );
    }

    function test_calcUint_chainCallOperand() public view {
        // chainCall(target, [token(), decimals()]) + getValue = 18 + 42 = 60
        bytes memory chained = _chainData(
            address(target),
            _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calcU(
                Combinators.ArithOp.Add,
                address(combinators),
                chained,
                address(target),
                abi.encodeCall(MockTarget.getValue, ())
            ),
            60
        );
    }

    function test_ethBalance_getter() public {
        vm.deal(ANOTHER_ADDRESS, 5 ether);
        assertEq(combinators.ethBalance(ANOTHER_ADDRESS), 5 ether);
        assertions.assertEqCallUint(
            address(combinators),
            abi.encodeCall(Combinators.ethBalance, (ANOTHER_ADDRESS)),
            5 ether
        );
    }

    function test_blockGetters() public view {
        assertEq(combinators.blockTimestamp(), block.timestamp);
        assertEq(combinators.blockNumber(), block.number);
    }

    // ============ Comparison Composition (cmpUint / cmpInt) ============

    function test_cmpUint_allOps() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory b = abi.encodeCall(MockToken.decimals, ());  // 18
        assertFalse(combinators.cmpUint(Combinators.CmpOp.Eq, address(target), a, address(token), b));
        assertTrue(combinators.cmpUint(Combinators.CmpOp.Ne, address(target), a, address(token), b));
        assertTrue(combinators.cmpUint(Combinators.CmpOp.Gt, address(target), a, address(token), b));
        assertFalse(combinators.cmpUint(Combinators.CmpOp.Lt, address(target), a, address(token), b));
        assertTrue(combinators.cmpUint(Combinators.CmpOp.Ge, address(target), a, address(token), b));
        assertFalse(combinators.cmpUint(Combinators.CmpOp.Le, address(target), a, address(token), b));
    }

    function test_cmpUint_equalOperands() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory c = _constU(42);
        assertTrue(combinators.cmpUint(Combinators.CmpOp.Eq, address(target), a, address(combinators), c));
        assertTrue(combinators.cmpUint(Combinators.CmpOp.Ge, address(target), a, address(combinators), c));
        assertTrue(combinators.cmpUint(Combinators.CmpOp.Le, address(target), a, address(combinators), c));
        assertFalse(combinators.cmpUint(Combinators.CmpOp.Ne, address(target), a, address(combinators), c));
    }

    function test_cmpInt_signedComparison() public view {
        bytes memory neg = abi.encodeCall(MockTarget.getInt, ());     // -42
        bytes memory pos = abi.encodeCall(MockToken.decimals, ());    // 18 (word doubles as int)
        // Signed: -42 < 18. An unsigned word comparison would say the opposite.
        assertTrue(combinators.cmpInt(Combinators.CmpOp.Lt, address(target), neg, address(token), pos));
        assertFalse(combinators.cmpInt(Combinators.CmpOp.Gt, address(target), neg, address(token), pos));
        // -42 < -7
        bytes memory temp = abi.encodeCall(MockToken.temperature, ());
        assertTrue(combinators.cmpInt(Combinators.CmpOp.Lt, address(target), neg, address(token), temp));
        // temperature == constantInt(-7)
        assertTrue(
            combinators.cmpInt(
                Combinators.CmpOp.Eq,
                address(token),
                temp,
                address(combinators),
                abi.encodeCall(Combinators.constantInt, (-7))
            )
        );
    }

    function test_constant_echoes() public view {
        assertEq(combinators.constantUint(123), 123);
        assertEq(combinators.constantInt(-5), -5);
        assertEq(combinators.constantUint(type(uint256).max), type(uint256).max);
    }

    // ============ Logic Composition (logicBool / notBool) ============

    function test_logicBool_and_truthTable() public {
        bytes memory t1 = abi.encodeCall(MockTarget.getBool, ());  // true (settable)
        bytes memory t2 = abi.encodeCall(MockToken.active, ());    // true
        bytes memory f = abi.encodeCall(MockToken.paused, ());     // false
        assertTrue(combinators.logicBool(Combinators.LogicOp.And, address(target), t1, address(token), t2));
        assertFalse(combinators.logicBool(Combinators.LogicOp.And, address(target), t1, address(token), f));
        assertFalse(combinators.logicBool(Combinators.LogicOp.And, address(token), f, address(token), t2));
        assertFalse(combinators.logicBool(Combinators.LogicOp.And, address(token), f, address(token), f));
    }

    function test_logicBool_or_truthTable() public view {
        bytes memory t1 = abi.encodeCall(MockTarget.getBool, ());
        bytes memory t2 = abi.encodeCall(MockToken.active, ());
        bytes memory f = abi.encodeCall(MockToken.paused, ());
        assertTrue(combinators.logicBool(Combinators.LogicOp.Or, address(target), t1, address(token), t2));
        assertTrue(combinators.logicBool(Combinators.LogicOp.Or, address(target), t1, address(token), f));
        assertTrue(combinators.logicBool(Combinators.LogicOp.Or, address(token), f, address(token), t2));
        assertFalse(combinators.logicBool(Combinators.LogicOp.Or, address(token), f, address(token), f));
    }

    function test_logicBool_xor_truthTable() public view {
        bytes memory t1 = abi.encodeCall(MockTarget.getBool, ());
        bytes memory t2 = abi.encodeCall(MockToken.active, ());
        bytes memory f = abi.encodeCall(MockToken.paused, ());
        assertFalse(combinators.logicBool(Combinators.LogicOp.Xor, address(target), t1, address(token), t2));
        assertTrue(combinators.logicBool(Combinators.LogicOp.Xor, address(target), t1, address(token), f));
        assertTrue(combinators.logicBool(Combinators.LogicOp.Xor, address(token), f, address(token), t2));
        assertFalse(combinators.logicBool(Combinators.LogicOp.Xor, address(token), f, address(token), f));
    }

    function test_notBool() public view {
        assertTrue(combinators.notBool(address(token), abi.encodeCall(MockToken.paused, ())));
        assertFalse(combinators.notBool(address(token), abi.encodeCall(MockToken.active, ())));
    }

    function test_logicBool_nonBooleanOperand_reverts() public {
        // getValue returns 42, which abi.decode rejects as a bool
        vm.expectRevert();
        combinators.logicBool(
            Combinators.LogicOp.And,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.active, ())
        );
    }

    function test_logic_endToEnd_orExample() public view {
        // "ANOTHER_ADDRESS has ETH OR has more than 10 tokens":
        // no ETH (false) OR balanceOf = 1000 > 10 (true) => true
        bytes memory hasEth = _cmpU(
            Combinators.CmpOp.Gt,
            address(combinators),
            abi.encodeCall(Combinators.ethBalance, (ANOTHER_ADDRESS)),
            address(combinators),
            _constU(0)
        );
        bytes memory hasTokens = _cmpU(
            Combinators.CmpOp.Gt,
            address(token),
            abi.encodeCall(MockToken.balanceOf, (ANOTHER_ADDRESS)),
            address(combinators),
            _constU(10)
        );
        assertions.assertEqCallBool(
            address(combinators),
            abi.encodeCall(
                Combinators.logicBool,
                (Combinators.LogicOp.Or, address(combinators), hasEth, address(combinators), hasTokens)
            ),
            true
        );
    }

    function test_composition_deepNested() public view {
        // assertTrue( (chainCall(target,[token,decimals]) + getValue == 60) AND !paused )
        bytes memory chained = _chainData(
            address(target),
            _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
        );
        bytes memory sum = _calcU(
            Combinators.ArithOp.Add,
            address(combinators),
            chained,
            address(target),
            abi.encodeCall(MockTarget.getValue, ())
        );
        bytes memory sumIs60 = _cmpU(
            Combinators.CmpOp.Eq,
            address(combinators),
            sum,
            address(combinators),
            _constU(60)
        );
        bytes memory notPaused = abi.encodeCall(
            Combinators.notBool,
            (address(token), abi.encodeCall(MockToken.paused, ()))
        );
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.logicBool,
                (Combinators.LogicOp.And, address(combinators), sumIs60, address(combinators), notPaused)
            )
        );
    }

    // ============ Bitwise Composition (bitUint / bitNotUint) ============

    function test_bitUint_andOrXor() public view {
        // 42 = 0b101010, 18 = 0b010010
        bytes memory a = abi.encodeCall(MockTarget.getValue, ());
        bytes memory b = abi.encodeCall(MockToken.decimals, ());
        assertEq(combinators.bitUint(Combinators.BitOp.And, address(target), a, address(token), b), 2);
        assertEq(combinators.bitUint(Combinators.BitOp.Or, address(target), a, address(token), b), 58);
        assertEq(combinators.bitUint(Combinators.BitOp.Xor, address(target), a, address(token), b), 56);
    }

    function test_bitUint_shifts() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        assertEq(
            combinators.bitUint(Combinators.BitOp.Shl, address(target), a, address(combinators), _constU(2)),
            168
        );
        assertEq(
            combinators.bitUint(Combinators.BitOp.Shr, address(target), a, address(combinators), _constU(1)),
            21
        );
    }

    function test_bitUint_shiftOfWidthOrMore_yieldsZero() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        assertEq(
            combinators.bitUint(Combinators.BitOp.Shl, address(target), a, address(combinators), _constU(256)),
            0
        );
        assertEq(
            combinators.bitUint(Combinators.BitOp.Shr, address(target), a, address(combinators), _constU(300)),
            0
        );
    }

    function test_bitNotUint() public view {
        assertEq(
            combinators.bitNotUint(address(combinators), _constU(0)),
            type(uint256).max
        );
        assertEq(
            combinators.bitNotUint(address(token), abi.encodeCall(MockToken.maxUint, ())),
            0
        );
    }

    function test_bitUint_bitmaskPattern() public view {
        // Packed config word 0b1010: assert `config & 0b10 != 0` and `(config >> 3) & 1 == 1`
        bytes memory config = _constU(10);
        assertions.assertNeCallUint(
            address(combinators),
            abi.encodeCall(
                Combinators.bitUint,
                (Combinators.BitOp.And, address(combinators), config, address(combinators), _constU(2))
            ),
            0
        );
        bytes memory shifted = abi.encodeCall(
            Combinators.bitUint,
            (Combinators.BitOp.Shr, address(combinators), config, address(combinators), _constU(3))
        );
        assertions.assertEqCallUint(
            address(combinators),
            abi.encodeCall(
                Combinators.bitUint,
                (Combinators.BitOp.And, address(combinators), shifted, address(combinators), _constU(1))
            ),
            1
        );
    }

    // ============ Hash Composition (hashCall) ============

    function test_hashCall_tupleReturn() public view {
        bytes[] memory calls = new bytes[](1);
        calls[0] = abi.encodeCall(MockTarget.getTuple, ());
        bytes32 expected = keccak256(
            abi.encode(uint256(42), address(0xBEEF), true, keccak256("test"))
        );
        assertEq(combinators.hashCall(address(target), calls), expected);
        assertions.assertEqCallBytes32(
            address(combinators),
            abi.encodeCall(Combinators.hashCall, (address(target), calls)),
            expected
        );
    }

    function test_hashCall_chained() public view {
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.symbol, ())
        );
        bytes32 expected = keccak256(abi.encode(string("WETH")));
        assertEq(combinators.hashCall(address(target), calls), expected);
        assertions.assertEqCallBytes32(
            address(combinators),
            abi.encodeCall(Combinators.hashCall, (address(target), calls)),
            expected
        );
    }

    // ============ String Split Composition (splitCall) ============

    /// @dev Wraps a single call into a one-element chain for splitCall tests
    function _single(bytes memory call) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](1);
        calls[0] = call;
    }

    function test_splitCall_wordCheck() public view {
        // "Curve LP Token" split by " " -> segment 1 is "LP"
        assertEq(
            combinators.splitCall(address(token), _single(abi.encodeCall(MockToken.name, ())), " ", 1),
            "LP"
        );
    }

    function test_splitCall_versionCheck() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(combinators.splitCall(address(target), calls, ".", 0), "2");
        assertEq(combinators.splitCall(address(target), calls, ".", 1), "1");
        assertEq(combinators.splitCall(address(target), calls, ".", 2), "0");
    }

    function test_splitCall_adjacentDelimiters_emptySegments() public {
        target.setString("a,,b");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(combinators.splitCall(address(target), calls, ",", 0), "a");
        assertEq(combinators.splitCall(address(target), calls, ",", 1), "");
        assertEq(combinators.splitCall(address(target), calls, ",", 2), "b");
        // Trailing delimiter also yields an empty final segment
        target.setString("a,");
        assertEq(combinators.splitCall(address(target), calls, ",", 1), "");
    }

    function test_splitCall_multiByteDelimiter() public {
        target.setString("red, green, blue");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(combinators.splitCall(address(target), calls, ", ", 1), "green");
        assertEq(combinators.splitCall(address(target), calls, ", ", 2), "blue");
    }

    function test_splitCall_delimiterAbsent_wholeString() public view {
        // storedString defaults to "hello"; no delimiter -> one segment
        assertEq(
            combinators.splitCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), ",", 0),
            "hello"
        );
    }

    function test_splitCall_indexOutOfRange_reverts() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, 3, 3)
        );
        combinators.splitCall(address(target), calls, ".", 3);
    }

    function test_splitCall_delimiterAbsent_indexOutOfRange_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, 1, 1)
        );
        combinators.splitCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), ",", 1);
    }

    function test_splitCall_emptyDelimiter_reverts() public {
        vm.expectRevert(Combinators.EmptyDelimiter.selector);
        combinators.splitCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), "", 0);
    }

    function test_splitCall_negativeIndex_fromEnd() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(combinators.splitCall(address(target), calls, ".", -1), "0");
        assertEq(combinators.splitCall(address(target), calls, ".", -2), "1");
        assertEq(combinators.splitCall(address(target), calls, ".", -3), "2");
    }

    function test_splitCall_negativeIndex_endsWith_composed() public view {
        // "the name ends with Token": last space-segment of "Curve LP Token"
        assertions.assertEqCallStringN(
            address(combinators),
            abi.encodeCall(
                Combinators.splitCall,
                (address(token), _single(abi.encodeCall(MockToken.name, ())), " ", -1)
            ),
            0,
            "Token"
        );
    }

    function test_splitCall_negativeIndex_outOfRange_reverts() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, int256(-4), uint256(3))
        );
        combinators.splitCall(address(target), calls, ".", -4);
    }

    function test_splitCall_negativeIndex_delimiterAbsent_wholeString() public {
        target.setString("hello");
        assertEq(
            combinators.splitCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), ",", -1),
            "hello"
        );
    }

    function test_splitCall_chained() public view {
        // target.token().name() -> "Curve LP Token", segment 1 is "LP"
        assertEq(
            combinators.splitCall(
                address(target),
                _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.name, ())),
                " ",
                1
            ),
            "LP"
        );
    }

    function test_splitCall_composed_endToEnd() public view {
        // splitCall returns a normal ABI-encoded string, so the string assertion
        // consumes it directly (index 0 decodes a plain string return)
        assertions.assertEqCallStringN(
            address(combinators),
            abi.encodeCall(
                Combinators.splitCall,
                (address(token), _single(abi.encodeCall(MockToken.name, ())), " ", 1)
            ),
            0,
            "LP"
        );
    }

    function test_splitCall_composed_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedString.selector, "EQ_N", "LP", "WETH")
        );
        assertions.assertEqCallStringN(
            address(combinators),
            abi.encodeCall(
                Combinators.splitCall,
                (address(token), _single(abi.encodeCall(MockToken.name, ())), " ", 1)
            ),
            0,
            "WETH"
        );
    }

    // ============ String Inclusion (includesCall) ============

    function test_includesCall_found() public view {
        // token.name() -> "Curve LP Token": middle, start, end, whole string
        bytes[] memory calls = _single(abi.encodeCall(MockToken.name, ()));
        assertTrue(combinators.includesCall(address(token), calls, "LP"));
        assertTrue(combinators.includesCall(address(token), calls, "Curve"));
        assertTrue(combinators.includesCall(address(token), calls, "Token"));
        assertTrue(combinators.includesCall(address(token), calls, "Curve LP Token"));
    }

    function test_includesCall_notFound_caseSensitive() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.name, ()));
        assertFalse(combinators.includesCall(address(token), calls, "Sushi"));
        assertFalse(combinators.includesCall(address(token), calls, "lp"));
    }

    function test_includesCall_needleLongerThanString() public {
        target.setString("ab");
        assertFalse(
            combinators.includesCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), "abc")
        );
    }

    function test_includesCall_emptyString() public {
        target.setString("");
        assertFalse(
            combinators.includesCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), "a")
        );
    }

    function test_includesCall_emptyPart_reverts() public {
        vm.expectRevert(Combinators.EmptySubstring.selector);
        combinators.includesCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), "");
    }

    function test_includesCall_chained() public view {
        // target.token().name() -> "Curve LP Token"
        assertTrue(
            combinators.includesCall(
                address(target), _two(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.name, ())), "LP"
            )
        );
    }

    function test_includesCall_composed_endToEnd() public view {
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.includesCall, (address(token), _single(abi.encodeCall(MockToken.name, ())), "LP")
            )
        );
    }

    function test_includesCall_negated_composed() public view {
        // "the name does NOT mention Sushi" via notBool
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.notBool,
                (
                    address(combinators),
                    abi.encodeCall(
                        Combinators.includesCall,
                        (address(token), _single(abi.encodeCall(MockToken.name, ())), "Sushi")
                    )
                )
            )
        );
    }

    function test_includesCall_composed_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedBool.selector, "TRUE", false, true)
        );
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.includesCall, (address(token), _single(abi.encodeCall(MockToken.name, ())), "Sushi")
            )
        );
    }

    // ============ Character Set (charsetCall) ============

    /// @dev Builds a charsetCall bitmap covering byte values lo..hi inclusive
    function _maskRange(bytes1 lo, bytes1 hi) internal pure returns (uint256 m) {
        for (uint256 b = uint8(lo); b <= uint8(hi); b++) {
            m |= 1 << b;
        }
    }

    function test_charsetCall_lowercaseOnly() public {
        target.setString("weth");
        assertTrue(
            combinators.charsetCall(
                address(target), _single(abi.encodeCall(MockTarget.getString, ())), _maskRange("a", "z")
            )
        );
    }

    function test_charsetCall_uppercase_fails() public view {
        // token.symbol() -> "WETH"
        assertFalse(
            combinators.charsetCall(
                address(token), _single(abi.encodeCall(MockToken.symbol, ())), _maskRange("a", "z")
            )
        );
    }

    function test_charsetCall_documentedLowercaseMask() public {
        // the mask the natspec documents for a-z equals the range-built one
        assertEq(_maskRange("a", "z"), 0x07fffffe << 96);
    }

    function test_charsetCall_composedMask() public {
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        uint256 mask = _maskRange("a", "z") | _maskRange("0", "9") | (uint256(1) << uint8(bytes1("-")));
        target.setString("curve-lp-01");
        assertTrue(combinators.charsetCall(address(target), calls, mask));
        // space is not in the set
        target.setString("curve lp");
        assertFalse(combinators.charsetCall(address(target), calls, mask));
    }

    function test_charsetCall_emptyString_vacuouslyTrue() public {
        target.setString("");
        assertTrue(
            combinators.charsetCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), 0)
        );
    }

    function test_charsetCall_utf8_failsAsciiMask() public {
        // every byte of a multi-byte UTF-8 character is >= 0x80
        target.setString(unicode"café");
        assertFalse(
            combinators.charsetCall(
                address(target), _single(abi.encodeCall(MockTarget.getString, ())), _maskRange("a", "z")
            )
        );
    }

    function test_charsetCall_chained() public view {
        // target.token().underlying().symbol() -> "DAI" is NOT lowercase
        assertFalse(
            combinators.charsetCall(
                address(target),
                _three(
                    abi.encodeCall(MockTarget.token, ()),
                    abi.encodeCall(MockToken.underlying, ()),
                    abi.encodeCall(MockToken.symbol, ())
                ),
                _maskRange("a", "z")
            )
        );
    }

    function test_charsetCall_composed_endToEnd() public {
        target.setString("weth");
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.charsetCall,
                (address(target), _single(abi.encodeCall(MockTarget.getString, ())), _maskRange("a", "z"))
            )
        );
    }

    function test_charsetCall_composed_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedBool.selector, "TRUE", false, true)
        );
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.charsetCall,
                (address(token), _single(abi.encodeCall(MockToken.symbol, ())), _maskRange("a", "z"))
            )
        );
    }

    // ============ Exponentiation (ArithOp.Exp) ============

    function test_calcUint_exp_success() public view {
        assertEq(
            combinators.calcUint(
                Combinators.ArithOp.Exp, address(combinators), _constU(2), address(combinators), _constU(10)
            ),
            1024
        );
        assertEq(
            combinators.calcUint(
                Combinators.ArithOp.Exp, address(combinators), _constU(10), address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            1e18
        );
    }

    function test_calcUint_exp_edgeCases() public view {
        // x ** 0 == 1 and 0 ** 0 == 1 per EVM semantics
        assertEq(
            combinators.calcUint(
                Combinators.ArithOp.Exp, address(combinators), _constU(7), address(combinators), _constU(0)
            ),
            1
        );
        assertEq(
            combinators.calcUint(
                Combinators.ArithOp.Exp, address(combinators), _constU(0), address(combinators), _constU(0)
            ),
            1
        );
    }

    function test_calcUint_exp_overflow_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calcUint(
            Combinators.ArithOp.Exp, address(combinators), _constU(2), address(combinators), _constU(256)
        );
    }

    function test_calcInt_exp_reverts_unsupported() public {
        // Solidity ** requires unsigned operands, so signed Exp is rejected loudly
        vm.expectRevert(Combinators.UnsupportedOp.selector);
        combinators.calcInt(
            Combinators.ArithOp.Exp, address(combinators), _constU(2), address(combinators), _constU(3)
        );
    }

    function test_exp_canonicalExample_decimalsScaling() public view {
        // whaleBalance() >= 5 * 10 ** token.decimals(), judged through the core
        bytes memory scale = _calcU(
            Combinators.ArithOp.Exp,
            address(combinators),
            _constU(10),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
        bytes memory threshold = _calcU(
            Combinators.ArithOp.Mul, address(combinators), _constU(5), address(combinators), scale
        );
        assertions.assertEqCallBool(
            address(combinators),
            _cmpU(
                Combinators.CmpOp.Ge,
                address(token),
                abi.encodeCall(MockToken.whaleBalance, ()),
                address(combinators),
                threshold
            ),
            true
        );
    }

    // ============ Word Extraction (uintCall) ============

    function test_uintCall_extractsTupleWords() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.getReserves, ()));
        assertEq(combinators.uintCall(address(token), calls, 0), 5000e18);
        assertEq(combinators.uintCall(address(token), calls, 1), 1000e18);
        assertEq(combinators.uintCall(address(token), calls, 2), 123456);
    }

    function test_uintCall_chained() public view {
        // target.token() -> token.getReserves(), word 1
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.getReserves, ())
        );
        assertEq(combinators.uintCall(address(target), calls, 1), 1000e18);
    }

    function test_uintCall_wordIndexOutOfRange_reverts() public {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.getReserves, ()));
        vm.expectRevert(abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 3, 96));
        combinators.uintCall(address(token), calls, 3);
    }

    function test_uintCall_emptyChain_reverts() public {
        vm.expectRevert(Combinators.EmptyCallChain.selector);
        combinators.uintCall(address(token), new bytes[](0), 0);
    }

    function test_uintCall_negativeIndex_fromEnd() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.getReserves, ()));
        assertEq(combinators.uintCall(address(token), calls, -1), 123456);
        assertEq(combinators.uintCall(address(token), calls, -2), 1000e18);
        assertEq(combinators.uintCall(address(token), calls, -3), 5000e18);
    }

    function test_uintCall_negativeIndex_lastArrayElement() public view {
        // getArray() -> [10, 20, 30, 40, 50]: raw words are offset, length,
        // items — -1 is the last item however long the live array is
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getArray, ()));
        assertEq(combinators.uintCall(address(target), calls, -1), 50);
    }

    function test_uintCall_negativeIndex_outOfRange_reverts() public {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.getReserves, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, int256(-4), uint256(96))
        );
        combinators.uintCall(address(token), calls, -4);
    }

    function test_uintCall_canonicalExample_reservesRatio() public view {
        // reserve0 / reserve1 >= 5, judged through the core
        bytes[] memory reserves = _single(abi.encodeCall(MockToken.getReserves, ()));
        bytes memory ratio = _calcU(
            Combinators.ArithOp.Div,
            address(combinators),
            abi.encodeCall(Combinators.uintCall, (address(token), reserves, 0)),
            address(combinators),
            abi.encodeCall(Combinators.uintCall, (address(token), reserves, 1))
        );
        assertions.assertEqCallBool(
            address(combinators),
            _cmpU(Combinators.CmpOp.Ge, address(combinators), ratio, address(combinators), _constU(5)),
            true
        );
    }

    // ============ Returndata Length (lengthCall) ============

    function test_lengthCall_arrayEncoding() public view {
        // uint256[](5): offset word + length word + 5 items = 224 bytes
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getArray, ()));
        assertEq(combinators.lengthCall(address(target), calls), 224);
    }

    function test_lengthCall_chained() public view {
        // target.token() -> token.holders() (3 addresses): 64 + 3 * 32 = 160
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.holders, ())
        );
        assertEq(combinators.lengthCall(address(target), calls), 160);
    }

    function test_lengthCall_insideArithmetic() public view {
        // item count = (lengthCall - 64) / 32 = 5, judged through the core
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getArray, ()));
        bytes memory bytesMinusHead = _calcU(
            Combinators.ArithOp.Sub,
            address(combinators),
            abi.encodeCall(Combinators.lengthCall, (address(target), calls)),
            address(combinators),
            _constU(64)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calcU(Combinators.ArithOp.Div, address(combinators), bytesMinusHead, address(combinators), _constU(32)),
            5
        );
    }

    // ============ Bool→Uint Bridge (boolToUint) ============

    function test_boolToUint_values() public view {
        assertEq(combinators.boolToUint(address(token), abi.encodeCall(MockToken.active, ())), 1);
        assertEq(combinators.boolToUint(address(token), abi.encodeCall(MockToken.paused, ())), 0);
    }

    function test_boolToUint_nonBooleanOperand_reverts() public {
        // getValue returns 42, which abi.decode rejects as a bool
        vm.expectRevert();
        combinators.boolToUint(address(target), abi.encodeCall(MockTarget.getValue, ()));
    }

    /// @dev Encodes the conditional-select idiom cond * a + (1 - cond) * b
    function _select(bytes memory cond, uint256 a, uint256 b) internal view returns (bytes memory) {
        bytes memory condTimesA = _calcU(
            Combinators.ArithOp.Mul, address(combinators), cond, address(combinators), _constU(a)
        );
        bytes memory oneMinusCond = _calcU(
            Combinators.ArithOp.Sub, address(combinators), _constU(1), address(combinators), cond
        );
        bytes memory notCondTimesB = _calcU(
            Combinators.ArithOp.Mul, address(combinators), oneMinusCond, address(combinators), _constU(b)
        );
        return _calcU(
            Combinators.ArithOp.Add, address(combinators), condTimesA, address(combinators), notCondTimesB
        );
    }

    function test_boolToUint_conditionalSelect_trueBranch() public view {
        bytes memory cond = abi.encodeCall(
            Combinators.boolToUint, (address(token), abi.encodeCall(MockToken.active, ()))
        );
        assertions.assertEqCallUint(address(combinators), _select(cond, 100, 200), 100);
    }

    function test_boolToUint_conditionalSelect_falseBranch() public view {
        bytes memory cond = abi.encodeCall(
            Combinators.boolToUint, (address(token), abi.encodeCall(MockToken.paused, ()))
        );
        assertions.assertEqCallUint(address(combinators), _select(cond, 100, 200), 200);
    }

    // ============ Min / Max / AbsDiff (ArithOp extensions) ============

    function test_calcUint_minMaxAbsDiff_success() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory b = abi.encodeCall(MockToken.decimals, ());  // 18
        assertEq(combinators.calcUint(Combinators.ArithOp.Min, address(target), a, address(token), b), 18);
        assertEq(combinators.calcUint(Combinators.ArithOp.Max, address(target), a, address(token), b), 42);
        assertEq(combinators.calcUint(Combinators.ArithOp.AbsDiff, address(target), a, address(token), b), 24);
        // AbsDiff is symmetric: the smaller operand first must not underflow
        assertEq(combinators.calcUint(Combinators.ArithOp.AbsDiff, address(token), b, address(target), a), 24);
    }

    function test_calcUint_absDiff_liveApproxEq_composed() public view {
        // |target.getValue() - token.decimals()| <= 30: live-vs-live approximate
        // equality, which the core's ApproxEq (constant expected side) cannot express
        assertions.assertLeCallUint(
            address(combinators),
            _calcU(
                Combinators.ArithOp.AbsDiff,
                address(target),
                abi.encodeCall(MockTarget.getValue, ()),
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            30
        );
    }

    function test_calcInt_minMaxAbsDiff_success() public view {
        bytes memory a = abi.encodeCall(MockTarget.getInt, ());      // -42
        bytes memory b = abi.encodeCall(MockToken.temperature, ());  // -7
        assertEq(combinators.calcInt(Combinators.ArithOp.Min, address(target), a, address(token), b), -42);
        assertEq(combinators.calcInt(Combinators.ArithOp.Max, address(target), a, address(token), b), -7);
        assertEq(combinators.calcInt(Combinators.ArithOp.AbsDiff, address(target), a, address(token), b), 35);
        assertEq(combinators.calcInt(Combinators.ArithOp.AbsDiff, address(token), b, address(target), a), 35);
    }

    function test_calcInt_absDiff_overflow_reverts() public {
        // |max - min| exceeds type(int256).max, so the checked subtraction panics
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calcInt(
            Combinators.ArithOp.AbsDiff,
            address(combinators),
            abi.encodeCall(Combinators.constantInt, (type(int256).max)),
            address(combinators),
            abi.encodeCall(Combinators.constantInt, (type(int256).min))
        );
    }

    // ============ Decoded Dynamic Length (arrayLengthCall) ============

    function test_arrayLengthCall_array() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getArray, ()));
        assertEq(combinators.arrayLengthCall(address(target), calls), 5);
    }

    function test_arrayLengthCall_emptyArray() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getEmptyArray, ()));
        assertEq(combinators.arrayLengthCall(address(target), calls), 0);
    }

    function test_arrayLengthCall_stringByteLength() public view {
        // "Curve LP Token" is 14 bytes; string returns share the dynamic encoding
        bytes[] memory calls = _single(abi.encodeCall(MockToken.name, ()));
        assertEq(combinators.arrayLengthCall(address(token), calls), 14);
    }

    function test_arrayLengthCall_chained() public view {
        // target.token() -> token.holders(): 3 addresses, decoded element count
        // (lengthCall sees the same return as 160 raw bytes)
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.holders, ())
        );
        assertEq(combinators.arrayLengthCall(address(target), calls), 3);
    }

    function test_arrayLengthCall_asOperand_composed() public view {
        // holders().length * 100 >= 300, judged through the core
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.holders, ())
        );
        assertions.assertGeCallUint(
            address(combinators),
            _calcU(
                Combinators.ArithOp.Mul,
                address(combinators),
                abi.encodeCall(Combinators.arrayLengthCall, (address(target), calls)),
                address(combinators),
                _constU(100)
            ),
            300
        );
    }

    function test_arrayLengthCall_staticReturn_reverts() public {
        // getValue() returns the word 42, which is not a valid head offset
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getValue, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 32)
        );
        combinators.arrayLengthCall(address(target), calls);
    }

    // ============ Chain-Resolved Balance (ethBalanceCall) ============

    function test_ethBalanceCall_single() public {
        vm.deal(address(0xBEEF), 3 ether);
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getAddress, ()));
        assertEq(combinators.ethBalanceCall(address(target), calls), 3 ether);
    }

    function test_ethBalanceCall_chained_composed() public {
        // Balance of target.token() -> token.underlying(), judged through the core
        vm.deal(address(underlyingToken), 1 ether);
        bytes[] memory calls = _two(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.underlying, ())
        );
        assertions.assertEqCallUint(
            address(combinators),
            abi.encodeCall(Combinators.ethBalanceCall, (address(target), calls)),
            1 ether
        );
    }

    function test_ethBalanceCall_emptyReturn_reverts() public {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.emptyReturn, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.ethBalanceCall(address(token), calls);
    }

    function test_ethBalanceCall_revertingHop_reverts() public {
        bytes memory hop = abi.encodeCall(MockToken.revertingHop, ());
        bytes[] memory calls = _single(hop);
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(token), hop)
        );
        combinators.ethBalanceCall(address(token), calls);
    }
}
