import { BASE_UNITS_COMMENT } from "@evmcrispr/sdk";
import { describe, expect, it, vi } from "vitest";

import { type ComposeEnv, amountField, amountHint, composeCall, decomposeCall, tokenAmount, wantedName } from "../compose-call";
import { bindVariables, gcScaffolding, insertAssertionLines, removeCommand, stripAssertions } from "../script-ops";

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const ALICE = "0xABcdEFABcdEFabcdEfAbCdefabcdeFABcDEFabCD";
const PLAIN = "0x00000000000000000000000000000000000000bb";
const MAX = (2n ** 256n - 1n).toString();

const TOKENS = [
  { symbol: "USDC", chainId: 1, address: USDC },
  { symbol: "WETH", chainId: 1, address: WETH },
  // Not names a variable may take: a second USDC, the native symbol, a
  // symbol that is no plain word, another chain's token.
  { symbol: "USDC", chainId: 1, address: PLAIN },
  { symbol: "ETH", chainId: 1, address: "0x00000000000000000000000000000000000000e1" },
  { symbol: "a-b", chainId: 1, address: "0x00000000000000000000000000000000000000e2" },
  { symbol: "GNO", chainId: 100, address: "0x00000000000000000000000000000000000000e3" },
];
const DECIMALS: Record<string, number> = { [USDC]: 6, [WETH]: 18 };

const env = (partial: Partial<ComposeEnv> = {}): ComposeEnv => ({
  chainId: 1,
  nativeSymbol: "ETH",
  tokens: TOKENS,
  decimalsOf: async (address) => DECIMALS[address],
  ensToVar: async () => null,
  ...partial,
});
const input = (name: string, type: string) => ({ name, type });
const TRANSFER = { signature: "transfer(address,uint256)", inputs: [input("to", "address"), input("value", "uint256")] };
const APPROVE = { signature: "approve(address,uint256)", inputs: [input("spender", "address"), input("amount", "uint256")] };
const TRANSFER_FROM = {
  signature: "transferFrom(address,address,uint256)",
  inputs: [input("from", "address"), input("to", "address"), input("amount", "uint256")],
};

/** The call as the script gets it: bound to the script's variables and
 *  inserted the way the builder inserts an action. */
async function added(script: string, call: Parameters<typeof composeCall>[0], e = env()) {
  const composed = await composeCall(call, e);
  const { line, sets } = bindVariables(script, composed);
  return insertAssertionLines(script, line, "post", sets).script;
}
const transfer = (to: string, amount: string, target = USDC) => ({
  target,
  targetRef: target,
  ...TRANSFER,
  values: { to, value: amount },
});

