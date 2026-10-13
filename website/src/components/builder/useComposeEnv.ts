import { type TokenListEntry, symbolInList } from "@evmcrispr/sdk";
import { useCallback, useEffect, useMemo } from "react";
import { type Address, parseAbiItem } from "viem";

import { chainById } from "../deployments/wagmi";
import type { ComposeEnv } from "./compose-call";
import { tokenList } from "./token-list";
import { useChainClient } from "./useChainSupport";

const DECIMALS = [parseAbiItem("function decimals() view returns (uint8)")];

/**
 * What composing a call reads from the chain the batch targets: its token
 * list (asked for as soon as the chain is known, so that it is there by
 * the time an action is added) and a token's `decimals()`. Shared by the
 * contract form and the Transaction Builder import, which write actions
 * the same way.
 */
export function useComposeEnv(chainId: number) {
  const chainClient = useChainClient(chainId);
  useEffect(() => {
    void tokenList(chainId);
  }, [chainId]);
  const nativeSymbol = chainById(chainId)?.nativeCurrency.symbol ?? "ETH";

  const decimalsOf = useCallback(
    async (address: Address): Promise<number | undefined> => {
      if (!chainClient) return undefined;
      const decimals = await chainClient.readContract({
        address,
        abi: DECIMALS,
        functionName: "decimals",
      });
      return typeof decimals === "number" ? decimals : undefined;
    },
    [chainClient],
  );

  /** The symbol the chain's token list resolves to exactly this address:
   *  the only name a token is shown or written under. */
  const listedSymbol = useCallback(
    async (address: Address): Promise<string | undefined> =>
      symbolInList(await tokenList(chainId), chainId, nativeSymbol, address) ??
      undefined,
    [chainId, nativeSymbol],
  );

  const env = useCallback(
    async (ensToVar: ComposeEnv["ensToVar"]): Promise<ComposeEnv> => ({
      chainId,
      nativeSymbol,
      tokens: (await tokenList(chainId)) as readonly TokenListEntry[],
      decimalsOf,
      ensToVar,
    }),
    [chainId, nativeSymbol, decimalsOf],
  );

  return useMemo(
    () => ({ env, decimalsOf, listedSymbol }),
    [env, decimalsOf, listedSymbol],
  );
}
