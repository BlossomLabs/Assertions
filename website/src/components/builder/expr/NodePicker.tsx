import {
  type ValueExpr,
  emptyCall,
  emptyLiteral,
  unwrapNode,
} from "../assertion-model";
import { Select, type SelectItem } from "../../ui/Select";
import { type CatalogEntry, sourceEntries, wrapEntriesFor } from "./catalog";
import { type IconName, LineIcon } from "./icons";

/** Flattened node-kind key the pickers operate on. */
export type NodeKey =
  | "literal"
  | "call"
  | "balance"
  | "timestamp"
  | "blocknumber"
  | "chainId"
  | "codeHash"
  | "codeAt"
  | "min"
  | "max"
  | "absDiff"
  | "arith"
  | "cmp"
  | "logic"
  | "bytes"
  | "not"
  | "len"
  | "bytelen"
  | "hash"
  | "split"
  | "includes"
  | "charset"
  | "divFloor"
  | "divCeil"
  | "numformat"
  | "numparse";

export function nodeKey(node: ValueExpr): NodeKey {
  switch (node.kind) {
    case "arith":
      if (node.op !== "/") return "arith";
      return node.rounding === "ceil" ? "divCeil" : "divFloor";
    case "minmax":
      return node.op;
    case "clock":
      return node.which;
    case "callwrap":
      return node.helper;
    case "strtest":
      return node.helper;
    default:
      return node.kind as NodeKey;
  }
}

/** Kinds the SourcePicker offers directly (everything else is a wrap). */
const SOURCE_KINDS = new Set<ValueExpr["kind"]>([
  "literal",
  "call",
  "balance",
  "clock",
  "chainId",
  "codeHash",
  "codeAt",
]);

export const isSourceNode = (node: ValueExpr): boolean =>
  SOURCE_KINDS.has(node.kind);

/** The call-shaped seed a transform keeps when converting. */
function seedCall(node: ValueExpr): ValueExpr {
  if (node.kind === "call") return node;
  const primary = unwrapNode(node);
  return primary?.kind === "call" ? primary : emptyCall();
}

/** The value-shaped seed a combinator keeps as its first operand. */
function seedValue(node: ValueExpr): ValueExpr {
  if (node.kind === "literal" && !node.value.trim()) return node;
  return node;
}

/** An address-shaped seed (@balance! account, @codeHash! target). */
function seedAddress(node: ValueExpr): ValueExpr {
  if (node.kind === "call" || node.kind === "literal") return node;
  return emptyLiteral();
}

/** Convert a node to the picked kind in place, preserving a compatible
 *  child where sensible (picking a combinator wraps the current node). */
export function convertNode(node: ValueExpr, key: NodeKey): ValueExpr {
  if (nodeKey(node) === key) return node;
  switch (key) {
    case "literal":
      return node.kind === "literal" ? node : emptyLiteral();
    case "call":
      return seedCall(node);
    case "balance":
      return {
        kind: "balance",
        token: "ETH",
        account:
          node.kind === "call" ? node : { kind: "literal", value: "@me" },
      };
    case "timestamp":
    case "blocknumber":
      return { kind: "clock", which: key };
    case "chainId":
      return { kind: "chainId" };
    case "codeHash":
      return { kind: "codeHash", address: seedAddress(node) };
    case "codeAt":
      return { kind: "codeAt", address: seedAddress(node) };
    case "min":
    case "max":
      return node.kind === "minmax"
        ? { ...node, op: key }
        : { kind: "minmax", op: key, items: [seedValue(node), emptyLiteral()] };
    case "absDiff":
      return { kind: "absDiff", a: seedValue(node), b: emptyLiteral() };
    case "arith":
      return {
        kind: "arith",
        op: "+",
        left: seedValue(node),
        right: emptyLiteral(),
      };
    case "divFloor":
    case "divCeil": {
      const rounding = key === "divCeil" ? "ceil" : "floor";
      return node.kind === "arith" && node.op === "/"
        ? { ...node, rounding }
        : {
            kind: "arith",
            op: "/",
            rounding,
            left: seedValue(node),
            right: emptyLiteral(),
          };
    }
    case "numformat":
      return { kind: "numformat", value: seedValue(node), decimals: "18" };
    case "numparse":
      return {
        kind: "numparse",
        value: seedValue(node),
        decimals: "18",
        rounding: "trunc",
        signedness: "signed",
      };
    case "cmp":
      return {
        kind: "cmp",
        op: "==",
        left: seedValue(node),
        right: emptyLiteral(),
      };
    case "logic":
      return {
        kind: "logic",
        op: "and",
        left: seedValue(node),
        right: emptyLiteral(),
      };
    case "bytes":
      return {
        kind: "bytes",
        op: "&",
        left: seedValue(node),
        right: emptyLiteral(),
      };
    case "not":
      return { kind: "not", operand: seedValue(node) };
    case "len":
    case "bytelen":
    case "hash":
      return node.kind === "callwrap"
        ? { ...node, helper: key }
        : { kind: "callwrap", helper: key, call: seedCall(node) };
    case "split":
      return { kind: "split", call: seedCall(node), delimiter: " ", index: "0" };
    case "includes":
    case "charset":
      return node.kind === "strtest"
        ? { ...node, helper: key }
        : { kind: "strtest", helper: key, call: seedCall(node), arg: "" };
  }
}

