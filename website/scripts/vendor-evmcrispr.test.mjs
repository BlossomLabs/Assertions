import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { chmodSync, copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";

function fixture(t) {
  const root = mkdtempSync(path.join(tmpdir(), "assertions-vendor-"));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const dir = path.join(root, ".evmcrispr");
  mkdirSync(path.join(dir, "node_modules/.bin"), { recursive: true });
  mkdirSync(path.join(root, "scripts"));
  mkdirSync(path.join(root, "bin"));
  copyFileSync(new URL("./vendor-evmcrispr.mjs", import.meta.url), path.join(root, "scripts/vendor-evmcrispr.mjs"));
  const git = (...args) => execFileSync("git", ["-C", dir, ...args], { encoding: "utf8" }).trim();
  git("init", "-q");
  writeFileSync(path.join(dir, ".gitignore"), "node_modules/\n");
  writeFileSync(path.join(dir, "source.txt"), "original\n");
  git("add", ".");
  git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-qm", "fixture");
  const commit = git("rev-parse", "HEAD");
  // Fake only the dependency tools; checkout safety is tested with real Git.
  for (const file of [path.join(root, "bin/bun"), path.join(dir, "node_modules/.bin/turbo")]) {
    writeFileSync(file, '#!/bin/sh\nif [ "$VENDOR_TEST_FAIL" = "1" ]; then exit 1; fi\nexit 0\n');
    chmodSync(file, 0o755);
  }
  const pin = (sha) => writeFileSync(path.join(root, "package.json"), JSON.stringify({ evmcrispr: { repo: dir, commit: sha } }));
  pin(commit);
  const run = (extra = {}) => spawnSync(process.execPath, ["scripts/vendor-evmcrispr.mjs"], {
    cwd: root,
    encoding: "utf8",
    env: { ...process.env, EVMCRISPR_SRC: "", PATH: `${root}/bin:${process.env.PATH}`, ...extra },
  });
  return { root, dir, commit, git, pin, run };
}

test("a failed preparation is retried even when HEAD already equals the pin", (t) => {
  const f = fixture(t);
  assert.notEqual(f.run({ VENDOR_TEST_FAIL: "1" }).status, 0);
  const success = f.run();
  assert.equal(success.status, 0, success.stderr);
  assert.match(success.stdout, /installing dependencies/);
  assert.equal(readFileSync(path.join(f.dir, "node_modules/.assertions-ready-commit"), "utf8").trim(), f.commit);
  const cached = f.run({ VENDOR_TEST_FAIL: "1" });
  assert.equal(cached.status, 0, cached.stderr);
  assert.doesNotMatch(cached.stdout, /installing|generating|fetching/);
});

test("a pin mismatch never discards tracked or untracked checkout changes", (t) => {
  const f = fixture(t);
  f.pin("0".repeat(40));
  for (const file of ["source.txt", "untracked.txt"]) {
    writeFileSync(path.join(f.dir, file), "keep my work\n");
    const result = f.run();
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /checkout has local changes/);
    assert.equal(f.git("rev-parse", "HEAD"), f.commit);
    assert.equal(readFileSync(path.join(f.dir, file), "utf8"), "keep my work\n");
    if (file === "source.txt") writeFileSync(path.join(f.dir, file), "original\n");
  }
});
