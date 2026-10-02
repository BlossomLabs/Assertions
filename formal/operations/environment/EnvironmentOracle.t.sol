// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

interface OperationsEnvironmentVm {
    function warp(uint256) external;
    function roll(uint256) external;
    function deal(address, uint256) external;
}

contract OperationsEnvironmentOracleTest {
    Operations private op = new Operations();
    OperationsEnvironmentVm private constant vm =
        OperationsEnvironmentVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function testBalance() public {
        vm.deal(address(this), 42);
        require(op.balance(address(this)) == 42);
    }

    function testCodeHash() public view {
        require(op.codeHash(address(op)) == address(op).codehash);
    }

    function testTimestamp() public {
        vm.warp(1700000000);
        vm.roll(1234);
        require(op.timestamp() == 1700000000);
    }

    function testBlockNumber() public {
        vm.roll(1234);
        require(op.blockNumber() == 1234);
    }

    function testChainId() public view {
        require(op.chainId() == block.chainid);
    }

    function testBaseFee() public view {
        require(op.baseFee() == block.basefee);
    }

    function testPrevRandao() public view {
        require(op.prevRandao() == block.prevrandao);
    }

    function testCoinbase() public view {
        require(op.coinbase() == block.coinbase);
    }

    function testGasLimit() public view {
        require(op.gasLimit() == block.gaslimit);
    }

    function testBlobBaseFee() public view {
        require(op.blobBaseFee() == block.blobbasefee);
    }

    function testBlockHash() public {
        vm.roll(1000);
        require(op.blockHash(1000) == bytes32(0) && op.blockHash(1001) == bytes32(0) && op.blockHash(743) == bytes32(0));
    }

    function testOrigin() public view {
        require(op.origin() == tx.origin);
    }

    function testGasPrice() public view {
        require(op.gasPrice() == tx.gasprice);
    }

    function testBlobHash() public view {
        require(op.blobHash(type(uint256).max) == bytes32(0));
    }

    function testCode() public view {
        require(keccak256(op.code(address(op))) == keccak256(address(op).code));
    }
}
