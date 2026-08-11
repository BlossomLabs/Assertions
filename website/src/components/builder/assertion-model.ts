import type { Category as ModCategory, OpFamily } from "@evmcrispr/sdk/onchain";
import { allowedInfixOps, checkInfix, INFIX_OPS } from "@evmcrispr/sdk/onchain";
import { isAddress } from "viem";

/**
 * The assertion expression model. An assertion compares two value
 * expressions; each side is a tree of contract calls, literals and
 * Operators v1 helpers (`@min!`, `@absDiff!`, `@num!`, …) that the
 * codegen renders into an `assert` line.
 *
 * Nodes hold only serializable strings — ABI fetching and ENS resolution
 * stay in the editor components (one `useContractFunctions` per call node).
 *
 * Which operators compose with which value categories comes from the
 * assertions module's own composition table (the same one its compiler
 * consults), so the UI can never offer a combination that won't compile.
 */

/** Comparison category, derived from ABI return types and literal shapes. */
export type Category =
  | "uint"
  | "int"
  | "address"
  | "bool"
  | "bytes32"
  | "string"
  | "bytes"
  /** Dynamic/array return — only legal inside len/bytes.len/hash (or as
   *  the single operand of min/max). */
  | "array"
  /** Multi-output call without a return-value selection yet. */
  | "tuple"
  | "unknown";

/** A call node — the `kind: "call"` member of ValueExpr, also usable as a
 *  nested live argument of another call. */
export type CallNode = Extract<ValueExpr, { kind: "call" }>;

/** One positional argument of a hop: raw form text, or a nested live call
 *  whose result splices into the calldata at assertion time. */
export type CallArg = string | CallNode;

export function isCallArgNode(arg: CallArg | undefined): arg is CallNode {
  return arg !== undefined && typeof arg !== "string";
}

/** One segment of a `::` call chain. */
export interface CallHop {
  /** "" until a function is chosen. */
  fnName: string;
  /** Inline-ABI form `{fn(types)(ret) args}` vs an ABI-known `fn(args)`. */
  inline: boolean;
  /** Canonical argument types. */
  argTypes: string[];
  /** Canonical output types (multiple allowed — one is selected via
   *  `lensIndex`, mid-chain or on the final hop). */
  returnTypes: string[];
  /** Positional arguments: raw form strings, or nested live calls. */
  args: CallArg[];
  /** On a hop with several return values: the index of the output the
   *  expression uses, rendered as a destructure lens (`[_ $ _]`). On a
   *  non-final hop it must select an address (the chain continues on it);
   *  on the final hop it may select any output. Undefined for
   *  single-output hops. */
  lensIndex?: number;
  /** Selection path below the selected output, one entry per composite
   *  level (array element or tuple value index), rendered as nested lens
   *  levels (`[_ [_ [$ _]]]`). Raw form strings; negative array indices
   *  count from the end (rendered with the `...` rest marker — dynamic
   *  arrays resolve them live on-chain). Only meaningful on the final
   *  hop: the module can't chain through an array element. */
  lensPath?: string[];
}

export type ValueExpr =
  | { kind: "literal"; value: string }
  | {
      kind: "call";
      /** Address or ENS name as typed. */
      target: string;
      /** Resolved address when `target` is an ENS name (set by the editor);
       *  null/undefined while unresolved — the call is incomplete then. */
      resolved?: string | null;
      hops: CallHop[];
    }
  | { kind: "balance"; token: string; account: ValueExpr }
  | { kind: "minmax"; op: "min" | "max"; items: ValueExpr[] }
  | { kind: "absDiff"; a: ValueExpr; b: ValueExpr }
  | {
      kind: "arith";
      op: "+" | "-" | "*" | "/" | "//" | "%" | "^";
      left: ValueExpr;
      right: ValueExpr;
    }
  | {
      kind: "cmp";
      op: "==" | "!=" | "<" | "<=" | ">" | ">=";
      left: ValueExpr;
      right: ValueExpr;
    }
  | {
      kind: "logic";
      op: "or" | "and" | "xor";
      left: ValueExpr;
      right: ValueExpr;
    }
  /** Bitwise word ops, rendered through `@bytes!(a "&" b)`. */
  | {
      kind: "bytes";
      op: "&" | "|" | "^" | "<<" | ">>";
      left: ValueExpr;
      right: ValueExpr;
    }
  | { kind: "not"; operand: ValueExpr }
  | { kind: "callwrap"; helper: "len" | "bytelen" | "hash"; call: ValueExpr }
  // (the `bytelen` node key predates the helper unification; it renders as
  // the lang module's @bytes.len! — see callwrapHelperName)
  | { kind: "split"; call: ValueExpr; delimiter: string; index: string }
  | { kind: "clock"; which: "timestamp" | "blocknumber" }
  | { kind: "chainId" }
  /** EXTCODEHASH of an address (literal or address-returning call). */
  | { kind: "codeHash"; address: ValueExpr }
  /** String predicates over a call's string return (@str.includes!/@str.charset!). */
  | {
      kind: "strtest";
      helper: "includes" | "charset";
      call: ValueExpr;
      arg: string;
    };

