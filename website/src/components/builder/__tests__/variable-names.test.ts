import { BASE_UNITS_COMMENT } from "@evmcrispr/sdk";
import { describe, expect, it } from "vitest";

import {
  type ContextVariable,
  type Naming,
  bindVariables,
  gcScaffolding,
  insertAssertionLines,
  nameContext,
  removeCommand,
  renameVariable,
  replaceCommand,
  isAccountName,
  userRename,
  withoutComment,
} from "../script-ops";
import { buildFinalScript } from "../wrap";

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const SAFE = "0x5Afe000000000000000000000000000000005afe";
const GOV = "0x00000000000000000000000000000000000090ff";
const TIMELOCK = "0x00000000000000000000000000000000000071fe";

const TRANSFER = {
  line: 'exec $_0 "transfer(address,uint256)" $_1 @token:amount($_0 1)',
  vars: [
    { name: "_0", value: USDC, wanted: "usdc", origin: "list" as const },
    { name: "_1", value: DEAD, wanted: "to", origin: "role" as const },
  ],
};
const APPROVE = {
  line: `exec $_0 "approve(address,uint256)" $_1 5${BASE_UNITS_COMMENT}$_0`,
  vars: [
    { name: "_0", value: WETH, wanted: "weth", origin: "list" as const },
    { name: "_1", value: DEAD, wanted: "spender", origin: "role" as const },
  ],
};

/** Adds lines the way the builder does, carrying what it knows of names. */
function batch(naming: Naming = {}) {
  let script = "";
  let managed = new Map(naming.managed ?? []);
  return {
    add(entry: Parameters<typeof bindVariables>[1], placement: "pre" | "post" = "post") {
      const bound = bindVariables(script, entry, { ...naming, managed });
      managed = bound.managed;
      script = insertAssertionLines(bound.script, bound.line, placement, bound.sets).script;
      return script.split("\n");
    },
    get script() {
      return script;
    },
    set script(next: string) {
      script = next;
    },
    get managed() {
      return managed;
    },
    set managed(next) {
      managed = next;
    },
  };
}

describe("a comment at the end of a line", () => {
  it("is not part of what the line says, and a # in quotes is no comment", () => {
    expect(withoutComment("assert $a == 5  # base units of $weth")).toBe("assert $a == 5");
    expect(withoutComment('exec $a "note(string)" "a # b"  # said')).toBe('exec $a "note(string)" "a # b"');
    expect(withoutComment("assert $a == 5")).toBe("assert $a == 5");
    expect(withoutComment("# only a comment")).toBe("");
  });

  it("does not keep a variable alive: only the line itself uses one", () => {
    const script = [
      `set $weth ${WETH}`,
      `set $to ${DEAD}`,
      "assert $to::!{paused()(bool)} == false  # nothing of $weth here",
    ].join("\n");
    expect(gcScaffolding(script).split("\n")).toEqual([
      `set $to ${DEAD}`,
      "assert $to::!{paused()(bool)} == false  # nothing of $weth here",
    ]);
  });
});

describe("renaming a variable", () => {
  const script = [
    `set $weth ${WETH}`,
    `set $wethVault ${DEAD}`,
    'exec $weth "note(string)" "pay $weth now"',
    `assert @token:allowance!($weth $wethVault $wethVault) == 5${BASE_UNITS_COMMENT}$weth`,
  ].join("\n");

  it("follows every use, the comment's included, and leaves strings and longer names alone", () => {
    expect(renameVariable(script, "weth", "wrapped").split("\n")).toEqual([
      `set $wrapped ${WETH}`,
      `set $wethVault ${DEAD}`,
      'exec $wrapped "note(string)" "pay $weth now"',
      `assert @token:allowance!($wrapped $wethVault $wethVault) == 5${BASE_UNITS_COMMENT}$wrapped`,
    ]);
  });

  it("the user's rename is refused with a short reason when the name is no name or is taken", () => {
    expect(userRename(script, "weth", "wrapped")).toEqual({
      script: renameVariable(script, "weth", "wrapped"),
    });
    expect(userRename(script, "weth", "weth")).toEqual({ script });
    expect(userRename(script, "weth", "")).toEqual({ error: "Type a name." });
    for (const bad of ["2pac", "my var", "a-b", "$x", "std:x"])
      expect(userRename(script, "weth", bad), bad).toEqual({
        error: "Letters and digits only, starting with a letter.",
      });
    expect(userRename(script, "weth", "wethVault")).toEqual({
      error: "$wethVault is already used.",
    });
    expect(userRename(script, "nope", "x")).toEqual({ error: "No such variable." });
  });
});

