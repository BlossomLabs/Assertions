// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract PreparationTarget {
    function pair(uint256 a, uint256 b) external pure returns (uint256) {
        return a * 100 + b;
    }
}

contract PreparationOracleTest {
    Collections private collection = new Collections();
    PreparationTarget private target = new PreparationTarget();

    function callback() private view returns (Collections.Callback memory cb) {
        cb.target = address(target);
        cb.selector = target.pair.selector;
        cb.arguments = "(uint256,uint256)";
        cb.constants = new bytes[](2);
        cb.constants[0] = abi.encode(uint256(7));
        cb.first = 1;
    }

    function emptyMap(Collections.Callback memory cb, bytes memory expected) private view {
        check(abi.encodeCall(collection.mapValues, ("uint256", "uint256", new bytes[](0), cb)), expected);
    }

    function check(bytes memory request, bytes memory expected) private view {
        (bool ok, bytes memory actual) = address(collection).staticcall(request);
        require(!ok && keccak256(actual) == keccak256(expected), "wrong preparation error");
    }

    function testSlotBoundsPrecedeDescriptorParsing() public view {
        Collections.Callback memory cb = callback();
        cb.first = 2;
        cb.arguments = "bad type";
        emptyMap(cb, abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    function testBinarySlotsMustBeDistinct() public view {
        Collections.Callback memory cb = callback();
        cb.second = cb.first;
        check(
            abi.encodeCall(collection.foldValues, ("uint256", "uint256", new bytes[](0), abi.encode(uint256(0)), cb)),
            abi.encodeWithSelector(Collections.InvalidCallback.selector)
        );
    }

    function testBinaryPlaceholdersAreNotConstants() public view {
        Collections.Callback memory cb = callback();
        cb.first = 0;
        cb.second = 1;
        cb.constants[0] = hex"";
        bytes memory value = collection.foldValues("uint256", "uint256", new bytes[](0), abi.encode(uint256(8)), cb);
        require(abi.decode(value, (uint256)) == 8, "placeholder validated");
    }

    function testConstantValidationBeforeEmptyTraversal() public view {
        Collections.Callback memory cb = callback();
        cb.arguments = "(uint8,uint256)";
        cb.constants[0] = abi.encode(uint256(256));
        emptyMap(cb, abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0)));
    }

    function testFirstInvalidConstantIsReported() public view {
        Collections.Callback memory cb = callback();
        cb.arguments = "(uint8,uint8,uint256)";
        cb.constants = new bytes[](3);
        cb.first = 2;
        cb.constants[0] = abi.encode(uint256(256));
        cb.constants[1] = abi.encode(uint256(257));
        emptyMap(cb, abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0)));
    }

    function testBindingReplacesOnlySelectedSlot() public view {
        Collections.Callback memory cb = callback();
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(3));
        values[1] = abi.encode(uint256(4));
        bytes[] memory out = collection.mapValues("uint256", "uint256", values, cb);
        require(
            abi.decode(out[0], (uint256)) == 703 && abi.decode(out[1], (uint256)) == 704, "wrong binding or constant"
        );
    }

    function testBoundValueValidationUsesSelectedComponent() public view {
        Collections.Callback memory cb = callback();
        cb.arguments = "(uint256,uint8)";
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(256));
        check(
            abi.encodeCall(collection.mapValues, ("uint256", "uint256", values, cb)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0))
        );
    }
}