/** EVML/display name of a callwrap helper node: the internal `bytelen`
 *  key predates the helper unification and renders as lang's @bytes.len!
 *  (decoded byte length of a string/bytes return). */
export function callwrapHelperName(
  helper: "len" | "bytelen" | "hash",
): string {
  return helper === "bytelen" ? "bytes.len" : helper;
}

export interface Assertion {
  subject: ValueExpr;
  /** null = bare boolean form (`assert $t::paused() "msg"`). */
  operator: string | null;
  expected: ValueExpr | null;
  /** Tolerance, used when operator is "~=". */
  delta: string;
  message: string;
}

export const emptyLiteral = (): ValueExpr => ({ kind: "literal", value: "" });
export const emptyCall = (): CallNode => ({
  kind: "call",
  target: "",
  resolved: null,
  hops: [{ fnName: "", inline: false, argTypes: [], returnTypes: [], args: [] }],
});

export const emptyAssertion = (): Assertion => ({
  subject: emptyCall(),
  operator: "==",
  expected: emptyLiteral(),
  delta: "",
  message: "",
});

/** True for values frozen into calldata at build time (drives `~=`
 *  availability and the both-sides-constant error). */
export function isBuildTimeConst(expr: ValueExpr): boolean {
  return expr.kind === "literal";
}

const ENS_RE = /^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$/;

function categoryFromAbiType(t: string): Category {
  if (/\[\d*\]$/.test(t) || t === "bytes" || t === "string") {
    if (t === "string") return "string";
    if (t === "bytes") return "bytes";
    return "array";
  }
  // Canonical struct type "(address,uint256)" — same "pick a value"
  // guidance as a multi-output return.
  if (t.startsWith("(")) return "tuple";
  if (/^uint\d*$/.test(t)) return "uint";
  if (/^int\d*$/.test(t)) return "int";
  if (t === "address") return "address";
  if (t === "bool") return "bool";
  if (t === "bytes32") return "bytes32";
  if (/^bytes\d+$/.test(t)) return "bytes32";
  return "unknown";
}

const ARRAY_RETURN_RE = /\[(\d*)\]$/;

/** The output type a hop's lens selection narrows to: the single output,
 *  or the `lensIndex` one of a multi-value return. Undefined while a
 *  multi-value return has no selection yet. */
export function selectedOutput(hop: CallHop): string | undefined {
  if (hop.returnTypes.length === 1) return hop.returnTypes[0];
  return hop.lensIndex !== undefined
    ? hop.returnTypes[hop.lensIndex]
    : undefined;
}

/** One composite level of a canonical type: an array (fixed or dynamic)
 *  or a struct/tuple. Null for scalar and string/bytes types. */
export type LensLevel =
  | { kind: "array"; base: string; length?: number }
  | { kind: "tuple"; components: string[] };

/** Split a canonical tuple type "(a,(b,c),d[2])" into component types. */
function tupleComponents(t: string): string[] | null {
  if (!t.startsWith("(") || !t.endsWith(")")) return null;
  const components: string[] = [];
  let depth = 0;
  let start = 1;
  for (let i = 1; i < t.length - 1; i++) {
    const c = t[i];
    if (c === "(") depth++;
    else if (c === ")") depth--;
    else if (c === "," && depth === 0) {
      components.push(t.slice(start, i));
      start = i + 1;
    }
  }
  components.push(t.slice(start, t.length - 1));
  return components.filter((c) => c !== "");
}

