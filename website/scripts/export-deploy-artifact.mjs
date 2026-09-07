#!/usr/bin/env node
// Exports the compiled creation bytecode (plus the CREATE2 deployment
// constants) of the four contracts into
// committed modules, so the website can deploy them to their canonical
// addresses on any chain without needing the gitignored Hardhat artifacts at
// build time, and writes src/lib/deployments.json: the one manifest (names,
// versions, release status, addresses, salts, hashes, sizes, measured gas and
// the prior release) that every website consumer and check:integration read.
//
// Usage: pnpm hardhat compile (from the repo root), then from website/:
//   node scripts/export-deploy-artifact.mjs [--contract Operations]

import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
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

// Salts are 32-byte values mined with `cast create2` so each address opens
// with its contract's name in hex (a55e47 ASSErT, 09e4a7e OPERATE, c011ec7
// COLLECT, e5594e55 EXPRESS with the unrepresentable X dropped); see mine-salt.mjs for the command. A
// contract is `released` when the SDK targets it: `sdkAddressExport` names the
// constant in packages/sdk/src/onchain/addresses.ts that must equal its
// address (check:integration asserts it). An unreleased contract is exported
// and deployable but has no SDK consumer yet.
const CONTRACTS = [
  {
    name: "Assertions",
    key: "core",
    version: "2.0",
    released: true,
    sdkAddressExport: "CORE_ADDRESS",
    artifact: "artifacts/contracts/Assertions.sol/Assertions.json",
    output: "src/lib/assertions-deployment.ts",
    // Vanity salt for the 2.0 release.
    salt: "0x815b54312580b32036bde3218abe63b49e46ba9773ae5b4bdd089288679c811c",
    expectedAddress: "0xA55e47F41968c49e084955524fA77c1B2ef2B638",
    prefix: "ASSERTIONS",
    description: "Assertions core contract",
    includeProxyConstants: true,
  },
  {
    name: "Operations",
    key: "operators",
    version: "2.0",
    released: true,
    sdkAddressExport: "OPERATIONS_ADDRESS",
    artifact: "artifacts/contracts/Operations.sol/Operations.json",
    output: "src/lib/operations-deployment.ts",
    // Vanity salt for the 2.0 release.
    salt: "0x4b123c4d7b7581d183be92a28c56b467d37f1cde8a08a5cab6518e939c9555af",
    expectedAddress: "0x09E4A7Ef72b44d3E16466Ca3517Af567eA7D8aDA",
    prefix: "OPERATIONS",
    description: "Operations plain-value vocabulary contract",
    includeProxyConstants: false,
  },
  {
    name: "Collections",
    key: "collections",
    version: "2.0",
    released: true,
    sdkAddressExport: "COLLECTIONS_ADDRESS",
    artifact: "artifacts/contracts/Collections.sol/Collections.json",
    output: "src/lib/collections-deployment.ts",
    // Vanity salt for the 2.0 release. The callback interface is local, so
    // Expressions source edits do not move this address.
    salt: "0xd05e880804757a5f5a4dad693f62ebb488cda0f5ef2a4cc2757d2963e8ca6eaf",
    expectedAddress: "0xC011ec718c89903c3c5348837877f0FFCa67B500",
    prefix: "COLLECTIONS",
    description: "generic ABI collection vocabulary contract",
    includeProxyConstants: false,
  },
  {
    name: "Expressions",
    key: "expressions",
    version: "2.0",
    released: true,
    sdkAddressExport: "EXPRESSIONS_ADDRESS",
    artifact: "artifacts/contracts/Expressions.sol/Expressions.json",
    output: "src/lib/expressions-deployment.ts",
    // Vanity salt for the 2.0 release. The core interface is local, so core
    // source edits do not move this address.
    salt: "0xae9e0eb2baca8771e7389dc50d7111b19293e3e0470e559a8f9438abf5af37d7",
    expectedAddress: "0xE5594e551FA2209A28386418AAb971983A874029",
    prefix: "EXPRESSIONS",
    description: "typed expression graphs contract",
    includeProxyConstants: false,
  },
];

