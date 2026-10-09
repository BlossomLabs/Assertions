import { describe, expect, it } from "vitest";

import type { CallNode, ValueExpr } from "../assertion-model";
import { convertNode, freshSource } from "../expr/NodePicker";

const T = "0x1234567890123456789012345678901234567890";
const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const filledCall: CallNode = {
  kind: "call",
  target: T,
  resolved: null,
  hops: [{ fnName: "owner", inline: false, argTypes: [], returnTypes: ["address"], args: [] }],
};

describe("changing what a value is", () => {
  it("starts a balance from the executor, whatever it replaces", () => {
    const me = { kind: "balance", token: "ETH", account: literal("@me") };
    expect(freshSource(filledCall, "balance")).toEqual(me);
    expect(freshSource(literal(T), "balance")).toEqual(me);
    expect(freshSource({ kind: "chainId" }, "balance")).toEqual(me);
  });

  it("starts code and code hash from an empty address", () => {
    for (const from of [filledCall, literal(T), { kind: "chainId" } as ValueExpr]) {
      expect(freshSource(from, "codeHash")).toEqual({ kind: "codeHash", address: literal("") });
      expect(freshSource(from, "codeAt")).toEqual({ kind: "codeAt", address: literal("") });
    }
  });

  it("starts a contract call empty, not from the call it wrapped", () => {
    const wrapped: ValueExpr = { kind: "codeHash", address: filledCall };
    const next = freshSource(wrapped, "call") as CallNode;
    expect(next.kind).toBe("call");
    expect(next.target).not.toBe(T);
    expect(next.hops.some((hop) => hop.fnName === "owner")).toBe(false);
  });

  it("clears a typed value and keeps a value of the kind it already is", () => {
    expect(freshSource(filledCall, "literal")).toEqual(literal(""));
    expect(freshSource(filledCall, "call")).toBe(filledCall);
  });
});

describe("combining a value", () => {
  it("still carries the value in hand into the new one", () => {
    expect(convertNode(filledCall, "tokenDecimals")).toEqual({ kind: "tokenDecimals", token: filledCall });
  });
});
