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

import { ChainIcon } from "../ui/ChainIcon";
import {
  DEPLOYED_CONTRACTS,
  explorerAddressUrl,
  makePublicClient,
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

type RowStatus = "loading" | "deployed" | "missing" | "error";

// Starlight ships no reset, so a bare <button> keeps the browser's chrome.
const STATUS_LINK =
  "appearance-none border-0 bg-transparent p-0 cursor-pointer inline-flex items-center gap-1.5 text-sm text-[var(--color-bp-400)] underline-offset-4 hover:underline focus-visible:underline";

/**
 * One section per contract: its name and version, then the
 * networks it was checked on. A deterministic address says where the code
 * goes, not that it is there, so every status comes from a live read of the
 * chain, and a chain that could not be read says so instead of "pending deployment".
 */
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
    <div className="border-y border-[var(--color-ink-3)]/30">
      {DEPLOYED_CONTRACTS.map((contract, contractIndex) => (
        <section
          key={contract.key}
          aria-labelledby={`deployments-${contract.key}`}
          className="border-b border-[var(--color-ink-3)]/30 py-7 last:border-b-0"
        >
          <header className="mb-4 flex items-baseline gap-3">
            <h3
              id={`deployments-${contract.key}`}
              className="m-0 text-xl font-semibold text-[var(--color-ink)]"
            >
              {contract.name}
            </h3>
            <span className="font-mono text-xs text-[var(--color-ink-2)]">
              v{contract.version}
              {contract.released ? "" : " · unreleased"}
            </span>
          </header>

          <div className="overflow-x-auto">
            <table className="m-0 w-full min-w-[26rem] table-fixed border-collapse text-left text-sm">
              <caption className="sr-only">
                {contract.name}: status on each network
              </caption>
              <thead>
                <tr className="border-b border-[var(--color-ink-3)]/30 text-xs text-[var(--color-ink-2)]">
                  <th scope="col" className="w-[42%] py-2.5 pr-3 font-medium">
                    Network
                  </th>
                  <th scope="col" className="w-[24%] py-2.5 pr-3 font-medium">
                    Chain ID
                  </th>
                  <th scope="col" className="w-[34%] py-2.5 font-medium">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody>
                {MAJOR_CHAINS.map((chain, chainIndex) => {
                  const query = results[chainIndex];
                  const status: RowStatus = query.isPending
                    ? "loading"
                    : query.isError
                      ? "error"
                      : query.data![contractIndex]
                        ? "deployed"
                        : "missing";
                  const explorer = explorerAddressUrl(chain, contract.address);
                  return (
                    <tr
                      key={chain.id}
                      className="border-b border-[var(--color-ink-3)]/15 last:border-b-0"
                    >
                      <th
                        scope="row"
                        className="py-3 pr-3 font-medium whitespace-nowrap text-[var(--color-ink)]"
                      >
                        <ChainIcon
                          chainId={chain.id}
                          name={chain.name}
                          size={18}
                          className="inline-block align-[-0.2em] mr-2"
                        />
                        {chain.name}
                        {chain.testnet && (
                          <span className="ml-2 text-[10px] font-normal uppercase tracking-wide px-1.5 py-0.5 rounded border border-[var(--color-ink-3)]/40 text-[var(--color-ink-2)]">
                            testnet
                          </span>
                        )}
                      </th>
                      <td className="py-3 pr-3 font-mono text-xs tabular-nums text-[var(--color-ink-2)]">
                        {chain.id}
                      </td>
                      <td className="py-3 whitespace-nowrap">
                        {status === "loading" && (
                          <span className="text-[var(--color-ink-2)]">
                            Checking…
                          </span>
                        )}
                        {status === "deployed" &&
                          (explorer ? (
                            <a
                              href={explorer}
                              target="_blank"
                              rel="noopener noreferrer"
                              aria-label={`Deployed: view ${contract.name} on the ${chain.name} explorer`}
                              className={STATUS_LINK}
                            >
                              <span
                                aria-hidden="true"
                                className="size-1.5 shrink-0 rounded-full bg-[var(--color-ok)]"
                              />
                              Deployed ↗
                            </a>
                          ) : (
                            <span className="inline-flex items-center gap-1.5 text-[var(--color-ink)]">
                              <span
                                aria-hidden="true"
                                className="size-1.5 shrink-0 rounded-full bg-[var(--color-ok)]"
                              />
                              Deployed
                            </span>
                          ))}
                        {status === "missing" && (
                          <button
                            type="button"
                            onClick={() => onDeploy(chain)}
                            aria-label={`Pending deployment: deploy to ${chain.name}`}
                            className={STATUS_LINK}
                          >
                            <span
                              aria-hidden="true"
                              className="size-1.5 shrink-0 rounded-full border border-current"
                            />
                            Pending deployment ↓
                          </button>
                        )}
                        {status === "error" && (
                          <span
                            className="text-[var(--color-ink-2)]"
                            title="The chain's public RPC did not answer, so the status is unknown"
                          >
                            RPC unavailable
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </section>
      ))}
    </div>
  );
}
