// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "../lib/ERC8211.sol";

/**
 * Gas ledger for the resolve-once decisions. The assertions below pin the
 * ORDERING, which is the durable claim; the emitted numbers are the evidence.
 * Reference figures, solc 0.8.36 / optimizer 200 / cancun, measured through
 * `Assertions.resolve` on 2026-09-07. Re-measure before quoting these; they
 * move with the compiler, and nothing here asserts their exact values.
 *
 *   call shape                     read+splice     core get
 *   one live string  (L=1)              20,217       19,000   -> stays on read
 *   two live strings (L=2)              51,474       32,440   -> get wins
 *   three live strings (L=3)           126,757       43,887   -> get wins big
 *   word-only add(lit, lit)             14,718       21,219   -> stays on read
 *
 * Graph vs tree, same day: a graph costs roughly 10k fixed plus 3.5k per node
 * plus 20k per Call, so it only pays off above a leaf cost of a few tens of k.
 *   add(x, x) over a 75k leaf        graph 115,230   tree 144,374  -> graph wins
 *   add(x, x) over a 3.6k leaf       graph  50,531   tree  14,976  -> tree wins
 */
contract Src {
    function str() external pure returns (string memory) {
        return "forty bytes of string payload for tests!";
    }
    function word() external pure returns (uint256) {
        return 7;
    }
}

contract Costly {
    function burn() internal pure returns (bytes32 h) {
        for (uint256 i; i < 300; i++) h = keccak256(abi.encode(h, i));
    }
    function str() external pure returns (string memory) {
        burn();
        return "forty bytes of string payload for tests!";
    }
    function word() external pure returns (uint256) {
        return uint256(burn()) & 0 + 7;
    }
}

contract Sink {
    function take1(string memory a) external pure returns (uint256) {
        return bytes(a).length;
    }
    function take2(string memory a, string memory b) external pure returns (uint256) {
        return bytes(a).length + bytes(b).length;
    }
    function take3(string memory a, string memory b, string memory c) external pure returns (uint256) {
        return bytes(a).length + bytes(b).length + bytes(c).length;
    }
    function who() external view returns (address) {
        return msg.sender;
    }
}

/**
 * @notice The measurements behind the SDK's call-host and graph-admission
 *         rules (docs/superpowers/plans/2026-09-07-expressions-sdk-adoption.md):
 *         L live dynamic arguments through the splice and the core's
 *         get; a shared leaf as a tree and as a graph; the graph's
 *         fixed and per-node cost; and the wrap a bytes-typed parameter
 *         needs to receive an array envelope.
 *         Costs are gasleft() around one staticcall to Assertions.resolve, so
 *         every row is billed the same way. Run with `pnpm test` and read the
 *         log lines; the assertions bound the ratios the rules rely on.
 */
