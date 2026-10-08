// @ts-check
import { readFileSync } from 'node:fs';
import path from 'node:path';

import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';

import react from '@astrojs/react';
import starlight from '@astrojs/starlight';

import { evmcrisprSrc, local, vendoredDepIds } from './scripts/evmcrispr-sources.mjs';

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
    server: {
      fs: { allow: [path.resolve('.'), evmcrisprSrc] },
      // The vendored checkout carries turbo's cache (tens of thousands of
      // files in .turbo/cache, one inotify watch each) which pushes the dev
      // server past the kernel's watcher limit (ENOSPC) and kills it on
      // startup. Vite ignores node_modules and .git by default, not .turbo.
      watch: { ignored: ['**/.turbo/**'] },
    },
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
          label: 'Start',
          items: [
            { slug: 'docs' },
            { slug: 'docs/quickstart' },
            { slug: 'docs/guides/executors' },
          ],
        },
        {
          label: 'Protect a transaction',
          items: [
            { slug: 'docs/guides/safe' },
            { slug: 'docs/guides/dao-proposals' },
            { slug: 'docs/guides/wallet-batches' },
          ],
        },
        {
          label: 'Write assertions',
          items: [
            { slug: 'docs/evml' },
            { slug: 'docs/recipes' },
            { slug: 'docs/test-an-assertion' },
            { slug: 'docs/troubleshooting' },
            { slug: 'docs/reference' },
          ],
        },
        {
          label: 'Review and trust',
          items: [{ slug: 'docs/reviewing' }, { slug: 'docs/security' }],
        },
        {
          label: 'Integrate and upgrade',
          items: [{ slug: 'docs/integrate' }, { slug: 'docs/migration' }],
        },
        {
          label: 'Contracts',
          items: [
            { slug: 'docs/contracts' },
            { slug: 'docs/contracts/assertions' },
            { slug: 'docs/contracts/operations' },
            { slug: 'docs/contracts/collections' },
            { slug: 'docs/contracts/expressions' },
            { slug: 'docs/contracts/errors' },
            { slug: 'docs/contracts/deployments' },
            { slug: 'docs/contracts/verification' },
          ],
        },
        {
          label: 'Help',
          items: [{ slug: 'docs/faq' }, { slug: 'docs/glossary' }],
        },
      ],
      customCss: ['./src/styles/starlight.css'],
      // Share the main site's theme state: read/write the same localStorage
      // key and swap the 3-way picker for the site's sun/moon toggle.
      components: {
        ThemeProvider: './src/components/docs/ThemeProvider.astro',
        ThemeSelect: './src/components/docs/ThemeSelect.astro',
        Footer: './src/components/docs/Footer.astro',
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
