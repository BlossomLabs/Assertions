import {
  type ValueExpr,
  emptyCall,
  emptyLiteral,
  unwrapNode,
} from "../assertion-model";
import { chipSelectCls } from "../ui";

/** Flattened node-kind key the picker operates on. */
export type NodeKey =
  | "literal"
  | "call"
  | "balance"
  | "timestamp"
  | "blocknumber"
  | "min"
  | "max"
  | "absdiff"
  | "arith"
  | "logic"
  | "not"
  | "at"
  | "len"
  | "bytelen"
  | "hash"
  | "split";

export function nodeKey(node: ValueExpr): NodeKey {
  switch (node.kind) {
    case "minmax":
      return node.op;
    case "clock":
      return node.which;
    case "callwrap":
      return node.helper;
    case "neg":
      return "arith";
    default:
      return node.kind as NodeKey;
  }
}

const GROUPS: { label: string; keys: [NodeKey, string][] }[] = [
  {
    label: "Value",
    keys: [
      ["literal", "value"],
      ["call", "contract call"],
      ["balance", "balance (live)"],
      ["timestamp", "timestamp (live)"],
      ["blocknumber", "block number (live)"],
    ],
  },
  {
    label: "Combine",
    keys: [
      ["min", "min of…"],
      ["max", "max of…"],
      ["absdiff", "|a − b|"],
      ["arith", "arithmetic"],
      ["logic", "comparison / logic"],
      ["not", "not…"],
    ],
  },
  {
    label: "Transform a call",
    keys: [
      ["len", "length of…"],
      ["bytelen", "byte length of…"],
      ["hash", "hash of…"],
      ["at", "return word at…"],
      ["split", "split string of…"],
    ],
  },
];

/** Keys only offered at the top level of an assertion side. */
const TOP_LEVEL_KEYS = new Set<NodeKey>(["split", "hash"]);

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
        account: { kind: "literal", value: "@me" },
      };
    case "timestamp":
    case "blocknumber":
      return { kind: "clock", which: key };
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
    case "logic":
      return {
        kind: "logic",
        op: ">",
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
    case "at":
      return { kind: "at", call: seedCall(node), index: "0" };
    case "split":
      return { kind: "split", call: seedCall(node), delimiter: " ", index: "0" };
  }
}

/**
 * The per-node kind select. Picking a combinator wraps the current node as
 * its first operand — the progressive-disclosure path from a simple call
 * to a composed expression.
 */
export function NodePicker({
  node,
  depth,
  onConvert,
}: {
  node: ValueExpr;
  depth: number;
  onConvert: (next: ValueExpr) => void;
}) {
  const current = nodeKey(node);
  return (
    <select
      className={chipSelectCls}
      value={current}
      onChange={(e) => onConvert(convertNode(node, e.target.value as NodeKey))}
      title="Change what this value is"
    >
      {GROUPS.map((group) => {
        const keys = group.keys.filter(
          ([key]) =>
            depth === 0 || !TOP_LEVEL_KEYS.has(key) || key === current,
        );
        if (keys.length === 0) return null;
        return (
          <optgroup key={group.label} label={group.label}>
            {keys.map(([key, label]) => (
              <option key={key} value={key}>
                {label}
              </option>
            ))}
          </optgroup>
        );
      })}
    </select>
  );
}
