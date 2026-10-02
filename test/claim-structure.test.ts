// Run the isolated A34/W27 compiler checks in normal Node/Hardhat test discovery.
// The Python suite emits no canonical build artifacts or deployment candidates.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { dirname, resolve } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");

test("claim structural evidence: A34 imports/metadata and W27 judge ABI", { timeout: 120_000 }, () => {
  const result = spawnSync("python3", [resolve(root, "scripts/test-claim-structure.py")], {
    cwd: root,
    encoding: "utf8",
    timeout: 110_000,
  });
  assert.ifError(result.error);
  const output = `${result.stdout}${result.stderr}`;
  assert.equal(result.status, 0, output);
  assert.match(output, /Ran 2 tests/);
  assert.match(output, /\nOK\s*$/);
});
