// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Assertions} from "../../contracts/Assertions.sol";
import {
    InputParam,
    InputParamType,
    InputParamFetcherType,
    Constraint,
    ConstraintType,
    ConstraintFailed,
    ReturnDataOutOfBounds,
    InvalidAddressWord
} from "../../contracts/lib/ERC8211.sol";

contract CoreTarget {
    function next(address target) external pure returns (address) {
        return target;
    }

    function dirty() external pure returns (uint256) {
        return uint256(1) << 160;
    }

    function finish() external pure {
        assembly {
            mstore(0, 0x123456)
            return(29, 3)
        }
    }

    function pair(uint256 a, uint256 b) external pure returns (uint256) {
        require(a == 31 && b == 47, "wrong arguments");
        return 78;
    }

    function fail() external pure {
        revert("losing branch");
    }

    function sender() external view returns (address) {
        return msg.sender;
    }
}

contract CoreOracleTest {
    Assertions private core = new Assertions();
    CoreTarget private target = new CoreTarget();

    function raw(bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function constrained(bytes memory data, uint256 expected) private pure returns (InputParam memory p) {
        p = raw(data);
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(expected));
    }

    function failCall() private view returns (InputParam memory p) {
        p = raw(abi.encode(address(target), abi.encodeCall(target.fail, ())));
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
    }

    function check(bytes memory data, bool success, bytes memory expected) private view {
        (bool ok, bytes memory result) = address(core).staticcall(data);
        require(ok == success, "wrong verdict");
        require(keccak256(result) == keccak256(expected), "wrong raw bytes");
    }

    function failure(uint256 index, uint256 actual, uint256 expected) private pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            "",
            uint256(0),
            index,
            uint256(0),
            ConstraintType.EQ,
            bytes32(actual),
            abi.encode(expected)
        );
    }

    function slice(bytes memory value, uint256 begin, uint256 end) private pure returns (bytes memory result) {
        result = new bytes(end - begin);
        for (uint256 i; i < result.length; ++i) {
            result[i] = value[begin + i];
        }
    }

    function testResolveRawAndCaller() public view {
        check(abi.encodeCall(core.resolve, (raw(hex"00ff0102"))), true, hex"00ff0102");
        InputParam memory p = raw(abi.encode(address(target), abi.encodeCall(target.sender, ())));
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
        check(abi.encodeCall(core.resolve, (p)), true, abi.encode(address(core)));
    }

    function testGatherPreservesValuesAndFirstFailure() public view {
        InputParam[] memory args = new InputParam[](4);
        bytes[] memory expected = new bytes[](4);
        expected[0] = "";
        expected[1] = hex"12";
        expected[2] = abi.encode(uint256(71));
        expected[3] = new bytes(33);
        for (uint256 i; i < 4; ++i) {
            args[i] = raw(expected[i]);
        }
        check(abi.encodeCall(core.gather, (args)), true, abi.encode(expected));
        args[2] = constrained(abi.encode(uint256(71)), 72);
        args[3] = failCall();
        check(abi.encodeCall(core.gather, (args)), false, failure(2, 71, 72));
    }

    function testPickNegativeAndPartialTail() public view {
        bytes memory value = bytes.concat(abi.encode(uint256(71), uint256(99)), hex"ffff01");
        check(abi.encodeCall(core.pick, (raw(value), int256(-1))), true, abi.encode(uint256(99)));
        check(abi.encodeCall(core.pick, (raw(value), int256(-2))), true, abi.encode(uint256(71)));
        check(
            abi.encodeCall(core.pick, (raw(value), int256(2))),
            false,
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(2), uint256(67))
        );
        check(
            abi.encodeCall(core.pick, (raw(value), type(int256).min)),
            false,
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, type(int256).min, uint256(67))
        );
        check(
            abi.encodeCall(core.pick, (raw(hex"01"), int256(-1))),
            false,
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(-1), uint256(1))
        );
    }

    function testPickConstraintBeforeIndex() public view {
        check(
            abi.encodeCall(core.pick, (constrained(abi.encode(uint256(7)), 8), type(int256).max)),
            false,
            failure(0, 7, 8)
        );
    }

    function testReadSegmentsAndOperandIndex() public view {
        bytes memory encoded = abi.encode(uint256(31), uint256(47));
        InputParam[] memory args = new InputParam[](3);
        args[0] = raw(slice(encoded, 0, 5));
        args[1] = raw(slice(encoded, 5, 38));
        args[2] = raw(slice(encoded, 38, 64));
        check(
            abi.encodeCall(core.read, (raw(abi.encode(address(target))), target.pair.selector, args)),
            true,
            abi.encode(uint256(78))
        );
        args[0] = constrained(abi.encode(uint256(3)), 4);
        check(
            abi.encodeCall(core.read, (raw(abi.encode(address(target))), target.pair.selector, args)),
            false,
            failure(1, 3, 4)
        );
    }

    function testChainRawFinalAndEmptyBeforeResolution() public view {
        bytes[] memory calls = new bytes[](3);
        calls[0] = abi.encodeCall(target.next, (address(target)));
        calls[1] = calls[0];
        calls[2] = abi.encodeCall(target.finish, ());
        check(abi.encodeCall(core.chain, (raw(abi.encode(address(target))), calls)), true, hex"123456");
        check(
            abi.encodeCall(core.chain, (failCall(), new bytes[](0))),
            false,
            abi.encodeWithSelector(Assertions.EmptyCallChain.selector)
        );
    }

    function testChainDirtyHopIndex() public view {
        bytes[] memory calls = new bytes[](3);
        calls[0] = abi.encodeCall(target.next, (address(target)));
        calls[1] = abi.encodeCall(target.dirty, ());
        calls[2] = abi.encodeCall(target.finish, ());
        check(
            abi.encodeCall(core.chain, (raw(abi.encode(address(target))), calls)),
            false,
            abi.encodeWithSelector(InvalidAddressWord.selector, uint256(2), bytes32(uint256(1) << 160))
        );
    }

    function testCondLazyAndBranchIndices() public view {
        check(abi.encodeCall(core.cond, (raw(abi.encode(uint256(7))), raw(hex"abcd"), failCall())), true, hex"abcd");
        check(abi.encodeCall(core.cond, (raw(abi.encode(uint256(0))), failCall(), raw(hex"cdef"))), true, hex"cdef");
        check(
            abi.encodeCall(
                core.cond, (raw(abi.encode(uint256(0))), failCall(), constrained(abi.encode(uint256(7)), 8))
            ),
            false,
            failure(2, 7, 8)
        );
        check(
            abi.encodeCall(core.cond, (raw(hex"01"), failCall(), failCall())),
            false,
            abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(1))
        );
    }
}
