// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

/**
 * @dev Returns its caller as one word followed by the exact calldata it received
 */
contract Echo {
    fallback() external {
        assembly {
            mstore(0, caller())
            calldatacopy(32, 0, calldatasize())
            return(0, add(32, calldatasize()))
        }
    }
}

/**
 * @dev Returns its single word argument unchanged: a chain hop with a chosen result
 */
contract Hop {
    function hop(bytes32 w) external pure returns (bytes32) {
        return w;
    }
}

/**
 * @notice Halmos properties for the core's call construction (`get`, `read`,
 *         `chain`) and for error offsets. Run with `pnpm halmos`.
 * @dev The oracle is solc: get's calldata must be byte-identical to
 *      abi.encodeWithSelector over solc's decoding of the resolved arguments,
 *      and accepted exactly when solc accepts them canonically.
 */
contract CoreSymbolicTest is Test {
    Assertions core;
    Collections collections;
    Echo echo;
    Hop hopper;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        echo = new Echo();
        hopper = new Hop();
    }

    // ============ get: calldata identical to solc ============

    function solcStatics(bytes calldata d) external pure returns (uint8, address, bool, bytes4) {
        return abi.decode(d, (uint8, address, bool, bytes4));
    }

    function check_getStaticArgumentsMatchSolc(bytes32[4] memory w, bytes4 selector) public view {
        InputParam[] memory args = new InputParam[](4);
        for (uint256 i; i < 4; i++) {
            args[i] = raw(abi.encode(w[i]));
        }
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(
                    Assertions.get, (raw(abi.encode(address(echo))), selector, "(uint8,address,bool,bytes4)", args)
                )
            );
        (bool solcOk,) = address(this).staticcall(abi.encodeCall(this.solcStatics, (abi.encodePacked(w))));
        assertEq(ok, solcOk, "get and solc disagree on the arguments");
        if (ok) {
            assertEq(out, bytes.concat(bytes32(uint256(uint160(address(core)))), selector, abi.encodePacked(w)));
        }
    }

    function solcDynamics(bytes calldata d) external pure returns (uint256, string memory, uint8[] memory) {
        return abi.decode(d, (uint256, string, uint8[]));
    }

    /**
     * @dev Dynamic arguments arrive as canonical single-value encodings; the
     *      tuple get builds must be solc's, heads and tails included
     */
    function check_getDynamicArgumentsMatchSolc(
        uint256 w0,
        uint8 lengthCase,
        bytes32 payload,
        uint8 countCase,
        bytes32[2] memory e,
        bytes4 selector
    ) public view {
        vm.assume(lengthCase < 4 && countCase < 3);
        uint256 len = lengthCase == 0 ? 0 : lengthCase == 1 ? 5 : lengthCase == 2 ? 32 : 31;
        uint256 n = countCase == 0 ? 0 : countCase == 1 ? 1 : 2;
        bytes memory str = len == 0 ? abi.encode(uint256(32), uint256(0)) : abi.encode(uint256(32), len, payload);
        bytes memory arr = abi.encode(uint256(32), n);
        for (uint256 k; k < n; k++) {
            arr = bytes.concat(arr, e[k]);
        }
        InputParam[] memory args = new InputParam[](3);
        args[0] = raw(abi.encode(w0));
        args[1] = raw(str);
        args[2] = raw(arr);
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                abi.encodeCall(
                    Assertions.get, (raw(abi.encode(address(echo))), selector, "(uint256,string,uint8[])", args)
                )
            );
        // The canonical tuple solc would build from the same three values, if it accepts them.
        bytes memory tuple = bytes.concat(abi.encode(w0, uint256(0x60), uint256(0x60 + str.length - 32)));
        tuple = bytes.concat(tuple, slice(str, 32), slice(arr, 32));
        (bool solcOk, bytes memory decoded) = address(this).staticcall(abi.encodeCall(this.solcDynamics, (tuple)));
        bool canonical;
        if (solcOk) {
            (uint256 a, string memory b, uint8[] memory c) = abi.decode(decoded, (uint256, string, uint8[]));
            canonical = keccak256(abi.encode(a, b, c)) == keccak256(tuple);
        }
        assertEq(ok, canonical, "get and solc disagree on dynamic arguments");
        if (ok) assertEq(out, bytes.concat(bytes32(uint256(uint160(address(core)))), selector, tuple));
    }

    // ============ read: raw segments in order ============

    /**
     * @dev A segment of 0, 5, 32 or 33 bytes cut from two symbolic words (a literal length per case)
     */
    function segment(uint8 c, bytes32 a, bytes32 b) internal pure returns (bytes memory out) {
        out = abi.encodePacked(a, b);
        uint256 length;
        if (c == 0) {
            length = 0;
        } else if (c == 1) {
            length = 5;
        } else if (c == 2) {
            length = 32;
        } else {
            vm.assume(c == 3);
            length = 33;
        }
        assembly ("memory-safe") { mstore(out, length) }
    }

    /**
     * @dev read sends selector ++ each argument's resolved bytes, raw and in
     *      order (no padding, whatever their lengths), to the resolved target,
     *      as the core, and returns the raw returndata
     */
    function check_readSendsRawSegmentsInOrder(bytes4 selector, uint8[3] memory lengths, bytes32[6] memory w)
        public
        view
    {
        bytes memory s0 = segment(lengths[0], w[0], w[1]);
        bytes memory s1 = segment(lengths[1], w[2], w[3]);
        bytes memory s2 = segment(lengths[2], w[4], w[5]);
        InputParam[] memory args = new InputParam[](3);
        args[0] = raw(s0);
        args[1] = raw(s1);
        args[2] = raw(s2);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.read, (raw(abi.encode(address(echo))), selector, args)));
        assertTrue(ok, "read refused plain segments");
        assertEq(out, bytes.concat(bytes32(uint256(uint160(address(core)))), selector, s0, s1, s2));
    }

    // ============ Address words ============

    /**
     * @dev get, read and chain take a target word only when its upper 96 bits are clear
     */
    function check_targetWordMustBeClean(uint96 upper, uint8 primitive) public view {
        vm.assume(primitive < 3);
        bytes32 word = bytes32(uint256(uint160(address(echo))) | (uint256(upper) << 160));
        bytes memory call;
        if (primitive == 0) {
            call =
                abi.encodeCall(Assertions.get, (raw(abi.encode(word)), bytes4(0x12345678), "()", new InputParam[](0)));
        } else if (primitive == 1) {
            call = abi.encodeCall(Assertions.read, (raw(abi.encode(word)), bytes4(0x12345678), new InputParam[](0)));
        } else {
            bytes[] memory calls = new bytes[](1);
            calls[0] = hex"12345678";
            call = abi.encodeCall(Assertions.chain, (raw(abi.encode(word)), calls));
        }
        (bool ok, bytes memory out) = address(core).staticcall(call);
        if (upper == 0) {
            assertTrue(ok, "a clean target word is refused");
        } else {
            assertFalse(ok, "a dirty target word is accepted");
            assertEq(out, abi.encodeWithSelector(InvalidAddressWord.selector, uint256(0), word));
        }
    }

    /**
     * @dev A mid-chain hop's address word is held to the same rule, reported at hop index + 1
     */
    function check_chainHopWordMustBeClean(uint96 upper) public view {
        bytes32 word = bytes32(uint256(uint160(address(echo))) | (uint256(upper) << 160));
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeCall(Hop.hop, (word));
        calls[1] = hex"12345678";
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.chain, (raw(abi.encode(address(hopper))), calls)));
        if (upper == 0) {
            assertTrue(ok, "a clean hop word is refused");
            assertEq(out, bytes.concat(bytes32(uint256(uint160(address(core)))), hex"12345678"));
        } else {
            assertFalse(ok, "a dirty hop word is accepted");
            assertEq(out, abi.encodeWithSelector(InvalidAddressWord.selector, uint256(1), word));
        }
    }

    // ============ Error offsets ============

    /**
     * @dev An out-of-range rejection names the FIRST offending word: the word
     *      at the reported offset breaks its type, every earlier word is fine
     */
    function check_errorOffsetNamesFirstBadWord(bytes32[4] memory w) public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encodePacked(w);
        (bool ok, bytes memory out) = address(collections)
            .staticcall(abi.encodeCall(Collections.packArray, ("(uint8,bool,int8,address)", values)));
        bool[4] memory good = [
            uint256(w[0]) < 256,
            uint256(w[1]) < 2,
            int256(uint256(w[2])) >= -128 && int256(uint256(w[2])) < 128,
            uint256(w[3]) >> 160 == 0
        ];
        if (ok) {
            assertTrue(good[0] && good[1] && good[2] && good[3], "an out-of-range word is accepted");
            return;
        }
        uint256 first = 4;
        for (uint256 i = 4; i > 0; i--) {
            if (!good[i - 1]) first = i - 1;
        }
        assertLt(first, 4, "a rejection with every word in range");
        assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, first * 32));
    }

    /**
     * @dev The same inside one run of words: a uint8[4] is checked as four
     *      consecutive words, so the offset must advance within the run
     */
    function check_errorOffsetWithinWordRun(bytes32[4] memory w) public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encodePacked(w);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.packArray, ("uint8[4]", values)));
        uint256 first = 4;
        for (uint256 i = 4; i > 0; i--) {
            if (uint256(w[i - 1]) > 255) first = i - 1;
        }
        if (first == 4) {
            assertTrue(ok, "an in-range uint8[4] is rejected");
        } else {
            assertFalse(ok, "an out-of-range uint8[4] is accepted");
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, first * 32));
        }
    }

    // ============ Harness ============

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function slice(bytes memory data, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(data.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = data[from + i];
        }
    }
}
