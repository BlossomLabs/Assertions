// Local EVM regression probe for the pre-publication review's LEN finding.
// Run: pnpm hardhat run scripts/probe-nav-length.ts
import assert from "node:assert/strict";
import { network } from "hardhat";
import { decodeAbiParameters, encodeAbiParameters, encodeFunctionData } from "viem";

const { viem } = await network.connect();
const core = await viem.deployContract("Assertions");
const client = await viem.getPublicClient();
const paramData = encodeAbiParameters(
  [{ type: "uint256" }, { type: "uint256" }],
  [32n, 999n],
);
for (const type of ["uint256[]", "bytes", "string"] as const) {
  // The claimed payload does not exist, so ordinary ABI decoding fails.
  assert.throws(() => decodeAbiParameters([{ type }], paramData));
  await assert.rejects(client.call({
    to: core.address,
    data: encodeFunctionData({
      abi: core.abi,
      functionName: "nav",
      args: [
        { paramType: 2, fetcherType: 0, paramData, constraints: [] },
        `(${type})`,
        [0n, -(1n << 255n)],
      ],
    }),
  }));
  console.log(`${type}: LEN rejects the missing payload`);
}
