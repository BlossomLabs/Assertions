// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/ERC8211.sol";

interface IReferenceComposable {
    function executeComposableDelegateCall(ComposableExecution[] calldata entries) external;
}

// A predicate-only delegatecall host for the pinned deployed Biconomy runtime.
// The TypeScript differential test installs it at its original address.
contract ERC8211ReferenceHarness {
    function judge(InputParam calldata param) external {
        ComposableExecution[] memory entries = new ComposableExecution[](1);
        InputParam[] memory params = new InputParam[](1);
        params[0] = param;
        entries[0] = ComposableExecution(bytes4(0), params, new OutputParam[](0));
        (bool ok, bytes memory result) = address(0x0000821108B5C9F3fe17E40811bE5b66DaF8f0e7)
            .delegatecall(abi.encodeCall(IReferenceComposable.executeComposableDelegateCall, (entries)));
        if (!ok) assembly ("memory-safe") { revert(add(result, 32), mload(result)) }
    }

    function words() external pure returns (uint256, uint256, int256) {
        return (42, 999, -7);
    }
}
