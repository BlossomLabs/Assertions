// Differential fuzzer for the manual ABI machinery: Assertions.nav (typed
// navigation over encoded data) and Operators.encode (runtime abi.encode).
//
// The oracle is viem's ABI encoder — the question these tests answer is
// "does the Solidity shape parser agree with the real ABI spec?", so every
// case builds a random type, a random value of that type and a random path,
// encodes with viem, runs the contract, and compares byte-for-byte against
// what the documented semantics say must come back (value, envelope, length
// word, payload, or a specific typed revert).
//
// Two hygiene passes fuzz the failure surface: corrupted data and mutated
// descriptors must produce one of the declared custom errors — never a
// Panic, never an unknown selector — because a raw assembly return that
// survives malformed input is how out-of-bounds reads hide.
//
// Deterministic: FUZZ_SEED / FUZZ_RUNS env vars override the defaults, and
// every failure message carries the seed + case number to replay it.

import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { network } from "hardhat";
import {
  decodeErrorResult,
  encodeAbiParameters,
  encodeFunctionData,
  getAddress,
  stringToHex,
  type AbiParameter,
  type Hex,
} from "viem";

const SEED = Number(process.env.FUZZ_SEED ?? 20260811);
const RUNS = Number(process.env.FUZZ_RUNS ?? 300);

const INT256_MIN = -(1n << 255n);
const LEN = INT256_MIN;
const PAYLOAD = INT256_MIN + 1n;

// ============ Deterministic PRNG ============

type Rng = () => number;

