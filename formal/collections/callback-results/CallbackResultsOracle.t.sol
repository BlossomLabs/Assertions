// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract CallbackResultsTarget {
    function echo(uint256 answer) external pure returns (uint256) {
        return answer;
    }

    function twice(uint256 answer) external pure returns (uint256, uint256) {
        return (answer, 0);
    }
    function empty(uint256) external pure {}

    function signal(uint256) external pure {
        assembly {
            mstore(0, shl(224, 0xd271060e))
            revert(0, 4)
        }
    }

    function prefix(uint256) external pure {
        assembly {
            mstore(0, shl(216, 0xd271060e00))
            revert(0, 5)
        }
    }

    function reject(uint256) external pure {
        revert("ordinary");
    }
}

contract CallbackResultsOracleTest {
    Collections private collection = new Collections();
    CallbackResultsTarget private target = new CallbackResultsTarget();

    function callback(bytes4 selector) private view returns (Collections.Callback memory cb) {
        cb.target = address(target);
        cb.selector = selector;
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
    }

    function values(uint256 answer) private pure returns (bytes[] memory v) {
        v = new bytes[](2);
        v[0] = abi.encode(uint256(1));
        v[1] = abi.encode(answer);
    }

    function check(bytes4 selector, uint256 answer, bytes memory reason) private view {
        (bool ok, bytes memory data) = address(collection)
            .staticcall(abi.encodeCall(collection.filterValues, ("uint256", values(answer), callback(selector))));
        require(!ok && keccak256(data) == keccak256(reason), "wrong exact predicate error");
    }

    function invalid(uint256 index) private view returns (bytes memory) {
        return abi.encodeWithSelector(
            AbiCodec.InvalidCallbackResult.selector,
            collection.filterValues.selector,
            index,
            uint256(0),
            address(target)
        );
    }

    function wrapped(bytes4 selector, bytes memory reason) private view returns (bytes memory) {
        return abi.encodeWithSelector(
            Collections.CallbackFailed.selector,
            collection.filterValues.selector,
            uint256(0),
            uint256(0),
            address(target),
            abi.encodeWithSelector(selector, uint256(1)),
            reason
        );
    }

    function testCanonicalZeroAndOne() public view {
        require(collection.filterValues("uint256", values(0), callback(target.echo.selector)).length == 1, "zero");
        require(collection.filterValues("uint256", values(1), callback(target.echo.selector)).length == 2, "one");
    }

    function testNoncanonicalWordRejectsAtItsOwnIndex() public view {
        check(target.echo.selector, 2, invalid(1));
        check(target.echo.selector, type(uint256).max, invalid(1));
    }

    function testTwoWordsAreRejected() public view {
        check(target.twice.selector, 0, invalid(0));
    }

    function testEmptyReturnIsRejected() public view {
        check(target.empty.selector, 0, invalid(0));
    }

    function testExactExhaustionSignalPropagates() public view {
        check(target.signal.selector, 0, hex"d271060e");
    }

    function testLongerSignalPrefixIsWrapped() public view {
        check(target.prefix.selector, 0, wrapped(target.prefix.selector, hex"d271060e00"));
    }

    function testOrdinaryFailurePropagatesBeforePredicateValidation() public view {
        check(
            target.reject.selector,
            0,
            wrapped(target.reject.selector, abi.encodeWithSignature("Error(string)", "ordinary"))
        );
    }
}
