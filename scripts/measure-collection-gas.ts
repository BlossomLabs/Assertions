// Local transaction estimates, including intrinsic/calldata gas. No public-chain access.
// Run: pnpm hardhat run scripts/measure-collection-gas.ts
import { readFileSync } from "node:fs";
import { network } from "hardhat";
import { encodeAbiParameters, encodeFunctionData, parseAbiParameters, toFunctionSelector, type Abi } from "viem";

const { viem } = await network.connect("hardhatMainnet");
const publicClient = await viem.getPublicClient();
const ops = await viem.deployContract("Operations");
const collections = await viem.deployContract("Collections");
const { abi } = JSON.parse(readFileSync("artifacts/contracts/Collections.sol/Collections.json", "utf8")) as {abi: Abi};
const encodeInt = (value: bigint) => encodeAbiParameters(parseAbiParameters("int256"), [value]);
const callback = {
  target: ops.address,
  selector: toFunctionSelector("sub(int256,int256)"),
  arguments: "(int256,int256)",
  constants: ["0x", "0x"],
  first: 0n,
  second: 1n, program: "0x",
};
for (const length of [1, 4, 16]) {
  const values = Array.from({length}, (_, i) => encodeInt(BigInt(length - i)));
  const samples = [
    {functionName: "packArray", args: ["int256", values]},
    {functionName: "sortValues", args: ["int256", values, callback]},
    {functionName: "foldValues", args: ["int256", "int256", values, encodeInt(0n), {...callback, selector: toFunctionSelector("add(int256,int256)")}]},
  ];
  for (const sample of samples) {
    const data = encodeFunctionData({abi, ...sample});
    const gas = await publicClient.estimateGas({to: collections.address, data});
    console.log(`collection-gas ${sample.functionName} length=${length}: ${gas}`);
  }
}
