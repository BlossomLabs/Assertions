// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract OrderTarget {
    function combine(uint256 a, uint256 b) external pure returns (uint256) {
        return 100 * a + b;
    }
}

contract RecursiveOracleTest {
    Expressions private evaluator = new Expressions();
    OrderTarget private target = new OrderTarget();

    function graph(uint256 count) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](count);
        p.result = count - 1;
        for (uint256 i; i < count; i++) {
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(uint256(0));
        }
    }

    function check(Expressions.Expression memory p, bool expectedOk, bytes memory expected) private view {
        (bool ok, bytes memory value) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok == expectedOk, "wrong verdict");
        require(keccak256(value) == keccak256(expected), "wrong exact bytes");
    }

    function testSelectDirectionAndLaziness() public view {
        Expressions.Expression memory p = graph(4);
        p.nodes[1].data = abi.encode(uint256(42));
        p.nodes[2].valueType = "uint8";
        p.nodes[2].data = abi.encode(uint256(256));
        p.nodes[3].kind = Expressions.Kind.Select;
        p.nodes[3].refs = new uint256[](3);
        p.nodes[3].refs[1] = 1;
        p.nodes[3].refs[2] = 2;
        p.nodes[0].data = abi.encode(uint256(1));
        check(p, true, abi.encode(uint256(42)));
        p.nodes[0].data = abi.encode(uint256(0));
        p.nodes[2].data = abi.encode(uint256(99));
        p.nodes[1].valueType = "uint8";
        p.nodes[1].data = abi.encode(uint256(256));
        check(p, true, abi.encode(uint256(99)));
    }

    function testValidationCannotBeSkipped() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].valueType = "uint8";
        p.nodes[0].data = abi.encode(uint256(256));
        check(p, false, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
    }

    function testCallArgumentsRemainOrdered() public view {
        Expressions.Expression memory p = graph(4);
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(target));
        p.nodes[1].data = abi.encode(uint256(7));
        p.nodes[2].data = abi.encode(uint256(11));
        p.nodes[3].kind = Expressions.Kind.Call;
        p.nodes[3].selector = target.combine.selector;
        p.nodes[3].arguments = "(uint256,uint256)";
        p.nodes[3].refs = new uint256[](3);
        p.nodes[3].refs[1] = 1;
        p.nodes[3].refs[2] = 2;
        check(p, true, abi.encode(uint256(711)));
    }

    function testAddressFailurePrecedesArgumentEvaluation() public view {
        Expressions.Expression memory p = graph(3);
        p.nodes[0].data = abi.encode(type(uint256).max);
        p.nodes[1].valueType = "uint8";
        p.nodes[1].data = abi.encode(uint256(256));
        p.nodes[2].kind = Expressions.Kind.Call;
        p.nodes[2].selector = target.combine.selector;
        p.nodes[2].arguments = "(uint256)";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        check(p, false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(2)));
    }
}
