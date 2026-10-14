import type { SimulationResult } from "@evmcrispr/core";
import { describe, expect, it } from "vitest";

import { insertAssertionLines } from "../script-ops";
import { simKeyFor } from "../SimulationPanel";
import type { SimKey, SimulationState } from "../simulation";
import {
  type SuggestedCheck,
  ALLOWANCE_WARNING,
  AMOUNT_WARNING,
  BALANCE_WARNING,
  NATIVE_FLOOR_WARNING,
  PIN_MAX_AGE_MS,
  amountWarning,
  checkNotices,
  EMPTIED_NOTICE,
  RECIPIENT_NOTICE,
  confirmationBlock,
  descriptionParts,
  displayDescription,
  suggestOption,
  suggestionSource,
  suggestedChecks,
} from "../suggested-checks";

const SAFE = "0x5Afe000000000000000000000000000000005afe";
const OTHER = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001";
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
const HELD_1155: SuggestedCheck = {
  ...RECEIVED,
  line: `assert ${TOKEN}::!{balanceOf(address,uint256)(uint256) ${OTHER} 7} >= 1`,
  event: "erc1155TransferSingle",
};
const UNKNOWN_AMOUNT: SuggestedCheck = {
  ...SPENT,
  line: `assert ${TOKEN}::!{staked(address)(uint256) ${SAFE}} >= 1`,
  module: "vault",
  event: "somethingNew",
};
const PROXY = "0x00000000000000000000000000000000000000cc";
const IMPL = "0x00000000000000000000000000000000000000dd";
const UPGRADED: SuggestedCheck = {
  line: `assert @proxies:implementation!(${PROXY}) == ${IMPL}`,
  description:
    "0x0000…00cc reports the implementation 0x0000…00dd",
  kind: "state",
  module: "proxies",
  event: "upgraded",
  eventName: "Upgraded",
  emitter: PROXY,
};
const NODE = `0x${"ab".repeat(32)}`;
const ENS_OWNER: SuggestedCheck = {
  line: `assert ${OWNED}::!{owner(bytes32)(address) ${NODE}} == ${OTHER}`,
  description:
    "The node transferred on 0x0000…00bb is owned by 0xabcd…0001",
  kind: "state",
  module: "ens",
  event: "transfer",
  eventName: "Transfer",
  emitter: OWNED,
};

const key = (partial: Partial<SimKey> = {}): SimKey => ({
  script: BATCH,
  from: SAFE,
  chainId: 1,
  mode: "protected",
  ...partial,
});
/** A result as a test writes it: its suggestions may be of the older
 *  shape, which the builder still takes. */
type ResultLike = Omit<Partial<SimulationResult>, "suggestions"> & {
  suggestions?: SuggestedCheck[];
};
/** Step 1's run of the batch `simulated` stands for: its actions alone,
 *  which is what suggests checks. */
const ran = (simulated: SimKey, result: ResultLike = {}): SimulationState => {
  const full = { success: true, logs: [], actions: [], ...result } as SimulationResult;
  return {
    status: full.success ? "success" : "failure",
    result: full,
    simulated: simKeyFor("actions-only", simulated.script, simulated.from, simulated.chainId),
  };
};
const add = (script: string, check: SuggestedCheck) =>
  insertAssertionLines(script, check.line, "post").script;
/** The lines still offered to add: those the batch does not hold. */
const lines = (state: SimulationState, k: SimKey) =>
  suggestedChecks(state, k)
    ?.rows.filter((row) => !row.inBatch)
    .map((row) => row.check.line) ?? null;
/** Every row, as offered: to add, or to remove. */
const offered = (state: SimulationState, k: SimKey) =>
  suggestedChecks(state, k)?.rows.map((row) => [row.check.line, row.inBatch ? "remove" : "add"]);

describe("suggestOption", () => {
  const actions = (partial: Partial<SimKey> = {}) => key({ mode: "actions-only", ...partial });

  it("asks step 1's run, guarding the account it runs as", () => {
    expect(suggestOption(actions())).toEqual({ executor: SAFE });
  });

  it("asks without an executor when there is none", () => {
    expect(suggestOption(actions({ from: undefined }))).toBe(true);
  });

  it("does not ask the protected batch: its checks are the ones being added", () => {
    expect(suggestOption(key())).toBeUndefined();
  });

  it("asks a wallet batch for exact amounts: it executes from the state just simulated", () => {
    expect(suggestOption(actions(), "eoa")).toEqual({ executor: SAFE, exact: true });
    expect(suggestOption(actions({ from: undefined }), "eoa")).toEqual({
      exact: true,
    });
  });

  it.each(["safe", "governor", "aragonosx"] as const)(
    "keeps floors where execution comes later, in a %s context",
    (kind) => {
      expect(suggestOption(actions(), kind)).toEqual({ executor: SAFE });
    },
  );
});

