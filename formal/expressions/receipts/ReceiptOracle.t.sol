// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract ErrorPayloadTarget {
    function fail(bytes calldata reason) external pure {
        assembly {
            calldatacopy(0, reason.offset, reason.length)
            revert(0, reason.length)
        }
    }
}

contract ReceiptOracleTest {
    Expressions private evaluator = new Expressions();
    ErrorPayloadTarget private target = new ErrorPayloadTarget();

    function payload(uint256 n) private pure returns (bytes memory data) {
        data = new bytes(n);
        for (uint256 i; i < n; i++) {
            data[i] = bytes1(uint8(i + 17));
        }
    }

    function checkFailure(uint256 n) private view {
        bytes memory reason = payload(n);
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](3);
        p.result = 2;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(target));
        p.nodes[1].valueType = "bytes";
        p.nodes[1].data = abi.encode(reason);
        p.nodes[2].kind = Expressions.Kind.Call;
        p.nodes[2].valueType = "uint256";
        p.nodes[2].selector = target.fail.selector;
        p.nodes[2].arguments = "(bytes)";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        (bool ok, bytes memory data) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(!ok, "must revert");
        bytes memory expected = abi.encodeWithSelector(
            Expressions.NodeCallFailed.selector,
            uint256(2),
            address(target),
            abi.encodeCall(target.fail, (reason)),
            reason
        );
        require(keccak256(data) == keccak256(expected), "exact dynamic error frame");
    }

    function testEmptyPayload() public view {
        checkFailure(0);
    }

    function testSingleBytePayload() public view {
        checkFailure(1);
    }

    function testPartialWordPayload() public view {
        checkFailure(31);
    }

    function testWordPayload() public view {
        checkFailure(32);
    }

    function testPastWordPayload() public view {
        checkFailure(33);
    }

    function testMultiwordPayload() public view {
        checkFailure(65);
    }
}
