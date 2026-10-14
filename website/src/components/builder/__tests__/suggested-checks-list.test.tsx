// @vitest-environment jsdom
import type { SimulationResult } from "@evmcrispr/core";
import { fireEvent, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";

import type { ContextKind } from "../context";
import { simKeyFor } from "../SimulationPanel";
import type { SimulationState } from "../simulation";
import { SuggestedChecks } from "../SuggestedChecks";
import {
  ALLOWANCE_WARNING,
  BALANCE_WARNING,
  NATIVE_FLOOR_WARNING,
  type SuggestedCheck,
} from "../suggested-checks";
import { useScriptState } from "../useScriptState";
import { markSuggested as marked } from "../script-ops";

/** Opens a row's (i): where its check comes from, and its notices. */
/** The assistant's button, ready and logged in. */
const SUGGEST = { ready: true, running: false, loggedIn: true, onSuggest: () => {} };
/** "Add assertions manually", closed. */
const MANUAL = { open: false, controls: "manual", onToggle: () => {} };

const about = (row: HTMLElement) =>
  fireEvent.click(within(row).getByRole("button", { name: "About this check" }));

const SAFE = "0x5Afe000000000000000000000000000000005afe" as const;
const OTHER = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001" as const;
const TOKEN = "0x00000000000000000000000000000000000000aa";
const OWNED = "0x00000000000000000000000000000000000000bb";
const ACTION = `exec ${TOKEN} "transfer(address,uint256)" ${OTHER} 5`;
const ACTION_2 = `exec ${OWNED} "transferOwnership(address)" ${OTHER}`;
const BATCH = `${ACTION}\n${ACTION_2}`;

const OWNER: SuggestedCheck = {
  line: `assert @acl:owner!(${OWNED}) == ${OTHER}`,
  description: "0x0000…00bb is owned by 0xabcd…0001",
  kind: "state",
  module: "acl",
  event: "ownershipTransferred",
  eventName: "OwnershipTransferred",
  emitter: OWNED,
};
const SPENT: SuggestedCheck = {
  line: `assert @balance!(${TOKEN} ${SAFE}) >= 95`,
  description:
    "0x5Afe…5afe spends no more TKN (0x0000…00aa) than simulated",
  kind: "amount",
  module: "token",
  event: "erc20Transfer",
  eventName: "Transfer",
  emitterName: "TKN",
  emitter: TOKEN,
};
const RECEIVED: SuggestedCheck = {
  line: `assert @balance!(${TOKEN} ${OTHER}) >= 5`,
  description:
    "0xabcd…0001 holds at least the TKN (0x0000…00aa) it received; that account can make this check fail by moving it first",
  kind: "amount",
  module: "token",
  event: "erc20Transfer",
  eventName: "Transfer",
  emitterName: "TKN",
  emitter: TOKEN,
};
const ALL = [OWNER, SPENT, RECEIVED];
const ALLOWANCE: SuggestedCheck = {
  line: `assert @token:allowance!(${TOKEN} ${SAFE} ${OTHER}) == 5`,
  description:
    "0xabcd…0001 is left with an allowance of 5 TKN (0x0000…00aa)",
  kind: "amount",
  module: "token",
  event: "erc20Approval",
  eventName: "Approval",
  emitterName: "TKN",
  emitter: TOKEN,
};
const NATIVE: SuggestedCheck = {
  line: `assert @balance!(ETH ${SAFE}) >= 990000000000000000`,
  description:
    "ETH balance of 0x5Afe…5afe stays at or above the simulated amount, less up to 0.01 ETH assumed for gas",
  kind: "amount",
  module: "std",
  event: "native",
  emitter: SAFE,
};
const PROXY = "0x00000000000000000000000000000000000000cc";
const UPGRADED: SuggestedCheck = {
  line: `assert @proxies:implementation!(${PROXY}) == ${OWNED}`,
  description:
    "0x0000…00cc reports the implementation 0x0000…00bb",
  kind: "state",
  module: "proxies",
  event: "upgraded",
  eventName: "Upgraded",
  emitter: PROXY,
};
const ENS_OWNER: SuggestedCheck = {
  line: `assert ${OWNED}::!{owner(bytes32)(address) 0x${"ab".repeat(32)}} == ${OTHER}`,
  description:
    "The node transferred on 0x0000…00bb is owned by 0xabcd…0001",
  kind: "state",
  module: "ens",
  event: "transfer",
  eventName: "Transfer",
  emitter: OWNED,
};

/** The paragraph that reads exactly `text`, whatever elements it is split
 *  into (a shortened address is its own no-break element). */
/** A row's sentence, by its text: the "suggested" chip a managed check
 *  ends with aside. */
const saying =
  (text: string) =>
  (_content: string, element: Element | null): boolean =>
    element?.tagName === "P" &&
    (element.textContent === text || element.textContent === `${text}suggested`);

const INTRO =
  "Drawn from what the simulation of step 1 did: read each one before adding it.";
const TRUNCATED =
  "The simulation did more than was looked at: this list may be incomplete.";
const STALE =
  "The actions changed since these were suggested: simulate the batch in step 1 again to update them.";
const NONE = "This simulation suggested no checks.";
const BEFORE = "Simulate the batch in step 1 to see the checks it suggests.";

/** A step 1 simulation of BATCH as SAFE on mainnet that answered with
 *  `result`. */
/** A result as a test writes it: its suggestions may be of the older
 *  shape, which the builder still takes. */
type ResultLike = Omit<Partial<SimulationResult>, "suggestions"> & {
  suggestions?: SuggestedCheck[];
};
const ran = (result: ResultLike): SimulationState => {
  const full = { success: true, logs: [], actions: [], ...result } as SimulationResult;
  return {
    status: full.success ? "success" : "failure",
    result: full,
    simulated: simKeyFor("actions-only", BATCH, SAFE, 1),
  };
};

/** The list over a live script: what "Add" does lands in it. */
function Harness({
  state,
  context = "safe",
  from = SAFE,
  chainId = 1,
  explorerChainId,
}: {
  /** The chain the rows link to, when it is not the simulated one. */
  explorerChainId?: number;
  state: SimulationState;
  context?: ContextKind;
  from?: `0x${string}`;
  chainId?: number;
}) {
  const scriptState = useScriptState(BATCH);
  return (
    <>
      <SuggestedChecks
        suggest={SUGGEST}
        manual={MANUAL}
        state={state}
        simKey={simKeyFor("protected", scriptState.script, from, chainId)}
        context={context}
        chainId={explorerChainId ?? chainId}
        scriptState={scriptState}
      />
      <pre data-testid="script">{scriptState.script}</pre>
      <button
        type="button"
        onClick={() => scriptState.setScript(`${scriptState.script}\n${ACTION}`)}
      >
        another action
      </button>
    </>
  );
}

const script = () => screen.getByTestId("script").textContent?.split("\n");
const rows = () => screen.queryAllByRole("listitem");
const addButton = (check: SuggestedCheck) =>
  screen.getByRole("button", { name: `Add check: ${check.description}` });
const removeButton = (check: SuggestedCheck) =>
  screen.getByRole("button", { name: `Remove check: ${check.description}` });

/** Reveal a row's code: the line it adds is one click away. */
const showCode = async (row: HTMLElement) => {
  await userEvent.setup().click(within(row).getByRole("button", { name: "Show code" }));
};

// Suggestions of the shape that came before sentences: a description and
// a line of literal addresses. They still render and add as they did.
describe("SuggestedChecks", () => {
  it("lists each suggestion with its description, its line and a way to add it", async () => {
    render(<Harness state={ran({ suggestions: ALL })} />);
    expect(screen.getByRole("heading", { name: "Suggested checks" })).toBeTruthy();
    expect(screen.getByText(INTRO)).toBeTruthy();
    expect(rows()).toHaveLength(3);
    for (const [i, check] of ALL.entries()) {
      const row = within(rows()[i]);
      // The description as it came, with whose word it is.
      expect(row.getByText(saying(check.description))).toBeTruthy();
      expect(row.queryByText(check.line)).toBeNull();
      await showCode(rows()[i]);
      expect(row.getByText(check.line).tagName).toBe("CODE");
      expect(row.getByRole("button", { name: `Add check: ${check.description}` }))
        .toBeTruthy();
    }
    // Step 1's run adds them itself: there is no Add all.
    expect(screen.queryByRole("button", { name: "Add all" })).toBeNull();
    expect(screen.queryByText(TRUNCATED)).toBeNull();
    expect(screen.queryByText(STALE)).toBeNull();
  });

  it("says which contract's event a check comes from, linking the name to the explorer", () => {
    render(<Harness state={ran({ suggestions: [SPENT] })} />);
    about(rows()[0]);
    const source = within(rows()[0]).getByText(/^Suggested by/);
    expect(source.textContent).toBe("Suggested by TKN's Transfer event");
    const link = within(source).getByRole("link", { name: "TKN" });
    expect(link.getAttribute("href")).toBe(`https://etherscan.io/address/${TOKEN}`);
    // The name is the contract's own word: the address is one hover away.
    expect(link.getAttribute("title")).toBe(TOKEN);
    expect(link.getAttribute("target")).toBe("_blank");
    expect(link.getAttribute("rel")).toBe("noreferrer noopener");
    // And the description is shown as it came.
    expect(within(rows()[0]).getByText(saying(SPENT.description))).toBeTruthy();
  });

  it("links the shortened address of a contract without a name", () => {
    render(<Harness state={ran({ suggestions: [OWNER] })} />);
    about(rows()[0]);
    const source = within(rows()[0]).getByText(/^Suggested by/);
    expect(source.textContent).toBe(
      "Suggested by 0x0000…00bb's OwnershipTransferred event",
    );
    const link = within(source).getByRole("link", { name: "0x0000…00bb" });
    expect(link.getAttribute("href")).toBe(`https://etherscan.io/address/${OWNED}`);
    expect(link.getAttribute("title")).toBe(OWNED);
  });

  it("links to the explorer of the chain the batch targets", () => {
    const state = ran({ suggestions: [SPENT] });
    state.simulated = simKeyFor("actions-only", BATCH, SAFE, 100);
    render(<Harness state={state} chainId={100} />);
    about(rows()[0]);
    expect(screen.getByRole("link", { name: "TKN" }).getAttribute("href")).toBe(
      `https://gnosisscan.io/address/${TOKEN}`,
    );
  });

  it("shows the name as plain text, address on hover, where no explorer is known", () => {
    render(
      <Harness state={ran({ suggestions: [SPENT] })} explorerChainId={987_654_321_012} />,
    );
    const source = within(rows()[0]).getByText(/^Suggested by/);
    expect(source.textContent).toBe("Suggested by TKN's Transfer event");
    expect(within(rows()[0]).queryByRole("link")).toBeNull();
    expect(within(source).getByText("TKN").getAttribute("title")).toBe(TOKEN);
  });

  it("says the native floor comes from the balance changes, with no event to link", () => {
    render(<Harness state={ran({ suggestions: [NATIVE, SPENT] })} />);
    expect(within(rows()[0]).getByText(/Suggested by/).textContent).toBe(
      "Suggested by the simulation's balance changes",
    );
    expect(within(rows()[0]).queryByRole("link")).toBeNull();
    expect(within(rows()[1]).getByText(/^Suggested by/)).toBeTruthy();
  });

  it("renders a suggestion of the older shape without a source line", () => {
    const older = {
      line: OWNER.line,
      description: `${OWNER.description}, as reported by 0x0000…00bb`,
      kind: "state",
      module: "acl",
      event: "ownershipTransferred",
      emitter: OWNED,
    } as SuggestedCheck;
    render(<Harness state={ran({ suggestions: [older] })} />);
    expect(rows()).toHaveLength(1);
    expect(screen.getByText(saying(older.description))).toBeTruthy();
    expect(screen.queryByText(/Suggested by/)).toBeNull();
  });

  it("adds one after the last action, with the load it needs, and keeps it listed to remove", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran({ suggestions: ALL })} />);
    await user.click(addButton(OWNER));
    expect(script()).toEqual(["load acl", ACTION, ACTION_2, marked(OWNER.line)]);
    // Still listed, now to take back.
    expect(rows()).toHaveLength(3);
    expect(screen.getByText(saying(OWNER.description))).toBeTruthy();
    expect(removeButton(OWNER)).toBeTruthy();
    expect(addButton(SPENT)).toBeTruthy();

    await user.click(addButton(RECEIVED));
    expect(script()).toEqual([
      "load acl",
      ACTION,
      ACTION_2,
      marked(OWNER.line),
      marked(RECEIVED.line),
    ]);
    expect(rows()).toHaveLength(3);
  });

  it("removes one again, with the load only it needed, and offers it again", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran({ suggestions: ALL })} />);
    await user.click(addButton(OWNER));
    await user.click(addButton(SPENT));
    await user.click(removeButton(OWNER));
    expect(script()).toEqual([ACTION, ACTION_2, marked(SPENT.line)]);
    expect(addButton(OWNER)).toBeTruthy();
    expect(removeButton(SPENT)).toBeTruthy();
  });



  it("offers to remove a suggestion the script already has", () => {
    const state = ran({ suggestions: ALL });
    function Preloaded() {
      const scriptState = useScriptState(`${BATCH}\n${SPENT.line}`);
      return (
        <SuggestedChecks
          suggest={SUGGEST}
        manual={MANUAL}
          state={state}
          simKey={simKeyFor("protected", scriptState.script, SAFE, 1)}
          context="safe"
          chainId={1}
          scriptState={scriptState}
        />
      );
    }
    render(<Preloaded />);
    expect(rows()).toHaveLength(3);
    expect(removeButton(SPENT)).toBeTruthy();
    expect(addButton(OWNER)).toBeTruthy();
  });


  it.each(["safe", "governor", "aragonosx"] as const)(
    "warns on amounts, not on state, in a %s context",
    (context) => {
      render(<Harness state={ran({ suggestions: ALL })} context={context} />);
      expect(within(rows()[0]).queryByText(/may change/)).toBeNull();
      expect(within(rows()[1]).getByText(BALANCE_WARNING)).toBeTruthy();
      expect(within(rows()[2]).getByText(BALANCE_WARNING)).toBeTruthy();
    },
  );

  it("names the allowance on an approval and what the native floor depends on", () => {
    render(<Harness state={ran({ suggestions: [ALLOWANCE, NATIVE] })} />);
    expect(within(rows()[0]).getByText(ALLOWANCE_WARNING)).toBeTruthy();
    expect(within(rows()[0]).queryByText(BALANCE_WARNING)).toBeNull();
    // One warning on the row, the more specific one.
    expect(within(rows()[1]).getByText(NATIVE_FLOOR_WARNING)).toBeTruthy();
    expect(within(rows()[1]).queryByText(BALANCE_WARNING)).toBeNull();
    // The assumed fee is part of the description, shown as it came.
    expect(
      within(rows()[1]).getByText(/less up to 0\.01 ETH assumed for gas/),
    ).toBeTruthy();
  });

  it("lists an upgrade and an ENS suggestion, and loads proxies with the upgrade", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran({ suggestions: [UPGRADED, ENS_OWNER] })} />);
    expect(rows()).toHaveLength(2);
    expect(screen.getByText(saying(UPGRADED.description))).toBeTruthy();
    expect(screen.getByText(saying(ENS_OWNER.description))).toBeTruthy();
    expect(screen.queryByText(/may change/)).toBeNull();
    await user.click(addButton(UPGRADED));
    expect(script()).toEqual(["load proxies", ACTION, ACTION_2, marked(UPGRADED.line)]);
    await user.click(addButton(ENS_OWNER));
    expect(script()).toEqual([
      "load proxies",
      ACTION,
      ACTION_2,
      marked(UPGRADED.line),
      marked(ENS_OWNER.line),
    ]);
  });

  it("does not warn in a wallet context, except on the native floor", () => {
    render(<Harness state={ran({ suggestions: [...ALL, NATIVE] })} context="eoa" />);
    expect(rows()).toHaveLength(4);
    expect(screen.queryByText(/may change/)).toBeNull();
    expect(within(rows()[3]).getByText(NATIVE_FLOOR_WARNING)).toBeTruthy();
    expect(screen.getAllByText(NATIVE_FLOOR_WARNING)).toHaveLength(1);
  });

  it("shows shortened addresses in one style, in the text and in the button's name", async () => {
    const dotted: SuggestedCheck = {
      ...SPENT,
      description: "0x5Afe...5afe spends no more TKN (0x0000...00aa) than simulated",
    };
    render(<Harness state={ran({ suggestions: [dotted] })} />);
    const shown = "0x5Afe…5afe spends no more TKN (0x0000…00aa) than simulated";
    expect(within(rows()[0]).getByText(saying(shown))).toBeTruthy();
    expect(screen.getByRole("button", { name: `Add check: ${shown}` })).toBeTruthy();
    expect(screen.queryByText(/\.\.\./)).toBeNull();
    // The line itself is the script's: untouched.
    await showCode(rows()[0]);
    expect(within(rows()[0]).getByText(SPENT.line)).toBeTruthy();
  });

  it("keeps each shortened address, and the name in the source line, in one piece", () => {
    render(<Harness state={ran({ suggestions: [SPENT, OWNER] })} />);
    const text = within(rows()[0]).getByText(saying(SPENT.description));
    const pieces = [...text.querySelectorAll("span")];
    expect(pieces.map((p) => p.textContent)).toEqual(["0x5Afe…5afe", "0x0000…00aa"]);
    for (const piece of pieces) expect(piece.className).toContain("whitespace-nowrap");
    // The words between them still wrap.
    expect(text.className).not.toContain("whitespace-nowrap");
    about(rows()[0]);
    expect(screen.getByRole("link", { name: "TKN" }).className).toContain(
      "whitespace-nowrap",
    );
    about(rows()[1]);
    expect(screen.getByRole("link", { name: "0x0000…00bb" }).className).toContain(
      "whitespace-nowrap",
    );
  });

  it("wraps the line at spaces, like the batch listing", async () => {
    render(<Harness state={ran({ suggestions: [SPENT] })} />);
    await showCode(rows()[0]);
    const pre = within(rows()[0]).getByText(SPENT.line).closest("pre") as HTMLElement;
    expect(pre.className).toContain("whitespace-pre-wrap");
    expect(pre.className).not.toContain("break-all");
  });

  it("says when the list may be incomplete", () => {
    render(
      <Harness state={ran({ suggestions: [OWNER], suggestionsTruncated: true })} />,
    );
    expect(screen.getByText(TRUNCATED)).toBeTruthy();
  });

  it("says so when a passing run suggested nothing", () => {
    render(<Harness state={ran({ suggestions: [] })} />);
    expect(screen.getByRole("heading", { name: "Suggested checks" })).toBeTruthy();
    expect(screen.getByText(NONE)).toBeTruthy();
    expect(rows()).toHaveLength(0);
  });

  it("reads a result without suggestions (older shape) as one that suggested none", () => {
    render(<Harness state={ran({})} />);
    expect(screen.getByText(NONE)).toBeTruthy();
  });

  it("asks for step 1's simulation after a failed run or before any run", () => {
    const failed = render(
      <Harness state={ran({ success: false, error: "boom", suggestions: ALL })} />,
    );
    expect(rows()).toHaveLength(0);
    expect(screen.getByText(BEFORE)).toBeTruthy();
    failed.unmount();
    render(<Harness state={{ status: "idle", result: null, simulated: null }} />);
    expect(rows()).toHaveLength(0);
    expect(screen.getByText(BEFORE)).toBeTruthy();
  });

  it("keeps its rows, added or not, when the actions change, and says they are from before", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran({ suggestions: ALL })} />);
    await user.click(addButton(OWNER));
    expect(screen.queryByText(STALE)).toBeNull();
    await user.click(screen.getByRole("button", { name: "another action" }));
    expect(rows()).toHaveLength(3);
    expect(screen.getByText(STALE)).toBeTruthy();
    // The added one is still in the batch and can still be taken back.
    expect(script()).toContain(marked(OWNER.line));
    expect(removeButton(OWNER)).toBeTruthy();
    await user.click(addButton(SPENT));
    expect(script()).toContain(marked(SPENT.line));
  });

  it.each([
    ["the executor", { from: OTHER }],
    ["the chain", { chainId: 100 }],
  ])("lists none for another %s: they were suggested for this one", (_name, change) => {
    const state = ran({ suggestions: ALL });
    const view = render(<Harness state={state} />);
    expect(rows()).toHaveLength(3);
    view.rerender(<Harness state={state} {...change} />);
    expect(rows()).toHaveLength(0);
    view.rerender(<Harness state={state} />);
    expect(rows()).toHaveLength(3);
  });

  it("keeps where a check comes from and its notices behind its (i), one row at a time", () => {
    render(<Harness state={ran({ suggestions: [SPENT, OWNER] })} context="safe" />);
    const [first, second] = rows();
    const button = within(first).getByRole("button", { name: "About this check" });
    expect(button.getAttribute("aria-expanded")).toBe("false");
    // Closed: in the page for assistive technology to be pointed at, not shown.
    const note = document.getElementById(button.getAttribute("aria-controls")!)!;
    expect(note.hidden).toBe(true);
    about(first);
    expect(button.getAttribute("aria-expanded")).toBe("true");
    expect(note.hidden).toBe(false);
    // Another row's (i) closes this one.
    about(second);
    expect(note.hidden).toBe(true);
    // Escape, and a click outside, close it.
    fireEvent.keyDown(document, { key: "Escape" });
    expect(
      document.querySelectorAll("[data-about-check]:not([hidden])"),
    ).toHaveLength(0);
    about(first);
    fireEvent.mouseDown(document.body);
    expect(note.hidden).toBe(true);
  });
});