describe("suggestedChecks", () => {
  it("lists what a passing simulation of the current batch suggested", () => {
    expect(suggestedChecks(ran(key(), { suggestions: ALL }), key())).toEqual({
      rows: ALL.map((check) => ({ check, inBatch: false, marked: false })),
      truncated: false,
      stale: false,
    });
  });

  it("says when the run saw more than was looked at", () => {
    expect(
      suggestedChecks(
        ran(key(), { suggestions: [OWNER], suggestionsTruncated: true }),
        key(),
      )?.truncated,
    ).toBe(true);
  });

  it("says why a run that could not vouch for its suggestions gave none", () => {
    const found = suggestedChecks(
      ran(key(), { suggestions: [], suggestionsError: "the node did not trace" }),
      key(),
    );
    expect(found?.rows).toEqual([]);
    expect(found?.error).toBe("the node did not trace");
  });

  it("has nothing for a failed run, a run in flight or no run", () => {
    expect(
      suggestedChecks(ran(key(), { success: false, suggestions: ALL }), key()),
    ).toBeNull();
    expect(
      suggestedChecks({ status: "running", result: null, simulated: key() }, key()),
    ).toBeNull();
    expect(
      suggestedChecks({ status: "idle", result: null, simulated: null }, key()),
    ).toBeNull();
  });

  it("reads a result without suggestions (older shape) as one that suggested none", () => {
    expect(suggestedChecks(ran(key()), key())?.rows).toEqual([]);
    expect(
      suggestedChecks(ran(key(), { suggestions: "nope" as never }), key())?.rows,
    ).toEqual([]);
  });

  it("lists an empty run as empty", () => {
    expect(suggestedChecks(ran(key(), { suggestions: [] }), key())).toEqual({
      rows: [],
      truncated: false,
      stale: false,
    });
  });

  it.each([
    ["another executor", { from: OTHER as `0x${string}` }],
    ["no executor", { from: undefined }],
    ["another chain", { chainId: 100 }],
  ])("has nothing for %s: they were suggested for this one", (_name, change) => {
    expect(suggestedChecks(ran(key(), { suggestions: ALL }), key(change))).toBeNull();
  });

  it.each([
    ["another action", { script: `${BATCH}\n${ACTION}` }],
    ["one action fewer", { script: ACTION }],
  ])("keeps them, marked as from before, after %s", (_name, change) => {
    const found = suggestedChecks(ran(key(), { suggestions: ALL }), key(change));
    expect(found?.rows).toHaveLength(3);
    expect(found?.stale).toBe(true);
  });

  it("is not from before because of a check: only the actions count", () => {
    const script = `${add(BATCH, OWNER)}\nassert ${TOKEN}::!{paused()(bool)} == false`;
    expect(suggestedChecks(ran(key(), { suggestions: ALL }), key({ script }))?.stale).toBe(
      false,
    );
  });

  it("keeps every row after one is added, that one now to remove", () => {
    const state = ran(key(), { suggestions: ALL });
    const one = add(BATCH, OWNER);
    // The line brought its module's load with it.
    expect(one.split("\n")).toEqual(["load acl", ACTION, ACTION_2, OWNER.line]);
    expect(offered(state, key({ script: one }))).toEqual([
      [OWNER.line, "remove"],
      [SPENT.line, "add"],
      [RECEIVED.line, "add"],
    ]);
    const two = add(one, RECEIVED);
    expect(lines(state, key({ script: two }))).toEqual([SPENT.line]);
    const three = add(two, SPENT);
    expect(lines(state, key({ script: three }))).toEqual([]);
    expect(suggestedChecks(state, key({ script: three }))?.rows).toHaveLength(3);
  });

  it("brings a suggestion back when its line is removed again", () => {
    const state = ran(key(), { suggestions: ALL });
    const added = add(add(BATCH, OWNER), SPENT);
    const without = added
      .split("\n")
      .filter((l) => l !== OWNER.line && l !== "load acl")
      .join("\n");
    expect(lines(state, key({ script: without }))).toEqual([
      OWNER.line,
      RECEIVED.line,
    ]);
  });

  it("hides a suggestion the simulated batch already had", () => {
    const script = add(BATCH, OWNER);
    expect(lines(ran(key({ script }), { suggestions: ALL }), key({ script }))).toEqual(
      [SPENT.line, RECEIVED.line],
    );
  });

  it("keeps an added suggestion to remove once an action changes too", () => {
    const state = ran(key(), { suggestions: ALL });
    const edited = `${add(BATCH, OWNER)}\n${ACTION}`;
    expect(offered(state, key({ script: edited }))?.[0]).toEqual([OWNER.line, "remove"]);
    expect(suggestedChecks(state, key({ script: edited }))?.stale).toBe(true);
  });

  it("ignores trailing blank lines and the executor's letter case", () => {
    const state = ran(key({ script: `${BATCH}\n` }), { suggestions: ALL });
    expect(
      lines(state, key({ from: SAFE.toLowerCase() as `0x${string}` })),
    ).toHaveLength(3);
  });

  it("offers upgrade and ENS suggestions, and loads proxies with the upgrade one", () => {
    const state = ran(key(), { suggestions: [UPGRADED, ENS_OWNER] });
    expect(lines(state, key())).toEqual([UPGRADED.line, ENS_OWNER.line]);
    const one = add(BATCH, UPGRADED);
    expect(one.split("\n")).toEqual([
      "load proxies",
      ACTION,
      ACTION_2,
      UPGRADED.line,
    ]);
    expect(lines(state, key({ script: one }))).toEqual([ENS_OWNER.line]);
    // An ENS check is a plain call: no module to load.
    const two = add(one, ENS_OWNER);
    expect(two.split("\n")).toEqual([
      "load proxies",
      ACTION,
      ACTION_2,
      UPGRADED.line,
      ENS_OWNER.line,
    ]);
  });

  it("does not offer a second native floor once the batch has one", () => {
    // Simulated again with the floor in place, the run costs other gas and
    // the same floor comes back with another number.
    const script = add(BATCH, NATIVE);
    const again: SuggestedCheck = {
      ...NATIVE,
      line: `assert @balance!(ETH ${SAFE}) >= 989999999999999999`,
    };
    expect(
      lines(ran(key({ script }), { suggestions: [again, SPENT] }), key({ script })),
    ).toEqual([SPENT.line]);
    // Another account's floor, or a token floor with another number, is
    // another check.
    const others: SuggestedCheck[] = [
      { ...NATIVE, line: `assert @balance!(ETH ${OTHER}) >= 5` },
      { ...SPENT, line: `assert @balance!(${TOKEN} ${SAFE}) >= 94` },
    ];
    const withSpent = add(script, SPENT);
    expect(
      lines(
        ran(key({ script: withSpent }), { suggestions: others }),
        key({ script: withSpent }),
      ),
    ).toEqual(others.map((o) => o.line));
    // Removed again, it is offered again.
    expect(lines(ran(key(), { suggestions: [again] }), key())).toEqual([again.line]);
  });

  it("lists a line suggested twice once", () => {
    expect(
      lines(ran(key(), { suggestions: [OWNER, SPENT, OWNER] }), key()),
    ).toEqual([OWNER.line, SPENT.line]);
  });
});

