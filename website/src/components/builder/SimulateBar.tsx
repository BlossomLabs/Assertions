import {
  type Action,
  isBatchedAction,
  isTransactionAction,
  type SimulationResult,
} from "@evmcrispr/core";
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

/** Assertions are read-only eth_calls; everything else is a real action.
 *  Batches are counted by their contents, not as a single action. */
function countActions(actions: Action[]): {
  actions: number;
  assertions: number;
} {
  let regular = 0;
  let assertions = 0;
  for (const action of actions) {
    if (isBatchedAction(action)) {
      const nested = countActions(action.actions);
      regular += nested.actions;
      assertions += nested.assertions;
    } else if (isTransactionAction(action) && action.readOnly) {
      assertions += 1;
    } else {
      regular += 1;
    }
  }
  return { actions: regular, assertions };
}

function passedSummary(actions: Action[]): string {
  const counts = countActions(actions);
  const plural = (n: number, word: string) => `${n} ${word}${n === 1 ? "" : "s"}`;
  const parts: string[] = [];
  if (counts.actions || !counts.assertions)
    parts.push(plural(counts.actions, "action"));
  if (counts.assertions) parts.push(plural(counts.assertions, "assertion"));
  return `Simulation passed (${parts.join(", ")})`;
}

const LOG_EMOJI: Record<string, string> = {
  success: "✅",
  error: "❌",
  warning: "⚠️",
  waiting: "⏳",
};

/** Turn interpreter markers like `:success:` into emojis. */
function formatLog(line: string): string {
  return line.replace(
    /:(success|error|warning|waiting):\s*/g,
    (_match, name: string) => `${LOG_EMOJI[name]} `,
  );
}

/** simulate() runs scripts that don't fork themselves inside a 2-line
 *  `load sim` / `sim:fork (` prelude (see simulateScript in @evmcrispr/core),
 *  so reported line numbers are shifted by 2 relative to the user's script. */
function simWrapOffset(script: string): number {
  const s = script.toLowerCase();
  return s.includes("load sim") && s.includes("sim:fork") ? 0 : 2;
}

/** Rewrite interpreter source locations like `exec(4:0,4:23):` into the
 *  script text they point at, quoted above the message:
 *  ``Error on line 2: `exec $usdcTkn "pause()"`\n> Transaction reverted: …``.
 *  Lines are 1-based and columns 0-based (see NodeError in @evmcrispr/sdk). */
function humanizeLocations(text: string, script: string | null): string {
  if (!script) return text;
  const lines = script.split(/\r?\n/);
  const offset = simWrapOffset(script);
  return text.replace(
    /(\S+)\((\d+):(\d+),(\d+):(\d+)\):\s*/g,
    (match, _name, sl: string, sc: string, el: string, ec: string) => {
      const startLine = Number(sl) - offset;
      const lineText = startLine >= 1 ? lines[startLine - 1] : undefined;
      if (lineText === undefined) return match;
      const singleLine = Number(sl) === Number(el);
      const snippet = (
        singleLine
          ? lineText.slice(Number(sc), Number(ec))
          : lineText.slice(Number(sc))
      ).trim();
      if (!snippet) return match;
      return `Error on line ${startLine}: \`${snippet}${singleLine ? "" : " …"}\`\n> `;
    },
  );
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
        {ok ? passedSummary(result?.actions ?? []) : "Simulation failed"}
      </p>
      {result?.error && (
        <p className="text-xs font-mono text-[var(--color-err)] whitespace-pre-wrap break-all">
          {humanizeLocations(result.error, state.simulatedScript)}
        </p>
      )}
      {!!result?.logs.length && (
        <pre className="text-xs font-mono text-[var(--color-ink-2)] whitespace-pre-wrap max-h-48 overflow-y-auto">
          {result.logs
            .map((line) => humanizeLocations(formatLog(line), state.simulatedScript))
            .join("\n")}
        </pre>
      )}
    </div>
  );
}
