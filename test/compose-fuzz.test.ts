// Differential fuzzer for the core's COMPOSITION surface: random expression
// trees over resolve / pick / nav / cond / orElse / isValid / chain / read /
// revertData / assertParam / assertComposable, with operands nested back into
// the core as STATIC_CALL fetchers — the self-referencing shapes the flat
// per-function fuzzers cannot reach. The oracle is a TypeScript interpreter
// of the documented resolution semantics; the load-bearing rule it mirrors
// is error WRAPPING: a failure inside a STATIC_CALL fetcher surfaces as
// CallFailed in the frame that resolves it (the inner reason is lost), while
// constraint, address-word and bounds failures surface under their own names
// in the frame that checks them, and orElse / isValid catch everything
// through the self-staticcall boundary.
//
// The second half fuzzes the Operators fold/map/filter family against
// DEPLOYED lambda targets, which the string/math fuzzers deliberately left
// out. Operators-target templates are simulated at the byte level (the
// accumulator window is stamped first, then each element window in
// elemOffsets order), so overlapping and UNALIGNED window offsets are
// checked exactly, not just the well-formed ones. Core-target templates —
// full resolve(...) calldata with marker words found by SCANNING the
// encoded bytes, one and two ABI layers deep — tie the two halves together:
// the fold's lambda is itself a core expression.
//
// Deterministic: FUZZ_SEED / FUZZ_RUNS env vars override the defaults, and
// every failure message carries the seed + case number to replay it.

import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { network } from "hardhat";
import {
  decodeErrorResult,
  encodeAbiParameters,
  encodeErrorResult,
  encodeFunctionData,
  type Hex,
} from "viem";

const SEED = Number(process.env.FUZZ_SEED ?? 20260811);
const RUNS = Number(process.env.FUZZ_RUNS ?? 200);

const U256 = 1n << 256n;
const MAXU = U256 - 1n;

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

function hexBytes(rng: Rng, n: number): string {
  let s = "";
  for (let i = 0; i < n; i++) s += randInt(rng, 0, 255).toString(16).padStart(2, "0");
  return s;
}

function randBig(rng: Rng, bits: number): bigint {
  return BigInt("0x0" + hexBytes(rng, Math.ceil(bits / 8)));
}

// ============ Hex helpers ============

const byteLen = (h: Hex): number => (h.length - 2) / 2;

function word(n: bigint): Hex {
  return ("0x" + n.toString(16).padStart(64, "0")) as Hex;
}

// The 32-byte word at byte offset `off`, or null when it overruns the data.
function wordAt(h: Hex, off: number): bigint | null {
  if (byteLen(h) < off + 32) return null;
  return BigInt("0x" + h.slice(2 + off * 2, 2 + (off + 32) * 2));
}

function catHex(...parts: Hex[]): Hex {
  return ("0x" + parts.map((p) => p.slice(2)).join("")) as Hex;
}

function addrWord(addr: string): Hex {
  return ("0x" + "00".repeat(12) + addr.slice(2).toLowerCase()) as Hex;
}

// ============ Expectations and revert decoding ============

type Expect = { ok: Hex } | { revert: string };

const REV = (name: string): Expect => ({ revert: name });

