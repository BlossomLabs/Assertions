import { INFIX_OPS } from "@evmcrispr/sdk/onchain";
import type { OpFamily } from "@evmcrispr/sdk/onchain";

import {
  type Category,
  type ValueExpr,
  elementTypeOf,
  familyOpsFor,
  inferCategory,
  isListSource,
  producedType,
} from "../assertion-model";
import { REGISTRIES } from "../helper-owners";
// Circular with NodePicker (it renders the entries this module computes);
// safe because both sides only use the other's exports inside functions.
import { type NodeKey, nodeKey } from "./NodePicker";

/**
 * The combinator catalog, derived from the modules' generated helper
 * registries so the UI cannot drift from them: an entry is only offered
 * when its helper exists in a registry, descriptions come from the
 * registry, and any mismatch between the two is reported at dev time.
 *
 * The on-chain (`!`) helper surface the catalog reads spans seven modules:
 * safe owns the reads of a Safe (@safe:threshold!, @safe:owners!, ...),
 * offered only on an address known to be one, and token owns the amount
 * and decimals helpers. The other five date from the unified
 * helper rework: std owns the composition engines (@calc!/@bool!/@bytes!/
 * @hash!/@balance!) plus the revert probe @reverts! and the `assert` command
 * itself, lang owns the array/string faces (@len!, @str.split!,
 * @bytes.len!, ...), receipts owns the block/tx context reads and the chain
 * id (@block.timestamp!, @tx.from!, @chainId!), contracts owns the code and
 * storage reads (@codeHash!, @codeAt!), and math owns the arithmetic
 * conveniences (@min!, @absDiff!, ...). The catalog merges the receipts and
 * math registries with the on-chain faces of lang, std and contracts (their
 * plain faces are ordinary build-time helpers the builder never offers as
 * nodes).
 *
 * What stays local is the UI *role* of each helper: whether it is a value
 * source, a wrap around an existing node, or an infix engine reached
 * through dedicated node kinds. Which categories each role accepts comes
 * from the module's composition table (the same rules its compiler
 * enforces), so the menus only offer combinations that compile.
 */

/** A registry helper with its provenance (the module that registers it). */
type HelperInfo = { description?: string; module: string };

const faces = (
  module: string,
  keep: (name: string) => boolean = () => true,
): Record<string, HelperInfo> =>
  Object.fromEntries(
    Object.entries(REGISTRIES[module] ?? {})
      .filter(([name]) => keep(name))
      .map(([name, entry]) => [name, { description: entry.description, module }]),
  );
const onchainFaces = (module: string) => faces(module, (name) => name.endsWith("!"));

const helpers: Record<string, HelperInfo> = {
  ...onchainFaces("safe"),
  ...onchainFaces("token"),
  ...onchainFaces("lang"),
  ...onchainFaces("std"),
  ...onchainFaces("contracts"),
  ...faces("receipts"),
  ...faces("math"),
};

/** What is known about a value beyond its shape, looked up on the chain. */
export interface NodeFacts {
  /** The value is an address, and that address is a Safe (for a call,
   *  the address it returns now). */
  isSafe?: boolean;
}

type Accepts = (node: ValueExpr, cat: Category, facts?: NodeFacts) => boolean;

/** Accepts when the composition table allows this family over the node's
 *  category (checked against itself, the other operand doesn't exist
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
/** An address to read something of: one a call returns, or one typed in. */
const addressCall: Accepts = (node, cat) =>
  (node.kind === "call" || node.kind === "literal") && cat === "address";
/** A bytes-like source: a call, or the deployed code of an address. */
const bytesSource: Accepts = (node, cat) =>
  (node.kind === "call" || node.kind === "codeAt") &&
  (cat === "string" || cat === "bytes" || cat === "unknown");

/** A list to look into or measure: an array a call returns, or a Safe's
 *  owners or modules. */
const listSource: Accepts = (node, cat) =>
  isListSource(node) && (cat === "array" || cat === "unknown");
/** A list whose items a test can be run on: one word each. A list not
 *  typed yet is not ruled out. */
const testableList: Accepts = (node, cat) =>
  isListSource(node) && (cat === "unknown" || elementTypeOf(node) !== null);
