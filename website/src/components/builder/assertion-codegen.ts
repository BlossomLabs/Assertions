import { isAddress } from "viem";

import { chainById } from "../deployments/wagmi";

import {
  type Assertion,
  type ValueExpr,
  callwrapHelperName,
  inferCategory,
  resolveLens,
} from "./assertion-model";
import { ensVarName, evmlArg } from "./useContractFunctions";

/**
 * Renders the assertion expression tree into `assert` lines
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
  for (const hop of expr.hops) {
    if (!hop.fnName) return null;
    if (hop.args.length !== hop.argTypes.length) return null;
    const argVals: string[] = [];
    for (let i = 0; i < hop.args.length; i++) {
      const arg = hop.args[i];
      if (typeof arg !== "string") {
        // A nested live call: renders as its own (possibly inline-ABI)
        // call expression, resolved and spliced in at assertion time.
        const rendered = await renderCall(arg, ctx);
        if (!rendered) return null;
        argVals.push(rendered);
      } else {
        if (!arg.trim()) return null;
        argVals.push(await evmlArg(hop.argTypes[i], arg, ctx.ensToVar));
      }
    }
    out += hop.inline
      ? `::{${hop.fnName}(${hop.argTypes.join(",")})(${hop.returnTypes.join(",")})${argVals.length ? ` ${argVals.join(" ")}` : ""}}`
      : `::${hop.fnName}(${argVals.join(" ")})`;
    // A lens narrows the hop's return: `[_ $ _]` selects one output of a
    // multi-value return (mid-chain: the address the chain continues on),
    // and nested levels (`[_ [_ [$ _]]]`) select through array elements
    // and struct values — negative array indices anchor from the end via
    // the `...` rest marker (`[[... $]]` = last element, resolved live
    // for dynamic arrays).
    const lens = resolveLens(hop);
    if (lens?.valid) {
      const slots = (k: number, payload: string): string =>
        k >= 0
          ? [...Array<string>(k).fill("_"), payload].join(" ")
          : ["...", payload, ...Array<string>(-k - 1).fill("_")].join(" ");
      let payload = "$";
      for (const idx of [...lens.entries].reverse())
        payload = `[${slots(idx, payload)}]`;
      if (hop.returnTypes.length > 1 && hop.lensIndex !== undefined) {
        out += `[${hop.returnTypes
          .map((_, i) => (i === hop.lensIndex ? payload : "_"))
          .join(" ")}]`;
      } else if (hop.returnTypes.length === 1 && lens.entries.length > 0) {
        out += `[${payload}]`;
      }
    }
  }
  return out;
}

/** Wrap a rendered boolean operand in parens when it is itself a
 *  cmp/logic/not node — corpus style: `($a::q() > 0) or (not $a::paused())`. */
