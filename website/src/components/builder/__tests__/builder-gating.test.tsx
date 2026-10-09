// @vitest-environment jsdom
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import AssertionBuilder from "../AssertionBuilder";
import { clearContracts, registerContract } from "./helpers/fake-contracts";
import { type FakeTag, useFreshTag } from "./helpers/fake-tag";
import { resetWallet, wallet } from "./helpers/fake-wagmi";

vi.mock("../useIsSafe", async () =>
  (await import("./helpers/fake-safe")).fakeIsSafeModule(),
);
vi.mock("@evmcrispr/editor", async () =>
  (await import("./helpers/fake-tag")).fakeEditorModule(),
);
vi.mock("wagmi", async (importOriginal) =>
  (await import("./helpers/fake-wagmi")).fakeWagmiModule(await importOriginal()),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);
// The interpreter and its modules: the fake tag stands in for all of it.
vi.mock("../evml", () => ({
  evml: {},
  createLiveTag: (current: () => unknown) => current(),
}));
vi.mock("../useBuilderChatAgent", () => ({
  builderChatStorage: { getApiKey: () => null },
  builderAuth: { loginWithNexus: vi.fn(), logoutNexus: vi.fn() },
  useBuilderChatAgent: () => ({
    hasKey: false,
    isRunning: false,
    items: [],
    error: null,
    setApiKey: vi.fn(),
    clearApiKey: vi.fn(),
    send: vi.fn(),
    stop: vi.fn(),
  }),
}));
vi.mock("../useContextAddressCheck", () => ({
  useContextAddress: () => ({ resolved: null, check: { state: "idle" } }),
  useGovernorTimelock: () => null,
}));
vi.mock("../useChainSupport", () => ({
  OFFICIAL_CHAIN_IDS: new Set([1, 100, 8453, 10, 42161, 137, 11155111]),
  useChainClient: () => undefined,
  useChainSupport: () => ({ state: "official" }),
}));
vi.mock("../compile-adapter", () => ({
  previewSubjectValue: vi.fn(),
  compileAssertionLine: vi.fn(async (_tag: unknown, script: string) => ({
    ok: true,
    diagnostics: [],
    candidate: script,
    insertedAt: 1,
  })),
}));

const ME = "0x1234567890123456789012345678901234567890" as const;
const T = "0x00000000000000000000000000000000000000aa";
const ACTION = `exec ${T} "pause()"`;

const NO_EXECUTOR = "Choose the executor in step 1 first.";
const NO_ACTION = "Add an action in step 1 first.";
const NOT_SIMULATED = "Simulate the batch in step 1 first.";
const NO_ASSERTION = "Add an assertion in step 2 first.";
const NOT_PROTECTED = "Simulate the protected batch in step 2 first.";

/** A numbered step: its card, whether it is folded, and the hint it shows. */
function step(n: 1 | 2 | 3) {
  const title = { 1: "Compose", 2: "Assertions", 3: "Submit" }[n];
  const heading = screen.getByRole("heading", {
    name: new RegExp(`^${n}\\s*${title}`),
  });
  const section = heading.closest("section") as HTMLElement;
  const hints = [NO_EXECUTOR, NO_ACTION, NOT_SIMULATED, NO_ASSERTION, NOT_PROTECTED];
  return {
    in: within(section),
    /** The body cannot be reached or used while folded. */
    folded: section.querySelector("[inert]") !== null,
    hint: hints.find((h) => within(heading).queryByText(h)) ?? null,
    ring: within(heading).queryByRole("img")?.getAttribute("aria-label") ?? null,
  };
}

const connect = () => {
  wallet.address = ME;
  wallet.chain = { id: 1, name: "Ethereum" };
};

async function addAction(user: ReturnType<typeof userEvent.setup>) {
  const compose = step(1).in;
  await user.click(compose.getByPlaceholderText("0x… or mydao.eth"));
  await user.paste(T);
  await user.click(compose.getByRole("button", { name: "Select a function…" }));
  await user.click(screen.getByRole("option", { name: "pause()" }));
  await user.click(compose.getByRole("button", { name: "Add to batch" }));
}

let fake: FakeTag;
beforeEach(() => {
  resetWallet();
  clearContracts();
  registerContract(T, { name: "Pausable", abi: ["function pause()"] });
  fake = useFreshTag(ME);
});