contract ExpressionsGasTest is Test {
    Assertions core;
    Operations ops;
    Expressions xp;
    Src src;
    Costly costly;
    Sink sink;

    bytes4 constant ADD = bytes4(keccak256("add(uint256,uint256)"));
    bytes4 constant BITAND = bytes4(keccak256("bitAnd(uint256,uint256)"));

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
        xp = new Expressions();
        src = new Src();
        costly = new Costly();
        sink = new Sink();
    }

    function _none() internal pure returns (Constraint[] memory) {}
    function _lit(bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, d, _none());
    }
    function _w(uint256 v) internal pure returns (InputParam memory) { return _lit(abi.encode(v)); }
    function _addr(address a) internal pure returns (InputParam memory) { return _lit(abi.encode(a)); }
    function _sc(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }
    function _read(InputParam memory target, bytes4 sel, InputParam[] memory args) internal view returns (InputParam memory) {
        return _sc(address(core), abi.encodeCall(Assertions.read, (target, sel, args)));
    }
    function _op(bytes4 sel, InputParam memory a, InputParam memory b) internal view returns (InputParam memory) {
        InputParam[] memory args = new InputParam[](2);
        args[0] = a; args[1] = b;
        return _read(_addr(address(ops)), sel, args);
    }
    function _pick(InputParam memory p, int256 i) internal view returns (InputParam memory) {
        return _sc(address(core), abi.encodeCall(Assertions.pick, (p, i)));
    }
    /// bitAnd(add(pick(env,1),31), ~31): the SDK's bytesPayloadParam.
    function _payload(InputParam memory env) internal view returns (InputParam memory) {
        return _op(BITAND, _op(ADD, _pick(env, 1), _w(31)), _w(type(uint256).max - 31));
    }
    /// spliceLayout for L live string envelopes (every one runtime-sized), head-only call.
    function _splice(InputParam memory target, bytes4 sel, InputParam[] memory lives) internal view returns (InputParam memory) {
        uint256 L = lives.length;
        InputParam[] memory segs = new InputParam[](2 * L);
        uint256 at = 32 * L;
        InputParam memory grown;
        bool hasGrown;
        for (uint256 j; j < L; j++) {
            uint256 here = at + 32;
            segs[j] = hasGrown ? _op(ADD, grown, _w(here)) : _w(here);
            if (j + 1 == L) break;
            at += 64;
            InputParam memory p = _payload(lives[j]);
            grown = hasGrown ? _op(ADD, grown, p) : p;
            hasGrown = true;
        }
        for (uint256 j; j < L; j++) segs[L + j] = lives[j];
        return _read(target, sel, segs);
    }
    /// The core's own resolve-once construction.
    function _get(address to, bytes4 sel, string memory types, InputParam[] memory args) internal view returns (InputParam memory) {
        return _sc(address(core), abi.encodeCall(Assertions.get, (_addr(to), sel, types, args)));
    }

    function _resolve(InputParam memory p) internal view returns (uint256 gas, bytes memory out) {
        bytes memory data = abi.encodeCall(Assertions.resolve, (p));
        uint256 before = gasleft();
        (bool ok, bytes memory r) = address(core).staticcall(data);
        gas = before - gasleft();
        require(ok, string(r));
        out = r;
    }

    function _lives(address s, uint256 n) internal pure returns (InputParam[] memory a) {
        a = new InputParam[](n);
        for (uint256 i; i < n; i++) a[i] = _sc(s, abi.encodeCall(Src.str, ()));
    }

    function _node(Expressions.Kind k, string memory vt, bytes memory d) internal pure returns (Expressions.Node memory n) {
        n.kind = k; n.valueType = vt; n.data = d;
    }
    function _callNode(string memory vt, bytes4 sel, string memory args, uint256[] memory refs) internal pure returns (Expressions.Node memory n) {
        n.kind = Expressions.Kind.Call; n.valueType = vt; n.selector = sel; n.arguments = args; n.refs = refs;
    }
    function _r3(uint256 a, uint256 b, uint256 c) internal pure returns (uint256[] memory r) {
        r = new uint256[](3); r[0] = a; r[1] = b; r[2] = c;
    }
    function _r1(uint256 a) internal pure returns (uint256[] memory r) { r = new uint256[](1); r[0] = a; }
    function _graph(Expressions.Expression memory p) internal view returns (InputParam memory) {
        return _sc(address(xp), abi.encodeCall(Expressions.evaluate, (p, new bytes[](0))));
    }

    // ---- shared leaf: add(x, x) ----
    function _graph2(address s, InputParam memory x, bool viaResolve) internal view returns (InputParam memory) {
        Expressions.Expression memory p;
        p.core = address(core);
        if (viaResolve) {
            p.nodes = new Expressions.Node[](3);
            p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
            p.nodes[1] = _node(Expressions.Kind.Resolve, "uint256", abi.encode(x));
            p.nodes[2] = _callNode("uint256", ADD, "(uint256,uint256)", _r3(0, 1, 1));
            p.result = 2;
        } else {
            p.nodes = new Expressions.Node[](4);
            p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(s));
            p.nodes[1] = _callNode("uint256", Src.word.selector, "()", _r1(0));
            p.nodes[2] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
            p.nodes[3] = _callNode("uint256", ADD, "(uint256,uint256)", _r3(2, 1, 1));
            p.result = 3;
        }
        return _graph(p);
    }
    function _graph4(InputParam memory x) internal view returns (InputParam memory) {
        Expressions.Expression memory r;
        r.core = address(core);
        r.nodes = new Expressions.Node[](4);
        r.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
        r.nodes[1] = _node(Expressions.Kind.Resolve, "uint256", abi.encode(x));
        r.nodes[2] = _callNode("uint256", ADD, "(uint256,uint256)", _r3(0, 1, 1));
        r.nodes[3] = _callNode("uint256", ADD, "(uint256,uint256)", _r3(0, 2, 2));
        r.result = 3;
        return _graph(r);
    }
    function _tree4(InputParam memory x) internal view returns (InputParam memory) {
        return _op(ADD, _op(ADD, x, x), _op(ADD, x, x));
    }
    function _sharedLeaf(address s, string memory label, bool graphWins) internal {
        InputParam memory x = _sc(s, abi.encodeCall(Src.word, ()));
        (uint256 leaf,) = _resolve(x);
        emit log_named_uint(string.concat(label, " leaf alone           "), leaf);
        (uint256 tree, bytes memory t) = _resolve(_op(ADD, x, x));
        emit log_named_uint(string.concat(label, " tree add(x,x)        "), tree);
        (uint256 g1, bytes memory o1) = _resolve(_graph2(s, x, true));
        assertEq(t, o1);
        emit log_named_uint(string.concat(label, " graph Resolve leaf   "), g1);
        // The graph's fixed cost is worth one saved resolution of a costly
        // leaf and not of a cheap one: the admission rule in the SDK plan.
        if (graphWins) assertLt(g1, tree);
        else assertLt(tree * 2, g1);
        (uint256 g2, bytes memory o2) = _resolve(_graph2(s, x, false));
        assertEq(t, o2);
        emit log_named_uint(string.concat(label, " graph Call leaf      "), g2);
        (uint256 tree4,) = _resolve(_tree4(x));
        emit log_named_uint(string.concat(label, " tree 4 leaves 3 ops  "), tree4);
        (uint256 graph4,) = _resolve(_graph4(x));
        emit log_named_uint(string.concat(label, " graph 1 leaf 2 ops   "), graph4);
    }
    function test_sharedLeaf_cheap() public { _sharedLeaf(address(src), "cheap ", false); }
    function test_sharedLeaf_costly() public { _sharedLeaf(address(costly), "costly", true); }

    // ---- dynamic args: L = 1, 2, 3 ----
    function _dyn(address s, string memory label) internal {
        bytes4[3] memory sels = [Sink.take1.selector, Sink.take2.selector, Sink.take3.selector];
        string[3] memory types = ["(string)", "(string,string)", "(string,string,string)"];
        for (uint256 L = 1; L <= 3; L++) {
            InputParam[] memory lives = _lives(s, L);
            (uint256 gs, bytes memory a) = _resolve(_splice(_addr(address(sink)), sels[L - 1], lives));
            (uint256 gc, bytes memory b) = _resolve(_get(address(sink), sels[L - 1], types[L - 1], lives));
            assertEq(a, b);
            assertEq(abi.decode(a, (uint256)), 40 * L);
            emit log_named_uint(string.concat(label, " L=", vm.toString(L), " read+splice      "), gs);
            emit log_named_uint(string.concat(label, " L=", vm.toString(L), " core get         "), gc);
            if (L == 1) {
                // One live argument stays on `read` (byte-identical calldata to
                // today); get is within a frame of it either way.
                assertLt(gc, gs * 12 / 10);
            } else {
                // Two or more live dynamic arguments: the core's resolve-once
                // construction beats the offset splice, for a cheap and for a
                // costly source alike.
                assertLt(gc, gs);
            }
        }
    }
    function test_dynamic_cheap() public { _dyn(address(src), "cheap "); }
    function test_dynamic_costly() public { _dyn(address(costly), "costly"); }

    // ---- row B: word-only calls never migrate ----
    function test_wordOnly() public {
        InputParam[] memory lits = new InputParam[](2);
        lits[0] = _w(7); lits[1] = _w(8);
        (uint256 gRead,) = _resolve(_read(_addr(address(ops)), ADD, lits));
        (uint256 gArgs,) = _resolve(_get(address(ops), ADD, "(uint256,uint256)", lits));
        emit log_named_uint("word-only read(ops, add, [lit, lit])     ", gRead);
        emit log_named_uint("word-only get(ops, add, (u256,u256))     ", gArgs);
        assertLt(gRead, gArgs);
    }

    // ---- caller ----
    function test_caller() public {
        InputParam[] memory none = new InputParam[](0);
        (, bytes memory a) = _resolve(_read(_addr(address(sink)), Sink.who.selector, none));
        (, bytes memory d) = _resolve(_get(address(sink), Sink.who.selector, "()", none));
        assertEq(abi.decode(a, (address)), address(core));
        assertEq(abi.decode(d, (address)), address(core));
    }
}

