// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import "./SignedModSpec.t.sol";

contract Concrete is SignedModSpec {
    function testFuzz_addZeroModulus(int256 a, int256 b) public view {
        prove_addZeroModulus(a, b);
    }

    function testFuzz_mulZeroModulus(int256 a, int256 b) public view {
        prove_mulZeroModulus(a, b);
    }

    function testFuzz_addReference(int256 a, int256 b, int256 m) public view {
        prove_addReference(a, b, m);
    }

    function testFuzz_mulReference(int256 a, int256 b, int256 m) public view {
        prove_mulReference(a, b, m);
    }

    function test_fullWidthWitnesses() public view {
        prove_addReference(type(int256).min, type(int256).min, 7);
        prove_mulReference(type(int256).min, type(int256).min, 7);
        prove_addReference(type(int256).max, type(int256).min, -7);
        prove_mulReference(type(int256).min, -1, type(int256).min);
    }
}
