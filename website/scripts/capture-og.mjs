// Photographs /og/card, the hamsa beside one line in a 1200x630 frame,
// and saves it as the default social card. Run it against a running site after
// the card page changes, then commit the image:
//
//   pnpm og:capture                       (the dev server on localhost:3000)
//   pnpm og:capture http://localhost:4321
//
// It needs Chrome or Chromium; set CHROME to its path if it is not found.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const origin = process.argv[2] ?? 'http://localhost:3000';
const out = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../public/og/default.png');

const chrome = [process.env.CHROME, '/usr/bin/google-chrome', '/usr/bin/chromium', '/usr/bin/chromium-browser', '/snap/bin/chromium', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'].find(
  (candidate) => candidate && existsSync(candidate),
);
if (!chrome) throw new Error('No Chrome or Chromium found. Set CHROME to its path.');

mkdirSync(path.dirname(out), { recursive: true });
execFileSync(
  chrome,
  [
    '--headless=new',
    '--hide-scrollbars',
    '--force-device-scale-factor=1',
    '--window-size=1200,630',
    // The hamsa swings and its eye looks around; reduced motion has both rest as drawn.
    '--force-prefers-reduced-motion',
    // Long enough for the web fonts to arrive before the picture is taken.
    '--virtual-time-budget=8000',
    `--screenshot=${out}`,
    `${origin}/og/card`,
  ],
  { stdio: 'inherit' },
);
console.log(`Wrote ${out}`);
