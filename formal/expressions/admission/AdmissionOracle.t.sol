// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";
import {InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract AdmissionOracleTest {
    Expressions private evaluator = new Expressions();

    function literal() private pure returns (Expressions.Node memory n) {
        n.kind = Expressions.Kind.Literal;
        n.valueType = "uint256";
        n.data = abi.encode(uint256(7));
        n.refs = new uint256[](0);
    }

    function graph(uint256 count) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](count);
        for (uint256 i; i < count; i++) {
            p.nodes[i] = literal();
        }
    }

    function check(Expressions.Expression memory p, bool success, bytes memory expected) private view {
        (bool ok, bytes memory actual) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok == success, "wrong verdict");
        require(keccak256(actual) == keccak256(expected), "wrong exact bytes");
    }

    function testResultBoundsPrecedeAllParsing() public view {
        Expressions.Expression memory p = graph(1);
        p.result = 1;
        p.nodes[0].valueType = "(";
        check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
    }

    function testShapePrecedesReferencesAndArity() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].kind = Expressions.Kind.Select;
        p.nodes[0].valueType = "(";
        p.nodes[0].refs = new uint256[](1);
        check(p, false, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1)));
    }

    function testReferencePrecedesArity() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].kind = Expressions.Kind.Select;
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].refs[0] = 1;
        check(p, false, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(1), uint256(1)));
    }

    function testFirstInvalidReferenceInListOrder() public view {
        Expressions.Expression memory p = graph(3);
        p.nodes[2].kind = Expressions.Kind.Tuple;
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[0] = 3;
        p.nodes[2].refs[1] = 2;
        check(p, false, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(2), uint256(3)));
    }

    function testUnusedNodeStillNeedsAValidDescriptor() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].valueType = "(";
        check(p, false, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1)));
    }

    function testBadNodeArity() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].kind = Expressions.Kind.Select;
        p.nodes[1].refs = new uint256[](2);
        check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].refs = new uint256[](0);
        check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
        p.nodes[1].kind = Expressions.Kind.Parameter;
        p.nodes[1].refs = new uint256[](1);
        check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
    }

    function testProbeCalldataTypeAdmission() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].kind = Expressions.Kind.ProbeCall;
        p.nodes[1].refs = new uint256[](2);
        check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
        p.nodes[0].valueType = "bytes";
        p.nodes[0].data = abi.encode(bytes("data"));
        check(p, true, p.nodes[0].data);
    }

    function testUnusedNodeDataIsNotEvaluated() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].kind = Expressions.Kind.Parameter;
        p.nodes[1].data = hex"01";
        check(p, true, abi.encode(uint256(7)));
    }

    function testEveryKindArityFamily() public view {
        for (uint8 k; k <= uint8(Expressions.Kind.ProbeCall); ++k) {
            Expressions.Expression memory p = graph(2);
            p.nodes[0].valueType = "bytes";
            p.nodes[0].data = abi.encode(bytes("admission"));
            Expressions.Kind kind = Expressions.Kind(k);
            p.nodes[1].kind = kind;
            uint256 count;
            if (kind == Expressions.Kind.Call || kind == Expressions.Kind.Wrap || kind == Expressions.Kind.IsValid) {
                count = 1;
            } else if (kind == Expressions.Kind.Select) {
                count = 3;
            } else if (
                kind == Expressions.Kind.TryOrElse || kind == Expressions.Kind.ProbeCall
                    || kind == Expressions.Kind.Array || kind == Expressions.Kind.Tuple
            ) {
                count = 2;
            }
            p.nodes[1].refs = new uint256[](count);
            check(p, true, p.nodes[0].data);
            if (kind == Expressions.Kind.Array || kind == Expressions.Kind.Tuple) {
                p.nodes[1].refs = new uint256[](0);
                check(p, true, p.nodes[0].data);
            } else {
                p.nodes[1].refs = new uint256[](count == 0 ? 1 : count - 1);
                check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
            }
        }
    }
}
