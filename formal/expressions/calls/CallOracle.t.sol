// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Expressions} from "../../../contracts/Expressions.sol";

contract ReceiptTarget {
    function good() external pure returns (uint256) {
        return 73;
    }

    fallback() external {
        assembly {
            calldatacopy(0, 4, sub(calldatasize(), 4))
            revert(0, sub(calldatasize(), 4))
        }
    }
}

contract CallOracleTest {
    Expressions private evaluator = new Expressions();
    ReceiptTarget private target = new ReceiptTarget();

    function callGraph(address to, bytes4 selector) private pure returns (Expressions.Expression memory p) {
        p.nodes = new Expressions.Node[](2);
        p.result = 1;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(to);
        p.nodes[1].kind = Expressions.Kind.Call;
        p.nodes[1].valueType = "uint256";
        p.nodes[1].refs = new uint256[](1);
        p.nodes[1].selector = selector;
        p.nodes[1].arguments = "()";
    }

    function probeGraph(address to, bytes memory data, bytes4 expected)
        private
        pure
        returns (Expressions.Expression memory p)
    {
        p.nodes = new Expressions.Node[](3);
        p.result = 2;
        p.nodes[0].valueType = "address";
        p.nodes[0].data = abi.encode(to);
        p.nodes[1].valueType = "bytes";
        p.nodes[1].data = abi.encode(data);
        p.nodes[2].kind = Expressions.Kind.ProbeCall;
        p.nodes[2].valueType = "bytes";
        p.nodes[2].refs = new uint256[](2);
        p.nodes[2].refs[1] = 1;
        p.nodes[2].selector = expected;
    }

    function check(Expressions.Expression memory p, bool wanted, bytes memory expected) private view {
        (bool ok, bytes memory result) =
            address(evaluator).staticcall(abi.encodeCall(evaluator.evaluate, (p, new bytes[](0))));
        require(ok == wanted, "verdict");
        require(keccak256(result) == keccak256(expected), "exact receipt");
    }

    function testCallSuccess() public view {
        check(callGraph(address(target), target.good.selector), true, abi.encode(uint256(73)));
    }

    function testCallFailureFields() public view {
        check(
            callGraph(address(target), 0x12345678),
            false,
            abi.encodeWithSelector(
                Expressions.NodeCallFailed.selector, uint256(1), address(target), hex"12345678", bytes("")
            )
        );
    }

    function testCallNoCode() public view {
        check(
            callGraph(address(0x1234), 0x12345678),
            false,
            abi.encodeWithSelector(Expressions.InvalidTarget.selector, uint256(1), address(0x1234))
        );
    }

    function testProbeSuccessRejected() public view {
        check(
            probeGraph(address(target), abi.encodeCall(target.good, ()), 0),
            false,
            abi.encodeWithSelector(Expressions.DidNotRevert.selector, address(target), abi.encodeCall(target.good, ()))
        );
    }

    function testProbeCodeLess() public view {
        check(probeGraph(address(0x1234), hex"12345678", 0), true, abi.encode(bytes("")));
        check(
            probeGraph(address(0x1234), hex"12345678", 0x01020304),
            false,
            abi.encodeWithSelector(Expressions.UnexpectedRevertData.selector, bytes4(0x01020304), bytes4(0))
        );
    }

    function testProbeSelectorMatchAndStrip() public view {
        check(probeGraph(address(target), hex"1234567801020304aabbcc", 0x01020304), true, abi.encode(hex"aabbcc"));
        check(probeGraph(address(target), hex"1234567801020304", 0x01020304), true, abi.encode(bytes("")));
    }

    function testProbeMismatchAndShort() public view {
        check(
            probeGraph(address(target), hex"1234567801020304aa", 0xaabbccdd),
            false,
            abi.encodeWithSelector(Expressions.UnexpectedRevertData.selector, bytes4(0xaabbccdd), bytes4(0x01020304))
        );
        check(
            probeGraph(address(target), hex"12345678010203", 0xaabbccdd),
            false,
            abi.encodeWithSelector(Expressions.UnexpectedRevertData.selector, bytes4(0xaabbccdd), bytes4(0))
        );
    }

    function testProbeWildcardAndMarker() public view {
        check(probeGraph(address(target), hex"1234567801020304aa", 0), true, abi.encode(hex"01020304aa"));
        check(
            probeGraph(address(target), hex"12345678d271060e", 0),
            false,
            abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector)
        );
    }

    function testForbiddenBeforeNoCodeOrCall() public view {
        check(
            callGraph(address(evaluator), evaluator.evaluateGuarded.selector),
            false,
            abi.encodeWithSelector(Expressions.GuardedCallForbidden.selector)
        );
        check(
            probeGraph(address(evaluator), abi.encodePacked(evaluator.evaluateGuarded.selector), 0),
            false,
            abi.encodeWithSelector(Expressions.GuardedCallForbidden.selector)
        );
    }
}
