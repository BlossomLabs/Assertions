// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Collections.sol";
import "../Expressions.sol";

/**
 * @dev Independent callback oracles: calldata capture, raw words, caller and
 *      deliberately non-word return widths. No callback mutates storage.
 */
contract ClaimCallbackOracle {
    fallback(bytes calldata data) external returns (bytes memory) {
        return abi.encode(data);
    }

    function echo(uint256 x) external pure returns (uint256) {
        return x;
    }

    function pair(uint256 a, uint256 b) external pure returns (uint256) {
        return a ^ b;
    }

    function caller(uint256, uint256) external view returns (address) {
        return msg.sender;
    }

    /**
     * @dev All other elements return zero, so every reduction mode reaches
     *      the selected element without an earlier exit or sum overflow.
     */
    function width(uint256 index, uint256 selected, uint256 size, bytes32 reply) external pure returns (bytes32) {
        assembly ("memory-safe") {
            mstore(0, 0)
            mstore(32, 0)
            if eq(index, selected) {
                mstore(0, reply)
                mstore(32, not(reply))
                return(0, size)
            }
            return(0, 32)
        }
    }
}

/**
 * @notice Bounded EVM properties for L70-L75. Words are symbolic;
 *         traversal sizes, descriptors, graph shapes and copy offsets are
 *         literal cases. Every expected success is checked through staticcall.
 */
