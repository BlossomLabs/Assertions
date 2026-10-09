import {
  type ReactNode,
  createContext,
  useCallback,
  useContext,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from "react";
import { createPortal } from "react-dom";

import type { OpFamily } from "@evmcrispr/sdk/onchain";

import {
  type Category,
  type QuantOp,
  type SafeRead,
  type ValueExpr,
  categoryFromAbiType,
  elementTypeOf,
  emptyCall,
  familyOpsFor,
  inferCategory,
  isListSource,
  emptyLiteral,
  unwrapNode,
} from "../assertion-model";
import { Select } from "../../ui/Select";
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
  | "not"
  | "len"
  | "bytelen"
  | "hash"
  | "split"
  | "includes"
  | "divFloor"
  | "divCeil"

  | "sum"
  | "arrIncludes"
  | "reverts"
  | "orElse"
  | "safeOwners"
  | "safeThreshold"
  | "safeIsOwner"
  | "safeGuard"
  | "safeModules"
  | "safeNonce"
  | "tokenAmount"
  | "tokenDecimals"
  | "all"
  | "any"
  | "count"
  | "element";

const SAFE_KEYS: Record<SafeRead, NodeKey> = {
  owners: "safeOwners",
  threshold: "safeThreshold",
  isOwner: "safeIsOwner",
  guard: "safeGuard",
  modules: "safeModules",
  nonce: "safeNonce",
};
const SAFE_READS = Object.fromEntries(
  Object.entries(SAFE_KEYS).map(([read, key]) => [key, read]),
) as Partial<Record<NodeKey, SafeRead>>;

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
    case "safe":
      return SAFE_KEYS[node.read];
    case "quant":
      return node.op;
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
  "element",
]);

export const isSourceNode = (node: ValueExpr): boolean =>
  SOURCE_KINDS.has(node.kind);

/** The call-shaped seed a transform keeps when converting. */
function seedCall(node: ValueExpr): ValueExpr {
  if (node.kind === "call") return node;
  const primary = unwrapNode(node);
  return primary?.kind === "call" ? primary : emptyCall();
}

/** The list a transform keeps: a call, or a Safe's owners or modules. */
function seedList(node: ValueExpr): ValueExpr {
  return isListSource(node) ? node : seedCall(node);
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

/** A new, empty value of the picked source kind. Changing what a value is
 *  replaces it, so nothing of the old value is kept: only combining (the
 *  WrapMenu, through convertNode) carries a value over. The executor is the
 *  default account of a balance, not something inherited. */
export function freshSource(
  node: ValueExpr,
  key: NodeKey,
  elementType?: string,
): ValueExpr {
  if (nodeKey(node) === key) return node;
  switch (key) {
    case "element":
      // Only offered inside a quantifier's test, which says what an item is.
      return elementType !== undefined
        ? { kind: "element", type: elementType }
        : emptyLiteral();
    case "call":
      return emptyCall();
    case "balance":
      return {
        kind: "balance",
        token: "ETH",
        account: { kind: "literal", value: "@me" },
      };
    case "timestamp":
    case "blocknumber":
      return { kind: "clock", which: key };
    case "chainId":
      return { kind: "chainId" };
    case "codeHash":
      return { kind: "codeHash", address: emptyLiteral() };
    case "codeAt":
      return { kind: "codeAt", address: emptyLiteral() };
    default:
      return emptyLiteral();
  }
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
    case "timestamp":
    case "blocknumber":
      return { kind: "clock", which: key };
    case "chainId":
      return { kind: "chainId" };
    // Picked as a kind of value (freshSource), never wrapped around one.
    case "balance":
    case "codeHash":
    case "codeAt":
      return node;
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
    case "not":
      return { kind: "not", operand: seedValue(node) };
    case "len":
      return node.kind === "callwrap"
        ? { ...node, helper: key }
        : { kind: "callwrap", helper: key, call: seedList(node) };
    case "bytelen":
    case "hash":
    case "sum":
      return node.kind === "callwrap"
        ? { ...node, helper: key }
        : { kind: "callwrap", helper: key, call: seedCall(node) };
    case "arrIncludes":
      return { kind: "arrIncludes", call: seedList(node), item: emptyLiteral() };
    case "reverts":
      return { kind: "reverts", call: seedCall(node) };
    case "orElse":
      return { kind: "orElse", primary: seedCall(node), fallback: emptyLiteral() };
    case "safeOwners":
    case "safeThreshold":
    case "safeIsOwner":
    case "safeGuard":
    case "safeModules":
    case "safeNonce":
      return node.kind === "safe"
        ? { ...node, read: SAFE_READS[key] as SafeRead }
        : {
            kind: "safe",
            read: SAFE_READS[key] as SafeRead,
            safe: seedAddress(node),
            owner: emptyLiteral(),
          };
    case "tokenAmount":
      // The number in hand is the amount; the token is filled in next.
      return { kind: "tokenAmount", amount: seedValue(node), token: emptyLiteral() };
    case "tokenDecimals":
      return { kind: "tokenDecimals", token: seedAddress(node) };
    case "all":
    case "any":
    case "count": {
      if (node.kind === "quant") return { ...node, op: key as QuantOp };
      const list = seedList(node);
      // The test starts as a comparison of the item with a value.
      return {
        kind: "quant",
        op: key as QuantOp,
        call: list,
        predicate: {
          kind: "cmp",
          op: "==",
          left: { kind: "element", type: elementTypeOf(list) ?? "" },
          right: emptyLiteral(),
        },
      };
    }
    case "element":
      return node;
    case "split":
      return { kind: "split", call: seedCall(node), delimiter: " ", index: "0" };
    case "includes":
      return node.kind === "strtest"
        ? { ...node, helper: key }
        : { kind: "strtest", helper: key, call: seedCall(node), arg: "" };
  }
}

