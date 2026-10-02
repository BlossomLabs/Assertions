// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Assertions} from "../../contracts/Assertions.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../contracts/lib/AbiCodec.sol";
import {
    InputParam,
    InputParamType,
    InputParamFetcherType,
    Constraint,
    ConstraintType,
    ConstraintFailed,
    InvalidAddressWord
} from "../../contracts/lib/ERC8211.sol";

interface VmArguments {
    function expectCall(address callee, bytes calldata data, uint64 count) external;
}

contract ArgumentsTarget {
    function caller() external view returns (address) {
        return msg.sender;
    }

    function mixed(uint8 a, string calldata b, bytes[] calldata c) external view returns (bytes32, address) {
        return (keccak256(abi.encode(a, b, c)), msg.sender);
    }

    function reject() external pure {
        revert("destination");
    }

    function literal() external pure returns (string memory) {
        return "fetched argument";
    }
}

contract ArgumentsOracleTest {
    Assertions private core = new Assertions();
    ArgumentsTarget private destination = new ArgumentsTarget();

    function raw(bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function target() private view returns (InputParam memory) {
        return raw(abi.encode(address(destination)));
    }

    function constrained(uint256 value) private pure returns (InputParam memory p) {
        p = raw(abi.encode(value));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(99)));
    }

    function check(
        InputParam memory to,
        bytes4 selector,
        string memory types,
        InputParam[] memory args,
        bool success,
        bytes memory expected
    ) private view {
        (bool ok, bytes memory data) = address(core).staticcall(abi.encodeCall(core.get, (to, selector, types, args)));
        require(ok == success, "wrong verdict");
        require(keccak256(data) == keccak256(expected), "wrong exact bytes");
    }

    function failure(uint256 index, uint256 actual) private pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            "",
            uint256(0),
            index,
            uint256(0),
            ConstraintType.EQ,
            bytes32(actual),
            abi.encode(uint256(99))
        );
    }

    function testEmptyTupleAndCallerIdentity() public view {
        check(target(), destination.caller.selector, "()", new InputParam[](0), true, abi.encode(address(core)));
    }

    function testCanonicalMixedArgumentsMatchSolc() public view {
        bytes[] memory blobs = new bytes[](2);
        blobs[0] = hex"aabb";
        blobs[1] = hex"cc";
        InputParam[] memory args = new InputParam[](3);
        args[0] = raw(abi.encode(uint8(17)));
        args[1] = raw(abi.encode(address(destination), abi.encodeCall(destination.literal, ())));
        args[1].fetcherType = InputParamFetcherType.STATIC_CALL;
        args[2] = raw(abi.encode(blobs));
        check(
            target(),
            destination.mixed.selector,
            "(uint8,string,bytes[])",
            args,
            true,
            abi.encode(keccak256(abi.encode(uint8(17), "fetched argument", blobs)), address(core))
        );
    }

    function testTargetPrecedesArgumentsAndTypeParsing() public view {
        InputParam[] memory args = new InputParam[](1);
        args[0] = constrained(7);
        check(constrained(6), bytes4(0), "bad", args, false, failure(0, 6));
        check(
            raw(abi.encode(uint256(1) << 160)),
            bytes4(0),
            "bad",
            args,
            false,
            abi.encodeWithSelector(InvalidAddressWord.selector, uint256(0), bytes32(uint256(1) << 160))
        );
    }

    function testArgumentResolutionPrecedesEncodingAndNamesOperand() public view {
        InputParam[] memory args = new InputParam[](2);
        args[0] = raw(abi.encode(uint256(0)));
        args[1] = constrained(7);
        check(target(), bytes4(0), "bad", args, false, failure(2, 7));
    }

    function testCountMismatchPrecedesValueValidation() public view {
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(hex"01");
        check(
            target(),
            bytes4(0),
            "(uint8,uint8)",
            args,
            false,
            abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, uint256(2), uint256(1))
        );
    }

    function testFirstInvalidComponentAndExactLength() public view {
        InputParam[] memory args = new InputParam[](3);
        args[0] = raw(abi.encode(uint8(1)));
        args[1] = raw(abi.encode(uint256(256)));
        args[2] = raw(hex"01");
        check(
            target(),
            bytes4(0),
            "(uint8,uint8,uint8)",
            args,
            false,
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0))
        );
        args[1] = raw(abi.encode(uint8(2)));
        check(
            target(),
            bytes4(0),
            "(uint8,uint8,uint8)",
            args,
            false,
            abi.encodeWithSelector(AbiCodec.InvalidComponentLength.selector, uint256(2), uint256(32), uint256(1))
        );
    }

    function testEmptyShortcutDoesNotAcceptValues() public view {
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(abi.encode(uint8(1)));
        check(
            target(), bytes4(0), "()", args, false, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1))
        );
    }

    function testEnvelopeFailureAndDescriptorFailure() public view {
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(hex"01");
        check(
            target(),
            bytes4(0),
            "(string)",
            args,
            false,
            abi.encodeWithSelector(AbiCodec.InvalidComponentEnvelope.selector, uint256(0), uint256(1), bytes32(0))
        );
        check(target(), bytes4(0), "(", args, false, abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1)));
    }

    function testEachArgumentIsResolvedOnce() public {
        VmArguments vm = VmArguments(address(uint160(uint256(keccak256("hevm cheat code")))));
        vm.expectCall(address(destination), abi.encodeCall(destination.literal, ()), uint64(1));
        bytes[] memory blobs = new bytes[](0);
        InputParam[] memory args = new InputParam[](3);
        args[0] = raw(abi.encode(uint8(17)));
        args[1] = raw(abi.encode(address(destination), abi.encodeCall(destination.literal, ())));
        args[1].fetcherType = InputParamFetcherType.STATIC_CALL;
        args[2] = raw(abi.encode(blobs));
        check(
            target(),
            destination.mixed.selector,
            "(uint8,string,bytes[])",
            args,
            true,
            abi.encode(keccak256(abi.encode(uint8(17), "fetched argument", blobs)), address(core))
        );
    }

    function testDestinationFailurePolicy() public view {
        InputParam memory callParam = raw(abi.encode(address(destination), abi.encodeCall(destination.reject, ())));
        callParam.fetcherType = InputParamFetcherType.STATIC_CALL;
        (bool ok, bytes memory expected) = address(core).staticcall(abi.encodeCall(core.resolve, (callParam)));
        require(!ok, "expected failure");
        check(target(), destination.reject.selector, "()", new InputParam[](0), false, expected);
    }
}
