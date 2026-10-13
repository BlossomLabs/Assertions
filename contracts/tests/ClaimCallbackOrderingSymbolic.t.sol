// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Collections.sol";

contract ClaimOrderingProbe {
    Vm constant VM = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    error LaterCallback(uint256 index);

    function step(uint256 element, uint256, uint256 failAt, bool truth) external returns (uint256) {
        VM.warp(block.timestamp + 1);
        if (element == failAt) revert LaterCallback(element);
        return truth ? 1 : 0;
    }

    function predicate(uint256 element, uint256 failAt, bool truth) external returns (bool) {
        VM.warp(block.timestamp + 1);
        if (element == failAt) revert LaterCallback(element);
        return truth;
    }

    function count() external view returns (uint256) {
        return block.timestamp - 1000;
    }
}

/**
 * @dev Whole-calldata comparison without hashing. The expected stream is
 *      configured outside STATICCALL and compared a word at a time; padding
 *      outside either stream is excluded from the final partial word.
 */
contract ClaimWindowCapture {
    bytes expected;

    function configure(bytes calldata data) external {
        expected = data;
    }

    fallback(bytes calldata data) external returns (bytes memory) {
        bytes memory want = expected;
        bool matches = data.length == want.length;
        for (uint256 i; matches && i < data.length; i += 32) {
            uint256 a;
            uint256 b;
            assembly ("memory-safe") {
                a := calldataload(add(data.offset, i))
                b := mload(add(add(want, 32), i))
            }
            uint256 left = data.length - i;
            if (left < 32) {
                a >>= (32 - left) * 8;
                b >>= (32 - left) * 8;
            }
            matches = a == b;
        }
        return abi.encode(matches ? uint256(1) : uint256(0));
    }
}

/**
 * @notice L4/L5: would-fail later callbacks are never visited after early
 *         exit; six literal byte-window geometries pin overwrite order and
 *         the complete remaining template through an independent receiver.
 */
