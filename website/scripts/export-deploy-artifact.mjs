#!/usr/bin/env node
// Exports the compiled creation bytecode (plus the CREATE2 deployment
// constants) of the Assertions core and its periphery contracts into
// committed modules, so the website can deploy them to their canonical
// addresses on any chain without needing the gitignored Hardhat artifacts at
// build time, and writes src/lib/deployments.json: the one manifest (names,
// versions, release status, addresses, salts, hashes, sizes, measured gas and
// prior releases) that every website consumer and check:integration read.
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
    // Vanity salt for the 2.0 core release; earlier candidates under
    // previous salts are listed in HISTORY.
    salt: "0xe650e74e2e7870dc5dde1aa4f797df9a7f83aa15758fe8716a281fbeca1db52e",
    expectedAddress: "0xA55E47Df0739353DFd7a914d65d935624F88A45d",
    prefix: "ASSERTIONS",
    description: "Assertions core contract",
    includeProxyConstants: true,
  },
  {
    name: "Operations",
    key: "operators",
    version: "1.0",
    released: true,
    sdkAddressExport: "OPERATIONS_ADDRESS",
    artifact: "artifacts/contracts/Operations.sol/Operations.json",
    output: "src/lib/operations-deployment.ts",
    // Vanity salt for the 1.0 release; earlier candidates are listed in HISTORY.
    salt: "0x4bf30c2a9855e5bea0f62bc18f30addde025b45cb19b6f71a137c0578d7c9ee3",
    expectedAddress: "0x09e4A7eD11DeF3e3b98d9bB70995043cb51766CE",
    prefix: "OPERATIONS",
    description: "Operations plain-value vocabulary contract",
    includeProxyConstants: false,
  },
  {
    name: "Collections",
    key: "collections",
    version: "1.0",
    released: true,
    sdkAddressExport: "COLLECTIONS_ADDRESS",
    artifact: "artifacts/contracts/Collections.sol/Collections.json",
    output: "src/lib/collections-deployment.ts",
    // Vanity salt after removing the standalone validator. The callback
    // interface is local, so Expressions source edits do not move this address.
    salt: "0xb03362ee27179486e28877486ea6b09c2381fe4cecfaadbc0a6b535bd5ded106",
    expectedAddress: "0xc011EC7840D287b6b7Ccbad6E8Ef7D7C8411Ca19",
    prefix: "COLLECTIONS",
    description: "generic ABI collection vocabulary contract",
    includeProxyConstants: false,
  },
  {
    name: "Expressions",
    key: "expressions",
    version: "1.0",
    released: true,
    sdkAddressExport: "EXPRESSIONS_ADDRESS",
    artifact: "artifacts/contracts/Expressions.sol/Expressions.json",
    output: "src/lib/expressions-deployment.ts",
    // Vanity salt after declaring the core interface and probe errors locally.
    salt: "0xeefe23c619f31d6de8c3a62108e5521a6fa693f3b96c97459113a89e543728b8",
    expectedAddress: "0xe5594E555895542163715a3348B379976Acdfc81",
    prefix: "EXPRESSIONS",
    description: "typed expression graphs contract",
    includeProxyConstants: false,
  },
];

