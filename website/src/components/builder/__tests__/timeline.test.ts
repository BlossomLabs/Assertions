import { describe, expect, it } from "vitest";

import type { SimKey, SimulationState } from "../simulation";
import { eyeStateFor, nodeStatuses, timelineNodes } from "../timeline";

const A = "0x000000000000000000000000000000000000aaaa";

const SCRIPT = [
  "set $a 0x000000000000000000000000000000000000aaaa",
  "assert 1 == 1",
  "assert 2 == 2",
  "exec $a f()",
  "assert 3 == 3",
  "exec $a g()",
  "assert 4 == 4",
].join("\n");

const keyOf = (script: string): SimKey => ({
  script,
  from: A,
  chainId: 1,
  mode: "protected",
});
const key = keyOf(SCRIPT);

const state = (
  status: SimulationState["status"],
  simulated: SimKey | null = key,
  error?: string,
): SimulationState => ({
  status,
  result:
    status === "success" || status === "failure"
      ? { success: status === "success", logs: [], actions: [], error }
      : null,
  simulated,
});

/** An interpreter error naming a 1-based line of a script the simulator
 *  wrapped in its two-line prelude. */
const errorAt = (line: number) => `assert(${line + 2}:0,${line + 2}:13): nope`;

describe("timelineNodes", () => {
  it("lists checks and actions in script order, without scaffolding", () => {
    const nodes = timelineNodes(SCRIPT);
    expect(nodes.map((n) => [n.span.start, n.kind, n.lane, n.label])).toEqual([
      [2, "check", "pre", 1],
      [3, "check", "pre", 2],
      [4, "action", "actions", 1],
      [5, "check", "actions", 3],
      [6, "action", "actions", 2],
      [7, "check", "post", 4],
    ]);
  });

  it("puts every check before the actions when there are none", () => {
    expect(timelineNodes("assert 1 == 1\nassert 2 == 2").map((n) => n.lane)).toEqual([
      "pre",
      "pre",
    ]);
  });

  it("is empty for an empty script", () => {
    expect(timelineNodes("")).toEqual([]);
  });
});

describe("nodeStatuses", () => {
  const nodes = timelineNodes(SCRIPT);

  it("is idle before any run and once the run is stale", () => {
    expect(nodeStatuses(nodes, state("idle", null), key)).toEqual(
      nodes.map(() => "idle"),
    );
    const stale = state("success", keyOf(`${SCRIPT}\nassert 5 == 5`));
    expect(nodeStatuses(nodes, stale, key)).toEqual(nodes.map(() => "idle"));
  });

  it("marks every node while its own run is in flight", () => {
    expect(nodeStatuses(nodes, state("running"), key)).toEqual(
      nodes.map(() => "running"),
    );
  });

  it("marks every node passed on a fresh pass", () => {
    expect(nodeStatuses(nodes, state("success"), key)).toEqual(
      nodes.map(() => "ok"),
    );
  });

  it("splits a fresh failure at the failing command", () => {
    const failed = state("failure", key, errorAt(5));
    expect(nodeStatuses(nodes, failed, key)).toEqual([
      "ok",
      "ok",
      "ok",
      "err",
      "skip",
      "skip",
    ]);
  });

  it("stays idle when the failure names no command", () => {
    const failed = state("failure", key, "rpc unreachable");
    expect(nodeStatuses(nodes, failed, key)).toEqual(nodes.map(() => "idle"));
  });
});

describe("eyeStateFor", () => {
  it("sleeps without a script", () => {
    expect(eyeStateFor(state("success"), key, false)).toBe("asleep");
  });

  it("follows the simulation of the current batch", () => {
    expect(eyeStateFor(state("idle", null), key, true)).toBe("stale");
    expect(eyeStateFor(state("running"), key, true)).toBe("running");
    expect(eyeStateFor(state("success"), key, true)).toBe("pass");
    expect(eyeStateFor(state("failure"), key, true)).toBe("fail");
  });

  it("droops once the batch moves on from the last run", () => {
    const other = keyOf("exec $a h()");
    expect(eyeStateFor(state("success", other), key, true)).toBe("stale");
    expect(eyeStateFor(state("failure", other), key, true)).toBe("stale");
  });
});
