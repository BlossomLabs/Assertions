// Differential fuzzer for the Operators math vocabulary. Every function
// with an exact mathematical definition is fuzzed against a BigInt oracle
// that computes the same thing with unbounded integers — including the
// EXACT revert expected (Panic(0x11) overflow, Panic(0x12) division by
// zero, bare revert) — so checked semantics, truncation direction and
// panic codes are all part of the contract being verified.
//
// The transcendentals (expWad, lnWad) have no exact integer oracle, so
// they get a three-way check: a double-precision float reference with a
// tolerance far below any real bug but far above float noise, exact
// anchors (expWad(0), e, ln(1e18)), and the lnWad∘expWad round trip.
//
// Deterministic: FUZZ_SEED / FUZZ_RUNS env vars override the defaults
// (FUZZ_RUNS is per-operator here), and every failure message carries the
// seed + case number to replay it.

import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { network } from "hardhat";
import { decodeErrorResult, encodeFunctionData, type Hex } from "viem";

const SEED = Number(process.env.FUZZ_SEED ?? 20260811);
const RUNS = Number(process.env.FUZZ_RUNS ?? 100);

const U256 = 1n << 256n;
const MAXU = U256 - 1n;
const I_MAX = (1n << 255n) - 1n;
const I_MIN = -(1n << 255n);
const WAD = 10n ** 18n;

// Boundaries and anchors of the wad transcendentals.
const EXP_OVERFLOW = 135305999368893231589n; // expWad reverts at and above
const EXP_UNDERFLOW = -42139678854452767551n; // expWad returns 0 at and below
const E_WAD = 2718281828459045235n; // floor(e * 1e18)

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

function randBig(rng: Rng, bits: number): bigint {
  let s = "0x0";
  for (let i = 0; i < Math.ceil(bits / 8); i++) s += randInt(rng, 0, 255).toString(16).padStart(2, "0");
  return BigInt(s);
}

// Biased operand pools: the bugs live at 0, 1, type boundaries and powers
// of two/ten, so those get far more weight than uniform sampling gives.
function genU(rng: Rng): bigint {
  const r = rng();
  if (r < 0.25) return BigInt(randInt(rng, 0, 10));
  if (r < 0.35) return 10n ** BigInt(randInt(rng, 1, 27));
  if (r < 0.45) return (1n << BigInt(randInt(rng, 1, 255))) + BigInt(randInt(rng, -1, 1));
  if (r < 0.55) return MAXU - BigInt(randInt(rng, 0, 3));
  if (r < 0.75) return randBig(rng, 64);
  return randBig(rng, 256) & MAXU;
}

function genI(rng: Rng): bigint {
  const r = rng();
  if (r < 0.1) return I_MIN + BigInt(randInt(rng, 0, 2));
  if (r < 0.2) return I_MAX - BigInt(randInt(rng, 0, 2));
  if (r < 0.35) return BigInt(randInt(rng, -10, 10));
  const v = randBig(rng, 256) & MAXU;
  return v > I_MAX ? v - U256 : v;
}

// ============ Oracles ============

type Expect = { ok: bigint } | { revert: string };

const P11: Expect = { revert: "Panic11" }; // arithmetic overflow
const P12: Expect = { revert: "Panic12" }; // division / modulo by zero
const BARE: Expect = { revert: "<empty>" }; // revert() with no data

const okU = (v: bigint): Expect => (v < 0n || v > MAXU ? P11 : { ok: v });
const okI = (v: bigint): Expect => (v < I_MIN || v > I_MAX ? P11 : { ok: v });

function mulDivRef(a: bigint, b: bigint, d: bigint): Expect {
  if (d === 0n) return P12;
  const q = (a * b) / d;
  return q > MAXU ? P11 : { ok: q };
}

function mulDivUpRef(a: bigint, b: bigint, d: bigint): Expect {
  if (d === 0n) return P12;
  const q = (a * b + d - 1n) / d;
  return q > MAXU ? P11 : { ok: q };
}

