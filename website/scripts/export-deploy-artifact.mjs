#!/usr/bin/env node
// Exports the compiled creation bytecode (plus the CREATE2 deployment
// constants) of BOTH deployed contracts — the Assertions core and the
// Combinators building blocks — into committed modules so the website can deploy
// them to their canonical addresses on any chain without needing the
// gitignored Hardhat artifacts at build time.
//
// Usage: pnpm hardhat compile (from the repo root), then from website/:
//   node scripts/export-deploy-artifact.mjs

import { execSync } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { concat, getAddress, keccak256 } from "viem";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, "..", "..");

// Arachnid deterministic-deployment-proxy: same address on every EVM chain.
// https://github.com/Arachnid/deterministic-deployment-proxy
const CREATE2_PROXY = "0x4e59b44847b379578588920cA78FbF26c0B4956C";

const PROXY_CONSTANTS = `/**
 * Arachnid deterministic-deployment-proxy. Deployed at the same address on
 * virtually every EVM chain. Sending \`salt ++ initCode\` as calldata performs
 * a CREATE2 deployment.
 * https://github.com/Arachnid/deterministic-deployment-proxy
 */
export const CREATE2_PROXY =
  "${CREATE2_PROXY}" as const;

/** One-time signer of the proxy deployment transaction. */
export const CREATE2_PROXY_DEPLOYER =
  "0x3fAB184622Dc19b6109349B94811493BF2a45362" as const;

/**
 * Presigned legacy transaction that deploys the proxy from
 * CREATE2_PROXY_DEPLOYER on any chain. Requires the deployer to hold exactly
 * gas * gasPrice = 100000 * 100 gwei = 0.01 native tokens.
 */
export const CREATE2_PROXY_DEPLOY_TX =
  "0xf8a58085174876e800830186a08080b853604580600e600039806000f350fe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222" as const;

/** Cost of the proxy deployment tx in wei (0.01 native tokens). */
export const CREATE2_PROXY_DEPLOY_COST = 10_000_000_000_000_000n;
`;

const CONTRACTS = [
  {
    name: "Assertions",
    key: "core",
    artifact: "artifacts/contracts/Assertions.sol/Assertions.json",
    output: "src/lib/assertions-deployment.ts",
    // Salt mined for the core v2.0 vanity address (see hardhat.config.ts).
    // v1.1 remains at 0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0
    // (salt 0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f6012c7cd0);
    // v1.0 remains at 0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F
    // (salt 0xea760d182a298325dc178401b3f5298c30f1bf94f8d5f42ec27c43b2b826e7cb).
    salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f600eeeda2",
    expectedAddress: "0xA55E4797c1b755183B7Aad07BFd39D3e824621f9",
    prefix: "ASSERTIONS",
    description: "Assertions core contract",
    includeProxyConstants: true,
  },
  {
    name: "Combinators",
    key: "combinators",
    artifact: "artifacts/contracts/Combinators.sol/Combinators.json",
    output: "src/lib/combinators-deployment.ts",
    // Combinators v2.0; v1.0 remains at 0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC
    // (salt 0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f60027fbe3).
    salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f6005c2ac8",
    expectedAddress: "0xA55EC06e0A82a5ed05bf08c0ff07A45d4BC2eBf8",
    prefix: "COMBINATORS",
    description: "Combinators building-block contract",
    includeProxyConstants: false,
  },
];

// Measure the real deploy gas of each contract by replaying the canonical
// Arachnid-proxy deployment on an in-process Hardhat network (see
// scripts/measure-deploy-gas.ts at the repo root). Never hardcode gas: it
// changes with every bytecode change.
const measureOutput = execSync("npx hardhat run scripts/measure-deploy-gas.ts", {
  cwd: repoRoot,
  encoding: "utf8",
  env: {
    ...process.env,
    MEASURE_DEPLOY_GAS_CONFIG: JSON.stringify(
      CONTRACTS.map((c) => ({
        name: c.name,
        artifact: c.artifact,
        salt: c.salt,
        expectedAddress: c.expectedAddress,
      })),
    ),
  },
});
const gasLine = measureOutput
  .split("\n")
  .find((line) => line.startsWith("DEPLOY_GAS_JSON "));
if (!gasLine) {
  throw new Error(
    `measure-deploy-gas.ts produced no DEPLOY_GAS_JSON line:\n${measureOutput}`,
  );
}
const deployGas = JSON.parse(gasLine.slice("DEPLOY_GAS_JSON ".length));

// Resolves the import closure of `entry` within a standard-JSON `sources`
// map, so the verification bundle only ships the files the contract needs
// (dropping unrelated sources like the test mocks from the same compile job).
function importClosure(sources, entry) {
  const closure = new Set();
  const queue = [entry];
  while (queue.length > 0) {
    const name = queue.pop();
    if (closure.has(name)) continue;
    const source = sources[name];
    if (!source) throw new Error(`Source ${name} missing from build info`);
    closure.add(name);
    const importRe = /import\s[^;]*?["']([^"']+)["']\s*;/g;
    for (const [, path] of source.content.matchAll(importRe)) {
      if (!path.startsWith(".")) {
        queue.push(path);
        continue;
      }
      const base = name.split("/").slice(0, -1);
      for (const segment of path.split("/")) {
        if (segment === "." || segment === "") continue;
        else if (segment === "..") base.pop();
        else base.push(segment);
      }
      queue.push(base.join("/"));
    }
  }
  return Object.fromEntries(
    Object.entries(sources).filter(([name]) => closure.has(name)),
  );
}