const ERROR_ABI = [
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
  { type: "error", name: "InvalidBalanceData", inputs: [{ type: "uint256" }, { type: "uint256" }, { type: "uint256" }] },
  {
    type: "error",
    name: "InvalidConstraintData",
    inputs: [{ type: "uint256" }, { type: "uint256" }, { type: "uint256" }, { type: "uint256" }],
  },
  { type: "error", name: "ReturnDataOutOfBounds", inputs: [{ type: "int256" }, { type: "uint256" }] },
  { type: "error", name: "InvalidAddressWord", inputs: [{ type: "uint256" }, { type: "bytes32" }] },
  { type: "error", name: "InvalidNavigation", inputs: [{ type: "uint256" }] },
  { type: "error", name: "InvalidTypeDescriptor", inputs: [{ type: "uint256" }] },
  { type: "error", name: "ElementIndexOutOfBounds", inputs: [{ type: "int256" }, { type: "uint256" }] },
  { type: "error", name: "OutputParamsNotSupported", inputs: [{ type: "uint256" }] },
  { type: "error", name: "ValueParamNotSupported", inputs: [{ type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "DuplicateTargetParam", inputs: [{ type: "uint256" }] },
  { type: "error", name: "BalanceCannotBeTarget", inputs: [{ type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "EmptyCallChain", inputs: [] },
  { type: "error", name: "RevertProbeNotACall", inputs: [{ type: "uint8" }] },
  { type: "error", name: "RevertProbeConstrained", inputs: [{ type: "uint256" }] },
  { type: "error", name: "DidNotRevert", inputs: [{ type: "address" }, { type: "bytes" }] },
  { type: "error", name: "UnexpectedRevertData", inputs: [{ type: "bytes4" }, { type: "bytes4" }] },
  { type: "error", name: "LambdaOffsetOutOfBounds", inputs: [{ type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "LambdaCallFailed", inputs: [{ type: "uint256" }, { type: "address" }, { type: "bytes" }] },
  { type: "error", name: "LambdaReturnTooShort", inputs: [{ type: "uint256" }, { type: "uint256" }] },
  { type: "error", name: "UnalignedWords", inputs: [{ type: "uint256" }] },
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

const CORE = assertions.address as Hex;
const OPS = operators.address as Hex;
const CORE_W = addrWord(CORE);
const OPS_W = addrWord(OPS);

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

function coreCalldata(fn: string, args: unknown[]): Hex {
  return encodeFunctionData({ abi: assertions.abi, functionName: fn as any, args: args as any });
}

// Single-function ABIs sidestep the uint/int overloads, as in math-fuzz.
function opCalldata(name: string, args: bigint[]): Hex {
  const abi = [
    {
      type: "function",
      name,
      stateMutability: "view",
      inputs: args.map(() => ({ type: "uint256" })),
      outputs: [{ type: "uint256" }],
    },
  ] as const;
  return encodeFunctionData({ abi, functionName: name, args });
}

async function checkExpr(label: string, i: number, desc: string, to: Hex, data: Hex, expect: Expect): Promise<void> {
  const got = await rawCall(to, data);
  const e = "ok" in expect ? `ok ${expect.ok}` : `revert ${expect.revert}`;
  const g = got.ok ? `ok ${got.data}` : `revert ${got.errorName}`;
  const ctx = `[seed=${SEED} case=${i}] ${label} ${desc} — expected ${e}, got ${g}`;
  if ("ok" in expect) {
    assert.ok(got.ok, ctx);
    assert.equal(got.data, expect.ok.toLowerCase(), ctx);
  } else {
    assert.ok(!got.ok, ctx);
    assert.equal(got.errorName, expect.revert, ctx);
  }
}

// ============ InputParams with oracles ============

interface ConsStruct {
  constraintType: number;
  referenceData: Hex;
}

interface ParamStruct {
  paramType: number;
  fetcherType: number;
  paramData: Hex;
  constraints: ConsStruct[];
}

interface P {
  struct: ParamStruct;
  expect: Expect; // outcome of _resolve(param) in the resolving frame
  desc: string;
}

// Constraints against a KNOWN resolved value: chosen to pass or to fail
// deliberately, with the occasional malformed referenceData. Returns the
// structs plus the error of the first violated / malformed one (validation
// order matters: the contract reports the FIRST bad constraint).
function genConstraints(rng: Rng, value: Hex): { list: ConsStruct[]; verdict: string | null; desc: string } {
  if (rng() < 0.55) return { list: [], verdict: null, desc: "" };
  if (byteLen(value) < 32) {
    // _validateConstraints reads the first word before anything else.
    return {
      list: [{ constraintType: 0, referenceData: word(0n) }],
      verdict: "ReturnDataOutOfBounds",
      desc: "{EQ on short}",
    };
  }
  const w = wordAt(value, 0)!;
  const n = rng() < 0.75 ? 1 : 2;
  const list: ConsStruct[] = [];
  const tags: string[] = [];
  let verdict: string | null = null;
  for (let k = 0; k < n; k++) {
    const r = rng();
    if (r < 0.07) {
      list.push({ constraintType: 0, referenceData: ("0x" + hexBytes(rng, 16)) as Hex });
      tags.push("EQ:malformed");
      verdict ??= "InvalidConstraintData";
      continue;
    }
    // Aim to pass or fail; at the type boundaries a requested failure may be
    // unsatisfiable (nothing exceeds MAXU), so `fails` is recomputed from the
    // actual reference, never assumed.
    const pass = rng() < 0.7;
    const t = randInt(rng, 0, 3);
    let fails: boolean;
    if (t === 0) {
      const ref = pass ? w : w ^ 1n;
      list.push({ constraintType: 0, referenceData: word(ref) });
      fails = ref !== w;
      tags.push(fails ? "EQ✗" : "EQ✓");
    } else if (t === 1) {
      const ref = pass ? (rng() < 0.5 ? w : w >> 1n) : w === MAXU ? 0n : w + 1n;
      list.push({ constraintType: 1, referenceData: word(ref) });
      fails = w < ref;
      tags.push(fails ? "GTE✗" : "GTE✓");
    } else if (t === 2) {
      const ref = pass ? (rng() < 0.5 ? w : MAXU) : w === 0n ? MAXU : w - 1n;
      list.push({ constraintType: 2, referenceData: word(ref) });
      fails = w > ref;
      tags.push(fails ? "LTE✗" : "LTE✓");
    } else {
      let lo: bigint;
      let hi: bigint;
      if (pass) {
        lo = w >= 2n && rng() < 0.5 ? w - (randBig(rng, 8) % w) : 0n;
        hi = w <= MAXU - 2n && rng() < 0.5 ? w + (randBig(rng, 8) % (MAXU - w)) : MAXU;
      } else if (w < MAXU) {
        lo = w + 1n;
        hi = MAXU;
      } else {
        lo = 0n;
        hi = w - 1n;
      }
      list.push({ constraintType: 3, referenceData: catHex(word(lo), word(hi)) });
      fails = w < lo || w > hi;
      tags.push(fails ? "IN✗" : "IN✓");
    }
    if (fails) verdict ??= "ConstraintFailed";
  }
  return { list, verdict, desc: "{" + tags.join(",") + "}" };
}

// Wraps a fetch outcome into a full param: constraints attach on top and the
// combined resolution expectation is computed here, in validation order.
function finishParam(
  rng: Rng,
  fetcherType: number,
  paramData: Hex,
  fetch: Expect,
  desc: string,
  allowConstraints = true
): P {
  let constraints: ConsStruct[] = [];
  let expect = fetch;
  let cdesc = "";
  if ("ok" in fetch && allowConstraints) {
    const c = genConstraints(rng, fetch.ok);
    constraints = c.list;
    cdesc = c.desc;
    if (c.verdict) expect = REV(c.verdict);
  }
  return {
    struct: { paramType: 2, fetcherType, paramData, constraints },
    expect,
    desc: desc + cdesc,
  };
}

// ---- Leaves ----

function genRawValue(rng: Rng): Hex {
  const r = rng();
  if (r < 0.06) return "0x";
  if (r < 0.18) return ("0x" + hexBytes(rng, randInt(rng, 1, 31))) as Hex;
  const words = r < 0.62 ? 1 : r < 0.78 ? 2 : randInt(rng, 3, 6);
  const parts: Hex[] = [];
  for (let i = 0; i < words; i++) {
    const p = rng();
    if (p < 0.3) parts.push(word(BigInt(randInt(rng, 0, 5))));
    else if (p < 0.4) parts.push(word(MAXU - BigInt(randInt(rng, 0, 2))));
    else if (p < 0.5) parts.push(OPS_W);
    else if (p < 0.55) parts.push(word((1n << 160n) + randBig(rng, 32)));
    else parts.push(word(randBig(rng, 256) & MAXU));
  }
  const out = catHex(...parts);
  // Occasionally shear the tail so lengths go unaligned.
  if (rng() < 0.12) return out.slice(0, out.length - randInt(rng, 1, 30) * 2) as Hex;
  return out;
}

function rawLeaf(rng: Rng): P {
  const v = genRawValue(rng);
  return finishParam(rng, 0, v, { ok: v }, `raw[${byteLen(v)}]`);
}

function balanceLeaf(rng: Rng): P {
  const r = rng();
  if (r < 0.15) {
    const bad = ("0x" + hexBytes(rng, randInt(rng, 0, 39))) as Hex;
    return finishParam(rng, 2, bad, REV("InvalidBalanceData"), `bal[len=${byteLen(bad)}]`);
  }
  const account = "0x" + hexBytes(rng, 20);
  if (r < 0.65) {
    // Native balance of a random (empty) account: zero, deterministically.
    const data = ("0x" + "00".repeat(20) + account.slice(2)) as Hex;
    return finishParam(rng, 2, data, { ok: word(0n) }, "bal[native0]");
  }
  if (r < 0.85) {
    // Token with code but no balanceOf: the fetcher's staticcall reverts.
    const data = (OPS + account.slice(2)) as Hex;
    return finishParam(rng, 2, data, REV("CallFailed"), "bal[ops-token]");
  }
  // Code-less token: _staticCall rejects it before calling.
  const data = ("0x" + hexBytes(rng, 20) + account.slice(2)) as Hex;
  return finishParam(rng, 2, data, REV("CallFailed"), "bal[eoa-token]");
}

// Word-level Operators leaves with exact bigint references. Only ok/revert
// matters for nesting: a leaf revert always surfaces as CallFailed.
type OpRef = (a: bigint, b: bigint) => bigint | null; // null = reverts

const OP_LEAVES: { name: string; ref: OpRef }[] = [
  { name: "add", ref: (a, b) => (a + b > MAXU ? null : a + b) },
  { name: "sub", ref: (a, b) => (a < b ? null : a - b) },
  { name: "mul", ref: (a, b) => (a * b > MAXU ? null : a * b) },
  { name: "div", ref: (a, b) => (b === 0n ? null : a / b) },
  { name: "mod", ref: (a, b) => (b === 0n ? null : a % b) },
  { name: "min", ref: (a, b) => (a < b ? a : b) },
  { name: "max", ref: (a, b) => (a > b ? a : b) },
  { name: "lt", ref: (a, b) => (a < b ? 1n : 0n) },
  { name: "eq", ref: (a, b) => (a === b ? 1n : 0n) },
  { name: "bitXor", ref: (a, b) => a ^ b },
];

function genOpArg(rng: Rng): bigint {
  const r = rng();
  if (r < 0.4) return BigInt(randInt(rng, 0, 10));
  if (r < 0.55) return MAXU - BigInt(randInt(rng, 0, 2));
  if (r < 0.7) return randBig(rng, 64);
  if (r < 0.8) return (1n << 160n) + randBig(rng, 16);
  return randBig(rng, 256) & MAXU;
}

function scFetch(rng: Rng, to: Hex, data: Hex, inner: Expect, desc: string, allowConstraints = true): P {
  const paramData = encodeAbiParameters([{ type: "address" }, { type: "bytes" }], [to, data]);
  const fetch: Expect = "ok" in inner ? inner : REV("CallFailed");
  return finishParam(rng, 1, paramData, fetch, desc, allowConstraints);
}

function opLeaf(rng: Rng): P {
  if (rng() < 0.1) {
    // iotaWords: a bytes-returning leaf, so envelopes flow through operands.
    const n = randInt(rng, 0, 4);
    const payload = catHex(...Array.from({ length: n }, (_, i) => word(BigInt(i))));
    const env = encodeAbiParameters([{ type: "bytes" }], [payload]);
    return scFetch(rng, OPS, opCalldata("iotaWords", [BigInt(n)]), { ok: env }, `sc:iota(${n})`);
  }
  const op = OP_LEAVES[randInt(rng, 0, OP_LEAVES.length - 1)];
  const a = genOpArg(rng);
  const b = genOpArg(rng);
  const v = op.ref(a, b);
  return scFetch(
    rng,
    OPS,
    opCalldata(op.name, [a, b]),
    v === null ? REV("op-revert") : { ok: word(v) },
    `sc:${op.name}`
  );
}

// ============ Expression trees ============

interface Expr {
  data: Hex; // calldata to the core
  expect: Expect; // outcome of calling it directly
  desc: string;
}

function exprAsParam(rng: Rng, e: Expr): P {
  return scFetch(rng, CORE, e.data, e.expect, `[${e.desc}]`);
}

function genParam(rng: Rng, depth: number): P {
  const r = rng();
  if (depth > 0 && r < 0.38) return exprAsParam(rng, genExpr(rng, depth - 1));
  if (r < 0.62) return rawLeaf(rng);
  if (r < 0.88) return opLeaf(rng);
  return balanceLeaf(rng);
}

function genResolve(rng: Rng, depth: number): Expr {
  const p = genParam(rng, depth);
  return { data: coreCalldata("resolve", [p.struct]), expect: p.expect, desc: `resolve(${p.desc})` };
}

function genPick(rng: Rng, depth: number): Expr {
  const p = genParam(rng, depth);
  let idx: bigint;
  let expect: Expect;
  if ("revert" in p.expect) {
    idx = BigInt(randInt(rng, -3, 3));
    expect = p.expect;
  } else {
    const v = p.expect.ok;
    const words = Math.floor(byteLen(v) / 32);
    const r = rng();
    if (words > 0 && r < 0.55) {
      const k = randInt(rng, 0, words - 1);
      idx = rng() < 0.4 ? BigInt(k - words) : BigInt(k);
      expect = { ok: ("0x" + v.slice(2 + k * 64, 2 + k * 64 + 64)) as Hex };
    } else if (r < 0.8) {
      idx = BigInt(words + randInt(rng, 0, 2));
      expect = REV("ReturnDataOutOfBounds");
    } else {
      idx = BigInt(-(words + 1 + randInt(rng, 0, 2)));
      expect = REV("ReturnDataOutOfBounds");
    }
  }
  return { data: coreCalldata("pick", [p.struct, idx]), expect, desc: `pick(${p.desc},${idx})` };
}

function genNav(rng: Rng, depth: number): Expr {
  const p = genParam(rng, depth);
  if (rng() < 0.7) {
    // Empty path: pure passthrough, the descriptor is never parsed.
    return { data: coreCalldata("nav", [p.struct, "(uint256)", []]), expect: p.expect, desc: `nav(${p.desc},[])` };
  }
  // A bare sentinel path has no steps to navigate: InvalidNavigation, but
  // only after the operand resolved.
  const LEN = -(1n << 255n);
  const expect: Expect = "revert" in p.expect ? p.expect : REV("InvalidNavigation");
  return { data: coreCalldata("nav", [p.struct, "(uint256)", [LEN]]), expect, desc: `nav(${p.desc},[LEN])` };
}

function genCond(rng: Rng, depth: number): Expr {
  const c = genParam(rng, depth);
  const t = genParam(rng, depth);
  const e = genParam(rng, depth);
  let expect: Expect;
  if ("revert" in c.expect) expect = c.expect;
  else if (byteLen(c.expect.ok) < 32) expect = REV("ReturnDataOutOfBounds");
  else expect = wordAt(c.expect.ok, 0)! !== 0n ? t.expect : e.expect;
  return {
    data: coreCalldata("cond", [c.struct, t.struct, e.struct]),
    expect,
    desc: `cond(${c.desc},${t.desc},${e.desc})`,
  };
}

function genOrElse(rng: Rng, depth: number): Expr {
  const a = genParam(rng, depth);
  const b = genParam(rng, depth);
  const expect = "ok" in a.expect ? a.expect : b.expect;
  return { data: coreCalldata("orElse", [a.struct, b.struct]), expect, desc: `orElse(${a.desc},${b.desc})` };
}

function genIsValid(rng: Rng, depth: number): Expr {
  const a = genParam(rng, depth);
  return {
    data: coreCalldata("isValid", [a.struct]),
    expect: { ok: word("ok" in a.expect ? 1n : 0n) },
    desc: `isValid(${a.desc})`,
  };
}

function genChain(rng: Rng, depth: number): Expr {
  // Start operand: mostly a clean route into a real contract, with the
  // documented failure modes mixed in.
  const r0 = rng();
  let start: P;
  let cur: "ops" | "core" | "dead" | null = null; // null = start fails
  if (r0 < 0.45) {
    start = finishParam(rng, 0, OPS_W, { ok: OPS_W }, "raw[ops]");
    cur = "ops";
  } else if (r0 < 0.6) {
    start = scFetch(rng, OPS, opCalldata("min", [BigInt(OPS_W), BigInt(OPS_W)]), { ok: OPS_W }, "sc:min[ops]");
    cur = "ops";
  } else if (r0 < 0.7) {
    start = finishParam(rng, 0, CORE_W, { ok: CORE_W }, "raw[core]", false);
    cur = "core";
  } else if (r0 < 0.78) {
    const short = ("0x" + hexBytes(rng, randInt(rng, 0, 31))) as Hex;
    start = finishParam(rng, 0, short, { ok: short }, "raw[short]", false);
  } else if (r0 < 0.86) {
    const dirty = word((1n << 160n) | randBig(rng, 80));
    start = finishParam(rng, 0, dirty, { ok: dirty }, "raw[dirty]", false);
  } else if (r0 < 0.94) {
    const dead = word(randBig(rng, 160) | (1n << 24n));
    start = finishParam(rng, 0, dead, { ok: dead }, "raw[eoa]", false);
    cur = "dead";
  } else {
    start = genParam(rng, depth);
    if ("ok" in start.expect) {
      const v = start.expect.ok;
      if (byteLen(v) < 32) cur = null;
      else {
        const w = wordAt(v, 0)!;
        if (w >> 160n !== 0n) cur = null;
        else cur = w === BigInt(OPS_W) ? "ops" : w === BigInt(CORE_W) ? "core" : "dead";
      }
    }
  }

  let expect: Expect | null = null;
  if ("revert" in start.expect) expect = start.expect;
  else if (cur === null) {
    const v = start.expect.ok;
    expect = byteLen(v) < 32 ? REV("ReturnDataOutOfBounds") : REV("InvalidAddressWord");
  }

  if (rng() < 0.06) {
    return {
      data: coreCalldata("chain", [start.struct, []]),
      expect: REV("EmptyCallChain"),
      desc: `chain(${start.desc},[])`,
    };
  }

  const nHops = randInt(rng, 1, 3);
  const calls: Hex[] = [];
  const hopTags: string[] = [];
  for (let h = 0; h < nHops; h++) {
    const last = h === nHops - 1;
    if (expect !== null) {
      // Outcome already decided upstream; fill with a benign hop.
      calls.push(opCalldata("add", [1n, 1n]));
      hopTags.push("fill");
      continue;
    }
    if (cur === "dead") {
      calls.push(opCalldata("add", [1n, 1n]));
      hopTags.push("dead");
      expect = REV("CallFailed");
      continue;
    }
    const r = rng();
    if (cur === "ops") {
      if (last) {
        const op = OP_LEAVES[randInt(rng, 0, OP_LEAVES.length - 1)];
        const a = genOpArg(rng);
        const b = genOpArg(rng);
        calls.push(opCalldata(op.name, [a, b]));
        hopTags.push(`fin:${op.name}`);
        const v = op.ref(a, b);
        expect = v === null ? REV("CallFailed") : { ok: word(v) };
      } else if (r < 0.35) {
        calls.push(opCalldata("min", [BigInt(OPS_W), BigInt(OPS_W)]));
        hopTags.push("→ops");
      } else if (r < 0.65) {
        calls.push(opCalldata("min", [BigInt(CORE_W), BigInt(CORE_W)]));
        hopTags.push("→core");
        cur = "core";
      } else if (r < 0.78) {
        calls.push(opCalldata("div", [genOpArg(rng), 0n]));
        hopTags.push("div0");
        expect = REV("CallFailed");
      } else if (r < 0.9) {
        const dirty = (1n << 160n) + BigInt(randInt(rng, 0, 1000));
        calls.push(opCalldata("add", [dirty, 5n]));
        hopTags.push("dirty");
        expect = REV("InvalidAddressWord");
      } else {
        calls.push(opCalldata("add", [1n, 2n]));
        hopTags.push("→0x3");
        cur = "dead";
      }
    } else {
      // cur === "core": hop THROUGH the core with resolve(raw ...).
      const mk = (v: Hex) =>
        coreCalldata("resolve", [{ paramType: 2, fetcherType: 0, paramData: v, constraints: [] }]);
      if (last) {
        if (r < 0.3) {
          // Empty returndata is fine on the FINAL hop: returned raw.
          calls.push(mk("0x"));
          hopTags.push("fin:empty");
          expect = { ok: "0x" };
        } else {
          const v = genRawValue(rng);
          calls.push(mk(v));
          hopTags.push("fin:raw");
          expect = { ok: v };
        }
      } else if (r < 0.4) {
        calls.push(mk(OPS_W));
        hopTags.push("→ops");
        cur = "ops";
      } else if (r < 0.6) {
        // Empty returndata mid-chain: no word to read the next target from.
        calls.push(mk("0x"));
        hopTags.push("mid:empty");
        expect = REV("ReturnDataOutOfBounds");
      } else if (r < 0.8) {
        const dirty = word((1n << 200n) | 7n);
        calls.push(mk(dirty));
        hopTags.push("dirty");
        expect = REV("InvalidAddressWord");
      } else {
        calls.push(mk(CORE_W));
        hopTags.push("→core");
      }
    }
  }
  return {
    data: coreCalldata("chain", [start.struct, calls]),
    expect: expect ?? { ok: "0x" },
    desc: `chain(${start.desc},[${hopTags.join(",")}])`,
  };
}

const ADD_SELECTOR = opCalldata("add", [0n, 0n]).slice(0, 10) as Hex;
const RESOLVE_SELECTOR = coreCalldata("resolve", [
  { paramType: 2, fetcherType: 0, paramData: "0x", constraints: [] },
]).slice(0, 10) as Hex;

function genRead(rng: Rng, depth: number): Expr {
  const r0 = rng();
  if (r0 < 0.2) {
    // read(core, resolve, [pre-encoded tail]) ≡ resolve(param): the core as
    // its own read target.
    const p = genParam(rng, depth);
    const tail = ("0x" + coreCalldata("resolve", [p.struct]).slice(10)) as Hex;
    const target = finishParam(rng, 0, CORE_W, { ok: CORE_W }, "raw[core]", false);
    const arg = finishParam(rng, 0, tail, { ok: tail }, "tail", false);
    const expect: Expect = "ok" in p.expect ? p.expect : REV("CallFailed");
    return {
      data: coreCalldata("read", [target.struct, RESOLVE_SELECTOR, [arg.struct]]),
      expect,
      desc: `read(core,resolve,[${p.desc}])`,
    };
  }

  // read(operators, add, segments): the constructed calldata is judged by
  // the REAL decoder — at least 64 bytes of segments, words read at fixed
  // offsets, surplus bytes ignored.
  let target: P;
  let targetFail: string | null = null;
  const rt = rng();
  if (rt < 0.7) target = finishParam(rng, 0, OPS_W, { ok: OPS_W }, "raw[ops]", false);
  else if (rt < 0.8) {
    const short = ("0x" + hexBytes(rng, 10)) as Hex;
    target = finishParam(rng, 0, short, { ok: short }, "raw[short]", false);
    targetFail = "ReturnDataOutOfBounds";
  } else if (rt < 0.9) {
    const dirty = word((1n << 170n) | 5n);
    target = finishParam(rng, 0, dirty, { ok: dirty }, "raw[dirty]", false);
    targetFail = "InvalidAddressWord";
  } else {
    target = genParam(rng, depth);
    if ("revert" in target.expect) targetFail = target.expect.revert;
    else {
      const v = target.expect.ok;
      if (byteLen(v) < 32) targetFail = "ReturnDataOutOfBounds";
      else if (wordAt(v, 0)! >> 160n !== 0n) targetFail = "InvalidAddressWord";
      else if (wordAt(v, 0)! !== BigInt(OPS_W)) targetFail = "CallFailed"; // wherever it points: code-less or wrong-selector
    }
  }

  const nArgs = randInt(rng, 0, 3);
  const args: P[] = Array.from({ length: nArgs }, () => genParam(rng, depth));
  let expect: Expect;
  if (targetFail !== null) {
    expect = REV(targetFail);
  } else {
    const failing = args.find((a) => "revert" in a.expect);
    if (failing) {
      expect = failing.expect;
    } else {
      const blob = catHex(...args.map((a) => (a.expect as { ok: Hex }).ok));
      if (byteLen(blob) < 64) expect = REV("CallFailed");
      else {
        const a = wordAt(blob, 0)!;
        const b = wordAt(blob, 32)!;
        expect = a + b > MAXU ? REV("CallFailed") : { ok: word(a + b) };
      }
    }
  }
  return {
    data: coreCalldata("read", [target.struct, ADD_SELECTOR, args.map((a) => a.struct)]),
    expect,
    desc: `read(${target.desc},add,[${args.map((a) => a.desc).join(",")}])`,
  };
}

// revertData: operands drawn from a vocabulary of KNOWN revert reasons so
// the returned (possibly selector-stripped) bytes are computable exactly.
const PANIC_SELECTOR = "0x4e487b71" as Hex;

function panicData(code: bigint): Hex {
  return catHex(PANIC_SELECTOR, word(code));
}

function genRevertData(rng: Rng): Expr {
  const r = rng();
  const scData = (to: Hex, data: Hex): Hex =>
    encodeAbiParameters([{ type: "address" }, { type: "bytes" }], [to, data]);

  if (r < 0.08) {
    // Non-STATIC_CALL operand: rejected before anything runs.
    const p: ParamStruct = { paramType: 2, fetcherType: 0, paramData: word(1n), constraints: [] };
    return {
      data: coreCalldata("revertData", [p, "0x00000000"]),
      expect: REV("RevertProbeNotACall"),
      desc: "revertData(raw)",
    };
  }
  if (r < 0.16) {
    // Constrained operand: rejected — the probed call never yields a value.
    const p: ParamStruct = {
      paramType: 2,
      fetcherType: 1,
      paramData: scData(OPS, opCalldata("div", [1n, 0n])),
      constraints: [{ constraintType: 0, referenceData: word(0n) }],
    };
    return {
      data: coreCalldata("revertData", [p, "0x00000000"]),
      expect: REV("RevertProbeConstrained"),
      desc: "revertData(constrained)",
    };
  }
  if (r < 0.26) {
    // Code-less target: a failure with no reason to match.
    const dead = ("0x" + hexBytes(rng, 20)) as Hex;
    const p: ParamStruct = { paramType: 2, fetcherType: 1, paramData: scData(dead, "0x12345678"), constraints: [] };
    const expectSel = rng() < 0.5;
    return {
      data: coreCalldata("revertData", [p, expectSel ? PANIC_SELECTOR : "0x00000000"]),
      expect: expectSel ? REV("UnexpectedRevertData") : { ok: "0x" },
      desc: `revertData(eoa,${expectSel ? "sel" : "0"})`,
    };
  }
  if (r < 0.36) {
    // The operand SUCCEEDS: that is itself the failure.
    const p: ParamStruct = {
      paramType: 2,
      fetcherType: 1,
      paramData: scData(OPS, opCalldata("add", [1n, 2n])),
      constraints: [],
    };
    return {
      data: coreCalldata("revertData", [p, "0x00000000"]),
      expect: REV("DidNotRevert"),
      desc: "revertData(succeeds)",
    };
  }
  if (r < 0.5) {
    // Bare revert: expWad above its overflow bound reverts with no data.
    const abi = [
      {
        type: "function",
        name: "expWad",
        stateMutability: "view",
        inputs: [{ type: "int256" }],
        outputs: [{ type: "int256" }],
      },
    ] as const;
    const data = encodeFunctionData({ abi, functionName: "expWad", args: [135305999368893231589n] });
    const p: ParamStruct = { paramType: 2, fetcherType: 1, paramData: scData(OPS, data), constraints: [] };
    const expectSel = rng() < 0.5;
    return {
      data: coreCalldata("revertData", [p, expectSel ? PANIC_SELECTOR : "0x00000000"]),
      expect: expectSel ? REV("UnexpectedRevertData") : { ok: "0x" },
      desc: `revertData(bare,${expectSel ? "sel" : "0"})`,
    };
  }
  if (r < 0.75) {
    // Panic from Operators: div-by-zero (0x12) or checked underflow (0x11).
    const div = rng() < 0.5;
    const data = div ? opCalldata("div", [genOpArg(rng), 0n]) : opCalldata("sub", [0n, 1n + (randBig(rng, 64) | 1n)]);
    const p: ParamStruct = { paramType: 2, fetcherType: 1, paramData: scData(OPS, data), constraints: [] };
    const full = panicData(div ? 0x12n : 0x11n);
    const mode = rng();
    if (mode < 0.4) {
      return {
        data: coreCalldata("revertData", [p, "0x00000000"]),
        expect: { ok: full },
        desc: `revertData(panic,0)`,
      };
    }
    if (mode < 0.75) {
      return {
        data: coreCalldata("revertData", [p, PANIC_SELECTOR]),
        expect: { ok: ("0x" + full.slice(10)) as Hex },
        desc: `revertData(panic,strip)`,
      };
    }
    return {
      data: coreCalldata("revertData", [p, "0xdeadbeef"]),
      expect: REV("UnexpectedRevertData"),
      desc: `revertData(panic,mismatch)`,
    };
  }
  // A nested core expression as the probed call: the observed reason is the
  // CORE's own error — here a ConstraintFailed built to be byte-predictable.
  const w = randBig(rng, 256) & MAXU;
  const ref = word(w ^ 1n);
  const failing: ParamStruct = {
    paramType: 2,
    fetcherType: 0,
    paramData: word(w),
    constraints: [{ constraintType: 0, referenceData: ref }],
  };
  const inner = coreCalldata("resolve", [failing]);
  const p: ParamStruct = { paramType: 2, fetcherType: 1, paramData: scData(CORE, inner), constraints: [] };
  const full = encodeErrorResult({
    abi: ERROR_ABI,
    errorName: "ConstraintFailed",
    args: ["", 0n, 0n, 0n, 0, word(w), ref],
  });
  const strip = rng() < 0.5;
  return {
    data: coreCalldata("revertData", [p, strip ? (full.slice(0, 10) as Hex) : "0x00000000"]),
    expect: { ok: strip ? (("0x" + full.slice(10)) as Hex) : full },
    desc: `revertData(core-constraint,${strip ? "strip" : "0"})`,
  };
}

function genAssertParam(rng: Rng, depth: number): Expr {
  const p = genParam(rng, depth);
  const expect: Expect = "ok" in p.expect ? { ok: "0x" } : p.expect;
  return { data: coreCalldata("assertParam", [p.struct]), expect, desc: `assertParam(${p.desc})` };
}

function genExpr(rng: Rng, depth: number): Expr {
  const r = rng();
  if (r < 0.14) return genResolve(rng, depth);
  if (r < 0.26) return genPick(rng, depth);
  if (r < 0.34) return genNav(rng, depth);
  if (r < 0.48) return genCond(rng, depth);
  if (r < 0.6) return genOrElse(rng, depth);
  if (r < 0.68) return genIsValid(rng, depth);
  if (r < 0.8) return genChain(rng, depth);
  if (r < 0.92) return genRead(rng, depth);
  return genRevertData(rng);
}

function genTopExpr(rng: Rng): Expr {
  if (rng() < 0.08) return genAssertParam(rng, randInt(rng, 1, 3));
  return genExpr(rng, randInt(rng, 1, 3));
}

describe("composed expression fuzz", () => {
  it("random trees match the resolution oracle", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = mulberry32((SEED + i * 0x9e3779b9) >>> 0);
      const e = genTopExpr(rng);
      await checkExpr("expr", i, e.desc, CORE, e.data, e.expect);
    }
  });
});

// ============ assertComposable: the judge over composed entries ============

interface OutputParamStruct {
  fetcherType: number;
  paramData: Hex;
}

interface EntryStruct {
  functionSig: Hex;
  inputParams: ParamStruct[];
  outputParams: OutputParamStruct[];
}

function genEntry(rng: Rng): { struct: EntryStruct; fail: string | null; desc: string } {
  const r = rng();
  const sig = ("0x" + hexBytes(rng, 4)) as Hex;

  if (r < 0.05) {
    return {
      struct: {
        functionSig: sig,
        inputParams: [],
        outputParams: [{ fetcherType: 0, paramData: "0x" }],
      },
      fail: "OutputParamsNotSupported",
      desc: "entry[output]",
    };
  }
  if (r < 0.12) {
    const p = rawLeaf(rng);
    p.struct.paramType = 1; // VALUE
    return {
      struct: { functionSig: sig, inputParams: [p.struct], outputParams: [] },
      fail: "ValueParamNotSupported",
      desc: "entry[value]",
    };
  }
  if (r < 0.19) {
    const t1: ParamStruct = { paramType: 0, fetcherType: 0, paramData: OPS_W, constraints: [] };
    const t2: ParamStruct = { paramType: 0, fetcherType: 0, paramData: OPS_W, constraints: [] };
    return {
      struct: { functionSig: sig, inputParams: [t1, t2], outputParams: [] },
      fail: "DuplicateTargetParam",
      desc: "entry[dup-target]",
    };
  }
  if (r < 0.26) {
    const account = "0x" + hexBytes(rng, 20);
    const t: ParamStruct = {
      paramType: 0,
      fetcherType: 2,
      paramData: ("0x" + "00".repeat(20) + account.slice(2)) as Hex,
      constraints: [],
    };
    return {
      struct: { functionSig: sig, inputParams: [t], outputParams: [] },
      fail: "BalanceCannotBeTarget",
      desc: "entry[balance-target]",
    };
  }
  if (r < 0.62) {
    // Predicate entry: CALL_DATA params only, no call.
    const n = randInt(rng, 1, 2);
    const ps = Array.from({ length: n }, () => genParam(rng, 1));
    const failing = ps.find((p) => "revert" in p.expect);
    return {
      struct: { functionSig: sig, inputParams: ps.map((p) => p.struct), outputParams: [] },
      fail: failing ? (failing.expect as { revert: string }).revert : null,
      desc: `entry[pred:${ps.map((p) => p.desc).join(",")}]`,
    };
  }
  if (r < 0.72) {
    // TARGET resolving to zero: the constructed call is skipped entirely.
    const t: ParamStruct = { paramType: 0, fetcherType: 0, paramData: word(0n), constraints: [] };
    const p = rawLeaf(rng);
    return {
      struct: { functionSig: sig, inputParams: [t, p.struct], outputParams: [] },
      fail: "revert" in p.expect ? (p.expect as { revert: string }).revert : null,
      desc: `entry[target0,${p.desc}]`,
    };
  }
  if (r < 0.82) {
    // Dirty target word.
    const t: ParamStruct = {
      paramType: 0,
      fetcherType: 0,
      paramData: word((1n << 165n) | 3n),
      constraints: [],
    };
    return {
      struct: { functionSig: sig, inputParams: [t], outputParams: [] },
      fail: "InvalidAddressWord",
      desc: "entry[dirty-target]",
    };
  }
  // A real constructed call: operators.add(a, b) built from two word
  // segments — the call itself is the assertion.
  const a = genOpArg(rng);
  const b = genOpArg(rng);
  const t: ParamStruct = { paramType: 0, fetcherType: 0, paramData: OPS_W, constraints: [] };
  const pa: ParamStruct = { paramType: 2, fetcherType: 0, paramData: word(a), constraints: [] };
  const pb: ParamStruct = { paramType: 2, fetcherType: 0, paramData: word(b), constraints: [] };
  return {
    struct: { functionSig: ADD_SELECTOR, inputParams: [t, pa, pb], outputParams: [] },
    fail: a + b > MAXU ? "CallFailed" : null,
    desc: `entry[call:add(${a},${b})]`,
  };
}

describe("assertComposable judge fuzz", () => {
  it("random batches match the judge oracle", async () => {
    for (let i = 0; i < RUNS; i++) {
      const rng = mulberry32((SEED + (0x40000000 + i) * 0x9e3779b9) >>> 0);
      const n = randInt(rng, 1, 3);
      const entries = Array.from({ length: n }, () => genEntry(rng));
      const failing = entries.find((e) => e.fail !== null);
      const expect: Expect = failing ? REV(failing.fail!) : { ok: "0x" };
      const data = coreCalldata("assertComposable", [entries.map((e) => e.struct)]);
      await checkExpr("judge", i, entries.map((e) => e.desc).join(" "), CORE, data, expect);
    }
  });
});

// ============ Folds / map / filter with deployed lambda targets ============

// Byte-level template simulation: an Operators binary-op template is 68
// bytes (selector + two words); windows may land ANYWHERE in [4, 36], so a
// stamp can straddle both argument slots. The simulator stamps exactly like
// _stampWindows (accumulator first, then elemOffsets in order) and decodes
// like the real ABI decoder (words at fixed offsets 4 and 36).

interface LamOp {
  name: string;
  ref: OpRef;
  sel: string;
}

const LAM_OPS: LamOp[] = [
  { name: "add", ref: (a, b) => (a + b > MAXU ? null : a + b) },
  { name: "sub", ref: (a, b) => (a < b ? null : a - b) },
  { name: "mul", ref: (a, b) => (a * b > MAXU ? null : a * b) },
  { name: "div", ref: (a, b) => (b === 0n ? null : a / b) },
  { name: "min", ref: (a, b) => (a < b ? a : b) },
  { name: "max", ref: (a, b) => (a > b ? a : b) },
  { name: "bitOr", ref: (a, b) => a | b },
  { name: "bitXor", ref: (a, b) => a ^ b },
  { name: "lt", ref: (a, b) => (a < b ? 1n : 0n) },
  { name: "gt", ref: (a, b) => (a > b ? 1n : 0n) },
  { name: "eq", ref: (a, b) => (a === b ? 1n : 0n) },
].map((o) => ({ ...o, sel: opCalldata(o.name, [0n, 0n]).slice(2, 10) }));

function hexToBytes(h: Hex): number[] {
  const out: number[] = [];
  for (let i = 2; i < h.length; i += 2) out.push(parseInt(h.slice(i, i + 2), 16));
  return out;
}

function bytesToHex(b: number[]): Hex {
  return ("0x" + b.map((x) => x.toString(16).padStart(2, "0")).join("")) as Hex;
}

function stampWord(bytes: number[], off: number, w: bigint): void {
  const hex = w.toString(16).padStart(64, "0");
  for (let i = 0; i < 32; i++) bytes[off + i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
}

function wordFromBytes(bytes: number[], off: number): bigint {
  let v = 0n;
  for (let i = 0; i < 32; i++) v = (v << 8n) | BigInt(bytes[off + i]);
  return v;
}

// One lambda application against an Operators binary-op template.
function simOpsLambda(template: number[], stamps: { off: number; w: bigint }[]): bigint | null {
  const t = template.slice();
  for (const s of stamps) stampWord(t, s.off, s.w);
  const sel = t
    .slice(0, 4)
    .map((x) => x.toString(16).padStart(2, "0"))
    .join("");
  const op = LAM_OPS.find((o) => o.sel === sel);
  if (!op) return null; // scrambled selector: unknown function, reverts
  return op.ref(wordFromBytes(t, 4), wordFromBytes(t, 36));
}

type Domain = "range" | "bytes" | "words";

interface FoldCase {
  domain: Domain;
  count: number;
  elems: bigint[]; // domain elements in order
  sHex: Hex; // subject bytes (empty for range)
  unaligned: boolean;
}

function genFoldSubject(rng: Rng, domain: Domain): FoldCase {
  if (domain === "range") {
    const n = rng() < 0.15 ? 0 : randInt(rng, 1, 30);
    return { domain, count: n, elems: Array.from({ length: n }, (_, i) => BigInt(i)), sHex: "0x", unaligned: false };
  }
  if (domain === "bytes") {
    const n = rng() < 0.15 ? 0 : randInt(rng, 1, 40);
    const hex = hexBytes(rng, n);
    const elems: bigint[] = [];
    for (let i = 0; i < n; i++) elems.push(BigInt(parseInt(hex.slice(i * 2, i * 2 + 2), 16)));
    return { domain, count: n, elems, sHex: ("0x" + hex) as Hex, unaligned: false };
  }
  if (rng() < 0.08) {
    const n = randInt(rng, 1, 3) * 32 + randInt(rng, 1, 31);
    return { domain, count: 0, elems: [], sHex: ("0x" + hexBytes(rng, n)) as Hex, unaligned: true };
  }
  const n = rng() < 0.15 ? 0 : randInt(rng, 1, 12);
  const elems = Array.from({ length: n }, () => {
    const r = rng();
    if (r < 0.5) return BigInt(randInt(rng, 0, 20));
    if (r < 0.65) return MAXU - BigInt(randInt(rng, 0, 2));
    return randBig(rng, 256) & MAXU;
  });
  return { domain, count: n, elems, sHex: catHex(...elems.map(word)), unaligned: false };
}

function genWindows(rng: Rng): { accOffset: number; elemOffsets: number[] } {
  const r = rng();
  if (r < 0.4) return { accOffset: 4, elemOffsets: [36] };
  if (r < 0.55) return { accOffset: 36, elemOffsets: [4] };
  if (r < 0.63) return { accOffset: 4, elemOffsets: [4] }; // full overlap: element wins
  if (r < 0.71) return { accOffset: 4, elemOffsets: [4, 36] }; // multi-window
  if (r < 0.79) return { accOffset: 4, elemOffsets: [] }; // acc-only lambda
  if (r < 0.88) return { accOffset: 4, elemOffsets: [randInt(rng, 5, 35)] }; // unaligned straddle
  if (r < 0.95) return { accOffset: randInt(rng, 4, 36), elemOffsets: [36] };
  return { accOffset: 4, elemOffsets: [randInt(rng, 37, 90)] }; // out of bounds
}

function genInit(rng: Rng): bigint {
  const r = rng();
  if (r < 0.4) return BigInt(randInt(rng, 0, 5));
  if (r < 0.55) return MAXU;
  return randBig(rng, 256) & MAXU;
}

// The exact engine: checks in _fold order, then the loop with early exits.
function simFold(
  c: FoldCase,
  templateLen: number,
  apply: (acc: bigint, elem: bigint) => bigint | null,
  accOffset: number,
  elemOffsets: number[],
  init: bigint,
  exit: number,
  targetHasCode: boolean
): Expect {
  if (c.unaligned) return REV("UnalignedWords");
  if (templateLen < 32 || accOffset > templateLen - 32) return REV("LambdaOffsetOutOfBounds");
  for (const off of elemOffsets) if (off > templateLen - 32) return REV("LambdaOffsetOutOfBounds");
  if (c.count === 0) return { ok: word(init) };
  if (!targetHasCode) return REV("LambdaCallFailed");
  let acc = init;
  for (const elem of c.elems) {
    const next = apply(acc, elem);
    if (next === null) return REV("LambdaCallFailed");
    acc = next;
    if (exit === 1 && acc !== 0n) break;
    if (exit === 2 && acc === 0n) break;
  }
  return { ok: word(acc) };
}

const FOLD_FNS: Record<Domain, string> = { range: "foldRange", bytes: "foldBytes", words: "foldWords" };

function foldCalldata(
  domain: Domain,
  c: FoldCase,
  target: Hex,
  template: Hex,
  accOffset: number,
  elemOffsets: number[],
  init: bigint,
  exit: number
): Hex {
  const abi = [
    {
      type: "function",
      name: FOLD_FNS[domain],
      stateMutability: "view",
      inputs: [
        { type: domain === "range" ? "uint256" : "bytes" },
        { type: "address" },
        { type: "bytes" },
        { type: "uint256" },
        { type: "uint256[]" },
        { type: "bytes32" },
        { type: "uint8" },
      ],
      outputs: [{ type: "bytes32" }],
    },
  ] as const;
  return encodeFunctionData({
    abi,
    functionName: FOLD_FNS[domain],
    args: [
      domain === "range" ? BigInt(c.count) : c.sHex,
      target,
      template,
      BigInt(accOffset),
      elemOffsets.map(BigInt),
      word(init),
      exit,
    ],
  });
}

function applyWordsCalldata(fn: string, s: Hex, target: Hex, template: Hex, elemOffsets: number[]): Hex {
  const abi = [
    {
      type: "function",
      name: fn,
      stateMutability: "view",
      inputs: [{ type: "bytes" }, { type: "address" }, { type: "bytes" }, { type: "uint256[]" }],
      outputs: [{ type: "bytes" }],
    },
  ] as const;
  return encodeFunctionData({ abi, functionName: fn, args: [s, target, template, elemOffsets.map(BigInt)] });
}

describe("fold differential fuzz (deployed lambda targets)", () => {
  for (const domain of ["range", "bytes", "words"] as Domain[]) {
    it(`${FOLD_FNS[domain]} matches the byte-level engine simulation`, async () => {
      const base = domain === "range" ? 0x50000000 : domain === "bytes" ? 0x58000000 : 0x60000000;
      for (let i = 0; i < RUNS; i++) {
        const rng = mulberry32((SEED + (base + i) * 0x9e3779b9) >>> 0);
        const c = genFoldSubject(rng, domain);
        const op = LAM_OPS[randInt(rng, 0, LAM_OPS.length - 1)];
        const litA = genOpArg(rng);
        const litB = genOpArg(rng);
        const template = opCalldata(op.name, [litA, litB]);
        const tBytes = hexToBytes(template);
        const { accOffset, elemOffsets } = genWindows(rng);
        const init = genInit(rng);
        const exit = randInt(rng, 0, 2);
        const deadTarget = rng() < 0.04;
        const target = deadTarget ? (("0x" + hexBytes(rng, 20)) as Hex) : OPS;

        const apply = (acc: bigint, elem: bigint) =>
          simOpsLambda(tBytes, [
            { off: accOffset, w: acc },
            ...elemOffsets.map((off) => ({ off, w: elem })),
          ]);
        const expect = simFold(c, tBytes.length, apply, accOffset, elemOffsets, init, exit, !deadTarget);
        const data = foldCalldata(domain, c, target, template, accOffset, elemOffsets, init, exit);
        const desc = `${op.name}(acc@${accOffset},elem@[${elemOffsets}]) n=${c.count} exit=${exit}${deadTarget ? " dead" : ""}${c.unaligned ? " unaligned" : ""}`;
        await checkExpr(FOLD_FNS[domain], i, desc, OPS, data, expect);
      }
    });
  }

  for (const fn of ["mapWords", "filterWords"]) {
    it(`${fn} matches the byte-level engine simulation`, async () => {
      const base = fn === "mapWords" ? 0x68000000 : 0x70000000;
      for (let i = 0; i < RUNS; i++) {
        const rng = mulberry32((SEED + (base + i) * 0x9e3779b9) >>> 0);
        const c = genFoldSubject(rng, "words");
        const op = LAM_OPS[randInt(rng, 0, LAM_OPS.length - 1)];
        const template = rng() < 0.04 ? ("0x" + hexBytes(rng, randInt(rng, 0, 31))) as Hex : opCalldata(op.name, [genOpArg(rng), genOpArg(rng)]);
        const tBytes = hexToBytes(template);
        // No accumulator window in map/filter: reuse the generator but keep
        // only element windows, biased to include multi and unaligned.
        const w = genWindows(rng);
        const elemOffsets = w.elemOffsets.length > 0 ? w.elemOffsets : [4];
        const deadTarget = rng() < 0.04;
        const target = deadTarget ? (("0x" + hexBytes(rng, 20)) as Hex) : OPS;

        let expect: Expect;
        if (c.unaligned) expect = REV("UnalignedWords");
        else if (tBytes.length < 32) expect = REV("LambdaOffsetOutOfBounds");
        else if (elemOffsets.some((off) => off > tBytes.length - 32)) expect = REV("LambdaOffsetOutOfBounds");
        else if (c.count === 0) expect = { ok: encodeAbiParameters([{ type: "bytes" }], ["0x"]) };
        else if (deadTarget) expect = REV("LambdaCallFailed");
        else {
          const kept: bigint[] = [];
          let failed = false;
          for (const elem of c.elems) {
            const v = simOpsLambda(tBytes, elemOffsets.map((off) => ({ off, w: elem })));
            if (v === null) {
              failed = true;
              break;
            }
            if (fn === "mapWords") kept.push(v);
            else if (v !== 0n) kept.push(elem);
          }
          expect = failed
            ? REV("LambdaCallFailed")
            : { ok: encodeAbiParameters([{ type: "bytes" }], [kept.length ? catHex(...kept.map(word)) : "0x"]) };
        }
        const data = applyWordsCalldata(fn, c.sHex, target, template, elemOffsets);
        const desc = `${op.name}(elem@[${elemOffsets}]) n=${c.count}${deadTarget ? " dead" : ""}${c.unaligned ? " unaligned" : ""}`;
        await checkExpr(fn, i, desc, OPS, data, expect);
      }
    });
  }
});

// ============ Core-target lambda templates ============
//
// The fold's lambda is a core expression: the template is complete
// resolve(...) calldata whose operand reaches Operators (one or two decode
// layers deep), and the window offsets are found by SCANNING the encoded
// bytes for marker words — never recomputed from layout formulas, matching
// the doctrine set by CoreTargetLambda.t.sol.

// Markers must be non-periodic: a repeating pattern placed in two adjacent
// windows would match the scan at every shifted offset.
const ACC_MARKER = 0xac0113a7e1b2c3d4e5f60718293a4b5c6d7e8f90ffee1122334455667788aa01n;
const ELEM_MARKER = 0xe1e355aa123456789abcdef0fedcba9876543210b00c4de5f61728394a5b6c02n;
const ELEM2_MARKER = 0xe2e2d00d48151623421337c0de600df00dbadb100dca7d06beeffacecafe0303n;

function scanOffset(template: Hex, marker: bigint): number {
  const needle = marker.toString(16).padStart(64, "0");
  const hay = template.slice(2);
  const first = hay.indexOf(needle);
  assert.ok(first >= 0, "marker not found in template");
  assert.equal(hay.indexOf(needle, first + 1), -1, "marker not unique in template");
  assert.equal(first % 2, 0, "marker not byte-aligned");
  return first / 2;
}

function coreTemplate(opName: string, a: bigint, b: bigint, deep: boolean): Hex {
  const inner = opCalldata(opName, [a, b]);
  const param = (to: Hex, data: Hex): ParamStruct => ({
    paramType: 2,
    fetcherType: 1,
    paramData: encodeAbiParameters([{ type: "address" }, { type: "bytes" }], [to, data]),
    constraints: [],
  });
  const one = coreCalldata("resolve", [param(OPS, inner)]);
  if (!deep) return one;
  // Two layers: resolve(sc(core, resolve(sc(operators, op)))) — the marker
  // sits inside doubly-encoded calldata, and substitution must still work
  // because a 32-byte overwrite shifts no ABI offsets.
  return coreCalldata("resolve", [param(CORE, one)]);
}

describe("core-target lambda fuzz", () => {
  it("foldWords folds through resolve(...) templates, one and two layers deep", async () => {
    for (let i = 0; i < RUNS / 2; i++) {
      const rng = mulberry32((SEED + (0x78000000 + i) * 0x9e3779b9) >>> 0);
      const c = genFoldSubject(rng, "words");
      const deep = rng() < 0.35;
      const template = coreTemplate("add", ACC_MARKER, ELEM_MARKER, deep);
      const accOffset = scanOffset(template, ACC_MARKER);
      const elemOffset = scanOffset(template, ELEM_MARKER);
      const init = genInit(rng);
      const exit = randInt(rng, 0, 2);
      const apply = (acc: bigint, elem: bigint) => (acc + elem > MAXU ? null : acc + elem);
      const expect = simFold(c, byteLen(template), apply, accOffset, [elemOffset], init, exit, true);
      const data = foldCalldata("words", c, CORE, template, accOffset, [elemOffset], init, exit);
      await checkExpr("core-fold", i, `sum n=${c.count} deep=${deep} exit=${exit}`, OPS, data, expect);
    }
  });

  it("mapWords squares and filterWords thresholds through the core", async () => {
    for (let i = 0; i < RUNS / 2; i++) {
      const rng = mulberry32((SEED + (0x7c000000 + i) * 0x9e3779b9) >>> 0);
      const c = genFoldSubject(rng, "words");
      const deep = rng() < 0.3;
      if (rng() < 0.5) {
        // Square map: BOTH windows are the element — one call, two stamps.
        // Two DISTINCT markers keep each scan unambiguous; the engine stamps
        // the same element into both windows either way.
        const template = coreTemplate("mul", ELEM_MARKER, ELEM2_MARKER, deep);
        const offs = [scanOffset(template, ELEM_MARKER), scanOffset(template, ELEM2_MARKER)];
        let expect: Expect;
        if (c.unaligned) expect = REV("UnalignedWords");
        else {
          const out: bigint[] = [];
          let failed = false;
          for (const e of c.elems) {
            if (e * e > MAXU) {
              failed = true;
              break;
            }
            out.push(e * e);
          }
          expect = failed
            ? REV("LambdaCallFailed")
            : { ok: encodeAbiParameters([{ type: "bytes" }], [out.length ? catHex(...out.map(word)) : "0x"]) };
        }
        const data = applyWordsCalldata("mapWords", c.sHex, CORE, template, offs);
        await checkExpr("core-map", i, `square n=${c.count} deep=${deep}`, OPS, data, expect);
      } else {
        const k = rng() < 0.5 ? BigInt(randInt(rng, 0, 25)) : randBig(rng, 256) & MAXU;
        const template = coreTemplate("lt", ELEM_MARKER, k, deep);
        const off = scanOffset(template, ELEM_MARKER);
        let expect: Expect;
        if (c.unaligned) expect = REV("UnalignedWords");
        else {
          const kept = c.elems.filter((e) => e < k);
          expect = { ok: encodeAbiParameters([{ type: "bytes" }], [kept.length ? catHex(...kept.map(word)) : "0x"]) };
        }
        const data = applyWordsCalldata("filterWords", c.sHex, CORE, template, [off]);
        await checkExpr("core-filter", i, `lt(${k}) n=${c.count} deep=${deep}`, OPS, data, expect);
      }
    }
  });
});
