import { useEvmlTag } from "@evmcrispr/editor";
import { useState } from "react";
import type { Address } from "viem";
import { useWalletClient } from "wagmi";

import { Callout } from "./Callout";
import { CONTEXT_LABELS, type ExecutionContext } from "./context";
import { actionsToTxBuilderBatch } from "./safe-tx-builder";
import { buildFinalScript } from "./wrap";

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

export function SubmitStage({
  block,
  context,
  contextAddress,
  chainId,
  verified,
}: {
  block: string;
  context: ExecutionContext;
  /** Context address after ENS resolution. */
  contextAddress: Address | null;
  chainId: number;
  /** The protected batch passed a simulation in its current form. */
  verified: boolean;
}) {
  const tag = useEvmlTag();
  const { data: walletClient } = useWalletClient();
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
      {!verified && (
        <Callout tone="warn">
          <p>
            The protected batch has not passed a simulation in its current
            form. Simulate it in step 2 before submitting.
          </p>
        </Callout>
      )}

      <div>
        <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
          Final script ({CONTEXT_LABELS[context.kind]})
        </p>
        <pre className="p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap max-h-64 overflow-y-auto">
          {finalScript}
        </pre>
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <button
          type="button"
          disabled={!walletClient || busy}
          onClick={execute}
          className="px-5 py-2.5 rounded-lg text-sm font-semibold bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
        >
          {status.phase === "running"
            ? "Confirm in wallet…"
            : ACTION_LABELS[context.kind]}
        </button>

        {context.kind === "safe" && (
          <button
            type="button"
            disabled={busy}
            onClick={downloadBatch}
            className="px-5 py-2.5 rounded-lg text-sm font-semibold border border-[var(--color-bp-500)] text-[var(--color-bp-500)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
          >
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
