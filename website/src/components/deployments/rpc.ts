/**
 * RPC endpoint selection. With `VITE_DRPC_API_KEY` set (website/.env, read at
 * build time and inlined into the bundle) the chains below go through dRPC's
 * load balancer; without it every chain stays on viem's public defaults.
 *
 * The site is static, so the key is visible to anyone who opens the bundle:
 * restrict it to this site's domains in the dRPC dashboard.
 */
import {
  arbitrum,
  base,
  gnosis,
  mainnet,
  optimism,
  polygon,
  sepolia,
} from "viem/chains";

/** chainId -> dRPC network slug, for the chains the builder offers. */
export const DRPC_SLUGS: Record<number, string> = {
  [mainnet.id]: "ethereum",
  [gnosis.id]: "gnosis",
  [base.id]: "base",
  [optimism.id]: "optimism",
  [arbitrum.id]: "arbitrum",
  [polygon.id]: "polygon",
  [sepolia.id]: "sepolia",
};

export function drpcUrl(
  chainId: number,
  key: string | undefined,
): string | undefined {
  const slug = DRPC_SLUGS[chainId];
  return key && slug ? `https://lb.drpc.live/${slug}/${key}` : undefined;
}

const DRPC_API_KEY = import.meta.env.VITE_DRPC_API_KEY as string | undefined;

/** The configured endpoint for a chain, or undefined for viem's default. */
export function rpcUrl(chainId: number): string | undefined {
  return drpcUrl(chainId, DRPC_API_KEY);
}