function boolOperand(rendered: string, node: ValueExpr): string {
  return node.kind === "cmp" || node.kind === "logic" || node.kind === "not"
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
    case "absDiff": {
      const a = await renderExpr(expr.a, ctx);
      const b = await renderExpr(expr.b, ctx);
      if (!a || !b) return null;
      return `@absDiff!(${a} ${b})`;
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
    case "cmp": {
      const inner = { ...ctx, bool: true };
      const left = await renderExpr(expr.left, inner);
      const right = await renderExpr(expr.right, inner);
      if (!left || !right) return null;
      // Boolean operands of a comparison get parens (`(a > b) == (c > d)`).
      const body = `${boolOperand(left, expr.left)} ${expr.op} ${boolOperand(right, expr.right)}`;
      return ctx.bool ? body : `@bool!(${body})`;
    }
    case "logic": {
      const inner = { ...ctx, bool: true };
      const left = await renderExpr(expr.left, inner);
      const right = await renderExpr(expr.right, inner);
      if (!left || !right) return null;
      const body = `${boolOperand(left, expr.left)} ${expr.op} ${boolOperand(right, expr.right)}`;
      return ctx.bool ? body : `@bool!(${body})`;
    }
    case "not": {
      const operand = await renderExpr(expr.operand, { ...ctx, bool: true });
      if (!operand) return null;
      const body =
        expr.operand.kind === "cmp" ||
        expr.operand.kind === "logic" ||
        expr.operand.kind === "not"
          ? `not (${operand})`
          : `not ${operand}`;
      return ctx.bool ? body : `@bool!(${body})`;
    }
    case "bytes": {
      // Helper arguments are self-delimiting: children render with a fresh
      // context so arithmetic/logic re-wrap themselves in @num!/@bool!.
      const clean = { ...ctx, num: false, bool: false };
      const left = await renderExpr(expr.left, clean);
      const right = await renderExpr(expr.right, clean);
      if (!left || !right) return null;
      return `@bytes!(${left} "${expr.op}" ${right})`;
    }
    case "callwrap": {
      const call = await renderExpr(expr.call, ctx);
      if (!call) return null;
      // The node keys predate the helper unification; `bytelen` renders as
      // the lang module's @bytes.len! (decoded byte length of the return).
      return `@${callwrapHelperName(expr.helper)}!(${call})`;
    }
    case "split": {
      const call = await renderExpr(expr.call, ctx);
      if (!call || !expr.delimiter || !/^-?\d+$/.test(expr.index.trim()))
        return null;
      return `@str.split!(${call} ${JSON.stringify(expr.delimiter)} ${expr.index.trim()})`;
    }
    case "strtest": {
      const call = await renderExpr(expr.call, ctx);
      if (!call || !expr.arg) return null;
      return `@str.${expr.helper}!(${call} ${JSON.stringify(expr.arg)})`;
    }
    case "clock":
      return expr.which === "timestamp" ? "@block.timestamp!" : "@block.number!";
    case "chainId":
      return "@chainId!";
    case "codeHash": {
      const addr = await renderExpr(expr.address, ctx);
      if (!addr) return null;
      return `@codeHash!(${addr})`;
    }
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
    // Arg-level ENS names always become a $variable backed by a hoisted set
    // line. When resolution succeeds it is chain-aware (live @ens on
    // mainnet, the per-chain address frozen elsewhere); when it is
    // unavailable (the preview's no-op resolver, or a failed lookup) the
    // name stays live via `set $var @ens(name)` — same mainnet-registry
    // semantics the resolver falls back to anyway.
    ensToVar: async (name) => {
      const varName = ensVarName(name);
      const address = await options.resolveEns(name);
      registerSet(
        address
          ? ensSetLine(name, address, options.chainId)
          : `set ${varName} @ens(${name})`,
      );
      return varName;
    },
  };
  return { ctx, sets };
}

/**
 * Build the `assert` line (+ hoisted set lines) from the
 * expression model, or null while the form is incomplete.
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
    return { line: `assert ${lhs}${msg}`, sets };

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
  return { line: `assert ${lhs}${cmp}${msg}`, sets };
}

// ---------------------------------------------------------------------------
// The simple form's chain-state assertions.
// ---------------------------------------------------------------------------

export type CodeVariant = "has-code" | "no-code" | "codeHash";
export type BlockField = "number" | "timestamp";

export interface FlatAssertion {
  kind: "balance" | "code" | "block" | "chainId";
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

/**
 * Build the line for the simple form's chain-state kinds (balance, code,
 * block, chainId). Each is an `assert` over the on-chain face that reads
 * that piece of state — the dedicated `assert-*` commands these once
 * emitted were retired once every one of them had a helper face.
 *
 * The `load` lines those faces need are not this function's business:
 * `useScriptState` derives them from the helpers the line mentions.
 */
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
      // @balance! reads a NATIVE balance only for the chain's own currency
      // symbol (ETH on mainnet, XDAI on Gnosis) — anything else resolves
      // through the token list as an ERC-20, which is a different question
      // and the expression editor's job.
      const native = chainById(ctx.chainId)?.nativeCurrency.symbol ?? "ETH";
      return { line: `assert @balance!(${native} ${acct})${cmp}${msg}`, sets };
    }
    case "code": {
      const t = renderTarget(flat.targetInput, flat.targetResolved, ctx);
      if (!t) return null;
      if (flat.codeVariant === "codeHash") {
        const exp = flat.expected.trim();
        if (!exp) return null;
        return { line: `assert @codeHash!(${t}) == ${exp}${msg}`, sets };
      }
      // Code exists exactly when the deployed payload is non-empty — the
      // same predicate the retired assert-code spelled out as
      // `codehash != 0 && codehash != keccak256("")`.
      const op = flat.codeVariant === "has-code" ? ">" : "==";
      return {
        line: `assert @bytes.len!(@codeAt!(${t})) ${op} 0${msg}`,
        sets,
      };
    }
    case "block": {
      const cmp = comparison(false);
      if (!cmp) return null;
      const face =
        flat.blockField === "number" ? "@block.number!" : "@block.timestamp!";
      return { line: `assert ${face}${cmp}${msg}`, sets };
    }
    case "chainId": {
      if (!flat.expected.trim()) return null;
      return {
        line: `assert @chainId! == ${flat.expected.trim()}${msg}`,
        sets,
      };
    }
  }
}
