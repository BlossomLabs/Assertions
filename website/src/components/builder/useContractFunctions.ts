import { fetchContractSource } from "@evmcrispr/sdk";
import { useEffect, useState } from "react";
import type { AbiParameter, Address } from "viem";
import { isAddress, parseAbiItem } from "viem";
import { normalize } from "viem/ens";
import { usePublicClient } from "wagmi";

export interface ParsedFunction {
  signature: string;
  name: string;
  inputs: { name: string; type: string }[];
  /** Canonical output types (empty for write functions). */
  outputs: string[];
  payable: boolean;
}

/** Shared Tailwind classes for the builder's form inputs. */
export const inputCls =
  "w-full px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 " +
  "focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-sm placeholder:text-[var(--color-ink-3)]";

/** Canonical ABI type string, expanding tuples: "(uint256,address)[]" not "tuple[]". */
export function canonicalType(param: AbiParameter): string {
  if (param.type.startsWith("tuple") && "components" in param) {
    const suffix = param.type.slice("tuple".length);
    return `(${param.components.map(canonicalType).join(",")})${suffix}`;
  }
  return param.type;
}

export function toInputs(params: readonly AbiParameter[]) {
  return params.map((param, i) => ({
    name: param.name || `arg${i}`,
    type: canonicalType(param),
  }));
}

/**
 * Functions out of the human-readable ABI signatures the sdk returns.
 * `write` keeps state-changing functions (batch actions); `view` keeps
 * view/pure functions with a return value (assertion subjects).
 */
export function parseFunctions(
  abi: readonly string[],
  kind: "write" | "view",
): ParsedFunction[] {
  const out: ParsedFunction[] = [];
  for (const entry of abi) {
    if (!entry.startsWith("function ")) continue;
    const isView = /\b(view|pure)\b/.test(entry);
    if (kind === "write" ? isView : !isView) continue;
    try {
      const item = parseAbiItem(entry);
      if (item.type !== "function") continue;
      const outputs = (item.outputs ?? []).map(canonicalType);
      if (kind === "view" && outputs.length === 0) continue;
      out.push({
        signature: `${item.name}(${item.inputs.map(canonicalType).join(",")})`,
        name: item.name,
        inputs: toInputs(item.inputs),
        outputs,
        payable: item.stateMutability === "payable",
      });
    } catch {
      /* skip signatures viem can't parse */
    }
  }
  return out.sort((a, b) => a.name.localeCompare(b.name));
}

/** Split on top-level commas, ignoring ones nested in brackets, parens or quotes. */
export function splitTopLevel(s: string): string[] {
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
export function ensVarName(name: string): string {
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
export async function evmlArg(
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

/**
 * Resolve an address/ENS input and fetch the verified ABI, following proxies.
 * Shared by the batch composer (write functions) and the assertion form
 * (view functions).
 */
export function useContractFunctions(
  chainId: number,
  addressInput: string,
  kind: "write" | "view",
) {
  const publicClient = usePublicClient({ chainId: 1 });
  const [resolved, setResolved] = useState<Address | null>(null);
  const [status, setStatus] = useState<string | null>(null);
  const [functions, setFunctions] = useState<ParsedFunction[] | null>(null);
  const [contractName, setContractName] = useState<string | null>(null);

  useEffect(() => {
    const input = addressInput.trim();
    setResolved(null);
    setFunctions(null);
    setContractName(null);
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
      let fns = parseFunctions(source.abi, kind);
      let name = source.name;
      if (source.isProxy && source.implementation) {
        const impl = await fetchContractSource(
          chainId,
          source.implementation,
        ).catch(() => null);
        if (cancelled) return;
        if (impl) {
          fns = parseFunctions(impl.abi, kind);
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
  }, [addressInput, chainId, kind, publicClient]);

  return { resolved, status, functions, contractName };
}
