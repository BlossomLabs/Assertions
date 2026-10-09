import type { OpFamily } from "@evmcrispr/sdk/onchain";
import { type ReactNode, useEffect } from "react";

import {
  type Category,
  type Path,
  type ValueExpr,
  callwrapHelperName,
  elementTypeOf,
  familyOpsFor,
  inferCategory,
  retypeElements,
  emptyCall,
  argFits,
  argText,
  isCallArgNode,
  unwrapNode,
} from "../assertion-model";
import { inputCls } from "../useContractFunctions";
import { useIsSafe } from "../useIsSafe";
import { smallLabelCls } from "../ui";
import { Select } from "../../ui/Select";
import { ArgMismatch, CallEditor } from "./CallEditor";
import { callTail, lensText, summarize } from "./summarize";
import { PLACEHOLDERS, unixToDatetimeLocal } from "./LiteralEditor";
import {
  ElementScope,
  SourceLabel,
  SourcePicker,
  WrapMenu,
  isSourceNode,
} from "./NodePicker";

/** The operators the composition table allows for this node's operand
 *  categories. An op invalidated by an edit stays listed (the compiler's
 *  diagnostic explains why) instead of blanking the select. */
function infixOptions(
  family: OpFamily,
  node: Extract<ValueExpr, { left: ValueExpr; right: ValueExpr; op: string }>,
): string[] {
  const allowed = familyOpsFor(
    family,
    inferCategory(node.left),
    inferCategory(node.right),
  );
  return allowed.includes(node.op) ? allowed : [node.op, ...allowed];
}

/** Short static label for combinator nodes (their kind is changed by
 *  unwrapping, not by a select). */
function kindLabel(node: ValueExpr): string {
  switch (node.kind) {
    case "minmax":
      return `@${node.op}!`;
    case "absDiff":
      return "@absDiff!";
    case "arith":
      if (node.op === "/")
        return node.rounding === "ceil" ? "@calcCeil!" : "@calcFloor!";
      return "arithmetic";
    case "cmp":
      return "comparison";
    case "logic":
      return "logic";
    case "not":
      return "not";
    case "callwrap":
      return `@${callwrapHelperName(node.helper)}!`;
    case "split":
      return "@str.split!";
    case "strtest":
      return `@str.${node.helper}!`;
    case "reverts":
      return "@reverts!";
    case "orElse":
      return "@orElse!";
    case "arrIncludes":
      return "@includes!";
    case "safe":
      return `@safe:${node.read}!`;
    case "quant":
      return `@${node.op}!`;
    case "tokenAmount":
      return "@token:amount!";
    case "tokenDecimals":
      return "@token:decimals!";
    default:
      return "";
  }
}

/** Friendly inferred-category badge text (null hides the badge). */
function categoryBadge(cat: Category): string | null {
  switch (cat) {
    case "uint":
      return "number";
    case "int":
      return "number (signed)";
    case "unknown":
      return null;
    default:
      return cat;
  }
}

/**
 * What kind of value this is (number, address, bytes32...), as a small tag.
 * It sits beside the value's name, not inside its field: it describes the
 * value and decides which operators and combinations the menus offer.
 * Nothing is shown while the kind is not known yet.
 */
export function CategoryBadge({ node }: { node: ValueExpr }) {
  const badge = categoryBadge(inferCategory(node));
  if (!badge) return null;
  return (
    <span
      className="shrink-0 text-[10px] font-mono px-1 py-0.5 rounded border border-[var(--color-ink-3)]/25 text-[var(--color-ink-3)]"
      title="Inferred value category: decides which operators and combinators the menus offer"
    >
      {badge}
    </span>
  );
}

export interface TreeUpdate {
  (path: Path, updater: (node: any) => any): void;
}

function OpSelect<T extends string>({
  value,
  options,
  onChange,
}: {
  value: T;
  options: readonly T[];
  onChange: (op: T) => void;
}) {
  return (
    <Select
      variant="chip"
      value={value}
      options={options.map((op) => ({ value: op, label: op }))}
      onChange={onChange}
    />
  );
}

/**
 * The item type in scope at a path: that of the nearest quantifier whose
 * test the path goes through. Undefined outside any test.
 */
