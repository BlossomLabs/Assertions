import type { SimulationResult } from "@evmcrispr/core";
import { BASE_UNITS_COMMENT } from "@evmcrispr/sdk";
import { describe, expect, it } from "vitest";

import { type Naming, insertAssertionLines, nameContext, userRename } from "../script-ops";
import type { SimKey, SimulationState } from "../simulation";
import {
  type SuggestedCheck,
  confirmationBlock,
  lineMeaning,
  prepareSuggestion,
  suggestedChecks,
  suggestionVariables,
} from "../suggested-checks";

const SAFE = "0x5Afe000000000000000000000000000000005afe";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DEAD = "0x000000000000000000000000000000000000dEaD";

const BATCH = [
  "load token",
  `set $weth ${WETH}`,
  `set $to ${DEAD}`,
  'exec $weth "transfer(address,uint256)" $to @token:amount($weth 1)',
  `exec $weth "approve(address,uint256)" $to 5${BASE_UNITS_COMMENT}$weth`,
].join("\n");
const MANAGED: Naming["managed"] = new Map([["to", "role"]]);

const check = (partial: Partial<SuggestedCheck> & Pick<SuggestedCheck, "line" | "vars">): SuggestedCheck => ({
  description: "d",
  kind: "amount",
  module: "token",
  event: "erc20Approval",
  eventName: "Approval",
  emitter: WETH,
  sentence: [
    {
      type: "amount",
      value: "5",
      bound: "exact",
      token: WETH,
      symbol: "WETH",
      decimals: 18,
      listed: true,
      text: "5 base units of WETH",
    },
  ],
  ...partial,
});
const ALLOWED = check({
  line: `assert @token:allowance!($weth $executor $spender) == 5${BASE_UNITS_COMMENT}$weth`,
  vars: [
    { name: "weth", value: WETH },
    { name: "executor", value: SAFE },
    { name: "spender", value: DEAD },
  ],
});
const HELD = check({
  event: "erc20Transfer",
  line: "assert @balance!($weth $recipient) >= @token:amount($weth 0.99)",
  vars: [
    { name: "weth", value: WETH },
    { name: "recipient", value: DEAD },
  ],
});
const NATIVE = check({
  module: "std",
  event: "native",
  eventName: undefined,
  line: `assert @balance!(ETH $executor) >= 849${BASE_UNITS_COMMENT}ETH`,
  vars: [{ name: "executor", value: SAFE }],
});

const key = (script: string): SimKey => ({ script, from: SAFE, chainId: 1, mode: "protected" });
const ran = (script: string, suggestions: SuggestedCheck[]): SimulationState => ({
  status: "success",
  result: { success: true, logs: [], actions: [], suggestions } as unknown as SimulationResult,
  simulated: key(script),
  block: 21_234_567,
  blockReadAt: 1_000,
});
const naming: Naming = { managed: MANAGED, context: [{ name: "safe", address: SAFE }], kinds: new Map([[DEAD.toLowerCase(), "account"]]) };
const added = (script: string, suggestion: SuggestedCheck, n: Naming = naming) => {
  const bound = prepareSuggestion(script, suggestion, n);
  return {
    script: insertAssertionLines(bound.script, bound.line, "post", bound.sets).script,
    managed: bound.managed,
  };
};
const offered = (state: SimulationState, script: string) =>
  suggestedChecks(state, key(script))?.checks.map((c) => c.event) ?? null;

describe("a line's meaning", () => {
  it("is the same with and without the comment that says its unit, and under any variable name", () => {
    const vars = new Map([
      ["weth", WETH],
      ["w", WETH],
    ]);
    const plain = lineMeaning("assert $weth::!{totalSupply()(uint256)} == 5", vars);
    expect(lineMeaning(`assert $weth::!{totalSupply()(uint256)} == 5${BASE_UNITS_COMMENT}$weth`, vars)).toBe(plain);
    expect(lineMeaning("assert $w::!{totalSupply()(uint256)} == 5  # anything", vars)).toBe(plain);
    expect(plain).toContain(WETH.toLowerCase());
    // A # in a string is text, and the line is another line.
    expect(lineMeaning('exec $weth "note(string)" "a # b"', vars)).not.toBe(lineMeaning('exec $weth "note(string)" "a"', vars));
  });
});