function expRef(a: bigint, b: bigint): Expect {
  if (a === 0n) return { ok: b === 0n ? 1n : 0n };
  if (a === 1n) return { ok: 1n };
  if (b > 256n) return P11; // a >= 2, so a^b >= 2^257
  const v = a ** b;
  return v > MAXU ? P11 : { ok: v };
}

function isqrt(x: bigint): bigint {
  if (x < 2n) return x;
  let r = 1n << BigInt(Math.ceil(x.toString(2).length / 2));
  while (true) {
    const next = (r + x / r) >> 1n;
    if (next >= r) return r;
    r = next;
  }
}

// Mirror of rpow's fixed-point binary exponentiation, floored mulDiv per
// step — bit-identical by construction, so any divergence is a Solidity-
// level bug (overflow handling, checked arithmetic), not rounding noise.
function rpowRef(x: bigint, n: bigint, base: bigint): Expect {
  if (base === 0n) return BARE;
  if (x === 0n) return { ok: n === 0n ? base : 0n };
  let result = base;
  while (n > 0n) {
    if (n & 1n) {
      const r = mulDivRef(result, x, base);
      if ("revert" in r) return r;
      result = r.ok;
    }
    n >>= 1n;
    if (n > 0n) {
      const r = mulDivRef(x, x, base);
      if ("revert" in r) return r;
      x = r.ok;
    }
  }
  return { ok: result };
}

// ============ Revert decoding ============

