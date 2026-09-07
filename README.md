# Assertions

On-chain assertion contracts for verifying blockchain state in Solidity, built around a static call to [ERC-8211 (Smart Batching)](https://www.erc8211.com/). An assertion is an ERC-8211 predicate: an `InputParam` that declares how to fetch a live value (`RAW_BYTES` literal, arbitrary `STATIC_CALL`, or `BALANCE` query) and the inline `Constraint`s (`EQ` / `GTE` / `LTE` / `IN`) it must satisfy. Batch assertion calls alongside the transactions they guard (DAO proposals, Safe batches, upgrades): if any constraint fails, the entire transaction reverts, atomically.

**The core reads and judges; the periphery computes.**

- **`Assertions` (the core)** owns everything that speaks ERC-8211. It judges batches in view mode: `assertParam` resolves one input parameter and validates its constraints; `assertBatch(executions)` evaluates a full `ComposableExecution[]` batch with every fetcher and every constructed call executed via `staticcall`. And it carries the read primitives whose operands arrive unresolved: `resolve`, `pick`, `nav`, `chain`, `read` (construct a staticcall from runtime-resolved segments) and the lazy control primitives `cond`, `orElse`, `isValid`, `revertData`.
- **`Operations`** provides scalar arithmetic, comparisons, bitwise operations, environment reads, bytes/string processing, and ABI encoding.
- **`Collections`** owns iteration: the bounded folds, the word-array family (map, filter, sort, deduplicate, zip, sum) and the generic ABI-valued traversals with typed callbacks. Both sorting paths use stable bottom-up merge sort.
- **`Expressions`** (unreleased) adds typed expression graphs and resolve-once call construction, so a repeated subterm is evaluated once instead of being duplicated in calldata; `Collections.Callback.expression` is its only in-tree consumer.

- **`ERC8211.sol`** carries the standard's wire format (`ComposableExecution`, `InputParam`, `Constraint`) and the `IComposableExecution` interface, so batches produced by any ERC-8211 SDK decode here unchanged. **`AbiCodec.sol`** shares descriptor parsing, canonical value validation, and ABI assembly across the core and the periphery contracts. Navigation remains selective; public encoding validates complete values.

## Canonical addresses (same on every chain)

```
Assertions          v2.0  0xf601f42D6752dB5423efE6e5c16044d275F06aC2   (frozen core: judge + primitives)
Operations          v1.0  0xe3F9CCD4f6A11a044533055B9581765EB845AbB3   (versionable periphery)
Collections         v1.0  0x9647762c87a5Ff7a378c4a4752D23b88E5302e3B   (generic collections)
Expressions         v1.0  0xb3cC9B9821b990B7c7EAe4934555d04c273Ce487   (unreleased typed expression graphs)
```

These are the CREATE2 addresses of the current artifact set: the shared-codec core, the split Operations/Collections periphery, and Expressions. Listing an address implies no public-chain deployment; check the website's Deployments page for per-chain availability. Expressions is unreleased: the SDK does not compile against it. Earlier releases and retired artifact candidates (which use different bytecode) are listed on the Deployments page, rendered from `website/src/lib/deployments.json`.

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

- **Overview & architecture**: the four contracts, the admission test that splits them, and why the core stays frozen
- **Using assertions from Solidity**: complete patterns for proposals, Safe batches and upgrades
- **Core primitives**: the reads (`resolve`, `pick`, `nav`, `chain`, `read`) and resolution control (`cond`, `orElse`, `isValid`, `revertData`)
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

The website vendors an EVMcrispr checkout at `website/.evmcrispr`, pinned by `evmcrispr.commit` in `website/package.json`. The pinned revision's SDK compiles against the Assertions, Operations and Collections addresses above; Expressions has no SDK face. `pnpm --dir website check:integration` verifies that the pin, the compiled artifacts and the deployment manifest agree.

## License

MIT
