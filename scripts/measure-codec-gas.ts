// Transaction gas, including calldata/intrinsic costs. Optional baseline runtime
// enables a same-input comparison: OPERATORS_BASELINE_RUNTIME=/path/to/runtime.hex
// pnpm hardhat run scripts/measure-codec-gas.ts
import { readFileSync } from "node:fs";
import { network } from "hardhat";
import { encodeAbiParameters, encodeFunctionData, parseAbiParameters, type Hex } from "viem";

const { viem } = await network.connect("hardhatMainnet");
const client = await viem.getPublicClient();
const ops = await viem.deployContract("Operators");
const targets: [string, `0x${string}`][] = [["current", ops.address]];
if (process.env.OPERATORS_BASELINE_RUNTIME) {
  const baseline = "0x000000000000000000000000000000000000beef" as const;
  const code = readFileSync(process.env.OPERATORS_BASELINE_RUNTIME, "utf8").trim() as Hex;
  await client.request({ method: "hardhat_setCode" as never, params: [baseline, code] as never });
  targets.unshift(["baseline", baseline]);
}
for (const length of [1, 4, 16]) {
  for (const type of ["uint256", "string", "string[]"]) {
    const values = Array.from({ length }, (_, i) => encodeAbiParameters(
      parseAbiParameters(type),
      [type === "uint256" ? BigInt(i) : type === "string" ? "x".repeat(33) : ["", "x".repeat(33)]],
    ));
    const data = encodeFunctionData({ abi: ops.abi, functionName: "encodeBytes", args: [`(${Array(length).fill(type).join(",")})`, values] });
    for (const [label, to] of targets) {
      console.log(`codec-gas ${label} ${type} length=${length}: ${await client.estimateGas({ to, data })}`);
    }
  }
}
