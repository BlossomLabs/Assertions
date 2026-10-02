// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Assertions} from "../../contracts/Assertions.sol";
import {
    InputParam,
    InputParamType,
    InputParamFetcherType,
    Constraint,
    ConstraintType,
    ComposableExecution,
    OutputParam,
    OutputParamFetcherType,
    CallFailed,
    InvalidBalanceData,
    InvalidAddressWord,
    ReturnDataOutOfBounds,
    ConstraintFailed
} from "../../contracts/lib/ERC8211.sol";

contract ResolutionHarness is Assertions {
    function resolveAt(InputParam calldata p, string calldata message, uint256 entry, uint256 index)
        external
        view
        returns (bytes memory)
    {
        return _resolve(p, message, entry, index);
    }

    function callAt(address target, bytes memory data) external view returns (bytes memory) {
        return _staticCall(target, data);
    }
}

contract ResolutionTarget {
    function balanceOf(address account) external pure returns (uint256) {
        return uint160(account) + 19;
    }

    function twoWords() external pure returns (uint256, uint256) {
        return (71, 99);
    }

    function oneByte() external pure {
        assembly {
            mstore(0, 7)
            return(31, 1)
        }
    }

    function fail() external pure {
        revert("ordinary failure");
    }

    function signal() external pure {
        revert Assertions.SubcallOutOfGas();
    }

    function longerSignal() external pure {
        assembly {
            mstore(0, shl(224, 0xd271060e))
            revert(0, 5)
        }
    }

    function successfulSignal() external pure {
        assembly {
            mstore(0, shl(224, 0xd271060e))
            return(0, 4)
        }
    }

    function checkArgs(uint256 a, uint256 b) external pure returns (bool) {
        require(a == 31 && b == 47, "argument order");
        return false;
    }
}

contract ShortBalanceTarget {
    fallback() external {
        assembly {
            mstore(0, 7)
            return(31, 1)
        }
    }
}

contract LongBalanceTarget {
    function balanceOf(address) external pure returns (uint256, uint256) {
        return (137, 999);
    }
}

