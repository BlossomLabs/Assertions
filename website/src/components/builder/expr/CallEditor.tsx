import { useEffect, useMemo, useState } from "react";
import { isAddress, parseAbiItem } from "viem";

import type { CallHop, ValueExpr } from "../assertion-model";
import {
  canonicalType,
  inputCls,
  toInputs,
  useContractFunctions,
} from "../useContractFunctions";
import { labelCls, smallLabelCls } from "../ui";

/** Sentinel for the dropdown option that reveals the manual signature inputs. */
const CUSTOM_SIG = "__custom__";

type CallNode = Extract<ValueExpr, { kind: "call" }>;

const emptyHop = (): CallHop => ({
  fnName: "",
  inline: false,
  argTypes: [],
  returnTypes: [],
  args: [],
});

/** Parse "fn(argTypes)" + returns into an inline hop, or null while invalid. */
function parseInlineHop(sig: string, ret: string): Omit<CallHop, "args"> | null {
  if (!sig.trim() || !ret.trim()) return null;
  try {
    const item = parseAbiItem(
      `function ${sig.trim()} view returns (${ret.trim()})`,
    );
    if (item.type !== "function" || item.outputs.length === 0) return null;
    return {
      fnName: item.name,
      inline: true,
      argTypes: item.inputs.map(canonicalType),
      returnTypes: item.outputs.map(canonicalType),
    };
  } catch {
    return null;
  }
}

/** Argument input rows for one hop. */
function ArgInputs({
  inputs,
  hop,
  onArgs,
}: {
  inputs: { name: string; type: string }[];
  hop: CallHop;
  onArgs: (args: string[]) => void;
}) {
  if (inputs.length === 0) return null;
  return (
    <div className="space-y-2">
      {inputs.map((input, i) => (
        <div key={`${input.name}-${i}`}>
          <label className={smallLabelCls}>
            {input.name} <span className="opacity-60">({input.type})</span>
            {input.type === "address" && (
              <span className="opacity-60"> (@me = the executor)</span>
            )}
          </label>
          <input
            className={inputCls}
            value={hop.args[i] ?? ""}
            onChange={(e) => {
              const args = [...hop.args];
              args[i] = e.target.value;
              onArgs(args);
            }}
            spellCheck={false}
          />
        </div>
      ))}
    </div>
  );
}

/** Manual signature editor writing an inline-ABI hop (used for the custom
 *  fallback on hop 0 and for every chained hop, which has no ABI source). */
function InlineHopEditor({
  hop,
  onHop,
  compact,
}: {
  hop: CallHop;
  onHop: (hop: CallHop) => void;
  compact: boolean;
}) {
  const [sig, setSig] = useState(() =>
    hop.inline && hop.fnName ? `${hop.fnName}(${hop.argTypes.join(",")})` : "",
  );
  const [ret, setRet] = useState(() =>
    hop.inline && hop.fnName ? hop.returnTypes.join(",") : "",
  );

  // Push the parse into the hop whenever it becomes valid.
  useEffect(() => {
    const parsed = parseInlineHop(sig, ret);
    if (!parsed) return;
    const next: CallHop = {
      ...parsed,
      args: parsed.argTypes.map((t, i) =>
        hop.argTypes[i] === t ? (hop.args[i] ?? "") : "",
      ),
    };
    if (
      JSON.stringify({ ...hop, args: undefined }) !==
        JSON.stringify({ ...next, args: undefined }) ||
      next.args.length !== hop.args.length
    )
      onHop(next);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sig, ret]);

  const argInputs = useMemo(() => {
    if (!hop.inline || !hop.fnName)
      return [] as { name: string; type: string }[];
    try {
      const item = parseAbiItem(
        `function ${hop.fnName}(${hop.argTypes.join(",")}) view returns (${hop.returnTypes.join(",")})`,
      );
      if (item.type === "function") return toInputs(item.inputs);
    } catch {
      /* fall through */
    }
    return hop.argTypes.map((type, i) => ({ name: `arg${i}`, type }));
  }, [hop]);

  return (
    <div className="space-y-2">
      <div className="grid grid-cols-[1fr_8rem] gap-2">
        <div>
          <label className={compact ? smallLabelCls : labelCls}>
            Function signature
          </label>
          <input
            className={inputCls}
            placeholder="balanceOf(address)"
            value={sig}
            onChange={(e) => setSig(e.target.value)}
            spellCheck={false}
          />
        </div>
        <div>
          <label className={compact ? smallLabelCls : labelCls}>Returns</label>
          <input
            className={inputCls}
            placeholder="uint256"
            value={ret}
            onChange={(e) => setRet(e.target.value)}
            spellCheck={false}
          />
        </div>
      </div>
      <ArgInputs
        inputs={argInputs}
        hop={hop}
        onArgs={(args) => onHop({ ...hop, args })}
      />
    </div>
  );
}

