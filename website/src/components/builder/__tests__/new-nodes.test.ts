import type { PublicClient } from "viem";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { buildAssertionLine } from "../assertion-codegen";
import {
  type Assertion,
  type CallNode,
  type ValueExpr,
  inferCategory,
  unwrapNode,
} from "../assertion-model";
import { compileAssertionLine } from "../compile-adapter";
import { evml } from "../evml";
import { wrapEntriesFor } from "../expr/catalog";
import { convertNode, nodeKey } from "../expr/NodePicker";
import { probeSafe, resetSafeProbes } from "../useIsSafe";

const T = "0x1234567890123456789012345678901234567890";
const ACCOUNT = "0x0000000000000000000000000000000000000001";
const tag = evml.with({ chainId: 1, account: ACCOUNT });
const EXEC = `exec ${T} transfer(address,uint256) @me 1`;
const noEns = { resolveEns: async () => null, chainId: 1 };

const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const call = (fnName: string, returnTypes: string[]): CallNode => ({
  kind: "call",
  target: T,
  resolved: null,
  hops: [{ fnName, inline: false, argTypes: [], returnTypes, args: [] }],
});
const assertion = (partial: Partial<Assertion>): Assertion => ({
  subject: literal(""),
  operator: "==",
  expected: literal(""),
  delta: "",
  message: "",
  ...partial,
});
const bare = (subject: ValueExpr) =>
  assertion({ subject, operator: null, expected: null });

/** The line the builder writes for an assertion, and whether it compiles. */
async function built(a: Assertion) {
  const line = await buildAssertionLine(a, noEns);
  if (!line) return { line: null, ok: false, loads: [] as string[] };
  const out = await compileAssertionLine(tag, EXEC, line.line, line.sets, "post");
  return {
    line: line.line,
    ok: out.ok,
    loads: out.candidate.split("\n").filter((l) => l.startsWith("load")),
    diagnostics: out.diagnostics.map((d) => d.message),
  };
}

describe("the revert probe and its fallback", () => {
  it("writes a call that must revert as a bare boolean", async () => {
    const out = await built(bare({ kind: "reverts", call: call("f", ["uint256"]) }));
    expect(out.line).toBe(`assert @reverts!(${T}::!{f()(uint256)})`);
    expect(out.ok).toBe(true);
  });

  it("writes a read with a fallback, which is a value of the read's kind", async () => {
    const node: ValueExpr = {
      kind: "orElse",
      primary: call("decimals", ["uint8"]),
      fallback: literal("18"),
    };
    expect(inferCategory(node)).toBe("uint");
    const out = await built(assertion({ subject: node, expected: literal("18") }));
    expect(out.line).toBe(`assert @orElse!(${T}::!{decimals()(uint8)} 18) == 18`);
    expect(out.ok).toBe(true);
  });

  it("stays incomplete until the fallback is filled in", async () => {
    const node: ValueExpr = {
      kind: "orElse",
      primary: call("decimals", ["uint8"]),
      fallback: literal(""),
    };
    expect(await buildAssertionLine(assertion({ subject: node, expected: literal("18") }), noEns)).toBeNull();
  });

  it("unwraps back to the call", () => {
    const read = call("f", ["uint256"]);
    expect(unwrapNode({ kind: "reverts", call: read })).toBe(read);
    expect(unwrapNode({ kind: "orElse", primary: read, fallback: literal("1") })).toBe(read);
  });
});

describe("lists", () => {
  it("writes a membership test over a call's list", async () => {
    const out = await built(
      bare({ kind: "arrIncludes", call: call("owners", ["address[]"]), item: literal(ACCOUNT) }),
    );
    expect(out.line).toBe(`assert @includes!(${T}::!{owners()(address[])} ${ACCOUNT})`);
    expect(out.ok).toBe(true);
    expect(out.loads).toEqual(["load lang"]);
  });

  it("writes the sum of a list of numbers", async () => {
    const out = await built(
      assertion({
        subject: { kind: "callwrap", helper: "sum", call: call("caps", ["uint256[]"]) },
        operator: ">=",
        expected: literal("100"),
      }),
    );
    expect(out.line).toBe(`assert @sum!(${T}::!{caps()(uint256[])}) >= 100`);
    expect(out.ok).toBe(true);
  });

  it("offers the sum for numbers and not for addresses", () => {
    const keys = (node: ValueExpr) => wrapEntriesFor(node, 0).map((e) => e.key);
    expect(keys(call("caps", ["uint256[]"]))).toContain("sum");
    expect(keys(call("owners", ["address[]"]))).not.toContain("sum");
  });
});

