// @vitest-environment jsdom
import { BASE_UNITS_COMMENT } from "@evmcrispr/sdk";
import { act, renderHook } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import type { AddressKind } from "../script-ops";
import { useScriptState } from "../useScriptState";

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const SAFE = "0x5Afe000000000000000000000000000000005afe";

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
const SPENT = {
  line: "assert @balance!($usdc $executor) >= @token:amount($usdc 5)",
  vars: [
    { name: "usdc", value: USDC },
    { name: "executor", value: SAFE },
  ],
};
const ALLOWED = {
  line: `assert @token:allowance!($weth $executor $spender) == 5${BASE_UNITS_COMMENT}$weth`,
  vars: [
    { name: "weth", value: WETH },
    { name: "executor", value: SAFE },
    { name: "spender", value: DEAD },
  ],
};

const lines = (script: string) => script.split("\n");
const setup = (kind?: AddressKind) => {
  const kindOf = vi.fn(async () => kind);
  const hook = renderHook(() => useScriptState("", { kindOf }));
  return { ...hook, kindOf, state: () => hook.result.current };
};

describe("useScriptState: names", () => {
  it("renames a recipient that becomes a spender by its code, read once", async () => {
    const { state, kindOf } = setup("account");
    await act(() => state().appendWithSets(TRANSFER.line, [], TRANSFER.vars));
    // Nothing to rename: nothing read.
    expect(kindOf).not.toHaveBeenCalled();
    await act(() => state().appendWithSets(APPROVE.line, [], APPROVE.vars));
    expect(kindOf).toHaveBeenCalledExactlyOnceWith(DEAD.toLowerCase());
    expect(lines(state().script)).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $account ${DEAD}`,
      `set $weth ${WETH}`,
      'exec $usdc "transfer(address,uint256)" $account @token:amount($usdc 1)',
      `exec $weth "approve(address,uint256)" $account 5${BASE_UNITS_COMMENT}$weth`,
    ]);
  });

  it("applies several adds in the order they were asked, each on what the one before left", async () => {
    const { state } = setup("contract");
    await act(() => state().setContext([{ name: "executor", address: SAFE }]));
    await act(async () => {
      // Not awaited one by one: "Add all" asks for them in a row.
      void state().appendWithSets(TRANSFER.line, [], TRANSFER.vars);
      void state().appendWithSets(APPROVE.line, [], APPROVE.vars);
      await state().addLine(ALLOWED.line, "post", { vars: ALLOWED.vars });
    });
    expect(lines(state().script).slice(-3)).toEqual([
      'exec $usdc "transfer(address,uint256)" $contract @token:amount($usdc 1)',
      `exec $weth "approve(address,uint256)" $contract 5${BASE_UNITS_COMMENT}$weth`,
      `assert @token:allowance!($weth $executor $contract) == 5${BASE_UNITS_COMMENT}$weth`,
    ]);
  });

  it("gives the executing account the context's name, now and when the context changes", async () => {
    const { state } = setup("contract");
    await act(() => state().setContext([{ name: "safe", address: SAFE }]));
    await act(() => state().addLine(SPENT.line, "post", { vars: SPENT.vars }));
    expect(state().script).toContain("assert @balance!($usdc $safe) >= @token:amount($usdc 5)");
    expect(state().previewLine(ALLOWED.line, ALLOWED.vars)).toEqual({
      line: `assert @token:allowance!($weth $safe $spender) == 5${BASE_UNITS_COMMENT}$weth`,
      sets: [`set $weth ${WETH}`, `set $spender ${DEAD}`],
    });
    await act(() => state().setContext([{ name: "dao", address: SAFE }]));
    expect(state().script).toContain(`set $dao ${SAFE}`);
    expect(state().script).toContain("$usdc $dao)");
    // No longer the context's account: what its code says.
    await act(() => state().setContext([]));
    expect(state().script).toContain(`set $contract ${SAFE}`);
    // With no context to say so, a suggestion's `$executor` names nothing.
    expect(state().previewLine(SPENT.line, SPENT.vars).line).toBe(
      "assert @balance!($usdc $contract) >= @token:amount($usdc 5)",
    );
  });

  it("the user's rename follows every use, is refused with a reason, and is never undone", async () => {
    const { state } = setup("account");
    await act(() => state().appendWithSets(TRANSFER.line, [], TRANSFER.vars));
    expect(state().renameVariable("to", "usdc")).toEqual({ error: "$usdc is already used." });
    expect(state().renameVariable("to", "my burn")).toEqual({
      error: "Letters and digits only, starting with a letter.",
    });
    let result: { error?: string } = {};
    act(() => {
      result = state().renameVariable("to", "burn");
    });
    expect(result).toEqual({});
    expect(state().script).toContain('"transfer(address,uint256)" $burn @token:amount($usdc 1)');
    await act(() => state().appendWithSets(APPROVE.line, [], APPROVE.vars));
    expect(state().script).toContain(`$burn 5${BASE_UNITS_COMMENT}$weth`);
    expect(state().script).not.toContain("$account");
  });

  it("replaces an action where it is", async () => {
    const { state } = setup();
    await act(() => state().setContext([{ name: "executor", address: SAFE }]));
    await act(() => state().appendWithSets(TRANSFER.line, [], TRANSFER.vars));
    await act(() => state().addLine(SPENT.line, "post", { vars: SPENT.vars }));
    const at = lines(state().script).findIndex((l) => l.startsWith("exec")) + 1;
    await act(() =>
      state().replaceLine(at, 'exec $_0 "transfer(address,uint256)" $_1 @token:amount($_0 2)', [], [
        { name: "_0", value: WETH, wanted: "weth", origin: "list" },
        { name: "_1", value: SAFE, wanted: "to", origin: "role" },
      ]),
    );
    expect(lines(state().script)).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      `set $executor ${SAFE}`,
      `set $weth ${WETH}`,
      'exec $weth "transfer(address,uint256)" $executor @token:amount($weth 2)',
      "assert @balance!($usdc $executor) >= @token:amount($usdc 5)",
    ]);
  });
});