describe("confirmationBlock", () => {
  const T0 = 1_700_000_000_000;
  const at = (state: SimulationState, block = 21_234_567): SimulationState => ({
    ...state,
    block,
    blockReadAt: T0,
  });
  const state = at(ran(key(), { suggestions: ALL }));

  it("confirms added suggestions at the block they were drawn from", () => {
    const one = add(BATCH, OWNER);
    expect(confirmationBlock(state, key({ script: one }), T0 + 1000)).toBe(21_234_567);
    const all = add(add(one, SPENT), RECEIVED);
    expect(confirmationBlock(state, key({ script: all }), T0 + 1000)).toBe(21_234_567);
  });

  it("goes back to the latest block for the batch as it was simulated", () => {
    expect(confirmationBlock(state, key(), T0 + 1000)).toBeUndefined();
  });

  it("keeps the block with a check written by hand beside them: the actions are the same", () => {
    const script = `${add(BATCH, OWNER)}\nassert ${TOKEN}::!{paused()(bool)} == false`;
    expect(confirmationBlock(state, key({ script }), T0 + 1000)).toBe(21_234_567);
  });

  it.each([
    ["another action", { script: `${add(BATCH, OWNER)}\n${ACTION}` }],
    ["another executor", { script: add(BATCH, OWNER), from: OTHER as `0x${string}` }],
    ["another chain", { script: add(BATCH, OWNER), chainId: 100 }],
  ])("drops the block for %s", (_name, change) => {
    expect(confirmationBlock(state, key(change), T0 + 1000)).toBeUndefined();
  });

  it("drops the block once it is too old to stand for the chain", () => {
    const k = key({ script: add(BATCH, OWNER) });
    expect(confirmationBlock(state, k, T0 + PIN_MAX_AGE_MS)).toBe(21_234_567);
    expect(confirmationBlock(state, k, T0 + PIN_MAX_AGE_MS + 1)).toBeUndefined();
    expect(PIN_MAX_AGE_MS).toBe(5 * 60_000);
  });

  it("has no block to confirm at after a failure, or when none was read", () => {
    const k = key({ script: add(BATCH, OWNER) });
    expect(
      confirmationBlock(at(ran(key(), { success: false, suggestions: ALL })), k, T0),
    ).toBeUndefined();
    expect(confirmationBlock(ran(key(), { suggestions: ALL }), k, T0)).toBeUndefined();
    expect(confirmationBlock(at(ran(key())), k, T0)).toBeUndefined();
  });
});

