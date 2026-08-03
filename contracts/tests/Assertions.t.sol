// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "./Mocks.sol";

contract AssertionsTest is Test {
    Assertions public assertions;
    MockTarget public target;

    // Test addresses
    address constant TEST_EOA = address(0x1234);
    address constant ANOTHER_ADDRESS = address(0x5678);

    function setUp() public {
        assertions = new Assertions();
        target = new MockTarget();
    }

    // ============ Uint256 Call Assertions ============

    function test_assertEqCallUint_success() public view {
        assertions.assertEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42
        );
    }

    function test_assertEqCallUint_withMessage_success() public view {
        assertions.assertEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42,
            "custom message"
        );
    }

    function test_assertEqCallUint_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ",
                42,
                100
            )
        );
        assertions.assertEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            100
        );
    }

    function test_assertNeCallUint_success() public view {
        assertions.assertNeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            100
        );
    }

    function test_assertNeCallUint_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "NE",
                42,
                42
            )
        );
        assertions.assertNeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42
        );
    }

    function test_assertGtCallUint_success() public view {
        assertions.assertGtCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            41
        );
    }

    function test_assertGtCallUint_boundary_reverts() public {
        // Equal should fail GT
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GT",
                42,
                42
            )
        );
        assertions.assertGtCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42
        );
    }

    function test_assertGtCallUint_greater_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GT",
                42,
                100
            )
        );
        assertions.assertGtCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            100
        );
    }

    function test_assertLtCallUint_success() public view {
        assertions.assertLtCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            43
        );
    }

    function test_assertLtCallUint_boundary_reverts() public {
        // Equal should fail LT
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LT",
                42,
                42
            )
        );
        assertions.assertLtCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42
        );
    }

    function test_assertGeCallUint_equal_success() public view {
        assertions.assertGeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42
        );
    }

    function test_assertGeCallUint_greater_success() public view {
        assertions.assertGeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            41
        );
    }

    function test_assertGeCallUint_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GE",
                42,
                100
            )
        );
        assertions.assertGeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            100
        );
    }

    function test_assertLeCallUint_equal_success() public view {
        assertions.assertLeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42
        );
    }

    function test_assertLeCallUint_less_success() public view {
        assertions.assertLeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            43
        );
    }

    function test_assertLeCallUint_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LE",
                42,
                10
            )
        );
        assertions.assertLeCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            10
        );
    }

    // ============ Address Call Assertions ============

    function test_assertEqCallAddress_success() public view {
        assertions.assertEqCallAddress(
            address(target),
            abi.encodeCall(MockTarget.getAddress, ()),
            address(0xBEEF)
        );
    }

    function test_assertEqCallAddress_withMessage_success() public view {
        assertions.assertEqCallAddress(
            address(target),
            abi.encodeCall(MockTarget.getAddress, ()),
            address(0xBEEF),
            "address check"
        );
    }

    function test_assertEqCallAddress_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedAddress.selector,
                "EQ",
                address(0xBEEF),
                address(0xDEAD)
            )
        );
        assertions.assertEqCallAddress(
            address(target),
            abi.encodeCall(MockTarget.getAddress, ()),
            address(0xDEAD)
        );
    }

    function test_assertNeCallAddress_success() public view {
        assertions.assertNeCallAddress(
            address(target),
            abi.encodeCall(MockTarget.getAddress, ()),
            address(0xDEAD)
        );
    }

    function test_assertNeCallAddress_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedAddress.selector,
                "NE",
                address(0xBEEF),
                address(0xBEEF)
            )
        );
        assertions.assertNeCallAddress(
            address(target),
            abi.encodeCall(MockTarget.getAddress, ()),
            address(0xBEEF)
        );
    }

    // ============ Bool Call Assertions ============

    function test_assertEqCallBool_true_success() public view {
        assertions.assertEqCallBool(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            true
        );
    }

    function test_assertEqCallBool_withMessage_success() public view {
        assertions.assertEqCallBool(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            true,
            "bool check"
        );
    }

    function test_assertEqCallBool_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBool.selector,
                "EQ",
                true,
                false
            )
        );
        assertions.assertEqCallBool(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            false
        );
    }

    function test_assertEqCallBool_false_success() public {
        target.setBool(false);
        assertions.assertEqCallBool(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            false
        );
    }

    // ============ Bytes32 Call Assertions ============

    function test_assertEqCallBytes32_success() public view {
        assertions.assertEqCallBytes32(
            address(target),
            abi.encodeCall(MockTarget.getBytes32, ()),
            keccak256("test")
        );
    }

    function test_assertEqCallBytes32_withMessage_success() public view {
        assertions.assertEqCallBytes32(
            address(target),
            abi.encodeCall(MockTarget.getBytes32, ()),
            keccak256("test"),
            "bytes32 check"
        );
    }

    function test_assertEqCallBytes32_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBytes32.selector,
                "EQ",
                keccak256("test"),
                keccak256("wrong")
            )
        );
        assertions.assertEqCallBytes32(
            address(target),
            abi.encodeCall(MockTarget.getBytes32, ()),
            keccak256("wrong")
        );
    }

    function test_assertNeCallBytes32_success() public view {
        assertions.assertNeCallBytes32(
            address(target),
            abi.encodeCall(MockTarget.getBytes32, ()),
            keccak256("other")
        );
    }

    function test_assertNeCallBytes32_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBytes32.selector,
                "NE",
                keccak256("test"),
                keccak256("test")
            )
        );
        assertions.assertNeCallBytes32(
            address(target),
            abi.encodeCall(MockTarget.getBytes32, ()),
            keccak256("test")
        );
    }

    // ============ Tuple-Indexed Assertions ============

    function test_assertEqCallUintN_success() public view {
        assertions.assertEqCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0, // index 0 is the uint256
            42
        );
    }

    function test_assertEqCallUintN_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ_N",
                42,
                100
            )
        );
        assertions.assertEqCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            100
        );
    }

    function test_assertGtCallUintN_success() public view {
        assertions.assertGtCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            41
        );
    }

    function test_assertLtCallUintN_success() public view {
        assertions.assertLtCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            43
        );
    }

    function test_assertGeCallUintN_success() public view {
        assertions.assertGeCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            42
        );
    }

    function test_assertLeCallUintN_success() public view {
        assertions.assertLeCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            42
        );
    }

    function test_assertEqCallAddressN_success() public view {
        assertions.assertEqCallAddressN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            1, // index 1 is the address
            address(0xBEEF)
        );
    }

    function test_assertNeCallAddressN_success() public view {
        assertions.assertNeCallAddressN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            1,
            address(0xDEAD)
        );
    }

    function test_assertEqCallBoolN_success() public view {
        assertions.assertEqCallBoolN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            2, // index 2 is the bool
            true
        );
    }

    function test_assertEqCallBytes32N_success() public view {
        assertions.assertEqCallBytes32N(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            3, // index 3 is the bytes32
            keccak256("test")
        );
    }

    // ============ Array Length Assertions ============

    function test_assertEqCallArrayLength_success() public view {
        assertions.assertEqCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            5
        );
    }

    function test_assertEqCallArrayLength_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ_LEN",
                5,
                10
            )
        );
        assertions.assertEqCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            10
        );
    }

    function test_assertGtCallArrayLength_success() public view {
        assertions.assertGtCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            4
        );
    }

    function test_assertGeCallArrayLength_success() public view {
        assertions.assertGeCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            5
        );
    }

    function test_assertEqCallArrayLength_empty_success() public view {
        assertions.assertEqCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getEmptyArray, ()),
            0
        );
    }

    // ============ Raw Bytes Assertions ============

    function test_assertEqCallBytes_success() public view {
        // The raw return from getRawUint() is abi.encode(uint256(12345))
        bytes memory expected = abi.encode(uint256(12345));
        assertions.assertEqCallBytes(
            address(target),
            abi.encodeCall(MockTarget.getRawUint, ()),
            expected
        );
    }

    function test_assertEqCallBytes_reverts() public {
        bytes memory wrongExpected = abi.encode(uint256(99999));
        bytes memory actualBytes = abi.encode(uint256(12345));
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBytes.selector,
                "EQ_BYTES",
                keccak256(actualBytes),
                keccak256(wrongExpected)
            )
        );
        assertions.assertEqCallBytes(
            address(target),
            abi.encodeCall(MockTarget.getRawUint, ()),
            wrongExpected
        );
    }

    // ============ Approximate Equality Assertions ============

    function test_assertApproxEqCallUint_exact_success() public view {
        assertions.assertApproxEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            42,
            0 // exact match
        );
    }

    function test_assertApproxEqCallUint_withinDelta_success() public view {
        assertions.assertApproxEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            40, // actual is 42
            5   // delta of 2 is within 5
        );
    }

    function test_assertApproxEqCallUint_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedApprox.selector,
                "APPROX_EQ",
                42,    // actual
                30,    // expected
                12,    // delta
                5      // maxDelta
            )
        );
        assertions.assertApproxEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            30, // actual is 42, delta is 12
            5   // maxDelta is only 5
        );
    }

    function test_assertApproxEqCallUintN_success() public view {
        assertions.assertApproxEqCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,  // index
            40, // expected (actual is 42)
            5   // maxDelta
        );
    }

    // ============ ETH Balance Assertions ============

    function test_assertEqBalance_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertEqBalance(TEST_EOA, 1 ether);
    }

    function test_assertEqBalance_withMessage_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertEqBalance(TEST_EOA, 1 ether, "balance check");
    }

    function test_assertEqBalance_reverts() public {
        vm.deal(TEST_EOA, 1 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ_BAL",
                1 ether,
                2 ether
            )
        );
        assertions.assertEqBalance(TEST_EOA, 2 ether);
    }

    function test_assertGtBalance_success() public {
        vm.deal(TEST_EOA, 2 ether);
        assertions.assertGtBalance(TEST_EOA, 1 ether);
    }

    function test_assertGtBalance_reverts() public {
        vm.deal(TEST_EOA, 1 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GT_BAL",
                1 ether,
                2 ether
            )
        );
        assertions.assertGtBalance(TEST_EOA, 2 ether);
    }

    function test_assertLtBalance_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertLtBalance(TEST_EOA, 2 ether);
    }

    function test_assertLtBalance_reverts() public {
        vm.deal(TEST_EOA, 2 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LT_BAL",
                2 ether,
                1 ether
            )
        );
        assertions.assertLtBalance(TEST_EOA, 1 ether);
    }

    function test_assertGeBalance_equal_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertGeBalance(TEST_EOA, 1 ether);
    }

    function test_assertGeBalance_greater_success() public {
        vm.deal(TEST_EOA, 2 ether);
        assertions.assertGeBalance(TEST_EOA, 1 ether);
    }

    function test_assertGeBalance_reverts() public {
        vm.deal(TEST_EOA, 1 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GE_BAL",
                1 ether,
                2 ether
            )
        );
        assertions.assertGeBalance(TEST_EOA, 2 ether);
    }

    function test_assertLeBalance_equal_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertLeBalance(TEST_EOA, 1 ether);
    }

    function test_assertLeBalance_less_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertLeBalance(TEST_EOA, 2 ether);
    }

    function test_assertLeBalance_reverts() public {
        vm.deal(TEST_EOA, 2 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LE_BAL",
                2 ether,
                1 ether
            )
        );
        assertions.assertLeBalance(TEST_EOA, 1 ether);
    }

    function test_assertApproxEqBalance_success() public {
        vm.deal(TEST_EOA, 1 ether);
        assertions.assertApproxEqBalance(
            TEST_EOA,
            1.05 ether, // expected
            0.1 ether   // maxDelta
        );
    }

    function test_assertApproxEqBalance_reverts() public {
        vm.deal(TEST_EOA, 1 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedApprox.selector,
                "APPROX_EQ_BAL",
                1 ether,      // actual
                2 ether,      // expected
                1 ether,      // delta
                0.1 ether     // maxDelta
            )
        );
        assertions.assertApproxEqBalance(
            TEST_EOA,
            2 ether,
            0.1 ether
        );
    }

    // ============ Block Number Assertions ============

    function test_assertEqBlockNumber_success() public {
        vm.roll(12345);
        assertions.assertEqBlockNumber(12345);
    }

    function test_assertEqBlockNumber_withMessage_success() public {
        vm.roll(12345);
        assertions.assertEqBlockNumber(12345, "block check");
    }

    function test_assertEqBlockNumber_reverts() public {
        vm.roll(12345);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ_BLOCK",
                12345,
                99999
            )
        );
        assertions.assertEqBlockNumber(99999);
    }

    function test_assertGtBlockNumber_success() public {
        vm.roll(12345);
        assertions.assertGtBlockNumber(12344);
    }

    function test_assertGtBlockNumber_reverts() public {
        vm.roll(12345);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GT_BLOCK",
                12345,
                12345
            )
        );
        assertions.assertGtBlockNumber(12345);
    }

    function test_assertLtBlockNumber_success() public {
        vm.roll(12345);
        assertions.assertLtBlockNumber(12346);
    }

    function test_assertLtBlockNumber_reverts() public {
        vm.roll(12345);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LT_BLOCK",
                12345,
                12345
            )
        );
        assertions.assertLtBlockNumber(12345);
    }

    function test_assertGeBlockNumber_equal_success() public {
        vm.roll(12345);
        assertions.assertGeBlockNumber(12345);
    }

    function test_assertGeBlockNumber_greater_success() public {
        vm.roll(12345);
        assertions.assertGeBlockNumber(12344);
    }

    function test_assertGeBlockNumber_reverts() public {
        vm.roll(12345);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GE_BLOCK",
                12345,
                12346
            )
        );
        assertions.assertGeBlockNumber(12346);
    }

    function test_assertLeBlockNumber_equal_success() public {
        vm.roll(12345);
        assertions.assertLeBlockNumber(12345);
    }

    function test_assertLeBlockNumber_less_success() public {
        vm.roll(12345);
        assertions.assertLeBlockNumber(12346);
    }

    function test_assertLeBlockNumber_reverts() public {
        vm.roll(12345);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LE_BLOCK",
                12345,
                12344
            )
        );
        assertions.assertLeBlockNumber(12344);
    }

    // ============ Block Timestamp Assertions ============

    function test_assertEqBlockTimestamp_success() public {
        vm.warp(1700000000);
        assertions.assertEqBlockTimestamp(1700000000);
    }

    function test_assertEqBlockTimestamp_withMessage_success() public {
        vm.warp(1700000000);
        assertions.assertEqBlockTimestamp(1700000000, "timestamp check");
    }

    function test_assertEqBlockTimestamp_reverts() public {
        vm.warp(1700000000);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ_TIME",
                1700000000,
                1800000000
            )
        );
        assertions.assertEqBlockTimestamp(1800000000);
    }

    function test_assertGtBlockTimestamp_success() public {
        vm.warp(1700000000);
        assertions.assertGtBlockTimestamp(1699999999);
    }

    function test_assertGtBlockTimestamp_reverts() public {
        vm.warp(1700000000);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GT_TIME",
                1700000000,
                1700000000
            )
        );
        assertions.assertGtBlockTimestamp(1700000000);
    }

    function test_assertLtBlockTimestamp_success() public {
        vm.warp(1700000000);
        assertions.assertLtBlockTimestamp(1700000001);
    }

    function test_assertLtBlockTimestamp_reverts() public {
        vm.warp(1700000000);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LT_TIME",
                1700000000,
                1700000000
            )
        );
        assertions.assertLtBlockTimestamp(1700000000);
    }

    function test_assertGeBlockTimestamp_equal_success() public {
        vm.warp(1700000000);
        assertions.assertGeBlockTimestamp(1700000000);
    }

    function test_assertGeBlockTimestamp_greater_success() public {
        vm.warp(1700000000);
        assertions.assertGeBlockTimestamp(1699999999);
    }

    function test_assertGeBlockTimestamp_reverts() public {
        vm.warp(1700000000);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "GE_TIME",
                1700000000,
                1700000001
            )
        );
        assertions.assertGeBlockTimestamp(1700000001);
    }

    function test_assertLeBlockTimestamp_equal_success() public {
        vm.warp(1700000000);
        assertions.assertLeBlockTimestamp(1700000000);
    }

    function test_assertLeBlockTimestamp_less_success() public {
        vm.warp(1700000000);
        assertions.assertLeBlockTimestamp(1700000001);
    }

    function test_assertLeBlockTimestamp_reverts() public {
        vm.warp(1700000000);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LE_TIME",
                1700000000,
                1699999999
            )
        );
        assertions.assertLeBlockTimestamp(1699999999);
    }

    // ============ Chain ID Assertions ============

    function test_assertEqChainId_success() public view {
        // Default chain ID in foundry is 31337
        assertions.assertEqChainId(31337);
    }

    function test_assertEqChainId_withMessage_success() public view {
        assertions.assertEqChainId(31337, "chain check");
    }

    function test_assertEqChainId_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "EQ_CHAIN",
                31337,
                1
            )
        );
        assertions.assertEqChainId(1);
    }

    // ============ Contract Existence Assertions ============

    function test_assertHasCode_contract_success() public view {
        assertions.assertHasCode(address(target));
    }

    function test_assertHasCode_withMessage_success() public view {
        assertions.assertHasCode(address(target), "has code check");
    }

    function test_assertHasCode_eoa_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "HAS_CODE",
                0,
                1
            )
        );
        assertions.assertHasCode(TEST_EOA);
    }

    function test_assertNoCode_eoa_success() public view {
        assertions.assertNoCode(TEST_EOA);
    }

    function test_assertNoCode_withMessage_success() public view {
        assertions.assertNoCode(TEST_EOA, "no code check");
    }

    function test_assertNoCode_contract_reverts() public {
        vm.expectRevert(); // Contract has code, so size > 0
        assertions.assertNoCode(address(target));
    }

    function test_assertEqCodeHash_success() public view {
        bytes32 expectedHash = address(target).codehash;
        assertions.assertEqCodeHash(address(target), expectedHash);
    }

    function test_assertEqCodeHash_withMessage_success() public view {
        bytes32 expectedHash = address(target).codehash;
        assertions.assertEqCodeHash(address(target), expectedHash, "codehash check");
    }

    function test_assertEqCodeHash_reverts() public {
        bytes32 wrongHash = keccak256("wrong bytecode");
        bytes32 actualHash = address(target).codehash;
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBytes32.selector,
                "EQ_CODEHASH",
                actualHash,
                wrongHash
            )
        );
        assertions.assertEqCodeHash(address(target), wrongHash);
    }

    // ============ Call Failed Tests ============

    function test_callFailed_reverts() public {
        bytes memory callData = abi.encodeCall(MockTarget.revertingFunction, ());
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.CallFailed.selector,
                address(target),
                callData
            )
        );
        assertions.assertEqCallUint(
            address(target),
            callData,
            0
        );
    }

    function test_callFailed_nonExistentFunction_reverts() public {
        // Call a function that doesn't exist
        bytes memory callData = abi.encodeWithSignature("nonExistentFunction()");
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.CallFailed.selector,
                address(target),
                callData
            )
        );
        assertions.assertEqCallUint(
            address(target),
            callData,
            0
        );
    }

    // ============ Custom Message Tests ============

    function test_customMessage_appearsInError() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "my custom error message",
                42,
                100
            )
        );
        assertions.assertEqCallUint(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            100,
            "my custom error message"
        );
    }

    function test_customMessage_address() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedAddress.selector,
                "address mismatch",
                address(0xBEEF),
                address(0xDEAD)
            )
        );
        assertions.assertEqCallAddress(
            address(target),
            abi.encodeCall(MockTarget.getAddress, ()),
            address(0xDEAD),
            "address mismatch"
        );
    }

    function test_customMessage_bool() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBool.selector,
                "bool mismatch",
                true,
                false
            )
        );
        assertions.assertEqCallBool(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            false,
            "bool mismatch"
        );
    }

    function test_customMessage_bytes32() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBytes32.selector,
                "bytes32 mismatch",
                keccak256("test"),
                keccak256("wrong")
            )
        );
        assertions.assertEqCallBytes32(
            address(target),
            abi.encodeCall(MockTarget.getBytes32, ()),
            keccak256("wrong"),
            "bytes32 mismatch"
        );
    }

    // ============ Tuple-Indexed String Assertions ============

    function test_assertEqCallStringN_success() public view {
        assertions.assertEqCallStringN(
            address(target),
            abi.encodeCall(MockTarget.getTupleWithString, ()),
            1,
            "hello"
        );
    }

    function test_assertEqCallStringN_failure() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedString.selector,
                "EQ_N",
                "hello",
                "world"
            )
        );
        assertions.assertEqCallStringN(
            address(target),
            abi.encodeCall(MockTarget.getTupleWithString, ()),
            1,
            "world"
        );
    }

    // ============ assertTrue / assertFalse ============

    function test_assertTrue_success() public view {
        assertions.assertTrue(
            address(target),
            abi.encodeCall(MockTarget.getBool, ())
        );
    }

    function test_assertTrue_failure() public {
        target.setBool(false);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBool.selector,
                "TRUE",
                false,
                true
            )
        );
        assertions.assertTrue(
            address(target),
            abi.encodeCall(MockTarget.getBool, ())
        );
    }

    function test_assertTrue_withMessage() public view {
        assertions.assertTrue(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            "should be true"
        );
    }

    function test_assertFalse_success() public {
        target.setBool(false);
        assertions.assertFalse(
            address(target),
            abi.encodeCall(MockTarget.getBool, ())
        );
    }

    function test_assertFalse_failure() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedBool.selector,
                "FALSE",
                true,
                false
            )
        );
        assertions.assertFalse(
            address(target),
            abi.encodeCall(MockTarget.getBool, ())
        );
    }

    function test_assertFalse_withMessage() public {
        target.setBool(false);
        assertions.assertFalse(
            address(target),
            abi.encodeCall(MockTarget.getBool, ()),
            "should be false"
        );
    }

    // ============ Int256 Call Assertions ============

    function test_assertEqCallInt_success() public view {
        assertions.assertEqCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -42
        );
    }

    function test_assertEqCallInt_withMessage_success() public view {
        assertions.assertEqCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -42,
            "int check"
        );
    }

    function test_assertEqCallInt_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "EQ",
                -42,
                100
            )
        );
        assertions.assertEqCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            100
        );
    }

    function test_assertEqCallInt_customMessage_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "int mismatch",
                -42,
                0
            )
        );
        assertions.assertEqCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            0,
            "int mismatch"
        );
    }

    function test_assertNeCallInt_success() public view {
        assertions.assertNeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            42
        );
    }

    function test_assertNeCallInt_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "NE",
                -42,
                -42
            )
        );
        assertions.assertNeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -42
        );
    }

    function test_assertGtCallInt_negative_success() public view {
        // -42 > -100
        assertions.assertGtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -100
        );
    }

    function test_assertGtCallInt_boundary_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "GT",
                -42,
                -42
            )
        );
        assertions.assertGtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -42
        );
    }

    function test_assertLtCallInt_success() public view {
        // -42 < 0
        assertions.assertLtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            0
        );
    }

    function test_assertLtCallInt_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "LT",
                -42,
                -100
            )
        );
        assertions.assertLtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -100
        );
    }

    function test_assertGeCallInt_equal_success() public view {
        assertions.assertGeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -42
        );
    }

    function test_assertGeCallInt_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "GE",
                -42,
                0
            )
        );
        assertions.assertGeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            0
        );
    }

    function test_assertLeCallInt_equal_success() public view {
        assertions.assertLeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -42
        );
    }

    function test_assertLeCallInt_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "LE",
                -42,
                -100
            )
        );
        assertions.assertLeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            -100
        );
    }

    function test_assertEqCallInt_min_success() public {
        target.setInt(type(int256).min);
        assertions.assertEqCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            type(int256).min
        );
    }

    function test_assertGeCallInt_min_success() public {
        target.setInt(type(int256).min);
        assertions.assertGeCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            type(int256).min
        );
    }

    function test_assertLtCallInt_min_reverts() public {
        target.setInt(type(int256).min);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "LT",
                type(int256).min,
                type(int256).min
            )
        );
        assertions.assertLtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            type(int256).min
        );
    }

    function test_assertEqCallInt_max_success() public {
        target.setInt(type(int256).max);
        assertions.assertEqCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            type(int256).max
        );
    }

    function test_assertGtCallInt_max_reverts() public {
        target.setInt(type(int256).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "GT",
                type(int256).max,
                type(int256).max
            )
        );
        assertions.assertGtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            type(int256).max
        );
    }

    function test_assertGtCallInt_minToMax_success() public {
        target.setInt(type(int256).max);
        assertions.assertGtCallInt(
            address(target),
            abi.encodeCall(MockTarget.getInt, ()),
            type(int256).min
        );
    }

    // ============ Tuple-Indexed Int256 Assertions ============

    function test_assertEqCallIntN_success() public view {
        assertions.assertEqCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0, // index 0 is storedInt
            -42
        );
    }

    function test_assertEqCallIntN_withMessage_success() public view {
        assertions.assertEqCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            1, // index 1 is the constant 7
            7,
            "intN check"
        );
    }

    function test_assertEqCallIntN_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "EQ_N",
                -42,
                100
            )
        );
        assertions.assertEqCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            100
        );
    }

    function test_assertNeCallIntN_success() public view {
        assertions.assertNeCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            42
        );
    }

    function test_assertNeCallIntN_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "NE_N",
                -42,
                -42
            )
        );
        assertions.assertNeCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            -42
        );
    }

    function test_assertGtCallIntN_success() public view {
        assertions.assertGtCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            -100
        );
    }

    function test_assertLtCallIntN_success() public view {
        assertions.assertLtCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            0
        );
    }

    function test_assertGeCallIntN_equal_success() public view {
        assertions.assertGeCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            -42
        );
    }

    function test_assertLeCallIntN_equal_success() public view {
        assertions.assertLeCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            0,
            -42
        );
    }

    function test_assertLeCallIntN_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedInt.selector,
                "LE_N",
                7,
                -100
            )
        );
        assertions.assertLeCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            1,
            -100
        );
    }

    // ============ Tuple-Indexed Uint256 Ne Assertions ============

    function test_assertNeCallUintN_success() public view {
        assertions.assertNeCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            100
        );
    }

    function test_assertNeCallUintN_withMessage_success() public view {
        assertions.assertNeCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            100,
            "uintN ne check"
        );
    }

    function test_assertNeCallUintN_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "NE_N",
                42,
                42
            )
        );
        assertions.assertNeCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            0,
            42
        );
    }

    // ============ Array Length Lt/Le Assertions ============

    function test_assertLtCallArrayLength_success() public view {
        assertions.assertLtCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            6
        );
    }

    function test_assertLtCallArrayLength_boundary_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LT_LEN",
                5,
                5
            )
        );
        assertions.assertLtCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            5
        );
    }

    function test_assertLeCallArrayLength_equal_success() public view {
        assertions.assertLeCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            5
        );
    }

    function test_assertLeCallArrayLength_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.AssertionFailedUint.selector,
                "LE_LEN",
                5,
                4
            )
        );
        assertions.assertLeCallArrayLength(
            address(target),
            abi.encodeCall(MockTarget.getArray, ()),
            4
        );
    }

    // ============ Out-of-Range Index Assertions ============

    function test_assertEqCallUintN_indexOutOfRange_reverts() public {
        // getValue() returns a single 32-byte word, so index 1 is out of range
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.ReturnDataOutOfBounds.selector,
                1,
                32
            )
        );
        assertions.assertEqCallUintN(
            address(target),
            abi.encodeCall(MockTarget.getValue, ()),
            1,
            42
        );
    }

    function test_assertEqCallAddressN_indexOutOfRange_reverts() public {
        // getTuple() returns 4 words, so index 4 is out of range
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.ReturnDataOutOfBounds.selector,
                4,
                128
            )
        );
        assertions.assertEqCallAddressN(
            address(target),
            abi.encodeCall(MockTarget.getTuple, ()),
            4,
            address(0xBEEF)
        );
    }

    function test_assertEqCallIntN_indexOutOfRange_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.ReturnDataOutOfBounds.selector,
                2,
                64
            )
        );
        assertions.assertEqCallIntN(
            address(target),
            abi.encodeCall(MockTarget.getIntTuple, ()),
            2,
            0
        );
    }

    function test_assertEqCallStringN_indexOutOfRange_reverts() public {
        // getTupleWithString() returns 160 bytes (3 head words + string length + data)
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.ReturnDataOutOfBounds.selector,
                50,
                160
            )
        );
        assertions.assertEqCallStringN(
            address(target),
            abi.encodeCall(MockTarget.getTupleWithString, ()),
            50,
            "hello"
        );
    }

    function test_assertEqCallStringN_indexNotAnOffset_reverts() public {
        // Index 0 of getTupleWithString() is a uint256 (42), not a valid string
        // offset, so the offset validation must reject it
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.ReturnDataOutOfBounds.selector,
                0,
                160
            )
        );
        assertions.assertEqCallStringN(
            address(target),
            abi.encodeCall(MockTarget.getTupleWithString, ()),
            0,
            "hello"
        );
    }

    // ============ Code-less Target Assertions ============

    function test_call_toEOA_reverts_withCallFailed() public {
        bytes memory callData = abi.encodeCall(MockTarget.getValue, ());
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.CallFailed.selector,
                TEST_EOA,
                callData
            )
        );
        assertions.assertEqCallUint(TEST_EOA, callData, 42);
    }

    function test_assertEqCallInt_toEOA_reverts_withCallFailed() public {
        bytes memory callData = abi.encodeCall(MockTarget.getInt, ());
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.CallFailed.selector,
                TEST_EOA,
                callData
            )
        );
        assertions.assertEqCallInt(TEST_EOA, callData, -42);
    }
}
