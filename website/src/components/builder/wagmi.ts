import type { Transport } from "viem";
import { createConfig, http } from "wagmi";
import {
  arbitrum,
  base,
  gnosis,
  mainnet,
  optimism,
  polygon,
  sepolia,
} from "wagmi/chains";
import { injected, safe } from "wagmi/connectors";

import { rpcUrl } from "../deployments/rpc";

export const CHAINS = [
  mainnet,
  gnosis,
  base,
  optimism,
  arbitrum,
  polygon,
  sepolia,
] as const;

/** Per-chain transports, shared between wagmi and the EVML interpreter so
 *  both hit the same RPC endpoints (dRPC with a key, public defaults
 *  otherwise; see ../deployments/rpc.ts). */
export const transports = Object.fromEntries(
  CHAINS.map((chain) => [chain.id, http(rpcUrl(chain.id))]),
) as Record<(typeof CHAINS)[number]["id"], Transport>;

export const wagmiConfig = createConfig({
  chains: CHAINS,
  connectors: [
    injected(),
    // Auto-connects when the site runs inside the Safe{Wallet} app iframe.
    safe({ allowedDomains: [/app\.safe\.global$/], debug: false }),
  ],
  transports,
});
