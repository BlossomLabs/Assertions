import { useQueries } from "@tanstack/react-query";
import type { Chain } from "viem";
import {
  arbitrum,
  base,
  gnosis,
  mainnet,
  optimism,
  polygon,
  sepolia,
} from "viem/chains";

import {
  DEPLOYED_CONTRACTS,
  explorerAddressUrl,
  makePublicClient,
  shortAddress,
} from "./shared";

export const MAJOR_CHAINS: Chain[] = [
  mainnet,
  optimism,
  base,
  arbitrum,
  polygon,
  gnosis,
  sepolia,
];

type RowStatus = "loading" | "deployed" | "partial" | "missing" | "error";

export function DeploymentsTable({
  onDeploy,
}: {
  onDeploy: (chain: Chain) => void;
}) {
  const results = useQueries({
    queries: MAJOR_CHAINS.map((chain) => ({
      queryKey: ["assertions-deployed", chain.id],
      queryFn: async () => {
        const client = makePublicClient(chain);
        const codes = await Promise.all(
          DEPLOYED_CONTRACTS.map((contract) =>
            client.getCode({ address: contract.address }),
          ),
        );
        return DEPLOYED_CONTRACTS.map(
          (_, i) => codes[i] !== undefined && codes[i] !== "0x",
        );
      },
      staleTime: 60_000,
      retry: 1,
    })),
  });

  return (
    <div className="rounded-2xl border border-[var(--color-ink-3)]/20 bg-[var(--color-surface-2)] overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[var(--color-ink-3)]/20 text-left text-xs text-[var(--color-ink-3)]">
              <th className="px-5 py-3 font-medium">Network</th>
              <th className="px-5 py-3 font-medium">Chain ID</th>
              <th className="px-5 py-3 font-medium">Status</th>
              <th className="px-5 py-3 font-medium">Contracts</th>
            </tr>
          </thead>
          <tbody>
            {MAJOR_CHAINS.map((chain, i) => {
              const query = results[i];
              const deployedFlags = query.data;
              const status: RowStatus = query.isPending
                ? "loading"
                : query.isError
                  ? "error"
                  : deployedFlags!.every(Boolean)
                    ? "deployed"
                    : deployedFlags!.some(Boolean)
                      ? "partial"
                      : "missing";
              return (
                <tr
                  key={chain.id}
                  className="border-b border-[var(--color-ink-3)]/10 last:border-b-0"
                >
                  <td className="px-5 py-3 font-medium whitespace-nowrap">
                    {chain.name}
                    {chain.testnet && (
                      <span className="ml-2 text-[10px] uppercase tracking-wide px-1.5 py-0.5 rounded border border-[var(--color-ink-3)]/30 text-[var(--color-ink-3)]">
                        testnet
                      </span>
                    )}
                  </td>
                  <td className="px-5 py-3 font-mono text-[var(--color-ink-2)]">
                    {chain.id}
                  </td>
                  <td className="px-5 py-3 whitespace-nowrap">
                    {status === "loading" && (
                      <span className="text-[var(--color-ink-3)]">Checking…</span>
                    )}
                    {status === "deployed" && (
                      <span className="inline-flex items-center gap-1.5 text-[var(--color-ok)]">
                        <span className="size-1.5 rounded-full bg-[var(--color-ok)]" />
                        Deployed
                      </span>
                    )}
                    {status === "partial" && (
                      <button
                        type="button"
                        onClick={() => onDeploy(chain)}
                        className="inline-flex items-center gap-1.5 text-[var(--color-bp-300)] hover:text-[var(--color-bp-400)] font-medium transition-colors"
                      >
                        <span className="size-1.5 rounded-full border border-current bg-[var(--color-bp-300)]/40" />
                        Partial — finish the deployment ↓
                      </button>
                    )}
                    {status === "missing" && (
                      <button
                        type="button"
                        onClick={() => onDeploy(chain)}
                        className="inline-flex items-center gap-1.5 text-[var(--color-bp-300)] hover:text-[var(--color-bp-400)] font-medium transition-colors"
                      >
                        <span className="size-1.5 rounded-full border border-current" />
                        Not deployed — deploy it ↓
                      </button>
                    )}
                    {status === "error" && (
                      <span
                        className="text-[var(--color-ink-3)]"
                        title="Could not reach the chain's public RPC"
                      >
                        RPC unreachable
                      </span>
                    )}
                  </td>
                  <td className="px-5 py-3 font-mono whitespace-nowrap">
                    <div className="space-y-0.5">
                      {DEPLOYED_CONTRACTS.map((contract, j) => {
                        const explorer = explorerAddressUrl(
                          chain,
                          contract.address,
                        );
                        const isDeployed = deployedFlags?.[j] === true;
                        return (
                          <div
                            key={contract.key}
                            className="flex items-baseline gap-2"
                          >
                            <span className="text-[10px] uppercase tracking-wide text-[var(--color-ink-3)] w-16">
                              {contract.key}
                            </span>
                            {isDeployed && explorer ? (
                              <a
                                href={explorer}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="text-[var(--color-bp-300)] hover:underline"
                              >
                                {shortAddress(contract.address)} ↗
                              </a>
                            ) : (
                              <span className="text-[var(--color-ink-3)]">
                                {shortAddress(contract.address)}
                              </span>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
