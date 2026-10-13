import { describe, expect, it } from "vitest";

import { type ExecutionContext, contextVariables } from "../context";
import { evml } from "../evml";
import { buildFinalScript } from "../wrap";

const SAFE = "0x5Afe000000000000000000000000000000005afe";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const TIMELOCK = "0x00000000000000000000000000000000000071fe";
const WALLET = "0x00000000000000000000000000000000000a11e7";
const tag = evml.with({ chainId: 1, account: SAFE });

const ACTION = 'exec $usdc "transfer(address,uint256)" $to 5';
const block = (executor: string) =>
  [`set $usdc ${USDC}`, `set $to ${DEAD}`, `set $${executor} ${SAFE}`, ACTION, `assert $usdc::!{balanceOf(address)(uint256) $${executor}} >= 1`].join("\n");
const PLAIN = [`set $usdc ${USDC}`, `set $to ${DEAD}`, ACTION].join("\n");

const valid = async (script: string) => {
  const { valid, diagnostics } = await tag.script(script).validate();
  expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
  expect(valid).toBe(true);
};

describe("the wrapper names the account the user said executes", () => {
  it.each([
    [{ kind: "safe", address: SAFE }, "safe", "load safe", "safe:propose $safe ("],
    [{ kind: "governor", address: SAFE, description: "d" }, "governor", "load governor", 'governor:propose $proposalId $governor "d" ('],
    [{ kind: "aragonosx", address: SAFE, plugin: "token-voting" }, "dao", "load aragonosx", "aragonosx:connect $dao ("],
  ] as const)("%o: a variable of its own when the batch does not name the account", async (context, name, load, opener) => {
    const final = buildFinalScript(PLAIN, context, 1);
    expect(final.split("\n\n")[0].split("\n")).toEqual([
      load,
      `set $${name} ${SAFE}`,
      `set $usdc ${USDC}`,
      `set $to ${DEAD}`,
    ]);
    expect(final.split("\n")).toContain(opener);
    expect(final).not.toContain(` ${SAFE} (`);
    await valid(final);
  });

  it.each([
    [{ kind: "safe", address: SAFE }, "safe", "safe:propose $safe ("],
    [{ kind: "governor", address: SAFE, description: "d" }, "governor", 'governor:propose $proposalId $governor "d" ('],
    [{ kind: "aragonosx", address: SAFE, plugin: "token-voting" }, "dao", "aragonosx:connect $dao ("],
    // A name the user gave the account is the wrapper's too.
    [{ kind: "safe", address: SAFE.toLowerCase() }, "treasury", "safe:propose $treasury ("],
  ] as const)("%o: the batch's own variable for it, set once", async (context, name, opener) => {
    const final = buildFinalScript(block(name), context, 1);
    const lines = final.split("\n");
    expect(lines.filter((l) => l.trim().startsWith(`set $${name} `))).toEqual([`set $${name} ${SAFE}`]);
    expect(lines.indexOf(`set $${name} ${SAFE}`)).toBeLessThan(lines.indexOf(opener));
    expect(final).toContain(`$usdc::!{balanceOf(address)(uint256) $${name}} >= 1`);
    await valid(final);
  });

  it("takes the next free name when the batch uses the name for something else", async () => {
    const other = [`set $safe ${DEAD}`, 'exec $safe "poke()"'].join("\n");
    const final = buildFinalScript(other, { kind: "safe", address: SAFE }, 1);
    expect(final).toContain(`set $safe2 ${SAFE}`);
    expect(final).toContain("safe:propose $safe2 (");
    await valid(final);
  });

  it("a Governor that executes through a timelock: the wrapper is the Governor, the account in the checks the timelock", async () => {
    const script = [
      `set $usdc ${USDC}`,
      `set $to ${DEAD}`,
      `set $timelock ${TIMELOCK}`,
      ACTION,
      "assert $usdc::!{balanceOf(address)(uint256) $timelock} >= 1",
    ].join("\n");
    const final = buildFinalScript(script, { kind: "governor", address: SAFE, description: "d" }, 1);
    expect(final).toContain(`set $governor ${SAFE}`);
    expect(final).toContain(`set $timelock ${TIMELOCK}`);
    expect(final).toContain('governor:propose $proposalId $governor "d" (');
    await valid(final);
  });

  it("binds the proposal's id first, so that the Governor's variable is not taken for that one", async () => {
    const context = { kind: "governor", address: SAFE, description: "d" } as const;
    expect(buildFinalScript(PLAIN, context, 1)).toContain('governor:propose $proposalId $governor "d" (');
    // A name the batch already uses is left to it.
    const used = `set $proposalId ${DEAD}\nexec $proposalId "poke()"`;
    const final = buildFinalScript(used, context, 1);
    expect(final).toContain('governor:propose $proposalId2 $governor "d" (');
    await valid(final);
    // The same for a Governor given by its ENS name.
    expect(buildFinalScript(PLAIN, { kind: "governor", address: "gov.eth" }, 1)).toContain(
      'governor:propose $proposalId $gov "Proposal built with assertions.eth" (',
    );
  });

  it("a wallet batch names no account of its own, and an ENS name keeps its lookup", async () => {
    expect(buildFinalScript(PLAIN, { kind: "eoa" }, 1)).not.toContain("$executor");
    expect(buildFinalScript(PLAIN, { kind: "eoa", address: WALLET }, 1)).not.toContain(WALLET);
    const walletBlock = block("wallet").replaceAll(SAFE, WALLET);
    const asWallet = buildFinalScript(walletBlock, { kind: "eoa", address: WALLET }, 1);
    expect(asWallet).toContain(`set $wallet ${WALLET}`);
    await valid(asWallet);
    const named = buildFinalScript(PLAIN, { kind: "safe", address: "dao.eth" }, 1);
    expect(named).toContain("set $dao @ens(dao.eth)");
    expect(named).toContain("safe:propose $dao (");
  });
});

