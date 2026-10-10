import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import sharp from 'sharp';

// Social cards are drawn from the site's own figures, in the dark palette they
// are designed against. They carry no text: the page title travels in
// og:title, and text here would be set in whatever font the build machine has.
export const CARD_W = 1200;
export const CARD_H = 630;

const PALETTE: Record<string, string> = {
  '--color-bp-50': '#e8f4ff',
  '--color-bp-400': '#60a5fa',
  '--color-bp-500': '#005BA6',
  '--color-surface-2': '#0f2750',
};
export const BACKGROUND = PALETTE['--color-surface-2'];

/** What a figure component draws inside its `<svg>`, ready to nest in a card. */
export async function figure(component: Parameters<AstroContainer['renderToString']>[0], props = {}) {
  const container = await AstroContainer.create();
  const html = await container.renderToString(component, { props });
  const open = html.indexOf('<svg');
  return (
    html
      .slice(html.indexOf('>', open) + 1, html.lastIndexOf('</svg>'))
      .replace(/<!--[\s\S]*?-->/g, '')
      .replace(/var\((--[\w-]+)\)/g, (_, name) => PALETTE[name] ?? BACKGROUND)
  );
}

/** Attributes without a value are HTML, not XML, and none of the data-* ones draw anything. */
const xml = (svg: string) => svg.replace(/\sdata-[\w-]+(="[^"]*")?/g, '');

/** A card from what goes on its background, as a PNG response. */
export async function card(content: string) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${CARD_W}" height="${CARD_H}" viewBox="0 0 ${CARD_W} ${CARD_H}">
  <rect width="${CARD_W}" height="${CARD_H}" fill="${BACKGROUND}" />
  ${xml(content)}
</svg>`;
  const png = await sharp(Buffer.from(svg)).png().toBuffer();
  return new Response(new Uint8Array(png), { headers: { 'Content-Type': 'image/png' } });
}
