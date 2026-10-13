// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";

contract ClaimBoundsOracle {
    function echo(uint256 value) external pure returns (uint256) {
        return value;
    }

    /**
     * @dev Replies are prefixes of four independent words. The size is
     *      bounded explicitly so the return reads only the allocated buffer.
     */
    function width(uint256 index, uint256 selected, uint256 size, bytes32 a, bytes32 b, bytes32 c, bytes32 d)
        external
        pure
        returns (bytes32)
    {
        require(size <= 128);
        bytes memory data = new bytes(128);
        if (index == selected) {
            assembly ("memory-safe") {
                let p := add(data, 32)
                mstore(p, a)
                mstore(add(p, 32), b)
                mstore(add(p, 64), c)
                mstore(add(p, 96), d)
                return(p, size)
            }
        }
        assembly ("memory-safe") { return(add(data, 32), 32) }
    }
}

/**
 * @notice L71/L72 over zero to four words, zero or three windows (overlaps
 *         included), and twelve reply widths at every reachable index.
 *         L75's raw-word comparison/sum checks extend to two symbolic words.
 */
contract ClaimReductionBoundsSymbolicTest is Test {
    Collections collections;
    ClaimBoundsOracle oracle;

    function setUp() public {
        collections = new Collections();
        oracle = new ClaimBoundsOracle();
    }

    function check_extendedReductionWidths(
        bytes32[4] memory reply,
        uint8 countCase,
        uint8 indexCase,
        uint8 sizeCase,
        uint8 mode
    ) public view {
        vm.assume(countCase < 5 && indexCase < 4 && sizeCase < 12 && mode < 4);
        uint256 n = countCase == 0 ? 0 : countCase == 1 ? 1 : countCase == 2 ? 2 : countCase == 3 ? 3 : 4;
        uint256 selected = indexCase == 0 ? 0 : indexCase == 1 ? 1 : indexCase == 2 ? 2 : 3;
        vm.assume(n == 0 || selected < n);
        uint256 size = sizeCase == 0
            ? 0
            : sizeCase == 1
                ? 1
                : sizeCase == 2
                    ? 2
                    : sizeCase == 3
                        ? 30
                        : sizeCase == 4
                            ? 31
                            : sizeCase == 5
                                ? 32
                                : sizeCase == 6
                                    ? 33
                                    : sizeCase == 7
                                        ? 63
                                        : sizeCase == 8 ? 64 : sizeCase == 9 ? 65 : sizeCase == 10 ? 96 : 97;
        bytes memory s = cut(abi.encode(uint256(0), uint256(1), uint256(2), uint256(3)), countCase);
        (bool ok, bytes memory out) = invokeWidth(reply, selected, size, mode, s);
        if (n != 0 && size != 32) {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    Collections.reduceWords.selector,
                    selected,
                    uint256(0),
                    address(oracle)
                )
            );
        } else {
            assertTrue(ok);
            uint256 expected = mode == 0 ? 1 : mode == 1 ? 0 : mode == 2 ? n : n == 0 ? 0 : uint256(reply[0]);
            assertEq(abi.decode(out, (uint256)), expected);
        }
    }

    function invokeWidth(bytes32[4] memory reply, uint256 selected, uint256 size, uint8 mode, bytes memory s)
        internal
        view
        returns (bool, bytes memory)
    {
        uint256[] memory windows = new uint256[](1);
        windows[0] = 4;
        bytes memory template = widthTemplate(reply, selected, size);
        return address(collections)
            .staticcall(
                abi.encodeWithSelector(
                    Collections.reduceWords.selector,
                    s,
                    s.length == 0 ? address(0xE0A) : address(oracle),
                    template,
                    windows,
                    mode,
                    mode == 1 ? uint8(Collections.Cmp.LT) : uint8(Collections.Cmp.GE),
                    bytes32(0)
                )
            );
    }

    function widthTemplate(bytes32[4] memory reply, uint256 selected, uint256 size)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(ClaimBoundsOracle.width, (0, selected, size, reply[0], reply[1], reply[2], reply[3]));
    }

    function check_extendedReductionWindowBounds(
        bytes32[4] memory words,
        uint8 countCase,
        uint8 templateCase,
        uint8 windowCase,
        uint8 mode
    ) public view {
        vm.assume(countCase < 5 && templateCase < 3 && windowCase < 5 && mode < 4);
        bytes memory s = cut(abi.encode(words), countCase);
        uint256 length = templateCase == 0 ? 31 : templateCase == 1 ? 32 : 100;
        uint256[] memory windows = new uint256[](windowCase == 0 ? 0 : 3);
        if (windowCase != 0) {
            windows[0] = 0;
            windows[1] = 4;
            windows[2] = windowCase == 1 ? 68 : windowCase == 2 ? 5 : windowCase == 3 ? 69 : type(uint256).max;
        }
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(
                    Collections.reduceWords.selector,
                    s,
                    address(0xE0A),
                    new bytes(length),
                    windows,
                    mode,
                    uint8(Collections.Cmp.EQ),
                    bytes32(0)
                )
            );
        bool bad = templateCase == 0 || (templateCase == 1 && windowCase != 0) || (templateCase == 2 && windowCase >= 3);
        if (bad) {
            assertFalse(ok);
            uint256 offset = templateCase == 0 ? 0 : templateCase == 1 ? 4 : windowCase == 3 ? 69 : type(uint256).max;
            assertEq(out, abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, offset, length));
        } else if (countCase != 0) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0xE0A)));
        } else {
            assertTrue(ok);
            assertEq(abi.decode(out, (uint256)), mode == 0 ? 1 : 0);
        }
    }

    function check_extendedRawWordPairs(bytes32 a, bytes32 b, uint8 mode) public view {
        vm.assume(mode < 4);
        uint256[] memory windows = new uint256[](1);
        windows[0] = 4;
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(
                    Collections.reduceWords.selector,
                    abi.encode(a, b),
                    address(oracle),
                    abi.encodeCall(ClaimBoundsOracle.echo, (0)),
                    windows,
                    mode,
                    uint8(Collections.Cmp.EQ),
                    a
                )
            );
        uint256 sum;
        unchecked {
            sum = uint256(a) + uint256(b);
        }
        if (mode == 3 && sum < uint256(a)) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSignature("Panic(uint256)", uint256(0x11)));
        } else {
            assertTrue(ok);
            assertEq(
                abi.decode(out, (uint256)),
                mode == 0 ? (a == b ? 1 : 0) : mode == 1 ? 1 : mode == 2 ? (a == b ? 2 : 1) : sum
            );
        }
        (ok, out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.mapWords,
                    (abi.encode(a, b), address(oracle), abi.encodeCall(ClaimBoundsOracle.echo, (0)), windows)
                )
            );
        assertTrue(ok);
        assertEq(abi.decode(out, (bytes)), abi.encode(a, b));
    }

    function cut(bytes memory s, uint8 countCase) internal pure returns (bytes memory) {
        if (countCase == 0) {
            assembly ("memory-safe") { mstore(s, 0) }
        } else if (countCase == 1) {
            assembly ("memory-safe") {
                mstore(s, 32)
            }
        } else if (countCase == 2) {
            assembly ("memory-safe") { mstore(s, 64) }
        } else if (countCase == 3) {
            assembly ("memory-safe") {
                mstore(s, 96)
            }
        }
        return s;
    }

    function test_extendedReductionGeometries() public view {
        bytes32[4] memory words =
            [bytes32(type(uint256).max), bytes32(uint256(7)), bytes32(uint256(19)), bytes32(uint256(31))];
        for (uint8 n; n < 5; n++) {
            for (uint8 size; size < 12; size++) {
                for (uint8 mode; mode < 4; mode++) {
                    check_extendedReductionWidths(words, n, n == 0 ? 0 : n - 1, size, mode);
                }
            }
            for (uint8 t; t < 3; t++) {
                for (uint8 w; w < 5; w++) {
                    check_extendedReductionWindowBounds(words, n, t, w, 0);
                }
            }
        }
        check_extendedReductionWidths(words, 4, 1, 11, 3);
        for (uint8 mode; mode < 4; mode++) {
            check_extendedRawWordPairs(bytes32(type(uint256).max), bytes32(uint256(1)), mode);
            check_extendedRawWordPairs(bytes32(uint256(7)), bytes32(uint256(19)), mode);
        }
    }
}
