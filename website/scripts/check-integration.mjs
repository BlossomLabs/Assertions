// Exercise the builder against the same source aliases as the website build.
// No RPC, wallet, or external service is used.
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
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

try {
  const load = (path) => server.ssrLoadModule(path);
  const { evml } = await load("/src/components/builder/evml.ts");
  const { emptyAssertion, validateAssertion } = await load("/src/components/builder/assertion-model.ts");
  const { wrapEntriesFor } = await load("/src/components/builder/expr/catalog.ts");
  const sdk = await load("@evmcrispr/sdk/onchain");
  const fixtures = await load(`${evmcrisprSrc}/packages/test-utils/src/onchain/assertions-bytecode.ts`);
  const core = await load("/src/lib/assertions-deployment.ts");
  const operators = await load("/src/lib/operations-deployment.ts");
  const collections = await load("/src/lib/collections-deployment.ts");

  for (const [name, exports, prefix, sdkAddress] of [
    ["Assertions", core, "ASSERTIONS", sdk.CORE_ADDRESS],
    ["Operations", operators, "OPERATIONS", sdk.OPERATIONS_ADDRESS],
    ["Collections", collections, "COLLECTIONS", sdk.COLLECTIONS_ADDRESS],
  ]) {
    const artifact = JSON.parse(readFileSync(`../artifacts/contracts/${name}.sol/${name}.json`, "utf8"));
    assert.equal(exports[`${prefix}_ADDRESS`], sdkAddress, `${name}: compiler address drift`);
    assert.equal(exports[`${prefix}_CREATION_BYTECODE`], artifact.bytecode, `${name}: stale deployment bytecode`);
    assert.equal(fixtures[`${prefix}_RUNTIME_HASH`], keccak256(artifact.deployedBytecode), `${name}: stale EVM test fixture`);
    assert.equal(fixtures[`${prefix}_RUNTIME_BYTECODE`], artifact.deployedBytecode);
    assert.equal(getContractAddress({ from: core.CREATE2_PROXY, opcode: "CREATE2", salt: exports[`${prefix}_SALT`], bytecode: artifact.bytecode }), sdkAddress);
    const size = (artifact.deployedBytecode.length - 2) / 2;
    assert.ok(size <= 24576, `${name}: EIP-170 limit exceeded`);
    console.log(`${name}: ${size} runtime bytes; deployment, SDK and fixture agree`);
  }

  const { DEPLOYED_CONTRACTS } = await load("/src/components/deployments/shared.ts");
  assert.deepEqual(DEPLOYED_CONTRACTS.map((contract) => contract.name), ["Assertions", "Operations", "Collections"]);
  assert.deepEqual(DEPLOYED_CONTRACTS.map((contract) => contract.address), [sdk.CORE_ADDRESS, sdk.OPERATIONS_ADDRESS, sdk.COLLECTIONS_ADDRESS]);

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

  for (const type of ["uint256[]", "uint256", "string", "bytes"]) {
    const call = { kind: "call", target, resolved: target, hops: [{ fnName: "value", inline: true, argTypes: [], returnTypes: [type], args: [] }] };
    const acceptsHash = type === "string" || type === "bytes";
    assert.equal(wrapEntriesFor(call, 0).some((entry) => entry.key === "hash"), acceptsHash);
    for (const helper of ["hash", "bytelen"]) {
      const assertion = { ...emptyAssertion(), subject: { kind: "callwrap", helper, call }, expected: { kind: "literal", value: helper === "hash" ? `0x${"00".repeat(32)}` : "1" } };
      const issues = validateAssertion(assertion);
      assert.equal(issues.some((issue) => issue.message.includes("needs a string or bytes")), !acceptsHash);
    }
  }
  console.log(`Builder: ${snippets.length} scripts validate and compile; invalid byte operands rejected`);
} finally {
  await server.close();
}
