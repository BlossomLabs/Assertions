---
title: Deployments
description: Canonical CREATE2 addresses and how to deploy to a new chain.
---

Both contracts live at the same canonical address on every chain:

```
Assertions  v1.1  0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0   (frozen core)
Combinators v1.0  0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC   (versionable periphery)
```

Core v1.0 remains deployed at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F) (`0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`).

The [interactive deployments page](/deployments) shows per-chain status, lets you deploy with a connected wallet, and verifies contracts on explorers.

## How the addresses stay canonical

Deployment goes through [Arachnid's deterministic-deployment proxy](https://github.com/Arachnid/deterministic-deployment-proxy) (`0x4e59b44847b379578588920cA78FbF26c0B4956C`), which performs a CREATE2 with a fixed salt per contract:

```
address = keccak256(0xff ++ 0x4e59b448...956C ++ salt ++ keccak256(initCode))[12:]
```

Same proxy, same salt, same init code on every chain: same address.

## Deploying to a new chain

The easiest way is the [deployments page](/deployments): connect a wallet, pick the network (or add a custom RPC), and send one transaction per contract (Assertions ~4.2M gas, Combinators ~1.1M gas). If the Arachnid proxy is missing on the chain, the page walks you through installing it permissionlessly first.

Manually, each deployment is a single transaction to the proxy with `salt ++ initCode` as calldata:

```bash
cast send 0x4e59b44847b379578588920cA78FbF26c0B4956C \
  "$(cat salt_and_initcode.hex)" --rpc-url <rpc> --private-key <key>
```

The salts live in `hardhat.config.ts` and `website/scripts/export-deploy-artifact.mjs`; the script regenerates `website/src/lib/assertions-deployment.ts` and `website/src/lib/combinators-deployment.ts` (salt, init code, and predicted address for each contract) from a fresh compile. It refuses to export if the compiled bytecode no longer reproduces a canonical address.

:::caution
**Do not use `hardhat ignition deploy` for the canonical deployment.** Ignition's `create2` strategy goes through the CreateX factory, which re-hashes the salt and therefore produces a *different* address than the Arachnid proxy. The Ignition module is kept only for local testing.
:::

:::note[Chain requirements]
The bytecode targets `cancun` and contains `PUSH0`, so the target chain must support the Shanghai upgrade or later. The exact compiler settings in `hardhat.config.ts` (solc 0.8.28, optimizer 200 runs, `evmVersion: cancun`) must not change, or the CREATE2 addresses change with the bytecode.
:::
