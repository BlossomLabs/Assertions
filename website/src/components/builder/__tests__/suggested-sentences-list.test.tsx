// @vitest-environment jsdom
import { useState } from "react";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";

import { BatchList } from "../BatchList";
import type { ContextKind } from "../context";
import { isAssertSpan } from "../script-ops";
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
import {
  ACTION,
  ACTION_2,
  ALLOWANCE,
  BATCH,
  EXECUTOR,
  NATIVE,
  OTHER,
  OWNED,
  OWNER,
  RECEIVED,
  SPENT,
  USDC,
  WETH,
} from "./helpers/suggestions";

/** The assistant's button, ready and logged in. */
const SUGGEST = { ready: true, running: false, loggedIn: true, onSuggest: () => {} };
/** "Add assertions manually", closed. */
const MANUAL = { open: false, controls: "manual", onToggle: () => {} };

const short = (a: string) => `${a.slice(0, 6)}…${a.slice(-4)}`;
const ran = (suggestions: SuggestedCheck[], script = BATCH): SimulationState => ({
  status: "success",
  result: { success: true, logs: [], actions: [], suggestions: suggestions as never },
  simulated: simKeyFor("actions-only", script, EXECUTOR, 1),
});

/** The list over a live script, with the batch listing above it. */
function Harness({
  state,
  context = "eoa",
  chainId = 1,
  initial = BATCH,
}: {
  state: SimulationState;
  context?: ContextKind;
  chainId?: number;
  initial?: string;
}) {
  const scriptState = useScriptState(initial);
  // The batch runs as the connected wallet: `$executor` is that account.
  useState(() => void scriptState.setContext([{ name: "executor", address: EXECUTOR }]));
  return (
    <>
      <div data-testid="listing">
        <BatchList
          script={scriptState.script}
          chainId={chainId}
          onRemove={scriptState.removeCommand}
          canRemove={isAssertSpan}
        />
      </div>
      <SuggestedChecks
        suggest={SUGGEST}
        manual={MANUAL}
        state={state}
        simKey={simKeyFor("protected", scriptState.script, EXECUTOR, 1)}
        context={context}
        chainId={chainId}
        scriptState={scriptState}
      />
      <pre data-testid="script">{scriptState.script}</pre>
    </>
  );
}

const script = () => screen.getByTestId("script").textContent?.split("\n");
const rows = () => within(screen.getByRole("list")).queryAllByRole("listitem");
const sentence = (row: HTMLElement) => row.querySelector("p") as HTMLElement;
const add = (check: SuggestedCheck) =>
  screen.getByRole("button", {
    name: `Add check: ${check.description.replace(/\.\.\./g, "…")}`,
  });

