// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract CompoundOracleTest {
    Expressions private evaluator = new Expressions();

    function graph(uint256 n) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](n);
        p.result = n - 1;
    }

    function check(Expressions.Expression memory p, bytes memory expected) private view {
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok, "evaluation failed");
        require(keccak256(result) == keccak256(expected), "canonical bytes");
    }

    function testWrapPreservesWholeEncoding() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[0].valueType = "bytes";
        p.nodes[0].data = abi.encode(hex"aabbcc");
        p.nodes[1].kind = Expressions.Kind.Wrap;
        p.nodes[1].valueType = "bytes";
        p.nodes[1].refs = new uint256[](1);
        check(p, abi.encode(abi.encode(hex"aabbcc")));
    }

    struct Pair {
        uint256 n;
        bytes data;
    }

    function testDynamicTupleOuterOffset() public view {
        Expressions.Expression memory p = graph(3);
        p.nodes[0].valueType = "uint256";
        p.nodes[0].data = abi.encode(uint256(7));
        p.nodes[1].valueType = "bytes";
        p.nodes[1].data = abi.encode(hex"aabbcc");
        p.nodes[2].kind = Expressions.Kind.Tuple;
        p.nodes[2].valueType = "(uint256,bytes)";
        p.nodes[2].arguments = "(uint256,bytes)";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        check(p, abi.encode(Pair(7, hex"aabbcc")));
    }

    function testStaticTupleNoOuterOffset() public view {
        Expressions.Expression memory p = graph(3);
        p.nodes[0].valueType = "uint256";
        p.nodes[0].data = abi.encode(uint256(7));
        p.nodes[1].valueType = "uint256";
        p.nodes[1].data = abi.encode(uint256(9));
        p.nodes[2].kind = Expressions.Kind.Tuple;
        p.nodes[2].valueType = "(uint256,uint256)";
        p.nodes[2].arguments = "(uint256,uint256)";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        check(p, abi.encode(uint256(7), uint256(9)));
    }

    function testDynamicArrayElements() public view {
        Expressions.Expression memory p = graph(3);
        p.nodes[0].valueType = "bytes";
        p.nodes[0].data = abi.encode(hex"aabbcc");
        p.nodes[1].valueType = "bytes";
        p.nodes[1].data = abi.encode(bytes(""));
        p.nodes[2].kind = Expressions.Kind.Array;
        p.nodes[2].valueType = "bytes[]";
        p.nodes[2].arguments = "bytes";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        bytes[] memory values = new bytes[](2);
        values[0] = hex"aabbcc";
        check(p, abi.encode(values));
    }

    function testEmptyArray() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].kind = Expressions.Kind.Array;
        p.nodes[0].valueType = "uint256[]";
        p.nodes[0].arguments = "uint256";
        check(p, abi.encode(new uint256[](0)));
    }
}
