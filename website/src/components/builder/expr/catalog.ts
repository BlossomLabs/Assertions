import { INFIX_OPS } from "@evmcrispr/module-assertions/composition";
import type { OpFamily } from "@evmcrispr/module-assertions/composition";
import { helpers } from "@evmcrispr/module-assertions/registry";

import {
  type Category,
  type ValueExpr,
  familyOpsFor,
  inferCategory,
} from "../assertion-model";
// Circular with NodePicker (it renders the entries this module computes);
// safe because both sides only use the other's exports inside functions.
import { type NodeKey, nodeKey } from "./NodePicker";

/**
 * The combinator catalog, derived from the assertions module's generated
 * helper registry so the UI cannot drift from the module: an entry is only
 * offered when its helper exists in the registry, descriptions come from
 * the registry, and any mismatch between the two is reported at dev time.
 *
 * What stays local is the UI *role* of each helper — whether it is a value
 * source, a wrap around an existing node, or an infix engine reached
 * through dedicated node kinds. Which categories each role accepts comes
 * from the module's composition table (the same rules its compiler
 * enforces), so the menus only offer combinations that compile.
 */

type Accepts = (node: ValueExpr, cat: Category) => boolean;

/** Accepts when the composition table allows this family over the node's
 *  category (checked against itself — the other operand doesn't exist
 *  yet). Pass a symbol to require one specific operator (e.g. `and` keeps
 *  the logic role bool-only, excluding numeric bitwise xor). Unknown stays
 *  permissive while the tree is incomplete. */
const familyAccepts =
  (family: OpFamily, symbol?: string): Accepts =>
  (_node, cat) => {
    if (cat === "unknown") return true;
    const ops = familyOpsFor(family, cat, cat);
    return symbol ? ops.includes(symbol) : ops.length > 0;
  };

const stringCall: Accepts = (node, cat) =>
  node.kind === "call" && (cat === "string" || cat === "unknown");
const anyCall: Accepts = (node) => node.kind === "call";
const addressCall: Accepts = (node, cat) =>
  node.kind === "call" && cat === "address";

interface InfixEntry {
  key: NodeKey;
  label: string;
  accepts: Accepts;
}

type HelperRole =
  /** A standalone value the subject/expected picker offers. */
  | {
      role: "source";
      key: NodeKey;
      label: string;
      /** Also offered as a wrap when a node matches (e.g. @codehash! around
       *  an address-returning call). */
      wrapAccepts?: Accepts;
    }
  /** A combinator wrapped around the current node via the (+) menu. */
  | {
      role: "wrap";
      key: NodeKey;
      label: string;
      accepts: Accepts;
      topLevelOnly?: boolean;
    }
  /** Infix syntax entry points surfaced through dedicated node kinds. */
  | { role: "infix"; entries: InfixEntry[] }
  /** Build-time helper with no live node in the expression tree. */
  | { role: "composition-time" };

/** Every registry helper MUST appear here (checked at dev time below). */
const HELPER_ROLES: Record<string, HelperRole> = {
  "balance!": {
    role: "source",
    key: "balance",
    label: "balance",
    wrapAccepts: addressCall,
  },
  "timestamp!": { role: "source", key: "timestamp", label: "timestamp" },
  "blocknumber!": {
    role: "source",
    key: "blocknumber",
    label: "block number",
  },
  "chainid!": { role: "source", key: "chainid", label: "chain id" },
  "codehash!": {
    role: "source",
    key: "codehash",
    label: "code hash",
    wrapAccepts: addressCall,
  },
  "min!": {
    role: "wrap",
    key: "min",
    label: "min of…",
    accepts: familyAccepts("arith"),
  },
  "max!": {
    role: "wrap",
    key: "max",
    label: "max of…",
    accepts: familyAccepts("arith"),
  },
  "absdiff!": {
    role: "wrap",
    key: "absdiff",
    label: "|a − b|",
    accepts: familyAccepts("arith"),
  },
  "len!": {
    role: "wrap",
    key: "len",
    label: "length of…",
    accepts: (node, cat) =>
      node.kind === "call" &&
      (cat === "array" ||
        cat === "string" ||
        cat === "bytes" ||
        cat === "unknown"),
  },
  "bytelen!": {
    role: "wrap",
    key: "bytelen",
    label: "byte length of…",
    accepts: anyCall,
  },
  "hash!": {
    role: "wrap",
    key: "hash",
    label: "hash of…",
    accepts: anyCall,
    topLevelOnly: true,
  },
  "split!": {
    role: "wrap",
    key: "split",
    label: "split string of…",
    accepts: stringCall,
    topLevelOnly: true,
  },
  "includes!": {
    role: "wrap",
    key: "includes",
    label: "contains substring…",
    accepts: stringCall,
  },
  "charset!": {
    role: "wrap",
    key: "charset",
    label: "characters in class…",
    accepts: stringCall,
  },
  "num!": {
    role: "infix",
    entries: [
      { key: "arith", label: "arithmetic…", accepts: familyAccepts("arith") },
    ],
  },
  "bool!": {
    role: "infix",
    entries: [
      { key: "cmp", label: "comparison…", accepts: familyAccepts("cmp") },
      // `and` keeps this bool-only: numeric xor lives in the bitwise node.
      {
        key: "logic",
        label: "logic (and/or/xor)…",
        accepts: familyAccepts("logic", "and"),
      },
    ],
  },
  "not!": {
    role: "infix",
    entries: [
      // Boolean-only in the builder; @not!'s bitwise word complement stays
      // chat/EVML-level.
      { key: "not", label: "not…", accepts: familyAccepts("logic", "and") },
    ],
  },
  "bytes!": {
    role: "infix",
    entries: [
      {
        key: "bytes",
        label: "bitwise (& | ^ << >>)…",
        accepts: familyAccepts("bytes"),
      },
    ],
  },
  codehash: { role: "composition-time" },
};

