// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import "./OperationsRuntime.sol";

interface VmSignedMod {
    function etch(address target, bytes calldata code) external;
}

// Runs the exact Hardhat runtime. Gas is abstracted; no gas claim is made.
contract SignedModSpec {
    VmSignedMod constant vm = VmSignedMod(address(uint160(uint256(keccak256("hevm cheat code")))));
    address constant TARGET = address(0x10000);

    function setUp() public {
        vm.etch(TARGET, OperationsRuntime.code());
    }

    function prove_addZeroModulus(int256 a, int256 b) public view {
        (bool ok, bytes memory data) =
            TARGET.staticcall(abi.encodeWithSignature("addMod(int256,int256,int256)", a, b, int256(0)));
        assert(!ok);
        assert(data.length == 36);
        bytes4 selector;
        uint256 code;
        assembly {
            selector := mload(add(data, 32))
            code := mload(add(data, 36))
        }
        assert(selector == 0x4e487b71 && code == 0x12);
    }

    function prove_mulZeroModulus(int256 a, int256 b) public view {
        (bool ok, bytes memory data) =
            TARGET.staticcall(abi.encodeWithSignature("mulMod(int256,int256,int256)", a, b, int256(0)));
        assert(!ok);
        assert(data.length == 36);
        bytes4 selector;
        uint256 code;
        assembly {
            selector := mload(add(data, 32))
            code := mload(add(data, 36))
        }
        assert(selector == 0x4e487b71 && code == 0x12);
    }

    function prove_addReference(int256 a, int256 b, int256 m) public view {
        if (m == 0) return; // Covered by prove_addZeroModulus.
        uint256 x;
        uint256 y;
        uint256 d;
        int256 expected;
        assembly {
            x := a
            if slt(a, 0) { x := sub(0, a) }
            y := b
            if slt(b, 0) { y := sub(0, b) }
            d := m
            if slt(m, 0) { d := sub(0, m) }
            switch eq(slt(a, 0), slt(b, 0))
            case 1 {
                expected := addmod(x, y, d)
                if slt(a, 0) { expected := sub(0, expected) }
            }
            default {
                switch lt(x, y)
                case 0 {
                    expected := mod(sub(x, y), d)
                    if slt(a, 0) { expected := sub(0, expected) }
                }
                default {
                    expected := mod(sub(y, x), d)
                    if slt(b, 0) { expected := sub(0, expected) }
                }
            }
        }
        (bool ok, bytes memory data) =
            TARGET.staticcall(abi.encodeWithSignature("addMod(int256,int256,int256)", a, b, m));
        assert(ok);
        assert(data.length == 32);
        assert(abi.decode(data, (int256)) == expected);
    }

    function prove_mulReference(int256 a, int256 b, int256 m) public view {
        if (m == 0) return; // The two zero-modulus properties cover this case.
        uint256 x;
        uint256 y;
        uint256 d;
        int256 expected;
        // EVM subtraction computes absolute values without Solidity's checked
        // signed negation, including int256.min. MULMOD has full-width product.
        assembly {
            x := a
            if slt(a, 0) { x := sub(0, a) }
            y := b
            if slt(b, 0) { y := sub(0, b) }
            d := m
            if slt(m, 0) { d := sub(0, m) }
            expected := mulmod(x, y, d)
            if xor(slt(a, 0), slt(b, 0)) { expected := sub(0, expected) }
        }
        (bool ok, bytes memory data) =
            TARGET.staticcall(abi.encodeWithSignature("mulMod(int256,int256,int256)", a, b, m));
        assert(ok);
        assert(data.length == 32);
        assert(abi.decode(data, (int256)) == expected);
    }
}
