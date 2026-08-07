import { type ReactNode, useState } from "react";

import {
  type Category,
  type Issue,
  type Path,
  type ValueExpr,
  unwrapNode,
} from "../assertion-model";
import { inputCls } from "../useContractFunctions";
import { chipSelectCls, smallLabelCls } from "../ui";
import { CallEditor } from "./CallEditor";
import { LiteralEditor } from "./LiteralEditor";
import { NodePicker } from "./NodePicker";

const ARITH_OPS = ["+", "-", "*", "/", "//", "%", "^", "xor"] as const;
const LOGIC_OPS = [">", "<", ">=", "<=", "==", "!=", "and", "or", "xor"] as const;

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
    <select
      className={chipSelectCls}
      value={value}
      onChange={(e) => onChange(e.target.value as T)}
    >
      {options.map((op) => (
        <option key={op} value={op}>
          {op}
        </option>
      ))}
    </select>
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
    case "absdiff":
      return "|a − b|";
    case "arith":
      return `arithmetic (${node.op})`;
    case "neg":
      return "negation";
    case "logic":
      return `logic (${node.op})`;
    case "not":
      return "not …";
    case "callwrap":
      return `@${node.helper}!(…)`;
    case "at":
      return `@at!(… ${node.index})`;
    case "split":
      return `@split!(… ${node.index})`;
    case "clock":
      return `@${node.which}!`;
  }
}

/** A call slot inside a transform (@len!, @at!, @split!) — rendered as a
 *  bare CallEditor since only :: calls are legal there. */
function CallSlot({
  node,
  path,
  update,
  chainId,
  issues,
}: {
  node: ValueExpr;
  path: Path;
  update: TreeUpdate;
  chainId: number;
  issues?: Issue[];
}) {
  if (node.kind !== "call")
    return (
      <ValueEditor
        node={node}
        path={path}
        update={update}
        depth={99}
        chainId={chainId}
        issues={issues}
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
 * step with a left border.
 */
export function ValueEditor({
  node,
  path,
  update,
  depth,
  chainId,
  counterpart,
  timestampHint = false,
  issues,
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
  /** Eager validation issues for the whole tree; each node renders its own. */
  issues?: Issue[];
  onRemove?: () => void;
}) {
  const replace = (next: ValueExpr) => update(path, () => next);
  const unwrapped = unwrapNode(node);
  const [collapsed, setCollapsed] = useState(depth >= 3);
  const pathKey = JSON.stringify(path);
  const ownIssues = (issues ?? []).filter(
    (i) => JSON.stringify(i.path) === pathKey,
  );

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
      issues={issues}
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
            Read at assertion time: ETH (native) balance, or an ERC-20
            balanceOf for a token symbol or address.
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
    case "absdiff":
      body = (
        <div className="space-y-2">
          {child("a", node.a)}
          {child("b", node.b)}
        </div>
      );
      break;
    case "arith":
      body = (
        <div className="space-y-2">
          {child("left", node.left)}
          <OpSelect
            value={node.op}
            options={ARITH_OPS}
            onChange={(op) => update([...path, "op"], () => op)}
          />
          {child("right", node.right)}
        </div>
      );
      break;
    case "neg":
      body = (
        <div className="space-y-2">
          <span className="text-xs font-mono text-[var(--color-ink-3)]">−</span>
          {child("operand", node.operand)}
        </div>
      );
      break;
    case "logic":
      body = (
        <div className="space-y-2">
          {child("left", node.left)}
          <OpSelect
            value={node.op}
            options={LOGIC_OPS}
            onChange={(op) => update([...path, "op"], () => op)}
          />
          {child("right", node.right)}
        </div>
      );
      break;
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
          issues={issues}
        />
      );
      break;
    case "at":
      body = (
        <div className="space-y-2">
          <CallSlot
            node={node.call}
            path={[...path, "call"]}
            update={update}
            chainId={chainId}
            issues={issues}
          />
          <div className="w-28">
            <label className={smallLabelCls}>word index</label>
            <input
              className={inputCls}
              value={node.index}
              onChange={(e) => update([...path, "index"], () => e.target.value)}
              spellCheck={false}
            />
          </div>
        </div>
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
            issues={issues}
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
    case "clock":
      body = (
        <p className="text-xs text-[var(--color-ink-3)]">
          The {node.which === "timestamp" ? "block timestamp" : "block number"}{" "}
          at assertion time (not at composition time).
        </p>
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
        <NodePicker
          node={node}
          depth={depth}
          onConvert={replace}
        />
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
      {ownIssues.length > 0 && (
        <div className="text-xs text-[var(--color-err)] space-y-0.5">
          {ownIssues.map((issue, i) => (
            <p key={i}>{issue.message}</p>
          ))}
        </div>
      )}
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