/** A read that can fail: only a call can revert. */
const liveCall: Accepts = (node) => node.kind === "call";
/** A read whose value a fallback can stand in for: both are one value of
 *  the same kind, so a list or several return values have none. */
const fallbackable: Accepts = (node, cat) =>
  node.kind === "call" && cat !== "array" && cat !== "tuple";
/** A list of numbers a call returns (or one not typed yet). */
const numberList: Accepts = (node, cat) => {
  if (node.kind !== "call") return false;
  if (cat === "unknown") return true;
  return cat === "array" && /^u?int\d*\[\d*\]$/.test(producedType(node) ?? "");
};
/** An address known to be a Safe: one typed in, an ENS name, `@me`, or
 *  the address a call returns now. */
const safeAddress: Accepts = (node, _cat, facts) =>
  (node.kind === "literal" || node.kind === "call") && !!facts?.isSafe;

/** What `@hash!` digests: a bytes-like source, or the bytes of an address or
 *  a bytes32 word. */
const hashSource: Accepts = (node, cat) =>
  bytesSource(node, cat) ||
  (node.kind === "call" && (cat === "address" || cat === "bytes32"));

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
  /** No live node in the expression tree: a build-time helper, or an
   *  on-chain face reachable through chat/EVML only (no builder node yet). */
  | { role: "composition-time" };

/** Registry helpers with no dedicated builder node. The build-time plain
 *  faces (@block.timestamp, @chainId, ...) snapshot at composition time; the
 *  `!` faces here are on-chain but only reachable through chat/EVML. */
const COMPOSITION_TIME = [
  // receipts: plain build-time face of the chain id
  "chainId",
  // contracts: slot derivations over live keys/indices, chat/EVML only
  "slot.mapping!",
  "slot.array!",
  // Left out of the builder on purpose: rarely the thing an assertion
  // checks, and each cost a place in the combine menu. Chat and EVML reach
  // them: the character-class test, decimal formatting and parsing, and the
  // bitwise word operators.
  "str.charset!",
  "num.format!",
  "num.parse!",
  "bytes!",
  // token: reads without a builder node
  "allowance!",
  "symbol!",
  "totalSupply!",
  // std: the lazy ternary over the core's cond, chat/EVML only
  "ifElse!",
  // std: the abi codec faces and the signature check, chat/EVML only
  "abi.decode!",
  "abi.decodeCall!",
  "abi.encode!",
  "abi.encodePacked!",
  "abi.encodeCall!",
  "sigValid!",
  // receipts: plain build-time faces of the block reads (addressed by
  // block number or tag, default latest)
  "block.timestamp",
  "block.number",
  "block.baseFee",
  "block.blobBaseFee",
  "block.hash",
  "block.coinbase",
  "block.gasLimit",
  "block.prevrandao",
  // receipts: block/tx context faces without a builder node
  "block.baseFee!",
  "block.blobBaseFee!",
  "block.hash!",
  "block.coinbase!",
  "block.gasLimit!",
  "block.prevrandao!",
  "tx.from!",
  "tx.gasPrice!",
  "tx.blobHash!",
  // receipts: off-chain receipt readers (chat/EVML only)
  "tx",
  "tx.block",
  "tx.calldata",
  "tx.fee",
  "tx.from",
  "tx.gasUsed",
  "tx.status",
  "tx.timestamp",
  "tx.to",
  "tx.value",
  "txs",
  // math: plain build-time faces and the on-chain sqrt
  "absDiff",
  "min",
  "max",
  "sqrt",
  "sqrt!",
  // math: the fixed-point family, both faces. Their wad/ray scaling has no
  // builder node yet (the exponent and the unit are arguments, not operands),
  // so they stay chat/EVML-level.
  "exp",
  "exp!",
  "ln",
  "ln!",
  "log2",
  "log2!",
  "pow",
  "pow!",
  // lang: array/string on-chain faces without a builder node
  "at!",
  "bytes.at!",
  "bytes.concat!",
  "bytes.not!", // the bitwise word complement; @bool!'s `not` is the logic one
  "bytes.slice!",
  "concat!",
  "enumerate!",
  "filter!",
  "find!",
  "flat!",
  "keys!",
  "lookup!",
  "map!",
  "reduce!",
  "reverse!",
  "slice!",
  "sort!",
  "str.at!",
  "str.concat!",
  "str.join!",
  "str.len!",
  "str.lower!",
  "str.replace!",
  "str.slice!",
  "str.upper!",
  "unique!",
  "unzip!",
  "values!",
  "zip!",
];

