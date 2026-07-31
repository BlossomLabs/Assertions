import { useState } from "react";
import { useWalletClient } from "wagmi";

import { CONTEXT_LABELS, type ExecutionContext } from "./context";
import { evml } from "./evml";
import { buildFinalScript } from "./wrap";

const ACTION_LABELS: Record<ExecutionContext["kind"], string> = {
  eoa: "Execute batch",
  safe: "Propose to Safe",
  governor: "Create Governor proposal",
  aragonosx: "Create DAO proposal",
};

export function ExecuteStep({
  block,
  context,
  chainId,
}: {
  block: string;
  context: ExecutionContext;
  chainId: number | undefined;
}) {
  const { data: walletClient } = useWalletClient();
  const [status, setStatus] = useState<
    | { phase: "idle" }
    | { phase: "running" }
    | { phase: "done" }
    | { phase: "error"; message: string }
  >({ phase: "idle" });

  const finalScript = buildFinalScript(block, context);

  const execute = async () => {
    if (!walletClient) return;
    setStatus({ phase: "running" });
    try {
      const tag = chainId ? evml.with({ chainId }) : evml;
      await tag.script(finalScript).execute(walletClient);
      setStatus({ phase: "done" });
    } catch (e) {
      setStatus({
        phase: "error",
        message: e instanceof Error ? e.message : String(e),
      });
    }
  };

  return (
    <div className="space-y-4">
      <div>
        <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
          Final script — {CONTEXT_LABELS[context.kind]}
        </p>
        <pre className="p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap max-h-64 overflow-y-auto">
          {finalScript}
        </pre>
      </div>

      <button
        type="button"
        disabled={!walletClient || status.phase === "running"}
        onClick={execute}
        className="px-5 py-2.5 rounded-lg text-sm font-semibold bg-[var(--color-bp-500)] text-white hover:bg-[var(--color-bp-400)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
      >
        {status.phase === "running"
          ? "Confirm in wallet…"
          : ACTION_LABELS[context.kind]}
      </button>

      {status.phase === "done" && (
        <p className="text-sm text-[var(--color-ok)]">
          {context.kind === "eoa"
            ? "Batch executed."
            : "Proposal submitted — it now goes through its normal review/vote flow."}
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
