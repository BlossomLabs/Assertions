// @vitest-environment jsdom
import { cleanup, render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { CallNode, Path, ValueExpr } from "../assertion-model";
import { ExpressionHarness, type Sides } from "./helpers/expression-harness";
import { clearContracts } from "./helpers/fake-contracts";
import { resetSafes, safes } from "./helpers/fake-safe";

vi.mock("../useIsSafe", async () =>
  (await import("./helpers/fake-safe")).fakeIsSafeModule(),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);

const T = "0x1234567890123456789012345678901234567890";
const KIND_MENU = "Change what this value is";
const COMBINE = "Combine or transform this value";

const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const list = (returnType: string): CallNode => ({
  kind: "call",
  target: T,
  resolved: null,
  hops: [{ fnName: "holders", inline: false, argTypes: [], returnTypes: [returnType], args: [] }],
});
const everyHolder = (itemType = "address"): ValueExpr => ({
  kind: "quant",
  op: "all",
  call: list("address[]"),
  predicate: {
    kind: "cmp",
    op: "!=",
    left: { kind: "element", type: itemType },
    right: literal(""),
  },
});

function setup(initial: Sides, initialOpen: Path | null = null) {
  const onState = vi.fn();
  const user = userEvent.setup();
  render(<ExpressionHarness initial={initial} initialOpen={initialOpen} onState={onState} />);
  const state = () =>
    onState.mock.lastCall?.[0] as { root: Sides; openPath: Path | null };
  return {
    user,
    state,
    subject: within(screen.getByTestId("subject")),
    expected: () => within(screen.getByTestId("expected")),
    tray: within(screen.getByTestId("tray")),
  };
}
const options = () => screen.getAllByRole("option").map((o) => o.textContent);

beforeEach(() => {
  cleanup();
  clearContracts();
  resetSafes();
});

describe("a test over the items of a list", () => {
  it("wraps a list in 'every item', with a test ready to fill in", async () => {
    const { user, subject, state } = setup({ subject: list("address[]"), expected: null });
    await user.click(subject.getByRole("button", { name: COMBINE }));
    await user.click(
      screen.getByRole("button", { name: "whether every item passes a test" }),
    );
    expect(state().root.subject).toEqual({
      kind: "quant",
      op: "all",
      call: list("address[]"),
      predicate: {
        kind: "cmp",
        op: "==",
        left: { kind: "element", type: "address" },
        right: literal(""),
      },
    });
  });

  it("shows the list and the test in one field, the test as a pill that opens it", async () => {
    const { user, subject, state } = setup({ subject: everyHolder(), expected: null });
    expect(subject.getByText("@all!")).toBeTruthy();
    expect(subject.getByText("where")).toBeTruthy();
    await user.click(subject.getByText("comparison (!=)"));
    expect(state().openPath).toEqual(["subject", "predicate"]);
  });

  it("offers 'the item' as a value inside the test, first", async () => {
    const { user, tray } = setup(
      { subject: everyHolder(), expected: null },
      ["subject", "predicate"],
    );
    // The right-hand operand of the comparison is plain text for now.
    const menus = tray.getAllByRole("button", { name: KIND_MENU });
    await user.click(menus[menus.length - 1]);
    expect(options()[0]).toBe("the item");
  });

  it("does not offer 'the item' outside a test", async () => {
    const { user, expected } = setup({ subject: everyHolder(), expected: literal("") });
    await user.click(expected().getByRole("button", { name: "value" }));
    expect(options()).not.toContain("the item");
  });

  it("turns an operand into the item when it is picked", async () => {
    const { user, tray, state } = setup(
      { subject: everyHolder(), expected: null },
      ["subject", "predicate"],
    );
    const menus = tray.getAllByRole("button", { name: KIND_MENU });
    await user.click(menus[menus.length - 1]);
    await user.click(screen.getByRole("option", { name: /the item/ }));
    const subject = state().root.subject as Extract<ValueExpr, { kind: "quant" }>;
    expect((subject.predicate as Extract<ValueExpr, { kind: "cmp" }>).right).toEqual({
      kind: "element",
      type: "address",
    });
  });

  it("retypes the item when the list says it is something else", async () => {
    // The test was written for bytes32 items; the list holds addresses.
    const { state } = setup({ subject: everyHolder("bytes32"), expected: null });
    await waitFor(() => {
      const subject = state().root.subject as Extract<ValueExpr, { kind: "quant" }>;
      expect((subject.predicate as Extract<ValueExpr, { kind: "cmp" }>).left).toEqual({
        kind: "element",
        type: "address",
      });
    });
  });
});

describe("the reads of a Safe, in the editor", () => {
  const SAFE_READ = "how many owners must sign";

  it("are not offered on an address that is not a Safe", async () => {
    const { user, expected } = setup({ subject: list("uint256"), expected: literal(T) });
    await user.click(expected().getByRole("button", { name: COMBINE }));
    expect(screen.queryByRole("button", { name: SAFE_READ })).toBeNull();
  });

  it("are offered on one that is, and wrap it", async () => {
    safes.add(T.toLowerCase());
    const { user, expected, state } = setup({ subject: list("uint256"), expected: literal(T) });
    await user.click(expected().getByRole("button", { name: COMBINE }));
    await user.click(screen.getByRole("button", { name: SAFE_READ }));
    expect(state().root.expected).toEqual({
      kind: "safe",
      read: "threshold",
      safe: literal(T),
      owner: literal(""),
    });
    expect(expected().getByText("@safe:threshold!")).toBeTruthy();
  });
});
