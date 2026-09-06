// Vendors the EVMcrispr monorepo into .evmcrispr/ at the commit pinned in
// package.json's "evmcrispr" field, then installs its dependencies with bun
// (it is a bun workspace). astro.config.mjs aliases every @evmcrispr/*
// import to this checkout's TypeScript sources.
//
// To develop against your own checkout instead, set EVMCRISPR_SRC to its
// repo root — this script then does nothing.
//
// To bump the pin: update "evmcrispr.commit" in package.json (e.g. to the
// output of `git ls-remote https://github.com/EVMcrispr/evmcrispr.git next`).
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const websiteDir = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const { evmcrispr } = JSON.parse(
  readFileSync(path.join(websiteDir, "package.json"), "utf-8"),
);
const { repo, commit } = evmcrispr;
const dir = path.join(websiteDir, ".evmcrispr");
const readyFile = path.join(dir, "node_modules", ".assertions-ready-commit");

if (process.env.EVMCRISPR_SRC) {
  console.log(
    `[evmcrispr] EVMCRISPR_SRC is set — using ${process.env.EVMCRISPR_SRC} instead of the vendored clone`,
  );
  process.exit(0);
}

const git = (...args) =>
  execFileSync("git", ["-C", dir, ...args], {
    stdio: ["ignore", "pipe", "inherit"],
  })
    .toString()
    .trim();

let atPin = false;
if (existsSync(path.join(dir, ".git"))) {
  try {
    atPin = git("rev-parse", "HEAD") === commit;
  } catch {
    /* corrupt checkout — refetch below */
  }
}

if (!atPin) {
  if (existsSync(path.join(dir, ".git")) && git("status", "--porcelain")) {
    throw new Error("EVMcrispr checkout has local changes. Commit or preserve them before updating the pin, or use EVMCRISPR_SRC.");
  }
  if (!existsSync(path.join(dir, ".git"))) {
    mkdirSync(dir, { recursive: true });
    git("init", "-q");
    git("remote", "add", "origin", repo);
  }
  git("remote", "set-url", "origin", repo);
  console.log(`[evmcrispr] fetching ${repo} @ ${commit.slice(0, 10)}…`);
  git("fetch", "-q", "--depth", "1", "origin", commit);
  git("checkout", "-q", "--detach", commit);
}

if (!existsSync(readyFile) || readFileSync(readyFile, "utf-8").trim() !== commit) {
  console.log("[evmcrispr] installing dependencies (bun install)…");
  execFileSync("bun", ["install", "--frozen-lockfile"], {
    cwd: dir,
    stdio: "inherit",
  });
  // The packages' src/_generated.ts files are codegen output, not committed.
  console.log("[evmcrispr] generating sources (turbo run codegen)…");
  execFileSync(path.join(dir, "node_modules/.bin/turbo"), ["run", "codegen"], {
    cwd: dir,
    stdio: "inherit",
  });
  writeFileSync(readyFile, `${commit}\n`);
}

console.log(`[evmcrispr] ready: .evmcrispr @ ${commit.slice(0, 10)}`);
