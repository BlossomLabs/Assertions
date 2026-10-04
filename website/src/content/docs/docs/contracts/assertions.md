---
title: Assertions
description: "The core contract: the ERC-8211 judge (assertParam, assertBatch) and the eleven primitives that read, construct and branch on operands that arrive unresolved."
---

`Assertions` is the contract every assertion calls. It is the main contract, also called the core: the other three contracts are its [expansion packs](/docs/contracts), which add extra functions and are reached by address. It does two things. It **judges**: `assertParam` and `assertBatch` fetch live values, check them against inline constraints in the [ERC-8211 (Smart Batching)](https://eips.ethereum.org/EIPS/eip-8211) wire format, and revert with `ConstraintFailed` when one fails. And it **evaluates operands**: eleven view functions that select a value out of a read, build a call from other reads, or decide which read happens at all. Each of them takes ERC-8211 `InputParam`s and returns its result as if the final target had returned it, so they nest to any depth.

You meet it in every decoded batch: it is the target of each assertion call, and its own address appears as the `target` of a `STATIC_CALL` whenever a value is built from other reads (see [Assertions built from other reads](/docs/reviewing#assertions-built-from-other-reads)). Operations, Collections and Expressions are reached through it. The address is on [Deployments](/docs/contracts/deployments); it is the same on every chain.

## Functions by task

| Task | Function | Meaning | EVML spelling |
|------|----------|---------|---------------|
| Judge | `assertParam(param[, message])` | Fetch one value, check its constraints | `assert <value> <op> <expected>` |
| Judge | `assertBatch(executions[, message])` | Judge an ERC-8211 batch under view rules | none, call it from Solidity or an SDK |
| Read | `resolve(param)` | Fetch an operand, check its constraints, return the bytes unchanged | none, the compiler emits it |
| Read | `gather(args)` | Resolve N operands once each into a `bytes[]` | none, the compiler emits it |
| Select | `pick(param, wordIndex)` | One raw 32-byte word of a result | `[_ $ _]` lens |
| Select | `nav(param, retTypes, path)` | Typed walk into tuples, arrays and structs, plus `LEN` and `PAYLOAD` | nested lens `[[_ [_ _ $]]]`, `@len!`, `@abi.decode!` |
| Construct | `chain(start, calls)` | Call a chain of contracts whose addresses come from the previous hop | `::!{…}::!{…}` chains |
| Construct | `read(target, selector, args)` | Call a view function with calldata assembled from other reads | a call as an argument of a call |
| Construct | `get(target, selector, argumentTypes, args)` | The same, from whole ABI values, each resolved once | emitted automatically for several live dynamic arguments |
| Control | `cond(c, then_, else_)` | Resolve only the branch the condition selects | `@ifElse!(c ? a : b)` |
| Control | `orElse(a, b)` | Use `b` if resolving `a` fails | `@orElse!(a b)` |
| Control | `isValid(a)` | 1 if `a` resolves and passes its constraints, else 0 | `@reverts!(call)` (negated) |
| Control | `revertData(a, selector)` | The revert data of a call that must fail | `@reverts!(call -!> Err(types))` |

All of them are `view`. The contract holds no funds, owns no permissions and writes no storage.

## The judge

```solidity
function assertParam(InputParam calldata param) external view;
function assertParam(InputParam calldata param, string calldata message) external view;
function assertBatch(ComposableExecution[] calldata executions) external view;
function assertBatch(ComposableExecution[] calldata executions, string calldata message) external view;
```

`assertParam` is the common case: resolve one `InputParam` and validate its constraints, with no batch scaffolding. The `paramType` field is ignored, since nothing is routed. In EVML:

```evml
assert $token::!{balanceOf(address)(uint256) $treasury} >= 100e18 "treasury below floor"
```

The decoded form of this assertion is on [Reviewing an assertion](/docs/reviewing). The `message` is echoed inside `ConstraintFailed`. Without one, `assertParam` reports `"PARAM"` and `assertBatch` reports `"COMPOSABLE"`. Operands of the primitives below report an empty message and name the operand by index.

### The three fetchers

| Fetcher | `paramData` | Resolves to |
|---------|-------------|-------------|
| `RAW_BYTES` | the value itself | the literal bytes, unchanged |
| `STATIC_CALL` | `abi.encode(target, callData)` | the raw returndata of the staticcall |
| `BALANCE` | `abi.encodePacked(token, account)`, exactly 40 bytes | native balance when `token == address(0)`, else `IERC20(token).balanceOf(account)`, as one `uint256` word |

A `STATIC_CALL` to an address with no code reverts with `CallFailed(target, data)`; a plain staticcall would succeed with empty returndata and surface as a silent wrong value. A `BALANCE` paramData of any other length reverts with `InvalidBalanceData`. For an ERC-20 balance, a `balanceOf` that returns fewer than 32 bytes reverts with `ReturnDataOutOfBounds`.

In EVML, `@balance!(ETH $recipient)` and `@balance!(token account)` compile to the `BALANCE` fetcher:

```evml
assert @balance!(ETH $recipient) >= 1e18 "recipient underfunded"
```

### Judging a batch

`assertBatch` evaluates an ERC-8211 batch under view rules. It accepts unmodified batches built by any ERC-8211 SDK. For each entry:

- An entry without a `TARGET` parameter is a predicate entry: every input parameter is resolved and constraint-checked, and nothing is called.
- An entry with a `TARGET` parameter constructs a call: the 4-byte `functionSig` followed by the full resolved bytes of each `CALL_DATA` parameter, in order. The call is executed with `staticcall` and must not revert. Its return data is ignored, so a returned `false` does not fail the batch. A `TARGET` that resolves to `address(0)` skips the call.
- An empty batch succeeds.

A view context cannot express some parts of the standard, and the judge rejects them:

| Error | Raised when |
|-------|-------------|
| `OutputParamsNotSupported(entryIndex)` | an entry carries output parameters (Storage writes) |
| `ValueParamNotSupported(entryIndex, paramIndex)` | an input parameter is `VALUE` (no ETH forwarding through a staticcall) |
| `DuplicateTargetParam(entryIndex)` | an entry has a second `TARGET` parameter |
| `BalanceCannotBeTarget(entryIndex, paramIndex)` | the `TARGET` parameter uses the `BALANCE` fetcher |
| `InvalidAddressWord(paramIndex, word)` | the `TARGET` word has dirty upper bytes |

Being a view function, the judge is also an operand: see [A batch as an operand](#a-batch-as-an-operand).

An empty constraint list adds no value predicate, even for an empty `RAW_BYTES` value: the assertion only checks that the read succeeds. To assert that a boolean call returned true, fetch it and constrain its first word to `EQ 1`; `isValid` of an unconstrained call that returns `false` is still 1.

Rollback of the guarded actions needs a mandatory assertion in the same transaction, and an executor that propagates its failure. Catching the error, ignoring a low-level call failure, or letting the assertion action fail can keep earlier changes. Put preconditions before the guarded actions and postconditions after them.

## Wire format and constraints

```solidity
struct InputParam {
    InputParamType paramType;          // TARGET 0, VALUE 1, CALL_DATA 2: where the value routes
    InputParamFetcherType fetcherType; // RAW_BYTES 0, STATIC_CALL 1, BALANCE 2
    bytes paramData;                   // fetcher-specific payload
    Constraint[] constraints;          // inline predicates on the resolved value
}

struct Constraint {
    ConstraintType constraintType;     // IDs 0..8
    bytes referenceData;               // payload depends on the kind
}

struct ComposableExecution {
    bytes4 functionSig;                // selector of the constructed call
    InputParam[] inputParams;
    OutputParam[] outputParams;        // must be empty here
}
```

**Constraint `i` judges resolved word `i`.** A one-word value has one constraint. All constrained words must exist before any predicate runs (a shorter value reverts with `ReturnDataOutOfBounds`), and even `SKIP` needs a complete word. A violation reverts with `ConstraintFailed(assertion, entryIndex, paramIndex, constraintIndex, constraintType, actual, referenceData)`, which echoes the actual word.

| ID | Constraint | Reference data | Word `i` must be |
|----|------------|----------------|------------------|
| 0 | `EQ` | exactly 32 bytes | equal to the reference (raw words) |
| 1 | `GTE` | exactly 32 bytes | at least the reference, unsigned |
| 2 | `LTE` | exactly 32 bytes | at most the reference, unsigned |
| 3 | `IN` | exactly 64 bytes: `abi.encode(lo, hi)` | in the inclusive range, unsigned |
| 4 | `GTE_SIGNED` | exactly 32 bytes | at least the reference, as `int256` |
| 5 | `LTE_SIGNED` | exactly 32 bytes | at most the reference, as `int256` |
| 6 | `OR` | `abi.encode(Constraint[])` | matching at least one leaf, all leaves judging the same word |
| 7 | `SKIP` | empty bytes | anything: the word is not judged |
| 8 | `IN_SIGNED` | exactly 64 bytes: `abi.encode(int256(lo), int256(hi))` | in the inclusive range, as `int256` |

The IDs and positional semantics are Biconomy's ERC-8211 reference encoding, and the canonical predicate encodings match that reference. Do not reorder or extend the IDs.

Rules and edge cases:

- **Signedness is the author's choice.** The unsigned constraints read a negative `int256` as a huge positive number. Use `GTE_SIGNED`, `LTE_SIGNED` and `IN_SIGNED` for signed values, or the `int256` overloads of [Operations](/docs/contracts/operations) read-spliced and judged `EQ 1`. Signed tolerance uses the signed `absDiff` overload.
- **A scalar range is one `IN`.** `[GTE(lo), LTE(hi)]` checks two different words, so on a one-word balance it reverts. For several other conditions on one scalar, compose an Operations or Expressions boolean and judge it `EQ 1`, or emit separate entries. EVML does this for you: `~=` with `--delta` compiles an unsigned approximate equality to one `IN`.
- **Positions are raw ABI words.** A dynamic return starts with an offset, not its contents. Select the value with `pick` or `nav` before constraining it. For example, resolved words `(42, 999)` pass `[EQ(42), EQ(999)]` and fail `[EQ(42), EQ(42)]`.
- **`OR` leaves judge the same word.** Before any leaf runs, all leaves are scanned: an empty `OR`, or a leaf that is itself an `OR`, reverts with `InvalidOrConstraint(entryIndex, paramIndex, constraintIndex)`. Leaves are then tried in order and the first match wins. An `OR` of `OR`s is refused because it flattens to one `OR`, and accepting it would break parity with the reference.
- **Reference data lengths are exact.** A wrong length reverts with `InvalidConstraintData(entryIndex, paramIndex, constraintIndex, length)`, including a non-empty `SKIP`. A range with a lower bound above the upper bound reverts with `InvalidConstraintRange`. `IN` and `IN_SIGNED` require exactly 64 bytes, where the Biconomy decoder permits trailing bytes: this is a deliberate stricter rejection.
- **Output captures are out of scope.** The judge is view-only and does not execute writes or output captures.

## Reading values

These primitives resolve an operand and hand back a selection of it. Every one returns through a raw assembly return, so a consumer (a judge fetcher, another primitive's operand) decodes the result as if it had called the final target. A `STATIC_CALL` operand may target the core itself, which is how the primitives nest.

### resolve and gather

```solidity
function resolve(InputParam calldata param) external view;                         // raw return
function gather(InputParam[] calldata args) external view returns (bytes[] memory values);
```

`resolve` is the base primitive: the ERC-8211 static call exposed as a read. It resolves the operand, validates its constraints and returns the bytes unchanged. Because a violated constraint reverts with `ConstraintFailed`, any expression node doubles as an inline assert. The fetch runs in the core's staticcall context, so a target that depends on `msg.sender` or `gasleft()` can answer differently than in a direct call. EVML has no spelling for `resolve`; the compiler emits it where it needs it.

`gather` is `resolve` over a list. Each operand resolves exactly once and the raw results come back in order as one `bytes[]`, taken as-is and validated against no type. It builds a `bytes[]` from N live operands without computing array offsets on-chain: the values list of [`Operations.concat` or `encode`](/docs/contracts/operations), or a generic [collection](/docs/contracts/collections)'s values array. An ordinary ABI return of `bytes[]` is that type's canonical single-value encoding, so the result feeds a `bytes[]` position of `get` as one whole argument, and the descriptor there does the type check. A constraint violation names the operand by its index. EVML has no spelling for `gather` either; the compiler uses it when a helper takes several live parts.

### pick

```solidity
function pick(InputParam calldata param, int256 wordIndex) external view returns (bytes32);
```

`pick` returns one raw 32-byte word of the resolved bytes. `wordIndex` is signed: 0-based from the start, negative from the end (`-1` is the last word), resolved against the live data. Outside the full words it reverts with `ReturnDataOutOfBounds`. In EVML it is a lens on a multi-value return:

```evml
assert $vault::!{getPosition(uint256)(uint256,uint256,address) $id}[_ $ _] == $expectedDebt "unexpected debt"
```

Word positions follow the raw ABI encoding, so dynamic types contribute head offsets, not content. `pick` is raw-word extraction for static-layout returns, not an ABI decoder. To select into tuples and arrays, use `nav`. From Solidity, assert word 1 of `getPosition`:

```solidity
assertions.assertParam(
    callParam(
        address(assertions),
        abi.encodeCall(Assertions.pick, (
            callParam(vault, abi.encodeCall(IVault.getPosition, (positionId)), noConstraints()),
            int256(1)
        )),
        eq(bytes32(expectedDebt))
    ),
    "Unexpected debt"
);
```

(`callParam`, `eq` and `noConstraints` are in [Solidity helpers](#solidity-helpers).)

### nav

```solidity
function nav(InputParam calldata a, string calldata retTypes, int256[] calldata path) external view;
```

`nav` is the typed selector. It interprets the resolved bytes as the declared type `retTypes` (a parenthesized tuple such as `"(address,address[][])"`, structs as parenthesized tuples) and walks `path` through it, following runtime offsets and lengths that raw word positions cannot express. In EVML a nested lens is one step per nesting level:

```evml
assert $gov::!{proposals()((address,uint256,bool)[])}[[_ [_ _ $]]] == false "proposal executed"
```

That reads `proposals()[1].executed`; the equivalent Solidity call uses `retTypes = "((address,uint256,bool)[])"` and path `[0, 1, 2]`. The first path step selects a return component. Each further step indexes the current tuple or array, and array steps accept negative indices resolved against the live length (`-1` is the last). The contract derives every offset-follow and bounds check from the descriptor's shape (dynamic or static, head footprints). `[... $]` in EVML anchors from the end.

**What a path returns.** Every terminal comes back as its canonical single-value encoding:

- A static word, fixed array or static tuple returns its complete bounded encoding, with no offset or length prefix. `nav(param, "(uint256,int256[2])", [1])` returns exactly the two signed words.
- A `string`, `bytes` or array of statically encoded elements returns `[0x20][length][payload]`.
- A dynamic tuple or an array of dynamic elements returns `abi.encode(value)`, re-encoded from a canonical-form walk of its extent. Malformed nested data reverts with `AbiCodec`'s `InvalidValue` at the offending offset.
- An empty path is a byte-for-byte passthrough: `nav` degenerates to `resolve`.

**What is checked.** Every word `nav` returns is range-checked for its declared type as solc's decoder would: a `uint8` word above 255 or an `int8` word that is not sign-extended reverts with `InvalidValue` at the offset in the resolved data. A whole `string` or `bytes` terminal is returned canonical too, so nonzero padding reverts with `InvalidValue` at the first dirty byte. Validation covers the selected value only. Unvisited siblings and the enclosing frame's tight offset layout are not checked, so a successful navigation does not validate the entire returndata. The descriptor is read the same way: each step validates the components it passes and the one it enters, so a malformed component on the path reverts with `InvalidTypeDescriptor`, while text after the selected component is never read and cannot change the result. An empty path skips descriptor validation; the operand's own fetch and constraints still have to succeed.

**The descriptor is your claim.** Like an inline ABI, the declared type is the author's statement about the encoder. A wrong claim reverts loudly in almost all cases, but a shape-compatible wrong type reads the wrong value (a `uint256` declared for an address, for example). This is documented, not defended against.

#### LEN: the length of a dynamic value

A path ending in the `LEN` sentinel (`type(int256).min`, the public constant `LEN`) returns the decoded length of the dynamic value the preceding steps reach, as a `uint256` word: the element count for arrays, the byte length for `string` and `bytes`. Because the sentinel composes with navigation, the length of an array inside a struct is one call.

```evml
load lang

assert @len!($registry::!{holders()(address[])}) >= 3
```

`LEN` checks that the selected payload (including ABI padding) or the array's element heads fit in the returndata before returning the length. For arrays of dynamic elements it checks the offset-word region but does not validate each element's tail, so a length check is not full ABI validation of every element. Static values, fixed arrays and tuples do not support `LEN` (`InvalidNavigation`); for a dynamic tuple or a fixed array of dynamic elements, truncated data can raise `ReturnDataOutOfBounds` before `InvalidNavigation`. A path made only of `LEN` has nothing to measure and reverts with `InvalidNavigation`.

#### PAYLOAD: typed re-entry into a bytes value

`bytes` is a sealed leaf in the descriptor grammar: an encoded blob's content is opaque to the descriptor that reaches it, so the grammar stays plain ABI syntax. A path ending in the `PAYLOAD` sentinel (`type(int256).min + 1`, the public constant `PAYLOAD`) opens the seal. It navigates to a `string` or `bytes` value and returns its raw payload: exactly its byte length, no envelope, no padding. Re-entry is then ordinary composition, with the payload's encoding claimed by the next `nav`'s own descriptor. In EVML, `@abi.decode!` does this:

```evml
assert @abi.decode!("address,uint256" $oracle::!{lastReport()(uint256,bytes)}[_ $] [_ $]) == 42
```

In Solidity, for `f()` returning `(uint256 ok, bytes data)` where `data` encodes `(address, uint256)`:

```solidity
/** The inner nav strips the blob in the same frame that reaches it;
    the outer nav claims the payload's type. */
nav( nav(x, "(uint256,bytes)", [1, PAYLOAD]), "(address,uint256)", [0] )
```

Over `rawCall` (which wraps any call's raw returndata as a `bytes` value, see [Operations](/docs/contracts/operations)) the sentinel is a general unwrapper, and on a `string` it returns the true unpadded bytes. Arrays and dynamic tuples refuse it with `InvalidNavigation`: only `string` and `bytes` carry a byte-counted payload, and a plain path returns an array or tuple as its canonical value. A length word that overruns the data reverts with `ReturnDataOutOfBounds`. Like `LEN`, a sentinel only works as the last path entry; anywhere else it falls into the ordinary bounds checks and reverts.

## Constructing calls

A `STATIC_CALL` fetcher fixes its target and its calldata when the batch is encoded. These three primitives remove that limit: the target, the calldata, or both come from other reads at judge time.

### chain

```solidity
function chain(InputParam calldata start, bytes[] calldata calls) external view;   // raw return
```

`chain` follows addresses that are only known at run time. `start` resolves to the first hop's target; each hop is a plain `abi.encodeCall` entry; every hop except the last must return an address as its first word, which becomes the next hop's target. The last hop's returndata passes through raw. In EVML a `::!` chain compiles to it. "The pool's token has the symbol WETH":

```evml
assert $pool::!{token()(address)}::!{symbol()(string)} == "WETH"
```

In practice `start` is a `STATIC_CALL` fetcher whose result is the first address. From Solidity:

```solidity
bytes[] memory hops = new bytes[](1);
hops[0] = abi.encodeCall(IERC20.symbol, ());

/** Judged value: chain(pool.token() -> symbol()). Compare its hash with
    EQ keccak256("WETH") through Operations.hash, or navigate it with
    nav("(string)"). */
abi.encodeCall(Assertions.chain, (
    callParam(pool, abi.encodeCall(IPool.token, ()), noConstraints()),
    hops
));
```

Errors: an empty `calls` array reverts with `EmptyCallChain`. A dirty address word reverts with `InvalidAddressWord`, index 0 for `start` and hop index + 1 for a mid-chain hop. A mid-chain hop returning fewer than 32 bytes reverts with `ReturnDataOutOfBounds`. A reverting hop or a hop at a code-less address reverts with `CallFailed` naming that call.

### read

```solidity
function read(InputParam calldata target, bytes4 selector, InputParam[] calldata args) external view;   // raw return
```

`read` constructs a call at judge time. The 4-byte `selector` is followed by the full resolved bytes of each `args` entry, concatenated in order, which is exactly ERC-8211's `CALL_DATA` routing. The call is a `staticcall` against the address `target` resolves to, and its returndata passes through raw. In EVML, a call used as an argument of another call:

```evml
assert $vault::!{sharesOf(address)(uint256) $registry::!{owner()(address)}} > 0
```

From Solidity, `balanceOf(computedHolder)` on whatever token the vault currently reports, where both target and argument resolve at judge time:

```solidity
InputParam[] memory args = new InputParam[](1);
args[0] = callParam(registry, abi.encodeCall(IRegistry.treasury, ()), noConstraints());

abi.encodeCall(Assertions.read, (
    callParam(vault, abi.encodeCall(IVault.asset, ()), noConstraints()),
    IERC20.balanceOf.selector,
    args
));
```

The `args` are calldata segments, not necessarily one per Solidity argument. A `RAW_BYTES` segment carries any literal span (head words, pre-encoded tails), and a `STATIC_CALL` segment computes a span at judge time (a word-returning operand contributes exactly 32 bytes). The encoder owns the layout: a segment that resolves to any other length shifts everything after it, so live word segments must fill single-word parameters and runtime-sized envelopes need their head offsets accounted for. The destination sees the core as `msg.sender`.

`read` is the composition socket for the other three contracts. Any deployed view or pure contract is reachable this way with fully composable operands, so [Operations](/docs/contracts/operations) is the canonical first extension, and a custom pure function deployed once is callable from every assertion with computed arguments.

Errors: a target word with dirty upper bytes reverts with `InvalidAddressWord` (index 0), a code-less target or a reverting constructed call with `CallFailed`, and a violated segment constraint with `ConstraintFailed` naming the operand (target is operand 0, args are at index + 1).

### get

```solidity
function get(InputParam calldata target, bytes4 selector, string calldata argumentTypes, InputParam[] calldata args) external view;   // raw return
```

`get` is `read` for calls with several dynamic arguments. `read` splices bytes as segments, so a call with two runtime-sized values (two live strings, an array and a string) would have to compute the second value's head offset from the first value's length on-chain, re-resolving the first value once per later offset. `get` takes each argument as a **whole canonical ABI value**: a word for a static scalar, the full bare footprint for a static tuple or fixed array, `[0x20][len][payload]` for a `string` or `bytes`, `abi.encode(T[])` for a dynamic array. It resolves every operand exactly once and lays the tuple out in its own frame through the shared `AbiCodec` grammar, with `argumentTypes` such as `"(address,string,uint256[])"`. The empty descriptor `"()"` with no arguments encodes to the bare selector. As with `read`, the destination sees the core as `msg.sender`.

EVML has no separate spelling. The compiler chooses `get` when a runtime-sized live value is followed by another live dynamic argument, and `read` otherwise:

```evml
assert $x::!{same(string,string)(bool) $a::!{name()(string)} $b::!{symbol()(string)}}
```

Measured through `Assertions.resolve` on 2026-09-07: two live string arguments cost 32,440 gas through `get` against 51,474 through the offset splice, and at three arguments 43,887 against 126,757. One live argument stays on `read` (19,000 against 20,217), and so do word-only calls (14,718 against 21,219). These are snapshots of one compiler on one day, so treat the ordering as the durable claim and re-measure before quoting a figure.

Errors: those of `read` for the target, `ConstraintFailed` and `CallFailed`, plus the codec's own: `ComponentCountMismatch` when the argument count disagrees with the descriptor, `InvalidComponentEnvelope`, `InvalidComponentLength` or `InvalidComponentValue` naming the argument whose resolved value does not fit its declared type, and `InvalidTypeDescriptor` for a malformed descriptor.

## Resolution control

Constraints revert or pass, and the read primitives select and construct. The control primitives decide whether operands resolve at all. A branch that must not execute can only be held by code that speaks the `InputParam` format, because an unresolved operand is data, not a call. Ordinary Solidity arguments are evaluated before the call; `InputParam` operands are not.

```solidity
function cond      (InputParam calldata c, InputParam calldata then_, InputParam calldata else_) external view; // raw return
function orElse    (InputParam calldata a, InputParam calldata b) external view;                                // raw return
function isValid   (InputParam calldata a) external view returns (uint256);
function revertData(InputParam calldata a, bytes4 expectedSelector) external view;                              // raw return
```

### cond: branch on a value

`cond(c, then_, else_)` resolves the condition, then resolves and returns **only** the winning branch. The losing branch is never resolved, so its calls never happen: it may target a contract that reverts, or one that does not exist yet.

```evml
assert @ifElse!($vault::!{locked()(bool)} ? $vault::!{staked()(uint256)} : $vault::!{balance()(uint256)}) >= $min
```

Truth is the first 32-byte word of the resolved condition, nonzero meaning true. Operations comparisons return 0/1 words, so they compose directly as conditions. A condition that resolves to fewer than 32 bytes reverts with `ReturnDataOutOfBounds`. The condition resolves normally, fetcher plus full constraint validation, and a violated condition constraint reverts the whole `cond`: branching on a failure is `orElse`'s job, branching on a value is `cond`'s. The winning branch is resolved with its constraints and returned byte-identically. In resolution errors the condition is operand 0, the then-branch operand 1 and the else-branch operand 2.

From Solidity, "the vault's spendable amount is at least `min`": `staked()` while locked, `balance()` otherwise.

```solidity
bytes memory spendable = abi.encodeCall(Assertions.cond, (
    callParam(vault, abi.encodeCall(IVault.locked, ()), noConstraints()),
    callParam(vault, abi.encodeCall(IVault.staked, ()), noConstraints()),
    callParam(vault, abi.encodeCall(IVault.balance, ()), noConstraints())
));
assertions.assertParam(callParam(address(assertions), spendable, gte(minSpendable)));
```

### orElse: branch on a failure

`orElse(a, b)` resolves `a`. If that fails for any ordinary reason, it resolves and returns `b` instead. It is a composable try/catch.

```evml
assert @orElse!($token::!{decimals()(uint8)} 18) <= 18
```

Every ordinary failure of the attempt selects the fallback: a reverting or code-less call target, malformed data, a violated constraint. That last one is the **constraint-as-guard pattern**. An operand's inline constraints normally turn expression nodes into asserts, and in an `orElse` attempt they act as admission tests. "Use the oracle price only when it is positive, otherwise the TWAP" is one guarded operand:

```solidity
InputParam memory guarded = callParam(oracle, abi.encodeCall(IOracle.price, ()), gte(1));
bytes memory price = abi.encodeCall(Assertions.orElse, (
    guarded,
    callParam(twap, abi.encodeCall(ITwap.price, ()), noConstraints())
));
```

On success the attempt's bytes pass through byte-identically. The fallback resolves in-frame, so its failures propagate (in resolution errors `b` is operand 1). For more than one fallback, nest: `orElse(a, orElse(b, c))` tries three sources in order. In EVML, `@orElse!` requires both branches to resolve to the same kind of value, and a constant fallback must fit in one word. A fallback that hides a failure weakens whatever you assert on the result: use `orElse` for contracts that lack a method, and `revertData` when the failure is what you want to observe.

From Solidity, `name()` on a token that may not implement it, with a literal fallback (`rawParam` is in [Solidity helpers](#solidity-helpers)):

```solidity
bytes memory name = abi.encodeCall(Assertions.orElse, (
    callParam(token, abi.encodeCall(IERC20.name, ()), noConstraints()),
    rawParam(abi.encode("unknown"))
));
```

### isValid: probe a resolution

`isValid(a)` collapses the same question to a word: 1 when `a` resolves **and passes its constraints**, 0 otherwise. Point a constrained fetcher at it to assert that a call succeeds (`EQ 1`) or fails (`EQ 0`). The result is a 0/1 word, so it also feeds `cond`, branching on resolvability instead of on a value. A successful call that returns `false` is valid unless a constraint requires its word to be true.

EVML's `@reverts!(call)` is the negation of `isValid`: true when the chain refuses the call.

```evml
assert @reverts!($legacy::!{latestAnswer()(uint256)}) == true "legacy oracle still answers"
```

From Solidity, "the legacy oracle no longer answers": the probe must come back 0.

```solidity
bytes memory probe = abi.encodeCall(Assertions.isValid, (
    callParam(legacyOracle, abi.encodeCall(IOracle.latestAnswer, ()), noConstraints())
));
assertions.assertParam(callParam(address(assertions), probe, eq(bytes32(0))));
```

### revertData: the reason a call fails

`isValid` answers whether; `revertData(a, expectedSelector)` answers why. The operand must be an unconstrained `STATIC_CALL` (the call itself is the subject). `revertData` performs the staticcall **in its own frame**, so the target's revert data survives; the routes through `resolve` that the other probes take convert a revert into the core's own `CallFailed` and lose the reason.

- A call that succeeds reverts with `DidNotRevert(target, callData)`: an assertion that a call fails is not satisfied by it working.
- With a non-zero `expectedSelector`, the first four bytes of the revert data must match, else `UnexpectedRevertData(expected, actual)` (`actual` is zero when the revert carried fewer than four bytes). The selector is **stripped** from the result: what returns is the error's ABI-encoded arguments, word-aligned, so `pick` and `nav` navigate them exactly as they navigate a call's return.
- A zero selector accepts any revert and passes the data through whole, selector included.
- A code-less target counts as a failure, as for `isValid`, but carries no reason: only a zero selector accepts it, returning empty data. A non-zero selector reverts with `UnexpectedRevertData(expected, 0x00000000)`.
- An operand that is not a `STATIC_CALL` reverts with `RevertProbeNotACall(fetcherType)`, and one carrying constraints with `RevertProbeConstrained(count)`. Silently ignoring a constraint that can never be checked would be worse.

In EVML, `-!>` matches the reason and a `[_ $]` lens selects an error argument. "`withdraw(100)` still fails with `InsufficientBalance`, and the shortfall it reports is at least 100":

```evml
assert @reverts!($vault::!{withdraw(uint256)(uint256) 100} -!> InsufficientBalance(uint256,uint256) [_ $]) >= 100
```

In Solidity, `nav` selects argument 1 of the stripped payload and the constraint judges it like any other read:

```solidity
bytes memory probe = abi.encodeCall(Assertions.revertData, (
    callParam(vault, abi.encodeCall(IVault.withdraw, (100)), noConstraints()),
    IVault.InsufficientBalance.selector
));
int256[] memory path = new int256[](1);
path[0] = 1;
bytes memory nav = abi.encodeCall(Assertions.nav, (
    callParam(address(assertions), probe, noConstraints()), "(uint256,uint256)", path
));
assertions.assertParam(callParam(address(assertions), nav, gte(100)));
```

`isValid(revertData(a, sel))` is 1 exactly when `a` reverts with the expected error. The reason `revertData` observes belongs to whatever the operand calls **directly**. A nested core expression is itself a staticcall into the core, so probing one reports the core's own error: reason matching only makes sense on a direct target call, and a composer must keep the operand direct when the selector is non-zero. Operand decoding happens before the target is probed, and a decoder failure at that stage (a bare revert, an allocation panic) is propagated, not reported as the target's revert data.

### A batch as an operand

The batch judge is a view function, so an entire ERC-8211 batch encodes into one `STATIC_CALL` operand pointed back at the core, and the probes above apply to it unchanged. `abi.encodeCall` cannot disambiguate the `assertBatch` overloads, so name the single-batch surface through a one-function interface:

```solidity
interface IAssertBatch {
    function assertBatch(ComposableExecution[] calldata executions) external view;
}

InputParam memory batchProbe = callParam(
    address(assertions), abi.encodeCall(IAssertBatch.assertBatch, (executions)), noConstraints()
);
```

With no new surface:

- `isValid(batchProbe)` reads "would this batch pass, right now" as a 0/1 word: branch on it with `cond`, or constrain it `EQ 1` (the batch must hold) or `EQ 0` (it must not).
- `orElse(batchProbe, fallback)` selects a fallback value when the batch would not hold.
- `revertData(batchProbe, ConstraintFailed.selector)` asserts the batch fails for exactly a constraint, and returns `ConstraintFailed`'s arguments (which entry, which parameter, the offending value) for `pick` and `nav` to judge. The operand is a direct call into the core, so the reason observed is the core's own error, which is the one being matched.

The same shape pointed at a deployed ERC-8211 implementation's `executeComposable` asks "this account would accept this batch right now", the eth_call gate relayers apply off-chain, made composable on-chain. Two caveats come with that form. The probe is a staticcall, so only state-neutral batches (predicate entries) can pass it, and a 0 from `isValid` conflates "a constraint fails" with "the batch writes state". Real accounts may also gate `executeComposable` by sender, so a rejection can mean authorization rather than constraints; `revertData` with a selector tells the two apart. There is no EVML spelling for a batch as an operand.

### The staticcall boundary and the OOG caveat

`orElse` and `isValid` evaluate their attempt behind an external self-staticcall boundary, and `revertData` staticcalls its target in-frame. A failed subcall that consumed nearly all its forwarded gas is ambiguous: the transaction's gas limit may have caused the failure. Each call boundary therefore checks failed subcalls before handling ordinary errors. If at most `gasBefore / 63` of the gas remains, or the callee returned exactly the four-byte `SubcallOutOfGas()` error, the boundary rethrows `SubcallOutOfGas()`.

The core, Expressions, `Operations.rawCall`, and Collections' word and value callbacks all preserve this signal. In these supported compositions, exhaustion cannot select `orElse` or `TryOrElse` fallbacks, make `isValid` or `IsValid` report false, or become accepted revert data in `revertData` or `ProbeCall`. Concrete gas sweeps cover direct calls and each wrapper, including expression callbacks and nested core calls.

This is a conservative refusal, not a way to identify the reason for every failure. An ordinary revert that consumed nearly all its gas is refused too. An external target can swallow a subcall's exhaustion, transform its error, or intentionally branch on `gasleft()`, and the toolkit cannot recover information that target hides. Do not interpret failure probes as gas-independent predictions for arbitrary external code. The exact four-byte `SubcallOutOfGas()` is a reserved refusal signal, not authenticated evidence of its origin: a target can raise it deliberately.

## Solidity helpers

These helpers build the calldata of an assertion in a script or a test. They are not meant for a contract to call Assertions at run time: Assertions is for transactions you prepare, and a contract that needs a check should write it natively in Solidity, which costs far less.

An assertion is one external view call to the judge. The wire format is three structs imported from `ERC8211.sol`, and a few one-line helpers cover almost everything. The other contract pages reuse these.

```solidity
import {
    InputParam, InputParamType, InputParamFetcherType,
    Constraint, ConstraintType
} from "assertions/lib/ERC8211.sol"; // adjust the path to where you keep ERC8211.sol

/** A staticcall fetcher: the raw returndata of target.data is the value. */
function callParam(address target, bytes memory data, Constraint[] memory cs)
    pure returns (InputParam memory)
{
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.STATIC_CALL,
        abi.encode(target, data),
        cs
    );
}

/** A balance fetcher: token == address(0) reads the native balance,
    otherwise IERC20(token).balanceOf(account). */
function balanceParam(address token, address account, Constraint[] memory cs)
    pure returns (InputParam memory)
{
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.BALANCE,
        abi.encodePacked(token, account),
        cs
    );
}

/** A literal operand: the RAW_BYTES fetcher echoes the bytes. */
function rawParam(bytes memory v) pure returns (InputParam memory) {
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.RAW_BYTES,
        v,
        new Constraint[](0)
    );
}

function noConstraints() pure returns (Constraint[] memory cs) {
    cs = new Constraint[](0);
}
function eq(bytes32 x) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.EQ, abi.encode(x));
}
function gte(uint256 x) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.GTE, abi.encode(x));
}
function lte(uint256 x) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.LTE, abi.encode(x));
}
/** Inclusive range; also the approximate-equality form (x - d .. x + d). */
function within(uint256 lo, uint256 hi) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.IN, abi.encode(lo, hi));
}
```

A complete example: a DAO proposal that moves tokens out of a treasury, with a precondition, the transfer, a postcondition and an ownership invariant. In EVML the four checks are one line each, and the decoded form of each is what [Reviewing an assertion](/docs/reviewing) teaches a signer to read.

```evml
assert $token::!{balanceOf(address)(uint256) $treasury} >= $requiredBalance "Treasury balance too low"
# ... the transfer ...
assert $token::!{balanceOf(address)(uint256) $treasury} >= $minimumReserves "Transfer would deplete reserves"
assert $treasury::!{owner()(address)} == $dao "Treasury ownership compromised"
```

The same batch from Solidity, as the proposal's action list:

```solidity
/** 1. Precondition: the treasury holds the expected balance before the transfer. */
assertions.assertParam(
    callParam(token, abi.encodeCall(IERC20.balanceOf, (treasury)), gte(requiredBalance)),
    "Treasury balance too low"
);

/** 2. The guarded action. */
IERC20(token).transferFrom(treasury, recipient, amount);

/** 3. Postcondition: the treasury keeps its minimum reserves. */
assertions.assertParam(
    callParam(token, abi.encodeCall(IERC20.balanceOf, (treasury)), gte(minimumReserves)),
    "Transfer would deplete reserves"
);

/** 4. Invariant: the DAO still owns the treasury. */
assertions.assertParam(
    callParam(treasury, abi.encodeCall(Ownable.owner, ()), eq(bytes32(uint256(uint160(dao))))),
    "Treasury ownership compromised"
);
```

Caveats that apply when building parameters:

- **Choose the constraint's signedness.** For `int256` returns use `GTE_SIGNED`, `LTE_SIGNED` or `IN_SIGNED`, or the Operations `int256` overloads read-spliced and judged `EQ 1`.
- **Calls to code-less addresses revert with `CallFailed`.** To tolerate a missing or reverting target, wrap the operand in `orElse`.
- **View-only judging.** The judge rejects output parameters and `VALUE` parameters: assertions never change state.
- **EIP-7702 delegated EOAs carry code.** A delegated EOA has a 23-byte delegation designator as its code, so a "has no code" check (`Operations.codeHash` equal to `bytes32(0)` or `keccak256("")`) is not a strict "is an EOA" check on chains with EIP-7702.
- **`block.number` differs across chains.** On OP-stack and most L2s, `Operations.blockNumber()` sees the L2 block number, and on Arbitrum `block.number` returns the approximate L1 block. Block times also vary per chain, so avoid porting block-number thresholds between networks.

The Operations reads named in the last two items are on the [Operations page](/docs/contracts/operations).

## Failure modes and limits

Exhaustion and the exact reserved `SubcallOutOfGas()` signal propagate unchanged through every primitive. Ordinary failures are descriptive. The errors shared by every contract are on the [Errors](/docs/contracts/errors) page; the ones this contract raises:

| Error | Raised when |
|-------|-------------|
| `ConstraintFailed` | a constraint is violated; names the entry, operand, constraint index and echoes the actual word |
| `CallFailed(target, data)` | an operand's call reverts or its target has no code |
| `ReturnDataOutOfBounds(index, length)` | a value is shorter than a constraint, `pick` index or first-word read needs; also nav data that does not match the declared shape |
| `InvalidAddressWord(index, word)` | an address word has dirty upper bytes (`chain`, `read`, `get`, a batch `TARGET`) |
| `InvalidBalanceData`, `InvalidConstraintData`, `InvalidConstraintRange`, `InvalidOrConstraint` | malformed `BALANCE` paramData or constraint payloads |
| `OutputParamsNotSupported`, `ValueParamNotSupported`, `DuplicateTargetParam`, `BalanceCannotBeTarget` | a batch asks for something a view judge cannot do |
| `InvalidTypeDescriptor(position)` | `nav` or `get` receives a malformed type descriptor, at the offending character |
| `InvalidNavigation(position)` | a `nav` step enters a non-composite value, a sentinel has no preceding selection, or `LEN` or `PAYLOAD` meets an unsupported type |
| `ElementIndexOutOfBounds(index, count)` | a `nav` path index lies outside its tuple or array |
| `InvalidValue(offset)` (from `AbiCodec`) | `nav` returns a word outside its type's range, dirty `string` or `bytes` padding, or malformed nested data in a re-encoded terminal |
| `EmptyCallChain` | `chain` receives no calls |
| `ComponentCountMismatch`, `InvalidComponentEnvelope`, `InvalidComponentLength`, `InvalidComponentValue` | `get` argument values do not fit `argumentTypes` |
| `DidNotRevert`, `UnexpectedRevertData`, `RevertProbeNotACall`, `RevertProbeConstrained` | `revertData` preconditions |
| `SubcallOutOfGas()` | a failed subcall looks like gas exhaustion; see [the OOG caveat](#the-staticcall-boundary-and-the-oog-caveat) |

Limits that follow from the design:

- **Resolution is recursive.** A primitive operand that is itself a core call is a staticcall into the core, so deep nesting costs one external call per level, and the transaction's gas bounds how much an assertion can check.
- **Bare reverts exist.** Wire bytes that solc's ABI decoder cannot read (a `STATIC_CALL` `paramData`, an `OR` `referenceData`) can revert without data, nested requests can raise `Panic(0x41)`, and resource exhaustion can return empty data. These are documented rather than pre-validated, because a canonical check would reject what the reference accepts and tax every `STATIC_CALL`.
- **Types are claims.** Descriptors and type lists are checked for encoding validity and each word's range, not for truth.
- **Splicing an array into a bytes operation is a trap.** At the raw Solidity boundary, passing an `ARRAY` return directly to `Operations.hash` or `byteLen` digests N bytes of an N-element payload, because its length word counts elements. `hash(rawCall(target, data))` is the raw whole-returndata spelling. The SDK rejects non-string, non-bytes operands, and so does the builder.
- **The code is not yet externally audited.** Every function is `view`, so the failure mode is a wrong answer, not a loss of funds.

## Why it lives here

The core's admission test is that only what needs operands to arrive **unresolved** lives on it. Every primitive above holds `InputParam`s and decides how, or whether, to resolve them; a branch that must not execute, a fallback that must catch a failure, and a call whose arguments come from other reads can only be held by code that speaks the `InputParam` format. Scalar computation over resolved values belongs to [Operations](/docs/contracts/operations), iteration to [Collections](/docs/contracts/collections), and expression graphs to [Expressions](/docs/contracts/expressions). Before adding anything here, check whether composition already expresses it: `hash(rawCall(target, data))` made both a `hashOf` primitive and a hash-equality constraint type unnecessary. A branch that moved `pick`, `nav`, `chain`, `read`, `cond`, `orElse`, `isValid` and `revertData` onto a separate contract bound to the core by an immutable was measured on 2026-09-07 and refused: every operand resolution became an extra staticcall hop, and the `OperationsGas` tables roughly doubled per element (the composed `bitSet` fold went from 16,572 to 35,708 gas per byte and `hashPairSorted` from 10,486 to 22,510 gas per level), so the primitives stay on the core.
