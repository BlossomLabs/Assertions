import { useEvmlTag } from "@evmcrispr/editor";
import { useState } from "react";
import type { Address } from "viem";
import { useAccount, useWalletClient } from "wagmi";

import { Callout } from "./Callout";
import {
  CONTEXT_LABELS,
  type ExecutionContext,
  senderMismatch,
} from "./context";
import { SimRing } from "./SimRing";
import { attributeFailure, type SimulationState } from "./simulation";
import { actionsToTxBuilderBatch } from "./safe-tx-builder";
import type { EyeState } from "./timeline";
import { WalletConnect } from "./WalletConnect";
import { buildFinalScript } from "./wrap";
import { ButtonIcon } from "./ButtonIcon";

/** What the gate ring's state means for submitting. */
const GATE_TEXT: Record<EyeState, { lead: string; rest: string; cls: string }> = {
  asleep: {
    lead: "Nothing to submit.",
    rest: "Add actions to the batch in step 1.",
    cls: "text-[var(--color-ink-2)]",
  },
  stale: {
    lead: "Out of date.",
    rest: "The protected batch has not passed a simulation in its current form. Simulate it in step 2 before submitting.",
    cls: "text-amber-700 dark:text-amber-300",
  },
  running: {
    lead: "Simulating…",
    rest: "Running the protected batch on a fork.",
    cls: "text-[var(--color-bp-400)]",
  },
  pass: {
    lead: "Passed.",
    rest: "The protected batch passes a simulation in its current form.",
    cls: "text-[var(--color-ok)]",
  },
  fail: {
    lead: "Failed.",
    rest: "The protected batch fails its simulation. See step 2.",
    cls: "text-[var(--color-err)]",
  },
};

const ACTION_LABELS: Record<ExecutionContext["kind"], string> = {
  eoa: "Execute batch",
  safe: "Propose to Safe",
  governor: "Create Governor proposal",
  aragonosx: "Create DAO proposal",
};

function downloadJson(value: unknown, filename: string) {
  const blob = new Blob([JSON.stringify(value, null, 2)], {
    type: "application/json",
  });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}

const short = (address: Address | undefined) =>
  address ? `${address.slice(0, 6)}…${address.slice(-4)}` : "the default account";

/**
 * The gate's sentence. A finished run of the batch as it is now gets a
 * receipt: when it ran, as which account, and on a failure whether an
 * action or an assertion stopped it.
 */
function gateText(
  gate: EyeState,
  simulation: SimulationState | undefined,
): { lead: string; rest: string } {
  const base = GATE_TEXT[gate];
  const ran = simulation?.simulated;
  if ((gate !== "pass" && gate !== "fail") || !simulation || !ran) return base;
  const at = simulation.finishedAt
    ? ` at ${new Date(simulation.finishedAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`
    : "";
  const receipt = `Simulated on a fork${at}, as ${short(ran.from)}.`;
  if (gate === "pass") return { lead: base.lead, rest: receipt };
  const error = simulation.result?.error;
  const where = error ? attributeFailure(error, ran.script) : null;
  return {
    lead: where ? `Failed at an ${where.kind}.` : base.lead,
    rest: `${receipt} Nothing would have been executed. See step 2.`,
  };
}

export function SubmitStage({
  block,
  context,
  contextAddress,
  chainId,
  gate,
  simulation,
}: {
  block: string;
  context: ExecutionContext;
  /** Context address after ENS resolution. */
  contextAddress: Address | null;
  chainId: number;
  /** The state of the protected batch's simulation: `pass` once the
   *  batch passed a simulation in its current form. */
  gate: EyeState;
  /** That simulation, for the receipt the gate shows. */
  simulation?: SimulationState;
}) {
  const text = gateText(gate, simulation);
  const tag = useEvmlTag();
  const { address: connected, isConnected } = useAccount();
  const { data: walletClient } = useWalletClient();
  // Built for an impersonated account, another wallet connected.
  const wrongSender = senderMismatch(context, connected, contextAddress);
  const [status, setStatus] = useState<
    | { phase: "idle" }
    | { phase: "running" }
    | { phase: "done" }
    | { phase: "downloading" }
    | { phase: "downloaded" }
    | { phase: "error"; message: string }
  >({ phase: "idle" });

  const finalScript = buildFinalScript(block, context, chainId);
  const busy = status.phase === "running" || status.phase === "downloading";

  const execute = async () => {
    if (!walletClient) return;
    setStatus({ phase: "running" });
    try {
      await tag.script(finalScript).execute(walletClient);
      setStatus({ phase: "done" });
    } catch (e) {
      setStatus({
        phase: "error",
        message: e instanceof Error ? e.message : String(e),
      });
    }
  };

  /** Resolve the raw (unwrapped) block into transactions and save them as a
   *  Safe Transaction Builder batch JSON. */
  const downloadBatch = async () => {
    setStatus({ phase: "downloading" });
    try {
      const actions = await tag.script(block).interpret();
      const batch = actionsToTxBuilderBatch(actions, {
        chainId,
        safeAddress: contextAddress ?? undefined,
      });
      downloadJson(batch, `safe-batch-${chainId}.json`);
      setStatus({ phase: "downloaded" });
    } catch (e) {
      setStatus({
        phase: "error",
        message: e instanceof Error ? e.message : String(e),
      });
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-4">
        <SimRing state={gate} size={40} />
        <p className="text-sm text-[var(--color-ink-2)]">
          <span className={`font-semibold ${GATE_TEXT[gate].cls}`}>
            {text.lead}
          </span>{" "}
          {text.rest}
        </p>
      </div>

      <div>
        <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
          Final script ({CONTEXT_LABELS[context.kind]})
        </p>
        <pre className="p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap max-h-64 overflow-y-auto">
          {finalScript}
        </pre>
      </div>

      {wrongSender && contextAddress && (
        <Callout tone="warn">
          <p>
            This batch was built to run as{" "}
            <code className="font-mono">
              {contextAddress.slice(0, 6)}…{contextAddress.slice(-4)}
            </code>
            , but another wallet is connected. Connect that account to send
            it, or clear the account you are simulating as in step 1.
          </p>
        </Callout>
      )}

      <div className="flex flex-wrap items-center gap-3">
        {/* Sending is the one thing that needs a wallet. */}
        {isConnected ? (
          <button
            type="button"
            disabled={!walletClient || busy || wrongSender}
            onClick={execute}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-semibold bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
          >
            <ButtonIcon name="run" />
            {status.phase === "running"
              ? "Confirm in wallet…"
              : ACTION_LABELS[context.kind]}
          </button>
        ) : (
          <WalletConnect />
        )}

        {context.kind === "safe" && (
          <button
            type="button"
            disabled={busy}
            onClick={downloadBatch}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg text-sm font-semibold border border-[var(--color-bp-500)] text-[var(--color-bp-500)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
          >
            <ButtonIcon name="download" />
            {status.phase === "downloading"
              ? "Preparing JSON…"
              : "Download Transaction Builder JSON"}
          </button>
        )}
      </div>

      {status.phase === "done" && (
        <p className="text-sm text-[var(--color-ok)]">
          {context.kind === "eoa"
            ? "Batch executed."
            : "Proposal submitted. It now goes through its normal review/vote flow."}
        </p>
      )}
      {status.phase === "downloaded" && (
        <p className="text-sm text-[var(--color-ok)]">
          JSON downloaded. Import it in Safe's Transaction Builder app.
        </p>
      )}
      {status.phase === "error" && (
        <p className="text-xs font-mono text-[var(--color-err)] whitespace-pre-wrap break-all">
          {status.message}
        </p>
      )}
    </div>
  );
}