describe("a suggestion row", () => {
  it("reads as a sentence, each address a link to the explorer", () => {
    render(<Harness state={ran([OWNER])} />);
    const text = sentence(rows()[0]);
    expect(text.textContent).toBe(`${short(OWNED)} is owned by ${short(OTHER)}`);
    const links = within(text).getAllByRole("link");
    expect(links.map((a) => a.textContent)).toEqual([short(OWNED), short(OTHER)]);
    expect(links.map((a) => a.getAttribute("href"))).toEqual([
      `https://etherscan.io/address/${OWNED}`,
      `https://etherscan.io/address/${OTHER}`,
    ]);
    for (const [i, a] of links.entries()) {
      expect(a.getAttribute("title")).toBe([OWNED, OTHER][i]);
      expect(a.getAttribute("target")).toBe("_blank");
      expect(a.getAttribute("rel")).toBe("noreferrer noopener");
      expect(a.className).toContain("whitespace-nowrap");
    }
  });

  it("writes an amount as it is said, the listed symbol alone and linked to the token", () => {
    render(<Harness state={ran([SPENT])} />);
    const text = sentence(rows()[0]);
    expect(text.textContent).toBe(`${short(EXECUTOR)} keeps at least 51,950.2982 USDC`);
    const symbol = within(text).getByRole("link", { name: "USDC" });
    expect(symbol.getAttribute("href")).toBe(`https://etherscan.io/address/${USDC}`);
    expect(symbol.getAttribute("title")).toBe(USDC);
  });

  it("shows the address beside a symbol only the token vouches for", () => {
    render(<Harness state={ran([ALLOWANCE])} />);
    const text = sentence(rows()[0]);
    expect(text.textContent).toBe(
      `${short(OTHER)} is left with an allowance of 5 WETH (${short(WETH)})`,
    );
    expect(
      within(text)
        .getByRole("link", { name: `WETH (${short(WETH)})` })
        .getAttribute("href"),
    ).toBe(`https://etherscan.io/address/${WETH}`);
  });

  it("does not link the chain's own currency", () => {
    render(<Harness state={ran([NATIVE])} />);
    const text = sentence(rows()[0]);
    expect(text.textContent).toBe(
      `ETH balance of ${short(EXECUTOR)} stays at or above 122.0843 ETH, which leaves up to 0.00002 ETH for gas`,
    );
    expect(within(text).getAllByRole("link")).toHaveLength(1);
  });

  it("shows names as plain text, the address on hover, where no explorer is known", () => {
    render(<Harness state={ran([SPENT])} chainId={987_654_321_012} />);
    const text = sentence(rows()[0]);
    expect(text.textContent).toBe(`${short(EXECUTOR)} keeps at least 51,950.2982 USDC`);
    expect(within(rows()[0]).queryByRole("link")).toBeNull();
    expect(within(text).getByText("USDC").getAttribute("title")).toBe(USDC);
  });

  it("keeps the source line and the warnings", () => {
    render(<Harness state={ran([ALLOWANCE, SPENT, NATIVE])} context="safe" />);
    expect(within(rows()[0]).getByText(/^Suggested by/).textContent).toBe(
      "Suggested by WETH's Approval event",
    );
    expect(within(rows()[0]).getByText(ALLOWANCE_WARNING)).toBeTruthy();
    expect(within(rows()[1]).getByText(BALANCE_WARNING)).toBeTruthy();
    expect(within(rows()[2]).getByText(NATIVE_FLOOR_WARNING)).toBeTruthy();
    // No event: it says where it comes from all the same.
    expect(within(rows()[2]).getByText(/^Suggested by/).textContent).toBe(
      "Suggested by the simulation's balance changes",
    );
  });

  it("keeps the code one click away: the sets it needs, then its line", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran([SPENT, OWNER])} />);
    const row = within(rows()[0]);
    // Closed to begin with: a sentence, no EVML.
    expect(row.queryByText(/assert/)).toBeNull();
    const toggle = row.getByRole("button", { name: "Show code" });
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
    await user.click(toggle);
    const code = rows()[0].querySelector("pre") as HTMLElement;
    expect(code.textContent?.split("\n")).toEqual([
      `set $usdc ${USDC}`,
      `set $executor ${EXECUTOR}`,
      SPENT.line,
    ]);
    expect(code.className).toContain("whitespace-pre-wrap");
    expect(code.className).not.toContain("break-all");
    expect(
      row.getByRole("button", { name: "Hide code" }).getAttribute("aria-expanded"),
    ).toBe("true");
    // The other row stays closed.
    expect(rows()[1].querySelector("pre")).toBeNull();
    await user.click(row.getByRole("button", { name: "Hide code" }));
    expect(rows()[0].querySelector("pre")).toBeNull();
  });

  it("shows the code as it would be added to this script", async () => {
    const user = userEvent.setup();
    const initial = `set $stable ${USDC}\nset $executor ${OTHER}\n${BATCH}`;
    render(<Harness state={ran([SPENT], initial)} initial={initial} />);
    await user.click(within(rows()[0]).getByRole("button", { name: "Show code" }));
    expect(rows()[0].querySelector("pre")?.textContent?.split("\n")).toEqual([
      `set $executor2 ${EXECUTOR}`,
      "assert @balance!($stable $executor2) >= @token:amount($stable 51950.2982)",
    ]);
  });
});

