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

contract ControlTarget {
    function fail(bytes calldata reason) external pure {
        bytes memory copied = reason;
        assembly { revert(add(copied, 32), mload(copied)) }
    }

    function falseValue() external pure returns (bool) {
        return false;
    }

    function burn() external pure {
        assembly { for {} 1 {} {} }
    }
}

contract ControlOracleTest {
    Assertions private core = new Assertions();
    ControlTarget private target = new ControlTarget();

    function raw(bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function callParam(address address_, bytes memory data) private pure returns (InputParam memory p) {
        p = raw(abi.encode(address_, data));
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
    }

    function failing(bytes memory reason) private view returns (InputParam memory) {
        return callParam(address(target), abi.encodeCall(target.fail, (reason)));
    }

    function constrained(uint256 value, uint256 wanted) private pure returns (InputParam memory p) {
        p = raw(abi.encode(value));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(wanted));
    }

    function check(bytes memory callData, bool expected, bytes memory data) private view {
        (bool ok, bytes memory out) = address(core).staticcall(callData);
        require(ok == expected, "wrong verdict");
        require(keccak256(out) == keccak256(data), "wrong exact bytes");
    }

    function testSuccessfulAttemptIsLazyAndPreservesBytes() public view {
        check(abi.encodeCall(core.orElse, (raw(hex"d271060e"), failing(hex"ab"))), true, hex"d271060e");
        check(abi.encodeCall(core.isValid, (raw(hex"d271060e"))), true, abi.encode(uint256(1)));
        InputParam memory a = callParam(address(target), abi.encodeCall(target.falseValue, ()));
        check(abi.encodeCall(core.orElse, (a, failing(hex"ab"))), true, abi.encode(false));
        check(abi.encodeCall(core.isValid, (a)), true, abi.encode(uint256(1)));
    }

    function testOrdinaryFailuresSelectFallback() public view {
        InputParam memory fallback_ = raw(hex"123456");
        check(abi.encodeCall(core.orElse, (failing(hex"01"), fallback_)), true, hex"123456");
        check(abi.encodeCall(core.orElse, (callParam(address(0x1234), hex"abcd"), fallback_)), true, hex"123456");
        check(abi.encodeCall(core.orElse, (constrained(7, 8), fallback_)), true, hex"123456");
        InputParam memory malformed = raw(hex"01");
        malformed.fetcherType = InputParamFetcherType.STATIC_CALL;
        check(abi.encodeCall(core.orElse, (malformed, fallback_)), true, hex"123456");
        check(abi.encodeCall(core.isValid, (malformed)), true, abi.encode(uint256(0)));
        check(abi.encodeCall(core.isValid, (constrained(7, 8))), true, abi.encode(uint256(0)));
    }

    function testFallbackFailureNamesOperandOne() public view {
        check(
            abi.encodeCall(core.orElse, (failing(hex"01"), constrained(7, 8))),
            false,
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "",
                uint256(0),
                uint256(1),
                uint256(0),
                ConstraintType.EQ,
                bytes32(uint256(7)),
                abi.encode(uint256(8))
            )
        );
    }

    function testExactSignalPropagatesAndPrefixDoesNot() public view {
        bytes memory signal = abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
        check(abi.encodeCall(core.orElse, (failing(signal), raw(hex"01"))), false, signal);
        check(abi.encodeCall(core.isValid, (failing(signal))), false, signal);
        check(abi.encodeCall(core.revertData, (failing(signal), bytes4(0))), false, signal);
        check(abi.encodeCall(core.orElse, (failing(bytes.concat(signal, hex"ff")), raw(hex"01"))), true, hex"01");
        check(
            abi.encodeCall(core.revertData, (failing(bytes.concat(signal, hex"ff")), bytes4(0))),
            true,
            bytes.concat(signal, hex"ff")
        );
        InputParam memory nested =
            callParam(address(core), abi.encodeCall(core.orElse, (failing(signal), raw(hex"02"))));
        check(abi.encodeCall(core.orElse, (nested, raw(hex"03"))), false, signal);
    }

    function testRevertProbeAdmissionOrder() public view {
        InputParam memory p = constrained(7, 8);
        check(
            abi.encodeCall(core.revertData, (p, bytes4(0))),
            false,
            abi.encodeWithSelector(Assertions.RevertProbeNotACall.selector, uint8(0))
        );
        p.fetcherType = InputParamFetcherType.STATIC_CALL;
        p.paramData = hex"01";
        check(
            abi.encodeCall(core.revertData, (p, bytes4(0))),
            false,
            abi.encodeWithSelector(Assertions.RevertProbeConstrained.selector, uint256(1))
        );
        p.constraints = new Constraint[](0);
        check(abi.encodeCall(core.revertData, (p, bytes4(0))), false, "");
    }

    function testSelectorMatchingAndStripping() public view {
        check(abi.encodeCall(core.revertData, (failing(hex"12345678abcdef"), bytes4(0))), true, hex"12345678abcdef");
        check(abi.encodeCall(core.revertData, (failing(hex"12345678abcdef"), bytes4(0x12345678))), true, hex"abcdef");
        check(abi.encodeCall(core.revertData, (failing(hex"12345678"), bytes4(0x12345678))), true, "");
        check(
            abi.encodeCall(core.revertData, (failing(hex"12345678"), bytes4(0xaabbccdd))),
            false,
            abi.encodeWithSelector(Assertions.UnexpectedRevertData.selector, bytes4(0xaabbccdd), bytes4(0x12345678))
        );
        check(
            abi.encodeCall(core.revertData, (failing(hex"123456"), bytes4(0x12345678))),
            false,
            abi.encodeWithSelector(Assertions.UnexpectedRevertData.selector, bytes4(0x12345678), bytes4(0))
        );
    }

    function testCodelessProbeAndSuccessfulCall() public view {
        InputParam memory a = callParam(address(0x1234), hex"01");
        check(abi.encodeCall(core.revertData, (a, bytes4(0))), true, "");
        check(
            abi.encodeCall(core.revertData, (a, bytes4(0x12345678))),
            false,
            abi.encodeWithSelector(Assertions.UnexpectedRevertData.selector, bytes4(0x12345678), bytes4(0))
        );
        bytes memory data = abi.encodeCall(target.falseValue, ());
        a = callParam(address(target), data);
        check(
            abi.encodeCall(core.revertData, (a, bytes4(0))),
            false,
            abi.encodeWithSelector(Assertions.DidNotRevert.selector, address(target), data)
        );
    }

    function testConcreteExhaustionDoesNotSelectFallback() public view {
        InputParam memory a = callParam(address(target), abi.encodeCall(target.burn, ()));
        (bool ok, bytes memory out) =
            address(core).staticcall{gas: 500000}(abi.encodeCall(core.orElse, (a, raw(hex"01"))));
        require(
            !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector)),
            "exhaustion must propagate"
        );
    }
}