describe("contextVariables", () => {
  const of = (context: ExecutionContext, timelock: string | null = null, wallet: "connected" | "none" = "connected") =>
    contextVariables(context, {
      connected: wallet === "connected" ? WALLET : undefined,
      resolved: context.address ? SAFE : null,
      timelock,
    });

  it("names the account by what the user said it is", () => {
    expect(of({ kind: "safe", address: SAFE })).toEqual([{ name: "safe", address: SAFE }]);
    expect(of({ kind: "aragonosx", address: SAFE, plugin: "p" })).toEqual([{ name: "dao", address: SAFE }]);
    expect(of({ kind: "governor", address: SAFE })).toEqual([{ name: "governor", address: SAFE }]);
    expect(of({ kind: "governor", address: SAFE }, TIMELOCK)).toEqual([
      { name: "governor", address: SAFE },
      { name: "timelock", address: TIMELOCK },
    ]);
    // The zero address is no timelock, and a Governor that is its own is one account.
    expect(of({ kind: "governor", address: SAFE }, `0x${"0".repeat(40)}`)).toHaveLength(1);
    expect(of({ kind: "governor", address: SAFE }, SAFE)).toEqual([{ name: "governor", address: SAFE }]);
  });

  it("a wallet is $executor, and $wallet when the user typed which", () => {
    expect(of({ kind: "eoa" })).toEqual([{ name: "executor", address: WALLET }]);
    expect(of({ kind: "eoa", address: SAFE })).toEqual([{ name: "wallet", address: SAFE }]);
    expect(of({ kind: "eoa" }, null, "none")).toEqual([]);
    // Nothing resolved yet: nothing to name.
    expect(contextVariables({ kind: "safe", address: "dao.eth" }, { connected: WALLET, resolved: null, timelock: null })).toEqual([]);
  });
});
