// @vitest-environment jsdom
import { cleanup, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { CallHop, CallNode, Path, ValueExpr } from "../assertion-model";
import { ExpressionHarness, type Sides } from "./helpers/expression-harness";
import { clearContracts, registerContract } from "./helpers/fake-contracts";

vi.mock("../useIsSafe", async () =>
  (await import("./helpers/fake-safe")).fakeIsSafeModule(),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);

const T = "0x1234567890123456789012345678901234567890";
const U = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001";

const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const hop = (partial: Partial<CallHop> & { fnName: string }): CallHop => ({
  inline: false,
  argTypes: [],
  returnTypes: ["uint256"],
  args: [],
  ...partial,
});
const call = (target: string, hops: CallHop[]): CallNode => ({
  kind: "call",
  target,
  resolved: null,
  hops,
});
const totalSupply = () => call(T, [hop({ fnName: "totalSupply" })]);

/** Every kind a value can be on its own, with the name its menu shows. */
const SOURCES: [string, ValueExpr][] = [
  ["contract call", totalSupply()],
  ["value", literal("5")],
  ["balance", { kind: "balance", token: "ETH", account: literal("@me") }],
  ["code hash", { kind: "codeHash", address: literal(T) }],
  ["deployed code", { kind: "codeAt", address: literal(T) }],
  ["chain id", { kind: "chainId" }],
  ["timestamp", { kind: "clock", which: "timestamp" }],
  ["block number", { kind: "clock", which: "blocknumber" }],
];
const NO_INPUT = ["chain id", "timestamp", "block number"];

const KIND_MENU = "Change what this value is";
const COMBINE = "Combine or transform this value";
const UNWRAP = "Unwrap: keep only the first operand";

function setup(initial: Sides, initialOpen: Path | null = null) {
  const onState = vi.fn();
  const user = userEvent.setup();
  render(
    <ExpressionHarness
      initial={initial}
      initialOpen={initialOpen}
      onState={onState}
    />,
  );
  const state = () =>
    onState.mock.lastCall?.[0] as { root: Sides; openPath: Path | null };
  return {
    user,
    state,
    subject: within(screen.getByTestId("subject")),
    expected: () => within(screen.getByTestId("expected")),
    tray: within(screen.getByTestId("tray")),
    trayEl: screen.getByTestId("tray"),
  };
}

/** The menus that say what a value is: listbox buttons, top-level ones
 *  named by the kind, an operand's by the action. */
type Scope = Pick<typeof screen, "getAllByRole" | "queryAllByRole">;
const menus = (scope: Scope) =>
  scope
    .queryAllByRole("button")
    .filter((b) => b.getAttribute("aria-haspopup") === "listbox");

const pick = async (
  user: ReturnType<typeof userEvent.setup>,
  menu: HTMLElement,
  option: string,
) => {
  await user.click(menu);
  await user.click(screen.getByRole("option", { name: option }));
};

beforeEach(() => clearContracts());

describe("ValueSlot: one field per value", () => {
  it.each(SOURCES)("shows a %s as a single slot", (label, node) => {
    const { expected } = setup({ subject: totalSupply(), expected: node });
    const slot = expected();
    // What it is: one menu, showing the kind.
    const kindMenus = menus(slot).filter(
      (b) => b.getAttribute("title") === KIND_MENU && !b.hasAttribute("aria-label"),
    );
    expect(kindMenus.map((b) => b.textContent)).toEqual([label]);
    // One way to combine it, and nothing to unwrap.
    expect(slot.getAllByRole("button", { name: COMBINE })).toHaveLength(1);
    expect(slot.queryByRole("button", { name: UNWRAP })).toBeNull();
  });

  it.each(SOURCES)("a %s says so when it takes no parameter", (label, node) => {
    const { expected } = setup({ subject: totalSupply(), expected: node });
    const slot = expected();
    if (NO_INPUT.includes(label)) {
      expect(slot.getByText("read on-chain, no input")).toBeTruthy();
      expect(slot.queryAllByRole("textbox")).toEqual([]);
    } else {
      expect(slot.queryByText("read on-chain, no input")).toBeNull();
      expect(slot.getAllByRole("textbox").length).toBeGreaterThan(0);
    }
  });

  it("puts each kind's main parameter in the slot", () => {
    const value = (el: HTMLElement) => (el as HTMLInputElement).value;
    const fields = (node: ValueExpr) => {
      const view = setup({ subject: totalSupply(), expected: node });
      const out = view.expected().getAllByRole("textbox").map(value);
      cleanup();
      return out;
    };
    expect(fields(SOURCES[1][1])).toEqual(["5"]);
    expect(fields(SOURCES[2][1])).toEqual(["ETH", "@me"]);
    expect(fields(SOURCES[3][1])).toEqual([T]);
    expect(fields(SOURCES[4][1])).toEqual([T]);
  });

  it("names the contract call's address field and writes the rest of the call on a chip", async () => {
    const { user, subject, state } = setup({
      subject: totalSupply(),
      expected: literal(""),
    });
    const address = subject.getByRole("textbox", {
      name: "Contract address or ENS name",
    }) as HTMLInputElement;
    expect(address.value).toBe(T);
    const chip = subject.getByRole("button", { name: ".totalSupply()" });
    expect(chip.getAttribute("title")).toBe("Edit the call");
    // The chip opens the call in the tray, and closes it again.
    await user.click(chip);
    expect(state().openPath).toEqual(["subject"]);
    await user.click(chip);
    expect(state().openPath).toBeNull();
  });

  it("writes the whole call on the chip: arguments, what is picked, chained calls", () => {
    const chip = (node: CallNode) => {
      const view = setup({ subject: node, expected: literal("") });
      const text = view.subject.queryByTitle("Edit the call")?.textContent ?? null;
      cleanup();
      return text;
    };
    expect(chip(call(T, [hop({ fnName: "", returnTypes: [] })]))).toBeNull();
    expect(
      chip(
        call(T, [
          hop({
            fnName: "getPair",
            argTypes: ["address", "address"],
            returnTypes: ["address"],
            args: ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", ""],
          }),
        ]),
      ),
    ).toBe(".getPair(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, …)");
    expect(
      chip(
        call(T, [
          hop({ fnName: "factory", returnTypes: ["address"] }),
          hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath: ["-1"] }),
          hop({ fnName: "", returnTypes: [] }),
        ]),
      ),
    ).toBe(".factory().getOwners()[-1]");
  });

  it("does not offer 'value' for the value being checked, and does for the expected one", async () => {
    const { user, subject, expected } = setup({
      subject: totalSupply(),
      expected: literal("5"),
    });
    const options = () =>
      screen.getAllByRole("option").map((o) => o.textContent);

    await user.click(subject.getByRole("button", { name: "contract call" }));
    expect(options()).toEqual([
      "contract call",
      "balance",
      "timestamp",
      "block number",
      "chain id",
      "code hash",
      "deployed code",
    ]);
    await user.keyboard("{Escape}");

    await user.click(expected().getByRole("button", { name: "value" }));
    expect(options()).toEqual([
      "value",
      "contract call",
      "balance",
      "timestamp",
      "block number",
      "chain id",
      "code hash",
      "deployed code",
    ]);
  });

  it("changes what a value is from its menu", async () => {
    const { user, expected, state } = setup({
      subject: totalSupply(),
      expected: literal("5"),
    });
    await pick(user, expected().getByRole("button", { name: "value" }), "balance");
    expect(state().root.expected).toEqual({
      kind: "balance",
      token: "ETH",
      account: literal("@me"),
    });
    expect(state().openPath).toBeNull();

    await pick(user, expected().getByRole("button", { name: "balance" }), "timestamp");
    expect(state().root.expected).toEqual({ kind: "clock", which: "timestamp" });
    expect(expected().getByText("read on-chain, no input")).toBeTruthy();
  });

  it("opens the tray at once on a kind that has settings", async () => {
    const { user, expected, state, tray } = setup({
      subject: totalSupply(),
      expected: literal("5"),
    });
    await pick(
      user,
      expected().getByRole("button", { name: "value" }),
      "contract call",
    );
    expect(state().root.expected?.kind).toBe("call");
    expect(state().openPath).toEqual(["expected"]);
    expect(tray.getByText("Expected value")).toBeTruthy();
  });

  it("starts a new call when the address changes", async () => {
    const { user, subject, state } = setup({
      subject: totalSupply(),
      expected: literal(""),
    });
    const address = subject.getByRole("textbox", {
      name: "Contract address or ENS name",
    });
    await user.type(address, "0");
    const next = state().root.subject as CallNode;
    expect(next.target).toBe(`${T}0`);
    expect(next.hops).toHaveLength(1);
    expect(next.hops[0].fnName).toBe("");
    // The address field shows the call's settings as it takes the cursor.
    expect(state().openPath).toEqual(["subject"]);
  });
});

