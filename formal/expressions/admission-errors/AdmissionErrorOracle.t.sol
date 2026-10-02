// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";
import {InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract AdmissionErrorOracleTest {
    Expressions private evaluator = new Expressions();

    function graph(uint256 count) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](count);
        for (uint256 i; i < count; i++) {
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(uint256(73));
        }
    }

    function check(Expressions.Expression memory p, bytes memory expected) private view {
        (bool ok, bytes memory reason) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(!ok, "admission must fail");
        require(keccak256(reason) == keccak256(expected), "exact admission error");
    }

    function testFullWidthResultBeforeDescriptor() public view {
        Expressions.Expression memory p = graph(1);
        p.result = type(uint256).max;
        p.nodes[0].valueType = "";
        check(p, abi.encodeWithSelector(Expressions.InvalidNode.selector, type(uint256).max));
    }

    function testFullWidthReference() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].kind = Expressions.Kind.Wrap;
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].refs[0] = type(uint256).max;
        check(p, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(1), type(uint256).max));
    }

    function testDescriptorBeforeReference() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].valueType = "";
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].refs[0] = 99;
        check(p, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(0)));
    }

    function testUnreachableDescriptorOffset() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].valueType = "uint256[0]";
        check(p, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(9)));
    }

    function testArityBeforeLaterDescriptor() public view {
        Expressions.Expression memory p = graph(3);
        p.nodes[1].kind = Expressions.Kind.Select;
        p.nodes[1].refs = new uint256[](2);
        p.nodes[2].valueType = "";
        check(p, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1)));
    }

    function testNestedDescriptorOffset() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].valueType = "(uint256,)";
        check(p, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(9)));
    }

    function overflow(uint256 value) external pure returns (uint256) {
        return value + 1;
    }

    function testStandardPanicBytes() public view {
        (bool ok, bytes memory reason) = address(this).staticcall(abi.encodeCall(this.overflow, (type(uint256).max)));
        require(!ok, "must overflow");
        require(keccak256(reason) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(17))), "panic bytes");
    }
}
