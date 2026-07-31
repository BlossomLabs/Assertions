// @ts-check
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';

import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';

import react from '@astrojs/react';

// ---------------------------------------------------------------------------
// Optional: develop against a local EVMcrispr checkout instead of the published
// packages. Set EVMCRISPR_SRC to the repo root and every @evmcrispr/* import
// resolves straight to that checkout's TypeScript sources -- no build step in
// EVMcrispr, and new files are picked up without reinstalling.
//
//   EVMCRISPR_SRC=~/Projects/EVMcrispr pnpm dev
//
// Unset (the default, and how CI/other contributors run), the packages resolve
// normally from node_modules at the versions pinned in package.json.
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

      // Sub-path exports first so they match before the bare package name
      // (e.g. @evmcrispr/core/worker before @evmcrispr/core).
      for (const [key, val] of Object.entries(pkg.exports ?? {})) {
        if (key === '.' || !val?.bun) continue;
        alias.push({
          find: `${pkg.name}${key.slice(1)}`,
          replacement: path.resolve(groupDir, dir, val.bun),
        });
      }

      const entry = pkg.exports?.['.']?.bun ?? 'src/index.ts';
      alias.push({
        find: pkg.name,
        replacement: path.resolve(groupDir, dir, entry),
      });
      ids.push(pkg.name);
    }
  }

  return { alias, ids };
}

const evmcrisprSrc = process.env.EVMCRISPR_SRC
  ? path.resolve(process.env.EVMCRISPR_SRC.replace(/^~/, process.env.HOME ?? '~'))
  : null;

const local = evmcrisprSrc ? evmcrisprSourceAliases(evmcrisprSrc) : null;

if (evmcrisprSrc && !local?.ids.length) {
  throw new Error(
    `EVMCRISPR_SRC="${evmcrisprSrc}" contains no @evmcrispr/* packages -- point it at the EVMcrispr repo root.`,
  );
}

if (local) {
  console.log(`[evmcrispr] using local sources from ${evmcrisprSrc} (${local.ids.length} packages)`);
}

// https://astro.build/config
export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
    ...(local && {
      resolve: { alias: local.alias },
      // Sources live outside the Astro project root, so Vite must be allowed to
      // serve them, and esbuild must not try to pre-bundle them from node_modules.
      server: { fs: { allow: [path.resolve('.'), evmcrisprSrc] } },
      optimizeDeps: { exclude: local.ids },
    }),
  },

  integrations: [react()],
});
