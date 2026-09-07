---
title: "Expressions: typed expression graphs"
description: The unreleased Expressions contract, resolve-once ABI call construction, and backwards-referencing typed graphs with a lazy Select, guarded evaluation and per-evaluation memoisation.
---

`Expressions` is a stateless periphery contract that addresses one structural limit of raw operands: an ERC-8211 `InputParam` is a tree with no way to name a subterm, so a repeated expression is duplicated in calldata and resolved again at every occurrence. Expressions adds two things. **Resolve-once** entry points resolve every supplied operand exactly once and assemble canonical calldata from the results, with no cap on how many live arguments a call may take. **Typed expression graphs** are node lists whose nodes reference earlier nodes, so a shared value is evaluated once per evaluation, branches can be lazy, and a whole canonical ABI value (a string, an array, a tuple) binds to one node. It imports the core (for `Assertions.resolve`) and the shared `AbiCodec`; it adds nothing to the frozen core and changes no wire format.

**Status: unreleased.** The deployment manifest lists it with `released: false` (see [Deployments](/docs/reference/deployments)): it is an artifact candidate the EVMcrispr SDK does not compile against, and its only in-tree consumer is `Collections.Callback.expression` ([below](#collections-callbacks-through-an-expression)). Because `Collections` imports it, an edit to `Expressions.sol` moves the Collections address too.

## Resolve once

```solidity
function resolveCall     (address core, InputParam target, bytes4 selector,
                          string argumentTypes, InputParam[] args) external view;   // raw return
function resolveArguments(address core, string argumentTypes, InputParam[] args)
                          external view;                                            // raw return
function resolveValues   (address core, InputParam[] args)
                          external view returns (bytes[] values);
```

All three take the core's address explicitly and resolve each operand through `Assertions.resolve`, so operands keep their inline constraints and every [core primitive](/docs/core/reads) nests inside them as usual.

- **`resolveCall`** resolves `target` (which must yield one clean address word), then each argument once, ABI-encodes the arguments as the tuple `argumentTypes` describes, staticcalls the target with `selector` prefixed, and returns the call's raw returndata. Each resolved argument must be a canonical single-value envelope matching its position in the descriptor.
- **`resolveArguments`** returns the encoded argument tuple itself, raw and without a bytes envelope: a calldata segment for the core's `read` to splice, the role [`Operations.encode`](/docs/operators/data#encode-runtime-abiencode) plays for already-resolved pieces.
- **`resolveValues`** returns each operand's raw resolved bytes as one `bytes[]` element, the value shape the [generic collections](/docs/operators/collections) consume.

Operands are resolved in a loop, once each: there is no four-live-argument limit. Duplicate entries in `args` are still independent resolutions; to share a value, put it in a graph. The empty descriptor `()` with no arguments encodes to nothing. In errors, `resolveCall` numbers its target 0, its arguments from 1 and the constructed call `args.length + 1`; the other two number arguments from 0.

The core's own [`readArgs`](/docs/core/reads) does the same construction in one frame: it resolves each argument in place and keeps the core as the destination's `msg.sender`, where `resolveCall` makes Expressions the caller. Measured through `Assertions.resolve` on 2026-09-07 (`contracts/tests/ExpressionsGas.t.sol`), two live string arguments cost 32,440 gas through `readArgs`, 40,440 through `resolveCall` and 51,474 through the SDK's offset splice. The SDK targets `readArgs`; `resolveCall` and `resolveArguments` remain for callers that want Expressions as the caller, and `resolveValues` is how a `bytes[]` is assembled from N operands.

## The graph

```solidity
enum Kind { Literal, Parameter, Resolve, Call, Select, Wrap, Array, Tuple, TryOrElse, IsValid, ProbeCall }

struct Node {
    Kind kind;
    string valueType;   // the author's claim about this node's value, validated by shape
    bytes data;         // Literal: the value; Parameter: abi.encode(index); Resolve: abi.encode(InputParam)
    uint256[] refs;     // earlier nodes this node reads (strictly backward)
    bytes4 selector;    // Call: the function selector; ProbeCall: the required error selector (or zero)
    string arguments;   // Call and Tuple: the argument tuple descriptor; Array: the element descriptor
}

struct Expression {
    address core;       // the Assertions core that Resolve nodes go through
    Node[] nodes;
    uint256 result;     // the node whose value the expression returns
}

function evaluate       (Expression expression, bytes[] parameters) external view;  // raw return
function evaluateEncoded(bytes expression, bytes[] parameters) external view;       // raw return
```

`evaluate` first checks the whole graph: `result` must index a node, every `valueType` must parse (`InvalidTypeDescriptor` otherwise), every reference must point to an earlier node (`InvalidReference(node, ref)`), and each kind must carry the right number of references (`InvalidNode(node)`): `Call` at least one, `Select` three, `TryOrElse` and `ProbeCall` two, `Wrap` and `IsValid` one, `Literal`, `Parameter` and `Resolve` none; `Array` and `Tuple` take any number. It then evaluates the `result` node. Only nodes reachable from `result` execute, and a node reached twice is evaluated once: every successful node is memoised for the rest of that evaluation. After a node produces its value, `AbiCodec.validate(valueType, value)` checks that the bytes are a canonical single-value encoding of the claimed type: offsets, lengths, padding and the absence of trailing data are verified, while scalar semantics such as a narrow integer range remain the author's claim, exactly as with [`nav`](/docs/core/reads) descriptors. The result returns raw, like the core primitives, so an evaluation is itself an operand.

| Kind | Meaning |
|---|---|
| `Literal` | `data` is the value itself, a canonical encoding of `valueType`. |
| `Parameter` | `data` is `abi.encode(uint256 index)`; the value is `parameters[index]`, one of the canonical single-value envelopes supplied to `evaluate` (`InvalidNode` when `data` is not one word, `InvalidReference(node, index)` when the index is out of range). |
| `Resolve` | `data` is `abi.encode(InputParam)`; the value is `Assertions.resolve` of that operand on `expression.core`, constraints included. It resolves only when reached. |
| `Call` | `refs[0]` is the target address (one clean 32-byte address word); the remaining references are the arguments in order, encoded as the tuple `arguments` describes and prefixed with `selector`. The value is the staticcall's raw returndata. |
| `Select` | References are condition, then, else. Truth is judged like the core's [`cond`](/docs/core/control): the condition must be at least 32 bytes (`InvalidNode` otherwise) and its first word decides, nonzero evaluates `refs[1]` and zero evaluates `refs[2]`. Only the chosen branch executes. A condition longer than one word is accepted and only its first word counts. |
| `Wrap` | The referenced value's encoding wrapped as one `bytes` value (a canonical bytes envelope around those bytes). |
| `Array` | The referenced values packed as a canonical `T[]`, where `arguments` is the element descriptor `T`. |
| `Tuple` | The referenced values assembled as one canonical tuple value whose components `arguments` describes; a dynamic tuple gets its leading offset word so it stays a single value. |
| `TryOrElse` | Evaluate `refs[0]` in an isolated frame; on any failure evaluate `refs[1]` instead. |
| `IsValid` | A canonical bool word: whether `refs[0]` evaluates successfully in an isolated frame. |
| `ProbeCall` | `refs[0]` is a target address and `refs[1]` a calldata `bytes` value; the target is staticcalled and MUST revert, and the value is its revert data as a `bytes` value. With a nonzero `selector` the revert data must start with it and the four selector bytes are stripped, leaving the error's arguments word-aligned. |

### Guarded evaluation

`TryOrElse` and `IsValid` evaluate their attempt through `evaluateGuarded`, an external self-call that only the contract itself may make (any other caller reverts with `NotSelf`), because a call frame is the EVM's only catch primitive. The frame takes a copy of the memo cache in; on success its cache comes back and replaces the caller's, so values evaluated inside the attempt stay memoised, and on failure the frame's cache changes are discarded with the frame. Every failure counts, including out-of-gas in the subframe: the same edge the core's [`orElse` and `isValid`](/docs/core/control#the-staticcall-boundary-and-the-oog-caveat) document.

### ProbeCall details

`ProbeCall` reuses the core's revert-probe errors. A target that succeeds reverts the evaluation with `DidNotRevert(target, callData)`. With a nonzero `selector`, revert data that does not start with it reverts with `UnexpectedRevertData(expected, actual)`, where `actual` is zero when the revert carried fewer than four bytes. A target without code has no reason to report: with a zero selector the value is empty bytes, with a nonzero one the node reverts with `UnexpectedRevertData(expected, 0x00000000)`. An error with no arguments yields empty bytes after stripping. The probe runs in Expressions' own frame, so the target's reason survives intact.

### Memoisation scope

Memoisation lasts one `evaluate` call. In a Collections traversal that is one callback invocation: a `Resolve` node reached in every iteration resolves once per iteration, not once per traversal. Resolve a source array once with the outer `resolveValues` (or the core) and pass its elements in as parameters instead.

## A graph with a shared subterm

"Append the element to itself, then append the accumulator", with the element named twice and evaluated once. With `node`, `callNode` and `refs3` helpers shaped like the ones in `contracts/tests/Expressions.t.sol`:

```solidity
Expressions.Expression memory p;
p.nodes = new Expressions.Node[](5);
p.nodes[0] = node(Expressions.Kind.Literal,   "address", abi.encode(target));
p.nodes[1] = node(Expressions.Kind.Parameter, "string",  abi.encode(uint256(0)));   // the element
p.nodes[2] = node(Expressions.Kind.Parameter, "string",  abi.encode(uint256(1)));   // the accumulator
p.nodes[3] = callNode("string", IAppend.append.selector, "(string,string)", refs3(0, 1, 1));
p.nodes[4] = callNode("string", IAppend.append.selector, "(string,string)", refs3(0, 3, 2));
p.result = 4;
// evaluate(p, [abi.encode("ab"), abi.encode("!")]) returns abi.encode("abab!")
```

Node 1 is referenced twice by node 3, and node 3 once by node 4; each is evaluated once. The same shape as a raw `InputParam` tree would carry the element's calldata twice and inline the whole inner append under the outer one.

## Collections callbacks through an expression

[`Collections.Callback`](/docs/operators/collections#callback-specification) carries a trailing `bytes expression` field. Empty, the callback is a direct call: `target`, `selector`, and the argument tuple with the element slots substituted. Non-empty, it is `abi.encode(Expression)`: Collections binds the element slots (`first`, and `second` for binary operations) into the constants exactly as before, then staticcalls `target` with `evaluateEncoded(expression, substitutedArguments)`; `selector` is ignored and `target` is the Expressions contract. Inside the graph, `Parameter` nodes read those substituted slots, so an element can be referenced any number of times, arguments may be dynamic and multi-word, and live reads compose without byte-offset substitution. The result is validated exactly like a direct callback's: mapped values against `outputType`, predicate results as a canonical 0/1 word. That last rule is Collections' own (`_predicate` demands a canonical bool from every callback result); `Select`'s first-word truth rule is a different concern and does not relax it.

`evaluateEncoded` decodes the expression and self-calls `evaluate`, returning the same raw value. A failure inside surfaces as `NodeCallFailed(0, expressions, data, reason)` wrapping the inner error, which Collections in turn reports through `CallbackFailed`.

## Errors

| Error | Description |
|---|---|
| `InvalidNode(uint256 node)` | the node is malformed: `result` out of range, the wrong reference count for its kind, a `Parameter` whose data is not one word, a `Select` condition shorter than 32 bytes, an address word that is not a clean address (a `Call` or `ProbeCall` target, or `resolveCall`'s resolved target at index 0) |
| `NotSelf(address caller)` | `evaluateGuarded` was called by anyone other than the contract itself |
| `InvalidReference(uint256 node, uint256 ref)` | a reference does not point strictly backward, or a `Parameter` index is past the supplied parameters |
| `InvalidTarget(uint256 node, address target)` | a `Call`, a `Resolve`, a resolve-once operand or the `evaluateEncoded` self-call targets an address without code (the index is the node, or the operand position in the resolve-once entry points) |
| `NodeCallFailed(uint256 node, address target, bytes callData, bytes reason)` | the staticcall a node or a resolve-once entry point made reverted; calldata and reason are preserved. Note the four-argument signature: the core's `CallFailed(address, bytes)` is a different error |

Descriptor and value validation raise the shared [`AbiCodec` errors](/docs/reference/errors#abicodec-shared-abi-machinery) (`InvalidTypeDescriptor`, `InvalidValue`, the component errors), and `ProbeCall` raises the core's `DidNotRevert` and `UnexpectedRevertData`.