contract ClaimCallbacksSymbolicTest is Test {
    Collections collections;
    Expressions expressions;
    ClaimCallbackOracle oracle;

    function setUp() public {
        collections = new Collections();
        expressions = new Expressions();
        oracle = new ClaimCallbackOracle();
    }

    function check_claimSlotsMatchingAndDifferent(bytes32 a, bytes32 b, bool same) public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        Collections.Callback memory cb = capture("(uint8)", 1);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(abi.encodeCall(Collections.mapValues, (same ? "uint8" : "uint256", "bytes", values, cb)));
        if (uint256(a) > 255 || uint256(b) > 255) {
            assertFalse(ok);
            assertEq(
                out,
                same
                    ? abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
                    : abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0))
            );
        } else {
            assertTrue(ok);
            bytes[] memory got = abi.decode(out, (bytes[]));
            assertEq(got.length, 2);
            assertEq(got[0], abi.encode(bytes.concat(cb.selector, abi.encode(a))));
            assertEq(got[1], abi.encode(bytes.concat(cb.selector, abi.encode(b))));
        }
    }

    function check_claimBinarySlots(bytes32 a, bytes32 b, bool same) public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(b);
        Collections.Callback memory cb = capture("(uint8,uint8)", 2);
        cb.selector = ClaimCallbackOracle.pair.selector;
        cb.second = 1;
        string memory t = same ? "uint8" : "uint256";
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.foldValues, (t, t, values, abi.encode(a), cb)));
        if (uint256(a) > 255 || uint256(b) > 255) {
            assertFalse(ok);
            assertEq(
                out,
                same
                    ? abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
                    : abi.encodeWithSelector(
                        AbiCodec.InvalidComponentValue.selector, uint256(a) > 255 ? uint256(0) : uint256(1), uint256(0)
                    )
            );
        } else {
            assertTrue(ok);
            assertEq(abi.decode(out, (bytes)), abi.encode(a ^ b));
        }
    }

    function check_claimConstantsBeforeTraversal(bytes32 x, bytes32 narrow, bytes32 boolean, bool empty) public view {
        bytes[] memory values = new bytes[](empty ? 0 : 1);
        if (!empty) values[0] = abi.encode(x);
        Collections.Callback memory cb = capture("(uint256,uint8,bool)", 3);
        cb.constants[1] = abi.encode(narrow);
        cb.constants[2] = abi.encode(boolean);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.mapValues, ("uint256", "bytes", values, cb)));
        if (uint256(narrow) > 255 || uint256(boolean) > 1) {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidComponentValue.selector, uint256(narrow) > 255 ? uint256(1) : uint256(2), uint256(0)
                )
            );
        } else {
            assertTrue(ok);
            bytes[] memory got = abi.decode(out, (bytes[]));
            assertEq(got.length, empty ? 0 : 1);
            if (!empty) assertEq(got[0], abi.encode(bytes.concat(cb.selector, abi.encode(x, narrow, boolean))));
        }
    }

    function check_claimReduceResultWidth(bytes32 reply, uint8 indexCase, uint8 widthCase, uint8 modeCase) public view {
        vm.assume(indexCase < 3 && widthCase < 6 && modeCase < 4);
        uint256 index = indexCase == 0 ? 0 : indexCase == 1 ? 1 : 2;
        uint256 size = widthCase == 0
            ? 0
            : widthCase == 1 ? 1 : widthCase == 2 ? 31 : widthCase == 3 ? 32 : widthCase == 4 ? 33 : 64;
        bytes memory template = abi.encodeCall(ClaimCallbackOracle.width, (0, index, size, reply));
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(
                    Collections.reduceWords.selector,
                    abi.encode(uint256(0), uint256(1), uint256(2)),
                    address(oracle),
                    template,
                    offsets(4),
                    modeCase,
                    modeCase == 1 ? uint8(Collections.Cmp.LT) : uint8(Collections.Cmp.GE),
                    bytes32(0)
                )
            );
        if (size != 32) {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    Collections.reduceWords.selector,
                    index,
                    uint256(0),
                    address(oracle)
                )
            );
        } else {
            assertTrue(ok);
            assertEq(
                abi.decode(out, (uint256)), modeCase == 0 ? 1 : modeCase == 1 ? 0 : modeCase == 2 ? 3 : uint256(reply)
            );
        }
    }

    function check_claimReduceEnumDecoder(uint256 mode, uint256 cmp, bytes32 x, bool empty) public view {
        vm.assume(mode >= 4 || cmp >= 10);
        // Encode the WHOLE call with numeric fields: the harness must not cast
        // to enums and reject the input before the production decoder sees it.
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(
                    Collections.reduceWords.selector,
                    empty ? bytes("") : abi.encode(x),
                    address(oracle),
                    abi.encodeCall(ClaimCallbackOracle.echo, (0)),
                    offsets(4),
                    mode,
                    cmp,
                    x
                )
            );
        assertFalse(ok);
        assertEq(out, bytes(""));
    }

    function check_claimReduceMultipleWindows(bytes32 x, uint8 mode, uint8 windowCase, bool empty, bool unaligned)
        public
        view
    {
        vm.assume(mode < 4 && windowCase < 4);
        uint256[] memory windows = new uint256[](2);
        windows[0] = windowCase == 1 ? 37 : 4;
        windows[1] = windowCase == 2 ? 37 : windowCase == 3 ? type(uint256).max : 36;
        bytes memory payload = unaligned ? abi.encodePacked(x, bytes1(0)) : empty ? bytes("") : abi.encode(x);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeWithSelector(
                    Collections.reduceWords.selector,
                    payload,
                    address(0xE0A),
                    abi.encodeCall(ClaimCallbackOracle.caller, (0, 0)),
                    windows,
                    mode,
                    uint8(Collections.Cmp.EQ),
                    bytes32(0)
                )
            );
        if (unaligned) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(33)));
        } else if (windowCase != 0) {
            assertFalse(ok);
            uint256 bad = windowCase == 3 ? type(uint256).max : 37;
            assertEq(out, abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, bad, uint256(68)));
        } else if (!empty) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0xE0A)));
        } else {
            assertTrue(ok);
            assertEq(abi.decode(out, (uint256)), mode == 0 ? 1 : 0);
        }
    }

    function check_claimWordCaller(bytes32 a, bytes32 b, bytes32 init) public view {
        bytes memory payload = abi.encode(a, b);
        bytes memory template = abi.encodeCall(ClaimCallbackOracle.caller, (0, 0));
        bytes32 expected = bytes32(uint256(uint160(address(collections))));
        bytes memory out =
            succeeds(abi.encodeCall(Collections.mapWords, (payload, address(oracle), template, offsets(4))));
        assertEq(abi.decode(out, (bytes)), abi.encode(expected, expected));
        out = succeeds(
            abi.encodeCall(
                Collections.foldWords,
                (payload, address(oracle), template, 36, offsets(4), init, Collections.FoldExit.Full)
            )
        );
        assertEq(abi.decode(out, (bytes32)), expected);
        out = succeeds(
            abi.encodeCall(
                Collections.reduceWords,
                (payload, address(oracle), template, offsets(4), Collections.Reduce.All, Collections.Cmp.EQ, expected)
            )
        );
        assertEq(abi.decode(out, (uint256)), 1);
    }

    function check_claimValueAndGraphCaller(bytes32 a, bytes32 b) public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        Collections.Callback memory cb = capture("(uint256,uint256)", 2);
        cb.selector = ClaimCallbackOracle.caller.selector;
        assertCaller(values, cb, address(collections));
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = Expressions.Node(
            Expressions.Kind.Literal, "address", abi.encode(address(oracle)), new uint256[](0), bytes4(0), ""
        );
        nodes[1] = Expressions.Node(
            Expressions.Kind.Parameter, "uint256", abi.encode(uint256(0)), new uint256[](0), bytes4(0), ""
        );
        uint256[] memory refs = new uint256[](3);
        refs[0] = 0;
        refs[1] = 1;
        refs[2] = 1;
        nodes[2] = Expressions.Node(
            Expressions.Kind.Call, "address", "", refs, ClaimCallbackOracle.caller.selector, "(uint256,uint256)"
        );
        cb.target = address(expressions);
        cb.expression = abi.encode(Expressions.Expression(address(0), nodes, 2));
        assertCaller(values, cb, address(expressions));
    }

    function check_claimRawAndTypedWords(bytes32 x, uint8 typeCase) public view {
        vm.assume(typeCase < 3);
        bytes memory payload = abi.encode(x);
        bytes memory template = abi.encodeCall(ClaimCallbackOracle.echo, (0));
        bytes memory out =
            succeeds(abi.encodeCall(Collections.mapWords, (payload, address(oracle), template, offsets(4))));
        assertEq(abi.decode(out, (bytes)), payload);
        out = succeeds(
            abi.encodeCall(
                Collections.reduceWords,
                (payload, address(oracle), template, offsets(4), Collections.Reduce.All, Collections.Cmp.EQ, x)
            )
        );
        assertEq(abi.decode(out, (uint256)), 1);
        out = succeeds(
            abi.encodeCall(
                Collections.reduceWords,
                (payload, address(oracle), template, offsets(4), Collections.Reduce.Sum, Collections.Cmp.EQ, bytes32(0))
            )
        );
        assertEq(abi.decode(out, (uint256)), uint256(x));
        bytes[] memory values = new bytes[](1);
        values[0] = payload;
        Collections.Callback memory cb = capture("(uint256)", 1);
        cb.selector = ClaimCallbackOracle.echo.selector;
        string memory t = typeCase == 0 ? "bool" : typeCase == 1 ? "uint8" : "address";
        (bool ok, bytes memory result) =
            address(collections).staticcall(abi.encodeCall(Collections.mapValues, ("uint256", t, values, cb)));
        bool canonical =
            typeCase == 0 ? uint256(x) <= 1 : typeCase == 1 ? uint256(x) <= 255 : uint256(x) <= type(uint160).max;
        assertEq(ok, canonical);
        if (canonical) {
            bytes[] memory got = abi.decode(result, (bytes[]));
            assertEq(got.length, 1);
            assertEq(got[0], payload);
        } else {
            assertEq(
                result,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    Collections.mapValues.selector,
                    uint256(0),
                    uint256(0),
                    address(oracle)
                )
            );
        }
    }

    function test_claimCallbackSamples() public view {
        check_claimSlotsMatchingAndDifferent(bytes32(uint256(7)), bytes32(uint256(256)), true);
        check_claimSlotsMatchingAndDifferent(bytes32(uint256(7)), bytes32(uint256(256)), false);
        check_claimBinarySlots(bytes32(uint256(7)), bytes32(uint256(256)), false);
        check_claimBinarySlots(bytes32(uint256(7)), bytes32(uint256(9)), true);
        check_claimConstantsBeforeTraversal(bytes32(0), bytes32(uint256(256)), bytes32(0), true);
        check_claimConstantsBeforeTraversal(bytes32(uint256(7)), bytes32(uint256(1)), bytes32(uint256(1)), false);
        check_claimReduceResultWidth(bytes32(type(uint256).max), 2, 4, 3);
        check_claimReduceResultWidth(bytes32(type(uint256).max), 2, 3, 3);
        check_claimReduceEnumDecoder(3, 10, bytes32(0), true);
        check_claimReduceMultipleWindows(bytes32(uint256(7)), 3, 2, true, false);
        check_claimReduceMultipleWindows(bytes32(uint256(7)), 0, 0, true, false);
        check_claimWordCaller(bytes32(uint256(7)), bytes32(uint256(9)), bytes32(0));
        check_claimValueAndGraphCaller(bytes32(uint256(7)), bytes32(uint256(9)));
        check_claimRawAndTypedWords(bytes32(uint256(2)), 0);
        check_claimRawAndTypedWords(bytes32(uint256(256)), 1);
        check_claimRawAndTypedWords(bytes32(uint256(1) << 160), 2);
        check_claimRawAndTypedWords(bytes32(uint256(1)), 0);
    }

    function capture(string memory arguments, uint256 count) internal view returns (Collections.Callback memory cb) {
        cb.target = address(oracle);
        cb.selector = bytes4(0xabcdef01);
        cb.arguments = arguments;
        cb.constants = new bytes[](count);
        for (uint256 i; i < count; i++) {
            cb.constants[i] = abi.encode(uint256(0));
        }
    }

    function offsets(uint256 offset) internal pure returns (uint256[] memory values) {
        values = new uint256[](1);
        values[0] = offset;
    }

    function succeeds(bytes memory data) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = address(collections).staticcall(data);
        assertTrue(ok);
    }

    function assertCaller(bytes[] memory values, Collections.Callback memory cb, address expected) internal view {
        bytes memory out = succeeds(abi.encodeCall(Collections.mapValues, ("uint256", "address", values, cb)));
        bytes[] memory got = abi.decode(out, (bytes[]));
        assertEq(got.length, values.length);
        for (uint256 i; i < got.length; i++) {
            assertEq(got[i], abi.encode(expected));
        }
    }
}
