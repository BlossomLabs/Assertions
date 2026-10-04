import { describe, expect, it } from "vitest";

import {
  contextReady,
  executorAddress,
  senderMismatch,
  simulationSender,
} from "../context";

const GOVERNOR = "0x000000000000000000000000000000000000aaaa";
const TIMELOCK = "0x000000000000000000000000000000000000bbbb";
const ZERO = "0x0000000000000000000000000000000000000000";

describe("simulationSender", () => {
  it("simulates from the timelock when the governor has one", () => {
    expect(simulationSender(GOVERNOR, TIMELOCK)).toBe(TIMELOCK);
  });

  it("falls back to the executor without a timelock", () => {
    expect(simulationSender(GOVERNOR, null)).toBe(GOVERNOR);
    expect(simulationSender(GOVERNOR, undefined)).toBe(GOVERNOR);
  });

  it("treats the zero address as no timelock", () => {
    expect(simulationSender(GOVERNOR, ZERO)).toBe(GOVERNOR);
  });

  it("stays undefined while the executor is unresolved", () => {
    expect(simulationSender(undefined, null)).toBeUndefined();
  });
});

describe("a wallet as executor", () => {
  const WALLET = "0x000000000000000000000000000000000000cccc";
  const OTHER = "0x000000000000000000000000000000000000dddd";

  it("runs as the connected wallet when no account is impersonated", () => {
    expect(executorAddress({ kind: "eoa" }, WALLET, null)).toBe(WALLET);
    expect(contextReady({ kind: "eoa" }, WALLET, null)).toBe(true);
    expect(contextReady({ kind: "eoa" }, undefined, null)).toBe(false);
  });

  it("runs as the impersonated account, connected or not", () => {
    const context = { kind: "eoa", address: OTHER } as const;
    expect(executorAddress(context, undefined, OTHER)).toBe(OTHER);
    expect(executorAddress(context, WALLET, OTHER)).toBe(OTHER);
    expect(contextReady(context, undefined, OTHER)).toBe(true);
  });

  it("is not ready while the impersonated account is unresolved", () => {
    const context = { kind: "eoa", address: "vitalik.eth" } as const;
    expect(executorAddress(context, WALLET, null)).toBeUndefined();
    expect(contextReady(context, WALLET, null)).toBe(false);
  });

  it("can only be sent by the account it was built for", () => {
    const context = { kind: "eoa", address: OTHER } as const;
    expect(senderMismatch(context, WALLET, OTHER)).toBe(true);
    expect(senderMismatch(context, OTHER.toUpperCase().replace("0X", "0x") as typeof OTHER, OTHER)).toBe(false);
    expect(senderMismatch(context, undefined, OTHER)).toBe(false);
    expect(senderMismatch({ kind: "eoa" }, WALLET, null)).toBe(false);
    expect(senderMismatch({ kind: "safe", address: OTHER }, WALLET, OTHER)).toBe(false);
  });
});
