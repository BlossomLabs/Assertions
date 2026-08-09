// @ts-check
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';

import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';

import react from '@astrojs/react';
import starlight from '@astrojs/starlight';

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
// helper) drive the builder's combinator catalog; they have no package
// export of their own, so alias them explicitly. The catalog merges the
// assertions registry with the on-chain faces lang and std contribute.
for (const mod of ['assertions', 'lang', 'math', 'receipts', 'std']) {
  local.alias.push({
    find: exact(`@evmcrispr/module-${mod}/registry`),
    replacement: path.resolve(evmcrisprSrc, `modules/${mod}/src/_generated.ts`),
  });
}

// The module's type-composition table (which operators accept which operand
// categories) drives the builder's operator menus — same single source of
// truth the assert compiler consults.
local.alias.push({
  find: /^@evmcrispr\/module-assertions\/composition$/,
  replacement: path.resolve(
    evmcrisprSrc,
    'modules/assertions/src/lib/composition.ts',
  ),
});

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
    optimizeDeps: {
      exclude: local.ids,
      // Deps imported only from the excluded @evmcrispr sources are not
      // discoverable by the startup scan; without listing them, Vite
      // re-optimizes when they first load in the browser and force-reloads
      // the page (most visibly: opening the Monaco editor tab wiped the
      // whole builder). Pre-bundle them eagerly instead.
      include: ['monaco-editor', ...vendoredDepIds],
    },
  },

  integrations: [
    // Documentation lives under /docs (files in src/content/docs/docs/ so
    // every slug carries the prefix); the landing, builder and deployments
    // pages in src/pages are untouched by Starlight.
    starlight({
      title: 'Assertions',
      description:
        'On-chain assertions for verifying view function return values and blockchain state.',
      logo: {
        light: './src/assets/logo-light.svg',
        dark: './src/assets/logo-dark.svg',
        replacesTitle: true,
      },
      favicon: '/favicon.svg',
      // The main site's fonts, loaded the same way Layout.astro does.
      head: [
        {
          tag: 'link',
          attrs: { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        },
        {
          tag: 'link',
          attrs: {
            rel: 'preconnect',
            href: 'https://fonts.gstatic.com',
            crossorigin: true,
          },
        },
        {
          tag: 'link',
          attrs: {
            rel: 'stylesheet',
            href: 'https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Outfit:wght@300;400;500;600;700&display=swap',
          },
        },
      ],
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/blossomlabs/Assertions',
        },
      ],
      sidebar: [
        {
          label: 'Introduction',
          items: [{ slug: 'docs' }, { slug: 'docs/solidity' }],
        },
        {
          label: 'Core primitives',
          items: [
            { slug: 'docs/core/reads' },
            { slug: 'docs/core/control' },
          ],
        },
        {
          label: 'Operators',
          items: [
            { slug: 'docs/operators' },
            { slug: 'docs/operators/words' },
            { slug: 'docs/operators/data' },
            { slug: 'docs/operators/fold' },
          ],
        },
        {
          label: 'EVMcrispr',
          items: [{ slug: 'docs/evml' }],
        },
        {
          label: 'Reference',
          items: [
            { slug: 'docs/reference/core' },
            { slug: 'docs/reference/errors' },
            { slug: 'docs/reference/deployments' },
          ],
        },
      ],
      customCss: ['./src/styles/starlight.css'],
      // Share the main site's theme state: read/write the same localStorage
      // key and swap the 3-way picker for the site's sun/moon toggle.
      components: {
        ThemeProvider: './src/components/docs/ThemeProvider.astro',
        ThemeSelect: './src/components/docs/ThemeSelect.astro',
      },
      expressiveCode: {
        shiki: {
          // EVML snippets highlight with the same TextMate grammar the
          // builder's Monaco/Shiki editor uses, loaded from the vendored
          // EVMcrispr checkout.
          langs: [
            JSON.parse(
              readFileSync(
                path.resolve(
                  evmcrisprSrc,
                  'packages/editor/src/grammars/evml.tmLanguage.json',
                ),
                'utf-8',
              ),
            ),
          ],
        },
      },
    }),
    react(),
  ],
});
