// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";

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
}