describe("the reads of a Safe", () => {
  const safe = (read: Extract<ValueExpr, { kind: "safe" }>["read"]): ValueExpr => ({
    kind: "safe",
    read,
    safe: literal(T),
    owner: literal(ACCOUNT),
  });

  it.each([
    ["threshold", `assert @safe:threshold!(${T}) >= 2`, "uint"],
    ["nonce", `assert @safe:nonce!(${T}) >= 2`, "uint"],
  ] as const)("writes %s as a number", async (read, line, cat) => {
    expect(inferCategory(safe(read))).toBe(cat);
    const out = await built(assertion({ subject: safe(read), operator: ">=", expected: literal("2") }));
    expect(out.line).toBe(line);
    expect(out.ok).toBe(true);
    expect(out.loads).toEqual(["load safe"]);
  });

  it("writes the guard as an address", async () => {
    expect(inferCategory(safe("guard"))).toBe("address");
    const zero = `0x${"00".repeat(20)}`;
    const out = await built(assertion({ subject: safe("guard"), expected: literal(zero) }));
    expect(out.line).toBe(`assert @safe:guard!(${T}) == ${zero}`);
    expect(out.ok).toBe(true);
  });

  it("writes the owner test with the owner first", async () => {
    const out = await built(bare(safe("isOwner")));
    expect(out.line).toBe(`assert @safe:isOwner!(${ACCOUNT} ${T})`);
    expect(out.ok).toBe(true);
  });

  it("writes owners and modules as lists, to count or look into", async () => {
    expect(inferCategory(safe("owners"))).toBe("array");
    const counted = await built(
      assertion({
        subject: { kind: "callwrap", helper: "len", call: safe("owners") },
        expected: literal("3"),
      }),
    );
    expect(counted.line).toBe(`assert @len!(@safe:owners!(${T})) == 3`);
    expect(counted.ok).toBe(true);
    const member = await built(
      bare({ kind: "arrIncludes", call: safe("modules"), item: literal(ACCOUNT) }),
    );
    expect(member.line).toBe(`assert @includes!(@safe:modules!(${T}) ${ACCOUNT})`);
    expect(member.ok).toBe(true);
  });

  it("keeps a Safe's list when it is wrapped in its length or a membership test", () => {
    const owners = safe("owners");
    expect(convertNode(owners, "len")).toEqual({ kind: "callwrap", helper: "len", call: owners });
    expect(convertNode(owners, "arrIncludes")).toMatchObject({ kind: "arrIncludes", call: owners });
  });

  it("is offered on a typed address only once that address is known to be a Safe", () => {
    const keys = (node: ValueExpr, isSafe: boolean) =>
      wrapEntriesFor(node, 0, { isSafe })
        .map((e) => e.key)
        .filter((key) => key.startsWith("safe"));
    expect(keys(literal(T), false)).toEqual([]);
    expect(keys(literal("@me"), true)).toHaveLength(6);
    expect(keys(literal("mysafe.eth"), true)).toHaveLength(6);
    expect(keys(literal(T), true)).toEqual([
      "safeOwners",
      "safeThreshold",
      "safeIsOwner",
      "safeGuard",
      "safeModules",
      "safeNonce",
    ]);
  });

  it("is written over the executor and over an ENS name as it is over an address", async () => {
    const mine = await built(
      assertion({
        subject: { kind: "safe", read: "threshold", safe: literal("@me"), owner: literal("") },
        operator: ">=",
        expected: literal("2"),
      }),
    );
    expect(mine.line).toBe("assert @safe:threshold!(@me) >= 2");
    expect(mine.ok).toBe(true);
    // Off mainnet a name is frozen to the address it resolves to there.
    const named = await buildAssertionLine(
      assertion({
        subject: { kind: "safe", read: "threshold", safe: literal("mysafe.eth"), owner: literal("") },
        operator: ">=",
        expected: literal("2"),
      }),
      { resolveEns: async () => T, chainId: 100 },
    );
    expect(named?.line).toBe("assert @safe:threshold!($mysafe) >= 2");
    expect(named?.sets).toEqual([`set $mysafe ${T}`]);
    const out = await compileAssertionLine(tag, EXEC, named?.line ?? "", named?.sets ?? [], "post");
    expect(out.ok).toBe(true);
  });

  it("is offered on a call too, once the address it returns now is known to be a Safe", () => {
    const keys = (isSafe: boolean) =>
      wrapEntriesFor(call("safe", ["address"]), 0, { isSafe })
        .map((e) => e.key)
        .filter((key) => key.startsWith("safe"));
    expect(keys(false)).toEqual([]);
    expect(keys(true)).toHaveLength(6);
  });

  it("is written over a call, read against the address it returns then", async () => {
    const live = call("safe", ["address"]);
    const threshold = await built(
      assertion({
        subject: { kind: "safe", read: "threshold", safe: live, owner: literal("") },
        operator: ">=",
        expected: literal("2"),
      }),
    );
    expect(threshold.line).toBe(`assert @safe:threshold!(${T}::!{safe()(address)}) >= 2`);
    expect(threshold.ok).toBe(true);
    const owner = await built(
      bare({ kind: "safe", read: "isOwner", safe: live, owner: literal(ACCOUNT) }),
    );
    expect(owner.line).toBe(`assert @safe:isOwner!(${ACCOUNT} ${T}::!{safe()(address)})`);
    expect(owner.ok).toBe(true);
    const owners = await built(
      assertion({
        subject: {
          kind: "callwrap",
          helper: "len",
          call: { kind: "safe", read: "owners", safe: live, owner: literal("") },
        },
        expected: literal("3"),
      }),
    );
    expect(owners.line).toBe(`assert @len!(@safe:owners!(${T}::!{safe()(address)})) == 3`);
    expect(owners.ok).toBe(true);
  });

  it("wraps the address, and unwraps back to it", () => {
    const address = literal(T);
    const node = convertNode(address, "safeThreshold");
    expect(node).toEqual({ kind: "safe", read: "threshold", safe: address, owner: literal("") });
    expect(nodeKey(node)).toBe("safeThreshold");
    expect(unwrapNode(node)).toBe(address);
  });
});

