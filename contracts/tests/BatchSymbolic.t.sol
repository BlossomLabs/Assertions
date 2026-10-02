// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";

/**
 * @dev Returns exactly the calldata it receives
 */
contract Returner {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            return(0, calldatasize())
        }
    }
}

/**
 * @dev A token whose balances are a fixed function of the account
 */
contract Token {
    function balanceOf(address account) external pure returns (uint256) {
        return uint256(keccak256(abi.encode(account)));
    }
}

/**
 * @dev Accepts exactly selector 0xAABBCCDD followed by two words a, b with
 *      a == b + 1: success therefore proves the selector prefix, the order
 *      of the CALL_DATA segments and the TARGET routing all at once
 */
contract Gate {
    fallback() external {
        require(msg.data.length == 68 && bytes4(msg.data[0:4]) == 0xAABBCCDD);
        (uint256 a, uint256 b) = abi.decode(msg.data[4:], (uint256, uint256));
        require(b != type(uint256).max && a == b + 1);
    }
}

/**
 * @notice Halmos properties for the fetchers and `assertBatch`: what each
 *         fetcher resolves to, how an entry constructs and executes its
 *         call, and which operand every error names. Run with `pnpm halmos`.
 * @dev Every call expected to succeed checks its success explicitly: Halmos
 *      discards reverting paths.
 */
