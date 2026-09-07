// Exercise the builder against the same source aliases as the website build.
// No RPC, wallet, or external service is used.
//
// The deployment half reads src/lib/deployments.json (written by
// scripts/export-deploy-artifact.mjs) and checks that the compiled artifacts,
// the generated deployment modules, the vendored SDK's pinned addresses and
// its EVM test fixture all agree with it. The SDK's addresses.ts cannot
// import a website file and stays hand-pinned; this is the only guard that
// pin, fixture, artifacts and manifest agree.
import assert from "node:assert/strict";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { createRequire } from "node:module";
import { join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { getContractAddress, keccak256 } from "viem";

process.chdir(fileURLToPath(new URL("..", import.meta.url)));
const require = createRequire(import.meta.url);
const astroRequire = createRequire(require.resolve("astro/package.json"));
const { createServer } = await import(astroRequire.resolve("vite"));
const { evmcrisprSrc, local } = await import("./evmcrispr-sources.mjs");
const server = await createServer({
  configFile: false,
  resolve: { alias: local.alias },
  server: { middlewareMode: true, watch: null, hmr: false, ws: false },
  optimizeDeps: { noDiscovery: true, include: [] },
});

const manifest = JSON.parse(readFileSync("src/lib/deployments.json", "utf8"));

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) walk(path, out);
    else if (/\.mdx?$/.test(entry)) out.push(path);
  }
  return out;
}