const verificationInputs = [];

for (const c of CONTRACTS) {
  const artifactPath = join(repoRoot, c.artifact);
  const artifact = JSON.parse(readFileSync(artifactPath, "utf8"));
  const creationBytecode = artifact.bytecode;

  if (
    typeof creationBytecode !== "string" ||
    !creationBytecode.startsWith("0x")
  ) {
    throw new Error(`Invalid bytecode in artifact at ${artifactPath}`);
  }

  // Sanity check: the CREATE2 math must reproduce the canonical address, or
  // the compiled bytecode no longer matches the deployed contract.
  const initCodeHash = keccak256(creationBytecode);
  const predicted = getAddress(
    `0x${keccak256(concat(["0xff", CREATE2_PROXY, c.salt, initCodeHash])).slice(26)}`,
  );
  if (predicted !== c.expectedAddress) {
    throw new Error(
      `CREATE2 address mismatch for ${c.name}: compiled bytecode predicts ` +
        `${predicted}, expected ${c.expectedAddress}. The local artifact ` +
        `differs from the deployed contract — do not export it.`,
    );
  }

  const output = `// Generated by scripts/export-deploy-artifact.mjs — do not edit by hand.
// Contains everything needed to deploy the ${c.description} to its
// canonical address on any EVM chain via the Arachnid CREATE2 proxy.

/** Canonical deployment address of the ${c.name} contract on every chain. */
export const ${c.prefix}_ADDRESS =
  "${c.expectedAddress}" as const;

/** Salt mined for the vanity address (see hardhat.config.ts). */
export const ${c.prefix}_SALT =
  "${c.salt}" as const;

/** keccak256 of the creation bytecode. */
export const ${c.prefix}_INIT_CODE_HASH =
  "${initCodeHash}" as const;

/**
 * Gas used by the canonical Arachnid-proxy CREATE2 deployment, measured by
 * replaying it on an in-process Hardhat network at export time.
 */
export const ${c.prefix}_DEPLOY_GAS = ${deployGas[c.name]};

${c.includeProxyConstants ? `${PROXY_CONSTANTS}\n` : ""}/** Creation bytecode of the ${c.name} contract (no constructor args). */
export const ${c.prefix}_CREATION_BYTECODE =
  "${creationBytecode}" as const;
`;

  const outputPath = join(__dirname, "..", c.output);
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, output);
  console.log(
    `Exported ${((creationBytecode.length - 2) / 2 / 1024).toFixed(1)} KiB of ` +
      `${c.name} creation bytecode to ${c.output} ` +
      `(predicted address ${predicted}, deploy gas ${deployGas[c.name]}).`,
  );

  // Bundle the exact standard-JSON compiler input that produced this
  // bytecode, so the website can verify the source on any explorer without
  // depending on an existing (mainnet) verification.
  const buildInfoPath = join(
    repoRoot,
    "artifacts",
    "build-info",
    `${artifact.buildInfoId}.json`,
  );
  const buildInfo = JSON.parse(readFileSync(buildInfoPath, "utf8"));
  const entrySource = artifact.inputSourceName;
  if (!buildInfo.input.sources[entrySource]?.content.includes(`contract ${c.name}`)) {
    throw new Error(
      `Build info ${artifact.buildInfoId} does not contain ${c.name} at ${entrySource}`,
    );
  }
  verificationInputs.push({
    key: c.key,
    name: c.name,
    address: c.expectedAddress,
    contractName: `${entrySource}:${c.name}`,
    compilerVersion: `v${buildInfo.solcLongVersion}`,
    input: {
      language: buildInfo.input.language,
      sources: importClosure(buildInfo.input.sources, entrySource),
      settings: buildInfo.input.settings,
    },
  });
}

const verificationModule = `// Generated by scripts/export-deploy-artifact.mjs — do not edit by hand.
// The exact solc standard-JSON inputs that produced the canonical bytecode of
// each deployed contract, for explorer source verification on any chain.
// Import lazily (dynamic import): the embedded sources are large.

export interface VerificationInput {
  /** Fully qualified name as it appears in the standard JSON input. */
  contractName: string;
  /** Long solc version with the "v" prefix Etherscan expects. */
  compilerVersion: string;
  /** solc standard JSON input, pruned to the contract's import closure. */
  input: unknown;
}

export const VERIFICATION_INPUTS: Record<
  "core" | "combinators",
  VerificationInput
> = ${JSON.stringify(
  Object.fromEntries(
    verificationInputs.map(({ key, contractName, compilerVersion, input }) => [
      key,
      { contractName, compilerVersion, input },
    ]),
  ),
  null,
  2,
)};
`;

const verificationPath = join(__dirname, "..", "src", "lib", "verification-inputs.ts");
writeFileSync(verificationPath, verificationModule);
console.log(
  `Exported ${(verificationModule.length / 1024).toFixed(1)} KiB of ` +
    "verification inputs to src/lib/verification-inputs.ts " +
    `(${verificationInputs
      .map((v) => `${v.name}: ${Object.keys(v.input.sources).join(", ")}`)
      .join("; ")}).`,
);