contract ResolutionOracleTest {
    ResolutionHarness private core = new ResolutionHarness();
    ResolutionTarget private target = new ResolutionTarget();
    ShortBalanceTarget private shortToken = new ShortBalanceTarget();
    LongBalanceTarget private longToken = new LongBalanceTarget();

    function raw(bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function called(bytes memory data) private view returns (InputParam memory p) {
        p = raw(abi.encode(address(target), data));
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
    }

    function constrained(InputParam memory p, uint256 bound) private pure returns (InputParam memory) {
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(bound));
        return p;
    }

    function resolution(InputParam memory p, bool expected, bytes memory bytes_) private view {
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(core.resolveAt, (p, "context", uint256(17), uint256(23))));
        require(ok == expected, "resolver verdict");
        require(keccak256(out) == keccak256(bytes_), "resolver exact bytes");
    }

    function batch(ComposableExecution[] memory entries, bool expected, bytes memory bytes_) private view {
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeWithSelector(
                    bytes4(
                        keccak256(
                            "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[],string)"
                        )
                    ),
                    entries,
                    "batch context"
                )
            );
        require(ok == expected, "batch verdict");
        require(keccak256(out) == keccak256(bytes_), "batch exact bytes");
    }

    function entry(InputParam[] memory params, bytes4 selector) private pure returns (ComposableExecution memory) {
        return ComposableExecution(selector, params, new OutputParam[](0));
    }

    function testRawAndStaticCallPreserveBytes() public view {
        resolution(raw(hex"000102ff"), true, abi.encode(hex"000102ff"));
        resolution(called(abi.encodeCall(target.twoWords, ())), true, abi.encode(abi.encode(uint256(71), uint256(99))));
        resolution(called(abi.encodeCall(target.successfulSignal, ())), true, abi.encode(hex"d271060e"));
    }

    function testMalformedCallBeforeConstraints() public view {
        InputParam memory p = constrained(raw(hex"01"), 0);
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
        resolution(p, false, "");
    }

    function testCallFailureAndSignal() public view {
        bytes memory data = abi.encodeCall(target.fail, ());
        resolution(called(data), false, abi.encodeWithSelector(CallFailed.selector, address(target), data));
        resolution(
            called(abi.encodeCall(target.signal, ())),
            false,
            abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector)
        );
        data = abi.encodeCall(target.longerSignal, ());
        resolution(called(data), false, abi.encodeWithSelector(CallFailed.selector, address(target), data));
        InputParam memory p = raw(abi.encode(address(0x1234), hex"0102"));
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
        resolution(p, false, abi.encodeWithSelector(CallFailed.selector, address(0x1234), hex"0102"));
    }

    function testNativeAndTokenBalance() public view {
        InputParam memory p = raw(abi.encodePacked(address(0), address(target)));
        p.fetcherType = InputParamFetcherType.BALANCE;
        resolution(p, true, abi.encode(abi.encode(address(target).balance)));
        p.paramData = abi.encodePacked(address(target), address(0xabc));
        resolution(p, true, abi.encode(abi.encode(uint256(0xabc + 19))));
        p.paramData = hex"01";
        resolution(p, false, abi.encodeWithSelector(InvalidBalanceData.selector, uint256(17), uint256(23), uint256(1)));
    }

    function testConstraintContextAndFailedFetchPrecedence() public view {
        InputParam memory p = constrained(raw(abi.encode(uint256(71))), 72);
        resolution(
            p,
            false,
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "context",
                uint256(17),
                uint256(23),
                uint256(0),
                ConstraintType.EQ,
                bytes32(uint256(71)),
                abi.encode(uint256(72))
            )
        );
        p = constrained(called(abi.encodeCall(target.fail, ())), 0);
        resolution(
            p, false, abi.encodeWithSelector(CallFailed.selector, address(target), abi.encodeCall(target.fail, ()))
        );
    }

    function testAssertParamIgnoresRouteAndDefaults() public view {
        InputParam memory p = raw(hex"01");
        p.paramType = InputParamType.VALUE;
        core.assertParam(p);
        p = constrained(raw(abi.encode(uint256(7))), 8);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
        require(
            !ok
                && keccak256(out)
                    == keccak256(
                        abi.encodeWithSelector(
                            ConstraintFailed.selector,
                            "PARAM",
                            uint256(0),
                            uint256(0),
                            uint256(0),
                            ConstraintType.EQ,
                            bytes32(uint256(7)),
                            abi.encode(uint256(8))
                        )
                    )
        );
    }

    function testConstructedCallOrderAndFalseReturn() public view {
        InputParam[] memory params = new InputParam[](3);
        params[0] = raw(abi.encode(uint256(31)));
        params[1] = raw(abi.encode(address(target)));
        params[1].paramType = InputParamType.TARGET;
        params[2] = raw(abi.encode(uint256(47)));
        ComposableExecution[] memory entries = new ComposableExecution[](1);
        entries[0] = entry(params, target.checkArgs.selector);
        batch(entries, true, "");
        params[1].paramData = abi.encode(address(0));
        entries[0] = entry(params, bytes4(0xffffffff));
        batch(entries, true, "");
        batch(new ComposableExecution[](0), true, "");
    }

    function testRoutingErrorsPrecedeResolution() public view {
        InputParam[] memory params = new InputParam[](2);
        params[0] = raw(hex"01");
        params[0].paramType = InputParamType.VALUE;
        params[0].fetcherType = InputParamFetcherType.STATIC_CALL;
        params[1] = raw("");
        ComposableExecution[] memory entries = new ComposableExecution[](1);
        entries[0] = entry(params, 0);
        batch(
            entries, false, abi.encodeWithSelector(Assertions.ValueParamNotSupported.selector, uint256(0), uint256(0))
        );
        entries[0].outputParams = new OutputParam[](1);
        batch(entries, false, abi.encodeWithSelector(Assertions.OutputParamsNotSupported.selector, uint256(0)));
        params[0] = raw(abi.encode(address(0)));
        params[0].paramType = InputParamType.TARGET;
        params[1] = raw(hex"01");
        params[1].paramType = InputParamType.TARGET;
        params[1].fetcherType = InputParamFetcherType.BALANCE;
        entries[0] = entry(params, 0);
        batch(entries, false, abi.encodeWithSelector(Assertions.DuplicateTargetParam.selector, uint256(0)));
        params = new InputParam[](1);
        params[0] = raw(hex"01");
        params[0].paramType = InputParamType.TARGET;
        params[0].fetcherType = InputParamFetcherType.BALANCE;
        entries[0] = entry(params, 0);
        batch(entries, false, abi.encodeWithSelector(Assertions.BalanceCannotBeTarget.selector, uint256(0), uint256(0)));
    }

    function testTargetValidationAndLaterContext() public view {
        InputParam[] memory params = new InputParam[](1);
        params[0] = raw(hex"01");
        params[0].paramType = InputParamType.TARGET;
        ComposableExecution[] memory entries = new ComposableExecution[](2);
        entries[0] = entry(new InputParam[](0), 0);
        entries[1] = entry(params, 0);
        batch(entries, false, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(1)));
        params[0].paramData = abi.encode(uint256(1) << 160);
        entries[1] = entry(params, 0);
        batch(
            entries, false, abi.encodeWithSelector(InvalidAddressWord.selector, uint256(0), bytes32(uint256(1) << 160))
        );
        params[0] = constrained(raw(abi.encode(uint256(4))), 5);
        entries[1] = entry(params, 0);
        batch(
            entries,
            false,
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "batch context",
                uint256(1),
                uint256(0),
                uint256(0),
                ConstraintType.EQ,
                bytes32(uint256(4)),
                abi.encode(uint256(5))
            )
        );
    }

    function testTokenBalanceFirstWordAndShortReturn() public view {
        InputParam memory p = raw(abi.encodePacked(address(shortToken), address(0xabc)));
        p.fetcherType = InputParamFetcherType.BALANCE;
        resolution(p, false, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), uint256(1)));
        p.paramData = abi.encodePacked(address(longToken), address(0xabc));
        resolution(p, true, abi.encode(abi.encode(uint256(137))));
    }

    function testTargetConstraintsBeforeAddress() public view {
        InputParam[] memory params = new InputParam[](2);
        params[0] = raw("");
        params[1] = constrained(raw(abi.encode(uint256(1) << 160)), 0);
        params[1].paramType = InputParamType.TARGET;
        ComposableExecution[] memory entries = new ComposableExecution[](2);
        entries[0] = entry(new InputParam[](0), 0);
        entries[1] = entry(params, 0);
        batch(
            entries,
            false,
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "batch context",
                uint256(1),
                uint256(1),
                uint256(0),
                ConstraintType.EQ,
                bytes32(uint256(1) << 160),
                abi.encode(uint256(0))
            )
        );
    }
}
