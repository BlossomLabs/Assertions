// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract CallerContextTest {
    function testGraphSelfCallCanSupplyGuardedCache() public {
        Expressions e = new Expressions();
        Expressions.Expression memory inner;
        inner.nodes = new Expressions.Node[](1);
        inner.nodes[0].kind = Expressions.Kind.Literal;
        inner.nodes[0].valueType = "uint256";
        inner.nodes[0].data = abi.encode(uint256(7));
        inner.nodes[0].refs = new uint256[](0);
        Expressions.Cache memory injected =
            Expressions.Cache(new bytes[](1), new bool[](1), new bool[](1), new uint256[](1));
        injected.values[0] = hex"ff";
        injected.ready[0] = true;
        injected.words[0] = 1;
        Expressions.Expression memory outer;
        outer.nodes = new Expressions.Node[](6);
        outer.result = 5;
        for (uint256 i; i < 5; i++) {
            outer.nodes[i].kind = Expressions.Kind.Literal;
            outer.nodes[i].refs = new uint256[](0);
        }
        outer.nodes[0].valueType = "address";
        outer.nodes[0].data = abi.encode(address(e));
        outer.nodes[1].valueType = "(address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256)";
        outer.nodes[1].data = abi.encode(inner);
        outer.nodes[2].valueType = "bytes[]";
        outer.nodes[2].data = abi.encode(new bytes[](0));
        outer.nodes[3].valueType = "uint256";
        outer.nodes[3].data = abi.encode(uint256(0));
        outer.nodes[4].valueType = "(bytes[],bool[],bool[],uint256[])";
        outer.nodes[4].data = abi.encode(injected);
        outer.nodes[5].kind = Expressions.Kind.Call;
        outer.nodes[5].refs = new uint256[](5);
        for (uint256 i; i < 5; i++) {
            outer.nodes[5].refs[i] = i;
        }
        outer.nodes[5].selector = e.evaluateGuarded.selector;
        outer.nodes[5].arguments =
            "((address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256),bytes[],uint256,(bytes[],bool[],bool[],uint256[]))";
        bytes memory expected = abi.encode(hex"ff", injected);
        require(expected.length == 18 * 32, "unexpected solc geometry");
        outer.nodes[5].valueType = "uint256[18]";
        (bool ok, bytes memory actual) = address(e).staticcall(abi.encodeCall(e.evaluate, (outer, new bytes[](0))));
        require(ok, "indirect self-call failed");
        require(keccak256(actual) == keccak256(expected), "cache bytes differed");
        (bytes memory value, Expressions.Cache memory returned) = abi.decode(actual, (bytes, Expressions.Cache));
        require(keccak256(value) == keccak256(hex"ff") && returned.ready[0], "not supplied cache");
    }
}