export function elementScopeAt(root: unknown, path: Path): string | undefined {
  let scope: string | undefined;
  for (let i = 0; i < path.length; i++) {
    if (path[i] !== "predicate") continue;
    const owner = nodeAt(root, path.slice(0, i));
    if (owner?.kind === "quant") scope = elementTypeOf(owner.call) ?? "";
  }
  return scope;
}

/** The node a path points at, or undefined when the tree no longer has it. */
export function nodeAt(root: unknown, path: Path): ValueExpr | undefined {
  const found = path.reduce<any>((n, key) => (n == null ? n : n[key]), root);
  return found && typeof found === "object" && "kind" in found
    ? (found as ValueExpr)
    : undefined;
}

const samePath = (a: Path | null, b: Path) =>
  a !== null && a.length === b.length && a.every((key, i) => key === b[i]);

/** How deep a path sits in the tree, counting values, not array steps. */
const depthOf = (path: Path) =>
  path.filter((key) => key !== "items").length - 1;

/** Why a source reads what it reads, shown in the tray. */
const KIND_HELP: Partial<Record<ValueExpr["kind"], string>> = {
  balance:
    "Read at assertion time: the native balance for the chain's own symbol, or an ERC-20 balanceOf for a token symbol or address.",
  chainId: "The chain id, read on-chain at assertion time.",
  codeHash:
    "EXTCODEHASH at assertion time: bytes32(0) for a nonexistent account, keccak256 of the code otherwise.",
  codeAt:
    "The deployed code at assertion time, as bytes: empty when the address holds no code. Compare its byte length or hash.",
  reverts:
    "True when the call reverts at assertion time, or the address holds no code.",
  orElse:
    "The call's value, or the fallback when the call reverts. Both must be the same kind of value.",
  arrIncludes: "True when the list holds the item, read at assertion time.",
  safe: "Read from the Safe at assertion time. When the Safe is a call, it is whatever address that call returns then.",
  tokenAmount:
    "A human amount in the token's base units, scaled by the token's decimals read at assertion time.",
  tokenDecimals: "The token's decimals, read at assertion time.",
  quant:
    "Runs the test on each item of the list at assertion time. In the test, pick 'the item' wherever the item goes: as a value to compare, or as an argument of a call.",
  element: "Stands for each item of the list in turn while the test runs.",
};

/** Kinds whose settings live in the tray, behind a chip in the slot. */
const hasSettings = (node: ValueExpr) =>
  node.kind === "call" ||
  node.kind === "split" ||
  node.kind === "strtest";

const CALL_PLACEHOLDER = "0x… or mydao.eth";

const bareInputCls =
  "min-w-0 bg-transparent font-mono text-sm outline-none placeholder:text-[var(--color-ink-3)]";
const wordCls = "shrink-0 text-xs text-[var(--color-ink-3)]";
const chipBtnCls =
  "shrink-0 max-w-40 truncate px-1.5 py-0.5 rounded-md text-xs font-mono bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/25";

/** Comparing against a boolean: a fixed true/false select. */
function BoolLiteral({
  value,
  onChange,
}: {
  value: string;
  onChange: (value: string) => void;
}) {
  useEffect(() => {
    if (!["true", "false"].includes(value)) onChange("true");
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value]);
  return (
    <Select
      variant="chip"
      value={value}
      options={[
        { value: "true", label: "true" },
        { value: "false", label: "false" },
      ]}
      onChange={onChange}
    />
  );
}

/**
 * One value, whatever its kind, as a single field (one line tall, more when
 * a long value wraps): what it
 * is on the left, its main parameter in the middle and, for a combined
 * value, the way to unwrap it on the right. The combine
 * button sits outside the field, after it. A value nested inside it is typed in place
 * when it is plain text and shown as a pill otherwise; a pill opens the
 * tray on that value, so nesting never changes the height of the field.
 */