describe("displayDescription", () => {
  it("writes shortened addresses the way the rest of the builder does", () => {
    expect(
      displayDescription(
        "0x28C6...1d60 spends no more USDC (0xA0b8...eB48) than simulated",
      ),
    ).toBe("0x28C6…1d60 spends no more USDC (0xA0b8…eB48) than simulated");
  });

  it("leaves every other run of dots alone", () => {
    for (const text of [
      "Wait... the owner is 0x28C6",
      "An allowance of 5 base units... of TKN",
      "0x28C6....1d60",
      "0x28C...1d60",
      "0x28C6...1d6",
      "0x28C6c0...1d60ab",
      "0xZZZZ...1d60",
      "0x28C6…1d60 already",
    ])
      expect(displayDescription(text)).toBe(text);
  });
});

describe("descriptionParts", () => {
  it("sets shortened addresses apart from the words around them", () => {
    expect(
      descriptionParts("0x28C6...1d60 spends no more USDC (0xA0b8…eB48) than simulated"),
    ).toEqual([
      { address: "0x28C6…1d60" },
      " spends no more USDC (",
      { address: "0xA0b8…eB48" },
      ") than simulated",
    ]);
  });

  it("is the text itself when it names no address", () => {
    expect(descriptionParts("Wait... nothing here, not even 0x28C6")).toEqual([
      "Wait... nothing here, not even 0x28C6",
    ]);
    expect(descriptionParts("")).toEqual([]);
  });

  it("reads back as the displayed description", () => {
    const text = "ETH balance of 0x28C6...1d60 stays (0xA0b8...eB48), 0x28C6....1d60";
    expect(
      descriptionParts(text)
        .map((p) => (typeof p === "string" ? p : p.address))
        .join(""),
    ).toBe(displayDescription(text));
  });
});

describe("suggestionSource", () => {
  it("names the emitter as it names itself, linked to its page on the chain's explorer", () => {
    expect(suggestionSource(SPENT, 1)).toEqual({
      label: "TKN",
      href: `https://etherscan.io/address/${TOKEN}`,
      address: TOKEN,
      eventName: "Transfer",
    });
    expect(suggestionSource(SPENT, 100)?.href).toBe(
      `https://gnosisscan.io/address/${TOKEN}`,
    );
  });

  it("shows the shortened address of an emitter without a name", () => {
    expect(suggestionSource(OWNER, 1)).toEqual({
      label: "0x0000…00bb",
      href: `https://etherscan.io/address/${OWNED}`,
      address: OWNED,
      eventName: "OwnershipTransferred",
    });
  });

  it("has no link on a chain without a known explorer", () => {
    const source = suggestionSource(SPENT, 987_654_321_012);
    expect(source).toEqual({ label: "TKN", address: TOKEN, eventName: "Transfer" });
    expect(source && "href" in source).toBe(false);
  });

  it("is nothing for a suggestion that comes from no event", () => {
    expect(suggestionSource(NATIVE, 1)).toBeNull();
  });

  it("is nothing for a suggestion of the older shape", () => {
    const { eventName: _e, emitterName: _n, ...older } = SPENT;
    expect(suggestionSource(older, 1)).toBeNull();
    expect(suggestionSource({ ...older, emitter: undefined as never }, 1)).toBeNull();
  });

  it("does not link to an emitter that is not an address", () => {
    expect(
      suggestionSource({ ...SPENT, emitter: "javascript:alert(1)" as never }, 1),
    ).toBeNull();
  });
});

