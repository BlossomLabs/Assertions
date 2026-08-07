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

    /// @dev The LEN sentinel path entry (mirrors Combinators.LEN)
    int256 constant LEN = type(int256).min;

    function setUp() public {
        assertions = new Assertions();
        combinators = new Combinators();
        target = new MockTarget();
        underlyingToken = new MockToken(address(0), "DAI");
        token = new MockToken(address(underlyingToken), "WETH");
        target.setToken(address(token));
    }

    // ============ Test Helpers ============

    /// @dev Wraps a single call into a one-element chain
    function _single(bytes memory call) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](1);
        calls[0] = call;
    }

    /// @dev Builds a two-hop call chain (plain calldata entries)
    function _pair(bytes memory a, bytes memory b) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](2);
        calls[0] = a;
        calls[1] = b;
    }

    /// @dev Builds a three-hop call chain (plain calldata entries)
    function _triple(bytes memory a, bytes memory b, bytes memory c) internal pure returns (bytes[] memory calls) {
        calls = new bytes[](3);
        calls[0] = a;
        calls[1] = b;
        calls[2] = c;
    }

    function _p1(int256 a) internal pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = a;
    }

    function _p2(int256 a, int256 b) internal pure returns (int256[] memory p) {
        p = new int256[](2);
        p[0] = a;
        p[1] = b;
    }

    function _p3(int256 a, int256 b, int256 c) internal pure returns (int256[] memory p) {
        p = new int256[](3);
        p[0] = a;
        p[1] = b;
        p[2] = c;
    }

    /// @dev read calldata: pure passthrough chain — every hop raw mode with
    ///      an empty path (mid-chain: word 0; final: raw returndata)
    function _readData(address start, bytes[] memory calls) internal pure returns (bytes memory) {
        return abi.encodeCall(
            Combinators.read,
            (start, calls, new string[](calls.length), new int256[][](calls.length))
        );
    }

    /// @dev read calldata: two-hop chain selecting raw word `wordIndex` of
    ///      the first hop, passing the final return through
    function _readDataAt(address start, int256 wordIndex, bytes memory a, bytes memory b)
        internal
        pure
        returns (bytes memory)
    {
        int256[][] memory paths = new int256[][](2);
        paths[0] = _p1(wordIndex);
        paths[1] = new int256[](0);
        return abi.encodeCall(Combinators.read, (start, _pair(a, b), new string[](2), paths));
    }

    /// @dev read calldata: single call, raw word extraction at `wordIndex`
    function _wordData(address start, bytes memory call, int256 wordIndex) internal pure returns (bytes memory) {
        return _wordDataChain(start, _single(call), wordIndex);
    }

    /// @dev read calldata: passthrough chain with raw word extraction on the
    ///      final hop
    function _wordDataChain(address start, bytes[] memory calls, int256 wordIndex)
        internal
        pure
        returns (bytes memory)
    {
        int256[][] memory paths = new int256[][](calls.length);
        paths[calls.length - 1] = _p1(wordIndex);
        return abi.encodeCall(Combinators.read, (start, calls, new string[](calls.length), paths));
    }

    /// @dev read calldata: single call, typed navigation
    function _navData(address start, bytes memory call, string memory t, int256[] memory path)
        internal
        pure
        returns (bytes memory)
    {
        string[] memory types_ = new string[](1);
        types_[0] = t;
        int256[][] memory paths = new int256[][](1);
        paths[0] = path;
        return abi.encodeCall(Combinators.read, (start, _single(call), types_, paths));
    }

    /// @dev calc calldata for composition tests
    function _calc(Combinators.CalcOp op, address t1, bytes memory d1, address t2, bytes memory d2)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(Combinators.calc, (op, t1, d1, t2, d2));
    }

    /// @dev data calldata for composition tests
    function _dataCall(Combinators.DataOp op, address start, bytes[] memory calls, bytes memory arg, int256 index)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(Combinators.data, (op, start, calls, arg, index));
    }

    /// @dev Encodes an env(Constant) uint operand
    function _constU(uint256 x) internal pure returns (bytes memory) {
        return abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, x));
    }

    /// @dev Encodes an env(Constant) int operand (two's-complement word)
    function _constI(int256 x) internal pure returns (bytes memory) {
        return abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, uint256(x)));
    }

    /// @dev Staticcalls the combinators contract and decodes a word result,
    ///      bubbling the revert data on failure
    function _staticUint(bytes memory callData) internal view returns (uint256) {
        (bool ok, bytes memory out) = address(combinators).staticcall(callData);
        if (!ok) {
            assembly {
                revert(add(out, 32), mload(out))
            }
        }
        return abi.decode(out, (uint256));
    }

    /// @dev Staticcalls the combinators contract and decodes a bytes32 result
    function _staticBytes32(bytes memory callData) internal view returns (bytes32) {
        return bytes32(_staticUint(callData));
    }

    /// @dev Staticcalls the combinators contract and decodes a bool result
    function _staticBool(bytes memory callData) internal view returns (bool) {
        return _staticUint(callData) != 0;
    }

    /// @dev Staticcalls the combinators contract and decodes a string result
    function _staticString(bytes memory callData) internal view returns (string memory) {
        (bool ok, bytes memory out) = address(combinators).staticcall(callData);
        if (!ok) {
            assembly {
                revert(add(out, 32), mload(out))
            }
        }
        return abi.decode(out, (string));
    }

    // ============ Chained Reads (read passthrough) ============

    function test_read_uint_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            18
        );
    }

    function test_read_uint_withArgs_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.balanceOf, (ANOTHER_ADDRESS)))
            ),
            1000
        );
    }

    function test_read_uint_gt_success() public view {
        assertions.assertGtCallUint(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            10
        );
    }

    function test_read_uint_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedUint.selector, "EQ", 18, 6)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            6
        );
    }

    function test_read_uint_withMessage_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedUint.selector, "Wrong decimals", 18, 6)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            6,
            "Wrong decimals"
        );
    }

    function test_read_string_success() public view {
        assertions.assertEqCallStringN(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbol, ()))
            ),
            0,
            "WETH"
        );
    }

    function test_read_string_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedString.selector, "EQ_N", "WETH", "DAI")
        );
        assertions.assertEqCallStringN(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbol, ()))
            ),
            0,
            "DAI"
        );
    }

    function test_read_threeHop_string_success() public view {
        assertions.assertEqCallStringN(
            address(combinators),
            _readData(
                address(target),
                _triple(
                    abi.encodeCall(MockTarget.token, ()),
                    abi.encodeCall(MockToken.underlying, ()),
                    abi.encodeCall(MockToken.symbol, ())
                )
            ),
            0,
            "DAI"
        );
    }

    function test_read_threeHop_uint_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _readData(
                address(target),
                _triple(
                    abi.encodeCall(MockTarget.token, ()),
                    abi.encodeCall(MockToken.underlying, ()),
                    abi.encodeCall(MockToken.decimals, ())
                )
            ),
            18
        );
    }

    function test_read_int_success() public view {
        assertions.assertEqCallInt(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.temperature, ()))
            ),
            -7
        );
    }

    function test_read_address_success() public view {
        assertions.assertEqCallAddress(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.underlying, ()))
            ),
            address(underlyingToken)
        );
    }

    function test_read_address_ne_success() public view {
        assertions.assertNeCallAddress(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.underlying, ()))
            ),
            ANOTHER_ADDRESS
        );
    }

    function test_read_bool_assertFalse_success() public view {
        assertions.assertFalse(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.paused, ()))
            )
        );
    }

    function test_read_bytes32_success() public view {
        assertions.assertEqCallBytes32(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbolHash, ()))
            ),
            keccak256("WETH")
        );
    }

    function test_read_tupleIndexed_success() public view {
        assertions.assertEqCallUintN(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.limits, ()))
            ),
            1,
            1000
        );
    }

    function test_read_arrayLength_success() public view {
        assertions.assertEqCallArrayLength(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.holders, ()))
            ),
            3
        );
    }

    function test_read_approx_success() public view {
        assertions.assertApproxEqCallUint(
            address(combinators),
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
            ),
            20,
            5
        );
    }

    function test_read_emptyCalls_reverts() public {
        vm.expectRevert(Combinators.EmptyCallChain.selector);
        combinators.read(address(target), new bytes[](0), new string[](0), new int256[][](0));
    }

    function test_read_arrayLengthMismatch_reverts() public {
        bytes[] memory calls = _pair(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.decimals, ())
        );
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ArgumentCountMismatch.selector, 2, 1, 2)
        );
        combinators.read(address(target), calls, new string[](1), new int256[][](2));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ArgumentCountMismatch.selector, 2, 2, 3)
        );
        combinators.read(address(target), calls, new string[](2), new int256[][](3));
    }

    function test_read_failingHop_identifiesTarget() public {
        bytes memory hopData = abi.encodeCall(MockToken.revertingHop, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(token), hopData)
        );
        combinators.read(
            address(target),
            _triple(abi.encodeCall(MockTarget.token, ()), hopData, abi.encodeCall(MockToken.decimals, ())),
            new string[](3),
            new int256[][](3)
        );
    }

    function test_read_codelessIntermediate_reverts() public {
        // eoaPointer() returns 0x1234, which has no code, so the next hop fails
        bytes memory hopData = abi.encodeCall(MockToken.decimals, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, TEST_EOA, hopData)
        );
        combinators.read(
            address(target),
            _triple(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.eoaPointer, ()), hopData),
            new string[](3),
            new int256[][](3)
        );
    }

    function test_read_shortIntermediateReturn_reverts() public {
        // emptyReturn() returns no data, so the next hop's address cannot be read
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.read(
            address(target),
            _triple(
                abi.encodeCall(MockTarget.token, ()),
                abi.encodeCall(MockToken.emptyReturn, ()),
                abi.encodeCall(MockToken.decimals, ())
            ),
            new string[](3),
            new int256[][](3)
        );
    }

    function test_read_midChainRawWordSelection_success() public view {
        // tokenInfo() returns (uint256, address, uint256) — the token at word 1
        assertions.assertEqCallStringN(
            address(combinators),
            _readDataAt(
                address(target), 1, abi.encodeCall(MockTarget.tokenInfo, ()), abi.encodeCall(MockToken.symbol, ())
            ),
            0,
            "WETH"
        );
    }

    function test_read_midChainTypedSelection_success() public view {
        // The same hop selected by a typed path over the declared return tuple
        string[] memory types_ = new string[](2);
        types_[0] = "(uint256,address,uint256)";
        int256[][] memory paths = new int256[][](2);
        paths[0] = _p1(1);
        assertions.assertEqCallStringN(
            address(combinators),
            abi.encodeCall(
                Combinators.read,
                (
                    address(target),
                    _pair(abi.encodeCall(MockTarget.tokenInfo, ()), abi.encodeCall(MockToken.symbol, ())),
                    types_,
                    paths
                )
            ),
            0,
            "WETH"
        );
    }

    function test_read_midChainNavigatedArrayElement_success() public {
        // signers() returns (address[], address): hop through list[-1] (0xaaa3),
        // which has no code — proving the path resolved to the array element
        string[] memory types_ = new string[](2);
        types_[0] = "(address[],address)";
        int256[][] memory paths = new int256[][](2);
        paths[0] = _p2(0, -1);
        bytes memory hopData = abi.encodeCall(MockToken.decimals, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(0xaaa3), hopData)
        );
        combinators.read(
            address(token), _pair(abi.encodeCall(MockToken.signers, ()), hopData), types_, paths
        );
    }

    function test_read_midChainWord_dirtyUpperBytes_reverts() public {
        // getTuple()'s word 3 is a bytes32 hash — not a clean address
        vm.expectRevert(
            abi.encodeWithSelector(
                Combinators.InvalidAddressWord.selector, 0, keccak256("test")
            )
        );
        (bool ok, ) = address(combinators).staticcall(
            _readDataAt(address(target), 3, abi.encodeCall(MockTarget.getTuple, ()), abi.encodeCall(MockToken.symbol, ()))
        );
        ok;
    }

    function test_read_midChainWord_pastReturndata_reverts() public {
        // tokenInfo() returns 96 bytes — word 5 lies past them
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 5, 96)
        );
        (bool ok, ) = address(combinators).staticcall(
            _readDataAt(address(target), 5, abi.encodeCall(MockTarget.tokenInfo, ()), abi.encodeCall(MockToken.symbol, ()))
        );
        ok;
    }

    function test_read_composedFailure_surfacesAsOuterCallFailed() public {
        // When a chain hop fails inside a composed assertion, the outer assertion
        // sees its staticcall to read revert and wraps it in CallFailed
        // pointing at the combinators contract with the read calldata.
        bytes memory readData = _readData(
            address(target),
            _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.revertingHop, ()))
        );
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(combinators), readData)
        );
        assertions.assertEqCallUint(address(combinators), readData, 0);
    }

    function test_read_rawReturn_matchesFinalCallExactly() public view {
        (bool okChained, bytes memory chained) = address(combinators).staticcall(
            _readData(
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.symbol, ()))
            )
        );
        (bool okDirect, bytes memory direct) = address(token).staticcall(
            abi.encodeCall(MockToken.symbol, ())
        );
        assertTrue(okChained);
        assertTrue(okDirect);
        assertEq(chained, direct);
    }

    // ============ Arithmetic (calc: Add..Exp) ============

    function test_calc_canonicalExample_ethPlusTokenBalance() public {
        // env(Balance, addr) + WETH.balanceOf(addr) > 0
        vm.deal(ANOTHER_ADDRESS, 1 ether);
        assertions.assertGtCallUint(
            address(combinators),
            _calc(
                Combinators.CalcOp.Add,
                address(combinators),
                abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(ANOTHER_ADDRESS)))),
                address(token),
                abi.encodeCall(MockToken.balanceOf, (ANOTHER_ADDRESS))
            ),
            0
        );
    }

    function test_calc_unsignedOps_success() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory b = abi.encodeCall(MockToken.decimals, ());  // 18
        assertEq(combinators.calc(Combinators.CalcOp.Add, address(target), a, address(token), b), 60);
        assertEq(combinators.calc(Combinators.CalcOp.Sub, address(target), a, address(token), b), 24);
        assertEq(combinators.calc(Combinators.CalcOp.Mul, address(target), a, address(token), b), 756);
        assertEq(combinators.calc(Combinators.CalcOp.Div, address(target), a, address(token), b), 2);
        assertEq(combinators.calc(Combinators.CalcOp.Mod, address(target), a, address(token), b), 6);
    }

    function test_calc_composed_success() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _calc(
                Combinators.CalcOp.Add,
                address(target),
                abi.encodeCall(MockTarget.getValue, ()),
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            60
        );
    }

    function test_calc_signedOps_success() public view {
        bytes memory a = abi.encodeCall(MockTarget.getInt, ());       // -42
        bytes memory b = abi.encodeCall(MockToken.temperature, ());   // -7
        assertEq(int256(combinators.calc(Combinators.CalcOp.SAdd, address(target), a, address(token), b)), -49);
        assertEq(int256(combinators.calc(Combinators.CalcOp.SSub, address(target), a, address(token), b)), -35);
        assertEq(int256(combinators.calc(Combinators.CalcOp.SMul, address(target), a, address(token), b)), 294);
        assertEq(int256(combinators.calc(Combinators.CalcOp.SDiv, address(target), a, address(token), b)), 6);
    }

    function test_calc_sadd_mixedSigns_noPanic() public view {
        // -7 + 18 = 11: as unsigned checked Add the -7 word would overflow,
        // which is exactly why SAdd exists
        assertEq(
            int256(
                combinators.calc(
                    Combinators.CalcOp.SAdd,
                    address(token),
                    abi.encodeCall(MockToken.temperature, ()),
                    address(token),
                    abi.encodeCall(MockToken.decimals, ())
                )
            ),
            11
        );
    }

    function test_calc_ssub_goesNegative() public view {
        // temperature (-7) - decimals (18) = -25
        assertEq(
            int256(
                combinators.calc(
                    Combinators.CalcOp.SSub,
                    address(token),
                    abi.encodeCall(MockToken.temperature, ()),
                    address(token),
                    abi.encodeCall(MockToken.decimals, ())
                )
            ),
            -25
        );
    }

    function test_calc_sdiv_truncatesTowardZero() public {
        // 45 / -7 = -6.43 -> truncates toward zero to -6 (not -7)
        target.setInt(45);
        assertEq(
            int256(
                combinators.calc(
                    Combinators.CalcOp.SDiv,
                    address(target),
                    abi.encodeCall(MockTarget.getInt, ()),
                    address(token),
                    abi.encodeCall(MockToken.temperature, ())
                )
            ),
            -6
        );
    }

    function test_calc_smod_takesSignOfDividend() public {
        // 45 % -7 = 3 (sign of the dividend, positive)
        target.setInt(45);
        assertEq(
            int256(
                combinators.calc(
                    Combinators.CalcOp.SMod,
                    address(target),
                    abi.encodeCall(MockTarget.getInt, ()),
                    address(token),
                    abi.encodeCall(MockToken.temperature, ())
                )
            ),
            3
        );
        // -45 % 7 = -3 (sign of the dividend, negative)
        target.setInt(-45);
        assertEq(
            int256(
                combinators.calc(
                    Combinators.CalcOp.SMod,
                    address(target),
                    abi.encodeCall(MockTarget.getInt, ()),
                    address(combinators),
                    _constI(7)
                )
            ),
            -3
        );
    }

    function test_calc_add_overflow_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calc(
            Combinators.CalcOp.Add,
            address(token),
            abi.encodeCall(MockToken.maxUint, ()),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
    }

    function test_calc_sub_underflow_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calc(
            Combinators.CalcOp.Sub,
            address(token),
            abi.encodeCall(MockToken.decimals, ()),
            address(target),
            abi.encodeCall(MockTarget.getValue, ())
        );
    }

    function test_calc_divByZero_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x12));
        combinators.calc(
            Combinators.CalcOp.Div,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.balanceOf, (address(0)))
        );
    }

    function test_calc_modByZero_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x12));
        combinators.calc(
            Combinators.CalcOp.Mod,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.balanceOf, (address(0)))
        );
    }

    function test_calc_sdiv_minByMinusOne_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calc(
            Combinators.CalcOp.SDiv,
            address(combinators),
            _constI(type(int256).min),
            address(combinators),
            _constI(-1)
        );
    }

    function test_calc_malformedOperand_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.calc(
            Combinators.CalcOp.Add,
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
        combinators.calc(
            Combinators.CalcOp.Add,
            address(token),
            failing,
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
    }

    function test_calc_nested_calcOperand() public view {
        // (getValue + decimals) * decimals = (42 + 18) * 18 = 1080
        bytes memory inner = _calc(
            Combinators.CalcOp.Add,
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calc(
                Combinators.CalcOp.Mul,
                address(combinators),
                inner,
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            1080
        );
    }

    function test_calc_readOperand() public view {
        // read(target, [token(), decimals()]) + getValue = 18 + 42 = 60
        bytes memory chained = _readData(
            address(target),
            _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calc(
                Combinators.CalcOp.Add,
                address(combinators),
                chained,
                address(target),
                abi.encodeCall(MockTarget.getValue, ())
            ),
            60
        );
    }

    // ============ Value Getters (env) ============

    function test_env_balance() public {
        vm.deal(ANOTHER_ADDRESS, 5 ether);
        assertEq(
            combinators.env(Combinators.EnvOp.Balance, uint256(uint160(ANOTHER_ADDRESS))),
            5 ether
        );
        assertions.assertEqCallUint(
            address(combinators),
            abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(ANOTHER_ADDRESS)))),
            5 ether
        );
    }

    function test_env_blockGetters() public view {
        assertEq(combinators.env(Combinators.EnvOp.Timestamp, 0), block.timestamp);
        assertEq(combinators.env(Combinators.EnvOp.BlockNumber, 0), block.number);
    }

    function test_env_chainId() public {
        assertEq(combinators.env(Combinators.EnvOp.ChainId, 0), block.chainid);
        vm.chainId(100);
        assertEq(combinators.env(Combinators.EnvOp.ChainId, 0), 100);
        // chainId + 1 == 101, judged through the core
        assertions.assertEqCallUint(
            address(combinators),
            _calc(
                Combinators.CalcOp.Add,
                address(combinators),
                abi.encodeCall(Combinators.env, (Combinators.EnvOp.ChainId, 0)),
                address(combinators),
                _constU(1)
            ),
            101
        );
    }

    function test_env_codeHash() public {
        assertEq(
            combinators.env(Combinators.EnvOp.CodeHash, uint256(uint160(address(token)))),
            uint256(address(token).codehash)
        );
        // Existing code-less account (has balance): keccak256("")
        vm.deal(TEST_EOA, 1 ether);
        assertEq(
            combinators.env(Combinators.EnvOp.CodeHash, uint256(uint160(TEST_EOA))),
            uint256(keccak256(""))
        );
        // Nonexistent account: bytes32(0)
        assertEq(combinators.env(Combinators.EnvOp.CodeHash, uint256(uint160(address(0x9999)))), 0);
        // Judged through the core
        assertions.assertEqCallBytes32(
            address(combinators),
            abi.encodeCall(Combinators.env, (Combinators.EnvOp.CodeHash, uint256(uint160(address(token))))),
            address(token).codehash
        );
    }

    function test_env_codeHash_composed_eq() public view {
        // Both MockTokens share bytecode, so their code hashes match: judged
        // live-vs-live through calc(Eq) over the raw hash words.
        assertions.assertTrue(
            address(combinators),
            _calc(
                Combinators.CalcOp.Eq,
                address(combinators),
                abi.encodeCall(Combinators.env, (Combinators.EnvOp.CodeHash, uint256(uint160(address(token))))),
                address(combinators),
                abi.encodeCall(
                    Combinators.env, (Combinators.EnvOp.CodeHash, uint256(uint160(address(underlyingToken))))
                )
            )
        );
    }

    function test_env_constant_echoes() public view {
        assertEq(combinators.env(Combinators.EnvOp.Constant, 123), 123);
        assertEq(int256(combinators.env(Combinators.EnvOp.Constant, uint256(int256(-5)))), -5);
        assertEq(combinators.env(Combinators.EnvOp.Constant, type(uint256).max), type(uint256).max);
    }

    function test_env_dirtyAddressArg_reverts() public {
        uint256 dirty = uint256(keccak256("test"));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.InvalidAddressWord.selector, 0, bytes32(dirty))
        );
        combinators.env(Combinators.EnvOp.Balance, dirty);
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.InvalidAddressWord.selector, 0, bytes32(dirty))
        );
        combinators.env(Combinators.EnvOp.CodeHash, dirty);
    }

    // ============ Comparisons (calc: Eq..SGe) ============

    function test_calc_unsignedComparisons() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory b = abi.encodeCall(MockToken.decimals, ());  // 18
        assertEq(combinators.calc(Combinators.CalcOp.Eq, address(target), a, address(token), b), 0);
        assertEq(combinators.calc(Combinators.CalcOp.Ne, address(target), a, address(token), b), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Gt, address(target), a, address(token), b), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Lt, address(target), a, address(token), b), 0);
        assertEq(combinators.calc(Combinators.CalcOp.Ge, address(target), a, address(token), b), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Le, address(target), a, address(token), b), 0);
    }

    function test_calc_comparisons_equalOperands() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory c = _constU(42);
        assertEq(combinators.calc(Combinators.CalcOp.Eq, address(target), a, address(combinators), c), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Ge, address(target), a, address(combinators), c), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Le, address(target), a, address(combinators), c), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Ne, address(target), a, address(combinators), c), 0);
    }

    function test_calc_signedComparisons() public view {
        bytes memory neg = abi.encodeCall(MockTarget.getInt, ());     // -42
        bytes memory pos = abi.encodeCall(MockToken.decimals, ());    // 18 (word doubles as int)
        // Signed: -42 < 18. The unsigned Lt on the same words says the opposite.
        assertEq(combinators.calc(Combinators.CalcOp.SLt, address(target), neg, address(token), pos), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Lt, address(target), neg, address(token), pos), 0);
        assertEq(combinators.calc(Combinators.CalcOp.SGt, address(target), neg, address(token), pos), 0);
        // -42 < -7
        bytes memory temp = abi.encodeCall(MockToken.temperature, ());
        assertEq(combinators.calc(Combinators.CalcOp.SLt, address(target), neg, address(token), temp), 1);
        assertEq(combinators.calc(Combinators.CalcOp.SLe, address(target), neg, address(token), temp), 1);
        assertEq(combinators.calc(Combinators.CalcOp.SGe, address(target), neg, address(token), temp), 0);
        // temperature == constant(-7)
        assertEq(
            combinators.calc(Combinators.CalcOp.Eq, address(token), temp, address(combinators), _constI(-7)),
            1
        );
    }

    // ============ Boolean Logic (calc: And/Or/Xor + unary: IsZero) ============

    function test_calc_and_truthTable() public view {
        bytes memory t1 = abi.encodeCall(MockTarget.getBool, ());  // true (settable)
        bytes memory t2 = abi.encodeCall(MockToken.active, ());    // true
        bytes memory f = abi.encodeCall(MockToken.paused, ());     // false
        assertEq(combinators.calc(Combinators.CalcOp.And, address(target), t1, address(token), t2), 1);
        assertEq(combinators.calc(Combinators.CalcOp.And, address(target), t1, address(token), f), 0);
        assertEq(combinators.calc(Combinators.CalcOp.And, address(token), f, address(token), t2), 0);
        assertEq(combinators.calc(Combinators.CalcOp.And, address(token), f, address(token), f), 0);
    }

    function test_calc_or_truthTable() public view {
        bytes memory t1 = abi.encodeCall(MockTarget.getBool, ());
        bytes memory t2 = abi.encodeCall(MockToken.active, ());
        bytes memory f = abi.encodeCall(MockToken.paused, ());
        assertEq(combinators.calc(Combinators.CalcOp.Or, address(target), t1, address(token), t2), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Or, address(target), t1, address(token), f), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Or, address(token), f, address(token), t2), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Or, address(token), f, address(token), f), 0);
    }

    function test_calc_xor_truthTable() public view {
        bytes memory t1 = abi.encodeCall(MockTarget.getBool, ());
        bytes memory t2 = abi.encodeCall(MockToken.active, ());
        bytes memory f = abi.encodeCall(MockToken.paused, ());
        assertEq(combinators.calc(Combinators.CalcOp.Xor, address(target), t1, address(token), t2), 0);
        assertEq(combinators.calc(Combinators.CalcOp.Xor, address(target), t1, address(token), f), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Xor, address(token), f, address(token), t2), 1);
        assertEq(combinators.calc(Combinators.CalcOp.Xor, address(token), f, address(token), f), 0);
    }

    function test_unary_isZero() public view {
        assertEq(combinators.unary(Combinators.UnaryOp.IsZero, address(token), abi.encodeCall(MockToken.paused, ())), 1);
        assertEq(combinators.unary(Combinators.UnaryOp.IsZero, address(token), abi.encodeCall(MockToken.active, ())), 0);
        // IsZero is EVM ISZERO: any nonzero word negates to 0
        assertEq(combinators.unary(Combinators.UnaryOp.IsZero, address(target), abi.encodeCall(MockTarget.getValue, ())), 0);
        assertEq(combinators.unary(Combinators.UnaryOp.IsZero, address(combinators), _constU(0)), 1);
    }

    function test_logic_endToEnd_orExample() public view {
        // "ANOTHER_ADDRESS has ETH OR has more than 10 tokens":
        // no ETH (false) OR balanceOf = 1000 > 10 (true) => true
        bytes memory hasEth = _calc(
            Combinators.CalcOp.Gt,
            address(combinators),
            abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(ANOTHER_ADDRESS)))),
            address(combinators),
            _constU(0)
        );
        bytes memory hasTokens = _calc(
            Combinators.CalcOp.Gt,
            address(token),
            abi.encodeCall(MockToken.balanceOf, (ANOTHER_ADDRESS)),
            address(combinators),
            _constU(10)
        );
        assertions.assertEqCallBool(
            address(combinators),
            _calc(Combinators.CalcOp.Or, address(combinators), hasEth, address(combinators), hasTokens),
            true
        );
    }

    function test_composition_deepNested() public view {
        // assertTrue( (read(target,[token,decimals]) + getValue == 60) AND !paused )
        bytes memory chained = _readData(
            address(target),
            _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.decimals, ()))
        );
        bytes memory sum = _calc(
            Combinators.CalcOp.Add,
            address(combinators),
            chained,
            address(target),
            abi.encodeCall(MockTarget.getValue, ())
        );
        bytes memory sumIs60 = _calc(
            Combinators.CalcOp.Eq,
            address(combinators),
            sum,
            address(combinators),
            _constU(60)
        );
        bytes memory notPaused = abi.encodeCall(
            Combinators.unary,
            (Combinators.UnaryOp.IsZero, address(token), abi.encodeCall(MockToken.paused, ()))
        );
        assertions.assertTrue(
            address(combinators),
            _calc(Combinators.CalcOp.And, address(combinators), sumIs60, address(combinators), notPaused)
        );
    }

    // ============ Bitwise (calc: And/Or/Xor/Shl/Shr + unary: Not) ============

    function test_calc_bitwise_andOrXor() public view {
        // 42 = 0b101010, 18 = 0b010010
        bytes memory a = abi.encodeCall(MockTarget.getValue, ());
        bytes memory b = abi.encodeCall(MockToken.decimals, ());
        assertEq(combinators.calc(Combinators.CalcOp.And, address(target), a, address(token), b), 2);
        assertEq(combinators.calc(Combinators.CalcOp.Or, address(target), a, address(token), b), 58);
        assertEq(combinators.calc(Combinators.CalcOp.Xor, address(target), a, address(token), b), 56);
    }

    function test_calc_shifts() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        assertEq(
            combinators.calc(Combinators.CalcOp.Shl, address(target), a, address(combinators), _constU(2)),
            168
        );
        assertEq(
            combinators.calc(Combinators.CalcOp.Shr, address(target), a, address(combinators), _constU(1)),
            21
        );
    }

    function test_calc_shiftOfWidthOrMore_yieldsZero() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        assertEq(
            combinators.calc(Combinators.CalcOp.Shl, address(target), a, address(combinators), _constU(256)),
            0
        );
        assertEq(
            combinators.calc(Combinators.CalcOp.Shr, address(target), a, address(combinators), _constU(300)),
            0
        );
    }

    function test_unary_not() public view {
        assertEq(
            combinators.unary(Combinators.UnaryOp.Not, address(combinators), _constU(0)),
            type(uint256).max
        );
        assertEq(
            combinators.unary(Combinators.UnaryOp.Not, address(token), abi.encodeCall(MockToken.maxUint, ())),
            0
        );
    }

    function test_calc_bitmaskPattern() public view {
        // Packed config word 0b1010: assert `config & 0b10 != 0` and `(config >> 3) & 1 == 1`
        bytes memory config = _constU(10);
        assertions.assertNeCallUint(
            address(combinators),
            _calc(Combinators.CalcOp.And, address(combinators), config, address(combinators), _constU(2)),
            0
        );
        bytes memory shifted = _calc(
            Combinators.CalcOp.Shr, address(combinators), config, address(combinators), _constU(3)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calc(Combinators.CalcOp.And, address(combinators), shifted, address(combinators), _constU(1)),
            1
        );
    }

    // ============ Hashing (data: Hash) ============

    function test_data_hash_tupleReturn() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getTuple, ()));
        bytes32 expected = keccak256(
            abi.encode(uint256(42), address(0xBEEF), true, keccak256("test"))
        );
        assertEq(
            _staticBytes32(_dataCall(Combinators.DataOp.Hash, address(target), calls, "", 0)),
            expected
        );
        assertions.assertEqCallBytes32(
            address(combinators),
            _dataCall(Combinators.DataOp.Hash, address(target), calls, "", 0),
            expected
        );
    }

    function test_data_hash_chained() public view {
        bytes[] memory calls = _pair(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.symbol, ())
        );
        bytes32 expected = keccak256(abi.encode(string("WETH")));
        assertEq(
            _staticBytes32(_dataCall(Combinators.DataOp.Hash, address(target), calls, "", 0)),
            expected
        );
        assertions.assertEqCallBytes32(
            address(combinators),
            _dataCall(Combinators.DataOp.Hash, address(target), calls, "", 0),
            expected
        );
    }

    function test_data_emptyCalls_reverts() public {
        vm.expectRevert(Combinators.EmptyCallChain.selector);
        combinators.data(Combinators.DataOp.Hash, address(target), new bytes[](0), "", 0);
    }

    // ============ String Split (data: Split) ============

    function _splitCall(address start, bytes[] memory calls, bytes memory delim, int256 index)
        internal
        pure
        returns (bytes memory)
    {
        return _dataCall(Combinators.DataOp.Split, start, calls, delim, index);
    }

    function test_data_split_wordCheck() public view {
        // "Curve LP Token" split by " " -> segment 1 is "LP"
        assertEq(
            _staticString(_splitCall(address(token), _single(abi.encodeCall(MockToken.name, ())), " ", 1)),
            "LP"
        );
    }

    function test_data_split_versionCheck() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(_staticString(_splitCall(address(target), calls, ".", 0)), "2");
        assertEq(_staticString(_splitCall(address(target), calls, ".", 1)), "1");
        assertEq(_staticString(_splitCall(address(target), calls, ".", 2)), "0");
    }

    function test_data_split_adjacentDelimiters_emptySegments() public {
        target.setString("a,,b");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(_staticString(_splitCall(address(target), calls, ",", 0)), "a");
        assertEq(_staticString(_splitCall(address(target), calls, ",", 1)), "");
        assertEq(_staticString(_splitCall(address(target), calls, ",", 2)), "b");
        // Trailing delimiter also yields an empty final segment
        target.setString("a,");
        assertEq(_staticString(_splitCall(address(target), calls, ",", 1)), "");
    }

    function test_data_split_multiByteDelimiter() public {
        target.setString("red, green, blue");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(_staticString(_splitCall(address(target), calls, ", ", 1)), "green");
        assertEq(_staticString(_splitCall(address(target), calls, ", ", 2)), "blue");
    }

    function test_data_split_delimiterAbsent_wholeString() public view {
        // storedString defaults to "hello"; no delimiter -> one segment
        assertEq(
            _staticString(_splitCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), ",", 0)),
            "hello"
        );
    }

    function test_data_split_indexOutOfRange_reverts() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, 3, 3)
        );
        combinators.data(Combinators.DataOp.Split, address(target), calls, ".", 3);
    }

    function test_data_split_delimiterAbsent_indexOutOfRange_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, 1, 1)
        );
        combinators.data(
            Combinators.DataOp.Split, address(target), _single(abi.encodeCall(MockTarget.getString, ())), ",", 1
        );
    }

    function test_data_split_emptyDelimiter_reverts() public {
        vm.expectRevert(Combinators.EmptyDelimiter.selector);
        combinators.data(
            Combinators.DataOp.Split, address(target), _single(abi.encodeCall(MockTarget.getString, ())), "", 0
        );
    }

    function test_data_split_negativeIndex_fromEnd() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        assertEq(_staticString(_splitCall(address(target), calls, ".", -1)), "0");
        assertEq(_staticString(_splitCall(address(target), calls, ".", -2)), "1");
        assertEq(_staticString(_splitCall(address(target), calls, ".", -3)), "2");
    }

    function test_data_split_negativeIndex_endsWith_composed() public view {
        // "the name ends with Token": last space-segment of "Curve LP Token"
        assertions.assertEqCallStringN(
            address(combinators),
            _splitCall(address(token), _single(abi.encodeCall(MockToken.name, ())), " ", -1),
            0,
            "Token"
        );
    }

    function test_data_split_negativeIndex_outOfRange_reverts() public {
        target.setString("2.1.0");
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.SegmentIndexOutOfBounds.selector, int256(-4), uint256(3))
        );
        combinators.data(Combinators.DataOp.Split, address(target), calls, ".", -4);
    }

    function test_data_split_negativeIndex_delimiterAbsent_wholeString() public {
        target.setString("hello");
        assertEq(
            _staticString(
                _splitCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), ",", -1)
            ),
            "hello"
        );
    }

    function test_data_split_chained() public view {
        // target.token().name() -> "Curve LP Token", segment 1 is "LP"
        assertEq(
            _staticString(
                _splitCall(
                    address(target),
                    _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.name, ())),
                    " ",
                    1
                )
            ),
            "LP"
        );
    }

    function test_data_split_composed_endToEnd() public view {
        // Split returns a normal ABI-encoded string, so the string assertion
        // consumes it directly (index 0 decodes a plain string return)
        assertions.assertEqCallStringN(
            address(combinators),
            _splitCall(address(token), _single(abi.encodeCall(MockToken.name, ())), " ", 1),
            0,
            "LP"
        );
    }

    function test_data_split_composed_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedString.selector, "EQ_N", "LP", "WETH")
        );
        assertions.assertEqCallStringN(
            address(combinators),
            _splitCall(address(token), _single(abi.encodeCall(MockToken.name, ())), " ", 1),
            0,
            "WETH"
        );
    }

    // ============ String Inclusion (data: Includes) ============

    function _includesCall(address start, bytes[] memory calls, bytes memory part)
        internal
        pure
        returns (bytes memory)
    {
        return _dataCall(Combinators.DataOp.Includes, start, calls, part, 0);
    }

    function test_data_includes_found() public view {
        // token.name() -> "Curve LP Token": middle, start, end, whole string
        bytes[] memory calls = _single(abi.encodeCall(MockToken.name, ()));
        assertTrue(_staticBool(_includesCall(address(token), calls, "LP")));
        assertTrue(_staticBool(_includesCall(address(token), calls, "Curve")));
        assertTrue(_staticBool(_includesCall(address(token), calls, "Token")));
        assertTrue(_staticBool(_includesCall(address(token), calls, "Curve LP Token")));
    }

    function test_data_includes_notFound_caseSensitive() public view {
        bytes[] memory calls = _single(abi.encodeCall(MockToken.name, ()));
        assertFalse(_staticBool(_includesCall(address(token), calls, "Sushi")));
        assertFalse(_staticBool(_includesCall(address(token), calls, "lp")));
    }

    function test_data_includes_needleLongerThanString() public {
        target.setString("ab");
        assertFalse(
            _staticBool(_includesCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), "abc"))
        );
    }

    function test_data_includes_emptyString() public {
        target.setString("");
        assertFalse(
            _staticBool(_includesCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), "a"))
        );
    }

    function test_data_includes_emptyPart_reverts() public {
        vm.expectRevert(Combinators.EmptySubstring.selector);
        combinators.data(
            Combinators.DataOp.Includes, address(target), _single(abi.encodeCall(MockTarget.getString, ())), "", 0
        );
    }

    function test_data_includes_chained() public view {
        // target.token().name() -> "Curve LP Token"
        assertTrue(
            _staticBool(
                _includesCall(
                    address(target),
                    _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.name, ())),
                    "LP"
                )
            )
        );
    }

    function test_data_includes_composed_endToEnd() public view {
        assertions.assertTrue(
            address(combinators),
            _includesCall(address(token), _single(abi.encodeCall(MockToken.name, ())), "LP")
        );
    }

    function test_data_includes_negated_composed() public view {
        // "the name does NOT mention Sushi" via unary(IsZero)
        assertions.assertTrue(
            address(combinators),
            abi.encodeCall(
                Combinators.unary,
                (
                    Combinators.UnaryOp.IsZero,
                    address(combinators),
                    _includesCall(address(token), _single(abi.encodeCall(MockToken.name, ())), "Sushi")
                )
            )
        );
    }

    function test_data_includes_composed_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedBool.selector, "TRUE", false, true)
        );
        assertions.assertTrue(
            address(combinators),
            _includesCall(address(token), _single(abi.encodeCall(MockToken.name, ())), "Sushi")
        );
    }

    // ============ Character Set (data: Charset) ============

    /// @dev Builds a charset bitmap covering byte values lo..hi inclusive
    function _maskRange(bytes1 lo, bytes1 hi) internal pure returns (uint256 m) {
        for (uint256 b = uint8(lo); b <= uint8(hi); b++) {
            m |= 1 << b;
        }
    }

    function _charsetCall(address start, bytes[] memory calls, uint256 mask)
        internal
        pure
        returns (bytes memory)
    {
        return _dataCall(Combinators.DataOp.Charset, start, calls, abi.encodePacked(bytes32(mask)), 0);
    }

    function test_data_charset_lowercaseOnly() public {
        target.setString("weth");
        assertTrue(
            _staticBool(
                _charsetCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), _maskRange("a", "z"))
            )
        );
    }

    function test_data_charset_uppercase_fails() public view {
        // token.symbol() -> "WETH"
        assertFalse(
            _staticBool(
                _charsetCall(address(token), _single(abi.encodeCall(MockToken.symbol, ())), _maskRange("a", "z"))
            )
        );
    }

    function test_data_charset_documentedLowercaseMask() public pure {
        // the mask the natspec documents for a-z equals the range-built one
        assertEq(_maskRange("a", "z"), 0x07fffffe << 96);
    }

    function test_data_charset_composedMask() public {
        bytes[] memory calls = _single(abi.encodeCall(MockTarget.getString, ()));
        uint256 mask = _maskRange("a", "z") | _maskRange("0", "9") | (uint256(1) << uint8(bytes1("-")));
        target.setString("curve-lp-01");
        assertTrue(_staticBool(_charsetCall(address(target), calls, mask)));
        // space is not in the set
        target.setString("curve lp");
        assertFalse(_staticBool(_charsetCall(address(target), calls, mask)));
    }

    function test_data_charset_emptyString_vacuouslyTrue() public {
        target.setString("");
        assertTrue(
            _staticBool(_charsetCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), 0))
        );
    }

    function test_data_charset_utf8_failsAsciiMask() public {
        // every byte of a multi-byte UTF-8 character is >= 0x80
        target.setString(unicode"café");
        assertFalse(
            _staticBool(
                _charsetCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), _maskRange("a", "z"))
            )
        );
    }

    function test_data_charset_chained() public view {
        // target.token().underlying().symbol() -> "DAI" is NOT lowercase
        assertFalse(
            _staticBool(
                _charsetCall(
                    address(target),
                    _triple(
                        abi.encodeCall(MockTarget.token, ()),
                        abi.encodeCall(MockToken.underlying, ()),
                        abi.encodeCall(MockToken.symbol, ())
                    ),
                    _maskRange("a", "z")
                )
            )
        );
    }

    function test_data_charset_composed_endToEnd() public {
        target.setString("weth");
        assertions.assertTrue(
            address(combinators),
            _charsetCall(address(target), _single(abi.encodeCall(MockTarget.getString, ())), _maskRange("a", "z"))
        );
    }

    function test_data_charset_composed_fails() public {
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.AssertionFailedBool.selector, "TRUE", false, true)
        );
        assertions.assertTrue(
            address(combinators),
            _charsetCall(address(token), _single(abi.encodeCall(MockToken.symbol, ())), _maskRange("a", "z"))
        );
    }

    function test_data_charset_badMaskLength_reverts() public {
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidMaskLength.selector, 3));
        combinators.data(
            Combinators.DataOp.Charset,
            address(token),
            _single(abi.encodeCall(MockToken.symbol, ())),
            hex"ffffff",
            0
        );
    }

    // ============ Exponentiation (CalcOp.Exp) ============

    function test_calc_exp_success() public view {
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Exp, address(combinators), _constU(2), address(combinators), _constU(10)
            ),
            1024
        );
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Exp, address(combinators), _constU(10), address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            1e18
        );
    }

    function test_calc_exp_edgeCases() public view {
        // x ** 0 == 1 and 0 ** 0 == 1 per EVM semantics
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Exp, address(combinators), _constU(7), address(combinators), _constU(0)
            ),
            1
        );
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Exp, address(combinators), _constU(0), address(combinators), _constU(0)
            ),
            1
        );
    }

    function test_calc_exp_overflow_reverts() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        combinators.calc(
            Combinators.CalcOp.Exp, address(combinators), _constU(2), address(combinators), _constU(256)
        );
    }

    function test_exp_canonicalExample_decimalsScaling() public view {
        // whaleBalance() >= 5 * 10 ** token.decimals(), judged through the core
        bytes memory scale = _calc(
            Combinators.CalcOp.Exp,
            address(combinators),
            _constU(10),
            address(token),
            abi.encodeCall(MockToken.decimals, ())
        );
        bytes memory threshold = _calc(
            Combinators.CalcOp.Mul, address(combinators), _constU(5), address(combinators), scale
        );
        assertions.assertEqCallBool(
            address(combinators),
            _calc(
                Combinators.CalcOp.Ge,
                address(token),
                abi.encodeCall(MockToken.whaleBalance, ()),
                address(combinators),
                threshold
            ),
            true
        );
    }

    // ============ Raw Word Extraction (read raw mode) ============

    function test_read_rawWord_extractsTupleWords() public view {
        bytes memory call = abi.encodeCall(MockToken.getReserves, ());
        assertEq(_staticUint(_wordData(address(token), call, 0)), 5000e18);
        assertEq(_staticUint(_wordData(address(token), call, 1)), 1000e18);
        assertEq(_staticUint(_wordData(address(token), call, 2)), 123456);
    }

    function test_read_rawWord_chained() public view {
        // target.token() -> token.getReserves(), word 1
        bytes[] memory calls = _pair(
            abi.encodeCall(MockTarget.token, ()),
            abi.encodeCall(MockToken.getReserves, ())
        );
        assertEq(_staticUint(_wordDataChain(address(target), calls, 1)), 1000e18);
    }

    function test_read_rawWord_indexOutOfRange_reverts() public {
        vm.expectRevert(abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 3, 96));
        (bool ok, ) = address(combinators).staticcall(
            _wordData(address(token), abi.encodeCall(MockToken.getReserves, ()), 3)
        );
        ok;
    }

    function test_read_rawWord_negativeIndex_fromEnd() public view {
        bytes memory call = abi.encodeCall(MockToken.getReserves, ());
        assertEq(_staticUint(_wordData(address(token), call, -1)), 123456);
        assertEq(_staticUint(_wordData(address(token), call, -2)), 1000e18);
        assertEq(_staticUint(_wordData(address(token), call, -3)), 5000e18);
    }

    function test_read_rawWord_negativeIndex_lastArrayElement() public view {
        // getArray() -> [10, 20, 30, 40, 50]: raw words are offset, length,
        // items — -1 is the last item however long the live array is
        assertEq(_staticUint(_wordData(address(target), abi.encodeCall(MockTarget.getArray, ()), -1)), 50);
    }

    function test_read_rawWord_negativeIndex_outOfRange_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, int256(-4), uint256(96))
        );
        (bool ok, ) = address(combinators).staticcall(
            _wordData(address(token), abi.encodeCall(MockToken.getReserves, ()), -4)
        );
        ok;
    }

    function test_read_rawWord_multiEntryPath_reverts() public {
        string[] memory types_ = new string[](1);
        int256[][] memory paths = new int256[][](1);
        paths[0] = _p2(0, 1);
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(0)));
        combinators.read(
            address(token), _single(abi.encodeCall(MockToken.getReserves, ())), types_, paths
        );
    }

    function test_read_rawWord_canonicalExample_reservesRatio() public view {
        // reserve0 / reserve1 >= 5, judged through the core
        bytes memory reservesCall = abi.encodeCall(MockToken.getReserves, ());
        bytes memory ratio = _calc(
            Combinators.CalcOp.Div,
            address(combinators),
            _wordData(address(token), reservesCall, 0),
            address(combinators),
            _wordData(address(token), reservesCall, 1)
        );
        assertions.assertEqCallBool(
            address(combinators),
            _calc(Combinators.CalcOp.Ge, address(combinators), ratio, address(combinators), _constU(5)),
            true
        );
    }

    // ============ Typed Navigation (read typed mode) ============

    function test_read_nav_tupleWithArray() public view {
        bytes memory call = abi.encodeCall(MockToken.signers, ());
        string memory t = "(address[],address)";
        assertEq(_staticUint(_navData(address(token), call, t, _p2(0, 0))), uint256(0xaaa1));
        assertEq(_staticUint(_navData(address(token), call, t, _p2(0, 1))), uint256(0xaaa2));
        assertEq(_staticUint(_navData(address(token), call, t, _p2(0, -1))), uint256(0xaaa3));
        // a single-step path selects the static return value itself
        assertEq(_staticUint(_navData(address(token), call, t, _p1(1))), uint256(0xb055));
    }

    function test_read_nav_nestedArrays() public view {
        // matrix() -> [[0xaaa1, 0xaaa2], [0xbbb1, 0xbbb2, 0xbbb3], []]
        bytes memory call = abi.encodeCall(MockToken.matrix, ());
        string memory t = "(address[][])";
        assertEq(_staticUint(_navData(address(token), call, t, _p3(0, 0, 1))), uint256(0xaaa2));
        assertEq(_staticUint(_navData(address(token), call, t, _p3(0, 1, 2))), uint256(0xbbb3));
        assertEq(_staticUint(_navData(address(token), call, t, _p3(0, -2, -1))), uint256(0xbbb3));
    }

    function test_read_nav_structArray() public view {
        // proposals() -> [(0xcafe1, 41, false), (0xcafe2, 99, true)]
        bytes memory call = abi.encodeCall(MockToken.proposals, ());
        string memory t = "((address,uint256,bool)[])";
        assertEq(_staticUint(_navData(address(token), call, t, _p3(0, 0, 1))), 41);
        assertEq(_staticUint(_navData(address(token), call, t, _p3(0, 1, 0))), uint256(0xcafe2));
        assertEq(_staticUint(_navData(address(token), call, t, _p3(0, -1, 2))), 1);
    }

    function test_read_nav_multiWordStaticHead() public view {
        // mixed() -> (uint256[2] [11, 22], address[] [0xddd1, 0xddd2]): the
        // fixed array occupies TWO head words, so the dynamic array's offset
        // sits at head word 2 — derived from the declared type
        bytes memory call = abi.encodeCall(MockToken.mixed, ());
        string memory t = "(uint256[2],address[])";
        assertEq(_staticUint(_navData(address(token), call, t, _p2(0, 1))), 22);
        assertEq(_staticUint(_navData(address(token), call, t, _p2(1, 0))), uint256(0xddd1));
        assertEq(_staticUint(_navData(address(token), call, t, _p2(1, -1))), uint256(0xddd2));
    }

    function test_read_nav_indexOutOfBounds_reverts() public {
        bytes memory call = abi.encodeCall(MockToken.signers, ());
        string memory t = "(address[],address)";
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, int256(3), uint256(3))
        );
        (bool ok1, ) = address(combinators).staticcall(_navData(address(token), call, t, _p2(0, 3)));
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, int256(-4), uint256(3))
        );
        (bool ok2, ) = address(combinators).staticcall(_navData(address(token), call, t, _p2(0, -4)));
        // tuple component out of range reports the component count
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, int256(2), uint256(2))
        );
        (bool ok3, ) = address(combinators).staticcall(_navData(address(token), call, t, _p1(2)));
        (ok1, ok2, ok3);
    }

    function test_read_nav_emptyInnerArray_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ElementIndexOutOfBounds.selector, int256(0), uint256(0))
        );
        (bool ok, ) = address(combinators).staticcall(
            _navData(address(token), abi.encodeCall(MockToken.matrix, ()), "(address[][])", _p3(0, 2, 0))
        );
        ok;
    }

    function test_read_nav_nonComposite_step_reverts() public {
        // path [1, 0] steps into the plain address return value
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(11)));
        (bool ok, ) = address(combinators).staticcall(
            _navData(address(token), abi.encodeCall(MockToken.signers, ()), "(address[],address)", _p2(1, 0))
        );
        ok;
    }

    function test_read_nav_malformedDescriptor_reverts() public {
        bytes memory call = abi.encodeCall(MockToken.signers, ());
        // unbalanced tuple
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(9)));
        (bool ok1, ) = address(combinators).staticcall(_navData(address(token), call, "(address[", _p1(0)));
        // top-level type must be a parenthesized return tuple
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(0)));
        (bool ok2, ) = address(combinators).staticcall(_navData(address(token), call, "address[]", _p1(0)));
        (ok1, ok2);
    }

    function test_read_nav_truncatedData_reverts() public {
        // descriptor claims three words, decimals() returns one
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, int256(2), uint256(32))
        );
        (bool ok, ) = address(combinators).staticcall(
            _navData(address(token), abi.encodeCall(MockToken.decimals, ()), "(uint256,uint256,uint256)", _p1(2))
        );
        ok;
    }

    function test_read_nav_emptyPath_isPassthrough() public view {
        // An empty path ignores the descriptor and passes the returndata through
        (bool ok, bytes memory out) = address(combinators).staticcall(
            _navData(address(token), abi.encodeCall(MockToken.signers, ()), "(address[],address)", new int256[](0))
        );
        (bool okDirect, bytes memory direct) = address(token).staticcall(abi.encodeCall(MockToken.signers, ()));
        assertTrue(ok);
        assertTrue(okDirect);
        assertEq(out, direct);
    }

    function test_read_nav_composed_endToEnd() public view {
        // "the second signer is 0xaaa2", judged as an address by the core
        assertions.assertEqCallAddress(
            address(combinators),
            _navData(address(token), abi.encodeCall(MockToken.signers, ()), "(address[],address)", _p2(0, 1)),
            address(0xaaa2)
        );
    }

    // ============ Dynamic Terminals (read envelope returns) ============

    function test_read_dynamicTerminal_stringField_judgedByCore() public view {
        // items()[0].label == "Curve LP": the envelope decodes as a plain string
        assertions.assertEqCallStringN(
            address(combinators),
            _navData(address(token), abi.encodeCall(MockToken.items, ()), "((string,uint256)[])", _p3(0, 0, 0)),
            0,
            "Curve LP"
        );
    }

    function test_read_dynamicTerminal_arrayEnvelope_matchesAbiEncode() public view {
        // matrix()[0] comes back exactly as a contract returning that array
        address[] memory row = new address[](2);
        row[0] = address(0xaaa1);
        row[1] = address(0xaaa2);
        (bool ok, bytes memory out) = address(combinators).staticcall(
            _navData(address(token), abi.encodeCall(MockToken.matrix, ()), "(address[][])", _p2(0, 0))
        );
        assertTrue(ok);
        assertEq(out, abi.encode(row));
    }

    function test_read_dynamicTerminal_composesWithSplit() public view {
        // second word of items()[1].label ("Gauge Deposit") is "Deposit":
        // the read envelope self-chains as data(Split)'s call
        bytes[] memory inner = _single(
            _navData(address(token), abi.encodeCall(MockToken.items, ()), "((string,uint256)[])", _p3(0, 1, 0))
        );
        assertEq(_staticString(_splitCall(address(combinators), inner, " ", -1)), "Deposit");
    }

    function test_read_dynamicTerminal_composesWithHash() public view {
        // the envelope of matrix()[0] hashes like abi.encode of that array
        address[] memory row = new address[](2);
        row[0] = address(0xaaa1);
        row[1] = address(0xaaa2);
        bytes[] memory inner = _single(
            _navData(address(token), abi.encodeCall(MockToken.matrix, ()), "(address[][])", _p2(0, 0))
        );
        assertEq(
            _staticBytes32(_dataCall(Combinators.DataOp.Hash, address(combinators), inner, "", 0)),
            keccak256(abi.encode(row))
        );
    }

    function test_read_dynamicTerminal_arrayOfDynamicElements_reverts() public {
        // address[][] itself: elements are dynamic, extent not extractable
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(1)));
        (bool ok, ) = address(combinators).staticcall(
            _navData(address(token), abi.encodeCall(MockToken.matrix, ()), "(address[][])", _p1(0))
        );
        ok;
    }

    // ============ Decoded Lengths (read LEN sentinel) ============

    function test_read_len_array() public view {
        assertEq(
            _staticUint(
                _navData(address(target), abi.encodeCall(MockTarget.getArray, ()), "(uint256[])", _p2(0, LEN))
            ),
            5
        );
    }

    function test_read_len_emptyArray() public view {
        assertEq(
            _staticUint(
                _navData(address(target), abi.encodeCall(MockTarget.getEmptyArray, ()), "(uint256[])", _p2(0, LEN))
            ),
            0
        );
    }

    function test_read_len_stringByteLength() public view {
        // "Curve LP Token" is 14 bytes; string returns share the dynamic encoding
        assertEq(
            _staticUint(_navData(address(token), abi.encodeCall(MockToken.name, ()), "(string)", _p2(0, LEN))),
            14
        );
    }

    function test_read_len_nested() public view {
        // matrix()[1] has three elements — a nested length no v1 combinator could reach
        assertEq(
            _staticUint(
                _navData(address(token), abi.encodeCall(MockToken.matrix, ()), "(address[][])", _p3(0, 1, LEN))
            ),
            3
        );
        // and the byte length of a string inside a struct array
        assertEq(
            _staticUint(
                _navData(
                    address(token), abi.encodeCall(MockToken.items, ()), "((string,uint256)[])", _p2(0, LEN)
                )
            ),
            2
        );
    }

    function test_read_len_chained() public view {
        // target.token() -> token.holders(): 3 addresses, decoded element count
        string[] memory types_ = new string[](2);
        types_[1] = "(address[])";
        int256[][] memory paths = new int256[][](2);
        paths[1] = _p2(0, LEN);
        assertEq(
            _staticUint(
                abi.encodeCall(
                    Combinators.read,
                    (
                        address(target),
                        _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.holders, ())),
                        types_,
                        paths
                    )
                )
            ),
            3
        );
    }

    function test_read_len_asOperand_composed() public view {
        // holders().length * 100 >= 300, judged through the core
        string[] memory types_ = new string[](2);
        types_[1] = "(address[])";
        int256[][] memory paths = new int256[][](2);
        paths[1] = _p2(0, LEN);
        bytes memory lenData = abi.encodeCall(
            Combinators.read,
            (
                address(target),
                _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.holders, ())),
                types_,
                paths
            )
        );
        assertions.assertGeCallUint(
            address(combinators),
            _calc(Combinators.CalcOp.Mul, address(combinators), lenData, address(combinators), _constU(100)),
            300
        );
    }

    function test_read_len_staticTerminal_reverts() public {
        // getValue() returns a plain word — nothing has a length there
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(1)));
        (bool ok, ) = address(combinators).staticcall(
            _navData(address(target), abi.encodeCall(MockTarget.getValue, ()), "(uint256)", _p2(0, LEN))
        );
        ok;
    }

    function test_read_len_bareSentinel_reverts() public {
        // LEN must follow at least one navigation step
        vm.expectRevert(abi.encodeWithSelector(Combinators.InvalidNavigation.selector, uint256(0)));
        (bool ok, ) = address(combinators).staticcall(
            _navData(address(target), abi.encodeCall(MockTarget.getArray, ()), "(uint256[])", _p1(LEN))
        );
        ok;
    }

    // ============ Raw Byte Length (data: ByteLen) ============

    function test_data_byteLen_arrayEncoding() public view {
        // uint256[](5): offset word + length word + 5 items = 224 bytes
        assertEq(
            _staticUint(
                _dataCall(
                    Combinators.DataOp.ByteLen, address(target), _single(abi.encodeCall(MockTarget.getArray, ())), "", 0
                )
            ),
            224
        );
    }

    function test_data_byteLen_chained() public view {
        // target.token() -> token.holders() (3 addresses): 64 + 3 * 32 = 160
        assertEq(
            _staticUint(
                _dataCall(
                    Combinators.DataOp.ByteLen,
                    address(target),
                    _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.holders, ())),
                    "",
                    0
                )
            ),
            160
        );
    }

    function test_data_byteLen_insideArithmetic() public view {
        // item count = (byteLen - 64) / 32 = 5, judged through the core
        bytes memory byteLen = _dataCall(
            Combinators.DataOp.ByteLen, address(target), _single(abi.encodeCall(MockTarget.getArray, ())), "", 0
        );
        bytes memory bytesMinusHead = _calc(
            Combinators.CalcOp.Sub, address(combinators), byteLen, address(combinators), _constU(64)
        );
        assertions.assertEqCallUint(
            address(combinators),
            _calc(Combinators.CalcOp.Div, address(combinators), bytesMinusHead, address(combinators), _constU(32)),
            5
        );
    }

    // ============ Bool as Word (conditional select without a bridge) ============

    function test_boolWord_directOperand() public view {
        // A bool return IS a 0/1 word: calc consumes it with no bridge call
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Mul,
                address(token),
                abi.encodeCall(MockToken.active, ()),
                address(combinators),
                _constU(100)
            ),
            100
        );
        assertEq(
            combinators.calc(
                Combinators.CalcOp.Mul,
                address(token),
                abi.encodeCall(MockToken.paused, ()),
                address(combinators),
                _constU(100)
            ),
            0
        );
    }

    /// @dev Encodes the conditional-select idiom cond * a + (1 - cond) * b,
    ///      with the bool call used directly as a numeric operand
    function _select(address condTarget, bytes memory cond, uint256 a, uint256 b)
        internal
        view
        returns (bytes memory)
    {
        bytes memory condTimesA = _calc(
            Combinators.CalcOp.Mul, condTarget, cond, address(combinators), _constU(a)
        );
        bytes memory oneMinusCond = _calc(
            Combinators.CalcOp.Sub, address(combinators), _constU(1), condTarget, cond
        );
        bytes memory notCondTimesB = _calc(
            Combinators.CalcOp.Mul, address(combinators), oneMinusCond, address(combinators), _constU(b)
        );
        return _calc(
            Combinators.CalcOp.Add, address(combinators), condTimesA, address(combinators), notCondTimesB
        );
    }

    function test_conditionalSelect_trueBranch() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _select(address(token), abi.encodeCall(MockToken.active, ()), 100, 200),
            100
        );
    }

    function test_conditionalSelect_falseBranch() public view {
        assertions.assertEqCallUint(
            address(combinators),
            _select(address(token), abi.encodeCall(MockToken.paused, ()), 100, 200),
            200
        );
    }

    // ============ Min / Max / AbsDiff ============

    function test_calc_minMaxAbsDiff_unsigned() public view {
        bytes memory a = abi.encodeCall(MockTarget.getValue, ()); // 42
        bytes memory b = abi.encodeCall(MockToken.decimals, ());  // 18
        assertEq(combinators.calc(Combinators.CalcOp.Min, address(target), a, address(token), b), 18);
        assertEq(combinators.calc(Combinators.CalcOp.Max, address(target), a, address(token), b), 42);
        assertEq(combinators.calc(Combinators.CalcOp.AbsDiff, address(target), a, address(token), b), 24);
        // AbsDiff is symmetric: the smaller operand first must not underflow
        assertEq(combinators.calc(Combinators.CalcOp.AbsDiff, address(token), b, address(target), a), 24);
    }

    function test_calc_absDiff_liveApproxEq_composed() public view {
        // |target.getValue() - token.decimals()| <= 30: live-vs-live approximate
        // equality, which the core's ApproxEq (constant expected side) cannot express
        assertions.assertLeCallUint(
            address(combinators),
            _calc(
                Combinators.CalcOp.AbsDiff,
                address(target),
                abi.encodeCall(MockTarget.getValue, ()),
                address(token),
                abi.encodeCall(MockToken.decimals, ())
            ),
            30
        );
    }

    function test_calc_minMaxAbsDiff_signed() public view {
        bytes memory a = abi.encodeCall(MockTarget.getInt, ());      // -42
        bytes memory b = abi.encodeCall(MockToken.temperature, ());  // -7
        assertEq(int256(combinators.calc(Combinators.CalcOp.SMin, address(target), a, address(token), b)), -42);
        assertEq(int256(combinators.calc(Combinators.CalcOp.SMax, address(target), a, address(token), b)), -7);
        // SAbsDiff returns the magnitude as a uint256
        assertEq(combinators.calc(Combinators.CalcOp.SAbsDiff, address(target), a, address(token), b), 35);
        assertEq(combinators.calc(Combinators.CalcOp.SAbsDiff, address(token), b, address(target), a), 35);
    }

    function test_calc_absDiff_fullRange_total() public view {
        // Unsigned: |0 - maxUint| spans the whole word without underflow
        assertEq(
            combinators.calc(
                Combinators.CalcOp.AbsDiff,
                address(combinators),
                _constU(0),
                address(token),
                abi.encodeCall(MockToken.maxUint, ())
            ),
            type(uint256).max
        );
    }

    function test_calc_sabsDiff_widestSpan_total() public view {
        // |int256.max - int256.min| = 2^256 - 1: v1's checked signed AbsDiff
        // panicked here; the magnitude form is total
        assertEq(
            combinators.calc(
                Combinators.CalcOp.SAbsDiff,
                address(combinators),
                _constI(type(int256).max),
                address(combinators),
                _constI(type(int256).min)
            ),
            type(uint256).max
        );
        assertEq(
            combinators.calc(
                Combinators.CalcOp.SAbsDiff,
                address(combinators),
                _constI(type(int256).min),
                address(combinators),
                _constI(type(int256).max)
            ),
            type(uint256).max
        );
    }

    function test_calc_sabsDiff_toleranceCheck_composed() public view {
        // |temperature - (-9)| <= 5, an unsigned Le over the magnitude
        bytes memory dist = _calc(
            Combinators.CalcOp.SAbsDiff,
            address(token),
            abi.encodeCall(MockToken.temperature, ()),
            address(combinators),
            _constI(-9)
        );
        assertions.assertLeCallUint(address(combinators), dist, 5);
    }

    // ============ Resolved-Address Properties (unary: Balance / CodeHash) ============

    function test_unary_balance_single() public {
        vm.deal(address(0xBEEF), 3 ether);
        assertEq(
            combinators.unary(
                Combinators.UnaryOp.Balance, address(target), abi.encodeCall(MockTarget.getAddress, ())
            ),
            3 ether
        );
    }

    function test_unary_balance_chained_composed() public {
        // Balance of target.token() -> token.underlying(), judged through the
        // core: the chain nests as read calldata on the combinators contract
        vm.deal(address(underlyingToken), 1 ether);
        bytes memory chained = _readData(
            address(target),
            _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.underlying, ()))
        );
        assertions.assertEqCallUint(
            address(combinators),
            abi.encodeCall(Combinators.unary, (Combinators.UnaryOp.Balance, address(combinators), chained)),
            1 ether
        );
    }

    function test_unary_balance_emptyReturn_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.unary(Combinators.UnaryOp.Balance, address(token), abi.encodeCall(MockToken.emptyReturn, ()));
    }

    function test_unary_balance_revertingOperand_reverts() public {
        bytes memory failing = abi.encodeCall(MockToken.revertingHop, ());
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.CallFailed.selector, address(token), failing)
        );
        combinators.unary(Combinators.UnaryOp.Balance, address(token), failing);
    }

    function test_unary_balance_dirtyAddressWord_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.InvalidAddressWord.selector, 0, keccak256("test"))
        );
        combinators.unary(Combinators.UnaryOp.Balance, address(target), abi.encodeCall(MockTarget.getBytes32, ()));
    }

    function test_unary_codeHash_single() public view {
        assertEq(
            combinators.unary(Combinators.UnaryOp.CodeHash, address(target), abi.encodeCall(MockTarget.token, ())),
            uint256(address(token).codehash)
        );
    }

    function test_unary_codeHash_chained_composed() public view {
        // Code hash of target.token() -> token.underlying(), judged through the core
        bytes memory chained = _readData(
            address(target),
            _pair(abi.encodeCall(MockTarget.token, ()), abi.encodeCall(MockToken.underlying, ()))
        );
        assertions.assertEqCallBytes32(
            address(combinators),
            abi.encodeCall(Combinators.unary, (Combinators.UnaryOp.CodeHash, address(combinators), chained)),
            address(underlyingToken).codehash
        );
    }

    function test_unary_codeHash_emptyReturn_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(Combinators.ReturnDataOutOfBounds.selector, 0, 0)
        );
        combinators.unary(Combinators.UnaryOp.CodeHash, address(token), abi.encodeCall(MockToken.emptyReturn, ()));
    }
}