export function ValueSlot({
  node,
  path,
  update,
  chainId,
  openPath,
  onOpen,
  counterpart,
  timestampHint = false,
  fixedKind = false,
  noLiteral = false,
}: {
  node: ValueExpr;
  path: Path;
  update: TreeUpdate;
  chainId: number;
  /** The value the tray is showing, if any. */
  openPath: Path | null;
  onOpen: (path: Path | null) => void;
  /** Category of the comparison's other side (top-level sides only). */
  counterpart?: Category;
  /** Offer the date picker on a top-level literal (timestamp subjects). */
  timestampHint?: boolean;
  /** The kind is shown but not changed here: in the tray, where the menu
   *  that changes it stays on the value's own field in the row. */
  fixedKind?: boolean;
  /** Plain text is not offered as a kind (the value being checked). */
  noLiteral?: boolean;
}) {
  const replace = (next: ValueExpr) => update(path, () => next);
  const isSafe = useIsSafe(node, chainId);
  // A quantifier's test follows its list: when the list changes what an
  // item is, the placeholders in the test change with it.
  const itemType = node.kind === "quant" ? elementTypeOf(node.call) : null;
  const predicate = node.kind === "quant" ? node.predicate : null;
  useEffect(() => {
    if (!itemType || !predicate) return;
    const retyped = retypeElements(predicate, itemType);
    if (retyped !== predicate) update([...path, "predicate"], () => retyped);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [itemType, predicate]);
  const unwrapped = unwrapNode(node);
  const active = samePath(openPath, path);

  /** A nested value: typed here when it is plain text, a pill otherwise. */
  const child = (key: string | number, value: ValueExpr, placeholder = "") => {
    const childPath = [
      ...path,
      ...(typeof key === "number" ? ["items", key] : [key]),
    ];
    const shown = samePath(openPath, childPath);
    // Every operand is its own small field with, at its start, the menu
    // that says what it is: it stays there whatever the operand becomes.
    // Plain text is typed in the field; anything else is a pill that
    // opens the operand in the tray.
    return (
      <span
        className={`flex-1 basis-24 min-w-0 flex items-center gap-1 h-7 pr-2 rounded-md border focus-within:border-[var(--color-bp-400)]/60 ${
          shown
            ? "border-[var(--color-bp-400)]"
            : "border-[var(--color-ink-3)]/25"
        }`}
      >
        {isSourceNode(value) && (
          <SourcePicker
            node={value}
            iconOnly
            onConvert={(next) => {
              update(childPath, () => next);
              // Anything but plain text is filled in from the tray.
              if (next.kind !== "literal") onOpen(childPath);
              else if (shown) onOpen(null);
            }}
            title="Change what this value is"
            className="shrink-0 [&>button]:border-0 [&>button]:gap-0.5 [&>button]:text-[var(--color-bp-300)]"
          />
        )}
        {value.kind === "literal" ? (
          <input
            className={`${bareInputCls} flex-1`}
            placeholder={placeholder || "value"}
            value={value.value}
            onChange={(e) =>
              update([...childPath, "value"], () => e.target.value)
            }
            spellCheck={false}
          />
        ) : (
          <button
            type="button"
            className="flex-1 min-w-0 truncate text-left text-xs font-mono text-[var(--color-bp-300)] hover:underline"
            onClick={() => onOpen(shown ? null : childPath)}
            title="Edit this value"
          >
            {summarize(value)}
          </button>
        )}
      </span>
    );
  };

  const settings = (label: string) => (
    <button
      type="button"
      className={chipBtnCls}
      onClick={() => onOpen(active ? null : path)}
      title="Edit the settings"
    >
      {label}
    </button>
  );

  let body: ReactNode = null;
  switch (node.kind) {
    case "literal":
      body =
        counterpart === "bool" ? (
          <BoolLiteral
            value={node.value}
            onChange={(value) => update([...path, "value"], () => value)}
          />
        ) : (
          <>
            <input
              className={`${bareInputCls} flex-1`}
              placeholder={counterpart ? (PLACEHOLDERS[counterpart] ?? "") : ""}
              value={node.value}
              onChange={(e) => update([...path, "value"], () => e.target.value)}
              spellCheck={false}
            />
            {timestampHint && settings("pick a date")}
          </>
        );
      break;
    case "call": {
      const tail = callTail(node);
      body = (
        <>
          <input
            // As wide as what it holds, so the rest of the call follows
            // the contract directly.
            className={`${bareInputCls} max-w-full`}
            style={{
              width: `${Math.max(node.target.length, CALL_PLACEHOLDER.length) + 1}ch`,
            }}
            aria-label="Contract address or ENS name"
            placeholder={CALL_PLACEHOLDER}
            value={node.target}
            // A new address means a new ABI: the function choice goes too.
            onChange={(e) => replace({ ...emptyCall(), target: e.target.value })}
            onFocus={() => onOpen(path)}
            spellCheck={false}
          />
          {tail && (
            // The whole call, wrapping onto more lines when it is long.
            <button
              type="button"
              className="min-w-0 px-1.5 py-0.5 rounded-md text-left text-xs font-mono break-all bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/25"
              onClick={() => onOpen(active ? null : path)}
              title="Edit the call"
            >
              {tail}
            </button>
          )}
        </>
      );
      break;
    }
    case "balance":
      body = (
        <>
          <input
            className={`${bareInputCls} w-14 shrink-0`}
            aria-label="Token symbol or address"
            placeholder="ETH"
            value={node.token}
            onChange={(e) => update([...path, "token"], () => e.target.value)}
            spellCheck={false}
          />
          <span className={wordCls}>of</span>
          {child("account", node.account, "0x…, name.eth or @me")}
        </>
      );
      break;
    case "codeHash":
    case "codeAt":
      body = (
        <>
          <span className={wordCls}>of</span>
          {child("address", node.address, "0x… or name.eth")}
        </>
      );
      break;
    case "clock":
    case "chainId":
      body = (
        <span className="text-xs text-[var(--color-ink-3)] truncate">
          read on-chain, no input
        </span>
      );
      break;
    case "minmax":
      body = (
        <>
          {node.items.map((item, i) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: positional operands
            <span key={i} className="contents">
              {i > 0 && <span className={wordCls}>,</span>}
              {child(i, item)}
            </span>
          ))}
          <button
            type="button"
            className="shrink-0 text-xs text-[var(--color-bp-300)] hover:underline"
            title="Add an operand"
            onClick={() =>
              update(path, (n) => ({
                ...n,
                items: [...n.items, { kind: "literal", value: "" }],
              }))
            }
          >
            + operand
          </button>
        </>
      );
      break;
    case "absDiff":
      body = (
        <>
          <span className={wordCls}>|</span>
          {child("a", node.a)}
          <span className={wordCls}>−</span>
          {child("b", node.b)}
          <span className={wordCls}>|</span>
        </>
      );
      break;
    case "arith":
    case "cmp":
    case "logic": {
      const family: OpFamily = node.kind === "arith" ? "arith" : node.kind;
      body = (
        <>
          {child("left", node.left)}
          <OpSelect
            value={node.op}
            options={infixOptions(family, node)}
            onChange={(op) => update([...path, "op"], () => op)}
          />
          {node.kind === "arith" && node.op === "/" && (
            <OpSelect
              value={node.rounding ?? "floor"}
              options={["floor", "ceil"] as const}
              onChange={(rounding) =>
                update([...path, "rounding"], () => rounding)
              }
            />
          )}
          {child("right", node.right)}
        </>
      );
      break;
    }
    case "not":
      body = child("operand", node.operand);
      break;
    case "callwrap":
    case "reverts":
      body = child("call", node.call);
      break;
    case "orElse":
      body = (
        <>
          {child("primary", node.primary)}
          <span className={wordCls}>or else</span>
          {child("fallback", node.fallback)}
        </>
      );
      break;
    case "arrIncludes":
      body = (
        <>
          {child("call", node.call)}
          <span className={wordCls}>contains</span>
          {child("item", node.item)}
        </>
      );
      break;
    case "quant":
      body = (
        <>
          {child("call", node.call)}
          <span className={wordCls}>
            {node.op === "count" ? "items where" : "where"}
          </span>
          <ElementScope.Provider value={itemType ?? ""}>
            {child("predicate", node.predicate)}
          </ElementScope.Provider>
        </>
      );
      break;
    case "element":
      body = (
        <span className="text-xs text-[var(--color-ink-3)] truncate">
          each item of the list, in turn
        </span>
      );
      break;
    case "safe":
      body = (
        <>
          {node.read === "isOwner" && (
            <>
              {child("owner", node.owner, "0x… or name.eth")}
              <span className={wordCls}>in</span>
            </>
          )}
          <span className={wordCls}>of</span>
          {child("safe", node.safe, "0x… Safe address")}
        </>
      );
      break;
    case "tokenAmount":
      body = (
        <>
          {child("amount", node.amount, "100")}
          <span className={wordCls}>of</span>
          {child("token", node.token, "DAI or 0x…")}
        </>
      );
      break;
    case "tokenDecimals":
      body = (
        <>
          <span className={wordCls}>of</span>
          {child("token", node.token, "DAI or 0x…")}
        </>
      );
      break;
    case "split":
      body = (
        <>
          {child("call", node.call)}
          {settings(`by ${JSON.stringify(node.delimiter)}, #${node.index || "…"}`)}
        </>
      );
      break;
    case "strtest":
      body = (
        <>
          {child("call", node.call)}
          {settings(node.arg ? JSON.stringify(node.arg) : "set the text…")}
        </>
      );
      break;
  }

  return (
    // The box is the value; combining sits outside it, since what gets
    // combined with something else is the whole box.
    <div className="flex items-center gap-2 min-w-0">
      <div
        className={`flex-1 flex items-stretch min-h-[38px] min-w-0 rounded-lg bg-[var(--color-surface)] border text-sm focus-within:border-[var(--color-bp-400)] ${
          active
            ? "border-[var(--color-bp-400)]"
            : "border-[var(--color-ink-3)]/30"
        }`}
      >
        {/* What this value is. */}
        <div className="shrink-0 flex items-center border-r border-[var(--color-ink-3)]/20 px-1">
          {fixedKind && isSourceNode(node) ? (
            <SourceLabel node={node} />
          ) : isSourceNode(node) ? (
            <SourcePicker
              node={node}
              noLiteral={noLiteral}
              onConvert={(next) => {
                replace(next);
                // A source with settings shows them at once.
                onOpen(hasSettings(next) ? path : active ? null : openPath);
              }}
              className="[&>button]:border-0 [&>button]:text-[var(--color-ink-2)]"
            />
          ) : (
            <span className="px-1.5 text-xs font-mono text-[var(--color-ink-2)]">
              {kindLabel(node)}
            </span>
          )}
        </div>

        {/* Its main parameter. */}
        {/* It wraps onto more lines when it does not fit on one. */}
        <div className="flex-1 min-w-0 flex flex-wrap items-center gap-x-1.5 gap-y-1 px-2 py-1">
          {body}
        </div>

        {/* For a combined value, the way back out. */}
        <div className="shrink-0 flex items-center gap-1 pr-1">
          {unwrapped && (
            <button
              type="button"
              className="size-7 inline-flex items-center justify-center rounded-md text-[var(--color-ink-3)] hover:text-[var(--color-ink)] hover:bg-[var(--color-ink-3)]/15"
              title="Unwrap: keep only the first operand"
              aria-label="Unwrap: keep only the first operand"
              onClick={() => {
                replace(unwrapped);
                onOpen(null);
              }}
            >
              {/* Brackets being taken away. */}
              <svg
                width="15"
                height="15"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
              >
                <path d="M8 4.5H5v15h3" />
                <path d="M16 4.5h3v15h-3" />
                <path d="m9.5 9.5 5 5" />
                <path d="m14.5 9.5-5 5" />
              </svg>
            </button>
          )}
        </div>
      </div>
      <WrapMenu
        node={node}
        depth={depthOf(path)}
        isSafe={isSafe}
        onConvert={(next) => {
          replace(next);
          // An argument stays open: it is handed back with OK or Cancel.
          onOpen(path[path.length - 2] === "args" ? path : null);
        }}
      />
    </div>
  );
}