describe("ValueSlot: nested operands", () => {
  const sum = (left: ValueExpr, right: ValueExpr = literal("")): ValueExpr => ({
    kind: "arith",
    op: "+",
    left,
    right,
  });

  it("types plain text operands in place", async () => {
    const { user, subject, state, tray } = setup({
      subject: sum(literal("1")),
      expected: literal(""),
    });
    const [left, right] = subject.getAllByPlaceholderText("value");
    expect((left as HTMLInputElement).value).toBe("1");
    await user.type(right, "42");
    expect(state().root.subject).toEqual(sum(literal("1"), literal("42")));
    // Nothing opened: plain text never needs the tray.
    expect(state().openPath).toBeNull();
    expect(tray.queryByRole("button", { name: "close" })).toBeNull();
  });

  it("names a combined value by its kind, with no menu to change it", () => {
    const { subject } = setup({ subject: sum(literal("1")), expected: literal("") });
    expect(subject.getByText("arithmetic")).toBeTruthy();
    expect(
      menus(subject).filter((b) => !b.hasAttribute("aria-label")).map((b) => b.textContent),
    ).toEqual(["+"]);
  });

  it.each(SOURCES)(
    "keeps the type menu on the operand's field when the operand is a %s",
    (label, node) => {
      const { subject } = setup({ subject: sum(node), expected: literal("") });
      const operandMenus = subject.getAllByRole("button", { name: KIND_MENU });
      expect(operandMenus).toHaveLength(2);
      const field = operandMenus[0].closest("span.rounded-md") as HTMLElement;
      if (label === "value") {
        expect((within(field).getByRole("textbox") as HTMLInputElement).value).toBe("5");
        expect(within(field).queryByTitle("Edit this value")).toBeNull();
      } else {
        // Anything but plain text is a pill in the same field as its menu.
        expect(within(field).getByTitle("Edit this value")).toBeTruthy();
        expect(within(field).queryByRole("textbox")).toBeNull();
      }
      // The other operand keeps its own.
      expect(field.contains(operandMenus[1])).toBe(false);
    },
  );

  it("summarises each kind of operand on its pill", () => {
    const pill = (node: ValueExpr) => {
      const view = setup({ subject: sum(node), expected: literal("") });
      const text = view.subject.getByTitle("Edit this value").textContent;
      cleanup();
      return text;
    };
    expect(pill(totalSupply())).toBe("0x1234…7890.totalSupply()");
    expect(pill(SOURCES[2][1])).toBe("balance of ETH");
    expect(pill(SOURCES[3][1])).toBe("@codeHash!(…)");
    expect(pill(SOURCES[4][1])).toBe("@codeAt!(…)");
    expect(pill(SOURCES[5][1])).toBe("@chainId!");
    expect(pill(SOURCES[6][1])).toBe("@timestamp!");
    expect(pill(SOURCES[7][1])).toBe("@blocknumber!");
  });

  it("opens the tray on an operand converted to a contract call", async () => {
    const { user, subject, state, tray } = setup({
      subject: sum(literal("1")),
      expected: literal(""),
    });
    const [, rightMenu] = subject.getAllByRole("button", { name: KIND_MENU });
    await pick(user, rightMenu, "contract call");

    expect((state().root.subject as any).right.kind).toBe("call");
    expect(state().openPath).toEqual(["subject", "right"]);
    expect(tray.getByRole("button", { name: "close" })).toBeTruthy();
    // The operand's own menu is still on its field in the row.
    expect(subject.getAllByRole("button", { name: KIND_MENU })).toHaveLength(2);
    expect(subject.getByTitle("Edit this value").textContent).toBe("empty call");
  });

  it("shows the kind as a fixed label in the tray, not as a menu", async () => {
    const { tray } = setup(
      { subject: sum(literal("1"), totalSupply()), expected: literal("") },
      ["subject", "right"],
    );
    const label = tray.getByText("contract call");
    expect(label.closest("button")).toBeNull();
    expect(tray.queryByRole("button", { name: "contract call" })).toBeNull();
    expect(tray.queryByRole("button", { name: KIND_MENU })).toBeNull();
    // The value itself is edited there.
    expect(
      (tray.getByRole("textbox", {
        name: "Contract address or ENS name",
      }) as HTMLInputElement).value,
    ).toBe(T);
  });

  it("shows a top-level value's settings in the tray without repeating its slot", () => {
    const { tray, subject } = setup(
      { subject: totalSupply(), expected: literal("") },
      ["subject"],
    );
    expect(tray.getByRole("button", { name: "close" })).toBeTruthy();
    expect(
      tray.queryByRole("textbox", { name: "Contract address or ENS name" }),
    ).toBeNull();
    expect(
      subject.getByRole("textbox", { name: "Contract address or ENS name" }),
    ).toBeTruthy();
  });

  it("closes the tray when the operand it shows goes back to plain text", async () => {
    const { user, subject, state, tray } = setup(
      { subject: sum(literal("1"), totalSupply()), expected: literal("") },
      ["subject", "right"],
    );
    const [, rightMenu] = subject.getAllByRole("button", { name: KIND_MENU });
    await pick(user, rightMenu, "value");
    expect((state().root.subject as any).right).toEqual(literal(""));
    expect(state().openPath).toBeNull();
    expect(tray.queryByRole("button", { name: "close" })).toBeNull();
  });

  it("opens the tray from an operand's pill, and closes it from the same pill", async () => {
    const { user, subject, state } = setup({
      subject: sum(totalSupply()),
      expected: literal(""),
    });
    const pill = subject.getByTitle("Edit this value");
    await user.click(pill);
    expect(state().openPath).toEqual(["subject", "left"]);
    await user.click(pill);
    expect(state().openPath).toBeNull();
  });

  it("offers the operators the operands allow and sets the one picked", async () => {
    const { user, subject, state } = setup({
      subject: sum(literal("1"), literal("2")),
      expected: literal(""),
    });
    await pick(user, subject.getByRole("button", { name: "+" }), "*");
    expect((state().root.subject as any).op).toBe("*");
    expect(subject.getByRole("button", { name: "*" })).toBeTruthy();
  });

  it("asks which way a division rounds", async () => {
    const { user, subject, state } = setup({
      subject: { kind: "arith", op: "/", rounding: "floor", left: literal("7"), right: literal("2") },
      expected: literal(""),
    });
    expect(subject.getByText("@calcFloor!")).toBeTruthy();
    await pick(user, subject.getByRole("button", { name: "floor" }), "ceil");
    expect((state().root.subject as any).rounding).toBe("ceil");
    expect(subject.getByText("@calcCeil!")).toBeTruthy();
  });

  it("adds operands to min and max", async () => {
    const { user, subject, state } = setup({
      subject: { kind: "minmax", op: "min", items: [literal("1"), literal("2")] },
      expected: literal(""),
    });
    expect(subject.getByText("@min!")).toBeTruthy();
    await user.click(subject.getByRole("button", { name: "+ operand" }));
    expect((state().root.subject as any).items).toEqual([
      literal("1"),
      literal("2"),
      literal(""),
    ]);
    expect(subject.getAllByPlaceholderText("value")).toHaveLength(3);
  });

  it("puts a value's extra settings behind a chip that opens the tray", async () => {
    const name = call(T, [hop({ fnName: "name", returnTypes: ["string"] })]);
    const { user, subject, state, tray } = setup({
      subject: { kind: "split", call: name, delimiter: " ", index: "0" },
      expected: literal(""),
    });
    await user.click(subject.getByRole("button", { name: 'by " ", #0' }));
    expect(state().openPath).toEqual(["subject"]);
    const segment = tray.getByDisplayValue("0");
    await user.clear(segment);
    await user.type(segment, "2");
    expect((state().root.subject as any).index).toBe("2");
    expect(subject.getByRole("button", { name: 'by " ", #2' })).toBeTruthy();
  });
});

