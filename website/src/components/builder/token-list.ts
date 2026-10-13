import type { TokenListEntry } from "@evmcrispr/sdk";

/**
 * The chain's token list, the one EVMcrispr resolves symbols against
 * (`$std:tokenlist`'s default): the only thing that may name a token in a
 * script. Fetched once per chain; a failed fetch is not remembered, and
 * reads as an empty list (no token gets a name).
 */

const lists = new Map<number, Promise<TokenListEntry[]>>();

export function tokenList(chainId: number): Promise<TokenListEntry[]> {
  let list = lists.get(chainId);
  if (!list) {
    list = fetch(`https://api.evmcrispr.com/tokenlist/${chainId}`)
      .then((response) => (response.ok ? response.json() : Promise.reject()))
      .then((body: { tokens?: unknown }) =>
        Array.isArray(body.tokens) ? (body.tokens as TokenListEntry[]) : [],
      )
      .catch(() => {
        lists.delete(chainId);
        return [];
      });
    lists.set(chainId, list);
  }
  return list;
}
