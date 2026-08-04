import type { Address } from "viem";
import { isAddress } from "viem";
import { useAccount, useConnect, useDisconnect } from "wagmi";

import {
  CONTEXT_LABELS,
  type ContextKind,
  type ExecutionContext,
} from "./context";
import type { AddressCheck } from "./useContextAddressCheck";

const inputCls =
  "w-full px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 " +
  "focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-sm placeholder:text-[var(--color-ink-3)]";

const CONTEXT_HELP: Record<ContextKind, string> = {
  eoa: "Execute the whole block as one atomic batch from your connected wallet (EIP-5792 wallet_sendCalls; uses your wallet's EIP-7702 delegation when available).",
  safe: "Queue the block as a single Safe transaction on the Safe Transaction Service, signed by you as owner or delegate.",
  governor: "Create an OpenZeppelin Governor proposal whose calls are the block's actions.",
  aragonosx: "Create a proposal on one of an Aragon OSx DAO's governance plugins.",
};

export function ContextSelector({
  context,
  onChange,
  resolved,
  check,
}: {
  context: ExecutionContext;
  onChange: (next: ExecutionContext) => void;
  /** Context address after ENS resolution (null while unresolved). */
  resolved: Address | null;
  /** On-chain verification of the resolved address. */
  check: AddressCheck;
}) {
  const { address, isConnected, chain } = useAccount();
  const { connect, connectors, isPending } = useConnect();
  const { disconnect } = useDisconnect();

  const injected = connectors.find((c) => c.id === "injected") ?? connectors[0];

  return (
    <div className="space-y-5">
      {/* Wallet */}
      <div className="flex items-center justify-between gap-4 flex-wrap">
        {isConnected && address ? (
          <div className="flex items-center gap-3">
            <span className="size-2 rounded-full bg-[var(--color-ok)]" />
            <span className="font-mono text-sm">
              {address.slice(0, 6)}…{address.slice(-4)}
            </span>
            {chain && (
              <span className="text-xs px-2 py-0.5 rounded-full border border-[var(--color-ink-3)]/30 text-[var(--color-ink-2)]">
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
        ) : (
          <button
            type="button"
            disabled={isPending || !injected}
            onClick={() => injected && connect({ connector: injected })}
            className="px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-50 transition-colors"
          >
            {isPending ? "Connecting…" : "Connect wallet"}
          </button>
        )}
      </div>

      {/* Execution path */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-2">
        {(Object.keys(CONTEXT_LABELS) as ContextKind[]).map((kind) => (
          <button
            key={kind}
            type="button"
            onClick={() => onChange({ kind })}
            className={`px-3 py-2.5 rounded-lg text-sm font-medium border transition-all ${
              context.kind === kind
                ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 text-[var(--color-bp-300)]"
                : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/50"
            }`}
          >
            {CONTEXT_LABELS[kind]}
          </button>
        ))}
      </div>
      <p className="text-xs text-[var(--color-ink-3)] leading-relaxed">
        {CONTEXT_HELP[context.kind]}
      </p>

      {/* Per-context inputs */}
      {context.kind !== "eoa" && (
        <div className="space-y-3">
          <div>
            <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
              {context.kind === "safe"
                ? "Safe address"
                : context.kind === "governor"
                  ? "Governor address"
                  : "DAO address"}
            </label>
            <input
              className={inputCls}
              placeholder="0x… or name.eth"
              value={context.address ?? ""}
              onChange={(e) =>
                onChange({ ...context, address: e.target.value.trim() })
              }
              spellCheck={false}
            />
            {context.address &&
              !isAddress(context.address) &&
              !context.address.includes(".") && (
                <p className="mt-1 text-xs text-[var(--color-err)]">
                  Not a valid address or ENS name.
                </p>
              )}
            {check.state !== "ok" &&
              resolved &&
              context.address &&
              !isAddress(context.address) && (
                <p className="mt-1 text-xs font-mono text-[var(--color-ink-3)]">
                  {resolved}
                </p>
              )}
            {check.state === "resolving" && (
              <p className="mt-1 text-xs text-[var(--color-ink-3)]">
                Resolving ENS name…
              </p>
            )}
            {check.state === "checking" && (
              <p className="mt-1 text-xs text-[var(--color-ink-3)]">
                Checking the contract…
              </p>
            )}
            {check.state === "ok" && (
              <p className="mt-1 text-xs">
                <span className="text-[var(--color-ok)]">{check.message}</span>
                {resolved && context.address && !isAddress(context.address) && (
                  <span className="font-mono text-[var(--color-ink-3)]">
                    {" · "}
                    {resolved}
                  </span>
                )}
              </p>
            )}
            {check.state === "error" && (
              <p className="mt-1 text-xs text-[var(--color-err)]">
                {check.message}
              </p>
            )}
          </div>
          {context.kind === "aragonosx" && (
            <div>
              <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
                Governance plugin
              </label>
              <input
                className={inputCls}
                placeholder="token-voting, multisig, or plugin address"
                value={context.plugin ?? ""}
                onChange={(e) => onChange({ ...context, plugin: e.target.value.trim() })}
                spellCheck={false}
              />
            </div>
          )}
          {(context.kind === "governor" || context.kind === "aragonosx") && (
            <div>
              <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
                Proposal description{" "}
                <span className="text-[var(--color-ink-3)]">(optional)</span>
              </label>
              <input
                className={inputCls}
                placeholder="What does this proposal do?"
                value={context.description ?? ""}
                onChange={(e) =>
                  onChange({ ...context, description: e.target.value })
                }
              />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
