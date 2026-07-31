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
 *  both hit the same RPC endpoints (public defaults). */
export const transports = Object.fromEntries(
  CHAINS.map((chain) => [chain.id, http()]),
);

export const wagmiConfig = createConfig({
  chains: CHAINS,
  connectors: [
    injected(),
    // Auto-connects when the site runs inside the Safe{Wallet} app iframe.
    safe({ allowedDomains: [/app\.safe\.global$/], debug: false }),
  ],
  transports,
});
