import { describe, expect, it } from "vitest";

import { buildAssertionLine } from "../assertion-codegen";
import { type Assertion, updateAt } from "../assertion-model";
import { PRESETS, type PresetKey, seedAssertion } from "../presets";

const T = "0x1234567890123456789012345678901234567890";
const HASH = `0x${"ab".repeat(32)}`;

const render = (assertion: Assertion, chainId = 1) =>
  buildAssertionLine(assertion, { resolveEns: async () => null, chainId });

const withExpected = (a: Assertion, value: string): Assertion =>
  updateAt(a, ["expected", "value"], () => value);

describe("seedAssertion", () => {
  it("has a tile for every preset", () => {
    const keys: PresetKey[] = [
      "call",
      "balance",
      "codeHash",
      "hasCode",
      "noCode",
      "blockNumber",
      "timestamp",
      "chainId",
    ];
    expect(PRESETS.map((p) => p.key)).toEqual(keys);
  });

  it("starts the call preset incomplete", async () => {
    expect(await render(seedAssertion("call", 1))).toBeNull();
  });

  it("renders the balance line with the chain's native symbol", async () => {
    expect(await render(withExpected(seedAssertion("balance", 1), "1e18"))).toEqual({
      line: "assert @balance!(ETH @me) >= 1e18",
      sets: [],
    });
    expect(await render(withExpected(seedAssertion("balance", 100), "1e18"), 100)).toEqual({
      line: "assert @balance!(XDAI @me) >= 1e18",
      sets: [],
    });
  });

  it("renders the code presets over the address", async () => {
    const address = (a: Assertion) => updateAt(a, ["subject", "address", "value"], () => T);
    const codeAt = (a: Assertion) =>
      updateAt(a, ["subject", "call", "address", "value"], () => T);
    expect(await render(withExpected(address(seedAssertion("codeHash", 1)), HASH))).toEqual({
      line: `assert @codeHash!(${T}) == ${HASH}`,
      sets: [],
    });
    expect(await render(codeAt(seedAssertion("hasCode", 1)))).toEqual({
      line: `assert @bytes.len!(@codeAt!(${T})) > 0`,
      sets: [],
    });
    expect(await render(codeAt(seedAssertion("noCode", 1)))).toEqual({
      line: `assert @bytes.len!(@codeAt!(${T})) == 0`,
      sets: [],
    });
  });

  it("renders the block and chain presets", async () => {
    expect(await render(withExpected(seedAssertion("blockNumber", 1), "100"))).toEqual({
      line: "assert @block.number! >= 100",
      sets: [],
    });
    expect(await render(withExpected(seedAssertion("timestamp", 1), "1700000000"))).toEqual({
      line: "assert @block.timestamp! >= 1700000000",
      sets: [],
    });
    expect(await render(seedAssertion("chainId", 100), 100)).toEqual({
      line: "assert @chainId! == 100",
      sets: [],
    });
  });

  it("keeps the revert message", async () => {
    const a = { ...withExpected(seedAssertion("chainId", 1), "1"), message: "wrong chain" };
    expect((await render(a))?.line).toBe('assert @chainId! == 1 "wrong chain"');
  });
});
