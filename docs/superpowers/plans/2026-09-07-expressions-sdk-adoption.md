<!-- Written 2026-09-07 from a read-only design pass; revised the same day after review, a measured spike and the contract changes those measurements asked for. Scope: the SDK in the vendored checkout. Supersede or delete when delivered. -->

# Plan: resolve-once call construction and `Expressions` in the EVMcrispr SDK compiler

Status: design, SDK scope. Written against the main repo working tree of 2026-09-07 (the contract changes in 0.1 are in the working tree, uncommitted) and the vendored checkout `website/.evmcrispr` @ `6513da6c` with the SDK retarget in flight (`CompileCtx = {module, interpreters, core, operations, collections, hints?}`, `packages/sdk/src/onchain/{assertion,decode}.ts` present, untracked). Everything below assumes the retarget lands first and the release mechanics of Phase 0 run once.

## 0. Facts this plan is built on

### 0.1 What the contracts now provide (landed 2026-09-07 in the main repo working tree)

| Change | Where | What the SDK gets |
|---|---|---|
| `Assertions.readArgs(InputParam target, bytes4 selector, string argumentTypes, InputParam[] args)`: resolves the target and each argument once in-frame, encodes the tuple through `AbiCodec.tuple`, staticcalls the destination from the core frame, raw-returns | `contracts/Assertions.sol` after `read`; `_encodeArguments` beside `_staticCall`; tests `contracts/tests/CoreExtensions.t.sol` | A resolve-once host for calls with several dynamic arguments that keeps the core as `msg.sender`. Error numbering as `read` (target 0, `args[i]` at `i + 1`); `AbiCodec`'s `ComponentCountMismatch`, `InvalidComponentEnvelope`, `InvalidComponentLength`, `InvalidComponentValue` name the argument index; `"()"` with no arguments is the bare selector |
| `nav` returns arrays of dynamic elements and dynamic tuples as `abi.encode(value)` (extent from `AbiCodec.body`; malformed nested data reverts `AbiCodec.InvalidValue(offset)`); `PAYLOAD` stays string/bytes only, `LEN` unchanged | `Assertions._returnDynamic`, `_extent`; `CoreReads.t.sol` flipped; `test/nav-encode-fuzz.test.ts` oracle updated | `lensedDataOperand` works for `string[]`, `bytes[]`, dynamic-struct arrays and struct fields; Phase 4 has no lens restriction |
| `AbiCodec` parses with assembly scanners and `tupleLayout` parses once; `Expressions.evaluate` caches every node's shape (`Cache.dynamic`, `Cache.words`) and takes the tuple's dynamic flag from the layout | `contracts/lib/AbiCodec.sol`, `contracts/Expressions.sol`; `contracts/tests/AbiCodecGas.t.sol` | Descriptor parsing 3 to 4× cheaper everywhere (callback binds, graph nodes, `readArgs`) |
| `Assertions.resolveValues(InputParam[] args) returns (bytes[])`: resolves N operands once each in-frame, returns the raw results as a canonical `bytes[]`; `Expressions.resolveCall`, `resolveArguments` and `resolveValues` removed (each paid an external hop per operand; `resolveCall` also changed the caller). Expressions is graphs only | `contracts/Assertions.sol` after `resolve`; tests `CoreExtensions.t.sol` (`test_resolveValues_*`, including the `readArgs(…, "(bytes[])", [resolveValues])` shape) | The `bytes[]` assembler for Phase 1b lives on the core: `EXPRESSIONS_ABI` carries no resolve-once functions and `encodeResolveValues` goes in `core.ts` beside `encodeReadArgs` |
| Fixtures: `MockTarget.caller()`, `callerGated(address expected, string a, string b)`, `join3`, `join6`, `strings() returns (string[])`, `taggedPairs() returns (uint256, Pair[])` | `contracts/tests/Mocks.sol` | Caller-preservation and multi-argument fixtures, vendored to the checkout by the Phase 0 sync |
| Gas tables as permanent tests | `contracts/tests/ExpressionsGas.t.sol` (`ExpressionsGasTest`, `GraphCostGasTest`), `contracts/tests/AbiCodecGas.t.sol` | Every constant in this plan cites a row there |

Runtime sizes after the change (`test/bytecode-size.test.ts`): Assertions 17,050 B (7,526 headroom), Operations 20,080 B (4,496), Collections 23,441 B (1,135, up from 272), Expressions 17,860 B (6,716). The main repo gate `pnpm test` passes at 466 tests (380 Solidity, 86 nodejs, fuzzers included).

**Not run yet (Phase 0 below):** the release mechanics. All four addresses move (every contract imports `AbiCodec`), the checkout's runtime fixtures are stale against the working tree (the vendored `Assertions` has no `readArgs`), and Expressions is still `released: false`.

### 0.2 Measured (2026-09-07, `pnpm test` log lines of the two gas suites)

Isolated execution: `gasleft()` around one `staticcall` to `Assertions.resolve(param)`; solc 0.8.36, optimizer 200, cancun. Transaction estimates add ≈ 21k intrinsic plus 16 gas per non-zero calldata byte. Sources: a 40-byte constant string (≈ 3.6k raw) and a "costly" variant burning 300 keccak rounds first (≈ +65k). `Sink.takeN(string…) returns (uint256)`.

**Table A: L live dynamic arguments, four hosts**

| Source | L | `read` + `spliceLayout` | **core `readArgs`** | `Expressions.resolveCall` | `read(target, sel, [resolveArguments])` |
|---|---|---:|---:|---:|---:|
| cheap | 1 | 19,000 | 20,217 | 28,301 | 26,208 |
| cheap | 2 | 51,474 | **32,440** | 40,440 | 41,011 |
| cheap | 3 | 126,757 | **43,887** | 55,174 | 56,480 |
| costly | 1 | 83,686 | 84,903 | 92,987 | 90,894 |
| costly | 2 | 245,532 | **161,812** | 169,812 | 170,383 |
| costly | 3 | 514,873 | **237,945** | 249,232 | 250,538 |

