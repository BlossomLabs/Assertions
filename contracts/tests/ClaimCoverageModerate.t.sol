// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";
import "../Collections.sol";
import "./BiconomyERC8211Runtime.sol";

contract CoverageWireHost {
    // Independent uint8 wire structs also allow wire IDs to be exercised without using local enum names.
    struct ConstraintWire {
        uint8 constraintType;
        bytes referenceData;
    }

    struct InputWire {
        uint8 paramType;
        uint8 fetcherType;
        bytes paramData;
        ConstraintWire[] constraints;
    }

    struct OutputWire {
        uint8 fetcherType;
        bytes paramData;
    }

    struct EntryWire {
        bytes4 functionSig;
        InputWire[] inputParams;
        OutputWire[] outputParams;
    }

    function ping(uint256 x) external pure returns (uint256) {
        return x;
    }

    function crossDecode(bytes calldata encoded) external pure returns (bytes memory) {
        EntryWire[] memory e = abi.decode(encoded, (EntryWire[]));
        return abi.encode(e);
    }

    function referenceExecute(bytes calldata encoded) external {
        (bool ok, bytes memory reason) = BICONOMY_ERC8211.delegatecall(
            bytes.concat(
                bytes4(
                    keccak256(
                        "executeComposableDelegateCall((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])"
                    )
                ),
                encoded
            )
        );
        if (!ok) assembly { revert(add(reason, 32), mload(reason)) }
    }

    function positive(uint256, uint256) external pure returns (int256) {
        return 1;
    }

    function neverEqual(uint256, uint256) external pure returns (bool) {
        return false;
    }

    function alwaysEqual(uint256, uint256) external pure returns (bool) {
        return true;
    }
}