/**
 * A whole side of the comparison written out on one line, with the part
 * the tray is editing marked. Every part is a way to it: clicking one
 * moves the tray there. This is the tray's "you are here".
 */
function Formula({
  node,
  path,
  openPath,
  onOpen,
}: {
  node: ValueExpr;
  path: Path;
  openPath: Path;
  onOpen: (path: Path) => void;
}) {
  const part = (key: string | number, value: ValueExpr) => (
    <Formula
      node={value}
      path={[...path, ...(typeof key === "number" ? ["items", key] : [key])]}
      openPath={openPath}
      onOpen={onOpen}
    />
  );
  const fn = (name: string, inner: ReactNode) => (
    <>
      {name}({inner})
    </>
  );

  let text: ReactNode;
  switch (node.kind) {
    case "literal":
      text = node.value.trim() || "…";
      break;
    case "call": {
      const target = node.target.trim();
      const calls = node.hops
        .map((hop, h) => ({ hop, h }))
        .filter(({ hop }) => hop.fnName);
      text = !target ? (
        "empty call"
      ) : (
        <>
          {/^0x[0-9a-fA-F]{40}$/.test(target)
            ? `${target.slice(0, 6)}…${target.slice(-4)}`
            : target}
          {calls.map(({ hop, h }) => (
            <span key={h}>
              .{hop.fnName}(
              {hop.args.map((arg, a) => (
                // biome-ignore lint/suspicious/noArrayIndexKey: positional arguments
                <span key={a}>
                  {a > 0 && ", "}
                  {isCallArgNode(arg) ? (
                    <Formula
                      node={arg}
                      path={[...path, "hops", h, "args", a]}
                      openPath={openPath}
                      onOpen={onOpen}
                    />
                  ) : (
                    argText(arg)?.trim() || "…"
                  )}
                </span>
              ))}
              ){lensText(hop)}
            </span>
          ))}
        </>
      );
      break;
    }
    case "balance":
      text = fn("balance", (
        <>
          {node.token || "…"} of {part("account", node.account)}
        </>
      ));
      break;
    case "codeHash":
      text = fn("codeHash", part("address", node.address));
      break;
    case "codeAt":
      text = fn("code", part("address", node.address));
      break;
    case "clock":
      text = node.which === "timestamp" ? "timestamp" : "block number";
      break;
    case "chainId":
      text = "chain id";
      break;
    case "minmax":
      text = fn(
        node.op,
        node.items.map((item, i) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: positional operands
          <span key={i}>
            {i > 0 && ", "}
            {part(i, item)}
          </span>
        )),
      );
      break;
    case "absDiff":
      text = (
        <>
          |{part("a", node.a)} − {part("b", node.b)}|
        </>
      );
      break;
    case "arith":
    case "cmp":
    case "logic":
      text = (
        <>
          {path.length > 1 && "("}
          {part("left", node.left)} {node.op} {part("right", node.right)}
          {path.length > 1 && ")"}
        </>
      );
      break;
    case "not":
      text = <>not {part("operand", node.operand)}</>;
      break;
    case "callwrap":
      text = fn(callwrapHelperName(node.helper), part("call", node.call));
      break;
    case "reverts":
      text = fn("reverts", part("call", node.call));
      break;
    case "orElse":
      text = fn("orElse", (
        <>
          {part("primary", node.primary)}, {part("fallback", node.fallback)}
        </>
      ));
      break;
    case "arrIncludes":
      text = fn("includes", (
        <>
          {part("call", node.call)}, {part("item", node.item)}
        </>
      ));
      break;
    case "safe":
      text = fn(node.read, (
        <>
          {node.read === "isOwner" && <>{part("owner", node.owner)}, </>}
          {part("safe", node.safe)}
        </>
      ));
      break;
    case "quant":
      text = fn(node.op, (
        <>
          {part("call", node.call)}, {part("predicate", node.predicate)}
        </>
      ));
      break;
    case "element":
      text = "item";
      break;
    case "tokenAmount":
      text = fn("amount", (
        <>
          {part("token", node.token)}, {part("amount", node.amount)}
        </>
      ));
      break;
    case "tokenDecimals":
      text = fn("decimals", part("token", node.token));
      break;
    case "split":
      text = fn("split", part("call", node.call));
      break;
    case "strtest":
      text = fn(node.helper, part("call", node.call));
      break;
  }

  const here = samePath(openPath, path);
  const go = (e: { stopPropagation: () => void }) => {
    e.stopPropagation();
    onOpen(path);
  };
  return (
    // biome-ignore lint/a11y/useSemanticElements: parts nest, buttons cannot
    <span
      role="button"
      tabIndex={0}
      aria-current={here ? "true" : undefined}
      title={here ? "You are editing this part" : "Edit this part"}
      onClick={go}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          go(e);
        }
      }}
      className={`cursor-pointer rounded px-0.5 ${
        here
          ? "bg-[var(--color-bp-500)]/30 text-[var(--color-ink)] ring-1 ring-[var(--color-bp-400)]"
          : "hover:bg-[var(--color-bp-500)]/15"
      }`}
    >
      {text}
    </span>
  );
}

