# Assertions

On-chain assertion contracts for verifying blockchain state in Solidity, built around a static call to [ERC-8211 (Smart Batching)](https://www.erc8211.com/). An assertion is an ERC-8211 predicate: an `InputParam` that declares how to fetch a live value (`RAW_BYTES` literal, arbitrary `STATIC_CALL`, or `BALANCE` query) and the inline `Constraint`s (`EQ` / `GTE` / `LTE` / `IN`) it must satisfy. Batch assertion calls alongside the transactions they guard (DAO proposals, Safe batches, upgrades): if any constraint fails, the entire transaction reverts, atomically.

**The core reads and judges, Operators compute.**

- **`Assertions` (the core)** owns everything that speaks ERC-8211. It judges batches in view mode: `assertParam` resolves one input parameter and validates its constraints; `assertComposable(executions)` evaluates a full `ComposableExecution[]` batch with every fetcher and every constructed call executed via `staticcall`. And it carries the read primitives whose operands arrive unresolved: `resolve`, `pick`, `nav`, `chain`, `read` (construct a staticcall from runtime-resolved segments) and the lazy control primitives `cond`, `orElse`, `isValid`, `revertData`.
- **`Operators` (the periphery)** is a plain-Solidity vocabulary with zero ERC-8211 coupling: named word ops with `int256` overloads (`add`, `gt`, `absDiff`, ...), 512-bit `mulDiv` and `sqrt`, bitwise ops (including the arithmetic-shift `shr` overload), environment reads, bytes, search and parse operations (`hash`, occurrence-ordinal `indexOf`, `parseUint`), a runtime `encode`, and bounded folds. The core's `read` resolves operand expressions and splices the values into Operators calldata; any deployed view contract extends the vocabulary through the same socket.
- **`ERC8211.sol`** carries the standard's wire format (`ComposableExecution`, `InputParam`, `Constraint`) and the `IComposableExecution` interface — batches produced by any ERC-8211 SDK decode here unchanged. **`AbiShape.sol`** is the shared ABI type-descriptor grammar `nav` and `encode` both parse.

## Canonical addresses (same on every chain)

```
Assertions  v2.0  0xA01bC220Efc4c730BBcBC9ee52EE570D33EA956F   (ERC-8211 judge; INTERIM address)
Operators   v1.0  0x8e832Ace3f433943eb605c258bA37AF24a69dC53   (versionable periphery; INTERIM address)
```

The current addresses use a zero CREATE2 salt while the 2.0 line is still in flux; vanity `0xa55E…` salts get re-mined before the canonical roll.

Deployed versions are immutable and keep working forever at their own canonical addresses: the v2.0-rc core lives at `0xa55E47F37088b6D0212BdfD56b175ec08744DB19` with Combinators v2.0-rc at `0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9`, the v1.1 typed-assert core at `0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0` with Combinators v1.0 at `0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`, and the original v1.0 core at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F).

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
- **Core primitives** — the reads (`resolve`, `pick`, `nav`, `chain`, `read`) and resolution control (`cond`, `orElse`, `isValid`, `revertData`)
- **Operators** — the plain-value vocabulary: word ops, comparisons, bytes and search operations, the runtime encoder and the folds
- **EVMcrispr integration** — the `assertions` module, lenses and on-chain `@helper!`s
- **Reference** — every assertion function, every custom error, and deployment to new chains

Run it locally with `pnpm --dir website dev` and open `http://localhost:3000/docs`, or use the hosted site. The website also ships an interactive **Assertion Builder** (`/builder`) and a **Deployments** page (`/deployments`) for deploying both contracts to new chains at their canonical CREATE2 addresses.

## Development

```bash
pnpm install          # install dependencies
pnpm hardhat compile  # build the contracts
pnpm test             # run the test suite
```

The contracts target solc 0.8.36 with `evmVersion: cancun`; compiler settings in `hardhat.config.ts` must not change or the canonical CREATE2 addresses change with the bytecode.

## License

MIT
