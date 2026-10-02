// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract ValidationOracleTest {
    Collections private collection = new Collections();

    function echo(uint256 x) external pure returns (uint256) {
        return x;
    }

    function codec(bytes calldata t, bytes calldata value, bool result) external pure {
        if (result) {
            AbiCodec.validate(
                t, value, AbiCodec.Context(AbiCodec.ContextKind.CallbackResult, 0x12345678, 9, 0, address(0x1234))
            );
        } else {
            AbiCodec.validate(t, value);
        }
    }

    function callback() private view returns (Collections.Callback memory cb) {
        cb.target = address(this);
        cb.selector = this.echo.selector;
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
    }

    function check(address target, bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory actual) = target.staticcall(data);
        require(!ok && keccak256(actual) == keccak256(expected), "validation bytes");
    }

    function testInputOffsetBeforeCallback() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(0), uint256(256));
        check(
            address(collection),
            abi.encodeCall(collection.mapValues, ("(uint256,uint8)", "uint256", values, callback())),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32))
        );
    }

    function testResultOperationIndexTarget() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(1));
        values[1] = abi.encode(uint256(256));
        check(
            address(collection),
            abi.encodeCall(collection.mapValues, ("uint256", "uint8", values, callback())),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector,
                collection.mapValues.selector,
                uint256(1),
                uint256(0),
                address(this)
            )
        );
    }

    function testDynamicPaddingErrorOffset() public view {
        bytes memory value = abi.encode(bytes(hex"01"));
        value[value.length - 1] = 0x01;
        check(
            address(this),
            abi.encodeCall(this.codec, (bytes("bytes"), value, false)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(95))
        );
    }

    function testDynamicResultRoutesContext() public view {
        bytes memory value = abi.encode(bytes(hex"01"));
        value[value.length - 1] = 0x01;
        check(
            address(this),
            abi.encodeCall(this.codec, (bytes("bytes"), value, true)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, bytes4(0x12345678), uint256(9), uint256(0), address(0x1234)
            )
        );
    }

    function testDescriptorErrorSurvivesResultContext() public view {
        check(
            address(this),
            abi.encodeCall(this.codec, (bytes("uint256["), hex"", true)),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8))
        );
    }

    function testFoldInitialUsesValueContext() public view {
        Collections.Callback memory cb = callback();
        cb.arguments = "(uint256,uint256)";
        cb.constants = new bytes[](2);
        cb.second = 1;
        check(
            address(collection),
            abi.encodeCall(collection.foldValues, ("uint256", "uint8", new bytes[](0), abi.encode(uint256(256)), cb)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
        );
    }

    function testCanonicalResultAccepted() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(1));
        values[1] = abi.encode(uint256(255));
        bytes[] memory out = collection.mapValues("uint8", "uint8", values, callback());
        require(
            out.length == 2 && abi.decode(out[0], (uint256)) == 1 && abi.decode(out[1], (uint256)) == 255,
            "canonical output"
        );
    }
}
