// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract ValueSortTraceTarget {
    struct Item {
        uint256 key;
        uint256 id;
    }

    function byKey(Item calldata a, Item calldata b) external pure returns (int256) {
        return a.key < b.key ? int256(-1) : (a.key == b.key ? int256(0) : int256(1));
    }

    function positive(Item calldata, Item calldata) external pure returns (int256) {
        return 1;
    }

    function laterFailure(Item calldata a, Item calldata b) external pure returns (int256) {
        require(a.id != 1 || b.id != 3, "later");
        return a.key <= b.key ? int256(-1) : int256(1);
    }
}

contract ValueSortTraceOracleTest {
    Collections private collection = new Collections();
    ValueSortTraceTarget private target = new ValueSortTraceTarget();

    function callback(bytes4 selector) private view returns (Collections.Callback memory cb) {
        cb.target = address(target);
        cb.selector = selector;
        cb.arguments = "((uint256,uint256),(uint256,uint256))";
        cb.constants = new bytes[](2);
        cb.second = 1;
    }

    function values(uint256[] memory keys) private pure returns (bytes[] memory v) {
        v = new bytes[](keys.length);
        for (uint256 i; i < keys.length; i++) {
            v[i] = abi.encode(keys[i], i);
        }
    }

    function check(uint256[] memory keys, uint256[] memory expected) private view {
        bytes[] memory v = values(keys);
        bytes[] memory out = collection.sortValues("(uint256,uint256)", v, callback(target.byKey.selector));
        require(out.length == expected.length, "length");
        for (uint256 i; i < out.length; i++) {
            require(keccak256(out[i]) == keccak256(v[expected[i]]), "order or occurrence");
        }
    }

    function testStableOddRunsWithDuplicates() public view {
        uint256[] memory keys = new uint256[](5);
        keys[0] = 2;
        keys[1] = 1;
        keys[2] = 2;
        keys[3] = 0;
        keys[4] = 1;
        uint256[] memory expected = new uint256[](5);
        expected[0] = 3;
        expected[1] = 1;
        expected[2] = 4;
        expected[3] = 0;
        expected[4] = 2;
        check(keys, expected);
    }

    function testEqualKeysKeepEveryOccurrence() public view {
        uint256[] memory keys = new uint256[](5);
        uint256[] memory expected = new uint256[](5);
        for (uint256 i; i < 5; i++) {
            keys[i] = 7;
            expected[i] = i;
        }
        check(keys, expected);
    }

    function testBothRunDrainDirections() public view {
        uint256[] memory keys = new uint256[](4);
        keys[0] = 1;
        keys[1] = 3;
        keys[2] = 7;
        keys[3] = 9;
        uint256[] memory expected = new uint256[](4);
        for (uint256 i; i < 4; i++) {
            expected[i] = i;
        }
        check(keys, expected);
        keys[0] = 7;
        keys[1] = 9;
        keys[2] = 1;
        keys[3] = 3;
        expected[0] = 2;
        expected[1] = 3;
        expected[2] = 0;
        expected[3] = 1;
        check(keys, expected);
    }

    function testEmptyAndSingletonHaveNoComparison() public view {
        Collections.Callback memory cb = callback(target.byKey.selector);
        cb.target = address(0);
        bytes[] memory v = new bytes[](0);
        require(collection.sortValues("(uint256,uint256)", v, cb).length == 0, "empty");
        v = new bytes[](1);
        v[0] = abi.encode(uint256(9), uint256(0));
        bytes[] memory out = collection.sortValues("(uint256,uint256)", v, cb);
        require(out.length == 1 && keccak256(out[0]) == keccak256(v[0]), "singleton");
    }

    function testInconsistentComparatorStillPermutesOnSuccess() public view {
        uint256[] memory keys = new uint256[](5);
        for (uint256 i; i < 5; i++) {
            keys[i] = i + 17;
        }
        bytes[] memory v = values(keys);
        bytes[] memory out = collection.sortValues("(uint256,uint256)", v, callback(target.positive.selector));
        require(out.length == 5, "count");
        bool[] memory seen = new bool[](5);
        for (uint256 i; i < 5; i++) {
            (uint256 key, uint256 id) = abi.decode(out[i], (uint256, uint256));
            require(id < 5 && !seen[id] && key == keys[id], "permutation");
            seen[id] = true;
        }
    }

    function testLaterFailurePreservesCurrentPositionsAndOperands() public view {
        uint256[] memory keys = new uint256[](4);
        keys[0] = 5;
        keys[1] = 2;
        keys[2] = 7;
        keys[3] = 3;
        (bool ok, bytes memory actual) = address(collection)
            .staticcall(
                abi.encodeCall(
                    Collections.sortValues, ("(uint256,uint256)", values(keys), callback(target.laterFailure.selector))
                )
            );
        bytes memory data = abi.encodeWithSelector(
            target.laterFailure.selector, ValueSortTraceTarget.Item(2, 1), ValueSortTraceTarget.Item(3, 3)
        );
        bytes memory expected = abi.encodeWithSelector(
            Collections.CallbackFailed.selector,
            collection.sortValues.selector,
            uint256(0),
            uint256(2),
            address(target),
            data,
            abi.encodeWithSignature("Error(string)", "later")
        );
        require(!ok && keccak256(actual) == keccak256(expected), "failure context");
    }
}
