// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../lib/ERC8211.sol";

/**
 * @notice The walkers behind packArray, unpackArray and nav never panic and
 *         never run out of gas on a descriptor with extreme fixed lengths:
 *         every failure carries a declared selector
 * @dev A concrete sweep rather than a Halmos property. A length the codec
 *      accepts is one the walkers iterate and copy, so a symbolic length
 *      there is either a symbolic copy size (NotConcreteError) or a loop
 *      past the unrolling bound; once the lengths are concrete a symbolic
 *      run only enumerates this grid, slower. Forge also models gas, which
 *      Halmos does not: each call gets a fixed budget, so running out of it
 *      shows up as empty revert data. NoPanicSymbolic covers the parser
 *      over symbolic digits.
 */
contract NoPanicTest is Test {
    bytes4 constant PANIC = 0x4e487b71;
    uint256 constant CALL_GAS = 10_000_000;
    string constant TAIL = "[4294967295][4294967295][4294967295][4294967295][4294967295][4294967295][4294967295]";

    Collections collections;
    Assertions core;

    function setUp() public {
        collections = new Collections();
        core = new Assertions();
    }

    function testPackNeverPanics() public view {
        bytes[] memory none = new bytes[](0);
        bytes[] memory one = new bytes[](1);
        one[0] = abi.encode(bytes32(uint256(1)), bytes32(uint256(2)));
        bytes[] memory empty = new bytes[](1);
        string[] memory ds = descriptors();
        for (uint256 i; i < ds.length; i++) {
            call(address(collections), abi.encodeCall(Collections.packArray, (ds[i], none)), ds[i]);
            call(address(collections), abi.encodeCall(Collections.packArray, (ds[i], one)), ds[i]);
            call(address(collections), abi.encodeCall(Collections.packArray, (ds[i], empty)), ds[i]);
        }
    }

    function testUnpackNeverPanics() public view {
        uint256[5] memory counts = [uint256(0), 1, 2, 1 << 40, type(uint256).max];
        string[] memory ds = descriptors();
        for (uint256 i; i < ds.length; i++) {
            for (uint256 j; j < counts.length; j++) {
                bytes memory encoded = abi.encode(uint256(32), counts[j], uint256(1), uint256(2));
                call(address(collections), abi.encodeCall(Collections.unpackArray, (ds[i], encoded)), ds[i]);
                encoded = abi.encode(uint256(32), counts[j]);
                call(address(collections), abi.encodeCall(Collections.unpackArray, (ds[i], encoded)), ds[i]);
            }
        }
    }

    function testNavNeverPanics() public view {
        int256[4] memory indices = [int256(0), 1, -1, type(int256).max];
        InputParam memory p = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.RAW_BYTES,
            abi.encode(uint256(32), uint256(2), uint256(3), uint256(4)),
            new Constraint[](0)
        );
        string[] memory ds = descriptors();
        for (uint256 i; i < ds.length; i++) {
            string memory types = string.concat("(", ds[i], ")");
            for (uint256 j; j < indices.length; j++) {
                int256[] memory path = new int256[](2);
                path[1] = indices[j];
                call(address(core), abi.encodeCall(Assertions.nav, (p, types, path)), types);
                path = new int256[](3);
                path[1] = indices[j];
                path[2] = indices[j];
                call(address(core), abi.encodeCall(Assertions.nav, (p, types, path)), types);
            }
        }
    }

    // ============ Grid ============

    /**
     * @dev base[x][y], with and without the overflow tail, for every pair of
     *      lengths: zero, small, both sides of 2^32 - 1, eleven digits,
     *      leading zeros, and 78 digits (past 2^256)
     */
    function descriptors() internal pure returns (string[] memory ds) {
        string[5] memory bases = ["uint8", "string", "(bool,string)", "(uint256,int8)", "bytes32[0]"];
        string[8] memory lengths = [
            "0",
            "1",
            "2",
            "4294967295",
            "4294967296",
            "99999999999",
            "0000000000000000000042949672",
            "999999999999999999999999999999999999999999999999999999999999999999999999999999"
        ];
        ds = new string[](bases.length * lengths.length * lengths.length * 2);
        uint256 n;
        for (uint256 b; b < bases.length; b++) {
            for (uint256 x; x < lengths.length; x++) {
                for (uint256 y; y < lengths.length; y++) {
                    string memory d = string.concat(bases[b], "[", lengths[x], "][", lengths[y], "]");
                    ds[n++] = d;
                    ds[n++] = string.concat(d, TAIL);
                }
            }
        }
    }

    function call(address target, bytes memory data, string memory descriptor) internal view {
        (bool ok, bytes memory out) = target.staticcall{gas: CALL_GAS}(data);
        if (ok) return;
        assertGe(out.length, 4, string.concat("no selector (out of gas?) for ", descriptor));
        assertTrue(bytes4(out) != PANIC, string.concat("panic for ", descriptor));
    }
}
