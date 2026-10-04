// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { ExecutionContext } from "../context";
import type { SimKey, SimulationState } from "../simulation";
import { SubmitStage } from "../SubmitStage";
import type { EyeState } from "../timeline";
import { useFreshTag } from "./helpers/fake-tag";
import { resetWallet, wallet } from "./helpers/fake-wagmi";

vi.mock("@evmcrispr/editor", async () =>
  (await import("./helpers/fake-tag")).fakeEditorModule(),
);
vi.mock("wagmi", async (importOriginal) =>
  (await import("./helpers/fake-wagmi")).fakeWagmiModule(await importOriginal()),
);

const FROM = "0x1234567890123456789012345678901234567890" as const;
const OTHER = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001" as const;
const T = "0x00000000000000000000000000000000000000aa";
const ACTION = `exec ${T} "pause()"`;
const ASSERT = `assert ${T}::!{paused()(bool)} == true`;
const SCRIPT = `${ACTION}\n${ASSERT}`;
/** 14:05 local time, whatever the machine's zone. */
const FINISHED = new Date(2026, 0, 15, 14, 5, 0).getTime();

const ran = (from: SimKey["from"] = FROM): SimKey => ({
  script: SCRIPT,
  from,
  chainId: 1,
  mode: "protected",
});
const sim = (partial: Partial<SimulationState>): SimulationState => ({
  status: "success",
  result: { success: true, logs: [], actions: [] },
  simulated: ran(),
  finishedAt: FINISHED,
  ...partial,
});
const failed = (error: string | undefined): SimulationState =>
  sim({
    status: "failure",
    result: { success: false, logs: [], actions: [], error },
  });

function show(
  gate: EyeState,
  simulation?: SimulationState,
  context: ExecutionContext = { kind: "eoa" },
  contextAddress: `0x${string}` | null = null,
) {
  const view = render(
    <SubmitStage
      block={SCRIPT}
      context={context}
      contextAddress={contextAddress}
      chainId={1}
      gate={gate}
      simulation={simulation}
    />,
  );
  /** The gate's sentence: its lead in bold, then the rest. */
  const sentence = view.container.querySelector("p");
  return {
    ...view,
    lead: sentence?.querySelector("span")?.textContent,
    text: sentence?.textContent,
    ring: view.container.querySelector("[data-state]")?.getAttribute("data-state"),
  };
}

beforeEach(() => {
  resetWallet();
  useFreshTag();
});

describe("SubmitStage: the gate", () => {
  it("passes with a receipt: when it ran and as which account", () => {
    const { lead, text, ring } = show("pass", sim({}));
    expect(lead).toBe("Passed.");
    expect(text).toMatch(
      /^Passed\. Simulated on a fork at \D*0?2[:.]05\D*, as 0x1234…7890\.$|^Passed\. Simulated on a fork at 14[:.]05, as 0x1234…7890\.$/,
    );
    expect(ring).toBe("pass");
  });

  it("names the default account when the run had no executor", () => {
    const { text } = show("pass", sim({ simulated: { ...ran(), from: undefined } }));
    expect(text).toMatch(/, as the default account\.$/);
  });

  it("leaves the time out when the run did not record one", () => {
    const { text } = show("pass", sim({ finishedAt: undefined }));
    expect(text).toBe("Passed. Simulated on a fork, as 0x1234…7890.");
  });

  it("says which kind of command a failure stopped at: an assertion", () => {
    // Line 4 of the wrapped script is the assert, the script's second line.
    const { lead, text, ring } = show("fail", failed("assert(4:0,4:12): did not hold"));
    expect(lead).toBe("Failed at an assertion.");
    expect(text).toMatch(
      /^Failed at an assertion\. Simulated on a fork at .+, as 0x1234…7890\. Nothing would have been executed\. See step 2\.$/,
    );
    expect(ring).toBe("fail");
  });

  it("says which kind of command a failure stopped at: an action", () => {
    const { lead, text } = show("fail", failed("exec(3:0,3:12): reverted"));
    expect(lead).toBe("Failed at an action.");
    expect(text).toMatch(/Nothing would have been executed\. See step 2\.$/);
  });

  it("just says Failed when the error names no command", () => {
    const { lead, text } = show("fail", failed("network down"));
    expect(lead).toBe("Failed.");
    expect(text).toMatch(
      /^Failed\. Simulated on a fork at .+, as 0x1234…7890\. Nothing would have been executed\. See step 2\.$/,
    );
    expect(show("fail", failed(undefined)).lead).toBe("Failed.");
  });

  it("is out of date, with no receipt, once the batch moved on from its last run", () => {
    // The last run passed, but for another batch: the gate is stale.
    const { lead, text, ring } = show("stale", sim({}));
    expect(lead).toBe("Out of date.");
    expect(text).toBe(
      "Out of date. The protected batch has not passed a simulation in its current form. Simulate it in step 2 before submitting.",
    );
    expect(text).not.toMatch(/Simulated on a fork/);
    expect(ring).toBe("stale");
  });

  it("falls back to the plain sentence when there is no run to report", () => {
    expect(show("pass").text).toBe(
      "Passed. The protected batch passes a simulation in its current form.",
    );
    expect(show("fail").text).toBe(
      "Failed. The protected batch fails its simulation. See step 2.",
    );
  });

  it("says there is nothing to submit for an empty batch", () => {
    const { text, ring } = show("asleep");
    expect(text).toBe("Nothing to submit. Add actions to the batch in step 1.");
    expect(ring).toBe("asleep");
  });

  it("says a simulation is running", () => {
    const { text, ring } = show("running", sim({ status: "running" }));
    expect(text).toBe("Simulating… Running the protected batch on a fork.");
    expect(ring).toBe("running");
  });
});

