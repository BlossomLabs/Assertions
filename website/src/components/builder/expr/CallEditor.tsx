import {
  Fragment,
  createContext,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { isAddress, parseAbiItem } from "viem";

import type { CallArg, CallHop, LensLevel, ValueExpr } from "../assertion-model";
import {
  argFits,
  argText,
  canYield,
  categoryFromAbiType,
  isCallArgNode,
  lensLevelOf,
  producedType,
  resolveLens,
} from "../assertion-model";
import {
  canonicalType,
  inputCls,
  toInputs,
  useContractFunctions,
} from "../useContractFunctions";
import { labelCls, smallLabelCls } from "../ui";
import { SourcePicker, isSourceNode } from "./NodePicker";
import { lensText, summarize } from "./summarize";
import { Select } from "../../ui/Select";

/**
 * The view functions as menu options. When the call has to produce a given
 * type (it fills an argument), the functions whose return cannot become it
 * are greyed out; one that returns an address stays, since it can be
 * called again to reach the type.
 */
function functionOptions(
  fns: { signature: string; outputs: string[] }[],
  wants: string | undefined,
) {
  const wanted = wants ? categoryFromAbiType(wants) : undefined;
  return fns.map((fn) => {
    const fits = !wanted || wanted === "unknown" || canYield(fn.outputs, wanted);
    return {
      value: fn.signature,
      label: `${fn.signature} → ${
        fn.outputs.length === 1 ? fn.outputs[0] : `(${fn.outputs.join(",")})`
      }`,
      disabled: !fits,
      description: fits
        ? undefined
        : `Does not return ${wants ?? "the type needed"}, nor an address to call on`,
    };
  });
}

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

export { callSummary, lensText } from "./summarize";

/** Where an argument sits in a call: which of its chained calls, and
 *  which argument of that one. */
export type OpenArg = (hop: number, arg: number) => void;

const argBoxCls =
  "flex items-center gap-1.5 h-[38px] px-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 focus-within:border-[var(--color-bp-400)]";

/** Argument rows for one call of the chain. Each is one field with, at
 *  its end, the menu that says what it is: plain text typed in place, or a
 *  live value (a contract call, a balance, anything the editor composes),
 *  read when the assertion runs and shown as a pill that opens it in the
 *  tray. */
function ArgInputs({
  inputs,
  hop,
  hopIndex,
  onArgs,
  onOpenArg,
  allowCallArgs,
}: {
  inputs: { name: string; type: string }[];
  hop: CallHop;
  /** Which call of the chain these arguments belong to. */
  hopIndex: number;
  onArgs: (args: CallArg[]) => void;
  /** Shows an argument's live value in the tray. */
  onOpenArg?: OpenArg;
  allowCallArgs: boolean;
}) {
  if (inputs.length === 0) return null;
  const setArg = (i: number, value: CallArg) => {
    const args = [...hop.args];
    args[i] = value;
    onArgs(args);
  };
  return (
    <div className="space-y-2">
      {inputs.map((input, i) => {
        const arg = hop.args[i];
        const live = isCallArgNode(arg) ? arg : null;
        const text = argText(arg) ?? "";
        return (
          <div key={`${input.name}-${i}`}>
            <label className={smallLabelCls}>
              {input.name} <span className="opacity-60">({input.type})</span>
              {!live && input.type === "address" && (
                <span className="opacity-60"> (@me = the executor)</span>
              )}
            </label>
            <div className={argBoxCls}>
              {live ? (
                <button
                  type="button"
                  className="flex-1 min-w-0 truncate text-left text-xs font-mono text-[var(--color-bp-300)] hover:underline"
                  title="Edit this value"
                  onClick={() => onOpenArg?.(hopIndex, i)}
                >
                  {summarize(live)}
                </button>
              ) : (
                <input
                  className="flex-1 min-w-0 bg-transparent font-mono text-sm outline-none placeholder:text-[var(--color-ink-3)]"
                  value={text}
                  onChange={(e) => setArg(i, e.target.value)}
                  spellCheck={false}
                />
              )}
              {/* What the argument is. A combined value (arithmetic and
                  the like) has no kind to pick: it is changed in the tray. */}
              {allowCallArgs &&
                onOpenArg &&
                (!live || isSourceNode(live)) && (
                  <SourcePicker
                    node={live ?? { kind: "literal", value: text }}
                    iconOnly
                    accepts={categoryFromAbiType(input.type)}
                    onConvert={(next) => {
                      if (next.kind === "literal") {
                        setArg(i, next.value);
                        return;
                      }
                      // Anything but plain text is filled in from the tray.
                      setArg(i, next);
                      onOpenArg(hopIndex, i);
                    }}
                    title="Change what this argument is"
                    className="shrink-0 [&>button]:border-0 [&>button]:gap-0.5 [&>button]:text-[var(--color-bp-300)]"
                  />
                )}
            </div>
            {live && !argFits(live, input.type) && (
              <ArgMismatch value={live} type={input.type} />
            )}
          </div>
        );
      })}
    </div>
  );
}

/** Why a live value cannot fill an argument, and what to do about it. */
export function ArgMismatch({
  value,
  type,
}: {
  value: ValueExpr;
  /** The argument's ABI type. */
  type: string;
}) {
  const got = producedType(value);
  return (
    <p className="mt-1 text-xs text-[var(--color-err)]" role="alert">
      This argument takes {type}
      {got ? `, but the value is ${got}` : ", but the value is not one yet"}.{" "}
      {got === "address"
        ? "Call a function on that address that returns it, or pick another value."
        : value.kind === "call"
          ? "Pick the part of the result that is, or another function."
          : "Pick another value."}
    </p>
  );
}

/** Manual signature editor writing an inline-ABI hop (used for the custom
 *  fallback on hop 0 and for every chained hop, which has no ABI source). */
function InlineHopEditor({
  hop,
  hopIndex,
  onHop,
  compact,
  onOpenArg,
  allowCallArgs,
}: {
  hop: CallHop;
  hopIndex: number;
  onHop: (hop: CallHop) => void;
  compact: boolean;
  onOpenArg?: OpenArg;
  allowCallArgs: boolean;
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
        hopIndex={hopIndex}
        onArgs={(args) => onHop({ ...hop, args })}
        onOpenArg={onOpenArg}
        allowCallArgs={allowCallArgs}
      />
    </div>
  );
}

const partBtnCls = (on: boolean) =>
  `h-8 px-2.5 rounded-md border text-xs font-mono transition-colors ${
    on
      ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/25 text-[var(--color-ink)]"
      : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/60"
  }`;

/** One level of picking among a known, short list of parts (the values a
 *  call returns, the values of a struct, the elements of a fixed array):
 *  a button per part, its index and its type. Long lists fall back to a
 *  menu. */
function PartPicker({
  label,
  value,
  choices,
  onPick,
}: {
  label: string;
  /** The picked index, "" while none is. */
  value: string;
  choices: { value: string; type: string; disabled?: boolean }[];
  onPick: (value: string) => void;
}) {
  return (
    <div className="flex items-start gap-3">
      <span className="w-32 shrink-0 pt-2 text-xs text-[var(--color-ink-3)]">
        {label}
      </span>
      {choices.length > 8 ? (
        <Select
          variant="chip"
          value={value}
          placeholder="pick one…"
          options={choices.map((c) => ({
            value: c.value,
            label: `[${c.value}] ${c.type}`,
            disabled: c.disabled,
          }))}
          onChange={onPick}
        />
      ) : (
        <div className="flex flex-wrap gap-1.5">
          {choices.map((c) => (
            <button
              key={c.value}
              type="button"
              aria-pressed={value === c.value}
              disabled={c.disabled}
              title={
                c.disabled ? "Cannot become the type needed here" : undefined
              }
              className={`${partBtnCls(value === c.value)} disabled:opacity-30 disabled:pointer-events-none`}
              onClick={() => onPick(c.value)}
            >
              <span className="text-[var(--color-bp-300)]">[{c.value}]</span>{" "}
              {c.type}
            </button>
          ))}
          {value === "" && (
            <span className="self-center text-xs text-[var(--color-err)]">
              pick one
            </span>
          )}
        </div>
      )}
    </div>
  );
}

/** Picking one element of an array whose length is only known on-chain:
 *  the first, the last, or any index typed in (negative counts from the
 *  end, resolved when the assertion runs). */
function ElementPicker({
  type,
  value,
  onPick,
}: {
  type: string;
  /** The picked index as typed, "" while none is. */
  value: string;
  onPick: (value: string) => void;
}) {
  const v = value.trim();
  // While the index is being typed the field keeps what was typed, even
  // when it reads 0 or -1 for a moment: emptying it there would drop the
  // start of "-12" or "05".
  const [typing, setTyping] = useState(false);
  const custom = v !== "" && (typing || (v !== "0" && v !== "-1"));
  return (
    <div className="flex items-start gap-3">
      <span className="w-32 shrink-0 pt-2 text-xs text-[var(--color-ink-3)]">
        Element of {type}
      </span>
      <div className="flex flex-wrap items-center gap-1.5">
        <button
          type="button"
          aria-pressed={v === "0"}
          className={partBtnCls(v === "0")}
          onClick={() => onPick("0")}
        >
          <span className="text-[var(--color-bp-300)]">[0]</span> first
        </button>
        <button
          type="button"
          aria-pressed={v === "-1"}
          className={partBtnCls(v === "-1")}
          onClick={() => onPick("-1")}
        >
          <span className="text-[var(--color-bp-300)]">[-1]</span> last
        </button>
        <label
          className={`flex items-center gap-1.5 h-8 pl-2.5 pr-1 rounded-md border text-xs font-mono ${
            custom
              ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/25"
              : "border-[var(--color-ink-3)]/25"
          }`}
          title="Any index: 0 is the first element, negative numbers count from the end"
        >
          <span className="text-[var(--color-ink-3)]">index</span>
          <input
            className="w-14 bg-transparent outline-none text-[var(--color-ink)] placeholder:text-[var(--color-ink-3)]"
            inputMode="numeric"
            placeholder="2, -2…"
            value={custom ? value : ""}
            onChange={(e) => onPick(e.target.value)}
            onFocus={() => setTyping(true)}
            onBlur={() => setTyping(false)}
            spellCheck={false}
          />
        </label>
        {v === "" && (
          <span className="text-xs text-[var(--color-err)]">pick one</span>
        )}
      </div>
    </div>
  );
}

/**
 * Works out the address a call returns, as the assertion will find it: the
 * builder provides it by simulating the batch's actions up to the point
 * the assertion runs and reading the call there. Without one (or when the
 * read fails) a chained call falls back to a typed signature.
 */
export type CallAddressResolver = (
  call: CallNode,
) => Promise<{ address: string } | { error: string }>;

export const CallAddressContext = createContext<CallAddressResolver | null>(
  null,
);

/**
 * One call of a chain after the first: a call on the address the previous
 * one returns. That address is read from a simulation of the batch, so its
 * verified functions can be listed like the first call's; when it cannot
 * be read, or the contract is not verified, the signature is typed.
 */
function ChainedHopEditor({
  prefix,
  hop,
  hopIndex,
  onHop,
  chainId,
  onOpenArg,
  allowCallArgs,
  wants,
}: {
  /** The chain up to and including the previous call. */
  prefix: CallNode;
  hop: CallHop;
  hopIndex: number;
  onHop: (hop: CallHop) => void;
  chainId: number;
  onOpenArg?: OpenArg;
  allowCallArgs: boolean;
  /** The ABI type the whole call has to produce, if it fills an argument. */
  wants?: string;
}) {
  const resolve = useContext(CallAddressContext);
  const [found, setFound] = useState<
    | { status: "idle" | "loading" }
    | { status: "ok"; address: string }
    | { status: "error"; message: string }
  >({ status: resolve ? "loading" : "idle" });
  const prefixKey = JSON.stringify(prefix);

  useEffect(() => {
    if (!resolve) return;
    let cancelled = false;
    setFound({ status: "loading" });
    // Wait for typing to settle: each read is a simulation.
    const timer = setTimeout(async () => {
      const result = await resolve(prefix).catch((e) => ({
        error: e instanceof Error ? e.message : String(e),
      }));
      if (cancelled) return;
      setFound(
        "address" in result
          ? { status: "ok", address: result.address }
          : { status: "error", message: result.error },
      );
    }, 400);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [resolve, prefixKey]);

  const address = found.status === "ok" ? found.address : "";
  const contract = useContractFunctions(chainId, address, "view");
  const viewFns = contract.functions;
  const [customChosen, setCustomChosen] = useState(
    () => hop.inline && !!hop.fnName,
  );
  const selectedSig =
    hop.fnName && !hop.inline
      ? `${hop.fnName}(${hop.argTypes.join(",")})`
      : customChosen
        ? CUSTOM_SIG
        : "";
  const selectedFn =
    viewFns?.find((f) => f.signature === selectedSig) ?? null;
  // Typed by hand when there is no list to pick from, or by choice.
  const manual =
    customChosen ||
    found.status === "error" ||
    found.status === "idle" ||
    (viewFns !== null && viewFns.length === 0);

  const changeFn = (sig: string) => {
    if (sig === CUSTOM_SIG) {
      setCustomChosen(true);
      onHop(emptyHop());
      return;
    }
    setCustomChosen(false);
    const fn = viewFns?.find((f) => f.signature === sig);
    onHop(
      fn
        ? {
            fnName: fn.name,
            inline: false,
            argTypes: fn.inputs.map((i) => i.type),
            returnTypes: fn.outputs,
            args: fn.inputs.map(() => ""),
          }
        : emptyHop(),
    );
  };

  return (
    <div className="space-y-2">
      {found.status === "loading" && (
        <p className="text-xs text-[var(--color-ink-3)]">
          Simulating the batch to find that address…
        </p>
      )}
      {found.status === "ok" && (
        <p className="text-xs">
          {contract.contractName ? (
            <span className="text-[var(--color-ok)]">
              Verified: {contract.contractName}
            </span>
          ) : (
            <span className="text-[var(--color-ink-3)]">
              {contract.status ?? "Contract found"}
            </span>
          )}
          <span className="font-mono text-[var(--color-ink-3)]">
            {" · "}
            {found.address}
          </span>
        </p>
      )}
      {found.status === "error" && (
        <p className="text-xs text-[var(--color-ink-3)]">
          Could not read that address from a simulation ({found.message}).
          Type the function to call.
        </p>
      )}

      {found.status === "ok" && viewFns && viewFns.length > 0 && (
        <Select
          value={selectedSig}
          placeholder="Select a view function…"
          searchable
          options={[
            ...functionOptions(viewFns, wants),
            { value: CUSTOM_SIG, label: "Custom signature (not in the ABI)…" },
          ]}
          onChange={changeFn}
        />
      )}

      {found.status !== "loading" && manual ? (
        <InlineHopEditor
          hop={hop}
          hopIndex={hopIndex}
          onHop={onHop}
          compact
          onOpenArg={onOpenArg}
          allowCallArgs={allowCallArgs}
        />
      ) : (
        selectedFn && (
          <ArgInputs
            inputs={selectedFn.inputs}
            hop={hop}
            hopIndex={hopIndex}
            onArgs={(args) => onHop({ ...hop, args })}
            onOpenArg={onOpenArg}
            allowCallArgs={allowCallArgs}
          />
        )
      )}
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
  allowChain = true,
  allowCallArgs = true,
  hideTarget = false,
  onOpenArg,
  wants,
}: {
  node: CallNode;
  onChange: (updater: (node: CallNode) => CallNode) => void;
  chainId: number;
  /** Nested nodes drop the field labels to keep the tree readable. */
  compact?: boolean;
  /** Chained hops compile through the core's chain primitive, so the simple
   *  form (single call, no composition) turns them off. */
  allowChain?: boolean;
  /** Nested live calls as arguments compile to the core's read
   *  primitive, so the simple form turns them off too. */
  allowCallArgs?: boolean;
  /** The address is typed elsewhere (the value's slot): leave the field
   *  out and keep what follows from it. */
  hideTarget?: boolean;
  /** Shows the live call filling an argument: it is edited in the tray,
   *  not inside this editor. Without it, arguments are plain text only. */
  onOpenArg?: OpenArg;
  /** The ABI type this call has to produce (it fills an argument of that
   *  type): functions that cannot lead to it are greyed out. */
  wants?: string;
}) {
  const contract = useContractFunctions(chainId, node.target, "view");
  const hop = node.hops[0] ?? emptyHop();
  const [customChosen, setCustomChosen] = useState(
    () => hop.inline && !!hop.fnName,
  );

  // The address can change from outside this editor: a new one drops the
  // custom-signature choice, as typing it here does.
  const lastTarget = useRef(node.target);
  useEffect(() => {
    if (lastTarget.current === node.target) return;
    lastTarget.current = node.target;
    setCustomChosen(false);
  }, [node.target]);

  // Keep the node's resolved address in sync with the ENS/ABI lookup.
  useEffect(() => {
    const next = contract.resolved ?? null;
    onChange((n) =>
      (n.resolved ?? null) === next ? n : { ...n, resolved: next },
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [contract.resolved]);

  // All view functions are listed — dynamic and multi-output returns are
  // reachable through @len!, the return-value picker and chain hops.
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
  const addressOutputs = lastHop.returnTypes
    .map((type, i) => ({ type, i }))
    .filter((o) => o.type === "address");

  // The final hop's selection: walk the picked output through `lensPath`,
  // yielding one picker per composite level (array element or struct
  // value) plus the next level to pick, rendered as nested lens levels.
  const selType =
    lastHop.returnTypes.length === 1
      ? lastHop.returnTypes[0]
      : lastHop.lensIndex !== undefined
        ? lastHop.returnTypes[lastHop.lensIndex]
        : undefined;
  const lensLevels: { level: LensLevel; value: string }[] = [];
  {
    let t = selType;
    const pathVals = lastHop.lensPath ?? [];
    for (let k = 0; t !== undefined; k++) {
      const level = lensLevelOf(t);
      if (!level) break;
      const value = pathVals[k] ?? "";
      lensLevels.push({ level, value });
      const v = value.trim();
      if (!/^-?\d+$/.test(v)) break; // deeper levels need this one picked
      t =
        level.kind === "array" ? level.base : level.components[Number(v)];
    }
  }

  const setLensEntry = (k: number, value: string) => {
    const base = (lastHop.lensPath ?? []).slice(0, k);
    const nextPath = value === "" ? base : [...base, value];
    setHop(node.hops.length - 1, {
      ...lastHop,
      lensPath: nextPath.length > 0 ? nextPath : undefined,
    });
  };

  // The chain continues wherever the current selection lands on an
  // address: the single output, a lens-picked address output, an address
  // element reached through arrays/structs, or — before any selection —
  // some address output `addHop` can anchor to.
  const lensSelection = resolveLens(lastHop);
  const canChain =
    allowChain &&
    !!lastHop.fnName &&
    (lensSelection
      ? lensSelection.valid && lensSelection.terminal === "address"
      : addressOutputs.length > 0);

  const addHop = () =>
    onChange((n) => {
      const hops = [...n.hops];
      const prev = hops[hops.length - 1];
      const lens = resolveLens(prev);
      const keep = !!lens?.valid && lens.terminal === "address";
      if (!keep && prev.returnTypes.length > 1) {
        // No usable selection yet — anchor the chain to the first plain
        // address output.
        hops[hops.length - 1] = {
          ...prev,
          lensIndex: addressOutputs[0]?.i,
          lensPath: undefined,
        };
      }
      return { ...n, hops: [...hops, emptyHop()] };
    });

  const targetInput = node.target.trim();

  // A chain is edited one call at a time: the strip picks which.
  const [activeHop, setActiveHop] = useState(() => node.hops.length - 1);
  const lastIndex = node.hops.length - 1;
  const shown = Math.min(activeHop, lastIndex);
  // Whether a part of the result can still become what the call has to
  // produce (always, when nothing in particular is asked of it).
  const wanted = wants ? categoryFromAbiType(wants) : undefined;
  const leads = (type: string) =>
    !wanted || wanted === "unknown" || canYield([type], wanted);
  const hopLabel = (h: CallHop) =>
    h.fnName ? `${h.fnName}()${lensText(h)}` : "function…";

  return (
    <div className="space-y-2">
      <div>
        {!hideTarget && (
          <input
            className={inputCls}
            aria-label="Contract address or ENS name"
            placeholder="0x… or mydao.eth"
            value={node.target}
            onChange={(e) => changeTarget(e.target.value)}
            spellCheck={false}
          />
        )}
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

      {(node.hops.length > 1 || canChain) && (
        <div className="flex items-center gap-1.5 flex-wrap">
          <span className="mr-1 text-xs font-mono text-[var(--color-ink-3)]">
            Chain
          </span>
          {node.hops.map((h, i) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: positional hops
            <Fragment key={i}>
              {i > 0 && (
                <span
                  className="text-xs text-[var(--color-ink-3)]"
                  aria-hidden="true"
                >
                  →
                </span>
              )}
              <button
                type="button"
                aria-pressed={i === shown}
                onClick={() => setActiveHop(i)}
                title={
                  i === 0
                    ? "The call on the contract above"
                    : "A call on the address the previous call returns"
                }
                className={`max-w-48 truncate px-1.5 py-0.5 rounded-md text-xs font-mono transition-colors ${
                  i === shown
                    ? "bg-[var(--color-bp-500)]/30 text-[var(--color-ink)] ring-1 ring-[var(--color-bp-400)]"
                    : "bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/25"
                }`}
              >
                {hopLabel(h)}
              </button>
            </Fragment>
          ))}
          {canChain && (
            <>
              <span
                className="text-xs text-[var(--color-ink-3)]"
                aria-hidden="true"
              >
                →
              </span>
              <button
                type="button"
                className="px-1.5 py-0.5 rounded-md border border-dashed border-[var(--color-bp-400)]/50 text-xs text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/15"
                title="Call a view function on the address this call returns"
                onClick={() => {
                  addHop();
                  setActiveHop(node.hops.length);
                }}
              >
                + call on the result
              </button>
            </>
          )}
        </div>
      )}

      {shown === 0 && viewFns && viewFns.length > 0 && (
        <div>
          {!compact && <label className={labelCls}>View function</label>}
          <Select
            value={selectedSig}
            placeholder="Select a view function…"
            searchable
            options={[
              ...functionOptions(viewFns, wants),
              { value: CUSTOM_SIG, label: "Custom signature (not in the ABI)…" },
            ]}
            onChange={changeFn}
          />
        </div>
      )}

      {shown > 0 ? null : contract.resolved && useManual ? (
        <InlineHopEditor
          hop={hop}
          hopIndex={0}
          onHop={(next) => setHop(0, next)}
          compact={compact}
          onOpenArg={onOpenArg}
          allowCallArgs={allowCallArgs}
        />
      ) : (
        selectedFn && (
          <ArgInputs
            inputs={selectedFn.inputs}
            hop={hop}
            hopIndex={0}
            onArgs={(args) => setHop(0, { ...hop, args })}
            onOpenArg={onOpenArg}
            allowCallArgs={allowCallArgs}
          />
        )
      )}

      {shown > 0 &&
        (() => {
          const chained = node.hops[shown];
          const prev = node.hops[shown - 1];
          const prevAddressOutputs = prev.returnTypes
            .map((type, j) => ({ type, j }))
            .filter((o) => o.type === "address");
          return (
            <div className="space-y-2">
              <div className="flex items-center gap-2 flex-wrap text-xs text-[var(--color-ink-3)]">
                <span>Called on</span>
                {(prev.lensPath ?? []).length > 0 ? (
                  // The selection reaches through arrays/structs; it was
                  // made with the full picker before this call was added:
                  // remove the call to change it.
                  <span className="font-mono">
                    the selected address element of {hopLabel(prev)}
                  </span>
                ) : prev.returnTypes.length > 1 ? (
                  <>
                    <Select
                      variant="chip"
                      value={String(
                        prev.lensIndex ?? prevAddressOutputs[0]?.j ?? 0,
                      )}
                      options={prevAddressOutputs.map((o) => ({
                        value: String(o.j),
                        label: `return value #${o.j + 1} (address)`,
                      }))}
                      onChange={(v) =>
                        setHop(shown - 1, {
                          ...prev,
                          lensIndex: Number(v),
                          lensPath: undefined,
                        })
                      }
                      title="Which return value the chain continues on"
                    />
                    <span className="font-mono">of {hopLabel(prev)}</span>
                  </>
                ) : (
                  <span className="font-mono">
                    the address {hopLabel(prev)} returns
                  </span>
                )}
                {shown === lastIndex && (
                  <button
                    type="button"
                    className="ml-auto hover:text-[var(--color-err)]"
                    onClick={() => {
                      onChange((n) => ({ ...n, hops: n.hops.slice(0, -1) }));
                      setActiveHop(shown - 1);
                    }}
                  >
                    remove this call
                  </button>
                )}
              </div>
              <ChainedHopEditor
                // One editor per call: its fields start from that call.
                key={shown}
                prefix={{ ...node, hops: node.hops.slice(0, shown) }}
                hop={chained}
                hopIndex={shown}
                onHop={(next) => setHop(shown, next)}
                chainId={chainId}
                onOpenArg={onOpenArg}
                allowCallArgs={allowCallArgs}
                wants={wants}
              />
            </div>
          );
        })()}

      {shown === lastIndex &&
        !!lastHop.fnName &&
        (lastHop.returnTypes.length > 1 || lensLevels.length > 0) && (
          <div className="rounded-lg border border-[var(--color-ink-3)]/20 p-3 space-y-2.5">
            <p className="text-xs text-[var(--color-ink-3)]">
              <span className="text-[var(--color-ink-2)]">Which part to use.</span>{" "}
              This call returns several values or a list: pick down to the one
              the assertion reads.
            </p>
            {lastHop.returnTypes.length > 1 && (
              <PartPicker
                label="Return value"
                value={
                  lastHop.lensIndex === undefined
                    ? ""
                    : String(lastHop.lensIndex)
                }
                choices={lastHop.returnTypes.map((type, i) => ({
                  value: String(i),
                  type,
                  disabled: !leads(type),
                }))}
                onPick={(v) =>
                  setHop(node.hops.length - 1, {
                    ...lastHop,
                    lensIndex: Number(v),
                    lensPath: undefined,
                  })
                }
              />
            )}
            {lensLevels.map(({ level, value }, k) =>
              level.kind === "array" && level.length === undefined ? (
                <ElementPicker
                  // biome-ignore lint/suspicious/noArrayIndexKey: positional levels
                  key={k}
                  type={`${level.base}[]`}
                  value={value}
                  onPick={(v) => setLensEntry(k, v)}
                />
              ) : (
                <PartPicker
                  // biome-ignore lint/suspicious/noArrayIndexKey: positional levels
                  key={k}
                  label={
                    level.kind === "array"
                      ? `Element of ${level.base}[${level.length}]`
                      : "Value of the struct"
                  }
                  value={value}
                  choices={
                    level.kind === "array"
                      ? Array.from({ length: level.length ?? 0 }, (_, i) => ({
                          value: String(i),
                          type: level.base,
                          disabled: !leads(level.base),
                        }))
                      : level.components.map((type, i) => ({
                          value: String(i),
                          type,
                          disabled: !leads(type),
                        }))
                  }
                  onPick={(v) => setLensEntry(k, v)}
                />
              ),
            )}
            <p className="text-xs font-mono text-[var(--color-ink-3)]">
              uses{" "}
              <span className="text-[var(--color-ink)]">
                {hopLabel(lastHop)}
              </span>
              {lensSelection?.valid && (
                <>
                  {" → "}
                  {lensSelection.terminal}
                </>
              )}
            </p>
          </div>
        )}
    </div>
  );
}
