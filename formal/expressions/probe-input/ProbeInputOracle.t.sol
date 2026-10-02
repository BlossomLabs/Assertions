// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract EchoRevertPayload {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            revert(0, calldatasize())
        }
    }
}

contract ProbeInputOracleTest {
    Expressions private evaluator = new Expressions();
    EchoRevertPayload private target = new EchoRevertPayload();

    function check(uint256 n) private view {
        bytes memory data = new bytes(n);
        for (uint256 i; i < n; i++) {
            data[i] = bytes1(uint8(i + 19));
        }
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](3);
        p.result = 2;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(target));
        p.nodes[1].valueType = "bytes";
        p.nodes[1].data = abi.encode(data);
        p.nodes[2].kind = Expressions.Kind.ProbeCall;
        p.nodes[2].valueType = "bytes";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        (bool ok, bytes memory output) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok, "probe failed");
        require(keccak256(output) == keccak256(abi.encode(data)), "calldata payload changed");
    }

    function testEmptyPayload() public view {
        check(0);
    }

    function testShortPayload() public view {
        check(3);
    }

    function testExactSelectorPayload() public view {
        check(4);
    }

    function testWordPayload() public view {
        check(32);
    }

    function testUnalignedPayload() public view {
        check(33);
    }

    function testMultipleWordsPayload() public view {
        check(97);
    }
}
