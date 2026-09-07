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
  // the lang module's @bytes.len!, see callwrapHelperName)
  | { kind: "split"; call: ValueExpr; delimiter: string; index: string }
  | { kind: "clock"; which: "timestamp" | "blocknumber" }
  | { kind: "chainId" }
  /** EXTCODEHASH of an address (literal or address-returning call). */
  | { kind: "codeHash"; address: ValueExpr }
  /** The deployed code of an address (literal or address-returning call),
   *  a bytes value: the source `@bytes.len!` and `@hash!` wrap. */
  | { kind: "codeAt"; address: ValueExpr }
  /** String predicates over a call's string return (@str.includes!/@str.charset!). */
  | {
      kind: "strtest";
      helper: "includes" | "charset";
      call: ValueExpr;
      arg: string;
    }
  /** `@num.format!(value decimals)`: a raw integer as a decimal string. */
  | { kind: "numformat"; value: ValueExpr; decimals: string }
  /** `@num.parse!(value decimals rounding signedness)`: a decimal string
   *  as a raw integer in base units. */
  | {
      kind: "numparse";
      value: ValueExpr;
      decimals: string;
      rounding: ParseRounding;
      signedness: Signedness;
    };

export type Rounding = "floor" | "ceil";
export type ParseRounding = "trunc" | "floor" | "ceil";
export type Signedness = "signed" | "unsigned";

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
 *  availability and the "use current value" gate). */
export function isBuildTimeConst(expr: ValueExpr): boolean {
  return expr.kind === "literal";
}

const ENS_RE = /^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$/;

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
    case "codeAt":
      return "bytes";
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
    case "numformat":
      return "string";
    case "numparse":
      return expr.signedness === "unsigned" ? "uint" : "int";
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

/** Operator value for the bare boolean form (`assert target::fn()`). */
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
    case "bytes":
      return node.left;
    case "not":
      return node.operand;
    case "callwrap":
    case "split":
    case "strtest":
      return node.call;
    case "numformat":
    case "numparse":
      return node.value;
    default:
      return null;
  }
}
