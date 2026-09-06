// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../CollectionOperators.sol";

contract CollectionOperatorsTest is Test {
    CollectionOperators ops;

    struct Record {
        uint256 key;
        string name;
    }

    function setUp() public {
        ops = new CollectionOperators();
    }

    function append(string memory a, string memory b) external pure returns (string memory) {
        return string.concat(a, b);
    }

    function nonempty(string memory a) external pure returns (bool) {
        return bytes(a).length != 0;
    }

    function compare(Record memory a, Record memory b) external pure returns (int256) {
        return a.key < b.key ? int256(-1) : a.key > b.key ? int256(1) : int256(0);
    }

    function equal(string memory a, string memory b) external pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function malformed(string memory) external pure {
        assembly {
            mstore(0, 1000)
            return(0, 32)
        }
    }

    function fail(string memory) external pure {
        revert("callback failed");
    }

    function cb(bytes4 selector, string memory args, uint256 count)
        private
        view
        returns (CollectionOperators.Callback memory x)
    {
        x.target = address(this);
        x.selector = selector;
        x.arguments = args;
        x.constants = new bytes[](count);
        x.first = 0;
        x.second = 1;
    }

    function strings() private pure returns (bytes[] memory v) {
        v = new bytes[](3);
        v[0] = abi.encode("a");
        v[1] = abi.encode("");
        v[2] = abi.encode("xyz");
    }

    function testDynamicPackUnpack() public view {
        bytes[] memory v = strings();
        string[] memory expected = new string[](3);
        expected[0] = "a";
        expected[1] = "";
        expected[2] = "xyz";
        bytes memory packed = ops.packArray("string", v);
        assertEq(packed, abi.encode(expected));
        bytes[] memory unpacked = ops.unpackArray("string", packed);
        for (uint256 i; i < 3; i++) {
            assertEq(unpacked[i], v[i]);
        }
    }

    function testNestedFixedDynamicArray() public view {
        string[2][] memory a = new string[2][](2);
        a[0] = ["a", "long payload of more than thirty two bytes here"];
        a[1] = ["", "b"];
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(a[0]);
        v[1] = abi.encode(a[1]);
        assertEq(ops.packArray("string[2]", v), abi.encode(a));
        bytes[] memory u = ops.unpackArray("string[2]", abi.encode(a));
        assertEq(u[0], v[0]);
        assertEq(u[1], v[1]);
    }

    function testNestedArraysAndStaticStruct() public view {
        uint256[][] memory a = new uint256[][](2);
        a[0] = new uint256[](1);
        a[0][0] = 42;
        a[1] = new uint256[](0);
        bytes[] memory u = ops.unpackArray("uint256[]", abi.encode(a));
        assertEq(u[0], abi.encode(a[0]));
        assertEq(ops.packArray("uint256[]", u), abi.encode(a));
        bytes[] memory v = new bytes[](1);
        v[0] = abi.encode(uint256(1), int256(-2));
        bytes memory p = ops.packArray("(uint256,int256)", v);
        assertEq(ops.unpackArray("(uint256,int256)", p)[0], v[0]);
    }

    function testMapFilterFold() public view {
        bytes[] memory v = strings();
        CollectionOperators.Callback memory c = cb(this.append.selector, "(string,string)", 2);
        c.constants[1] = abi.encode("!");
        bytes[] memory mapped = ops.mapValues("string", "string", v, c);
        assertEq(abi.decode(mapped[0], (string)), "a!");
        assertEq(abi.decode(mapped[1], (string)), "!");
        bytes[] memory filtered = ops.filterValues("string", v, cb(this.nonempty.selector, "(string)", 1));
        assertEq(filtered.length, 2);
        assertEq(filtered[1], v[2]);
        bytes memory folded = ops.foldValues("string", "string", v, abi.encode("prefix:"), c);
        assertEq(abi.decode(folded, (string)), "prefix:axyz");
        assertEq(ops.foldValues("string", "string", new bytes[](0), abi.encode("initial"), c), abi.encode("initial"));
    }

    function testStableSortDistinctFlatten() public view {
        bytes[] memory v = new bytes[](3);
        v[0] = abi.encode(Record(2, "first"));
        v[1] = abi.encode(Record(1, "middle"));
        v[2] = abi.encode(Record(2, "last"));
        bytes[] memory sorted =
            ops.sortValues("(uint256,string)", v, cb(this.compare.selector, "((uint256,string),(uint256,string))", 2));
        assertEq(sorted[0], v[1]);
        assertEq(sorted[1], v[0]);
        assertEq(sorted[2], v[2]);
        v[0] = abi.encode("b");
        v[1] = abi.encode("a");
        v[2] = abi.encode("b");
        bytes[] memory distinct = ops.distinctValues("string", v, cb(this.equal.selector, "(string,string)", 2));
        assertEq(distinct.length, 2);
        assertEq(distinct[0], v[0]);
        assertEq(distinct[1], v[1]);
        bytes[][] memory nested = new bytes[][](2);
        nested[0] = v;
        nested[1] = distinct;
        assertEq(ops.flattenValues(nested).length, 5);
    }

    function testRejectMalformedOffsetsAndPadding() public {
        bytes memory encoded = abi.encode(new string[](1));
        assembly { mstore(add(encoded, 96), 64) }
        vm.expectRevert();
        ops.unpackArray("string", encoded);
        bytes[] memory v = new bytes[](1);
        v[0] = abi.encode("a");
        v[0][v[0].length - 1] = 0x01;
        vm.expectRevert();
        ops.packArray("string", v);
    }

    function testCallbackErrorsHaveContext() public {
        CollectionOperators.Callback memory c = cb(this.malformed.selector, "(string)", 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                ops.mapValues.selector,
                uint256(0),
                uint256(0),
                address(this)
            )
        );
        ops.mapValues("string", "string", strings(), c);
        c.selector = this.fail.selector;
        vm.expectRevert(
            abi.encodeWithSelector(
                CollectionOperators.CallbackFailed.selector,
                ops.mapValues.selector,
                uint256(0),
                uint256(0),
                address(this),
                abi.encodeWithSignature("Error(string)", "callback failed")
            )
        );
        ops.mapValues("string", "string", strings(), c);
    }

    function testFuzzUintArray(uint256 a, uint256 b) public view {
        uint256[] memory v = new uint256[](2);
        v[0] = a;
        v[1] = b;
        bytes[] memory u = ops.unpackArray("uint256", abi.encode(v));
        assertEq(u[0], abi.encode(a));
        assertEq(u[1], abi.encode(b));
        assertEq(ops.packArray("uint256", u), abi.encode(v));
    }
    function testEmptyValidatesDescriptorsAndCallback() public {
        bytes[] memory empty = new bytes[](0);
        CollectionOperators.Callback memory c = cb(this.nonempty.selector, "(string)", 1);
        vm.expectRevert();
        ops.filterValues("", empty, c);
        c.first = 2;
        vm.expectRevert(CollectionOperators.InvalidCallback.selector);
        ops.filterValues("string", empty, c);
    }

    function testDistinctChecksEveryPreviousValue() public view {
        bytes[] memory values = new bytes[](4);
        values[0] = abi.encode("a");
        values[1] = abi.encode("b");
        values[2] = abi.encode("c");
        values[3] = abi.encode("b");
        bytes[] memory result = ops.distinctValues("string", values, cb(this.equal.selector, "(string,string)", 2));
        assertEq(result.length, 3);
        assertEq(result[2], values[2]);
    }

    function surround(string memory prefix, string memory value, string memory suffix)
        external pure returns (string memory)
    {
        return string.concat(prefix, value, suffix);
    }

    function invalidBool(string memory) external pure returns (uint256) { return 2; }

    function invalidComparator(Record memory, Record memory) external pure returns (int256, int256) {
        return (0, 0);
    }

    function testCallbackSubstitutesMiddleDynamicSlot() public view {
        CollectionOperators.Callback memory c = cb(this.surround.selector, "(string,string,string)", 3);
        c.first = 1;
        c.constants[0] = abi.encode("prefix longer than a single ABI word:");
        c.constants[2] = abi.encode(":suffix");
        bytes[] memory result = ops.mapValues("string", "string", strings(), c);
        assertEq(abi.decode(result[0], (string)), "prefix longer than a single ABI word:a:suffix");
        assertEq(abi.decode(result[1], (string)), "prefix longer than a single ABI word::suffix");
        assertEq(abi.decode(result[2], (string)), "prefix longer than a single ABI word:xyz:suffix");
    }

    function testMalformedPredicateAndComparatorAreRejected() public {
        CollectionOperators.Callback memory c = cb(this.invalidBool.selector, "(string)", 1);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector,
            ops.filterValues.selector, uint256(0), uint256(0), address(this)));
        ops.filterValues("string", strings(), c);
        bytes[] memory records = new bytes[](2);
        records[0] = abi.encode(Record(1, "one"));
        records[1] = abi.encode(Record(2, "two"));
        c = cb(this.invalidComparator.selector, "((uint256,string),(uint256,string))", 2);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector,
            ops.sortValues.selector, uint256(0), uint256(1), address(this)));
        ops.sortValues("(uint256,string)", records, c);
    }

    function testFuzzSortIsStablePermutation(uint256 seed, uint8 length) public view {
        uint256 n = uint256(length) % 13;
        bytes[] memory values = new bytes[](n);
        for (uint256 i; i < n; i++) {
            values[i] = abi.encode(Record(uint256(keccak256(abi.encode(seed, i))) % 4, string(abi.encode(i))));
        }
        bytes[] memory sorted = ops.sortValues("(uint256,string)", values,
            cb(this.compare.selector, "((uint256,string),(uint256,string))", 2));
        bool[] memory seen = new bool[](n);
        uint256 previousKey;
        uint256 previousIndex;
        for (uint256 i; i < n; i++) {
            Record memory record = abi.decode(sorted[i], (Record));
            uint256 originalIndex = abi.decode(bytes(record.name), (uint256));
            assertLt(originalIndex, n);
            assertFalse(seen[originalIndex]);
            seen[originalIndex] = true;
            assertEq(sorted[i], values[originalIndex]);
            if (i != 0) {
                assertGe(record.key, previousKey);
                if (record.key == previousKey) assertGt(originalIndex, previousIndex);
            }
            previousKey = record.key;
            previousIndex = originalIndex;
        }
    }
}
