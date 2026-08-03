import type { Chain } from "viem";
import * as viemChains from "viem/chains";
import { createConfig, http } from "wagmi";
import { injected } from "wagmi/connectors";

function isChain(value: unknown): value is Chain {
  return (
    typeof value === "object" &&
    value !== null &&
    typeof (value as Chain).id === "number" &&
    typeof (value as Chain).name === "string"
  );
}

/** Every chain viem knows about, deduplicated by chain id. */
export const ALL_CHAINS: Chain[] = (() => {
  const byId = new Map<number, Chain>();
  for (const value of Object.values(viemChains)) {
    if (isChain(value) && !byId.has(value.id)) byId.set(value.id, value);
  }
  return [...byId.values()].sort((a, b) => a.name.localeCompare(b.name));
})();

export function chainById(id: number): Chain | undefined {
  return ALL_CHAINS.find((chain) => chain.id === id);
}

/** Default public transports for every known chain. */
export const transports = Object.fromEntries(
  ALL_CHAINS.map((chain) => [chain.id, http()]),
);

// Registering every viem chain lets wagmi's switchChain reach any of them
// (issuing wallet_addEthereumChain when the wallet lacks the network).
export const wagmiConfig = createConfig({
  chains: ALL_CHAINS as unknown as readonly [Chain, ...Chain[]],
  connectors: [injected()],
  transports,
});