const ERROR_ABI = [
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

function revertLabel(data: Hex): string {
  if (data === "0x") return "<empty>";
  try {
    const d = decodeErrorResult({ abi: ERROR_ABI, data });
    if (d.errorName === "Panic") return "Panic" + (d.args[0] as bigint).toString(16);
    return d.errorName;
  } catch {
    return "<unknown " + data.slice(0, 10) + ">";
  }
}

// ============ Harness ============

const { viem } = await network.connect();
const publicClient = await viem.getPublicClient();
const operators = await viem.deployContract("Operators");

type CallResult = { ok: true; value: bigint } | { ok: false; errorName: string };

// Overloads (add/sub/min/... exist for uint256 AND int256) make name-based
// encoding ambiguous, so every call builds its exact single-function ABI.
async function callOp(name: string, inTypes: string[], args: bigint[], signedOut: boolean): Promise<CallResult> {
  const abi = [
    {
      type: "function",
      name,
      stateMutability: "view",
      inputs: inTypes.map((t) => ({ type: t })),
      outputs: [{ type: "uint256" }],
    },
  ] as const;
  try {
    const res = await publicClient.call({
      to: operators.address,
      data: encodeFunctionData({ abi, functionName: name, args }),
    });
    let v = BigInt(res.data ?? "0x0");
    if (signedOut && v > I_MAX) v -= U256;
    return { ok: true, value: v };
  } catch (err) {
    const raw = revertDataOf(err);
    if (raw === null) throw err;
    return { ok: false, errorName: revertLabel(raw) };
  }
}

function ctxOf(spec: string, i: number, args: bigint[], expect: Expect, got: CallResult): string {
  const e = "ok" in expect ? `ok ${expect.ok}` : `revert ${expect.revert}`;
  const g = got.ok ? `ok ${got.value}` : `revert ${got.errorName}`;
  return `[seed=${SEED} case=${i}] ${spec}(${args.map(String).join(", ")}) — expected ${e}, got ${g}`;
}

async function checkCase(spec: OpSpec, i: number, args: bigint[]): Promise<void> {
  const expect = spec.ref(...args);
  const got = await callOp(spec.name, spec.inTypes, args, spec.signedOut ?? false);
  const ctx = ctxOf(spec.label, i, args, expect, got);
  if ("ok" in expect) {
    assert.ok(got.ok, ctx);
    assert.equal(got.value, expect.ok, ctx);
  } else {
    assert.ok(!got.ok, ctx);
    assert.equal(got.errorName, expect.revert, ctx);
  }
}

// ============ The operator table ============

interface OpSpec {
  label: string; // unique display name (overloads share `name`)
  name: string;
  inTypes: string[];
  signedOut?: boolean;
  gen: (rng: Rng) => bigint[];
  ref: (...args: bigint[]) => Expect;
}

const bool = (b: boolean): Expect => ({ ok: b ? 1n : 0n });
const uu = (rng: Rng) => [genU(rng), genU(rng)];
const ii = (rng: Rng) => [genI(rng), genI(rng)];
const uuu = (rng: Rng) => [genU(rng), genU(rng), genU(rng)];
const shift = (rng: Rng): bigint => (rng() < 0.7 ? BigInt(randInt(rng, 0, 300)) : genU(rng));
const clampShift = (b: bigint) => (b > 256n ? 256n : b);

const SPECS: OpSpec[] = [
  // ---- unsigned arithmetic ----
  { label: "add(u)", name: "add", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => okU(a + b) },
  { label: "sub(u)", name: "sub", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => okU(a - b) },
  { label: "mul(u)", name: "mul", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => okU(a * b) },
  { label: "div(u)", name: "div", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => (b === 0n ? P12 : { ok: a / b }) },
  { label: "mod(u)", name: "mod", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => (b === 0n ? P12 : { ok: a % b }) },
  { label: "exp", name: "exp", inTypes: ["uint256", "uint256"], gen: uu, ref: expRef },
  { label: "min(u)", name: "min", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => ({ ok: a < b ? a : b }) },
  { label: "max(u)", name: "max", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => ({ ok: a > b ? a : b }) },
  { label: "absDiff(u)", name: "absDiff", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => ({ ok: a > b ? a - b : b - a }) },
  { label: "mulDiv", name: "mulDiv", inTypes: ["uint256", "uint256", "uint256"], gen: uuu, ref: mulDivRef },
  { label: "mulDivUp", name: "mulDivUp", inTypes: ["uint256", "uint256", "uint256"], gen: uuu, ref: mulDivUpRef },
  { label: "addMod", name: "addMod", inTypes: ["uint256", "uint256", "uint256"], gen: uuu, ref: (a, b, m) => (m === 0n ? P12 : { ok: (a + b) % m }) },
  { label: "mulMod", name: "mulMod", inTypes: ["uint256", "uint256", "uint256"], gen: uuu, ref: (a, b, m) => (m === 0n ? P12 : { ok: (a * b) % m }) },
  {
    label: "sqrt",
    name: "sqrt",
    inTypes: ["uint256"],
    // Perfect squares and their neighbors are where floor(sqrt) breaks.
    gen: (rng) => {
      const r = rng();
      if (r < 0.4) {
        const root = randBig(rng, 2 * randInt(rng, 1, 64)) & ((1n << 128n) - 1n);
        const sq = root * root + BigInt(randInt(rng, -1, 1));
        return [sq < 0n ? 0n : sq];
      }
      return [genU(rng)];
    },
    ref: (x) => ({ ok: isqrt(x) }),
  },
  { label: "log2", name: "log2", inTypes: ["uint256"], gen: (rng) => [genU(rng)], ref: (x) => (x === 0n ? BARE : { ok: BigInt(x.toString(2).length - 1) }) },
  // ---- signed arithmetic ----
  { label: "add(i)", name: "add", inTypes: ["int256", "int256"], signedOut: true, gen: ii, ref: (a, b) => okI(a + b) },
  { label: "sub(i)", name: "sub", inTypes: ["int256", "int256"], signedOut: true, gen: ii, ref: (a, b) => okI(a - b) },
  { label: "mul(i)", name: "mul", inTypes: ["int256", "int256"], signedOut: true, gen: ii, ref: (a, b) => okI(a * b) },
  {
    label: "div(i)",
    name: "div",
    inTypes: ["int256", "int256"],
    signedOut: true,
    gen: ii,
    ref: (a, b) => (b === 0n ? P12 : a === I_MIN && b === -1n ? P11 : { ok: a / b }),
  },
  { label: "mod(i)", name: "mod", inTypes: ["int256", "int256"], signedOut: true, gen: ii, ref: (a, b) => (b === 0n ? P12 : { ok: a % b }) },
  { label: "min(i)", name: "min", inTypes: ["int256", "int256"], signedOut: true, gen: ii, ref: (a, b) => ({ ok: a < b ? a : b }) },
  { label: "max(i)", name: "max", inTypes: ["int256", "int256"], signedOut: true, gen: ii, ref: (a, b) => ({ ok: a > b ? a : b }) },
  { label: "absDiff(i)", name: "absDiff", inTypes: ["int256", "int256"], gen: ii, ref: (a, b) => ({ ok: a > b ? a - b : b - a }) },
  // ---- comparisons ----
  { label: "eq", name: "eq", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => bool(a === b) },
  { label: "ne", name: "ne", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => bool(a !== b) },
  { label: "lt(u)", name: "lt", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => bool(a < b) },
  { label: "gt(u)", name: "gt", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => bool(a > b) },
  { label: "le(u)", name: "le", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => bool(a <= b) },
  { label: "ge(u)", name: "ge", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => bool(a >= b) },
  { label: "lt(i)", name: "lt", inTypes: ["int256", "int256"], gen: ii, ref: (a, b) => bool(a < b) },
  { label: "gt(i)", name: "gt", inTypes: ["int256", "int256"], gen: ii, ref: (a, b) => bool(a > b) },
  { label: "le(i)", name: "le", inTypes: ["int256", "int256"], gen: ii, ref: (a, b) => bool(a <= b) },
  { label: "ge(i)", name: "ge", inTypes: ["int256", "int256"], gen: ii, ref: (a, b) => bool(a >= b) },
  // ---- bitwise ----
  { label: "bitAnd", name: "bitAnd", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => ({ ok: a & b }) },
  { label: "bitOr", name: "bitOr", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => ({ ok: a | b }) },
  { label: "bitXor", name: "bitXor", inTypes: ["uint256", "uint256"], gen: uu, ref: (a, b) => ({ ok: a ^ b }) },
  {
    label: "shl",
    name: "shl",
    inTypes: ["uint256", "uint256"],
    gen: (rng) => [genU(rng), shift(rng)],
    ref: (a, b) => ({ ok: b > 255n ? 0n : (a << b) & MAXU }),
  },
  {
    label: "shr(u)",
    name: "shr",
    inTypes: ["uint256", "uint256"],
    gen: (rng) => [genU(rng), shift(rng)],
    ref: (a, b) => ({ ok: a >> clampShift(b) }),
  },
  {
    label: "shr(i,sar)",
    name: "shr",
    inTypes: ["int256", "uint256"],
    signedOut: true,
    gen: (rng) => [genI(rng), shift(rng)],
    ref: (a, b) => ({ ok: a >> clampShift(b) }),
  },
  {
    label: "bitSet",
    name: "bitSet",
    inTypes: ["uint256", "uint256"],
    gen: (rng) => [genU(rng), shift(rng)],
    ref: (mask, i) => bool(((mask >> clampShift(i)) & 1n) === 1n),
  },
];

describe("operator differential fuzz", () => {
  for (const spec of SPECS) {
    it(`${spec.label} matches the bigint oracle`, async () => {
      const base = SPECS.indexOf(spec) * 0x01000000;
      for (let i = 0; i < RUNS; i++) {
        const rng = mulberry32((SEED + (base + i) * 0x9e3779b9) >>> 0);
        await checkCase(spec, i, spec.gen(rng));
      }
    });
  }
});

// ============ rpow ============

describe("rpow differential fuzz", () => {
  it("matches the mirrored fixed-point oracle exactly", async () => {
    for (let i = 0; i < RUNS * 2; i++) {
      const rng = mulberry32((SEED + (0x30000000 + i) * 0x9e3779b9) >>> 0);
      const bases = [WAD, 10n ** 27n, 1n, 2n, 10n ** 6n, randBig(rng, 32) + 1n, genU(rng)];
      let base = bases[randInt(rng, 0, bases.length - 1)];
      if (rng() < 0.05) base = 0n;
      const r = rng();
      let x: bigint;
      if (r < 0.5) {
        x = base + BigInt(randInt(rng, -1000, 1000));
      } else if (r < 0.7) {
        x = base * BigInt(randInt(rng, 0, 5));
      } else {
        x = genU(rng);
      }
      if (x < 0n) x = 0n;
      if (x > MAXU) x = MAXU;
      const ns = [0n, 1n, 2n, 3n, BigInt(randInt(rng, 4, 20)), 31536000n, randBig(rng, 32), randBig(rng, 256)];
      const n = ns[randInt(rng, 0, ns.length - 1)];

      const expect = rpowRef(x, n, base);
      const got = await callOp("rpow", ["uint256", "uint256", "uint256"], [x, n, base], false);
      const ctx = ctxOf("rpow", i, [x, n, base], expect, got);
      if ("ok" in expect) {
        assert.ok(got.ok, ctx);
        assert.equal(got.value, expect.ok, ctx);
      } else {
        assert.ok(!got.ok, ctx);
        assert.equal(got.errorName, expect.revert, ctx);
      }

      // Independent of the mirror: for small n the exact real value is
      // computable, and step-flooring may only round DOWN, by a bounded
      // amount for rate-like x.
      if ("ok" in expect && got.ok && n >= 1n && n <= 10n && base > 0n && x > 0n) {
        const exact = x ** n / base ** (n - 1n);
        assert.ok(got.value <= exact, `${ctx} — rpow exceeded the exact value ${exact}`);
        if (x <= 2n * base) {
          assert.ok(exact - got.value <= 2048n, `${ctx} — rpow lost more than the rounding bound vs ${exact}`);
        }
      }
    }
  });
});

// ============ expWad / lnWad ============

async function callWad(name: string, x: bigint): Promise<CallResult> {
  return callOp(name, ["int256"], [x], true);
}

function assertClose(actual: bigint, ref: number, absTol: number, ctx: string): void {
  const diff = Math.abs(Number(actual) - ref);
  const tol = Math.max(absTol, Math.abs(ref) * 1e-12);
  assert.ok(diff <= tol, `${ctx} — got ${actual}, float reference ${ref}, diff ${diff} > tol ${tol}`);
}

describe("wad transcendental fuzz", () => {
  it("expWad tracks e^x, its boundaries and anchors", async () => {
    // Exact anchors first: the identity and floor(e * 1e18).
    const one = await callWad("expWad", 0n);
    assert.ok(one.ok && one.value === WAD, `expWad(0) = ${one.ok ? one.value : one.errorName}, expected 1e18`);
    const e = await callWad("expWad", WAD);
    assert.ok(e.ok && e.value >= E_WAD - 2n && e.value <= E_WAD + 2n, `expWad(1e18) = ${e.ok ? e.value : e.errorName}, expected ~${E_WAD}`);
    // Boundary behavior, exact.
    const over = await callWad("expWad", EXP_OVERFLOW);
    assert.ok(!over.ok, "expWad must revert at its documented overflow bound");
    const under = await callWad("expWad", EXP_UNDERFLOW);
    assert.ok(under.ok && under.value === 0n, "expWad must return 0 at its documented underflow bound");

    for (let i = 0; i < RUNS * 2; i++) {
      const rng = mulberry32((SEED + (0x10000000 + i) * 0x9e3779b9) >>> 0);
      const r = rng();
      let x: bigint;
      if (r < 0.5) {
        // Uniform across the whole live range, cutoffs included.
        x = -45n * WAD + (randBig(rng, 128) % (185n * WAD));
      } else if (r < 0.7) {
        x = (rng() < 0.5 ? EXP_OVERFLOW : EXP_UNDERFLOW) + BigInt(randInt(rng, -3, 3));
      } else if (r < 0.9) {
        x = BigInt(randInt(rng, -1000000, 1000000)); // near zero
      } else {
        x = genI(rng); // far outside: huge positive reverts, huge negative is 0
      }

      const got = await callWad("expWad", x);
      const ctx = `[seed=${SEED} case=${i}] expWad(${x})`;
      if (x >= EXP_OVERFLOW) {
        assert.ok(!got.ok && got.errorName === "<empty>", `${ctx} — expected bare revert, got ${got.ok ? got.value : got.errorName}`);
      } else if (x <= EXP_UNDERFLOW) {
        assert.ok(got.ok && got.value === 0n, `${ctx} — expected 0, got ${got.ok ? got.value : got.errorName}`);
      } else {
        assert.ok(got.ok, `${ctx} — unexpected revert ${got.ok ? "" : got.errorName}`);
        assertClose(got.value, Math.exp(Number(x) / 1e18) * 1e18, 5, ctx);
      }
    }
  });

  it("lnWad tracks ln(x) and rejects the non-positive domain", async () => {
    const zero = await callWad("lnWad", WAD);
    assert.ok(zero.ok && zero.value >= -1n && zero.value <= 1n, `lnWad(1e18) = ${zero.ok ? zero.value : zero.errorName}, expected ~0`);
    for (const bad of [0n, -1n, -WAD, I_MIN]) {
      const got = await callWad("lnWad", bad);
      assert.ok(!got.ok && got.errorName === "<empty>", `lnWad(${bad}) must bare-revert, got ${got.ok ? got.value : got.errorName}`);
    }

    for (let i = 0; i < RUNS * 2; i++) {
      const rng = mulberry32((SEED + (0x20000000 + i) * 0x9e3779b9) >>> 0);
      const r = rng();
      let x: bigint;
      if (r < 0.25) x = BigInt(randInt(rng, 1, 1000));
      else if (r < 0.5) x = WAD + BigInt(randInt(rng, -1000000, 1000000));
      else if (r < 0.75) x = randBig(rng, randInt(rng, 8, 128));
      else x = randBig(rng, 255) & I_MAX;
      if (x <= 0n) x = 1n;

      const got = await callWad("lnWad", x);
      const ctx = `[seed=${SEED} case=${i}] lnWad(${x})`;
      assert.ok(got.ok, `${ctx} — unexpected revert ${got.ok ? "" : got.errorName}`);
      assertClose(got.value, Math.log(Number(x) / 1e18) * 1e18, 1e5, ctx);
    }
  });

  it("lnWad inverts expWad within tolerance", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = mulberry32((SEED + (0x28000000 + i) * 0x9e3779b9) >>> 0);
      // Restricted to expWad(x) >= ~0.36e18 so the integer floor of the
      // exponential cannot dominate the round-trip error.
      const x = -WAD + (randBig(rng, 128) % (136n * WAD));
      const y = await callWad("expWad", x);
      if (!y.ok || y.value === 0n) continue;
      const back = await callWad("lnWad", y.value);
      const ctx = `[seed=${SEED} case=${i}] lnWad(expWad(${x})) via ${y.value}`;
      assert.ok(back.ok, `${ctx} — unexpected revert`);
      const diff = back.value - x;
      assert.ok(diff >= -1000000n && diff <= 1000000n, `${ctx} — round trip drifted by ${diff}`);
    }
  });
});
