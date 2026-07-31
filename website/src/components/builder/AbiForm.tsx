import { fetchContractSource } from "@evmcrispr/sdk";
import { useEffect, useMemo, useState } from "react";
import type { AbiParameter, Address } from "viem";
import { isAddress, parseAbiItem } from "viem";
import { normalize } from "viem/ens";
import { usePublicClient } from "wagmi";

interface ParsedFunction {
  signature: string;
  name: string;
  inputs: { name: string; type: string }[];
  payable: boolean;
}

/** Canonical ABI type string, expanding tuples: "(uint256,address)[]" not "tuple[]". */
function canonicalType(param: AbiParameter): string {
  if (param.type.startsWith("tuple") && "components" in param) {
    const suffix = param.type.slice("tuple".length);
    return `(${param.components.map(canonicalType).join(",")})${suffix}`;
  }
  return param.type;
}

function toInputs(params: readonly AbiParameter[]) {
  return params.map((param, i) => ({
    name: param.name || `arg${i}`,
    type: canonicalType(param),
  }));
}

/** Write functions out of the human-readable ABI signatures the sdk
 *  returns (view/pure ones can't be batch actions). */
function parseWriteFunctions(abi: readonly string[]): ParsedFunction[] {
  const out: ParsedFunction[] = [];
  for (const entry of abi) {
    if (!entry.startsWith("function ")) continue;
    if (/\b(view|pure)\b/.test(entry)) continue;
    try {
      const item = parseAbiItem(entry);
      if (item.type !== "function") continue;
      out.push({
        signature: `${item.name}(${item.inputs.map(canonicalType).join(",")})`,
        name: item.name,
        inputs: toInputs(item.inputs),
        payable: item.stateMutability === "payable",
      });
    } catch {
      /* skip signatures viem can't parse */
    }
  }
  return out.sort((a, b) => a.name.localeCompare(b.name));
}

/** Split on top-level commas, ignoring ones nested in brackets, parens or quotes. */
function splitTopLevel(s: string): string[] {
  const parts: string[] = [];
  let cur = "";
  let depth = 0;
  let quote: string | null = null;
  for (const ch of s) {
    if (quote) {
      cur += ch;
      if (ch === quote) quote = null;
      continue;
    }
    if (ch === '"' || ch === "'") {
      quote = ch;
      cur += ch;
      continue;
    }
    if (ch === "[" || ch === "(") depth++;
    else if (ch === "]" || ch === ")") depth--;
    if (ch === "," && depth === 0) {
      parts.push(cur);
      cur = "";
      continue;
    }
    cur += ch;
  }
  parts.push(cur);
  return parts.map((p) => p.trim()).filter(Boolean);
}

/** "$daiTokensEthers" for "dai.tokens.ethers.eth" — an EVML variable name. */
function ensVarName(name: string): string {
  const parts = name
    .replace(/\.eth$/i, "")
    .split(/[^a-zA-Z0-9]+/)
    .filter(Boolean);
  const ident = parts
    .map((p, i) => (i === 0 ? p : p[0].toUpperCase() + p.slice(1)))
    .join("");
  return `$${/^\d/.test(ident) ? `a${ident}` : ident || "addr"}`;
}

/**
 * Turn a raw form value into an EVML argument. Comma-separated (optionally
 * bracketed) values become EVML's whitespace-separated arrays; tuples are
 * written as arrays too (EVML has no tuple literal). Names that resolve via
 * ENS become $variables backed by `set $var @ens(name)` lines (the @ens
 * helper can't run mid-batch, so it's hoisted to the top of the script).
 */
