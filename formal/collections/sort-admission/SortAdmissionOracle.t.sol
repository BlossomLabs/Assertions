// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract SortAdmissionOracleTest {
    Collections private collection = new Collections();

    function callback() private pure returns (Collections.Callback memory cb) {
        cb.arguments = "(uint256,uint256)";
        cb.constants = new bytes[](2);
        cb.second = 1;
    }

    function check(string memory t, bytes[] memory values, Collections.Callback memory cb, bytes memory expected)
        private
        view
    {
        (bool ok, bytes memory actual) =
            address(collection).staticcall(abi.encodeCall(Collections.sortValues, (t, values, cb)));
        require(!ok && keccak256(actual) == keccak256(expected), "wrong exact failure");
    }

    function testBinarySlotsBeforeInputType() public view {
        Collections.Callback memory cb = callback();
        cb.second = cb.first;
        check("", new bytes[](0), cb, abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    function testArityBeforeInputType() public view {
        Collections.Callback memory cb = callback();
        cb.constants = new bytes[](3);
        check("", new bytes[](0), cb, abi.encodeWithSelector(Collections.InvalidCallback.selector));
    }

    function testEmptyStillParsesType() public view {
        check("", new bytes[](0), callback(), abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(0)));
    }

    function testEmptyNeverChecksTarget() public view {
        bytes[] memory out = collection.sortValues("uint8", new bytes[](0), callback());
        require(out.length == 0, "empty");
    }

    function testSingletonNeverChecksTarget() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(73));
        bytes[] memory out = collection.sortValues("uint8", values, callback());
        require(out.length == 1 && keccak256(out[0]) == keccak256(values[0]), "singleton");
    }

    function testLastInputBeforeAnyTargetCheck() public view {
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(uint256(7));
        values[1] = abi.encode(uint256(9));
        values[2] = abi.encode(uint256(256));
        check("uint8", values, callback(), abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
    }

    function testFirstFailureOffsetAndOrder() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(1), uint256(2));
        values[1] = abi.encode(uint256(2), uint256(1));
        check("(bool,bool)", values, callback(), abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(32)));
    }

    function testMalformedSingletonStillValidated() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = hex"01";
        check("uint256", values, callback(), abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
    }
}