contract BatchSymbolicTest is Test {
    Assertions core;
    Returner returner;
    Token token;
    Gate gate;

    function setUp() public {
        core = new Assertions();
        returner = new Returner();
        token = new Token();
        gate = new Gate();
    }

    // ============ Fetchers ============

    /**
     * @dev STATIC_CALL resolves to exactly the target's returndata
     */
    function check_staticCallResolvesToReturndata(uint8 lengthCase, bytes32[2] memory w) public view {
        vm.assume(lengthCase < 4);
        bytes memory data =
            truncate(abi.encodePacked(w), lengthCase == 0 ? 0 : lengthCase == 1 ? 5 : lengthCase == 2 ? 32 : 64);
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(
                    Assertions.resolve, (param(InputParamFetcherType.STATIC_CALL, abi.encode(address(returner), data)))
                )
            );
        assertTrue(ok, "a STATIC_CALL to a live target reverts");
        assertEq(out, data);
    }

    /**
     * @dev A code-less STATIC_CALL target reverts CallFailed(target, callData)
     */
    function check_staticCallToEmptyAccountFails(bytes32 w) public view {
        bytes memory data = abi.encode(w);
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(
                    Assertions.resolve, (param(InputParamFetcherType.STATIC_CALL, abi.encode(address(0xE0A), data)))
                )
            );
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(CallFailed.selector, address(0xE0A), data));
    }

    /**
     * @dev BALANCE: token 0 reads the native balance, any other token its
     *      balanceOf first word; a payload that is not 40 bytes reverts
     *      InvalidBalanceData with its length
     */
    function check_balanceFetcher(uint96 native, address account, uint8 which, uint8 lengthCase) public {
        vm.assume(which < 3 && lengthCase < 4);
        vm.assume(account != address(core) && account != address(this));
        vm.deal(account, native);
        bytes memory data;
        bytes memory expected;
        if (which == 0) {
            data = abi.encodePacked(address(0), account);
            expected = abi.encode(uint256(native));
        } else if (which == 1) {
            data = abi.encodePacked(address(token), account);
            expected = abi.encode(token.balanceOf(account));
        } else {
            uint256 length = lengthCase == 0 ? 0 : lengthCase == 1 ? 20 : lengthCase == 2 ? 39 : 41;
            data = truncate(abi.encodePacked(address(token), account, bytes1(0x01)), length);
            expected = abi.encodeWithSelector(InvalidBalanceData.selector, uint256(0), uint256(0), length);
        }
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.resolve, (param(InputParamFetcherType.BALANCE, data))));
        assertEq(ok, which < 2, "BALANCE verdict");
        assertEq(out, expected);
    }

    // ============ assertBatch ============

    /**
     * @dev An entry's call is selector ++ the CALL_DATA segments in order,
     *      sent to the TARGET, and must not revert: the batch passes exactly
     *      when the gate accepts, and the TARGET's position is irrelevant
     */
    function check_batchConstructsTheCall(uint256 a, uint256 b, uint8 targetPosition) public view {
        vm.assume(targetPosition < 3);
        InputParam[] memory params = new InputParam[](3);
        uint256 k;
        for (uint256 j; j < 3; j++) {
            if (j == targetPosition) {
                params[j] = param(InputParamFetcherType.RAW_BYTES, abi.encode(address(gate)));
                params[j].paramType = InputParamType.TARGET;
            } else {
                params[j] = param(InputParamFetcherType.RAW_BYTES, abi.encode(k == 0 ? a : b));
                k++;
            }
        }
        ComposableExecution[] memory batch = new ComposableExecution[](1);
        batch[0] = ComposableExecution(bytes4(0xAABBCCDD), params, new OutputParam[](0));
        (bool ok,) = address(core)
            .staticcall(
                abi.encodeWithSignature(
                    "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", batch
                )
            );
        assertEq(ok, b != type(uint256).max && a == b + 1, "the batch verdict is not the gate's");
    }

    /**
     * @dev A failing constraint names its entry, parameter and constraint
     */
    function check_batchErrorNamesTheOperand(bytes32 actual, bytes32 ref) public view {
        vm.assume(actual != ref);
        ComposableExecution[] memory batch = new ComposableExecution[](2);
        batch[0] = ComposableExecution(bytes4(0), new InputParam[](1), new OutputParam[](0));
        batch[0].inputParams[0] = param(InputParamFetcherType.RAW_BYTES, abi.encode(uint256(1)));
        batch[1] = ComposableExecution(bytes4(0), new InputParam[](2), new OutputParam[](0));
        batch[1].inputParams[0] = param(InputParamFetcherType.RAW_BYTES, abi.encode(uint256(2)));
        batch[1].inputParams[1] = param(InputParamFetcherType.RAW_BYTES, abi.encode(actual));
        batch[1].inputParams[1].constraints = new Constraint[](1);
        batch[1].inputParams[1].constraints[0] = Constraint(ConstraintType.EQ, abi.encode(ref));
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeWithSignature(
                    "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", batch
                )
            );
        assertFalse(ok, "a violated constraint passes");
        assertEq(
            out,
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "COMPOSABLE",
                uint256(1),
                uint256(1),
                uint256(0),
                ConstraintType.EQ,
                actual,
                abi.encode(ref)
            )
        );
    }

    /**
     * @dev The structural refusals, each naming its entry and parameter
     */
    function check_batchStructuralRefusals(uint8 caseId) public view {
        vm.assume(caseId < 4);
        ComposableExecution[] memory batch = new ComposableExecution[](2);
        batch[0] = ComposableExecution(bytes4(0), new InputParam[](0), new OutputParam[](0));
        batch[1] = ComposableExecution(bytes4(0), new InputParam[](2), new OutputParam[](0));
        batch[1].inputParams[0] = param(InputParamFetcherType.RAW_BYTES, abi.encode(address(gate)));
        batch[1].inputParams[1] = param(InputParamFetcherType.RAW_BYTES, abi.encode(address(gate)));
        bytes memory want;
        if (caseId == 0) {
            batch[1].outputParams = new OutputParam[](1);
            want = abi.encodeWithSelector(Assertions.OutputParamsNotSupported.selector, uint256(1));
        } else if (caseId == 1) {
            batch[1].inputParams[1].paramType = InputParamType.VALUE;
            want = abi.encodeWithSelector(Assertions.ValueParamNotSupported.selector, uint256(1), uint256(1));
        } else if (caseId == 2) {
            batch[1].inputParams[0].paramType = InputParamType.TARGET;
            batch[1].inputParams[1].paramType = InputParamType.TARGET;
            want = abi.encodeWithSelector(Assertions.DuplicateTargetParam.selector, uint256(1));
        } else {
            batch[1].inputParams[1].paramType = InputParamType.TARGET;
            batch[1].inputParams[1].fetcherType = InputParamFetcherType.BALANCE;
            want = abi.encodeWithSelector(Assertions.BalanceCannotBeTarget.selector, uint256(1), uint256(1));
        }
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeWithSignature(
                    "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", batch
                )
            );
        assertFalse(ok, "a structural refusal passes");
        assertEq(out, want);
    }

    // ============ Harness ============

    function param(InputParamFetcherType fetcher, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, fetcher, data, new Constraint[](0));
    }

    function truncate(bytes memory data, uint256 length) internal pure returns (bytes memory out) {
        out = data;
        assembly ("memory-safe") { mstore(out, length) }
    }
}
