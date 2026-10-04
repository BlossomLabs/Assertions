// @vitest-environment jsdom
import type { SimulationResult } from "@evmcrispr/core";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { SimulationPanel, simKeyFor, useSimulation } from "../SimulationPanel";
import type { SimKey, SimulationState } from "../simulation";
import { useFreshTag } from "./helpers/fake-tag";

vi.mock("@evmcrispr/editor", async () =>
  (await import("./helpers/fake-tag")).fakeEditorModule(),
);

const FROM = "0x1234567890123456789012345678901234567890" as const;
const OTHER = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001" as const;
const T = "0x00000000000000000000000000000000000000aa";
const ACTION = `exec ${T} "pause()"`;
const ASSERT = `assert ${T}::!{paused()(bool)} == true`;
const PROTECTED = `${ACTION}\n${ASSERT}`;

const key = (partial: Partial<SimKey> = {}): SimKey => ({
  script: ACTION,
  from: FROM,
  chainId: 1,
  mode: "actions-only",
  ...partial,
});
const ok = (partial: Partial<SimulationResult> = {}): SimulationResult => ({
  success: true,
  logs: [],
  actions: [],
  ...partial,
});
const finished = (
  simulated: SimKey,
  result: SimulationResult,
): SimulationState => ({
  status: result.success ? "success" : "failure",
  result,
  simulated,
  finishedAt: 1_700_000_000_000,
});

/** A panel shown with a simulation in a given state. */
function show(
  state: SimulationState,
  simKey: SimKey,
  props: Partial<React.ComponentProps<typeof SimulationPanel>> = {},
) {
  const simulate = vi.fn(async () => undefined);
  const panel = (k: SimKey) => (
    <SimulationPanel
      label="Simulate batch"
      simKey={k}
      simulation={{ state, simulate, reset: vi.fn() }}
      {...props}
    />
  );
  const view = render(panel(simKey));
  return { simulate, rerenderWith: (k: SimKey) => view.rerender(panel(k)) };
}

const idle: SimulationState = { status: "idle", result: null, simulated: null };
const tx = { to: T, data: "0x" };
const check = { to: T, data: "0x", readOnly: true };

