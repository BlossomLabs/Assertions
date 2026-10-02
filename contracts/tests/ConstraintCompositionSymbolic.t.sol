// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "./BatchDifferentialSymbolic.t.sol";

/**
 * @notice Halmos properties for constraint composition on the wire: a
 *         two-entry batch whose parameters each carry two constraints, EQ
 *         then a two-leaf OR, judged like the pinned Biconomy reference and
 *         failing with the complete first-failure payload; and every non-OR
 *         constraint kind at a nonzero constraint index over eight literal
 *         reference lengths, accepted at exactly its required length. Run
 *         with `pnpm halmos`.
 * @dev Errors are compared byte for byte. The words judged and the reference
 *      words stay symbolic; the batch shape, constraint kinds and reference
 *      lengths are literals. The reference bytecode is the inlined copy
 *      BatchDifferentialSymbolic pins to the fixture.
 */
contract ConstraintCompositionSymbolicTest is Test {
    Assertions core;
    BatchReferenceHost host;

    function setUp() public {
        core = new Assertions();
        host = new BatchReferenceHost();
        vm.etch(BICONOMY_ERC8211, BICONOMY_ERC8211_RUNTIME);
    }

    function batchParam(bytes32 a, bytes32 b, bytes32 expected, bytes32 left, bytes32 right)
        internal
        pure
        returns (InputParam memory p)
    {
        Constraint[] memory alternatives = new Constraint[](2);
        alternatives[0] = Constraint(ConstraintType.EQ, abi.encode(left));
        alternatives[1] = Constraint(ConstraintType.EQ, abi.encode(right));
        Constraint[] memory constraints = new Constraint[](2);
        constraints[0] = Constraint(ConstraintType.EQ, abi.encode(expected));
        constraints[1] = Constraint(ConstraintType.OR, abi.encode(alternatives));
        p = InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(a, b), constraints);
    }

    function batchCall(ComposableExecution[] memory batch) internal pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", batch
            );
    }

    /**
     * @dev Two entries, one two-word parameter each, EQ on word 0 then a
     *      two-leaf OR on word 1: the verdict equals the reference's, and a
     *      failure is ConstraintFailed for the first failing constraint in
     *      entry order (index 0 with EQ, or index 1 with OR echoing the whole
     *      OR payload)
     */
    function check_batchSecondConstraintAndOr(bytes32[4] memory actual, bytes32[6] memory refs) public {
        ComposableExecution[] memory batch = new ComposableExecution[](2);
        for (uint256 i; i < 2; i++) {
            batch[i].inputParams = new InputParam[](1);
            batch[i].inputParams[0] =
                batchParam(actual[2 * i], actual[2 * i + 1], refs[3 * i], refs[3 * i + 1], refs[3 * i + 2]);
        }
        (bool ok, bytes memory out) = address(core).call(batchCall(batch));
        (bool referenceOk,) = address(host).call(abi.encodeCall(BatchReferenceHost.judge, (batch)));
        bool expected = true;
        bytes memory failure;
        for (uint256 i; i < 2; i++) {
            bool first = actual[2 * i] == refs[3 * i];
            bool second = actual[2 * i + 1] == refs[3 * i + 1] || actual[2 * i + 1] == refs[3 * i + 2];
            if (!first || !second) {
                expected = false;
                uint256 k = first ? 1 : 0;
                failure = batchFailure(batch[i].inputParams[0], actual[2 * i + k], i, k);
                break;
            }
        }
        assertEq(ok, expected);
        assertEq(referenceOk, expected);
        if (!ok) assertEq(out, failure);
    }

    function batchFailure(InputParam memory p, bytes32 actual, uint256 entry, uint256 index)
        internal
        pure
        returns (bytes memory)
    {
        Constraint memory c = p.constraints[index];
        return abi.encodeWithSelector(
            ConstraintFailed.selector, "COMPOSABLE", entry, uint256(0), index, c.constraintType, actual, c.referenceData
        );
    }

    /**
     * @dev Every non-OR kind at constraint index 1 (a SKIP at index 0 keeps
     *      the error context nonzero) with reference lengths 0, 1, 31, 32,
     *      33, 64, 65 and 96: any length but the required one reverts
     *      InvalidConstraintData(0, 0, 1, length), a reversed range
     *      InvalidConstraintRange, and otherwise the verdict and the exact
     *      leaf failure follow the kind's semantics over symbolic words
     */
    function check_exactReferenceLengths(bytes32 value, bytes32 a, bytes32 b, uint8 kind, uint8 lengthCase)
        public
        view
    {
        vm.assume(kind < 9 && kind != 6 && lengthCase < 8);
        uint256 length;
        if (lengthCase == 0) length = 0;
        else if (lengthCase == 1) length = 1;
        else if (lengthCase == 2) length = 31;
        else if (lengthCase == 3) length = 32;
        else if (lengthCase == 4) length = 33;
        else if (lengthCase == 5) length = 64;
        else if (lengthCase == 6) length = 65;
        else length = 96;
        bytes memory ref = abi.encode(a, b, bytes32(0));
        assembly ("memory-safe") { mstore(ref, length) }
        bool ok;
        bytes memory out;
        {
            InputParam memory p;
            p.fetcherType = InputParamFetcherType.RAW_BYTES;
            p.paramData = abi.encode(bytes32(0), value);
            p.constraints = new Constraint[](2);
            p.constraints[0] = Constraint(ConstraintType.SKIP, "");
            p.constraints[1] = Constraint(ConstraintType(kind), ref);
            bytes memory callData = abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p);
            (ok, out) = address(core).staticcall(callData);
        }
        uint256 required = kind == 7 ? 0 : (kind == 3 || kind == 8) ? 64 : 32;
        if (length != required) {
            assertFalse(ok);
            assertEq(
                out, abi.encodeWithSelector(InvalidConstraintData.selector, uint256(0), uint256(0), uint256(1), length)
            );
            return;
        }
        bool reversed = kind == 3 ? a > b : kind == 8 && int256(uint256(a)) > int256(uint256(b));
        if (reversed) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(InvalidConstraintRange.selector, uint256(0), uint256(0), uint256(1)));
            return;
        }
        bool expected;
        if (kind == 0) expected = value == a;
        else if (kind == 1) expected = value >= a;
        else if (kind == 2) expected = value <= a;
        else if (kind == 3) expected = a <= value && value <= b;
        else if (kind == 4) expected = int256(uint256(value)) >= int256(uint256(a));
        else if (kind == 5) expected = int256(uint256(value)) <= int256(uint256(a));
        else if (kind == 7) expected = true;
        else expected = int256(uint256(a)) <= int256(uint256(value)) && int256(uint256(value)) <= int256(uint256(b));
        assertEq(ok, expected);
        if (!ok) assertEq(out, leafFailure(kind, value, ref));
    }

    function leafFailure(uint8 kind, bytes32 value, bytes memory ref) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector, "PARAM", uint256(0), uint256(0), uint256(1), ConstraintType(kind), value, ref
        );
    }

    /**
     * @dev Every case on a real EVM, with passing and failing words
     */
    function test_constraintGeometries() public {
        bytes32[4] memory actual = [bytes32(uint256(1)), bytes32(uint256(2)), bytes32(uint256(3)), bytes32(uint256(4))];
        bytes32[6] memory refs = [
            bytes32(uint256(1)),
            bytes32(uint256(2)),
            bytes32(uint256(8)),
            bytes32(uint256(3)),
            bytes32(uint256(4)),
            bytes32(uint256(9))
        ];
        check_batchSecondConstraintAndOr(actual, refs);
        actual[3] = bytes32(uint256(5));
        check_batchSecondConstraintAndOr(actual, refs);
        actual[2] = bytes32(uint256(5));
        check_batchSecondConstraintAndOr(actual, refs);
        actual[1] = bytes32(uint256(5));
        check_batchSecondConstraintAndOr(actual, refs);
        actual[0] = bytes32(uint256(5));
        check_batchSecondConstraintAndOr(actual, refs);
        for (uint8 kind; kind < 9; kind++) {
            if (kind == 6) continue;
            for (uint8 lengthCase; lengthCase < 8; lengthCase++) {
                check_exactReferenceLengths(
                    bytes32(uint256(2)), bytes32(uint256(1)), bytes32(uint256(3)), kind, lengthCase
                );
                check_exactReferenceLengths(
                    bytes32(uint256(4)), bytes32(uint256(3)), bytes32(uint256(1)), kind, lengthCase
                );
            }
        }
    }
}