function mulberry32(seed: number): Rng {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function caseRng(i: number): Rng {
  return mulberry32((SEED + i * 0x9e3779b9) >>> 0);
}

function randInt(rng: Rng, min: number, max: number): number {
  return min + Math.floor(rng() * (max - min + 1));
}

function hexBytes(rng: Rng, n: number): string {
  let s = "";
  for (let i = 0; i < n; i++) s += randInt(rng, 0, 255).toString(16).padStart(2, "0");
  return s;
}

function randBig(rng: Rng, bits: number): bigint {
  return BigInt("0x0" + hexBytes(rng, Math.ceil(bits / 8)));
}

// ============ Random ABI types, descriptors, values ============

type AbiT =
  | { kind: "word"; name: string }
  | { kind: "bytes" }
  | { kind: "string" }
  | { kind: "tuple"; comps: AbiT[] }
  | { kind: "array"; elem: AbiT; len: number | null };

const WORD_NAMES = ["uint256", "uint112", "uint8", "address", "bool", "bytes32", "bytes4"];

function genType(rng: Rng, depth: number): AbiT {
  const r = rng();
  if (depth <= 0 || r < 0.45) {
    const r2 = rng();
    if (r2 < 0.7) return { kind: "word", name: WORD_NAMES[randInt(rng, 0, WORD_NAMES.length - 1)] };
    return rng() < 0.5 ? { kind: "bytes" } : { kind: "string" };
  }
  if (r < 0.72) {
    const n = randInt(rng, 1, 3);
    return { kind: "tuple", comps: Array.from({ length: n }, () => genType(rng, depth - 1)) };
  }
  const elem = genType(rng, depth - 1);
  return { kind: "array", elem, len: rng() < 0.4 ? randInt(rng, 1, 3) : null };
}

function isDynamic(t: AbiT): boolean {
  switch (t.kind) {
    case "word":
      return false;
    case "bytes":
    case "string":
      return true;
    case "tuple":
      return t.comps.some(isDynamic);
    case "array":
      return t.len === null || isDynamic(t.elem);
  }
}

// Head footprint in words, mirroring AbiShape.typeShape (dynamic = 1 offset word).
function headWords(t: AbiT): number {
  if (isDynamic(t)) return 1;
  switch (t.kind) {
    case "word":
      return 1;
    case "tuple":
      return t.comps.reduce((s, c) => s + headWords(c), 0);
    case "array":
      return (t.len ?? 0) * headWords(t.elem);
    default:
      return 1;
  }
}

function descriptorOf(t: AbiT): string {
  switch (t.kind) {
    case "word":
      return t.name;
    case "bytes":
      return "bytes";
    case "string":
      return "string";
    case "tuple":
      return "(" + t.comps.map(descriptorOf).join(",") + ")";
    case "array":
      return descriptorOf(t.elem) + (t.len === null ? "[]" : `[${t.len}]`);
  }
}

function viemParamOf(t: AbiT): AbiParameter {
  switch (t.kind) {
    case "word":
      return { type: t.name };
    case "bytes":
      return { type: "bytes" };
    case "string":
      return { type: "string" };
    case "tuple":
      return { type: "tuple", components: t.comps.map(viemParamOf) } as AbiParameter;
    case "array": {
      const inner = viemParamOf(t.elem) as AbiParameter & { components?: unknown };
      const suffix = t.len === null ? "[]" : `[${t.len}]`;
      return { ...inner, type: inner.type + suffix } as AbiParameter;
    }
  }
}

function genValue(rng: Rng, t: AbiT): unknown {
  switch (t.kind) {
    case "word": {
      if (t.name === "address") return getAddress(("0x" + hexBytes(rng, 20)) as Hex);
      if (t.name === "bool") return rng() < 0.5;
      if (t.name === "bytes32") return ("0x" + hexBytes(rng, 32)) as Hex;
      if (t.name === "bytes4") return ("0x" + hexBytes(rng, 4)) as Hex;
      const bits = t.name === "uint8" ? 8 : t.name === "uint112" ? 112 : 256;
      const max = (1n << BigInt(bits)) - 1n;
      const r = rng();
      if (r < 0.15) return 0n;
      if (r < 0.25) return 1n;
      if (r < 0.35) return max;
      return randBig(rng, bits) & max;
    }
    case "bytes":
      return ("0x" + hexBytes(rng, randInt(rng, 0, 70))) as Hex;
    case "string": {
      const n = randInt(rng, 0, 24);
      const ascii = "abcXYZ 0189_,()[]";
      let s = "";
      for (let i = 0; i < n; i++) s += rng() < 0.06 ? "é" : ascii[randInt(rng, 0, ascii.length - 1)];
      return s;
    }
    case "tuple":
      return t.comps.map((c) => genValue(rng, c));
    case "array": {
      const n = t.len ?? randInt(rng, 0, 3);
      return Array.from({ length: n }, () => genValue(rng, t.elem));
    }
  }
}

// ============ The nav oracle ============

type Expect = { ok: Hex } | { revert: string };

function word(n: bigint): Hex {
  return ("0x" + n.toString(16).padStart(64, "0")) as Hex;
}

function utf8Len(s: string): bigint {
  return BigInt(new TextEncoder().encode(s).length);
}

function encodeSingle(t: AbiT, v: unknown): Hex {
  return encodeAbiParameters([viemParamOf(t)], [v]);
}

// What nav must return for a plain (non-sentinel) path ending on `node`.
function terminalExpect(node: AbiT, val: unknown): Expect {
  if (!isDynamic(node)) {
    return headWords(node) === 1 ? { ok: encodeSingle(node, val) } : { revert: "InvalidNavigation" };
  }
  if (node.kind === "bytes" || node.kind === "string") return { ok: encodeSingle(node, val) };
  if (node.kind === "array" && node.len === null && !isDynamic(node.elem)) {
    return { ok: encodeSingle(node, val) };
  }
  // Dynamic tuples, T[] of dynamic T, and fixed arrays of dynamic elements
  // are documented as unrepresentable terminals.
  return { revert: "InvalidNavigation" };
}

// What nav must return for a path ending in LEN or PAYLOAD on `node`.
function sentinelExpect(s: bigint, node: AbiT, val: unknown): Expect {
  if (s === LEN) {
    if (node.kind === "array" && node.len === null) return { ok: word(BigInt((val as unknown[]).length)) };
    if (node.kind === "bytes") return { ok: word(BigInt(((val as Hex).length - 2) / 2)) };
    if (node.kind === "string") return { ok: word(utf8Len(val as string)) };
    // Statics, tuples and FIXED arrays (their length is known at
    // composition time, per the NatSpec) must revert.
    return { revert: "InvalidNavigation" };
  }
  if (node.kind === "bytes") return { ok: val as Hex };
  if (node.kind === "string") return { ok: stringToHex(val as string) };
  return { revert: "InvalidNavigation" };
}

interface NavCase {
  path: bigint[];
  expect: Expect;
}

function genPath(rng: Rng, top: AbiT & { kind: "tuple" }, topVal: unknown[], fullData: Hex): NavCase {
  const r0 = rng();
  if (r0 < 0.05) return { path: [], expect: { ok: fullData } };
  if (r0 < 0.07) return { path: [LEN], expect: { revert: "InvalidNavigation" } };
  if (r0 < 0.09) return { path: [PAYLOAD], expect: { revert: "InvalidNavigation" } };

  const path: bigint[] = [];
  let node: AbiT = top;
  let val: unknown = topVal;

  while (true) {
    if (node.kind === "tuple" || node.kind === "array") {
      if (path.length > 0 && rng() < 0.4) break;
      const count = node.kind === "tuple" ? node.comps.length : node.len ?? (val as unknown[]).length;
      const r = rng();
      if (r < 0.06) {
        path.push(BigInt(count + randInt(rng, 0, 2)));
        return { path, expect: { revert: "ElementIndexOutOfBounds" } };
      }
      if (node.kind === "tuple" && r < 0.1) {
        // Tuple steps only accept non-negative indices.
        path.push(-1n);
        return { path, expect: { revert: "ElementIndexOutOfBounds" } };
      }
      if (node.kind === "array" && r < 0.1) {
        path.push(BigInt(-(count + 1 + randInt(rng, 0, 2))));
        return { path, expect: { revert: "ElementIndexOutOfBounds" } };
      }
      if (count === 0) {
        path.push(rng() < 0.5 ? 0n : -1n);
        return { path, expect: { revert: "ElementIndexOutOfBounds" } };
      }
      const idx = randInt(rng, 0, count - 1);
      const neg = node.kind === "array" && rng() < 0.35;
      path.push(neg ? BigInt(idx - count) : BigInt(idx));
      val = (val as unknown[])[idx];
      node = node.kind === "tuple" ? node.comps[idx] : node.elem;
    } else {
      // Base leaf: occasionally take a deliberate step INTO it.
      if (path.length > 0 && rng() < 0.15) {
        path.push(BigInt(randInt(rng, 0, 2)));
        return { path, expect: { revert: "InvalidNavigation" } };
      }
      break;
    }
  }

  if (rng() < 0.25) {
    const s = rng() < 0.5 ? LEN : PAYLOAD;
    path.push(s);
    return { path, expect: sentinelExpect(s, node, val) };
  }
  return { path, expect: terminalExpect(node, val) };
}

// ============ Revert decoding ============

const ERROR_ABI = [
  { type: "error", name: "InvalidNavigation", inputs: [{ type: "uint256" }] },
  { type: "error", name: "InvalidTypeDescriptor", inputs: [{ type: "uint256" }] },
  { type: "error", name: "ElementIndexOutOfBounds", inputs: [{ type: "int256" }, { type: "uint256" }] },
  { type: "error", name: "ReturnDataOutOfBounds", inputs: [{ type: "int256" }, { type: "uint256" }] },
  { type: "error", name: "CallFailed", inputs: [{ type: "address" }, { type: "bytes" }] },
  {
    type: "error",
    name: "ConstraintFailed",
    inputs: [
      { type: "string" },
      { type: "uint256" },
      { type: "uint256" },
      { type: "uint256" },
      { type: "uint8" },
      { type: "bytes32" },
      { type: "bytes" },
    ],
  },
  { type: "error", name: "ComponentCountMismatch", inputs: [{ type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "InvalidComponentLength", inputs: [{ type: "uint256" }, { type: "uint256" }, { type: "uint256" }] },
  {
    type: "error",
    name: "InvalidComponentEnvelope",
    inputs: [{ type: "uint256" }, { type: "uint256" }, { type: "bytes32" }],
  },
  { type: "error", name: "Panic", inputs: [{ type: "uint256" }] },
  { type: "error", name: "Error", inputs: [{ type: "string" }] },
] as const;

function revertDataOf(err: unknown): Hex | null {
  for (let e = err as Record<string, any> | undefined; e; e = e.cause) {
    for (const d of [e.data, e.data?.data, e.error?.data, e.error?.data?.data]) {
      if (typeof d === "string" && d.startsWith("0x")) return d as Hex;
    }
  }
  return null;
}

function decodeRevert(data: Hex): string {
  if (data === "0x") return "<empty>";
  try {
    return decodeErrorResult({ abi: ERROR_ABI, data }).errorName;
  } catch {
    return "<unknown " + data.slice(0, 10) + ">";
  }
}

// ============ Harness ============

const { viem } = await network.connect();
const publicClient = await viem.getPublicClient();
const assertions = await viem.deployContract("Assertions");
const operators = await viem.deployContract("Operators");

type CallResult = { ok: true; data: Hex } | { ok: false; errorName: string; raw: Hex };

async function rawCall(to: Hex, calldata: Hex): Promise<CallResult> {
  try {
    const res = await publicClient.call({ to, data: calldata });
    return { ok: true, data: ((res.data ?? "0x") as string).toLowerCase() as Hex };
  } catch (err) {
    const raw = revertDataOf(err);
    if (raw === null) throw err;
    return { ok: false, errorName: decodeRevert(raw), raw };
  }
}

function navCalldata(desc: string, data: Hex, path: bigint[]): Hex {
  return encodeFunctionData({
    abi: assertions.abi,
    functionName: "nav",
    args: [{ paramType: 2, fetcherType: 0, paramData: data, constraints: [] }, desc, path],
  });
}

function describeCase(i: number, extra: Record<string, unknown>): string {
  const parts = Object.entries(extra).map(([k, v]) => `${k}=${typeof v === "bigint" ? v.toString() : JSON.stringify(v, (_, x) => (typeof x === "bigint" ? x.toString() : x))}`);
  return `[seed=${SEED} case=${i}] ` + parts.join(" ");
}

function genTopLevel(rng: Rng): { comps: AbiT[]; vals: unknown[]; desc: string; data: Hex } {
  const comps = Array.from({ length: randInt(rng, 1, 3) }, () => genType(rng, 2));
  const vals = comps.map((c) => genValue(rng, c));
  const desc = "(" + comps.map(descriptorOf).join(",") + ")";
  const data = encodeAbiParameters(comps.map(viemParamOf), vals);
  return { comps, vals, desc, data };
}

// Errors the descriptor/data hygiene passes accept: the machinery's own
// typed vocabulary. A Panic, an unknown selector or an empty revert fails.
const TYPED_NAV_ERRORS = new Set([
  "InvalidNavigation",
  "InvalidTypeDescriptor",
  "ElementIndexOutOfBounds",
  "ReturnDataOutOfBounds",
]);

// ============ nav suites ============

describe("nav differential fuzz", () => {
  it("agrees with viem on random typed navigations", async () => {
    const stats = { ok: 0, revert: 0 };
    for (let i = 0; i < RUNS; i++) {
      const rng = caseRng(i);
      const { comps, vals, desc, data } = genTopLevel(rng);
      const { path, expect } = genPath(rng, { kind: "tuple", comps }, vals, data);
      const res = await rawCall(assertions.address, navCalldata(desc, data, path));
      const ctx = describeCase(i, { desc, path: path.map(String), data, expect });
      if ("ok" in expect) {
        stats.ok++;
        assert.ok(res.ok, `${ctx} — expected success, got revert ${res.ok ? "" : res.errorName}`);
        assert.equal(res.data, expect.ok.toLowerCase(), `${ctx} — value mismatch`);
      } else {
        stats.revert++;
        assert.ok(!res.ok, `${ctx} — expected ${expect.revert}, call succeeded with ${res.ok ? res.data : ""}`);
        assert.equal(res.errorName, expect.revert, `${ctx} — wrong error`);
      }
    }
    // Generator honesty: both outcomes must actually be exercised.
    assert.ok(stats.ok > RUNS / 10, `degenerate generator: only ${stats.ok} success cases`);
    assert.ok(stats.revert > RUNS / 20, `degenerate generator: only ${stats.revert} revert cases`);
  });

  it("stays typed under data corruption", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = caseRng(0x40000000 + i);
      const { comps, vals, desc, data } = genTopLevel(rng);
      const { path } = genPath(rng, { kind: "tuple", comps }, vals, data);
      const corrupted = corrupt(rng, data);
      const res = await rawCall(assertions.address, navCalldata(desc, corrupted, path));
      if (!res.ok) {
        const ctx = describeCase(i, { desc, path: path.map(String), corrupted });
        assert.ok(
          TYPED_NAV_ERRORS.has(res.errorName),
          `${ctx} — corrupted data produced ${res.errorName} (raw ${res.raw}) instead of a typed nav error`,
        );
      }
    }
  });

  it("stays typed under descriptor mutation", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = caseRng(0x50000000 + i);
      const { comps, vals, desc, data } = genTopLevel(rng);
      const { path } = genPath(rng, { kind: "tuple", comps }, vals, data);
      const mutated = mutateDesc(rng, desc);
      const res = await rawCall(assertions.address, navCalldata(mutated, data, path));
      if (!res.ok) {
        const ctx = describeCase(i, { desc: mutated, path: path.map(String), data });
        assert.ok(
          TYPED_NAV_ERRORS.has(res.errorName),
          `${ctx} — mutated descriptor produced ${res.errorName} (raw ${res.raw}) instead of a typed nav error`,
        );
      }
    }
  });
});

