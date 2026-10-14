import { describe, expect, it } from "vitest";

import {
  stripAssertions,
  addressVariables,
  gcScaffolding,
  insertAssertionLines,
  removeCommand,
} from "../script-ops";
import type { SimKey, SimulationState } from "../simulation";
import {
  type SuggestedCheck,
  confirmationBlock,
  lineMeaning,
  prepareSuggestion,
  sentenceView,
  suggestedChecks,
} from "../suggested-checks";
import {
  ACTION,
  ACTION_2,
  BATCH,
  EXECUTOR,
  FAKE,
  NATIVE,
  OTHER,
  OWNED,
  OWNER,
  RECEIVED,
  SPENT,
  USDC,
} from "./helpers/suggestions";

const ALL = [SPENT, RECEIVED, OWNER];

const key = (partial: Partial<SimKey> = {}): SimKey => ({
  script: BATCH,
  from: EXECUTOR,
  chainId: 1,
  mode: "protected",
  ...partial,
});
/** Step 1's run of the batch `simulated` stands for: its actions alone. */
const ran = (simulated: SimKey, suggestions: SuggestedCheck[]): SimulationState => ({
  status: "success",
  result: { success: true, logs: [], actions: [], suggestions: suggestions as never },
  simulated: { ...simulated, mode: "actions-only", script: stripAssertions(simulated.script) },
});
/** The batch runs as the connected wallet: the context that makes
 *  `$executor` that account's name, and nothing else's. */
const AS_EXECUTOR = { context: [{ name: "executor" as const, address: EXECUTOR }] };
/** The script after the suggestion is added the way the builder adds it. */
const add = (script: string, check: SuggestedCheck): string => {
  const { line, sets } = prepareSuggestion(script, check, AS_EXECUTOR);
  return insertAssertionLines(script, line, "post", sets).script;
};
/** The lines still offered to add: those the batch does not hold. */
const lines = (state: SimulationState, k: SimKey) =>
  suggestedChecks(state, k)
    ?.rows.filter((row) => !row.inBatch)
    .map((row) => row.check.line) ?? null;
const short = (a: string) => `${a.slice(0, 6)}…${a.slice(-4)}`;
const link = (label: string, address: string) => ({
  label,
  address,
  href: `https://etherscan.io/address/${address}`,
});

describe("sentenceView", () => {
  it("links each address, by its shortened form when it has no name", () => {
    expect(sentenceView(OWNER, 1)).toEqual([
      link(short(OWNED), OWNED),
      " is owned by ",
      link(short(OTHER), OTHER),
    ]);
  });

  it("links the symbol inside an amount to the token, a listed one standing alone", () => {
    expect(sentenceView(SPENT, 1)).toEqual([
      link(short(EXECUTOR), EXECUTOR),
      " keeps at least ",
      "51,950.2982 ",
      link("USDC", USDC),
    ]);
  });

  it("shows the address beside a symbol only the token vouches for", () => {
    const amount = { ...SPENT.sentence![2], token: FAKE, listed: undefined } as never;
    const view = sentenceView({ ...SPENT, sentence: [amount] }, 1);
    expect(view).toEqual(["51,950.2982 ", link(`USDC (${short(FAKE)})`, FAKE)]);
  });

  it("does the same for a contract's name: alone when listed, with its address otherwise", () => {
    const named = (listed?: true): SuggestedCheck => ({
      ...OWNER,
      sentence: [
        { type: "address", address: USDC, name: "USDC", ...(listed ? { listed } : {}) },
        { type: "text", text: " is paused" },
      ],
    });
    expect(sentenceView(named(true), 1)).toEqual([link("USDC", USDC), " is paused"]);
    expect(sentenceView(named(), 1)).toEqual([
      link(`USDC (${short(USDC)})`, USDC),
      " is paused",
    ]);
  });

  it("keeps the symbol where the amount says it, as in dust", () => {
    const dust = {
      type: "amount",
      value: "5",
      bound: "exact",
      token: USDC,
      symbol: "USDC",
      decimals: 6,
      listed: true,
      text: "5 base units of USDC",
    } as const;
    expect(sentenceView({ ...SPENT, sentence: [dust] }, 1)).toEqual([
      "5 base units of ",
      link("USDC", USDC),
    ]);
  });

  it("names a token without a symbol by its address", () => {
    const bare = { type: "amount", value: "7", bound: "floor", token: FAKE, text: "7 base units" } as const;
    expect(sentenceView({ ...SPENT, sentence: [bare] }, 1)).toEqual([
      "7 base units",
      " of ",
      link(short(FAKE), FAKE),
    ]);
  });

  it("does not link the chain's own currency", () => {
    expect(sentenceView(NATIVE, 1)).toEqual([
      "ETH balance of ",
      link(short(EXECUTOR), EXECUTOR),
      " stays at or above ",
      "122.0843 ETH",
      ", which leaves up to ",
      "0.00002 ETH",
      " for gas",
    ]);
  });

  it("has no link on a chain without a known explorer, only the address", () => {
    expect(sentenceView(OWNER, 987_654_321_012)).toEqual([
      { label: short(OWNED), address: OWNED },
      " is owned by ",
      { label: short(OTHER), address: OTHER },
    ]);
  });

  it("refuses a name or a symbol that is not short and plain, and a part that is not an address", () => {
    const sentence = [
      { type: "address", address: USDC, name: "<b>USDC</b> https://x", listed: true },
      { type: "text", text: " and " },
      { type: "address", address: "javascript:alert(1)", name: "X" },
    ] as never;
    expect(sentenceView({ ...OWNER, sentence }, 1)).toEqual([
      link(short(USDC), USDC),
      " and ",
      "javascript:alert(1)",
    ]);
  });

  it("is nothing for the older shape, which has only a description", () => {
    const { sentence: _s, vars: _v, ...older } = OWNER;
    expect(sentenceView(older as SuggestedCheck, 1)).toBeNull();
    expect(sentenceView({ ...older, sentence: "nope" as never }, 1)).toBeNull();
    expect(sentenceView({ ...older, sentence: [] }, 1)).toBeNull();
  });
});

