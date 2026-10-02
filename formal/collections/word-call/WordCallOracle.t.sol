// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract WordCallEcho {
    fallback() external {
        assembly ("memory-safe") {
            mstore(0, calldataload(0))
            return(0, 32)
        }
    }
}

contract WordCallShort {
    fallback() external {
        assembly ("memory-safe") {
            mstore(0, 0)
            return(0, 31)
        }
    }
}

contract WordCallLong {
    fallback() external {
        assembly ("memory-safe") {
            mstore(0, 0)
            mstore(32, 0)
            return(0, 64)
        }
    }
}

contract WordCallLaterFailure {
    fallback() external {
        uint256 x;
        assembly ("memory-safe") { x := calldataload(0) }
        if (x == 2) {
            assembly ("memory-safe") {
                mstore(0, 0x030405)
                revert(29, 3)
            }
        }
        assembly ("memory-safe") {
            mstore(0, x)
            return(0, 32)
        }
    }
}

contract WordCallSignal {
    fallback() external {
        assembly ("memory-safe") {
            mstore(0, 0xd271060e)
            revert(28, 4)
        }
    }
}

contract WordCallOracleTest {
    Collections private c = new Collections();
    WordCallEcho private echoTarget = new WordCallEcho();
    WordCallShort private shortTarget = new WordCallShort();
    WordCallLong private longTarget = new WordCallLong();
    WordCallLaterFailure private laterTarget = new WordCallLaterFailure();
    WordCallSignal private signalTarget = new WordCallSignal();

    function offsets() private pure returns (uint256[] memory a) {
        a = new uint256[](1);
    }

    function rangeCall(uint256 n, address target) private view returns (bytes memory) {
        return
            abi.encodeCall(c.foldRange, (n, target, new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full));
    }

    function reject(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected rejection");
        require(keccak256(ret) == keccak256(expected), "wrong exact error");
    }

    function testRangeUsesCurrentIndex() public view {
        require(
            c.foldRange(3, address(echoTarget), new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full)
                == bytes32(uint256(2)),
            "range value"
        );
    }

    function testBytesUseByteValue() public view {
        require(
            c.foldBytes(
                    hex"8307", address(echoTarget), new bytes(32), 0, offsets(), bytes32(0), Collections.FoldExit.Full
                ) == bytes32(uint256(7)),
            "byte value"
        );
    }

    function testWordsKeepFullUnsignedValue() public view {
        require(
            c.foldWords(
                abi.encode(uint256(23), type(uint256).max),
                address(echoTarget),
                new bytes(32),
                0,
                offsets(),
                bytes32(0),
                Collections.FoldExit.Full
            ) == bytes32(type(uint256).max),
            "word value"
        );
    }

    function testShortReturnRejected() public view {
        reject(
            rangeCall(1, address(shortTarget)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.foldRange.selector, 0, 0, address(shortTarget)
            )
        );
    }

    function testLongReturnRejected() public view {
        reject(
            rangeCall(1, address(longTarget)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.foldRange.selector, 0, 0, address(longTarget)
            )
        );
    }

    function testLaterFailureHasCurrentIndexAndCalldata() public view {
        reject(
            rangeCall(3, address(laterTarget)),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                c.foldRange.selector,
                2,
                0,
                address(laterTarget),
                abi.encode(uint256(2)),
                hex"030405"
            )
        );
    }

    function testExactReservedSignalPropagates() public view {
        reject(rangeCall(1, address(signalTarget)), hex"d271060e");
    }

    function testCodeLessTargetRejected() public view {
        reject(rangeCall(1, address(0)), abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0)));
    }
}
