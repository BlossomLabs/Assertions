import { useEffect, useMemo, useState } from "react";
import { isAddress, parseAbiItem } from "viem";
import { usePublicClient } from "wagmi";

import {
  type AmountIn,
  type DecomposedCall,
  amountField,
  composeCall,
  isTokenAmountCall,
} from "./compose-call";
import type { LineVariable } from "./script-ops";
import { useComposeEnv } from "./useComposeEnv";
import {
  canonicalType,
  ensVarName,
  inputCls,
  resolveEnsAddress,
  toInputs,
  useContractFunctions,
} from "./useContractFunctions";
import { Select } from "../ui/Select";
import { ButtonIcon } from "./ButtonIcon";

/** Sentinel value for the dropdown option that reveals the manual signature input. */
const CUSTOM_SIG = "__custom__";

/** An action of the batch loaded back into the form: the line it is on,
 *  and what the form's fields hold for it. A new object each time an edit
 *  starts. */
export interface ActionEdit {
  line: number;
  call: DecomposedCall;
}

export function AbiForm({
  chainId,
  onAdd,
  onSkip,
  editing = null,
  onSave,
  onCancelEdit,
}: {
  chainId: number;
  /** Add the call: its line, the ENS `set` lines it needs, and the
   *  addresses it names, each to be given a variable in the script. */
  onAdd: (line: string, sets: string[], vars: LineVariable[]) => void;
  /** Shown beside the button as "Skip actions" when given. */
  onSkip?: () => void;
  /** The action being edited: the form holds it instead of a new one. */
  editing?: ActionEdit | null;
  /** Put the call where the edited action is. */
  onSave?: (at: number, line: string, sets: string[], vars: LineVariable[]) => void;
  /** Leave the edited action as it is. */
  onCancelEdit?: () => void;
}) {
  const publicClient = usePublicClient({ chainId: 1 });
  const compose = useComposeEnv(chainId);
  const [addressInput, setAddressInput] = useState("");
  const [manualSig, setManualSig] = useState("");
  const [selectedSig, setSelectedSig] = useState("");
  const [args, setArgs] = useState<Record<string, string>>({});
  const [value, setValue] = useState("");
  const [adding, setAdding] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // The unit the user wants a token amount in; token units unless switched.
  const [amountIn, setAmountIn] = useState<AmountIn>("token");
  // An edit whose function and arguments wait for the contract's ABI.
  const [loading, setLoading] = useState<ActionEdit | null>(null);

  const { resolved, status, functions, contractName } = useContractFunctions(
    chainId,
    addressInput,
    "write",
  );

  const clear = () => {
    setAddressInput("");
    setSelectedSig("");
    setManualSig("");
    setArgs({});
    setValue("");
    setAmountIn("token");
    setError(null);
    setLoading(null);
  };

  // An edit starts: the contract first; the function and the arguments
  // follow once its ABI is there (below). An edit that ends empties the
  // form.
  useEffect(() => {
    clear();
    if (!editing) return;
    setAddressInput(editing.call.target);
    setValue(editing.call.value);
    setAmountIn(editing.call.amountIn);
    setLoading(editing);
  }, [editing]);

  // A new address means a new ABI — drop the previous function selection,
  // unless the address is the one of the action being loaded.
  useEffect(() => {
    if (loading && loading.call.target === addressInput.trim()) return;
    setSelectedSig("");
  }, [addressInput]);

  // The ABI of the edited action's contract arrived: pick its function
  // (the custom-signature field when the ABI does not have it) and fill
  // the arguments in, by position.
  useEffect(() => {
    if (!loading || functions === null) return;
    if (loading.call.target !== addressInput.trim()) return;
    const { signature, args: values } = loading.call;
    const known = functions.find((f) => f.signature === signature);
    let inputs = known?.inputs;
    if (known) {
      setSelectedSig(signature);
      setManualSig("");
    } else {
      setSelectedSig(CUSTOM_SIG);
      setManualSig(signature);
      try {
        const item = parseAbiItem(`function ${signature}`);
        if (item.type === "function") inputs = toInputs(item.inputs);
      } catch {
        /* the signature came from a parsed line */
      }
    }
    setArgs(
      Object.fromEntries((inputs ?? []).map((input, i) => [input.name, values[i] ?? ""])),
    );
    setLoading(null);
  }, [loading, functions, addressInput]);

  const selected = useMemo(
    () => functions?.find((f) => f.signature === selectedSig) ?? null,
    [functions, selectedSig],
  );

  // Parse the manually-typed signature with viem so named params (e.g.
  // "transfer(address to, uint256 amount)") become labels, and the exec line
  // gets a canonical signature (names stripped, "uint" → "uint256", …).
  const manual = useMemo(() => {
    const sig = manualSig.trim();
    if (!sig) return null;
    try {
      const item = parseAbiItem(`function ${sig}`);
      if (item.type !== "function") return null;
      return {
        signature: `${item.name}(${item.inputs.map(canonicalType).join(",")})`,
        inputs: toInputs(item.inputs),
      };
    } catch {
      return null;
    }
  }, [manualSig]);

  const useManual =
    selectedSig === CUSTOM_SIG || (functions !== null && functions.length === 0);
  const activeSig = useManual ? manual?.signature : selected?.signature;
  const activeInputs = useManual ? (manual?.inputs ?? null) : (selected?.inputs ?? null);

  // `transfer`, `approve` and `transferFrom` on a contract that says its
  // decimals take their amount in the token's own units.
  const [token, setToken] = useState<{
    address: string;
    decimals?: number;
    symbol?: string;
  } | null>(null);
  const tokenCall = !!resolved && !!activeSig && isTokenAmountCall(activeSig);
  useEffect(() => {
    if (!resolved || !tokenCall) return;
    let cancelled = false;
    void Promise.all([
      compose.decimalsOf(resolved).catch(() => undefined),
      compose.listedSymbol(resolved).catch(() => undefined),
    ]).then(([decimals, symbol]) => {
      if (!cancelled) setToken({ address: resolved, decimals, symbol });
    });
    return () => {
      cancelled = true;
    };
  }, [resolved, tokenCall, compose]);
  const amountName = activeInputs?.at(-1)?.name;
  const amount =
    tokenCall && token?.address === resolved && activeSig && amountName !== undefined
      ? amountField({
          signature: activeSig,
          decimals: token.decimals,
          symbol: token.symbol,
          amountIn,
          raw: args[amountName] ?? "",
        })
      : null;

  const canAdd =
    !!resolved && !!activeSig && !!activeInputs && !loading && !amount?.error;

  const add = async () => {
    if (!resolved || !activeSig || !activeInputs || adding) return;
    setAdding(true);
    setError(null);
    try {
      const sets: string[] = [];
      // On mainnet the name stays live in the script via @ens; on other
      // chains the per-chain address (multichain names record one per
      // chain) is frozen in, since @ens reads the mainnet record.
      const registerEns = (name: string, address: string): string => {
        const varName = ensVarName(name);
        const line =
          chainId === 1
            ? `set ${varName} @ens(${name})`
            : `set ${varName} ${address}`;
        if (!sets.includes(line)) sets.push(line);
        return varName;
      };
      const ensToVar = async (name: string): Promise<string | null> => {
        const addr = await resolveEnsAddress(publicClient, name, chainId);
        return addr ? registerEns(name, addr) : null;
      };

      // If the contract was given as an ENS name, keep the name in the
      // script (via a set line) instead of the resolved hex address.
      const contractInput = addressInput.trim();
      const target = isAddress(contractInput)
        ? resolved
        : registerEns(contractInput, resolved);

      // Addresses become variables and standard token amounts are
      // written in the token's units (see compose-call.ts).
      const { line, vars } = await composeCall(
        {
          target: resolved,
          targetRef: target,
          signature: activeSig,
          inputs: activeInputs,
          values: args,
          value,
          // The unit the field was shown in: token units only where the
          // field said so.
          amountIn: amount ? amountIn : "base",
        },
        await compose.env(ensToVar),
      );
      if (editing && onSave) onSave(editing.line, line, sets, vars);
      else onAdd(line, sets, vars);
      if (editing) onCancelEdit?.();
      else clear();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setAdding(false);
    }
  };

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
          Contract address or ENS name
        </label>
        <input
          className={inputCls}
          placeholder="0x… or mydao.eth"
          value={addressInput}
          onChange={(e) => setAddressInput(e.target.value)}
          spellCheck={false}
        />
        {!contractName && resolved && !isAddress(addressInput.trim()) && (
          <p className="mt-1 text-xs font-mono text-[var(--color-ink-3)]">
            {resolved}
          </p>
        )}
        {status && (
          <p className="mt-1 text-xs text-[var(--color-ink-3)]">{status}</p>
        )}
        {contractName && (
          <p className="mt-1 text-xs">
            <span className="text-[var(--color-ok)]">
              Verified: {contractName}
            </span>
            {resolved && !isAddress(addressInput.trim()) && (
              <span className="font-mono text-[var(--color-ink-3)]">
                {" · "}
                {resolved}
              </span>
            )}
          </p>
        )}
      </div>

      {functions && functions.length > 0 && (
        <div>
          <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
            Function
          </label>
          <Select
            value={selectedSig}
            placeholder="Select a function…"
            searchable
            options={[
              ...functions.map((fn) => ({
                value: fn.signature,
                label: fn.signature,
              })),
              { value: CUSTOM_SIG, label: "Custom signature (not in the ABI)…" },
            ]}
            onChange={(sig) => {
              setSelectedSig(sig);
              setManualSig("");
              setArgs({});
            }}
          />
        </div>
      )}

      {resolved && useManual && (
        <div>
          <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">
            Function signature
          </label>
          <input
            className={inputCls}
            placeholder='transfer(address,uint256)'
            value={manualSig}
            onChange={(e) => setManualSig(e.target.value)}
            spellCheck={false}
          />
        </div>
      )}

      {activeInputs && activeInputs.length > 0 && (
        <div className="space-y-2">
          {activeInputs.map((input, i) => {
            // The amount of a token call: in the token's units, with the
            // base units it comes to underneath.
            const field = i === activeInputs.length - 1 ? amount : null;
            const set = (next: string) =>
              setArgs((prev) => ({ ...prev, [input.name]: next }));
            return (
              <div key={input.name}>
                <label
                  htmlFor={`abi-arg-${i}`}
                  className="block text-xs font-mono text-[var(--color-ink-3)] mb-1"
                >
                  {input.name}{" "}
                  <span className="opacity-60">
                    ({field ? field.unit : input.type})
                  </span>
                </label>
                <input
                  id={`abi-arg-${i}`}
                  className={inputCls}
                  value={args[input.name] ?? ""}
                  onChange={(e) => set(e.target.value)}
                  placeholder={
                    field ? (amountIn === "token" ? "1.5" : "1500000") : undefined
                  }
                  inputMode={field && amountIn === "token" ? "decimal" : undefined}
                  aria-invalid={field?.error ? true : undefined}
                  aria-describedby={field ? `abi-arg-${i}-unit` : undefined}
                  spellCheck={false}
                />
                {field && (
                  <p
                    id={`abi-arg-${i}-unit`}
                    className="mt-1 flex flex-wrap items-baseline gap-x-3 gap-y-0.5 text-xs text-[var(--color-ink-3)]"
                  >
                    {field.error ? (
                      <span role="alert" className="text-[var(--color-err)]">
                        {field.error}
                      </span>
                    ) : (
                      field.hint && (
                        <span className="font-mono wrap-anywhere">{field.hint}</span>
                      )
                    )}
                    {field.canMax && (
                      <button
                        type="button"
                        onClick={() => set("max")}
                        title="An unlimited allowance"
                        className="text-[var(--color-bp-300)] hover:underline"
                      >
                        max
                      </button>
                    )}
                    <button
                      type="button"
                      onClick={() => {
                        setAmountIn(amountIn === "token" ? "base" : "token");
                        set("");
                      }}
                      className="text-[var(--color-bp-300)] hover:underline"
                    >
                      {field.switchTo}
                    </button>
                  </p>
                )}
              </div>
            );
          })}
        </div>
      )}

      {(selected?.payable || useManual) && resolved && activeSig && (
        <div>
          <label className="block text-xs font-mono text-[var(--color-ink-3)] mb-1">
            value <span className="opacity-60">(wei, e.g. 1e18, optional)</span>
          </label>
          <input
            className={inputCls}
            value={value}
            onChange={(e) => setValue(e.target.value)}
            spellCheck={false}
          />
        </div>
      )}

      {error && (
        <p role="alert" className="text-xs text-[var(--color-err)]">
          {error}
        </p>
      )}

      <div className="flex flex-wrap items-center gap-4">
        <button
          type="button"
          disabled={!canAdd || adding}
          onClick={add}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
        >
          <ButtonIcon name={editing ? "edit" : "add"} />
          {editing ? "Save action" : "Add to batch"}
        </button>
        {editing && (
          <button
            type="button"
            onClick={onCancelEdit}
            className="text-sm text-[var(--color-bp-300)] hover:underline"
          >
            Cancel
          </button>
        )}
        {onSkip && !editing && (
          <button
            type="button"
            onClick={onSkip}
            className="text-sm text-[var(--color-bp-300)] hover:underline"
          >
            Skip actions <span aria-hidden="true">→</span>
          </button>
        )}
      </div>
    </div>
  );
}