describe("composeCall: addresses become variables", () => {
  it("names a listed token by its symbol, an argument by its parameter", async () => {
    expect((await added("", transfer(DEAD, "1000000"))).split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $to ${DEAD}`,
      'exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 1)',
    ]);
  });

  it("calls a target the list does not know $contract, and an unnamed argument $address", async () => {
    const script = await added("", {
      target: PLAIN,
      targetRef: PLAIN,
      signature: "grant(address,address)",
      inputs: [input("arg0", "address"), input("_who", "address")],
      values: { arg0: DEAD, _who: ALICE },
    });
    expect(script.split("\n")).toEqual([
      `set $contract ${PLAIN}`,
      `set $address ${DEAD}`,
      `set $who ${ALICE}`,
      'exec $contract "grant(address,address)" $address $who',
    ]);
  });

  it("never names a variable after a listed token it is not", async () => {
    // A parameter called usdc, pointing somewhere else: not $usdc.
    const script = await added("", {
      target: PLAIN,
      targetRef: PLAIN,
      signature: "set(address,address)",
      inputs: [input("usdc", "address"), input("WETH", "address")],
      values: { usdc: DEAD, WETH: WETH },
    });
    expect(script.split("\n")).toEqual([
      `set $contract ${PLAIN}`,
      `set $address ${DEAD}`,
      `set $weth ${WETH}`,
      'exec $contract "set(address,address)" $address $weth',
    ]);
  });

  it("does not take a symbol that is shared, native, not a plain word or another chain's", async () => {
    for (const address of [PLAIN, TOKENS[3].address, TOKENS[4].address, TOKENS[5].address]) {
      const script = await added("", { target: address, targetRef: address, signature: "poke()", inputs: [], values: {} });
      expect(script.split("\n")[0].toLowerCase()).toBe(`set $contract ${address}`.toLowerCase());
    }
  });

  it("gives one address one variable, and numbers a name two addresses want", async () => {
    const script = await added("", {
      ...TRANSFER_FROM,
      target: USDC,
      targetRef: USDC,
      values: { from: ALICE, to: ALICE, amount: "5" },
    });
    expect(script).toContain('exec $usdc "transferFrom(address,address,uint256)" $from $from @token:amount($usdc 0.000005)');
    const two = await added("", {
      target: PLAIN,
      targetRef: PLAIN,
      signature: "pair(address,address)",
      inputs: [input("arg0", "address"), input("arg1", "address")],
      values: { arg0: DEAD, arg1: ALICE },
    });
    expect(two.split("\n").slice(1)).toEqual([
      `set $address ${DEAD}`,
      `set $address2 ${ALICE}`,
      'exec $contract "pair(address,address)" $address $address2',
    ]);
  });

  it("names the addresses inside arrays and tuples too", async () => {
    const script = await added("", {
      target: PLAIN,
      targetRef: PLAIN,
      signature: "many(address[],(address,uint256))",
      inputs: [input("recipients", "address[]"), input("order", "(address,uint256)")],
      values: { recipients: `${DEAD}, ${ALICE}`, order: `(${WETH}, 7)` },
    });
    expect(script.split("\n")).toEqual([
      `set $contract ${PLAIN}`,
      `set $recipients ${DEAD}`,
      `set $recipients2 ${ALICE}`,
      `set $weth ${WETH}`,
      'exec $contract "many(address[],(address,uint256))" [$recipients $recipients2] [$weth 7]',
    ]);
  });

  it("leaves what is not a literal address as it was typed", async () => {
    const script = await added("", transfer("@me", "1000000"));
    expect(script.split("\n").at(-1)).toBe(
      'exec $usdc "transfer(address,uint256)" @me @token:amount($usdc 1)',
    );
    expect(await added("", transfer("$treasury", "1000000"))).toContain("$treasury @token:amount");
  });

  it("keeps an ENS name live on mainnet and uses its variable everywhere", async () => {
    const ensToVar = vi.fn(async () => "$vitalik");
    const composed = await composeCall(
      { ...transfer("vitalik.eth", "1000000"), targetRef: "$usdcTokensEthers" },
      env({ ensToVar }),
    );
    expect(composed.line).toBe(
      'exec $usdcTokensEthers "transfer(address,uint256)" $vitalik @token:amount($usdcTokensEthers 1)',
    );
    expect(composed.vars).toEqual([]);
  });

  it("uses the variable a script already has for an address, and renames on a clash", async () => {
    const script = `set $stable ${USDC}\nset $to ${ALICE}`;
    expect((await added(script, transfer(DEAD, "2500000"))).split("\n")).toEqual([
      "load token",
      `set $stable ${USDC}`,
      `set $to ${ALICE}`,
      `set $to2 ${DEAD}`,
      'exec $stable "transfer(address,uint256)" $to2 @token:amount($stable 2.5)',
    ]);
  });
});

describe("composeCall: token amounts", () => {
  const amountOf = async (call: Parameters<typeof composeCall>[0], e = env()) =>
    (await composeCall(call, e)).line.split(" ").slice(3).join(" ").replace(/^\$\S+ /, "");

  it.each([
    ["1000000", USDC, "@token:amount($_0 1)"],
    ["1", USDC, "@token:amount($_0 0.000001)"],
    ["51950298220", USDC, "@token:amount($_0 51950.29822)"],
    ["0", USDC, "@token:amount($_0 0)"],
    ["1000000000000000000", WETH, "@token:amount($_0 1)"],
    ["127019840673733935141936", WETH, "@token:amount($_0 127019.840673733935141936)"],
    ["1000000000000", WETH, "@token:amount($_0 0.000001)"],
    ["1e18", WETH, "@token:amount($_0 1)"],
    ["25e17", WETH, "@token:amount($_0 2.5)"],
  ])("writes %s base units of a token exactly", async (raw, token, expected) => {
    expect(await amountOf(transfer(DEAD, raw, token))).toBe(expected);
  });

  it.each([
    ["the largest number there is", MAX, USDC],
    ["something that is not a whole number of base units", "1.5", USDC],
    ["a helper the user wrote", "@token:amount(USDC 1)", USDC],
    ["nothing", "", USDC],
  ])("leaves %s as it was typed", async (_name, raw, token) => {
    expect(await amountOf(transfer(DEAD, raw, token))).toBe(raw);
  });

  it("writes dust in base units and says so, as a suggested check does", async () => {
    const dust = await composeCall(transfer(DEAD, "999999999999", WETH), env());
    expect(dust.line).toBe(
      `exec $_0 "transfer(address,uint256)" $_1 999999999999${BASE_UNITS_COMMENT}$_0`,
    );
    // After everything else on the line.
    const paid = await composeCall({ ...transfer(DEAD, "5", WETH), value: "1" }, env());
    expect(paid.line).toBe(
      `exec $_0 "transfer(address,uint256)" $_1 5 --value 1${BASE_UNITS_COMMENT}$_0`,
    );
    // In a script the unit names the token as the line does.
    expect((await added("", transfer(DEAD, "5", WETH))).split("\n").at(-1)).toBe(
      `exec $weth "transfer(address,uint256)" $to 5${BASE_UNITS_COMMENT}$weth`,
    );
  });

  it("says where each name comes from: the list, the parameter, or nothing", async () => {
    const composed = await composeCall(
      { target: USDC, targetRef: USDC, signature: "f(address,address)", inputs: [input("to", "address"), input("arg1", "address")], values: { to: DEAD, arg1: ALICE } },
      env(),
    );
    expect(composed.vars).toEqual([
      { name: "_0", value: USDC, wanted: "usdc", origin: "list" },
      { name: "_1", value: DEAD, wanted: "to", origin: "role" },
      { name: "_2", value: ALICE, wanted: "address", origin: "neutral" },
    ]);
    const plain = await composeCall(
      { target: PLAIN, targetRef: PLAIN, signature: "poke()", inputs: [], values: {} },
      env({ tokens: [] }),
    );
    expect(plain.vars).toEqual([{ name: "_0", value: PLAIN, wanted: "contract", origin: "role" }]);
  });

  it("names the addresses of the three token calls by the standard, whatever the ABI calls them", async () => {
    const weth = { target: WETH, targetRef: WETH };
    const approve = await composeCall(
      { ...weth, signature: "approve(address,uint256)", inputs: [input("guy", "address"), input("wad", "uint256")], values: { guy: DEAD, wad: "5" } },
      env(),
    );
    expect(approve.vars[1]).toEqual({ name: "_1", value: DEAD, wanted: "spender", origin: "role" });
    // No ABI: the form made the names up.
    const transferFrom = await composeCall(
      { ...weth, signature: "transferFrom(address,address,uint256)", inputs: [input("arg0", "address"), input("arg1", "address"), input("arg2", "uint256")], values: { arg0: ALICE, arg1: DEAD, arg2: "5" } },
      env(),
    );
    expect(transferFrom.vars.slice(1).map((v) => v.wanted)).toEqual(["from", "to"]);
    const transfer_ = await composeCall(
      { ...weth, signature: "transfer(address,uint256)", inputs: [input("dst", "address"), input("wad", "uint256")], values: { dst: DEAD, wad: "5" } },
      env(),
    );
    expect(transfer_.vars[1].wanted).toBe("to");
    // The same signature with other types is another function.
    const other = await composeCall(
      { ...weth, signature: "approve(address,bool)", inputs: [input("guy", "address"), input("ok", "bool")], values: { guy: DEAD, ok: "true" } },
      env(),
    );
    expect(other.vars[1].wanted).toBe("guy");
  });

  it.each(["safe", "_safe", "Safe", "SAFE_", "executor", "wallet", "dao", "governor", "timelock", "safe2", "_Executor3"])(
    "never takes a name of the executing account from a parameter: %s",
    async (parameter) => {
      // Whoever published the ABI wrote the parameter's name: it cannot
      // make an arbitrary address read as the user's own Safe or account.
      expect(wantedName(ALICE, { parameter }, env())).toBe("address");
      const composed = await composeCall(
        { target: PLAIN, targetRef: PLAIN, signature: "setUp(address)", inputs: [input(parameter, "address")], values: { [parameter]: ALICE } },
        env(),
      );
      expect(composed.vars[1]).toEqual({ name: "_1", value: ALICE, wanted: "address", origin: "neutral" });
      expect(await added("", { target: PLAIN, targetRef: PLAIN, signature: "setUp(address)", inputs: [input(parameter, "address")], values: { [parameter]: ALICE } })).toContain(
        `set $address ${ALICE}`,
      );
    },
  );

  it("does the same for approve and transferFrom", async () => {
    expect(
      (await composeCall({ ...APPROVE, target: USDC, targetRef: USDC, values: { spender: DEAD, amount: "5000000" } }, env())).line,
    ).toBe('exec $_0 "approve(address,uint256)" $_1 @token:amount($_0 5)');
    expect(
      (await composeCall({ ...APPROVE, target: USDC, targetRef: USDC, values: { spender: DEAD, amount: MAX } }, env())).line,
    ).toBe(`exec $_0 "approve(address,uint256)" $_1 ${MAX}`);
    expect(
      (await composeCall({ ...TRANSFER_FROM, target: USDC, targetRef: USDC, values: { from: ALICE, to: DEAD, amount: "1500000" } }, env())).line,
    ).toBe('exec $_0 "transferFrom(address,address,uint256)" $_1 $_2 @token:amount($_0 1.5)');
  });

  it("keeps the raw number where the target does not say its decimals", async () => {
    const decimalsOf = vi.fn(async () => undefined);
    expect(await amountOf(transfer(DEAD, "1000000", PLAIN), env({ decimalsOf }))).toBe("1000000");
    expect(decimalsOf).toHaveBeenCalledExactlyOnceWith(PLAIN);
    const failing = vi.fn(async () => {
      throw new Error("rpc down");
    });
    expect(await amountOf(transfer(DEAD, "1000000"), env({ decimalsOf: failing }))).toBe("1000000");
  });

  it("does not guess for any other function, and does not ask for decimals", async () => {
    const decimalsOf = vi.fn(async () => 6);
    const mint = await composeCall(
      { target: USDC, targetRef: USDC, signature: "mint(address,uint256)", inputs: TRANSFER.inputs, values: { to: DEAD, value: "1000000" } },
      env({ decimalsOf }),
    );
    expect(mint.line).toBe('exec $_0 "mint(address,uint256)" $_1 1000000');
    const other = await composeCall(
      { target: USDC, targetRef: USDC, signature: "transfer(address,uint256,bytes)", inputs: [...TRANSFER.inputs, input("data", "bytes")], values: { to: DEAD, value: "1000000", data: "0x" } },
      env({ decimalsOf }),
    );
    expect(other.line).toBe('exec $_0 "transfer(address,uint256,bytes)" $_1 1000000 0x');
    expect(decimalsOf).not.toHaveBeenCalled();
  });

  it("keeps the value option, and quotes strings as before", async () => {
    const composed = await composeCall(
      { target: PLAIN, targetRef: PLAIN, signature: "note(string)", inputs: [input("text", "string")], values: { text: "hi there" }, value: "1e18" },
      env(),
    );
    expect(composed.line).toBe('exec $_0 "note(string)" "hi there" --value 1e18');
  });
});

describe("a batch of composed actions", () => {
  it("shares a variable between two actions and drops it with the last one", async () => {
    const one = await added("", transfer(DEAD, "1000000"));
    const two = await added(one, transfer(DEAD, "2000000000000000000", WETH));
    expect(two.split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $to ${DEAD}`,
      `set $weth ${WETH}`,
      'exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 1)',
      'exec $weth "transfer(address,uint256)" $to @token:amount($weth 2)',
    ]);
    // The first goes: its token goes with it, the recipient stays.
    const without = removeCommand(two, 5);
    expect(without.split("\n")).toEqual([
      "load token",
      `set $to ${DEAD}`,
      `set $weth ${WETH}`,
      'exec $weth "transfer(address,uint256)" $to @token:amount($weth 2)',
    ]);
    expect(removeCommand(without, 4)).toBe("");
  });

  it("gives a changed recipient its own variable while the old one is still in use", async () => {
    const one = await added("", transfer(DEAD, "1000000"));
    const two = await added(one, transfer(DEAD, "1000000000000000000", WETH));
    // The WETH transfer is replaced by one to someone else.
    const replaced = await added(removeCommand(two, 6), transfer(ALICE, "1000000000000000000", WETH));
    expect(replaced.split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $to ${DEAD}`,
      `set $weth ${WETH}`,
      `set $to2 ${ALICE}`,
      'exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 1)',
      'exec $weth "transfer(address,uint256)" $to2 @token:amount($weth 1)',
    ]);
    // Replaced when it was the only action: the name is free again.
    const alone = await added(removeCommand(one, 4), transfer(ALICE, "1000000"));
    expect(alone.split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $to ${ALICE}`,
      'exec $usdc "transfer(address,uint256)" $to @token:amount($usdc 1)',
    ]);
  });

  it("keeps for the actions on their own what they need, and nothing a check alone used", async () => {
    const actions = await added("", transfer(DEAD, "1000000"));
    const { line, sets } = bindVariables(actions, {
      line: "assert @acl:owner!($contract) == $to",
      vars: [
        { name: "contract", value: PLAIN },
        { name: "to", value: DEAD },
      ],
    });
    const protectedScript = insertAssertionLines(actions, line, "post", sets).script;
    expect(protectedScript).toContain(`set $contract ${PLAIN}`);
    expect(protectedScript).toContain("load acl");
    expect(stripAssertions(protectedScript)).toBe(actions);
    expect(gcScaffolding(actions)).toBe(actions);
  });
});

