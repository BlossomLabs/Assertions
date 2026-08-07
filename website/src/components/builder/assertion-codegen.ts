import { isAddress } from "viem";

import {
  type Assertion,
  type ValueExpr,
  inferCategory,
} from "./assertion-model";
import { ensVarName, evmlArg } from "./useContractFunctions";

/**
 * Renders the assertion expression tree into `assertions:assert` lines
 * (plus the hoisted `set $x @ens(...)` lines that ENS names need).
 *
 * Formatting rules that matter to the compiler all funnel through here:
 * space-separated helper arguments, spaces around every infix operator,
 * one outer `@num!`/`@bool!` around arithmetic/logic, bare nullary helpers.
 */

export interface CodegenOptions {
  /** Resolves an ENS name to the address recorded for the target chain,
   *  or null when unresolved (the live preview passes a no-op resolver). */
  resolveEns: (name: string) => Promise<string | null>;
  /** The chain the assertion runs on. On mainnet, ENS names stay live in
   *  the script via `set $var @ens(name)`; on other chains the resolved
   *  per-chain address is frozen in (`set $var 0x…`), since `@ens` reads
   *  the mainnet record. */
  chainId: number;
}

interface RenderCtx {
  /** Resolves an ENS name to an EVML $variable (registering its set line),
   *  or null when unresolved. */
  ensToVar: (name: string) => Promise<string | null>;
  /** Collects hoisted `set` lines, deduplicated in first-seen order. */
  registerSet: (line: string) => void;
  chainId: number;
  /** Inside a @num!/@bool! wrapper already. */
  num?: boolean;
  bool?: boolean;
}

/** The hoisted binding for an ENS name: live on mainnet, frozen elsewhere. */
function ensSetLine(name: string, address: string, chainId: number): string {
  const varName = ensVarName(name);
  return chainId === 1
    ? `set ${varName} @ens(${name})`
    : `set ${varName} ${address}`;
}

/** Address/ENS target → EVML token (`0x…` or a registered `$var`), or null
 *  while the target is empty or an unresolved ENS name. */
function renderTarget(
  input: string,
  resolved: string | null | undefined,
  ctx: RenderCtx,
): string | null {
  const t = input.trim();
  if (!t) return null;
  if (isAddress(t)) return t;
  if (!resolved) return null;
  ctx.registerSet(ensSetLine(t, resolved, ctx.chainId));
  return ensVarName(t);
}

async function renderCall(
  expr: Extract<ValueExpr, { kind: "call" }>,
  ctx: RenderCtx,
): Promise<string | null> {
  const target = renderTarget(expr.target, expr.resolved, ctx);
  if (!target || expr.hops.length === 0) return null;
  let out = target;
  for (const [hopIndex, hop] of expr.hops.entries()) {
    if (!hop.fnName) return null;
    if (hop.args.some((a) => !a.trim())) return null;
    if (hop.args.length !== hop.argTypes.length) return null;
    const argVals = await Promise.all(
      hop.argTypes.map((type, i) => evmlArg(type, hop.args[i], ctx.ensToVar)),
    );
    out += hop.inline
      ? `::{${hop.fnName}(${hop.argTypes.join(",")})(${hop.returnTypes.join(",")})${argVals.length ? ` ${argVals.join(" ")}` : ""}}`
      : `::${hop.fnName}(${argVals.join(" ")})`;
    // Mid-chain multi-value hops continue on a lens-selected address.
    if (hop.lensIndex !== undefined && hopIndex < expr.hops.length - 1) {
      const slots = hop.returnTypes.map((_, i) =>
        i === hop.lensIndex ? "$" : "_",
      );
      out += `[${slots.join(" ")}]`;
    }
  }
  return out;
}

const LOGIC_WORDS = new Set(["or", "and", "xor"]);

/** Wrap a rendered logic operand in parens when it is itself a logic/not
 *  node — corpus style: `($a::q() > 0) or (not $a::paused())`. */
function logicOperand(rendered: string, node: ValueExpr): string {
  return node.kind === "logic" || node.kind === "not"
    ? `(${rendered})`
    : rendered;
}

/**
 * Render one side of an assertion (or a nested operand). Returns null while
 * the expression is incomplete — an empty literal, an unresolved target, an
 * unchosen function or a missing argument.
 *
 * `stringSide` marks a top-level side whose counterpart is a string call, so
 * literals get JSON-quoted (the old `formatExpected` behavior).
 */
