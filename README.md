# Assertions

On-chain assertion contracts for verifying blockchain state in Solidity, built around a static call to [ERC-8211 (Smart Batching)](https://www.erc8211.com/). An assertion is an ERC-8211 predicate: an `InputParam` that declares how to fetch a live value (`RAW_BYTES` literal, arbitrary `STATIC_CALL`, or `BALANCE` query) and the inline `Constraint`s (`EQ` / `GTE` / `LTE` / `IN`) it must satisfy. Batch assertion calls alongside the transactions they guard (DAO proposals, Safe batches, upgrades): if any constraint fails, the entire transaction reverts, atomically.

**Assertions judge, Combinators compute.**

- **`Assertions` (the core)** judges ERC-8211 batches in view mode: `assertParam` resolves one input parameter and validates its constraints; `assertComposable(executions)` evaluates a full `ComposableExecution[]` batch with every fetcher and every constructed call executed via `staticcall`; `assertComposable(composable, executions)` performs the literal static call to a deployed `IComposableExecution` implementation — the on-chain equivalent of a relayer's `eth_call` gate.
- **`Combinators` (the periphery)** fills the expressiveness gaps of the ERC-8211 constraint set with composable building blocks — `resolve`, `pick`, `nav`, `chain`, `calc`, `unary`, `data`, `env` — whose operands are themselves ERC-8211 `InputParam`s. The core judges the final value through a constrained `STATIC_CALL` fetcher pointed at the Combinators address.
- **`ERC8211.sol`** carries the standard's wire format (`ComposableExecution`, `InputParam`, `Constraint`), the `IComposableExecution` interface, and the shared resolution library both contracts use — batches produced by any ERC-8211 SDK decode here unchanged.

## Canonical addresses (same on every chain)

```
Assertions  v2.0  0xA55E4797c1b755183B7Aad07BFd39D3e824621f9   (ERC-8211 judge)
Combinators v2.0  0xA55EC06e0A82a5ed05bf08c0ff07A45d4BC2eBf8   (versionable periphery)
```

Deployed versions are immutable and keep working forever at their own canonical addresses: the v1.1 typed-assert core lives at `0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0` with Combinators v1.0 at `0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`, and the original v1.0 core at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F).

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

The same check encoded as an ERC-8211 predicate entry (a `ComposableExecution` with no `TARGET`) passes through `assertComposable` unchanged — and any predicate batch an ERC-8211 SDK produces can be judged on-chain the same way.

## Documentation

The full documentation lives on the website under `/docs`:

- **Overview & architecture** — the two-contract design and why it stays frozen
- **Using assertions from Solidity** — complete patterns for proposals, Safe batches and upgrades
- **Combinators** — the five functions (`read`, `calc`, `unary`, `data`, `env`), navigation, expressions and string operations
- **EVMcrispr integration** — the `assertions` module, lenses and on-chain `@helper!`s
- **Reference** — every assertion function, every custom error, and deployment to new chains

Run it locally with `pnpm --dir website dev` and open `http://localhost:3000/docs`, or use the hosted site. The website also ships an interactive **Assertion Builder** (`/builder`) and a **Deployments** page (`/deployments`) for deploying both contracts to new chains at their canonical CREATE2 addresses.

## Development

```bash
pnpm install          # install dependencies
pnpm hardhat compile  # build the contracts
pnpm test             # run the test suite
```

The contracts target solc 0.8.28 with `evmVersion: cancun`; compiler settings in `hardhat.config.ts` must not change or the canonical CREATE2 addresses change with the bytecode.

## License

MIT
