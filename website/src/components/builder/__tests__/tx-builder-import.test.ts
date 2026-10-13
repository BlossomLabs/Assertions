import { BASE_UNITS_COMMENT } from "@evmcrispr/sdk";
import { describe, expect, it } from "vitest";

import type { ComposeEnv } from "../compose-call";
import { evml } from "../evml";
import { type TxBuilderBatch, importTxBuilder, txBuilderToEvml } from "../safe-tx-builder";

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const OWNED = "0x00000000000000000000000000000000000000bb";
const SAFE = "0x5Afe000000000000000000000000000000005afe";

const env: ComposeEnv = {
  chainId: 1,
  nativeSymbol: "ETH",
  tokens: [
    { symbol: "USDC", chainId: 1, address: USDC },
    { symbol: "WETH", chainId: 1, address: WETH },
  ],
  decimalsOf: async (address) => ({ [USDC]: 6, [WETH]: 18 } as Record<string, number>)[address],
  ensToVar: async () => null,
};
const method = (name: string, ...inputs: [string, string][]) => ({
  name,
  inputs: inputs.map(([n, type]) => ({ name: n, type })),
  payable: false,
});
const BATCH: TxBuilderBatch = {
  version: "1.0",
  chainId: "1",
  meta: { name: "Payroll", description: "October" },
  transactions: [
    {
      to: USDC,
      value: "0",
      contractMethod: method("transfer", ["to", "address"], ["value", "uint256"]),
      contractInputsValues: { to: DEAD, value: "1500000" },
    },
    {
      to: WETH,
      value: "0",
      contractMethod: method("approve", ["guy", "address"], ["wad", "uint256"]),
      contractInputsValues: { guy: DEAD, wad: "5" },
    },
    {
      to: OWNED,
      value: "7",
      contractMethod: method("note", ["text", "string"], ["on", "bool"]),
      contractInputsValues: { text: "hi there", on: "true" },
    },
    // An array, then what has no method to decode.
    {
      to: OWNED,
      value: "0",
      contractMethod: method("many", ["who", "address[]"]),
      contractInputsValues: { who: `["${DEAD}","${USDC}"]` },
    },
    { to: DEAD, value: "1000", data: "0x" },
    { to: OWNED, value: "0", data: "0xdeadbeef" },
  ],
};

describe("importing a Transaction Builder batch", () => {
  it("writes decodable calls as the form does: named addresses, token units, dust with its unit", async () => {
    const out = await importTxBuilder(BATCH, env, { context: [{ name: "safe", address: SAFE }] });
    expect(out.script.split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      // A recipient, then a spender: neither, and its code was not read.
      `set $address ${DEAD}`,
      `set $weth ${WETH}`,
      `set $contract ${OWNED}`,
      "# Payroll",
      "# October",
      'exec $usdc "transfer(address,uint256)" $address @token:amount($usdc 1.5)',
      `exec $weth "approve(address,uint256)" $address 5${BASE_UNITS_COMMENT}$weth`,
      'exec $contract "note(string,bool)" "hi there" true --value 7',
      // An array is read from the JSON the export holds and written as
      // an EVML array, over the same variables.
      'exec $contract "many(address[])" [$address $usdc]',
      `send ${DEAD} --value 1000`,
      `send ${OWNED} --data 0xdeadbeef`,
    ]);
    expect(out.chainId).toBe(1);
    expect(out.name).toBe("Payroll");
    // The names it gave are the builder's to give again.
    expect([...out.managed]).toEqual([
      ["address", "neutral"],
      ["contract", "role"],
    ]);
  });

  it("leaves the undecodable lines exactly as the plain conversion writes them", async () => {
    const plain = txBuilderToEvml(BATCH).script.split("\n");
    const imported = (await importTxBuilder(BATCH, env)).script.split("\n");
    expect(imported.slice(-2)).toEqual(plain.slice(-2));
    expect(plain.at(-3)).toBe(`exec ${OWNED} "many(address[])" [${DEAD} ${USDC}]`);
  });

  it("names the account by its code where that was read, and the Safe by the context", async () => {
    const batch: TxBuilderBatch = {
      chainId: "1",
      transactions: [
        BATCH.transactions[0],
        BATCH.transactions[1],
        {
          to: USDC,
          value: "0",
          contractMethod: method("transferFrom", ["from", "address"], ["to", "address"], ["value", "uint256"]),
          contractInputsValues: { from: SAFE, to: DEAD, value: "1" },
        },
      ],
    };
    const out = await importTxBuilder(batch, env, {
      context: [{ name: "safe", address: SAFE }],
      kinds: new Map([[DEAD.toLowerCase(), "contract"]]),
    });
    expect(out.script.split("\n").filter((l) => l.startsWith("set "))).toEqual([
      `set $usdc ${USDC}`,
      `set $contract ${DEAD}`,
      `set $weth ${WETH}`,
      `set $safe ${SAFE}`,
    ]);
    expect(out.script).toContain('exec $usdc "transferFrom(address,address,uint256)" $safe $contract @token:amount($usdc 0.000001)');
  });

  it("does not let a file's parameter names claim the executing account's names", async () => {
    const batch: TxBuilderBatch = {
      chainId: "1",
      transactions: ["safe", "_executor", "Wallet", "dao", "governor", "timelock"].map((name) => ({
        to: OWNED,
        value: "0",
        contractMethod: method("setUp", [name, "address"]),
        contractInputsValues: { [name]: DEAD },
      })),
    };
    for (const naming of [{}, { context: [{ name: "safe" as const, address: SAFE }] }]) {
      const out = await importTxBuilder(batch, env, naming);
      expect(out.script.split("\n").filter((l) => l.startsWith("set "))).toEqual([
        `set $contract ${OWNED}`,
        `set $address ${DEAD}`,
      ]);
      expect(out.script).not.toMatch(/\$(safe|executor|wallet|dao|governor|timelock)\b/i);
    }
  });

  it("is the plain conversion for a batch of another chain: nothing was read there", async () => {
    const other = { ...BATCH, chainId: "100" };
    const out = await importTxBuilder(other, env);
    expect(out.script).toBe(txBuilderToEvml(other).script);
    expect(out.chainId).toBe(100);
    expect(out.managed.size).toBe(0);
  });

  it("is a script the builder's tag accepts", async () => {
    const { script } = await importTxBuilder(BATCH, env);
    const { diagnostics } = await evml.with({ chainId: 1, account: SAFE }).script(script).validate();
    expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
  });
});