describe("one variable per address, named for what is known", () => {
  it("a recipient that becomes a spender is neither: an account or a contract by its code", () => {
    for (const [kind, name] of [
      ["account", "account"],
      ["contract", "contract"],
      [undefined, "address"],
    ] as const) {
      const b = batch({ kinds: new Map(kind ? [[DEAD.toLowerCase(), kind]] : []) });
      b.add(TRANSFER);
      expect(b.add(APPROVE)).toEqual([
        "load token",
        `set $usdc ${USDC}`,
        `set $${name} ${DEAD}`,
        `set $weth ${WETH}`,
        `exec $usdc "transfer(address,uint256)" $${name} @token:amount($usdc 1)`,
        `exec $weth "approve(address,uint256)" $${name} 5${BASE_UNITS_COMMENT}$weth`,
      ]);
      // Neutral now: a third role changes nothing.
      const again = b.add({
        line: "assert $_0::!{paused()(bool)} == false",
        vars: [{ name: "_0", value: DEAD, wanted: "contract", origin: "role" }],
      });
      expect(again.at(-1)).toBe(`assert $${name}::!{paused()(bool)} == false`);
    }
  });

  it("a contract the form called, then named as a token by a check, stays $contract: that is what its code says", () => {
    const b = batch({ kinds: new Map([[USDC.toLowerCase(), "contract"]]) });
    b.add({
      line: 'exec $_0 "poke()"',
      vars: [{ name: "_0", value: USDC, wanted: "contract", origin: "role" }],
    });
    const lines = b.add({
      line: "assert $token::!{paused()(bool)} == false",
      vars: [{ name: "token", value: USDC }],
    });
    expect(lines).toEqual([
      `set $contract ${USDC}`,
      'exec $contract "poke()"',
      "assert $contract::!{paused()(bool)} == false",
    ]);
    expect(b.managed.get("contract")).toBe("neutral");
  });

  it("keeps the role while every use agrees on it, numbers aside, and a recipient is a `to`", () => {
    const b = batch();
    b.add(TRANSFER);
    b.add({ ...TRANSFER, vars: [TRANSFER.vars[0], { ...TRANSFER.vars[1], wanted: "to" }] });
    const lines = b.add({
      line: "assert @balance!($usdc $recipient) >= @token:amount($usdc 1)",
      vars: [
        { name: "usdc", value: USDC },
        { name: "recipient", value: DEAD },
      ],
    });
    expect(lines.filter((l) => l.startsWith("set "))).toEqual([`set $usdc ${USDC}`, `set $to ${DEAD}`]);
    expect(lines.at(-1)).toBe("assert @balance!($usdc $to) >= @token:amount($usdc 1)");
  });

  it("a use that says nothing of the role is not that role either: the name would be read into it", () => {
    for (const use of [
      // A suggestion that names it neutrally: its run gave it two roles.
      { name: "account", value: DEAD },
      // An argument whose parameter has no name.
      { name: "_0", value: DEAD, wanted: "address", origin: "neutral" as const },
    ]) {
      const b = batch({ kinds: new Map([[DEAD.toLowerCase(), "contract"]]) });
      b.add(TRANSFER);
      const lines = b.add({ line: `assert $${use.name}::!{paused()(bool)} == false`, vars: [use] });
      expect(lines.at(-1)).toBe("assert $contract::!{paused()(bool)} == false");
      expect(lines).toContain('exec $usdc "transfer(address,uint256)" $contract @token:amount($usdc 1)');
    }
  });

  it("never replaces a token-list name, a name the user typed, or one the user gave", () => {
    const spendUsdc = {
      line: "assert $_0::!{paused()(bool)} == false",
      vars: [{ name: "_0", value: USDC, wanted: "spender", origin: "role" as const }],
    };
    const b = batch();
    b.add(TRANSFER);
    expect(b.add(spendUsdc).at(-1)).toBe("assert $usdc::!{paused()(bool)} == false");

    // Typed in the editor: the builder never gave it, so it is the user's.
    const typed = bindVariables(`set $treasury ${DEAD}\nexec $treasury "poke()"`, APPROVE, {});
    expect(typed.line).toContain("$treasury 5");
    expect(typed.script).toContain(`set $treasury ${DEAD}`);

    // Renamed by the user: the user's from then on.
    const c = batch();
    c.add(TRANSFER);
    const renamed = userRename(c.script, "to", "burn");
    if ("error" in renamed) throw new Error(renamed.error);
    c.script = renamed.script;
    c.managed = new Map([...c.managed].filter(([name]) => name !== "to"));
    expect(c.add(APPROVE).at(-1)).toBe(
      `exec $weth "approve(address,uint256)" $burn 5${BASE_UNITS_COMMENT}$weth`,
    );
  });

  it("without anything known of its names, a script is bound as before", () => {
    const bound = bindVariables(`set $to ${DEAD}\nexec $to "poke()"`, APPROVE);
    expect(bound.script).toBe(`set $to ${DEAD}\nexec $to "poke()"`);
    expect(bound.line).toBe(`exec $weth "approve(address,uint256)" $to 5${BASE_UNITS_COMMENT}$weth`);
    expect(bound.sets).toEqual([`set $weth ${WETH}`]);
  });
});