export async function renderExpr(
  expr: ValueExpr,
  ctx: RenderCtx,
  stringSide = false,
): Promise<string | null> {
  switch (expr.kind) {
    case "literal": {
      const v = expr.value.trim();
      if (!v) return null;
      if (stringSide) return JSON.stringify(v);
      if (
        inferCategory(expr) === "address" &&
        !isAddress(v) &&
        v.includes(".") &&
        v !== "@me"
      ) {
        const varName = await ctx.ensToVar(v);
        if (varName) return varName;
      }
      return v;
    }
    case "call":
      return renderCall(expr, ctx);
    case "balance": {
      const token = expr.token.trim();
      if (!token) return null;
      const account = await renderExpr(expr.account, ctx);
      if (!account) return null;
      return `@balance!(${token} ${account})`;
    }
    case "minmax": {
      const items = await Promise.all(
        expr.items.map((i) => renderExpr(i, ctx)),
      );
      if (items.length < 1 || items.some((i) => i === null)) return null;
      return `@${expr.op}!(${items.join(" ")})`;
    }
    case "absdiff": {
      const a = await renderExpr(expr.a, ctx);
      const b = await renderExpr(expr.b, ctx);
      if (!a || !b) return null;
      return `@absdiff!(${a} ${b})`;
    }
    case "arith": {
      const inner = { ...ctx, num: true };
      const left = await renderExpr(expr.left, inner);
      const right = await renderExpr(expr.right, inner);
      if (!left || !right) return null;
      const l = expr.left.kind === "arith" ? `(${left})` : left;
      const r = expr.right.kind === "arith" ? `(${right})` : right;
      const body = `${l} ${expr.op} ${r}`;
      return ctx.num ? body : `@num!(${body})`;
    }
    case "neg": {
      const operand = await renderExpr(expr.operand, { ...ctx, num: true });
      if (!operand) return null;
      const body =
        expr.operand.kind === "literal" ? `-${operand}` : `-(${operand})`;
      return ctx.num ? body : `@num!(${body})`;
    }
    case "logic": {
      const inner = { ...ctx, bool: true };
      const left = await renderExpr(expr.left, inner);
      const right = await renderExpr(expr.right, inner);
      if (!left || !right) return null;
      const needsParens = LOGIC_WORDS.has(expr.op);
      const l = needsParens ? logicOperand(left, expr.left) : left;
      const r = needsParens ? logicOperand(right, expr.right) : right;
      const cmpParens =
        !LOGIC_WORDS.has(expr.op) &&
        (expr.left.kind === "logic" || expr.right.kind === "logic");
      const body = cmpParens
        ? `(${left}) ${expr.op} (${right})`
        : `${l} ${expr.op} ${r}`;
      return ctx.bool ? body : `@bool!(${body})`;
    }
    case "not": {
      const operand = await renderExpr(expr.operand, { ...ctx, bool: true });
      if (!operand) return null;
      const body =
        expr.operand.kind === "logic" || expr.operand.kind === "not"
          ? `not (${operand})`
          : `not ${operand}`;
      return ctx.bool ? body : `@bool!(${body})`;
    }
    case "callwrap": {
      const call = await renderExpr(expr.call, ctx);
      if (!call) return null;
      return `@${expr.helper}!(${call})`;
    }
    case "at": {
      const call = await renderExpr(expr.call, ctx);
      if (!call || !/^\d+$/.test(expr.index.trim())) return null;
      return `@at!(${call} ${expr.index.trim()})`;
    }
    case "split": {
      const call = await renderExpr(expr.call, ctx);
      if (!call || !expr.delimiter || !/^\d+$/.test(expr.index.trim()))
        return null;
      return `@split!(${call} ${JSON.stringify(expr.delimiter)} ${expr.index.trim()})`;
    }
    case "clock":
      return expr.which === "timestamp" ? "@timestamp!" : "@blocknumber!";
  }
}

export interface BuiltLine {
  line: string;
  sets: string[];
}

function makeCtx(options: CodegenOptions) {
  const sets: string[] = [];
  const registerSet = (line: string) => {
    if (!sets.includes(line)) sets.push(line);
  };
  const ctx: RenderCtx = {
    registerSet,
    chainId: options.chainId,
    // Arg-level ENS resolution also hoists a set line for the resolved name.
    ensToVar: async (name) => {
      const address = await options.resolveEns(name);
      if (!address) return null;
      registerSet(ensSetLine(name, address, options.chainId));
      return ensVarName(name);
    },
  };
  return { ctx, sets };
}

