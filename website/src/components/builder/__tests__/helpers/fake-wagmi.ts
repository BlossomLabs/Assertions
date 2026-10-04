import { createElement, Fragment, type ReactNode } from "react";
import { vi } from "vitest";

import type * as Real from "wagmi";

/**
 * Stands in for wagmi's hooks: no provider, no connector, no RPC. Tests
 * set who is connected (if anyone) on `wallet` before rendering.
 */
export const wallet: {
  address?: `0x${string}`;
  chain?: { id: number; name: string };
  /** What `useWalletClient` returns; any truthy value enables sending. */
  client?: unknown;
  connect: ReturnType<typeof vi.fn>;
  disconnect: ReturnType<typeof vi.fn>;
  switchChain: ReturnType<typeof vi.fn>;
} = {
  connect: vi.fn(),
  disconnect: vi.fn(),
  switchChain: vi.fn(),
};

export function resetWallet() {
  wallet.address = undefined;
  wallet.chain = undefined;
  wallet.client = undefined;
  wallet.connect = vi.fn();
  wallet.disconnect = vi.fn();
  wallet.switchChain = vi.fn();
}

export function fakeWagmiModule(real: typeof Real) {
  return {
    ...real,
    WagmiProvider: ({ children }: { children: ReactNode }) =>
      createElement(Fragment, null, children),
    useAccount: () => ({
      address: wallet.address,
      isConnected: !!wallet.address,
      chain: wallet.chain,
      chainId: wallet.chain?.id,
    }),
    useConnect: () => ({
      connect: wallet.connect,
      connectors: [{ id: "injected" }],
      isPending: false,
    }),
    useDisconnect: () => ({ disconnect: wallet.disconnect }),
    useSwitchChain: () => ({ switchChain: wallet.switchChain, isPending: false }),
    useWalletClient: () => ({ data: wallet.client }),
    usePublicClient: () => undefined,
  };
}
