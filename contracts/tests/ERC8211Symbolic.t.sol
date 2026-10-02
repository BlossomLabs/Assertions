// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "./ERC8211ReferenceHarness.sol";
import "./BiconomyERC8211Runtime.sol";

/**
 * @notice Halmos properties: Assertions judges ERC-8211 predicate constraints
 *         exactly as the pinned deployed Biconomy runtime does. Run with
 *         `pnpm halmos`.
 * @dev The oracle is Biconomy's bytecode, not a re-implementation. Constraint
 *      types travel as raw uint8 through mirror structs of the same ABI shape,
 *      so the invalid enum values 9..255 are explored too. One difference is
 *      deliberate (see erc8211-differential.test.ts): Assertions requires range
 *      references of exactly 64 bytes where Biconomy tolerates trailing bytes.
 *      So on canonical encodings the two must agree, and on every encoding
 *      Assertions may only be stricter: it never accepts what Biconomy rejects.
 */
contract ERC8211SymbolicTest is Test {
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

    uint8 constant OR = 6;
    uint8 constant SKIP = 7;

    Assertions core;
    ERC8211ReferenceHarness host;

    function setUp() public {
        vm.etch(BICONOMY_ERC8211, BICONOMY_ERC8211_RUNTIME);
        core = new Assertions();
        host = new ERC8211ReferenceHarness();
    }

    function test_inlinedRuntimeMatchesPinnedFixture() public pure {
        assertEq(keccak256(BICONOMY_ERC8211_RUNTIME), BICONOMY_ERC8211_RUNTIME_HASH);
    }

    function test_referenceRunsUnderFoundry() public {
        (bool ours, bool theirs) = judge(abi.encode(uint256(42)), one(0, abi.encode(uint256(42))));
        assertTrue(ours && theirs);
        (ours, theirs) = judge(abi.encode(uint256(42)), one(0, abi.encode(uint256(41))));
        assertFalse(ours || theirs);
    }

    // ============ Properties ============

    /**
     * @dev One constraint with a one-word reference: canonical for EQ, GTE,
     *      LTE, GTE_SIGNED and LTE_SIGNED
     */
    function check_wordReference(uint256 value, uint8 constraintType, uint256 ref) public {
        // As an OR payload a symbolic word is an ABI offset Halmos cannot follow;
        // OR has its own properties with a concrete structure.
        vm.assume(constraintType != OR);
        (bool ours, bool theirs) = judge(abi.encode(value), one(constraintType, abi.encode(ref)));
        agree(ours, theirs, isLeaf(constraintType));
    }

    /**
     * @dev One constraint over every reference length: empty, short and long
     *      of a word, one to three words. Canonical is a word for the leaves,
     *      two words for IN and IN_SIGNED, empty for SKIP.
     */
    function check_referenceLengths(uint256 value, uint8 constraintType, uint8 lengthCase, bytes32 a, bytes32 b, bytes32 c)
        public
    {
        uint256 length = pick(lengthCase, [uint256(0), 31, 32, 33, 64, 96]);
        vm.assume(constraintType != OR || length == 0);
        bytes memory ref = truncate(abi.encodePacked(a, b, c), length);
        (bool ours, bool theirs) = judge(abi.encode(value), one(constraintType, ref));
        bool canonical = (isLeaf(constraintType) && length == 32) || (isRange(constraintType) && length == 64)
            || (constraintType == SKIP && length == 0);
        agree(ours, theirs, canonical);
    }

    /**
     * @dev OR over zero to three one-word branches of any non-OR type: true
     *      when some branch holds, and an empty OR or a malformed branch
     *      rejects whatever the others say
     */
    function check_orOfWordBranches(uint256 value, uint8 count, uint8[3] memory types, uint256[3] memory refs)
        public
    {
        uint256 n = pick(count, [uint256(0), 1, 2, 3, 3, 3]);
        RawConstraint[] memory branches = new RawConstraint[](n);
        bool canonical = n > 0;
        for (uint256 i; i < n; i++) {
            vm.assume(types[i] != OR);
            branches[i] = RawConstraint(types[i], abi.encode(refs[i]));
            if (!isLeaf(types[i])) canonical = false;
        }
        (bool ours, bool theirs) = judge(abi.encode(value), one(OR, abi.encode(branches)));
        agree(ours, theirs, canonical);
    }

    /** @dev OR mixing a range branch, a SKIP and a word branch */
    function check_orWithRangeAndSkip(uint256 value, uint8 rangeType, uint256 lo, uint256 hi, uint8 t, uint256 ref)
        public
    {
        vm.assume(isRange(rangeType) && t != OR);
        RawConstraint[] memory branches = new RawConstraint[](3);
        branches[0] = RawConstraint(rangeType, abi.encode(lo, hi));
        branches[1] = RawConstraint(t, abi.encode(ref));
        branches[2] = RawConstraint(SKIP, "");
        (bool ours, bool theirs) = judge(abi.encode(value), one(OR, abi.encode(branches)));
        agree(ours, theirs, isLeaf(t));
    }

    /** @dev A nested OR is rejected wherever it sits, even after a true branch */
    function check_nestedOrRejected(uint256 value, uint8 t, uint256 ref, bool nestedFirst) public {
        vm.assume(t != OR);
        RawConstraint[] memory inner = one(t, abi.encode(ref));
        RawConstraint[] memory branches = new RawConstraint[](2);
        branches[nestedFirst ? 0 : 1] = RawConstraint(OR, abi.encode(inner));
        branches[nestedFirst ? 1 : 0] = RawConstraint(SKIP, "");
        (bool ours, bool theirs) = judge(abi.encode(value), one(OR, abi.encode(branches)));
        assertFalse(ours, "Assertions accepts a nested OR");
        assertEq(ours, theirs, "verdicts differ on a nested OR");
    }

    /** @dev Constraint i judges word i */
    function check_positionalWords(uint256 v0, uint256 v1, uint8 t0, uint256 r0, uint8 t1, uint256 r1) public {
        vm.assume(t0 != OR && t1 != OR);
        RawConstraint[] memory cs = new RawConstraint[](2);
        cs[0] = RawConstraint(t0, abi.encode(r0));
        cs[1] = RawConstraint(t1, abi.encode(r1));
        (bool ours, bool theirs) = judge(abi.encode(v0, v1), cs);
        agree(ours, theirs, isLeaf(t0) && isLeaf(t1));
    }

    /** @dev Every constraint needs its complete word, SKIP included */
    function check_paramLengths(uint8 lengthCase, bytes32 w0, bytes32 w1, uint8 t, uint256 ref, bool skipSecond)
        public
    {
        vm.assume(t != OR);
        uint256 length = pick(lengthCase, [uint256(0), 1, 31, 32, 33, 63]);
        RawConstraint[] memory cs = new RawConstraint[](skipSecond ? 2 : 1);
        cs[0] = RawConstraint(t, abi.encode(ref));
        if (skipSecond) cs[1] = RawConstraint(SKIP, "");
        (bool ours, bool theirs) = judge(truncate(abi.encodePacked(w0, w1), length), cs);
        agree(ours, theirs, isLeaf(t));
    }

    // ============ Harness ============

    /** @dev A concrete candidate per path: returning `c` itself would stay symbolic */
    function pick(uint8 c, uint256[6] memory candidates) internal pure returns (uint256) {
        if (c == 0) return candidates[0];
        if (c == 1) return candidates[1];
        if (c == 2) return candidates[2];
        if (c == 3) return candidates[3];
        if (c == 4) return candidates[4];
        return candidates[5];
    }

    function truncate(bytes memory data, uint256 length) internal pure returns (bytes memory out) {
        out = data;
        assembly ("memory-safe") { mstore(out, length) }
    }

    function isLeaf(uint8 constraintType) internal pure returns (bool) {
        return constraintType <= 2 || constraintType == 4 || constraintType == 5;
    }

    function isRange(uint8 constraintType) internal pure returns (bool) {
        return constraintType == 3 || constraintType == 8;
    }

    /**
     * @dev Equal verdicts on a canonical encoding; otherwise Assertions may
     *      only reject more. Both are explicit failures because Halmos
     *      discards reverting paths.
     */
    function agree(bool ours, bool theirs, bool canonical) internal pure {
        if (canonical) assertEq(ours, theirs, "verdicts differ on a canonical encoding");
        else if (ours) assertTrue(theirs, "Assertions accepts what Biconomy rejects");
    }

    function one(uint8 constraintType, bytes memory referenceData) internal pure returns (RawConstraint[] memory cs) {
        cs = new RawConstraint[](1);
        cs[0] = RawConstraint(constraintType, referenceData);
    }

    /** @dev Both verdicts on a RAW_BYTES CALL_DATA parameter */
    function judge(bytes memory paramData, RawConstraint[] memory constraints) internal returns (bool ours, bool theirs) {
        RawParam memory p = RawParam(uint8(InputParamType.CALL_DATA), uint8(InputParamFetcherType.RAW_BYTES), paramData, constraints);
        bytes memory args = abi.encode(p);
        (ours,) = address(core).call(bytes.concat(bytes4(keccak256("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))")), args));
        (theirs,) = address(host).call(bytes.concat(ERC8211ReferenceHarness.judge.selector, args));
    }
}
