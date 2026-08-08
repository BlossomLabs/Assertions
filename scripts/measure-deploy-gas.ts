// Measures the real gas cost of the canonical CREATE2 deployments by
// replaying them on an in-process Hardhat network: the Arachnid proxy's
// runtime code is installed at its canonical address, then each contract is
// deployed through it exactly as on a live chain (salt ++ initCode as
// calldata) and the receipt's gasUsed is reported.
//
// Driven by website/scripts/export-deploy-artifact.mjs, which passes the
// contract list via the MEASURE_DEPLOY_GAS_CONFIG env variable and parses
// the DEPLOY_GAS_JSON marker line from stdout:
//   npx hardhat run scripts/measure-deploy-gas.ts

import { readFileSync } from "node:fs";

import { network } from "hardhat";
import { concat, getAddress } from "viem";

// Arachnid deterministic-deployment-proxy runtime bytecode (the code living
// at 0x4e59b44847b379578588920cA78FbF26c0B4956C on every chain).
const CREATE2_PROXY = "0x4e59b44847b379578588920cA78FbF26c0B4956C" as const;
const CREATE2_PROXY_RUNTIME =
  "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3" as const;

interface MeasureTarget {
  name: string;
  artifact: string; // path relative to the repo root
  salt: `0x${string}`;
  expectedAddress: `0x${string}`;
}

const config = process.env.MEASURE_DEPLOY_GAS_CONFIG;
if (!config) {
  throw new Error(
    "MEASURE_DEPLOY_GAS_CONFIG is not set — run this script through " +
      "website/scripts/export-deploy-artifact.mjs",
  );
}
const targets: MeasureTarget[] = JSON.parse(config);

const { viem } = await network.connect("hardhatMainnet");
const publicClient = await viem.getPublicClient();
const testClient = await viem.getTestClient();
const [wallet] = await viem.getWalletClients();

await testClient.setCode({
  address: CREATE2_PROXY,
  bytecode: CREATE2_PROXY_RUNTIME,
});

const gasUsed: Record<string, number> = {};
for (const target of targets) {
  const artifact = JSON.parse(readFileSync(target.artifact, "utf8"));
  const hash = await wallet.sendTransaction({
    to: CREATE2_PROXY,
    data: concat([target.salt, artifact.bytecode]),
  });
  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  if (receipt.status !== "success") {
    throw new Error(`Canonical deployment of ${target.name} reverted`);
  }
  const code = await publicClient.getCode({
    address: getAddress(target.expectedAddress),
  });
  if (!code || code === "0x") {
    throw new Error(
      `${target.name} did not land at ${target.expectedAddress} — the ` +
        "local artifact no longer reproduces the canonical address",
    );
  }
  gasUsed[target.name] = Number(receipt.gasUsed);
}

console.log(`DEPLOY_GAS_JSON ${JSON.stringify(gasUsed)}`);
