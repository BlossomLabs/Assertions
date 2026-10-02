// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract ComparatorTarget {
    function minimum(uint256, uint256) external pure returns (int256) {
        return type(int256).min;
    }

    function negativeOne(uint256, uint256) external pure returns (int256) {
        return -1;
    }

    function zero(uint256, uint256) external pure returns (int256) {
        return 0;
    }

    function maximum(uint256, uint256) external pure returns (int256) {
        return type(int256).max;
    }

    function positiveOne(uint256, uint256) external pure returns (int256) {
        return 1;
    }

    function shortResult(uint256, uint256) external pure {
        assembly {
            mstore(0, 0)
            return(0, 31)
        }
    }

    function longResult(uint256, uint256) external pure {
        assembly {
            mstore(0, 0)
            mstore(32, 0)
            return(0, 33)
        }
    }

    function badLaterPair(uint256 a, uint256 b) external pure returns (int256) {
        if (a == 2 && b == 3) assembly { return(0, 0) }
        return a <= b ? int256(-1) : int256(1);
    }

    function revertLaterPair(uint256 a, uint256 b) external pure returns (int256) {
        require(a != 2 || b != 3, "pair");
        return a <= b ? int256(-1) : int256(1);
    }

    function signal(uint256, uint256) external pure {
        revert Collections.SubcallOutOfGas();
    }
}

contract ComparatorOracleTest {
    Collections private collection = new Collections();
    ComparatorTarget private target = new ComparatorTarget();

    function callback(bytes4 selector) private view returns (Collections.Callback memory cb) {
        cb.target = address(target);
        cb.selector = selector;
        cb.arguments = "(uint256,uint256)";
        cb.constants = new bytes[](2);
        cb.second = 1;
    }

    function pair() private pure returns (bytes[] memory v) {
        v = new bytes[](2);
        v[0] = abi.encode(uint256(91));
        v[1] = abi.encode(uint256(4));
    }

    function four() private pure returns (bytes[] memory v) {
        v = new bytes[](4);
        v[0] = abi.encode(uint256(5));
        v[1] = abi.encode(uint256(2));
        v[2] = abi.encode(uint256(7));
        v[3] = abi.encode(uint256(3));
    }

    function order(bytes4 selector, bool left) private view {
        bytes[] memory out = collection.sortValues("uint256", pair(), callback(selector));
        require(out.length == 2, "length");
        require(abi.decode(out[0], (uint256)) == (left ? 91 : 4), "first");
        require(abi.decode(out[1], (uint256)) == (left ? 4 : 91), "second");
    }

    function failure(bytes4 selector, bytes[] memory values, bytes memory expected) private view {
        (bool ok, bytes memory actual) = address(collection)
            .staticcall(abi.encodeCall(Collections.sortValues, ("uint256", values, callback(selector))));
        require(!ok && keccak256(actual) == keccak256(expected), "wrong exact error");
    }

    function testSignedMinimum() public view {
        order(target.minimum.selector, true);
    }

    function testNegativeOne() public view {
        order(target.negativeOne.selector, true);
    }

    function testZeroIsLeftBiased() public view {
        order(target.zero.selector, true);
    }

    function testSignedMaximum() public view {
        order(target.maximum.selector, false);
    }

    function testPositiveOne() public view {
        order(target.positiveOne.selector, false);
    }

    function testExactResultLength() public view {
        bytes memory expected = abi.encodeWithSelector(
            AbiCodec.InvalidCallbackResult.selector,
            collection.sortValues.selector,
            uint256(0),
            uint256(1),
            address(target)
        );
        failure(target.shortResult.selector, pair(), expected);
        failure(target.longResult.selector, pair(), expected);
    }

    function testCurrentMergeIndices() public view {
        failure(
            target.badLaterPair.selector,
            four(),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                collection.sortValues.selector,
                uint256(0),
                uint256(2),
                address(target)
            )
        );
    }

    function testWrappedRevertPreservesContextAndCalldata() public view {
        failure(
            target.revertLaterPair.selector,
            four(),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                collection.sortValues.selector,
                uint256(0),
                uint256(2),
                address(target),
                abi.encodeWithSelector(target.revertLaterPair.selector, uint256(2), uint256(3)),
                abi.encodeWithSignature("Error(string)", "pair")
            )
        );
    }

    function testExhaustionSignalPrecedesResultCheck() public view {
        failure(target.signal.selector, pair(), abi.encodeWithSelector(Collections.SubcallOutOfGas.selector));
    }
}
