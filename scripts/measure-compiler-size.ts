// Compile size probes without modifying production configuration or sources.
// SOLC=/path/to/solc-0.8.36 pnpm hardhat run scripts/measure-compiler-size.ts
import { execFileSync } from "node:child_process";
import { readFileSync, readdirSync } from "node:fs";

const sources = Object.fromEntries(readdirSync("contracts")
  .filter(name => name.endsWith(".sol"))
  .map(name => [`contracts/${name}`, { content: readFileSync(`contracts/${name}`, "utf8") }]));
for (const [name, parent] of [["MergedOperationsProbe", "Operations"], ["CoreWithCollectionsProbe", "Assertions"]]) {
  sources[`contracts/${name}.sol`] = { content: `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {${parent}} from "./${parent}.sol";
import {Collections} from "./Collections.sol";
contract ${name} is ${parent}, Collections {}` };
}
for (const viaIR of [false, true]) {
  for (const runs of [1, 50, 200]) {
    const input = { language: "Solidity", sources, settings: {
      optimizer: { enabled: true, runs }, viaIR, evmVersion: "cancun",
      outputSelection: { "*": { "*": ["evm.deployedBytecode.object"] } },
    } };
    const result = JSON.parse(execFileSync(process.env.SOLC ?? "solc", ["--standard-json"], {
      input: JSON.stringify(input), encoding: "utf8", maxBuffer: 16 * 1024 * 1024,
    }));
    const errors = result.errors?.filter((e: {severity: string}) => e.severity === "error");
    if (errors?.length) throw new Error(JSON.stringify(errors));
    const sizes = Object.fromEntries(["Assertions", "Operations", "Collections", "MergedOperationsProbe", "CoreWithCollectionsProbe"]
      .map(name => [name, result.contracts[`contracts/${name}.sol`][name].evm.deployedBytecode.object.length / 2]));
    console.log(JSON.stringify({ viaIR, runs, sizes }));
  }
}