describe("amountWarning", () => {
  const LATER = ["safe", "governor", "aragonosx"] as const;

  it.each(LATER)("names the allowance for an approval in a %s context", (kind) => {
    expect(amountWarning(ALLOWANCE, kind)).toBe(ALLOWANCE_WARNING);
    expect(ALLOWANCE_WARNING).toBe(
      "The allowance may change before the proposal executes.",
    );
  });

  it.each(["eoa", ...LATER] as const)(
    "says what the native floor depends on in a %s context, in place of the balance warning",
    (kind) => {
      expect(amountWarning(NATIVE, kind)).toBe(NATIVE_FLOOR_WARNING);
      expect(NATIVE_FLOOR_WARNING).toBe(
        "Other transactions from this account change this balance: the check fails if it falls below the floor.",
      );
    },
  );

  it.each(LATER)(
    "names balances for the native currency of other accounts, and for an executor emptied of it, in a %s context",
    (kind) => {
      const other = { kind: "amount" as const, module: "std", event: "nativeBalance" };
      expect(amountWarning(other, kind)).toBe(BALANCE_WARNING);
      // `== 0` is not a floor: the floor's warning would not be true of it.
      const emptied = {
        ...NATIVE,
        line: "assert @balance!(ETH $executor) == 0",
      };
      expect(amountWarning(emptied, kind)).toBe(BALANCE_WARNING);
    },
  );

  it("says nothing of an exact amount in a wallet batch, which executes right away", () => {
    expect(
      amountWarning({ ...NATIVE, line: "assert @balance!(ETH $executor) == 0" }, "eoa"),
    ).toBeNull();
    expect(
      amountWarning({ kind: "amount", module: "std", event: "nativeBalance" }, "eoa"),
    ).toBeNull();
  });

  it.each(LATER)("names balances for transfers in a %s context", (kind) => {
    for (const check of [SPENT, RECEIVED, HELD_1155])
      expect(amountWarning(check, kind)).toBe(BALANCE_WARNING);
    expect(BALANCE_WARNING).toBe(
      "Balances may change before the proposal executes.",
    );
  });

  it.each(LATER)("says only what holds of any amount for an event it does not know, in a %s context", (kind) => {
    expect(amountWarning(UNKNOWN_AMOUNT, kind)).toBe(AMOUNT_WARNING);
    // The same event name from another module is not the token's.
    expect(amountWarning({ ...ALLOWANCE, module: "vault" }, kind)).toBe(
      AMOUNT_WARNING,
    );
    expect(AMOUNT_WARNING).toBe(
      "This amount may change before the proposal executes.",
    );
  });

  it.each(LATER)("does not warn about state in a %s context", (kind) => {
    for (const check of [OWNER, UPGRADED, ENS_OWNER])
      expect(amountWarning(check, kind)).toBeNull();
  });

  it("does not warn in a wallet context, which executes right away", () => {
    for (const check of [SPENT, ALLOWANCE, UNKNOWN_AMOUNT, OWNER])
      expect(amountWarning(check, "eoa")).toBeNull();
  });
});

describe("checkNotices", () => {
  const floor = (address: string): SuggestedCheck =>
    ({
      line: "assert @balance!($usdc $who) >= @token:amount($usdc 1485)",
      description: "holds at least",
      kind: "amount",
      module: "token",
      event: "erc20Transfer",
      emitter: SAFE,
      sentence: [
        { type: "address", address },
        { type: "text", text: " holds at least 1,485 USDC" },
      ],
    }) as SuggestedCheck;
  const OTHER_ACCOUNT = "0x00000000000000000000000000000000000a0001";

  it("says a recipient can move what it got, and anyone can refill an emptied account", () => {
    expect(checkNotices(floor(OTHER_ACCOUNT), "safe", SAFE)).toEqual([RECIPIENT_NOTICE]);
    expect(
      checkNotices(
        { ...floor(SAFE), line: "assert @balance!($dai $executor) == 0" },
        "safe",
        SAFE,
      ),
    ).toEqual([EMPTIED_NOTICE]);
    // The executor's own floor keeps the general notice.
    expect(checkNotices(floor(SAFE), "safe", SAFE)).toEqual([BALANCE_WARNING]);
  });

  it("has none in a wallet batch, which executes right away", () => {
    expect(checkNotices(floor(OTHER_ACCOUNT), "eoa", SAFE)).toEqual([]);
  });
});
