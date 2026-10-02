// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract WordFoldLoopTarget {
    function step(uint256 acc, uint256 elem) external pure returns (uint256) {
        return acc * 10 + elem + 1;
    }

    function anyStop(uint256, uint256 elem) external pure returns (uint256) {
        require(elem < 2, "unreachable any");
        return elem == 0 ? 0 : 9;
    }

    function allStop(uint256, uint256 elem) external pure returns (uint256) {
        require(elem < 2, "unreachable all");
        return elem == 0 ? 7 : 0;
    }

    function zero(uint256, uint256) external pure returns (uint256) {
        return 0;
    }

    function fail(uint256, uint256) external pure returns (uint256) {
        revert("first call required");
    }

    function later(uint256 acc, uint256 elem) external pure returns (uint256) {
        require(elem < 2, "later failure");
        return acc * 10 + elem + 1;
    }
}

contract WordFoldLoopOracleTest {
    Collections private c = new Collections();
    WordFoldLoopTarget private target = new WordFoldLoopTarget();

    function offsets() private pure returns (uint256[] memory a) {
        a = new uint256[](1);
        a[0] = 36;
    }

    function data(bytes4 selector) private pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, uint256(0), uint256(0));
    }

    function range(uint256 n, bytes4 selector, uint256 init, Collections.FoldExit mode) private view returns (uint256) {
        return uint256(c.foldRange(n, address(target), data(selector), 4, offsets(), bytes32(init), mode));
    }

    function reject(bytes memory callData, uint256 index, bytes memory sent, bytes memory reason) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(callData);
        require(!ok, "expected failure");
        require(
            keccak256(ret)
                == keccak256(
                    abi.encodeWithSelector(
                        Collections.CallbackFailed.selector,
                        c.foldRange.selector,
                        index,
                        0,
                        address(target),
                        sent,
                        reason
                    )
                ),
            "wrong failure context"
        );
    }

    function testFullNonCommutativeAccumulatorFeedback() public view {
        require(range(3, target.step.selector, 2, Collections.FoldExit.Full) == 2123, "feedback");
    }

    function testAnyStopsBeforeFailingSuffix() public view {
        require(range(5, target.anyStop.selector, 17, Collections.FoldExit.Any) == 9, "any stop");
    }

    function testAllStopsBeforeFailingSuffix() public view {
        require(range(5, target.allStop.selector, 0, Collections.FoldExit.All) == 0, "all stop");
    }

    function testAnyDoesNotJudgeInitialAccumulator() public view {
        require(range(1, target.zero.selector, 99, Collections.FoldExit.Any) == 0, "initial any");
    }

    function testAllStillCallsWithInitialZero() public view {
        reject(
            abi.encodeCall(
                c.foldRange,
                (1, address(target), data(target.fail.selector), 4, offsets(), bytes32(0), Collections.FoldExit.All)
            ),
            0,
            abi.encodeWithSelector(target.fail.selector, uint256(0), uint256(0)),
            abi.encodeWithSignature("Error(string)", "first call required")
        );
    }

    function testExactLaterFailureUsesUpdatedAccumulator() public view {
        reject(
            abi.encodeCall(
                c.foldRange,
                (
                    5,
                    address(target),
                    data(target.later.selector),
                    4,
                    offsets(),
                    bytes32(uint256(2)),
                    Collections.FoldExit.Full
                )
            ),
            2,
            abi.encodeWithSelector(target.later.selector, uint256(212), uint256(2)),
            abi.encodeWithSignature("Error(string)", "later failure")
        );
    }

    function testBytesAndWordsUseTheirDomains() public view {
        require(
            uint256(
                c.foldBytes(
                    hex"0205",
                    address(target),
                    data(target.step.selector),
                    4,
                    offsets(),
                    bytes32(uint256(1)),
                    Collections.FoldExit.Full
                )
            ) == 136,
            "bytes feedback"
        );
        require(
            uint256(
                c.foldWords(
                    abi.encode(uint256(2), uint256(5)),
                    address(target),
                    data(target.step.selector),
                    4,
                    offsets(),
                    bytes32(uint256(1)),
                    Collections.FoldExit.Full
                )
            ) == 136,
            "words feedback"
        );
    }

    function testEmptyKeepsInitialAcrossAllModes() public view {
        for (uint8 mode; mode < 3; mode++) {
            require(
                c.foldRange(
                    0,
                    address(0),
                    data(target.step.selector),
                    4,
                    offsets(),
                    bytes32(uint256(37)),
                    Collections.FoldExit(mode)
                ) == bytes32(uint256(37)),
                "empty initial"
            );
        }
    }
}
