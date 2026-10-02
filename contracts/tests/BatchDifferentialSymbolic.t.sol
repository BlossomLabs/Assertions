// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "./BiconomyERC8211Runtime.sol";

interface IReferenceBatch {
    function executeComposableDelegateCall(ComposableExecution[] calldata entries) external;
}

/**
 * @dev Delegatecalls the pinned Biconomy runtime with a whole batch of
 *      predicate entries (no TARGET, so the reference makes no call either)
 */
contract BatchReferenceHost {
    function judge(ComposableExecution[] calldata entries) external {
        (bool ok, bytes memory result) =
            BICONOMY_ERC8211.delegatecall(abi.encodeCall(IReferenceBatch.executeComposableDelegateCall, (entries)));
        if (!ok) assembly ("memory-safe") { revert(add(result, 32), mload(result)) }
    }
}

/**
 * @notice Halmos properties: `assertBatch` over predicate entries judges
 *         exactly as its parts do and as the pinned Biconomy runtime does.
 *         Run with `pnpm halmos`.
 * @dev Two directions. Against the core itself: a batch of three CALL_DATA
 *      parameters over two entries (two, then one) passes exactly when
 *      `assertParam` passes on each, and otherwise reverts with the FIRST
 *      failing parameter's error relabeled to its batch position
 *      ("COMPOSABLE", entry, param), which pins the revert data, not only
 *      the verdict. Against the reference: the same batches reach the same
 *      verdict as Biconomy on canonical encodings, and Assertions is never
 *      more permissive. Entries carry no TARGET, so neither side makes a
 *      call: a TARGET entry would make Biconomy CALL where the view judge
 *      STATICCALLs. Parameters are RAW_BYTES. Each constraint is one of five
 *      cases with distinct outcomes (see param): the per-constraint semantics
 *      are ERC8211Symbolic's to prove, this suite proves how a batch composes
 *      them, and a symbolic type and reference length per operand multiplied
 *      past two million paths.
 */