/** Every registry helper MUST appear here (checked at dev time below). */
const HELPER_ROLES: Record<string, HelperRole> = {
  ...Object.fromEntries(
    COMPOSITION_TIME.map((name) => [
      name,
      { role: "composition-time" } satisfies HelperRole,
    ]),
  ),
  "balance!": {
    role: "source",
    key: "balance",
    label: "balance",
  },
  "block.timestamp!": { role: "source", key: "timestamp", label: "timestamp" },
  "block.number!": {
    role: "source",
    key: "blocknumber",
    label: "block number",
  },
  "chainId!": { role: "source", key: "chainId", label: "chain id" },
  "codeHash!": {
    role: "source",
    key: "codeHash",
    label: "code hash",
  },
  "codeAt!": {
    role: "source",
    key: "codeAt",
    label: "deployed code",
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
  "absDiff!": {
    role: "wrap",
    key: "absDiff",
    label: "|a − b|",
    accepts: familyAccepts("arith"),
  },
  "len!": {
    role: "wrap",
    key: "len",
    label: "length of…",
    accepts: (node, cat) =>
      isListSource(node) &&
      (cat === "array" ||
        cat === "string" ||
        cat === "bytes" ||
        cat === "unknown"),
  },
  "sum!": {
    role: "wrap",
    key: "sum",
    label: "sum of…",
    accepts: numberList,
  },
  // The array form; the string form is str.includes! below.
  "includes!": {
    role: "wrap",
    key: "arrIncludes",
    label: "contains item…",
    accepts: listSource,
  },
  "all!": {
    role: "wrap",
    key: "all",
    label: "every item…",
    accepts: testableList,
  },
  "any!": {
    role: "wrap",
    key: "any",
    label: "some item…",
    accepts: testableList,
  },
  "count!": {
    role: "wrap",
    key: "count",
    label: "count items…",
    accepts: testableList,
  },
  "reverts!": {
    role: "wrap",
    key: "reverts",
    label: "reverts",
    accepts: liveCall,
  },
  "orElse!": {
    role: "wrap",
    key: "orElse",
    label: "fallback…",
    accepts: fallbackable,
  },
  "owners!": {
    role: "wrap",
    key: "safeOwners",
    label: "owners",
    accepts: safeAddress,
  },
  "threshold!": {
    role: "wrap",
    key: "safeThreshold",
    label: "threshold",
    accepts: safeAddress,
  },
  "isOwner!": {
    role: "wrap",
    key: "safeIsOwner",
    label: "is owner…",
    accepts: safeAddress,
  },
  "guard!": {
    role: "wrap",
    key: "safeGuard",
    label: "guard",
    accepts: safeAddress,
  },
  "modules!": {
    role: "wrap",
    key: "safeModules",
    label: "modules",
    accepts: safeAddress,
  },
  "nonce!": {
    role: "wrap",
    key: "safeNonce",
    label: "nonce",
    accepts: safeAddress,
  },
  // A number becomes an amount of a token; an address is the token whose
  // decimals are read.
  "amount!": {
    role: "wrap",
    key: "tokenAmount",
    label: "token amount…",
    accepts: (node, cat) =>
      (node.kind === "literal" || node.kind === "call") &&
      (cat === "uint" || cat === "unknown"),
  },
  "decimals!": {
    role: "wrap",
    key: "tokenDecimals",
    label: "token decimals",
    accepts: addressCall,
  },
  "bytes.len!": {
    role: "wrap",
    key: "bytelen",
    label: "byte length of…",
    accepts: bytesSource,
  },
  "hash!": {
    role: "wrap",
    key: "hash",
    label: "hash of…",
    accepts: hashSource,
    topLevelOnly: true,
  },
  "str.split!": {
    role: "wrap",
    key: "split",
    label: "split string of…",
    accepts: stringCall,
    topLevelOnly: true,
  },
  "str.includes!": {
    role: "wrap",
    key: "includes",
    label: "contains substring…",
    accepts: stringCall,
  },
  "calc!": {
    role: "infix",
    entries: [
      { key: "arith", label: "arithmetic…", accepts: familyAccepts("arith") },
    ],
  },
  // Rounded division: the arithmetic node with `/` as its root operator,
  // rendered as the helper that names the rounding.
  "calcFloor!": {
    role: "infix",
    entries: [
      {
        key: "divFloor",
        label: "divide, rounding down…",
        accepts: familyAccepts("arith", "/"),
      },
    ],
  },
  "calcCeil!": {
    role: "infix",
    entries: [
      {
        key: "divCeil",
        label: "divide, rounding up…",
        accepts: familyAccepts("arith", "/"),
      },
    ],
  },
  "bool!": {
    role: "infix",
    entries: [
      { key: "cmp", label: "comparison…", accepts: familyAccepts("cmp") },
      // `and` keeps this bool-only: numeric xor is a bitwise operator.
      {
        key: "logic",
        label: "logic (and/or/xor)…",
        accepts: familyAccepts("logic", "and"),
      },
      // Prefix `not` is one of @bool!'s operators, which is also what the
      // codegen emits. The bitwise word complement is a different thing
      // (@lang:bytes.not!) and stays chat/EVML-level.
      { key: "not", label: "not…", accepts: familyAccepts("logic", "and") },
    ],
  },
  // The core's read primitive has no registry helper anymore: `@read!` was
  // replaced by the `::!{sig(argTypes)(retTypes) args}` chain operator,
  // which compiles to the same read. It has no builder node of its own
  // either (CallArg models the nesting directly).
};

/** WrapMenu grouping (option groups), keyed by node kind. */
const NODE_GROUP: Partial<Record<NodeKey, string>> = {
  arith: "arithmetic",
  divFloor: "arithmetic",
  divCeil: "arithmetic",
  min: "arithmetic",
  max: "arithmetic",
  absDiff: "arithmetic",
  cmp: "comparison & logic",
  logic: "comparison & logic",
  not: "comparison & logic",
  len: "data",
  sum: "data",
  arrIncludes: "data",
  all: "data",
  any: "data",
  count: "data",
  reverts: "comparison & logic",
  orElse: "data",
  safeOwners: "safe",
  safeThreshold: "safe",
  safeIsOwner: "safe",
  safeGuard: "safe",
  safeModules: "safe",
  safeNonce: "safe",
  tokenAmount: "decimals",
  tokenDecimals: "decimals",
  bytelen: "data",
  hash: "data",
  split: "strings",
  includes: "strings",
  balance: "environment",
  codeHash: "environment",
  codeAt: "environment",
};

if (import.meta.env.DEV) {
  const unmapped = Object.keys(helpers).filter((h) => !(h in HELPER_ROLES));
  const stale = Object.keys(HELPER_ROLES).filter((h) => !(h in helpers));
  if (unmapped.length || stale.length)
    console.warn(
      "[assertion-builder] operator catalog drift vs the module registry:",
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
  // The bitwise family has no node on purpose (see COMPOSITION_TIME).
  const FAMILY_NODE: Partial<Record<OpFamily, NodeKey>> = {
    arith: "arith",
    cmp: "cmp",
    logic: "logic",
  };
  const unreachable = [...new Set(INFIX_OPS.map((op) => op.family))].filter(
    (family) => {
      const node = FAMILY_NODE[family];
      return node !== undefined && !reachable.has(node);
    },
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
export function wrapEntriesFor(
  node: ValueExpr,
  depth: number,
  facts?: NodeFacts,
): CatalogEntry[] {
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
      if (role.accepts(node, cat, facts)) push(role.key, role.label, description);
    } else if (role.role === "infix") {
      for (const entry of role.entries) {
        if (entry.key === nodeKey(node)) continue;
        if (entry.accepts(node, cat))
          push(entry.key, entry.label, description);
      }
    }
  }
  return entries;
}
