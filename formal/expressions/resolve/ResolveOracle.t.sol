// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions, ICore} from "../../../contracts/Expressions.sol";
import {Assertions} from "../../../contracts/Assertions.sol";
import {
    InputParam,
    InputParamType,
    InputParamFetcherType,
    Constraint,
    ConstraintType,
    ConstraintFailed
} from "../../../contracts/lib/ERC8211.sol";

contract ResolveReflector {
    function resolve(InputParam calldata) external pure returns (bytes memory) {
        return msg.data;
    }

    function number() external pure returns (uint256) {
        return 73;
    }
}

contract ResolveOracleTest {
    Expressions private evaluator = new Expressions();
    Assertions private core = new Assertions();
    ResolveReflector private reflector = new ResolveReflector();

    function param() private pure returns (InputParam memory p) {
        p.paramType = InputParamType.CALL_DATA;
        p.fetcherType = InputParamFetcherType.RAW_BYTES;
        p.paramData = abi.encode(uint256(73));
        p.constraints = new Constraint[](0);
    }

    function graph(bytes memory source, address target, string memory valueType)
        private
        pure
        returns (Expressions.Expression memory p)
    {
        p.core = target;
        p.nodes = new Expressions.Node[](2);
        p.result = 1;
        p.nodes[0].valueType = "uint256";
        p.nodes[0].data = abi.encode(uint256(0));
        p.nodes[1].kind = Expressions.Kind.Resolve;
        p.nodes[1].valueType = valueType;
        p.nodes[1].data = source;
    }

    function check(Expressions.Expression memory p, bool expectedOk, bytes memory expected) private view {
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok == expectedOk, "verdict");
        require(keccak256(result) == keccak256(expected), "exact bytes");
    }

    function testRawResolveWithConstraints() public view {
        InputParam memory p = param();
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.IN_SIGNED, abi.encode(int256(-1), int256(74)));
        check(graph(abi.encode(p), address(core), "uint256"), true, p.paramData);
    }

    function testRevertKeepsNodeAndCoreReason() public view {
        InputParam memory p = param();
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(74)));
        bytes memory reason = abi.encodeWithSelector(
            ConstraintFailed.selector,
            "",
            uint256(0),
            uint256(0),
            uint256(0),
            ConstraintType.EQ,
            bytes32(uint256(73)),
            p.constraints[0].referenceData
        );
        check(
            graph(abi.encode(p), address(core), "uint256"),
            false,
            abi.encodeWithSelector(
                Expressions.NodeCallFailed.selector,
                uint256(1),
                address(core),
                abi.encodeCall(ICore.resolve, (p)),
                reason
            )
        );
    }

    function testMissingCoreKeepsNodeIndex() public view {
        InputParam memory p = param();
        check(
            graph(abi.encode(p), address(0x1234), "uint256"),
            false,
            abi.encodeWithSelector(Expressions.InvalidTarget.selector, uint256(1), address(0x1234))
        );
    }

    function testMalformedDecodeBareRevert() public view {
        check(graph(hex"ff", address(core), "uint256"), false, "");
    }

    function testAllWireKindsAndDynamicOffsets() public view {
        InputParam memory p = param();
        p.paramType = InputParamType.VALUE;
        p.fetcherType = InputParamFetcherType.BALANCE;
        p.paramData = hex"aabbcc";
        p.constraints = new Constraint[](9);
        for (uint256 i; i < 9; i++) {
            p.constraints[i] = Constraint(ConstraintType(i), new bytes(i * 7));
        }
        check(graph(abi.encode(p), address(reflector), "bytes"), true, abi.encode(abi.encodeCall(ICore.resolve, (p))));
    }

    function testStaticCallFetcher() public view {
        InputParam memory p = param();
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
        p.paramData = abi.encode(address(reflector), abi.encodeCall(reflector.number, ()));
        check(graph(abi.encode(p), address(core), "uint256"), true, abi.encode(uint256(73)));
    }

    function testNativeBalanceFetcher() public view {
        InputParam memory p = param();
        p.fetcherType = InputParamFetcherType.BALANCE;
        p.paramData = abi.encodePacked(address(0), address(0x1234));
        check(graph(abi.encode(p), address(core), "uint256"), true, abi.encode(address(0x1234).balance));
    }
}
