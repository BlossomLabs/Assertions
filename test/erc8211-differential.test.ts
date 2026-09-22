// Compare canonical predicate acceptance with a pinned, deployed Biconomy
// runtime. The fixture is independent of this implementation and runs offline.
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { encodeAbiParameters, encodeFunctionData, encodePacked, keccak256, toHex, zeroAddress, type Hex } from "viem";

const reference = JSON.parse(readFileSync(new URL("./fixtures/biconomy-erc8211.json", import.meta.url), "utf8"));
const { viem, provider } = await network.connect();
assert.equal(keccak256(reference.bytecode), reference.runtimeHash);
await provider.request({ method: "hardhat_setCode", params: [reference.address, reference.bytecode] });
const core = await viem.deployContract("Assertions");
const host = await viem.deployContract("ERC8211ReferenceHarness");
const word = (x: bigint | number): Hex => toHex(BigInt.asUintN(256, BigInt(x)), { size: 32 });
const words = (...xs: (bigint | number)[]): Hex => `0x${xs.map(x => word(x).slice(2)).join("")}`;
const c = (constraintType: number, referenceData: Hex = "0x") => ({ constraintType, referenceData });
const scalar = (type: number, n: bigint | number) => c(type, word(n));
const range = (type: number, a: bigint | number, b: bigint | number) => c(type, words(a, b));
const or = (cs: ReturnType<typeof c>[]) => c(6, encodeAbiParameters([{ type: "tuple[]", components: [{ name: "constraintType", type: "uint8" }, { name: "referenceData", type: "bytes" }] }], [cs]));
const param = (paramData: Hex, constraints: ReturnType<typeof c>[], fetcherType = 0) => ({ paramType: 2, fetcherType, paramData, constraints });

async function accepts(to: string, data: Hex): Promise<boolean> {
  try {
    await provider.request({ method: "eth_call", params: [{ to, data }, "latest"] });
    return true;
  } catch (error) {
    // A broken RPC/test harness is not a rejected predicate.
    assert.match(String(error), /revert/i);
    return false;
  }
}
async function compare(p: ReturnType<typeof param>, label: string, expected?: boolean) {
  const ours = await accepts(core.address, encodeFunctionData({ abi: core.abi, functionName: "assertParam", args: [p] }));
  const theirs = await accepts(host.address, encodeFunctionData({ abi: host.abi, functionName: "judge", args: [p] }));
  assert.equal(ours, theirs, label);
  if (expected !== undefined) assert.equal(ours, expected, label);
}

describe("ERC-8211 positional constraint compatibility", () => {
  it("matches deployed Biconomy on boundaries for every leaf kind", async () => {
    const values = [0n, 1n, 42n, (1n << 255n) - 1n, 1n << 255n, (1n << 256n) - 1n];
    for (const value of values) {
      for (const ref of values) {
        for (const type of [0, 1, 2, 4, 5]) {
          await compare(param(word(value), [scalar(type, ref)]), `leaf ${type}: ${value}, ${ref}`);
        }
        for (const type of [3, 8]) {
          await compare(param(word(value), [range(type, ref, value)]), `range ${type}: ${value}, ${ref}`);
        }
      }
      await compare(param(word(value), [c(7)]), "SKIP", true);
      await compare(param(word(value), [or([scalar(0, 0), scalar(4, -1)])]), `OR ${value}`);
    }
  });

  it("checks distinct words and rejects missing complete words before predicates", async () => {
    await compare(param(words(42, 999), [scalar(0, 42), scalar(0, 999)]), "different words", true);
    await compare(param(words(42, 999), [scalar(0, 42), scalar(0, 42)]), "word 1 unchecked by old core", false);
    await compare(param(words(42, 999, -7), [c(7), scalar(0, 999), range(8, -10, 0)]), "skip then signed", true);
    for (const bytes of [0, 1, 31, 32, 33, 63]) {
      await compare(param(`0x${"00".repeat(bytes)}`, [scalar(0, 0), c(7)]), `short ${bytes}`, false);
    }
    await compare(param("0x", []), "empty unconstrained bytes", true);
    // ABI envelopes remain raw words: this checks the offset, not the string.
    await compare(param(encodeAbiParameters([{ type: "string" }], ["hello"]), [scalar(0, 32)]), "dynamic offset", true);
  });

  it("uses the same positions for STATIC_CALL and BALANCE fetchers", async () => {
    const callData = encodeFunctionData({ abi: host.abi, functionName: "words" });
    const data = encodeAbiParameters([{ type: "address" }, { type: "bytes" }], [host.address, callData]);
    await compare(param(data, [scalar(0, 42), scalar(0, 999), scalar(5, -7)], 1), "static tuple", true);
    await compare(param(data, [scalar(0, 42), scalar(0, 42)], 1), "static second mismatch", false);
    const balanceData = encodePacked(["address", "address"], [zeroAddress, host.address]);
    await compare(param(balanceData, [scalar(0, 0)], 2), "native balance", true);
    await compare(param(balanceData, [scalar(0, 0), c(7)], 2), "balance has one word", false);
  });

  it("rejects malformed leaves, invalid ranges and structurally nested OR", async () => {
    for (const type of [0, 1, 2, 4, 5]) {
      for (const bytes of [0, 1, 31, 33]) {
        await compare(param(word(0), [c(type, `0x${"00".repeat(bytes)}`)]), `malformed leaf ${type}/${bytes}`, false);
      }
    }
    for (const type of [3, 8]) {
      await compare(param(word(0), [c(type, word(0))]), "short range", false);
      await compare(param(word(0), [range(type, 10, 1)]), "inverted range", false);
    }
    await compare(param(word(0), [or([])]), "empty OR", false);
    await compare(param(word(0), [or([c(7), or([c(7)])])]), "nested OR after true", false);
    await compare(param(word(0), [or([range(8, 10, -10), c(7)])]), "invalid range before true", false);
    await compare(param(word(0), [c(6, "0x01")]), "malformed OR", false);
    await compare(param(word(0), [c(7, word(0))]), "SKIP payload", false);
  });

  it("retains stricter canonical range lengths in Assertions", async () => {
    // Biconomy's abi.decode permits trailing range bytes; Assertions has
    // always required exactly 64 bytes. This is a deliberate rejection-only
    // difference, not a different interpretation of canonical constraints.
    const p = param(word(5), [c(3, words(0, 10, 99))]);
    assert.equal(await accepts(core.address, encodeFunctionData({ abi: core.abi, functionName: "assertParam", args: [p] })), false);
    assert.equal(await accepts(host.address, encodeFunctionData({ abi: host.abi, functionName: "judge", args: [p] })), true);
  });
});