contract Arr {
    struct Pair { address a; uint256 n; }
    function strs() external pure returns (string[] memory s) {
        s = new string[](2);
        s[0] = "ab";
        s[1] = "a value with more than thirty-two bytes";
    }
    function empty() external pure returns (string[] memory s) {}
    function pairs() external pure returns (Pair[] memory p) {
        p = new Pair[](2);
        p[0] = Pair(address(1), 1);
        p[1] = Pair(address(2), 2);
    }
    function nested() external pure returns (string[][] memory n) {
        n = new string[][](2);
        n[0] = new string[](1);
        n[0][0] = "x";
        n[1] = new string[](0);
    }
    function taggedPairs() external pure returns (uint256 tag, Pair[] memory p) {
        tag = 9;
        p = new Pair[](2);
        p[0] = Pair(address(1), 1);
        p[1] = Pair(address(2), 2);
    }
    function tagged() external pure returns (uint256 tag, string[] memory s) {
        tag = 9;
        s = new string[](1);
        s[0] = "only";
    }
}

/**
 * @notice Where a graph's cost goes (fixed, per node, per Call/Tuple), the
 *         unpackArray boundary (an array envelope must be wrapped as bytes,
 *         in a graph with Wrap and outside one with Operations.rawCall), and
 *         the nav re-encoder over lensed arrays.
 */
