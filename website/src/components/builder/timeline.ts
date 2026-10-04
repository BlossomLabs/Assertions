import {
  type CommandSpan,
  commandSpans,
  isAssertSpan,
  isDefSpan,
  isHelperLoad,
  isLoadSpan,
  isSetSpan,
} from "./script-ops";
import {
  type SimKey,
  type SimulationState,
  attributeFailure,
  isFresh,
  sameKey,
} from "./simulation";

/**
 * The batch as a picture: its checks and actions in execution order, how
 * far the last simulation got through them, and the pose of the eye that
 * stands for a simulation. Pure functions; the components only draw them.
 */

export type EyeState = "asleep" | "stale" | "running" | "pass" | "fail";

export type Lane = "pre" | "actions" | "post";

export type NodeStatus = "idle" | "running" | "ok" | "err" | "skip";

export interface TimelineNode {
  span: CommandSpan;
  kind: "check" | "action";
  /** Checks ahead of the first action, everything up to the last action,
   *  checks after it. */
  lane: Lane;
  /** 1-based position among the nodes of the same kind. */
  label: number;
}

/** The script's checks and actions in order. Scaffolding (`load`, `set`,
 *  `def`) does nothing a reader of the batch needs to follow. */
export function timelineNodes(script: string): TimelineNode[] {
  const spans = commandSpans(script).filter(
    (s) =>
      !isHelperLoad(s.text.trim()) &&
      !(isLoadSpan(s) || isSetSpan(s) || isDefSpan(s)),
  );
  const isAction = (s: CommandSpan) => !isAssertSpan(s);
  const first = spans.findIndex(isAction);
  const last = spans.findLastIndex(isAction);
  let checks = 0;
  let actions = 0;
  return spans.map((span, i) => {
    const check = isAssertSpan(span);
    return {
      span,
      kind: check ? "check" : "action",
      lane: first < 0 || i < first ? "pre" : i > last ? "post" : "actions",
      label: check ? ++checks : ++actions,
    };
  });
}

/** How far the simulation of `key` got through the nodes. Only a result
 *  for exactly this batch says anything about them; a failure that names
 *  no command says nothing either. */
export function nodeStatuses(
  nodes: TimelineNode[],
  state: SimulationState,
  key: SimKey,
): NodeStatus[] {
  const all = (status: NodeStatus) => nodes.map(() => status);
  if (state.status === "running") {
    return all(state.simulated && sameKey(state.simulated, key) ? "running" : "idle");
  }
  if (!isFresh(state, key)) return all("idle");
  if (state.status === "success") return all("ok");
  const failure = state.result?.error
    ? attributeFailure(state.result.error, key.script)
    : null;
  if (!failure) return all("idle");
  return nodes.map((n) =>
    n.span.end < failure.line ? "ok" : n.span.start > failure.line ? "skip" : "err",
  );
}

/** The eye's pose for a simulation of the current batch. */
export function eyeStateFor(
  state: SimulationState,
  key: SimKey,
  hasScript: boolean,
): EyeState {
  if (!hasScript) return "asleep";
  if (state.status === "running") return "running";
  if (!isFresh(state, key)) return "stale";
  return state.status === "success" ? "pass" : "fail";
}