describe("adding a suggestion", () => {
  it("adds its variables, its load and its line, and keeps the other rows", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran([SPENT, RECEIVED, OWNER])} />);
    await user.click(add(SPENT));
    expect(script()).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $executor ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      marked(SPENT.line),
    ]);
    // Still listed, now to take back.
    expect(rows()).toHaveLength(3);
    expect(screen.getByRole("button", { name: /^Remove check: .*keeps at least/ })).toBeTruthy();
  });

  it("loads token for a native floor added on its own, once", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran([NATIVE])} />);
    await user.click(within(rows()[0]).getByRole("button", { name: "Show code" }));
    expect(rows()[0].querySelector("pre")?.textContent?.split("\n")).toEqual([
      `set $executor ${EXECUTOR}`,
      NATIVE.line,
    ]);
    await user.click(add(NATIVE));
    expect(script()).toEqual([
      "load token",
      `set $executor ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      marked(NATIVE.line),
    ]);
  });

  it("does not load token a second time for a native floor", async () => {
    const user = userEvent.setup();
    const initial = `load token\n${BATCH}`;
    render(<Harness state={ran([NATIVE], initial)} initial={initial} />);
    await user.click(add(NATIVE));
    expect(script()).toEqual([
      "load token",
      `set $executor ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      marked(NATIVE.line),
    ]);
  });

  it("adds each, each variable and each load once", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran([SPENT, RECEIVED, NATIVE])} />);
    for (const check of [SPENT, RECEIVED, NATIVE]) await user.click(add(check));
    expect(script()).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $executor ${EXECUTOR}`,
      `set $recipient ${OTHER}`,
      ACTION,
      ACTION_2,
      marked(SPENT.line),
      marked(RECEIVED.line),
      marked(NATIVE.line),
    ]);
    expect(screen.getAllByRole("button", { name: /^Remove check:/ })).toHaveLength(3);
  });

  it("renames a variable the script uses for something else, in the line it adds", async () => {
    const user = userEvent.setup();
    const initial = `set $executor ${OTHER}\n${BATCH}`;
    render(<Harness state={ran([NATIVE, SPENT], initial)} initial={initial} />);
    await user.click(add(NATIVE));
    expect(script()).toEqual([
      "load token",
      `set $executor ${OTHER}`,
      `set $executor2 ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      marked("assert @balance!(ETH $executor2) >= @token:amount(ETH 122.0843)"),
    ]);
    // The next one finds that variable and uses it.
    await user.click(add(SPENT));
    expect(script()?.at(-1)).toBe(
      marked("assert @balance!($usdc $executor2) >= @token:amount($usdc 51950.2982)"),
    );
    expect(script()?.filter((l) => l.startsWith("set $executor"))).toHaveLength(2);
    expect(screen.getAllByRole("button", { name: /^Remove check:/ })).toHaveLength(2);
  });

  it("uses the variable the script already has for an address", async () => {
    const user = userEvent.setup();
    const initial = `set $stable ${USDC}\n${BATCH}`;
    render(<Harness state={ran([SPENT], initial)} initial={initial} />);
    await user.click(add(SPENT));
    expect(script()).toEqual([
      "load token",
      `set $stable ${USDC}`,
      `set $executor ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      marked("assert @balance!($stable $executor) >= @token:amount($stable 51950.2982)"),
    ]);
  });

  it("takes a variable away again with the last check that used it", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran([SPENT, RECEIVED])} />);
    for (const check of [SPENT, RECEIVED]) await user.click(add(check));
    await user.click(
      screen.getByRole("button", { name: `Remove command: ${RECEIVED.line}` }),
    );
    expect(script()).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $executor ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      marked(SPENT.line),
    ]);
    // And the removed one is offered again.
    expect(rows()).toHaveLength(2);
    expect(screen.getAllByRole("button", { name: /^Add check:/ })).toHaveLength(1);
    await user.click(screen.getByRole("button", { name: `Remove command: ${SPENT.line}` }));
    expect(script()).toEqual([ACTION, ACTION_2]);
  });
});

describe("the batch listing with an added suggestion", () => {
  it("lists the addresses apart, each name with its linked address, and the commands below", async () => {
    const user = userEvent.setup();
    render(<Harness state={ran([SPENT])} />);
    const listing = within(screen.getByTestId("listing"));
    expect(listing.queryByRole("group", { name: "Addresses" })).toBeNull();
    await user.click(add(SPENT));
    const addresses = within(listing.getByRole("group", { name: "Addresses" }));
    expect(addresses.getByText("$usdc")).toBeTruthy();
    expect(addresses.getByText("$executor")).toBeTruthy();
    const links = addresses.getAllByRole("link");
    expect(links.map((a) => [a.textContent, a.getAttribute("href"), a.getAttribute("title")])).toEqual([
      [short(USDC), `https://etherscan.io/address/${USDC}`, USDC],
      [short(EXECUTOR), `https://etherscan.io/address/${EXECUTOR}`, EXECUTOR],
    ]);
    // The set lines are not listed a second time as commands; the load is hidden.
    expect(listing.queryByText(`set $usdc ${USDC}`)).toBeNull();
    expect(listing.queryByText("load token")).toBeNull();
    expect(listing.getByText(ACTION)).toBeTruthy();
    expect(listing.getByText(SPENT.line)).toBeTruthy();
  });

  it("leaves a variable that is not a plain address where it was", () => {
    render(
      <BatchList
        script={`set $name @ens(vitalik.eth)\n${ACTION}`}
        chainId={1}
        onRemove={() => {}}
      />,
    );
    expect(screen.queryByRole("group", { name: "Addresses" })).toBeNull();
    expect(screen.getByText("set $name @ens(vitalik.eth)")).toBeTruthy();
  });
});

