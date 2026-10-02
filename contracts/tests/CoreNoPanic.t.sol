// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import {Operations} from "../Operations.sol";
import {HostileTarget} from "./CollectionsNoPanic.t.sol";

/**
 * @notice Fuzz checks for selector-bearing, non-panic failures on generated
 *         parameters and targets, with selected malformed wire cases allowed
 *         to revert without data.
 * @dev The Raw* structs mirror the ERC-8211 structs with uint8 enums, so
 *      they encode identically and an out-of-range enum reaches the
 *      decoder. Each call gets a fixed gas budget, like the other NoPanic
 *      suites. Reads and batches use canonical nested ABI with bounded payloads;
 *      explicit regressions pin allocation Panic(0x41) for impossible
 *      STATIC_CALL and OR allocations. The primitive sweep retains selected
 *      malformed wire cases; none of these sweeps proves arbitrary resource
 *      availability.
 */
contract CoreNoPanicTest is Test {
    bytes4 constant PANIC = 0x4e487b71;
    uint256 constant CALL_GAS = 10_000_000;
    string constant PARAM = "(uint8,uint8,bytes,(uint8,bytes)[])";

    struct RawConstraint {
        uint8 constraintType;
        bytes referenceData;
    }

    struct RawParam {
        uint8 paramType;
        uint8 fetcherType;
        bytes paramData;
        RawConstraint[] constraints;
    }

    struct RawOutput {
        uint8 fetcherType;
        bytes paramData;
    }

    struct RawExecution {
        bytes4 functionSig;
        RawParam[] inputParams;
        RawOutput[] outputParams;
    }

    /**
     * @dev What one fuzzed parameter is built from
     */
    struct ParamInput {
        uint8 kind;
        uint8 targetCase;
        uint8 enums;
        uint8 constraintCount;
        bytes data;
        bytes32 word;
    }

    Assertions core;
    address[10] targets;

    function setUp() public {
        core = new Assertions();
        for (uint256 m; m < 8; m++) {
            targets[m] = address(new HostileTarget(m));
        }
        targets[8] = address(new Operations());
        targets[9] = address(0xdead);
    }

    // ============ Primitives ============

    function testFuzzPrimitivesNeverPanic(ParamInput calldata a, ParamInput calldata b, ParamInput calldata c)
        public
        view
    {
        (RawParam memory pa, bool ma) = param(a);
        (RawParam memory pb, bool mb) = param(b);
        (RawParam memory pc, bool mc) = param(c);
        bool malformed = ma || mb || mc;
        call(abi.encodeWithSignature(string.concat("resolve(", PARAM, ")"), pa), ma);
        call(abi.encodeWithSignature(string.concat("assertParam(", PARAM, ")"), pa), ma);
        call(abi.encodeWithSignature(string.concat("assertParam(", PARAM, ",string)"), pa, "m"), ma);
        call(abi.encodeWithSignature(string.concat("isValid(", PARAM, ")"), pa), ma);
        call(abi.encodeWithSignature(string.concat("revertData(", PARAM, ",bytes4)"), pa, bytes4(a.word)), ma);
        call(abi.encodeWithSignature(string.concat("pick(", PARAM, ",int256)"), pa, int256(uint256(b.word))), ma);
        call(abi.encodeWithSignature(string.concat("orElse(", PARAM, ",", PARAM, ")"), pa, pb), ma || mb);
        call(abi.encodeWithSignature(string.concat("cond(", PARAM, ",", PARAM, ",", PARAM, ")"), pa, pb, pc), malformed);
        RawParam[] memory all = new RawParam[](3);
        all[0] = pa;
        all[1] = pb;
        all[2] = pc;
        call(abi.encodeWithSignature(string.concat("gather(", PARAM, "[])"), all), malformed);
    }

    function testFuzzBoundedReadsNeverPanic(
        ParamInput calldata a,
        ParamInput calldata b,
        uint8 typesCase,
        int256[] calldata path,
        bytes[] calldata calls
    ) public view {
        RawParam memory pa = boundedParam(a);
        RawParam memory pb = boundedParam(b);
        string memory types = descriptor(typesCase);
        int256[] memory boundedPath = new int256[](path.length > 16 ? 16 : path.length);
        for (uint256 i; i < boundedPath.length; i++) {
            boundedPath[i] = path[i];
        }
        bytes[] memory boundedCalls = new bytes[](calls.length > 4 ? 4 : calls.length);
        for (uint256 i; i < boundedCalls.length; i++) {
            boundedCalls[i] = calls[i][:calls[i].length > 256 ? 256 : calls[i].length];
        }
        call(abi.encodeWithSignature(string.concat("nav(", PARAM, ",string,int256[])"), pa, types, boundedPath), false);
        call(abi.encodeWithSignature(string.concat("chain(", PARAM, ",bytes[])"), pa, boundedCalls), false);
        RawParam[] memory args = new RawParam[](1);
        args[0] = pb;
        bytes4 selector = bytes4(a.word);
        call(
            abi.encodeWithSignature(string.concat("read(", PARAM, ",bytes4,", PARAM, "[])"), pa, selector, args), false
        );
        call(
            abi.encodeWithSignature(
                string.concat("get(", PARAM, ",bytes4,string,", PARAM, "[])"), pa, selector, types, args
            ),
            false
        );
    }

    function testFuzzBoundedBatchNeverPanics(ParamInput calldata a, ParamInput calldata b, bytes4 sig, uint8 outputs)
        public
        view
    {
        RawParam memory pa = boundedParam(a);
        RawParam memory pb = boundedParam(b);
        RawExecution[] memory batch = new RawExecution[](1);
        batch[0].functionSig = sig;
        batch[0].inputParams = new RawParam[](2);
        batch[0].inputParams[0] = pa;
        batch[0].inputParams[1] = pb;
        batch[0].outputParams = new RawOutput[](outputs % 2);
        string memory execution = string.concat("(bytes4,", PARAM, "[],(uint8,bytes)[])[]");
        call(abi.encodeWithSignature(string.concat("assertBatch(", execution, ")"), batch), false);
        call(abi.encodeWithSignature(string.concat("assertBatch(", execution, ",string)"), batch, "m"), false);
    }

    /**
     * @dev A valid read and batch must actually succeed, so accepting declared
     *      errors in the hostile-input sweeps cannot hide universal rejection.
     */
    function testFuzzBoundedReadAndBatchSucceed(uint256 value) public view {
        RawParam memory target = RawParam(0, 0, abi.encode(targets[8]), new RawConstraint[](0));
        RawParam memory arg = RawParam(2, 0, abi.encode(value), new RawConstraint[](0));
        RawParam[] memory args = new RawParam[](1);
        args[0] = arg;
        bytes4 selector = bytes4(keccak256("toString(uint256)"));
        bytes memory expected = abi.encode(vm.toString(value));
        (bool ok, bytes memory out) = address(core).staticcall{gas: CALL_GAS}(
            abi.encodeWithSignature(string.concat("read(", PARAM, ",bytes4,", PARAM, "[])"), target, selector, args)
        );
        assertTrue(ok);
        assertEq(out, expected);
        (ok, out) = address(core).staticcall{gas: CALL_GAS}(
            abi.encodeWithSignature(
                string.concat("get(", PARAM, ",bytes4,string,", PARAM, "[])"), target, selector, "(uint256)", args
            )
        );
        assertTrue(ok);
        assertEq(out, expected);
        RawExecution[] memory batch = new RawExecution[](1);
        batch[0].functionSig = selector;
        batch[0].inputParams = new RawParam[](2);
        batch[0].inputParams[0] = target;
        batch[0].inputParams[1] = arg;
        batch[0].outputParams = new RawOutput[](0);
        string memory execution = string.concat("(bytes4,", PARAM, "[],(uint8,bytes)[])[]");
        (ok, out) = address(core).staticcall{gas: CALL_GAS}(
            abi.encodeWithSignature(string.concat("assertBatch(", execution, ")"), batch)
        );
        assertTrue(ok);
        assertEq(out.length, 0);
        (ok, out) = address(core).staticcall{gas: CALL_GAS}(
            abi.encodeWithSignature(string.concat("assertBatch(", execution, ",string)"), batch, "m")
        );
        assertTrue(ok);
        assertEq(out.length, 0);
    }

    /**
     * @dev The nested STATIC_CALL ABI requests more memory than solc can allocate.
     *      This happens before the encoded target is called, including through reads
     *      and batches; pin the allocation panic rather than a universal no-panic rule.
     */
    function testReadsAndBatchRejectImpossibleDecoderAllocation() public view {
        RawParam memory bad =
            RawParam(2, 1, abi.encode(address(1), uint256(64), type(uint256).max), new RawConstraint[](0));
        bytes memory panic = abi.encodeWithSignature("Panic(uint256)", uint256(0x41));
        RawParam[] memory args = new RawParam[](0);
        assertFailure(
            abi.encodeWithSignature(string.concat("read(", PARAM, ",bytes4,", PARAM, "[])"), bad, bytes4(0), args),
            panic
        );
        assertFailure(
            abi.encodeWithSignature(
                string.concat("get(", PARAM, ",bytes4,string,", PARAM, "[])"), bad, bytes4(0), "()", args
            ),
            panic
        );
        RawExecution[] memory batch = new RawExecution[](1);
        batch[0].inputParams = new RawParam[](1);
        batch[0].inputParams[0] = bad;
        batch[0].outputParams = new RawOutput[](0);
        string memory execution = string.concat("(bytes4,", PARAM, "[],(uint8,bytes)[])[]");
        assertFailure(abi.encodeWithSignature(string.concat("assertBatch(", execution, ")"), batch), panic);
        assertFailure(abi.encodeWithSignature(string.concat("assertBatch(", execution, ",string)"), batch, "m"), panic);
    }

    function testOrRejectsImpossibleDecoderAllocation() public view {
        RawConstraint[] memory cs = new RawConstraint[](1);
        cs[0] = RawConstraint(6, abi.encode(uint256(32), type(uint256).max));
        RawParam memory bad = RawParam(2, 0, abi.encode(uint256(1)), cs);
        assertFailure(
            abi.encodeWithSignature(string.concat("assertParam(", PARAM, ")"), bad),
            abi.encodeWithSignature("Panic(uint256)", uint256(0x41))
        );
    }

    function assertFailure(bytes memory data, bytes memory expected) internal view {
        (bool ok, bytes memory out) = address(core).staticcall{gas: CALL_GAS}(data);
        assertFalse(ok);
        assertEq(out, expected);
    }

    // ============ Builders ============

    /**
     * @dev Bounded payloads with valid enums and canonical nested ABI. Semantic
     *      errors and hostile targets remain covered, but impossible allocations
     *      are exercised separately. The no-panic checks still require an error
     *      selector on every failure, including target gas exhaustion.
     */
    function boundedParam(ParamInput calldata p) internal view returns (RawParam memory out) {
        ParamInput memory bounded = p;
        bounded.kind &= 0x7f;
        bounded.enums %= 3;
        bounded.data = p.data[:p.data.length > 256 ? 256 : p.data.length];
        bool malformed;
        (out, malformed) = param(bounded);
        assertFalse(malformed);
    }

    /**
     * @dev One parameter and whether it carries wire bytes solc's decoder
     *      may refuse: a raw fetcher, a junk STATIC_CALL paramData, an
     *      out-of-range enum or a junk OR payload
     */
    function param(ParamInput memory p) internal view returns (RawParam memory out, bool malformed) {
        address target = targets[p.targetCase % targets.length];
        // Half the runs inject nothing undecodable, so a bare revert there fails the test.
        bool junk = p.kind & 0x80 != 0;
        out.paramType = junk ? p.enums % 4 : p.enums % 3;
        malformed = out.paramType > 2;
        uint8 kind = junk ? p.kind % 5 : p.kind % 2 == 0 ? 0 : p.kind % 4 == 1 ? 1 : 3;
        if (kind == 0) {
            out.fetcherType = 0;
            out.paramData = p.data;
        } else if (kind == 1) {
            out.fetcherType = 1;
            out.paramData = abi.encode(target, p.data);
        } else if (kind == 2) {
            out.fetcherType = 1;
            out.paramData = p.data;
            malformed = true;
        } else if (kind == 3) {
            out.fetcherType = 2;
            out.paramData = p.enums & 0x80 == 0 ? abi.encodePacked(target, target) : p.data;
        } else {
            out.fetcherType = 3;
            out.paramData = p.data;
            malformed = true;
        }
        bool junkConstraint;
        (out.constraints, junkConstraint) = constraints(p.constraintCount % 4, p.word, p.data, junk);
        malformed = malformed || junkConstraint;
    }

    /**
     * @dev Constraints of every kind, well-formed or not, and whether any is undecodable
     */
    function constraints(uint256 count, bytes32 word, bytes memory data, bool junk)
        internal
        pure
        returns (RawConstraint[] memory out, bool malformed)
    {
        out = new RawConstraint[](count);
        for (uint256 i; i < count; i++) {
            uint8 kind = uint8(word[i]) % (junk ? 10 : 9);
            out[i].constraintType = kind;
            if (kind > 8) {
                malformed = true;
            } else if (kind == 6) {
                if (!junk || uint8(word[i + 8]) & 1 == 0) {
                    RawConstraint[] memory leaves = new RawConstraint[](uint8(word[i + 16]) % 3);
                    for (uint256 j; j < leaves.length; j++) {
                        leaves[j] = RawConstraint(uint8(word[j + 20]) % 9, abi.encode(word));
                    }
                    out[i].referenceData = abi.encode(leaves);
                } else {
                    out[i].referenceData = data;
                    malformed = true;
                }
            } else {
                uint8 shape = uint8(word[i + 24]) % 3;
                out[i].referenceData = shape == 0 ? abi.encode(word) : shape == 1 ? abi.encode(word, word) : data;
            }
        }
    }

    function descriptor(uint8 c) internal pure returns (string memory) {
        c %= 7;
        if (c == 0) return "(uint256)";
        if (c == 1) return "(uint256,bytes)";
        if (c == 2) return "(uint8[2],string)";
        if (c == 3) return "(bytes[])";
        if (c == 4) return "(uint256[4294967296])";
        if (c == 5) return "uint256";
        return "((";
    }

    // ============ Helpers ============

    /**
     * @dev Canonical-input failures require a non-panic selector. Injected
     *      malformed wire bytes may additionally produce a bare revert or
     *      exact allocation Panic(0x41), as pinned by the decoder regressions
     */
    function call(bytes memory data, bool malformed) internal view {
        (bool ok, bytes memory out) = address(core).staticcall{gas: CALL_GAS}(data);
        if (ok) return;
        if (out.length == 0 && malformed) return;
        if (malformed && keccak256(out) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(0x41)))) return;
        assertGe(out.length, 4, "no selector (out of gas?)");
        assertTrue(bytes4(out) != PANIC, "the core panicked");
    }
}