try {
  const load = (path) => server.ssrLoadModule(path);
  const { evml } = await load("/src/components/builder/evml.ts");
  const { buildAssertionLine } = await load("/src/components/builder/assertion-codegen.ts");
  const { compileAssertionLine } = await load("/src/components/builder/compile-adapter.ts");
  const { HELPER_OWNER, REGISTRIES } = await load("/src/components/builder/helper-owners.ts");
  const { wrapEntriesFor } = await load("/src/components/builder/expr/catalog.ts");
  const sdk = await load("@evmcrispr/sdk/onchain");
  const fixtures = await load(`${evmcrisprSrc}/packages/test-utils/src/onchain/assertions-bytecode.ts`);
  const core = await load("/src/lib/assertions-deployment.ts");
  assert.equal(core.CREATE2_PROXY, manifest.create2Proxy, "manifest proxy drift");

  for (const contract of manifest.contracts) {
    const { name, prefix } = contract;
    const exports = await load(`/${contract.deploymentModule}`);
    const artifact = JSON.parse(readFileSync(`../artifacts/contracts/${name}.sol/${name}.json`, "utf8"));
    const runtimeHash = keccak256(artifact.deployedBytecode);
    const size = (artifact.deployedBytecode.length - 2) / 2;
    assert.equal(contract.runtimeHash, runtimeHash, `${name}: stale manifest runtime hash; run pnpm sync:artifact`);
    assert.equal(contract.runtimeBytes, size, `${name}: stale manifest runtime size`);
    assert.equal(contract.initCodeHash, keccak256(artifact.bytecode), `${name}: stale manifest init-code hash`);
    assert.equal(
      getContractAddress({ from: manifest.create2Proxy, opcode: "CREATE2", salt: contract.salt, bytecode: artifact.bytecode }),
      contract.address,
      `${name}: the compiled bytecode does not reproduce the manifest address`,
    );
    assert.equal(exports[`${prefix}_ADDRESS`], contract.address, `${name}: deployment module address drift`);
    assert.equal(exports[`${prefix}_SALT`], contract.salt, `${name}: deployment module salt drift`);
    assert.equal(exports[`${prefix}_CREATION_BYTECODE`], artifact.bytecode, `${name}: stale deployment bytecode`);
    assert.ok(size <= 24576, `${name}: EIP-170 limit exceeded`);
    if (contract.released) {
      assert.equal(sdk[contract.sdkAddressExport], contract.address, `${name}: compiler address drift (${contract.sdkAddressExport})`);
      assert.equal(fixtures[`${prefix}_RUNTIME_HASH`], runtimeHash, `${name}: stale EVM test fixture`);
      assert.equal(fixtures[`${prefix}_RUNTIME_BYTECODE`], artifact.deployedBytecode, `${name}: stale EVM test fixture bytecode`);
    }
    console.log(
      `${name}: ${size} runtime bytes; manifest, artifact and deployment module agree` +
        (contract.released ? "; SDK and fixture agree" : " (unreleased: no SDK or fixture check)"),
    );
  }

  const { DEPLOYED_CONTRACTS, RELEASED_CONTRACTS } = await load("/src/components/deployments/shared.ts");
  assert.deepEqual(DEPLOYED_CONTRACTS.map((contract) => contract.name), manifest.contracts.map((contract) => contract.name));
  const released = manifest.contracts.filter((contract) => contract.released);
  assert.deepEqual(RELEASED_CONTRACTS.map((contract) => contract.name), released.map((contract) => contract.name));
  assert.deepEqual(RELEASED_CONTRACTS.map((contract) => contract.address), released.map((contract) => sdk[contract.sdkAddressExport]));

  // Every address the docs print must be one the manifest knows (current,
  // history, or the proxy and its deployer), and only the pages that document
  // history may carry a retired one. README.md must list every current
  // address. The docs/*.md records and the vendored checkout are not scanned.
  const current = new Set(manifest.contracts.map((contract) => contract.address.toLowerCase()));
  const known = new Set([
    ...current,
    ...manifest.history.map((row) => row.address.toLowerCase()),
    manifest.create2Proxy.toLowerCase(),
    core.CREATE2_PROXY_DEPLOYER.toLowerCase(),
  ]);
  const historyAllowed = new Set([
    "README.md",
    "hardhat.config.ts",
    "website/src/content/docs/docs/index.md",
    "website/src/content/docs/docs/reference/deployments.mdx",
  ]);
  const scanned = ["../README.md", "../hardhat.config.ts", ...walk("src/content/docs/docs")];
  const violations = [];
  for (const file of scanned) {
    const label = relative("..", file);
    const text = readFileSync(file, "utf8");
    for (const [address] of text.matchAll(/\b0x[0-9a-fA-F]{40}\b/g)) {
      const lower = address.toLowerCase();
      if (!known.has(lower)) violations.push(`${label}: ${address} is neither a current address nor in the manifest's history`);
      else if (!current.has(lower) && !historyAllowed.has(label)) violations.push(`${label}: ${address} is retired; only current addresses belong here`);
    }
  }
  const readme = readFileSync("../README.md", "utf8");
  for (const contract of manifest.contracts) {
    if (!readme.includes(contract.address)) violations.push(`README.md: missing the current ${contract.name} address ${contract.address}`);
  }
  assert.equal(violations.length, 0, `docs address scan:\n${violations.join("\n")}`);
  console.log(`Docs: ${scanned.length} files carry only manifest addresses; README lists every current one`);

  const target = "0x0000000000000000000000000000000000000001";
  const tag = evml.with({ chainId: 1, account: target });
  const snippets = [
    `load contracts\nassert @codeHash!(${target}) != 0x${"00".repeat(32)}`,
    "load receipts\nassert @chainId! == 1",
    `load lang\nassert @len!(${target}::{values()(uint256[])}) > 0`,
    `assert @hash!(${target}::{name()(string)}) == @hash("Assertions")`,
    `load lang\nassert @bytes.len!(${target}::{data()(bytes)}) >= 32`,
    `load math\nassert @sqrt!(${target}::{amount()(uint256)}) > 1`,
    `assert ${target}::{balanceOf(address)(uint256) @sender} > 0`,
    `load lang\nassert @str.concat!(${target}::{name()(string)} ${target}::{symbol()(string)}) == "Assertions"`,
    `assert ${target}::{combine(string,string)(uint256) ${target}::{name()(string)} ${target}::{symbol()(string)}} > 0`,
  ];
  for (const source of snippets) {
    const script = tag.script(source);
    const validation = await script.validate();
    assert.ok(validation.valid, JSON.stringify(validation.diagnostics));
    const actions = await script.interpret();
    assert.equal(actions.length, 1, source);
    assert.equal(actions[0].to, sdk.CORE_ADDRESS, source);
  }
  const invalidArrayHash = `assert @hash!(${target}::{values()(uint256[])}) == 0x${"00".repeat(32)}`;
  await assert.rejects(() => tag.script(invalidArrayHash).interpret(), /string or bytes/);

  // The builder's menus and the compiler agree on what @hash!/@bytes.len!
  // accept: the catalog offers the wrap exactly when the rendered line
  // compiles.
  for (const type of ["uint256[]", "uint256", "string", "bytes"]) {
    const call = { kind: "call", target, resolved: target, hops: [{ fnName: "value", inline: true, argTypes: [], returnTypes: [type], args: [] }] };
    const acceptsHash = type === "string" || type === "bytes";
    assert.equal(wrapEntriesFor(call, 0).some((entry) => entry.key === "hash"), acceptsHash);
    for (const helper of ["hash", "bytelen"]) {
      const assertion = { subject: { kind: "callwrap", helper, call }, operator: "==", expected: { kind: "literal", value: helper === "hash" ? `0x${"00".repeat(32)}` : "1" }, delta: "", message: "" };
      const built = await buildAssertionLine(assertion, { resolveEns: async () => null, chainId: 1 });
      assert.ok(built, `${helper} over ${type}: the line did not render`);
      const compiled = await compileAssertionLine(tag, "", built.line, built.sets, "post");
      assert.equal(compiled.ok, acceptsHash, `${helper} over ${type}: ${JSON.stringify(compiled.diagnostics)}`);
    }
  }

  // Every on-chain helper face has exactly one owning module, so the load
  // derivation is never ambiguous.
  const owners = new Map();
  for (const [module, registry] of Object.entries(REGISTRIES)) {
    for (const [name, entry] of Object.entries(registry)) {
      if (entry.onchain) owners.set(name, [...(owners.get(name) ?? []), module]);
    }
  }
  for (const [name, modules] of owners) assert.equal(modules.length, 1, `@${name} is owned by ${modules.join(" and ")}`);
  assert.equal(Object.keys(HELPER_OWNER).length, owners.size, "helper ownership map drift");
  console.log(`Builder: ${snippets.length} scripts validate and compile; invalid byte operands rejected; ${owners.size} on-chain faces with one owner each`);
} finally {
  await server.close();
}