/**
 * Build the `assertions:assert` line (+ hoisted set lines) from the
 * expression model, or null while the form is incomplete. Byte-compatible
 * with the old flat `buildAssertion` for single-call subjects.
 */
export async function buildAssertionLine(
  assertion: Assertion,
  options: CodegenOptions,
): Promise<BuiltLine | null> {
  const { ctx, sets } = makeCtx(options);
  const stringCmp =
    inferCategory(assertion.subject) === "string" ||
    (assertion.expected !== null &&
      inferCategory(assertion.expected) === "string" &&
      assertion.expected.kind !== "literal");

  const lhs = await renderExpr(
    assertion.subject,
    ctx,
    assertion.subject.kind === "literal" && stringCmp,
  );
  if (!lhs) return null;

  const msg = assertion.message.trim()
    ? ` ${JSON.stringify(assertion.message.trim())}`
    : "";

  if (assertion.operator === null || assertion.expected === null)
    return { line: `assertions:assert ${lhs}${msg}`, sets };

  const rhs = await renderExpr(
    assertion.expected,
    ctx,
    assertion.expected.kind === "literal" && stringCmp,
  );
  if (!rhs) return null;

  let cmp = ` ${assertion.operator} ${rhs}`;
  if (assertion.operator === "~=") {
    if (!assertion.delta.trim()) return null;
    cmp += ` --delta ${assertion.delta.trim()}`;
  }
  return { line: `assertions:assert ${lhs}${cmp}${msg}`, sets };
}

// ---------------------------------------------------------------------------
// Flat (non-expression) assertion commands.
// ---------------------------------------------------------------------------

export type CodeVariant = "has-code" | "no-code" | "codehash";
export type BlockField = "number" | "timestamp";

export interface FlatAssertion {
  kind: "balance" | "code" | "block" | "chainid";
  account: string;
  targetInput: string;
  /** Resolved address when targetInput is an ENS name. */
  targetResolved: string | null;
  codeVariant: CodeVariant;
  blockField: BlockField;
  operator: string;
  expected: string;
  delta: string;
  message: string;
}

/** Build the line for the dedicated assert-* commands (balance, code,
 *  block, chainid) — moved verbatim from the old form codegen. */
export async function buildFlatLine(
  flat: FlatAssertion,
  options: CodegenOptions,
): Promise<BuiltLine | null> {
  const { ctx, sets } = makeCtx(options);
  const msg = flat.message.trim()
    ? ` ${JSON.stringify(flat.message.trim())}`
    : "";
  const comparison = (allowDelta: boolean): string | null => {
    if (!flat.expected.trim()) return null;
    let out = ` ${flat.operator} ${flat.expected.trim()}`;
    if (flat.operator === "~=") {
      if (!allowDelta || !flat.delta.trim()) return null;
      out += ` --delta ${flat.delta.trim()}`;
    }
    return out;
  };

  switch (flat.kind) {
    case "balance": {
      if (!flat.account.trim()) return null;
      const acct =
        flat.account.trim() === "@me"
          ? "@me"
          : await evmlArg("address", flat.account, ctx.ensToVar);
      const cmp = comparison(true);
      if (!cmp) return null;
      return { line: `assertions:assert-balance ${acct}${cmp}${msg}`, sets };
    }
    case "code": {
      const t = renderTarget(flat.targetInput, flat.targetResolved, ctx);
      if (!t) return null;
      if (flat.codeVariant === "codehash") {
        const exp = flat.expected.trim();
        if (!exp) return null;
        return { line: `assertions:assert-codehash ${t} ${exp}${msg}`, sets };
      }
      const cmd =
        flat.codeVariant === "has-code" ? "assert-code" : "assert-no-code";
      return { line: `assertions:${cmd} ${t}${msg}`, sets };
    }
    case "block": {
      const cmp = comparison(false);
      if (!cmp) return null;
      const cmd =
        flat.blockField === "number"
          ? "assert-block-number"
          : "assert-timestamp";
      return { line: `assertions:${cmd}${cmp}${msg}`, sets };
    }
    case "chainid": {
      if (!flat.expected.trim()) return null;
      return {
        line: `assertions:assert-chainid ${flat.expected.trim()}${msg}`,
        sets,
      };
    }
  }
}
