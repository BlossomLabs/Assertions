// Social cards need an absolute address, and the site has no single host: it
// is served from IPFS through gateways. This is the one the cards point at.
export const SITE = 'https://assertions.eth.limo';

/** The card of every page that has none of its own: the hamsa beside one line, captured by capture-og.mjs. */
export const DEFAULT_CARD = '/og/default.png';
