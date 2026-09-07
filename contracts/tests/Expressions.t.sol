// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Expressions.sol";
import "../Collections.sol";
import "../Operations.sol";
import "../lib/ERC8211.sol";

contract ExpressionsTest is Test {
    Expressions expressions;
    Assertions core;
    Collections collections;
    Operations operations;

    function setUp() public {
        expressions = new Expressions();
        core = new Assertions();
        collections = new Collections();
        operations = new Operations();
    }

    function source() external pure returns (string memory) {
        return "dynamic value longer than one ABI word";
    }

    function append(string memory a, string memory b) external pure returns (string memory) {
        return string.concat(a, b);
    }

    function bomb() external pure returns (string memory) {
        revert("unused");
    }

    function six(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f)
        external
        pure
        returns (string memory)
    {
        return string.concat(a, b, c, d, e, f);
    }

    function nonempty(string memory a) external pure returns (bool) {
        require(keccak256(bytes(a)) != keccak256("bomb"));
        return bytes(a).length != 0;
    }

    function equal(string memory a, string memory b) external pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function literal(bytes memory data) private pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function live(bytes memory data) private view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(this), data),
            new Constraint[](0)
        );
    }

    function run(Expressions.Expression memory p, bytes[] memory params) private view returns (bytes memory out) {
        bool ok;
        (ok, out) = address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (p, params)));
        if (!ok) assembly { revert(add(out, 32), mload(out)) }
    }

    function node(Expressions.Kind kind, string memory valueType, bytes memory data)
        private
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = kind;
        n.valueType = valueType;
        n.data = data;
    }

    function callNode(string memory valueType, bytes4 selector, string memory arguments, uint256[] memory refs)
        private
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = Expressions.Kind.Call;
        n.valueType = valueType;
        n.selector = selector;
        n.arguments = arguments;
        n.refs = refs;
    }

    function refs2(uint256 a, uint256 b) private pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[0] = a;
        r[1] = b;
    }

    function refs3(uint256 a, uint256 b, uint256 c) private pure returns (uint256[] memory r) {
        r = new uint256[](3);
        r[0] = a;
        r[1] = b;
        r[2] = c;
    }

    function testResolveSixDynamicArgumentsAndValuesOnce() public {
        InputParam[] memory args = new InputParam[](6);
        for (uint256 i; i < 6; i++) {
            args[i] = live(abi.encodeCall(this.source, ()));
        }
        vm.expectCall(address(this), abi.encodeCall(this.source, ()), uint64(19));
        (bool ok, bytes memory out) = address(expressions)
            .staticcall(
                abi.encodeCall(
                    Expressions.resolveCall,
                    (
                        address(core),
                        literal(abi.encode(address(this))),
                        this.six.selector,
                        "(string,string,string,string,string,string)",
                        args
                    )
                )
            );
        assertTrue(ok);
        string memory value = this.source();
        assertEq(abi.decode(out, (string)), string.concat(value, value, value, value, value, value));
        bytes[] memory values = expressions.resolveValues(address(core), args);
        assertEq(values.length, 6);
        assertEq(values[5], abi.encode(value));
        (ok, out) = address(expressions)
            .staticcall(
                abi.encodeCall(
                    Expressions.resolveArguments,
                    (address(core), "(string,string,string,string,string,string)", args)
                )
            );
        assertTrue(ok);
        assertEq(out, abi.encode(value, value, value, value, value, value));
    }

    function testGraphMemoizesSharedDynamicCallAndLazyBranch() public {
        Expressions.Expression memory p;
        p.core = address(core);
        p.nodes = new Expressions.Node[](6);
        p.result = 5;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        uint256[] memory target = new uint256[](1);
        target[0] = 0;
        p.nodes[1] = callNode("string", this.source.selector, "()", target);
        p.nodes[2] = callNode("string", this.append.selector, "(string,string)", refs3(0, 1, 1));
        p.nodes[3] = callNode("string", this.bomb.selector, "()", target);
        p.nodes[4] = node(Expressions.Kind.Literal, "bool", abi.encode(true));
        p.nodes[5] = node(Expressions.Kind.Select, "string", "");
        p.nodes[5].refs = refs3(4, 2, 3);
        vm.expectCall(address(this), abi.encodeCall(this.source, ()), uint64(1));
        bytes memory out = run(p, new bytes[](0));
        assertEq(
            abi.decode(out, (string)), "dynamic value longer than one ABI worddynamic value longer than one ABI word"
        );
    }

    function testGraphRejectsForwardReferenceAndInvalidTarget() public {
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](2);
        p.result = 1;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(type(uint256).max));
        p.nodes[1] = callNode("string", this.source.selector, "()", refs2(0, 1));
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidReference.selector, 1, 1));
        this.externalRun(p);
        uint256[] memory r = new uint256[](1);
        r[0] = 0;
        p.nodes[1].refs = r;
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, 1));
        this.externalRun(p);
    }

    function externalRun(Expressions.Expression calldata p) external view {
        run(p, new bytes[](0));
    }

    // Node 0 target, node 1 then (a bomb call or the literal "then"), node 2 the literal "else",
    // node 3 the condition literal, node 4 the Select.
    function selectGraph(string memory conditionType, bytes memory condition, bool thenBombs)
        private
        view
        returns (Expressions.Expression memory p)
    {
        p.core = address(core);
        p.nodes = new Expressions.Node[](5);
        p.result = 4;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        uint256[] memory target = new uint256[](1);
        target[0] = 0;
        if (thenBombs) p.nodes[1] = callNode("string", this.bomb.selector, "()", target);
        else p.nodes[1] = node(Expressions.Kind.Literal, "string", abi.encode("then"));
        p.nodes[2] = node(Expressions.Kind.Literal, "string", abi.encode("else"));
        p.nodes[3] = node(Expressions.Kind.Literal, conditionType, condition);
        p.nodes[4] = node(Expressions.Kind.Select, "string", "");
        p.nodes[4].refs = refs3(3, 1, 2);
    }

    function testSelectFalseTakesElseWithoutEvaluatingThen() public view {
        Expressions.Expression memory p = selectGraph("bool", abi.encode(false), true);
        assertEq(abi.decode(run(p, new bytes[](0)), (string)), "else");
    }

    function testSelectAcceptsAnyNonzeroFirstWord() public view {
        Expressions.Expression memory p = selectGraph("uint256", abi.encode(uint256(7)), false);
        assertEq(abi.decode(run(p, new bytes[](0)), (string)), "then");
    }

    function testSelectJudgesFirstWordOfMultiWordCondition() public view {
        Expressions.Expression memory p = selectGraph("(uint256,uint256)", abi.encode(uint256(0), uint256(9)), false);
        assertEq(abi.decode(run(p, new bytes[](0)), (string)), "else");
        p.nodes[3].data = abi.encode(uint256(7), uint256(0));
        assertEq(abi.decode(run(p, new bytes[](0)), (string)), "then");
    }

    function testSelectRejectsConditionShorterThanOneWord() public {
        Expressions.Expression memory p = selectGraph("uint256[0]", "", false);
        vm.expectRevert(abi.encodeWithSelector(Expressions.InvalidNode.selector, 4));
        this.externalRun(p);
    }

    function testComposedDynamicCallbackRepeatsParameter() public view {
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](5);
        p.result = 4;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        p.nodes[1] = node(Expressions.Kind.Parameter, "string", abi.encode(uint256(0)));
        p.nodes[2] = node(Expressions.Kind.Parameter, "string", abi.encode(uint256(1)));
        p.nodes[3] = callNode("string", this.append.selector, "(string,string)", refs3(0, 1, 1));
        p.nodes[4] = callNode("string", this.append.selector, "(string,string)", refs3(0, 3, 2));
        Collections.Callback memory cb;
        cb.target = address(expressions);
        cb.arguments = "(string,string)";
        cb.constants = new bytes[](2);
        cb.constants[1] = abi.encode("!");
        cb.first = 0;
        cb.expression = abi.encode(p);
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode("ab");
        v[1] = abi.encode("a value with more than thirty-two bytes");
        bytes[] memory out = collections.mapValues("string", "string", v, cb);
        assertEq(abi.decode(out[0], (string)), "abab!");
        assertEq(
            abi.decode(out[1], (string)),
            "a value with more than thirty-two bytesa value with more than thirty-two bytes!"
        );
    }

    function predicateCallback() private view returns (Collections.Callback memory cb) {
        cb.target = address(this);
        cb.selector = this.nonempty.selector;
        cb.arguments = "(string)";
        cb.constants = new bytes[](1);
    }

    function testGenericTraversalSliceZipAndShortCircuit() public view {
        bytes[] memory v = new bytes[](3);
        v[0] = abi.encode("a");
        v[1] = abi.encode("b");
        v[2] = abi.encode("c");
        assertEq(collections.reverseValues("string", v)[0], v[2]);
        bytes[] memory sliced = collections.sliceValues("string", v, -2, 99);
        assertEq(sliced.length, 2);
        assertEq(sliced[0], v[1]);
        assertEq(collections.sliceValues("string", v, 2, 1).length, 0);
        assertEq(collections.sliceValues("string", v, type(int256).min, -2)[0], v[0]);
        bytes[] memory zipped = collections.zipValues("string", "string", v, v);
        assertEq(zipped[0], abi.encode(StringPair("a", "a")));
        Collections.Callback memory cb = predicateCallback();
        v[1] = abi.encode("bomb");
        assertTrue(collections.anyValues("string", v, cb));
        assertEq(collections.findValues("string", v, cb), 0);
        v[0] = abi.encode("");
        assertFalse(collections.allValues("string", v, cb));
        assertTrue(collections.allValues("string", new bytes[](0), cb));
        assertFalse(collections.anyValues("string", new bytes[](0), cb));
        v[1] = abi.encode("b");
        cb.selector = this.equal.selector;
        cb.arguments = "(string,string)";
        cb.constants = new bytes[](2);
        cb.second = 1;
        assertEq(collections.indexOfValues("string", v, abi.encode("b"), cb), 1);
        assertEq(collections.indexOfValues("string", v, abi.encode("none"), cb), type(uint256).max);
    }

    struct StringPair {
        string a;
        string b;
    }

    function testGuardedGraphFallbackAndSuccessfulCacheMerge() public {
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](5);
        p.result = 4;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        uint256[] memory target = new uint256[](1);
        target[0] = 0;
        p.nodes[1] = callNode("string", this.source.selector, "()", target);
        p.nodes[2] = callNode("string", this.bomb.selector, "()", target);
        p.nodes[3] = node(Expressions.Kind.TryOrElse, "string", "");
        p.nodes[3].refs = refs2(1, 2);
        p.nodes[4] = callNode("string", this.append.selector, "(string,string)", refs3(0, 3, 1));
        vm.expectCall(address(this), abi.encodeCall(this.source, ()), uint64(1));
        assertEq(
            abi.decode(run(p, new bytes[](0)), (string)),
            "dynamic value longer than one ABI worddynamic value longer than one ABI word"
        );
    }

    function testGuardedGraphFailureAndValidity() public view {
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](5);
        p.result = 3;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        uint256[] memory target = new uint256[](1);
        target[0] = 0;
        p.nodes[1] = callNode("string", this.bomb.selector, "()", target);
        p.nodes[2] = node(Expressions.Kind.Literal, "string", abi.encode("fallback"));
        p.nodes[3] = node(Expressions.Kind.TryOrElse, "string", "");
        p.nodes[3].refs = refs2(1, 2);
        p.nodes[4] = node(Expressions.Kind.IsValid, "bool", "");
        p.nodes[4].refs = new uint256[](1);
        p.nodes[4].refs[0] = 1;
        assertEq(abi.decode(run(p, new bytes[](0)), (string)), "fallback");
        p.result = 4;
        assertFalse(abi.decode(run(p, new bytes[](0)), (bool)));
        p.nodes[4].refs[0] = 3;
        assertTrue(abi.decode(run(p, new bytes[](0)), (bool)));
    }

    function testGraphAbiConstructors() public view {
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](5);
        p.result = 4;
        p.nodes[0] = node(Expressions.Kind.Literal, "string", abi.encode("abc"));
        p.nodes[1] = node(Expressions.Kind.Wrap, "bytes", "");
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].refs[0] = 0;
        p.nodes[2] = node(Expressions.Kind.Array, "bytes[]", "");
        p.nodes[2].arguments = "bytes";
        p.nodes[2].refs = refs2(1, 1);
        p.nodes[3] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(7)));
        p.nodes[4] = node(Expressions.Kind.Tuple, "(uint256,bytes[])", "");
        p.nodes[4].arguments = "(uint256,bytes[])";
        p.nodes[4].refs = refs2(3, 2);
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode("abc");
        values[1] = abi.encode("abc");
        assertEq(run(p, new bytes[](0)), abi.encode(Constructed(7, values)));
    }

    struct Constructed {
        uint256 number;
        bytes[] values;
    }

    function testUnzipBothDynamicAndStaticLanes() public {
        bytes[] memory strings = new bytes[](2);
        strings[0] = abi.encode("odd");
        strings[1] = abi.encode("longer than a single ABI word of data!");
        bytes[] memory numbers = new bytes[](2);
        numbers[0] = abi.encode(uint256(5));
        numbers[1] = abi.encode(uint256(9));
        bytes[] memory pairs = collections.zipValues("string", "uint256", strings, numbers);
        bytes[] memory left = collections.unzipValues("string", "uint256", pairs, 0);
        bytes[] memory right = collections.unzipValues("string", "uint256", pairs, 1);
        assertEq(left[1], strings[1]);
        assertEq(right[0], numbers[0]);
        pairs = collections.zipValues("uint256", "string", numbers, strings);
        assertEq(collections.unzipValues("uint256", "string", pairs, 1)[1], strings[1]);
        pairs = collections.zipValues("string", "string", strings, strings);
        assertEq(collections.unzipValues("string", "string", pairs, 0)[0], strings[0]);
        assertEq(collections.unzipValues("string", "string", pairs, 1)[1], strings[1]);
        pairs[0] = bytes.concat(pairs[0], abi.encode(uint256(0)));
        vm.expectRevert();
        collections.unzipValues("string", "string", pairs, 0);
        pairs = collections.zipValues("uint256", "uint256", numbers, numbers);
        assertEq(collections.unzipValues("uint256", "uint256", pairs, 1)[1], numbers[1]);
    }

    function testByteRangesAndUtf8Boundaries() public {
        bytes memory value = hex"61c3a9f09f988062";
        assertEq(operations.sliceRange(value, -2, type(int256).max), hex"8062");
        assertEq(operations.byteAt(value, -1), bytes("b"));
        assertEq(operations.stringSlice(value, 1, 3), hex"c3a9");
        assertEq(operations.stringSlice(value, 3, 7), hex"f09f9880");
        assertEq(operations.stringAt(value, -1), bytes("b"));
        vm.expectRevert();
        operations.stringSlice(value, 2, 3);
        vm.expectRevert();
        operations.stringAt(value, 1);
        vm.expectRevert();
        operations.byteAt(value, type(int256).min);
        vm.expectRevert();
        operations.stringSlice(hex"eda080", 0, 0);
        vm.expectRevert();
        operations.stringSlice(hex"f4908080", 0, 4);
        vm.expectRevert();
        operations.stringSlice(hex"c080", 0, 2);
        vm.expectRevert();
        operations.stringSlice(hex"e282", 0, 2);
        assertEq(operations.stringSlice(hex"efbbbf61", 0, 3), hex"efbbbf");
    }

    error ProbeReason(string value);
    error EmptyProbeReason();

    function failWith(string calldata value) external pure {
        revert ProbeReason(value);
    }

    function failEmpty() external pure {
        revert EmptyProbeReason();
    }

    function testProbeCallPreservesUnderlyingDynamicReason() public {
        Expressions.Expression memory p;
        p.nodes = new Expressions.Node[](3);
        p.result = 2;
        p.nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        p.nodes[1] =
            node(
            Expressions.Kind.Literal, "bytes", abi.encode(abi.encodeCall(this.failWith, ("dynamic reason")))
        );
        p.nodes[2] = node(Expressions.Kind.ProbeCall, "bytes", "");
        p.nodes[2].refs = refs2(0, 1);
        p.nodes[2].selector = ProbeReason.selector;
        assertEq(abi.decode(run(p, new bytes[](0)), (bytes)), abi.encode("dynamic reason"));
        p.nodes[2].selector = bytes4(0);
        assertEq(
            abi.decode(run(p, new bytes[](0)), (bytes)), abi.encodeWithSelector(ProbeReason.selector, "dynamic reason")
        );
        p.nodes[2].selector = EmptyProbeReason.selector;
        vm.expectRevert(
            abi.encodeWithSelector(
                Assertions.UnexpectedRevertData.selector, EmptyProbeReason.selector, ProbeReason.selector
            )
        );
        this.externalRun(p);
        p.nodes[1].data = abi.encode(abi.encodeCall(this.failEmpty, ()));
        assertEq(abi.decode(run(p, new bytes[](0)), (bytes)), bytes(""));
        p.nodes[1].data = abi.encode(abi.encodeCall(this.source, ()));
        vm.expectRevert(
            abi.encodeWithSelector(Assertions.DidNotRevert.selector, address(this), abi.encodeCall(this.source, ()))
        );
        this.externalRun(p);
        p.nodes[0].data = abi.encode(address(0xdead));
        p.nodes[2].selector = bytes4(0);
        assertEq(abi.decode(run(p, new bytes[](0)), (bytes)), bytes(""));
    }

    function testRestoredMathAndContains() public view {
        assertEq(operations.expWad(0), 1e18);
        assertEq(operations.lnWad(1e18), 0);
        assertTrue(operations.contains("", ""));
        assertTrue(operations.contains("abc", ""));
        assertTrue(operations.contains("abc", "bc"));
        assertFalse(operations.contains("", "a"));
        assertFalse(operations.contains("abc", "abcd"));
    }
}