export function lensLevelOf(type: string): LensLevel | null {
  const m = type.match(ARRAY_RETURN_RE);
  if (m)
    return {
      kind: "array",
      base: type.slice(0, -m[0].length),
      length: m[1] === "" ? undefined : Number(m[1]),
    };
  const components = tupleComponents(type);
  if (components && components.length > 0)
    return { kind: "tuple", components };
  return null;
}

export interface LensSelection {
  /** Type reached after applying every parsed entry. */
  terminal: string;
  /** Parsed entries — shorter than `lensPath` when one is malformed. */
  entries: number[];
  /** Every entry parsed and in range where the arity is known. The
   *  terminal may still be composite — whether that fits depends on the
   *  context (a comparison needs a single word; @len! wants an array). */
  valid: boolean;
  /** First problem found, phrased for the validator. */
  issue?: string;
}

/** Resolve a hop's selection: walk `lensPath` from the selected output
 *  through array/tuple levels. Null while a multi-value return has no
 *  `lensIndex` yet. */
export function resolveLens(hop: CallHop): LensSelection | null {
  const sel = selectedOutput(hop);
  if (sel === undefined) return null;
  let terminal = sel;
  const entries: number[] = [];
  let issue: string | undefined;
  for (const raw of hop.lensPath ?? []) {
    const level = lensLevelOf(terminal);
    if (!level) break; // stale path beyond a scalar — ignore the rest
    const t = raw.trim();
    if (!/^-?\d+$/.test(t)) {
      issue =
        "The element index must be an integer (negative counts from the end, -1 = last).";
      break;
    }
    const idx = Number(t);
    if (level.kind === "array") {
      if (
        level.length !== undefined &&
        (idx >= level.length || idx < -level.length)
      ) {
        issue = `Element ${t} is out of range for ${terminal}.`;
        break;
      }
      terminal = level.base;
    } else {
      if (idx < 0 || idx >= level.components.length) {
        issue = `Value ${t} is out of range for ${terminal}.`;
        break;
      }
      terminal = level.components[idx];
    }
    entries.push(idx);
  }
  const valid = !issue && entries.length === (hop.lensPath ?? []).length;
  return { terminal, entries, valid, issue };
}

function literalCategory(value: string): Category {
  const v = value.trim();
  if (!v) return "unknown";
  if (/^-\d/.test(v) && /^-?\d+(\.\d+)?(e\+?\d+)?$/i.test(v)) return "int";
  if (/^\d+(\.\d+)?(e\+?\d+)?$/i.test(v)) return "uint";
  if (isAddress(v)) return "address";
  if (/^0x[0-9a-fA-F]{64}$/.test(v)) return "bytes32";
  if (/^0x([0-9a-fA-F]{2})*$/.test(v)) return "bytes";
  if (v === "true" || v === "false") return "bool";
  if (v === "@me") return "address";
  if (ENS_RE.test(v)) return "address";
  if (v.startsWith("$") || v.startsWith("@")) return "unknown";
  return "string";
}

/** The comparison category an expression produces. */
export function inferCategory(expr: ValueExpr): Category {
  switch (expr.kind) {
    case "literal":
      return literalCategory(expr.value);
    case "call": {
      const last = expr.hops[expr.hops.length - 1];
      if (!last || last.returnTypes.length === 0) return "unknown";
      const lens = resolveLens(last);
      if (lens === null) return "tuple";
      // The selection path narrows the output level by level; the category
      // is whatever type the path has reached so far.
      return categoryFromAbiType(lens.terminal);
    }
    case "balance":
    case "clock":
    case "chainId":
      return "uint";
    case "codeHash":
      return "bytes32";
    case "strtest":
      return "bool";
    case "minmax":
      return expr.items.some((i) => inferCategory(i) === "int") ? "int" : "uint";
    case "absDiff":
      return "uint";
    case "arith":
      return inferCategory(expr.left) === "int" ||
        inferCategory(expr.right) === "int"
        ? "int"
        : "uint";
    case "cmp":
    case "logic":
    case "not":
      return "bool";
    case "bytes":
      // Raw 32-byte word result, exposed as a number.
      return "uint";
    case "callwrap":
      return expr.helper === "hash" ? "bytes32" : "uint";
    case "split":
      return "string";
  }
}

