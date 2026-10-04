// @vitest-environment jsdom
import { cleanup, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";

import type { CallNode, ValueExpr } from "../assertion-model";
import { WrapMenu } from "../expr/NodePicker";

const T = "0x1234567890123456789012345678901234567890";
const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const call = (returnTypes: string[]): CallNode => ({
  kind: "call",
  target: T,
  resolved: null,
  hops: [{ fnName: "read", inline: false, argTypes: [], returnTypes, args: [] }],
});

const COMBINE = "Combine or transform this value";

function setup(node: ValueExpr, depth = 0) {
  const onConvert = vi.fn();
  const user = userEvent.setup();
  render(
    <div>
      <WrapMenu node={node} depth={depth} onConvert={onConvert} />
      <p>elsewhere</p>
    </div>,
  );
  return { onConvert, user };
}

const openPalette = async (user: ReturnType<typeof userEvent.setup>) => {
  await user.click(screen.getByRole("button", { name: COMBINE }));
  return screen.getByRole("dialog", { name: COMBINE });
};

/** The names of the palette's choices, split by whether they can be picked. */
const choices = (palette: HTMLElement) => {
  const buttons = within(palette)
    .getAllByRole("button")
    .filter((b) => !b.hasAttribute("aria-expanded")) as HTMLButtonElement[];
  const name = (b: HTMLButtonElement) => b.getAttribute("aria-label") ?? "";
  return {
    enabled: buttons.filter((b) => !b.disabled).map(name),
    disabled: buttons.filter((b) => b.disabled).map(name),
  };
};

describe("WrapMenu", () => {
  it("is a button that opens the palette, closed to begin with", async () => {
    const { user } = setup(literal("5"));
    const trigger = screen.getByRole("button", { name: COMBINE });
    expect(trigger.getAttribute("aria-expanded")).toBe("false");
    expect(screen.queryByRole("dialog")).toBeNull();
    await openPalette(user);
    expect(trigger.getAttribute("aria-expanded")).toBe("true");
  });

  it("lays the operations out in five rows", async () => {
    const { user } = setup(literal("5"));
    const palette = await openPalette(user);
    for (const row of ["Arithmetic", "Comparison", "Logic", "Address", "Other"])
      expect(within(palette).getByText(row)).toBeTruthy();
    const names = (label: string) =>
      within(within(palette).getByText(label).parentElement as HTMLElement)
        .getAllByRole("button")
        .map((b) => b.textContent);
    expect(names("Arithmetic")).toEqual(["+", "−", "×", "÷", "more"]);
    expect(names("Comparison")).toEqual(["==", "!=", "<", "<=", ">", ">="]);
    expect(names("Logic")).toEqual(["and", "or", "xor", "not"]);
    expect(names("Address")).toEqual(["balance of", "code hash of", "code of"]);
    expect(names("Other")).toEqual([
      "format as decimal",
      "parse decimal",
      "bitwise",
      "length",
      "byte length",
      "hash",
      "split text",
      "contains text",
      "characters in class",
    ]);
  });

  it("keeps the rarer arithmetic behind 'more'", async () => {
    const { user } = setup(literal("5"));
    const palette = await openPalette(user);
    const rare = [
      "integer division, truncating",
      "remainder",
      "power",
      "divide, rounding up",
      "the smallest of several values",
      "the largest of several values",
      "absolute difference",
    ];
    for (const name of rare)
      expect(within(palette).queryByRole("button", { name })).toBeNull();

    const more = within(palette).getByRole("button", { name: "more" });
    expect(more.getAttribute("aria-expanded")).toBe("false");
    await user.click(more);
    for (const name of rare)
      expect(within(palette).getByRole("button", { name })).toBeTruthy();

    const less = within(palette).getByRole("button", { name: "less" });
    expect(less.getAttribute("aria-expanded")).toBe("true");
    await user.click(less);
    expect(
      within(palette).queryByRole("button", { name: "remainder" }),
    ).toBeNull();
  });

  it("folds 'more' back when the palette is reopened", async () => {
    const { user } = setup(literal("5"));
    let palette = await openPalette(user);
    await user.click(within(palette).getByRole("button", { name: "more" }));
    await user.keyboard("{Escape}");
    palette = await openPalette(user);
    expect(within(palette).getByRole("button", { name: "more" })).toBeTruthy();
    expect(
      within(palette).queryByRole("button", { name: "remainder" }),
    ).toBeNull();
  });

  it("greys out what a number cannot take: logic and the text operations", async () => {
    const { user } = setup(call(["uint256"]));
    const palette = await openPalette(user);
    await user.click(within(palette).getByRole("button", { name: "more" }));
    expect(choices(palette)).toEqual({
      enabled: [
        "add",
        "subtract",
        "multiply",
        "divide, rounding down",
        "integer division, truncating",
        "remainder",
        "power",
        "divide, rounding up",
        "the smallest of several values",
        "the largest of several values",
        "absolute difference",
        "compare with ==",
        "compare with !=",
        "compare with <",
        "compare with <=",
        "compare with >",
        "compare with >=",
        "a raw integer as a decimal string",
        "bitwise and, or, xor and shifts",
      ],
      disabled: [
        "both are true",
        "either is true",
        "exactly one is true",
        "the opposite",
        "the balance of this address",
        "the hash of this address's code",
        "the code deployed at this address",
        "a decimal string as a raw integer",
        "how many elements",
        "how many bytes",
        "keccak256 of the value",
        "one segment of a string",
        "whether a string contains a substring",
        "whether every character is in a class",
      ],
    });
  });

  it("offers logic on a boolean", async () => {
    const { user } = setup(call(["bool"]));
    const { enabled } = choices(await openPalette(user));
    for (const name of [
      "both are true",
      "either is true",
      "exactly one is true",
      "the opposite",
    ])
      expect(enabled).toContain(name);
  });

  it("offers the text operations on a string call, and no arithmetic", async () => {
    const { user } = setup(call(["string"]));
    expect(choices(await openPalette(user))).toEqual({
      enabled: [
        "compare with ==",
        "compare with !=",
        "a decimal string as a raw integer",
        "how many elements",
        "how many bytes",
        "keccak256 of the value",
        "one segment of a string",
        "whether a string contains a substring",
        "whether every character is in a class",
      ],
      disabled: [
        "add",
        "subtract",
        "multiply",
        "divide, rounding down",
        "compare with <",
        "compare with <=",
        "compare with >",
        "compare with >=",
        "both are true",
        "either is true",
        "exactly one is true",
        "the opposite",
        "the balance of this address",
        "the hash of this address's code",
        "the code deployed at this address",
        "a raw integer as a decimal string",
        "bitwise and, or, xor and shifts",
      ],
    });
  });

  describe("the Address row", () => {
    const ADDRESS_ROW = [
      "the balance of this address",
      "the hash of this address's code",
      "the code deployed at this address",
    ];
    const COMPARISONS = ["==", "!=", "<", "<=", ">", ">="].map(
      (op) => `compare with ${op}`,
    );
    const split = async (node: ValueExpr) => {
      const { user } = setup(node);
      const result = choices(await openPalette(user));
      cleanup();
      return result;
    };

    it.each([
      ["a call returning an address", call(["address"])],
      ["a typed 0x address", literal(T)],
      ["@me", literal("@me")],
    ])("is offered for %s", async (_name, node) => {
      const { enabled } = await split(node);
      for (const name of ADDRESS_ROW) expect(enabled).toContain(name);
    });

    it.each([
      ["a number", call(["uint256"])],
      ["a typed number", literal("5")],
      ["a boolean", call(["bool"])],
      ["a string", call(["string"])],
    ])("is greyed out for %s", async (_name, node) => {
      const { disabled } = await split(node);
      for (const name of ADDRESS_ROW) expect(disabled).toContain(name);
    });

    it("compares an address with == and != only", async () => {
      const { enabled, disabled } = await split(call(["address"]));
      expect(enabled.filter((n) => COMPARISONS.includes(n))).toEqual([
        "compare with ==",
        "compare with !=",
      ]);
      expect(disabled.filter((n) => COMPARISONS.includes(n))).toEqual([
        "compare with <",
        "compare with <=",
        "compare with >",
        "compare with >=",
      ]);
    });

    it("keeps all six comparisons for a number", async () => {
      const { enabled } = await split(call(["uint256"]));
      expect(enabled.filter((n) => COMPARISONS.includes(n))).toEqual(COMPARISONS);
    });

    it("keeps every operator for a value with no category yet", async () => {
      const { enabled } = await split(literal(""));
      expect(enabled.filter((n) => COMPARISONS.includes(n))).toEqual(COMPARISONS);
    });

    it.each([
      ["a call returning an address", call(["address"])],
      ["a typed address", literal(T)],
    ])("wraps %s in 'balance of', keeping it as the account", async (_name, node) => {
      const { user, onConvert } = setup(node);
      const palette = await openPalette(user);
      await user.click(
        within(palette).getByRole("button", { name: "the balance of this address" }),
      );
      expect(onConvert).toHaveBeenCalledExactlyOnceWith({
        kind: "balance",
        token: "ETH",
        account: node,
      });
    });

    it("wraps an address in its code hash and its code", async () => {
      const node = call(["address"]);
      const pick = async (name: string) => {
        const { user, onConvert } = setup(node);
        const palette = await openPalette(user);
        await user.click(within(palette).getByRole("button", { name }));
        cleanup();
        return onConvert.mock.calls[0][0];
      };
      expect(await pick("the hash of this address's code")).toEqual({
        kind: "codeHash",
        address: node,
      });
      expect(await pick("the code deployed at this address")).toEqual({
        kind: "codeAt",
        address: node,
      });
    });
  });

  it("offers only the length of a list", async () => {
    const { user } = setup(call(["address[]"]));
    expect(choices(await openPalette(user)).enabled).toEqual([
      "how many elements",
    ]);
  });

  it("leaves hash and split out for a nested value", async () => {
    const { user } = setup(call(["string"]), 1);
    const { enabled, disabled } = choices(await openPalette(user));
    expect(disabled).toContain("keccak256 of the value");
    expect(disabled).toContain("one segment of a string");
    expect(enabled).toContain("whether a string contains a substring");
  });

  it("shows no button at all when nothing can wrap the value", () => {
    // Several return values with none picked yet.
    setup(call(["uint256", "address"]));
    expect(screen.queryByRole("button", { name: COMBINE })).toBeNull();
  });

  it("does not pick a greyed out choice", async () => {
    const { user, onConvert } = setup(call(["uint256"]));
    const palette = await openPalette(user);
    await user.click(within(palette).getByRole("button", { name: "both are true" }));
    expect(onConvert).not.toHaveBeenCalled();
    expect(screen.getByRole("dialog")).toBeTruthy();
  });

  it.each([
    ["add", { kind: "arith", op: "+" }],
    ["subtract", { kind: "arith", op: "-" }],
    ["multiply", { kind: "arith", op: "*" }],
    ["divide, rounding down", { kind: "arith", op: "/", rounding: "floor" }],
    ["compare with ==", { kind: "cmp", op: "==" }],
    ["compare with !=", { kind: "cmp", op: "!=" }],
    ["compare with <", { kind: "cmp", op: "<" }],
    ["compare with <=", { kind: "cmp", op: "<=" }],
    ["compare with >", { kind: "cmp", op: ">" }],
    ["compare with >=", { kind: "cmp", op: ">=" }],
    ["bitwise and, or, xor and shifts", { kind: "bytes", op: "&" }],
  ])("picking '%s' wraps the value with that operator set", async (name, shape) => {
    const node = call(["uint256"]);
    const { user, onConvert } = setup(node);
    const palette = await openPalette(user);
    await user.click(within(palette).getByRole("button", { name }));
    expect(onConvert).toHaveBeenCalledExactlyOnceWith({
      ...shape,
      left: node,
      right: literal(""),
    });
    // The value itself is the first operand, not a copy.
    expect(onConvert.mock.calls[0][0].left).toBe(node);
    expect(screen.queryByRole("dialog")).toBeNull();
  });

  it.each([
    ["integer division, truncating", { kind: "arith", op: "//" }],
    ["remainder", { kind: "arith", op: "%" }],
    ["power", { kind: "arith", op: "^" }],
    ["divide, rounding up", { kind: "arith", op: "/", rounding: "ceil" }],
  ])("picking '%s' from 'more' sets that operator", async (name, shape) => {
    const node = call(["uint256"]);
    const { user, onConvert } = setup(node);
    const palette = await openPalette(user);
    await user.click(within(palette).getByRole("button", { name: "more" }));
    await user.click(within(palette).getByRole("button", { name }));
    expect(onConvert).toHaveBeenCalledExactlyOnceWith({
      ...shape,
      left: node,
      right: literal(""),
    });
  });

  it.each([
    ["both are true", "and"],
    ["either is true", "or"],
    ["exactly one is true", "xor"],
  ])("picking '%s' wraps a boolean in logic with %s", async (name, op) => {
    const node = call(["bool"]);
    const { user, onConvert } = setup(node);
    const palette = await openPalette(user);
    await user.click(within(palette).getByRole("button", { name }));
    expect(onConvert).toHaveBeenCalledExactlyOnceWith({
      kind: "logic",
      op,
      left: node,
      right: literal(""),
    });
  });

  it("wraps in the operations that take one value or a list of them", async () => {
    const pick = async (node: ValueExpr, name: string, more = false) => {
      const { user, onConvert } = setup(node);
      const palette = await openPalette(user);
      if (more)
        await user.click(within(palette).getByRole("button", { name: "more" }));
      await user.click(within(palette).getByRole("button", { name }));
      cleanup();
      return onConvert.mock.calls[0][0];
    };
    const flag = call(["bool"]);
    const number = call(["uint256"]);
    const text = call(["string"]);
    expect(await pick(flag, "the opposite")).toEqual({
      kind: "not",
      operand: flag,
    });
    expect(await pick(number, "the smallest of several values", true)).toEqual({
      kind: "minmax",
      op: "min",
      items: [number, literal("")],
    });
    expect(await pick(number, "the largest of several values", true)).toEqual({
      kind: "minmax",
      op: "max",
      items: [number, literal("")],
    });
    expect(await pick(number, "absolute difference", true)).toEqual({
      kind: "absDiff",
      a: number,
      b: literal(""),
    });
    expect(await pick(number, "a raw integer as a decimal string")).toEqual({
      kind: "numformat",
      value: number,
      decimals: "18",
    });
    expect(await pick(text, "how many elements")).toEqual({
      kind: "callwrap",
      helper: "len",
      call: text,
    });
    expect(await pick(text, "one segment of a string")).toEqual({
      kind: "split",
      call: text,
      delimiter: " ",
      index: "0",
    });
    expect(await pick(text, "whether a string contains a substring")).toEqual({
      kind: "strtest",
      helper: "includes",
      call: text,
      arg: "",
    });
  });

  it("closes on Escape, giving the focus back to its button", async () => {
    const { user, onConvert } = setup(literal("5"));
    await openPalette(user);
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).toBeNull();
    expect(document.activeElement).toBe(
      screen.getByRole("button", { name: COMBINE }),
    );
    expect(onConvert).not.toHaveBeenCalled();
  });

  it("closes on a click outside, and stays open on a click inside", async () => {
    const { user, onConvert } = setup(literal("5"));
    const palette = await openPalette(user);
    await user.click(within(palette).getByText("Arithmetic"));
    expect(screen.getByRole("dialog")).toBeTruthy();
    await user.click(screen.getByText("elsewhere"));
    expect(screen.queryByRole("dialog")).toBeNull();
    expect(onConvert).not.toHaveBeenCalled();
  });

  it("closes when its button is pressed again", async () => {
    const { user } = setup(literal("5"));
    await openPalette(user);
    await user.click(screen.getByRole("button", { name: COMBINE }));
    expect(screen.queryByRole("dialog")).toBeNull();
  });
});
