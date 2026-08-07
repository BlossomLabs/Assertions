import { isAddress } from "viem";

/**
 * The assertion expression model. An assertion compares two value
 * expressions; each side is a tree of contract calls, literals and
 * assertions-1.1 combinators (`@min!`, `@absdiff!`, `@num!`, …) that the
 * codegen renders into an `assertions:assert` line.
 *
 * Nodes hold only serializable strings — ABI fetching and ENS resolution
 * stay in the editor components (one `useContractFunctions` per call node).
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
  /** Dynamic/array return — only legal inside len/bytelen/hash/at (or as
   *  the single operand of min/max). */
  | "array"
  /** Multi-output call — only legal inside @at!. */
  | "tuple"
  | "unknown";

/** One segment of a `::` call chain. */
export interface CallHop {
  /** "" until a function is chosen. */
  fnName: string;
  /** Inline-ABI form `{fn(types)(ret) args}` vs an ABI-known `fn(args)`. */
  inline: boolean;
  /** Canonical argument types. */
  argTypes: string[];
  /** Canonical output types (multiple allowed — gated to @at! at the end
   *  of a chain, or continued via `lensIndex` mid-chain). */
  returnTypes: string[];
  /** Raw form strings, positional. */
  args: string[];
  /** On a non-final hop with several return values: the index of the
   *  address output the chain continues on, rendered as a destructure
   *  lens (`[_ $ _]`). Undefined for single-address hops. */
  lensIndex?: number;
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
  | { kind: "absdiff"; a: ValueExpr; b: ValueExpr }
  | {
      kind: "arith";
      op: "+" | "-" | "*" | "/" | "//" | "%" | "^" | "xor";
      left: ValueExpr;
      right: ValueExpr;
    }
  | { kind: "neg"; operand: ValueExpr }
  | {
      kind: "logic";
      op: "or" | "and" | "xor" | "==" | "!=" | "<" | "<=" | ">" | ">=";
      left: ValueExpr;
      right: ValueExpr;
    }
  | { kind: "not"; operand: ValueExpr }
  | { kind: "callwrap"; helper: "len" | "bytelen" | "hash"; call: ValueExpr }
  | { kind: "at"; call: ValueExpr; index: string }
  | { kind: "split"; call: ValueExpr; delimiter: string; index: string }
  | { kind: "clock"; which: "timestamp" | "blocknumber" };

export interface Assertion {
  subject: ValueExpr;
  /** null = bare boolean form (`assert $t::paused() "msg"`). */
  operator: string | null;
  expected: ValueExpr | null;
  /** Tolerance, used when operator is "~=". */
  delta: string;
  message: string;
}

/** Node kinds that only compare at the top level of an assertion side
 *  (`@split!`, `@hash!` — the callwrap check special-cases hash). */
export const TOP_LEVEL_ONLY = new Set(["split"]);

export const emptyLiteral = (): ValueExpr => ({ kind: "literal", value: "" });
export const emptyCall = (): ValueExpr => ({
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
  if (/^uint\d*$/.test(t)) return "uint";
  if (/^int\d*$/.test(t)) return "int";
  if (t === "address") return "address";
  if (t === "bool") return "bool";
  if (t === "bytes32") return "bytes32";
  if (/^bytes\d+$/.test(t)) return "bytes32";
  return "unknown";
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
      if (last.returnTypes.length > 1) return "tuple";
      return categoryFromAbiType(last.returnTypes[0]);
    }
    case "balance":
    case "clock":
      return "uint";
    case "minmax":
      return expr.items.some((i) => inferCategory(i) === "int") ? "int" : "uint";
    case "absdiff":
      return "uint";
    case "arith":
      return inferCategory(expr.left) === "int" ||
        inferCategory(expr.right) === "int"
        ? "int"
        : "uint";
    case "neg":
      return "int";
    case "logic":
    case "not":
      return "bool";
    case "callwrap":
      return expr.helper === "hash" ? "bytes32" : "uint";
    case "at":
      // Raw 32-byte return word, exposed as a number.
      return "uint";
    case "split":
      return "string";
  }
}

const NUMERIC: ReadonlySet<Category> = new Set(["uint", "int", "unknown"]);

/** Operator value for the bare boolean form (`assert target::fn()`). */
export const BARE_OP = "is true";

/**
 * Operators available for a subject/expected pair. `~=` needs exactly one
 * build-time-constant side; two live numeric sides suggest
 * `@absdiff!(a b) <= d` instead (the editor offers that transform).
 */
export function opsFor(
  subjectCat: Category,
  expectedCat: Category,
  subjectConst: boolean,
  expectedConst: boolean,
): string[] {
  if (subjectCat === "bool") return [BARE_OP, "==", "!="];
  if (NUMERIC.has(subjectCat) && NUMERIC.has(expectedCat)) {
    const ops = ["==", "!=", ">", "<", ">=", "<="];
    if (subjectConst !== expectedConst) ops.push("~=");
    return ops;
  }
  return ["==", "!="];
}

// ---------------------------------------------------------------------------
// Tree plumbing: paths fall out of recursive rendering — a path is the list
// of keys/indices from the assertion root, e.g. ["subject","items",0].
// ---------------------------------------------------------------------------

export type Path = (string | number)[];

export function getAt(root: unknown, path: Path): unknown {
  let node: unknown = root;
  for (const key of path) node = (node as Record<string | number, unknown>)?.[key];
  return node;
}

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