/** What the sources with a fixed reading produce. A contract call reads
 *  whatever its function returns and plain text is whatever is typed, so
 *  neither is listed. */
const SOURCE_CATEGORY: Partial<Record<NodeKey, Category>> = {
  balance: "uint",
  timestamp: "uint",
  blocknumber: "uint",
  chainId: "uint",
  codeHash: "bytes32",
  codeAt: "bytes",
};

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
  element: "value",
};

/** The item of a quantifier's test, as a source: listed only inside one. */
const ELEMENT_LABEL = "the item";

/**
 * The ABI type of the item being tested, for every value inside a
 * quantifier's test, and undefined outside one. The pickers read it to
 * offer the item as a value; whoever renders a test provides it.
 */
export const ElementScope = createContext<string | undefined>(undefined);

/** What a source value is, as a fixed label: its icon and name. Shown
 *  where the kind is on display but changed elsewhere. */
export function SourceLabel({ node }: { node: ValueExpr }) {
  const key = nodeKey(node);
  const entry = sourceEntries().find((e) => e.key === key);
  const icon = SOURCE_ICONS[key];
  return (
    <span className="inline-flex items-center gap-1.5 px-1.5 text-xs font-mono text-[var(--color-ink-2)]">
      {icon && <LineIcon name={icon} className="size-3.5 opacity-80" />}
      {key === "element" ? ELEMENT_LABEL : (entry?.label ?? key)}
    </span>
  );
}

/**
 * The value-source select, shown on source nodes (literal, call, balance,
 * clock, chain id, code hash, deployed code): what this value *is*.
 * Combinators are not listed here: they wrap a value via the WrapMenu.
 */
