# Assertions

On-chain assertion contracts for verifying view function return values and blockchain state in Solidity. Batch assertion calls alongside the transactions they guard (DAO proposals, Safe batches, upgrades): if any assertion fails, the entire transaction reverts, atomically.

**Assertions judge, Combinators compute.**

- **`Assertions` (the core)** executes view functions via `staticcall` and compares the results against expected values, reverting with descriptive custom errors on failure. The core is frozen forever: no future version changes its behavior at its canonical address.
- **`Combinators` (the periphery)** provides five composable building blocks — `read`, `calc`, `unary`, `data`, `env` — that compute arbitrary expressions over live on-chain values. The core judges the final value by pointing any call assertion at the Combinators address.

## Canonical addresses (same on every chain)

```
Assertions  v1.1  0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0   (frozen core)
Combinators v1.0  0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC   (versionable periphery)
```

Core v1.0 remains deployed at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F); v1.1 is a strict superset of its ABI.

## Quick example

```solidity
// In a DAO proposal's action list:
assertions.assertGeCallUint(
    treasury,
    abi.encodeCall(IERC20.balanceOf, (treasury)),
    requiredBalance,
    "Treasury balance too low"
);

treasury.transfer(recipient, amount);

assertions.assertEqCallAddress(
    treasury,
    abi.encodeCall(Ownable.owner, ()),
    address(dao),
    "Treasury ownership compromised"
);
```

Or as a one-line [EVMcrispr](https://evmcrispr.blossom.software) script:

```
assertions:assert $treasury::balanceOf($treasury) >= 1000e18 "Treasury balance too low"
```

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
