// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract CallsTarget {
    function pair(uint256 a, uint256 b) external pure returns (uint256) {
        return a * 100 + b;
    }

    function sized(uint256 a, string calldata b) external pure returns (uint256) {
        return a * 100 + bytes(b).length;
    }

    function bomb(uint256 a, uint256 b) external pure returns (uint256) {
        require(b != 2, "two");
        return a + b;
    }

    function caller(uint256, uint256) external view returns (address) {
        return msg.sender;
    }

    function evaluateEncoded(bytes calldata expression, bytes[] calldata parameters) external pure {
        require(keccak256(expression) == keccak256(hex"aabb"), "expression");
        uint256 v = abi.decode(parameters[0], (uint256)) * 100 + abi.decode(parameters[1], (uint256));
        assembly {
            mstore(0, v)
            return(0, 32)
        }
    }
}

contract CallsOracleTest {
    Collections private collection = new Collections();
    CallsTarget private target = new CallsTarget();

    function cb(bytes4 selector) private view returns (Collections.Callback memory c) {
        c.target = address(target);
        c.selector = selector;
        c.arguments = "(uint256,uint256)";
        c.constants = new bytes[](2);
        c.constants[0] = abi.encode(uint256(7));
        c.first = 1;
    }

    function inputs(uint256 a, uint256 b) private pure returns (bytes[] memory v) {
        v = new bytes[](2);
        v[0] = abi.encode(a);
        v[1] = abi.encode(b);
    }

    function check(bytes memory request, bytes memory expected) private view {
        (bool ok, bytes memory actual) = address(collection).staticcall(request);
        require(!ok && keccak256(actual) == keccak256(expected), "wrong call error");
    }

    function testDirectTupleHasNoArrayEnvelope() public view {
        bytes[] memory out = collection.mapValues("uint256", "uint256", inputs(3, 4), cb(target.pair.selector));
        require(abi.decode(out[0], (uint256)) == 703 && abi.decode(out[1], (uint256)) == 704, "direct arguments");
    }

    function testExpressionPathIgnoresDirectSelector() public view {
        Collections.Callback memory c = cb(0xffffffff);
        c.expression = hex"aabb";
        bytes[] memory out = collection.mapValues("uint256", "uint256", inputs(3, 4), c);
        require(abi.decode(out[0], (uint256)) == 703 && abi.decode(out[1], (uint256)) == 704, "expression arguments");
    }

    function testBinarySlotsReceiveAccumulatorThenElement() public view {
        Collections.Callback memory c = cb(target.pair.selector);
        c.first = 0;
        c.second = 1;
        bytes memory out = collection.foldValues("uint256", "uint256", inputs(3, 4), abi.encode(uint256(2)), c);
        require(abi.decode(out, (uint256)) == 20304, "binary arguments");
    }

    function testTargetCheckPrecedesBindingValidation() public view {
        Collections.Callback memory c = cb(target.pair.selector);
        c.target = address(0);
        c.arguments = "(uint256,uint8)";
        check(
            abi.encodeCall(collection.mapValues, ("uint256", "uint256", inputs(256, 3), c)),
            abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, address(0))
        );
    }

    function testDynamicArgumentsRebuiltForEachCall() public view {
        Collections.Callback memory c = cb(target.sized.selector);
        c.arguments = "(uint256,string)";
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode("hi");
        v[1] = abi.encode("abcdefghijklmnopqrstuvwxyz0123456789ABCDE");
        bytes[] memory out = collection.mapValues("string", "uint256", v, c);
        require(abi.decode(out[0], (uint256)) == 702 && abi.decode(out[1], (uint256)) == 741, "dynamic arguments");
    }

    function testCallbackRevertIncludesActualIndexAndCalldata() public view {
        Collections.Callback memory c = cb(target.bomb.selector);
        check(
            abi.encodeCall(collection.mapValues, ("uint256", "uint256", inputs(1, 2), c)),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                collection.mapValues.selector,
                uint256(1),
                uint256(0),
                address(target),
                abi.encodeCall(target.bomb, (uint256(7), uint256(2))),
                abi.encodeWithSignature("Error(string)", "two")
            )
        );
    }

    function testCallbackCallerIsCollections() public view {
        bytes[] memory out = collection.mapValues("uint256", "address", inputs(3, 4), cb(target.caller.selector));
        require(
            abi.decode(out[0], (address)) == address(collection)
                && abi.decode(out[1], (address)) == address(collection),
            "caller"
        );
    }
}
