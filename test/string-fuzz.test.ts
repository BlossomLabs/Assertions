// Differential fuzzer for the Operators bytes/string/word-array vocabulary.
// Every function here is a pure data transformation with a few-line
// JavaScript reference, so each case generates biased random inputs, runs
// both, and compares exactly — values byte-for-byte, reverts by error name
// (and arguments, where the oracle can compute them, e.g. the position and
// character of an InvalidDecimalDigit).
//
// Generation is match-heavy on purpose: haystacks drawn from 1-3 byte
// alphabets so needles collide and overlap (the `aaaa`/`aa` enumeration
// cases), payload words drawn from small pools so sort/unique see
// duplicates, near-2^256 words so sumWords overflows, digit strings
// straddling the 78-digit uint256 boundary.
//
// Deterministic: FUZZ_SEED / FUZZ_RUNS env vars override the defaults
// (FUZZ_RUNS is per-function here), and every failure message carries the
// seed + case number to replay it.

import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { network } from "hardhat";
import {
  concat as concatHex,
  decodeAbiParameters,
  decodeErrorResult,
  encodeFunctionData,
  keccak256,
  type Hex,
} from "viem";

const SEED = Number(process.env.FUZZ_SEED ?? 20260811);
const RUNS = Number(process.env.FUZZ_RUNS ?? 120);

const U256 = 1n << 256n;
const MAXU = U256 - 1n;
const I_MIN = -(1n << 255n);
const I_MAX = (1n << 255n) - 1n;

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

function randInt(rng: Rng, min: number, max: number): number {
  return min + Math.floor(rng() * (max - min + 1));
}

// ============ Byte-array helpers (oracles work on number[]) ============

function toHexStr(b: number[]): Hex {
  return ("0x" + b.map((x) => x.toString(16).padStart(2, "0")).join("")) as Hex;
}

function fromHexStr(h: Hex): number[] {
  const out: number[] = [];
  for (let i = 2; i < h.length; i += 2) out.push(parseInt(h.slice(i, i + 2), 16));
  return out;
}

function wordsOf(h: Hex): bigint[] | null {
  const n = (h.length - 2) / 2;
  if (n % 32 !== 0) return null;
  const out: bigint[] = [];
  for (let i = 0; i < n / 32; i++) out.push(BigInt("0x0" + h.slice(2 + i * 64, 2 + (i + 1) * 64)));
  return out;
}

function toPayload(words: bigint[]): Hex {
  return ("0x" + words.map((w) => w.toString(16).padStart(64, "0")).join("")) as Hex;
}

const cmpU = (a: bigint, b: bigint) => (a < b ? -1 : a > b ? 1 : 0);

// ============ Input generators ============

// Haystacks: small alphabets make needles match and self-overlap.
function genHay(rng: Rng): number[] {
  const r = rng();
  const len = randInt(rng, 0, 40);
  if (r < 0.4) {
    const alpha = Array.from({ length: randInt(rng, 1, 3) }, () => randInt(rng, 0, 255));
    return Array.from({ length: len }, () => alpha[randInt(rng, 0, alpha.length - 1)]);
  }
  if (r < 0.7) {
    // ASCII text: letters both cases, digits, punctuation — the
    // toLower/toUpper/charset/parseUint-shaped inputs.
    const pool = "azAZmM09  ,.()[]_éÿ";
    return Array.from({ length: len }, () => pool.charCodeAt(randInt(rng, 0, pool.length - 1)) & 0xff);
  }
  return Array.from({ length: len }, () => randInt(rng, 0, 255));
}

function genNeedle(rng: Rng, hay: number[]): number[] {
  const r = rng();
  if (r < 0.1) return [];
  if (r < 0.7 && hay.length > 0) {
    const start = randInt(rng, 0, hay.length - 1);
    const len = randInt(rng, 1, Math.min(4, hay.length - start));
    return hay.slice(start, start + len);
  }
  return Array.from({ length: randInt(rng, 1, 3) }, () => randInt(rng, 0, 255));
}

