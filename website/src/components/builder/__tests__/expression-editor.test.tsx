// @vitest-environment jsdom
import { fireEvent, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { Assertion, CallHop, CallNode, ValueExpr } from "../assertion-model";
import { previewSubjectValue } from "../compile-adapter";
import { ExpressionAssertionEditor } from "../ExpressionAssertionEditor";
import { clearContracts, registerContract } from "./helpers/fake-contracts";
import { type FakeTag, useFreshTag } from "./helpers/fake-tag";

vi.mock("@evmcrispr/editor", async () =>
  (await import("./helpers/fake-tag")).fakeEditorModule(),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);
vi.mock("../useChainSupport", () => ({
  OFFICIAL_CHAIN_IDS: new Set([1]),
  useChainClient: () => ({ fake: "client" }),
  useChainSupport: () => ({ state: "official" }),
}));
vi.mock("../compile-adapter", () => ({
  previewSubjectValue: vi.fn(),
  compileAssertionLine: vi.fn(),
}));

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
const call = (hops: CallHop[], target = T): CallNode => ({
  kind: "call",
  target,
  resolved: target,
  hops,
});
const assertion = (partial: Partial<Assertion>): Assertion => ({
  subject: call([hop({ fnName: "totalSupply" })]),
  operator: "==",
  expected: literal(""),
  delta: "",
  message: "",
  ...partial,
});

function Harness({
  initial,
  onAssertion,
  script = "",
  placement,
}: {
  initial: Assertion;
  onAssertion: (a: Assertion) => void;
  script?: string;
  placement?: "pre" | "post";
}) {
  const [value, setValue] = useState(initial);
  onAssertion(value);
  return (
    <ExpressionAssertionEditor
      assertion={value}
      setAssertion={setValue}
      chainId={1}
      script={script}
      placement={placement}
    />
  );
}

function setup(
  initial: Assertion,
  props: { script?: string; placement?: "pre" | "post" } = {},
) {
  const onAssertion = vi.fn();
  const user = userEvent.setup();
  render(<Harness initial={initial} onAssertion={onAssertion} {...props} />);
  /** The slot under one of the row's labels. */
  const side = (label: string) => {
    const el = screen.getByText(label).closest("div.min-w-0");
    if (!el) throw new Error(`no side labelled ${label}`);
    return within(el as HTMLElement);
  };
  return {
    user,
    current: () => onAssertion.mock.lastCall?.[0] as Assertion,
    subject: () => side("Value to check"),
    expected: () => side("Expected value"),
  };
}

const optionLabels = () => screen.getAllByRole("option").map((o) => o.textContent);
/** The operator select: labelled, so it is found the way a user reads it. */
const operator = () => screen.getByLabelText("Operator");

let fake: FakeTag;
beforeEach(() => {
  clearContracts();
  fake = useFreshTag("0x00000000000000000000000000000000000000ee");
  vi.mocked(previewSubjectValue).mockReset();
});

describe("ExpressionAssertionEditor", () => {
  it("offers 'value' as a kind for the expected side only", async () => {
    const { user, subject, expected } = setup(assertion({}));
    await user.click(subject().getByRole("button", { name: "contract call" }));
    expect(optionLabels()).not.toContain("value");
    expect(optionLabels()).toContain("balance");
    await user.keyboard("{Escape}");

    await user.click(expected().getByRole("button", { name: "value" }));
    expect(optionLabels()[0]).toBe("value");
  });

  it("says what kind of value each side is, beside its name", async () => {
    const { user, subject, expected } = setup(assertion({ expected: literal("true") }));
    const BADGE =
      "Inferred value category: decides which operators and combinators the menus offer";
    expect(subject().getByTitle(BADGE).textContent).toBe("number");
    expect(expected().getByTitle(BADGE).textContent).toBe("bool");
    // Nothing while the kind is not known yet.
    await user.clear(expected().getByRole("textbox"));
    expect(expected().queryByTitle(BADGE)).toBeNull();
  });

  it("offers the comparisons the two sides allow", async () => {
    const { user, current } = setup(assertion({ expected: literal("5") }));
    await user.click(operator());
    // A typed value on one side only also allows the approximate match.
    expect([...optionLabels()].sort()).toEqual(
      ["==", "!=", "<", "<=", ">", ">=", "~="].sort(),
    );
    await user.click(screen.getByRole("option", { name: ">=" }));
    expect(current().operator).toBe(">=");
  });

  it("asks for the tolerance of an approximate comparison", async () => {
    const { user, current } = setup(assertion({ expected: literal("5") }));
    expect(screen.queryByLabelText(/Allowed delta/)).toBeNull();
    await user.click(operator());
    await user.click(screen.getByRole("option", { name: "~=" }));
    await user.type(screen.getByLabelText(/Allowed delta/), "50e8");
    expect(current()).toMatchObject({ operator: "~=", delta: "50e8" });
  });

  it("drops the expected side for a boolean checked as it is", async () => {
    const { user, current } = setup(
      assertion({ subject: call([hop({ fnName: "paused", returnTypes: ["bool"] })]) }),
    );
    await user.click(operator());
    expect(optionLabels()).toEqual(["is true", "==", "!="]);
    await user.click(screen.getByRole("option", { name: "is true" }));
    expect(current()).toMatchObject({ operator: null, expected: null });
    expect(screen.queryByText("Expected value")).toBeNull();

    await user.click(operator());
    await user.click(screen.getByRole("option", { name: "==" }));
    expect(current()).toMatchObject({ operator: "==", expected: literal("true") });
  });

  it("compares a boolean with true or false from a menu, not typed text", async () => {
    const { user, expected, current } = setup(
      assertion({ subject: call([hop({ fnName: "paused", returnTypes: ["bool"] })]) }),
    );
    // An empty expected value settles on true.
    expect(current().expected).toEqual(literal("true"));
    expect(expected().queryByRole("textbox")).toBeNull();
    await user.click(expected().getByRole("button", { name: "true" }));
    await user.click(screen.getByRole("option", { name: "false" }));
    expect(current().expected).toEqual(literal("false"));
  });

  it("moves an operator the sides no longer allow back to an allowed one", () => {
    const { current } = setup(
      assertion({
        subject: call([hop({ fnName: "name", returnTypes: ["string"] })]),
        operator: ">=",
        expected: call([hop({ fnName: "symbol", returnTypes: ["bytes"] })], U),
      }),
    );
    expect(current().operator).toBe("==");
  });

  it("offers a date for the value a timestamp is compared with", async () => {
    const { user, expected, current } = setup(
      assertion({ subject: { kind: "clock", which: "timestamp" }, operator: "<" }),
    );
    await user.click(expected().getByRole("button", { name: "pick a date" }));
    const picker = document.querySelector(
      'input[type="datetime-local"]',
    ) as HTMLInputElement;
    expect(picker).not.toBeNull();
    fireEvent.change(picker, { target: { value: "2030-01-02T03:04" } });
    expect(current().expected).toEqual(
      literal(String(Math.floor(new Date(2030, 0, 2, 3, 4).getTime() / 1000))),
    );
    // The typed value and the picker stay in step.
    expect(picker.value).toBe("2030-01-02T03:04");
  });

  it("closes the tray on a click outside the expression, not inside it", async () => {
    const { user, expected } = setup(
      assertion({ subject: { kind: "clock", which: "timestamp" }, operator: "<" }),
    );
    const open = () => document.querySelector('input[type="datetime-local"]');
    await user.click(expected().getByRole("button", { name: "pick a date" }));
    expect(open()).not.toBeNull();
    // Inside: the operator, and a menu it opens (which floats in the page).
    await user.click(operator());
    await user.click(screen.getAllByRole("option")[0]);
    expect(open()).not.toBeNull();
    // Outside.
    await user.click(document.body);
    expect(open()).toBeNull();
  });

  it("does not offer a date for other subjects", () => {
    const { expected } = setup(assertion({}));
    expect(expected().queryByRole("button", { name: "pick a date" })).toBeNull();
  });

  it("fills the expected value with the subject's current one", async () => {
    vi.mocked(previewSubjectValue).mockResolvedValue({ kind: "value", text: "1234" });
    const { user, current } = setup(assertion({}), { script: "set $a 1" });
    await user.click(screen.getByRole("button", { name: "Use current value" }));
    await vi.waitFor(() => expect(current().expected).toEqual(literal("1234")));
    expect(previewSubjectValue).toHaveBeenCalledExactlyOnceWith(
      fake.tag,
      { fake: "client" },
      "set $a 1",
      current().subject,
      1,
    );
    expect(screen.queryByText(/Fetching current value/)).toBeNull();
  });

  it("says why the current value could not be read", async () => {
    vi.mocked(previewSubjectValue).mockResolvedValue({
      kind: "error",
      message: "execution reverted",
    });
    const { user, current } = setup(assertion({}));
    await user.click(screen.getByRole("button", { name: "Use current value" }));
    expect(
      await screen.findByText(
        "Could not fetch the current value: execution reverted",
      ),
    ).toBeTruthy();
    expect(current().expected).toEqual(literal(""));
  });

  it("does not offer the current value when the expected side is itself live", () => {
    setup(assertion({ expected: { kind: "chainId" } }));
    expect(screen.queryByRole("button", { name: "Use current value" })).toBeNull();
  });

  it("turns two live numbers into a bounded difference on request", async () => {
    const supply = call([hop({ fnName: "totalSupply" })]);
    const assets = call([hop({ fnName: "totalAssets" })], U);
    const { user, current } = setup(assertion({ subject: supply, expected: assets }));
    await user.click(
      screen.getByRole("button", { name: "Compare |a − b| ≤ delta instead" }),
    );
    expect(current()).toMatchObject({
      subject: { kind: "absDiff", a: supply, b: assets },
      operator: "<=",
      expected: literal(""),
    });
  });

  it("does not suggest that against a typed value", () => {
    setup(assertion({ expected: literal("5") }));
    expect(
      screen.queryByRole("button", { name: "Compare |a − b| ≤ delta instead" }),
    ).toBeNull();
  });
});

describe("ExpressionAssertionEditor: finding the contract a chained call is made on", () => {
  const ACTION = `exec ${T} "pause()"`;
  const chained = () =>
    assertion({
      subject: call([
        hop({ fnName: "owner", returnTypes: ["address"] }),
        hop({ fnName: "", returnTypes: [] }),
      ]),
    });

  beforeEach(() => {
    registerContract(T, {
      name: "Registry",
      abi: ["function owner() view returns (address)"],
    });
    registerContract(U, {
      name: "Vault",
      abi: ["function totalAssets() view returns (uint256)"],
    });
  });

  it("simulates the actions, reads the previous call there and lists that contract's functions", async () => {
    fake.simulate.mockResolvedValue({
      success: true,
      actions: [],
      logs: [`:success: ${U}`],
    });
    const { user, subject } = setup(chained(), {
      script: `${ACTION}\nassert ${T}::!{paused()(bool)}`,
      placement: "post",
    });
    await user.click(subject().getByRole("button", { name: ".owner()" }));
    expect(await screen.findByText("Verified: Vault")).toBeTruthy();
    // After the actions, without the assertions, reading while the script runs.
    expect(fake.simulate).toHaveBeenCalledTimes(1);
    expect(fake.simulate.mock.calls[0][0]).toBe(
      `${ACTION}\nprint ${T}::{owner()(address)}`,
    );
    await user.click(screen.getByRole("button", { name: "Select a view function…" }));
    expect(optionLabels()).toContain("totalAssets() → uint256");
  });

  it("reads before the actions for a check placed before them", async () => {
    fake.simulate.mockResolvedValue({ success: true, actions: [], logs: [U] });
    const { user, subject } = setup(chained(), { script: ACTION, placement: "pre" });
    await user.click(subject().getByRole("button", { name: ".owner()" }));
    expect(await screen.findByText("Verified: Vault")).toBeTruthy();
    expect(fake.simulate.mock.calls[0][0]).toBe(`print ${T}::{owner()(address)}`);
  });

  it("falls back to a typed signature when the simulation fails", async () => {
    fake.simulate.mockResolvedValue({
      success: false,
      actions: [],
      logs: [],
      error: "exec reverted",
    });
    const { user, subject } = setup(chained(), { script: ACTION });
    await user.click(subject().getByRole("button", { name: ".owner()" }));
    expect(
      await screen.findByText(
        "Could not read that address from a simulation (exec reverted). Type the function to call.",
      ),
    ).toBeTruthy();
    expect(screen.getByPlaceholderText("balanceOf(address)")).toBeTruthy();
  });

  it("falls back when the call printed no address", async () => {
    fake.simulate.mockResolvedValue({ success: true, actions: [], logs: ["42"] });
    const { user, subject } = setup(chained());
    await user.click(subject().getByRole("button", { name: ".owner()" }));
    expect(
      await screen.findByText(/\(the call did not return an address\)/),
    ).toBeTruthy();
  });
});
