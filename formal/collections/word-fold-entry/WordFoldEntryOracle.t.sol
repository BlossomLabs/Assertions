// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract WordFoldEntryShort {
    fallback() external {
        assembly ("memory-safe") {
            mstore(0, 0)
            return(0, 31)
        }
    }
}

contract WordFoldEntryOracleTest {
    Collections private c = new Collections();
    WordFoldEntryShort private target = new WordFoldEntryShort();

    function reject(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected failure");
        require(keccak256(ret) == keccak256(expected), "wrong priority or context");
    }

    function offsets() private pure returns (uint256[] memory a) {
        a = new uint256[](1);
    }

    function testWordsAlignmentBeforeWindows() public view {
        reject(
            abi.encodeCall(
                c.foldWords,
                (hex"01", address(0), bytes(""), type(uint256).max, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(1))
        );
    }

    function testAllEmptyWrappersStillValidateWindows() public view {
        bytes memory want =
            abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(7), uint256(31));
        reject(
            abi.encodeCall(
                c.foldRange, (0, address(0), new bytes(31), 7, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            want
        );
        reject(
            abi.encodeCall(
                c.foldBytes, (bytes(""), address(0), new bytes(31), 7, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            want
        );
        reject(
            abi.encodeCall(
                c.foldWords, (bytes(""), address(0), new bytes(31), 7, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            want
        );
    }

    function testAllEmptyWrappersSkipTarget() public view {
        bytes32 initial = bytes32(uint256(19));
        require(
            c.foldRange(0, address(0), new bytes(32), 0, offsets(), initial, Collections.FoldExit.Any) == initial,
            "empty range"
        );
        require(
            c.foldBytes(bytes(""), address(0), new bytes(32), 0, offsets(), initial, Collections.FoldExit.All)
                == initial,
            "empty bytes"
        );
        require(
            c.foldWords(bytes(""), address(0), new bytes(32), 0, offsets(), initial, Collections.FoldExit.Full)
                == initial,
            "empty words"
        );
    }

    function testAllWindowsCheckedBeforeTarget() public view {
        uint256[] memory slots = new uint256[](3);
        slots[0] = 0;
        slots[1] = 99;
        slots[2] = 48;
        reject(
            abi.encodeCall(
                c.foldRange, (1, address(0), new bytes(64), 0, slots, bytes32(0), Collections.FoldExit.Full)
            ),
            abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, uint256(99), uint256(64))
        );
    }

    function testNonemptyCodeLessTarget() public view {
        reject(
            abi.encodeCall(
                c.foldBytes, (hex"01", address(0), new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0))
        );
    }

    function testEachWrapperBindsItsOwnOperationSelector() public view {
        reject(
            abi.encodeCall(
                c.foldRange, (1, address(target), new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector, c.foldRange.selector, 0, 0, address(target))
        );
        reject(
            abi.encodeCall(
                c.foldBytes,
                (hex"01", address(target), new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector, c.foldBytes.selector, 0, 0, address(target))
        );
        reject(
            abi.encodeCall(
                c.foldWords,
                (new bytes(32), address(target), new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full)
            ),
            abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector, c.foldWords.selector, 0, 0, address(target))
        );
    }
}