function genWord(rng: Rng): bigint {
  const pool = [0n, 1n, 2n, MAXU, MAXU - 1n, 1n << 255n];
  const r = rng();
  if (r < 0.5) return pool[randInt(rng, 0, pool.length - 1)];
  if (r < 0.75) return BigInt(randInt(rng, 0, 1000));
  let s = "0x0";
  for (let i = 0; i < 32; i++) s += randInt(rng, 0, 255).toString(16).padStart(2, "0");
  return BigInt(s) & MAXU;
}

// Aligned word payload, occasionally spoiled with stray tail bytes.
function genPayload(rng: Rng): Hex {
  const words = Array.from({ length: randInt(rng, 0, 8) }, () => genWord(rng));
  let h = toPayload(words);
  if (rng() < 0.08) h = (h + "aa".repeat(randInt(rng, 1, 31))) as Hex;
  return h;
}

// ============ Oracles for the scan family ============

// Non-overlapping left-to-right occurrence positions — the enumeration
// indexOf, replace and occurrence counting all share.
function occurrencePositions(s: number[], needle: number[]): number[] {
  const out: number[] = [];
  let p = 0;
  while (p + needle.length <= s.length) {
    if (needle.every((b, j) => s[p + j] === b)) {
      out.push(p);
      p += needle.length;
    } else {
      p++;
    }
  }
  return out;
}

function indexOfRef(s: number[], needle: number[], occ: bigint): bigint {
  const n = BigInt(s.length);
  if (needle.length === 0) {
    const positions = n + 1n;
    if (occ >= 0n) return occ < positions ? occ : n;
    if (occ < -positions) return n;
    return positions + occ;
  }
  const occs = occurrencePositions(s, needle);
  let wanted: bigint;
  if (occ < 0n) {
    if (occ < -BigInt(occs.length)) return n;
    wanted = BigInt(occs.length) + occ;
  } else {
    wanted = occ;
  }
  return wanted < BigInt(occs.length) ? BigInt(occs[Number(wanted)]) : n;
}

function replaceRef(s: number[], needle: number[], repl: number[]): number[] {
  const out: number[] = [];
  let p = 0;
  let start = 0;
  while (p + needle.length <= s.length) {
    if (needle.every((b, j) => s[p + j] === b)) {
      out.push(...s.slice(start, p), ...repl);
      p += needle.length;
      start = p;
    } else {
      p++;
    }
  }
  out.push(...s.slice(start));
  return out;
}

// ============ Revert decoding ============

