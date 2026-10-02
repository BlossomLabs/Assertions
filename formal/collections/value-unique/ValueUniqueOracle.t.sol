// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract ValueUniqueOracleTest {
    Collections private c = new Collections();
    error Bomb(uint256 a, uint256 b);

    function equal(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }

    function less(uint256 a, uint256 b) external pure returns (bool) {
        return a < b;
    }

    function poison(uint256 a, uint256 b) external pure returns (bool) {
        if (a == 9 && b == 1) revert Bomb(a, b);
        return a == b;
    }

    function bad(uint256 a, uint256 b) external pure returns (uint256) {
        return a == 4 && b == 9 ? 2 : 0;
    }

    function failing(uint256 a, uint256 b) external pure returns (bool) {
        if (a == 4 && b == 9) revert Bomb(a, b);
        return false;
    }

    function longReply(uint256, uint256) external pure returns (uint256, uint256) {
        return (1, 0);
    }

    function textEqual(string calldata a, string calldata b, uint256 salt) external pure returns (bool) {
        require(salt == 17);
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function evaluateEncoded(bytes calldata expression, bytes[] calldata slots) external view {
        require(
            msg.sender == address(c) && keccak256(expression) == keccak256(hex"abcd") && slots.length == 2,
            "expression wire"
        );
        uint256 answer = abi.decode(slots[0], (uint256)) == abi.decode(slots[1], (uint256)) ? 1 : 0;
        assembly ("memory-safe") {
            mstore(0, answer)
            return(0, 32)
        }
    }

    function cb() private view returns (Collections.Callback memory) {
        return Collections.Callback(address(this), this.equal.selector, "(uint256,uint256)", new bytes[](2), 0, 1, "");
    }

    function values(uint256 a, uint256 b, uint256 d) private pure returns (bytes[] memory v) {
        v = new bytes[](3);
        v[0] = abi.encode(a);
        v[1] = abi.encode(b);
        v[2] = abi.encode(d);
    }

    function one(uint256 a) private pure returns (bytes[] memory v) {
        v = new bytes[](1);
        v[0] = abi.encode(a);
    }

    function check(bytes[] memory actual, bytes[] memory expected) private pure {
        require(keccak256(abi.encode(actual)) == keccak256(abi.encode(expected)), "original stable encodings");
    }

    function fail(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected unique failure");
        require(keccak256(ret) == keccak256(expected), "wrong exact unique error");
    }

    function invalid(uint256 offset) private pure returns (bytes memory) {
        return abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset);
    }

    function testUnorderedStableOriginalValuesAndShrink() public view {
        bytes[] memory v = new bytes[](5);
        v[0] = abi.encode(uint256(3));
        v[1] = abi.encode(uint256(1));
        v[2] = v[0];
        v[3] = abi.encode(type(uint256).max);
        v[4] = v[1];
        check(c.uniqueValues("uint256", v, cb(), false), values(3, 1, type(uint256).max));
    }

    function testOrderedRunStartsAndTrustedGrouping() public view {
        bytes[] memory v = new bytes[](5);
        v[0] = abi.encode(uint256(3));
        v[1] = v[0];
        v[2] = abi.encode(uint256(1));
        v[3] = v[2];
        v[4] = abi.encode(uint256(2));
        check(c.uniqueValues("uint256", v, cb(), true), values(3, 1, 2));
        check(c.uniqueValues("uint256", values(3, 1, 3), cb(), true), values(3, 1, 3));
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(uint256(3));
        expected[1] = abi.encode(uint256(1));
        check(c.uniqueValues("uint256", values(3, 1, 3), cb(), false), expected);
    }

    function testRetainedCandidateOrientationWithAsymmetricPredicate() public view {
        Collections.Callback memory callback = cb();
        callback.selector = this.less.selector;
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(uint256(3));
        expected[1] = abi.encode(uint256(1));
        check(c.uniqueValues("uint256", values(3, 1, 2), callback, false), expected);
    }

    function testFirstTrueStopsBeforeLaterPoisonComparison() public view {
        Collections.Callback memory callback = cb();
        callback.selector = this.poison.selector;
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(uint256(1));
        expected[1] = abi.encode(uint256(9));
        check(c.uniqueValues("uint256", values(1, 9, 1), callback, false), expected);
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", values(1, 9, 1), callback, true)),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                c.uniqueValues.selector,
                uint256(2),
                uint256(1),
                address(this),
                abi.encodeCall(this.poison, (uint256(9), uint256(1))),
                abi.encodeWithSelector(Bomb.selector, uint256(9), uint256(1))
            )
        );
    }

    function testEmptyAndSingletonNeverCheckTargetOrCompare() public view {
        Collections.Callback memory callback = cb();
        callback.target = address(0x1234);
        check(c.uniqueValues("uint8", new bytes[](0), callback, false), new bytes[](0));
        check(c.uniqueValues("uint8", one(7), callback, false), one(7));
        check(c.uniqueValues("uint8", one(7), callback, true), one(7));
    }

    function testEveryCandidateValidatedBeforeComparisons() public view {
        fail(abi.encodeCall(c.uniqueValues, ("uint8", values(1, 256, 1), cb(), false)), invalid(0));
        fail(abi.encodeCall(c.uniqueValues, ("uint8", one(256), cb(), false)), invalid(0));
        bytes[] memory v = new bytes[](1);
        v[0] = abi.encode(uint256(1), uint256(2));
        fail(abi.encodeCall(c.uniqueValues, ("(uint8,bool)", v, cb(), false)), invalid(32));
    }

    function testRawBinaryAdmissionBeforeInputDescriptor() public view {
        Collections.Callback memory callback = cb();
        callback.second = callback.first;
        fail(
            abi.encodeCall(c.uniqueValues, ("()", new bytes[](0), callback, false)),
            abi.encodeWithSelector(Collections.InvalidCallback.selector)
        );
    }

    function testDescriptorValidationOnEmpty() public view {
        fail(
            abi.encodeCall(c.uniqueValues, ("()", new bytes[](0), cb(), false)),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1))
        );
    }

    function testConstantsValidatedEvenOnEmpty() public view {
        Collections.Callback memory callback = cb();
        callback.arguments = "(uint256,uint256,uint8)";
        callback.constants = new bytes[](3);
        callback.constants[2] = abi.encode(uint256(256));
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", new bytes[](0), callback, false)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(2), uint256(0))
        );
    }

    function testCandidateValidationBeforeLazyTargetFailure() public view {
        Collections.Callback memory callback = cb();
        callback.target = address(0x1234);
        fail(abi.encodeCall(c.uniqueValues, ("uint8", values(1, 256, 2), callback, false)), invalid(0));
        fail(
            abi.encodeCall(c.uniqueValues, ("uint8", values(1, 2, 3), callback, false)),
            abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, callback.target)
        );
    }

    function testStrictBooleanExactCandidateAndRetainedOrdinal() public view {
        Collections.Callback memory callback = cb();
        callback.selector = this.bad.selector;
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", values(1, 4, 9), callback, false)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.uniqueValues.selector, uint256(2), uint256(1), address(this)
            )
        );
    }

    function testStrictReplyLength() public view {
        Collections.Callback memory callback = cb();
        callback.selector = this.longReply.selector;
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", values(1, 2, 3), callback, false)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.uniqueValues.selector, uint256(1), uint256(0), address(this)
            )
        );
    }

    function testOrdinaryFailureExactPayloadAndContext() public view {
        Collections.Callback memory callback = cb();
        callback.selector = this.failing.selector;
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", values(1, 4, 9), callback, false)),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                c.uniqueValues.selector,
                uint256(2),
                uint256(1),
                address(this),
                abi.encodeCall(this.failing, (uint256(4), uint256(9))),
                abi.encodeWithSelector(Bomb.selector, uint256(4), uint256(9))
            )
        );
    }

    function testBothBoundComponentsValidatedBeforeCall() public view {
        Collections.Callback memory callback = cb();
        callback.arguments = "(uint8,uint256)";
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", values(256, 1, 2), callback, false)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0))
        );
        callback.arguments = "(uint256,uint8)";
        fail(
            abi.encodeCall(c.uniqueValues, ("uint256", values(1, 256, 2), callback, false)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0))
        );
    }

    function testDynamicEncodingsAndConstantPreservation() public view {
        bytes[] memory v = new bytes[](3);
        v[0] = abi.encode("longer than one word of dynamic string content");
        v[1] = abi.encode("a");
        v[2] = v[0];
        Collections.Callback memory callback = cb();
        callback.selector = this.textEqual.selector;
        callback.arguments = "(string,string,uint256)";
        callback.constants = new bytes[](3);
        callback.constants[2] = abi.encode(uint256(17));
        bytes[] memory expected = new bytes[](2);
        expected[0] = v[0];
        expected[1] = v[1];
        check(c.uniqueValues("string", v, callback, false), expected);
    }

    function testExpressionBinaryWireAndIgnoredSelector() public view {
        Collections.Callback memory callback = cb();
        callback.expression = hex"abcd";
        callback.selector = this.bad.selector;
        bytes[] memory expected = new bytes[](2);
        expected[0] = abi.encode(uint256(1));
        expected[1] = abi.encode(uint256(2));
        check(c.uniqueValues("uint256", values(1, 2, 1), callback, false), expected);
    }
}
