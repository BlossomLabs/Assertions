import { useEffect, useMemo, useState } from "react";
import type { PublicClient } from "viem";
import { usePublicClient } from "wagmi";

import { RELEASED_CONTRACTS, makePublicClient } from "../deployments/shared";
import { chainById } from "../deployments/wagmi";
import { CHAINS } from "./wagmi";

/** Chains with first-class support (wagmi config, curated transports). */
export const OFFICIAL_CHAIN_IDS = new Set<number>(CHAINS.map((c) => c.id));

/**
 * A read client for any chain: the wagmi-configured one for official
 * chains, otherwise a viem client from the public registry's default RPC.
 * Undefined when the chain id is unknown to viem.
 */
export function useChainClient(chainId: number): PublicClient | undefined {
  const configured = usePublicClient({ chainId });
  return useMemo(() => {
    if (configured) return configured as unknown as PublicClient;
    const chain = chainById(chainId);
    return chain ? makePublicClient(chain) : undefined;
  }, [configured, chainId]);
}

export type ChainSupport =
  /** One of the officially supported chains: no check needed. */
  | { state: "official" }
  | { state: "unknown-chain" }
  | { state: "checking"; chainName: string }
  /** All canonical contracts have code on this chain. */
  | { state: "ok"; chainName: string }
  | { state: "missing"; chainName: string; missing: string[] }
  | { state: "error"; chainName: string };

/**
 * Whether the builder can work on `chainId`: official chains always can;
 * any other chain can when every released contract (the ones the SDK
 * compiles against; unreleased artifact candidates are not probed) has code
 * there. They live at the same CREATE2 address on every chain, and the
 * deployments page can put them on a missing one.
 */
export function useChainSupport(chainId: number): ChainSupport {
  const [support, setSupport] = useState<ChainSupport>({ state: "official" });

  useEffect(() => {
    if (OFFICIAL_CHAIN_IDS.has(chainId)) {
      setSupport({ state: "official" });
      return;
    }
    const chain = chainById(chainId);
    if (!chain) {
      setSupport({ state: "unknown-chain" });
      return;
    }
    const chainName = chain.name;
    let cancelled = false;
    setSupport({ state: "checking", chainName });
    void (async () => {
      try {
        const client = makePublicClient(chain);
        const codes = await Promise.all(
          RELEASED_CONTRACTS.map((c) => client.getCode({ address: c.address })),
        );
        if (cancelled) return;
        const missing = RELEASED_CONTRACTS.filter(
          (_, i) => !codes[i] || codes[i] === "0x",
        ).map((c) => c.name);
        setSupport(
          missing.length === 0
            ? { state: "ok", chainName }
            : { state: "missing", chainName, missing },
        );
      } catch {
        if (!cancelled) setSupport({ state: "error", chainName });
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [chainId]);

  return support;
}
