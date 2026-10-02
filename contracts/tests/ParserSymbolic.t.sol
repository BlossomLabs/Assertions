// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import "../lib/AbiCodec.sol";

/**
 * @dev Exposes the internal descriptor parser
 */
contract ShapeHarness {
    function shape(string calldata t) external pure returns (bool, uint256) {
        return AbiCodec.shape(bytes(t));
    }
}

/**
 * @notice Halmos properties for AbiCodec's descriptor grammar and name rules
 *         against independent references. Run with `pnpm halmos`.
 * @dev The shape reference parses TOKENS by recursive descent, a different
 *      algorithm from the byte-level assembly scanner it judges. The name
 *      rules come from a table written out by hand from the ABI spec.
 */
contract ParserSymbolicTest is Test {
    ShapeHarness harness;
    Collections collections;

    uint8 constant SKIP = 0;
    uint8 constant LP = 5;
    uint8 constant RP = 6;
    uint8 constant COMMA = 7;

    function setUp() public {
        harness = new ShapeHarness();
        collections = new Collections();
    }

    // ============ Shape ============

    /**
     * @dev Every descriptor of up to four tokens: the parser accepts exactly
     *      the grammar, and agrees on dynamic and head footprint
     */
    function check_shapeMatchesReference(uint8[4] memory raw) public view {
        uint8[] memory tokens = new uint8[](4);
        uint256 n;
        for (uint256 i; i < 4; i++) {
            vm.assume(raw[i] < 12);
            if (raw[i] != SKIP) tokens[n++] = raw[i];
        }
        assembly ("memory-safe") { mstore(tokens, n) }
        string memory descriptor;
        for (uint256 i; i < n; i++) {
            descriptor = string.concat(descriptor, text(tokens[i]));
        }
        (bool valid, uint256 next, bool dyn, uint256 words) = parse(tokens, 0);
        valid = valid && next == n;
        (bool ok, bytes memory out) = address(harness).staticcall(abi.encodeCall(ShapeHarness.shape, (descriptor)));
        assertEq(ok, valid, "parser and grammar disagree on validity");
        if (ok) {
            (bool gotDyn, uint256 gotWords) = abi.decode(out, (bool, uint256));
            assertEq(gotDyn, dyn, "parser and grammar disagree on dynamic");
            assertEq(gotWords, words, "parser and grammar disagree on head words");
        }
    }

    function text(uint8 token) internal pure returns (string memory) {
        if (token == 1) return "uint8";
        if (token == 2) return "bytes";
        if (token == 3) return "string";
        if (token == 4) return "x";
        if (token == LP) return "(";
        if (token == RP) return ")";
        if (token == COMMA) return ",";
        if (token == 8) return "[]";
        if (token == 9) return "[2]";
        if (token == 10) return "[0]";
        return "[10]";
    }

    function isName(uint8 token) internal pure returns (bool) {
        return token >= 1 && token <= 4;
    }

    /**
     * @dev type := (name | '(' type (',' type)* ')') suffix*. Adjacent name
     *      tokens concatenate into one name, dynamic only when it is exactly
     *      "bytes" or "string".
     */
    function parse(uint8[] memory t, uint256 p) internal pure returns (bool ok, uint256 next, bool dyn, uint256 words) {
        if (p >= t.length) return (false, p, false, 0);
        if (isName(t[p])) {
            next = p;
            while (next < t.length && isName(t[next])) next++;
            dyn = next == p + 1 && (t[p] == 2 || t[p] == 3);
            words = 1;
        } else if (t[p] == LP) {
            next = p + 1;
            while (true) {
                bool okc;
                bool d;
                uint256 w;
                (okc, next, d, w) = parse(t, next);
                if (!okc) return (false, next, false, 0);
                dyn = dyn || d;
                words += w;
                if (next >= t.length) return (false, next, false, 0);
                if (t[next] == COMMA) {
                    next++;
                    continue;
                }
                if (t[next] == RP) {
                    next++;
                    break;
                }
                return (false, next, false, 0);
            }
            if (dyn) words = 1;
        } else {
            return (false, p, false, 0);
        }
        while (next < t.length && t[next] >= 8) {
            // solc refuses T[0], and so does the grammar.
            if (t[next] == 10) return (false, next, false, 0);
            if (t[next] == 8) {
                dyn = true;
                words = 1;
            } else if (!dyn) {
                words *= t[next] == 9 ? 2 : 10;
            }
            next++;
        }
        ok = true;
    }

    // ============ Name rules ============

    /**
     * @dev For every word, a static value of each listed name is accepted
     *      exactly when the hand-written rule admits it. Kind 1: `bits` low
     *      bits; 2: sign-extended from `bits`; 3: `bits` high bits; 0: any word.
     */
    function check_nameRuleMatchesTable(uint8 nameCase, bytes32 w) public view {
        vm.assume(nameCase < 28);
        (string memory name, uint256 kind, uint256 bits) = nameRule(nameCase);
        uint256 x = uint256(w);
        bool admitted = kind == 0 || (kind == 1 && x >> bits == 0)
            || (kind == 2 && (x >> (bits - 1) == 0 || x >> (bits - 1) == type(uint256).max >> (bits - 1)))
            || (kind == 3 && x << bits == 0);
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(w);
        (bool ok,) = address(collections).staticcall(abi.encodeCall(Collections.packArray, (name, values)));
        assertEq(ok, admitted, "codec and the ABI table disagree on a name's words");
    }

    function nameRule(uint8 c) internal pure returns (string memory, uint256, uint256) {
        if (c == 0) return ("uint8", 1, 8);
        if (c == 1) return ("uint08", 0, 0);
        if (c == 2) return ("uint7", 0, 0);
        if (c == 3) return ("uint", 0, 0);
        if (c == 4) return ("uint256", 0, 0);
        if (c == 5) return ("uint264", 0, 0);
        if (c == 6) return ("uint512", 0, 0);
        if (c == 7) return ("int", 0, 0);
        if (c == 8) return ("int8", 2, 8);
        if (c == 9) return ("int256", 0, 0);
        if (c == 10) return ("int1000", 0, 0);
        if (c == 11) return ("bytes0", 0, 0);
        if (c == 12) return ("bytes1", 3, 8);
        if (c == 13) return ("bytes31", 3, 248);
        if (c == 14) return ("bytes32", 0, 0);
        if (c == 15) return ("bytes33", 0, 0);
        if (c == 16) return ("address", 1, 160);
        if (c == 17) return ("addressx", 0, 0);
        if (c == 18) return ("bool", 1, 1);
        if (c == 19) return ("boolx", 0, 0);
        if (c == 20) return ("function", 3, 192);
        if (c == 21) return ("functions", 0, 0);
        if (c == 22) return ("x", 0, 0);
        if (c == 23) return ("uint8x", 0, 0);
        if (c == 24) return ("int8a", 0, 0);
        if (c == 25) return ("uint2560", 0, 0);
        if (c == 26) return ("uint248", 1, 248);
        return ("int16", 2, 16);
    }
}
