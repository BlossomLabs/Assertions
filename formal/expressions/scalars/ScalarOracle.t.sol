// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract ScalarMarkerTarget {
    function marker() external pure {
        assembly {
            mstore(0, shl(224, 0xd271060e))
            revert(0, 4)
        }
    }

    function longer() external pure {
        assembly {
            mstore(0, shl(224, 0xd271060e))
            revert(0, 5)
        }
    }
}

contract ScalarOracleTest {
    Expressions private evaluator = new Expressions();
    ScalarMarkerTarget private target = new ScalarMarkerTarget();

    function graph(uint256 count) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](count);
        p.result = count - 1;
        for (uint256 i; i < count; i++) {
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(uint256(7));
        }
    }

    function check(Expressions.Expression memory p, bytes[] memory parameters, bool expectedOk, bytes memory expected)
        private
        view
    {
        (bool ok, bytes memory value) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, parameters)));
        require(ok == expectedOk, "wrong verdict");
        require(keccak256(value) == keccak256(expected), "wrong exact bytes");
    }

    function testParameterLengthPrecedesLookup() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].kind = Expressions.Kind.Parameter;
        p.nodes[0].data = new bytes(31);
        check(p, new bytes[](0), false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(0)));
        p.nodes[0].data = new bytes(33);
        check(p, new bytes[](0), false, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(0)));
    }

    function testParameterAtLengthHasExactError() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].kind = Expressions.Kind.Parameter;
        p.nodes[0].data = abi.encode(uint256(0));
        check(
            p,
            new bytes[](0),
            false,
            abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(0), uint256(0))
        );
        p.nodes[0].data = abi.encode(type(uint256).max);
        check(
            p,
            new bytes[](0),
            false,
            abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(0), type(uint256).max)
        );
    }

    function testParameterRetrievesRequestedValue() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].kind = Expressions.Kind.Parameter;
        p.nodes[0].data = abi.encode(uint256(1));
        bytes[] memory parameters = new bytes[](2);
        parameters[0] = abi.encode(uint256(7));
        parameters[1] = abi.encode(uint256(99));
        check(p, parameters, true, parameters[1]);
    }

    function testSelectUsesFirstWordAndDynamicEnvelope() public view {
        Expressions.Expression memory p = graph(4);
        p.nodes[0].valueType = "(uint256,uint256)";
        p.nodes[0].data = abi.encode(uint256(0), uint256(1));
        p.nodes[1].data = abi.encode(uint256(42));
        p.nodes[2].data = abi.encode(uint256(99));
        p.nodes[3].kind = Expressions.Kind.Select;
        p.nodes[3].refs = new uint256[](3);
        p.nodes[3].refs[1] = 1;
        p.nodes[3].refs[2] = 2;
        check(p, new bytes[](0), true, abi.encode(uint256(99)));
        p.nodes[0].valueType = "bytes";
        p.nodes[0].data = abi.encode(bytes(""));
        check(p, new bytes[](0), true, abi.encode(uint256(42)));
    }

    function testMaximumAddressIsClean() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[0].data = abi.encode(uint256(type(uint160).max));
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].arguments = "()";
        check(
            p,
            new bytes[](0),
            false,
            abi.encodeWithSelector(Expressions.InvalidTarget.selector, uint256(1), address(type(uint160).max))
        );
    }

    function testDirtyAndLongAddressWordsRejected() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[0].data = abi.encode(uint256(type(uint160).max) + 1);
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].arguments = "()";
        bytes memory expected = abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(1));
        check(p, new bytes[](0), false, expected);
        p.nodes[0].valueType = "(uint256,uint256)";
        p.nodes[0].data = abi.encode(uint256(0), uint256(0));
        check(p, new bytes[](0), false, expected);
    }

    function testIsValidReturnsCanonicalBoolean() public view {
        Expressions.Expression memory p = graph(2);
        p.nodes[0].valueType = "uint8";
        p.nodes[1].kind = Expressions.Kind.IsValid;
        p.nodes[1].valueType = "bool";
        p.nodes[1].refs = new uint256[](1);
        check(p, new bytes[](0), true, abi.encode(true));
        p.nodes[0].data = abi.encode(uint256(256));
        check(p, new bytes[](0), true, abi.encode(false));
    }

    function testGuardMarkerIsExact() public view {
        Expressions.Expression memory p = graph(4);
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(target));
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].arguments = "()";
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].selector = target.marker.selector;
        p.nodes[3].kind = Expressions.Kind.TryOrElse;
        p.nodes[3].refs = new uint256[](2);
        p.nodes[3].refs[0] = 1;
        p.nodes[3].refs[1] = 2;
        check(p, new bytes[](0), false, abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector));
        p.nodes[1].selector = target.longer.selector;
        check(p, new bytes[](0), true, abi.encode(uint256(7)));
    }
}
