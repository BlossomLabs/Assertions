import { describe, expect, it } from "vitest";

import { type ComposeEnv, composeCall } from "../compose-call";
import { evml } from "../evml";
import { actionsToTxBuilderBatch } from "../safe-tx-builder";
import { bindVariables, insertAssertionLines, stripAssertions } from "../script-ops";
import { attributeFailure, humanizeLocations } from "../simulation";
import { prepareSuggestion } from "../suggested-checks";
import { timelineNodes } from "../timeline";
import { buildFinalScript } from "../wrap";

// The real tag, offline: inline signatures need no ABI fetch. Token
// amounts read `decimals()` on a chain, so the scripts here name addresses
// only; amounts are covered by compose-call.test.ts and in the browser.
const SAFE = "0x5Afe000000000000000000000000000000005afe";
const TOKEN = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const OWNED = "0x00000000000000000000000000000000000000bb";
const tag = evml.with({ chainId: 1, account: SAFE });
const env: ComposeEnv = {
  chainId: 1,
  nativeSymbol: "ETH",
  tokens: [{ symbol: "USDC", chainId: 1, address: TOKEN }],
  // No decimals read here: the amount stays a number of base units.
  decimalsOf: async () => undefined,
  ensToVar: async () => null,
};
const CALLS = [
  {
    target: TOKEN,
    targetRef: TOKEN,
    signature: "transfer(address,uint256)",
    inputs: [
      { name: "to", type: "address" },
      { name: "value", type: "uint256" },
    ],
    values: { to: DEAD, value: "1000000" },
  },
  {
    target: OWNED,
    targetRef: OWNED,
    signature: "transferOwnership(address)",
    inputs: [{ name: "newOwner", type: "address" }],
    values: { newOwner: DEAD },
  },
] as const;
/** The same two calls as the composer wrote them before: literals. */
const LITERAL = [
  `exec ${TOKEN} "transfer(address,uint256)" ${DEAD} 1000000`,
  `exec ${OWNED} "transferOwnership(address)" ${DEAD}`,
].join("\n");

async function composed(): Promise<string> {
  let script = "";
  for (const call of CALLS) {
    const { line, sets } = bindVariables(script, await composeCall(call, env));
    script = insertAssertionLines(script, line, "post", sets).script;
  }
  return script;
}
const CHECK = {
  line: "assert @acl:owner!($contract) == $owner",
  vars: [
    { name: "contract", value: OWNED as `0x${string}` },
    { name: "owner", value: DEAD as `0x${string}` },
  ],
};
const withCheck = (script: string) => {
  const { line, sets } = prepareSuggestion(script, CHECK);
  return insertAssertionLines(script, line, "post", sets).script;
};
const calls = async (script: string) =>
  actionsToTxBuilderBatch(await tag.script(script).interpret(), { chainId: 1 }).transactions.map(
    ({ to, value, data }) => ({ to, value, data }),
  );

describe("composed actions with the real tag", () => {
  it("writes the two calls over three variables", async () => {
    expect((await composed()).split("\n")).toEqual([
      `set $usdc ${TOKEN}`,
      `set $to ${DEAD}`,
      `set $contract ${OWNED}`,
      'exec $usdc "transfer(address,uint256)" $to 1000000',
      'exec $contract "transferOwnership(address)" $to',
    ]);
  });

  it("validates, and a check drawn from the run uses the same variables", async () => {
    const script = withCheck(await composed());
    expect(script.split("\n").at(-1)).toBe("assert @acl:owner!($contract) == $to");
    expect(script.split("\n").filter((l) => l.startsWith("set "))).toHaveLength(3);
    const { valid, diagnostics } = await tag.script(script).validate();
    expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
    expect(valid).toBe(true);
  });

  it("exports to the Safe Transaction Builder the calls the literal script exports", async () => {
    const fromVariables = await calls(await composed());
    expect(fromVariables).toEqual(await calls(LITERAL));
    expect(fromVariables.map((c) => c.to)).toEqual([TOKEN, OWNED]);
    // Variables are gone from what is exported: addresses and calldata.
    expect(JSON.stringify(fromVariables)).not.toContain("$");
    expect(fromVariables[0].data).toContain(DEAD.slice(2).toLowerCase());
  });

  it.each([
    [{ kind: "eoa" }, "batch ("],
    [{ kind: "safe", address: SAFE }, "safe:propose $safe ("],
    [{ kind: "governor", address: SAFE, description: "d" }, 'governor:propose $proposalId $governor "d" ('],
    [{ kind: "aragonosx", address: SAFE, plugin: "token-voting" }, "aragonosx:connect $dao ("],
  ] as const)("is valid wrapped for %o, the addresses named above the wrapper", async (context, opener) => {
    const final = buildFinalScript(withCheck(await composed()), context, 1);
    const lines = final.split("\n");
    for (const name of ["usdc", "to", "contract"])
      expect(lines.findIndex((l) => l.startsWith(`set $${name} `))).toBeLessThan(
        lines.indexOf(opener),
      );
    expect(final).toContain('  exec $usdc "transfer(address,uint256)" $to 1000000');
    const { valid, diagnostics } = await tag.script(final).validate();
    expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
    expect(valid).toBe(true);
  });

  it("simulates the actions on their own with the variables they need, and only those", async () => {
    const actions = await composed();
    const stripped = stripAssertions(withCheck(actions));
    expect(stripped).toBe(actions);
    const { valid } = await tag.script(stripped).validate();
    expect(valid).toBe(true);
  });

  it("counts two actions and one check, whatever is set above them", async () => {
    expect(timelineNodes(withCheck(await composed())).map((n) => [n.kind, n.lane])).toEqual([
      ["action", "actions"],
      ["action", "actions"],
      ["check", "post"],
    ]);
  });

  it("attributes a failure to the command at that line, past the set lines", async () => {
    const script = withCheck(await composed());
    // The check brought `load acl` to the top: the second exec is line 6
    // of the script, and the simulation's prelude adds two lines.
    expect(script.split("\n")[5]).toBe('exec $contract "transferOwnership(address)" $to');
    expect(attributeFailure("exec(8:0,8:20): reverted", script)).toEqual({
      kind: "action",
      line: 6,
      text: 'exec $contract "transferOwnership(address)" $to',
    });
    expect(attributeFailure("assert(9:0,9:10): no", script)?.kind).toBe("assertion");
    expect(humanizeLocations("exec(8:0,8:14): reverted", script)).toBe(
      "Error on line 6: `exec $contract`\n> reverted",
    );
  });

  it("leaves a script written with literal addresses as it is: valid, and the same calls", async () => {
    const { valid } = await tag.script(LITERAL).validate();
    expect(valid).toBe(true);
    expect(stripAssertions(LITERAL)).toBe(LITERAL);
    // A check added to it names its own addresses and leaves the lines alone.
    const script = withCheck(LITERAL);
    expect(script.split("\n")).toEqual([
      "load acl",
      `set $contract ${OWNED}`,
      `set $owner ${DEAD}`,
      ...LITERAL.split("\n"),
      CHECK.line,
    ]);
  });
});