export function SourcePicker({
  node,
  onConvert,
  iconOnly = false,
  noLiteral = false,
  accepts,
  elementType,
  title = "Change what this value is",
  className,
}: {
  node: ValueExpr;
  onConvert: (next: ValueExpr) => void;
  /** Inside a quantifier's test: the ABI type of the item being tested,
   *  which is then offered as a value. */
  elementType?: string;
  /** Show the current kind as its icon alone, for tight places. */
  iconOnly?: boolean;
  /** Leave plain text out: the value being checked has to be read from
   *  the chain, a typed value would check nothing. */
  noLiteral?: boolean;
  /** Offer only the kinds that can be a value of this category: plain
   *  text and a contract call always can, the others read one fixed
   *  category each. */
  accepts?: Category;
  title?: string;
  className?: string;
}) {
  const scope = useContext(ElementScope);
  const itemType = elementType ?? scope;
  const current = nodeKey(node);
  const currentIcon = SOURCE_ICONS[current];
  const trigger = iconOnly ? (
    <>
      {currentIcon && <LineIcon name={currentIcon} className="size-3.5" />}
      <svg
        width="10"
        height="10"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <polyline points="6 9 12 15 18 9" />
      </svg>
    </>
  ) : undefined;
  const options = sourceEntries()
    .filter((entry) => !(noLiteral && entry.key === "literal"))
    .filter((entry) => {
      const reads = SOURCE_CATEGORY[entry.key as NodeKey];
      return !accepts || accepts === "unknown" || !reads || reads === accepts;
    })
    .map((entry) => {
    const icon = SOURCE_ICONS[entry.key as NodeKey];
    return {
      value: entry.key as NodeKey,
      label: entry.label,
      description: entry.description,
      icon: icon ? <LineIcon name={icon} className="size-3.5" /> : undefined,
    };
  });
  const itemFits =
    !accepts ||
    accepts === "unknown" ||
    (!!itemType && categoryFromAbiType(itemType) === accepts);
  if (itemType !== undefined && itemFits)
    // First: inside a test, the item is what a value usually is.
    options.unshift({
      value: "element",
      label: ELEMENT_LABEL,
      description: "The item of the list the test is run on.",
      icon: <LineIcon name="value" className="size-3.5" />,
    });
  return (
    <Select
      variant="chip"
      value={current}
      options={options}
      onChange={(key) => onConvert(freshSource(node, key, itemType))}
      trigger={trigger}
      title={title}
      aria-label={trigger ? title : undefined}
      className={className}
    />
  );
}

/** The operator families whose operators the composition table rules on. */
const OP_FAMILY: Partial<Record<NodeKey, OpFamily>> = {
  arith: "arith",
  cmp: "cmp",
  logic: "logic",
};

/** One choice in the palette: the kind it wraps the value in, and for an
 *  operator family the operator it starts with. */
interface PaletteItem {
  key: NodeKey;
  op?: string;
  /** What the button shows. */
  label: string;
  /** What it does, for the tooltip. */
  name: string;
}