// The only prior release that was ever deployed publicly. Hand-maintained here
// and nowhere else: the docs render it from the manifest, and check:integration
// rejects any address in the docs that is neither current nor listed here.
// Artifact candidates from development are deliberately NOT kept: they were
// never deployed, never canonical, and listing them invited the reading that a
// candidate address meant something. An address is a function of the bytecode;
// when the bytecode moves, the old address simply has no code.
const HISTORY = [
  {
    name: "Assertions",
    version: "1.0",
    address: "0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F",
    salt: "0xea760d182a298325dc178401b3f5298c30f1bf94f8d5f42ec27c43b2b826e7cb",
    note: "original v1.0 core, live on mainnet and reachable as assertions.eth",
  },
];

// A periphery update can be exported independently of other artifact candidates.
const args = process.argv.slice(2);
if (
  args.length &&
  (args.length !== 2 || args[0] !== "--contract" || !CONTRACTS.some((c) => c.name === args[1]))
) {
  throw new Error("Usage: export-deploy-artifact.mjs [--contract Assertions|Operations|Collections|Expressions]");
}
const selectedContracts = args.length
  ? CONTRACTS.filter((c) => c.name === args[1])
  : CONTRACTS;
const manifestPath = join(__dirname, "..", "src", "lib", "deployments.json");
let previousVerificationInputs = {};
let previousManifest = null;
if (args.length) {
  const previous = readFileSync(join(__dirname, "..", "src/lib/verification-inputs.ts"), "utf8");
  const match = previous.match(/>\s*=\s*(\{[\s\S]*\});\s*$/);
  if (!match) throw new Error("Cannot preserve existing verification inputs; run a full export first");
  previousVerificationInputs = JSON.parse(match[1]);
  if (!existsSync(manifestPath)) {
    throw new Error("Cannot merge into src/lib/deployments.json; run a full export first");
  }
  previousManifest = JSON.parse(readFileSync(manifestPath, "utf8"));
}

