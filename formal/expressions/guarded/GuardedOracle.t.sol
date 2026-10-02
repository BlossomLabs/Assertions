// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

interface VmGuarded {
    function prank(address caller) external;
}

contract GuardedOracleTest {
    Expressions private evaluator = new Expressions();
    VmGuarded private vm = VmGuarded(address(uint160(uint256(keccak256("hevm cheat code")))));

    function graph(uint256 n) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](n);
        for (uint256 i; i < n; i++) {
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(uint256(73));
        }
    }

    function cache(uint256 n) private pure returns (Expressions.Cache memory c) {
        c.values = new bytes[](n);
        c.ready = new bool[](n);
        c.dynamic = new bool[](n);
        c.words = new uint256[](n);
        for (uint256 i; i < n; i++) {
            c.words[i] = 1;
        }
    }

    function guarded(Expressions.Expression memory p, uint256 index, Expressions.Cache memory initial)
        private
        returns (bool ok, bytes memory result)
    {
        bytes memory data = abi.encodeCall(evaluator.evaluateGuarded, (p, new bytes[](0), index, initial));
        vm.prank(address(evaluator));
        return address(evaluator).staticcall(data);
    }

    function testForeignCallerBeforeCacheAccess() public view {
        Expressions.Expression memory p = graph(0);
        Expressions.Cache memory initial = cache(0);
        (bool ok, bytes memory reason) = address(evaluator)
            .staticcall(abi.encodeCall(evaluator.evaluateGuarded, (p, new bytes[](0), type(uint256).max, initial)));
        require(!ok, "foreign call accepted");
        require(
            keccak256(reason) == keccak256(abi.encodeWithSelector(Expressions.NotSelf.selector, address(this))),
            "exact denied caller"
        );
    }

    function testWarmCacheReturnTuple() public {
        Expressions.Expression memory p = graph(1);
        Expressions.Cache memory initial = cache(1);
        initial.ready[0] = true;
        initial.values[0] = abi.encode(uint256(7));
        (bool ok, bytes memory result) = guarded(p, 0, initial);
        require(ok, "warm call failed");
        require(keccak256(result) == keccak256(abi.encode(initial.values[0], initial)), "warm result/cache changed");
        (bytes memory value, Expressions.Cache memory updated) = abi.decode(result, (bytes, Expressions.Cache));
        require(
            keccak256(value) == keccak256(initial.values[0]) && updated.ready[0] && updated.words[0] == 1,
            "tuple decode"
        );
    }

    function testDynamicValueAndFourCacheArrays() public {
        Expressions.Expression memory p = graph(2);
        p.nodes[1].kind = Expressions.Kind.Wrap;
        p.nodes[1].valueType = "bytes";
        p.nodes[1].refs = new uint256[](1);
        Expressions.Cache memory initial = cache(2);
        initial.dynamic[1] = true;
        (bool ok, bytes memory result) = guarded(p, 1, initial);
        require(ok, "dynamic call failed");
        initial.ready[0] = true;
        initial.ready[1] = true;
        initial.values[0] = abi.encode(uint256(73));
        initial.values[1] = abi.encode(initial.values[0]);
        require(keccak256(result) == keccak256(abi.encode(initial.values[1], initial)), "exact four cache arrays");
    }

    function testValidationFailureHasNoSuccessTuple() public {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].valueType = "uint8";
        p.nodes[0].data = abi.encode(uint256(256));
        (bool ok, bytes memory result) = guarded(p, 0, cache(1));
        require(!ok, "invalid value accepted");
        require(
            keccak256(result) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))),
            "exact validation error"
        );
    }

    function testPublicTypedGuardSuccess() public view {
        Expressions.Expression memory p = graph(2);
        p.result = 1;
        p.nodes[1].kind = Expressions.Kind.TryOrElse;
        p.nodes[1].refs = new uint256[](2);
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok && keccak256(result) == keccak256(abi.encode(uint256(73))), "typed guard success");
    }

    function testPublicTypedGuardFallback() public view {
        Expressions.Expression memory p = graph(3);
        p.result = 2;
        p.nodes[0].valueType = "uint8";
        p.nodes[0].data = abi.encode(uint256(256));
        p.nodes[2].kind = Expressions.Kind.TryOrElse;
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok && keccak256(result) == keccak256(abi.encode(uint256(73))), "typed guard fallback");
    }
}
