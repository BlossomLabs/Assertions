import type { SimulationResult } from "@evmcrispr/core";
import type { Address } from "viem";

import { commandSpans, isAssertSpan, spanAtLine } from "./script-ops";

/**
 * One simulation, keyed by everything that changes its answer: the script,
 * the executor it runs as, the chain and the mode (the protected script or
 * the actions with the assertions stripped). A result is only fresh for
 * the exact key it was produced from.
 */

export type SimMode = "protected" | "actions-only";

export interface SimKey {
  script: string;
  from: Address | undefined;
  chainId: number;
  mode: SimMode;
}

export interface SimulationState {
  status: "idle" | "running" | "success" | "failure";
  result: SimulationResult | null;
  /** The key of the run the result (or the run in flight) belongs to. */
  simulated: SimKey | null;
}

export const idleSimulation = (): SimulationState => ({
  status: "idle",
  result: null,
  simulated: null,
});

export function sameKey(a: SimKey, b: SimKey): boolean {
  return (
    a.script === b.script &&
    (a.from ?? "").toLowerCase() === (b.from ?? "").toLowerCase() &&
    a.chainId === b.chainId &&
    a.mode === b.mode
  );
}

const finished = (state: SimulationState): boolean =>
  state.status === "success" || state.status === "failure";

/** The finished result was produced for exactly this key. */
export function isFresh(state: SimulationState, key: SimKey): boolean {
  return finished(state) && state.simulated !== null && sameKey(state.simulated, key);
}

/** A finished result exists, but for a different script, executor, chain
 *  or mode. */
export function isStale(state: SimulationState, key: SimKey): boolean {
  return finished(state) && state.simulated !== null && !sameKey(state.simulated, key);
}

/** simulate() runs scripts that don't fork themselves inside a 2-line
 *  `load sim` / `sim:fork (` prelude (see simulateScript in @evmcrispr/core),
 *  so reported line numbers are shifted by 2 relative to the user's script. */
export function simWrapOffset(script: string): number {
  const s = script.toLowerCase();
  return s.includes("load sim") && s.includes("sim:fork") ? 0 : 2;
}

export interface FailureAttribution {
  kind: "assertion" | "action";
  /** 1-based line in the simulated script. */
  line: number;
  /** The failing command's text. */
  text: string;
}

const LOCATION_RE = /\((\d+):(\d+)(?:,(\d+):(\d+))?\):/;

/** Which command of the simulated script an interpreter error names: the
 *  `name(l:c,l:c):` location, shifted by the sim prelude, mapped to the
 *  command span it falls in. Null when the error carries no location or
 *  points outside the script. */
export function attributeFailure(
  error: string,
  script: string,
): FailureAttribution | null {
  const m = error.match(LOCATION_RE);
  if (!m) return null;
  const line = Number(m[1]) - simWrapOffset(script);
  const span = spanAtLine(commandSpans(script), line);
  if (!span) return null;
  return {
    kind: isAssertSpan(span) ? "assertion" : "action",
    line: span.start,
    text: span.text.trim(),
  };
}

/** Rewrite interpreter source locations like `exec(4:0,4:23):` into the
 *  script text they point at, quoted above the message:
 *  ``Error on line 2: `exec $usdcTkn "pause()"`\n> Transaction reverted: …``.
 *  Lines are 1-based and columns 0-based (see NodeError in @evmcrispr/sdk). */
export function humanizeLocations(text: string, script: string | null): string {
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
