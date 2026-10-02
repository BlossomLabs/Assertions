// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract ReturnOracleTest {
    Expressions private evaluator = new Expressions();

    function check(string memory valueType, bytes memory value, bool encoded) private view {
        Expressions.Expression memory graph;
        graph.nodes = new Expressions.Node[](1);
        graph.nodes[0].kind = Expressions.Kind.Literal;
        graph.nodes[0].valueType = valueType;
        graph.nodes[0].data = value;
        bytes memory callData = encoded
            ? abi.encodeCall(evaluator.evaluateEncoded, (abi.encode(graph), new bytes[](0)))
            : abi.encodeCall(evaluator.evaluate, (graph, new bytes[](0)));
        (bool ok, bytes memory returned) = address(evaluator).staticcall(callData);
        require(ok, "evaluation reverted");
        require(returned.length == value.length, "raw return length");
        require(keccak256(returned) == keccak256(value), "raw return bytes");
    }

    function testDirectWord() public view {
        check("uint256", abi.encode(uint256(73)), false);
    }

    function testEncodedWord() public view {
        check("uint256", abi.encode(uint256(73)), true);
    }

    function testDirectDynamic() public view {
        check("bytes", abi.encode(hex"010203040506070809"), false);
    }

    function testEncodedDynamic() public view {
        check("string", abi.encode("a string long enough to cross the first word"), true);
    }

    function testDirectStaticTuple() public view {
        check("(uint8,int256)", abi.encode(uint8(7), int256(-9)), false);
    }

    function testEncodedEmptyBytes() public view {
        check("bytes", abi.encode(bytes("")), true);
    }
}