describe("ValueSlot: combining and unwrapping", () => {
  it("puts the combine button outside the value's box", () => {
    const { subject } = setup({ subject: totalSupply(), expected: literal("") });
    const combine = subject.getByRole("button", { name: COMBINE });
    const box = combine.previousElementSibling as HTMLElement;
    // The box holds the value: its kind and its parameter.
    expect(within(box).getByRole("button", { name: "contract call" })).toBeTruthy();
    expect(within(box).getByRole("textbox")).toBeTruthy();
    expect(box.contains(combine)).toBe(false);
  });

  it("keeps the unwrap icon inside the box of a combined value", () => {
    const { subject } = setup({
      subject: { kind: "arith", op: "+", left: totalSupply(), right: literal("1") },
      expected: literal(""),
    });
    const combine = subject.getByRole("button", { name: COMBINE });
    const box = combine.previousElementSibling as HTMLElement;
    const unwrap = subject.getByRole("button", { name: UNWRAP });
    expect(box.contains(unwrap)).toBe(true);
    expect(unwrap.querySelector("svg")).not.toBeNull();
  });

  it("combines the whole value from the palette", async () => {
    const { user, subject, state } = setup({
      subject: totalSupply(),
      expected: literal(""),
    });
    await user.click(subject.getByRole("button", { name: COMBINE }));
    await user.click(screen.getByRole("button", { name: "multiply" }));
    expect(state().root.subject).toEqual({
      kind: "arith",
      op: "*",
      left: totalSupply(),
      right: literal(""),
    });
    expect(subject.getByText("arithmetic")).toBeTruthy();
    expect(subject.getByRole("button", { name: UNWRAP })).toBeTruthy();
  });

  it("unwraps a combined value back to its first operand", async () => {
    const { user, subject, state, tray } = setup(
      {
        subject: { kind: "cmp", op: ">", left: totalSupply(), right: literal("7") },
        expected: literal(""),
      },
      ["subject", "left"],
    );
    expect(tray.getByRole("button", { name: "close" })).toBeTruthy();
    await user.click(subject.getByRole("button", { name: UNWRAP }));
    // (The call editor in the tray had recorded the resolved address.)
    expect(state().root.subject).toEqual({ ...totalSupply(), resolved: T });
    expect(state().openPath).toBeNull();
    expect(subject.queryByRole("button", { name: UNWRAP })).toBeNull();
    expect(subject.getByRole("button", { name: "contract call" })).toBeTruthy();
  });

  it.each([
    ["min of values", { kind: "minmax", op: "min", items: [literal("1"), literal("2")] }, literal("1")],
    ["an absolute difference", { kind: "absDiff", a: literal("3"), b: literal("4") }, literal("3")],
    ["a negation", { kind: "not", operand: literal("true") }, literal("true")],
    ["a token amount", { kind: "tokenAmount", amount: literal("9"), token: literal("DAI") }, literal("9")],
  ] as [string, ValueExpr, ValueExpr][])(
    "unwraps %s to its first operand",
    async (_name, node, first) => {
      const { user, expected, state } = setup({
        subject: totalSupply(),
        expected: node,
      });
      await user.click(expected().getByRole("button", { name: UNWRAP }));
      expect(state().root.expected).toEqual(first);
    },
  );
});

