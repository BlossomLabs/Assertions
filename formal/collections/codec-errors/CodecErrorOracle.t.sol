// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract CodecErrorOracleTest {
    Collections private collection = new Collections();

    function callback(string memory descriptor, bytes memory constantValue)
        private
        view
        returns (Collections.Callback memory cb)
    {
        cb.target = address(this);
        cb.arguments = descriptor;
        cb.constants = new bytes[](2);
        cb.constants[0] = constantValue;
        cb.first = 1;
    }

    function check(Collections.Callback memory cb, bytes[] memory values, bytes memory expected) private view {
        (bool ok, bytes memory actual) =
            address(collection).staticcall(abi.encodeCall(collection.mapValues, ("uint256", "uint256", values, cb)));
        require(!ok && keccak256(actual) == keccak256(expected), "exact codec receipt");
    }

    function testStaticLengthConstantBytes() public view {
        check(
            callback("(uint256,uint256)", hex"12"),
            new bytes[](0),
            abi.encodePacked(AbiCodec.InvalidComponentLength.selector, uint256(0), uint256(32), uint256(1))
        );
    }

    function testDynamicEnvelopeConstantBytes() public view {
        check(
            callback("(bytes,uint256)", abi.encode(uint256(64), uint256(0))),
            new bytes[](0),
            abi.encodePacked(AbiCodec.InvalidComponentEnvelope.selector, uint256(0), uint256(64), bytes32(uint256(64)))
        );
    }

    function testNarrowConstantBytes() public view {
        check(
            callback("(uint8,uint256)", abi.encode(uint256(256))),
            new bytes[](0),
            abi.encodePacked(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0))
        );
    }

    function testBoundSlotBytes() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(256));
        check(
            callback("(uint256,uint8)", abi.encode(uint256(0))),
            values,
            abi.encodePacked(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0))
        );
    }

    function testFirstConstantFailureBytes() public view {
        Collections.Callback memory cb = callback("(uint8,uint8,uint256)", abi.encode(uint256(256)));
        cb.constants = new bytes[](3);
        cb.constants[0] = abi.encode(uint256(256));
        cb.constants[1] = hex"12";
        cb.first = 2;
        check(cb, new bytes[](0), abi.encodePacked(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0)));
    }

    function testBytes4AddressFieldGeometry() public pure {
        bytes4 operation = 0x12345678;
        address target = address(0x1234567890123456789012345678901234567890);
        bytes memory actual =
            abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector, operation, uint256(9), uint256(17), target);
        bytes memory expected = abi.encodePacked(
            AbiCodec.InvalidCallbackResult.selector,
            operation,
            bytes28(0),
            uint256(9),
            uint256(17),
            uint256(uint160(target))
        );
        require(keccak256(actual) == keccak256(expected), "bytes4/address placement");
    }

    function testOtherStaticErrorSchemas() public pure {
        require(
            keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, type(uint256).max))
                == keccak256(abi.encodePacked(AbiCodec.InvalidValue.selector, type(uint256).max)),
            "value"
        );
        require(
            keccak256(abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, uint256(3), uint256(2)))
                == keccak256(abi.encodePacked(AbiCodec.ComponentCountMismatch.selector, uint256(3), uint256(2))),
            "count"
        );
        require(
            keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(19)))
                == keccak256(abi.encodePacked(InvalidTypeDescriptor.selector, uint256(19))),
            "descriptor"
        );
        require(
            keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(17)))
                == keccak256(abi.encodePacked(bytes4(0x4e487b71), uint256(17))),
            "panic"
        );
    }
}