/** Kinds a node can be wrapped into (the progressive-disclosure entry). */
export type WrapKind =
  | "minmax-min"
  | "minmax-max"
  | "absdiff"
  | "arith"
  | "logic"
  | "not"
  | "len"
  | "bytelen"
  | "hash"
  | "at"
  | "split"
  | "neg";

/** Put `node` into the first slot of a new combinator. */
export function wrapNode(node: ValueExpr, kind: WrapKind): ValueExpr {
  switch (kind) {
    case "minmax-min":
      return { kind: "minmax", op: "min", items: [node, emptyLiteral()] };
    case "minmax-max":
      return { kind: "minmax", op: "max", items: [node, emptyLiteral()] };
    case "absdiff":
      return { kind: "absdiff", a: node, b: emptyLiteral() };
    case "arith":
      return { kind: "arith", op: "+", left: node, right: emptyLiteral() };
    case "logic":
      return { kind: "logic", op: "and", left: node, right: emptyLiteral() };
    case "not":
      return { kind: "not", operand: node };
    case "neg":
      return { kind: "neg", operand: node };
    case "len":
      return { kind: "callwrap", helper: "len", call: node };
    case "bytelen":
      return { kind: "callwrap", helper: "bytelen", call: node };
    case "hash":
      return { kind: "callwrap", helper: "hash", call: node };
    case "at":
      return { kind: "at", call: node, index: "0" };
    case "split":
      return { kind: "split", call: node, delimiter: " ", index: "0" };
  }
}

/** The designated primary child a combinator unwraps back to. */
export function unwrapNode(node: ValueExpr): ValueExpr | null {
  switch (node.kind) {
    case "minmax":
      return node.items[0] ?? null;
    case "absdiff":
      return node.a;
    case "arith":
      return node.left;
    case "logic":
      return node.left;
    case "not":
    case "neg":
      return node.operand;
    case "callwrap":
    case "at":
    case "split":
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

function walk(
  expr: ValueExpr,
  path: Path,
  depth: number,
  issues: Issue[],
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
    case "call":
      for (const hop of expr.hops.slice(0, -1)) {
        if (!hop.fnName) continue;
        const continuesOn =
          hop.lensIndex !== undefined
            ? hop.returnTypes[hop.lensIndex]
            : hop.returnTypes.length === 1
              ? hop.returnTypes[0]
              : undefined;
        if (continuesOn !== "address")
          issues.push({
            path,
            message:
              "Every :: hop except the last must continue on an address. Pick the address return value to chain on.",
          });
      }
      break;
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
    case "absdiff":
      walk(expr.a, [...path, "a"], depth + 1, issues);
      walk(expr.b, [...path, "b"], depth + 1, issues);
      break;
    case "arith":
      if (
        expr.op === "^" &&
        (inferCategory(expr.left) === "int" ||
          inferCategory(expr.right) === "int")
      )
        issues.push({
          path,
          message: "^ (exponentiation) is not supported for signed values.",
        });
      walk(expr.left, [...path, "left"], depth + 1, issues);
      walk(expr.right, [...path, "right"], depth + 1, issues);
      break;
    case "neg":
      walk(expr.operand, [...path, "operand"], depth + 1, issues);
      break;
    case "logic": {
      const cmp = ["==", "!=", "<", "<=", ">", ">="].includes(expr.op);
      if (cmp) {
        const l = inferCategory(expr.left);
        if (l === "string")
          issues.push({
            path,
            message:
              "Strings can only be compared at the top level of an assertion.",
          });
      }
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
          message: `@${expr.helper}! expects a :: call expression.`,
        });
      walk(expr.call, [...path, "call"], depth + 1, issues);
      break;
    case "at":
      if (!/^\d+$/.test(expr.index.trim()))
        issues.push({
          path,
          message: "@at! needs a non-negative integer word index.",
        });
      if (expr.call.kind !== "call")
        issues.push({ path, message: "@at! expects a :: call expression." });
      walk(expr.call, [...path, "call"], depth + 1, issues);
      break;
    case "split":
      if (depth > 0)
        issues.push({
          path,
          message: "@split! results can only be compared at the top level.",
        });
      if (!expr.delimiter)
        issues.push({ path, message: "@split! needs a non-empty delimiter." });
      if (!/^\d+$/.test(expr.index.trim()))
        issues.push({
          path,
          message: "@split! needs a non-negative integer segment index.",
        });
      if (expr.call.kind !== "call")
        issues.push({ path, message: "@split! expects a :: call expression." });
      walk(expr.call, [...path, "call"], depth + 1, issues);
      break;
    case "clock":
      break;
  }

  // A bare tuple/array side needs a transform to become comparable.
  if (depth === 0) {
    const cat = inferCategory(expr);
    if (cat === "tuple")
      issues.push({
        path,
        message:
          "This call returns several values. Wrap it in @at! to pick one.",
      });
    if (cat === "array")
      issues.push({
        path,
        message:
          "This call returns a dynamic value. Compare its @len!, @bytelen! or @hash! instead.",
      });
  }
}

export function validateAssertion(assertion: Assertion): Issue[] {
  const issues: Issue[] = [];
  walk(assertion.subject, ["subject"], 0, issues);
  if (assertion.expected)
    walk(assertion.expected, ["expected"], 0, issues);

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
            "~= needs one constant side. For two live values use @absdiff!(a b) <= delta.",
        });
    }
  }
  return issues;
}