contract BatchDifferentialSymbolicTest is Test {
    struct RawConstraint {
        uint8 constraintType;
        bytes referenceData;
    }

    struct RawParam {
        uint8 paramType;
        uint8 fetcherType;
        bytes paramData;
        RawConstraint[] constraints;
    }

    struct RawOutput {
        uint8 fetcherType;
        bytes paramData;
    }

    struct RawExecution {
        bytes4 functionSig;
        RawParam[] inputParams;
        RawOutput[] outputParams;
    }

    /**
     * @dev One parameter's raw material: its word, the case its single
     *      constraint takes (see param) and the reference words
     */
    struct Operand {
        uint256 value;
        uint8 caseId;
        bytes32 ref0;
        bytes32 ref1;
    }

    uint8 constant SKIP = 7;
    string constant PARAM = "(uint8,uint8,bytes,(uint8,bytes)[])";

    Assertions core;
    BatchReferenceHost host;

    function setUp() public {
        vm.etch(BICONOMY_ERC8211, BICONOMY_ERC8211_RUNTIME);
        core = new Assertions();
        host = new BatchReferenceHost();
    }

    // ============ Properties ============

    /**
     * @dev A batch is the conjunction of its parameters, in order: it passes
     *      exactly when each passes alone, and otherwise reverts with the
     *      first failing parameter's own error, relabeled to its batch
     *      position
     */
    function check_batchIsItsPartsInOrder(Operand[3] memory ops) public {
        RawParam[3] memory params;
        for (uint256 k; k < 3; k++) {
            params[k] = param(ops[k]);
        }
        (bool ok, bytes memory out) = address(core).call(batchCall(params));

        bytes memory expected;
        bool allPass = true;
        for (uint256 k; k < 3; k++) {
            (bool one, bytes memory reason) =
                address(core).call(abi.encodeWithSignature(string.concat("assertParam(", PARAM, ")"), params[k]));
            if (!one) {
                allPass = false;
                expected = relabel(reason, k < 2 ? 0 : 1, k < 2 ? k : 0);
                break;
            }
        }
        assertEq(ok, allPass, "the batch verdict is not the conjunction of its parameters");
        if (!ok) assertEq(out, expected, "the batch does not report its first failing parameter");
    }

    /**
     * @dev The same batches against the pinned Biconomy runtime: equal
     *      verdicts on canonical encodings, and never accepting what the
     *      reference rejects
     */
    function check_batchMatchesReference(Operand[3] memory ops) public {
        RawParam[3] memory params;
        bool canonical = true;
        for (uint256 k; k < 3; k++) {
            params[k] = param(ops[k]);
            canonical = canonical && ops[k].caseId < 3;
        }
        (bool ours,) = address(core).call(batchCall(params));
        (bool theirs,) = address(host).call(abi.encodeWithSelector(BatchReferenceHost.judge.selector, entries(params)));
        if (canonical) assertEq(ours, theirs, "batch verdicts differ on a canonical encoding");
        else if (ours) assertTrue(theirs, "Assertions accepts a batch Biconomy rejects");
    }

    // ============ Harness ============

    /**
     * @dev A CALL_DATA RAW_BYTES parameter holding one word, with one
     *      constraint: 0 EQ the word ref0 (passes or fails on the value), 1
     *      IN [ref0, ref1] (passes, fails, or InvalidConstraintRange when
     *      reversed), 2 SKIP (always passes), 3 EQ with a 33-byte reference
     *      (InvalidConstraintData), 4 the raw type 200 (the ABI decoder's
     *      bare revert). Cases 0 to 2 are canonical.
     */
    function param(Operand memory o) internal pure returns (RawParam memory p) {
        p.paramType = uint8(InputParamType.CALL_DATA);
        p.fetcherType = uint8(InputParamFetcherType.RAW_BYTES);
        p.paramData = abi.encode(o.value);
        p.constraints = new RawConstraint[](1);
        if (o.caseId == 0) {
            p.constraints[0] = RawConstraint(uint8(ConstraintType.EQ), abi.encode(o.ref0));
        } else if (o.caseId == 1) {
            p.constraints[0] = RawConstraint(uint8(ConstraintType.IN), abi.encode(o.ref0, o.ref1));
        } else if (o.caseId == 2) {
            p.constraints[0] = RawConstraint(SKIP, "");
        } else if (o.caseId == 3) {
            p.constraints[0] = RawConstraint(uint8(ConstraintType.EQ), abi.encodePacked(o.ref0, bytes1(0)));
        } else {
            vm.assume(o.caseId == 4);
            p.constraints[0] = RawConstraint(200, abi.encode(o.ref0));
        }
    }

    /**
     * @dev Entry 0 holds parameters 0 and 1, entry 1 holds parameter 2
     */
    function entries(RawParam[3] memory params) internal pure returns (RawExecution[] memory batch) {
        batch = new RawExecution[](2);
        batch[0].inputParams = new RawParam[](2);
        batch[0].inputParams[0] = params[0];
        batch[0].inputParams[1] = params[1];
        batch[1].inputParams = new RawParam[](1);
        batch[1].inputParams[0] = params[2];
    }

    function batchCall(RawParam[3] memory params) internal pure returns (bytes memory) {
        return abi.encodeWithSignature(
            string.concat("assertBatch((bytes4,", PARAM, "[],(uint8,bytes)[])[])"), entries(params)
        );
    }

    /**
     * @dev assertParam's revert data as assertBatch reports it at (entry,
     *      param): ConstraintFailed carries "COMPOSABLE" and the position,
     *      the malformed-constraint errors carry the position in their first
     *      two words, and anything else (the ABI decoder's bare revert) is
     *      identical
     */
    function relabel(bytes memory reason, uint256 entry, uint256 index) internal pure returns (bytes memory) {
        if (reason.length < 4) return reason;
        bytes4 selector = bytes4(reason);
        if (selector == ConstraintFailed.selector) {
            (,,, uint256 constraintIndex, ConstraintType kind, bytes32 actual, bytes memory ref) =
                abi.decode(slice(reason, 4), (string, uint256, uint256, uint256, ConstraintType, bytes32, bytes));
            return abi.encodeWithSelector(
                ConstraintFailed.selector, "COMPOSABLE", entry, index, constraintIndex, kind, actual, ref
            );
        }
        if (
            selector == InvalidConstraintData.selector || selector == InvalidOrConstraint.selector
                || selector == InvalidConstraintRange.selector
        ) {
            bytes memory out = bytes.concat(reason);
            assembly ("memory-safe") {
                mstore(add(out, 36), entry)
                mstore(add(out, 68), index)
            }
            return out;
        }
        return reason;
    }

    function slice(bytes memory b, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(b.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = b[from + i];
        }
    }
}
