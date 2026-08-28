#!/usr/bin/env node
// Mines a CREATE2 salt for the Arachnid deterministic-deployment proxy so the
// deployed address starts with the project's vanity prefix (0xa55e... reads as
// "aSSE(rtions)"). Needed whenever a contract's bytecode changes before it has
// been published: the canonical address is derived from the exact init code,
// so a new build requires a fresh salt.
//
// PRIMARY ROUTE: Foundry's multi-threaded miner. The canonical v2.0 core and
// Operators v1.0 salts were mined this way (random 32-byte salts; the shared
// SALT_BASE convention below is retired and kept only for reproducing the
// older releases):
//   cast create2 -j 16 --deployer 0x4e59b44847b379578588920cA78FbF26c0B4956C \
//     --init-code-hash $(cast keccak <artifact .bytecode>) --starts-with a55e47
//   (Operators: --starts-with 09e4a7e, which reads "OPERATE")
// Run it a few times and pick the best-reading address, then set salt +
// expectedAddress in export-deploy-artifact.mjs.
//
// Fallback usage of this single-threaded script: pnpm hardhat compile (from
// the repo root), then from website/:
//   node scripts/mine-salt.mjs [artifactPath] [prefix]
// Defaults: the Assertions artifact and prefix "a55e47".

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { concat, getAddress, keccak256, toBytes } from "viem";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, "..", "..");

// Arachnid deterministic-deployment-proxy (same address on every EVM chain).
const CREATE2_PROXY = "0x4e59b44847b379578588920cA78FbF26c0B4956C";

// Legacy shared 28-byte base used by the pre-2.0 releases; only the low 4
// bytes were mined. The current canonical salts are full random 32-byte
// values from `cast create2` (see the header).
const SALT_BASE = "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f6";

const artifactPath = join(
  repoRoot,
  process.argv[2] ?? "artifacts/contracts/Assertions.sol/Assertions.json",
);
const prefix = (process.argv[3] ?? "a55e47").toLowerCase().replace(/^0x/, "");
if (prefix.length % 2 !== 0) {
  throw new Error(`Prefix must be a whole number of bytes, got "${prefix}"`);
}
const prefixBytes = toBytes(`0x${prefix}`);

const artifact = JSON.parse(readFileSync(artifactPath, "utf8"));
const initCodeHash = keccak256(artifact.bytecode);

// preimage = 0xff ++ proxy ++ salt ++ keccak256(initCode); the salt occupies
// bytes [21, 53) and only its final 4 bytes vary while mining.
const preimage = toBytes(
  concat(["0xff", CREATE2_PROXY, `${SALT_BASE}00000000`, initCodeHash]),
);
const COUNTER_OFFSET = 21 + 28;

console.log(`Mining salt for ${artifactPath}`);
console.log(`initCodeHash ${initCodeHash}, target prefix 0x${prefix}`);

const started = Date.now();
for (let counter = 0; counter <= 0xffffffff; counter++) {
  preimage[COUNTER_OFFSET] = counter >>> 24;
  preimage[COUNTER_OFFSET + 1] = (counter >>> 16) & 0xff;
  preimage[COUNTER_OFFSET + 2] = (counter >>> 8) & 0xff;
  preimage[COUNTER_OFFSET + 3] = counter & 0xff;

  const hash = toBytes(keccak256(preimage));
  // The address is the low 20 bytes of the hash, i.e. bytes [12, 32).
  let match = true;
  for (let i = 0; i < prefixBytes.length; i++) {
    if (hash[12 + i] !== prefixBytes[i]) {
      match = false;
      break;
    }
  }

  if (match) {
    const salt = `${SALT_BASE}${counter.toString(16).padStart(8, "0")}`;
    const address = getAddress(`0x${keccak256(preimage).slice(26)}`);
    const seconds = ((Date.now() - started) / 1000).toFixed(1);
    console.log(`Found after ${counter + 1} attempts in ${seconds}s:`);
    console.log(`  salt    ${salt}`);
    console.log(`  address ${address}`);
    process.exit(0);
  }

  if (counter !== 0 && counter % 1_000_000 === 0) {
    const rate = counter / ((Date.now() - started) / 1000);
    console.log(`  ${counter / 1e6}M attempts (${Math.round(rate / 1000)}k/s)…`);
  }
}

throw new Error("Exhausted the 4-byte counter without a match");