describe("an amount typed in the token's own units", () => {
  const inTokens = (call: Parameters<typeof composeCall>[0]) =>
    composeCall({ ...call, amountIn: "token" }, env());

  it.each([
    ["1.5", 6, 1_500_000n],
    ["1", 6, 1_000_000n],
    ["0.000001", 6, 1n],
    [".5", 6, 500_000n],
    ["2.", 6, 2_000_000n],
    ["0", 6, 0n],
    ["127019.840673733935141936", 18, 127019840673733935141936n],
    ["7", 0, 7n],
  ])("reads %s with %i decimals exactly", (raw, decimals, base) => {
    expect(tokenAmount(raw, decimals)).toEqual({ base });
  });

  it("refuses more decimals than the token has, and anything that is no amount", () => {
    expect(tokenAmount("1.0000001", 6)).toEqual({ error: "At most 6 decimals." });
    expect(tokenAmount("1.5", 0)).toEqual({ error: "A whole number: this token has no decimals." });
    for (const raw of ["", " ", "abc", "1e18", "1,5", "-1", "1.2.3", "@token:amount(USDC 1)"])
      expect(tokenAmount(raw, 6), raw).toEqual({ error: "Type an amount, like 1.5." });
    expect(tokenAmount(`${2n ** 256n}`, 0)).toEqual({ error: "More than a uint256 holds." });
    // The unlimited allowance, where the call takes one.
    expect(tokenAmount("max", 6)).toEqual({ error: "Type an amount, like 1.5." });
    expect(tokenAmount("max", 6, { max: true })).toEqual({ base: 2n ** 256n - 1n });
  });

  it("shows the other unit under the field", () => {
    expect(amountHint("1.5", 6, "token")).toBe("1500000 base units");
    expect(amountHint("max", 6, "token", { max: true })).toBe("an unlimited allowance");
    expect(amountHint("1500000", 6, "base")).toBe("1.5 in token units");
    expect(amountHint("25e17", 18, "base")).toBe("2.5 in token units");
    expect(amountHint("", 6, "token")).toBeNull();
    expect(amountHint("1.0000001", 6, "token")).toBeNull();
    expect(amountHint("abc", 6, "base")).toBeNull();
  });

  it("describes the field: its unit, the other unit under it, what is wrong, and the shortcuts", () => {
    const field = (partial: Partial<Parameters<typeof amountField>[0]>) =>
      amountField({ signature: TRANSFER.signature, decimals: 6, symbol: "USDC", amountIn: "token", raw: "", ...partial });
    expect(field({ raw: "1.5" })).toEqual({
      unit: "USDC",
      hint: "= 1500000 base units",
      error: null,
      canMax: false,
      switchTo: "Type base units",
    });
    // Not in the token list: no name to show, only what the unit is.
    expect(field({ symbol: undefined, raw: "1.5" })).toMatchObject({ unit: "token units", hint: "= 1500000 base units" });
    expect(field({ raw: "1.0000001" })).toMatchObject({ hint: null, error: "At most 6 decimals." });
    expect(field({ raw: "" })).toMatchObject({ hint: null, error: null });
    expect(field({ signature: APPROVE.signature, raw: "max" })).toMatchObject({
      hint: "= an unlimited allowance",
      error: null,
      canMax: true,
    });
    expect(field({ amountIn: "base", raw: "1500000" })).toEqual({
      unit: "base units",
      hint: "= 1.5 USDC",
      error: null,
      canMax: false,
      switchTo: "Type USDC",
    });
    expect(field({ amountIn: "base", symbol: undefined, raw: "1500000" })).toMatchObject({
      hint: "= 1.5 in token units",
      switchTo: "Type token units",
    });
    // Anything typed is passed on in base units, as before: no error.
    expect(field({ amountIn: "base", raw: "@token:amount(USDC 1)" })).toMatchObject({ hint: null, error: null });
    // Not one of the three calls, or a contract that does not say its
    // decimals: the field stays as it was.
    expect(field({ signature: "mint(address,uint256)" })).toBeNull();
    expect(field({ decimals: undefined })).toBeNull();
  });

  it("writes the line exactly, like the same amount in base units", async () => {
    const typed = await inTokens({ ...APPROVE, target: USDC, targetRef: USDC, values: { spender: DEAD, amount: "5.25" } });
    const base = await composeCall({ ...APPROVE, target: USDC, targetRef: USDC, values: { spender: DEAD, amount: "5250000" } }, env());
    expect(typed).toEqual(base);
    expect(typed.line).toBe('exec $_0 "approve(address,uint256)" $_1 @token:amount($_0 5.25)');
    // Dust is dust in either unit.
    expect((await inTokens(transfer(DEAD, "0.000000000005", WETH))).line).toBe(
      `exec $_0 "transfer(address,uint256)" $_1 5000000${BASE_UNITS_COMMENT}$_0`,
    );
    expect((await inTokens({ ...APPROVE, target: USDC, targetRef: USDC, values: { spender: DEAD, amount: "max" } })).line).toBe(
      `exec $_0 "approve(address,uint256)" $_1 ${MAX}`,
    );
  });

  it("refuses to write what it could not read as an amount", async () => {
    await expect(inTokens(transfer(DEAD, "1.0000001"))).rejects.toThrow("At most 6 decimals.");
    await expect(inTokens(transfer(DEAD, "max"))).rejects.toThrow("Type an amount");
    await expect(inTokens(transfer(DEAD, "1", PLAIN))).rejects.toThrow("decimals");
  });
});