// Prior releases and retired artifact candidates, hand-maintained here and
// nowhere else: the docs render them from the manifest, and check:integration
// rejects any address in the docs that is neither current nor listed here.
// "Combinators" is the periphery's pre-Operations name. Released rows stay
// live forever at their addresses; retired candidates were never canonical.
const ZERO_SALT = `0x${"00".repeat(32)}`;
const HISTORY = [
  {
    name: "Expressions",
    version: "1.0",
    address: "0xe5594E55E0fc24a271CA6bf55070a6bE63Cc43d8",
    salt: "0xa393cf61cfa5031ede52d2b820e3910ffe0d820bda97edb15ac7bfe16b8f5408",
    note: "previous artifact importing the core implementation rather than its local interface",
  },
  {
    name: "Assertions",
    version: "2.0",
    address: "0xa55E477cF2a24506317f0B2555e8B443522CBBf0",
    salt: "0x2e823aea45fadbba8356058dc60720447148149212e2deae10ecab2c431a95fc",
    note: "previous core artifact before whole static array and tuple lenses",
  },
  {
    name: "Collections",
    version: "1.0",
    address: "0xC011EC7e97deC05655D3d169e44aB87217996b19",
    salt: "0xda9eb39c5aa9ec9ed00a2c5d22a805adf131862ea9de1d3491ce0a3c5c26298f",
    note: "previous artifact with the standalone validator and an Expressions source import",
  },
  {
    name: "Assertions",
    version: "1.0",
    address: "0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F",
    salt: "0xea760d182a298325dc178401b3f5298c30f1bf94f8d5f42ec27c43b2b826e7cb",
    note: "original v1.0 core, reachable as assertions.eth",
  },
  {
    name: "Assertions",
    version: "1.1",
    address: "0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0",
    salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f6012c7cd0",
    note: "typed-assert core (140 assertEq*/assertGte* functions)",
  },
  {
    name: "Combinators",
    version: "1.0",
    address: "0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC",
    salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f60027fbe3",
    note: "periphery of the v1.1 core",
  },
  {
    name: "Assertions",
    version: "2.0-rc",
    address: "0xa55E47F37088b6D0212BdfD56b175ec08744DB19",
    salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f601469a3b",
    note: "ERC-8211 release candidate core",
  },
  {
    name: "Combinators",
    version: "2.0-rc",
    address: "0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9",
    salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f6031de88b",
    note: "periphery of the 2.0-rc core",
  },
  {
    name: "Assertions",
    version: "2.0",
    address: "0xA01bC220Efc4c730BBcBC9ee52EE570D33EA956F",
    salt: ZERO_SALT,
    note: "interim zero-salt deployment; live wherever it was sent, no longer canonical",
  },
  {
    name: "Operations",
    version: "1.0",
    address: "0x8e832Ace3f433943eb605c258bA37AF24a69dC53",
    salt: ZERO_SALT,
    note: "interim zero-salt deployment (then named Operators); live wherever it was sent, no longer canonical",
  },
  {
    name: "Assertions",
    version: "2.0",
    address: "0x67DBB438FdC614466984Dc8F68dAB812d785a2aE",
    salt: "0xd4f532eb8a77374d9696a5bcdc01f6c4f4fa29c20ee87346ef21bab6faeae45b",
    note: "retired artifact candidate under a previous salt (the SDK pin 6513da6c still targets it)",
  },
  {
    name: "Assertions",
    version: "2.0",
    address: "0x4D710b5AaBcd7f8753307c71779904A562422A15",
    salt: "0xd4f532eb8a77374d9696a5bcdc01f6c4f4fa29c20ee87346ef21bab6faeae45b",
    note: "retired artifact candidate under a previous salt",
  },
  {
    name: "Operations",
    version: "1.0",
    address: "0x7AD80f224A8473A4206ad486e5b6b4e4367D17AD",
    salt: "0x92d34082f305b501d427bef474df394f826a347b55dba79ecfe2bfe14b998cf9",
    note: "retired artifact candidate (then named Operators; the SDK pin 6513da6c still targets it)",
  },
  {
    name: "Operations",
    version: "1.0",
    address: "0x09E4A7E3072F075C2786BE9FA0B7c4BA6591AE9e",
    salt: "0x9ce558a766c6d9bb00fbc5b8d2d832c52994462655f328c0caf5f60f5f977f08",
    note: "retired artifact candidate under a previous salt",
  },
  {
    name: "Collections",
    version: "1.0",
    address: "0xc6D85B72bdF8040f61f4CD7957c7aa8e5f30a47f",
    salt: "0x4e34588f9111fbc67be34b0750e14b151b4657e6f4391c414ed7268bba4d214a",
    note: "retired artifact candidate under a previous salt (moved by the Expressions Select fix it imports)",
  },
  {
    name: "Expressions",
    version: "1.0",
    address: "0xc45C579021623712eE3f61D066a24218F6e01E22",
    salt: "0xc13ea26db51cabdbbd8c2a00c76d722f95b02034f61f5481dfcb487658f14939",
    note: "retired artifact candidate under a previous salt (Select judged an exact 0/1 word)",
  },
  {
    name: "Assertions",
    version: "2.0",
    address: "0x94b07F5364b54471b065Ee74150864628Df722d7",
    salt: "0xd4f532eb8a77374d9696a5bcdc01f6c4f4fa29c20ee87346ef21bab6faeae45b",
    note: "retired artifact candidate under a previous salt (moved by readArgs and the dynamic-terminal re-encoding; the SDK pin 3f02b3aa targets it)",
  },
  {
    name: "Operations",
    version: "1.0",
    address: "0x314e75BEFDb0f3e0621f68458f98Fce75246f7a7",
    salt: "0x9ce558a766c6d9bb00fbc5b8d2d832c52994462655f328c0caf5f60f5f977f08",
    note: "retired artifact candidate under a previous salt (moved by the shared AbiCodec changes it imports)",
  },
  {
    name: "Collections",
    version: "1.0",
    address: "0x830a490449eC148CE4404e398eC7FA9903Ce5Bc2",
    salt: "0x4e34588f9111fbc67be34b0750e14b151b4657e6f4391c414ed7268bba4d214a",
    note: "retired artifact candidate under a previous salt (moved by the Expressions and AbiCodec changes it imports)",
  },
  {
    name: "Expressions",
    version: "1.0",
    address: "0x03B82019Ed1802172606922e8F8c8d43d0cd6d12",
    salt: "0xc13ea26db51cabdbbd8c2a00c76d722f95b02034f61f5481dfcb487658f14939",
    note: "retired artifact candidate under a previous salt (Select now judges truth like the core's cond)",
  },
  {
    name: "Assertions",
    version: "2.0",
    address: "0xf601f42D6752dB5423efE6e5c16044d275F06aC2",
    salt: "0xd4f532eb8a77374d9696a5bcdc01f6c4f4fa29c20ee87346ef21bab6faeae45b",
    note: "retired artifact candidate under a previous salt (readArgs became get, gather joined the core, assertComposable became assertBatch; the SDK pin a36faaec targets it)",
  },
  {
    name: "Operations",
    version: "1.0",
    address: "0xe3F9CCD4f6A11a044533055B9581765EB845AbB3",
    salt: "0x9ce558a766c6d9bb00fbc5b8d2d832c52994462655f328c0caf5f60f5f977f08",
    note: "retired artifact candidate under a previous salt (moved by the AbiCodec changes it imports)",
  },
  {
    name: "Collections",
    version: "1.0",
    address: "0x9647762c87a5Ff7a378c4a4752D23b88E5302e3B",
    salt: "0x4e34588f9111fbc67be34b0750e14b151b4657e6f4391c414ed7268bba4d214a",
    note: "retired artifact candidate under a previous salt (moved by the Expressions and AbiCodec changes it imports)",
  },
  {
    name: "Expressions",
    version: "1.0",
    address: "0xb3cC9B9821b990B7c7EAe4934555d04c273Ce487",
    salt: "0xc13ea26db51cabdbbd8c2a00c76d722f95b02034f61f5481dfcb487658f14939",
    note: "retired artifact candidate under a previous salt (the resolve-once entry points moved to the core as get and gather)",
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