async function evmlArg(
  type: string,
  raw: string,
  ensToVar: (name: string) => Promise<string | null>,
): Promise<string> {
  const value = raw.trim();

  const arrayMatch = type.match(/^(.*)\[\d*\]$/);
  if (arrayMatch) {
    const inner =
      value.startsWith("[") && value.endsWith("]") ? value.slice(1, -1) : value;
    const elems = await Promise.all(
      splitTopLevel(inner).map((elem) => evmlArg(arrayMatch[1], elem, ensToVar)),
    );
    return `[${elems.join(" ")}]`;
  }

  if (type.startsWith("(") && type.endsWith(")")) {
    const compTypes = splitTopLevel(type.slice(1, -1));
    const inner =
      (value.startsWith("(") && value.endsWith(")")) ||
      (value.startsWith("[") && value.endsWith("]"))
        ? value.slice(1, -1)
        : value;
    const comps = await Promise.all(
      splitTopLevel(inner).map((comp, i) =>
        evmlArg(compTypes[i] ?? "", comp, ensToVar),
      ),
    );
    return `[${comps.join(" ")}]`;
  }

  if (type === "string") return JSON.stringify(value);

  if (type === "address" && value && !isAddress(value) && value.includes(".")) {
    const varName = await ensToVar(value);
    if (varName) return varName;
  }

  return value;
}

/** Sentinel value for the dropdown option that reveals the manual signature input. */
const CUSTOM_SIG = "__custom__";

const inputCls =
  "w-full px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 " +
  "focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-sm placeholder:text-[var(--color-ink-3)]";

export function AbiForm({
  chainId,
  onAdd,
}: {
  chainId: number;
  onAdd: (line: string, sets: string[]) => void;
}) {
  const publicClient = usePublicClient({ chainId: 1 });
  const [addressInput, setAddressInput] = useState("");
  const [resolved, setResolved] = useState<Address | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [functions, setFunctions] = useState<ParsedFunction[] | null>(null);
  const [contractName, setContractName] = useState<string | null>(null);
  const [manualSig, setManualSig] = useState("");
  const [selectedSig, setSelectedSig] = useState("");
  const [args, setArgs] = useState<Record<string, string>>({});
  const [value, setValue] = useState("");
  const [adding, setAdding] = useState(false);

  // Resolve the address/ENS, then fetch the verified ABI.
  useEffect(() => {
    const input = addressInput.trim();
    setResolved(null);
    setFunctions(null);
    setContractName(null);
    setSelectedSig("");
    setStatus(null);
    if (!input) return;

    let cancelled = false;
    const timer = setTimeout(async () => {
      let address: Address | null = null;
      if (isAddress(input)) {
        address = input;
      } else if (input.includes(".")) {
        setStatus("Resolving ENS name…");
        try {
          address = (await publicClient?.getEnsAddress({
            name: normalize(input),
          })) as Address | null;
        } catch {
          address = null;
        }
        if (!address) {
          if (!cancelled) setStatus("ENS name did not resolve.");
          return;
        }
      } else {
        return;
      }
      if (cancelled) return;
      setResolved(address);
      setStatus("Fetching verified ABI…");
      const source = await fetchContractSource(chainId, address).catch(
        () => null,
      );
      if (cancelled) return;
      if (!source) {
        setStatus(
          "No verified ABI found (or no Etherscan API key configured) — enter the function signature manually.",
        );
        setFunctions([]);
        return;
      }
      let fns = parseWriteFunctions(source.abi);
      let name = source.name;
      if (source.isProxy && source.implementation) {
        const impl = await fetchContractSource(
          chainId,
          source.implementation,
        ).catch(() => null);
        if (cancelled) return;
        if (impl) {
          fns = parseWriteFunctions(impl.abi);
          name = `${source.name} → ${impl.name}`;
        }
      }
      setContractName(name);
      setFunctions(fns);
      setStatus(null);
    }, 500);

    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [addressInput, chainId, publicClient]);

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
        {resolved && !isAddress(addressInput.trim()) && (
          <p className="mt-1 text-xs font-mono text-[var(--color-ink-3)]">
            {resolved}
          </p>
        )}
        {status && (
          <p className="mt-1 text-xs text-[var(--color-ink-3)]">{status}</p>
        )}
        {contractName && (
          <p className="mt-1 text-xs text-[var(--color-ok)]">
            Verified: {contractName}
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
        className="px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-bp-500)] text-white hover:bg-[var(--color-bp-400)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
      >
        Add to batch
      </button>
    </div>
  );
}