/** The source kinds' icons (shared with the simple form's check tiles),
 *  shown on each option and beside the current selection. */
const SOURCE_ICONS: Partial<Record<NodeKey, IconName>> = {
  literal: "value",
  call: "call",
  balance: "balance",
  timestamp: "timestamp",
  blocknumber: "block",
  chainId: "chainId",
  codeHash: "code",
  codeAt: "code",
};

/**
 * The value-source select, shown on source nodes (literal, call, balance,
 * clock, chain id, code hash, deployed code): what this value *is*.
 * Combinators are not listed here: they wrap a value via the WrapMenu.
 */
export function SourcePicker({
  node,
  onConvert,
}: {
  node: ValueExpr;
  onConvert: (next: ValueExpr) => void;
}) {
  const current = nodeKey(node);
  const options = sourceEntries().map((entry) => {
    const icon = SOURCE_ICONS[entry.key as NodeKey];
    return {
      value: entry.key as NodeKey,
      label: entry.label,
      description: entry.description,
      icon: icon ? <LineIcon name={icon} className="size-3.5" /> : undefined,
    };
  });
  return (
    <Select
      variant="chip"
      value={current}
      options={options}
      onChange={(key) => onConvert(convertNode(node, key))}
      title="Change what this value is"
    />
  );
}

/**
 * The contextual (+) menu: operators that can wrap the current node,
 * filtered to what makes sense for its category. Picking one converts the
 * node in place, seeding it as the combinator's first operand: the
 * progressive-disclosure path from a simple value to a composed expression.
 */
export function WrapMenu({
  node,
  depth,
  onConvert,
}: {
  node: ValueExpr;
  depth: number;
  onConvert: (next: ValueExpr) => void;
}) {
  const entries: CatalogEntry[] = wrapEntriesFor(node, depth);
  if (entries.length === 0) return null;
  // Group by operator family, preserving first-seen group order.
  const groups: { name: string | undefined; items: CatalogEntry[] }[] = [];
  for (const entry of entries) {
    const existing = groups.find((g) => g.name === entry.group);
    if (existing) existing.items.push(entry);
    else groups.push({ name: entry.group, items: [entry] });
  }
  const items: SelectItem<NodeKey>[] = groups.map((group) => ({
    label: group.name,
    options: group.items.map((entry) => ({
      value: entry.key as NodeKey,
      label: entry.label,
      description: entry.description,
    })),
  }));
  // Always empty: picking converts the node, the menu itself never holds a
  // selection.
  return (
    <Select<NodeKey | "">
      variant="chip"
      value=""
      placeholder="+ combine…"
      options={items}
      onChange={(key) => {
        if (key) onConvert(convertNode(node, key));
      }}
      title="Combine or transform this value"
    />
  );
}