describe("checks of the chain's own currency, long amounts, and a run that could not vouch", () => {
  const PAID: SuggestedCheck = {
    line: "assert @balance!(ETH $recipient) == @token:amount(ETH 2)",
    vars: [{ name: "recipient", value: OTHER }],
    sentence: [
      { type: "address", address: OTHER },
      { type: "text", text: " holds exactly " },
      { type: "amount", value: "2000000000000000000", bound: "exact", token: "native", symbol: "ETH", decimals: 18, text: "2 ETH" },
    ],
    description: "holds exactly 2 ETH",
    kind: "amount",
    module: "std",
    event: "nativeBalance",
    emitter: OTHER,
  };

  it("says an ETH check comes from the simulation's balance changes, as a token's says its event", () => {
    render(<Harness state={ran([NATIVE, PAID])} />);
    expect(
      screen.getAllByText("Suggested by the simulation's balance changes"),
    ).toHaveLength(2);
  });

  it("shortens an exact amount with many decimals, and keeps every digit on hover", () => {
    const LONG: SuggestedCheck = {
      ...PAID,
      line: "assert @balance!(ETH $recipient) == @token:amount(ETH 19898.033836102187577703)",
      sentence: [
        { type: "address", address: OTHER },
        { type: "text", text: " holds exactly " },
        { type: "amount", value: "19898033836102187577703", bound: "exact", token: "native", symbol: "ETH", decimals: 18, text: "19,898.033836102187577703 ETH" },
      ],
    };
    render(<Harness state={ran([LONG])} />);
    const shown = screen.getByTitle("19,898.033836102187577703 ETH");
    expect(shown.textContent).toBe("19,898.033836… ETH");
  });

  it("leaves a floor or a ceiling as it is said: it is already rounded", () => {
    render(<Harness state={ran([NATIVE])} />);
    expect(screen.queryByTitle(/ETH/)).toBeNull();
    expect(screen.getByText(/0\.00002 ETH/)).toBeTruthy();
  });

  it("says why there are no checks when the run could not vouch for them", () => {
    const state: SimulationState = {
      ...ran([]),
      result: {
        success: true,
        logs: [],
        actions: [],
        suggestions: [],
        suggestionsError: "the node did not trace",
      } as never,
    };
    render(<Harness state={state} />);
    expect(
      screen.getByText("No checks suggested: the node did not trace"),
    ).toBeTruthy();
  });
});
