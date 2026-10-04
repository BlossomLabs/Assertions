import { useState } from "react";
import type { Address } from "viem";
import { isAddress } from "viem";
import { useAccount, useSwitchChain } from "wagmi";

import { Callout } from "./Callout";
import {
  CONTEXT_LABELS,
  type ContextKind,
  type ExecutionContext,
} from "./context";
import { RELEASED_CONTRACTS } from "../deployments/shared";
import { type ChainSupport, OFFICIAL_CHAIN_IDS } from "./useChainSupport";
import type { AddressCheck } from "./useContextAddressCheck";
import { ChainIcon } from "../ui/ChainIcon";
import { ExecutorIcon } from "../ui/ExecutorIcon";
import { WalletConnect } from "./WalletConnect";
import { CHAINS } from "./wagmi";

const inputCls =
  "w-full px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 " +
  "focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-sm placeholder:text-[var(--color-ink-3)]";

/** "A, B and C" */
function listNames(names: string[]): string {
  if (names.length <= 1) return names.join("");
  return `${names.slice(0, -1).join(", ")} and ${names[names.length - 1]}`;
}

const CONTEXT_HELP: Record<ContextKind, string> = {
  eoa: "Execute the whole block as one atomic batch from a wallet (EIP-5792 wallet_sendCalls; uses the wallet's EIP-7702 delegation when available).",
  safe: "Queue the block as a single Safe transaction on the Safe Transaction Service, signed by you as owner or delegate.",
  governor: "Create an OpenZeppelin Governor proposal whose calls are the block's actions.",
  aragonosx: "Create a proposal on one of an Aragon OSx DAO's governance plugins.",
};

