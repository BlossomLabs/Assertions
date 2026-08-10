// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operators.sol";
import "../ERC8211.sol";
import "./Mocks.sol";

/**
 * @notice Lambda templates that target the CORE, executed through the
 *         fold engine on a real EVM — the form the SDK emits for composed
 *         predicates. Every other fold test drives the engine with
 *         `target = address(ops)` and a bare Operators template; these
 *         drive it with `target = core` and full ABI-encoded `read(...)`
 *         calldata, so the three legs the SDK otherwise only derives are
 *         executed: the element window is FOUND by scanning the encoded
 *         bytes (never recomputed from the layout), the per-element
 *         window rewrite must survive the core's own calldata decode, and
 *         the core's raw-return of the inner returndata must put the
 *         value in the first return word the engine reads.
 */
contract CoreTargetLambdaTest is Test {
    Assertions public assertions;
    Operators public ops;
    MockTarget public target;

    /// The SDK's element marker (keccak256 of "evmcrispr/fold-element"):
    /// its single occurrence in the compiled calldata IS the window.
    bytes32 constant MARKER = keccak256("evmcrispr/fold-element");

    bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
    bytes4 constant MUL_U = bytes4(keccak256("mul(uint256,uint256)"));
    bytes4 constant GT_U = bytes4(keccak256("gt(uint256,uint256)"));

    function setUp() public {
        assertions = new Assertions();
        ops = new Operators();
        target = new MockTarget();
        target.setValue(100);
    }

    // ============ Test Helpers ============

    /** One-element elemOffsets array — the N=1 shape every pre-C caller uses. */
    function _offs(uint256 o) internal pure returns (uint256[] memory a) {
        a = new uint256[](1);
        a[0] = o;
    }


    function _none() internal pure returns (Constraint[] memory cs) {
        cs = new Constraint[](0);
    }

    /**
     * @dev A RAW_BYTES operand carrying a literal word
     */
    function _lit(uint256 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    function _litB32(bytes32 v) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(v), _none());
    }

    /**
     * @dev A STATIC_CALL operand
     */
    function _call(address t, bytes memory d) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(t, d), _none());
    }

    /**
     * @dev `read(ops, selector, args)` calldata — a core-target template
     *      the way the SDK's composed-lambda fallback keeps it, verbatim.
     */
    function _readTemplate(bytes4 selector, InputParam[] memory args) internal view returns (bytes memory) {
        return abi.encodeCall(Assertions.read, (_lit(uint256(uint160(address(ops)))), selector, args));
    }

    /**
     * @dev Find `word`'s byte offset in `data` by scanning — the way the
     *      SDK's extractor locates the marker, never by re-deriving the
     *      offset from the ABI layout — and zero the window in place.
     *      Requires exactly one occurrence (N=1 callers).
     */
    function _window(bytes memory data, bytes32 word) internal pure returns (uint256 offset) {
        uint256[] memory offs = _windows(data, word);
        require(offs.length == 1, "window word must appear exactly once");
        return offs[0];
    }

    /**
     * @dev Find EVERY occurrence of `word` in `data` by scanning, zero
     *      each window in place, and return the ascending byte offsets —
     *      the multi-marker shape a definition naming its parameter more
     *      than once produces.
     */
    function _windows(bytes memory data, bytes32 word) internal pure returns (uint256[] memory offsets) {
        uint256 n;
        for (uint256 i = 0; i + 32 <= data.length; i++) {
            bytes32 w;
            assembly {
                w := mload(add(add(data, 32), i))
            }
            if (w == word) n++;
        }
        require(n > 0, "window word not found");
        offsets = new uint256[](n);
        uint256 k;
        for (uint256 i = 0; i + 32 <= data.length; i++) {
            bytes32 w;
            assembly {
                w := mload(add(add(data, 32), i))
            }
            if (w == word) {
                offsets[k++] = i;
                assembly {
                    mstore(add(add(data, 32), i), 0)
                }
            }
        }
    }

    // ============ Core-target read templates ============

    function test_foldWords_coreTargetTemplate_liveNestedCall() public view {
        // gt(<element>, target.getValue()) — the nested call stays a live
        // STATIC_CALL operand in the template, re-resolved per element.
        InputParam[] memory args = new InputParam[](2);
        args[0] = _litB32(MARKER);
        args[1] = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        bytes memory template = _readTemplate(GT_U, args);
        uint256 elemOffset = _window(template, MARKER);

        bytes memory payload = abi.encodePacked(uint256(10), uint256(200), uint256(30));
        // The predicate ignores the accumulator, so both windows share the
        // element offset — the convention the SDK's foldParam uses.
        assertEq(
            uint256(
                ops.foldWords(payload, address(assertions), template, elemOffset, _offs(elemOffset), bytes32(0), Operators.FoldExit.Any)
            ),
            1,
            "one element beats the live floor"
        );
        assertEq(
            uint256(
                ops.foldWords(payload, address(assertions), template, elemOffset, _offs(elemOffset), bytes32(0), Operators.FoldExit.All)
            ),
            0,
            "not every element beats the live floor"
        );
    }

    function test_foldWords_coreTargetTemplate_distinctWindows() public view {
        // add(<acc>, <element>) with SEPARATE windows, both inside the
        // ABI-encoded read args: each iteration's two rewrites must
        // survive the core's calldata decode.
        bytes32 accSentinel = keccak256("acc-window");
        InputParam[] memory args = new InputParam[](2);
        args[0] = _litB32(accSentinel);
        args[1] = _litB32(MARKER);
        bytes memory template = _readTemplate(ADD_U, args);
        uint256 accOffset = _window(template, accSentinel);
        uint256 elemOffset = _window(template, MARKER);

        bytes memory payload = abi.encodePacked(uint256(10), uint256(20), uint256(30));
        assertEq(
            uint256(
                ops.foldWords(payload, address(assertions), template, accOffset, _offs(elemOffset), bytes32(uint256(5)), Operators.FoldExit.Full)
            ),
            65,
            "5 + 10 + 20 + 30 through the core"
        );
    }

    function test_mapWords_coreTargetTemplate_composedExpression() public view {
        // add(mul(<element>, 2), 1) — the inner read nests through the
        // core itself, so the marker sits TWO ABI layers deep (inside the
        // inner read's calldata inside the outer args) and the window
        // rewrite must survive both decodes.
        InputParam[] memory innerArgs = new InputParam[](2);
        innerArgs[0] = _litB32(MARKER);
        innerArgs[1] = _lit(2);
        bytes memory innerRead = _readTemplate(MUL_U, innerArgs);
        InputParam[] memory outerArgs = new InputParam[](2);
        outerArgs[0] = _call(address(assertions), innerRead);
        outerArgs[1] = _lit(1);
        bytes memory template = _readTemplate(ADD_U, outerArgs);
        uint256 elemOffset = _window(template, MARKER);

        bytes memory payload = abi.encodePacked(uint256(1), uint256(2), uint256(3));
        assertEq(
            ops.mapWords(payload, address(assertions), template, _offs(elemOffset)),
            abi.encodePacked(uint256(3), uint256(5), uint256(7)),
            "add(mul(elem, 2), 1) mapped through nested core reads"
        );
    }

    function test_mapWords_coreTargetTemplate_multiWindowSquare() public view {
        // mul(<element>, <element>) — what a definition whose body names
        // its parameter twice compiles to, e.g. @num!($x * $x). Two
        // identical markers in one core-target read, both windows found by
        // scanning (never recomputed), both stamped per element.
        InputParam[] memory args = new InputParam[](2);
        args[0] = _litB32(MARKER);
        args[1] = _litB32(MARKER);
        bytes memory template = _readTemplate(MUL_U, args);
        uint256[] memory offs = _windows(template, MARKER);
        assertEq(offs.length, 2, "a parameter named twice yields two windows");
        assertTrue(offs[0] < offs[1], "offsets ascend");

        bytes memory payload = abi.encodePacked(uint256(1), uint256(2), uint256(3));
        assertEq(
            ops.mapWords(payload, address(assertions), template, offs),
            abi.encodePacked(uint256(1), uint256(4), uint256(9)),
            "mul(elem, elem) squares through a core-target multi-window template"
        );
    }

    function test_filterWords_coreTargetTemplate_liveFloor() public view {
        // Keep the elements above target.getValue(): the raw-returned
        // gt word is the engine's keep/drop signal.
        InputParam[] memory args = new InputParam[](2);
        args[0] = _litB32(MARKER);
        args[1] = _call(address(target), abi.encodeCall(MockTarget.getValue, ()));
        bytes memory template = _readTemplate(GT_U, args);
        uint256 elemOffset = _window(template, MARKER);

        bytes memory payload = abi.encodePacked(uint256(10), uint256(200), uint256(30), uint256(400));
        assertEq(
            ops.filterWords(payload, address(assertions), template, _offs(elemOffset)),
            abi.encodePacked(uint256(200), uint256(400)),
            "elements above the live floor survive"
        );
    }

    function test_mapWords_corePickTemplate() public view {
        // A non-read core primitive as the lambda: pick word 0 of
        // mul(<element>, 3). pick ABI-returns one bytes32, so the
        // first-return-word convention the engine relies on holds for it
        // too — the shape the SDK accepts for pick-wrapped operands.
        InputParam memory picked =
            _call(address(ops), abi.encodeWithSelector(MUL_U, uint256(MARKER), uint256(3)));
        bytes memory template = abi.encodeCall(Assertions.pick, (picked, int256(0)));
        uint256 elemOffset = _window(template, MARKER);

        bytes memory payload = abi.encodePacked(uint256(1), uint256(3), uint256(5));
        assertEq(
            ops.mapWords(payload, address(assertions), template, _offs(elemOffset)),
            abi.encodePacked(uint256(3), uint256(9), uint256(15)),
            "mul(elem, 3) through the core's pick"
        );
    }

    // ============ SDK-compiled fixture ============

    // Emitted by the SDK's `extractLambdaTemplate` for the pinned
    // addresses below: the compiled operand was
    // `staticCallParam(core, encodeOpRead(ops, gt(uint256,uint256),
    // [rawParam(ELEMENT_MARKER), staticCallParam(tgt, getValue())]))`
    // — i.e. `gt(<element>, tgt.getValue())`, the composed form of e.g.
    // `def @overCap! "$x: number -> bool" @bool!($x > ::getValue())` applied
    // as `@any!(caps @overCap!)`. elemOffset reported: 580.
    bytes constant SDK_TEMPLATE =
        hex"3efa16b7000000000000000000000000000000000000000000000000000000000000006021e5749b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000097e7a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000007a49e70000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000420965255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    uint256 constant SDK_ELEM_OFFSET = 580;

    function test_foldWords_sdkCompiledFixture_endToEnd() public {
        // The SDK compiled the template against pinned addresses; put the
        // real deployments' code there so its bytes run unmodified.
        address core_ = address(uint160(0xA55E7));
        address ops_ = address(uint160(0x97E7A7));
        address tgt_ = address(uint160(0x7A49E7));
        vm.etch(core_, address(assertions).code);
        vm.etch(ops_, address(ops).code);
        vm.etch(tgt_, address(target).code);
        MockTarget(tgt_).setValue(100);

        // Cross-implementation check: hand-encoding the same read(...)
        // with solc reproduces the SDK's (viem-encoded) bytes exactly,
        // and scanning finds the SDK's reported element offset.
        InputParam[] memory args = new InputParam[](2);
        args[0] = _litB32(MARKER);
        args[1] = _call(tgt_, abi.encodeCall(MockTarget.getValue, ()));
        bytes memory handBuilt =
            abi.encodeCall(Assertions.read, (_lit(uint256(uint160(ops_))), GT_U, args));
        assertEq(_window(handBuilt, MARKER), SDK_ELEM_OFFSET, "scanned offset matches the SDK's");
        assertEq(keccak256(handBuilt), keccak256(SDK_TEMPLATE), "solc and the SDK encode identical templates");

        bytes memory payload = abi.encodePacked(uint256(10), uint256(200), uint256(30));
        assertEq(
            uint256(
                Operators(ops_).foldWords(payload, core_, SDK_TEMPLATE, SDK_ELEM_OFFSET, _offs(SDK_ELEM_OFFSET), bytes32(0), Operators.FoldExit.Any)
            ),
            1,
            "the SDK-compiled predicate finds 200 > 100"
        );
        assertEq(
            uint256(
                Operators(ops_).foldWords(payload, core_, SDK_TEMPLATE, SDK_ELEM_OFFSET, _offs(SDK_ELEM_OFFSET), bytes32(0), Operators.FoldExit.All)
            ),
            0,
            "10 and 30 do not beat the floor"
        );
    }
}