function corrupt(rng: Rng, data: Hex): Hex {
  const bytes = data.slice(2);
  const n = bytes.length / 2;
  const mode = randInt(rng, 0, 2);
  if (mode === 0 || n === 0) {
    // Truncate — every offset/length beyond the cut turns hostile.
    const cut = randInt(rng, 0, Math.max(0, n - 1));
    return ("0x" + bytes.slice(0, cut * 2)) as Hex;
  }
  if (mode === 1 && n >= 32) {
    // Overwrite an aligned word: offset/length bombs.
    const w = randInt(rng, 0, Math.floor(n / 32) - 1) * 32;
    const bombs = ["ff".repeat(32), "80" + "00".repeat(31), "00".repeat(31) + "e0"];
    const bomb = bombs[randInt(rng, 0, bombs.length - 1)];
    return ("0x" + bytes.slice(0, w * 2) + bomb + bytes.slice((w + 32) * 2)) as Hex;
  }
  const i = randInt(rng, 0, n - 1);
  const b = (parseInt(bytes.slice(i * 2, i * 2 + 2), 16) ^ (1 << randInt(rng, 0, 7)))
    .toString(16)
    .padStart(2, "0");
  return ("0x" + bytes.slice(0, i * 2) + b + bytes.slice(i * 2 + 2)) as Hex;
}