describe("token amounts", () => {
  it("writes an amount in a token's own units", async () => {
    const out = await built(
      assertion({
        subject: {
          kind: "call",
          target: T,
          resolved: null,
          hops: [{ fnName: "balanceOf", inline: false, argTypes: ["address"], returnTypes: ["uint256"], args: ["@me"] }],
        },
        operator: ">=",
        expected: { kind: "tokenAmount", token: literal("DAI"), amount: literal("100") },
      }),
    );
    expect(out.line).toBe(`assert ${T}::!{balanceOf(address)(uint256) @me} >= @token:amount!(DAI 100)`);
    expect(out.ok).toBe(true);
    expect(out.loads).toEqual(["load token"]);
  });

  it("writes a token's decimals", async () => {
    const out = await built(
      assertion({ subject: { kind: "tokenDecimals", token: literal(T) }, expected: literal("18") }),
    );
    expect(out.line).toBe(`assert @token:decimals!(${T}) == 18`);
    expect(out.ok).toBe(true);
  });

  it("takes the token and the amount from calls, read when the assertion runs", async () => {
    const read = (fnName: string, returnTypes: string[]): ValueExpr => ({
      kind: "call",
      target: T,
      resolved: null,
      hops: [{ fnName, inline: false, argTypes: [], returnTypes, args: [] }],
    });
    const out = await built(
      assertion({
        subject: {
          kind: "tokenAmount",
          token: read("asset", ["address"]),
          amount: read("cap", ["uint256"]),
        },
        operator: ">",
        expected: literal("0"),
      }),
    );
    expect(out.line).toBe(
      `assert @token:amount!(${T}::!{asset()(address)} ${T}::!{cap()(uint256)}) > 0`,
    );
    expect(out.ok).toBe(true);
    const decimals = await built(
      assertion({
        subject: { kind: "tokenDecimals", token: read("asset", ["address"]) },
        expected: literal("18"),
      }),
    );
    expect(decimals.line).toBe(`assert @token:decimals!(${T}::!{asset()(address)}) == 18`);
    expect(decimals.ok).toBe(true);
  });

  it("stays incomplete without a token, or with an amount that is not a number", async () => {
    const line = (token: string, amount: string) =>
      buildAssertionLine(
        assertion({ subject: { kind: "tokenAmount", token: literal(token), amount: literal(amount) }, operator: ">", expected: literal("0") }),
        noEns,
      );
    expect(await line("", "100")).toBeNull();
    expect(await line("DAI", "")).toBeNull();
    expect(await line("DAI", "ten")).toBeNull();
    expect(await line("DAI", "1.5")).not.toBeNull();
  });
});

describe("probeSafe", () => {
  beforeEach(() => resetSafeProbes());

  const client = (readContract: (...args: unknown[]) => Promise<unknown>) =>
    ({ readContract }) as unknown as PublicClient;

  it("is true for an address that has a threshold and owners", async () => {
    const read = vi.fn(async () => 2n);
    expect(await probeSafe(client(read), 1, T)).toBe(true);
    expect(read).toHaveBeenCalledTimes(2);
  });

  it("is false for an address that does not answer as a Safe", async () => {
    const read = vi.fn(async () => {
      throw new Error("execution reverted");
    });
    expect(await probeSafe(client(read), 1, T)).toBe(false);
  });

  it("asks once per chain and address", async () => {
    const read = vi.fn(async () => 2n);
    await probeSafe(client(read), 1, T);
    await probeSafe(client(read), 1, T.toUpperCase().replace("0X", "0x") as `0x${string}`);
    expect(read).toHaveBeenCalledTimes(2);
    await probeSafe(client(read), 100, T);
    expect(read).toHaveBeenCalledTimes(4);
  });

  it("does not remember a failed connection", async () => {
    const offline = Object.assign(new Error("fetch failed"), {
      walk(fn: (e: unknown) => boolean) {
        return fn({ name: "HttpRequestError" }) ? this : null;
      },
    });
    const failing = vi.fn(async () => {
      throw offline;
    });
    expect(await probeSafe(client(failing), 1, T)).toBe(false);
    const read = vi.fn(async () => 2n);
    expect(await probeSafe(client(read), 1, T)).toBe(true);
  });
});
