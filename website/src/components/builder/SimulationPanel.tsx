import {
  type Action,
  isBatchedAction,
  isTransactionAction,
  type SimulationResult,
} from "@evmcrispr/core";
import { useEvmlTag } from "@evmcrispr/editor";
import { useCallback, useRef, useState } from "react";
import type { Address } from "viem";

import { stripAssertions } from "./script-ops";
import {
  type SimKey,
  type SimMode,
  type SimulationState,
  attributeFailure,
  humanizeLocations,
  idleSimulation,
  isStale,
} from "./simulation";
import { btnPrimaryCls } from "./ui";

/** One simulation: runs a key (script, executor, chain, mode) on a fork
 *  through the configured tag and remembers which key the result belongs
 *  to. The builder holds two, one per batch listing. */
export function useSimulation() {
  const tag = useEvmlTag();
  const [state, setState] = useState<SimulationState>(idleSimulation);
  const abortRef = useRef<AbortController | null>(null);

  const simulate = useCallback(
    async (key: SimKey): Promise<SimulationResult | undefined> => {
      abortRef.current?.abort();
      const abort = new AbortController();
      abortRef.current = abort;
      setState({ status: "running", result: null, simulated: key });
      try {
        const configured = tag.with({
          chainId: key.chainId,
          ...(key.from ? { account: key.from } : {}),
        });
        const result = await configured
          .script(key.script)
          .simulate({ from: key.from, signal: abort.signal });
        if (abort.signal.aborted) return undefined;
        setState({
          status: result.success ? "success" : "failure",
          result,
          simulated: key,
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
        setState({ status: "failure", result, simulated: key });
        return result;
      }
    },
    [tag],
  );

  const reset = useCallback(() => {
    abortRef.current?.abort();
    setState(idleSimulation());
  }, []);

  return { state, simulate, reset };
}

/** The key a mode simulates for the current script and executor. */
export function simKeyFor(
  mode: SimMode,
  script: string,
  from: Address | undefined,
  chainId: number,
): SimKey {
  return {
    script: mode === "protected" ? script : stripAssertions(script),
    from,
    chainId,
    mode,
  };
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

const MODE_LABEL: Record<SimMode, string> = {
  protected: "protected batch",
  "actions-only": "actions only",
};

const short = (address: Address | undefined) =>
  address ? `${address.slice(0, 6)}…${address.slice(-4)}` : "no executor";

/**
 * The simulate button under a batch listing and the result of its last
 * run: passed/failed, which command failed, the interpreter's error and
 * logs, and a stale marker once the batch, executor, network or mode moves
 * on from what was simulated.
 */
export function SimulationPanel({
  label,
  simKey,
  simulation,
  note,
  failureHint,
}: {
  /** Button caption. */
  label: string;
  /** What the button runs. */
  simKey: SimKey;
  simulation: ReturnType<typeof useSimulation>;
  /** Shown next to the button. */
  note?: string;
  /** Shown under a failed run. */
  failureHint?: string;
}) {
  const { state, simulate } = simulation;
  const hasScript = simKey.script.trim().length > 0;
  const running = state.status === "running";
  const stale = isStale(state, simKey);
  const result = state.result;
  const failure =
    state.status === "failure" && result?.error && state.simulated
      ? attributeFailure(result.error, state.simulated.script)
      : null;

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3 flex-wrap">
        <button
          type="button"
          disabled={running || !hasScript}
          onClick={() => void simulate(simKey)}
          className={btnPrimaryCls}
        >
          {running ? "Simulating…" : label}
        </button>
        <span className="text-xs font-mono text-[var(--color-ink-3)]">
          as {short(simKey.from)}
        </span>
        {note && <span className="text-xs text-[var(--color-ink-3)]">{note}</span>}
      </div>

      {running && (
        <div className="flex items-center gap-2 text-sm text-[var(--color-ink-2)]">
          <span className="size-2 rounded-full bg-[var(--color-bp-400)] animate-pulse" />
          Simulating the {MODE_LABEL[state.simulated?.mode ?? simKey.mode]} on a
          fork…
        </div>
      )}

      {(state.status === "success" || state.status === "failure") && state.simulated && (
        <div
          className={`rounded-lg border p-3 space-y-2 ${
            state.status === "success"
              ? "border-[var(--color-ok)]/40 bg-[var(--color-ok)]/5"
              : "border-[var(--color-err)]/40 bg-[var(--color-err)]/5"
          } ${stale ? "opacity-60" : ""}`}
        >
          {stale && (
            <p className="text-xs text-amber-400">
              The batch, executor or network changed since this run. Run it
              again.
            </p>
          )}
          <p
            className={`text-sm font-medium ${
              state.status === "success"
                ? "text-[var(--color-ok)]"
                : "text-[var(--color-err)]"
            }`}
          >
            {state.status === "success"
              ? passedSummary(result?.actions ?? [])
              : "Simulation failed"}
            <span className="font-normal text-xs text-[var(--color-ink-3)]">
              {" "}
              · {MODE_LABEL[state.simulated.mode]} as {short(state.simulated.from)}
            </span>
          </p>
          {failure && (
            <p className="text-xs text-[var(--color-ink-2)]">
              Failing {failure.kind}:{" "}
              <code className="font-mono">{failure.text}</code>
            </p>
          )}
          {result?.error && (
            <p className="text-xs font-mono text-[var(--color-err)] whitespace-pre-wrap break-all">
              {humanizeLocations(result.error, state.simulated.script)}
            </p>
          )}
          {!!result?.logs.length && (
            <pre className="text-xs font-mono text-[var(--color-ink-2)] whitespace-pre-wrap max-h-48 overflow-y-auto">
              {result.logs
                .map((line) =>
                  humanizeLocations(formatLog(line), state.simulated?.script ?? null),
                )
                .join("\n")}
            </pre>
          )}
          {state.status === "failure" && failureHint && (
            <p className="text-xs text-[var(--color-ink-3)]">{failureHint}</p>
          )}
        </div>
      )}
    </div>
  );
}
