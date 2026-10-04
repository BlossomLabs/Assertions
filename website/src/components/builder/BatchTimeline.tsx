import { Eye } from "./Eye";
import type { AssertionPlacement } from "./script-ops";
import type { SimKey, SimulationState } from "./simulation";
import {
  type EyeState,
  type Lane,
  type NodeStatus,
  type TimelineNode,
  nodeStatuses,
  timelineNodes,
} from "./timeline";
import { focusRingCls } from "./ui";

const LANES: { lane: Lane; title: string }[] = [
  { lane: "pre", title: "Before" },
  { lane: "actions", title: "Actions" },
  { lane: "post", title: "After" },
];

const CHECK_EYE: Record<NodeStatus, EyeState> = {
  idle: "stale",
  running: "running",
  ok: "pass",
  err: "fail",
  skip: "asleep",
};

const STATUS_CLS: Record<NodeStatus, string> = {
  idle: "border-[var(--color-ink-3)]/40 text-[var(--color-ink-2)]",
  running: "border-[var(--color-bp-400)]/60 text-[var(--color-bp-300)] animate-pulse",
  ok: "border-[var(--color-ok)] text-[var(--color-ok)]",
  err: "border-[var(--color-err)] text-[var(--color-err)] bg-[var(--color-err)]/10",
  skip: "border-[var(--color-ink-3)]/40 text-[var(--color-ink-2)] opacity-35",
};

const STATUS_TEXT: Record<NodeStatus, string> = {
  idle: "not simulated",
  running: "simulating",
  ok: "passed",
  err: "failed",
  skip: "not reached",
};

const tileCls = "size-11 shrink-0 grid place-items-center rounded-xl border-2";

/**
 * The batch drawn in execution order: the checks ahead of the actions, the
 * actions (with any checks placed between them), the checks after. Checks
 * are eyes, actions numbered tiles. Each node shows how far the last
 * simulation of this batch got, and a dashed tile marks where the check
 * being built will land. Selecting a node points at its command in the
 * listing below.
 */
export function BatchTimeline({
  script,
  simKey,
  state,
  placement,
  selected,
  onSelect,
}: {
  script: string;
  /** The protected-batch key the statuses are read against. */
  simKey: SimKey;
  state: SimulationState;
  placement: AssertionPlacement;
  /** 1-based first line of the selected command. */
  selected: number | null;
  onSelect: (line: number | null) => void;
}) {
  const nodes = timelineNodes(script);
  const statuses = nodeStatuses(nodes, state, simKey);

  const renderNode = (node: TimelineNode, i: number) => {
    const status = statuses[i];
    const line = node.span.start;
    const what = node.kind === "check" ? "Check" : "Action";
    return (
      <button
        key={line}
        type="button"
        aria-pressed={selected === line}
        aria-label={`${what} ${node.label}, ${STATUS_TEXT[status]}`}
        title={`${what} ${node.label}, ${STATUS_TEXT[status]}\n${node.span.text.trim()}`}
        onClick={() => onSelect(selected === line ? null : line)}
        className={`${tileCls} bg-[var(--color-surface-2)] font-mono text-sm font-semibold transition-colors ${focusRingCls} ${STATUS_CLS[status]} ${
          selected === line ? "ring-2 ring-[var(--color-bp-400)] ring-offset-2 ring-offset-[var(--color-surface)]" : ""
        }`}
      >
        {node.kind === "check" ? (
          <Eye state={CHECK_EYE[status]} className="w-8" bold />
        ) : (
          node.label
        )}
      </button>
    );
  };

  return (
    <div className="flex items-stretch gap-1.5 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 p-2.5 overflow-x-auto">
      {LANES.map(({ lane, title }, l) => {
        const inLane = nodes
          .map((node, i) => ({ node, i }))
          .filter(({ node }) => node.lane === lane);
        const checks = lane !== "actions";
        const landsHere = checks && placement === lane;
        return (
          <div key={lane} className={`flex items-stretch gap-1.5 ${checks ? "" : "flex-1"}`}>
            {l > 0 && (
              <span aria-hidden className="self-center text-[var(--color-ink-3)]">
                ›
              </span>
            )}
            <div
              role="group"
              aria-label={checks ? `Checks ${title.toLowerCase()} the actions` : title}
              className={`flex-1 min-w-24 rounded-lg px-3 pt-2 pb-3 ${
                checks
                  ? "bg-[var(--color-bp-500)]/10"
                  : "border border-dashed border-[var(--color-ink-3)]/40"
              }`}
            >
              <p className="mb-2 font-mono text-[0.625rem] font-semibold uppercase tracking-widest text-[var(--color-ink-3)]">
                {title}
              </p>
              <div className="flex flex-wrap items-center justify-center gap-2 min-h-11">
                {inLane.map(({ node, i }) => renderNode(node, i))}
                {landsHere && (
                  <span
                    title="The check you are building lands here"
                    className={`${tileCls} border-dashed border-[var(--color-bp-400)]/70 text-[var(--color-bp-300)]`}
                  >
                    +
                  </span>
                )}
                {inLane.length === 0 && !landsHere && (
                  <span className="text-xs text-[var(--color-ink-3)]">
                    {checks ? "no checks" : "no actions"}
                  </span>
                )}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
