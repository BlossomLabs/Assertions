import type { SimulationResult } from "@evmcrispr/core";
import { useCallback, useRef, useState } from "react";
import type { Address } from "viem";

import { evml } from "./evml";

export interface SimulationState {
  status: "idle" | "running" | "success" | "failure";
  result: SimulationResult | null;
  /** The script the current result was produced from, to flag stale results
   *  when the script changes afterwards. */
  simulatedScript: string | null;
}

export function useSimulation(chainId: number | undefined) {
  const [state, setState] = useState<SimulationState>({
    status: "idle",
    result: null,
    simulatedScript: null,
  });
  const abortRef = useRef<AbortController | null>(null);

  const simulate = useCallback(
    async (
      script: string,
      from: Address | undefined,
    ): Promise<SimulationResult | undefined> => {
      abortRef.current?.abort();
      const abort = new AbortController();
      abortRef.current = abort;
      setState({ status: "running", result: null, simulatedScript: script });
      try {
        const tag = chainId ? evml.with({ chainId }) : evml;
        const result = await tag
          .script(script)
          .simulate({ from, signal: abort.signal });
        if (abort.signal.aborted) return undefined;
        setState({
          status: result.success ? "success" : "failure",
          result,
          simulatedScript: script,
        });
        return result;
      } catch (e) {
        if (abort.signal.aborted) return undefined;
        const result: SimulationResult = {
          success: false,
          logs: [],
          actions: [],
          error: e instanceof Error ? e.message : String(e),
        };
        setState({ status: "failure", result, simulatedScript: script });
        return result;
      }
    },
    [chainId],
  );

  const reset = useCallback(() => {
    abortRef.current?.abort();
    setState({ status: "idle", result: null, simulatedScript: null });
  }, []);

  return { ...state, simulate, reset };
}

export function SimulationResults({
  state,
  stale = false,
}: {
  state: SimulationState;
  /** The script changed since this result was produced. */
  stale?: boolean;
}) {
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
      } ${stale ? "opacity-60" : ""}`}
    >
      {stale && (
        <p className="text-xs text-amber-400">
          The script changed since this simulation — run it again.
        </p>
      )}
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
