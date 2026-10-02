// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract CodecErrorHarness {
    function validate(bytes calldata t, bytes calldata v, AbiCodec.Context calldata c) external pure {
        AbiCodec.validate(t, v, c);
    }

    function tuple(bytes calldata t, bytes[] calldata v) external pure {
        AbiCodec.tuple(t, v);
    }

    function overflow(uint256 n) external pure returns (uint256) {
        return n + 1;
    }
}

contract CodecErrorOracleTest {
    CodecErrorHarness private h = new CodecErrorHarness();

    function check(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory reason) = address(h).staticcall(data);
        require(!ok, "must fail");
        require(keccak256(reason) == keccak256(expected), "exact error fields");
    }

    function context() private pure returns (AbiCodec.Context memory c) {
        return c;
    }

    function testInvalidValueOffset() public view {
        check(
            abi.encodeCall(h.validate, (bytes("uint8[2]"), abi.encode(uint256(1), uint256(256)), context())),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32))
        );
    }

    function testComponentContextOffset() public view {
        AbiCodec.Context memory c = context();
        c.kind = AbiCodec.ContextKind.TupleComponent;
        c.index = 37;
        check(
            abi.encodeCall(h.validate, (bytes("uint8[2]"), abi.encode(uint256(1), uint256(256)), c)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(37), uint256(32))
        );
    }

    function testCallbackContextFields() public view {
        AbiCodec.Context memory c =
            AbiCodec.Context(AbiCodec.ContextKind.CallbackResult, 0x12345678, 37, 52, address(0xabcdef));
        check(
            abi.encodeCall(h.validate, (bytes("bool"), abi.encode(uint256(2)), c)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, bytes4(0x12345678), uint256(37), uint256(52), address(0xabcdef)
            )
        );
    }

    function testComponentLengthFields() public view {
        bytes[] memory v = new bytes[](1);
        v[0] = abi.encode(uint256(7));
        check(
            abi.encodeCall(h.tuple, (bytes("(uint256[2])"), v)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentLength.selector, uint256(0), uint256(64), uint256(32))
        );
    }

    function testComponentEnvelopeFields() public view {
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(uint256(7));
        v[1] = abi.encode(uint256(99));
        check(
            abi.encodeCall(h.tuple, (bytes("(uint256,bytes)"), v)),
            abi.encodeWithSelector(
                AbiCodec.InvalidComponentEnvelope.selector, uint256(1), uint256(32), bytes32(uint256(99))
            )
        );
    }

    function testCountFields() public view {
        check(
            abi.encodeCall(h.tuple, (bytes("(uint256)"), new bytes[](0))),
            abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, uint256(1), uint256(0))
        );
    }

    function testDescriptorPosition() public view {
        check(
            abi.encodeCall(h.validate, (bytes(""), abi.encode(uint256(0)), context())),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(0))
        );
    }

    function testPanicWord() public view {
        check(abi.encodeCall(h.overflow, (type(uint256).max)), abi.encodeWithSelector(bytes4(0x4e487b71), uint256(17)));
    }
}