describe("SimulationPanel", () => {
  it("offers to simulate, saying as whom", async () => {
    const user = userEvent.setup();
    const { simulate } = show(idle, key());
    expect(screen.getByText("as 0x1234…7890")).toBeTruthy();
    await user.click(screen.getByRole("button", { name: "Simulate batch" }));
    expect(simulate).toHaveBeenCalledExactlyOnceWith(key());
  });

  it("says so when there is no executor", () => {
    show(idle, key({ from: undefined }));
    expect(screen.getByText("as no executor")).toBeTruthy();
  });

  it("cannot simulate an empty batch", () => {
    show(idle, key({ script: "  \n" }));
    const button = screen.getByRole("button", {
      name: "Simulate batch",
    }) as HTMLButtonElement;
    expect(button.disabled).toBe(true);
  });

  it("shows the note beside the button", () => {
    show(idle, key(), { note: "assertions are ignored here" });
    expect(screen.getByText("assertions are ignored here")).toBeTruthy();
  });

  it("says what is running while a simulation is under way", () => {
    show(
      { status: "running", result: null, simulated: key({ mode: "protected" }) },
      key({ mode: "protected" }),
    );
    const button = screen.getByRole("button", {
      name: "Simulating…",
    }) as HTMLButtonElement;
    expect(button.disabled).toBe(true);
    expect(
      screen.getByText("Simulating the protected batch on a fork…"),
    ).toBeTruthy();
    expect(screen.queryByText(/Simulation passed|Simulation failed/)).toBeNull();
  });

  it.each([
    [[tx], "Simulation passed (1 action)"],
    [[tx, tx], "Simulation passed (2 actions)"],
    [[], "Simulation passed (0 actions)"],
    [[tx, check], "Simulation passed (1 action, 1 assertion)"],
    [[check, check], "Simulation passed (2 assertions)"],
    [
      [{ type: "batched", actions: [tx, tx, check] }],
      "Simulation passed (2 actions, 1 assertion)",
    ],
  ])("counts what a passing run executed: %#", (actions, summary) => {
    show(finished(key(), ok({ actions: actions as any })), key());
    expect(screen.getByText(summary)).toBeTruthy();
    expect(screen.getByText("· actions only as 0x1234…7890")).toBeTruthy();
  });

  it("shows a pass with the solid ring and a failure with the failed one", () => {
    const { container } = render(
      <>
        <SimulationPanel
          label="one"
          simKey={key()}
          simulation={{
            state: finished(key(), ok()),
            simulate: vi.fn(),
            reset: vi.fn(),
          }}
        />
        <SimulationPanel
          label="two"
          simKey={key()}
          simulation={{
            state: finished(key(), ok({ success: false, error: "boom" })),
            simulate: vi.fn(),
            reset: vi.fn(),
          }}
        />
      </>,
    );
    expect(
      [...container.querySelectorAll("[data-state]")].map((el) =>
        el.getAttribute("data-state"),
      ),
    ).toEqual(["pass", "fail"]);
  });

  it("hides a result once the batch no longer matches what was simulated", () => {
    const { rerenderWith } = show(finished(key(), ok({ actions: [tx as any] })), key());
    expect(screen.getByText("Simulation passed (1 action)")).toBeTruthy();

    rerenderWith(key({ script: `${ACTION}\n${ACTION}` }));
    expect(screen.queryByText(/Simulation passed/)).toBeNull();
    // The button is back, for the batch as it is now.
    expect(
      (screen.getByRole("button", { name: "Simulate batch" }) as HTMLButtonElement)
        .disabled,
    ).toBe(false);

    // The same batch again: the result describes it once more.
    rerenderWith(key());
    expect(screen.getByText("Simulation passed (1 action)")).toBeTruthy();
  });

  it.each([
    ["another executor", { from: OTHER }],
    ["another network", { chainId: 100 }],
    ["another mode", { mode: "protected" as const }],
    ["no executor", { from: undefined }],
  ])("hides a result simulated for %s", (_name, change) => {
    const { rerenderWith } = show(finished(key(), ok()), key());
    expect(screen.getByText(/Simulation passed/)).toBeTruthy();
    rerenderWith(key(change));
    expect(screen.queryByText(/Simulation passed/)).toBeNull();
  });

  it("keeps a result for the same executor written in another case", () => {
    const { rerenderWith } = show(
      finished(key({ from: OTHER }), ok()),
      key({ from: OTHER }),
    );
    rerenderWith(key({ from: OTHER.toUpperCase().replace("0X", "0x") as any }));
    expect(screen.getByText(/Simulation passed/)).toBeTruthy();
  });

  it("hides a failure the same way", () => {
    const failed = finished(key(), ok({ success: false, error: "boom" }));
    const { rerenderWith } = show(failed, key(), { failureHint: "look at step 1" });
    expect(screen.getByText("Simulation failed")).toBeTruthy();
    rerenderWith(key({ script: "exec something else" }));
    expect(screen.queryByText("Simulation failed")).toBeNull();
    expect(screen.queryByText("boom")).toBeNull();
    expect(screen.queryByText("look at step 1")).toBeNull();
  });

  it("names the failing assertion, quoting it, with the error and the hint", () => {
    const k = key({ script: PROTECTED, mode: "protected" });
    // The simulation wraps the script in a two-line prelude: line 4 is the
    // script's second line.
    const error = "assert(4:0,4:20): the check did not hold";
    show(finished(k, ok({ success: false, error })), k, {
      failureHint: "Simulate the batch in step 1.",
    });
    expect(screen.getByText("Simulation failed")).toBeTruthy();
    expect(screen.getByText("· protected batch as 0x1234…7890")).toBeTruthy();
    expect(screen.getByText(/Failing assertion:/).textContent).toBe(
      `Failing assertion: ${ASSERT}`,
    );
    expect(
      screen.getByText(/Error on line 2:/).textContent,
    ).toBe(`Error on line 2: \`${ASSERT.slice(0, 20)}\`\n> the check did not hold`);
    expect(screen.getByText("Simulate the batch in step 1.")).toBeTruthy();
  });

  it("names a failing action as an action", () => {
    const k = key({ script: PROTECTED, mode: "protected" });
    show(finished(k, ok({ success: false, error: "exec(3:0,3:10): reverted" })), k);
    expect(screen.getByText(/Failing action:/).textContent).toBe(
      `Failing action: ${ACTION}`,
    );
  });

  it("shows an error that names no command as it is", () => {
    show(finished(key(), ok({ success: false, error: "network down" })), key());
    expect(screen.getByText("network down")).toBeTruthy();
    expect(screen.queryByText(/Failing/)).toBeNull();
  });

  it("does not show the failure hint on a pass", () => {
    show(finished(key(), ok()), key(), { failureHint: "look at step 1" });
    expect(screen.queryByText("look at step 1")).toBeNull();
  });

  it("shows the logs, with the interpreter's markers as emojis", () => {
    show(
      finished(key(), ok({ logs: [":success: all good", ":warning: careful"] })),
      key(),
    );
    expect(screen.getByText(/all good/).textContent).toBe(
      "✅ all good\n⚠️ careful",
    );
  });
});

