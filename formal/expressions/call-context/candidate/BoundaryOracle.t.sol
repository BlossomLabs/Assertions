// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract SameSelectorTarget {
    function evaluateGuarded(Expressions.Expression calldata, bytes[] calldata, uint256, Expressions.Cache calldata)
        external
        pure
        returns (uint256)
    {
        return 91;
    }
}

contract BoundaryOracleTest {
    Expressions private evaluator = new Expressions();
    bytes4 private constant FORBIDDEN = bytes4(keccak256("GuardedCallForbidden()"));

    function literalGraph(uint256 value) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](1);
        p.nodes[0].valueType = "uint256";
        p.nodes[0].data = abi.encode(value);
    }

    function injected() private pure returns (Expressions.Cache memory c) {
        c = Expressions.Cache(new bytes[](1), new bool[](1), new bool[](1), new uint256[](1));
        c.values[0] = hex"ff";
        c.ready[0] = true;
        c.words[0] = 1;
    }

    function guardedGraph(address target) private view returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](6);
        p.result = 5;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(target);
        p.nodes[1].valueType = "(address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256)";
        p.nodes[1].data = abi.encode(literalGraph(7));
        p.nodes[2].valueType = "bytes[]";
        p.nodes[2].data = abi.encode(new bytes[](0));
        p.nodes[3].valueType = "uint256";
        p.nodes[3].data = abi.encode(uint256(0));
        p.nodes[4].valueType = "(bytes[],bool[],bool[],uint256[])";
        p.nodes[4].data = abi.encode(injected());
        p.nodes[5].kind = Expressions.Kind.Call;
        p.nodes[5].valueType = "uint256[18]";
        p.nodes[5].selector = evaluator.evaluateGuarded.selector;
        p.nodes[5].arguments =
            "((address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256),bytes[],uint256,(bytes[],bool[],bool[],uint256[]))";
        p.nodes[5].refs = new uint256[](5);
        for (uint256 i; i < 5; i++) {
            p.nodes[5].refs[i] = i;
        }
    }

    function check(Expressions.Expression memory p, bool expectedOk, bytes memory expected) private view {
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok == expectedOk, "wrong verdict");
        require(keccak256(result) == keccak256(expected), "wrong exact bytes");
    }

    function probe(bytes memory data) private view returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](3);
        p.result = 2;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(evaluator));
        p.nodes[1].valueType = "bytes";
        p.nodes[1].data = abi.encode(data);
        p.nodes[2].kind = Expressions.Kind.ProbeCall;
        p.nodes[2].valueType = "bytes";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
    }

    function testCallCannotInjectCache() public view {
        check(guardedGraph(address(evaluator)), false, abi.encodeWithSelector(FORBIDDEN));
    }

    function testProbeCannotDispatchGuardedEntry() public view {
        bytes memory data =
            abi.encodeCall(evaluator.evaluateGuarded, (literalGraph(7), new bytes[](0), uint256(0), injected()));
        check(probe(data), false, abi.encodeWithSelector(FORBIDDEN));
    }

    function testProbeCannotDispatchMalformedGuardedEntry() public view {
        check(probe(abi.encodePacked(evaluator.evaluateGuarded.selector)), false, abi.encodeWithSelector(FORBIDDEN));
    }

    function testShortCalldataRetainsProbeBehavior() public view {
        for (uint256 i; i < 4; i++) {
            check(probe(new bytes(i)), true, abi.encode(bytes("")));
        }
    }

    function testSameSelectorOnExternalTargetRemainsAllowed() public {
        SameSelectorTarget target = new SameSelectorTarget();
        Expressions.Expression memory p = guardedGraph(address(target));
        p.nodes[5].valueType = "uint256";
        check(p, true, abi.encode(uint256(91)));
    }

    function testOrdinarySelfEvaluateRemainsAllowed() public view {
        Expressions.Expression memory p = guardedGraph(address(evaluator));
        p.nodes[5].selector = evaluator.evaluate.selector;
        p.nodes[5].arguments = "((address,(uint8,string,bytes,uint256[],bytes4,string)[],uint256),bytes[])";
        p.nodes[5].refs = new uint256[](3);
        p.nodes[5].refs[1] = 1;
        p.nodes[5].refs[2] = 2;
        p.nodes[5].valueType = "uint256";
        check(p, true, abi.encode(uint256(7)));
    }

    function testEncodedEntryRemainsAllowed() public view {
        (bool ok, bytes memory result) = address(evaluator)
            .staticcall(abi.encodeCall(evaluator.evaluateEncoded, (abi.encode(literalGraph(7)), new bytes[](0))));
        require(ok && keccak256(result) == keccak256(abi.encode(uint256(7))), "encoded evaluation changed");
    }
}
