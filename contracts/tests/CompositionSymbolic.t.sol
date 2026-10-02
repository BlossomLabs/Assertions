// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties for the seams between contracts: an Expressions
 *         Resolve node enforces its operand's constraints exactly as the core
 *         does, and a Collections predicate applied through an expression
 *         callback holds the result to the same canonical 0/1 rule as a direct
 *         one. Run with `pnpm halmos`.
 * @dev The oracle for each seam is the other side called directly: the core's
 *      own resolve, and the predicate rule on the value the expression
 *      returns. Halmos has no gas model, so once the core and Expressions
 *      guard failed subcalls against out-of-gas, their guard can fire on any
 *      failing path Halmos explores; those paths are discarded (see
 *      outOfGasArtifact).
 */
contract CompositionSymbolicTest is Test {
    Assertions core;
    Collections collections;
    Expressions expressions;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        expressions = new Expressions();
    }

    // ============ Resolve nodes ============

    /**
     * @dev A Resolve node over an operand with an EQ constraint evaluates
     *      exactly when the constraint holds, to the operand's value, and
     *      otherwise fails with the core's own resolve revert wrapped in
     *      NodeCallFailed at that node
     */
    function check_resolveNodeEnforcesConstraints(uint256 value, uint256 ref) public view {
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(ref));
        InputParam memory source =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(value), cs);
        (bool coreOk, bytes memory coreOut) = address(core).staticcall(abi.encodeCall(Assertions.resolve, (source)));
        vm.assume(!outOfGasArtifact(coreOk, coreOut));

        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] =
            Expressions.Node(Expressions.Kind.Resolve, "uint256", abi.encode(source), new uint256[](0), bytes4(0), "");
        (bool ok, bytes memory out) = address(expressions)
            .staticcall(
                abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), nodes, 0), new bytes[](0)))
            );
        vm.assume(!outOfGasArtifact(ok, out));

        assertEq(ok, value == ref, "a Resolve node and its constraint disagree");
        assertEq(coreOk, ok, "a Resolve node and the core disagree");
        if (ok) {
            assertEq(out, abi.encode(value));
        } else {
            assertEq(
                out,
                abi.encodeWithSelector(
                    Expressions.NodeCallFailed.selector,
                    uint256(0),
                    address(core),
                    abi.encodeCall(Assertions.resolve, (source)),
                    coreOut
                ),
                "a Resolve node does not carry the core's own error"
            );
        }
    }

    // ============ Expression callbacks ============

    /**
     * @dev filterValues through an expression callback that returns its
     *      element as a uint256: 1 keeps the element, 0 drops it, and any
     *      other word is refused with InvalidCallbackResult, exactly the
     *      canonical 0/1 rule a direct predicate is held to
     */
    function check_expressionPredicateIsCanonical(uint256 x) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] = Expressions.Node(
            Expressions.Kind.Parameter, "uint256", abi.encode(uint256(0)), new uint256[](0), bytes4(0), ""
        );
        Collections.Callback memory cb;
        cb.target = address(expressions);
        cb.arguments = "(uint256)";
        cb.constants = new bytes[](1);
        cb.constants[0] = abi.encode(uint256(0));
        cb.expression = abi.encode(Expressions.Expression(address(core), nodes, 0));
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(x);

        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.filterValues, ("uint256", values, cb)));
        vm.assume(!outOfGasArtifact(ok, out));

        assertEq(ok, x <= 1, "an expression predicate escapes the 0/1 rule");
        if (ok) {
            bytes[] memory kept = abi.decode(out, (bytes[]));
            assertEq(kept.length, x);
            if (x == 1) assertEq(kept[0], values[0]);
        } else {
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    Collections.filterValues.selector,
                    uint256(0),
                    uint256(0),
                    address(expressions)
                )
            );
        }
    }

    // ============ Harness ============

    /**
     * @dev Halmos has no gas model: gasleft() is a fresh symbol, so an
     *      out-of-gas guard on failed subcalls (SubcallOutOfGas, selector
     *      0xd271060e) can fire on any failing path it explores. That outcome
     *      is discarded; concrete tests pin the guard at real gas values.
     *      The selector is matched literally so this suite also builds where
     *      the guard is not yet declared.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(bytes4(0xd271060e)));
    }
}
