// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../../contracts/Operations.sol";

/// @dev Forge-only transaction-context fixture. It does not submit a real blob transaction.
contract ClaimCoverageBlobTest is Test {
    function test_O38_InjectedBlobHashesAndOutOfRangeIndices() public {
        Operations ops = new Operations();
        bytes32[] memory hashes = new bytes32[](3);
        hashes[0] = bytes32((uint256(1) << 248) | uint256(17));
        hashes[1] = bytes32((uint256(1) << 248) | uint256(29));
        hashes[2] = bytes32((uint256(1) << 248) | uint256(43));
        vm.blobhashes(hashes);
        for (uint256 i; i < hashes.length; i++) {
            assertEq(ops.blobHash(i), hashes[i]);
        }
        assertEq(ops.blobHash(3), bytes32(0));
        assertEq(ops.blobHash(type(uint256).max), bytes32(0));
        vm.blobhashes(new bytes32[](0));
        assertEq(ops.blobHash(0), bytes32(0));
    }
}
