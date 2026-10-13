// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Collections.sol";

/**
 * @dev Captures calldata or returns the second bytes argument verbatim.
 *      The raw-tail selectors require a valid two-slot ABI frame whose first
 *      component spans one head word (including dynamic types) or two words.
 */
contract ClaimTypesOracle {
    fallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sig == bytes4(0xcafef00d)) return abi.encode(data);
        uint256 head = msg.sig == bytes4(0xf00d0002) ? 68 : 36;
        require(data.length >= head + 32);
        assembly ("memory-safe") {
            let p := add(4, calldataload(head))
            let n := calldataload(p)
            let out := mload(0x40)
            calldatacopy(out, add(p, 32), n)
            return(out, n)
        }
    }

    function raw(bytes calldata value) external pure {
        assembly ("memory-safe") {
            let p := mload(0x40)
            calldatacopy(p, value.offset, value.length)
            return(p, value.length)
        }
    }
}

/**
 * @notice L70/L75 over additional scalar and compound ABI families. Shapes
 *         and lengths are literal cases; payload words remain symbolic.
 *         Rejection checks use full errors and success is always explicit.
 */
contract ClaimTypeFamiliesSymbolicTest is Test {
    struct NarrowPair {
        uint8 a;
        uint8 b;
    }

    struct WidePair {
        uint256 a;
        uint256 b;
    }

    struct NarrowText {
        uint8 a;
        string text;
    }

    struct WideText {
        uint256 a;
        string text;
    }

    struct ValueCase {
        string t;
        string wide;
        bytes value;
        bytes initial;
        bytes args;
        bool canonical;
        uint256 bad;
        bool twoWords;
    }
    bytes32 constant A = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
    bytes32 constant B = 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
    Collections collections;
    ClaimTypesOracle oracle;

    function setUp() public {
        collections = new Collections();
        oracle = new ClaimTypesOracle();
    }

    function check_extendedScalarSlotTypes(
        bytes32 x,
        bytes32 tag,
        uint8 typeCase,
        bool same,
        bool constantSlot,
        bool empty
    ) public view {
        vm.assume(typeCase < 6);
        ValueCase memory c = scalar(x, typeCase);
        c.args = constantSlot ? bytes.concat(c.initial, abi.encode(tag)) : c.initial;
        checkSlot(c, tag, same, constantSlot, empty);
    }

    function check_extendedCompoundSlotTypes(
        bytes32 a,
        bytes32 b,
        bytes32 text,
        uint8 typeCase,
        bool same,
        bool constantSlot,
        bool empty
    ) public view {
        vm.assume(typeCase < 4);
        ValueCase memory c = compound(a, b, text, typeCase, constantSlot);
        checkSlot(c, text, same, constantSlot, empty);
    }

    function check_extendedByteSlotEncodings(
        bytes32 a,
        bytes32 b,
        bytes32 c,
        uint8 lengthCase,
        uint8 fault,
        bool stringType,
        bool constantSlot,
        bool empty
    ) public view {
        vm.assume(lengthCase < 7 && fault < 3);
        ValueCase memory v = byteValue(a, b, c, lengthCase, fault, stringType);
        bytes32 tag = bytes32(uint256(7));
        bytes memory data = payload(a, b, c, lengthCase);
        v.args = stringType
            ? (constantSlot ? abi.encode(string(data), tag) : abi.encode(string(data)))
            : (constantSlot ? abi.encode(data, tag) : abi.encode(data));
        checkSlot(v, tag, true, constantSlot, empty);
    }

    function check_extendedNestedSlotOffsets(bytes32 a, bytes32 b, uint8 offsetCase, bool constantSlot, bool empty)
        public
        view
    {
        vm.assume(offsetCase < 4);
        string memory text = string(abi.encode(a, b));
        ValueCase memory c;
        c.t = "(uint8,string)";
        c.wide = c.t;
        c.value = abi.encode(NarrowText(7, text));
        c.initial = abi.encode(NarrowText(7, text));
        // The nested offset precedes the length word and payload. Find it in
        // a reference fixture, rather than reconstructing a codec layout.
        c.bad = findWord(abi.encode(NarrowText(7, "x")), bytes32(uint256(64)));
        uint256 offset = offsetCase == 0 ? 0 : offsetCase == 1 ? 32 : offsetCase == 2 ? 64 : 96;
        setWord(c.value, c.bad, bytes32(offset));
        c.canonical = offset == 64;
        c.args = constantSlot ? abi.encode(NarrowText(7, text), bytes32(uint256(9))) : c.initial;
        checkSlot(c, bytes32(uint256(9)), true, constantSlot, empty);
    }

    function check_extendedScalarResultTypes(bytes32 x, uint8 typeCase, bool fold, bool late) public view {
        vm.assume(typeCase < 6);
        checkResult(scalar(x, typeCase), fold, late);
    }

    function check_extendedCompoundResultTypes(bytes32 a, bytes32 b, bytes32 text, uint8 typeCase, bool fold, bool late)
        public
        view
    {
        vm.assume(typeCase < 4);
        checkResult(compound(a, b, text, typeCase, false), fold, late);
    }

    function check_extendedByteResultEncodings(
        bytes32 a,
        bytes32 b,
        bytes32 c,
        uint8 lengthCase,
        uint8 fault,
        bool stringType,
        bool fold,
        bool late
    ) public view {
        vm.assume(lengthCase < 7 && fault < 3);
        checkResult(byteValue(a, b, c, lengthCase, fault, stringType), fold, late);
    }

    function checkSlot(ValueCase memory c, bytes32 tag, bool same, bool constantSlot, bool empty) internal view {
        Collections.Callback memory cb;
        cb.target = address(oracle);
        cb.selector = bytes4(0xcafef00d);
        cb.arguments = string.concat("(", c.t, constantSlot ? ",bytes32)" : ")");
        cb.constants = new bytes[](constantSlot ? 2 : 1);
        cb.constants[0] = c.value;
        if (constantSlot) cb.constants[1] = abi.encode(tag);
        cb.first = constantSlot ? 1 : 0;
        bytes[] memory values = new bytes[](empty ? 0 : 1);
        if (!empty) values[0] = constantSlot ? abi.encode(tag) : c.value;
        string memory input = constantSlot ? "bytes32" : same ? c.t : c.wide;
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.mapValues, (input, "bytes", values, cb)));
        if (!c.canonical && (constantSlot || !empty)) {
            assertFalse(ok);
            if (
                constantSlot && bytes32(c.value) != bytes32(uint256(32))
                    && (keccak256(bytes(c.t)) == keccak256("bytes") || keccak256(bytes(c.t)) == keccak256("string"))
            ) {
                assertEq(
                    out,
                    abi.encodeWithSelector(
                        AbiCodec.InvalidComponentEnvelope.selector, uint256(0), c.value.length, bytes32(c.value)
                    )
                );
            } else {
                assertEq(
                    out,
                    same && !constantSlot
                        ? abi.encodeWithSelector(AbiCodec.InvalidValue.selector, c.bad)
                        : abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), c.bad)
                );
            }
        } else {
            assertTrue(ok);
            bytes[] memory got = abi.decode(out, (bytes[]));
            assertEq(got.length, empty ? 0 : 1);
            if (!empty) assertEq(got[0], abi.encode(bytes.concat(cb.selector, c.args)));
        }
    }

    function checkResult(ValueCase memory c, bool fold, bool late) internal view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(late ? c.initial : c.value);
        values[1] = abi.encode(late ? c.value : c.initial);
        Collections.Callback memory cb;
        cb.target = address(oracle);
        bytes memory callData;
        if (fold) {
            cb.selector = c.twoWords ? bytes4(0xf00d0002) : bytes4(0xf00d0001);
            cb.arguments = string.concat("(", c.t, ",bytes)");
            cb.constants = new bytes[](2);
            cb.constants[0] = c.initial;
            cb.constants[1] = abi.encode(bytes(""));
            cb.second = 1;
            callData = abi.encodeCall(Collections.foldValues, ("bytes", c.t, values, c.initial, cb));
        } else {
            cb.selector = ClaimTypesOracle.raw.selector;
            cb.arguments = "(bytes)";
            cb.constants = new bytes[](1);
            cb.constants[0] = abi.encode(bytes(""));
            callData = abi.encodeCall(Collections.mapValues, ("bytes", c.t, values, cb));
        }
        (bool ok, bytes memory out) = address(collections).staticcall(callData);
        if (!c.canonical) {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    fold ? Collections.foldValues.selector : Collections.mapValues.selector,
                    late ? uint256(1) : uint256(0),
                    uint256(0),
                    address(oracle)
                )
            );
        } else {
            assertTrue(ok);
            if (fold) {
                assertEq(abi.decode(out, (bytes)), late ? c.value : c.initial);
            } else {
                bytes[] memory got = abi.decode(out, (bytes[]));
                assertEq(got.length, 2);
                assertEq(got[0], late ? c.initial : c.value);
                assertEq(got[1], late ? c.value : c.initial);
            }
        }
    }

    function scalar(bytes32 x, uint8 typeCase) internal pure returns (ValueCase memory c) {
        c.wide = "bytes32";
        c.value = abi.encode(x);
        if (typeCase == 0) {
            c.t = "int8";
            c.initial = abi.encode(int8(uint8(uint256(x))));
        } else if (typeCase == 1) {
            c.t = "int32";
            c.initial = abi.encode(int32(uint32(uint256(x))));
        } else if (typeCase == 2) {
            c.t = "uint32";
            c.initial = abi.encode(uint32(uint256(x)));
        } else if (typeCase == 3) {
            c.t = "bytes4";
            c.initial = abi.encode(bytes4(x));
        } else if (typeCase == 4) {
            c.t = "bool";
            c.initial = abi.encode(uint256(x) != 0);
        } else {
            c.t = "address";
            c.initial = abi.encode(address(uint160(uint256(x))));
        }
        c.canonical = x == bytes32(c.initial);
    }

    function compound(bytes32 a, bytes32 b, bytes32 text, uint8 typeCase, bool constantSlot)
        internal
        pure
        returns (ValueCase memory c)
    {
        uint256 pa;
        uint256 pb;
        if (typeCase == 0) {
            c.t = "uint8[2]";
            c.wide = "uint256[2]";
            c.twoWords = true;
            c.value = abi.encode([uint256(A), uint256(B)]);
            uint8[2] memory v = [uint8(uint256(a)), uint8(uint256(b))];
            c.initial = abi.encode(v);
            c.args = constantSlot ? abi.encode(v, text) : c.initial;
        } else if (typeCase == 1) {
            c.t = "uint8[]";
            c.wide = "uint256[]";
            uint256[] memory seed = new uint256[](2);
            seed[0] = uint256(A);
            seed[1] = uint256(B);
            c.value = abi.encode(seed);
            uint8[] memory v = new uint8[](2);
            v[0] = uint8(uint256(a));
            v[1] = uint8(uint256(b));
            c.initial = abi.encode(v);
            c.args = constantSlot ? abi.encode(v, text) : c.initial;
        } else if (typeCase == 2) {
            c.t = "(uint8,uint8)";
            c.wide = "(uint256,uint256)";
            c.twoWords = true;
            c.value = abi.encode(WidePair(uint256(A), uint256(B)));
            NarrowPair memory v = NarrowPair(uint8(uint256(a)), uint8(uint256(b)));
            c.initial = abi.encode(v);
            c.args = constantSlot ? abi.encode(v, text) : c.initial;
        } else {
            c.t = "(uint8,string)";
            c.wide = "(uint256,string)";
            bytes memory body = abi.encode(text, b);
            assembly ("memory-safe") { mstore(body, 33) }
            c.value = abi.encode(WideText(uint256(A), string(body)));
            NarrowText memory v = NarrowText(uint8(uint256(a)), string(body));
            c.initial = abi.encode(v);
            c.args = constantSlot ? abi.encode(v, text) : c.initial;
        }
        pa = findWord(c.value, A);
        if (typeCase != 3) pb = findWord(c.value, B);
        setWord(c.value, pa, a);
        if (typeCase != 3) setWord(c.value, pb, b);
        c.canonical = uint256(a) <= 255 && (typeCase == 3 || uint256(b) <= 255);
        c.bad = uint256(a) > 255 ? pa : pb;
    }

    function byteValue(bytes32 a, bytes32 b, bytes32 c, uint8 lengthCase, uint8 fault, bool stringType)
        internal
        pure
        returns (ValueCase memory v)
    {
        bytes memory data = payload(a, b, c, lengthCase);
        v.t = stringType ? "string" : "bytes";
        v.wide = v.t;
        v.value = stringType ? abi.encode(string(data)) : abi.encode(data);
        v.initial = stringType ? abi.encode(string(data)) : abi.encode(data);
        v.canonical = true;
        if (fault == 2) {
            setWord(v.value, 0, bytes32(0));
            v.canonical = false;
        } else if (fault == 1 && data.length % 32 != 0) {
            bytes memory marker = payload(A, A, A, lengthCase);
            uint256 start = findWord(abi.encode(marker), bytes32(marker));
            v.bad = start + data.length;
            v.value[v.bad] = bytes1(0x01);
            v.canonical = false;
        }
    }

    function payload(bytes32 a, bytes32 b, bytes32 c, uint8 lengthCase) internal pure returns (bytes memory data) {
        data = abi.encode(a, b, c);
        uint256 n = lengthCase == 0
            ? 0
            : lengthCase == 1
                ? 1
                : lengthCase == 2 ? 31 : lengthCase == 3 ? 32 : lengthCase == 4 ? 33 : lengthCase == 5 ? 64 : 65;
        assembly ("memory-safe") { mstore(data, n) }
    }

    function findWord(bytes memory value, bytes32 marker) internal pure returns (uint256) {
        for (uint256 i; i + 32 <= value.length; i += 32) {
            bytes32 word;
            assembly ("memory-safe") { word := mload(add(add(value, 32), i)) }
            if (word == marker) return i;
        }
        assert(false);
        return 0;
    }

    function setWord(bytes memory value, uint256 offset, bytes32 word) internal pure {
        assembly ("memory-safe") { mstore(add(add(value, 32), offset), word) }
    }

    function test_extendedTypeSamples() public view {
        check_extendedScalarSlotTypes(bytes32(type(uint256).max), bytes32(0), 0, true, false, false);
        check_extendedScalarSlotTypes(bytes32(uint256(0x1234)), bytes32(0), 0, false, false, false);
        check_extendedScalarSlotTypes(bytes32(uint256(1)), bytes32(0), 3, true, true, true);
        check_extendedCompoundSlotTypes(bytes32(uint256(7)), bytes32(uint256(9)), bytes32(0), 0, true, false, false);
        check_extendedCompoundSlotTypes(bytes32(uint256(256)), bytes32(uint256(9)), bytes32(0), 1, false, false, false);
        check_extendedCompoundSlotTypes(bytes32(uint256(7)), bytes32(uint256(256)), bytes32(0), 2, true, true, true);
        check_extendedCompoundSlotTypes(bytes32(uint256(7)), bytes32(uint256(9)), bytes32(0), 3, true, true, false);
        check_extendedByteSlotEncodings(A, B, A, 4, 1, true, true, true);
        check_extendedByteSlotEncodings(A, B, A, 4, 2, false, true, true);
        check_extendedNestedSlotOffsets(A, B, 1, true, true);
        check_extendedScalarResultTypes(bytes32(type(uint256).max), 0, true, true);
        check_extendedScalarResultTypes(bytes32(uint256(7)), 3, false, true);
        check_extendedCompoundResultTypes(bytes32(uint256(7)), bytes32(uint256(9)), A, 0, true, true);
        check_extendedCompoundResultTypes(bytes32(uint256(7)), bytes32(uint256(256)), A, 1, true, true);
        check_extendedCompoundResultTypes(bytes32(uint256(7)), bytes32(uint256(9)), A, 3, true, false);
        check_extendedByteResultEncodings(A, B, A, 6, 0, true, true, true);
        check_extendedByteResultEncodings(A, B, A, 2, 1, false, true, true);
    }

    function test_extendedScalarAndCompoundGeometries() public view {
        for (uint8 t; t < 6; t++) {
            check_extendedScalarSlotTypes(bytes32(0), B, t, true, false, false);
            check_extendedScalarSlotTypes(bytes32(type(uint256).max), B, t, false, true, true);
            check_extendedScalarResultTypes(bytes32(type(uint256).max), t, false, false);
            check_extendedScalarResultTypes(bytes32(uint256(1)), t, true, true);
        }
        for (uint8 t; t < 4; t++) {
            check_extendedCompoundSlotTypes(bytes32(uint256(7)), bytes32(uint256(9)), B, t, true, false, false);
            check_extendedCompoundSlotTypes(bytes32(uint256(256)), bytes32(uint256(9)), B, t, false, false, false);
            check_extendedCompoundSlotTypes(bytes32(uint256(7)), bytes32(uint256(256)), B, t, false, true, true);
            check_extendedCompoundResultTypes(bytes32(uint256(7)), bytes32(uint256(9)), B, t, true, true);
            check_extendedCompoundResultTypes(bytes32(uint256(256)), bytes32(uint256(9)), B, t, false, true);
        }
        for (uint8 i; i < 4; i++) {
            check_extendedNestedSlotOffsets(A, B, i, true, true);
        }
    }

    function test_extendedByteGeometries() public view {
        for (uint8 n; n < 7; n++) {
            for (uint8 fault; fault < 3; fault++) {
                for (uint8 t; t < 2; t++) {
                    check_extendedByteSlotEncodings(A, B, A, n, fault, t == 1, true, true);
                    check_extendedByteSlotEncodings(A, B, A, n, fault, t == 1, false, false);
                    check_extendedByteResultEncodings(A, B, A, n, fault, t == 1, true, true);
                    check_extendedByteResultEncodings(A, B, A, n, fault, t == 1, false, false);
                }
            }
        }
    }
}
