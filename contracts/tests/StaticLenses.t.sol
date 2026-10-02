// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

contract StaticLensesTest is Test {
    Assertions assertions;

    struct Record {
        uint256[2] points;
        address owner;
    }

    function setUp() public {
        assertions = new Assertions();
    }

    function _raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function _path(int256 a) internal pure returns (int256[] memory path) {
        path = new int256[](1);
        path[0] = a;
    }

    function _path(int256 a, int256 b) internal pure returns (int256[] memory path) {
        path = new int256[](2);
        path[0] = a;
        path[1] = b;
    }

    function _nav(InputParam memory p, string memory types, int256[] memory path)
        internal
        view
        returns (bytes memory result)
    {
        (bool ok, bytes memory data) = address(assertions).staticcall(abi.encodeCall(Assertions.nav, (p, types, path)));
        assertTrue(ok);
        return data;
    }

    function test_nav_staticArray_hasNoEnvelopeOrSiblingWords() public view {
        int256[2] memory pair = [int256(-3), int256(4)];
        bytes memory result =
            _nav(_raw(abi.encode(uint256(99), pair, uint256(88))), "(uint256,int256[2],uint256)", _path(1));
        assertEq(result, abi.encode(pair));
        assertEq(result.length, 64);
    }

    function test_nav_staticTuple_completeNestedFootprint() public view {
        Record memory record = Record([uint256(7), uint256(8)], address(0xBEEF));
        bytes memory result = _nav(_raw(abi.encode(uint256(99), record)), "(uint256,(uint256[2],address))", _path(1));
        assertEq(result, abi.encode(record));
        assertEq(result.length, 96);
    }

    function test_nav_staticTuple_insideDynamicArrayFromEnd() public view {
        Record[] memory records = new Record[](2);
        records[0] = Record([uint256(1), uint256(2)], address(0xAAAA));
        records[1] = Record([uint256(3), uint256(4)], address(0xBBBB));
        assertEq(_nav(_raw(abi.encode(records)), "((uint256[2],address)[])", _path(0, -1)), abi.encode(records[1]));
    }

    function test_nav_staticArray_insideFixedArray() public view {
        uint256[2][2] memory matrix = [[uint256(1), uint256(2)], [uint256(3), uint256(4)]];
        assertEq(_nav(_raw(abi.encode(matrix)), "(uint256[2][2])", _path(0, 1)), abi.encode(matrix[1]));
    }

    function test_nav_staticArray_insideDynamicTuple() public view {
        int256[2] memory pair = [int256(-7), int256(8)];
        // A dynamic tuple is itself prefixed by an offset when ABI encoded.
        bytes memory tuple = abi.encode("before", pair, "after");
        bytes memory encoded = bytes.concat(abi.encode(uint256(32)), tuple);
        assertEq(_nav(_raw(encoded), "((string,int256[2],string))", _path(0, 1)), abi.encode(pair));
    }

    function test_nav_singleWordComposite_preservesWordEncoding() public view {
        uint256[1] memory value = [uint256(42)];
        assertEq(_nav(_raw(abi.encode(value)), "(uint256[1])", _path(0)), abi.encode(value));
        assertEq(_nav(_raw(abi.encode(uint256(42))), "((uint256))", _path(0)), abi.encode(uint256(42)));
    }

    function test_nav_staticSpan_rejectsTruncationAndOutOfRange() public {
        InputParam memory p = _raw(abi.encode(uint256(99), uint256(1)));
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(64)));
        assertions.nav(p, "(uint256,uint256[2])", _path(1));

        uint256[2][] memory pairs = new uint256[2][](1);
        pairs[0] = [uint256(1), uint256(2)];
        p = _raw(abi.encode(pairs));
        vm.expectRevert(abi.encodeWithSelector(ElementIndexOutOfBounds.selector, int256(-2), uint256(1)));
        assertions.nav(p, "(uint256[2][])", _path(0, -2));
    }

    function test_nav_staticComposites_keepSentinelRestrictions() public {
        int256 len = assertions.LEN();
        int256 payload = assertions.PAYLOAD();
        InputParam memory p = _raw(abi.encode(uint256(1), uint256(2)));
        vm.expectRevert(abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1)));
        assertions.nav(p, "(uint256[2])", _path(0, len));
        vm.expectRevert(abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1)));
        assertions.nav(p, "((uint256,uint256))", _path(0, payload));
    }

    function report() external view returns (uint256, int256[2] memory) {
        require(msg.sender == address(assertions), "caller must be core");
        return (99, [int256(-3), int256(4)]);
    }

    function test_nav_staticSource_resolvesOnceAndPreservesConstraints() public {
        bytes memory callData = abi.encodeCall(this.report, ());
        InputParam memory p = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(this), callData),
            new Constraint[](0)
        );
        vm.expectCall(address(this), callData, uint64(1));
        assertEq(_nav(p, "(uint256,int256[2])", _path(1)), abi.encode([int256(-3), int256(4)]));
        p = _raw(abi.encode(uint256(99), [int256(-3), int256(4)]));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(100)));
        (bool ok,) =
            address(assertions).staticcall(abi.encodeCall(Assertions.nav, (p, "(uint256,int256[2])", _path(1))));
        assertFalse(ok);
    }

    function testFuzz_nav_staticTuple_exactBytes(uint256 a, uint256 b, address owner) public view {
        Record memory record = Record([a, b], owner);
        assertEq(
            _nav(
                _raw(abi.encode(uint256(99), record, uint256(88))), "(uint256,(uint256[2],address),uint256)", _path(1)
            ),
            abi.encode(record)
        );
    }

    // ============ Canonical words in returned values ============

    /**
     * @dev Byte offset of the first word equal to `sentinel` at or after `from`
     */
    function _find(bytes memory data, uint256 sentinel, uint256 from) internal pure returns (uint256 p) {
        for (p = from; p + 32 <= data.length; p += 32) {
            uint256 w;
            assembly { w := mload(add(add(data, 32), p)) }
            if (w == sentinel) return p;
        }
        revert("sentinel not found");
    }

    function _expectInvalidValue(
        bytes memory data,
        string memory types,
        int256[] memory path,
        uint256 sentinel,
        uint256 from
    ) internal {
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, _find(data, sentinel, from)));
        assertions.nav(_raw(data), types, path);
    }

    function test_nav_rejectsOutOfRangeStaticTerminals() public {
        // A word terminal.
        bytes memory data = abi.encode(uint256(7), uint256(0x1234));
        _expectInvalidValue(data, "(uint256,uint8)", _path(1), 0x1234, 32);
        // A word inside a static tuple terminal.
        data = abi.encode(uint256(7), uint256(2), uint256(0xBEEF));
        _expectInvalidValue(data, "(uint256,(bool,address))", _path(1), 2, 32);
        // A word inside a fixed array terminal: 0x80 is no sign-extended int8.
        data = abi.encode(type(uint256).max, uint256(0x80));
        _expectInvalidValue(data, "(int8[2])", _path(0), 0x80, 0);
        // An element reached by indexing.
        data = abi.encode(uint256(1), uint256(1) << 160);
        _expectInvalidValue(data, "(address[2])", _path(0, 1), uint256(1) << 160, 0);
    }

    function test_nav_rejectsOutOfRangeElementsOfDynamicArrays() public {
        uint256[] memory words = new uint256[](3);
        words[0] = 1;
        words[1] = 2;
        words[2] = 0x100;
        bytes memory data = abi.encode(words);
        _expectInvalidValue(data, "(uint8[])", _path(0), 0x100, 64);
    }

    function test_nav_acceptsInRangeBoundaryWords() public view {
        bytes memory data = abi.encode(int8(-128), bytes1(0xff), type(uint160).max, true);
        assertEq(_nav(_raw(data), "(int8,bytes1,address,bool)", _path(0)), abi.encode(int8(-128)));
        assertEq(_nav(_raw(data), "(int8,bytes1,address,bool)", _path(1)), abi.encode(bytes1(0xff)));
        assertEq(_nav(_raw(data), "(int8,bytes1,address,bool)", _path(2)), abi.encode(type(uint160).max));
        assertEq(_nav(_raw(data), "(int8,bytes1,address,bool)", _path(3)), abi.encode(true));
        uint8[] memory small = new uint8[](2);
        small[0] = 0;
        small[1] = 255;
        assertEq(_nav(_raw(abi.encode(small)), "(uint8[])", _path(0)), abi.encode(small));
    }

    /**
     * @dev nav validates what it returns, not the siblings it skips: a
     *      dirty word next to the selection does not reach the consumer
     */
    function test_nav_checksOnlyTheReturnedValue() public view {
        bytes memory data = abi.encode(uint256(0x1234), uint256(5));
        assertEq(_nav(_raw(data), "(uint8,uint256)", _path(1)), abi.encode(uint256(5)));
    }

    /**
     * @dev A whole bytes or string terminal is returned canonical: dirty
     *      padding reverts at the first dirty byte, as AbiCodec.body does for
     *      the same value nested in an array. PAYLOAD and LEN never emit the
     *      padding and are unaffected.
     */
    function test_nav_rejectsDirtyPaddingOfBytesTerminal() public {
        bytes memory data = abi.encode(bytes("abc"), uint256(7));
        uint256 payload = _find(data, 3, 0) + 32;
        data[payload + 5] = 0x01;
        _nav(_raw(data), "(bytes,uint8)", _path(0, type(int256).min + 1));
        _nav(_raw(data), "(bytes,uint8)", _path(0, type(int256).min));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, payload + 5));
        assertions.nav(_raw(data), "(bytes,uint8)", _path(0));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, payload + 5));
        assertions.nav(_raw(data), "(string,uint8)", _path(0));
    }
}
