import { describe, expect, it } from "vitest";

import { buildAssertionLine } from "../assertion-codegen";
import {
  type Assertion,
  type CallNode,
  type ValueExpr,
  elementTypeOf,
  inferCategory,
  retypeElements,
  unwrapNode,
} from "../assertion-model";
import { compileAssertionLine } from "../compile-adapter";
import { evml } from "../evml";
import { wrapEntriesFor } from "../expr/catalog";
import { convertNode, freshSource, nodeKey } from "../expr/NodePicker";
import { elementScopeAt } from "../expr/ValueEditor";
import { gcScaffolding, insertAssertionLines, removeCommand } from "../script-ops";

const T = "0x1234567890123456789012345678901234567890";
const ACCOUNT = "0x0000000000000000000000000000000000000001";
const tag = evml.with({ chainId: 1, account: ACCOUNT });
const EXEC = `exec ${T} transfer(address,uint256) @me 1`;
const noEns = { resolveEns: async () => null, chainId: 1 };

const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const call = (
  fnName: string,
  returnTypes: string[],
  argTypes: string[] = [],
  args: CallNode["hops"][number]["args"] = [],
): CallNode => ({
  kind: "call",
  target: T,
  resolved: null,
  hops: [{ fnName, inline: false, argTypes, returnTypes, args }],
});
const item = (type: string): ValueExpr => ({ kind: "element", type });
const assertion = (partial: Partial<Assertion>): Assertion => ({
  subject: literal(""),
  operator: "==",
  expected: literal(""),
  delta: "",
  message: "",
  ...partial,
});
const bare = (subject: ValueExpr) => assertion({ subject, operator: null, expected: null });

async function built(a: Assertion) {
  const line = await buildAssertionLine(a, noEns);
  if (!line) return { line: null, sets: [] as string[], ok: false };
  const out = await compileAssertionLine(tag, EXEC, line.line, line.sets, "post");
  return {
    line: line.line,
    sets: line.sets,
    ok: out.ok,
    candidate: out.candidate,
    diagnostics: out.diagnostics.map((d) => d.message),
  };
}

const capsAtLeast100: ValueExpr = {
  kind: "quant",
  op: "all",
  call: call("caps", ["uint256[]"]),
  predicate: { kind: "cmp", op: ">=", left: item("uint256"), right: literal("100") },
};

