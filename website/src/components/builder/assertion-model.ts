import type { Category as ModCategory, OpFamily } from "@evmcrispr/sdk/onchain";
import {
  allowedInfixOps,
  categoryFromAbiType as sdkCategoryFromAbiType,
} from "@evmcrispr/sdk/onchain";
import { isAddress } from "viem";

/**
 * The assertion expression model. An assertion compares two value
 * expressions; each side is a tree of contract calls, literals and
 * on-chain helpers (`@min!`, `@absDiff!`, `@calc!`, …) that the codegen
 * renders into an `assert` line.
 *
 * Nodes hold only serializable strings: ABI fetching and ENS resolution
 * stay in the editor components (one `useContractFunctions` per call node).
 *
 * The model reasons about SHAPES only (which category a node produces,
 * which combinators the menus may offer). Whether a tree compiles is the
 * compiler's call: the form compiles the rendered line and shows its
 * diagnostics (see compile-adapter.ts).
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
  /** Dynamic/array return: only legal inside len (or as the single
   *  operand of min/max). */
  | "array"
  /** Multi-output call without a return-value selection yet. */
  | "tuple"
  | "unknown";

/** A call node, the `kind: "call"` member of ValueExpr, also usable as a
 *  nested live argument of another call. */
export type CallNode = Extract<ValueExpr, { kind: "call" }>;

/** One positional argument of a hop: raw form text, or a live value (a
 *  contract call, a balance, anything the editor composes) read when the
 *  assertion runs and spliced into the calldata. */
export type CallArg = string | ValueExpr;

/** The argument as plain text, or null when it is a live value. A literal
 *  node counts as its text: it is what a live value turns into when it is
 *  unwrapped down to a typed value. */
export function argText(arg: CallArg | undefined): string | null {
  if (arg === undefined) return "";
  if (typeof arg === "string") return arg;
  return arg.kind === "literal" ? arg.value : null;
}

/** The argument is a live value, not plain text. */
export function isCallArgNode(arg: CallArg | undefined): arg is ValueExpr {
  return argText(arg) === null;
}