/** WrapMenu grouping (option groups), keyed by node kind. */
const NODE_GROUP: Partial<Record<NodeKey, string>> = {
  arith: "arithmetic",
  min: "arithmetic",
  max: "arithmetic",
  absdiff: "arithmetic",
  cmp: "comparison & logic",
  logic: "comparison & logic",
  not: "comparison & logic",
  bytes: "bitwise",
  len: "data",
  bytelen: "data",
  hash: "data",
  split: "strings",
  includes: "strings",
  charset: "strings",
  balance: "environment",
  codehash: "environment",
};

if (import.meta.env.DEV) {
  const unmapped = Object.keys(helpers).filter((h) => !(h in HELPER_ROLES));
  const stale = Object.keys(HELPER_ROLES).filter((h) => !(h in helpers));
  if (unmapped.length || stale.length)
    console.warn(
      "[assertion-builder] combinator catalog drift vs the module registry —",
      unmapped.length ? `unmapped helpers: ${unmapped.join(", ")};` : "",
      stale.length ? `mapped but missing from registry: ${stale.join(", ")}` : "",
    );

  // Every operator family of the composition table must be reachable from
  // some infix node the builder offers.
  const reachable = new Set(
    Object.values(HELPER_ROLES)
      .filter((r) => r.role === "infix")
      .flatMap((r) => r.entries.map((e) => e.key)),
  );
  const FAMILY_NODE: Record<OpFamily, NodeKey> = {
    arith: "arith",
    cmp: "cmp",
    logic: "logic",
    bytes: "bytes",
  };
  const unreachable = [...new Set(INFIX_OPS.map((op) => op.family))].filter(
    (family) => !reachable.has(FAMILY_NODE[family]),
  );
  if (unreachable.length)
    console.warn(
      "[assertion-builder] composition-table operator families with no builder node:",
      unreachable.join(", "),
    );
}

export interface CatalogEntry {
  key: NodeKey;
  label: string;
  /** Registry description, surfaced as the option tooltip. */
  description?: string;
  /** WrapMenu option group. */
  group?: string;
}

/** Value sources for the subject/expected pickers: the non-helper leaves
 *  plus every registry-present source helper. */
export function sourceEntries(): CatalogEntry[] {
  const entries: CatalogEntry[] = [
    { key: "literal", label: "value" },
    { key: "call", label: "contract call" },
  ];
  for (const [name, role] of Object.entries(HELPER_ROLES)) {
    if (role.role !== "source" || !(name in helpers)) continue;
    entries.push({
      key: role.key,
      label: role.label,
      description: helpers[name].description,
    });
  }
  return entries;
}

/** Wraps valid around `node` at `depth`, offered by the (+) menu, tagged
 *  with their option group. */
export function wrapEntriesFor(node: ValueExpr, depth: number): CatalogEntry[] {
  const cat = inferCategory(node);
  const entries: CatalogEntry[] = [];
  const push = (key: NodeKey, label: string, description?: string) =>
    entries.push({ key, label, description, group: NODE_GROUP[key] });
  for (const [name, role] of Object.entries(HELPER_ROLES)) {
    if (!(name in helpers)) continue;
    const description = helpers[name].description;
    if (role.role === "wrap") {
      if (depth > 0 && role.topLevelOnly) continue;
      if (role.key === nodeKey(node)) continue;
      if (role.accepts(node, cat)) push(role.key, role.label, description);
    } else if (role.role === "infix") {
      for (const entry of role.entries) {
        if (entry.key === nodeKey(node)) continue;
        if (entry.accepts(node, cat))
          push(entry.key, entry.label, description);
      }
    } else if (role.role === "source" && role.wrapAccepts) {
      if (role.key === nodeKey(node)) continue;
      if (role.wrapAccepts(node, cat)) push(role.key, role.label, description);
    }
  }
  return entries;
}