// ---------------------------------------------------------------------------
// Bridge to the module's composition table (UI categories are lowercase).
// ---------------------------------------------------------------------------

const MOD_CAT: Partial<Record<Category, ModCategory>> = {
  uint: "Uint",
  int: "Int",
  address: "Address",
  bool: "Bool",
  bytes32: "Bytes32",
  string: "String",
  bytes: "Bytes",
};

/** UI category → module category; null for array/tuple/unknown, which have
 *  no word representation the table reasons about. */
export function toModCat(cat: Category): ModCategory | null {
  return MOD_CAT[cat] ?? null;
}

/** Operand categories for a table lookup: an unknown/incomplete side
 *  mirrors the other one (stay permissive while the tree is half-built). */
function tablePair(
  l: Category,
  r: Category,
): [ModCategory, ModCategory] | null {
  const lm = toModCat(l);
  const rm = toModCat(r);
  if (l === "unknown" || r === "unknown") {
    const known = lm ?? rm ?? "Uint";
    return [lm ?? known, rm ?? known];
  }
  if (!lm || !rm) return null; // array/tuple — not word-composable
  return [lm, rm];
}

/** The infix operator symbols of one family valid for an operand pair,
 *  straight from the composition table. */
export function familyOpsFor(
  family: OpFamily,
  left: Category,
  right: Category,
): string[] {
  const pair = tablePair(left, right);
  if (!pair) return [];
  return allowedInfixOps(pair[0], pair[1])
    .filter((op) => op.family === family)
    .map((op) => op.symbol);
}

/** The table's rejection reason for one operator over an operand pair, or
 *  null when it composes (or when a side is still unknown). */
export function infixIssue(
  family: OpFamily,
  symbol: string,
  left: Category,
  right: Category,
): string | null {
  if (left === "unknown" || right === "unknown") return null;
  const pair = tablePair(left, right);
  if (!pair) return null; // array/tuple issues are reported elsewhere
  const check = checkInfix({ symbol, family }, pair[0], pair[1]);
  return check.ok ? null : check.reason;
}

/** Operator value for the bare boolean form (`assert target::fn()`). */
export const BARE_OP = "is true";

/**
 * Operators available for a subject/expected pair, from the composition
 * table's cmp family. `~=` needs exactly one build-time-constant side; two
 * live numeric sides suggest `@absDiff!(a b) <= d` instead (the editor
 * offers that transform). Dynamic values (string/bytes/array/tuple) keep
 * == / != — the top-level judge compares them where nested expressions
 * can't.
 */
export function opsFor(
  subjectCat: Category,
  expectedCat: Category,
  subjectConst: boolean,
  expectedConst: boolean,
): string[] {
  if (subjectCat === "bool") return [BARE_OP, "==", "!="];
  const pair = tablePair(subjectCat, expectedCat);
  if (!pair || pair[0] === "Bytes" || pair[1] === "Bytes")
    return ["==", "!="];
  const ops = familyOpsFor("cmp", subjectCat, expectedCat);
  if (ops.length === 0) return ["==", "!="];
  const numeric = (c: ModCategory) => c === "Uint" || c === "Int";
  if (numeric(pair[0]) && numeric(pair[1]) && subjectConst !== expectedConst)
    ops.push("~=");
  return ops;
}

// ---------------------------------------------------------------------------
// Tree plumbing: paths fall out of recursive rendering — a path is the list
// of keys/indices from the assertion root, e.g. ["subject","items",0].
// ---------------------------------------------------------------------------

export type Path = (string | number)[];

/** Immutable update along a path with structural sharing. */
export function updateAt<T>(root: T, path: Path, updater: (node: any) => any): T {
  if (path.length === 0) return updater(root);
  const [head, ...rest] = path;
  const child = (root as any)[head];
  const next = updateAt(child, rest, updater);
  if (next === child) return root;
  const copy: any = Array.isArray(root) ? [...(root as any)] : { ...root };
  copy[head] = next;
  return copy;
}