function mutateDesc(rng: Rng, desc: string): string {
  const pool = "abcdefgsxyz0123456789()[],";
  const i = randInt(rng, 0, Math.max(0, desc.length - 1));
  const mode = randInt(rng, 0, 2);
  if (mode === 0 && desc.length > 1) return desc.slice(0, i) + desc.slice(i + 1);
  const c = pool[randInt(rng, 0, pool.length - 1)];
  if (mode === 1) return desc.slice(0, i) + c + desc.slice(i + 1);
  return desc.slice(0, i) + c + desc.slice(i);
}

// ============ encode suites ============

describe("encode differential fuzz", () => {
  it("agrees with viem abi.encode on random tuples", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = caseRng(0x60000000 + i);
      const { comps, vals, desc } = genTopLevel(rng);
      // Each component value in its canonical single-value encoding: a
      // static value's flattened words, a dynamic value's [0x20][tail].
      const values = comps.map((c, j) => encodeAbiParameters([viemParamOf(c)], [vals[j]]));
      const expected = encodeAbiParameters(comps.map(viemParamOf), vals).toLowerCase();
      const calldata = encodeFunctionData({
        abi: operators.abi,
        functionName: "encode",
        args: [desc, values],
      });
      const res = await rawCall(operators.address, calldata);
      const ctx = describeCase(i, { desc, values });
      assert.ok(res.ok, `${ctx} — encode reverted with ${res.ok ? "" : res.errorName}`);
      assert.equal(res.data, expected, `${ctx} — encoding mismatch`);
    }
  });

  it("rejects malformed component values with typed errors", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = caseRng(0x70000000 + i);
      const { comps, vals, desc } = genTopLevel(rng);
      const values = comps.map((c, j) => encodeAbiParameters([viemParamOf(c)], [vals[j]]));

      let expectError: string;
      const dynIdx = comps.findIndex(isDynamic);
      const staticIdx = comps.findIndex((c) => !isDynamic(c));
      const mode = randInt(rng, 0, 3);
      if (mode === 0) {
        values.pop();
        expectError = "ComponentCountMismatch";
      } else if (mode === 1) {
        values.push("0x" as Hex);
        expectError = "ComponentCountMismatch";
      } else if (mode === 2 && dynIdx !== -1) {
        const v = values[dynIdx].slice(2);
        const kind = randInt(rng, 0, 2);
        if (kind === 0) {
          // Head word must be exactly 0x20.
          values[dynIdx] = ("0x" + "40".padStart(64, "0") + v.slice(64)) as Hex;
        } else if (kind === 1) {
          // Below the minimum envelope of [0x20][one tail word].
          values[dynIdx] = ("0x" + v.slice(0, 64)) as Hex;
        } else {
          // Unaligned length.
          values[dynIdx] = ("0x" + v + "aa") as Hex;
        }
        expectError = "InvalidComponentEnvelope";
      } else if (staticIdx !== -1) {
        values[staticIdx] = (rng() < 0.5 ? "0x" : values[staticIdx] + "00".repeat(32)) as Hex;
        expectError = "InvalidComponentLength";
      } else {
        values.pop();
        expectError = "ComponentCountMismatch";
      }

      const calldata = encodeFunctionData({
        abi: operators.abi,
        functionName: "encode",
        args: [desc, values],
      });
      const res = await rawCall(operators.address, calldata);
      const ctx = describeCase(i, { desc, values, expectError });
      assert.ok(!res.ok, `${ctx} — malformed values were accepted`);
      assert.equal(res.errorName, expectError, `${ctx} — wrong error`);
    }
  });
});
