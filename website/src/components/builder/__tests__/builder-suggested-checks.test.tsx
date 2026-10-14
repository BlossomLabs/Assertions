// @vitest-environment jsdom
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { getAddress } from "viem";
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
// The assistant: logged out unless a test logs in.
const assistant = vi.hoisted(() => ({ hasKey: false }));
vi.mock("../useBuilderChatAgent", () => ({
  builderChatStorage: { getApiKey: () => null },
  builderAuth: { loginWithNexus: vi.fn(), logoutNexus: vi.fn() },
  useBuilderChatAgent: () => ({
    hasKey: assistant.hasKey,
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
// The chain's latest block, as the builder's client for the chain reads it.
const chain = vi.hoisted(() => ({
  block: 21_234_567n,
  getBlockNumber: undefined as unknown as ReturnType<typeof import("vitest").vi.fn>,
  /** `decimals()` by token address; a contract not listed here has none. */
  decimals: {} as Record<string, number>,
  /** The chain's token list. */
  tokens: [] as { symbol: string; chainId: number; address: string }[],
  /** The addresses with code. */
  contracts: new Set<string>(),
}));
vi.mock("../useChainSupport", () => ({
  OFFICIAL_CHAIN_IDS: new Set([1, 100, 8453, 10, 42161, 137, 11155111]),
  useChainClient: () => ({
    getBlockNumber: chain.getBlockNumber,
    getCode: async ({ address }: { address: string }) =>
      chain.contracts.has(address.toLowerCase()) ? "0x6080" : "0x",
    readContract: async ({ address }: { address: string }) => {
      if (!(address in chain.decimals)) throw new Error("execution reverted");
      return chain.decimals[address];
    },
  }),
  useChainSupport: () => ({ state: "official" }),
}));
// The chain's token list: none here, so no address is named after a token.
vi.mock("../token-list", () => ({ tokenList: async () => chain.tokens }));
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
const NEW_OWNER = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001";
// The composer names the contract once and calls it by that name.
const SET = `set $contract ${getAddress(T)}`;
const ACTION = `exec $contract "pause()"`;
const SCRIPT = `${SET}\n${ACTION}`;

const short = (a: string) => `${a.slice(0, 6)}…${a.slice(-4)}`;
const PAUSED = {
  line: "assert $contract::!{paused()(bool)} == true",
  vars: [{ name: "contract", value: T as `0x${string}` }],
  sentence: [
    { type: "address" as const, address: T as `0x${string}` },
    { type: "text" as const, text: " is paused" },
  ],
  description: "0x0000...00aa is paused",
  kind: "state" as const,
  module: "std",
  event: "paused",
  eventName: "Paused",
  emitter: T as `0x${string}`,
};
const OWNER = {
  line: "assert @acl:owner!($contract) == $owner",
  vars: [
    { name: "contract", value: T as `0x${string}` },
    { name: "owner", value: NEW_OWNER as `0x${string}` },
  ],
  sentence: [
    { type: "address" as const, address: T as `0x${string}` },
    { type: "text" as const, text: " is owned by " },
    { type: "address" as const, address: NEW_OWNER as `0x${string}` },
  ],
  description: "0x0000...00aa is owned by 0xabcd...0001",
  kind: "state" as const,
  module: "acl",
  event: "ownershipTransferred",
  eventName: "OwnershipTransferred",
  emitter: T as `0x${string}`,
};
const SPENT = {
  line: "assert @balance!($contract $executor) >= @token:amount($contract 95)",
  vars: [
    { name: "contract", value: T as `0x${string}` },
    { name: "executor", value: ME as `0x${string}` },
  ],
  sentence: [
    { type: "address" as const, address: ME as `0x${string}` },
    { type: "text" as const, text: " keeps at least " },
    {
      type: "amount" as const,
      value: "95000000",
      bound: "floor" as const,
      token: T as `0x${string}`,
      symbol: "TKN",
      decimals: 6,
      text: "95 TKN",
    },
  ],
  description: "0x1234...7890 keeps at least 95 TKN (0x0000...00aa)",
  kind: "amount" as const,
  module: "token",
  event: "erc20Transfer",
  eventName: "Transfer",
  emitterName: "TKN",
  emitter: T as `0x${string}`,
};
/** The accessible name of a row's Add button. */
const addName = (check: { description: string }) =>
  `Add check: ${check.description.replace(/\.\.\./g, "…")}`;
const WARNING = "Balances may change before the proposal executes.";

function step(n: 1 | 2 | 3) {
  const title = { 1: "Compose", 2: "Assertions", 3: "Submit" }[n];
  const heading = screen.getByRole("heading", {
    name: new RegExp(`^${n}\\s*${title}`),
  });
  const section = heading.closest("section") as HTMLElement;
  return {
    in: within(section),
    ring: within(heading).queryByRole("img")?.getAttribute("aria-label") ?? null,
  };
}

async function addAction(user: ReturnType<typeof userEvent.setup>) {
  const compose = step(1).in;
  await user.click(compose.getByPlaceholderText("0x… or mydao.eth"));
  await user.paste(T);
  await user.click(compose.getByRole("button", { name: "Select a function…" }));
  await user.click(screen.getByRole("option", { name: "pause()" }));
  await user.click(compose.getByRole("button", { name: "Add to batch" }));
}

/** A step-1 run that answers with `suggestions`. */
const answering = (suggestions?: unknown[]) =>
  fake.simulate.mockResolvedValue({
    success: true,
    logs: [],
    actions: [],
    ...(suggestions ? { suggestions } : {}),
  } as never);

const simulateActions = async (user: ReturnType<typeof userEvent.setup>) => {
  await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
  await step(1).in.findByText(/Simulation passed/);
};

/** A builder with one action whose step-1 simulation has passed, having
 *  suggested `suggestions`. */
async function composed(user: ReturnType<typeof userEvent.setup>, suggestions?: unknown[]) {
  wallet.address = ME;
  wallet.chain = { id: 1, name: "Ethereum" };
  render(<AssertionBuilder />);
  await addAction(user);
  answering(suggestions);
  await simulateActions(user);
}

const simulateProtected = async (user: ReturnType<typeof userEvent.setup>) => {
  await user.click(
    step(2).in.getByRole("button", { name: /^Simulate (protected )?batch$/ }),
  );
  await step(2).in.findByText(/Simulation passed/);
};

/** The box at the top of step 2. */
const box = () => {
  const found = document.querySelector("[data-suggested-checks]");
  if (!found) throw new Error("no suggested checks box");
  return within(found as HTMLElement);
};
const suggested = () => box().queryAllByRole("listitem");
const removeName = (check: { description: string }) =>
  `Remove check: ${check.description.replace(/\.\.\./g, "…")}`;
const more = () =>
  box().getByRole("button", { name: /Suggest more assertions/ }) as HTMLButtonElement;
/** The commands of step 2's batch listing. */
const batch = () =>
  [...step(2).in.queryAllByRole("button", { name: /^Remove command: / })].map((b) =>
    b.getAttribute("aria-label")?.replace("Remove command: ", ""),
  );

let fake: FakeTag;
beforeEach(() => {
  resetWallet();
  clearContracts();
  registerContract(T, { name: "Pausable", abi: ["function pause()"] });
  fake = useFreshTag(ME);
  chain.block = 21_234_567n;
  chain.decimals = {};
  chain.tokens = [];
  chain.getBlockNumber = vi.fn(async () => chain.block++);
  assistant.hasKey = false;
});

/** A line as step 1's run adds it: marked as a suggestion. */
const marked = (line: string) => `${line}  # suggested`;
/** A row's Keep, in the box, by the check: it makes the check yours. */
const unmarkName = (check: { description: string }) =>
  `Keep check: ${check.description.replace(/\.\.\./g, "…")}`;

describe("AssertionBuilder: suggested checks", () => {
  it("asks step 1's simulation, as the executor, and adds what it suggests, marked", async () => {
    const user = userEvent.setup();
    await composed(user, [PAUSED, OWNER, SPENT]);
    expect(fake.simulate.mock.calls[0][1]).toMatchObject({
      from: ME,
      // A wallet sends the batch itself, right away: exact amounts.
      suggest: { executor: ME, exact: true },
    });
    expect(box().getByRole("heading", { name: "Suggested checks" })).toBeTruthy();
    // In the batch already: the listing writes each line as the script
    // does, its mark a dimmed comment; the chip is on its row in the box.
    expect(batch()).toEqual([PAUSED.line, OWNER.line, SPENT.line]);
    const comments = step(2).in.getAllByText("# suggested");
    expect(comments).toHaveLength(3);
    expect(comments[0].className).toContain("text-[var(--color-ink-3)]");
    for (const check of [PAUSED, OWNER, SPENT])
      expect(box().getByRole("button", { name: unmarkName(check) })).toBeTruthy();
    // Listed, each to remove; no Add all.
    expect(suggested()).toHaveLength(3);
    expect(box().getAllByRole("button", { name: /^Remove check:/ })).toHaveLength(3);
    expect(box().queryByRole("button", { name: "Add all" })).toBeNull();
    // Sentences, with what they mention linked; no EVML until asked for.
    expect(suggested().map((row) => row.querySelector("p")?.textContent)).toEqual([
      `${short(T)} is paused`,
      `${short(T)} is owned by ${short(NEW_OWNER)}`,
      `${short(ME)} keeps at least 95 TKN (${short(T)})`,
    ]);
    const links = () =>
      within(suggested()[1]).getAllByRole("link").map((a) => a.getAttribute("href"));
    expect(links()).toEqual([
      `https://etherscan.io/address/${T}`,
      `https://etherscan.io/address/${NEW_OWNER}`,
    ]);
    // Where it comes from is behind its (i).
    await user.click(
      within(suggested()[1]).getByRole("button", { name: "About this check" }),
    );
    expect(links()).toEqual([
      `https://etherscan.io/address/${T}`,
      `https://etherscan.io/address/${NEW_OWNER}`,
      `https://etherscan.io/address/${T}`,
    ]);
    // A wallet executes right away: no notice on the amount.
    expect(step(2).in.queryByText(WARNING)).toBeNull();
    // The form that builds a check by hand is below, shown on request.
    const boxEl = document.querySelector("[data-suggested-checks]")!;
    const manual = box().getByRole("button", { name: "Add assertions manually" });
    const form = document.getElementById(manual.getAttribute("aria-controls")!)!;
    expect(form.hidden).toBe(true);
    await user.click(manual);
    expect(form.hidden).toBe(false);
    expect(within(form).getByText("Build an assertion")).toBeTruthy();
    expect(boxEl.compareDocumentPosition(form) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    // The step-2 batch listing has no picture of before, actions and after.
    expect(step(2).in.queryByText("BEFORE")).toBeNull();
    // What is simulated carries the marks.
    await simulateProtected(user);
    expect(fake.simulate.mock.calls.at(-1)?.[0]).toBe(
      [
        "load acl",
        "load token",
        SET,
        `set $owner ${NEW_OWNER}`,
        `set $executor ${ME}`,
        ACTION,
        marked(PAUSED.line),
        marked(OWNER.line),
        marked(SPENT.line),
      ].join("\n"),
    );
  });

  it("removes a suggestion from its row, with the variables only it used, and adds it back", async () => {
    const user = userEvent.setup();
    await composed(user, [PAUSED, OWNER, SPENT]);
    await user.click(box().getByRole("button", { name: removeName(SPENT) }));
    await user.click(box().getByRole("button", { name: removeName(OWNER) }));
    expect(batch()).toEqual([PAUSED.line]);
    await simulateProtected(user);
    expect(fake.simulate.mock.calls.at(-1)?.[0]).toBe(
      [SET, ACTION, marked(PAUSED.line)].join("\n"),
    );
    await user.click(box().getByRole("button", { name: addName(OWNER) }));
    expect(batch()).toEqual([PAUSED.line, OWNER.line]);
    expect(box().getByRole("button", { name: unmarkName(OWNER) })).toBeTruthy();
  });

  it("keeps a check as yours: the mark goes, the check stays", async () => {
    const user = userEvent.setup();
    await composed(user, [PAUSED, OWNER]);
    await user.click(box().getByRole("button", { name: unmarkName(OWNER) }));
    expect(box().queryByRole("button", { name: unmarkName(OWNER) })).toBeNull();
    // Still listed, to remove, and to hand back.
    expect(box().getByRole("button", { name: removeName(OWNER) })).toBeTruthy();
    const unkeep = `Unkeep check: ${OWNER.description.replace(/\.\.\./g, "…")}`;
    expect(box().getByRole("button", { name: unkeep })).toBeTruthy();
    expect(batch()).toEqual([PAUSED.line, OWNER.line]);
    await simulateProtected(user);
    expect(fake.simulate.mock.calls.at(-1)?.[0]).toBe(
      ["load acl", SET, `set $owner ${NEW_OWNER}`, ACTION, marked(PAUSED.line), OWNER.line].join("\n"),
    );
  });

  it("hands a kept check back with Unkeep: the mark returns, the next run manages it", async () => {
    const user = userEvent.setup();
    await composed(user, [PAUSED, OWNER]);
    const unkeep = `Unkeep check: ${OWNER.description.replace(/\.\.\./g, "…")}`;
    await user.click(box().getByRole("button", { name: unmarkName(OWNER) }));
    await user.click(box().getByRole("button", { name: unkeep }));
    expect(box().queryByRole("button", { name: unkeep })).toBeNull();
    expect(box().getByRole("button", { name: unmarkName(OWNER) })).toBeTruthy();
    // Managed again: a run that no longer suggests it takes it out.
    answering([PAUSED]);
    await simulateActions(user);
    expect(batch()).toEqual([PAUSED.line]);
  });

  it("confirms the suggested checks at the block of step 1's run, then moves on", async () => {
    const user = userEvent.setup();
    await composed(user, [PAUSED, OWNER]);
    // Step 1 read the block it forked: that is what suggested.
    expect(chain.getBlockNumber).toHaveBeenCalledExactlyOnceWith({ cacheTime: 0 });
    expect(fake.simulate.mock.calls[0][1]).toMatchObject({ blockNumber: 21_234_567 });
    await simulateProtected(user);
    expect(chain.getBlockNumber).toHaveBeenCalledTimes(1);
    expect(fake.simulate.mock.calls[1][1]).toMatchObject({ blockNumber: 21_234_567 });
    expect(step(2).in.getByText(/at block 21 234 567/)).toBeTruthy();

    // Another action: the batch is no longer the one those checks came from.
    await addAction(user);
    await simulateProtected(user);
    expect(chain.getBlockNumber).toHaveBeenCalledTimes(2);
    expect(fake.simulate.mock.calls[2][1]).toMatchObject({ blockNumber: 21_234_568 });
    expect(step(2).in.queryByText(/at block/)).toBeNull();
  });

  it("says so when step 1's simulation suggested nothing", async () => {
    const user = userEvent.setup();
    await composed(user, []);
    expect(box().getByText("This simulation suggested no checks.")).toBeTruthy();
    expect(suggested()).toHaveLength(0);
    expect(batch()).toEqual([]);
  });

  it("asks for step 1's simulation when step 2 is opened without one", async () => {
    const user = userEvent.setup();
    wallet.address = ME;
    wallet.chain = { id: 1, name: "Ethereum" };
    render(<AssertionBuilder />);
    await user.click(step(1).in.getByRole("button", { name: /Skip actions/ }));
    expect(
      box().getByText("Simulate the batch in step 1 to see the checks it suggests."),
    ).toBeTruthy();
    expect(more().disabled).toBe(true);
    expect(box().getByText("Simulate the batch in step 1 first.")).toBeTruthy();
  });

  it("keeps Suggest more assertions disabled until the batch is freshly simulated and the assistant logged in", async () => {
    const user = userEvent.setup();
    await composed(user, [PAUSED]);
    expect(more().disabled).toBe(true);
    expect(
      box().getByText("Log in to Dappnode Nexus in the assistant panel to use it."),
    ).toBeTruthy();
    await addAction(user);
    expect(more().disabled).toBe(true);
    expect(
      box().getByText("The batch changed since its last simulation: simulate it again first."),
    ).toBeTruthy();
  });

  it("enables Suggest more assertions for a freshly simulated batch with the assistant logged in", async () => {
    assistant.hasKey = true;
    const user = userEvent.setup();
    await composed(user, [PAUSED]);
    expect(more().disabled).toBe(false);
  });
});

describe("AssertionBuilder: a composed token transfer", () => {
  const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const DEAD = "0x000000000000000000000000000000000000dEaD";
  const TRANSFER = 'exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 1)';
  const KEEPS = {
    line: "assert @balance!($usdc $recipient) >= @token:amount($usdc 5)",
    vars: [
      { name: "usdc", value: USDC as `0x${string}` },
      { name: "recipient", value: DEAD as `0x${string}` },
    ],
    sentence: [
      { type: "address" as const, address: DEAD as `0x${string}` },
      { type: "text" as const, text: " holds at least " },
      {
        type: "amount" as const,
        value: "5000000",
        bound: "floor" as const,
        token: USDC as `0x${string}`,
        symbol: "USDC",
        decimals: 6,
        listed: true as const,
        text: "5 USDC",
      },
    ],
    description: "0x0000...dEaD holds at least 5 USDC (0xA0b8...eB48)",
    kind: "amount" as const,
    module: "token",
    event: "erc20Transfer",
    eventName: "Transfer",
    emitterName: "USDC",
    emitter: USDC as `0x${string}`,
  };

  async function addTransfer(user: ReturnType<typeof userEvent.setup>, to = DEAD, written = TRANSFER) {
    const compose = step(1).in;
    await user.click(compose.getByPlaceholderText("0x… or mydao.eth"));
    await user.paste(USDC);
    await user.click(compose.getByRole("button", { name: "Select a function…" }));
    await user.click(screen.getByRole("option", { name: "transfer(address,uint256)" }));
    await user.click(compose.getByLabelText(/^to/));
    await user.paste(to);
    // The token says its decimals and the list its name: the amount is
    // typed in USDC, and the field says what that is in base units.
    const amount = await compose.findByLabelText(/^value \(USDC\)/);
    await user.click(amount);
    await user.paste("1");
    expect(compose.getByText("= 1000000 base units")).toBeTruthy();
    await user.click(compose.getByRole("button", { name: "Add to batch" }));
    await compose.findByText(written);
  }

  beforeEach(() => {
    registerContract(USDC, {
      name: "FiatToken",
      abi: ["function transfer(address to, uint256 value) returns (bool)"],
    });
    chain.decimals = { [USDC]: 6 };
    chain.tokens = [{ symbol: "USDC", chainId: 1, address: USDC }];
    wallet.address = ME;
    wallet.chain = { id: 1, name: "Ethereum" };
  });

  it("loads an action back into the form, and saving replaces it where it is", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addTransfer(user);
    await addTransfer(user, "0x00000000000000000000000000000000000000c0");
    const compose = step(1).in;
    const SECOND = 'exec $usdc "transfer(address,uint256)" $to2 @token:amount($usdc 1)';
    await compose.findByText(SECOND);

    await user.click(compose.getByRole("button", { name: `Edit action: ${TRANSFER}` }));
    // The contract, the function and the arguments are back, the amount
    // in the token's units.
    const amount = (await compose.findByLabelText(/^value \(USDC\)/)) as HTMLInputElement;
    expect(amount.value).toBe("1");
    expect((compose.getByLabelText(/^to/) as HTMLInputElement).value).toBe(DEAD);
    expect((compose.getByPlaceholderText("0x… or mydao.eth") as HTMLInputElement).value).toBe(USDC);
    expect(compose.queryByRole("button", { name: "Add to batch" })).toBeNull();

    // Cancel leaves the batch as it was, and the form empty.
    await user.click(compose.getByRole("button", { name: "Cancel" }));
    expect(compose.getByText(TRANSFER)).toBeTruthy();
    expect((compose.getByPlaceholderText("0x… or mydao.eth") as HTMLInputElement).value).toBe("");
    expect(compose.getByRole("button", { name: "Add to batch" })).toBeTruthy();
    expect(compose.getByText(SECOND)).toBeTruthy();

    // Edit again, change the amount, save: same position, new line.
    await user.click(compose.getByRole("button", { name: `Edit action: ${TRANSFER}` }));
    const again = await compose.findByLabelText(/^value \(USDC\)/);
    await user.clear(again);
    await user.click(again);
    await user.paste("2.5");
    await user.click(compose.getByRole("button", { name: "Save action" }));
    const saved = 'exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 2.5)';
    await compose.findByText(saved);
    const rows = Array.from(compose.getByText(saved).closest("div")!.parentElement!.querySelectorAll("pre")).map(
      (pre) => pre.textContent,
    );
    expect(rows).toEqual([saved, SECOND]);
    expect(compose.getByRole("button", { name: "Add to batch" })).toBeTruthy();
  });

  it("names the connected wallet $executor where an action names it", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addTransfer(user, ME, 'exec $usdc "transfer(address,uint256)" $executor @token:amount($usdc 1)');
    expect(step(1).in.getByRole("button", { name: "Rename $executor" })).toBeTruthy();
  });

  it("refuses more decimals than the token has, and takes base units on request", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    const compose = step(1).in;
    await user.click(compose.getByPlaceholderText("0x… or mydao.eth"));
    await user.paste(USDC);
    await user.click(compose.getByRole("button", { name: "Select a function…" }));
    await user.click(screen.getByRole("option", { name: "transfer(address,uint256)" }));
    await user.click(compose.getByLabelText(/^to/));
    await user.paste(DEAD);
    const amount = await compose.findByLabelText(/^value \(USDC\)/);
    await user.click(amount);
    await user.paste("1.0000001");
    expect(compose.getByRole("alert").textContent).toBe("At most 6 decimals.");
    expect((compose.getByRole("button", { name: "Add to batch" }) as HTMLButtonElement).disabled).toBe(true);
    // A transfer takes no unlimited amount.
    expect(compose.queryByRole("button", { name: "max" })).toBeNull();

    await user.click(compose.getByRole("button", { name: "Type base units" }));
    const base = compose.getByLabelText(/^value \(base units\)/);
    expect((base as HTMLInputElement).value).toBe("");
    await user.click(base);
    await user.paste("5");
    expect(compose.getByText("= 0.000005 USDC")).toBeTruthy();
    await user.click(compose.getByRole("button", { name: "Add to batch" }));
    await compose.findByText('exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 0.000005)');
  });

  it("renames a variable from the Addresses block, everywhere", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addTransfer(user);
    const compose = step(1).in;
    await user.click(compose.getByRole("button", { name: "Rename $to" }));
    const field = compose.getByRole("textbox", { name: "New name for $to" });
    await user.clear(field);
    await user.type(field, "usdc{Enter}");
    expect(compose.getByRole("alert").textContent).toContain("$usdc is already used.");
    await user.clear(field);
    await user.type(field, "burn{Enter}");
    await compose.findByText('exec $usdc "transfer(address,uint256)" $burn @token:amount($usdc 1)');
    expect(compose.getByRole("button", { name: "Rename $burn" })).toBeTruthy();
  });

  it("names the token and the recipient once and writes the amount in the token's units", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addTransfer(user);
    const addresses = within(step(1).in.getByRole("group", { name: "Addresses" }));
    expect(addresses.getByText("$usdc")).toBeTruthy();
    expect(addresses.getByText("$to")).toBeTruthy();
    expect(
      addresses.getAllByRole("link").map((a) => a.getAttribute("title")),
    ).toEqual([USDC, DEAD]);

    await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
    await step(1).in.findByText(/Simulation passed/);
    expect(fake.simulate.mock.calls[0][0]).toBe(
      ["load token", `set $usdc ${USDC}`, `set $to ${DEAD}`, TRANSFER].join("\n"),
    );
  });

  it("gives a check suggested for that run the action's own variables", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addTransfer(user);
    answering([KEEPS]);
    await simulateActions(user);
    await simulateProtected(user);
    expect(fake.simulate.mock.calls[1][0]).toBe(
      [
        "load token",
        `set $usdc ${USDC}`,
        `set $to ${DEAD}`,
        TRANSFER,
        "assert @balance!($usdc $to) >= @token:amount($usdc 5)  # suggested",
      ].join("\n"),
    );
    // Confirmed at the block it came from; listed to remove.
    expect(fake.simulate.mock.calls[1][1]).toMatchObject({ blockNumber: 21_234_567 });
    expect(suggested()).toHaveLength(1);
    expect(box().getByRole("button", { name: removeName(KEEPS) })).toBeTruthy();
  });


  describe("editing the actions after checks were suggested", () => {
    const STALE =
      "The actions changed since these were suggested: simulate the batch in step 1 again to update them.";
    const KEPT = "assert @balance!($usdc $to) >= @token:amount($usdc 5)";

    /** A transfer and a pause, simulated in step 1: both suggestions in. */
    async function suggestedBoth(user: ReturnType<typeof userEvent.setup>) {
      render(<AssertionBuilder />);
      await addTransfer(user);
      await addAction(user);
      answering([KEEPS, PAUSED]);
      await simulateActions(user);
      expect(batch()).toEqual([KEPT, PAUSED.line]);
    }

    it("keeps the suggested checks, and the variables they use, until step 1 runs again", async () => {
      const user = userEvent.setup();
      await suggestedBoth(user);
      await user.click(step(1).in.getByRole("button", { name: `Remove command: ${TRANSFER}` }));
      expect(batch()).toEqual([KEPT, PAUSED.line]);
      expect(suggested()).toHaveLength(2);
      expect(box().getByText(STALE)).toBeTruthy();
      expect(more().disabled).toBe(true);
      await simulateProtected(user);
      expect(fake.simulate.mock.calls.at(-1)?.[0]).toBe(
        [
          "load token",
          `set $usdc ${USDC}`,
          `set $to ${DEAD}`,
          SET,
          ACTION,
          marked(KEPT),
          marked(PAUSED.line),
        ].join("\n"),
      );
    });

    it("follows the next run: a suggestion it drops goes, one it keeps stays, the stale mark ends", async () => {
      const user = userEvent.setup();
      await suggestedBoth(user);
      await user.click(step(1).in.getByRole("button", { name: `Remove command: ${TRANSFER}` }));
      answering([PAUSED]);
      await simulateActions(user);
      expect(box().queryByText(STALE)).toBeNull();
      // The transfer's check went with the variables only it used.
      expect(batch()).toEqual([PAUSED.line]);
      expect(suggested()).toHaveLength(1);
      await simulateProtected(user);
      expect(fake.simulate.mock.calls.at(-1)?.[0]).toBe(
        [SET, ACTION, marked(PAUSED.line)].join("\n"),
      );
    });

    it("leaves a check made yours, whatever the next run suggests", async () => {
      const user = userEvent.setup();
      await suggestedBoth(user);
      // The transfer's check, made yours from its chip.
      await user.click(box().getByRole("button", { name: unmarkName(KEEPS) }));
      await user.click(step(1).in.getByRole("button", { name: `Remove command: ${TRANSFER}` }));
      answering([]);
      await simulateActions(user);
      // The pause's suggestion went with the run; yours stayed.
      expect(batch()).toEqual([KEPT]);
    });

    it("does not add back a suggestion you removed, while the run still suggests it", async () => {
      const user = userEvent.setup();
      await suggestedBoth(user);
      await user.click(box().getByRole("button", { name: removeName(PAUSED) }));
      expect(batch()).toEqual([KEPT]);
      await addAction(user);
      answering([KEEPS, PAUSED]);
      await simulateActions(user);
      expect(batch()).toEqual([KEPT]);
      // Still listed, to add back by hand.
      expect(box().getByRole("button", { name: addName(PAUSED) })).toBeTruthy();
    });

    it("drops the suggested checks, not yours, when the executor changes", async () => {
      const user = userEvent.setup();
      await suggestedBoth(user);
      await user.click(box().getByRole("button", { name: unmarkName(PAUSED) }));
      await user.click(step(1).in.getByText("simulate as another account"));
      await user.type(step(1).in.getByLabelText("Account to simulate as"), NEW_OWNER);
      expect(batch()).toEqual([PAUSED.line]);
    });
  });

  it("keeps a shared recipient for the action that still uses it when the other goes", async () => {
    const user = userEvent.setup();
    render(<AssertionBuilder />);
    await addTransfer(user);
    await addAction(user);
    await user.click(step(1).in.getByRole("button", { name: `Remove command: ${TRANSFER}` }));
    await user.click(step(1).in.getByRole("button", { name: "Simulate batch" }));
    await step(1).in.findByText(/Simulation passed/);
    // The token, the recipient and the token module went with the transfer.
    expect(fake.simulate.mock.calls[0][0]).toBe(SCRIPT);
  });
});