contract GraphCostGasTest is Test {
    Assertions core;
    Operations ops;
    Collections cols;
    Expressions xp;
    Arr arr;

    bytes4 constant ADD = bytes4(keccak256("add(uint256,uint256)"));
    bytes4 constant BYTELEN = bytes4(keccak256("byteLen(bytes)"));

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
        cols = new Collections();
        xp = new Expressions();
        arr = new Arr();
    }

    function _none() internal pure returns (Constraint[] memory) {}
    function _lit(bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, d, _none());
    }
    function _sc(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }
    function _resolve(InputParam memory p) internal view returns (uint256 gas, bool ok, bytes memory out) {
        bytes memory data = abi.encodeCall(Assertions.resolve, (p));
        uint256 before = gasleft();
        (ok, out) = address(core).staticcall(data);
        gas = before - gasleft();
    }
    function _node(Expressions.Kind k, string memory vt, bytes memory d) internal pure returns (Expressions.Node memory n) {
        n.kind = k; n.valueType = vt; n.data = d;
    }
    function _callNode(string memory vt, bytes4 sel, string memory args, uint256[] memory refs) internal pure returns (Expressions.Node memory n) {
        n.kind = Expressions.Kind.Call; n.valueType = vt; n.selector = sel; n.arguments = args; n.refs = refs;
    }
    function _r1(uint256 a) internal pure returns (uint256[] memory r) { r = new uint256[](1); r[0] = a; }
    function _r2(uint256 a, uint256 b) internal pure returns (uint256[] memory r) { r = new uint256[](2); r[0] = a; r[1] = b; }
    function _r3(uint256 a, uint256 b, uint256 c) internal pure returns (uint256[] memory r) { r = new uint256[](3); r[0] = a; r[1] = b; r[2] = c; }
    function _graph(Expressions.Expression memory p) internal view returns (InputParam memory) {
        return _sc(address(xp), abi.encodeCall(Expressions.evaluate, (p, new bytes[](0))));
    }

    // ---- graph overhead decomposition ----
    function test_graphOverhead() public {
        Expressions.Expression memory p;
        p.core = address(core);
        // G0: a literal alone
        p.nodes = new Expressions.Node[](1);
        p.nodes[0] = _node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(7)));
        p.result = 0;
        (uint256 g0,,) = _resolve(_graph(p));
        emit log_named_uint("G0 evaluate(Literal)                 ", g0);
        // G1: Call add(lit, lit)
        p.nodes = new Expressions.Node[](3);
        p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
        p.nodes[1] = _node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(7)));
        p.nodes[2] = _callNode("uint256", ADD, "(uint256,uint256)", _r3(0, 1, 1));
        p.result = 2;
        (uint256 g1, bool ok1, bytes memory o1) = _resolve(_graph(p));
        assertTrue(ok1); assertEq(abi.decode(o1, (uint256)), 14);
        emit log_named_uint("G1 Call add(lit,lit) 3 nodes         ", g1);
        // G2: Call byteLen(lit string) with a dynamic arg
        p.nodes = new Expressions.Node[](3);
        p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
        p.nodes[1] = _node(Expressions.Kind.Literal, "string", abi.encode("forty bytes of string payload for tests!"));
        p.nodes[2] = _callNode("uint256", BYTELEN, "(bytes)", _r2(0, 1));
        p.result = 2;
        (uint256 g2, bool ok2, bytes memory o2) = _resolve(_graph(p));
        assertTrue(ok2); assertEq(abi.decode(o2, (uint256)), 40);
        emit log_named_uint("G2 Call byteLen(lit string) 3 nodes  ", g2);
        // G3: Tuple of two literals
        p.nodes = new Expressions.Node[](3);
        p.nodes[0] = _node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(7)));
        p.nodes[1] = _node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(8)));
        p.nodes[2] = _node(Expressions.Kind.Tuple, "(uint256,uint256)", "");
        p.nodes[2].arguments = "(uint256,uint256)";
        p.nodes[2].refs = _r2(0, 1);
        p.result = 2;
        (uint256 g3, bool ok3,) = _resolve(_graph(p));
        assertTrue(ok3);
        emit log_named_uint("G3 Tuple(lit,lit) 3 nodes            ", g3);
        // References: direct ops call and core read of the same add.
        (uint256 d,,) = _resolve(_sc(address(ops), abi.encodeWithSelector(ADD, uint256(7), uint256(7))));
        emit log_named_uint("ref direct ops.add(7,7) via resolve  ", d);
        InputParam[] memory a2 = new InputParam[](2);
        a2[0] = _lit(abi.encode(uint256(7))); a2[1] = a2[0];
        (uint256 r,,) = _resolve(_sc(address(core), abi.encodeCall(Assertions.read, (_lit(abi.encode(address(ops))), ADD, a2))));
        emit log_named_uint("ref core read(ops, add, [lit,lit])   ", r);
        // Raw staticcall to evaluate (no core.resolve frame) for G1
        p.nodes = new Expressions.Node[](3);
        p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
        p.nodes[1] = _node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(7)));
        p.nodes[2] = _callNode("uint256", ADD, "(uint256,uint256)", _r3(0, 1, 1));
        p.result = 2;
        bytes memory data = abi.encodeCall(Expressions.evaluate, (p, new bytes[](0)));
        uint256 before = gasleft();
        (bool okx,) = address(xp).staticcall(data);
        uint256 raw = before - gasleft();
        assertTrue(okx);
        emit log_named_uint("G1 raw evaluate (no core frame)      ", raw);
        emit log_named_uint("G1 evaluate calldata bytes           ", data.length);
    }

    // ---- unpackArray boundary: tree (rawCall wrap) and graph (Wrap) ----
    bytes4 constant UNPACK = bytes4(keccak256("unpackArray(string,bytes)"));

    /// read(collections, unpackArray, [heads+type tail][encoded segment]) with offset_encoded = 160 (+32 trick).
    function _unpackTree(string memory elemType, InputParam memory encoded) internal view returns (InputParam memory) {
        bytes memory typeTail = abi.encode(elemType); // [0x20][len][payload]
        bytes memory typeTailNoOffset = new bytes(typeTail.length - 32);
        for (uint256 i; i < typeTailNoOffset.length; i++) typeTailNoOffset[i] = typeTail[i + 32];
        uint256 encodedAt = 64 + typeTailNoOffset.length;
        InputParam[] memory segs = new InputParam[](2);
        segs[0] = _lit(bytes.concat(abi.encode(uint256(64)), abi.encode(encodedAt + 32), typeTailNoOffset));
        segs[1] = encoded;
        return _sc(address(core), abi.encodeCall(Assertions.read, (_lit(abi.encode(address(cols))), UNPACK, segs)));
    }
    /// Operations.rawCall(core, resolve(env)): the tree-level Wrap.
    function _wrapTree(InputParam memory env) internal view returns (InputParam memory) {
        return _sc(address(ops), abi.encodeCall(Operations.rawCall, (address(core), abi.encodeCall(Assertions.resolve, (env)))));
    }
    function _unpackGraph(string memory elemType, string memory arrayType, InputParam memory env) internal view returns (InputParam memory) {
        Expressions.Expression memory p;
        p.core = address(core);
        p.nodes = new Expressions.Node[](5);
        p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(cols)));
        p.nodes[1] = _node(Expressions.Kind.Literal, "string", abi.encode(elemType));
        p.nodes[2] = _node(Expressions.Kind.Resolve, arrayType, abi.encode(env));
        p.nodes[3] = _node(Expressions.Kind.Wrap, "bytes", "");
        p.nodes[3].refs = _r1(2);
        p.nodes[4] = _callNode("bytes[]", UNPACK, "(string,bytes)", _r3(0, 1, 3));
        p.result = 4;
        return _graph(p);
    }
    function _check(string memory label, string memory elemType, string memory arrayType, bytes memory call, uint256 expectCount) internal {
        InputParam memory env = _sc(address(arr), call);
        (uint256 gBad, bool okBad,) = _resolve(_unpackTree(elemType, env));
        (uint256 gTree, bool okTree, bytes memory t) = _resolve(_unpackTree(elemType, _wrapTree(env)));
        (uint256 gGraph, bool okGraph, bytes memory g) = _resolve(_unpackGraph(elemType, arrayType, env));
        assertFalse(okBad, "unwrapped envelope must revert");
        assertTrue(okTree, "tree wrap");
        assertTrue(okGraph, "graph wrap");
        assertEq(t, g);
        // Outside a graph, Operations.rawCall around resolve is the cheaper wrap.
        assertLt(gTree, gGraph);
        assertEq(abi.decode(t, (bytes[])).length, expectCount);
        emit log_named_uint(string.concat(label, " unwrapped (reverts) "), gBad);
        emit log_named_uint(string.concat(label, " tree rawCall wrap   "), gTree);
        emit log_named_uint(string.concat(label, " graph Wrap          "), gGraph);
    }
    function test_unpack_strings() public { _check("string[]        ", "string", "string[]", abi.encodeCall(Arr.strs, ()), 2); }
    function test_unpack_empty() public { _check("empty string[]  ", "string", "string[]", abi.encodeCall(Arr.empty, ()), 0); }
    function test_unpack_pairs() public { _check("(address,uint)[]", "(address,uint256)", "(address,uint256)[]", abi.encodeCall(Arr.pairs, ()), 2); }
    function test_unpack_nested() public { _check("string[][]      ", "string[]", "string[][]", abi.encodeCall(Arr.nested, ()), 2); }
    /// Lensed static-element array: nav returns a canonical envelope, wrap + unpack work.
    function test_unpack_lensed_static() public {
        int256[] memory path = new int256[](1);
        path[0] = 1;
        InputParam memory env = _sc(address(core), abi.encodeCall(Assertions.nav, (_sc(address(arr), abi.encodeCall(Arr.taggedPairs, ())), "(uint256,(address,uint256)[])", path)));
        (uint256 g, bool okTree, bytes memory t) = _resolve(_unpackTree("(address,uint256)", _wrapTree(env)));
        assertTrue(okTree);
        assertEq(abi.decode(t, (bytes[])).length, 2);
        emit log_named_uint("lensed (address,uint256)[] tree wrap", g);
    }
    /// Lensed dynamic-element array: nav re-encodes it (2026-09-07), so wrap + unpack work through a lens too.
    function test_unpack_lensed_dynamic() public {
        int256[] memory path = new int256[](1);
        path[0] = 1;
        InputParam memory env = _sc(address(core), abi.encodeCall(Assertions.nav, (_sc(address(arr), abi.encodeCall(Arr.tagged, ())), "(uint256,string[])", path)));
        (uint256 g, bool ok, bytes memory t) = _resolve(_unpackTree("string", _wrapTree(env)));
        assertTrue(ok);
        bytes[] memory v = abi.decode(t, (bytes[]));
        assertEq(v.length, 1);
        assertEq(abi.decode(v[0], (string)), "only");
        emit log_named_uint("lensed string[] tree wrap           ", g);
    }

    // ---- a string Parameter feeding a (bytes) Call through mapValues ----
    function test_stringParameterLambda() public view {
        Expressions.Expression memory p;
        p.core = address(core);
        p.nodes = new Expressions.Node[](3);
        p.nodes[0] = _node(Expressions.Kind.Literal, "address", abi.encode(address(ops)));
        p.nodes[1] = _node(Expressions.Kind.Parameter, "string", abi.encode(uint256(0)));
        p.nodes[2] = _callNode("uint256", BYTELEN, "(bytes)", _r2(0, 1));
        p.result = 2;
        Collections.Callback memory cb;
        cb.target = address(xp);
        cb.arguments = "(string)";
        cb.constants = new bytes[](1);
        cb.first = 0;
        cb.expression = abi.encode(p);
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode("ab");
        v[1] = abi.encode("a value with more than thirty-two bytes");
        bytes[] memory out = cols.mapValues("string", "uint256", v, cb);
        assertEq(abi.decode(out[0], (uint256)), 2);
        assertEq(abi.decode(out[1], (uint256)), 39);
    }
}
