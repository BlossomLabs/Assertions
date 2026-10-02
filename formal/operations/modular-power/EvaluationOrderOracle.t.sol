// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

contract ModularPowerEvaluationOrderProbe {
    function observe() external view returns (uint256 beforeSize, uint256 afterSize, bool done, uint256 result) {
        assembly ("memory-safe") {
            let p := mload(0x40)
            mstore(p, 32)
            mstore(add(p, 0x20), 32)
            mstore(add(p, 0x40), 32)
            mstore(add(p, 0x60), 2)
            mstore(add(p, 0x80), 0x100000000)
            mstore(add(p, 0xa0), 3)
            beforeSize := returndatasize()
            if and(staticcall(gas(), 0x05, p, 0xc0, p, 0x20), eq(returndatasize(), 32)) { done := 1 }
            afterSize := returndatasize()
            result := mload(p)
        }
    }
}

contract OperationsModularPowerEvaluationOrderOracleTest {
    ModularPowerEvaluationOrderProbe private probe = new ModularPowerEvaluationOrderProbe();

    function testPriorSizeReadBeforeSuccessfulModexp() public view {
        (uint256 beforeSize, uint256 afterSize, bool done, uint256 result) = probe.observe();
        require(beforeSize == 0);
        require(afterSize == 32 && result == 1);
        require(!done);
    }
}
