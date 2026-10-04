// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import "../../contracts/Assertions.sol";
import "../../contracts/lib/ERC8211.sol";

/**
 * @notice Establishes how OpenZeppelin Governor (5.x) treats a failing
 *         Assertions call inside a proposal, with and without
 *         GovernorTimelockControl. Everything is deployed locally.
 */

contract VotesToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("Votes", "VOT") ERC20Permit("Votes") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}

contract PlainGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes {
    constructor(IVotes token) Governor("Plain") GovernorSettings(1, 10, 0) GovernorVotes(token) {}

    function quorum(uint256) public pure override returns (uint256) {
        return 1;
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }
}

contract TimelockedGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorTimelockControl
{
    constructor(IVotes token, TimelockController timelock)
        Governor("Timelocked")
        GovernorSettings(1, 10, 0)
        GovernorVotes(token)
        GovernorTimelockControl(timelock)
    {}

    function quorum(uint256) public pure override returns (uint256) {
        return 1;
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    function state(uint256 id) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(id);
    }

    function proposalNeedsQueuing(uint256 id) public view override(Governor, GovernorTimelockControl) returns (bool) {
        return super.proposalNeedsQueuing(id);
    }

    function _queueOperations(
        uint256 id,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(id, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 id,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(id, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}

contract CounterTarget {
    uint256 public counter;

    function set(uint256 value) external {
        counter = value;
    }
}

contract GovernorExecutionTest is Test {
    // The asserted word is 5. FAIL requires >= 10, PASS requires >= 3; the
    // two variants differ only in this threshold word.
    bytes4 internal constant ASSERT_PARAM = bytes4(keccak256("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))"));
    uint256 internal constant ACTUAL = 5;
    uint256 internal constant FAIL_REF = 10;
    uint256 internal constant PASS_REF = 3;

    Assertions internal assertions;
    CounterTarget internal target;
    VotesToken internal token;
    address internal voter = address(0xA11CE);

    function setUp() public {
        assertions = new Assertions();
        target = new CounterTarget();
        token = new VotesToken();
        token.mint(voter, 100e18);
        vm.prank(voter);
        token.delegate(voter);
        vm.roll(block.number + 1);
    }

    // ============ Helpers ============

    function _assertParamCall(uint256 threshold) internal view returns (bytes memory) {
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.GTE, abi.encode(threshold));
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(ACTUAL), cs);
        return abi.encodeWithSelector(ASSERT_PARAM, p);
    }

    struct Proposal {
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        string description;
        bytes32 descriptionHash;
    }

    function _proposal(bool assertionFirst, uint256 threshold, string memory description)
        internal
        view
        returns (Proposal memory p)
    {
        p.targets = new address[](2);
        p.values = new uint256[](2);
        p.calldatas = new bytes[](2);
        bytes memory set = abi.encodeCall(target.set, (1));
        bytes memory check = _assertParamCall(threshold);
        uint256 setAt = assertionFirst ? 1 : 0;
        p.targets[setAt] = address(target);
        p.calldatas[setAt] = set;
        p.targets[1 - setAt] = address(assertions);
        p.calldatas[1 - setAt] = check;
        p.description = description;
        p.descriptionHash = keccak256(bytes(description));
    }

    function _passVote(Governor gov, Proposal memory p) internal returns (uint256 id) {
        vm.prank(voter);
        id = gov.propose(p.targets, p.values, p.calldatas, p.description);
        vm.roll(block.number + gov.votingDelay() + 1);
        vm.prank(voter);
        gov.castVote(id, 1);
        vm.roll(block.number + gov.votingPeriod() + 1);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Succeeded), "vote passed");
    }

    function _expectConstraintFailed(bool ok, bytes memory ret) internal view {
        assertFalse(ok, "execute must revert");
        bytes4 sel;
        assembly {
            sel := mload(add(ret, 32))
        }
        assertEq(sel, ConstraintFailed.selector, "bubbled ConstraintFailed");
        bytes memory body = new bytes(ret.length - 4);
        for (uint256 i; i < body.length; ++i) {
            body[i] = ret[i + 4];
        }
        (
            string memory message,
            uint256 entryIndex,
            uint256 paramIndex,
            uint256 constraintIndex,
            ConstraintType kind,
            bytes32 actual,
            bytes memory referenceData
        ) = abi.decode(body, (string, uint256, uint256, uint256, ConstraintType, bytes32, bytes));
        assertEq(message, "PARAM");
        assertEq(entryIndex, 0);
        assertEq(paramIndex, 0);
        assertEq(constraintIndex, 0);
        assertEq(uint8(kind), uint8(ConstraintType.GTE));
        assertEq(actual, bytes32(ACTUAL));
        assertEq(abi.decode(referenceData, (uint256)), FAIL_REF);
    }

    // ============ Plain Governor ============

    function _plain() internal returns (PlainGovernor) {
        return new PlainGovernor(IVotes(address(token)));
    }

    function _executePlain(PlainGovernor gov, Proposal memory p) internal returns (bool ok, bytes memory ret) {
        (ok, ret) =
            address(gov).call(abi.encodeCall(Governor.execute, (p.targets, p.values, p.calldatas, p.descriptionHash)));
    }

    function test_plain_failingAssertionAfterCall_revertsAndKeepsCounterZero() public {
        PlainGovernor gov = _plain();
        Proposal memory p = _proposal(false, FAIL_REF, "set then assert (fail)");
        uint256 id = _passVote(gov, p);

        (bool ok, bytes memory ret) = _executePlain(gov, p);

        _expectConstraintFailed(ok, ret);
        assertEq(target.counter(), 0, "earlier action rolled back");
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Succeeded), "proposal not marked executed");
    }

    function test_plain_failingAssertionBeforeCall_revertsAndKeepsCounterZero() public {
        PlainGovernor gov = _plain();
        Proposal memory p = _proposal(true, FAIL_REF, "assert (fail) then set");
        uint256 id = _passVote(gov, p);

        (bool ok, bytes memory ret) = _executePlain(gov, p);

        _expectConstraintFailed(ok, ret);
        assertEq(target.counter(), 0);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Succeeded));
    }

    function test_plain_passingAssertionAfterCall_executes() public {
        PlainGovernor gov = _plain();
        Proposal memory p = _proposal(false, PASS_REF, "set then assert (pass)");
        uint256 id = _passVote(gov, p);

        (bool ok,) = _executePlain(gov, p);

        assertTrue(ok, "execute succeeds");
        assertEq(target.counter(), 1);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Executed));
    }

    function test_plain_passingAssertionBeforeCall_executes() public {
        PlainGovernor gov = _plain();
        Proposal memory p = _proposal(true, PASS_REF, "assert (pass) then set");
        uint256 id = _passVote(gov, p);

        (bool ok,) = _executePlain(gov, p);

        assertTrue(ok);
        assertEq(target.counter(), 1);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Executed));
    }

    // ============ Governor + TimelockController ============

    function _timelocked() internal returns (TimelockedGovernor gov, TimelockController timelock) {
        address[] memory none = new address[](0);
        address[] memory anyone = new address[](1); // address(0): anyone may execute
        timelock = new TimelockController(1, none, anyone, address(this));
        gov = new TimelockedGovernor(IVotes(address(token)), timelock);
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(gov));
    }

    function _queueAndWait(TimelockedGovernor gov, Proposal memory p) internal {
        gov.queue(p.targets, p.values, p.calldatas, p.descriptionHash);
        vm.warp(block.timestamp + 2);
    }

    function _executeTimelocked(TimelockedGovernor gov, Proposal memory p)
        internal
        returns (bool ok, bytes memory ret)
    {
        (ok, ret) = address(gov)
            .call(abi.encodeCall(Governor.execute, (p.targets, p.values, p.calldatas, p.descriptionHash)));
    }

    function test_timelock_failingAssertionAfterCall_revertsAndKeepsCounterZero() public {
        (TimelockedGovernor gov, TimelockController timelock) = _timelocked();
        Proposal memory p = _proposal(false, FAIL_REF, "tl set then assert (fail)");
        uint256 id = _passVote(gov, p);
        _queueAndWait(gov, p);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Queued));

        (bool ok, bytes memory ret) = _executeTimelocked(gov, p);

        _expectConstraintFailed(ok, ret);
        assertEq(target.counter(), 0, "earlier action rolled back");
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Queued), "still queued, not executed");
        bytes32 opId =
            timelock.hashOperationBatch(p.targets, p.values, p.calldatas, 0, bytes20(address(gov)) ^ p.descriptionHash);
        assertTrue(timelock.isOperationPending(opId), "timelock operation still pending");
        assertFalse(timelock.isOperationDone(opId));
    }

    function test_timelock_failingAssertionBeforeCall_revertsAndKeepsCounterZero() public {
        (TimelockedGovernor gov,) = _timelocked();
        Proposal memory p = _proposal(true, FAIL_REF, "tl assert (fail) then set");
        uint256 id = _passVote(gov, p);
        _queueAndWait(gov, p);

        (bool ok, bytes memory ret) = _executeTimelocked(gov, p);

        _expectConstraintFailed(ok, ret);
        assertEq(target.counter(), 0);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Queued));
    }

    function test_timelock_passingAssertionAfterCall_executes() public {
        (TimelockedGovernor gov,) = _timelocked();
        Proposal memory p = _proposal(false, PASS_REF, "tl set then assert (pass)");
        uint256 id = _passVote(gov, p);
        _queueAndWait(gov, p);

        (bool ok,) = _executeTimelocked(gov, p);

        assertTrue(ok);
        assertEq(target.counter(), 1);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Executed));
    }

    function test_timelock_passingAssertionBeforeCall_executes() public {
        (TimelockedGovernor gov,) = _timelocked();
        Proposal memory p = _proposal(true, PASS_REF, "tl assert (pass) then set");
        uint256 id = _passVote(gov, p);
        _queueAndWait(gov, p);

        (bool ok,) = _executeTimelocked(gov, p);

        assertTrue(ok);
        assertEq(target.counter(), 1);
        assertEq(uint8(gov.state(id)), uint8(IGovernor.ProposalState.Executed));
    }

    // The timelock executor can also be driven directly (executeBatch), which
    // is the path other timelock users take. Same verdict.
    function test_timelock_directExecuteBatch_failingAssertionRevertsWholeBatch() public {
        (TimelockedGovernor gov, TimelockController timelock) = _timelocked();
        Proposal memory p = _proposal(false, FAIL_REF, "tl direct batch (fail)");
        _passVote(gov, p);
        _queueAndWait(gov, p);

        bytes32 salt = bytes20(address(gov)) ^ p.descriptionHash;
        (bool ok, bytes memory ret) = address(timelock)
            .call(abi.encodeCall(TimelockController.executeBatch, (p.targets, p.values, p.calldatas, bytes32(0), salt)));

        _expectConstraintFailed(ok, ret);
        assertEq(target.counter(), 0);
    }
}
