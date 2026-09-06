// Compare compiled candidates with pre-refactor artifacts saved by the review.
// BASELINE_ARTIFACTS=/path/to/baseline pnpm hardhat run scripts/measure-cleanup-gas.ts
import { readFileSync } from "node:fs";
import { network } from "hardhat";
import { encodeAbiParameters, encodeFunctionData, parseAbiParameters, toFunctionSelector } from "viem";

const baseline = process.env.BASELINE_ARTIFACTS;
if (!baseline) throw new Error("Set BASELINE_ARTIFACTS to the pre-refactor artifact directory");
const { viem } = await network.connect("hardhatMainnet");
const client = await viem.getPublicClient();
const [wallet] = await viem.getWalletClients();
for (const name of ["Operations", "Collections"]) {
  const results = [];
  for (const path of [`${baseline}/${name}.json`, `artifacts/contracts/${name}.sol/${name}.json`]) {
    const { abi, bytecode } = JSON.parse(readFileSync(path, "utf8"));
    const hash = await wallet.deployContract({ abi, bytecode });
    const { contractAddress: address } = await client.waitForTransactionReceipt({ hash });
    if (!address) throw new Error("Deployment failed");
    const gas = [];
    for (const n of (name === "Operations" ? [1, 16, 256, 1024] : [1, 16, 256])) {
      const sample = name === "Operations"
        ? {functionName: "replace", args: [`0x${"61".repeat(n)}21`, "0x61", "0x78797a"]}
        : {functionName: "mapValues", args: ["uint256", "uint256", Array.from({length:n}, (_, i) => encodeAbiParameters(parseAbiParameters("uint256"), [BigInt(i)])), {
          target: (await viem.deployContract("Operations")).address,
          selector: toFunctionSelector("add(uint256,uint256)"), arguments: "(uint256,uint256)",
          constants: ["0x", encodeAbiParameters(parseAbiParameters("uint256"), [1n])], first: 0n, second: 1n, program: "0x",
        }]};
      gas.push(Number(await client.estimateGas({to: address, data: encodeFunctionData({abi, ...sample})})));
    }
    results.push(gas);
  }
  console.log(JSON.stringify({name, lengths:name === "Operations" ? [1,16,256,1024] : [1,16,256], before:results[0], after:results[1]}));
}