describe("the executing account has the name the user gave it", () => {
  const safe: ContextVariable[] = [{ name: "safe", address: SAFE }];
  const SPENT = {
    line: "assert @balance!($usdc $executor) >= @token:amount($usdc 5)",
    vars: [
      { name: "usdc", value: USDC },
      { name: "executor", value: SAFE },
    ],
  };

  it("a check that arrives naming it $executor, and an action that names it, use the context's name", () => {
    const b = batch({ context: safe });
    b.add({
      line: 'exec $_0 "transferFrom(address,address,uint256)" $_1 $_2 5',
      vars: [
        { name: "_0", value: USDC, wanted: "usdc", origin: "list" },
        { name: "_1", value: SAFE, wanted: "from", origin: "role" },
        { name: "_2", value: DEAD, wanted: "to", origin: "role" },
      ],
    });
    expect(b.add(SPENT)).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $safe ${SAFE}`,
      `set $to ${DEAD}`,
      'exec $usdc "transferFrom(address,address,uint256)" $safe $to 5',
      "assert @balance!($usdc $safe) >= @token:amount($usdc 5)",
    ]);
  });

  it("changing the context renames the variable everywhere, and clearing it leaves a neutral name", () => {
    const b = batch({ context: [{ name: "executor", address: SAFE }] });
    b.add(SPENT);
    expect(b.script).toContain("$usdc $executor)");
    const named = (context: ContextVariable[], kinds: Naming["kinds"] = new Map()) => {
      const out = nameContext(b.script, { context, managed: b.managed, kinds });
      b.script = out.script;
      b.managed = out.managed;
      return out.script.split("\n").filter((l) => !l.startsWith("load "));
    };
    expect(named(safe)).toEqual([
      `set $usdc ${USDC}`,
      `set $safe ${SAFE}`,
      "assert @balance!($usdc $safe) >= @token:amount($usdc 5)",
    ]);
    expect(named([{ name: "dao", address: SAFE }])[1]).toBe(`set $dao ${SAFE}`);
    // A Governor with a timelock: the account that runs is the timelock.
    expect(
      named([
        { name: "governor", address: GOV },
        { name: "timelock", address: SAFE },
      ])[1],
    ).toBe(`set $timelock ${SAFE}`);
    // The context is another account now: this one is what its code says.
    expect(named([{ name: "safe", address: GOV }], new Map([[SAFE.toLowerCase(), "contract"]]))).toEqual([
      `set $usdc ${USDC}`,
      `set $contract ${SAFE}`,
      "assert @balance!($usdc $contract) >= @token:amount($usdc 5)",
    ]);
    // And back, from a neutral name.
    expect(named(safe)[1]).toBe(`set $safe ${SAFE}`);
    expect(named([])[1]).toBe(`set $address ${SAFE}`);
  });

  it("swaps two context names without one taking the other's", () => {
    const script = [`set $governor ${GOV}`, `set $timelock ${TIMELOCK}`, "assert $governor::!{a()(address)} == $timelock"].join("\n");
    const managed = new Map([
      ["governor", "context"],
      ["timelock", "context"],
    ] as const);
    const out = nameContext(script, {
      managed,
      context: [
        { name: "governor", address: TIMELOCK },
        { name: "timelock", address: GOV },
      ],
    });
    expect(out.script.split("\n")).toEqual([
      `set $timelock ${GOV}`,
      `set $governor ${TIMELOCK}`,
      "assert $timelock::!{a()(address)} == $governor",
    ]);
  });

  it("leaves a name the user gave the account, and a script that does not name it", () => {
    const typed = `set $treasury ${SAFE}\nexec $treasury "poke()"`;
    expect(nameContext(typed, { context: safe }).script).toBe(typed);
    const none = `set $to ${DEAD}\nexec $to "poke()"`;
    expect(nameContext(none, { context: safe, managed: new Map([["to", "role"]]) }).script).toBe(none);
  });

  it("a name the context wants that the user already uses gets a number", () => {
    const b = batch({ context: safe });
    b.script = `set $safe ${DEAD}\nexec $safe "poke()"`;
    expect(b.add(SPENT).filter((l) => l.startsWith("set "))).toEqual([
      `set $safe ${DEAD}`,
      `set $usdc ${USDC}`,
      `set $safe2 ${SAFE}`,
    ]);
  });
});

describe("replacing an action in place", () => {
  const b = batch();
  b.add(TRANSFER);
  b.add(APPROVE);
  b.add({ line: "assert $_0::!{paused()(bool)} == false", vars: [{ name: "_0", value: USDC, wanted: "usdc", origin: "list" }] });
  const script = b.script;

  it("keeps its position, adds what the new line needs and drops what only the old one used", () => {
    const lines = script.split("\n");
    const at = lines.findIndex((l) => l.includes("approve")) + 1;
    const next = replaceCommand(script, at, 'exec $usdc "approve(address,uint256)" $burn @token:amount($usdc 2)', [
      `set $burn ${GOV}`,
    ]);
    expect(next.split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $address ${DEAD}`,
      `set $burn ${GOV}`,
      'exec $usdc "transfer(address,uint256)" $address @token:amount($usdc 1)',
      'exec $usdc "approve(address,uint256)" $burn @token:amount($usdc 2)',
      "assert $usdc::!{paused()(bool)} == false",
    ]);
    // Removing it instead drops the same things.
    expect(removeCommand(script, at).split("\n")).not.toContain(`set $weth ${WETH}`);
  });

  it("does nothing for a line that is no command", () => {
    expect(replaceCommand(script, 99, "exec $usdc \"poke()\"", [])).toBe(script);
  });
});

