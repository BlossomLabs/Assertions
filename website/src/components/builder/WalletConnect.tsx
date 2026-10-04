import { useAccount, useConnect, useDisconnect } from "wagmi";

import { ChainIcon } from "../ui/ChainIcon";
import { WalletIcon } from "../ui/ExecutorIcon";

/**
 * The wallet connection, wherever the builder needs one: a Connect button
 * until a wallet is connected, then its address and network with a way to
 * disconnect. Connecting is only required to send the batch, so this sits
 * in Submit, and under "A wallet" for batches that run as the connected
 * wallet.
 */
export function WalletConnect() {
  const { address, isConnected, chain } = useAccount();
  const { connect, connectors, isPending } = useConnect();
  const { disconnect } = useDisconnect();
  const injected = connectors.find((c) => c.id === "injected") ?? connectors[0];

  if (isConnected && address) {
    return (
      <div className="flex items-center gap-3 flex-wrap">
        <span className="size-2 rounded-full bg-[var(--color-ok)]" />
        <span className="font-mono text-sm">
          {address.slice(0, 6)}…{address.slice(-4)}
        </span>
        {chain && (
          <span className="inline-flex items-center gap-1.5 text-xs px-2 py-0.5 rounded-full border border-[var(--color-ink-3)]/30 text-[var(--color-ink-2)]">
            <ChainIcon chainId={chain.id} name={chain.name} size={12} />
            {chain.name}
          </span>
        )}
        <button
          type="button"
          onClick={() => disconnect()}
          className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-err)] transition-colors"
        >
          Disconnect
        </button>
      </div>
    );
  }
  return (
    <button
      type="button"
      disabled={isPending || !injected}
      onClick={() => injected && connect({ connector: injected })}
      className="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-50 transition-colors"
    >
      <WalletIcon />
      {isPending ? "Connecting…" : "Connect wallet"}
    </button>
  );
}
