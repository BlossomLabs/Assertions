// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

contract AdmissionCodecOracle {
    function shape(string calldata descriptor) external pure {
        AbiCodec.shape(bytes(descriptor));
    }

    function layout(string calldata descriptor) external pure {
        AbiCodec.tupleLayout(bytes(descriptor));
    }
}

contract AdmissionOracleTest {
    Collections private collection = new Collections();
    AdmissionCodecOracle private codec = new AdmissionCodecOracle();

    function callback(string memory descriptor) private pure returns (Collections.Callback memory cb) {
        cb.arguments = descriptor;
        cb.constants = new bytes[](1);
    }

    function check(Collections.Callback memory cb, bytes memory expected) private view {
        (bool ok, bytes memory actual) = address(collection)
            .staticcall(abi.encodeCall(collection.mapValues, ("uint256", "uint256", new bytes[](0), cb)));
        require(!ok && keccak256(actual) == keccak256(expected), "admission bytes");
    }

    function codecError(string memory descriptor, bool tuple) private view returns (bytes memory data) {
        bool ok;
        (ok, data) = address(codec)
            .staticcall(tuple ? abi.encodeCall(codec.layout, (descriptor)) : abi.encodeCall(codec.shape, (descriptor)));
        require(!ok, "expected codec failure");
    }

    function testSlotRejectionPrecedesMalformedDescriptor() public view {
        Collections.Callback memory cb = callback("(");
        cb.first = 1;
        check(cb, abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    function testValidNonTupleBecomesInvalidCallback() public view {
        check(callback("uint256"), abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    function testMalformedNonTuplePreservesShapeError() public view {
        check(callback("uint256["), codecError("uint256[", false));
    }

    function testMalformedTuplePreservesLayoutError() public view {
        check(callback("(uint256,)"), codecError("(uint256,)", true));
    }

    function testEmptyDescriptorUsesLayoutError() public view {
        check(callback(""), codecError("", true));
    }

    function testArityMismatchPrecedesPlaceholderValidation() public view {
        check(callback("(uint256,uint256)"), abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    function testAcceptedTupleLeavesSubstitutedPlaceholderUnchecked() public view {
        bytes[] memory out = collection.mapValues("uint256", "uint256", new bytes[](0), callback("(uint256)"));
        require(out.length == 0, "empty result");
    }
}
