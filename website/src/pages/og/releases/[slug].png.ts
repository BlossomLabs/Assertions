import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import ReleaseBanner from '../../../components/ReleaseBanner.astro';
import { BACKGROUND, CARD_H, CARD_W, card, figure } from '../../../lib/og';
import { isPublished } from '../../../lib/releases';

// The social card of a release: its banner, enlarged around the eye. A card
// is 1200x630 and the banner 1200x300, so the banner is scaled up, cropped to
// the part that holds the eye, and faded into the background above and below.
const BANNER_W = 1200;
const BANNER_H = 300;
const SCALE = 1.6;
const FADE = 90;

export async function getStaticPaths() {
  const releases = await getCollection('releases', isPublished);
  return releases.map((entry) => ({ params: { slug: entry.id }, props: { banner: entry.data.banner } }));
}

export const GET: APIRoute = async ({ props }) => {
  const art = await figure(ReleaseBanner, { beast: props.banner, bare: true });

  // Where the eye is, in banner units. A mirrored banner draws it on the other side.
  const cx = Number(/data-cx="([\d.]+)"/.exec(art)?.[1] ?? BANNER_W / 2);
  const eye = art.includes(`translate(${BANNER_W} 0) scale(-1 1)`) ? BANNER_W - cx : cx;
  const span = CARD_W / SCALE;
  const left = Math.min(BANNER_W - span, Math.max(0, eye - span / 2));
  const height = BANNER_H * SCALE;
  const top = (CARD_H - height) / 2;

  return card(`<defs>
    <linearGradient id="og-top" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="${BACKGROUND}" /><stop offset="1" stop-color="${BACKGROUND}" stop-opacity="0" />
    </linearGradient>
    <linearGradient id="og-bottom" x1="0" y1="1" x2="0" y2="0">
      <stop offset="0" stop-color="${BACKGROUND}" /><stop offset="1" stop-color="${BACKGROUND}" stop-opacity="0" />
    </linearGradient>
  </defs>
  <svg x="0" y="${top}" width="${CARD_W}" height="${height}" viewBox="${left} 0 ${span} ${BANNER_H}">${art}</svg>
  <rect y="${top}" width="${CARD_W}" height="${FADE}" fill="url(#og-top)" />
  <rect y="${top + height - FADE}" width="${CARD_W}" height="${FADE}" fill="url(#og-bottom)" />`);
};
