---
title: Expressions
description: "Deduplicating calculations: define a read or a calculation once, name it, and reuse its result across a claim, with lazy branches and guarded fallbacks."
---

`Expressions` is the expansion pack that makes a claim pay for a read or a calculation once. When the same value feeds several parts of a claim, a plain assertion writes it out again each time and evaluates it each time. With Expressions you define the value once, name it and reuse the result, which saves gas whenever the repeated part is expensive. It also lets a claim branch lazily, so only the branch that is taken is read, and try a read with a fallback when it may fail. It is a stateless view contract, and the EVMcrispr compiler emits its graphs for you, so you rarely write one by hand. A raw ERC-8211 `InputParam` is a tree with no way to name a subterm, so a repeated expression is duplicated in calldata and resolved again at every occurrence. Expressions adds typed expression graphs: node lists whose nodes reference earlier nodes, so a reference reuses a successfully cached value, branches can be lazy, and a whole canonical ABI value (a string, an array, a tuple) binds to one node. It reaches the core through a local `ICore` interface at the address the expression names, and shares `AbiCodec`. It adds nothing to the core and changes no wire format.

You meet it in a decoded batch in two places. The first is a call to `evaluate` or `evaluateEncoded` on the Expressions address, usually as an operand spliced into a core `read`. The second is a Collections call whose `Callback.expression` field is non-empty: Collections then calls `evaluateEncoded` once per element. The EVMcrispr compiler emits graphs for you (see [EVML spellings](#evml-spellings)); you do not write them by hand in a script.

Resolving N operands once each for a single call is the core's job, through `get` for a whole call and `gather` for a `bytes[]` (see [Assertions](/docs/contracts/assertions)). A graph is for values shared across several places.

## Functions

| Task | Function | Meaning | EVML spelling |
|---|---|---|---|
| Evaluate a graph | `evaluate(expression, parameters)` | Checks the graph, evaluates the `result` node, returns its value raw | none directly; the compiler emits it |
| | `evaluateEncoded(expression, parameters)` | `evaluate` over an `abi.encode(Expression)` payload; the Collections callback socket | none directly; emitted for generic `@map!`, `@filter!`, `@find!` and friends |
| Internal | `evaluateGuarded(expression, parameters, index, initial)` | The call boundary behind `TryOrElse` and `IsValid`; only the contract itself may call it | none |

| Node kind | Meaning |
|---|---|
| `Literal` | A constant value |
| `Parameter` | One of the values supplied to `evaluate` |
| `Resolve` | The core's `resolve` of an `InputParam`, constraints included |
| `Call` | A staticcall with arguments from earlier nodes |
| `Select` | A lazy ternary on the first word of a condition |
| `Wrap` | A value wrapped as one `bytes` value |
| `Array` | Earlier values packed as a canonical `T[]` |
| `Tuple` | Earlier values assembled as one canonical tuple |
| `TryOrElse` | The value of an attempt, or a fallback if the attempt fails |
| `IsValid` | Whether an attempt evaluates successfully, as a bool |
| `ProbeCall` | A staticcall that must revert, returning its revert reason |

## The graph

```solidity
enum Kind { Literal, Parameter, Resolve, Call, Select, Wrap, Array, Tuple, TryOrElse, IsValid, ProbeCall }

struct Node {
    Kind kind;
    string valueType;   // the author's claim about this node's value, validated as a canonical encoding
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

`Kind` is ABI-encoded as `uint8`. Unused `data`, `selector` and `arguments` fields are ignored.

### Validation before evaluation

`evaluate` first checks the whole graph, reachable or not:

- `result` must index a node (`InvalidNode(result)` otherwise).
- Every `valueType` must parse (`InvalidTypeDescriptor` otherwise).
- Every reference must point to an earlier node (`InvalidReference(node, ref)`). A bad reference is reported before a bad kind.
- Each kind must carry the right number of references (`InvalidNode(node)`): `Call` at least one, `Select` three, `TryOrElse` and `ProbeCall` two, `Wrap` and `IsValid` one, `Literal`, `Parameter` and `Resolve` none. `Array` and `Tuple` take any number.
- A `ProbeCall`'s `refs[1]` must be a node typed `bytes` (`InvalidNode` otherwise), since its value is decoded as the calldata.
- An out-of-range `kind` value is refused by the ABI decoder.

It then evaluates the `result` node. Only nodes reachable from `result` execute. After a node produces its value, `AbiCodec.validate(valueType, value)` checks that the bytes are a canonical single-value encoding of the claimed type: offsets, lengths, padding, the absence of trailing data and each static word's range for its type are verified. Which type the value really has stays the author's claim, as with `nav` descriptors on the core. A mismatch reverts with `InvalidValue` at the offending offset.

The result returns raw, like the core primitives, so an evaluation is itself an operand.

### Node kinds

| Kind | Rules |
|---|---|
| `Literal` | `data` is the value itself, a canonical encoding of `valueType`. |
| `Parameter` | `data` is `abi.encode(uint256 index)`; the value is `parameters[index]`, one of the canonical single-value envelopes supplied to `evaluate`. `InvalidNode` when `data` is not one word, `InvalidReference(node, index)` when the index is out of range. |
| `Resolve` | `data` is `abi.encode(InputParam)`; the value is `Assertions.resolve` of that operand on `expression.core`, constraints included. It resolves only when reached. Malformed `data` can cause a bare revert, an allocation panic or a resource failure. |
| `Call` | `refs[0]` is the target address (one clean 32-byte address word, else `InvalidNode`); the remaining references are the arguments in order, encoded as the tuple `arguments` describes and prefixed with `selector`. The value is the staticcall's raw returndata. A target without code reverts `InvalidTarget(node, target)`; a reverting call raises `NodeCallFailed`. |
| `Select` | References are condition, then, else. Truth is judged like the core's `cond`: the first word of the condition decides (every value spans at least one word), nonzero evaluates `refs[1]` and zero evaluates `refs[2]`. Only the chosen branch executes. A condition longer than one word is accepted and only its first word counts. |
| `Wrap` | The referenced value's encoding wrapped as one `bytes` value (a canonical bytes envelope, `abi.encode(bytes)`, around those bytes). |
| `Array` | The referenced values packed as a canonical `T[]`, where `arguments` is the element descriptor `T`. |
| `Tuple` | The referenced values assembled as one canonical tuple value whose components `arguments` describes; a dynamic tuple gets its leading offset word so it stays a single value. `"()"` with no references is the empty tuple (the grammar has no empty-tuple production, so it is special-cased, as the core does). |
| `TryOrElse` | Evaluate `refs[0]` in an isolated frame; on ordinary failure evaluate `refs[1]` instead; exhaustion and the reserved signal propagate. |
| `IsValid` | A canonical bool word: whether `refs[0]` evaluates successfully in an isolated frame. |
| `ProbeCall` | `refs[0]` is a target address and `refs[1]` a calldata `bytes` value; the target is staticcalled and must revert, and the value is its revert data as a `bytes` value. See [ProbeCall](#probecall). |

### A graph with a shared subterm

"Append the element to itself, then append the accumulator", with the element named twice and evaluated once. With `node`, `callNode` and `refs3` as small helpers that build a node, a call node and a three-reference list:

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

## Memoisation

A reached node reuses its successful cached value. The cache lasts one `evaluate` call:

- In a Collections traversal that is one callback invocation. A `Resolve` node reached in every iteration resolves once per iteration, not once per traversal. Resolve a source array once outside the graph (the core's `gather`, or a `Resolve` node in an enclosing graph) and pass its elements in as parameters instead.
- Cache changes inside a failed guarded attempt are discarded, so work from that attempt can execute again.
- Sharing external reads preserves values only when the reads are deterministic under the relevant call context. Even a `view` call can depend on `gasleft()` or `msg.sender`, so sharing such calls is observable.

The cache (`Cache`: values, ready flags, and each node's parsed `valueType` shape) is a public struct only because guarded evaluation hands it across an external self-call. A graph carries fixed setup, per-node and call overhead, so it wins only when the resolutions it saves cost more than the nodes it adds.

## Guarded evaluation

`TryOrElse` and `IsValid` evaluate their attempt through `evaluateGuarded`, an external self-call, because a call frame is the EVM's only catch primitive. Only the contract itself may call it (any other caller reverts `NotSelf(caller)`). A generic `Call` or `ProbeCall` whose target is this contract and whose calldata starts with the `evaluateGuarded` selector reverts `GuardedCallForbidden()`, so only the typed internal guard supplies a cache. Ordinary self-calls to `evaluate` and `evaluateEncoded` remain available and start fresh caches.

The frame takes a copy of the memo cache in. On success the cache comes back and replaces the caller's, so values evaluated inside the attempt stay memoised. On failure the frame's cache changes are discarded with the frame. Failures that count as failures: a reverting target, a type mismatch, any ordinary error.

Exhaustion is not a failure. If the failed call burned (nearly) all the gas it was given, or reverted with exactly the four-byte `SubcallOutOfGas()` signal, the evaluation reverts `SubcallOutOfGas` instead of taking the fallback or reading false, because the transaction's gas limit could have chosen the outcome. `ProbeCall` refuses the same way, and the signal crosses the core, Operations and Collections unchanged. Do not use these nodes to distinguish other failure causes. The guarantee covers these cooperating wrappers, not external targets that swallow failures or deliberately branch on available gas. It is the same guard the core's `orElse` and `isValid` apply (see [Assertions](/docs/contracts/assertions)).

## ProbeCall

`ProbeCall` reuses the core's revert-probe errors, declared with the core's names and argument types so both probes decode alike. It runs in Expressions' own frame, so the target's reason survives intact.

- A target that succeeds reverts the evaluation with `DidNotRevert(target, callData)`.
- With a nonzero `selector`, revert data that does not start with it reverts `UnexpectedRevertData(expected, actual)`, where `actual` is zero when the revert carried fewer than four bytes. A matching selector is stripped, leaving the error's arguments word-aligned. An error with no arguments yields empty bytes.
- A target without code has no reason to report: with a zero selector the value is empty bytes, with a nonzero one the node reverts `UnexpectedRevertData(expected, 0x00000000)`.
- A probe aimed at this contract's own `evaluateGuarded` reverts `GuardedCallForbidden`.

## Collections callbacks through an expression

`Collections.Callback` carries a trailing `bytes expression` field (see [Collections](/docs/contracts/collections)). Empty, the callback is a direct call: `target`, `selector`, and the argument tuple with the element slots substituted. Non-empty, it is `abi.encode(Expression)`: Collections binds the element slots (`first`, and `second` for binary operations) into the constants exactly as for a direct callback, then staticcalls `target` with `evaluateEncoded(expression, substitutedArguments)`. `selector` is ignored and `target` is the Expressions contract. Inside the graph, `Parameter` nodes read the substituted slots, so an element can be referenced any number of times, arguments may be dynamic and multi-word, and live reads compose without byte-offset substitution.

The result is validated exactly like a direct callback's: mapped values against `outputType`, predicate results as a canonical 0/1 word. That last rule is Collections' own (`_predicate` demands a canonical bool from every callback result); `Select`'s first-word truth rule is a different concern and does not relax it. Collections reaches Expressions through an `IExpressions` interface rather than a source import, so an edit to `Expressions.sol` moves only the Expressions address.

### evaluateEncoded

`evaluateEncoded` forwards the encoded expression to `evaluate` through a self-call and returns the same raw value. It does not decode the payload first: `evaluate` validates what it reads.

- The payload bytes are placed last in the forwarded calldata, after the call head and the encoded parameters. ABI offsets only point forward, so every offset inside the payload resolves inside the payload or past the end of the calldata, never into the parameters. The payload alone determines the graph.
- A payload malformed in a field evaluation reads fails inside the self-call (`NodeCallFailed`, usually with an empty reason). One malformed only in fields evaluation never reads, such as the `data` of a node nothing reaches, is accepted.
- A payload shorter than a word, or whose leading offset is below 32 or past its own end, reverts without data.
- An ordinary failure inside surfaces as `NodeCallFailed(0, expressions, data, reason)` wrapping the inner error, which Collections in turn reports through `CallbackFailed`. Exhaustion and an exact `SubcallOutOfGas()` signal bypass both wrappers and propagate unchanged.

## EVML spellings

Expressions has no helper faces of its own. The EVMcrispr compiler emits graphs for generic collection callbacks (`@map!`, `@filter!`, `@find!` and friends over ABI-typed elements), for recipes that share one resolved envelope between two uses (the word payload of an array, the argument tuple of a calldata value, `@unzip!` lanes), and for the probe behind `@reverts!` on a call with live arguments. A named definition applied by an array face is inlined per element:

```evml
load lang
set $vault 0x1111111111111111111111111111111111111111
def @ge100! "$x: number -> bool" @bool!($x >= 100)
assert @all!($vault::!{caps()(uint256[])} @ge100!)
```

A probe whose call has a live argument:

```evml
set $vault 0x1111111111111111111111111111111111111111
set $registry 0x2222222222222222222222222222222222222222
assert @reverts!($vault::!{previewRedeem(uint256)(uint256) $registry::!{shares()(uint256)}}) == false
```

See the [EVML guide](/docs/evml) for the helpers.

## Failure modes and limits

| Error | Raised when |
|---|---|
| `InvalidNode(uint256 node)` | The node is malformed: `result` out of range (the index reported is the result index), the wrong reference count for its kind, a `Parameter` whose data is not one word, an address word that is not a clean address (a `Call` or `ProbeCall` target), a `ProbeCall` whose calldata node is not typed `bytes`. |
| `InvalidReference(uint256 node, uint256 ref)` | A reference does not point strictly backward, or a `Parameter` index is past the supplied parameters. |
| `InvalidTarget(uint256 node, address target)` | A `Call`, a `Resolve` or the `evaluateEncoded` self-call targets an address without code (the index is the node). |
| `NodeCallFailed(uint256 node, address target, bytes callData, bytes reason)` | The staticcall a node made reverted without exhaustion or the reserved signal; calldata and reason are preserved. The four-argument signature differs from the core's `CallFailed(address, bytes)`. |
| `NotSelf(address caller)` | `evaluateGuarded` was called by anyone other than the contract itself. |
| `GuardedCallForbidden()` | Generic call or probe dispatch targeted this contract's guarded evaluation entry. |
| `DidNotRevert(address target, bytes callData)` | A `ProbeCall` target did not revert. Shares the core's selector. |
| `UnexpectedRevertData(bytes4 expected, bytes4 actual)` | A `ProbeCall`'s revert data does not begin with the required selector. Shares the core's selector. |
| `SubcallOutOfGas()` | A call the graph made failed after burning all the gas it was given; raised instead of letting `TryOrElse` fall back, `IsValid` read false or `ProbeCall` report a revert. Shares the core's selector and propagates unchanged. |

Descriptor and value validation raise the shared [`AbiCodec` errors](/docs/contracts/errors#abi-descriptor-and-value-errors) (`InvalidTypeDescriptor`, `InvalidValue`, the component errors).

Other limits:

- A bare revert without data can come from wire bytes Solidity cannot decode (a `Resolve` node's data, an `evaluateEncoded` payload, an out-of-range enum), nested allocation requests can raise `Panic(0x41)`, and resource exhaustion can return empty data. These are documented, not pre-validated. A well-typed graph never reaches a bare decode: a `uint256` operand fed to a `ProbeCall` as calldata is refused with `InvalidNode`, not a bare revert.
- Memoisation does not span `evaluate` calls or collection iterations.
- Descriptors are the author's claim. A shape-compatible wrong claim reads the wrong value; the validator checks canonical form and ranges, not intent.

## Why it lives here

A graph is not an unresolved operand the core must judge: it takes resolved values by reference and builds a value, which fails the core's admission test. It is also not scalar computation over resolved values (Operations) or iteration (Collections). Expressions is the home for expression graphs, and it versions by deployment at a new address like the other computation contracts. Resolve-once construction of a single call stays on the core as `get` and `gather`, where it avoids an external hop per operand.