describe("SubmitStage: the final script and sending", () => {
  it("shows the script as it will be sent, wrapped for the executor", () => {
    const { container } = show("pass", sim({}));
    expect(screen.getByText("Final script (A wallet)")).toBeTruthy();
    const script = container.querySelector("pre")?.textContent ?? "";
    expect(script).toContain("batch (");
    expect(script).toContain(ACTION);
    expect(script).toContain(ASSERT);
  });

  it("wraps a Safe's batch as a proposal and offers the Transaction Builder file", () => {
    const { container } = show("pass", sim({}), { kind: "safe", address: OTHER }, OTHER);
    expect(screen.getByText("Final script (Safe)")).toBeTruthy();
    expect(container.querySelector("pre")?.textContent).toContain(
      `safe:propose ${OTHER} (`,
    );
    expect(
      screen.getByRole("button", { name: "Download Transaction Builder JSON" }),
    ).toBeTruthy();
  });

  it("does not offer the Transaction Builder file to a wallet", () => {
    show("pass", sim({}));
    expect(
      screen.queryByRole("button", { name: "Download Transaction Builder JSON" }),
    ).toBeNull();
  });

  it("asks for a wallet when none is connected", async () => {
    const user = userEvent.setup();
    show("pass", sim({}));
    expect(screen.queryByRole("button", { name: "Execute batch" })).toBeNull();
    await user.click(screen.getByRole("button", { name: "Connect wallet" }));
    expect(wallet.connect).toHaveBeenCalledTimes(1);
  });

  it.each([
    ["eoa", "Execute batch"],
    ["safe", "Propose to Safe"],
    ["governor", "Create Governor proposal"],
    ["aragonosx", "Create DAO proposal"],
  ] as const)("names the send button for a %s", (kind, label) => {
    wallet.address = FROM;
    wallet.client = {};
    show("pass", sim({}), { kind, address: kind === "eoa" ? undefined : OTHER, plugin: "multisig" }, kind === "eoa" ? null : OTHER);
    expect(screen.getByRole("button", { name: label })).toBeTruthy();
  });

  it("sends the final script with the connected wallet", async () => {
    const user = userEvent.setup();
    const fake = useFreshTag();
    wallet.address = FROM;
    wallet.client = { id: "wallet" };
    const { container } = show("pass", sim({}));
    await user.click(screen.getByRole("button", { name: "Execute batch" }));
    expect(await screen.findByText("Batch executed.")).toBeTruthy();
    expect(fake.execute).toHaveBeenCalledExactlyOnceWith(
      container.querySelector("pre")?.textContent,
      wallet.client,
    );
  });

  it("shows why sending failed", async () => {
    const user = userEvent.setup();
    const fake = useFreshTag();
    fake.execute.mockRejectedValue(new Error("User rejected the request"));
    wallet.address = FROM;
    wallet.client = {};
    show("pass", sim({}));
    await user.click(screen.getByRole("button", { name: "Execute batch" }));
    expect(await screen.findByText("User rejected the request")).toBeTruthy();
    expect(screen.queryByText("Batch executed.")).toBeNull();
  });

  it("refuses to send a batch built for another account than the connected one", () => {
    wallet.address = FROM;
    wallet.client = {};
    show("pass", sim({}), { kind: "eoa", address: OTHER }, OTHER);
    expect(
      (screen.getByRole("button", { name: "Execute batch" }) as HTMLButtonElement)
        .disabled,
    ).toBe(true);
    expect(screen.getByText(/but another wallet is connected/)).toBeTruthy();
    expect(screen.getByText("0xabcd…0001")).toBeTruthy();
  });

  it("sends a batch built for the connected account itself", () => {
    wallet.address = FROM;
    wallet.client = {};
    show("pass", sim({}), { kind: "eoa", address: FROM }, FROM);
    expect(
      (screen.getByRole("button", { name: "Execute batch" }) as HTMLButtonElement)
        .disabled,
    ).toBe(false);
    expect(screen.queryByText(/another wallet is connected/)).toBeNull();
  });
});