/** The settings of a value that do not fit in its slot. */
function Settings({
  node,
  path,
  update,
  chainId,
  timestampHint,
  onOpen,
  wants,
}: {
  node: ValueExpr;
  path: Path;
  update: TreeUpdate;
  chainId: number;
  timestampHint: boolean;
  onOpen: (path: Path) => void;
  /** The ABI type the value has to produce, when it fills an argument. */
  wants?: string;
}) {
  const field = (
    label: string,
    key: string,
    value: string,
    placeholder = "",
  ) => (
    <div className="w-36">
      <label className={smallLabelCls}>{label}</label>
      <input
        className={inputCls}
        placeholder={placeholder}
        value={value}
        onChange={(e) => update([...path, key], () => e.target.value)}
        spellCheck={false}
      />
    </div>
  );

  switch (node.kind) {
    case "call":
      return (
        <CallEditor
          // One editor per call: moving the tray to another call must not
          // carry over the first one's contract, function list or chain.
          key={path.join("/")}
          node={node}
          onChange={(updater) => update(path, updater)}
          chainId={chainId}
          hideTarget
          wants={wants}
          onOpenArg={(hop, arg) => onOpen([...path, "hops", hop, "args", arg])}
        />
      );
    case "literal":
      return timestampHint ? (
        <div className="w-64">
          <label className={smallLabelCls}>
            Pick a date{" "}
            <span className="opacity-60">(synced with the unix timestamp)</span>
          </label>
          <input
            type="datetime-local"
            className={inputCls}
            value={unixToDatetimeLocal(node.value)}
            onChange={(e) => {
              if (e.target.value)
                update([...path, "value"], () =>
                  String(Math.floor(new Date(e.target.value).getTime() / 1000)),
                );
            }}
          />
        </div>
      ) : null;
    case "split":
      return (
        <div className="flex gap-2 flex-wrap">
          {field("delimiter", "delimiter", node.delimiter)}
          {field("segment", "index", node.index)}
        </div>
      );
    case "strtest":
      return (
        <div className="space-y-2">
          {field("substring", "arg", node.arg, "text")}
          <p className="text-xs text-[var(--color-ink-3)]">
            True when the call's string return contains the substring.
          </p>
        </div>
      );
    default:
      return null;
  }
}

