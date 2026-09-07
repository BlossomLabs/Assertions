import type { OpFamily } from "@evmcrispr/sdk/onchain";
import { type ReactNode, useState } from "react";

import {
  type Category,
  type Path,
  type ValueExpr,
  callwrapHelperName,
  familyOpsFor,
  inferCategory,
  unwrapNode,
} from "../assertion-model";
import { inputCls } from "../useContractFunctions";
import { smallLabelCls } from "../ui";
import { Select } from "../../ui/Select";
import { CallEditor } from "./CallEditor";
import { LiteralEditor } from "./LiteralEditor";
import { SourcePicker, WrapMenu, isSourceNode } from "./NodePicker";

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
    case "bytes":
      return "bitwise";
    case "not":
      return "not";
    case "callwrap":
      return `@${callwrapHelperName(node.helper)}!`;
    case "split":
      return "@str.split!";
    case "strtest":
      return `@str.${node.helper}!`;
    case "numformat":
      return "@num.format!";
    case "numparse":
      return "@num.parse!";
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

/** One-line textual summary shown when a deep node is collapsed. */
function summarize(node: ValueExpr): string {
  switch (node.kind) {
    case "literal":
      return node.value.trim() || "(empty value)";
    case "call": {
      const fns = node.hops
        .map((h) => (h.fnName ? `${h.fnName}()` : "…"))
        .join("::");
      return `${node.target.trim() || "…"}::${fns}`;
    }
    case "balance":
      return `@balance!(${node.token} …)`;
    case "minmax":
      return `@${node.op}! of ${node.items.length} values`;
    case "absDiff":
      return "|a − b|";
    case "arith":
      return node.op === "/"
        ? `division, rounding ${node.rounding === "ceil" ? "up" : "down"}`
        : `arithmetic (${node.op})`;
    case "cmp":
      return `comparison (${node.op})`;
    case "logic":
      return `logic (${node.op})`;
    case "bytes":
      return `bitwise (${node.op})`;
    case "not":
      return "not …";
    case "callwrap":
      return `@${callwrapHelperName(node.helper)}!(…)`;
    case "split":
      return `@str.split!(… ${node.index})`;
    case "strtest":
      return `@str.${node.helper}!(… ${node.arg ? JSON.stringify(node.arg) : "…"})`;
    case "numformat":
      return `@num.format!(… ${node.decimals})`;
    case "numparse":
      return `@num.parse!(… ${node.decimals})`;
    case "clock":
      return `@${node.which}!`;
    case "chainId":
      return "@chainId!";
    case "codeHash":
      return "@codeHash!(…)";
    case "codeAt":
      return "@codeAt!(…)";
  }
}

/** A call slot inside a transform (@len!, @str.split!, …): a bare
 *  CallEditor for a `::` call, the deployed-code source one level down
 *  for @bytes.len!/@hash! over @codeAt!, and a deep (collapsed) editor for
 *  anything else the user converted the slot into. */
function CallSlot({
  node,
  path,
  update,
  chainId,
  depth,
}: {
  node: ValueExpr;
  path: Path;
  update: TreeUpdate;
  chainId: number;
  depth: number;
}) {
  if (node.kind !== "call")
    return (
      <ValueEditor
        node={node}
        path={path}
        update={update}
        depth={node.kind === "codeAt" ? depth + 1 : 99}
        chainId={chainId}
      />
    );
  return (
    <CallEditor
      node={node}
      onChange={(updater) => update(path, updater)}
      chainId={chainId}
      compact
    />
  );
}

/**
 * The recursive expression editor. Each node renders a small header (kind
 * picker + unwrap/remove) and a kind-specific body; children indent one
 * step with a left border. Whether the tree compiles is the compiler's
 * verdict, shown by the form under the generated line; the category badge
 * is the eager hint.
 */