describe("an action read back into the form", () => {
  const roundTrip = async (call: Parameters<typeof composeCall>[0], script = "") => {
    const next = await added(script, call);
    return { script: next, call: decomposeCall(next, next.split("\n").length) };
  };

  it("gives back the target, the function, the arguments and the value", async () => {
    const { call } = await roundTrip({ ...transfer(DEAD, "1500000"), value: "1e18" });
    expect(call).toEqual({
      target: USDC,
      signature: "transfer(address,uint256)",
      args: [DEAD, "1.5"],
      value: "1e18",
      amountIn: "token",
    });
  });

  it("gives back base units where the line holds them, and the unlimited allowance", async () => {
    expect((await roundTrip(transfer(DEAD, "5", WETH))).call).toMatchObject({ args: [DEAD, "5"], amountIn: "base" });
    expect(
      (await roundTrip({ ...APPROVE, target: USDC, targetRef: USDC, values: { spender: DEAD, amount: MAX } })).call,
    ).toMatchObject({ args: [DEAD, MAX], amountIn: "base" });
    expect((await roundTrip(transfer(DEAD, "1000000", PLAIN), "")).call).toMatchObject({ args: [DEAD, "1000000"], amountIn: "base" });
  });

  it("gives back strings, booleans, bytes, arrays and tuples as the form takes them", async () => {
    const { call } = await roundTrip({
      target: PLAIN,
      targetRef: PLAIN,
      signature: "f(string,bool,bytes,address[],(address,uint256),uint256[])",
      inputs: [
        input("note", "string"),
        input("flag", "bool"),
        input("data", "bytes"),
        input("who", "address[]"),
        input("pair", "(address,uint256)"),
        input("none", "uint256[]"),
      ],
      values: { note: 'say "hi" # now', flag: "true", data: "0xabcd", who: `${DEAD}, ${ALICE}`, pair: `(${DEAD}, 7)`, none: "" },
    });
    expect(call).toEqual({
      target: PLAIN,
      signature: "f(string,bool,bytes,address[],(address,uint256),uint256[])",
      args: ['say "hi" # now', "true", "0xabcd", `[${DEAD}, ${ALICE}]`, `[${DEAD}, 7]`, "[]"],
      value: "",
      amountIn: "base",
    });
  });

  it("gives back the ENS name an address was given as", () => {
    const script = [
      "set $dao @ens(dao.eth)",
      "set $vitalik @ens(vitalik.eth)",
      'exec $dao "transferOwnership(address)" $vitalik',
    ].join("\n");
    expect(decomposeCall(script, 3)).toMatchObject({ target: "dao.eth", args: ["vitalik.eth"] });
  });

  it.each([
    ["a helper the form does not write", `exec ${USDC} "transfer(address,uint256)" @me 5`],
    ["an amount of another token", `set $usdc ${USDC}\nset $weth ${WETH}\nexec $usdc "transfer(address,uint256)" $weth @token:amount($weth 1)`],
    ["a variable that is no address", `set $n 5\nexec ${USDC} "transfer(address,uint256)" ${DEAD} $n`],
    ["an option the form has no field for", `exec ${USDC} "transfer(address,uint256)" ${DEAD} 5 --from ${ALICE}`],
    ["a read hop", `exec ${USDC} "transfer(address,uint256)" ${USDC}::owner() 5`],
    ["a signature that does not parse", `exec ${USDC} "transfer(address,uint)x" ${DEAD} 5`],
    ["more arguments than the function takes", `exec ${USDC} "transfer(address,uint256)" ${DEAD} 5 6`],
    ["a command that is no exec", `send ${USDC} --value 1`],
    ["a named function with no signature", `exec ${USDC} transfer ${DEAD} 5`],
  ])("gives nothing for %s: the EVML editor is where that is edited", (_name, script) => {
    expect(decomposeCall(script, script.split("\n").length)).toBeNull();
  });
});
