import { Fragment } from "react";

import {
  type ValueExpr,
  emptyCall,
  emptyLiteral,
  unwrapNode,
} from "../assertion-model";
import { chipSelectCls } from "../ui";
import { type CatalogEntry, sourceEntries, wrapEntriesFor } from "./catalog";
import { type IconName, LineIcon } from "./icons";

/** Flattened node-kind key the pickers operate on. */
export type NodeKey =
  | "literal"
  | "call"
  | "balance"
  | "timestamp"
  | "blocknumber"
  | "chainid"
  | "codehash"
  | "min"
  | "max"
  | "absdiff"
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
  | "charset";

export function nodeKey(node: ValueExpr): NodeKey {
  switch (node.kind) {
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
  "chainid",
  "codehash",
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

/** An address-shaped seed (@balance! account, @codehash! target). */
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
    case "chainid":
      return { kind: "chainid" };
    case "codehash":
      return { kind: "codehash", address: seedAddress(node) };
    case "min":
    case "max":
      return node.kind === "minmax"
        ? { ...node, op: key }
        : { kind: "minmax", op: key, items: [seedValue(node), emptyLiteral()] };
    case "absdiff":
      return { kind: "absdiff", a: seedValue(node), b: emptyLiteral() };
    case "arith":
      return {
        kind: "arith",
        op: "+",
        left: seedValue(node),
        right: emptyLiteral(),
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

/** The source kinds' icons (shared with the simple form's check tiles;
 *  a native <select> can't render icons per option, so the current
 *  selection's icon sits beside the picker). */
const SOURCE_ICONS: Partial<Record<NodeKey, IconName>> = {
  literal: "value",
  call: "call",
  balance: "balance",
  timestamp: "timestamp",
  blocknumber: "block",
  chainid: "chainid",
  codehash: "code",
};

/**
 * The value-source select, shown on source nodes (literal, call, balance,
 * clock, chain id, code hash): what this value *is*. Operators are not
 * listed here — they wrap a value via the WrapMenu instead.
 */
export function SourcePicker({
  node,
  onConvert,
}: {
  node: ValueExpr;
  onConvert: (next: ValueExpr) => void;
}) {
  const current = nodeKey(node);
  const icon = SOURCE_ICONS[current];
  return (
    <span className="inline-flex items-center gap-1.5 text-[var(--color-ink-2)]">
      {icon && <LineIcon name={icon} className="size-3.5 shrink-0 opacity-70" />}
      <select
        className={chipSelectCls}
        value={current}
        onChange={(e) => onConvert(convertNode(node, e.target.value as NodeKey))}
        title="Change what this value is"
      >
        {sourceEntries().map((entry) => (
          <option key={entry.key} value={entry.key} title={entry.description}>
            {entry.label}
          </option>
        ))}
      </select>
    </span>
  );
}

/**
 * The contextual (+) menu: operators that can wrap the current node,
 * filtered to what makes sense for its category. Picking one converts the
 * node in place, seeding it as the combinator's first operand — the
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
  const options = (items: CatalogEntry[]) =>
    items.map((entry) => (
      <option key={entry.key} value={entry.key} title={entry.description}>
        {entry.label}
      </option>
    ));
  return (
    <select
      className={chipSelectCls}
      value=""
      onChange={(e) => {
        if (e.target.value)
          onConvert(convertNode(node, e.target.value as NodeKey));
      }}
      title="Combine or transform this value"
    >
      <option value="">+ combine…</option>
      {groups.map((group, i) =>
        group.name ? (
          <optgroup key={group.name} label={group.name}>
            {options(group.items)}
          </optgroup>
        ) : (
          <Fragment key={i}>{options(group.items)}</Fragment>
        ),
      )}
    </select>
  );
}
