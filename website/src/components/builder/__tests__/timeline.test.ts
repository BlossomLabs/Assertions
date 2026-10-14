import { describe, expect, it } from "vitest";

import type { SimKey, SimulationState } from "../simulation";
import { eyeStateFor } from "../timeline";

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
