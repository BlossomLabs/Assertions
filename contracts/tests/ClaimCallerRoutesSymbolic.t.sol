// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import "../Expressions.sol";

contract ClaimRoutesOracle {
    function caller(uint256, uint256) external view returns (address) {
        return msg.sender;
    }

    function context(uint256, uint256, address expected) external view returns (bool) {
        return msg.sender == expected;
    }

    function compare(uint256 a, uint256 b, address expected) external view returns (int256) {
        require(msg.sender == expected, "caller");
        return a < b ? int256(-1) : a > b ? int256(1) : int256(0);
    }
}

/**
 * @notice L74's remaining word and value callback entry points, and every
 *         value callback through a Call graph with an optional successful
 *         TryOrElse boundary. Input words are unrestricted; sizes are fixed.
 */
contract ClaimCallerRoutesSymbolicTest is Test {
    Collections collections;
    Expressions expressions;
    ClaimRoutesOracle oracle;

    function setUp() public {
        collections = new Collections();
        expressions = new Expressions();
        oracle = new ClaimRoutesOracle();
    }

    function check_extendedWordCallerRoutes(bytes32 a, bytes32 b, bytes32 init, bytes3 raw, uint8 route) public view {
        vm.assume(route < 3);
        uint256[] memory windows = new uint256[](1);
        windows[0] = 4;
        bytes memory template = abi.encodeCall(ClaimRoutesOracle.caller, (0, 0));
        bytes memory callData;
        if (route == 0) {
            callData = abi.encodeCall(
                Collections.foldRange, (3, address(oracle), template, 36, windows, init, Collections.FoldExit.Full)
            );
        } else if (route == 1) {
            callData = abi.encodeCall(
                Collections.foldBytes,
                (abi.encodePacked(raw), address(oracle), template, 36, windows, init, Collections.FoldExit.Full)
            );
        } else {
            callData = abi.encodeCall(
                Collections.filterWords,
                (
                    abi.encode(a, b),
                    address(oracle),
                    abi.encodeCall(ClaimRoutesOracle.context, (0, 0, address(collections))),
                    windows
                )
            );
        }
        bytes memory out = succeeds(callData);
        if (route == 2) assertEq(abi.decode(out, (bytes)), abi.encode(a, b));
        else assertEq(abi.decode(out, (bytes32)), bytes32(uint256(uint160(address(collections)))));
    }

    function check_extendedDirectValueCallerRoutes(bytes32 a, bytes32 b, uint8 route, bool ordered) public view {
        vm.assume(route < 9);
        Collections.Callback memory cb = callback(route);
        exercise(a, b, route, ordered, cb, address(collections));
    }

    function check_extendedGraphValueCallerRoutes(bytes32 a, bytes32 b, uint8 route, bool guarded, bool ordered)
        public
        view
    {
        vm.assume(route < 9);
        Collections.Callback memory cb = callback(route);
        cb.target = address(expressions);
        cb.expression = graph(route, guarded);
        exercise(a, b, route, ordered, cb, address(expressions));
    }

    function exercise(bytes32 a, bytes32 b, uint8 route, bool ordered, Collections.Callback memory cb, address caller)
        internal
        view
    {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        bytes memory data;
        if (route == 0) {
            data = abi.encodeCall(Collections.mapValues, ("uint256", "address", values, cb));
        } else if (route == 1) {
            data = abi.encodeCall(Collections.foldValues, ("uint256", "address", values, abi.encode(address(0)), cb));
        } else if (route == 2) {
            data = abi.encodeCall(Collections.filterValues, ("uint256", values, cb));
        } else if (route == 3) {
            data = abi.encodeCall(Collections.anyValues, ("uint256", values, cb));
        } else if (route == 4) {
            data = abi.encodeCall(Collections.allValues, ("uint256", values, cb));
        } else if (route == 5) {
            data = abi.encodeCall(Collections.findValues, ("uint256", values, cb));
        } else if (route == 6) {
            data = abi.encodeCall(Collections.indexOfValues, ("uint256", values, abi.encode(a), cb));
        } else if (route == 7) {
            data = abi.encodeCall(Collections.uniqueValues, ("uint256", values, cb, ordered));
        } else {
            data = abi.encodeCall(Collections.sortValues, ("uint256", values, cb));
        }
        bytes memory out = succeeds(data);
        if (route == 0) {
            bytes[] memory got = abi.decode(out, (bytes[]));
            assertEq(got.length, 2);
            assertEq(got[0], abi.encode(caller));
            assertEq(got[1], abi.encode(caller));
        } else if (route == 1) {
            assertEq(abi.decode(out, (bytes)), abi.encode(caller));
        } else if (route == 2) {
            assertEq(out, abi.encode(values));
        } else if (route == 3 || route == 4) {
            assertTrue(abi.decode(out, (bool)));
        } else if (route == 5 || route == 6) {
            assertEq(abi.decode(out, (uint256)), 0);
        } else if (route == 7) {
            bytes[] memory got = abi.decode(out, (bytes[]));
            assertEq(got.length, 1);
            assertEq(got[0], abi.encode(a));
        } else {
            bytes[] memory got = abi.decode(out, (bytes[]));
            assertEq(got.length, 2);
            assertEq(got[0], abi.encode(uint256(a) <= uint256(b) ? a : b));
            assertEq(got[1], abi.encode(uint256(a) <= uint256(b) ? b : a));
        }
    }

    function callback(uint8 route) internal view returns (Collections.Callback memory cb) {
        cb.target = address(oracle);
        if (route < 2) {
            cb.selector = ClaimRoutesOracle.caller.selector;
            cb.arguments = route == 1 ? "(address,uint256)" : "(uint256,uint256)";
            cb.constants = new bytes[](2);
        } else {
            cb.selector = route == 8 ? ClaimRoutesOracle.compare.selector : ClaimRoutesOracle.context.selector;
            cb.arguments = "(uint256,uint256,address)";
            cb.constants = new bytes[](3);
            cb.constants[2] = abi.encode(address(collections));
        }
        cb.constants[0] = abi.encode(uint256(0));
        cb.constants[1] = abi.encode(uint256(0));
        cb.second = 1;
    }

    function graph(uint8 route, bool guarded) internal view returns (bytes memory) {
        string memory t = route < 2 ? "address" : route == 8 ? "int256" : "bool";
        Expressions.Node[] memory nodes = new Expressions.Node[](7);
        nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(oracle)));
        nodes[1] = node(Expressions.Kind.Literal, "address", abi.encode(address(expressions)));
        nodes[2] = node(Expressions.Kind.Parameter, "uint256", abi.encode(uint256(0)));
        nodes[3] = node(Expressions.Kind.Parameter, "uint256", abi.encode(uint256(1)));
        nodes[4] = node(Expressions.Kind.Call, t, "");
        nodes[4].refs = new uint256[](route < 2 ? 3 : 4);
        nodes[4].refs[0] = 0;
        nodes[4].refs[1] = 2;
        nodes[4].refs[2] = 3;
        if (route >= 2) nodes[4].refs[3] = 1;
        nodes[4].arguments = route < 2 ? "(uint256,uint256)" : "(uint256,uint256,address)";
        nodes[4].selector = route < 2
            ? ClaimRoutesOracle.caller.selector
            : route == 8 ? ClaimRoutesOracle.compare.selector : ClaimRoutesOracle.context.selector;
        nodes[5] = node(Expressions.Kind.Literal, t, abi.encode(uint256(0)));
        nodes[6] = node(Expressions.Kind.TryOrElse, t, "");
        nodes[6].refs = new uint256[](2);
        nodes[6].refs[0] = 4;
        nodes[6].refs[1] = 5;
        return abi.encode(Expressions.Expression(address(0), nodes, guarded ? 6 : 4));
    }

    function node(Expressions.Kind kind, string memory t, bytes memory data)
        internal
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = kind;
        n.valueType = t;
        n.data = data;
        n.refs = new uint256[](0);
    }

    function succeeds(bytes memory data) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = address(collections).staticcall(data);
        assertTrue(ok);
    }

    function test_extendedCallerSamples() public view {
        for (uint8 i; i < 9; i++) {
            check_extendedDirectValueCallerRoutes(bytes32(uint256(9)), bytes32(uint256(7)), i, false);
            check_extendedGraphValueCallerRoutes(bytes32(uint256(9)), bytes32(uint256(7)), i, true, true);
        }
        for (uint8 i; i < 3; i++) {
            check_extendedWordCallerRoutes(bytes32(uint256(9)), bytes32(uint256(7)), bytes32(0), bytes3(0xabcdef), i);
        }
    }
}