describe("AssertionBuilder: which steps are open", () => {
  it("waits for an executor before anything else", () => {
    render(<AssertionBuilder />);
    expect(step(1)).toMatchObject({ folded: false, hint: null });
    expect(step(2)).toMatchObject({ folded: true, hint: NO_EXECUTOR });
    expect(step(3)).toMatchObject({ folded: true, hint: NO_EXECUTOR });
    // Nothing to skip to without an executor.
    expect(screen.queryByRole("button", { name: /Skip actions/ })).toBeNull();
  });

  it("then waits for an action, offering to skip them", () => {
    connect();
    render(<AssertionBuilder />);
    expect(step(2)).toMatchObject({ folded: true, hint: NO_ACTION });
    expect(step(3)).toMatchObject({ folded: true, hint: NO_ACTION });
    const skip = step(1).in.getByRole("button", { name: /Skip actions/ });
    // Next to "Add to batch".
    expect(
      within(skip.parentElement as HTMLElement).getByRole("button", {
        name: "Add to batch",
      }),
    ).toBeTruthy();
    expect(step(1).ring).toBe(
      "Simulation of the actions on their own: nothing to simulate yet.",
    );
  });

  it("opens step 2 on 'Skip actions', and keeps step 3 for a batch with an assertion", async () => {
    connect();
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await user.click(step(1).in.getByRole("button", { name: /Skip actions/ }));
    expect(step(2)).toMatchObject({ folded: false, hint: null });
    expect(step(3)).toMatchObject({ folded: true, hint: NO_ASSERTION });
    // Skipped: the offer is gone.
    expect(screen.queryByRole("button", { name: /Skip actions/ })).toBeNull();
  });

  it("keeps steps 2 and 3 folded until each previous simulation has passed", async () => {
    connect();
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addAction(user);

    // A batch, not simulated yet.
    expect(step(1).in.getByText(ACTION)).toBeTruthy();
    expect(step(2)).toMatchObject({ folded: true, hint: NOT_SIMULATED });
    expect(step(3)).toMatchObject({ folded: true, hint: NOT_SIMULATED });
    expect(screen.queryByRole("button", { name: /Skip actions/ })).toBeNull();
    expect(step(1).ring).toBe(
      "Simulation of the actions on their own: not run for the batch as it is now.",
    );

    // Step 1's simulation passes: step 2 opens, step 3 waits for step 2's.
    await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
    expect(await step(1).in.findByText(/Simulation passed/)).toBeTruthy();
    expect(fake.simulate.mock.calls[0][0]).toBe(ACTION);
    expect(step(1).ring).toBe("Simulation of the actions on their own: passed.");
    expect(step(2)).toMatchObject({ folded: false, hint: null });
    expect(step(3)).toMatchObject({ folded: true, hint: NOT_PROTECTED });
    expect(step(2).ring).toBe(
      "Simulation of the protected batch: not run for the batch as it is now.",
    );

    // Step 2's simulation passes: step 3 opens, with the gate passed.
    await user.click(step(2).in.getByRole("button", { name: "Simulate batch" }));
    expect(await step(2).in.findByText(/Simulation passed/)).toBeTruthy();
    expect(step(3)).toMatchObject({ folded: false, hint: null });
    expect(step(3).in.getByText("Passed.")).toBeTruthy();
    expect(step(2).ring).toBe("Simulation of the protected batch: passed.");
  });

  it("does not open step 2 on a failed simulation", async () => {
    connect();
    fake.simulate.mockResolvedValue({
      success: false,
      logs: [],
      actions: [],
      error: "exec(3:0,3:10): reverted",
    });
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addAction(user);
    await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
    expect(await step(1).in.findByText("Simulation failed")).toBeTruthy();
    expect(step(1).ring).toBe("Simulation of the actions on their own: failed.");
    expect(step(2)).toMatchObject({ folded: true, hint: NOT_SIMULATED });
  });

  it("keeps a step open through later edits, with its simulation out of date", async () => {
    connect();
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addAction(user);
    await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
    await step(1).in.findByText(/Simulation passed/);

    await addAction(user);
    expect(step(2)).toMatchObject({ folded: false, hint: null });
    expect(step(1).ring).toBe(
      "Simulation of the actions on their own: not run for the batch as it is now.",
    );
    // The result no longer describes the batch: it is gone.
    expect(step(1).in.queryByText(/Simulation passed/)).toBeNull();
  });

  it("starts over when the batch is emptied", async () => {
    connect();
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addAction(user);
    await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
    await step(1).in.findByText(/Simulation passed/);
    expect(step(2).folded).toBe(false);

    await user.click(
      step(1).in.getByRole("button", { name: `Remove command: ${ACTION}` }),
    );
    expect(step(2)).toMatchObject({ folded: true, hint: NO_ACTION });
    expect(step(3)).toMatchObject({ folded: true, hint: NO_ACTION });
    expect(step(1).in.getByRole("button", { name: /Skip actions/ })).toBeTruthy();

    // And a new batch has to pass again.
    await addAction(user);
    expect(step(2)).toMatchObject({ folded: true, hint: NOT_SIMULATED });
  });

  it("keeps the assistant's API key field behind the cog", async () => {
    connect();
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    const aside = within(screen.getByRole("complementary"));
    expect(aside.queryByPlaceholderText("sk-…")).toBeNull();
    await user.click(aside.getByRole("button", { name: "Use your own API key" }));
    expect(aside.getByPlaceholderText("sk-…")).toBeTruthy();
  });
});
