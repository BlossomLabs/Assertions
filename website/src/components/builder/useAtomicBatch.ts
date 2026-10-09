import { useAccount, useCapabilities } from "wagmi";

/** Whether the connected wallet can send an atomic batch: not yet known,
 *  yes, or no. */
export type AtomicBatch = "unknown" | "yes" | "no";

/**
 * Asks the connected wallet whether it can send an atomic batch on a
 * network (EIP-5792 `wallet_getCapabilities`). A wallet executes the block
 * as one atomic batch or not at all: sent call by call, a failed assertion
 * would no longer undo the calls before it. A wallet that cannot answer
 * does not batch.
 */
export function useAtomicBatch(chainId: number, enabled: boolean): AtomicBatch {
  const { address, isConnected } = useAccount();
  const asked = enabled && isConnected;
  const capabilities = useCapabilities({
    account: address,
    chainId,
    query: { enabled: asked, retry: false, staleTime: 60_000 },
  });
  if (!asked) return "unknown";
  if (capabilities.isError) return "no";
  if (!capabilities.isSuccess) return "unknown";
  const status = capabilities.data?.atomic?.status;
  return status === "supported" || status === "ready" ? "yes" : "no";
}
