// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";

contract PairFailureTarget {
    struct Item {
        uint256 key;
        bytes32 value;
    }
    error PairFailure(bytes32 a, bytes32 b, bytes32 tag);

    function sortPair(Item calldata a, Item calldata b, bytes32 tag) external pure returns (int256) {
        if (a.key == 2 && b.key == 3) revert PairFailure(a.value, b.value, tag);
        return 0;
    }

    function uniquePair(Item calldata a, Item calldata b, bytes32 tag) external pure returns (bool) {
        if (a.key == 1 && b.key == 2) revert PairFailure(a.value, b.value, tag);
        return false;
    }
}

/**
 * @notice Halmos properties for callback error context in Collections: the
 *         accumulator window is bounds-checked before any call, even on an
 *         empty fold, and a failing BINARY callback (sort, unique) reports
 *         both operands' indices with the exact calldata and reason. Run with
 *         `pnpm halmos`.
 * @dev Errors are compared byte for byte. Halmos has no gas model, so the
 *      out-of-gas guard's SubcallOutOfGas can fire on the failing callback
 *      it explores; only that exact outcome is discarded, never an ordinary
 *      failure.
 */
contract CallbackContextSymbolicTest is Test {
    Collections collections;
    PairFailureTarget target;

    function setUp() public {
        collections = new Collections();
        target = new PairFailureTarget();
    }

    /**
     * @dev A symbolic accumulator offset over an empty fold with no target
     *      code: accepted exactly when a word fits at the offset, returning
     *      `init`, otherwise LambdaOffsetOutOfBounds(offset, length) with no
     *      call made; a 31-byte template is refused at every offset
     */
    function check_accumulatorWindow(uint256 offset, bytes32 init, bool shortTemplate) public view {
        bytes memory template = shortTemplate ? new bytes(31) : new bytes(68);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(
                abi.encodeCall(
                    Collections.fold,
                    (
                        Collections.FoldDomain.Words,
                        0,
                        bytes(""),
                        address(0),
                        template,
                        offset,
                        new uint256[](0),
                        init,
                        Collections.FoldExit.Full
                    )
                )
            );
        bool valid = !shortTemplate && offset <= 36;
        assertEq(ok, valid);
        if (valid) {
            assertEq(out, abi.encode(init));
        } else {
            assertEq(out, abi.encodeWithSelector(Collections.LambdaOffsetOutOfBounds.selector, offset, template.length));
        }
    }

    /**
     * @dev Fixed keys make a later pair fail (2 and 3 under sort, 1 and 2
     *      under unique) while every value and reason word stays symbolic:
     *      CallbackFailed names the operation, index 2, the other operand's
     *      index, the target, the calldata sent and the reason verbatim
     */
    function check_binaryCallbackContext(bytes32[4] memory w, bytes32 tag, bool sorting) public view {
        bytes[] memory values = new bytes[](sorting ? 4 : 3);
        for (uint256 i; i < values.length; i++) {
            values[i] = abi.encode(PairFailureTarget.Item(i, w[i]));
        }
        Collections.Callback memory cb;
        cb.target = address(target);
        cb.selector = sorting ? PairFailureTarget.sortPair.selector : PairFailureTarget.uniquePair.selector;
        cb.arguments = "((uint256,bytes32),(uint256,bytes32),bytes32)";
        cb.constants = new bytes[](3);
        cb.constants[2] = abi.encode(tag);
        cb.second = 1;
        bytes memory callData = sorting
            ? abi.encodeCall(Collections.sortValues, ("(uint256,bytes32)", values, cb))
            : abi.encodeCall(Collections.uniqueValues, ("(uint256,bytes32)", values, cb, false));
        (bool ok, bytes memory out) = address(collections).staticcall(callData);
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Collections.SubcallOutOfGas.selector)));
        assertFalse(ok);
        uint256 a = sorting ? 2 : 1;
        uint256 b = sorting ? 3 : 2;
        bytes memory sent =
            abi.encodeWithSelector(cb.selector, PairFailureTarget.Item(a, w[a]), PairFailureTarget.Item(b, w[b]), tag);
        bytes memory reason = abi.encodeWithSelector(PairFailureTarget.PairFailure.selector, w[a], w[b], tag);
        assertEq(
            out,
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                sorting ? Collections.sortValues.selector : Collections.uniqueValues.selector,
                uint256(2),
                sorting ? uint256(3) : uint256(1),
                address(target),
                sent,
                reason
            )
        );
    }

    /**
     * @dev Every case on a real EVM
     */
    function test_callbackGeometries() public view {
        check_accumulatorWindow(0, bytes32("a"), false);
        check_accumulatorWindow(36, bytes32("a"), false);
        check_accumulatorWindow(37, bytes32("a"), false);
        check_accumulatorWindow(type(uint256).max, bytes32("a"), false);
        check_accumulatorWindow(0, bytes32("a"), true);
        bytes32[4] memory w = [bytes32("a"), bytes32("b"), bytes32("c"), bytes32("d")];
        check_binaryCallbackContext(w, bytes32("tag"), false);
        check_binaryCallbackContext(w, bytes32("tag"), true);
    }
}