export function ContextSelector({
  context,
  onChange,
  resolved,
  check,
  chainId,
  onChainChange,
  chainSupport,
}: {
  context: ExecutionContext;
  onChange: (next: ExecutionContext) => void;
  /** Context address after ENS resolution (null while unresolved). */
  resolved: Address | null;
  /** On-chain verification of the resolved address. */
  check: AddressCheck;
  /** The network the batch targets. */
  chainId: number;
  onChainChange: (chainId: number) => void;
  /** Canonical-deployment status for custom chains. */
  chainSupport: ChainSupport;
}) {
  const { isConnected, chain, chainId: walletChainId } = useAccount();
  const { switchChain, isPending: switching } = useSwitchChain();
  // A wallet's other-account field stays behind a link until asked for.
  const [asOtherOpen, setAsOtherOpen] = useState(false);
  const showAddress =
    context.kind !== "eoa" || asOtherOpen || !!context.address;

  // The last chip is a chain-id input for chains outside the official list.
  const [otherActive, setOtherActive] = useState(
    () => !OFFICIAL_CHAIN_IDS.has(chainId),
  );
  const [otherInput, setOtherInput] = useState(() =>
    OFFICIAL_CHAIN_IDS.has(chainId) ? "" : String(chainId),
  );

  const walletMismatch =
    isConnected && walletChainId !== undefined && walletChainId !== chainId;
  const walletChainName = chain?.name ?? `chain ${walletChainId}`;
  const targetChain = CHAINS.find((c) => c.id === chainId);
  const customSelected = otherActive || !OFFICIAL_CHAIN_IDS.has(chainId);

  return (
    <div className="space-y-5">
      {/* Network the batch targets */}
      <div>
        <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
          Network
        </label>
        <div className="flex items-center gap-1.5 flex-wrap">
          {CHAINS.map((c) => (
            <button
              key={c.id}
              type="button"
              onClick={() => {
                setOtherActive(false);
                setOtherInput("");
                onChainChange(c.id);
              }}
              className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-all ${
                !customSelected && chainId === c.id
                  ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 text-[var(--color-bp-300)]"
                  : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/50"
              }`}
            >
              <ChainIcon chainId={c.id} name={c.name} size={14} />
              {c.name}
            </button>
          ))}
          {/* Any other chain, by id: a chip you type into. */}
          <input
            aria-label="Another network, by chain ID"
            className={`w-24 px-3 py-1.5 rounded-full text-xs font-medium border bg-transparent transition-all focus:outline-none focus:border-[var(--color-bp-400)] placeholder:text-[var(--color-ink-2)] ${
              customSelected
                ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 text-[var(--color-bp-300)]"
                : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/50"
            }`}
            placeholder="Chain ID"
            inputMode="numeric"
            value={otherInput}
            onChange={(e) => {
              const v = e.target.value.trim();
              setOtherInput(v);
              const valid = /^\d+$/.test(v);
              setOtherActive(valid);
              if (valid) onChainChange(Number(v));
            }}
            spellCheck={false}
          />
        </div>
        {customSelected && (
          <div className="mt-3 space-y-1.5">
            {chainSupport.state === "checking" && (
              <p className="text-xs text-[var(--color-ink-3)]">
                Checking the canonical deployments on {chainSupport.chainName}…
              </p>
            )}
            {chainSupport.state === "ok" && (
              <p className="text-xs text-[var(--color-ok)]">
                {listNames(RELEASED_CONTRACTS.map((c) => c.name))} found on{" "}
                {chainSupport.chainName}. The builder works here.
              </p>
            )}
            {chainSupport.state === "missing" && (
              <Callout tone="error">
                <p>
                  {listNames(chainSupport.missing)}{" "}
                  {chainSupport.missing.length === 1 ? "is" : "are"} not
                  deployed on <strong>{chainSupport.chainName}</strong>.{" "}
                  <a
                    href="/docs/contracts/deployments"
                    className="font-medium underline hover:text-red-900 dark:hover:text-red-200"
                  >
                    Deploy the canonical contracts
                  </a>{" "}
                  first.
                </p>
              </Callout>
            )}
            {chainSupport.state === "unknown-chain" && otherInput !== "" && (
              <Callout tone="error">
                <p>
                  Chain id not in the public registry, so no RPC is known for
                  it.
                </p>
              </Callout>
            )}
            {chainSupport.state === "error" && (
              <Callout tone="error">
                <p>Could not reach an RPC for {chainSupport.chainName}.</p>
              </Callout>
            )}
          </div>
        )}
        {walletMismatch && (
          <Callout tone="warn">
            <p>
              Your wallet is connected to <strong>{walletChainName}</strong>,
              but this batch targets{" "}
              <strong>{targetChain?.name ?? `chain ${chainId}`}</strong>.
              Addresses, ABIs and simulations all use the target network.
            </p>
            {targetChain ? (
              <button
                type="button"
                disabled={switching}
                onClick={() => switchChain({ chainId })}
                className="font-medium underline hover:text-amber-900 dark:hover:text-amber-100 disabled:opacity-50"
              >
                {switching
                  ? "Switching…"
                  : `Switch wallet to ${targetChain.name}`}
              </button>
            ) : (
              <p className="text-amber-800/80 dark:text-amber-200/80">
                The wallet will be asked to switch when executing.
              </p>
            )}
          </Callout>
        )}
      </div>

      {/* Execution path */}
      <div>
        <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
          From
        </label>
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-2">
          {(Object.keys(CONTEXT_LABELS) as ContextKind[]).map((kind) => (
          <button
            key={kind}
            type="button"
            onClick={() => onChange({ kind })}
            className={`inline-flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg text-sm font-medium border transition-all ${
              context.kind === kind
                ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 text-[var(--color-bp-300)]"
                : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/50"
            }`}
          >
              <ExecutorIcon kind={kind} />
              {CONTEXT_LABELS[kind]}
            </button>
          ))}
        </div>
        <p className="mt-1.5 text-xs text-[var(--color-ink-3)] leading-relaxed">
          {CONTEXT_HELP[context.kind]}
        </p>
      </div>

      {/* Per-context inputs; a wallet gets its connection and, on request,
          another account to simulate as */}
      <div className="space-y-3">
        <div>
          <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
            {context.kind === "eoa"
              ? "Wallet"
              : context.kind === "safe"
                ? "Safe address"
                : context.kind === "governor"
                  ? "Governor address"
                  : "DAO address"}
          </label>
          {/* A wallet: connect one, or simulate as any other account. */}
          <div className="flex items-center gap-3 flex-wrap">
            {context.kind === "eoa" && (
              <>
                <WalletConnect />
                <span className="text-xs text-[var(--color-ink-3)]">or</span>
              </>
            )}
            {showAddress ? (
              <input
                className={`${inputCls} flex-1 min-w-48 w-auto`}
                placeholder={
                  context.kind === "eoa"
                    ? "Simulate as 0x… or name.eth"
                    : "0x… or name.eth"
                }
                aria-label={
                  context.kind === "eoa" ? "Account to simulate as" : undefined
                }
                value={context.address ?? ""}
                onChange={(e) =>
                  onChange({ ...context, address: e.target.value.trim() })
                }
                // Opened from the link: take the cursor, and fold back into
                // the link if left empty.
                autoFocus={context.kind === "eoa" && asOtherOpen}
                onBlur={() => {
                  if (!context.address) setAsOtherOpen(false);
                }}
                spellCheck={false}
              />
            ) : (
              <button
                type="button"
                onClick={() => setAsOtherOpen(true)}
                className="text-sm text-[var(--color-bp-300)] hover:underline"
              >
                simulate as another account
              </button>
            )}
          </div>
          {context.address &&
            !isAddress(context.address) &&
            !context.address.includes(".") && (
              <Callout tone="error">
                <p>Not a valid address or ENS name.</p>
              </Callout>
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
            <Callout tone="error">
              <p>{check.message}</p>
            </Callout>
          )}
          {context.kind === "eoa" && (
            <p className="mt-1.5 text-xs text-[var(--color-ink-3)] leading-relaxed">
              {context.address
                ? "Simulations run as this account. Only this account can send the batch."
                : "Simulations run as the connected wallet, or as another account you choose. Connecting is only needed to send the batch."}
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
    </div>
  );
}