Word-only `read(ops, add, [lit, lit])` 14,718 vs `readArgs` 21,219 (row B). Caller: `read`, `readArgs` and `read` over `resolveArguments` show the core; `resolveCall` shows Expressions; `callerGated(core, a, b)` passes through `readArgs` and fails through `resolveCall` (`CoreExtensions.t.sol`).

**Table C: shared leaf `x`, tree vs graph**

| Shape | cheap | costly |
|---|---:|---:|
| `x` alone (one `core.resolve`) | 10,275 | 74,974 |
| tree `add(x, x)` | 14,976 | 144,374 |
| graph `[Literal ops, Resolve x, Call add(1,1)]` | 50,531 | 115,230 |
| graph `[Literal src, Call word(), Literal ops, Call add]` | 52,552 | 117,251 |
| tree `add(add(x,x), add(x,x))` (x resolved 4×) | 32,146 | 290,942 |
| graph `[Literal ops, Resolve x, Call add, Call add]` (x once) | 72,904 | 137,603 |

**Table G: graph cost decomposition** (through `core.resolve` unless "raw")

| Graph | gas |
|---|---:|
| G0 `[Literal uint256]` | 16,277 |
| G1 `[Literal ops, Literal 7, Call add "(uint256,uint256)"]` | 44,498 (raw 38,934; calldata 1,572 bytes) |
| G2 `[Literal ops, Literal string(40 B), Call byteLen "(bytes)"]` | 41,461 |
| G3 `[Literal, Literal, Tuple "(uint256,uint256)"]` | 42,297 |
| raw `evaluate` of 1 / 2 / 3 / 4 Literal nodes | 10,818 / 12,696 / 17,086 / 21,497 (644 to 1,892 calldata bytes) |
| raw `[Literal, Literal, Tuple]` | 38,882 |
| reference: direct `ops.add(7,7)` | 3,637 |
| reference: `core.read(ops, add, [lit, lit])` | 9,837 |

**Table K: `AbiCodec` primitives, net of the 3,071 external-call baseline**: `shape("(uint256,uint256)")` 1,862 · `tupleLayout` 5,697 · `tuple` over two words 10,573 · `tuple("(bytes)", 40 B)` 8,496 · `validate("uint256")` 262 · `validate("string", 40 B)` 2,576. Before the change these were 6.9k, 25.2k, 30.0k, 17.3k, 2.5k and 5.0k.

**Table U: the `unpackArray(string, bytes)` boundary** (`core.read(collections, unpackArray, [heads + "string" tail][encoded])`)

| Array | unwrapped envelope | tree wrap `rawCall(core, resolve(env))` | graph `Wrap(Resolve(env))` |
|---|---|---:|---:|
| `string[]` (2) | reverts | 37,506 | 109,096 |
| `string[]` (0) | reverts | 27,496 | 88,431 |
| `(address,uint256)[]` (2) | reverts | 42,502 | 113,173 |
| `string[][]` (2) | reverts | 45,094 | 124,348 |
| lensed `(address,uint256)[]` through `nav` | | 69,584 | |
| lensed `string[]` through `nav` | | 58,412 (re-encoder) | |

Also pinned: `mapValues("string", "uint256", values, Callback{target: expressions, arguments: "(string)", constants: [""], first: 0, expression: [Literal ops, Parameter 0 "string", Call byteLen "(bytes)"]})` returns `[2, 39]`: a `string` Parameter satisfies a `(bytes)` component.

### 0.3 SDK facts (from the checkout)

