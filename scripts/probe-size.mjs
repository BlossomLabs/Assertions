// Size probe: compile contracts/ with one solc settings variant and print
// deployed sizes, optionally with per-function attribution from functionDebugData.
// Usage: node probe-size.mjs [--viaIR] [--runs N] [--nocbor] [--strip] [--steps SEQ]
//        [--attr CONTRACT] [--contracts DIR] [--merged NAME] [--json]
import { execFileSync } from "node:child_process";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const args = process.argv.slice(2);
const flag = (name) => args.includes(name);
const opt = (name, fallback) => { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : fallback; };

const dir = opt("--contracts", "contracts");
const runs = Number(opt("--runs", "200"));
const viaIR = flag("--viaIR");
const attr = opt("--attr", null);
const solc = process.env.SOLC ?? "/home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791";

const sources = Object.fromEntries(readdirSync(dir)
  .filter(name => name.endsWith(".sol"))
  .map(name => [`contracts/${name}`, { content: readFileSync(join(dir, name), "utf8") }]));
// Merged probe: only while Operators and CollectionOperators are separate contracts.
// Once Operators inherits CollectionOperators it is the merged periphery itself.
const hasCollections = "contracts/CollectionOperators.sol" in sources;
const alreadyMerged = /contract Operators is CollectionOperators/.test(sources["contracts/Operators.sol"]?.content ?? "");
if (hasCollections && !alreadyMerged && !flag("--nomerge")) {
  sources["contracts/MergedOperatorsProbe.sol"] = { content: `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operators} from "./Operators.sol";
import {CollectionOperators} from "./CollectionOperators.sol";
contract MergedOperatorsProbe is Operators, CollectionOperators {}` };
}

const settings = {
  optimizer: { enabled: true, runs },
  viaIR,
  evmVersion: opt("--evm", "cancun"),
  outputSelection: { "*": { "*": ["evm.deployedBytecode.object", "evm.deployedBytecode.functionDebugData"] } },
};
if (flag("--nocbor")) settings.metadata = { bytecodeHash: "none", appendCBOR: false };
if (flag("--strip")) settings.debug = { revertStrings: "strip" };
const steps = opt("--steps", null);
if (steps) settings.optimizer.details = { yul: true, yulDetails: { stackAllocation: true, optimizerSteps: steps } };

const input = { language: "Solidity", sources, settings };
const result = JSON.parse(execFileSync(solc, ["--standard-json"], {
  input: JSON.stringify(input), encoding: "utf8", maxBuffer: 64 * 1024 * 1024,
}));
const errors = result.errors?.filter(e => e.severity === "error");
if (errors?.length) { console.error(errors.map(e => e.formattedMessage).join("\n")); process.exit(1); }

const names = ["Assertions", "Operators", "CollectionOperators", "MergedOperatorsProbe"];
const sizes = {};
for (const name of names) {
  const c = result.contracts[`contracts/${name}.sol`]?.[name];
  if (c) sizes[name] = c.evm.deployedBytecode.object.length / 2;
}
const label = `viaIR=${viaIR} runs=${runs}${flag("--nocbor") ? " nocbor" : ""}${flag("--strip") ? " strip" : ""}${steps ? " steps=" + steps : ""}`;
if (flag("--json")) console.log(JSON.stringify({ label, sizes }));
else console.log(label.padEnd(40), Object.entries(sizes).map(([k, v]) => `${k}=${v}`).join("  "));

if (attr) {
  const c = result.contracts[`contracts/${attr}.sol`][attr];
  const dbg = c.evm.deployedBytecode.functionDebugData ?? {};
  const total = c.evm.deployedBytecode.object.length / 2;
  const entries = Object.entries(dbg)
    .filter(([, d]) => typeof d.entryPoint === "number")
    .map(([name, d]) => ({ name, entry: d.entryPoint }))
    .sort((a, b) => a.entry - b.entry);
  for (let i = 0; i < entries.length; i++) {
    entries[i].size = (i + 1 < entries.length ? entries[i + 1].entry : total) - entries[i].entry;
  }
  const first = entries.length ? entries[0].entry : total;
  console.log(`\n# ${attr}: ${total} bytes; dispatcher/prelude ${first} bytes; ${entries.length} functions`);
  const groups = new Map();
  for (const e of entries) {
    // Group by a coarse prefix so generated helpers cluster.
    const m = e.name.match(/^(abi_decode|abi_encode|external_fun|fun|checked|panic|revert|copy|allocate|array|cleanup|validator|finalize|round|shift|calldata|memory|require|convert|read|write|store|extract|increment|decrement|wrapping|mod|leftAlign|zero|update|access|cleanup|shift)/);
    const g = m ? m[1] : e.name.split("_")[0];
    groups.set(g, (groups.get(g) ?? 0) + e.size);
  }
  console.log("## by group");
  for (const [g, s] of [...groups].sort((a, b) => b[1] - a[1])) console.log(`${String(s).padStart(6)}  ${g}`);
  console.log("## top functions");
  for (const e of [...entries].sort((a, b) => b.size - a.size).slice(0, Number(opt("--top", "60")))) {
    console.log(`${String(e.size).padStart(6)}  ${e.name}`);
  }
}
