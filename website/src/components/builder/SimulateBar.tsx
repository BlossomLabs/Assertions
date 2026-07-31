import type { SimulationResult } from "@evmcrispr/core";
import { useCallback, useRef, useState } from "react";
import type { Address } from "viem";

import { evml } from "./evml";

export interface SimulationState {
  status: "idle" | "running" | "success" | "failure";
  result: SimulationResult | null;
}

export function useSimulation(chainId: number | undefined) {
  const [state, setState] = useState<SimulationState>({
    status: "idle",
    result: null,
  });
  const abortRef = useRef<AbortController | null>(null);

  const simulate = useCallback(
    async (script: string, from: Address | undefined) => {
      abortRef.current?.abort();
      const abort = new AbortController();
      abortRef.current = abort;
      setState({ status: "running", result: null });
      try {
        const tag = chainId ? evml.with({ chainId }) : evml;
        const result = await tag
          .script(script)
          .simulate({ from, signal: abort.signal });
        if (abort.signal.aborted) return;
        setState({
          status: result.success ? "success" : "failure",
          result,
        });
      } catch (e) {
        if (abort.signal.aborted) return;
        setState({
          status: "failure",
          result: {
            success: false,
            logs: [],
            actions: [],
            error: e instanceof Error ? e.message : String(e),
          },
        });
      }
    },
    [chainId],
  );

  const reset = useCallback(() => {
    abortRef.current?.abort();
    setState({ status: "idle", result: null });
  }, []);

  return { ...state, simulate, reset };
}

export function SimulationResults({ state }: { state: SimulationState }) {
  if (state.status === "idle") return null;
  if (state.status === "running")
    return (
      <div className="flex items-center gap-2 text-sm text-[var(--color-ink-2)]">
        <span className="size-2 rounded-full bg-[var(--color-bp-400)] animate-pulse" />
        Simulating on a fork…
      </div>
    );

  const result = state.result;
  const ok = state.status === "success";
  return (
    <div
      className={`rounded-lg border p-3 space-y-2 ${
        ok
          ? "border-[var(--color-ok)]/40 bg-[var(--color-ok)]/5"
          : "border-[var(--color-err)]/40 bg-[var(--color-err)]/5"
      }`}
    >
      <p
        className={`text-sm font-medium ${ok ? "text-[var(--color-ok)]" : "text-[var(--color-err)]"}`}
      >
        {ok
          ? `Simulation passed (${result?.actions.length ?? 0} action${(result?.actions.length ?? 0) === 1 ? "" : "s"})`
          : "Simulation failed"}
      </p>
      {result?.error && (
        <p className="text-xs font-mono text-[var(--color-err)] whitespace-pre-wrap break-all">
          {result.error}
        </p>
      )}
      {!!result?.logs.length && (
        <pre className="text-xs font-mono text-[var(--color-ink-2)] whitespace-pre-wrap max-h-48 overflow-y-auto">
          {result.logs.join("\n")}
        </pre>
      )}
    </div>
  );
}
