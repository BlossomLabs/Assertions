// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract ValueSearchOracleTest {
    Collections private c = new Collections();
    error Bomb(uint256 value);

    function predicate(uint256 value) external pure returns (bool) {
        if (value == 99) revert Bomb(value);
        return value >= 7;
    }

    function equal(uint256 value, uint256 needle) external pure returns (bool) {
        return value == needle;
    }

    function dirty(uint256) external pure returns (uint256) {
        return 2;
    }

    function longReply(uint256) external pure returns (uint256, uint256) {
        return (1, 0);
    }

    function textPredicate(string calldata text, uint256 limit) external pure returns (bool) {
        return bytes(text).length >= limit;
    }

    function evaluateEncoded(bytes calldata expression, bytes[] calldata slots) external view {
        require(msg.sender == address(c) && keccak256(expression) == keccak256(hex"abcd"), "expression wire");
        require(slots.length == 1, "expression slots");
        uint256 answer = abi.decode(slots[0], (uint256)) >= 7 ? 1 : 0;
        assembly ("memory-safe") {
            mstore(0, answer)
            return(0, 32)
        }
    }

    function cb(bool binary) private view returns (Collections.Callback memory callback) {
        bytes[] memory constants = new bytes[](binary ? 2 : 1);
        callback = Collections.Callback(
            address(this),
            binary ? this.equal.selector : this.predicate.selector,
            binary ? "(uint256,uint256)" : "(uint256)",
            constants,
            0,
            1,
            ""
        );
    }

    function values(uint256 a, uint256 b, uint256 d) private pure returns (bytes[] memory out) {
        out = new bytes[](3);
        out[0] = abi.encode(a);
        out[1] = abi.encode(b);
        out[2] = abi.encode(d);
    }

    function fail(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected search failure");
        require(keccak256(ret) == keccak256(expected), "wrong exact search error");
    }

    function invalid(uint256 offset) private pure returns (bytes memory) {
        return abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset);
    }

    function testEmptySemanticsAndLazyNoCodeTarget() public view {
        bytes[] memory empty = new bytes[](0);
        Collections.Callback memory unary = cb(false);
        unary.target = address(0x1234);
        Collections.Callback memory binary = cb(true);
        binary.target = unary.target;
        require(!c.anyValues("uint8", empty, unary), "empty any");
        require(c.allValues("uint8", empty, unary), "empty all");
        require(c.findValues("uint8", empty, unary) == type(uint256).max, "empty find");
        require(c.indexOfValues("uint8", empty, abi.encode(uint256(7)), binary) == type(uint256).max, "empty index");
    }

    function testFirstDecisiveOriginalIndexAndFullWidthNeedle() public view {
        bytes[] memory v = values(1, type(uint256).max, type(uint256).max);
        require(c.indexOfValues("uint256", v, abi.encode(type(uint256).max), cb(true)) == 1, "first binary match");
        require(c.findValues("uint256", v, cb(false)) == 1, "first unary match");
        require(c.anyValues("uint256", v, cb(false)), "any match");
    }

    function testAllStopsAtFirstFalseBeforeRevertingCallback() public view {
        require(!c.allValues("uint256", values(7, 1, 99), cb(false)), "all first miss");
        require(c.allValues("uint256", values(7, 8, type(uint256).max), cb(false)), "all true");
    }

    function testMissingSentinelAndUnaryResults() public view {
        bytes[] memory v = values(1, 2, 3);
        require(c.findValues("uint256", v, cb(false)) == type(uint256).max, "find missing");
        require(c.indexOfValues("uint256", v, abi.encode(uint256(8)), cb(true)) == type(uint256).max, "index missing");
        require(!c.anyValues("uint256", v, cb(false)), "any missing");
    }

    function testShortCircuitSkipsLaterDirtyValueAndRevert() public view {
        bytes[] memory v = values(7, 256, 99);
        require(c.findValues("uint8", v, cb(false)) == 0, "find should stop");
        require(c.anyValues("uint8", v, cb(false)), "any should stop");
        require(c.indexOfValues("uint8", v, abi.encode(uint256(7)), cb(true)) == 0, "index should stop");
        require(!c.allValues("uint8", values(1, 256, 99), cb(false)), "all should stop");
    }

    function testReachedNarrowValidationAtEveryIndex() public view {
        bytes[] memory v = values(1, 256, 7);
        fail(abi.encodeCall(c.findValues, ("uint8", v, cb(false))), invalid(0));
        fail(abi.encodeCall(c.indexOfValues, ("uint8", v, abi.encode(uint256(7)), cb(true))), invalid(0));
    }

    function testFirstInvalidOriginalOffsetBeforePredicate() public view {
        bytes[] memory v = new bytes[](2);
        v[0] = abi.encode(uint256(1), uint256(2));
        v[1] = abi.encode(uint256(256), uint256(0));
        fail(abi.encodeCall(c.findValues, ("(uint8,bool)", v, cb(false))), invalid(32));
    }

    function testInvalidRawCallbackBeforeDescriptorAndNeedle() public view {
        bytes[] memory empty = new bytes[](0);
        Collections.Callback memory unary = cb(false);
        unary.first = 1;
        fail(
            abi.encodeCall(c.findValues, ("()", empty, unary)),
            abi.encodeWithSelector(Collections.InvalidCallback.selector)
        );
        Collections.Callback memory binary = cb(true);
        binary.second = 0;
        fail(
            abi.encodeCall(c.indexOfValues, ("()", empty, bytes(""), binary)),
            abi.encodeWithSelector(Collections.InvalidCallback.selector)
        );
    }

    function testRawDescriptorAndNeedleValidationOnEmpty() public view {
        bytes[] memory empty = new bytes[](0);
        fail(
            abi.encodeCall(c.anyValues, ("()", empty, cb(false))),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1))
        );
        fail(abi.encodeCall(c.indexOfValues, ("uint8", empty, abi.encode(uint256(256)), cb(true))), invalid(0));
    }

    function testLazyTargetFailureAfterInputValidation() public view {
        Collections.Callback memory unary = cb(false);
        unary.target = address(0x1234);
        fail(abi.encodeCall(c.findValues, ("uint8", values(256, 1, 2), unary)), invalid(0));
        fail(
            abi.encodeCall(c.findValues, ("uint8", values(1, 2, 3), unary)),
            abi.encodeWithSelector(Collections.InvalidCallbackTarget.selector, unary.target)
        );
    }

    function testStrictBooleanPacketAndOuterOperationSelectors() public view {
        Collections.Callback memory unary = cb(false);
        unary.selector = this.dirty.selector;
        bytes[] memory v = values(1, 2, 3);
        fail(
            abi.encodeCall(c.findValues, ("uint256", v, unary)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.findValues.selector, uint256(0), uint256(0), address(this)
            )
        );
        fail(
            abi.encodeCall(c.anyValues, ("uint256", v, unary)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.anyValues.selector, uint256(0), uint256(0), address(this)
            )
        );
        fail(
            abi.encodeCall(c.allValues, ("uint256", v, unary)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.allValues.selector, uint256(0), uint256(0), address(this)
            )
        );
    }

    function testStrictReplyLength() public view {
        Collections.Callback memory unary = cb(false);
        unary.selector = this.longReply.selector;
        fail(
            abi.encodeCall(c.findValues, ("uint256", values(1, 2, 3), unary)),
            abi.encodeWithSelector(
                AbiCodec.InvalidCallbackResult.selector, c.findValues.selector, uint256(0), uint256(0), address(this)
            )
        );
    }

    function testOrdinaryRevertExactReachedIndexAndWire() public view {
        fail(
            abi.encodeCall(c.findValues, ("uint256", values(1, 99, 7), cb(false))),
            abi.encodeWithSelector(
                Collections.CallbackFailed.selector,
                c.findValues.selector,
                uint256(1),
                uint256(0),
                address(this),
                abi.encodeCall(this.predicate, (uint256(99))),
                abi.encodeWithSelector(Bomb.selector, uint256(99))
            )
        );
    }

    function testBoundComponentFailureBeforeCall() public view {
        Collections.Callback memory unary = cb(false);
        unary.arguments = "(uint8)";
        fail(
            abi.encodeCall(c.findValues, ("uint256", values(256, 1, 2), unary)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), uint256(0))
        );
    }

    function testDynamicVariableLengthsAndConstantSlotRebuilt() public view {
        bytes[] memory v = new bytes[](3);
        v[0] = abi.encode("");
        v[1] = abi.encode("a");
        v[2] = abi.encode("a string longer than one word with a different body size");
        bytes[] memory constants = new bytes[](2);
        constants[1] = abi.encode(uint256(2));
        Collections.Callback memory unary =
            Collections.Callback(address(this), this.textPredicate.selector, "(string,uint256)", constants, 0, 0, "");
        require(c.findValues("string", v, unary) == 2, "dynamic first match");
    }

    function testExpressionPredicateWireAndIgnoredSelector() public view {
        Collections.Callback memory unary = cb(false);
        unary.expression = hex"abcd";
        unary.selector = this.dirty.selector;
        require(c.findValues("uint256", values(1, 7, 99), unary) == 1, "expression first match");
    }

    function testConstantsValidatedBeforeEmptyInput() public view {
        bytes[] memory empty = new bytes[](0);
        Collections.Callback memory unary = cb(true);
        unary.arguments = "(uint256,uint8)";
        unary.constants[1] = abi.encode(uint256(256));
        fail(
            abi.encodeCall(c.findValues, ("uint256", empty, unary)),
            abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0))
        );
    }
}