| Fact | Where |
|---|---|
| `spliceLayout`: live source `j` of `L` runtime-sized lives resolves `1 + (L − j)` times; each payload sizing is `bitAnd(add(pick(env,1),31),~31)`; hard cap `MAX_LIVE_SLOTS = 4` | `packages/sdk/src/onchain/layout.ts:91, 116-126, 153-203` |
| The argument classifier is `compileArgSpecs` (`compile.ts:386-420`) → `buildCallSegments` (`construct.ts:103-188`); `reads.ts` `argSpec` (`:31-64`) is the second entry; `compileHopArgs`/`readParam` (`compile.ts:432-456`) and `callReadOperand` (`reads.ts:75-111`) emit the `read` | checkout |
| Precompiled operands (`operandNode`, `compile.ts:1053-1060`) are recognised by `compileOperand` (`:1063-1078`) and `reads.ts` `argSpec` (`:47`) but not by `chainArgWithLens` (`:1109-1146`, throws "expects a `::` call expression"), `compileArgSpecs`, or the faces classifying by hand: `str.concat.ts:44-48` (whose fallback interprets the synthetic bareword as the literal string `"element"`), `bytes.concat.ts:45-49`, `str.join.ts:63-67`, `flat.ts:46-47`, `zip.ts:38-39`, `len.ts:33`, `enumerate.ts:38` | checkout |
| `def` parameters accept the built-in type names, `string` included, and substitute AST nodes (`defs.ts:35-77`), so `def @length! "$x: string -> number" @str.len!($x)` reaches `str.len`'s compile face with whatever node the caller supplies | `packages/sdk/src/utils/schema.ts:33-50` |
| Inline `::{sig}` ABIs are parsed as `view` (`compile.ts` `hopAbi`), so `stateMutability` cannot say whether a destination is caller-independent | checkout |
| No periphery function reads `msg.sender` (only `Expressions.evaluateGuarded`'s self-check), so `Call` nodes to Operations, Collections or the core are caller-neutral | `grep -n msg.sender contracts/*.sol` |
| `Operations.rawCall(target, data)` returns the raw returndata inside a `bytes` envelope: the tree-level `Wrap` | `contracts/Operations.sol`, `OP_SELECTORS.rawCall` |
| Manifest: `CONTRACTS[]` carries `released`, `sdkAddressExport`, `key`; Expressions is `released: false`, `sdkAddressExport: null`; `check-integration.mjs:50-77` checks SDK address and fixture only when `released`; `DEPLOYED_CONTRACTS` already keys `expressions`; `sync-assertions-bytecode.ts` vendors Assertions, Operations, Collections, MockTarget | `website/scripts/export-deploy-artifact.mjs:57-118`, `website/src/components/deployments/shared.ts`, `scripts/sync-assertions-bytecode.ts:40-70` |
| Test-utils mocks: `installConstantMock(client, address, data)`, `installSelectorMock(client, address, entries)`; installer `installAssertionsCore` installs three | `packages/test-utils/src/onchain/{mock,install}.ts` |
| SDK adoption of Expressions today: zero; `addresses.ts` has no `EXPRESSIONS_ADDRESS`; `CORE_ABI` (`core.ts:14-26`) has no `readArgs` | checkout |

### 0.4 Where the compiler duplicates resolution today

| Shape | Emitted tree | Source resolved | Resolution in this plan |
|---|---|---|---|
| `spliceLayout` with L runtime-sized lives | offset add chains | `L + L(L−1)/2` | `readArgs` (Phase 1) |
| `enumerateParam` live `offset_b` (`recipes.ts:391`) | `add(mul(n,32),160)` | 2× | `readArgs(collections, zipWords, "(bytes,bytes)", [iotaWords(n), s])` (Phase 1) |
| `concatParam`/`flat` N live parts (`recipes.ts:658`) | quadratic splice, cap 4 | `L(L−1)/2` | `readArgs(ops, concat, "(bytes[],bytes)", [core.resolveValues(payloads), delimiter])` (Phase 1b) |
| `wordsPayload` (`arrays.ts:67`, `arrayWordsParam` `recipes.ts:423`) | `slice(reframed env, 64, mul(count,32))` | 3× | `readArgs(ops, slice, "(bytes,uint256,uint256)", [wrapParam(env), 64, mul(count,32)])` resolves the source twice (row D decides) |
| `@bool!((x > 0) and (x < 10))`, `def @sq!` applied to a call, `@absDiff!(a b)` named twice, `includesWordParam`, `calldataArgsParam`, `splitParam` | tree with a repeated leaf or subtree | 2–3× | graph only when the shared subtree is a costly composite (1.3); otherwise stays |
| `mulOf` fusion, `x ^ 2` | n/a | 1× | unchanged |

## 1. Design decisions

### 1.1 Call host per shape (Q1)

The SDK emits two hosts, both on the core. Expressions' resolve-once entry points no longer exist (Table A's last two columns are the pre-removal measurements: they cost the same as each other, more than `readArgs`, and `resolveCall` changed the destination's `msg.sender` to Expressions).

| Shape | Host | Why (Table A, B) |
|---|---|---|
| word-only calls | `read`, byte-identical to today | 14,718 vs 21,219 |
| exactly one runtime-sized live, placed last (literal offsets) | `read`, byte-identical to today | 19,000 vs 20,217; existing shape tests keep passing |
| any call that would need a runtime offset (a runtime-sized dynamic live followed by another dynamic live) | **`readArgs`** | 32,440 vs 51,474 at L = 2 cheap, 161,812 vs 245,532 costly, 43,887 vs 126,757 at L = 3 |

```ts
// packages/sdk/src/onchain/construct.ts
export type CompiledCall =
  | { host: "read"; selector: Hex; segments: InputParam[] }
  | { host: "readArgs"; selector: Hex; argumentTypes: string; args: InputParam[] };

/** A dyn spec whose padded size is not a build-time literal. */
export const runtimeSized = (s: ArgSpec): boolean => s.kind === "dyn" && typeof s.payload !== "bigint";

/** `readArgs` when some runtime-sized dynamic live is followed by another
 *  dynamic live (the only case that needs a runtime offset), else `read`.
 *  Pinned by ExpressionsGas.t.sol row A (L = 2 cheap and costly). */
export function chooseHost(specs: readonly ArgSpec[], inputs: readonly AbiParameter[]): CompiledCall["host"];
export function buildCall(ctx: CompileCtx, fnAbi: AbiFunction, specs: ArgSpec[]): CompiledCall;
/** `read` → staticCallParam(ctx.core, encodeRead(target, sel, segments));
 *  `readArgs` → staticCallParam(ctx.core, encodeReadArgs(target, sel, argumentTypes, args)). */
export function callParam(ctx: CompileCtx, target: InputParam, call: CompiledCall): InputParam;
```

`readArgs` arguments are whole canonical values: `word` → the param as is (32 bytes; `AbiCodec.validateComponent` checks the exact length), `dyn` → the envelope as is, `value` → `rawParam(encodeAbiParameters([input], [value]))`. `argumentTypes = "(" + inputs.map(formatParamType).join(",") + ")"` (`compile.ts:742` already emits the AbiCodec grammar). The target param passes through unchanged (literal address word or a live chain prefix). `core.ts` gains `"function readArgs(InputParam target, bytes4 selector, string argumentTypes, InputParam[] args) view"` in `CORE_ABI`, `"readArgs"` in `CoreFn`, and `encodeReadArgs(target, selector, argumentTypes, args)`.

`spliceLayout`'s runtime-add path (`layout.ts:184-200`) and `MAX_LIVE_SLOTS` are deleted in Phase 1; the function keeps literal offsets and throws `"internal: a runtime offset was requested; route through buildCall"` if handed two runtime-sized lives. `compileLiveHelperArg` (`compile.ts:995-1011`) hands a `String`/`Bytes` helper result to a dynamic parameter as `{kind:"dyn", param, payload: bytesPayloadParam(...)}` instead of rejecting.

Consumers to switch in Phase 1: `compileHopArgs`/`readParam`, `callReadOperand`, `indexOfParam` (live needle), `replaceParam`, `zipParam` (both live), `enumerateParam`, `splitParam` (via `indexOfParam`). Phase 1b: `concatParam`, `flat`, `str.join` with N live parts through the core's `resolveValues(parts)` as the single `bytes[]` argument of `readArgs(ops, concat, "(bytes[],bytes)", …)`; each live part is `payloadParam(...)` (a `nav … PAYLOAD` operand resolves to the raw payload, and `resolveValues` wraps each raw result as one element), a literal part is `rawParam(bytes)`. The core still makes the `concat` call.

Lambda extraction (`lambda.ts:218-308`) is unaffected: a `readArgs` operand takes the general path (target and calldata kept verbatim), and marker windows stay word-aligned inside an encoded `InputParam[]`.

### 1.2 Caller rule

Who executes the destination `staticcall` decides `msg.sender`:

| Lowering | Caller at the destination |
|---|---|
| core `read`, `readArgs`, `chain`, `cond`, `orElse`, `isValid`, `revertData` | core (today's behaviour) |
| graph `Call`, graph `ProbeCall` | Expressions |
| word-template lambda | Collections (direct template) or core (composed `read` template) |
| `Callback.expression` lambda | Expressions |

Rule: **a user-contract call keeps the core as caller.** The SDK never emits `resolveCall` or `ProbeCall`; in graphs only calls to the core, Operations, Collections or Expressions become `Call` nodes (0.3: none reads `msg.sender`), and a user-contract call stays a `Resolve` leaf holding its `read`/`readArgs` InputParam. Collection lambdas never had the core as caller; generic lambdas making `Call`s from Expressions are a documented change (Collections → Expressions) in the `map.md`/`filter.md`/`reduce.md` On-chain face sections, not a regression against the tree path. Fixture: `MockTarget.callerGated(core, a, b)` succeeds through every emitted host in `read-hops.test.ts`.

### 1.3 Graphs and shared subterms (Q3): admission by measured cost

`packages/sdk/src/onchain/graph.ts`:

```ts
export const KIND = { Literal:0, Parameter:1, Resolve:2, Call:3, Select:4, Wrap:5, Array:6, Tuple:7, TryOrElse:8, IsValid:9, ProbeCall:10 } as const;
export interface ExpressionNode { kind: number; valueType: string; data: Hex; refs: bigint[]; selector: Hex; arguments: string }
export interface Expression { core: Address; nodes: ExpressionNode[]; result: bigint }
export type NodeId = number;

export class GraphBuilder {
  constructor(readonly core: Address, readonly hosts: { core: Address; operations: Address; collections: Address; expressions: Address });
  literal(valueType: string, data: Hex, label?: string): NodeId;
  parameter(valueType: string, index: number, label?: string): NodeId;
  resolve(valueType: string, param: InputParam, label?: string): NodeId;
  /** `target` must be a Literal address node equal to one of `hosts` (1.2); throws otherwise.
   *  A `bytes`-typed argument position fed by a non-bytes node must be a `wrap` (the Wrap rule). */
  call(valueType: string, target: NodeId, selector: Hex, argumentTypes: string, args: NodeId[], label?: string): NodeId;
  select(valueType: string, cond: NodeId, then_: NodeId, else_: NodeId): NodeId;
  tryOrElse(valueType: string, attempt: NodeId, fallback: NodeId): NodeId;
  isValid(attempt: NodeId): NodeId;                        // "bool"
  wrap(inner: NodeId): NodeId;                             // "bytes"
  array(elementType: string, items: NodeId[]): NodeId;     // `${elementType}[]`
  tuple(componentTypes: string, items: NodeId[]): NodeId;
  hits(id: NodeId): number;
  readonly labels: string[];
  build(result: NodeId): Expression;
}
export function encodeEvaluate(expr: Expression, parameters: Hex[]): Hex;
export function encodeExpression(expr: Expression): Hex;            // abi.encode(Expression) for Callback.expression
export function graphParam(ctx: CompileCtx, expr: Expression): InputParam;

/** Seeds from ExpressionsGas.t.sol rows C and G (2026-09-07); re-pin when the rows move. */
export const GAS_MODEL = {
  evaluateFixed: 10_000,   // raw evaluate of one Literal minus the call baseline
  perNode: 3_500,          // each further Literal
  perCallNode: 21_000,     // a Call with two word args, excluding the callee's own cost
  coreFrame: 6_200,        // read(ops, add, [lit, lit]) minus ops.add
  sourceFloor: 3_600,      // the cheapest plausible external source
} as const;
export const GRAPH_MIN_SAVING = 15_000;
export function graphCost(expr: Expression): number;
export function treeCost(o: Operand): number;                     // frames of the emitted tree, sourceFloor per leaf call
export function maybeGraph(ctx: CompileCtx, o: Operand): Operand;
```

Hash-consing: constructors intern on `key = [kind, valueType, data, refs.join(","), selector, arguments].join("|")`; `Resolve` leaves dedupe by `paramData`.

**Admission.** `maybeGraph` (called from `compileAssertionSide`, test-utils `compileExpression` and top-level callers only) emits the graph when `treeCost(o) − graphCost(g) ≥ GRAPH_MIN_SAVING` with every external leaf costed at `sourceFloor`, that is, only when the graph wins even if every source is trivially cheap. With Table C this admits a shared **composite** subterm (a core-hosted `read`/`readArgs`/`nav`/`chain`/fold appearing at least twice, ≥ 8 frames saved) and never a shared plain leaf (`add(x, x)`: 14,976 tree vs 50,531 graph). Constructions with no tree alternative (Phase 4 callbacks, `Array`/`Tuple` beyond `resolveValues`) build graphs unconditionally.

**What may become a `Call` node**: only calls whose RAW target word equals `ctx.core`, `ctx.operations`, `ctx.collections` or `ctx.expressions` (1.2). A user-contract call, however many live arguments, is a `Resolve` leaf. `revertData` is a `Resolve` leaf, never `ProbeCall`.

**The Wrap rule.** A graph value flows into a `bytes` parameter that expects an *encoded* value (`unpackArray`, `slice` over an envelope, `hash`/`byteLen` of a whole return, a RAW `InputParam.paramData`) only through `wrap`: `Wrap` is `abi.encode(bytes(value))`, so `unpackArray(elemType, Wrap(Resolve(env)))` decodes `encoded = env` and `AbiCodec.unpack` sees its 0x20 word (Table U: the unwrapped envelope reverts). Outside a graph the wrap is `wrapParam(ctx, env) = staticCallParam(ctx.operations, encodeFunctionData({abi: OPERATIONS_ABI, functionName: "rawCall", args: [ctx.core, encodeResolve(env)]}))`, which is 3× cheaper than the graph form for a lone bridge (37,506 vs 109,096).

**Reading a graph value with the core**: a `Call` to the core with `nav.selector`, `argumentTypes = "((uint8,uint8,bytes,(uint8,bytes)[]),string,int256[])"`, first argument `tuple("(uint8,uint8,bytes,(uint8,bytes)[])", [lit uint8 2, lit uint8 0, wrap(value), lit abi.encode(new Constraint[](0))])`. The `bytes paramData` component is `wrap(value)`, whose payload is `value`, so the core's `_resolve` of the RAW param yields `value`. `[…, LEN]` paths return a word (`valueType "uint256"`); ordinary paths return canonical envelopes (now for every dynamic terminal); `PAYLOAD` paths return raw bytes no `valueType` validates, so a graph never uses them. `graphWordsPayload`: `env = resolve("T[]", envelope)`; `count = call("uint256", literal(core), nav, …, [tuple(… wrap(env) …), lit "(T[])", lit [0, LEN]])`; `payload = call("bytes", ops, slice, "(bytes,uint256,uint256)", [wrap(env), lit 64, call(mul, [count, lit 32])])`.

**Structure sources**, in order: (1) a fragments registry `registerFragment(param, (g, lift) => NodeId)` / `fragmentOf(param)` backed by a `WeakMap<InputParam, GraphFragment>`, attached by `opReadParam`/`colReadParam`/`wordOpParam`, every recipe, the std control faces (Phase 3) and any graph param (nested graphs merge); (2) lifting by decoding (`lift.ts`, `liftParam(g, param, valueType)`): RAW word → `Literal`; STATIC_CALL to `ctx.core` decoding as `read`/`readArgs` whose RAW host word is `ctx.operations`/`ctx.collections` and whose selector is in `OPERATIONS_ABI`/`COLLECTIONS_ABI` → `Call` with `valueType = outputs[0]`; anything else → `Resolve`. A leaf's `valueType` comes from the consuming ABI input or the root `Operand.cat`, never guessed.

`valueType` from `Operand`: `Uint→"uint256"`, `Int→"int256"`, `Address→"address"`, `Bool→"bool"`, `Bytes32→"bytes32"`, `String→"string"`, `Bytes→"bytes"`; `scale` ignored. `Operand.abiType?: string` (Phase 4) overrides with a full descriptor.

### 1.4 Lazy control (Q4)

Inside an admitted graph the std faces lower to `Select`/`TryOrElse`/`IsValid`:

| Core primitive | Graph node | Same | Different |
|---|---|---|---|
| `cond(c,t,e)` | `Select` | first word of a ≥ 32-byte condition, nonzero = then; loser never evaluated; condition constraints validated | short condition reverts `InvalidNode(node)` not `ReturnDataOutOfBounds`; the winning branch is validated against the node's `valueType`; string/bytes literal branches become possible |
| `orElse(a,b)` | `TryOrElse` | any failure of the attempt selects the fallback, subframe OOG included; fallback failures propagate | a wrong `valueType` claim on the attempt counts as failure and silently takes the fallback, so claims come from ABI, never guessed; cache changes of the failed attempt are discarded |
| `isValid(a)` | `IsValid` | 1/0 word, same catch boundary | Expressions' own validation errors also count as invalid |
| `revertData(a, sel)` | not lowered | | the probe would run from Expressions (1.2); it stays a `Resolve` leaf, including under `IsValid` |
| any `read` to a code-less target | `Call` | | `InvalidTarget(node, target)` instead of `CallFailed(address,bytes)`; both count as failure under guards |
| nested failure | | | `CallFailed(uint256 node, address target, bytes callData, bytes reason)` wraps the core's error as `reason` |

Error reporting: `decode.ts` gains `EXPRESSIONS_ERRORS` (`InvalidNode`, `InvalidReference`, `InvalidTarget`, `CallFailed(uint256,address,bytes,bytes)`) and `unwrapExpressionsRevert(data): { node?: number; inner: Hex }` applied recursively before the core decoding in `packages/sdk/src/utils/error-capture.ts` and `modules/std/src/helpers/reverts.ts`; the core error ABI in `error-capture.ts` gains the `AbiCodec` errors `readArgs` can raise (`ComponentCountMismatch`, `InvalidComponentEnvelope`, `InvalidComponentLength`, `InvalidComponentValue`, `InvalidTypeDescriptor`). `GraphBuilder.labels` travel on the emitted action as `compiled.debug?: { labels: string[] }`.

### 1.5 Generic collections (Q5)

`wordArrayPath` (`arrays.ts:36-62`) rejects non-word elements today. Phase 4 routes them to the `*Values` family:

- **Bridge** `valuesArg(ctx, node, helper): { values: InputParam /* bytes[] */; elemType: string; abiType: string }`: `elemType = formatParamType(element)`; `env` is the call's return or, with a lens, `lensedDataOperand` (every array shape navigates now, 0.1); `values = read(collections, unpackArray, [RAW heads + "elemType" tail, wrapParam(ctx, env)])` (one live dynamic argument last, so `read` with literal offsets suffices; Table U). Results are `bytes[]`; `packArray(outputType, values)` re-frames them as a canonical `T[]` operand `{kind:"call", cat:"Bytes", abiType:"T[]"}`.
- **`values.ts`**: `mapValuesParam`, `filterValuesParam`, `foldValuesParam`, `sortValuesParam`, `uniqueValuesParam`, `indexOfValuesParam`, `anyValuesParam`, `allValuesParam`, `findValuesParam`, `zipValuesParam`, `unzipValuesParam`, `flattenValuesParam`, `reverseValuesParam`, `sliceValuesParam`, `packArrayParam`, `unwrapValuesParam`. `values` (`bytes[]`, size underivable) precedes the `Callback` struct in every signature, so each is a `readArgs` to Collections with `argumentTypes` such as `"(string,string,bytes[],(address,bytes4,string,bytes[],uint256,uint256,bytes))"` and RAW canonical envelopes for the constant arguments, or a `Call` node inside a graph.
- **Lambdas.** `lambda.ts` gains `compileGraphLambda(ctx, defNode, label, params: { abiType: string; cat: Category }[]): { expression: Hex; arguments: string; resultType: string; operand: Operand }`, supplying `parameterOperand(i, cat, abiType)` markers (`{kind:"call", param: rawParam(PARAMETER_MARKER[i]), cat, abiType}`), compiling the body through `compileOnchainHelper`, then lifting with a `liftParam` override that turns a marker leaf into `g.parameter(abiType_i, i)`; a marker inside an opaque `Resolve` leaf's `paramData` is rejected ("the body must be whole-value calls; `<face>` cannot bind a collection element"). `Callback = { target: ctx.expressions, selector: 0x00000000, arguments: "(T)" | "(A,T)", constants: [placeholder envelopes], first: 0, second: 1, expression }`. A `string` parameter feeding a `(bytes)` `Call` validates (0.2).
- **Binding fix** (review finding 3): `dispatch.ts` exports `isLiveArgNode(node) = node.type === CallExpression || isBangHelperNode(node) || PRECOMPILED_OPERAND in node`; `chainArgWithLens` gains a first branch for precompiled operands returning `{ param: o.param, outputs: [{ type: o.abiType ?? (o.cat === "String" ? "string" : "bytes") }] }` (the bang-helper branch propagates `abiType` too); `compileArgSpecs` treats a precompiled node as live (`word` for word categories, `dyn` with `bytesPayloadParam` for `String`/`Bytes`); the seven hand-classifying faces use `isLiveArgNode`, and their interpretation fallbacks start with `if (PRECOMPILED_OPERAND in node) throw new ErrorException("internal: a precompiled operand reached the interpreter")` so the literal `"element"` can never be produced again. `stringArg` (`modules/lang/src/utils/onchain.ts:30-49`) already goes through `compileOperand`.
- **Per-element cost**: two Expressions frames plus ≈ 10k fixed plus ≈ 3.5k per node plus ≈ 21k per `Call` (Table G) per element, against a few thousand for a word template. Every generic face's `compileDescription` says the generic path costs more per element; row F of `ExpressionsGas.t.sol` (`mapValues` over 8 strings, selector vs expression callback) records the number when Phase 4 adds it.
- **Field access**: a both-faced lang helper `@field(value index…)` (name to decide; `@get` exists in std). Compile face: parameter/graph value → the `nav`-over-`Wrap` `Call` of 1.3 with the element descriptor; plain operand → `nav`. Off-chain face returns `value[index]`.
- **Faces**: extend `@map!`, `@filter!`, `@reduce!` (accumulator type from the def's declared type), `@sort!` (comparator def returning a signed word), `@unique!`, `@find!`, `@any!`, `@all!`, `@includes!` (`indexOfValues` with an equality def), `@zip!`/`@unzip!`, `@flat!`, `@reverse!`, `@slice!`; each gains a `compileDescription` sentence for the generic path.

### 1.6 Plumbing (Q6)

- `CompileCtx.expressions: Address` (`types.ts:78-94`); `EXPRESSIONS_ADDRESS` in `addresses.ts`; `defaultCompileCtx` (`assertion.ts:109-121`) and test-utils `compileExpression` (`packages/test-utils/src/onchain/compile.ts:77-87`) set it; the unit-test contexts (`splice-layout.test.ts:35-39`, `fold-hosts.test.ts:50-54`, `lambda-template.test.ts:40-44`, `operand-scale.test.ts:19-23`) gain `expressions` where reached.
- New `packages/sdk/src/onchain/expressions.ts`: `EXPRESSIONS_ABI` (parseAbi of `evaluate`, `evaluateEncoded`, the `Node`/`Expression` structs, the four errors); `index.ts` re-exports `expressions`, `graph`, `lift`, `values`. `resolveValues` is a core function: `"function resolveValues(InputParam[] args) view returns (bytes[])"` joins `CORE_ABI`, with `encodeResolveValues(args)` and `resolveValuesParam(ctx, parts) = staticCallParam(ctx.core, …)` in `core.ts`; the old `resolver.ts` (`EXPRESSION_RESOLVER_ABI`, `resolveCallParam`, `resolveArgumentsParam`, `resolveValuesParam`) is deleted.
- The four canonical addresses in `addresses.ts` move together in Phase 0 (every contract imports `AbiCodec`); `installAssertionsCore` installs four and `InstalledCore` gains `expressions`.
- Builder preview and the parity harness need no change: a `readArgs` operand or a graph is one `STATIC_CALL` param, and `Assertions.resolve(param)` staticcalls it like any operand.

### 1.7 Tests (Q7)

| Layer | Test | Teeth check |
|---|---|---|
| SDK unit | `packages/sdk/test/unit/call-host.test.ts`: `chooseHost` table (word-only → read; 1 dyn → read; `{size}` first + live last → read; 2 runtime-sized → readArgs; underivable non-last → readArgs); decoded `readArgs` calldata (`argumentTypes` string, each arg resolves through the `splice-layout.test.ts` resolver to `encodeAbiParameters([input],[value])`); the `resolveCall` selector appears in no emitted operand | delete `chooseHost` → table fails; grep the catalogue for the `resolveCall` selector |
| SDK unit | `graph.test.ts`: backwards-only refs; identical subtrees intern to one node (`hits === 2`); `call()` throws for a non-host target; `call()` throws for an unwrapped non-bytes node in a `bytes` position; `graphWordsPayload` shape (scan for the `nav` selector and the InputParam tuple descriptor); `maybeGraph` returns the tree for `add(x,x)` and the graph for a shared composite under `GAS_MODEL` | delete interning → `hits` fails; delete the Wrap check → the `unpackArray` fixture reverts on Anvil |
| SDK unit | `expression-hosts.test.ts` (the `fold-hosts` pattern): every recipe in `recipes.ts` and `values.ts` with 1..6 live parts against a golden host table; `assertNoRuntimeOffsets(param)` walks for the `bitAnd(add(pick(x,1),31),…)` chain; every face compiled with an `operandNode` argument either compiles to a live operand or throws, never yields a constant containing `"element"` | re-enable the `grown` path → the walker finds it; remove `isLiveArgNode` from `str.concat` → the `"element"` case fails |
| Real EVM | `modules/std/test/integration/read-hops.test.ts`: `::` calls with 2, 3 and 6 live string args against `MockTarget.join3/join6` and `callerGated(core, …)`; `parity-strings.test.ts`: `@str.concat!` with 2–6 live parts, `@str.replace!` live needle and replacement, `@str.split!` live delimiter; `parity.test.ts`: `@ifElse!`/`@orElse!`/`@reverts!` inside a shared-composite expression; `parity-values.test.ts` (Phase 4): `installConstantMock` returning `string[]`, `(address,uint256)[]`, `string[][]`, `installSelectorMock` returning `(uint256, string[])` for the lensed case, and the parsed definitions `def @length! "$x: string -> number" @str.len!($x)`, `def @shout! "$x: string -> string" @str.upper!($x)`, `def @long! "$x: string -> bool" @bool!(@str.len!($x) > 3)` applied by `@map!`, `@filter!`, `@find!` | undeclared compile failure fails the case |
| Solidity (main repo, per phase) | `ExpressionsGas.t.sol` gains SDK-emitted fixtures (`bytes constant`, produced by `packages/sdk/scripts/emit-gas-fixtures.ts` against `vm.etch` addresses, the `SDK_TEMPLATE` precedent in `OperationsGas.t.sol:230`): a `readArgs` operand for `join3`, an admitted graph, an SDK-emitted `Callback`, executed and `vm.expectCall`-counted | |
| Gate | `check-integration.mjs` four-contract loop; `parity-coverage.test.ts` demands `## On-chain face` sections for every changed face | |

### 1.8 Phasing

Current order: D contracts → A/B SDK retarget → pin bump → C Builder → E docs. Insert:

- **Phase 0** inside D, before the first pin bump: the release mechanics (below). The pinned SDK must carry the four final addresses and the fixtures must carry `readArgs`.
- **Phase 1** right after A/B lands (needs `ctx.operations`/`ctx.collections`, `opReadParam`/`colReadParam`, `assertion.ts`, `decode.ts`), before the pin bump → one bump covers A/B + Phase 1. Phase 1b follows in the same bump if the `resolveValues` rows are green.
- **Phase 2 and 3** together, admission-gated by `GAS_MODEL`; small in scope by construction (shared composites only).
- **Phase 4** last; 4a string/bytes elements, 4b struct elements and `@field`.
- E docs: per phase, not deferred.

## 2. Phases

### Phase 0: release mechanics (main repo and checkout plumbing, no SDK logic)

Files: `website/scripts/export-deploy-artifact.mjs` (Expressions `released: true`, `sdkAddressExport: "EXPRESSIONS_ADDRESS"`; the four `expectedAddress` values move once, salts kept, retired candidates to HISTORY), `website/src/lib/*` and `deployments.json` (regenerated), `README.md` and `reference/deployments.mdx` (addresses), checkout `scripts/sync-assertions-bytecode.ts` (+ `{ name: "Expressions", path: "contracts/Expressions.sol/Expressions.json", prefix: "EXPRESSIONS", label: "Expressions periphery" }`), `packages/test-utils/src/onchain/{assertions-bytecode.ts,install.ts}` (four contracts, `InstalledCore.expressions`), `packages/sdk/src/onchain/addresses.ts` (four addresses), `packages/sdk/src/onchain/core.ts` (`readArgs` in `CORE_ABI`, `encodeReadArgs`).

Steps: `pnpm compile` → `pnpm --dir website sync:artifact` (the guard prints the predicted addresses; copy them into `CONTRACTS`, move the old ones to HISTORY, rerun) → flip `released` → in the checkout `bun scripts/sync-assertions-bytecode.ts` → installer, addresses, `encodeReadArgs` → `pnpm --dir website check:integration`.

Gates: `pnpm test` in the main repo (466 today), `pnpm check:integration` reporting four contracts in agreement (SDK addresses, fixtures, deployment modules).

Exit: the checkout's vendored `Assertions` bytecode has `readArgs` and the re-encoding `nav`; `EXPRESSIONS_ADDRESS` exists; no contract change is planned.

### Phase 1: `readArgs` for multi-dynamic arguments

Files: `construct.ts` (`CompiledCall`, `runtimeSized`, `chooseHost`, `buildCall`, `callParam`), `core.ts` (from Phase 0), `types.ts` (`CompileCtx.expressions`), `compile.ts` (`compileHopArgs`/`readParam` → `buildCall`/`callParam`; `compileLiveHelperArg` dyn results), `reads.ts` (`callReadOperand` → `buildCall`), `recipes.ts` (`indexOfParam`, `replaceParam`, `zipParam`, `enumerateParam`, `splitParam`), `layout.ts` (delete the `grown` loop and `MAX_LIVE_SLOTS`), `error-capture.ts` (AbiCodec errors), `assertion.ts` (`defaultCompileCtx.expressions`), `modules/lang/src/helpers/str.concat.ts` (`compileDescription` drops "up to 4 parts" in 1b), `str.replace.md`/`str.split.md`/`str.includes.md`/`str.concat.md` On-chain face notes.

Interfaces produced: `buildCall`, `callParam`, `chooseHost`, `runtimeSized`, `encodeReadArgs`.

Steps: write `call-host.test.ts` (fails: `chooseHost` undefined) → implement `construct.ts` → switch `compileHopArgs`/`callReadOperand` → run the existing shape tests (word-only and single-live calldata byte-identical) → switch the recipes → delete the `grown` loop → `expression-hosts.test.ts` walker clean → `bun test ./test/unit` → `read-hops.test.ts` and parity strings on Anvil → `bun run codegen` → `bun scripts/build.ts --types` → `bun run validate-docs` → pin bump → `pnpm check:integration`.

Phase 1b (same bump if green): `resolveValuesParam` in `core.ts`, `concatParam`/`flat`/`str.join` over the core's `resolveValues`; parity `@str.concat!` with 2–6 live parts; a row in `ExpressionsGas.t.sol` for `concat` with 2 and 4 live parts (splice vs `resolveValues`).

Exit: no `::` call or recipe emits an offset add chain; the `resolveCall` selector appears in no emitted operand; the `read` host is byte-identical for word-only and single-live calls; `callerGated(core, …)` passes through every emitted host on Anvil.

### Phase 2 and 3: graphs for shared composites, lazy control inside them

Files: `graph.ts`, `lift.ts` (new), `recipes.ts` (fragments on every builder), `arrays.ts` (`wordsPayload` fragment), `compile.ts` (`opReadParam`/`colReadParam`/`wordOpParam` register fragments; `maybeGraph` export), `assertion.ts` (`maybeGraph` in `compileAssertionSide`; `compiled.debug.labels`), test-utils `compile.ts` and `decode.ts`, `operators.ts` (selector → ABI lookup), `modules/std/src/helpers/{ifElse,orElse,reverts}.ts` (fragments; `reverts` registers `isValid` over a `Resolve` leaf), `decode.ts` (`EXPRESSIONS_ERRORS`, `unwrapExpressionsRevert`), `ifElse.md`/`orElse.md`/`reverts.md` On-chain face sections, `reference/errors.md`.

Tests: `graph.test.ts`; parity: `@absDiff!` over two composite reads named twice, `@len!` + `@sum!` over the same fold, each control face inside an admitted graph; a `TryOrElse` attempt whose ABI claim is wrong by construction is refused at compile time; `@reverts!` inside an admitted graph still probes from the core (`callerGated` asserted through `@reverts!`); a Solidity fixture of an SDK-emitted graph executed with `vm.expectCall(source, 1)`; gas rows C/E with SDK-emitted fixtures.

Exit: `maybeGraph` admits exactly the shapes `GAS_MODEL` proves cheaper; every std control face has a fragment; `assert` messages name the failing node's label; the "zero SDK adoption" note in `AGENTS.md` is replaced by the admission rule.

### Phase 4: generic collections

Files: `values.ts` (new), `arrays.ts` (`valuesArg`, `wrapParam`, `wordArrayPath` routing), `lambda.ts` (`compileGraphLambda`, `parameterOperand`, marker rejection inside opaque leaves), `dispatch.ts` (`isLiveArgNode`), `compile.ts` (`chainArgWithLens` precompiled branch with `abiType`; `compileArgSpecs` precompiled branch; `categoryFromAbiType` accepts descriptors via `abiType`), `types.ts` (`Operand.abiType`), the seven hand-classifying faces, the lang faces of 1.5, new `modules/lang/src/helpers/field.{ts,md}`, test-utils `decode.ts` (canonical `T[]` decoding), docs `operators/collections.md` (SDK section), gas row F.

Tests: `parity-values.test.ts` (1.7) over `string[]`, `(address,uint256)[]`, `string[][]` and the lensed `string[]`; the three parsed definitions applied by `@map!`/`@filter!`/`@find!`; string accumulator fold; comparator sort by `@field!`; unit `graph-lambda.test.ts` (Callback encoding: `target = expressions`, `first/second`, `arguments`, a body naming `$x` twice yields one `Parameter` with two refs); the `expression-hosts.test.ts` `operandNode` sweep; one SDK-emitted callback fixture executed in `Expressions.t.sol`.

Exit: every word-only face has a generic sibling path with parity coverage and an On-chain face paragraph (caller note included); word arrays still take the template path byte for byte.

## 3. Non-goals

- No change to the ERC-8211 wire format; no new constraint types.
- No further contract change: every phase targets the bytecode Phase 0 releases.
- Word-template folds stay the word-only path; no migration of all-word calls to `readArgs` or Expressions.
- The SDK never emits `ProbeCall`; Expressions has no resolve-once entry points to emit.
- No cross-iteration memoization in collection callbacks.
- No Builder authoring UI for graphs; the Builder consumes `assert` output and previews through `resolve`.
- No change to off-chain faces beyond the new both-faced `@field`.

## 4. Risks

- Address churn: Phase 0 moves all four addresses once; a contract change after it forces a second fixture/SDK/pin cycle. Everything this plan needs from the contracts is already in the working tree.
- `GAS_MODEL` drift: the constants are pinned by `ExpressionsGas.t.sol`; they must never be edited without the Solidity rows moving with them.
- Silent fallback under `TryOrElse` when a `valueType` claim is wrong: claims are ABI-derived; lifting prefers opaque leaves over guesses.
- Lifting depends on `OPERATIONS_ABI`/`COLLECTIONS_ABI` listing every emitted function; a missing selector degrades to an opaque leaf (safe, loses CSE). Unit test: every `OP_SELECTORS`/`COL_SELECTORS` entry resolves in the ABI tables.
- Calldata growth: each node carries six ABI fields (416 bytes per Literal node, Table G); `evaluateGuarded` re-passes the whole expression per guard. `GAS_MODEL` prices nodes and `maybeGraph` stays opportunistic.
- Error-message regressions: `readArgs` surfaces `AbiCodec` errors from the core and graphs wrap the core's errors; both must be decoded everywhere the core's errors are decoded today (`error-capture.ts`, `reverts.ts`, website `assertion-eval.ts`).
- Chains without Expressions deployed: judge-time `CallFailed` at the Expressions address; the deployments page lists it after Phase 0.
- Concurrency with the retarget session: `construct.ts`, `compile.ts`, `recipes.ts`, `layout.ts`, `types.ts` are all in its working set; Phase 1 starts from its committed state, never from a stash. Another session is deleting the `docs/*.md` handoff records; this plan quotes numbers rather than linking them.
- Parity harness runtime: generic-collection cases install several mocks per case; keep them on `installConstantMock`/`installSelectorMock` and under the 30 s default.

### Critical files for implementation

- `/home/sem/Projects/Assertions/website/.evmcrispr/packages/sdk/src/onchain/construct.ts`
- `/home/sem/Projects/Assertions/website/.evmcrispr/packages/sdk/src/onchain/core.ts` (`readArgs` in `CORE_ABI`, `encodeReadArgs`)
- `/home/sem/Projects/Assertions/website/.evmcrispr/packages/sdk/src/onchain/compile.ts` (`chainArgWithLens`, `compileArgSpecs`, `compileHopArgs`)
- `/home/sem/Projects/Assertions/website/.evmcrispr/packages/sdk/src/onchain/graph.ts` (new; with `lift.ts`, `expressions.ts`, `values.ts` beside it)
- `/home/sem/Projects/Assertions/website/.evmcrispr/packages/sdk/src/onchain/recipes.ts`
- `/home/sem/Projects/Assertions/website/.evmcrispr/packages/sdk/src/onchain/lambda.ts`
- `/home/sem/Projects/Assertions/contracts/tests/ExpressionsGas.t.sol` (pins every constant above)