/**
 * The ABI-driven editor for one call node: target address/ENS input,
 * view-function select with a custom-signature (inline-ABI) fallback, one
 * input per argument, and optional `::` chain hops (each hop but the last
 * must return a single address). Fetches the verified ABI itself — one
 * `useContractFunctions` instance per rendered call node.
 */
export function CallEditor({
  node,
  onChange,
  chainId,
  compact = false,
}: {
  node: CallNode;
  onChange: (updater: (node: CallNode) => CallNode) => void;
  chainId: number;
  /** Nested nodes drop the field labels to keep the tree readable. */
  compact?: boolean;
}) {
  const contract = useContractFunctions(chainId, node.target, "view");
  const hop = node.hops[0] ?? emptyHop();
  const [customChosen, setCustomChosen] = useState(
    () => hop.inline && !!hop.fnName,
  );

  // Keep the node's resolved address in sync with the ENS/ABI lookup.
  useEffect(() => {
    const next = contract.resolved ?? null;
    onChange((n) =>
      (n.resolved ?? null) === next ? n : { ...n, resolved: next },
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [contract.resolved]);

  // All view functions are listed — dynamic and multi-output returns are
  // reachable through @len!/@at! and chain hops.
  const viewFns = contract.functions;

  const selectedSig =
    hop.fnName && !hop.inline
      ? `${hop.fnName}(${hop.argTypes.join(",")})`
      : customChosen
        ? CUSTOM_SIG
        : "";

  const selectedFn = useMemo(
    () => viewFns?.find((f) => f.signature === selectedSig) ?? null,
    [viewFns, selectedSig],
  );

  const useManual = customChosen || (viewFns !== null && viewFns.length === 0);

  const changeTarget = (target: string) => {
    setCustomChosen(false);
    // A new address means a new ABI — drop the previous function selection.
    onChange(() => ({
      kind: "call",
      target,
      resolved: null,
      hops: [emptyHop()],
    }));
  };

  const changeFn = (sig: string) => {
    if (sig === CUSTOM_SIG) {
      setCustomChosen(true);
      onChange((n) => ({ ...n, hops: [emptyHop(), ...n.hops.slice(1)] }));
      return;
    }
    setCustomChosen(false);
    const fn = viewFns?.find((f) => f.signature === sig) ?? null;
    onChange((n) => ({
      ...n,
      hops: [
        fn
          ? {
              fnName: fn.name,
              inline: false,
              argTypes: fn.inputs.map((i) => i.type),
              returnTypes: fn.outputs,
              args: fn.inputs.map(() => ""),
            }
          : emptyHop(),
        ...n.hops.slice(1),
      ],
    }));
  };

  const setHop = (index: number, next: CallHop) =>
    onChange((n) => {
      const hops = [...n.hops];
      hops[index] = next;
      return { ...n, hops };
    });

  const lastHop = node.hops[node.hops.length - 1] ?? hop;
  // Chaining continues on an address return — the only one, or a chosen
  // one from a multi-value return (rendered as a destructure lens).
  const addressOutputs = lastHop.returnTypes
    .map((type, i) => ({ type, i }))
    .filter((o) => o.type === "address");
  const canChain = !!lastHop.fnName && addressOutputs.length > 0;

  const addHop = () =>
    onChange((n) => {
      const hops = [...n.hops];
      const prev = hops[hops.length - 1];
      if (prev.returnTypes.length > 1)
        hops[hops.length - 1] = {
          ...prev,
          lensIndex: prev.lensIndex ?? addressOutputs[0]?.i,
        };
      return { ...n, hops: [...hops, emptyHop()] };
    });

  const targetInput = node.target.trim();

  return (
    <div className="space-y-2">
      <div>
        {!compact && (
          <label className={labelCls}>Contract address or ENS name</label>
        )}
        <input
          className={inputCls}
          placeholder="0x… or mydao.eth"
          value={node.target}
          onChange={(e) => changeTarget(e.target.value)}
          spellCheck={false}
        />
        {!contract.contractName &&
          contract.resolved &&
          !isAddress(targetInput) && (
            <p className="mt-1 text-xs font-mono text-[var(--color-ink-3)]">
              {contract.resolved}
            </p>
          )}
        {contract.status && (
          <p className="mt-1 text-xs text-[var(--color-ink-3)]">
            {contract.status}
          </p>
        )}
        {contract.contractName && (
          <p className="mt-1 text-xs">
            <span className="text-[var(--color-ok)]">
              Verified: {contract.contractName}
            </span>
            {contract.resolved && !isAddress(targetInput) && (
              <span className="font-mono text-[var(--color-ink-3)]">
                {" · "}
                {contract.resolved}
              </span>
            )}
          </p>
        )}
      </div>

      {viewFns && viewFns.length > 0 && (
        <div>
          {!compact && <label className={labelCls}>View function</label>}
          <select
            className={inputCls}
            value={selectedSig}
            onChange={(e) => changeFn(e.target.value)}
          >
            <option value="">Select a view function…</option>
            {viewFns.map((fn) => (
              <option key={fn.signature} value={fn.signature}>
                {fn.signature} → {fn.outputs.length === 1
                  ? fn.outputs[0]
                  : `(${fn.outputs.join(",")})`}
              </option>
            ))}
            <option value={CUSTOM_SIG}>
              Custom signature (not in the ABI)…
            </option>
          </select>
        </div>
      )}

      {contract.resolved && useManual ? (
        <InlineHopEditor
          hop={hop}
          onHop={(next) => setHop(0, next)}
          compact={compact}
        />
      ) : (
        selectedFn && (
          <ArgInputs
            inputs={selectedFn.inputs}
            hop={hop}
            onArgs={(args) => setHop(0, { ...hop, args })}
          />
        )
      )}

      {node.hops.slice(1).map((chained, i) => {
        const prev = node.hops[i];
        const prevAddressOutputs = prev.returnTypes
          .map((type, j) => ({ type, j }))
          .filter((o) => o.type === "address");
        return (
          <div
            key={i + 1}
            className="pl-3 border-l-2 border-[var(--color-ink-3)]/15 space-y-1.5"
          >
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-xs font-mono text-[var(--color-ink-3)]">
                :: then call on
              </span>
              {prev.returnTypes.length > 1 ? (
                <select
                  className="px-1.5 py-0.5 rounded-md bg-transparent border border-[var(--color-ink-3)]/25 text-xs font-mono text-[var(--color-ink-3)]"
                  value={prev.lensIndex ?? prevAddressOutputs[0]?.j ?? 0}
                  onChange={(e) =>
                    setHop(i, { ...prev, lensIndex: Number(e.target.value) })
                  }
                  title="Which return value the chain continues on"
                >
                  {prevAddressOutputs.map((o) => (
                    <option key={o.j} value={o.j}>
                      return value #{o.j + 1} (address)
                    </option>
                  ))}
                </select>
              ) : (
                <span className="text-xs font-mono text-[var(--color-ink-3)]">
                  the returned address
                </span>
              )}
              {i + 1 === node.hops.length - 1 && (
                <button
                  type="button"
                  className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-err)]"
                  onClick={() =>
                    onChange((n) => ({ ...n, hops: n.hops.slice(0, -1) }))
                  }
                >
                  remove
                </button>
              )}
            </div>
            <InlineHopEditor
              hop={chained}
              onHop={(next) => setHop(i + 1, next)}
              compact
            />
          </div>
        );
      })}

      {canChain && (
        <button
          type="button"
          className="text-xs text-[var(--color-bp-300)] hover:underline"
          title="Call a view function on the address this call returns"
          onClick={addHop}
        >
          + call on the result (::)
        </button>
      )}
    </div>
  );
}
