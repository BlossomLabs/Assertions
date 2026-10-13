// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";

contract ClaimControlOracle {
    function echo(bytes32 value) external pure returns (bytes32) {
        return value;
    }

    function fail(bytes calldata reason) external pure {
        assembly ("memory-safe") {
            calldatacopy(0, reason.offset, reason.length)
            revert(0, reason.length)
        }
    }
}

/**
 * @notice C85 over one STATIC_CALL operand, zero or one EQ constraint,
 *         ordinary failures and the exact reserved signal. No gas proof.
 */
contract ClaimControlSymbolicTest is Test {
    Assertions core;
    ClaimControlOracle oracle;

    function setUp() public {
        core = new Assertions();
        oracle = new ClaimControlOracle();
    }

    function check_claimValidityIsResolution(bytes32 value, bytes32 ref, bool constrained) public view {
        InputParam memory p = operand(abi.encodeCall(ClaimControlOracle.echo, (value)));
        if (constrained) {
            p.constraints = new Constraint[](1);
            p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(ref));
        }
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (p)));
        excludeGasArtifact(ok, out);
        assertTrue(ok);
        assertEq(abi.decode(out, (uint256)), !constrained || value == ref ? 1 : 0);
    }

    function check_claimValidityOrdinaryFailure(bytes32 reason, uint8 lengthCase, bool codeLess) public view {
        vm.assume(lengthCase < 4);
        bytes memory signal = abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
        // Every body word remains symbolic; only copying lengths are literal.
        bytes memory data = abi.encode(reason);
        if (lengthCase == 0) {
            assembly ("memory-safe") { mstore(data, 0) }
        } else if (lengthCase == 1) {
            assembly ("memory-safe") { mstore(data, 3) }
        } else if (lengthCase == 2) {
            assembly ("memory-safe") { mstore(data, 4) }
        }
        vm.assume(keccak256(data) != keccak256(signal));
        InputParam memory p = operand(abi.encodeCall(ClaimControlOracle.fail, (data)));
        if (codeLess) p.paramData = abi.encode(address(0xE0A), bytes(""));
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (p)));
        excludeGasArtifact(ok, out);
        assertTrue(ok);
        assertEq(abi.decode(out, (uint256)), 0);
    }

    function check_claimValidityReservedSignal() public view {
        bytes memory signal = abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
        InputParam memory p = operand(abi.encodeCall(ClaimControlOracle.fail, (signal)));
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (p)));
        // Do not exclude the signal path: it is the behavior being proved.
        assertFalse(ok);
        assertEq(out, signal);
    }

    function test_claimControlSamples() public view {
        check_claimValidityIsResolution(bytes32(0), bytes32(0), false);
        check_claimValidityIsResolution(bytes32(0), bytes32(uint256(1)), true);
        check_claimValidityOrdinaryFailure(bytes32(uint256(7)), 0, false);
        check_claimValidityOrdinaryFailure(bytes32(uint256(7)), 2, true);
        check_claimValidityReservedSignal();
    }

    function operand(bytes memory data) internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(oracle), data),
            new Constraint[](0)
        );
    }

    function excludeGasArtifact(bool ok, bytes memory out) internal pure {
        // Halmos gasleft() values are independent symbols. Exclude its
        // spurious exhaustion branch, retaining concrete gas-sweep evidence.
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector)));
    }
}
