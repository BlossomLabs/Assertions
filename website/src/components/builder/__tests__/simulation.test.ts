import { describe, expect, it } from "vitest";

import {
  type SimKey,
  type SimulationState,
  attributeFailure,
  humanizeLocations,
  isFresh,
  isStale,
  simWrapOffset,
} from "../simulation";

const A = "0x000000000000000000000000000000000000aaaa";
const B = "0x000000000000000000000000000000000000bbbb";

const key: SimKey = { script: "exec $a f()", from: A, chainId: 1, mode: "protected" };
const done = (simulated: SimKey, status: "success" | "failure" = "success"): SimulationState => ({
  status,
  result: { success: status === "success", logs: [], actions: [] },
  simulated,
});

describe("isFresh / isStale", () => {
  it("is fresh only for the exact key it ran with", () => {
    expect(isFresh(done(key), key)).toBe(true);
    expect(isStale(done(key), key)).toBe(false);
    expect(isFresh(done(key, "failure"), key)).toBe(true);
  });

  it("goes stale on every key field", () => {
    const variants: SimKey[] = [
      { ...key, script: "exec $a g()" },
      { ...key, from: B },
      { ...key, chainId: 100 },
      { ...key, mode: "actions-only" },
    ];
    for (const other of variants) {
      expect(isFresh(done(key), other)).toBe(false);
      expect(isStale(done(key), other)).toBe(true);
    }
  });

  it("compares executors case-insensitively and treats undefined as its own value", () => {
    expect(isFresh(done(key), { ...key, from: A.toUpperCase() as SimKey["from"] })).toBe(true);
    expect(isFresh(done({ ...key, from: undefined }), { ...key, from: undefined })).toBe(true);
    expect(isFresh(done({ ...key, from: undefined }), key)).toBe(false);
  });

  it("is neither fresh nor stale while idle or running", () => {
    const idle: SimulationState = { status: "idle", result: null, simulated: null };
    const running: SimulationState = { status: "running", result: null, simulated: key };
    expect(isFresh(idle, key)).toBe(false);
    expect(isStale(idle, key)).toBe(false);
    expect(isFresh(running, key)).toBe(false);
    expect(isStale(running, { ...key, chainId: 5 })).toBe(false);
  });
});

describe("attributeFailure", () => {
  const script = [
    "load lang",
    "set $a 0x1234567890123456789012345678901234567890",
    "exec $a transfer(address,uint256) @me 1",
    "assert @len!($a::{v()(uint256[])}) > 0",
  ].join("\n");

  it("shifts the location by the 2-line sim wrap and names the assertion", () => {
    expect(simWrapOffset(script)).toBe(2);
    expect(attributeFailure("assert(6:0,6:38): ConstraintFailed", script)).toEqual({
      kind: "assertion",
      line: 4,
      text: "assert @len!($a::{v()(uint256[])}) > 0",
    });
  });

  it("names an action when the location falls on one", () => {
    expect(attributeFailure("exec(5:0,5:40): Transaction reverted", script)).toEqual({
      kind: "action",
      line: 3,
      text: "exec $a transfer(address,uint256) @me 1",
    });
  });

  it("does not shift a script that forks itself", () => {
    const forking = `load sim\nsim:fork (\n  ${script.split("\n").join("\n  ")}\n)`;
    expect(simWrapOffset(forking)).toBe(0);
    expect(attributeFailure("assert(6:2,6:40): ConstraintFailed", forking)?.kind).toBe(
      "action",
    );
  });

  it("gives up without a location or outside the script", () => {
    expect(attributeFailure("Transaction reverted", script)).toBeNull();
    expect(attributeFailure("exec(40:0,40:10): x", script)).toBeNull();
  });
});

describe("humanizeLocations", () => {
  it("quotes the failing line", () => {
    expect(
      humanizeLocations("exec(5:0,5:40): Transaction reverted", "load lang\nset $a 1\nexec $a transfer(address,uint256) @me 1"),
    ).toBe("Error on line 3: `exec $a transfer(address,uint256) @me 1`\n> Transaction reverted");
  });
});