/** The designated primary child a combinator unwraps back to. */
export function unwrapNode(node: ValueExpr): ValueExpr | null {
  switch (node.kind) {
    case "minmax":
      return node.items[0] ?? null;
    case "absDiff":
      return node.a;
    case "arith":
    case "cmp":
    case "logic":
    case "bytes":
      return node.left;
    case "not":
      return node.operand;
    case "callwrap":
    case "split":
    case "strtest":
      return node.call;
    default:
      return null;
  }
}

// ---------------------------------------------------------------------------
// Eager validation — cheaper, better-located messages than the compiler's.
// The evml validator remains the final authority.
// ---------------------------------------------------------------------------

export interface Issue {
  path: Path;
  message: string;
}

const WORD_CATS: Category[] = ["uint", "int", "address", "bool", "bytes32"];

/** The type a nested-arg call supplies: its selected output narrowed by the
 *  lens path. Null while the call is incomplete (no function, no return
 *  selection yet, or a malformed lens — reported elsewhere). */
function nestedArgTerminal(arg: CallNode): string | null {
  const last = arg.hops[arg.hops.length - 1];
  if (!last?.fnName || last.returnTypes.length === 0) return null;
  const lens = resolveLens(last);
  if (!lens || !lens.valid) return null;
  return lens.terminal;
}

/** Mirror of the module compiler's nested live-argument rules
 *  (`compileLiveCallArg` + the construct-time dynamic-hole restrictions):
 *  single-word selections must category-match the declared type; dynamic
 *  selections must match it exactly, sit in the last argument slot and only
 *  in the outermost (top-level) judged call. */
function nestedArgIssue(
  arg: CallNode,
  declared: string,
  isLastArg: boolean,
  topLevel: boolean,
): string | null {
  const terminal = nestedArgTerminal(arg);
  if (terminal === null) return null;
  const cat = categoryFromAbiType(terminal);
  const declaredCat = categoryFromAbiType(declared);
  if (WORD_CATS.includes(cat)) {
    return cat === declaredCat
      ? null
      : `The nested call resolves a ${terminal} value, but this argument is ${declared}.`;
  }
  if (terminal !== declared)
    return `The nested call resolves a ${terminal} value, but this argument is ${declared} — adjust the selection to a matching value.`;
  if (!topLevel)
    return "A dynamic-typed (array/string/bytes) live argument only works in the outermost judged call — not inside a composed expression.";
  if (!isLastArg)
    return "A dynamic-typed (array/string/bytes) live argument must be the last argument — the judge appends its runtime-sized value.";
  return null;
}

/** Count dynamic-typed nested live arguments across the whole tree — the
 *  judge supports at most one per assertion. */
function countDynCallArgs(expr: ValueExpr): number {
  let count = 0;
  const visitCall = (call: CallNode): void => {
    for (const hop of call.hops) {
      for (const a of hop.args) {
        if (!isCallArgNode(a)) continue;
        const terminal = nestedArgTerminal(a);
        if (
          terminal !== null &&
          !WORD_CATS.includes(categoryFromAbiType(terminal))
        )
          count++;
        visitCall(a);
      }
    }
  };
  const visit = (node: ValueExpr): void => {
    if (node.kind === "call") {
      visitCall(node);
      return;
    }
    for (const value of Object.values(node)) {
      if (Array.isArray(value)) value.forEach((v) => v?.kind && visit(v));
      else if (value && typeof value === "object" && "kind" in value)
        visit(value as ValueExpr);
    }
  };
  visit(expr);
  return count;
}

