// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";
import "./Mocks.sol";

/**
 * @notice The 2026-09-07 core additions: `readArgs` (resolve-once call
 *         construction over whole ABI values, the core staying the caller)
 *         and `nav` returning arrays of dynamic elements and dynamic tuples
 *         as canonical values, with the caller rule pinned: the core stays
 *         the destination's msg.sender.
 */
contract CoreExtensionsTest is Test {
    Assertions assertions;
    MockTarget target;
    MockToken token;

    function setUp() public {
        assertions = new Assertions();
        target = new MockTarget();
        token = new MockToken(address(0), "WETH");
    }

    // ============ Helpers ============

    function _none() internal pure returns (Constraint[] memory) {}

    function _raw(bytes memory v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, v, _none());
    }

    function _call(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }

    function _string() internal view returns (InputParam memory) {
        return _call(address(target), abi.encodeCall(MockTarget.getString, ()));
    }

    function _readArgsData(address to, bytes4 sel, string memory types, InputParam[] memory args)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(Assertions.readArgs, (_raw(abi.encode(to)), sel, types, args));
    }

    function _readArgs(address to, bytes4 sel, string memory types, InputParam[] memory args)
        internal
        view
        returns (bool ok, bytes memory ret)
    {
        (ok, ret) = address(assertions).staticcall(_readArgsData(to, sel, types, args));
    }

    function _nav(InputParam memory p, string memory t, int256[] memory path)
        internal
        view
        returns (bool ok, bytes memory ret)
    {
        (ok, ret) = address(assertions).staticcall(abi.encodeCall(Assertions.nav, (p, t, path)));
    }

    function _path1(int256 a) internal pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = a;
    }

    function _path2(int256 a, int256 b) internal pure returns (int256[] memory p) {
        p = new int256[](2);
        p[0] = a;
        p[1] = b;
    }

    // ============ readArgs ============

    function test_readArgs_wordThenTwoStrings_callerIsCore() public view {
        // callerGated(address expected, string a, string b): a literal word, a
        // live string and a literal string; the mixed head/tail layout the
        // splice could only build with runtime offsets, and the caller check
        // passes because the core makes the call.
        InputParam[] memory args = new InputParam[](3);
        args[0] = _raw(abi.encode(address(assertions)));
        args[1] = _string();
        args[2] = _raw(abi.encode("literal"));
        (bool ok, bytes memory ret) =
            _readArgs(address(target), MockTarget.callerGated.selector, "(address,string,string)", args);
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), bytes("hello").length + bytes("literal").length);
    }

    function test_readArgs_sixLiveStrings_resolveEachOnce() public {
        InputParam[] memory args = new InputParam[](6);
        for (uint256 i; i < 6; i++) {
            args[i] = _string();
        }
        vm.expectCall(address(target), abi.encodeCall(MockTarget.getString, ()), uint64(6));
        (bool ok, bytes memory ret) = _readArgs(
            address(target), MockTarget.join6.selector, "(string,string,string,string,string,string)", args
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "hellohellohellohellohellohello");
    }

    function test_readArgs_emptyDescriptor() public view {
        (bool ok, bytes memory ret) =
            _readArgs(address(target), MockTarget.getValue.selector, "()", new InputParam[](0));
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 42);
    }

    function test_readArgs_nestsAsOperand() public view {
        // The constructed call's returndata is a canonical string, so a nav
        // over the readArgs operand reads its length like any other value.
        InputParam[] memory args = new InputParam[](3);
        args[0] = _string();
        args[1] = _raw(abi.encode("-"));
        args[2] = _string();
        InputParam memory joined =
            _call(address(assertions), _readArgsData(address(target), MockTarget.join3.selector, "(string,string,string)", args));
        (bool ok, bytes memory ret) = _nav(joined, "(string)", _path2(0, assertions.LEN()));
        assertTrue(ok);
        assertEq(abi.decode(ret, (uint256)), 11);
    }

    function test_readArgs_constraintNamesTheArgument() public view {
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(1)));
        InputParam[] memory args = new InputParam[](2);
        args[0] = _raw(abi.encode("a"));
        // A string envelope's first word is its 0x20 offset, so EQ 1 fails on arg 1 (operand index 2).
        args[1] = InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode("b"), cs);
        (bool ok, bytes memory ret) = _readArgs(address(target), MockTarget.join3.selector, "(string,string)", args);
        assertFalse(ok);
        assertEq(bytes4(ret), ConstraintFailed.selector);
        (, uint256 entryIndex, uint256 paramIndex,,) = abi.decode(_body(ret), (string, uint256, uint256, uint256, uint256));
        assertEq(entryIndex, 0);
        assertEq(paramIndex, 2);
    }

    function test_readArgs_componentCountMismatch() public {
        InputParam[] memory args = new InputParam[](1);
        args[0] = _raw(abi.encode("a"));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, 2, 1));
        this.readArgsExternal(address(target), MockTarget.join3.selector, "(string,string)", args);
    }

    function test_readArgs_valueMustFitItsType() public {
        InputParam[] memory args = new InputParam[](2);
        args[0] = _raw(abi.encode("a"));
        args[1] = _raw(abi.encode(uint256(5))); // a word where a string is declared
        vm.expectRevert(
            abi.encodeWithSelector(AbiCodec.InvalidComponentEnvelope.selector, 1, 32, bytes32(uint256(5)))
        );
        this.readArgsExternal(address(target), MockTarget.join3.selector, "(string,string)", args);
    }

    function test_readArgs_codelessTargetAndDirtyWord() public {
        InputParam[] memory none = new InputParam[](0);
        (bool ok, bytes memory ret) = _readArgs(address(0xdead), MockTarget.getValue.selector, "()", none);
        assertFalse(ok);
        assertEq(bytes4(ret), CallFailed.selector);

        bytes32 dirty = bytes32(uint256(1) << 200 | uint256(uint160(address(target))));
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressWord.selector, 0, dirty));
        assertions.readArgs(_raw(abi.encode(dirty)), MockTarget.getValue.selector, "()", none);
    }

    function readArgsExternal(address to, bytes4 sel, string memory types, InputParam[] memory args) external view {
        assertions.readArgs(_raw(abi.encode(to)), sel, types, args);
    }

    function _body(bytes memory ret) internal pure returns (bytes memory out) {
        out = new bytes(ret.length - 4);
        for (uint256 i; i < out.length; i++) {
            out[i] = ret[i + 4];
        }
    }

    // ============ Caller ============

    function test_caller_coreForReadAndReadArgs() public {
        InputParam[] memory none = new InputParam[](0);
        (bool ok, bytes memory ret) = address(assertions).staticcall(
            abi.encodeCall(Assertions.read, (_raw(abi.encode(address(target))), MockTarget.caller.selector, none))
        );
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(assertions));

        (ok, ret) = _readArgs(address(target), MockTarget.caller.selector, "()", none);
        assertTrue(ok);
        assertEq(abi.decode(ret, (address)), address(assertions));

        // A call gated on the core being the caller passes through readArgs.
        InputParam[] memory args = new InputParam[](3);
        args[0] = _raw(abi.encode(address(assertions)));
        args[1] = _raw(abi.encode("a"));
        args[2] = _raw(abi.encode("b"));
        (ok,) = _readArgs(address(target), MockTarget.callerGated.selector, "(address,string,string)", args);
        assertTrue(ok);
    }

    // ============ nav re-encoding ============

    function test_nav_arrayOfDynamicElements_canonical() public view {
        InputParam memory p = _call(address(token), abi.encodeCall(MockToken.tags, ()));
        (bool ok, bytes memory ret) = _nav(p, "(address,string[])", _path1(1));
        assertTrue(ok);
        (, string[] memory list) = token.tags();
        assertEq(ret, abi.encode(list));
        // and the element behind two offset layers, as before
        (ok, ret) = _nav(p, "(address,string[])", _path2(1, 2));
        assertTrue(ok);
        assertEq(abi.decode(ret, (string)), "gamma");
    }

    function test_nav_dynamicTupleTerminal_canonical() public view {
        InputParam memory p = _call(address(token), abi.encodeCall(MockToken.items, ()));
        (bool ok, bytes memory ret) = _nav(p, "((string,uint256)[])", _path2(0, 1));
        assertTrue(ok);
        MockToken.Item[] memory list = token.items();
        assertEq(ret, abi.encode(list[1]));
        assertEq(abi.decode(ret, (MockToken.Item)).label, "Gauge Deposit");
    }

    function test_nav_fixedArrayOfDynamicElements_canonical() public view {
        string[2] memory pair = ["a", "a value with more than thirty-two bytes"];
        InputParam memory p = _raw(abi.encode(pair));
        (bool ok, bytes memory ret) = _nav(p, "(string[2])", _path1(0));
        assertTrue(ok);
        assertEq(ret, abi.encode(pair));
    }

    function test_nav_soleReturnArray_unchanged() public view {
        // The whole-return passthrough (empty path) and the sole-component
        // selection agree for a string[] returned on its own.
        InputParam memory p = _call(address(target), abi.encodeCall(MockTarget.strings, ()));
        (bool ok, bytes memory ret) = _nav(p, "(string[])", _path1(0));
        assertTrue(ok);
        assertEq(ret, abi.encode(target.strings()));
    }

    function test_nav_reencodeRejectsMalformedNestedOffset() public {
        (address owner, string[] memory list) = token.tags();
        bytes memory data = abi.encode(owner, list);
        // [owner][offset 0x40][count][elem offsets...]: the first element
        // offset sits at byte 96; pointing it past its tight position breaks
        // canonical form, which the re-encoder's walk reports at that byte.
        assembly {
            mstore(add(add(data, 32), 96), 0x80)
        }
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, 96));
        assertions.nav(_raw(data), "(address,string[])", _path1(1));
    }

    function test_nav_payloadStillRefusesArraysAndTuples() public {
        InputParam memory p = _call(address(token), abi.encodeCall(MockToken.tags, ()));
        // Hoisted: an accessor inlined in the asserted call's arguments would disarm expectRevert.
        int256 payloadStep = assertions.PAYLOAD();
        vm.expectRevert(abi.encodeWithSelector(Assertions.InvalidNavigation.selector, 9));
        assertions.nav(p, "(address,string[])", _path2(1, payloadStep));
    }
}
