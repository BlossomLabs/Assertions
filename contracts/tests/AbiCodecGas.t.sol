// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../lib/AbiCodec.sol";
import "../Expressions.sol";
import "../Assertions.sol";

/**
 * @notice Harness exposing the shared codec's internal entry points as
 *         external calls, so each can be billed on its own.
 */
contract CodecHarness {
    function shape(string calldata t) external pure returns (bool, uint256) {
        return AbiCodec.shape(bytes(t));
    }

    function layout(string calldata t) external pure returns (uint256) {
        return AbiCodec.tupleLayout(bytes(t)).headSize;
    }

    function tuple(string calldata t, bytes[] memory v) external pure returns (bytes memory) {
        return AbiCodec.tuple(bytes(t), v);
    }

    function validate(string calldata t, bytes memory v) external pure returns (bool) {
        return AbiCodec.validate(bytes(t), v);
    }

    function nothing() external pure returns (uint256) {
        return 1;
    }
}

/**
 * @notice The cost of descriptor parsing, the shared hot path of every
 *         Collections callback bind, every Expressions node and the core's
 *         `get`. Measured 2026-09-07 before the assembly scanners:
 *         shape("(uint256,uint256)") 6.9k net, tupleLayout 25.2k, tuple over
 *         two words 30.0k, an Expressions Literal node 5 to 7k. The bounds
 *         below hold the post-rewrite figures with slack; a regression past
 *         them is the parse cost creeping back.
 *
 *         Run with `pnpm test` and read the log lines; the `_cost` numbers
 *         include the ~3k external-call baseline logged first.
 */
contract AbiCodecGasTest is Test {
    CodecHarness h;
    Expressions xp;
    Assertions core;

    function setUp() public {
        h = new CodecHarness();
        xp = new Expressions();
        core = new Assertions();
    }

    function _cost(address t, bytes memory d) internal view returns (uint256 g) {
        uint256 b = gasleft();
        (bool ok,) = t.staticcall(d);
        g = b - gasleft();
        require(ok, "measured call reverted");
    }

    function test_gas_descriptorParsing() public {
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(uint256(7));
        v[1] = abi.encode(uint256(8));
        bytes[] memory s = new bytes[](1);
        s[0] = abi.encode("forty bytes of string payload for tests!");
        uint256 base = _cost(address(h), abi.encodeCall(CodecHarness.nothing, ()));
        uint256 shape = _cost(address(h), abi.encodeCall(CodecHarness.shape, ("(uint256,uint256)")));
        uint256 layout = _cost(address(h), abi.encodeCall(CodecHarness.layout, ("(uint256,uint256)")));
        uint256 tuple2 = _cost(address(h), abi.encodeCall(CodecHarness.tuple, ("(uint256,uint256)", v)));
        uint256 tupleS = _cost(address(h), abi.encodeCall(CodecHarness.tuple, ("(bytes)", s)));
        uint256 validW = _cost(address(h), abi.encodeCall(CodecHarness.validate, ("uint256", v[0])));
        uint256 validS = _cost(address(h), abi.encodeCall(CodecHarness.validate, ("string", s[0])));
        emit log_named_uint("external call baseline              ", base);
        emit log_named_uint("shape('(uint256,uint256)')          ", shape);
        emit log_named_uint("tupleLayout('(uint256,uint256)')    ", layout);
        emit log_named_uint("tuple('(uint256,uint256)', 2 words) ", tuple2);
        emit log_named_uint("tuple('(bytes)', 40B string)        ", tupleS);
        emit log_named_uint("validate('uint256', word)           ", validW);
        emit log_named_uint("validate('string', 40B)             ", validS);
        // Net of the call baseline: parsing a 17-character tuple descriptor
        // stays under 3k and the whole two-word tuple encode under 14k.
        assertLt(shape - base, 3_000);
        assertLt(layout - base, 8_000);
        assertLt(tuple2 - base, 14_000);
    }

    function _literals(uint256 n) internal view returns (Expressions.Expression memory p) {
        p.core = address(core);
        p.nodes = new Expressions.Node[](n);
        for (uint256 i; i < n; i++) {
            p.nodes[i].kind = Expressions.Kind.Literal;
            p.nodes[i].valueType = "uint256";
            p.nodes[i].data = abi.encode(i);
        }
        p.result = n - 1;
    }

    function test_gas_evaluatePerNode() public {
        uint256[4] memory costs;
        for (uint256 n = 1; n <= 4; n++) {
            bytes memory d = abi.encodeCall(Expressions.evaluate, (_literals(n), new bytes[](0)));
            costs[n - 1] = _cost(address(xp), d);
            emit log_named_uint(string.concat("evaluate ", vm.toString(n), " Literal nodes, calldata bytes"), d.length);
            emit log_named_uint(string.concat("evaluate ", vm.toString(n), " Literal nodes, gas          "), costs[n - 1]);
        }
        Expressions.Expression memory q = _literals(2);
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = q.nodes[0];
        nodes[1] = q.nodes[1];
        nodes[2].kind = Expressions.Kind.Tuple;
        nodes[2].valueType = "(uint256,uint256)";
        nodes[2].arguments = "(uint256,uint256)";
        nodes[2].refs = new uint256[](2);
        nodes[2].refs[1] = 1;
        q.nodes = nodes;
        q.result = 2;
        uint256 tupleNode = _cost(address(xp), abi.encodeCall(Expressions.evaluate, (q, new bytes[](0))));
        emit log_named_uint("evaluate 2 Literals + Tuple, gas       ", tupleNode);
        // One Literal node under 13k, each further Literal under 5k, a
        // two-word Tuple node under 30k on top of its literals (26.2k measured).
        assertLt(costs[0], 13_000);
        assertLt((costs[3] - costs[0]) / 3, 5_000);
        assertLt(tupleNode - costs[1], 30_000);
    }
}