contract ClaimCoverageModerateTest is Test {
    Assertions core;
    Operations ops;
    Collections col;
    CoverageWireHost host;

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
        col = new Collections();
        host = new CoverageWireHost();
        vm.etch(BICONOMY_ERC8211, BICONOMY_ERC8211_RUNTIME);
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function nav(bytes memory encoded, string memory descriptor, int256[] memory path)
        internal
        view
        returns (bytes memory)
    {
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(core.nav, (raw(encoded), descriptor, path)));
        assertTrue(ok);
        return out;
    }

    function failure(address target, bytes memory data, bytes memory expected) internal view {
        (bool ok, bytes memory out) = target.staticcall(data);
        assertFalse(ok);
        assertEq(out, expected);
    }

    struct Item {
        uint8 id;
        string title;
        bytes blob;
    }

    function encodedItems(Item[] memory rows) internal pure returns (bytes memory) {
        return abi.encode(rows, uint256(13));
    }

    function test_C37_SelectedTupleArrayValuesAndSkippedSiblingPolicy() public view {
        Item[] memory rows = new Item[](2);
        rows[0] = Item(7, "hello", hex"010203");
        rows[1] = Item(9, "world", hex"ff");
        bytes memory encoded = encodedItems(rows);
        int256[] memory path = new int256[](3);
        path[0] = 0;
        path[1] = 1;
        path[2] = 1;
        assertEq(nav(encoded, "((uint8,string,bytes)[],uint256)", path), abi.encode("world"));
        path[2] = 2;
        assertEq(nav(encoded, "((uint8,string,bytes)[],uint256)", path), abi.encode(hex"ff"));
        path = new int256[](2);
        path[0] = 0;
        path[1] = 0;
        assertEq(nav(encoded, "((uint8,string,bytes)[],uint256)", path), abi.encode(rows[0]));
        path = new int256[](1);
        path[0] = 1;
        assertEq(nav(abi.encode(uint256(256), uint256(7)), "(uint8,uint256)", path), abi.encode(uint256(7)));
        path[0] = 0;
        failure(
            address(core),
            abi.encodeCall(core.nav, (raw(abi.encode(uint256(256), uint256(7))), "(uint8,uint256)", path)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(0))
        );
        bytes memory text = abi.encode(string("abc"));
        text[69] = hex"01";
        failure(
            address(core),
            abi.encodeCall(core.nav, (raw(text), "(string)", path)),
            abi.encodeWithSelector(AbiCodec.InvalidValue.selector, uint256(69))
        );
    }

    function test_C38_DescriptorErrorsPrecedeInvalidData() public view {
        int256[] memory path = new int256[](1);
        for (uint256 i; i < 2; i++) {
            bytes memory data = i == 0 ? bytes("") : abi.encode(uint256(7));
            failure(
                address(core),
                abi.encodeCall(core.nav, (raw(data), "(uint256,uint8[0])", path)),
                abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(16))
            );
        }
    }

    function encodedQuad(uint256[][][][] memory a) internal pure returns (bytes memory) {
        return abi.encode(a);
    }

    function test_C39_FourLevelDynamicArraySelection() public view {
        uint256[][][][] memory a = new uint256[][][][](1);
        a[0] = new uint256[][][](1);
        a[0][0] = new uint256[][](1);
        a[0][0][0] = new uint256[](2);
        a[0][0][0][0] = 17;
        a[0][0][0][1] = 29;
        int256[] memory path = new int256[](5);
        path[4] = 1;
        assertEq(nav(encodedQuad(a), "(uint256[][][][])", path), abi.encode(uint256(29)));
        path = new int256[](4);
        assertEq(nav(encodedQuad(a), "(uint256[][][][])", path), abi.encode(a[0][0][0]));
    }

    function test_C47_NavigationGasBudgetFailureAndSuccessfulControl() public view {
        uint256[] memory a = new uint256[](256);
        for (uint256 i; i < a.length; i++) {
            a[i] = i;
        }
        int256[] memory path = new int256[](1);
        bytes memory data = abi.encodeCall(core.nav, (raw(abi.encode(a)), "(uint256[])", path));
        (bool ok, bytes memory out) = address(core).staticcall{gas: 1000}(data);
        assertFalse(ok);
        assertEq(out, "");
        (ok, out) = address(core).staticcall{gas: 1000000}(data);
        assertTrue(ok);
        assertEq(out, abi.encode(a));
    }

    function test_O60_TextGasBudgetFailureAndSuccessfulControl() public view {
        bytes[] memory parts = new bytes[](2);
        parts[0] = new bytes(2048);
        parts[1] = new bytes(2048);
        bytes memory data = abi.encodeCall(ops.concat, (parts, bytes("|")));
        (bool ok, bytes memory out) = address(ops).staticcall{gas: 1000}(data);
        assertFalse(ok);
        assertEq(out, "");
        (ok, out) = address(ops).staticcall{gas: 1000000}(data);
        assertTrue(ok);
        assertEq(abi.decode(out, (bytes)), bytes.concat(parts[0], bytes("|"), parts[1]));
    }

    function test_W2_MultiEntryTargetWireCrossesReferenceAndCore() public {
        CoverageWireHost.EntryWire[] memory wire = new CoverageWireHost.EntryWire[](2);
        for (uint256 i; i < 2; i++) {
            wire[i].functionSig = host.ping.selector;
            wire[i].inputParams = new CoverageWireHost.InputWire[](2);
            wire[i].outputParams = new CoverageWireHost.OutputWire[](0);
            wire[i].inputParams[0] =
                CoverageWireHost.InputWire(0, 0, abi.encode(address(host)), new CoverageWireHost.ConstraintWire[](0));
            wire[i].inputParams[1] =
                CoverageWireHost.InputWire(2, 0, abi.encode(uint256(93 + i)), new CoverageWireHost.ConstraintWire[](0));
        }
        bytes memory encoded = abi.encode(wire);
        vm.expectCall(address(host), abi.encodeCall(host.ping, (uint256(93))), uint64(2));
        vm.expectCall(address(host), abi.encodeCall(host.ping, (uint256(94))), uint64(2));
        host.referenceExecute(encoded);
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                bytes.concat(
                    bytes4(keccak256("assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])")),
                    encoded
                )
            );
        assertTrue(ok);
        assertEq(out, "");
        assertEq(host.crossDecode(encoded), encoded);
    }

    function test_W2_ValueAndOutputWireCrossDecoding() public view {
        CoverageWireHost.EntryWire[] memory wire = new CoverageWireHost.EntryWire[](1);
        wire[0].inputParams = new CoverageWireHost.InputWire[](1);
        wire[0].inputParams[0] =
            CoverageWireHost.InputWire(1, 0, abi.encode(uint256(0)), new CoverageWireHost.ConstraintWire[](0));
        wire[0].outputParams = new CoverageWireHost.OutputWire[](2);
        wire[0].outputParams[0] = CoverageWireHost.OutputWire(0, hex"010203");
        bytes memory query = abi.encode(address(host), abi.encodeCall(host.ping, (uint256(5))));
        wire[0].outputParams[1] = CoverageWireHost.OutputWire(1, query);
        bytes memory encoded = abi.encode(wire);
        assertEq(host.crossDecode(encoded), encoded);
        failure(
            address(core),
            bytes.concat(
                bytes4(keccak256("assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])")),
                encoded
            ),
            abi.encodeWithSelector(Assertions.OutputParamsNotSupported.selector, uint256(0))
        );
        wire[0].outputParams = new CoverageWireHost.OutputWire[](0);
        failure(
            address(core),
            bytes.concat(
                bytes4(keccak256("assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])")),
                abi.encode(wire)
            ),
            abi.encodeWithSelector(Assertions.ValueParamNotSupported.selector, uint256(0), uint256(0))
        );
    }

    function naiveIndex(bytes memory s, bytes memory n) internal pure returns (uint256) {
        if (n.length > s.length) return s.length;
        for (uint256 i; i + n.length <= s.length; i++) {
            bool match_ = true;
            for (uint256 j; j < n.length; j++) {
                if (s[i + j] != n[j]) {
                    match_ = false;
                    break;
                }
            }
            if (match_) return i;
        }
        return s.length;
    }

    function test_O59_WordAndMaskedTailBoundariesAgainstByteOracle() public view {
        uint256[8] memory lengths = [uint256(1), 2, 31, 32, 33, 63, 64, 65];
        for (uint256 k; k < lengths.length; k++) {
            uint256 n = lengths[k];
            bytes memory needle = new bytes(n);
            for (uint256 j; j < n; j++) {
                needle[j] = bytes1(uint8(j % 251 + 1));
            }
            bytes memory hay = bytes.concat(hex"0000000000", needle, hex"eeeeeeee");
            assertEq(ops.indexOf(hay, needle, 0), naiveIndex(hay, needle));
            assertTrue(ops.contains(hay, needle));
            needle[n - 1] ^= hex"ff";
            assertEq(ops.indexOf(hay, needle, 0), naiveIndex(hay, needle));
            assertFalse(ops.contains(hay, needle));
        }
    }

    function callback(bytes4 selector) internal view returns (Collections.Callback memory cb) {
        cb.target = address(host);
        cb.selector = selector;
        cb.arguments = "(uint256,uint256)";
        cb.constants = new bytes[](2);
        cb.second = 1;
    }

    function test_L44_InconsistentOrderingAndEqualityRetainAlgorithmOutcomes() public view {
        bytes[] memory values = new bytes[](3);
        for (uint256 i; i < 3; i++) {
            values[i] = abi.encode(i + 1);
        }
        bytes[] memory sorted = col.sortValues("uint256", values, callback(host.positive.selector));
        assertEq(sorted.length, 3);
        uint256 mask;
        for (uint256 i; i < 3; i++) {
            uint256 v = abi.decode(sorted[i], (uint256));
            assertGe(v, 1);
            assertLe(v, 3);
            mask |= uint256(1) << v;
        }
        assertEq(mask, 14);
        for (uint256 i; i < 3; i++) {
            assertEq(sorted[i], values[2 - i]);
        }
        bytes[] memory kept = col.uniqueValues("uint256", values, callback(host.alwaysEqual.selector), false);
        assertEq(kept.length, 1);
        assertEq(kept[0], values[0]);
        values[1] = values[0];
        kept = col.uniqueValues("uint256", values, callback(host.neverEqual.selector), false);
        assertEq(kept.length, 3);
        for (uint256 i; i < 3; i++) {
            assertEq(kept[i], values[i]);
        }
    }

    function test_O23_RpowExactIntegerPowersAndStepRounding() public view {
        // Unit scale removes all quantization: Python-style integer power is an independent oracle.
        for (uint256 x = 0; x <= 7; x++) {
            for (uint256 n = 0; n <= 12; n++) {
                assertEq(ops.rpow(x, n, 1), x ** n);
            }
        }
        // Selected decimal traces have integer/half-unit intermediate powers.
        assertEq(ops.rpow(15, 3, 10), 33);
        assertEq(ops.rpow(15, 4, 10), 48);
        assertEq(ops.rpow(15, 5, 10), 72);
        assertEq(ops.rpow(0, 0, 10), 10);
        assertEq(ops.rpow(0, 17, 10), 0);
        failure(
            address(ops),
            abi.encodeCall(ops.rpow, (uint256(2), uint256(2), uint256(0))),
            abi.encodeWithSignature("Panic(uint256)", uint256(18))
        );
        failure(
            address(ops),
            abi.encodeCall(ops.rpow, (type(uint256).max, uint256(2), uint256(1))),
            abi.encodeWithSignature("Panic(uint256)", uint256(17))
        );
    }
}
