// Shared by Astro and the offline integration checks.
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';

// ---------------------------------------------------------------------------
// Every @evmcrispr/* import resolves straight to the TypeScript sources of an
// EVMcrispr checkout -- no build step in EVMcrispr, and new files are picked
// up without reinstalling.
//
// By default that checkout is .evmcrispr/, a clone of the EVMcrispr repo at
// the commit pinned in package.json's "evmcrispr" field. It is created and
// kept in sync by scripts/vendor-evmcrispr.mjs, which runs automatically
// before `dev` and `build`.
//
// To develop against your own checkout instead, point EVMCRISPR_SRC at it:
//
//   EVMCRISPR_SRC=~/Projects/EVMcrispr pnpm dev
// ---------------------------------------------------------------------------

const exact = (specifier) =>
  new RegExp(`^${specifier.replace(/[.*+?^${}()|[\]\\/]/g, '\\$&')}$`);

/** @returns {{alias: import('vite').Alias[], ids: string[]}} */
function evmcrisprSourceAliases(root) {
  /** @type {import('vite').Alias[]} */
  const alias = [];
  const ids = [];

  for (const group of ['packages', 'modules']) {
    const groupDir = path.resolve(root, group);
    if (!existsSync(groupDir)) continue;

    for (const dir of readdirSync(groupDir).sort()) {
      const pkgPath = path.resolve(groupDir, dir, 'package.json');
      if (!existsSync(pkgPath)) continue;

      const pkg = JSON.parse(readFileSync(pkgPath, 'utf-8'));
      if (!pkg.name?.startsWith('@evmcrispr/')) continue;

      // Exact-match regexes: a bare-string alias for the package name would
      // also prefix-match sub-path imports (e.g. @evmcrispr/editor/style.css)
      // and mangle them. Sub-paths without a `bun` source entry (prebuilt CSS
      // and the like) fall through to node_modules.
      for (const [key, val] of Object.entries(pkg.exports ?? {})) {
        if (key === '.' || !val?.bun) continue;
        alias.push({
          find: exact(`${pkg.name}${key.slice(1)}`),
          replacement: path.resolve(groupDir, dir, val.bun),
        });
      }

      const entry = pkg.exports?.['.']?.bun ?? 'src/index.ts';
      alias.push({
        find: exact(pkg.name),
        replacement: path.resolve(groupDir, dir, entry),
      });
      ids.push(pkg.name);
    }
  }

  return { alias, ids };
}

const evmcrisprSrc = process.env.EVMCRISPR_SRC
  ? path.resolve(process.env.EVMCRISPR_SRC.replace(/^~/, process.env.HOME ?? '~'))
  : path.resolve('.evmcrispr');

if (!existsSync(evmcrisprSrc)) {
  throw new Error(
    `EVMcrispr checkout not found at "${evmcrisprSrc}" -- run \`node scripts/vendor-evmcrispr.mjs\` (pnpm dev/build do this automatically), or point EVMCRISPR_SRC at a local EVMcrispr repo.`,
  );
}

const local = evmcrisprSourceAliases(evmcrisprSrc);

// The modules' generated helper registries (name/returnType/argDefs per
// helper, with `onchain: true` on every `!` face) drive the builder's
// combinator catalog and its helper-ownership map; they have no package
// export of their own, so alias each registered module's `_generated.ts`
// explicitly. Every module directory that carries one is aliased, so a
// newly registered module needs no edit here.
{
  const modulesDir = path.resolve(evmcrisprSrc, 'modules');
  const moduleDirs = existsSync(modulesDir) ? readdirSync(modulesDir).sort() : [];
  for (const mod of moduleDirs) {
    const registry = path.resolve(modulesDir, mod, 'src/_generated.ts');
    if (!existsSync(registry)) continue;
    local.alias.push({
      find: exact(`@evmcrispr/module-${mod}/registry`),
      replacement: registry,
    });
  }
}

if (!local.ids.length) {
  throw new Error(
    `"${evmcrisprSrc}" contains no @evmcrispr/* packages -- point EVMCRISPR_SRC at the EVMcrispr repo root.`,
  );
}

console.log(`[evmcrispr] using sources from ${evmcrisprSrc} (${local.ids.length} packages)`);

// Deps imported only from the excluded @evmcrispr sources live in the
// checkout's own node_modules, so their bare names don't resolve from the
// website root: optimizeDeps.include would skip them ("Failed to resolve
// dependency"), and they'd be re-optimized when they first load in the
// browser, force-reloading the page (most visibly: opening the Monaco editor
// tab wiped the whole builder). Alias each one to its vendored location --
// the package directory for bare ids, so Vite's normal module/exports field
// resolution still picks the right build, and the exact file for subpaths --
// which also makes the optimizeDeps.include entries below resolvable.
/** @type {string[]} */
const vendoredDepIds = [];
{
  const importers = /** @type {const} */ ([
    [
      'packages/editor',
      [
        '@monaco-editor/react',
        'shiki/core',
        'shiki/engine/oniguruma',
        'shiki/langs/json.mjs',
        'shiki/langs/solidity.mjs',
      ],
    ],
    ['packages/ai', ['ai', '@ai-sdk/openai-compatible']],
  ]);

  for (const [pkg, ids] of importers) {
    const req = createRequire(path.resolve(evmcrisprSrc, pkg, 'package.json'));
    for (const id of ids) {
      const isBarePackage = id.split('/').length === (id.startsWith('@') ? 2 : 1);
      let replacement;
      if (isBarePackage) {
        // Walk up from the resolved entry to the package root (identified by
        // a package.json whose name matches; dist/package.json shims don't).
        let dir = path.dirname(req.resolve(id));
        while (true) {
          const pkgJson = path.join(dir, 'package.json');
          if (existsSync(pkgJson) && JSON.parse(readFileSync(pkgJson, 'utf-8')).name === id)
            break;
          dir = path.dirname(dir);
        }
        replacement = dir;
      } else {
        replacement = req.resolve(id);
      }
      local.alias.push({ find: exact(id), replacement });
      vendoredDepIds.push(id);
    }
  }
}

export { evmcrisprSrc, local, vendoredDepIds };