function walk(
  expr: ValueExpr,
  path: Path,
  depth: number,
  issues: Issue[],
  /** Direct child of a call-consuming helper (@len!, @str.split!, …), which
   *  accepts string/bytes/array selections a comparison can't judge. */
  inCallHelper = false,
  /** Nested live argument of another call: its selection splices into
   *  calldata (word or dynamic hole), so the word-machine operand
   *  restrictions don't apply — arg typing is checked by the caller. */
  asCallArg = false,
): void {
  switch (expr.kind) {
    case "literal": {
      const v = expr.value.trim();
      if (/^-?\d+\.\d+$/.test(v))
        issues.push({
          path,
          message:
            "On-chain values are integers. Scale fractional amounts to base units (e.g. wei) first.",
        });
      break;
    }
    case "call": {
      for (const hop of expr.hops.slice(0, -1)) {
        if (!hop.fnName) continue;
        // A mid-chain selection may reach through array elements and
        // struct values, as long as it lands on an address.
        const hopLens = resolveLens(hop);
        if (!hopLens?.valid || hopLens.terminal !== "address")
          issues.push({
            path,
            message:
              "Every :: hop except the last must continue on an address. Pick an address (or address element) to chain on.",
          });
      }
      const last = expr.hops[expr.hops.length - 1];
      const lens = last ? resolveLens(last) : null;
      if (lens?.issue) issues.push({ path, message: lens.issue });
      // A nested (path) selection compiles to a typed read whose terminal
      // must be a single word — except inside the call-consuming helpers
      // (@len!, @str.split!, …), which accept string/bytes/array selections,
      // and nested live arguments, whose dynamic selections splice as
      // envelope holes (checked against the declared type by the caller).
      if (
        lens?.valid &&
        lens.entries.length > 0 &&
        !inCallHelper &&
        !asCallArg &&
        ["string", "bytes"].includes(categoryFromAbiType(lens.terminal))
      )
        issues.push({
          path,
          message:
            "A nested selection must land on a single-word value (number, address, bool or bytes32). Compare the string through @len!, @hash! or @str.split! instead.",
        });
      // The module compiles a nested flat selection to a raw-word read,
      // which it only accepts for numbers. Path selections compile to a
      // typed read instead and may be any single-word value.
      if (
        depth > 0 &&
        !asCallArg &&
        last &&
        last.returnTypes.length > 1 &&
        last.lensIndex !== undefined &&
        (last.lensPath ?? []).length === 0
      ) {
        const cat = categoryFromAbiType(
          last.returnTypes[last.lensIndex] ?? "",
        );
        if (cat !== "uint" && cat !== "int")
          issues.push({
            path,
            message:
              "Inside a composed expression, a return-value selection must be a number (uint/int). Compare this call at the top level instead.",
          });
      }
      // Nested live call arguments: mirror the compiler's typing and
      // placement rules and recurse (issues attach to this node's path —
      // the closest one the editor renders).
      for (const hop of expr.hops) {
        hop.args.forEach((a, i) => {
          if (!isCallArgNode(a)) return;
          const msg = nestedArgIssue(
            a,
            hop.argTypes[i] ?? "",
            i === hop.argTypes.length - 1,
            depth === 0,
          );
          if (msg) issues.push({ path, message: msg });
          walk(a, path, depth + 1, issues, false, true);
        });
      }
      break;
    }
    case "balance":
      walk(expr.account, [...path, "account"], depth + 1, issues);
      break;
    case "minmax": {
      const single =
        expr.items.length === 1 && inferCategory(expr.items[0]) === "array";
      if (expr.items.length < 2 && !single)
        issues.push({
          path,
          message: `@${expr.op}! needs at least two operands (or one array).`,
        });
      expr.items.forEach((item, i) =>
        walk(item, [...path, "items", i], depth + 1, issues),
      );
      break;
    }
    case "absDiff":
      walk(expr.a, [...path, "a"], depth + 1, issues);
      walk(expr.b, [...path, "b"], depth + 1, issues);
      break;
    case "arith":
    case "cmp":
    case "logic":
    case "bytes": {
      // The composition table judges the operator over the operand pair —
      // the same check the compiler runs, surfaced eagerly.
      const family =
        expr.kind === "arith"
          ? "arith"
          : expr.kind === "cmp"
            ? "cmp"
            : expr.kind === "logic"
              ? "logic"
              : "bytes";
      const reason = infixIssue(
        family,
        expr.op,
        inferCategory(expr.left),
        inferCategory(expr.right),
      );
      if (reason) issues.push({ path, message: reason });
      walk(expr.left, [...path, "left"], depth + 1, issues);
      walk(expr.right, [...path, "right"], depth + 1, issues);
      break;
    }
    case "not":
      walk(expr.operand, [...path, "operand"], depth + 1, issues);
      break;
    case "callwrap":
      if (expr.helper === "hash" && depth > 0)
        issues.push({
          path,
          message: "@hash! results can only be compared at the top level.",
        });
      if (expr.call.kind !== "call")
        issues.push({
          path,
          message: `@${callwrapHelperName(expr.helper)}! expects a :: call expression.`,
        });
      walk(expr.call, [...path, "call"], depth + 1, issues, true);
      break;
    case "split":
      if (depth > 0)
        issues.push({
          path,
          message: "@str.split! results can only be compared at the top level.",
        });
      if (!expr.delimiter)
        issues.push({ path, message: "@str.split! needs a non-empty delimiter." });
      if (!/^-?\d+$/.test(expr.index.trim()))
        issues.push({
          path,
          message:
            "@str.split! needs an integer segment index (negative counts from the end, -1 = last).",
        });
      if (expr.call.kind !== "call")
        issues.push({ path, message: "@str.split! expects a :: call expression." });
      walk(expr.call, [...path, "call"], depth + 1, issues, true);
      break;
    case "strtest": {
      if (!expr.arg)
        issues.push({
          path,
          message:
            expr.helper === "includes"
              ? "@str.includes! needs a non-empty substring."
              : "@str.charset! needs a character class (e.g. a-z0-9-).",
        });
      if (expr.call.kind !== "call")
        issues.push({
          path,
          message: `@str.${expr.helper}! expects a :: call expression.`,
        });
      else {
        const cat = inferCategory(expr.call);
        if (cat !== "string" && cat !== "unknown")
          issues.push({
            path,
            message: `@str.${expr.helper}! expects a call returning a string.`,
          });
      }
      walk(expr.call, [...path, "call"], depth + 1, issues, true);
      break;
    }
    case "codeHash": {
      const addr = expr.address;
      if (addr.kind === "literal") {
        if (addr.value.trim() && literalCategory(addr.value) !== "address")
          issues.push({
            path,
            message: "@codeHash! needs an address (or a call returning one).",
          });
      } else if (addr.kind === "call") {
        const cat = inferCategory(addr);
        if (cat !== "address" && cat !== "unknown")
          issues.push({
            path,
            message: "@codeHash! account call must return a single address.",
          });
      } else {
        issues.push({
          path,
          message: "@codeHash! needs an address (or a call returning one).",
        });
      }
      walk(addr, [...path, "address"], depth + 1, issues);
      break;
    }
    case "clock":
    case "chainId":
      break;
  }

  // A bare tuple/array side needs a transform to become comparable. Calls
  // guide the user inline, next to their return-value/element pickers.
  if (depth === 0 && expr.kind !== "call") {
    const cat = inferCategory(expr);
    if (cat === "tuple" || cat === "array")
      issues.push({
        path,
        message:
          "This value is dynamic. Compare its @len!, @bytes.len! or @hash! instead.",
      });
  }
}

