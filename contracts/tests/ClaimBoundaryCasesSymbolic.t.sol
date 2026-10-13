// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import {OutputParam} from "../lib/ERC8211.sol";

contract ClaimBoundaryTarget {
    Vm constant VM = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    fallback() external {
        VM.warp(block.timestamp + 1);
    }

    function count() external view returns (uint256) {
        return block.timestamp - 1000;
    }
}

/**
 * @notice C6/C28/W19/L31 boundary obligations. A test-only code-bearing zero
 *         address makes an incorrect call observable instead of a silent noop.
 */
contract ClaimBoundaryCasesSymbolicTest is Test {
    Assertions core;
    Collections collections;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        vm.etch(address(0), address(new ClaimBoundaryTarget()).code);
    }

    function check_edgesZeroTargetSkipsCall(bytes32 a, bytes32 b, uint8 position, bool message) public {
        vm.assume(position < 3);
        uint256 p = position == 0 ? 0 : position == 1 ? 1 : 2;
        vm.warp(1000);
        ComposableExecution[] memory entries = new ComposableExecution[](1);
        entries[0].functionSig = 0xcafef00d;
        entries[0].inputParams = new InputParam[](3);
        entries[0].outputParams = new OutputParam[](0);
        for (uint256 i; i < 3; i++) {
            entries[0].inputParams[i] = raw(abi.encode(i == p ? bytes32(0) : i == 0 ? a : b));
            if (i == p) entries[0].inputParams[i].paramType = InputParamType.TARGET;
        }
        bytes memory data = message
            ? abi.encodeWithSignature(
                "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[],string)", entries, "edge"
            )
            : abi.encodeWithSignature(
                "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", entries
            );
        (bool ok, bytes memory out) = address(core).staticcall(data);
        assertTrue(ok);
        assertEq(out, bytes(""));
        assertEq(ClaimBoundaryTarget(address(0)).count(), 0, "zero target must not execute even if it has code");
    }

    function check_edgesEmptyNavigation(bytes32[3] memory words, bytes32 descriptor, uint8 size) public view {
        vm.assume(size < 7);
        uint256 n =
            size == 0 ? 0 : size == 1 ? 1 : size == 2 ? 31 : size == 3 ? 32 : size == 4 ? 33 : size == 5 ? 64 : 65;
        bytes memory data = new bytes(n);
        bytes memory source = abi.encodePacked(words);
        for (uint256 i; i < n; i++) {
            data[i] = source[i];
        }
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(Assertions.nav, (raw(data), string(abi.encodePacked(descriptor)), new int256[](0)))
            );
        assertTrue(ok, "empty path must not parse descriptor");
        assertEq(out, data);
    }

    function check_edgesEmptyOrContext(bytes32 a, bytes32 b, bool late) public view {
        InputParam memory p = raw(abi.encode(a, b));
        p.constraints = new Constraint[](late ? 2 : 1);
        if (late) p.constraints[0] = Constraint(ConstraintType.SKIP, "");
        p.constraints[late ? 1 : 0] = Constraint(ConstraintType.OR, abi.encode(new Constraint[](0)));
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
        assertFalse(ok);
        assertEq(
            out,
            abi.encodeWithSelector(InvalidOrConstraint.selector, uint256(0), uint256(0), late ? uint256(1) : uint256(0))
        );
    }

    function check_edgesInvalidFoldExit(uint256 mode, uint8 route) public view {
        vm.assume(mode > 2 && route < 3);
        uint256[] memory slots = new uint256[](1);
        slots[0] = 4;
        bytes memory data = route == 0
            ? abi.encodeWithSelector(
                Collections.foldRange.selector,
                uint256(1),
                address(0),
                abi.encode(uint256(0), uint256(0)),
                uint256(36),
                slots,
                bytes32(uint256(9)),
                mode
            )
            : abi.encodeWithSelector(
                route == 1 ? Collections.foldBytes.selector : Collections.foldWords.selector,
                route == 1 ? bytes(hex"07") : abi.encode(uint256(7)),
                address(0),
                abi.encode(uint256(0), uint256(0)),
                uint256(36),
                slots,
                bytes32(uint256(9)),
                mode
            );
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertFalse(ok);
        assertEq(out, bytes(""));
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function test_edgesZeroTargetSamples() public {
        for (uint8 i; i < 3; i++) {
            check_edgesZeroTargetSkipsCall(bytes32(uint256(7)), bytes32(uint256(93)), i, false);
            check_edgesZeroTargetSkipsCall(bytes32(uint256(7)), bytes32(uint256(93)), i, true);
        }
    }

    function test_edgesNavigationAndEnumSamples() public view {
        bytes32[3] memory words = [bytes32(uint256(7)), bytes32(uint256(93)), bytes32(uint256(81))];
        for (uint8 i; i < 7; i++) {
            check_edgesEmptyNavigation(words, bytes32(type(uint256).max), i);
        }
        check_edgesEmptyOrContext(words[0], words[1], false);
        check_edgesEmptyOrContext(words[0], words[1], true);
        for (uint8 i; i < 3; i++) {
            check_edgesInvalidFoldExit(3, i);
            check_edgesInvalidFoldExit(type(uint256).max, i);
        }
    }
}
