import { useEffect, useMemo, useState } from "react";
import { isAddress, parseAbiItem } from "viem";
import { normalize } from "viem/ens";
import { usePublicClient } from "wagmi";

import {
  canonicalType,
  ensVarName,
  evmlArg,
  inputCls,
  toInputs,
  useContractFunctions,
} from "./useContractFunctions";

/** Sentinel value for the dropdown option that reveals the manual signature input. */
const CUSTOM_SIG = "__custom__";

export function AbiForm({
  chainId,
  onAdd,
}: {
  chainId: number;
  onAdd: (line: string, sets: string[]) => void;
}) {
  const publicClient = usePublicClient({ chainId: 1 });
  const [addressInput, setAddressInput] = useState("");
  const [manualSig, setManualSig] = useState("");
  const [selectedSig, setSelectedSig] = useState("");
  const [args, setArgs] = useState<Record<string, string>>({});
  const [value, setValue] = useState("");
  const [adding, setAdding] = useState(false);

  const { resolved, status, functions, contractName } = useContractFunctions(
    chainId,
    addressInput,
    "write",
  );

  // A new address means a new ABI — drop the previous function selection.
  useEffect(() => {
    setSelectedSig("");
  }, [addressInput]);

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
  const canAdd = !!resolved && !!activeSig && !!activeInputs;

  const add = async () => {
    if (!resolved || !activeSig || !activeInputs || adding) return;
    setAdding(true);
    try {
      const sets: string[] = [];
      const registerEns = (name: string): string => {
        const varName = ensVarName(name);
        const line = `set ${varName} @ens(${name})`;
        if (!sets.includes(line)) sets.push(line);
        return varName;
      };
      const ensToVar = async (name: string): Promise<string | null> => {
        try {
          const addr = await publicClient?.getEnsAddress({
            name: normalize(name),
          });
          return addr ? registerEns(name) : null;
        } catch {
          return null;
        }
      };

      // If the contract was given as an ENS name, keep the name in the
      // script (via a set line) instead of the resolved hex address.
      const contractInput = addressInput.trim();
      const target = isAddress(contractInput)
        ? resolved
        : registerEns(contractInput);

      const argStr = (
        await Promise.all(
          activeInputs.map((input) =>
            evmlArg(input.type, args[input.name] ?? "", ensToVar),
          ),
        )
      ).join(" ");
      const valueOpt = value.trim() ? ` --value ${value.trim()}` : "";
      onAdd(
        `exec ${target} "${activeSig}"${argStr ? ` ${argStr}` : ""}${valueOpt}`,
        sets,
      );
      setAddressInput("");
      setSelectedSig("");
      setManualSig("");
      setArgs({});
      setValue("");
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
          <select
            className={inputCls}
            value={selectedSig}
            onChange={(e) => {
              setSelectedSig(e.target.value);
              setManualSig("");
              setArgs({});
            }}
          >
            <option value="">Select a function…</option>
            {functions.map((fn) => (
              <option key={fn.signature} value={fn.signature}>
                {fn.signature}
              </option>
            ))}
            <option value={CUSTOM_SIG}>Custom signature (not in the ABI)…</option>
          </select>
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
          {activeInputs.map((input) => (
            <div key={input.name}>
              <label className="block text-xs font-mono text-[var(--color-ink-3)] mb-1">
                {input.name} <span className="opacity-60">({input.type})</span>
              </label>
              <input
                className={inputCls}
                value={args[input.name] ?? ""}
                onChange={(e) =>
                  setArgs((prev) => ({ ...prev, [input.name]: e.target.value }))
                }
                spellCheck={false}
              />
            </div>
          ))}
        </div>
      )}

      {(selected?.payable || useManual) && resolved && activeSig && (
        <div>
          <label className="block text-xs font-mono text-[var(--color-ink-3)] mb-1">
            value <span className="opacity-60">(wei, e.g. 1e18 — optional)</span>
          </label>
          <input
            className={inputCls}
            value={value}
            onChange={(e) => setValue(e.target.value)}
            spellCheck={false}
          />
        </div>
      )}

      <button
        type="button"
        disabled={!canAdd || adding}
        onClick={add}
        className="px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
      >
        Add to batch
      </button>
    </div>
  );
}
