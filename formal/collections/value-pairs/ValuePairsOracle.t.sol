// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract ValuePairsOracleTest {
    struct TextNumber {
        string text;
        uint256 number;
    }

    struct NumberBytes {
        uint256 number;
        bytes payload;
    }

    struct TextBytes {
        string text;
        bytes payload;
    }
    Collections private c = new Collections();

    function same(bytes memory a, bytes memory b) private pure {
        require(keccak256(a) == keccak256(b), "wrong pairing bytes/error");
    }

    function fail(bytes memory data, bytes memory reason) private view {
        (bool ok, bytes memory out) = address(c).staticcall(data);
        require(!ok, "expected pair rejection");
        same(out, reason);
    }

    function one(bytes memory v) private pure returns (bytes[] memory a) {
        a = new bytes[](1);
        a[0] = v;
    }

    function invalid(uint256 offset) private pure returns (bytes memory) {
        return abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset);
    }

    function testEmptyRawDescriptorsAndErrorPrecedence() public view {
        bytes[] memory empty = new bytes[](0);
        bytes[] memory oneValue = one(abi.encode(uint256(1)));
        fail(
            abi.encodeCall(c.zipValues, ("()", "()", empty, oneValue)),
            abi.encodeWithSelector(Collections.LengthMismatch.selector, uint256(0), uint256(1))
        );
        fail(
            abi.encodeCall(c.unzipValues, ("()", "()", empty, uint256(2))),
            abi.encodeWithSelector(Collections.InvalidLane.selector, uint256(2))
        );
        fail(
            abi.encodeCall(c.zipValues, ("()", "uint256", empty, empty)),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1))
        );
        fail(
            abi.encodeCall(c.unzipValues, ("uint256", "()", empty, uint256(0))),
            abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1))
        );
        same(abi.encode(c.zipValues("uint8", "bytes", empty, empty)), abi.encode(empty));
        same(abi.encode(c.unzipValues("uint8", "bytes", empty, 1)), abi.encode(empty));
    }

    function testStaticMultiwordBarePairAndBothLanes() public view {
        bytes[] memory a = one(abi.encode(type(uint256).max, uint256(7)));
        bytes[] memory b = one(abi.encode(true));
        bytes[] memory pairs = c.zipValues("uint256[2]", "bool", a, b);
        same(pairs[0], abi.encode(type(uint256).max, uint256(7), true));
        same(abi.encode(c.unzipValues("uint256[2]", "bool", pairs, 0)), abi.encode(a));
        same(abi.encode(c.unzipValues("uint256[2]", "bool", pairs, 1)), abi.encode(b));
    }

    function testDynamicLeftAndStaticRight() public view {
        bytes[] memory a = one(abi.encode(string("abc")));
        bytes[] memory b = one(abi.encode(uint256(7)));
        bytes[] memory pairs = c.zipValues("string", "uint256", a, b);
        same(pairs[0], abi.encode(TextNumber("abc", 7)));
        same(abi.encode(c.unzipValues("string", "uint256", pairs, 0)), abi.encode(a));
        same(abi.encode(c.unzipValues("string", "uint256", pairs, 1)), abi.encode(b));
    }

    function testStaticLeftAndDynamicRight() public view {
        bytes[] memory a = one(abi.encode(uint256(7)));
        bytes[] memory b = one(abi.encode(bytes(hex"abcdef")));
        bytes[] memory pairs = c.zipValues("uint256", "bytes", a, b);
        same(pairs[0], abi.encode(NumberBytes(7, hex"abcdef")));
        same(abi.encode(c.unzipValues("uint256", "bytes", pairs, 0)), abi.encode(a));
        same(abi.encode(c.unzipValues("uint256", "bytes", pairs, 1)), abi.encode(b));
    }

    function testBothDynamicAndPublicReassembly() public view {
        bytes[] memory a = new bytes[](2);
        bytes[] memory b = new bytes[](2);
        a[0] = abi.encode(string(""));
        a[1] = abi.encode(string("a string with a substantially longer body"));
        b[0] = abi.encode(bytes(hex"abcdef"));
        b[1] = abi.encode(bytes(""));
        bytes[] memory pairs = c.zipValues("string", "bytes", a, b);
        same(pairs[0], abi.encode(TextBytes("", hex"abcdef")));
        same(pairs[1], abi.encode(TextBytes("a string with a substantially longer body", bytes(""))));
        same(
            abi.encode(
                c.zipValues(
                    "string",
                    "bytes",
                    c.unzipValues("string", "bytes", pairs, 0),
                    c.unzipValues("string", "bytes", pairs, 1)
                )
            ),
            abi.encode(pairs)
        );
    }

    function testZipValidatesEveryRightElement() public view {
        bytes[] memory a = new bytes[](2);
        bytes[] memory b = new bytes[](2);
        a[0] = abi.encode(uint256(1));
        a[1] = a[0];
        b[0] = abi.encode(uint256(1));
        b[1] = abi.encode(uint256(256));
        fail(abi.encodeCall(c.zipValues, ("uint256", "uint8", a, b)), invalid(0));
    }

    function testZipFirstSideErrorBeforeSecondSide() public view {
        fail(
            abi.encodeCall(
                c.zipValues,
                ("(uint8,bool)", "uint8", one(abi.encode(uint256(1), uint256(2))), one(abi.encode(uint256(256))))
            ),
            invalid(32)
        );
    }

    function testUnzipValidatesUnselectedRightSide() public view {
        fail(
            abi.encodeCall(c.unzipValues, ("uint256", "uint8", one(abi.encode(uint256(7), uint256(256))), uint256(0))),
            invalid(0)
        );
    }

    function testUnzipValidatesUnselectedLeftSide() public view {
        fail(
            abi.encodeCall(c.unzipValues, ("uint8", "uint256", one(abi.encode(uint256(256), uint256(7))), uint256(1))),
            invalid(0)
        );
    }

    function testEnvelopeAndBothOffsetChecks() public view {
        fail(
            abi.encodeCall(
                c.unzipValues,
                (
                    "bytes",
                    "bytes",
                    one(abi.encode(uint256(31), uint256(64), uint256(96), uint256(0), uint256(0))),
                    uint256(0)
                )
            ),
            invalid(0)
        );
        fail(
            abi.encodeCall(
                c.unzipValues,
                (
                    "bytes",
                    "bytes",
                    one(abi.encode(uint256(32), uint256(63), uint256(96), uint256(0), uint256(0))),
                    uint256(0)
                )
            ),
            invalid(32)
        );
        fail(
            abi.encodeCall(
                c.unzipValues,
                ("bytes", "bytes", one(abi.encode(uint256(32), uint256(64), uint256(0), uint256(0))), uint256(0))
            ),
            invalid(32)
        );
    }

    function testStaticExactTailAndSpan() public view {
        fail(
            abi.encodeCall(c.unzipValues, ("uint8", "bool", one(abi.encode(uint256(1), true, uint256(9))), uint256(0))),
            invalid(64)
        );
        fail(abi.encodeCall(c.unzipValues, ("uint8", "bool", one(abi.encode(uint256(1))), uint256(0))), invalid(32));
    }

    function testFramingFailurePrecedesDirtyComponent() public view {
        fail(
            abi.encodeCall(
                c.unzipValues, ("uint8", "bool", one(abi.encode(uint256(256), uint256(2), uint256(9))), uint256(0))
            ),
            invalid(64)
        );
    }

    function testDynamicDirtyPaddingKeepsComponentOffset() public view {
        bytes memory canonical = abi.encode(NumberBytes(7, hex"aa"));
        canonical[129] = 0x01;
        fail(abi.encodeCall(c.unzipValues, ("uint256", "bytes", one(canonical), uint256(0))), invalid(65));
    }
}
