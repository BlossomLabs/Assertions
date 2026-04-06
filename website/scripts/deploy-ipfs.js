import { PinataSDK } from "pinata";
import { readdir, readFile, stat } from "node:fs/promises";
import { join, relative } from "node:path";
import { config } from "dotenv";

config();

const DIST_DIR = "dist";

async function collectFiles(dir, base = dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...await collectFiles(fullPath, base));
    } else {
      const content = await readFile(fullPath);
      const relPath = relative(base, fullPath);
      files.push(new File([content], relPath, { type: guessMime(relPath) }));
    }
  }
  return files;
}

function guessMime(path) {
  const ext = path.split(".").pop();
  const mimes = {
    html: "text/html", css: "text/css", js: "application/javascript",
    json: "application/json", svg: "image/svg+xml", png: "image/png",
    ico: "image/x-icon", webmanifest: "application/manifest+json",
    txt: "text/plain", xml: "application/xml", woff2: "font/woff2",
    woff: "font/woff", ttf: "font/ttf",
  };
  return mimes[ext] || "application/octet-stream";
}

async function main() {
  if (!process.env.PINATA_JWT) {
    console.error("Set PINATA_JWT environment variable");
    process.exit(1);
  }

  const distStat = await stat(DIST_DIR).catch(() => null);
  if (!distStat?.isDirectory()) {
    console.error(`${DIST_DIR}/ not found — run "pnpm build" first`);
    process.exit(1);
  }

  const pinata = new PinataSDK({ pinataJwt: process.env.PINATA_JWT });
  const files = await collectFiles(DIST_DIR);

  console.log(`Uploading ${files.length} files to IPFS...`);

  const result = await pinata.upload.public
    .fileArray(files)
    .name("assertions-website");

  console.log(`\nCID: ${result.cid}`);
  console.log(`IPFS: ipfs://${result.cid}`);
  console.log(`Gateway: https://gateway.pinata.cloud/ipfs/${result.cid}`);
  console.log(`\nUpdate your ENS content hash at:`);
  console.log(`https://app.ens.domains/assertions.eth?tab=records`);
}

main().catch((err) => { console.error(err); process.exit(1); });
