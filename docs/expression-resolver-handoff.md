# Expression resolver and generic traversal handoff

This extension adds `ExpressionResolver`, generic collection traversal and composed callbacks, byte-oriented slicing, and restored fixed-point exponential/logarithm operations. No public deployment or commit is performed. Pre-existing working-tree changes to the core/shared codec remain preserved; this extension does not modify core source.

## Resolve once

- `resolveCall(address core,InputParam target,bytes4 selector,string argumentTypes,InputParam[] args)` resolves the target and each argument once, constructs canonical calldata, and raw-returns target returndata.
- `resolveArguments(address core,string argumentTypes,InputParam[] args)` raw-returns the canonical argument tuple after one resolution per supplied argument.
- `resolveValues(address core,InputParam[] args) returns(bytes[])` resolves each source once and wraps its raw output as an array element.

There is no four-live-argument limit. Independent duplicate entries in these input arrays are still independent resolutions; use shared graph references for common subexpressions. The empty argument descriptor `()` is supported. Core resolution applies each InputParam's constraints.

## Typed expression graph

`evaluate(Program,bytes[])` raw-returns one canonical ABI value. `evaluateEncoded(bytes,bytes[])` accepts `abi.encode(Program)` and returns the same raw value; Collections uses this entry.

```
Program = (address core, Node[] nodes, uint256 result)
Node = (uint8 kind, string valueType, bytes data, uint256[] refs, bytes4 selector, string arguments)
```

All references point strictly backward. Only reachable nodes execute; successful nodes are memoized for one evaluation. Canonical ABI shape is validated for outputs, while scalar types remain descriptor claims, consistent with AbiCodec.

| Kind | Meaning |
|---|---|
| 0 Literal | `data` is a canonical value envelope. |
| 1 Parameter | `data` is `abi.encode(uint256 parameterIndex)`. |
| 2 Resolve | `data` is `abi.encode(InputParam)` resolved through `program.core`. |
| 3 Call | First reference is an address; remaining references are arguments. `selector` and `arguments` define the call. |
| 4 Select | References are condition, then, else. Condition is canonical bool; only one branch executes. |
| 5 Wrap | Wrap the referenced canonical encoding as a bytes value. |
| 6 Array | Pack referenced values as an array; `arguments` is the element descriptor. |
| 7 Tuple | Construct one canonical tuple value; `arguments` describes components. |
| 8 TryOrElse | Try the first reference in an isolated self-frame, otherwise evaluate the second. |
| 9 IsValid | Return a canonical bool word indicating successful referenced evaluation. |
| 10 ProbeCall | References are target/address and calldata/bytes; capture raw revert data as a bytes value. Nonzero selector requires a match and strips the four selector bytes. |

ProbeCall preserves the underlying target reason and uses the same `DidNotRevert(address,bytes)` and `UnexpectedRevertData(bytes4,bytes4)` errors as the core. A codeless target yields empty reason when no selector is required. Error payloads with no arguments are valid empty bytes after selector stripping.

Guarded success merges memoized values; reverted attempts discard their cache changes. All failures, including subframe out-of-gas, count as failure in guarded nodes, like the existing core guards. `evaluateGuarded` is a self-only implementation entry; arbitrary callers cannot inject caches.

`Collections.Callback` gains a final `bytes program` field. Empty selects the existing direct callback. Nonempty selects `target.evaluateEncoded(program, boundArguments)`; `selector` is ignored. Argument descriptors, constants, and first/second whole-value slots retain their meaning. This supports dynamic/multiword parameters, repeated references, live targets, and composed operations without byte-offset substitutions.

Memoization is per callback invocation, not across traversal iterations. Source arrays can be resolved once by the outer resolver. Captures encoded as graph Resolve nodes remain lazy but are re-evaluated for each invocation that reaches them. Traversal-wide capture caching is not claimed.

## Collection and byte APIs

- `reverseValues(string,bytes[]) returns(bytes[])`.
- `sliceValues(string,bytes[],int256 start,int256 end) returns(bytes[])`: clamped signed indexes, end exclusive, reversed range empty.
- `indexOfValues(string,bytes[],bytes needle,Callback) returns(uint256)`: first equality match, or uint256.max.
- `anyValues`, `allValues`, `findValues` take `(string,bytes[],Callback)`; any/all return bool, find returns first matching index or uint256.max. Traversal stops at the first decisive predicate, and empty any/all are false/true.
- `zipValues(string leftType,string rightType,bytes[] left,bytes[] right) returns(bytes[])`: equal lengths, canonical pair tuple envelopes.
- `unzipValues(string leftType,string rightType,bytes[] pairs,uint256 lane) returns(bytes[])`: lanes 0/1, validate both components.
- Operations `contains(bytes,bytes)` handles empty needles as true.
- `sliceRange(bytes,int256,int256)` uses clamped signed byte ranges; `byteAt(bytes,int256)` requires an in-range byte index.
- `stringSlice(bytes,int256,int256)` validates the full UTF-8 input and rejects nonempty ranges splitting a code point. Empty ranges return empty bytes. `stringAt(bytes,int256)` rejects a byte from a multibyte code point. Both return bytes envelopes compatible with string ABI transport.
- `expWad(int256)` and `lnWad(int256)` restore the earlier fixed-point algorithms and bounds.

## Validation and artifacts

`pnpm test` outside the restricted sandbox: **430 passing (346 Solidity, 84 nodejs)**. New tests execute six dynamic arguments, repeated shared sources, lazy select, guarded fallback/cache merge, canonical ABI constructors, composed dynamic callbacks, mixed tuple zip/unzip, short-circuit traversal, negative slices, malformed UTF-8, and restored math. Existing fuzz suites also execute. `forge fmt --check` on modified production contracts and `git diff --check` pass.

Final local CREATE2 replay through `node website/scripts/export-deploy-artifact.mjs`:

| Contract | Address | Runtime bytes | Deployment gas |
|---|---|---:|---:|
| Assertions | `0x4D710b5AaBcd7f8753307c71779904A562422A15` | 13,116 | 2,895,849 |
| Operations | `0xbe58Ca28d8FC1395F94E9871cB8A15f3D2Bd2f60` | 20,942 | 4,591,969 |
| Collections | `0xd19bdD4a5462080F40B795c50d98827812B2C56b` | 24,304 | 5,320,999 |
| ExpressionResolver | `0x255e580C85133DCECe94B67DaA21036Ed3C08997` | 17,949 | 3,943,154 |

Collections has **272 bytes** of EIP-170 headroom. These are unreleased candidate addresses, not claims of public-chain deployment.

`pnpm hardhat run scripts/measure-expression-gas.ts` measured transaction estimates (including intrinsic/calldata): resolveArguments for 1/4/16 dynamic values **51,743 / 124,448 / 417,215 gas**; a shared four-node graph **158,105 gas**. Generic expressions prioritize expressiveness and avoid repeated resolution; retain word-specialized paths where they have identical semantics and lower cost.

ABIs and deployment exports are under `website/src/lib/`, including `expression-resolver-abi.ts` and `expression-resolver-deployment.ts`. Artifacts are under `artifacts/contracts/<Contract>.sol/<Contract>.json`. SDK integration must synchronize addresses, creation bytes, runtime fixtures, installers, and exported ABIs together; preserve the website vendor pin until a separate authorized update.