contract ClaimCallbackOrderingSymbolicTest is Test {
    Collections collections;
    ClaimOrderingProbe probe;
    ClaimWindowCapture capture;

    function setUp() public {
        collections = new Collections();
        probe = new ClaimOrderingProbe();
        capture = new ClaimWindowCapture();
    }

    function check_orderEarlyFoldDomains(bytes32 initial, bool any, uint8 domain, uint8 failCase) public {
        vm.assume(domain < 3 && failCase < 2);
        uint256 failAt = failCase == 0 ? 1 : 2;
        vm.warp(1000);
        uint256[] memory offsets = one(4);
        bytes memory template = abi.encodeCall(ClaimOrderingProbe.step, (0, 0, failAt, any));
        Collections.FoldExit mode = any ? Collections.FoldExit.Any : Collections.FoldExit.All;
        bytes memory data = domain == 0
            ? abi.encodeCall(
                Collections.foldRange, (uint256(3), address(probe), template, uint256(36), offsets, initial, mode)
            )
            : domain == 1
                ? abi.encodeCall(
                    Collections.foldBytes,
                    (bytes(hex"000102"), address(probe), template, uint256(36), offsets, initial, mode)
                )
                : abi.encodeCall(
                    Collections.foldWords,
                    (
                        abi.encode(uint256(0), uint256(1), uint256(2)),
                        address(probe),
                        template,
                        uint256(36),
                        offsets,
                        initial,
                        mode
                    )
                );
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertTrue(ok, "a later failing callback must never run");
        assertEq(out, abi.encode(any ? uint256(1) : uint256(0)));
        assertEq(probe.count(), 1);
    }

    function check_orderEarlyReductions(bool any, uint8 failCase) public {
        vm.assume(failCase < 2);
        uint256 failAt = failCase == 0 ? 1 : 2;
        vm.warp(1000);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.reduceWords,
                    (
                        abi.encode(uint256(0), uint256(1), uint256(2)),
                        address(probe),
                        abi.encodeCall(ClaimOrderingProbe.step, (0, 0, failAt, any)),
                        one(4),
                        any ? Collections.Reduce.Any : Collections.Reduce.All,
                        Collections.Cmp.EQ,
                        bytes32(uint256(1))
                    )
                )
            );
        assertTrue(ok);
        assertEq(out, abi.encode(any ? uint256(1) : uint256(0)));
        assertEq(probe.count(), 1);
    }

    function check_orderEarlyValuePredicates(uint8 route, uint8 failCase) public {
        vm.assume(route < 3 && failCase < 2);
        uint256 failAt = failCase == 0 ? 1 : 2;
        vm.warp(1000);
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(uint256(0));
        values[1] = abi.encode(uint256(1));
        values[2] = abi.encode(uint256(2));
        Collections.Callback memory cb;
        cb.target = address(probe);
        cb.selector = ClaimOrderingProbe.predicate.selector;
        cb.arguments = "(uint256,uint256,bool)";
        cb.constants = new bytes[](3);
        cb.constants[0] = abi.encode(uint256(0));
        cb.constants[1] = abi.encode(failAt);
        cb.constants[2] = abi.encode(route != 1);
        bytes memory data = route == 0
            ? abi.encodeCall(Collections.anyValues, ("uint256", values, cb))
            : route == 1
                ? abi.encodeCall(Collections.allValues, ("uint256", values, cb))
                : abi.encodeCall(Collections.findValues, ("uint256", values, cb));
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertTrue(ok);
        assertEq(out, abi.encode(route == 0 ? uint256(1) : uint256(0)));
        assertEq(probe.count(), 1);
    }

    function check_orderWindowStamping(
        bytes32[4] memory templateWords,
        bytes32 initial,
        bytes32 element,
        uint8 geometry
    ) public {
        vm.assume(geometry < 6);
        bytes4 selector = 0xcafef00d;
        bytes memory template = bytes.concat(selector, abi.encode(templateWords));
        uint256 accOffset = geometry == 1 ? 36 : geometry == 2 ? 20 : geometry == 5 ? 68 : 4;
        uint256[] memory offsets = new uint256[](2);
        offsets[0] = geometry == 2 || geometry == 4 ? 36 : geometry == 3 ? 20 : 4;
        offsets[1] = geometry == 1 || geometry == 4 ? 20 : geometry == 2 ? 4 : 36;
        bytes memory body;
        if (geometry == 0 || geometry == 2) {
            body = abi.encode(element, element, templateWords[2], templateWords[3]);
        } else if (geometry == 1) {
            body = bytes.concat(
                bytes16(element),
                abi.encode(element),
                bytes16(initial << 128),
                abi.encode(templateWords[2], templateWords[3])
            );
        } else if (geometry == 3) {
            body = bytes.concat(
                bytes16(initial), bytes16(element), abi.encode(element, templateWords[2], templateWords[3])
            );
        } else if (geometry == 4) {
            body = bytes.concat(
                bytes16(initial),
                abi.encode(element),
                bytes16(element << 128),
                abi.encode(templateWords[2], templateWords[3])
            );
        } else {
            body = abi.encode(element, element, initial, templateWords[3]);
        }
        capture.configure(bytes.concat(selector, body));
        // A changed final byte must be detected, including the partial word.
        // This also makes an always-accepting observer a visible fault.
        assertReceiverRejects(bytes.concat(selector, body));
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.foldWords,
                    (
                        abi.encode(element),
                        address(capture),
                        template,
                        accOffset,
                        offsets,
                        initial,
                        Collections.FoldExit.Full
                    )
                )
            );
        assertTrue(ok);
        assertEq(out, abi.encode(uint256(1)), "receiver must see the complete expected calldata");
    }

    function one(uint256 offset) internal pure returns (uint256[] memory offsets) {
        offsets = new uint256[](1);
        offsets[0] = offset;
    }

    function assertReceiverRejects(bytes memory wrong) internal view {
        wrong[131] ^= bytes1(0x01);
        (bool ok, bytes memory out) = address(capture).staticcall(wrong);
        assertTrue(ok);
        assertEq(out, abi.encode(uint256(0)));
    }

    function test_orderEarlyFoldSamples() public {
        vm.expectCall(address(probe), abi.encodeCall(ClaimOrderingProbe.step, (0, 7, 1, true)), uint64(3));
        vm.expectCall(address(probe), abi.encodeCall(ClaimOrderingProbe.step, (0, 7, 1, false)), uint64(3));
        for (uint8 i; i < 3; i++) {
            check_orderEarlyFoldDomains(bytes32(uint256(7)), true, i, 0);
            check_orderEarlyFoldDomains(bytes32(uint256(7)), false, i, 0);
        }
        vm.expectCall(address(probe), abi.encodeCall(ClaimOrderingProbe.step, (0, 0, 2, true)), uint64(1));
        check_orderEarlyReductions(true, 1);
    }

    function test_orderEarlyValueSamples() public {
        vm.expectCall(address(probe), abi.encodeCall(ClaimOrderingProbe.predicate, (0, 2, true)), uint64(2));
        vm.expectCall(address(probe), abi.encodeCall(ClaimOrderingProbe.predicate, (0, 2, false)), uint64(1));
        for (uint8 i; i < 3; i++) {
            check_orderEarlyValuePredicates(i, 1);
        }
    }

    function test_orderWindowSamples() public {
        bytes32[4] memory words =
            [bytes32(uint256(7)), bytes32(uint256(93)), bytes32(uint256(81)), bytes32(uint256(65))];
        bytes32 initial = 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20;
        bytes32 element = 0x2122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40;
        for (uint8 i; i < 6; i++) {
            check_orderWindowStamping(words, initial, element, i);
        }
    }
}