describe("addressVariables", () => {
  it("lists the variables a script sets to an address, and only those", () => {
    const script = [
      `set $usdc ${USDC}`,
      "set $name @ens(vitalik.eth)",
      "set $n 5",
      `set $mod:key ${OWNED}`,
      ACTION,
    ].join("\n");
    expect([...addressVariables(script)]).toEqual([["usdc", USDC]]);
  });
});

describe("prepareSuggestion", () => {
  it("sets each of the line's variables, in the order the line uses them", () => {
    expect(prepareSuggestion(BATCH, SPENT, AS_EXECUTOR)).toMatchObject({
      line: SPENT.line,
      sets: [`set $usdc ${USDC}`, `set $executor ${EXECUTOR}`],
    });
  });

  it("lands the sets in the header, the load above them and the check after the last action", () => {
    expect(add(BATCH, SPENT).split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $executor ${EXECUTOR}`,
      ACTION,
      ACTION_2,
      SPENT.line,
    ]);
  });

  it("sets a variable two suggestions share once, and loads a module once", () => {
    const script = add(add(add(BATCH, SPENT), RECEIVED), OWNER);
    expect(script.split("\n")).toEqual([
      "load token",
      "load acl",
      `set $usdc ${USDC}`,
      `set $executor ${EXECUTOR}`,
      `set $recipient ${OTHER}`,
      `set $contract ${OWNED}`,
      ACTION,
      ACTION_2,
      SPENT.line,
      RECEIVED.line,
      // The new owner is the recipient: one address, one variable.
      "assert @acl:owner!($contract) == $recipient",
    ]);
  });

  it("reuses a variable the script already sets to the same address, whatever its name or case", () => {
    const script = `set $stable ${USDC.toUpperCase().replace("0X", "0x")}\nset $me2 ${EXECUTOR}\n${BATCH}`;
    expect(prepareSuggestion(script, SPENT, AS_EXECUTOR)).toMatchObject({
      line: "assert @balance!($stable $me2) >= @token:amount($stable 51950.2982)",
      sets: [],
    });
  });

  it("renames a variable whose name the script gives to something else", () => {
    const script = `set $executor ${OTHER}\nset $usdc @ens(usdc.eth)\n${BATCH}`;
    expect(prepareSuggestion(script, SPENT, AS_EXECUTOR)).toMatchObject({
      line: "assert @balance!($usdc2 $executor2) >= @token:amount($usdc2 51950.2982)",
      sets: [`set $usdc2 ${USDC}`, `set $executor2 ${EXECUTOR}`],
    });
    // And the next free number when that one is taken too.
    expect(
      prepareSuggestion(`set $executor2 ${OWNED}\n${script}`, NATIVE, AS_EXECUTOR),
    ).toMatchObject({
      line: "assert @balance!(ETH $executor3) >= @token:amount(ETH 122.0843)",
      sets: [`set $executor3 ${EXECUTOR}`],
    });
  });

  it("swaps names without mixing them up when the script has them the other way round", () => {
    const script = `set $executor ${USDC}\nset $usdc ${EXECUTOR}\n${BATCH}`;
    expect(prepareSuggestion(script, SPENT, AS_EXECUTOR)).toMatchObject({
      line: "assert @balance!($executor $usdc) >= @token:amount($executor 51950.2982)",
      sets: [],
    });
  });

  it("leaves a literal address in a hand-built line alone", () => {
    const script = add(BATCH, SPENT);
    expect(script).toContain(ACTION);
    expect(script.split("\n").filter((l) => l.includes(`$usdc`)).length).toBe(2);
  });

  it("is the line as it is for the older shape, with nothing to set", () => {
    const older = { ...OWNER, line: `assert @acl:owner!(${OWNED}) == ${OTHER}`, vars: undefined, sentence: undefined };
    expect(prepareSuggestion(BATCH, older, AS_EXECUTOR)).toMatchObject({ line: older.line, sets: [], script: BATCH });
  });
});

describe("removing an added suggestion", () => {
  it("takes the variables and the load nothing else uses with it", () => {
    const one = add(BATCH, SPENT);
    const two = add(one, RECEIVED);
    const withoutSecond = removeCommand(two, two.split("\n").indexOf(RECEIVED.line) + 1);
    expect(withoutSecond).toBe(one);
    expect(removeCommand(one, one.split("\n").indexOf(SPENT.line) + 1)).toBe(BATCH);
    expect(gcScaffolding(one)).toBe(one);
  });
});

describe("lineMeaning", () => {
  it("is the line with its variables as the addresses they stand for", () => {
    const meaning = lineMeaning(SPENT.line, new Map([["usdc", USDC], ["executor", EXECUTOR]]));
    expect(meaning).toBe(
      `assert @balance!(${USDC} ${EXECUTOR.toLowerCase()}) >= @token:amount(${USDC} 51950.2982)`,
    );
    // Other names, the same meaning; a literal, the same meaning.
    expect(
      lineMeaning(
        "assert @balance!($a   $b) >= @token:amount($a 51950.2982)",
        new Map([["a", USDC.toUpperCase().replace("0X", "0x")], ["b", EXECUTOR]]),
      ),
    ).toBe(meaning);
    expect(lineMeaning(`assert @balance!(${USDC} ${EXECUTOR}) >= @token:amount(${USDC} 51950.2982)`, new Map())).toBe(meaning);
  });

  it("leaves a variable it knows no address for, and does not take $usdc2 for $usdc", () => {
    expect(lineMeaning("assert $usdc2::!{x()(bool)} == $y", new Map([["usdc", USDC]]))).toBe(
      "assert $usdc2::!{x()(bool)} == $y",
    );
  });
});

describe("suggestedChecks, by what a line means", () => {
  const state = ran(key(), [...ALL, NATIVE]);

  it("knows an added suggestion as in the batch, and the others as not", () => {
    const one = add(BATCH, OWNER);
    expect(suggestedChecks(state, key({ script: one }))).toEqual({
      // Added as it is, without the mark: in the batch, not managed.
      rows: [...ALL, NATIVE].map((check) => ({
        check,
        inBatch: check === OWNER,
        marked: false,
      })),
      truncated: false,
      stale: false,
    });
    const all = [SPENT, RECEIVED, NATIVE].reduce(add, one);
    expect(lines(state, key({ script: all }))).toEqual([]);
  });

  it("knows an added suggestion under the name it was renamed to", () => {
    const base = `set $executor ${OTHER}\n${BATCH}`;
    const s = ran(key({ script: base }), [SPENT, NATIVE]);
    const one = add(base, SPENT);
    expect(one).toContain("$executor2");
    expect(lines(s, key({ script: one }))).toEqual([NATIVE.line]);
  });

  it("knows it under a variable the script already had for that address", () => {
    const base = `set $stable ${USDC}\n${BATCH}`;
    const s = ran(key({ script: base }), [SPENT, RECEIVED]);
    const one = add(base, SPENT);
    expect(one).toContain("@balance!($stable $executor)");
    expect(lines(s, key({ script: one }))).toEqual([RECEIVED.line]);
  });

  it("hides a suggestion the simulated batch already had, written with literals or not", () => {
    const literal = `${BATCH}\nassert @acl:owner!(${OWNED}) == ${OTHER}`;
    expect(lines(ran(key({ script: literal }), ALL), key({ script: literal }))).toEqual([
      SPENT.line,
      RECEIVED.line,
    ]);
  });

  it("is from before once the actions change, with suggestions added or not; a check is not an action", () => {
    for (const script of [`${add(BATCH, OWNER)}\n${ACTION}`, ACTION])
      expect(suggestedChecks(state, key({ script }))?.stale).toBe(true);
    const handWritten = `${add(BATCH, OWNER)}\nassert ${USDC}::!{paused()(bool)} == false`;
    expect(suggestedChecks(state, key({ script: handWritten }))?.stale).toBe(false);
  });

  it("does not offer a second native floor, whatever number the next run gives it", () => {
    const script = add(BATCH, NATIVE);
    expect(script.split("\n")[0]).toBe("load token");
    const again = {
      ...NATIVE,
      line: "assert @balance!(ETH $executor) >= @token:amount(ETH 122.0842)",
    };
    expect(lines(ran(key({ script }), [again, SPENT]), key({ script }))).toEqual([SPENT.line]);
    // A floor written the way it used to be (an e18 literal, base units, a
    // literal address) is that same floor: nobody gets a second one.
    for (const old of [
      // The exact balance an earlier version suggested, to the last wei.
      "assert @balance!(ETH $executor) >= @token:amount(ETH 122.084339000000000001)",
      "assert @balance!(ETH $executor) >= 122.0843e18",
      "assert @balance!(ETH $executor) >= 122084339000000000000",
      `assert @balance!(ETH ${EXECUTOR}) >= 1.5e18`,
    ]) {
      const had = `set $executor ${EXECUTOR}\n${BATCH}\n${old}`;
      expect(lines(ran(key({ script: had }), [NATIVE, SPENT]), key({ script: had }))).toEqual([
        SPENT.line,
      ]);
    }
    // A token floor with another number is not a native floor: still offered.
    const moved = { ...SPENT, line: "assert @balance!($usdc $executor) >= @token:amount($usdc 1)" };
    const withSpent = add(BATCH, SPENT);
    expect(
      lines(ran(key({ script: withSpent }), [moved]), key({ script: withSpent })),
    ).toEqual([moved.line]);
    // Another account's floor is another check.
    const other = { ...NATIVE, vars: [{ name: "executor", value: OTHER as `0x${string}` }] };
    expect(lines(ran(key({ script }), [other]), key({ script }))).toEqual([other.line]);
  });

  it("takes a token floor at another precision for another check", () => {
    // Only the native floor is one per account whatever its number: a
    // token floor the script has at the old, exact precision does not
    // stand for the rounded one a new run suggests.
    const exact = `set $usdc ${USDC}\nset $executor ${EXECUTOR}\n${BATCH}\nassert @balance!($usdc $executor) >= @token:amount($usdc 51950.29822)`;
    expect(lines(ran(key({ script: exact }), [SPENT]), key({ script: exact }))).toEqual([
      SPENT.line,
    ]);
  });

  it("confirms added suggestions at the block they came from", () => {
    const pinned = { ...state, block: 21_234_567, blockReadAt: 1000 };
    expect(confirmationBlock(pinned, key({ script: add(BATCH, SPENT) }), 2000)).toBe(21_234_567);
    expect(confirmationBlock(pinned, key(), 2000)).toBeUndefined();
    expect(
      confirmationBlock(pinned, key({ script: `${add(BATCH, SPENT)}\n${ACTION}` }), 2000),
    ).toBeUndefined();
  });
});