const ERROR_ABI = [
  { type: "error", name: "SliceOutOfBounds", inputs: [{ type: "uint256" }, { type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "EmptyNeedle", inputs: [] },
  { type: "error", name: "EmptyNumber", inputs: [] },
  { type: "error", name: "InvalidDecimalDigit", inputs: [{ type: "uint256" }, { type: "bytes1" }] },
  { type: "error", name: "UnalignedWords", inputs: [{ type: "uint256" }] },
  { type: "error", name: "WordCountMismatch", inputs: [{ type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "InvalidLane", inputs: [{ type: "uint256" }] },
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

function decodeRevert(data: Hex): { name: string; args: readonly unknown[] } {
  if (data === "0x") return { name: "<empty>", args: [] };
  try {
    const d = decodeErrorResult({ abi: ERROR_ABI, data });
    if (d.errorName === "Panic") return { name: "Panic" + (d.args[0] as bigint).toString(16), args: [] };
    return { name: d.errorName, args: d.args ?? [] };
  } catch {
    return { name: "<unknown " + data.slice(0, 10) + ">", args: [] };
  }
}

// ============ Harness ============

const { viem } = await network.connect();
const publicClient = await viem.getPublicClient();
const operators = await viem.deployContract("Operators");

type Expect = { ok: unknown } | { revert: string; args?: unknown[] };
type CallResult = { ok: true; value: unknown } | { ok: false; errorName: string; errorArgs: readonly unknown[] };

async function callFn(name: string, inTypes: string[], outType: string, args: unknown[]): Promise<CallResult> {
  const abi = [
    {
      type: "function",
      name,
      stateMutability: "view",
      inputs: inTypes.map((t) => (t.endsWith("[]") ? { type: t } : { type: t })),
      outputs: [{ type: outType }],
    },
  ] as const;
  try {
    const res = await publicClient.call({
      to: operators.address,
      data: encodeFunctionData({ abi, functionName: name, args }),
    });
    const [v] = decodeAbiParameters([{ type: outType }], (res.data ?? "0x") as Hex);
    return { ok: true, value: v };
  } catch (err) {
    const raw = revertDataOf(err);
    if (raw === null) throw err;
    const d = decodeRevert(raw);
    return { ok: false, errorName: d.name, errorArgs: d.args };
  }
}

function show(v: unknown): string {
  return JSON.stringify(v, (_, x) => (typeof x === "bigint" ? x.toString() : x));
}

function valuesEqual(outType: string, got: unknown, want: unknown): boolean {
  if (outType === "bytes" || outType === "bytes32") {
    return (got as string).toLowerCase() === (want as string).toLowerCase();
  }
  return got === want;
}

interface Spec {
  label: string;
  name: string;
  inTypes: string[];
  outType: string;
  gen: (rng: Rng) => unknown[];
  ref: (...args: any[]) => Expect;
}

async function checkCase(spec: Spec, i: number, args: unknown[]): Promise<void> {
  const expect = spec.ref(...args);
  const got = await callFn(spec.name, spec.inTypes, spec.outType, args);
  const e = "ok" in expect ? `ok ${show(expect.ok)}` : `revert ${expect.revert}${expect.args ? show(expect.args) : ""}`;
  const g = got.ok ? `ok ${show(got.value)}` : `revert ${got.errorName}${show(got.errorArgs)}`;
  const ctx = `[seed=${SEED} case=${i}] ${spec.label}(${args.map(show).join(", ")}) — expected ${e}, got ${g}`;
  if ("ok" in expect) {
    assert.ok(got.ok, ctx);
    assert.ok(valuesEqual(spec.outType, got.value, expect.ok), ctx);
  } else {
    assert.ok(!got.ok, ctx);
    assert.equal(got.errorName, expect.revert, ctx);
    if (expect.args) assert.equal(show(got.errorArgs), show(expect.args), ctx);
  }
}

// ============ The table ============

const SPECS: Spec[] = [
  // ---- bytes ----
  {
    label: "concat",
    name: "concat",
    inTypes: ["bytes[]"],
    outType: "bytes",
    gen: (rng) => [Array.from({ length: randInt(rng, 0, 4) }, () => toHexStr(genHay(rng)))],
    ref: (parts: Hex[]) => ({ ok: parts.length === 0 ? "0x" : concatHex(parts) }),
  },
  {
    label: "slice",
    name: "slice",
    inTypes: ["bytes", "uint256", "uint256"],
    outType: "bytes",
    gen: (rng) => {
      const data = genHay(rng);
      const r = rng();
      if (r < 0.7 && data.length > 0) {
        const start = randInt(rng, 0, data.length);
        return [toHexStr(data), BigInt(start), BigInt(randInt(rng, 0, data.length - start))];
      }
      // Out-of-bounds shapes, including huge starts/lengths.
      const wild = [0n, BigInt(data.length), BigInt(data.length + 1), MAXU, BigInt(randInt(rng, 0, 60))];
      return [toHexStr(data), wild[randInt(rng, 0, wild.length - 1)], wild[randInt(rng, 0, wild.length - 1)]];
    },
    ref: (data: Hex, start: bigint, len: bigint) => {
      const b = fromHexStr(data);
      if (start > BigInt(b.length) || len > BigInt(b.length) - start) {
        return { revert: "SliceOutOfBounds", args: [start, len, BigInt(b.length)] };
      }
      return { ok: toHexStr(b.slice(Number(start), Number(start + len))) };
    },
  },
  {
    label: "byteLen",
    name: "byteLen",
    inTypes: ["bytes"],
    outType: "uint256",
    gen: (rng) => [toHexStr(genHay(rng))],
    ref: (data: Hex) => ({ ok: BigInt((data.length - 2) / 2) }),
  },
  {
    label: "hash",
    name: "hash",
    inTypes: ["bytes"],
    outType: "bytes32",
    gen: (rng) => [toHexStr(genHay(rng))],
    ref: (data: Hex) => ({ ok: keccak256(data) }),
  },
  {
    label: "hashPairSorted",
    name: "hashPairSorted",
    inTypes: ["bytes32", "bytes32"],
    outType: "bytes32",
    gen: (rng) => {
      const w = () => ("0x" + genWord(rng).toString(16).padStart(64, "0")) as Hex;
      const a = w();
      return [a, rng() < 0.15 ? a : w()];
    },
    ref: (a: Hex, b: Hex) => ({ ok: BigInt(a) < BigInt(b) ? keccak256(concatHex([a, b])) : keccak256(concatHex([b, a])) }),
  },
  // ---- search / strings ----
  {
    label: "indexOf",
    name: "indexOf",
    inTypes: ["bytes", "bytes", "int256"],
    outType: "uint256",
    gen: (rng) => {
      const hay = genHay(rng);
      const occs = [0n, 1n, 2n, 5n, -1n, -2n, -3n, 100n, -100n, I_MIN, I_MAX];
      return [toHexStr(hay), toHexStr(genNeedle(rng, hay)), occs[randInt(rng, 0, occs.length - 1)]];
    },
    ref: (s: Hex, needle: Hex, occ: bigint) => ({ ok: indexOfRef(fromHexStr(s), fromHexStr(needle), occ) }),
  },
  {
    label: "replace",
    name: "replace",
    inTypes: ["bytes", "bytes", "bytes"],
    outType: "bytes",
    gen: (rng) => {
      const hay = genHay(rng);
      return [
        toHexStr(hay),
        toHexStr(genNeedle(rng, hay)),
        toHexStr(Array.from({ length: randInt(rng, 0, 5) }, () => randInt(rng, 0, 255))),
      ];
    },
    ref: (s: Hex, needle: Hex, repl: Hex) => {
      const n = fromHexStr(needle);
      if (n.length === 0) return { revert: "EmptyNeedle" };
      return { ok: toHexStr(replaceRef(fromHexStr(s), n, fromHexStr(repl))) };
    },
  },
  {
    label: "toLower",
    name: "toLower",
    inTypes: ["bytes"],
    outType: "bytes",
    gen: (rng) => [toHexStr(genHay(rng))],
    ref: (s: Hex) => ({ ok: toHexStr(fromHexStr(s).map((b) => (b >= 0x41 && b <= 0x5a ? b + 32 : b))) }),
  },
  {
    label: "toUpper",
    name: "toUpper",
    inTypes: ["bytes"],
    outType: "bytes",
    gen: (rng) => [toHexStr(genHay(rng))],
    ref: (s: Hex) => ({ ok: toHexStr(fromHexStr(s).map((b) => (b >= 0x61 && b <= 0x7a ? b - 32 : b))) }),
  },
  {
    label: "charset",
    name: "charset",
    inTypes: ["bytes", "uint256"],
    outType: "bool",
    gen: (rng) => {
      const s = genHay(rng);
      let mask = s.reduce((m, b) => m | (1n << BigInt(b)), 0n);
      const r = rng();
      if (r < 0.35 && s.length > 0) {
        // Knock out one present byte: usually flips the answer.
        mask &= ~(1n << BigInt(s[randInt(rng, 0, s.length - 1)]));
      } else if (r < 0.6) {
        mask = genWord(rng);
      }
      return [toHexStr(s), mask];
    },
    ref: (s: Hex, mask: bigint) => ({ ok: fromHexStr(s).every((b) => (mask & (1n << BigInt(b))) !== 0n) }),
  },
  // ---- parse ----
  {
    label: "parseUint",
    name: "parseUint",
    inTypes: ["bytes"],
    outType: "uint256",
    gen: (rng) => {
      const r = rng();
      if (r < 0.05) return ["0x" as Hex];
      // Length biased around the 78-digit uint256 boundary.
      const len = rng() < 0.3 ? randInt(rng, 70, 85) : randInt(rng, 1, 30);
      const digits = Array.from({ length: len }, (_, i) =>
        0x30 + (rng() < 0.2 && i > 0 ? 0 : randInt(rng, 0, 9)),
      );
      if (rng() < 0.2) digits[randInt(rng, 0, digits.length - 1)] = randInt(rng, 0, 255);
      return [toHexStr(digits)];
    },
    ref: (s: Hex) => {
      const b = fromHexStr(s);
      if (b.length === 0) return { revert: "EmptyNumber" };
      let acc = 0n;
      for (let i = 0; i < b.length; i++) {
        if (b[i] < 0x30 || b[i] > 0x39) {
          return { revert: "InvalidDecimalDigit", args: [BigInt(i), toHexStr([b[i]])] };
        }
        acc = acc * 10n + BigInt(b[i] - 0x30);
        if (acc > MAXU) return { revert: "Panic11" };
      }
      return { ok: acc };
    },
  },
  {
    label: "toString",
    name: "toString",
    inTypes: ["uint256"],
    outType: "string",
    gen: (rng) => {
      const r = rng();
      if (r < 0.3) return [BigInt(randInt(rng, 0, 10))];
      if (r < 0.5) return [10n ** BigInt(randInt(rng, 1, 77)) + BigInt(randInt(rng, -1, 1))];
      if (r < 0.6) return [MAXU];
      return [genWord(rng)];
    },
    ref: (v: bigint) => ({ ok: v.toString(10) }),
  },
  // ---- word arrays ----
  {
    label: "iotaWords",
    name: "iotaWords",
    inTypes: ["uint256"],
    outType: "bytes",
    gen: (rng) => [BigInt(randInt(rng, 0, 60))],
    ref: (n: bigint) => ({ ok: toPayload(Array.from({ length: Number(n) }, (_, i) => BigInt(i))) }),
  },
  {
    label: "wordIndexOf",
    name: "wordIndexOf",
    inTypes: ["bytes", "bytes32"],
    outType: "uint256",
    gen: (rng) => {
      const s = genPayload(rng);
      const w = wordsOf(s);
      const target =
        w && w.length > 0 && rng() < 0.5 ? w[randInt(rng, 0, w.length - 1)] : genWord(rng);
      return [s, ("0x" + target.toString(16).padStart(64, "0")) as Hex];
    },
    ref: (s: Hex, target: Hex) => {
      const w = wordsOf(s);
      if (!w) return { revert: "UnalignedWords" };
      const i = w.findIndex((x) => x === BigInt(target));
      return { ok: BigInt(i === -1 ? w.length : i) };
    },
  },
  {
    label: "reverseWords",
    name: "reverseWords",
    inTypes: ["bytes"],
    outType: "bytes",
    gen: (rng) => [genPayload(rng)],
    ref: (s: Hex) => {
      const w = wordsOf(s);
      return w ? { ok: toPayload([...w].reverse()) } : { revert: "UnalignedWords" };
    },
  },
  {
    label: "sortWords",
    name: "sortWords",
    inTypes: ["bytes"],
    outType: "bytes",
    gen: (rng) => [genPayload(rng)],
    ref: (s: Hex) => {
      const w = wordsOf(s);
      return w ? { ok: toPayload([...w].sort(cmpU)) } : { revert: "UnalignedWords" };
    },
  },
  {
    label: "uniqueWords",
    name: "uniqueWords",
    inTypes: ["bytes"],
    outType: "bytes",
    gen: (rng) => [genPayload(rng)],
    ref: (s: Hex) => {
      const w = wordsOf(s);
      if (!w) return { revert: "UnalignedWords" };
      return { ok: toPayload(w.filter((x, i) => i === 0 || x !== w[i - 1])) };
    },
  },
  {
    label: "sumWords",
    name: "sumWords",
    inTypes: ["bytes"],
    outType: "uint256",
    gen: (rng) => [genPayload(rng)],
    ref: (s: Hex) => {
      const w = wordsOf(s);
      if (!w) return { revert: "UnalignedWords" };
      const total = w.reduce((a, b) => a + b, 0n);
      return total > MAXU ? { revert: "Panic11" } : { ok: total };
    },
  },
  {
    label: "zipWords",
    name: "zipWords",
    inTypes: ["bytes", "bytes"],
    outType: "bytes",
    gen: (rng) => {
      const a = genPayload(rng);
      if (rng() < 0.6) {
        // Same word count so the zip actually happens.
        const w = wordsOf(a);
        if (w) return [a, toPayload(w.map(() => genWord(rng)))];
      }
      return [a, genPayload(rng)];
    },
    ref: (a: Hex, b: Hex) => {
      const wa = wordsOf(a);
      if (!wa) return { revert: "UnalignedWords", args: [BigInt((a.length - 2) / 2)] };
      const wb = wordsOf(b);
      if (!wb) return { revert: "UnalignedWords", args: [BigInt((b.length - 2) / 2)] };
      if (wa.length !== wb.length) return { revert: "WordCountMismatch", args: [BigInt(wa.length), BigInt(wb.length)] };
      return { ok: toPayload(wa.flatMap((x, i) => [x, wb[i]])) };
    },
  },
  {
    label: "unzipWords",
    name: "unzipWords",
    inTypes: ["bytes", "uint256"],
    outType: "bytes",
    gen: (rng) => [genPayload(rng), BigInt(rng() < 0.85 ? randInt(rng, 0, 1) : randInt(rng, 2, 5))],
    ref: (s: Hex, which: bigint) => {
      const w = wordsOf(s);
      if (!w) return { revert: "UnalignedWords" };
      if (which > 1n) return { revert: "InvalidLane", args: [which] };
      return { ok: toPayload(w.filter((_, i) => BigInt(i % 2) === which)) };
    },
  },
];

describe("string/bytes differential fuzz", () => {
  for (const spec of SPECS) {
    it(`${spec.label} matches the JS oracle`, async () => {
      const base = SPECS.indexOf(spec) * 0x01000000;
      for (let i = 0; i < RUNS; i++) {
        const rng = mulberry32((SEED + (base + i) * 0x9e3779b9) >>> 0);
        await checkCase(spec, i, spec.gen(rng));
      }
    });
  }

  it("toString(parseUint(s)) normalizes and parseUint(toString(v)) round-trips", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = mulberry32((SEED + (0x7f000000 + i) * 0x9e3779b9) >>> 0);
      const v = rng() < 0.3 ? MAXU - BigInt(randInt(rng, 0, 5)) : genWord(rng);
      const s = await callFn("toString", ["uint256"], "string", [v]);
      assert.ok(s.ok, `toString(${v}) reverted`);
      const asBytes = toHexStr([...(s.value as string)].map((c) => c.charCodeAt(0)));
      const back = await callFn("parseUint", ["bytes"], "uint256", [asBytes]);
      assert.ok(back.ok && back.value === v, `[seed=${SEED} case=${i}] parseUint(toString(${v})) = ${back.ok ? back.value : back.errorName}`);
    }
  });
});
