// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";
import {AbiCodec} from "../../../contracts/lib/AbiCodec.sol";

interface VmCache {
    function expectCall(address target, bytes calldata data, uint64 count) external;
}

contract CacheTarget {
    function value() external pure returns (uint256) {
        return 300;
    }

    function marker() external pure {
        assembly {
            mstore(0, shl(224, 0xd271060e))
            revert(0, 4)
        }
    }
}

contract CacheOracleTest {
    Expressions private evaluator = new Expressions();
    CacheTarget private target = new CacheTarget();
    VmCache private vm = VmCache(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct Pair {
        uint256 first;
        uint256 second;
    }

    function graph(uint256 size) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](size);
        p.result = size - 1;
        for (uint256 i; i < size; i++) {
            p.nodes[i].kind = Expressions.Kind.Literal;
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(uint256(7));
            p.nodes[i].refs = new uint256[](0);
        }
    }

    function refs(uint256 a, uint256 b) private pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[0] = a;
        r[1] = b;
    }

    function one(uint256 a) private pure returns (uint256[] memory r) {
        r = new uint256[](1);
        r[0] = a;
    }

    function base(uint256 size) private view returns (Expressions.Expression memory p) {
        p = graph(size);
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(address(target));
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].refs = one(0);
        p.nodes[1].selector = target.value.selector;
        p.nodes[1].arguments = "()";
    }

    function tuple(Expressions.Expression memory p, uint256 index, uint256 a, uint256 b, string memory types)
        private
        pure
    {
        p.nodes[index].kind = Expressions.Kind.Tuple;
        p.nodes[index].refs = refs(a, b);
        p.nodes[index].arguments = types;
        p.nodes[index].valueType = types;
    }

    function check(Expressions.Expression memory p, bool success, bytes memory expected) private view {
        (bool ok, bytes memory actual) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok == success, "wrong verdict");
        require(keccak256(actual) == keccak256(expected), "wrong exact bytes");
    }

    function testCacheHitUsesRequestedIndex() public view {
        Expressions.Expression memory p = graph(4);
        p.nodes[1].data = abi.encode(uint256(9));
        tuple(p, 2, 0, 1, "(uint256,uint256)");
        tuple(p, 3, 2, 1, "((uint256,uint256),uint256)");
        check(p, true, abi.encode(Pair(7, 9), uint256(9)));
    }

    function testSuccessfulAttemptMergesCache() public {
        Expressions.Expression memory p = base(5);
        p.nodes[3].kind = Expressions.Kind.TryOrElse;
        p.nodes[3].refs = refs(1, 2);
        tuple(p, 4, 3, 1, "(uint256,uint256)");
        vm.expectCall(address(target), abi.encodeCall(target.value, ()), uint64(1));
        check(p, true, abi.encode(uint256(300), uint256(300)));
    }

    function testGuardFailureDiscardsCache() public {
        Expressions.Expression memory p = base(6);
        p.nodes[3].kind = Expressions.Kind.Tuple;
        p.nodes[3].refs = one(1);
        p.nodes[3].arguments = "(uint256)";
        p.nodes[3].valueType = "(uint8)";
        p.nodes[4].kind = Expressions.Kind.TryOrElse;
        p.nodes[4].refs = refs(3, 2);
        tuple(p, 5, 4, 1, "(uint256,uint256)");
        vm.expectCall(address(target), abi.encodeCall(target.value, ()), uint64(2));
        check(p, true, abi.encode(uint256(7), uint256(300)));
    }

    function testInvalidValueCannotBecomeSuccessfulCacheEntry() public view {
        Expressions.Expression memory p = graph(1);
        p.nodes[0].valueType = "uint8";
        p.nodes[0].data = abi.encode(uint256(256));
        check(p, false, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0)));
    }

    function testExternalCacheInjectionRejectedFirst() public view {
        Expressions.Expression memory p = graph(1);
        Expressions.Cache memory cache =
            Expressions.Cache(new bytes[](0), new bool[](0), new bool[](0), new uint256[](0));
        (bool ok, bytes memory actual) = address(evaluator)
            .staticcall(abi.encodeCall(evaluator.evaluateGuarded, (p, new bytes[](0), uint256(99), cache)));
        require(!ok, "external cache accepted");
        require(
            keccak256(actual) == keccak256(abi.encodeWithSelector(Expressions.NotSelf.selector, address(this))),
            "wrong authentication error"
        );
    }

    function testExhaustionMarkerIsNotFallback() public view {
        Expressions.Expression memory p = base(4);
        p.nodes[1].selector = target.marker.selector;
        p.nodes[3].kind = Expressions.Kind.TryOrElse;
        p.nodes[3].refs = refs(1, 2);
        check(p, false, abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector));
    }
}
