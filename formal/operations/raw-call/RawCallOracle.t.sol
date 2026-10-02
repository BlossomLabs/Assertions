// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsRawCallEcho {
    fallback(bytes calldata data) external returns (bytes memory) {
        return data;
    }
}

contract OperationsRawCallRevert {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            revert(0, calldatasize())
        }
    }
}

contract OperationsRawCallBurn {
    fallback() external {
        assembly { for {} 1 {} {} }
    }
}

contract OperationsRawCallOracleTest {
    Operations private op = new Operations();
    OperationsRawCallEcho private echo = new OperationsRawCallEcho();
    OperationsRawCallRevert private failing = new OperationsRawCallRevert();
    OperationsRawCallBurn private burner = new OperationsRawCallBurn();

    function _failed(address target, bytes memory data, bytes memory expected, uint256 gasBudget) private view {
        (bool ok, bytes memory ret) =
            address(op).staticcall{gas: gasBudget}(abi.encodeWithSignature("rawCall(address,bytes)", target, data));
        require(!ok && keccak256(ret) == keccak256(expected));
    }

    function testSuccess() public view {
        require(keccak256(op.rawCall(address(echo), hex"1234ff00")) == keccak256(hex"1234ff00"));
    }

    function testOrdinaryFailure() public view {
        _failed(
            address(failing),
            hex"aabbcc",
            abi.encodeWithSelector(Operations.RawCallFailed.selector, address(failing), hex"aabbcc"),
            1000000
        );
    }

    function testExactSignalAndLongPrefix() public view {
        bytes memory signal = abi.encodeWithSelector(Operations.SubcallOutOfGas.selector);
        _failed(address(failing), signal, signal, 1000000);
        bytes memory longer = bytes.concat(signal, hex"ff");
        _failed(
            address(failing),
            longer,
            abi.encodeWithSelector(Operations.RawCallFailed.selector, address(failing), longer),
            1000000
        );
    }

    function testCodeLess() public view {
        require(op.rawCall(address(0x12345), hex"1234").length == 0);
    }

    function testIdentityPrecompile() public view {
        require(keccak256(op.rawCall(address(4), hex"1234ff00")) == keccak256(hex"1234ff00"));
    }

    function testGasBurner() public view {
        _failed(address(burner), hex"", abi.encodeWithSelector(Operations.SubcallOutOfGas.selector), 400000);
    }
}