const ARITH: PaletteItem[] = [
  { key: "arith", op: "+", label: "+", name: "add" },
  { key: "arith", op: "-", label: "−", name: "subtract" },
  { key: "arith", op: "*", label: "×", name: "multiply" },
  { key: "divFloor", label: "÷", name: "divide, rounding down" },
  { key: "sum", label: "Σ", name: "the total of a list of numbers" },
];
const ARITH_MORE: PaletteItem[] = [
  { key: "arith", op: "//", label: "//", name: "integer division, truncating" },
  { key: "arith", op: "%", label: "%", name: "remainder" },
  { key: "arith", op: "^", label: "^", name: "power" },
  { key: "divCeil", label: "÷ up", name: "divide, rounding up" },
  { key: "min", label: "min", name: "the smallest of several values" },
  { key: "max", label: "max", name: "the largest of several values" },
  { key: "absDiff", label: "|a − b|", name: "absolute difference" },
];
const COMPARE: PaletteItem[] = ["==", "!=", "<", "<=", ">", ">="].map((op) => ({
  key: "cmp" as const,
  op,
  label: op,
  name: `compare with ${op}`,
}));
const LOGIC: PaletteItem[] = [
  { key: "logic", op: "and", label: "and", name: "both are true" },
  { key: "logic", op: "or", label: "or", name: "either is true" },
  { key: "logic", op: "xor", label: "xor", name: "exactly one is true" },
  { key: "not", label: "not", name: "the opposite" },
];
/** What can be read of a Safe. Shown only on an address that is one. */
const OF_SAFE: PaletteItem[] = [
  { key: "safeThreshold", label: "threshold", name: "how many owners must sign" },
  { key: "safeOwners", label: "owners", name: "the list of owners" },
  { key: "safeIsOwner", label: "is owner", name: "whether an address is an owner" },
  { key: "safeGuard", label: "guard", name: "the transaction guard, zero when none" },
  { key: "safeModules", label: "modules", name: "the list of enabled modules" },
  { key: "safeNonce", label: "nonce", name: "the next transaction nonce" },
];
/** What can be asked of what a list or a text holds. */
const CONTENTS: PaletteItem[] = [
  { key: "arrIncludes", label: "contains item", name: "whether a list holds an item" },
  { key: "includes", label: "contains text", name: "whether a string contains a substring" },
  { key: "all", label: "every item", name: "whether every item passes a test" },
  { key: "any", label: "some item", name: "whether some item passes a test" },
  { key: "count", label: "count items", name: "how many items pass a test" },
  { key: "len", label: "length", name: "how many elements" },
];
const OTHER: PaletteItem[] = [
  { key: "bytelen", label: "byte length", name: "how many bytes" },
  { key: "hash", label: "hash", name: "keccak256 of the value" },
  { key: "split", label: "split text", name: "one segment of a string" },
  { key: "reverts", label: "reverts", name: "whether the call reverts" },
  { key: "orElse", label: "fallback", name: "a fallback for when the call reverts" },
  { key: "tokenAmount", label: "token amount", name: "a number of tokens, in the token's base units" },
  { key: "tokenDecimals", label: "token decimals", name: "the decimals of this token" },
];

/**
 * The combine palette, opened from the prominent button at the end of a
 * value's slot: every operation that can wrap the value, laid out by
 * family so the common ones are one click away. Picking one converts the
 * value in place, seeding it as the operation's first operand, with the
 * operator already set. What the value cannot take is greyed out, so the
 * palette keeps its shape.
 */