describe("suggestions through renames and comments", () => {
  const state = ran(BATCH, [ALLOWED, HELD, NATIVE]);

  it("tells the token list's names from roles by what the sentence vouches for", () => {
    expect(suggestionVariables(ALLOWED)).toEqual([
      { name: "weth", value: WETH, origin: "list" },
      { name: "executor", value: SAFE },
      { name: "spender", value: DEAD },
    ]);
  });

  it("adding one that renames a variable keeps the others, under the names the script has now", () => {
    const one = added(BATCH, ALLOWED);
    // The recipient is a spender now: an account, and the Safe is the Safe.
    expect(one.script.split("\n")).toEqual([
      "load token",
      `set $weth ${WETH}`,
      `set $account ${DEAD}`,
      `set $safe ${SAFE}`,
      'exec $weth "transfer(address,uint256)" $account @token:amount($weth 1)',
      `exec $weth "approve(address,uint256)" $account 5${BASE_UNITS_COMMENT}$weth`,
      `assert @token:allowance!($weth $safe $account) == 5${BASE_UNITS_COMMENT}$weth`,
    ]);
    expect(offered(state, one.script)).toEqual(["erc20Transfer", "native"]);
    expect(suggestedChecks(state, key(one.script))?.added).toBe(true);
    // And is confirmed at the block it was drawn from.
    expect(confirmationBlock(state, key(one.script), 2_000)).toBe(21_234_567);

    const two = added(one.script, HELD, { ...naming, managed: one.managed });
    expect(two.script.split("\n").at(-1)).toBe("assert @balance!($weth $account) >= @token:amount($weth 0.99)");
    expect(offered(state, two.script)).toEqual(["native"]);
  });

  it("a rename alone adds nothing: the list stays, with nothing to confirm", () => {
    const renamed = userRename(BATCH, "to", "burn");
    if ("error" in renamed) throw new Error(renamed.error);
    expect(offered(state, renamed.script)).toEqual(["erc20Approval", "erc20Transfer", "native"]);
    expect(suggestedChecks(state, key(renamed.script))?.added).toBe(false);
    expect(confirmationBlock(state, key(renamed.script), 2_000)).toBeUndefined();
    // The same for the context giving the account its name.
    const withSafe = `set $executor ${SAFE}\n${BATCH}\nassert $executor::!{nonce()(uint256)} == 1`;
    const simulated = ran(withSafe, [ALLOWED]);
    const named = nameContext(withSafe, { ...naming, managed: new Map([["executor", "context"]]) }).script;
    expect(named).toContain("$safe::!{nonce()(uint256)}");
    expect(offered(simulated, named)).toEqual(["erc20Approval"]);
    expect(suggestedChecks(simulated, key(named))?.added).toBe(false);
  });

  it("does not offer a check the script already has, whatever its comment or its names", () => {
    const literal = `${BATCH}\nassert @token:allowance!(${WETH} ${SAFE} ${DEAD}) == 5`;
    expect(offered(ran(literal, [ALLOWED, HELD]), literal)).toEqual(["erc20Transfer"]);
    const commented = `${BATCH}\nset $me ${SAFE}\nassert @token:allowance!($weth $me $to) == 5  # five wei`;
    expect(offered(ran(commented, [ALLOWED, HELD]), commented)).toEqual(["erc20Transfer"]);
  });

  it("offers one native floor: a floor in place is the same check with another number, comment or not", () => {
    const withFloor = `set $safe ${SAFE}\n${BATCH}\nassert @balance!(ETH $safe) >= 700${BASE_UNITS_COMMENT}ETH`;
    expect(offered(ran(withFloor, [NATIVE, HELD]), withFloor)).toEqual(["erc20Transfer"]);
    const bare = `set $safe ${SAFE}\n${BATCH}\nassert @balance!(ETH $safe) >= 700`;
    expect(offered(ran(bare, [NATIVE, HELD]), bare)).toEqual(["erc20Transfer"]);
  });

  it("any other edit still ends the list", () => {
    expect(offered(state, `${BATCH}\nexec $weth "deposit()"`)).toBeNull();
    expect(offered(state, BATCH.replace("5  #", "6  #"))).toBeNull();
    // A variable pointed at another address changes what the lines mean.
    expect(offered(state, BATCH.replace(DEAD, SAFE))).toBeNull();
  });
});
