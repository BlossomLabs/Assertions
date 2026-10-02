// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract EncodedSignalTarget {
    function fail() external pure {
        revert Expressions.SubcallOutOfGas();
    }
}

contract EncodedOracleTest {
    Expressions private evaluator = new Expressions();
    EncodedSignalTarget private signalTarget = new EncodedSignalTarget();

    function blob(bytes memory value) private pure returns (bytes memory out) {
        uint256 padded = (value.length + 31) / 32 * 32;
        out = new bytes(32 + padded);
        assembly ("memory-safe") { mstore(add(out, 32), mload(value)) }
        for (uint256 i; i < value.length; i++) {
            out[32 + i] = value[i];
        }
    }

    function dynamicArray(bytes[] memory bodies) private pure returns (bytes memory out) {
        bytes memory heads;
        bytes memory tails;
        uint256 offset = bodies.length * 32;
        for (uint256 i; i < bodies.length; i++) {
            heads = bytes.concat(heads, abi.encode(offset));
            tails = bytes.concat(tails, bodies[i]);
            offset += bodies[i].length;
        }
        return bytes.concat(abi.encode(bodies.length), heads, tails);
    }

    function nodeBody(Expressions.Node memory node) private pure returns (bytes memory) {
        bytes memory valueType = blob(bytes(node.valueType));
        bytes memory data = blob(node.data);
        bytes memory refs = abi.encode(node.refs.length);
        for (uint256 i; i < node.refs.length; i++) {
            refs = bytes.concat(refs, abi.encode(node.refs[i]));
        }
        bytes memory arguments = blob(bytes(node.arguments));
        bytes memory head = abi.encode(
            uint256(node.kind),
            uint256(192),
            192 + valueType.length,
            192 + valueType.length + data.length,
            node.selector,
            192 + valueType.length + data.length + refs.length
        );
        return bytes.concat(head, valueType, data, refs, arguments);
    }

    function calldataReference(Expressions.Expression memory graph, bytes[] memory parameters)
        private
        pure
        returns (bytes memory)
    {
        bytes[] memory nodes = new bytes[](graph.nodes.length);
        for (uint256 i; i < nodes.length; i++) {
            nodes[i] = nodeBody(graph.nodes[i]);
        }
        bytes memory expression = bytes.concat(abi.encode(graph.core, uint256(96), graph.result), dynamicArray(nodes));
        bytes[] memory params = new bytes[](parameters.length);
        for (uint256 i; i < params.length; i++) {
            params[i] = blob(parameters[i]);
        }
        return bytes.concat(
            Expressions.evaluate.selector,
            abi.encode(uint256(64), 64 + expression.length),
            expression,
            dynamicArray(params)
        );
    }

    function invoke(bytes memory data, bytes[] memory parameters, bool expectedOk, bytes memory expected) private view {
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluateEncoded, (data, parameters)));
        require(ok == expectedOk, "verdict");
        require(keccak256(result) == keccak256(expected), "exact encoded result");
    }

    function graph(uint256 count) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](count);
        for (uint256 i; i < count; i++) {
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(uint256(73));
        }
    }

    function testMalformedGraphBareRevert() public view {
        invoke(hex"01", new bytes[](0), false, "");
    }

    function testMalformedKindBareRevert() public view {
        bytes memory data = abi.encode(graph(1));
        assembly ("memory-safe") { mstore(add(data, 224), 11) }
        invoke(data, new bytes[](0), false, "");
    }

    function testRawSuccessAndParameters() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].kind = Expressions.Kind.Parameter;
        p.nodes[0].data = abi.encode(uint256(1));
        p.nodes[0].valueType = "bytes";
        bytes[] memory parameters = new bytes[](2);
        parameters[0] = abi.encode(uint256(7));
        parameters[1] = abi.encode(hex"010203040506070809");
        invoke(abi.encode(p), parameters, true, parameters[1]);
    }

    function testWrapperKeepsIndexAndExactCalldata() public view {
        Expressions.Expression memory p = graph(11);
        p.core = address(0x1234);
        p.result = type(uint256).max;
        for (uint256 i; i < p.nodes.length; i++) {
            p.nodes[i].kind = Expressions.Kind(i);
            p.nodes[i].valueType = i % 2 == 0 ? "(uint8,bytes)" : "uint256[]";
            p.nodes[i].data = new bytes(i * 7);
            p.nodes[i].refs = new uint256[](2);
            p.nodes[i].refs[0] = i;
            p.nodes[i].refs[1] = type(uint256).max;
            p.nodes[i].selector = bytes4(uint32(0xa1b2c300 + i));
            p.nodes[i].arguments = i % 2 == 0 ? "(uint256,bytes)" : "bytes";
        }
        bytes[] memory parameters = new bytes[](3);
        parameters[0] = hex"010203";
        parameters[1] = "";
        parameters[2] = new bytes(33);
        bytes memory calldata_ = calldataReference(p, parameters);
        require(
            keccak256(calldata_) == keccak256(abi.encodeCall(evaluator.evaluate, (p, parameters))), "reference calldata"
        );
        bytes memory reason = abi.encodeWithSelector(Expressions.InvalidNode.selector, type(uint256).max);
        invoke(
            abi.encode(p),
            parameters,
            false,
            abi.encodeWithSelector(
                Expressions.NodeCallFailed.selector, uint256(0), address(evaluator), calldata_, reason
            )
        );
    }

    function testEmptyGraphWrapper() public view {
        Expressions.Expression memory p = graph(0);
        bytes[] memory parameters = new bytes[](0);
        bytes memory reason = abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(0));
        invoke(
            abi.encode(p),
            parameters,
            false,
            abi.encodeWithSelector(
                Expressions.NodeCallFailed.selector,
                uint256(0),
                address(evaluator),
                calldataReference(p, parameters),
                reason
            )
        );
    }

    function testReservedSignalPropagatesUnwrapped() public view {
        Expressions.Expression memory p = graph(2);
        p.result = 1;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(signalTarget));
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].selector = signalTarget.fail.selector;
        p.nodes[1].arguments = "()";
        invoke(abi.encode(p), new bytes[](0), false, abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector));
    }
}