export function validateAssertion(assertion: Assertion): Issue[] {
  const issues: Issue[] = [];
  walk(assertion.subject, ["subject"], 0, issues);
  if (assertion.expected)
    walk(assertion.expected, ["expected"], 0, issues);

  const dynArgs =
    countDynCallArgs(assertion.subject) +
    (assertion.expected ? countDynCallArgs(assertion.expected) : 0);
  if (dynArgs > 1)
    issues.push({
      path: [],
      message:
        "At most one dynamic-typed (array/string/bytes) live argument per assertion — the judge splices a single runtime-sized value.",
    });

  const subjConst = isBuildTimeConst(assertion.subject);
  const expConst = assertion.expected
    ? isBuildTimeConst(assertion.expected)
    : false;
  if (assertion.operator !== null && assertion.expected) {
    if (subjConst && expConst)
      issues.push({
        path: [],
        message:
          "Nothing to assert on-chain: both sides are build-time constants.",
      });
    if (assertion.operator === "~=") {
      if (!assertion.delta.trim())
        issues.push({ path: [], message: "~= needs an allowed delta." });
      if (subjConst === expConst)
        issues.push({
          path: [],
          message:
            "~= needs one constant side. For two live values use @absDiff!(a b) <= delta.",
        });
    }
  }
  return issues;
}
