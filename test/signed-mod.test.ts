// Independent, full-width implementation checks for formal/signed-mod/SignedMod.dfy.
// JavaScript BigInt % follows the dividend's sign and does not wrap intermediates.
import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { encodeAbiParameters, encodeFunctionData, type Hex } from "viem";

const HALF = 1n << 255n;
const WORD = 1n << 256n;
const MIN = -HALF;
const MAX = HALF - 1n;
const SEED = Number(process.env.SIGNED_MOD_SEED ?? 20260929);
const RUNS = Number(process.env.SIGNED_MOD_RUNS ?? 1024);
assert.ok(Number.isInteger(SEED) && SEED > 0 && SEED <= 0xffffffff);
assert.ok(Number.isInteger(RUNS) && RUNS > 0);
const PANIC12 = (`0x4e487b71${"12".padStart(64, "0")}`) as Hex;
const EDGES = [MIN, MIN + 1n, -(1n << 128n), -7n, -1n, 0n, 1n, 7n, 1n << 128n, MAX - 1n, MAX];
const { viem } = await network.connect();
const client = await viem.getPublicClient();
const operators = await viem.deployContract("Operations");

type Operation = "addMod" | "mulMod";
function revertBytes(err: unknown): Hex | undefined {
  for (let e = err as Record<string, any> | undefined; e; e = e.cause) {
    for (const data of [e.data, e.data?.data, e.error?.data, e.error?.data?.data]) {
      if (typeof data === "string" && data.startsWith("0x")) return data as Hex;
    }
  }
}

async function check(op: Operation, a: bigint, b: bigint, m: bigint, caseId: string) {
  const abi = [{
    type: "function", name: op, stateMutability: "pure",
    inputs: [{ type: "int256" }, { type: "int256" }, { type: "int256" }],
    outputs: [{ type: "int256" }],
  }] as const;
  const label = `${op}(${a},${b},${m}) seed=${SEED} case=${caseId}`;
  let result: { success: true; data: Hex | undefined } | { success: false; data: Hex };
  try {
    const response = await client.call({
      to: operators.address,
      data: encodeFunctionData({ abi, functionName: op, args: [a, b, m] }),
      gas: 1_000_000n,
    });
    result = { success: true, data: response.data };
  } catch (error) {
    const data = revertBytes(error);
    if (data === undefined) throw error;
    result = { success: false, data };
  }
  if (m === 0n) {
    assert.equal(result.success, false, label);
    assert.equal(result.data, PANIC12, label);
  } else {
    const numerator = op === "addMod" ? a + b : a * b;
    const expected = numerator % m;
    assert.equal(result.success, true, label);
    assert.equal(result.data, encodeAbiParameters([{ type: "int256" }], [expected]), label);
  }
}

function randomSigned(seed: number) {
  let state = seed >>> 0;
  return () => {
    let word = 0n;
    for (let i = 0; i < 8; i++) {
      state ^= state << 13;
      state ^= state >>> 17;
      state ^= state << 5;
      word = (word << 32n) | BigInt(state >>> 0);
    }
    return word >= HALF ? word - WORD : word;
  };
}

for (const op of ["addMod", "mulMod"] as const) {
  describe(`signed ${op} proof correspondence`, () => {
    it("matches BigInt over the complete boundary Cartesian product", async () => {
      let i = 0;
      for (const a of EDGES) for (const b of EDGES) for (const m of EDGES) {
        await check(op, a, b, m, `boundary-${i++}`);
      }
    });
    it("matches BigInt for full-width generated operands", async () => {
      const next = randomSigned(SEED);
      for (let i = 0; i < RUNS; i++) {
        let a = next(), b = next(), m = next();
        if (i % 13 === 0) m = 0n;
        else if (i % 17 === 0) m = MIN;
        else if (i % 29 === 0) m = i % 2 ? -1n : 1n;
        if (i % 19 === 0) a = MIN;
        if (i % 23 === 0) b = MIN;
        await check(op, a, b, m, `random-${i}`);
      }
    });
    it("returns exact Panic(0x12) for every boundary operand pair at zero modulus", async () => {
      let i = 0;
      for (const a of EDGES) for (const b of EDGES) {
        await check(op, a, b, 0n, `zero-${i++}`);
      }
    });
  });
}
