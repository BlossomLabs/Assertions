# Assertions

On-chain assertion contracts for verifying blockchain state in Solidity, built around a static call to [ERC-8211 (Smart Batching)](https://www.erc8211.com/). An assertion is an ERC-8211 predicate: an `InputParam` that declares how to fetch a live value (`RAW_BYTES` literal, arbitrary `STATIC_CALL`, or `BALANCE` query) and the inline `Constraint`s it must satisfy: constraint i checks resolved word i, with unsigned/signed comparisons, ranges, OR alternatives and SKIP. Batch assertion calls alongside the transactions they guard (DAO proposals, Safe batches, upgrades): if any constraint fails, the guarded execution reverts atomically when the executor makes the assertion mandatory and propagates its failure in the same transaction.

**Four contracts, one toolkit.** `Assertions` holds operands unresolved and judges them; the other three compute over values that are already resolved. All four are stateless and view-only, reach each other by address rather than by source import, and version independently by deploying at a new address.

- **`Assertions`** owns everything that speaks ERC-8211. It judges batches in view mode: `assertParam` resolves one input parameter and validates its constraints; `assertBatch(executions)` evaluates a full `ComposableExecution[]` batch with every fetcher and every constructed call executed via `staticcall`. And it carries the eleven primitives whose operands arrive unresolved: selection (`resolve`, `gather`, `pick`, `nav`), call construction (`chain`, `read` from calldata segments, `get` from whole canonical values) and lazy resolution control (`cond`, `orElse`, `isValid`, `revertData`).
- **`Operations`** provides scalar arithmetic, comparisons, bitwise operations, environment reads, bytes/string processing, and ABI encoding. Not optional in practice: comparisons beyond the inline predicates (`!=`, string equality, live-vs-live tolerance) use Operations expressions. The SDK also retains its existing Operations lowering for signed comparisons.
- **`Collections`** owns iteration: the bounded folds, the word-array family (map, filter, sort, deduplicate, zip, sum) and the generic ABI-valued traversals with typed callbacks. Both sorting paths use stable bottom-up merge sort.
- **`Expressions`** adds typed expression graphs, so references reuse a successfully cached subterm instead of duplicating it in calldata; the SDK emits graphs for collection callbacks and shared subterms, and `Collections.Callback.expression` runs them per element. Resolve-once call construction lives on the core, as `get` and `gather`.

- **`ERC8211.sol`** carries the standard's wire format (`ComposableExecution`, `InputParam`, `Constraint`) and the `IComposableExecution` interface, so batches produced by any ERC-8211 SDK decode here unchanged. **`AbiCodec.sol`** shares descriptor parsing, canonical value validation, and ABI assembly across all four contracts, and is the one source they all compile in: an edit there moves every canonical address at once. Navigation remains selective; public encoding validates complete values.

## Canonical addresses (same on every chain)

```
Assertions  v2.0   0xa55e471cE89f66FaACF21E7E7cC22F2E9E2facab   (judge + primitives)
Operations  v2.0   0x09e4A7e2BDDf5783F7e67765354d8090DB658c9D   (scalar vocabulary)
Collections v2.0   0xC011Ec7d80189d7425976eC7B338e32129fc2E43   (folds, word arrays, generic traversals)
Expressions v2.0   0xE5594E55D68156e9E87dC083aEdC6D57aB09e66d   (typed expression graphs)
```

These are the CREATE2 addresses of the current artifact set, and they change whenever the bytecode does. `website/src/lib/deployments.json` is the source of truth that the SDK, the builder and the docs all read; prefer it to this snapshot. An address listed here says where the code goes, not that it is already there: check the website's Deployments page for per-chain availability before you rely on one. The SDK compiles against all four. Only prior public releases are retained in the release history; the release with public-chain history is Assertions v1.0, reachable as `assertions.eth`.

## Quick example

```solidity
// In a DAO proposal's action list: assert the treasury keeps
// at least `requiredBalance` after the transfer.
Constraint[] memory constraints = new Constraint[](1);
constraints[0] = Constraint(ConstraintType.GTE, abi.encode(requiredBalance));

treasury.transfer(recipient, amount);

assertions.assertParam(
    InputParam({
        paramType: InputParamType.CALL_DATA,
        fetcherType: InputParamFetcherType.BALANCE,
        paramData: abi.encodePacked(address(token), treasury),
        constraints: constraints
    }),
    "Treasury balance too low"
);
```

The same check encoded as an ERC-8211 predicate entry (a `ComposableExecution` with no `TARGET`) passes through `assertBatch` unchanged, and canonical predicate batches using the supported constraints can be judged on-chain the same way.

## Documentation

The full documentation lives on the website under `/docs`:

- **Overview & architecture**: the four contracts and the admission test that splits them
- **Using assertions from Solidity**: complete patterns for proposals, Safe batches and upgrades
- **Core primitives**: the reads (`resolve`, `gather`, `pick`, `nav`, `chain`, `read`, `get`) and resolution control (`cond`, `orElse`, `isValid`, `revertData`)
- **Operations, Collections and Expressions**: the plain-value vocabulary (word ops, comparisons, bytes and search operations, runtime encoding), the folds and collection traversals, and the expression graphs
- **EVMcrispr integration**: the `assert` command, lenses and on-chain `@helper!`s
- **Reference**: every judge function, every custom error, and deployment to new chains

Run it locally with `pnpm --dir website dev` and open `http://localhost:3000/docs`, or use the hosted site. The website also ships an interactive **Assertion Builder** (`/builder`) and a **Deployments** page (`/deployments`) for deploying every exported contract to new chains at its canonical CREATE2 address.

## Development

```bash
pnpm install          # install dependencies
pnpm hardhat compile  # build the contracts
pnpm test             # run the test suite
```

The contracts require a Cancun-compatible EVM (including MCOPY and blob-context opcodes) and target solc 0.8.36 with `evmVersion: cancun`; compiler settings in `hardhat.config.ts` must not change or the canonical CREATE2 addresses change with the bytecode.

The website vendors an EVMcrispr checkout at `website/.evmcrispr`, pinned by `evmcrispr.commit` in `website/package.json`. The pinned revision's SDK compiles against all four addresses above. `pnpm --dir website check:integration` verifies that the pin, the compiled artifacts and the deployment manifest agree.

The gas guard propagates `SubcallOutOfGas()` through supported core, Operations `rawCall`, Collections callbacks and Expressions paths. Ordinary errors retain their wrappers. External targets that hide failures or deliberately change behavior with available gas are outside this guarantee. Empty batches and unconstrained values are accepted; a constructed call must succeed, but its return value is discarded, even when it encodes `false`. See [the claims ledger](docs/claims.md) and [retained verification evidence](docs/verification/halmos-coverage/README.md) for bounds and execution status.

The [ABI source proof](formal/abi/CONNECTION.md) connects the mathematical encoder and validator to production `AbiCodec.sol`, including recursive arrays/tuples and pack/unpack. Its passing baseline retains the trusted translation, memory and resource assumptions; compiler correctness and arbitrary-geometry bytecode verification remain separate.

The [navigation source proof](formal/navigation/README.md) connects `nav` after operand resolution to typed path selection, complete ABI value returns, LEN/PAYLOAD and empty paths. It proves arbitrary finite canonical queries under explicit arithmetic and EVM-resource assumptions, with retained proof results, independent solc/EVM tests and actual-source fault checks. Full resolver and compiled-bytecode correspondence remain separate.

The [constraint engine source proof](formal/constraints/README.md) connects `_checkConstraint` and `_validateConstraints` to independent signed/unsigned predicates and arbitrary finite positional lists, including OR rejection, short-circuit order and exact first-failure fields. Its retained baseline states the translation, decoder-outcome, memory and resource assumptions; resolver, judge-entry and compiled-bytecode proofs remain separate.

The [resolution and judge source proof](formal/resolution/README.md) connects RAW_BYTES, STATIC_CALL and BALANCE to constraint validation and both judge entry points, with arbitrary finite batches, ordered routing and exact propagated failures. External outcomes are history-indexed, so repeated calls need not be deterministic. Remaining core primitives, Expressions, Collections and compiled-bytecode verification are tracked separately.

The [raw-value core source proof](formal/core/README.md) covers `resolve`, `gather`, `pick`, `read`, `chain` and `cond` over arbitrary finite operand/hop lists, including signed word selection, ordered resolution, lazy branches and exact error indices. Remaining source and bytecode obligations stay tracked in the verification plan.

The [guarded-control source proof](formal/control/README.md) covers `orElse`, `isValid` and `revertData`, including exact failure precedence, lazy fallback and selector handling. Self-call receipts and sampled gas remain explicit premises; recursive call trees and exact bytecode remain separate obligations.

The [resolver-to-navigation composition](formal/composition/README.md) connects `nav` to the constraint/resolver and navigation proofs, preserving exact resolver failure precedence and the independent canonical path/mode semantics.

The [get/argument source proof](formal/arguments/README.md) connects ordered operand resolution to canonical tuple construction and the final call, including first invalid component indices and the empty-tuple exception. Recursive call trees and the remaining graph/collection/bytecode obligations stay open.

The [expression-admission proof](formal/expressions/admission/README.md) covers graph descriptor parsing, backward references, kind arities and exact admission errors. Evaluation, canonical values and cache behavior remain separate proof obligations.

## License

MIT
