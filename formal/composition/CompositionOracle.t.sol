// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Assertions} from "../../contracts/Assertions.sol";
import {
    InputParam,
    InputParamType,
    InputParamFetcherType,
    Constraint,
    ConstraintType,
    ConstraintFailed
} from "../../contracts/lib/ERC8211.sol";

contract CompositionTarget {
    function value() external pure returns (uint8, string memory) {
        return (7, "resolved");
    }

    function fail() external pure {
        revert("producer");
    }
}

contract CompositionOracleTest {
    Assertions private core = new Assertions();
    CompositionTarget private target = new CompositionTarget();

    function raw(bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function called(bytes memory data) private view returns (InputParam memory p) {
        p = raw(abi.encode(address(target), data));
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
    }

    function path1(int256 index) private pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = index;
    }

    function check(InputParam memory p, string memory t, int256[] memory path, bool success, bytes memory expected)
        private
        view
    {
        (bool ok, bytes memory data) = address(core).staticcall(abi.encodeCall(core.nav, (p, t, path)));
        require(ok == success, "wrong verdict");
        require(keccak256(data) == keccak256(expected), "wrong exact bytes");
    }

    function failure(uint256 actual) private pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            "",
            uint256(0),
            uint256(0),
            uint256(0),
            ConstraintType.EQ,
            bytes32(actual),
            abi.encode(uint256(99))
        );
    }

    function testConstraintFailurePrecedesNavigationAndNamesContext() public view {
        InputParam memory p = called(abi.encodeCall(target.value, ()));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(99)));
        check(p, "broken", path1(30), false, failure(7));
        check(p, "broken", new int256[](0), false, failure(7));
    }

    function testMalformedFetchPrecedesEmptyPath() public view {
        InputParam memory p = raw(hex"1234");
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
        check(p, "", new int256[](0), false, "");
    }

    function testFetchFailurePassesThroughExactly() public view {
        InputParam memory p = called(abi.encodeCall(target.fail, ()));
        (bool ok, bytes memory expected) = address(core).staticcall(abi.encodeCall(core.resolve, (p)));
        require(!ok, "resolve should fail");
        check(p, "broken", path1(9), false, expected);
    }

    function testStaticCallCanonicalValueAndModes() public view {
        InputParam memory p = called(abi.encodeCall(target.value, ()));
        check(p, "(uint8,string)", path1(0), true, abi.encode(uint8(7)));
        check(p, "(uint8,string)", path1(1), true, abi.encode("resolved"));
        int256[] memory path = new int256[](2);
        path[0] = 1;
        path[1] = core.LEN();
        check(p, "(uint8,string)", path, true, abi.encode(uint256(8)));
        path[1] = core.PAYLOAD();
        check(p, "(uint8,string)", path, true, bytes("resolved"));
    }

    function testEmptyPathPassesResolvedBytesWithoutTypeParsing() public view {
        check(raw(hex"fe01020304"), "broken", new int256[](0), true, hex"fe01020304");
        check(
            called(abi.encodeCall(target.value, ())), "broken", new int256[](0), true, abi.encode(uint8(7), "resolved")
        );
    }

    function testMalformedSelectedValueKeepsNavigationError() public view {
        check(
            raw(abi.encode(uint256(256))),
            "(uint8)",
            path1(0),
            false,
            abi.encodeWithSelector(bytes4(keccak256("InvalidValue(uint256)")), uint256(0))
        );
    }
}