// Predict every selected address before measuring anything: the CREATE2 math
// must reproduce the canonical address, or the compiled bytecode no longer
// matches the deployed contract. A refusal lists every predicted address so a
// deliberate re-export can copy them into CONTRACTS (and move the retired
// ones into HISTORY) in one step.
const loaded = selectedContracts.map((c) => {
  const artifactPath = join(repoRoot, c.artifact);
  const artifact = JSON.parse(readFileSync(artifactPath, "utf8"));
  const creationBytecode = artifact.bytecode;
  if (typeof creationBytecode !== "string" || !creationBytecode.startsWith("0x")) {
    throw new Error(`Invalid bytecode in artifact at ${artifactPath}`);
  }
  const runtimeBytes = (artifact.deployedBytecode.length - 2) / 2;
  if (runtimeBytes > 24_576) throw new Error(`${c.name} exceeds the EVM runtime size limit: ${runtimeBytes}`);
  const initCodeHash = keccak256(creationBytecode);
  const predicted = getAddress(
    `0x${keccak256(concat(["0xff", CREATE2_PROXY, c.salt, initCodeHash])).slice(26)}`,
  );
  return { ...c, artifact, creationBytecode, runtimeBytes, initCodeHash, predicted };
});
const mismatches = loaded.filter((c) => c.predicted !== c.expectedAddress);
if (mismatches.length) {
  throw new Error(
    "CREATE2 address mismatch: the local artifact differs from the deployed contract, do not export it.\n" +
      mismatches
        .map((c) => `  ${c.name}: compiled bytecode predicts ${c.predicted}, expected ${c.expectedAddress}`)
        .join("\n") +
      "\nIf the change is deliberate, copy the predicted addresses into CONTRACTS and move the retired ones into HISTORY.",
  );
}

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
      selectedContracts.map((c) => ({
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
const manifestContracts = [];
let compiler = null;

for (const c of loaded) {
  const { artifact, creationBytecode, runtimeBytes, initCodeHash, predicted } = c;

  const output = `// Generated by scripts/export-deploy-artifact.mjs, do not edit by hand.
// Contains everything needed to deploy the ${c.description} to its
// canonical address on any EVM chain via the Arachnid CREATE2 proxy.

/** Canonical deployment address of the ${c.name} contract on every chain. */
export const ${c.prefix}_ADDRESS =
  "${c.expectedAddress}" as const;

/** Canonical CREATE2 salt (see scripts/export-deploy-artifact.mjs). */
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
  const abiPath = outputPath.replace("-deployment.ts", "-abi.ts");
  writeFileSync(abiPath, `// Generated by scripts/export-deploy-artifact.mjs, do not edit by hand.\nexport const ${c.prefix}_ABI = ${JSON.stringify(artifact.abi, null, 2)} as const;\n`);
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

  // The manifest's compiler block comes from the build info, never from
  // hardhat.config.ts by hand; every exported contract must share it.
  const settings = buildInfo.input.settings;
  const contractCompiler = {
    solcLongVersion: buildInfo.solcLongVersion,
    evmVersion: settings.evmVersion,
    optimizer: { enabled: settings.optimizer.enabled, runs: settings.optimizer.runs },
    // solc's default when the settings carry no metadata block.
    bytecodeHash: settings.metadata?.bytecodeHash ?? "ipfs",
  };
  if (compiler && JSON.stringify(compiler) !== JSON.stringify(contractCompiler)) {
    throw new Error(`${c.name} was compiled with different settings than the other exported contracts`);
  }
  compiler = contractCompiler;
  manifestContracts.push({
    name: c.name,
    key: c.key,
    version: c.version,
    released: c.released,
    address: c.expectedAddress,
    salt: c.salt,
    initCodeHash,
    runtimeHash: keccak256(artifact.deployedBytecode),
    runtimeBytes,
    deployGas: deployGas[c.name],
    prefix: c.prefix,
    sdkAddressExport: c.sdkAddressExport,
    deploymentModule: c.output,
    abiModule: c.output.replace("-deployment.ts", "-abi.ts"),
    description: c.description,
  });
}

const verificationModule = `// Generated by scripts/export-deploy-artifact.mjs, do not edit by hand.
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
  ${CONTRACTS.map((c) => JSON.stringify(c.key)).join(" | ")},
  VerificationInput
> = ${JSON.stringify(
  {
    ...previousVerificationInputs,
    ...Object.fromEntries(
      verificationInputs.map(({ key, contractName, compilerVersion, input }) => [
        key,
        { contractName, compilerVersion, input },
      ]),
    ),
  },
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

// The manifest: one row per CONTRACTS entry in that order. A --contract run
// merges its fresh row into the previous manifest, the way the verification
// inputs merge above; HISTORY is always rewritten from this script.
const contracts = CONTRACTS.map((c) => {
  const fresh = manifestContracts.find((m) => m.name === c.name);
  if (fresh) return fresh;
  const previous = previousManifest?.contracts.find((m) => m.name === c.name);
  if (!previous) throw new Error(`No previous manifest entry for ${c.name}; run a full export first`);
  return previous;
});
if (previousManifest && JSON.stringify(previousManifest.compiler) !== JSON.stringify(compiler)) {
  throw new Error("Compiler settings changed since the previous manifest; run a full export");
}
const manifest = {
  generatedBy: "scripts/export-deploy-artifact.mjs",
  create2Proxy: CREATE2_PROXY,
  compiler,
  contracts,
  history: HISTORY,
};
writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(
  `Wrote src/lib/deployments.json (${contracts.length} contracts, ${HISTORY.length} history rows; ` +
    `${contracts.map((c) => `${c.name} ${c.address}${c.released ? "" : " unreleased"}`).join(", ")}).`,
);
