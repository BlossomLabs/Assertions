// Current-source structural evidence and a clearly isolated Forge-only blob-context fixture.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { it } from "node:test";

const root = fileURLToPath(new URL("../", import.meta.url));
function run(command: string, args: string[], env = process.env): string {
  const result = spawnSync(command, args, {
    cwd: root, env, encoding: "utf8", timeout: 180_000, maxBuffer: 16 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  const output = result.stdout + result.stderr;
  assert.equal(result.status, 0, output);
  return output;
}
it("claim structure: cached admission metadata and offline reference identity", () => {
  const output = run("python3", ["-B", "scripts/test-claim-coverage-structure.py"]);
  assert.match(output, /Ran 5 tests/);
  for (const name of [
    "test_E42_admission_shape_metadata_reused_by_validation",
    "test_E42_checker_detects_missing_cached_words_argument",
    "test_E42_checker_detects_wrong_descriptor_input",
    "test_E42_checker_detects_wrong_iterator_increment",
    "test_W30_inlined_runtime_matches_pinned_fixture_bytes_and_hash_field",
  ]) assert.match(output, new RegExp(name + ".* \\.\\.\\. ok"));
});
it("blobHash observes injected Forge transaction context and index bounds", () => {
  const temporary = mkdtempSync(join(tmpdir(), "assertions-blob-context-"));
  try {
    const output = run("forge", [
      "test", "--match-contract", "^ClaimCoverageBlobTest$",
      "--out", join(temporary, "out"), "--cache-path", join(temporary, "cache"), "-vv",
    ], { ...process.env, FOUNDRY_TEST: "scripts/forge-only" });
    assert.match(output, /\[PASS\] test_O38_InjectedBlobHashesAndOutOfRangeIndices\(\)/);
    assert.match(output, /1 tests passed, 0 failed, 0 skipped \(1 total tests\)/);
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
});
