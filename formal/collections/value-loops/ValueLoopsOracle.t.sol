// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract ValueLoopsTarget {
    function identity(uint256 x) external pure returns (uint256) {
        return x;
    }

    function odd(uint256 x) external pure returns (bool) {
        return x % 2 == 1;
    }

    function append(uint256 acc, uint256 x) external pure returns (uint256) {
        return acc * 10 + x;
    }

    function rejectTwo(uint256 x) external pure returns (uint256) {
        require(x != 2, "two");
        return x;
    }
}

contract ValueLoopsOracleTest {
    Collections private collection = new Collections();
    ValueLoopsTarget private target = new ValueLoopsTarget();

    function callback(bytes4 selector, bool binary) private view returns (Collections.Callback memory cb) {
        cb.target = address(target);
        cb.selector = selector;
        cb.arguments = binary ? "(uint256,uint256)" : "(uint256)";
        cb.constants = new bytes[](binary ? 2 : 1);
        cb.second = 1;
    }

    function values(uint256 a, uint256 b, uint256 c) private pure returns (bytes[] memory v) {
        v = new bytes[](3);
        v[0] = abi.encode(a);
        v[1] = abi.encode(b);
        v[2] = abi.encode(c);
    }

    function check(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory actual) = address(collection).staticcall(data);
        require(!ok && keccak256(actual) == keccak256(expected), "wrong exact failure");
    }

    function testMapRetainsEveryResult() public view {
        bytes[] memory v = values(7, 2, 9);
        bytes[] memory out = collection.mapValues("uint256", "uint256", v, callback(target.identity.selector, false));
        require(keccak256(abi.encode(out)) == keccak256(abi.encode(v)), "map");
    }

    function testFilterShrinksAndPreservesOriginalOrder() public view {
        bytes[] memory out = collection.filterValues("uint256", values(7, 2, 9), callback(target.odd.selector, false));
        require(out.length == 2 && abi.decode(out[0], (uint256)) == 7 && abi.decode(out[1], (uint256)) == 9, "filter");
    }

    function testFoldThreadsAccumulatorInOrder() public view {
        bytes memory out = collection.foldValues(
            "uint256", "uint256", values(1, 2, 3), abi.encode(uint256(4)), callback(target.append.selector, true)
        );
        require(abi.decode(out, (uint256)) == 4123, "fold");
    }

    function testEmptyInputNeverChecksTarget() public view {
        Collections.Callback memory cb = callback(target.identity.selector, false);
        cb.target = address(0);
        bytes[] memory empty = new bytes[](0);
        require(collection.mapValues("uint256", "uint256", empty, cb).length == 0, "map empty");
        require(collection.filterValues("uint256", empty, cb).length == 0, "filter empty");
        cb = callback(target.append.selector, true);
        cb.target = address(0);
        require(
            abi.decode(collection.foldValues("uint256", "uint256", empty, abi.encode(uint256(42)), cb), (uint256))
                == 42,
            "fold empty"
        );
    }

    function testMapFirstInvalidResultPrecedesLaterInvalidInput() public view {
        Collections.Callback memory cb = callback(target.identity.selector, false);
        bytes[] memory v = values(1, 256, 3);
        v[2] = hex"";
        check(
            abi.encodeCall(collection.mapValues, ("uint256", "uint8", v, cb)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                collection.mapValues.selector,
                uint256(1),
                uint256(0),
                address(target)
            )
        );
    }

    function testFoldValidatesInitialBeforeTarget() public view {
        Collections.Callback memory cb = callback(target.append.selector, true);
        cb.target = address(0);
        check(
            abi.encodeCall(collection.foldValues, ("uint256", "uint8", values(1, 2, 3), abi.encode(uint256(256)), cb)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
        );
    }

    function testCallbackFailurePreservesFirstIndexAndBytes() public view {
        Collections.Callback memory cb = callback(target.rejectTwo.selector, false);
        bytes[] memory v = values(1, 2, 3);
        v[2] = hex"";
        check(
            abi.encodeCall(collection.mapValues, ("uint256", "uint256", v, cb)),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                collection.mapValues.selector,
                uint256(1),
                uint256(0),
                address(target),
                abi.encodeCall(target.rejectTwo, (uint256(2))),
                abi.encodeWithSignature("Error(string)", "two")
            )
        );
    }
}