export function ValueEditor({
  node,
  path,
  update,
  depth,
  chainId,
  counterpart,
  timestampHint = false,
  onRemove,
}: {
  node: ValueExpr;
  path: Path;
  update: TreeUpdate;
  depth: number;
  chainId: number;
  /** Category of the comparison's other side (top-level sides only). */
  counterpart?: Category;
  /** Offer the date picker on a top-level literal (timestamp subjects). */
  timestampHint?: boolean;
  onRemove?: () => void;
}) {
  const replace = (next: ValueExpr) => update(path, () => next);
  const unwrapped = unwrapNode(node);
  const badge = categoryBadge(inferCategory(node));
  const [collapsed, setCollapsed] = useState(depth >= 3);

  const child = (
    key: string | number,
    childNode: ValueExpr,
    extra?: { onRemove?: () => void },
  ): ReactNode => (
    <ValueEditor
      node={childNode}
      path={[...path, ...(typeof key === "number" ? ["items", key] : [key])]}
      update={update}
      depth={depth + 1}
      chainId={chainId}
      onRemove={extra?.onRemove}
    />
  );

  let body: ReactNode = null;
  switch (node.kind) {
    case "literal":
      body = (
        <LiteralEditor
          value={node.value}
          onChange={(value) => update([...path, "value"], () => value)}
          counterpart={depth === 0 ? counterpart : undefined}
          timestampHint={depth === 0 && timestampHint}
        />
      );
      break;
    case "call":
      body = (
        <CallEditor
          node={node}
          onChange={(updater) => update(path, updater)}
          chainId={chainId}
          compact={depth > 0}
        />
      );
      break;
    case "balance":
      body = (
        <div className="space-y-2">
          <div className="flex gap-2 items-start">
            <div className="w-28">
              <label className={smallLabelCls}>token</label>
              <input
                className={inputCls}
                placeholder="ETH"
                value={node.token}
                onChange={(e) =>
                  update([...path, "token"], () => e.target.value)
                }
                spellCheck={false}
              />
            </div>
            <div className="flex-1">
              <label className={smallLabelCls}>account</label>
              {child("account", node.account)}
            </div>
          </div>
          <p className="text-xs text-[var(--color-ink-3)]">
            Read at assertion time: the native balance for the chain's own
            symbol, or an ERC-20 balanceOf for a token symbol or address.
          </p>
        </div>
      );
      break;
    case "minmax":
      body = (
        <div className="space-y-2">
          {node.items.map((item, i) => (
            <div key={i}>
              {child(i, item, {
                onRemove:
                  node.items.length > 2
                    ? () =>
                        update(path, (n) => ({
                          ...n,
                          items: n.items.filter(
                            (_: unknown, j: number) => j !== i,
                          ),
                        }))
                    : undefined,
              })}
            </div>
          ))}
          <button
            type="button"
            className="text-xs text-[var(--color-bp-300)] hover:underline"
            onClick={() =>
              update(path, (n) => ({
                ...n,
                items: [...n.items, { kind: "literal", value: "" }],
              }))
            }
          >
            + operand
          </button>
        </div>
      );
      break;
    case "absDiff":
      body = (
        <div className="space-y-2">
          {child("a", node.a)}
          {child("b", node.b)}
        </div>
      );
      break;
    case "arith":
    case "cmp":
    case "logic":
    case "bytes": {
      const family: OpFamily = node.kind === "arith" ? "arith" : node.kind;
      const rounded = node.kind === "arith" && node.op === "/";
      body = (
        <div className="space-y-2">
          {child("left", node.left)}
          <div className="flex items-center gap-2 flex-wrap">
            <OpSelect
              value={node.op}
              options={infixOptions(family, node)}
              onChange={(op) => update([...path, "op"], () => op)}
            />
            {rounded && (
              <>
                <OpSelect
                  value={node.rounding ?? "floor"}
                  options={["floor", "ceil"] as const}
                  onChange={(rounding) =>
                    update([...path, "rounding"], () => rounding)
                  }
                />
                <span className="text-xs text-[var(--color-ink-3)]">
                  rounded division; `//` truncates
                </span>
              </>
            )}
          </div>
          {child("right", node.right)}
        </div>
      );
      break;
    }
    case "not":
      body = (
        <div className="space-y-2">
          <span className="text-xs font-mono text-[var(--color-ink-3)]">
            not
          </span>
          {child("operand", node.operand)}
        </div>
      );
      break;
    case "callwrap":
      body = (
        <CallSlot
          node={node.call}
          path={[...path, "call"]}
          update={update}
          chainId={chainId}
          depth={depth}
        />
      );
      break;
    case "split":
      body = (
        <div className="space-y-2">
          <CallSlot
            node={node.call}
            path={[...path, "call"]}
            update={update}
            chainId={chainId}
            depth={depth}
          />
          <div className="flex gap-2">
            <div className="w-28">
              <label className={smallLabelCls}>delimiter</label>
              <input
                className={inputCls}
                value={node.delimiter}
                onChange={(e) =>
                  update([...path, "delimiter"], () => e.target.value)
                }
                spellCheck={false}
              />
            </div>
            <div className="w-28">
              <label className={smallLabelCls}>segment</label>
              <input
                className={inputCls}
                value={node.index}
                onChange={(e) =>
                  update([...path, "index"], () => e.target.value)
                }
                spellCheck={false}
              />
            </div>
          </div>
        </div>
      );
      break;
    case "strtest":
      body = (
        <div className="space-y-2">
          <CallSlot
            node={node.call}
            path={[...path, "call"]}
            update={update}
            chainId={chainId}
            depth={depth}
          />
          <div className="w-40">
            <label className={smallLabelCls}>
              {node.helper === "includes" ? "substring" : "character class"}
            </label>
            <input
              className={inputCls}
              placeholder={node.helper === "includes" ? "text" : "a-z0-9-"}
              value={node.arg}
              onChange={(e) => update([...path, "arg"], () => e.target.value)}
              spellCheck={false}
            />
          </div>
          <p className="text-xs text-[var(--color-ink-3)]">
            {node.helper === "includes"
              ? "True when the call's string return contains the substring."
              : "True when every character of the string return is in the class."}
          </p>
        </div>
      );
      break;
    case "numformat":
      body = (
        <div className="space-y-2">
          {child("value", node.value)}
          <div className="w-28">
            <label className={smallLabelCls}>decimals</label>
            <input
              className={inputCls}
              value={node.decimals}
              onChange={(e) =>
                update([...path, "decimals"], () => e.target.value)
              }
              spellCheck={false}
            />
          </div>
          <p className="text-xs text-[var(--color-ink-3)]">
            The integer in base units as a decimal string (0 to 77 decimals),
            trailing fractional zeros trimmed.
          </p>
        </div>
      );
      break;
    case "numparse":
      body = (
        <div className="space-y-2">
          {child("value", node.value)}
          <div className="flex gap-2 flex-wrap">
            <div className="w-28">
              <label className={smallLabelCls}>decimals</label>
              <input
                className={inputCls}
                value={node.decimals}
                onChange={(e) =>
                  update([...path, "decimals"], () => e.target.value)
                }
                spellCheck={false}
              />
            </div>
            <div>
              <label className={smallLabelCls}>rounding</label>
              <OpSelect
                value={node.rounding}
                options={["trunc", "floor", "ceil"] as const}
                onChange={(rounding) =>
                  update([...path, "rounding"], () => rounding)
                }
              />
            </div>
            <div>
              <label className={smallLabelCls}>signedness</label>
              <OpSelect
                value={node.signedness}
                options={["signed", "unsigned"] as const}
                onChange={(signedness) =>
                  update([...path, "signedness"], () => signedness)
                }
              />
            </div>
          </div>
          <p className="text-xs text-[var(--color-ink-3)]">
            The decimal string as an integer in base units (0 to 77
            decimals).
          </p>
        </div>
      );
      break;
    case "clock":
      body = (
        <p className="text-xs text-[var(--color-ink-3)]">
          The {node.which === "timestamp" ? "block timestamp" : "block number"}{" "}
          at assertion time (not at composition time).
        </p>
      );
      break;
    case "chainId":
      body = (
        <p className="text-xs text-[var(--color-ink-3)]">
          The chain id, read on-chain at assertion time.
        </p>
      );
      break;
    case "codeHash":
      body = (
        <div className="space-y-2">
          <div>
            <label className={smallLabelCls}>account</label>
            {child("address", node.address)}
          </div>
          <p className="text-xs text-[var(--color-ink-3)]">
            EXTCODEHASH at assertion time: bytes32(0) for a nonexistent
            account, keccak256 of the code otherwise.
          </p>
        </div>
      );
      break;
    case "codeAt":
      body = (
        <div className="space-y-2">
          <div>
            <label className={smallLabelCls}>account</label>
            {child("address", node.address)}
          </div>
          <p className="text-xs text-[var(--color-ink-3)]">
            The deployed code at assertion time, as bytes: empty when the
            address holds no code. Compare its byte length or hash.
          </p>
        </div>
      );
      break;
  }

  return (
    <div
      className={
        depth > 0
          ? "pl-3 border-l-2 border-[var(--color-ink-3)]/15 space-y-1.5"
          : "space-y-1.5"
      }
    >
      <div className="flex items-center gap-1.5">
        {isSourceNode(node) ? (
          <SourcePicker node={node} onConvert={replace} />
        ) : (
          <span className="text-xs font-mono px-1.5 py-0.5 rounded bg-[var(--color-ink-3)]/10 text-[var(--color-ink-2)]">
            {kindLabel(node)}
          </span>
        )}
        {badge && (
          <span
            className="text-[10px] font-mono px-1 py-0.5 rounded border border-[var(--color-ink-3)]/25 text-[var(--color-ink-3)]"
            title="Inferred value category: decides which operators and combinators the menus offer"
          >
            {badge}
          </span>
        )}
        <WrapMenu node={node} depth={depth} onConvert={replace} />
        {unwrapped && (
          <button
            type="button"
            className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
            title="Unwrap: keep only the first operand"
            onClick={() => replace(unwrapped)}
          >
            unwrap
          </button>
        )}
        {onRemove && (
          <button
            type="button"
            className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-err)]"
            title="Remove this operand"
            onClick={onRemove}
          >
            remove
          </button>
        )}
        {depth > 0 && (
          <button
            type="button"
            className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
            title={collapsed ? "Expand this value" : "Collapse this value"}
            onClick={() => setCollapsed((c) => !c)}
          >
            {collapsed ? "expand" : "collapse"}
          </button>
        )}
      </div>
      {collapsed ? (
        <p className="text-xs font-mono text-[var(--color-ink-3)] truncate">
          {summarize(node)}
        </p>
      ) : (
        body
      )}
    </div>
  );
}
