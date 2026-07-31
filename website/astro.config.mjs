// @ts-check
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';

import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';

import react from '@astrojs/react';

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

      const exact = (specifier) =>
        new RegExp(`^${specifier.replace(/[.*+?^${}()|[\]\\/]/g, '\\$&')}$`);

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

if (!local.ids.length) {
  throw new Error(
    `"${evmcrisprSrc}" contains no @evmcrispr/* packages -- point EVMCRISPR_SRC at the EVMcrispr repo root.`,
  );
}

console.log(`[evmcrispr] using sources from ${evmcrisprSrc} (${local.ids.length} packages)`);

// https://astro.build/config
export default defineConfig({
  // localhost:3000 is the redirect origin allowlisted on the Dappnode Nexus
  // OAuth client; on any other port "Login with Dappnode Nexus" is rejected
  // with "redirect URI is not allowed".
  server: { port: 3000 },

  vite: {
    plugins: [tailwindcss()],
    // @evmcrispr/sdk reads VITE_ETHERSCAN_API_KEY via import.meta.env; Astro
    // only exposes PUBLIC_ by default.
    envPrefix: ['VITE_', 'PUBLIC_'],
    resolve: { alias: local.alias },
    // Sources may live outside the Astro project root (EVMCRISPR_SRC), so Vite
    // must be allowed to serve them, and esbuild must not try to pre-bundle
    // them from node_modules.
    server: { fs: { allow: [path.resolve('.'), evmcrisprSrc] } },
    optimizeDeps: { exclude: local.ids },
  },

  integrations: [react()],
});
