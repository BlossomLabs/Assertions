// Check the hand-written docs against the builder's own compiler and against
// each other. No RPC, wallet, or external service is used.
//
//   - every ```evml block parses and passes the analyzer, with the builder's
//     modules. A block that is deliberately not a script (a syntax template)
//     is fenced as ```evml novalidate.
//   - every internal link resolves to a page, and every #anchor to a heading.
//   - the EVML reference has one section per module that owns an on-chain
//     helper face.
import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { createRequire } from "node:module";
import { join, relative } from "node:path";
import { fileURLToPath } from "node:url";

process.chdir(fileURLToPath(new URL("..", import.meta.url)));
const require = createRequire(import.meta.url);
const astroRequire = createRequire(require.resolve("astro/package.json"));
const { createServer } = await import(astroRequire.resolve("vite"));
const { default: GithubSlugger } = await import(astroRequire.resolve("github-slugger"));
const { local } = await import("./evmcrispr-sources.mjs");

const DOCS = "src/content/docs/docs";

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) walk(path, out);
    else if (/\.mdx?$/.test(entry)) out.push(path);
  }
  return out.sort();
}

/** `/docs`, `/docs/evml`, `/docs/contracts` (an index.md is its directory). */
function routeOf(file) {
  const slug = relative(DOCS, file).replace(/\.mdx?$/, "").replace(/(^|\/)index$/, "");
  return slug ? `/docs/${slug}` : "/docs";
}

/** Fenced blocks with their info string and the line they start on. */
function fences(text) {
  const out = [];
  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const open = /^(\s*)(`{3,})(.*)$/.exec(lines[i]);
    if (!open) continue;
    const body = [];
    let j = i + 1;
    for (; j < lines.length && !new RegExp(`^\\s*${open[2]}\\s*$`).test(lines[j]); j++) {
      body.push(lines[j].slice(open[1].length));
    }
    out.push({ info: open[3].trim(), line: i + 1, end: j + 1, source: body.join("\n") });
    i = j;
  }
  return out;
}

/** Heading anchors as Starlight generates them (github-slugger). */
function anchorsOf(text, blocks) {
  const slugger = new GithubSlugger();
  const fenced = new Set();
  for (const block of blocks) for (let n = block.line; n <= block.end; n++) fenced.add(n);
  const anchors = new Set();
  text.split("\n").forEach((line, i) => {
    if (fenced.has(i + 1)) return;
    const heading = /^#{1,6}\s+(.*)$/.exec(line);
    if (!heading) return;
    // The slug is made from the rendered text: no code ticks, emphasis or link targets.
    const plain = heading[1].replace(/\[([^\]]*)\]\([^)]*\)/g, "$1").replace(/[`*]/g, "").trim();
    anchors.add(slugger.slug(plain));
  });
  return anchors;
}

const files = walk(DOCS);
const pages = new Map();
for (const file of files) {
  const text = readFileSync(file, "utf8");
  const blocks = fences(text);
  pages.set(routeOf(file), { file, text, blocks, anchors: anchorsOf(text, blocks) });
}

const failures = [];

// --- Links -----------------------------------------------------------------
const releases = new Set(readdirSync("src/content/releases").map((name) => `/releases/${name.replace(/\.md$/, "")}`));
const sitePages = new Set(["/", "/builder", "/releases", ...releases]);
let links = 0;
for (const [route, page] of pages) {
  const prose = page.text.split("\n");
  for (const block of page.blocks) for (let n = block.line; n <= block.end; n++) prose[n - 1] = "";
  prose.forEach((line, i) => {
    for (const [, href] of line.matchAll(/\]\(([^)\s]+)\)/g)) {
      if (/^[a-z]+:/i.test(href)) continue;
      links++;
      const where = `${page.file}:${i + 1}`;
      const [path, anchor] = href.split("#");
      const target = path === "" ? route : path.replace(/\/$/, "") || "/";
      if (!target.startsWith("/")) {
        failures.push(`${where}: relative link ${href}; write it from the site root`);
      } else if (pages.has(target)) {
        if (anchor && !pages.get(target).anchors.has(anchor)) failures.push(`${where}: ${href} names a heading that ${pages.get(target).file} does not have`);
      } else if (!sitePages.has(target)) {
        failures.push(`${where}: ${href} is not a page`);
      } else if (anchor && target !== "/") {
        failures.push(`${where}: ${href} has an anchor this check cannot resolve`);
      }
    }
  });
}

// --- EVML blocks -----------------------------------------------------------
// Nothing here may reach the network: a block that tries is counted as
// needing the chain.
globalThis.fetch = async () => {
  throw new Error("HTTP request failed: the docs check is offline");
};
const server = await createServer({
  configFile: false,
  resolve: { alias: local.alias },
  server: { middlewareMode: true, watch: null, hmr: false, ws: false },
  optimizeDeps: { noDiscovery: true, include: [] },
});
let checked = 0;
let skipped = 0;
let compiled = 0;
let needsChain = 0;

const PLACEHOLDERS = [
  "0x0000000000000000000000000000000000000001",
  "1",
  `0x${"00".repeat(31)}01`,
  "[0x0000000000000000000000000000000000000001]",
  '"x"',
];
const MAX_TYPINGS = 400;

/** undefined when the block compiles, "offline" when it needs the chain,
 *  else the error of the typing that got furthest into the block.
 *
 *  The search fixes one failing line at a time: every typing of the free
 *  variables that line names is tried, and the first one that moves the
 *  error to a later line (or removes it) is kept. */