describe("simKeyFor", () => {
  it("simulates the script as it is in protected mode, and without its assertions otherwise", () => {
    expect(simKeyFor("protected", PROTECTED, FROM, 1)).toEqual({
      script: PROTECTED,
      from: FROM,
      chainId: 1,
      mode: "protected",
    });
    expect(simKeyFor("actions-only", PROTECTED, FROM, 1)).toEqual({
      script: ACTION,
      from: FROM,
      chainId: 1,
      mode: "actions-only",
    });
  });
});

describe("useSimulation", () => {
  function Live({ simKey }: { simKey: SimKey }) {
    const simulation = useSimulation();
    return (
      <>
        <SimulationPanel label="Simulate batch" simKey={simKey} simulation={simulation} />
        <button type="button" onClick={simulation.reset}>
          reset
        </button>
      </>
    );
  }
  let fake: ReturnType<typeof useFreshTag>;
  beforeEach(() => {
    fake = useFreshTag();
  });

  it("runs the script on the key's chain as the key's executor and shows the pass", async () => {
    const user = userEvent.setup();
    fake.simulate.mockResolvedValue(ok({ actions: [tx as any] }));
    render(<Live simKey={key({ chainId: 100 })} />);
    await user.click(screen.getByRole("button", { name: "Simulate batch" }));
    expect(await screen.findByText("Simulation passed (1 action)")).toBeTruthy();
    expect(fake.withConfig).toHaveBeenCalledExactlyOnceWith({
      chainId: 100,
      account: FROM,
    });
    expect(fake.simulate).toHaveBeenCalledTimes(1);
    expect(fake.simulate.mock.calls[0][0]).toBe(ACTION);
    expect(fake.simulate.mock.calls[0][1]).toMatchObject({ from: FROM });
  });

  it("shows a run that reports failure as failed", async () => {
    const user = userEvent.setup();
    fake.simulate.mockResolvedValue(ok({ success: false, error: "reverted" }));
    render(<Live simKey={key()} />);
    await user.click(screen.getByRole("button", { name: "Simulate batch" }));
    expect(await screen.findByText("Simulation failed")).toBeTruthy();
    expect(screen.getByText("reverted")).toBeTruthy();
  });

  it("turns a simulation that throws into a failure with its message", async () => {
    const user = userEvent.setup();
    fake.simulate.mockRejectedValue(new Error("no RPC for this chain"));
    render(<Live simKey={key()} />);
    await user.click(screen.getByRole("button", { name: "Simulate batch" }));
    expect(await screen.findByText("Simulation failed")).toBeTruthy();
    expect(screen.getByText("no RPC for this chain")).toBeTruthy();
  });

  it("is busy while the run is in flight", async () => {
    const user = userEvent.setup();
    let finish: (r: SimulationResult) => void = () => {};
    fake.simulate.mockReturnValue(new Promise((resolve) => (finish = resolve)));
    render(<Live simKey={key()} />);
    await user.click(screen.getByRole("button", { name: "Simulate batch" }));
    expect(
      (screen.getByRole("button", { name: "Simulating…" }) as HTMLButtonElement)
        .disabled,
    ).toBe(true);
    expect(screen.getByText("Simulating the actions only on a fork…")).toBeTruthy();
    finish(ok());
    expect(await screen.findByText(/Simulation passed/)).toBeTruthy();
  });

  it("forgets the result on reset", async () => {
    const user = userEvent.setup();
    render(<Live simKey={key()} />);
    await user.click(screen.getByRole("button", { name: "Simulate batch" }));
    expect(await screen.findByText(/Simulation passed/)).toBeTruthy();
    await user.click(screen.getByRole("button", { name: "reset" }));
    expect(screen.queryByText(/Simulation passed/)).toBeNull();
  });
});
