import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { it } from "node:test";

it("claim IDs retain their meanings, retired evidence and displayed scopes", () => {
  const root = fileURLToPath(new URL("../", import.meta.url));
  for (const args of [["-B", "scripts/test-claim-ledger.py"], ["-B", "scripts/render-claims.py", "--check"]]) {
    const result = spawnSync("python3", args, { cwd: root, encoding: "utf8", timeout: 30_000 });
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stdout + result.stderr);
  }
});