describe("ValueTray: the formula header", () => {
  const tree = (): Sides => ({
    subject: {
      kind: "arith",
      op: "+",
      left: call(T, [hop({ fnName: "owner", returnTypes: ["address"] })]),
      right: { kind: "balance", token: "ETH", account: literal("@me") },
    },
    expected: literal("5"),
  });
  const current = (trayEl: HTMLElement) =>
    [...trayEl.querySelectorAll('[aria-current="true"]')].map(
      (el) => el.textContent,
    );
  const part = (tray: Scope, text: string) => {
    const found = tray
      .getAllByRole("button")
      .filter((el) => el.tagName === "SPAN" && el.textContent === text);
    expect(found).toHaveLength(1);
    return found[0];
  };

  it("shows nothing while no value is open", () => {
    const { trayEl } = setup(tree());
    expect(trayEl.textContent).toBe("");
  });

  it("writes the whole side as a formula, named by its side", () => {
    const { tray } = setup(tree(), ["subject", "left"]);
    expect(tray.getByText("Value to check")).toBeTruthy();
    expect(
      part(tray, "0x1234…7890.owner() + balance(ETH of @me)"),
    ).toBeTruthy();
  });

  it("says what kind of value the edited part is, beside the formula", () => {
    const badge = (open: Path) => {
      const view = setup(tree(), open);
      const title =
        "Inferred value category: decides which operators and combinators the menus offer";
      const text = view.tray.queryByTitle(title)?.textContent ?? null;
      cleanup();
      return text;
    };
    expect(badge(["subject", "left"])).toBe("address");
    expect(badge(["subject", "right"])).toBe("number");
    expect(badge(["expected"])).toBe("number");
  });

  it("marks the part being edited, and only that part", () => {
    const { trayEl, tray } = setup(tree(), ["subject", "left"]);
    expect(current(trayEl)).toEqual(["0x1234…7890.owner()"]);
    expect(part(tray, "0x1234…7890.owner()").getAttribute("title")).toBe(
      "You are editing this part",
    );
    expect(part(tray, "balance(ETH of @me)").getAttribute("title")).toBe(
      "Edit this part",
    );
  });

  it("moves the tray to another part when it is clicked", async () => {
    const { user, trayEl, tray, state } = setup(tree(), ["subject", "left"]);
    await user.click(part(tray, "balance(ETH of @me)"));
    expect(state().openPath).toEqual(["subject", "right"]);
    expect(current(trayEl)).toEqual(["balance(ETH of @me)"]);
    // The tray now edits the balance: its kind, fixed, and its fields.
    expect(tray.getByText("balance").closest("button")).toBeNull();
    expect(
      (tray.getByRole("textbox", {
        name: "Token symbol or address",
      }) as HTMLInputElement).value,
    ).toBe("ETH");

    // A part inside a part goes straight to the inner one.
    await user.click(part(tray, "@me"));
    expect(state().openPath).toEqual(["subject", "right", "account"]);
    expect(current(trayEl)).toEqual(["@me"]);

    // And the whole side is a part too.
    await user.click(part(tray, "0x1234…7890.owner() + balance(ETH of @me)"));
    expect(state().openPath).toEqual(["subject"]);
  });

  it("moves with the keyboard too", async () => {
    const { user, tray, state } = setup(tree(), ["subject", "left"]);
    part(tray, "balance(ETH of @me)").focus();
    await user.keyboard("{Enter}");
    expect(state().openPath).toEqual(["subject", "right"]);
    part(tray, "0x1234…7890.owner()").focus();
    await user.keyboard(" ");
    expect(state().openPath).toEqual(["subject", "left"]);
  });

  it("follows the tree as it is edited", async () => {
    const { user, tray } = setup(tree(), ["subject", "right"]);
    const token = tray.getByRole("textbox", { name: "Token symbol or address" });
    await user.clear(token);
    await user.type(token, "DAI");
    expect(
      part(tray, "0x1234…7890.owner() + balance(DAI of @me)"),
    ).toBeTruthy();
  });

  it("names the expected side when the tray is on it", () => {
    const { tray, trayEl } = setup(
      {
        subject: totalSupply(),
        expected: { kind: "codeHash", address: literal(T) },
      },
      ["expected", "address"],
    );
    expect(tray.getByText("Expected value")).toBeTruthy();
    expect(part(tray, `codeHash(${T})`)).toBeTruthy();
    expect(current(trayEl)).toEqual([T]);
  });

  it("brackets nested operations and writes what is still missing as '…'", () => {
    const { tray } = setup(
      {
        subject: {
          kind: "cmp",
          op: ">",
          left: { kind: "arith", op: "*", left: literal("2"), right: literal("") },
          right: { kind: "minmax", op: "max", items: [literal("1"), call("", [])] },
        },
        expected: null,
      },
      ["subject", "left"],
    );
    expect(part(tray, "(2 * …) > max(1, empty call)")).toBeTruthy();
  });

  it("writes a call with its arguments, live calls included, and what is picked from the return", () => {
    const { tray, trayEl } = setup(
      {
        subject: call(T, [
          hop({
            fnName: "balanceOf",
            argTypes: ["address"],
            args: [
              call(U, [
                hop({
                  fnName: "getOwners",
                  returnTypes: ["address[]"],
                  lensPath: ["-1"],
                }),
              ]),
            ],
          }),
        ]),
        expected: literal(""),
      },
      ["subject", "hops", 0, "args", 0],
    );
    expect(
      part(tray, "0x1234…7890.balanceOf(0xabcd…0001.getOwners()[-1])"),
    ).toBeTruthy();
    expect(current(trayEl)).toEqual(["0xabcd…0001.getOwners()[-1]"]);
  });

  it("closes from its close button", async () => {
    const { user, tray, trayEl, state } = setup(tree(), ["subject", "left"]);
    await user.click(tray.getByRole("button", { name: "close" }));
    expect(state().openPath).toBeNull();
    expect(trayEl.textContent).toBe("");
  });

  it("closes by itself when the value it shows is gone", async () => {
    const { user, subject, trayEl, state } = setup(
      {
        subject: {
          kind: "minmax",
          op: "min",
          items: [literal("1"), totalSupply()],
        },
        expected: literal(""),
      },
      ["subject", "items", 1],
    );
    expect(trayEl.textContent).not.toBe("");
    // Unwrapping keeps the first operand only: the second no longer exists.
    await user.click(subject.getByRole("button", { name: UNWRAP }));
    expect(state().openPath).toBeNull();
    expect(trayEl.textContent).toBe("");
  });

  it("removes an operand of min or max once there are more than two", async () => {
    const items = [literal("1"), totalSupply(), literal("3")];
    const { user, tray, state } = setup(
      { subject: { kind: "minmax", op: "max", items }, expected: literal("") },
      ["subject", "items", 1],
    );
    await user.click(tray.getByRole("button", { name: "remove" }));
    expect((state().root.subject as any).items).toEqual([literal("1"), literal("3")]);
    expect(state().openPath).toBeNull();
  });

  it("does not offer to remove one of only two operands", () => {
    const { tray } = setup(
      {
        subject: { kind: "minmax", op: "max", items: [literal("1"), totalSupply()] },
        expected: literal(""),
      },
      ["subject", "items", 1],
    );
    expect(tray.queryByRole("button", { name: "remove" })).toBeNull();
  });

  it("explains what a source reads", () => {
    const { tray } = setup(
      {
        subject: {
          kind: "cmp",
          op: "==",
          left: { kind: "chainId" },
          right: literal("1"),
        },
        expected: null,
      },
      ["subject", "left"],
    );
    expect(
      tray.getByText("The chain id, read on-chain at assertion time."),
    ).toBeTruthy();
  });
});