/**
 * The tray under the comparison row: the one place a nested value, or a
 * value's settings, is edited. It shows the value the row points at (a
 * pill, or a slot's own settings chip), under the whole side written out
 * with that value marked in it. One value at a time: going deeper
 * replaces it.
 */
export function ValueTray({
  root,
  openPath,
  onOpen,
  update,
  chainId,
  sides,
  timestampPath,
}: {
  /** The tree the paths are rooted in. */
  root: unknown;
  openPath: Path | null;
  onOpen: (path: Path | null) => void;
  update: TreeUpdate;
  chainId: number;
  /** What each top-level key is called, e.g. subject: "Value to check". */
  sides: Record<string, string>;
  /** The literal that takes a date picker, if any. */
  timestampPath?: Path;
}) {
  const node = openPath ? nodeAt(root, openPath) : undefined;
  // The value went away (its parent changed kind): nothing to show.
  useEffect(() => {
    if (openPath && !node) onOpen(null);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [openPath, node]);
  if (!openPath || !node) return null;

  const nested = openPath.length > 1;
  const timestampHint = !!timestampPath && samePath(openPath, timestampPath);
  const side = openPath.slice(0, 1);
  const sideNode = nodeAt(root, side);
  const parentPath = openPath.slice(0, -2);
  const parent =
    typeof openPath[openPath.length - 1] === "number"
      ? nodeAt(root, parentPath)
      : undefined;
  const removable =
    parent?.kind === "minmax" && parent.items.length > 2 ? parent : null;
  const help = KIND_HELP[node.kind];
  // The live value filling an argument of another call: it is handed
  // back to that call, kept or dropped.
  const isArg = openPath[openPath.length - 2] === "args";
  // The call that argument belongs to: past "hops", its index, "args" and
  // the argument's own.
  const argOwner = openPath.slice(0, -4);
  // What that argument's type asks of the value filling it.
  const owner = isArg ? nodeAt(root, argOwner) : undefined;
  const wants =
    owner?.kind === "call"
      ? owner.hops[openPath[openPath.length - 3] as number]?.argTypes[
          openPath[openPath.length - 1] as number
        ]
      : undefined;
  const mismatch = !!wants && !argFits(node, wants);

  return (
    <ElementScope.Provider value={elementScopeAt(root, openPath)}>
    <div className="rounded-lg border border-[var(--color-bp-400)]/40 bg-[var(--color-bp-500)]/5 p-3 space-y-3">
      {/* Where the tray is: the whole side, with the part being edited
          marked in it. */}
      <div className="flex items-start gap-2 text-xs text-[var(--color-ink-3)]">
        <span className="shrink-0 pt-0.5">
          {sides[String(side[0])] ?? String(side[0])}
        </span>
        {sideNode && (
          <span className="min-w-0 font-mono leading-relaxed break-words text-[var(--color-ink-2)]">
            <Formula
              node={sideNode}
              path={side}
              openPath={openPath}
              onOpen={onOpen}
            />{" "}
            <CategoryBadge node={node} />
          </span>
        )}
        <span className="ml-auto shrink-0 flex items-center gap-3 pt-0.5">
          {removable && (
            <button
              type="button"
              className="hover:text-[var(--color-err)]"
              title="Remove this operand"
              onClick={() => {
                const index = openPath[openPath.length - 1] as number;
                update(parentPath, (n) => ({
                  ...n,
                  items: n.items.filter((_: unknown, j: number) => j !== index),
                }));
                onOpen(null);
              }}
            >
              remove
            </button>
          )}
          <button
            type="button"
            className="hover:text-[var(--color-ink-2)]"
            onClick={() => onOpen(null)}
          >
            close
          </button>
        </span>
      </div>

      {nested && (
        <ValueSlot
          node={node}
          path={openPath}
          update={update}
          chainId={chainId}
          openPath={openPath}
          onOpen={onOpen}
          fixedKind
        />
      )}
      <Settings
        node={node}
        path={openPath}
        update={update}
        chainId={chainId}
        timestampHint={timestampHint}
        onOpen={onOpen}
        wants={wants}
      />
      {help && <p className="text-xs text-[var(--color-ink-3)]">{help}</p>}
      {isArg && wants && (
        <p className="text-xs text-[var(--color-ink-3)]">
          This argument takes{" "}
          <span className="font-mono text-[var(--color-ink-2)]">{wants}</span>.
        </p>
      )}
      {isArg && mismatch && wants && <ArgMismatch value={node} type={wants} />}
      {isArg && (
        // A live value is filled in here and handed back to the argument
        // it came from: kept, or dropped for a plain value. One of the
        // wrong type cannot be kept.
        <div className="flex items-center justify-end gap-2 pt-1">
          <button
            type="button"
            className="px-3 py-1.5 rounded-lg text-sm border border-[var(--color-ink-3)]/30 text-[var(--color-ink-2)] hover:border-[var(--color-ink-3)]/60"
            title="Drop the live value and go back to a plain value"
            onClick={() => {
              update(openPath, () => "");
              onOpen(argOwner);
            }}
          >
            Cancel
          </button>
          <button
            type="button"
            disabled={mismatch}
            className="px-4 py-1.5 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed"
            title="Keep the live value and go back to the call it fills"
            onClick={() => onOpen(argOwner)}
          >
            OK
          </button>
        </div>
      )}
    </div>
    </ElementScope.Provider>
  );
}