export function WrapMenu({
  node,
  depth,
  onConvert,
  isSafe = false,
}: {
  node: ValueExpr;
  depth: number;
  onConvert: (next: ValueExpr) => void;
  /** The value is an address known to be a Safe (see useIsSafe): the Safe
   *  reads are offered on it, and on nothing else. */
  isSafe?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [more, setMore] = useState(false);
  const [pos, setPos] = useState<{ top: number; left: number } | null>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const panelRef = useRef<HTMLDivElement>(null);

  const entries: CatalogEntry[] = wrapEntriesFor(node, depth, { isSafe });
  const valid = new Set(entries.map((entry) => entry.key));
  const cat = inferCategory(node);
  // An operator is offered when its family takes this value AND the
  // composition table allows that operator for it: an address can be
  // compared with == but not with <.
  const offered = (item: PaletteItem) => {
    if (!valid.has(item.key)) return false;
    const family = OP_FAMILY[item.key];
    if (!item.op || !family || cat === "unknown") return true;
    return familyOpsFor(family, cat, cat).includes(item.op);
  };
  const describe = (item: PaletteItem) =>
    entries.find((entry) => entry.key === item.key)?.description ?? item.name;

  const close = useCallback(() => {
    setOpen(false);
    setPos(null);
    setMore(false);
  }, []);

  // Place the panel under the button, its right edges aligned, flipping
  // upward when the viewport below runs out.
  const place = useCallback(() => {
    const trigger = triggerRef.current;
    const panel = panelRef.current;
    if (!trigger || !panel) return;
    const r = trigger.getBoundingClientRect();
    const gap = 6;
    const below = window.innerHeight - r.bottom - gap;
    const up = panel.offsetHeight > below && r.top - gap > below;
    const top = up
      ? Math.max(8, r.top - gap - panel.offsetHeight)
      : r.bottom + gap;
    const left = Math.max(
      8,
      Math.min(r.right - panel.offsetWidth, window.innerWidth - panel.offsetWidth - 8),
    );
    setPos({ top, left });
  }, []);

  useLayoutEffect(() => {
    if (!open) return;
    place();
    window.addEventListener("resize", place);
    window.addEventListener("scroll", place, true);
    return () => {
      window.removeEventListener("resize", place);
      window.removeEventListener("scroll", place, true);
    };
  }, [open, more, place]);

  useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      const t = e.target as Node;
      if (triggerRef.current?.contains(t) || panelRef.current?.contains(t)) return;
      close();
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== "Escape") return;
      close();
      triggerRef.current?.focus();
    };
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open, close]);

  if (entries.length === 0) return null;

  const pick = (item: PaletteItem) => {
    const next = convertNode(node, item.key);
    onConvert(
      item.op && "op" in next ? ({ ...next, op: item.op } as ValueExpr) : next,
    );
    close();
  };

  const button = (item: PaletteItem, text = false) => (
    <button
      key={`${item.key}${item.op ?? ""}`}
      type="button"
      disabled={!offered(item)}
      title={describe(item)}
      aria-label={item.name}
      onClick={() => pick(item)}
      className={`h-8 rounded-md border border-[var(--color-ink-3)]/25 text-[var(--color-ink)] transition-colors hover:border-[var(--color-bp-400)] hover:bg-[var(--color-bp-500)]/15 disabled:opacity-30 disabled:pointer-events-none ${
        text ? "px-2 text-xs" : "min-w-8 px-2 font-mono text-sm"
      }`}
    >
      {item.label}
    </button>
  );

  const row = (label: string, children: ReactNode) => (
    <div className="flex items-start gap-3">
      <span className="w-20 shrink-0 pt-2 font-sans text-[10px] uppercase tracking-wider text-[var(--color-ink-3)]">
        {label}
      </span>
      <div className="flex flex-wrap items-center gap-1.5">{children}</div>
    </div>
  );

  const panel = open && typeof document !== "undefined" && (
    <div
      ref={panelRef}
      role="dialog"
      aria-label="Combine or transform this value"
      className="fixed z-50 w-[26rem] max-w-[calc(100vw-1rem)] p-3 space-y-2.5 rounded-[10px] border border-[var(--color-ink-3)]/25 bg-[var(--color-surface-2)] shadow-[0_8px_24px_rgba(8,13,24,0.25)]"
      style={{
        top: pos?.top ?? 0,
        left: pos?.left ?? 0,
        visibility: pos ? "visible" : "hidden",
      }}
    >
      {row(
        "Arithmetic",
        <>
          {ARITH.map((item) => button(item))}
          <button
            type="button"
            aria-expanded={more}
            onClick={() => setMore((m) => !m)}
            className="h-8 px-2 text-xs text-[var(--color-bp-300)] hover:underline"
          >
            {more ? "less" : "more"}
          </button>
          {more && (
            <div className="basis-full flex flex-wrap items-center gap-1.5">
              {ARITH_MORE.map((item) => button(item))}
            </div>
          )}
        </>,
      )}
      {row("Comparison", COMPARE.map((item) => button(item)))}
      {row("Logic", LOGIC.map((item) => button(item)))}
      {/* Only an address that is a Safe has these: no row otherwise. */}
      {isSafe && row("Safe", OF_SAFE.map((item) => button(item, true)))}
      {row("Contains", CONTENTS.map((item) => button(item, true)))}
      {row("Other", OTHER.map((item) => button(item, true)))}
    </div>
  );

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        title="Combine or transform this value"
        aria-label="Combine or transform this value"
        aria-haspopup="dialog"
        aria-expanded={open}
        onClick={() => (open ? close() : setOpen(true))}
        className="shrink-0 size-7 inline-flex items-center justify-center rounded-md bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-bp-400)]/70"
      >
        {/* Two values joining into one: combining, not adding. */}
        <svg
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2.75"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
        >
          <path d="M6 4v3a6 6 0 0 0 6 6" />
          <path d="M18 4v3a6 6 0 0 1-6 6" />
          <path d="M12 13v7" />
        </svg>
      </button>
      {panel && createPortal(panel, document.body)}
    </>
  );
}