describe("ValueTray: a live value filling an argument", () => {
  const BALANCE_OF = "function balanceOf(address account) view returns (uint256)";
  const withArg = (arg: string | ValueExpr): Sides => ({
    subject: call(T, [
      hop({ fnName: "balanceOf", argTypes: ["address"], args: [arg] }),
    ]),
    expected: literal(""),
  });
  const ALL_PAIRS = "function allPairs(uint256 index) view returns (address)";
  const withIndex = (arg: string | ValueExpr): Sides => ({
    subject: call(T, [
      hop({
        fnName: "allPairs",
        argTypes: ["uint256"],
        returnTypes: ["address"],
        args: [arg],
      }),
    ]),
    expected: literal(""),
  });
  const ARG_PATH: Path = ["subject", "hops", 0, "args", 0];
  const ARG_MENU = "Change what this argument is";
  const owner = () => call(U, [hop({ fnName: "owner", returnTypes: ["address"] })]);
  const argOf = (state: () => { root: Sides }) =>
    (state().root.subject as CallNode).hops[0].args[0];

  beforeEach(() => registerContract(T, { name: "Token", abi: [BALANCE_OF, ALL_PAIRS] }));

  it("offers an address argument plain text or a contract call", async () => {
    const { user, tray } = setup(withArg("@me"), ["subject"]);
    await user.click(tray.getByRole("button", { name: ARG_MENU }));
    expect(screen.getAllByRole("option").map((o) => o.textContent)).toEqual([
      "value",
      "contract call",
    ]);
  });

  it("offers a number argument every kind that reads a number", async () => {
    const { user, tray } = setup(withIndex("0"), ["subject"]);
    await user.click(tray.getByRole("button", { name: ARG_MENU }));
    expect(screen.getAllByRole("option").map((o) => o.textContent)).toEqual([
      "value",
      "contract call",
      "balance",
      "timestamp",
      "block number",
      "chain id",
    ]);
  });

  it("turns an argument into a contract call and moves the tray onto it", async () => {
    const { user, tray, state } = setup(withArg("@me"), ["subject"]);
    await pick(user, tray.getByRole("button", { name: ARG_MENU }), "contract call");
    expect(argOf(state)).toMatchObject({ kind: "call", target: "" });
    expect(state().openPath).toEqual(ARG_PATH);
  });

  it("takes any live value, not only a call: the chain id", async () => {
    const { user, tray, trayEl, state } = setup(withIndex("0"), ["subject"]);
    await pick(user, tray.getByRole("button", { name: ARG_MENU }), "chain id");
    expect(argOf(state)).toEqual({ kind: "chainId" });
    expect(state().openPath).toEqual(ARG_PATH);
    // The tray edits the argument: its kind, what it reads, and the way back.
    expect(tray.getByText("read on-chain, no input")).toBeTruthy();
    expect(
      tray.getByText("The chain id, read on-chain at assertion time."),
    ).toBeTruthy();
    expect(
      [...trayEl.querySelectorAll('[aria-current="true"]')].map((el) => el.textContent),
    ).toEqual(["chain id"]);
    expect(trayEl.textContent).toContain("0x1234…7890.allPairs(chain id)");

    await user.click(tray.getByRole("button", { name: "OK" }));
    expect(state().openPath).toEqual(["subject"]);
    expect(argOf(state)).toEqual({ kind: "chainId" });
    expect(tray.getByTitle("Edit this value").textContent).toBe("@chainId!");
  });

  it("turns a live argument back into plain text from the same menu", async () => {
    const { user, tray, state } = setup(withIndex({ kind: "chainId" }), ["subject"]);
    expect(tray.queryByRole("textbox")).toBeNull();
    await pick(user, tray.getByRole("button", { name: ARG_MENU }), "value");
    expect(argOf(state)).toBe("");
    expect(state().openPath).toEqual(["subject"]);
    expect(tray.queryByTitle("Edit this value")).toBeNull();
    expect((tray.getByRole("textbox") as HTMLInputElement).value).toBe("");
  });

  it("types a plain argument in place", async () => {
    const { user, tray, state } = setup(withArg(""), ["subject"]);
    await user.type(tray.getByRole("textbox"), "@me");
    expect(argOf(state)).toBe("@me");
    expect(state().openPath).toEqual(["subject"]);
  });

  it("shows the argument's kind as a fixed label in the tray, like any nested value", () => {
    const { tray } = setup(withArg(owner()), ARG_PATH);
    expect(tray.getByText("contract call").closest("button")).toBeNull();
    expect(tray.queryByRole("button", { name: "contract call" })).toBeNull();
    expect(tray.queryByRole("button", { name: KIND_MENU })).toBeNull();
    expect(
      (tray.getByRole("textbox", {
        name: "Contract address or ENS name",
      }) as HTMLInputElement).value,
    ).toBe(U);
  });

  it("combines an argument, keeping the tray on it", async () => {
    const { user, tray, state } = setup(withIndex({ kind: "chainId" }), ARG_PATH);
    await user.click(tray.getByRole("button", { name: COMBINE }));
    await user.click(screen.getByRole("button", { name: "add" }));
    expect(argOf(state)).toEqual({
      kind: "arith",
      op: "+",
      left: { kind: "chainId" },
      right: literal(""),
    });
    expect(state().openPath).toEqual(ARG_PATH);
    expect(tray.getByText("arithmetic")).toBeTruthy();
    expect(tray.getByRole("button", { name: "OK" })).toBeTruthy();
  });

  it("shows a combined argument as a pill with no kind menu", () => {
    const { tray } = setup(
      withIndex({ kind: "arith", op: "+", left: { kind: "chainId" }, right: literal("1") }),
      ["subject"],
    );
    expect(tray.getByTitle("Edit this value").textContent).toBe("arithmetic (+)");
    expect(tray.queryByRole("button", { name: ARG_MENU })).toBeNull();
  });

  it("offers OK and Cancel on an argument only", () => {
    const onArg = setup(withArg(call(U, [])), ARG_PATH);
    expect(onArg.tray.getByRole("button", { name: "OK" })).toBeTruthy();
    expect(onArg.tray.getByRole("button", { name: "Cancel" })).toBeTruthy();
    cleanup();

    const onCall = setup(withArg("@me"), ["subject"]);
    expect(onCall.tray.queryByRole("button", { name: "OK" })).toBeNull();
    expect(onCall.tray.queryByRole("button", { name: "Cancel" })).toBeNull();
  });

  it("OK goes back to the owning call and keeps the live value", async () => {
    const live = owner();
    const { user, tray, state } = setup(withArg(live), ARG_PATH);
    await user.click(tray.getByRole("button", { name: "OK" }));
    expect(state().openPath).toEqual(["subject"]);
    expect(argOf(state)).toMatchObject({ kind: "call", target: U, hops: live.hops });
    // Back on the owning call, the argument shows as a pill.
    expect(tray.getByTitle("Edit this value").textContent).toBe(
      "0xabcd…0001.owner()",
    );
  });

  it("Cancel goes back to the owning call with the argument emptied", async () => {
    const { user, tray, state } = setup(withArg(owner()), ARG_PATH);
    await user.click(tray.getByRole("button", { name: "Cancel" }));
    expect(state().openPath).toEqual(["subject"]);
    expect(argOf(state)).toBe("");
    expect(tray.queryByTitle("Edit this value")).toBeNull();
    expect((tray.getByRole("textbox") as HTMLInputElement).value).toBe("");
  });

  it("goes back to the right call from an argument of a nested call", async () => {
    const { user, tray, state } = setup(
      {
        subject: {
          kind: "arith",
          op: "+",
          left: literal("1"),
          right: withArg(call(U, [])).subject,
        },
        expected: literal(""),
      },
      ["subject", "right", "hops", 0, "args", 0],
    );
    await user.click(tray.getByRole("button", { name: "OK" }));
    expect(state().openPath).toEqual(["subject", "right"]);
  });

  describe("whether the value fits the argument", () => {
    const VAULT = [
      "function owner() view returns (address)",
      "function totalAssets() view returns (uint256)",
    ];
    beforeEach(() => registerContract(U, { name: "Vault", abi: VAULT }));
    const hint = (trayEl: HTMLElement) =>
      [...trayEl.querySelectorAll("p")]
        .map((p) => p.textContent)
        .filter((t) => /^This argument takes \S+\.$/.test(t ?? ""));

    it("says which type the argument takes", () => {
      const { trayEl } = setup(withIndex({ kind: "chainId" }), ARG_PATH);
      expect(hint(trayEl)).toEqual(["This argument takes uint256."]);
      cleanup();
      expect(hint(setup(withArg(owner()), ARG_PATH).trayEl)).toEqual([
        "This argument takes address.",
      ]);
    });

    it("does not say so for a value that is not an argument", () => {
      const { trayEl } = setup(withIndex("0"), ["subject"]);
      expect(hint(trayEl)).toEqual([]);
    });

    it("accepts a value of the argument's type", () => {
      const { tray } = setup(withIndex({ kind: "chainId" }), ARG_PATH);
      expect(tray.queryByRole("alert")).toBeNull();
      expect(
        (tray.getByRole("button", { name: "OK" }) as HTMLButtonElement).disabled,
      ).toBe(false);
    });

    it("refuses a value of another type: an alert, and no OK", async () => {
      const { user, tray, state } = setup(withIndex(owner()), ARG_PATH);
      expect(tray.getByRole("alert").textContent).toBe(
        "This argument takes uint256, but the value is address. Call a function on that address that returns it, or pick another value.",
      );
      const ok = tray.getByRole("button", { name: "OK" }) as HTMLButtonElement;
      expect(ok.disabled).toBe(true);
      await user.click(ok);
      expect(state().openPath).toEqual(ARG_PATH);
    });

    it("allows OK again once a fitting function is picked", async () => {
      const { user, tray, state } = setup(withIndex(owner()), ARG_PATH);
      await pick(
        user,
        tray.getByRole("button", { name: "owner() → address" }),
        "totalAssets() → uint256",
      );
      expect(tray.queryByRole("alert")).toBeNull();
      const ok = tray.getByRole("button", { name: "OK" }) as HTMLButtonElement;
      expect(ok.disabled).toBe(false);
      await user.click(ok);
      expect(state().openPath).toEqual(["subject"]);
      expect(argOf(state)).toMatchObject({
        kind: "call",
        hops: [{ fnName: "totalAssets" }],
      });
    });

    it("still cancels a value that does not fit", async () => {
      const { user, tray, state } = setup(withIndex(owner()), ARG_PATH);
      await user.click(tray.getByRole("button", { name: "Cancel" }));
      expect(argOf(state)).toBe("");
      expect(state().openPath).toEqual(["subject"]);
    });

    it("does not judge a value still being filled in", () => {
      const { tray } = setup(withIndex(call(U, [hop({ fnName: "", returnTypes: [] })])), ARG_PATH);
      expect(tray.queryByRole("alert")).toBeNull();
      expect(
        (tray.getByRole("button", { name: "OK" }) as HTMLButtonElement).disabled,
      ).toBe(false);
    });

    it("greys out, in the argument's call, the functions that cannot lead to its type", async () => {
      registerContract(U, {
        name: "Vault",
        abi: [...VAULT, "function name() view returns (string)"],
      });
      const { user, tray } = setup(
        withIndex(call(U, [hop({ fnName: "", returnTypes: [] })])),
        ARG_PATH,
      );
      await user.click(tray.getByRole("button", { name: "Select a view function…" }));
      const disabled = screen
        .getAllByRole("option")
        .filter((o) => o.getAttribute("aria-disabled") === "true")
        .map((o) => o.textContent);
      expect(disabled).toEqual(["name() → string"]);
    });

    it("shows the alert under the argument once back on the owning call", () => {
      const { tray } = setup(withIndex(owner()), ["subject"]);
      expect(tray.getByRole("alert").textContent).toMatch(
        /^This argument takes uint256, but the value is address\./,
      );
    });
  });

  it("reopens a live argument from its pill", async () => {
    const { user, tray, state } = setup(withArg(call(U, [])), ["subject"]);
    await user.click(tray.getByTitle("Edit this value"));
    expect(state().openPath).toEqual(ARG_PATH);
  });
});