async function compile(tag, preamble, source, free) {
  const names = [...free];
  const typing = new Map(names.map((name) => [name, 0]));
  const lines = source.split("\n");
  const attempt = async () => {
    const sets = names.map((name) => `set ${name} ${PLACEHOLDERS[typing.get(name)]}`);
    try {
      await tag.script([...preamble, ...sets, source].join("\n")).interpret();
      return undefined;
    } catch (error) {
      const message = String(error?.message ?? error).split("\n")[0];
      const line = Number(/\((\d+):\d+,/.exec(message)?.[1] ?? preamble.length + sets.length + 1) - preamble.length - sets.length;
      return { line, message };
    }
  };
  let tries = 0;
  let failure = await attempt();
  while (failure && tries < MAX_TYPINGS) {
    if (/HTTP request failed/.test(failure.message)) return "offline";
    // A def body is resolved where the definition is used, so the analyzer
    // does not report a variable it names: pick those up from the error.
    const missing = /(\$[A-Za-z_][\w.]*) not defined/.exec(failure.message)?.[1];
    if (missing && !typing.has(missing)) {
      names.push(missing);
      typing.set(missing, 0);
      failure = await attempt();
      continue;
    }
    const here = names.filter((name) => new RegExp(`\\${name}(?![\\w.])`).test(lines[failure.line - 1] ?? ""));
    // A definition is compiled at its use, so its variables are in play too.
    const inDefs = names.filter((name) => !here.includes(name) && lines.some((l) => /^\s*def\s/.test(l) && l.includes(name)));
    const vary = [...here, ...inDefs];
    const before = failure;
    const saved = vary.map((name) => typing.get(name));
    let moved = false;
    for (let combo = 1; combo < PLACEHOLDERS.length ** vary.length && tries < MAX_TYPINGS; combo++, tries++) {
      vary.forEach((name, i) => typing.set(name, (saved[i] + Math.floor(combo / PLACEHOLDERS.length ** i)) % PLACEHOLDERS.length));
      const next = await attempt();
      if (!next) return undefined;
      if (next.line > before.line || /HTTP request failed/.test(next.message)) {
        failure = next;
        moved = true;
        break;
      }
    }
    if (!moved) {
      vary.forEach((name, i) => typing.set(name, saved[i]));
      return before;
    }
  }
  return failure;
}

try {
  const { evml } = await server.ssrLoadModule("/src/components/builder/evml.ts");
  const { REGISTRIES } = await server.ssrLoadModule("/src/components/builder/helper-owners.ts");
  const loadable = Object.keys(REGISTRIES).filter((module) => module !== "std");
  const tag = evml.with({ chainId: 1, account: "0x0000000000000000000000000000000000000001" });

  for (const page of pages.values()) {
    for (const block of page.blocks) {
      const [lang, ...flags] = block.info.split(/\s+/);
      if (lang !== "evml") continue;
      if (flags.includes("novalidate")) {
        skipped++;
        continue;
      }
      checked++;
      // A block with its own `load` line claims to be a whole script and is
      // checked as written. Any other block is a fragment: it gets every
      // builder module loaded ahead of it.
      const whole = /^\s*load\s/m.test(block.source);
      const preamble = whole ? [] : loadable.map((module) => `load ${module}`);
      const at = (line) => `${page.file}:${block.line + line - preamble.length}`;
      const validation = await tag.script([...preamble, block.source].join("\n")).validate();
      // Variables the page leaves to the reader ($vault, $treasury).
      const free = new Set();
      let invalid = false;
      for (const d of validation.diagnostics) {
        if (d.severity !== "error") continue;
        const variable = /^Variable (\$\S+) is not defined\.$/.exec(d.message);
        if (variable) free.add(variable[1]);
        else {
          invalid = true;
          failures.push(`${at(d.line)}: ${d.message}`);
        }
      }
      if (invalid) continue;

      // The analyzer does not compile, so it accepts lines the compiler
      // refuses (an operator a type does not support, a missing --delta).
      // Compile the block too. Free variables get placeholder values: the
      // block passes if some typing of them compiles. A block that needs the
      // chain (a token list, a build-time read, a DAO lookup) cannot be
      // compiled here and is counted, not failed.
      const outcome = await compile(tag, preamble, block.source, [...free]);
      if (outcome === "offline") needsChain++;
      else if (outcome) failures.push(`${page.file}:${block.line + outcome.line}: ${outcome.message}`);
      else compiled++;
    }
  }

  // --- Reference coverage --------------------------------------------------
  const reference = pages.get("/docs/reference");
  if (reference) {
    const owning = Object.entries(REGISTRIES)
      .filter(([, registry]) => Object.values(registry).some((entry) => entry.onchain))
      .map(([module]) => module)
      .sort();
    const listed = [...reference.text.matchAll(/<Helpers\s+module="([^"]+)"/g)].map(([, module]) => module).sort();
    assert.deepEqual(listed, owning, "the EVML reference must have one <Helpers module> section per module with on-chain helpers");
  }
} finally {
  await server.close();
}

assert.equal(failures.length, 0, `docs check:\n${failures.join("\n")}`);
console.log(`Docs: ${pages.size} pages; ${links} internal links resolve; ${checked} evml blocks validate, ${compiled} compile, ${needsChain} need the chain (${skipped} marked novalidate)`);