describe("a test run on every item of a list", () => {
  it("writes the test as a helper of its own, and the quantifier over it", async () => {
    const out = await built(bare(capsAtLeast100));
    expect(out.sets).toHaveLength(1);
    const [def] = out.sets;
    const name = def.match(/^def (@each[0-9a-z]+!) /)?.[1];
    expect(name).toBeDefined();
    expect(def).toBe(`def ${name} "$item: number -> bool" @bool!($item >= 100)`);
    expect(out.line).toBe(`assert @all!(${T}::!{caps()(uint256[])} ${name})`);
    expect(out.ok).toBe(true);
  });

  it("writes 'some item' and 'how many items' the same way", async () => {
    const some = await built(bare({ ...capsAtLeast100, op: "any" } as ValueExpr));
    expect(some.line).toMatch(/^assert @any!\(/);
    expect(some.ok).toBe(true);
    const count: ValueExpr = { ...capsAtLeast100, op: "count" } as ValueExpr;
    expect(inferCategory(count)).toBe("uint");
    const many = await built(assertion({ subject: count, operator: ">=", expected: literal("2") }));
    expect(many.line).toMatch(/^assert @count!\(.*\) >= 2$/);
    expect(many.ok).toBe(true);
  });

  it("passes the item to a call, as an argument", async () => {
    const funded: ValueExpr = {
      kind: "quant",
      op: "all",
      call: call("holders", ["address[]"]),
      predicate: {
        kind: "cmp",
        op: ">=",
        left: call("balanceOf", ["uint256"], ["address"], [item("address")]),
        right: literal("1000"),
      },
    };
    const out = await built(bare(funded));
    expect(out.sets[0]).toContain(
      `"$item: address -> bool" @bool!(${T}::!{balanceOf(address)(uint256) $item} >= 1000)`,
    );
    expect(out.ok).toBe(true);
  });

  it("runs over a Safe's owners", async () => {
    const owners: ValueExpr = { kind: "safe", read: "owners", safe: literal(T), owner: literal("") };
    expect(elementTypeOf(owners)).toBe("address");
    const out = await built(
      bare({
        kind: "quant",
        op: "all",
        call: owners,
        predicate: { kind: "cmp", op: "!=", left: item("address"), right: literal(ACCOUNT) },
      }),
    );
    expect(out.line).toMatch(new RegExp(`^assert @all!\\(@safe:owners!\\(${T}\\) @each`));
    expect(out.ok).toBe(true);
  });

  it("gives the same test the same name, so it is written once", async () => {
    const a = await buildAssertionLine(bare(capsAtLeast100), noEns);
    const b = await buildAssertionLine(bare({ ...capsAtLeast100, op: "any" } as ValueExpr), noEns);
    expect(a?.sets).toEqual(b?.sets);
    const first = insertAssertionLines(EXEC, a?.line ?? "", "post", a?.sets);
    const second = insertAssertionLines(first.script, b?.line ?? "", "post", b?.sets);
    expect(second.script.split("\n").filter((l) => l.startsWith("def "))).toHaveLength(1);
  });

  it("stays incomplete while the test is not a yes or no, or misses a value", async () => {
    const incomplete: ValueExpr = {
      ...capsAtLeast100,
      predicate: { kind: "cmp", op: ">=", left: item("uint256"), right: literal("") },
    } as ValueExpr;
    expect(await buildAssertionLine(bare(incomplete), noEns)).toBeNull();
    const notBool: ValueExpr = { ...capsAtLeast100, predicate: item("uint256") } as ValueExpr;
    expect(await buildAssertionLine(bare(notBool), noEns)).toBeNull();
  });

  it("has no meaning for an item outside a test", async () => {
    expect(
      await buildAssertionLine(assertion({ subject: item("uint256"), expected: literal("1") }), noEns),
    ).toBeNull();
  });
});

describe("which lists can be tested item by item", () => {
  it("is the element type for single-word items, and nothing otherwise", () => {
    expect(elementTypeOf(call("caps", ["uint256[]"]))).toBe("uint256");
    expect(elementTypeOf(call("holders", ["address[3]"]))).toBe("address");
    expect(elementTypeOf(call("names", ["string[]"]))).toBeNull();
    expect(elementTypeOf(call("pairs", ["(address,uint256)[]"]))).toBeNull();
    expect(elementTypeOf(call("one", ["uint256"]))).toBeNull();
  });

  it("offers the quantifiers on those lists only", () => {
    const keys = (node: ValueExpr) =>
      wrapEntriesFor(node, 0)
        .map((e) => e.key)
        .filter((k) => k === "all" || k === "any" || k === "count");
    expect(keys(call("caps", ["uint256[]"]))).toEqual(["all", "any", "count"]);
    expect(keys(call("names", ["string[]"]))).toEqual([]);
    expect(keys(call("one", ["uint256"]))).toEqual([]);
  });

  it("wraps the list with a test that starts as a comparison of the item", () => {
    const list = call("holders", ["address[]"]);
    const node = convertNode(list, "any");
    expect(node).toEqual({
      kind: "quant",
      op: "any",
      call: list,
      predicate: { kind: "cmp", op: "==", left: item("address"), right: literal("") },
    });
    expect(nodeKey(node)).toBe("any");
    expect(unwrapNode(node)).toBe(list);
    expect(convertNode(node, "count")).toMatchObject({ kind: "quant", op: "count", call: list });
  });
});

describe("the item of a test", () => {
  it("is in scope under a quantifier's test, and nowhere else", () => {
    const root = { subject: capsAtLeast100 };
    expect(elementScopeAt(root, ["subject"])).toBeUndefined();
    expect(elementScopeAt(root, ["subject", "call"])).toBeUndefined();
    expect(elementScopeAt(root, ["subject", "predicate"])).toBe("uint256");
    expect(elementScopeAt(root, ["subject", "predicate", "right"])).toBe("uint256");
  });

  it("becomes a value of the item's type when picked", () => {
    expect(freshSource(literal(""), "element", "address")).toEqual(item("address"));
    expect(inferCategory(item("address"))).toBe("address");
    // Outside a test there is no item to pick.
    expect(freshSource(literal(""), "element")).toEqual(literal(""));
  });

  it("follows the list when what an item is changes", () => {
    const predicate: ValueExpr = {
      kind: "cmp",
      op: ">=",
      left: call("balanceOf", ["uint256"], ["address"], [item("address")]),
      right: item("address"),
    };
    const retyped = retypeElements(predicate, "bytes32");
    expect(retyped).toEqual({
      kind: "cmp",
      op: ">=",
      left: call("balanceOf", ["uint256"], ["address"], [item("bytes32")]),
      right: item("bytes32"),
    });
    expect(retypeElements(retyped, "bytes32")).toBe(retyped);
  });
});

describe("the helper a test is written as", () => {
  it("goes away with the last assertion that used it", async () => {
    const a = await buildAssertionLine(bare(capsAtLeast100), noEns);
    const { script, insertedAt } = insertAssertionLines(EXEC, a?.line ?? "", "post", a?.sets);
    expect(script).toContain("def @each");
    expect(removeCommand(script, insertedAt)).toBe(EXEC);
  });

  it("is kept while another assertion still uses it", async () => {
    const a = await buildAssertionLine(bare(capsAtLeast100), noEns);
    const b = await buildAssertionLine(bare({ ...capsAtLeast100, op: "any" } as ValueExpr), noEns);
    const first = insertAssertionLines(EXEC, a?.line ?? "", "post", a?.sets);
    const second = insertAssertionLines(first.script, b?.line ?? "", "post", b?.sets);
    expect(removeCommand(second.script, second.insertedAt)).toContain("def @each");
  });

  it("leaves a helper the user defined alone, used or not", () => {
    const script = `def @mine! "$x: number -> bool" @bool!($x > 0)\n${EXEC}`;
    expect(gcScaffolding(script)).toBe(script);
  });
});
