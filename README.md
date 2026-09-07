# Assertions

On-chain assertion contracts for verifying blockchain state in Solidity, built around a static call to [ERC-8211 (Smart Batching)](https://www.erc8211.com/). An assertion is an ERC-8211 predicate: an `InputParam` that declares how to fetch a live value (`RAW_BYTES` literal, arbitrary `STATIC_CALL`, or `BALANCE` query) and the inline `Constraint`s (`EQ` / `GTE` / `LTE` / `IN`) it must satisfy. Batch assertion calls alongside the transactions they guard (DAO proposals, Safe batches, upgrades): if any constraint fails, the entire transaction reverts, atomically.

**Four contracts, one toolkit.** `Assertions` holds operands unresolved and judges them; the other three compute over values that are already resolved. All four are stateless and view-only, reach each other by address rather than by source import, and version independently by deploying at a new address.

- **`Assertions`** owns everything that speaks ERC-8211. It judges batches in view mode: `assertParam` resolves one input parameter and validates its constraints; `assertBatch(executions)` evaluates a full `ComposableExecution[]` batch with every fetcher and every constructed call executed via `staticcall`. And it carries the eleven primitives whose operands arrive unresolved: selection (`resolve`, `gather`, `pick`, `nav`), call construction (`chain`, `read` from calldata segments, `get` from whole canonical values) and lazy resolution control (`cond`, `orElse`, `isValid`, `revertData`).
- **`Operations`** provides scalar arithmetic, comparisons, bitwise operations, environment reads, bytes/string processing, and ABI encoding. Not optional in practice: every comparison the four constraint kinds cannot express (`!=`, signed ordering, string equality, tolerance) lowers to an Operations call judged `EQ 1`.
- **`Collections`** owns iteration: the bounded folds, the word-array family (map, filter, sort, deduplicate, zip, sum) and the generic ABI-valued traversals with typed callbacks. Both sorting paths use stable bottom-up merge sort.
- **`Expressions`** adds typed expression graphs, so a repeated subterm is evaluated once instead of being duplicated in calldata; the SDK emits graphs for collection callbacks and shared subterms, and `Collections.Callback.expression` runs them per element. Resolve-once call construction lives on the core, as `get` and `gather`.

- **`ERC8211.sol`** carries the standard's wire format (`ComposableExecution`, `InputParam`, `Constraint`) and the `IComposableExecution` interface, so batches produced by any ERC-8211 SDK decode here unchanged. **`AbiCodec.sol`** shares descriptor parsing, canonical value validation, and ABI assembly across all four contracts, and is the one source they all compile in: an edit there moves every canonical address at once. Navigation remains selective; public encoding validates complete values.

## Canonical addresses (same on every chain)

```
Assertions  v2.0   0xA55e47F41968c49e084955524fA77c1B2ef2B638   (judge + primitives)
Operations  v2.0   0x09E4A7Ef72b44d3E16466Ca3517Af567eA7D8aDA   (scalar vocabulary)
Collections v2.0   0xC011ec718c89903c3c5348837877f0FFCa67B500   (folds, word arrays, generic traversals)
Expressions v2.0   0xE5594e551FA2209A28386418AAb971983A874029   (typed expression graphs)
```

These are the CREATE2 addresses of the current artifact set, and they change whenever the bytecode does. `website/src/lib/deployments.json` is the source of truth that the SDK, the builder and the docs all read; prefer it to this snapshot. An address listed here says where the code goes, not that it is already there: check the website's Deployments page for per-chain availability before you rely on one. The SDK compiles against all four. Earlier releases and retired artifact candidates (which use different bytecode) are listed there too; the release with public-chain history is Assertions v1.0, reachable as `assertions.eth`.

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

The same check encoded as an ERC-8211 predicate entry (a `ComposableExecution` with no `TARGET`) passes through `assertBatch` unchanged, and any predicate batch an ERC-8211 SDK produces can be judged on-chain the same way.

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

The contracts target solc 0.8.36 with `evmVersion: cancun`; compiler settings in `hardhat.config.ts` must not change or the canonical CREATE2 addresses change with the bytecode.

The website vendors an EVMcrispr checkout at `website/.evmcrispr`, pinned by `evmcrispr.commit` in `website/package.json`. The pinned revision's SDK compiles against all four addresses above. `pnpm --dir website check:integration` verifies that the pin, the compiled artifacts and the deployment manifest agree.

## License

MIT