/** One segment of a `::!` call chain. */
export interface CallHop {
  /** "" until a function is chosen. */
  fnName: string;
  /** Whether the ABI was typed inline rather than fetched. Either way the
   *  hop renders as `::!{fn(types)(ret) args}`. */
  inline: boolean;
  /** Canonical argument types. */
  argTypes: string[];
  /** Canonical output types (multiple allowed; one is selected via
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
   *  count from the end (rendered with the `...` rest marker, dynamic
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
       *  null/undefined while unresolved, the call is incomplete then. */
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
      /** `/` is the rounded division of `@calcFloor!`/`@calcCeil!` (the
       *  checked `@calc!` surface spells integer division `//`); which
       *  way it rounds. Absent means floor. */
      rounding?: Rounding;
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
  | { kind: "not"; operand: ValueExpr }
  | { kind: "callwrap"; helper: CallwrapHelper; call: ValueExpr }
  // (the `bytelen` node key predates the helper unification; it renders as
  // the lang module's @bytes.len!, see callwrapHelperName)
  /** `@reverts!(call)`: whether the read reverts when the assertion runs. */
  | { kind: "reverts"; call: ValueExpr }
  /** `@orElse!(primary fallback)`: the read, or the fallback when it
   *  reverts. */
  | { kind: "orElse"; primary: ValueExpr; fallback: ValueExpr }
  /** `@includes!(array item)`: whether a list holds the item. */
  | { kind: "arrIncludes"; call: ValueExpr; item: ValueExpr }
  /** A read of a Safe (`@safe:threshold!(safe)`, ...). `owner` is the
   *  address `isOwner` asks about; the other reads ignore it. */
  | { kind: "safe"; read: SafeRead; safe: ValueExpr; owner: ValueExpr }
  /** `@all!`/`@any!`/`@count!` over a list: whether every item, or some
   *  item, passes the test, or how many do. `predicate` is the test, a
   *  boolean value in which `element` nodes stand for the item. */
  | { kind: "quant"; op: QuantOp; call: ValueExpr; predicate: ValueExpr }
  /** The item a quantifier's test is run on; `type` is its ABI type.
   *  Only meaningful inside a `quant` predicate. */
  | { kind: "element"; type: string }
  /** `@token:amount!(token amount)`: a number of tokens in the token's base
   *  units, scaled by its decimals when the assertion runs. The amount is
   *  the value it wraps; the token is a symbol, an address or a call
   *  returning one. */
  | { kind: "tokenAmount"; amount: ValueExpr; token: ValueExpr }
  /** `@token:decimals!(token)`, around the token's address. */
  | { kind: "tokenDecimals"; token: ValueExpr }
  | { kind: "split"; call: ValueExpr; delimiter: string; index: string }
  | { kind: "clock"; which: "timestamp" | "blocknumber" }
  | { kind: "chainId" }
  /** EXTCODEHASH of an address (literal or address-returning call). */
  | { kind: "codeHash"; address: ValueExpr }
  /** The deployed code of an address (literal or address-returning call),
   *  a bytes value: the source `@bytes.len!` and `@hash!` wrap. */
  | { kind: "codeAt"; address: ValueExpr }
  /** Whether a call's string return contains a substring
   *  (@str.includes!). */
  | {
      kind: "strtest";
      helper: "includes";
      call: ValueExpr;
      arg: string;
    };

export type CallwrapHelper = "len" | "bytelen" | "hash" | "sum";
export type QuantOp = "all" | "any" | "count";
export type SafeRead =
  | "owners"
  | "threshold"
  | "nonce"
  | "guard"
  | "modules"
  | "isOwner";

/** A value that is a list: a call returning an array, or a Safe's owners
 *  or modules. What `@len!` and `@includes!` wrap. */
export function isListSource(node: ValueExpr): boolean {
  return (
    node.kind === "call" ||
    (node.kind === "safe" && (node.read === "owners" || node.read === "modules"))
  );
}

/** The categories a quantifier's item can be: one word each. */
const ITEM_CATEGORIES = new Set<Category>([
  "uint",
  "int",
  "address",
  "bool",
  "bytes32",
]);

/**
 * The ABI type of one item of a list, when a test can be run on each: the
 * element type of an array a call returns, or `address` for a Safe's
 * owners and modules. Null while the list is not known, and for items
 * that are not a single word (strings, structs, nested arrays).
 */
export function elementTypeOf(list: ValueExpr): string | null {
  if (list.kind === "safe")
    return list.read === "owners" || list.read === "modules" ? "address" : null;
  if (list.kind !== "call") return null;
  const type = producedType(list);
  const level = type ? lensLevelOf(type) : null;
  if (level?.kind !== "array") return null;
  return ITEM_CATEGORIES.has(categoryFromAbiType(level.base)) ? level.base : null;
}

/** The predicate with every item placeholder set to the list's current
 *  item type (the same object when nothing changes). A nested quantifier
 *  keeps its own items. */
export function retypeElements(node: ValueExpr, type: string): ValueExpr {
  if (node.kind === "element")
    return node.type === type ? node : { ...node, type };
  if (node.kind === "quant") {
    const call = retypeElements(node.call, type);
    return call === node.call ? node : { ...node, call };
  }
  let next: Record<string, unknown> | null = null;
  const set = (key: string, value: unknown) => {
    next ??= { ...node };
    next[key] = value;
  };
  for (const [key, value] of Object.entries(node)) {
    if (Array.isArray(value)) {
      const mapped = value.map((item) =>
        isValueExpr(item)
          ? retypeElements(item, type)
          : isHop(item)
            ? retypeHop(item, type)
            : item,
      );
      if (mapped.some((item, i) => item !== value[i])) set(key, mapped);
    } else if (isValueExpr(value)) {
      const child = retypeElements(value, type);
      if (child !== value) set(key, child);
    }
  }
  return (next ?? node) as ValueExpr;
}

const isValueExpr = (value: unknown): value is ValueExpr =>
  !!value && typeof value === "object" && "kind" in value;
const isHop = (value: unknown): value is CallHop =>
  !!value && typeof value === "object" && "args" in value && "fnName" in value;

function retypeHop(hop: CallHop, type: string): CallHop {
  const args = hop.args.map((arg) =>
    typeof arg === "string" ? arg : retypeElements(arg, type),
  );
  return args.some((arg, i) => arg !== hop.args[i]) ? { ...hop, args } : hop;
}

export type Rounding = "floor" | "ceil";

/** EVML/display name of a callwrap helper node: the internal `bytelen`
 *  key predates the helper unification and renders as lang's @bytes.len!
 *  (decoded byte length of a string/bytes return). */
export function callwrapHelperName(helper: CallwrapHelper): string {
  return helper === "bytelen" ? "bytes.len" : helper;
}

export interface Assertion {
  subject: ValueExpr;
  /** null = bare boolean form (`assert $t::!{paused()(bool)} "msg"`). */
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
 *  availability and the "use current value" gate). */
export function isBuildTimeConst(expr: ValueExpr): boolean {
  return expr.kind === "literal";
}

const ENS_RE = /^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$/;

/** Text shaped like an ENS name (`mysafe.eth`), as opposed to an address. */
export const isEnsName = (text: string): boolean => ENS_RE.test(text.trim());

const CAT_FROM_MOD: Record<ModCategory, Category> = {
  Uint: "uint",
  Int: "int",
  Address: "address",
  Bool: "bool",
  Bytes32: "bytes32",
  String: "string",
  Bytes: "bytes",
};

/** The compiler's category for a canonical ABI type, plus the shapes its
 *  table does not reason about: arrays, structs (`(address,uint256)`) and
 *  anything the compiler rejects. */
export function categoryFromAbiType(t: string): Category {
  if (/\[\d*\]$/.test(t)) return "array";
  if (t.startsWith("(")) return "tuple";
  try {
    return CAT_FROM_MOD[sdkCategoryFromAbiType(t)];
  } catch {
    return "unknown";
  }
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

/**
 * Whether a return of these types can end up as a value of the wanted
 * category: directly, by picking an element or a struct value out of it,
 * or because it reaches an address, which can always be called again to
 * get something else.
 */
export function canYield(outputs: string[], wanted: Category): boolean {
  const reaches = (type: string): boolean => {
    const level = lensLevelOf(type);
    if (level === null) {
      const cat = categoryFromAbiType(type);
      return cat === wanted || cat === "address";
    }
    return level.kind === "array"
      ? reaches(level.base)
      : level.components.some(reaches);
  };
  return outputs.some(reaches);
}

/**
 * The ABI type a value ends up as, for telling the user what it is: a
 * call's picked return, or the value's category. Null while a call has no
 * function yet or returns several values with none picked.
 */
export function producedType(expr: ValueExpr): string | null {
  if (expr.kind !== "call") {
    const cat = inferCategory(expr);
    return cat === "unknown" ? null : cat === "uint" ? "uint256" : cat;
  }
  const hops = settledHops(expr.hops);
  const last = hops[hops.length - 1];
  if (!last?.fnName) return null;
  return resolveLens(last)?.terminal ?? null;
}

/**
 * Whether a live value can fill an argument of this ABI type. The compiler
 * splices the value in as it is, so the categories have to agree: an
 * address where a number is expected is refused here, before it reaches a
 * script. A value still being filled in (no category yet) is not judged.
 */
export function argFits(arg: ValueExpr, type: string): boolean {
  const wanted = categoryFromAbiType(type);
  const got = inferCategory(arg);
  return wanted === "unknown" || got === "unknown" || got === wanted;
}

export interface LensSelection {
  /** Type reached after applying every parsed entry. */
  terminal: string;
  /** Parsed entries, shorter than `lensPath` when one is malformed. */
  entries: number[];
  /** Every entry parsed and in range where the arity is known. The
   *  terminal may still be composite; whether that fits depends on the
   *  context (a comparison needs a single word; @len! wants an array). */
  valid: boolean;
}

/** Resolve a hop's selection: walk `lensPath` from the selected output
 *  through array/tuple levels. Null while a multi-value return has no
 *  `lensIndex` yet. */
export function resolveLens(hop: CallHop): LensSelection | null {
  const sel = selectedOutput(hop);
  if (sel === undefined) return null;
  let terminal = sel;
  const entries: number[] = [];
  let malformed = false;
  for (const raw of hop.lensPath ?? []) {
    const level = lensLevelOf(terminal);
    if (!level) break; // stale path beyond a scalar: ignore the rest
    const t = raw.trim();
    if (!/^-?\d+$/.test(t)) {
      malformed = true;
      break;
    }
    const idx = Number(t);
    if (level.kind === "array") {
      if (
        level.length !== undefined &&
        (idx >= level.length || idx < -level.length)
      ) {
        malformed = true;
        break;
      }
      terminal = level.base;
    } else {
      if (idx < 0 || idx >= level.components.length) {
        malformed = true;
        break;
      }
      terminal = level.components[idx];
    }
    entries.push(idx);
  }
  const valid = !malformed && entries.length === (hop.lensPath ?? []).length;
  return { terminal, entries, valid };
}

export function literalCategory(value: string): Category {
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
/**
 * The calls of a chain that count: a chained call added but not chosen yet
 * (no function) is not part of the value, so the chain reads, compiles and
 * previews as it did before it was added.
 */
export function settledHops(hops: CallHop[]): CallHop[] {
  let count = hops.length;
  while (count > 1 && !hops[count - 1].fnName) count--;
  return hops.slice(0, count);
}

export function inferCategory(expr: ValueExpr): Category {
  switch (expr.kind) {
    case "literal":
      return literalCategory(expr.value);
    case "call": {
      const hops = settledHops(expr.hops);
      const last = hops[hops.length - 1];
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
    case "codeAt":
      return "bytes";
    case "strtest":
    case "reverts":
    case "arrIncludes":
      return "bool";
    case "orElse": {
      // Both branches are the same kind of value; the read says which.
      const primary = inferCategory(expr.primary);
      return primary === "unknown" ? inferCategory(expr.fallback) : primary;
    }
    case "safe":
      switch (expr.read) {
        case "owners":
        case "modules":
          return "array";
        case "guard":
          return "address";
        case "isOwner":
          return "bool";
        default:
          return "uint";
      }
    case "tokenAmount":
    case "tokenDecimals":
      return "uint";
    case "quant":
      return expr.op === "count" ? "uint" : "bool";
    case "element":
      return categoryFromAbiType(expr.type);
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

/** UI category to module category; null for array/tuple/unknown, which
 *  have no word representation the table reasons about. */
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
  if (!lm || !rm) return null; // array/tuple: not word-composable
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

/** Operator value for the bare boolean form (`assert target::!{fn()(bool)}`). */
export const BARE_OP = "is true";

/**
 * Operators offered for a subject/expected pair, from the composition
 * table's cmp family. `~=` needs exactly one build-time-constant side; two
 * live numeric sides suggest `@absDiff!(a b) <= d` instead (the editor
 * offers that transform). Dynamic values (string/bytes/array/tuple) keep
 * == / !=: the top-level judge compares them where nested expressions
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
// Tree plumbing: paths fall out of recursive rendering; a path is the list
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
      return node.left;
    case "not":
      return node.operand;
    case "callwrap":
    case "split":
    case "strtest":
    case "reverts":
    case "arrIncludes":
    case "quant":
      return node.call;
    case "orElse":
      return node.primary;
    case "safe":
      return node.safe;
    case "tokenAmount":
      return node.amount;
    case "tokenDecimals":
      return node.token;
    default:
      return null;
  }
}
