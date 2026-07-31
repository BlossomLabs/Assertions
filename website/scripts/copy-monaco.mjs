// @evmcrispr/editor loads Monaco's AMD build from `/vs` on the site's own
// origin (no third-party CDN). Sync the installed monaco-editor's min/vs
// into public/ so both `astro dev` and the built site serve it.
import { cpSync, existsSync, rmSync } from "node:fs";
import { createRequire } from "node:module";
import path from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
// monaco's exports map hides package.json; the "." entry resolves to
// min/vs/index.js, whose directory is the AMD build we serve.
const vsDir = path.dirname(require.resolve("monaco-editor"));
const target = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../public/vs",
);

if (existsSync(target)) rmSync(target, { recursive: true });
cpSync(vsDir, target, { recursive: true });
console.log(`[monaco] copied ${vsDir} -> public/vs`);