describe("the names of the executing account come from the context alone", () => {
  const safe: ContextVariable[] = [{ name: "safe", address: SAFE }];

  it("knows them whatever their case, underscores or number", () => {
    for (const name of ["safe", "Safe", "_safe", "safe_", "SAFE2", "governor", "timelock", "dao", "wallet", "executor", "_Executor3"])
      expect(isAccountName(name), name).toBe(true);
    for (const name of ["safes", "to", "owner", "guard", "module", "admin", "account", "contract", "usdc"])
      expect(isAccountName(name), name).toBe(false);
  });

  it.each(["safe", "Safe", "_safe", "executor", "wallet", "dao", "governor", "timelock"])(
    "a line that asks for %s for an address the context does not name gets a neutral one, whoever asks",
    (name) => {
      for (const naming of [{}, { context: safe }, { context: [] }, { kinds: new Map([[DEAD.toLowerCase(), "contract" as const]]) }]) {
        // As a wanted name (a parameter), with any origin claimed, and as
        // the variable's own name (a suggestion).
        for (const use of [
          { name: "_0", value: DEAD, wanted: name, origin: "role" as const },
          { name: "_0", value: DEAD, wanted: name, origin: "context" as const },
          { name: "_0", value: DEAD, wanted: name, origin: "list" as const },
          { name: name.replace(/^_/, ""), value: DEAD },
        ]) {
          const bound = bindVariables("", { line: `exec $${use.name} "poke()"`, vars: [use] }, naming);
          const neutral = naming.kinds ? "contract" : "address";
          expect(bound.sets).toEqual([`set $${neutral} ${DEAD}`]);
          expect(bound.line).toBe(`exec $${neutral} "poke()"`);
          expect(bound.managed.get(neutral)).toBe("neutral");
        }
      }
    },
  );

  it("the context still gives its account its name, and a suggestion's $executor follows it", () => {
    const bound = bindVariables(
      "",
      { line: "assert $executor::!{nonce()(uint256)} == 1", vars: [{ name: "executor", value: SAFE }] },
      { context: safe },
    );
    expect(bound.sets).toEqual([`set $safe ${SAFE}`]);
    const wallet = bindVariables(
      "",
      { line: "assert $executor::!{nonce()(uint256)} == 1", vars: [{ name: "executor", value: SAFE }] },
      { context: [{ name: "executor", address: SAFE }] },
    );
    expect(wallet.sets).toEqual([`set $executor ${SAFE}`]);
  });

  it("a name the user gave is the user's: the context's account takes a number, and nothing is pointed elsewhere", () => {
    // The user called some other address $safe, by hand.
    const b = batch({ context: [] });
    b.add({ line: 'exec $_0 "poke()"', vars: [{ name: "_0", value: DEAD, wanted: "to", origin: "role" }] });
    const renamed = userRename(b.script, "to", "safe");
    if ("error" in renamed) throw new Error(renamed.error);
    const managed = new Map([...b.managed].filter(([name]) => name !== "to"));
    expect(renamed.script).toBe(`set $safe ${DEAD}\nexec $safe "poke()"`);
    // Now the context says which account is the Safe.
    const named = nameContext(renamed.script, { context: safe, managed });
    expect(named.script).toBe(renamed.script);
    const bound = bindVariables(
      named.script,
      { line: "assert $executor::!{nonce()(uint256)} == 1", vars: [{ name: "executor", value: SAFE }] },
      { context: safe, managed: named.managed },
    );
    expect(bound.script).toBe(renamed.script);
    expect(bound.sets).toEqual([`set $safe2 ${SAFE}`]);
    expect(bound.line).toBe("assert $safe2::!{nonce()(uint256)} == 1");
    // The wrapper proposes to the context's Safe, under that numbered name.
    const final = buildFinalScript(renamed.script, { kind: "safe", address: SAFE }, 1);
    expect(final).toContain(`set $safe2 ${SAFE}`);
    expect(final).toContain("safe:propose $safe2 (");
    expect(final).toContain(`set $safe ${DEAD}`);
  });
});
