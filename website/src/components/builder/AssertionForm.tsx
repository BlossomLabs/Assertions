import { useEffect, useMemo, useState } from "react";
import type { Address } from "viem";
import { isAddress, parseAbiItem } from "viem";
import { normalize } from "viem/ens";
import { usePublicClient } from "wagmi";

import { evml } from "./evml";
import {
  canonicalType,
  ensVarName,
  evmlArg,
  inputCls,
  toInputs,
  useContractFunctions,
} from "./useContractFunctions";
import {
  type AssertionPlacement,
  insertAssertionLines,
  type useScriptState,
} from "./useScriptState";

type Kind = "state" | "balance" | "code" | "block" | "chainid";
type CodeVariant = "has-code" | "no-code" | "codehash";
type BlockField = "number" | "timestamp";

const KINDS: { value: Kind; label: string; hint: string }[] = [
  {
    value: "state",
    label: "Contract state",
    hint: "A view call compared to a value — e.g. balanceOf(@me) >= 10e18, owner() == 0x…",
  },
  {
    value: "balance",
    label: "ETH balance",
    hint: "Native balance of an account — e.g. the recipient's balance grew to the expected amount",
  },
  {
    value: "code",
    label: "Contract code",
    hint: "Code exists, is absent, or matches a known hash",
  },
  {
    value: "block",
    label: "Block",
    hint: "Block number or timestamp — e.g. a proposal executes before a deadline",
  },
  {
    value: "chainid",
    label: "Chain ID",
    hint: "e.g. a reused signature can't land on another chain",
  },
];

const PLACEMENTS: {
  value: AssertionPlacement;
  label: string;
  hint: string;
}[] = [
  {
    value: "pre",
    label: "Pre-condition",
    hint: "Checked before the batch's actions run — guards the state the batch relies on (prices, code you reviewed, rights you hold).",
  },
  {
    value: "post",
    label: "Post-condition",
    hint: "Checked after the actions run — guards the outcome (funds arrived, rights granted, parameters set).",
  },
];

/** Sentinel for the dropdown option that reveals the manual signature inputs. */
const CUSTOM_SIG = "__custom__";
/** Operator value for the bare boolean form (`assert target::fn()`). */
const BARE_OP = "is true";

const UINT_OPS = ["==", "!=", ">", "<", ">=", "<=", "~="];
const BOOL_OPS = [BARE_OP, "==", "!="];
const EQ_OPS = ["==", "!="];
const BALANCE_OPS = ["==", ">", "<", ">=", "<=", "~="];
const BLOCK_OPS = ["==", ">", "<", ">=", "<="];

function opsForReturnType(returnType: string | null): string[] {
  if (!returnType) return EQ_OPS;
  if (/^u?int\d*$/.test(returnType)) return UINT_OPS;
  if (returnType === "bool") return BOOL_OPS;
  return EQ_OPS;
}

/** Integer parse accepting EVML-ish e-notation ("1e18", "2.5e6"). */
function parseNumeric(v: string): bigint {
  if (/^-?\d+$/.test(v)) return BigInt(v);
  const m = v.match(/^(-?\d+)(?:\.(\d+))?e\+?(\d+)$/i);
  if (m) {
    const [, int, frac = "", exp] = m;
    const zeros = Number(exp) - frac.length;
    if (zeros >= 0) return BigInt(int + frac + "0".repeat(zeros));
  }
  throw new Error(`cannot parse "${v}" as an integer`);
}

/** Form string → JS value for an eth_call argument. */
function parseCallArg(type: string, raw: string, executor?: Address): unknown {
  const v = raw.trim();
  if (v === "@me") {
    if (!executor) throw new Error("connect a wallet to resolve @me");
    return executor;
  }
  if (/^u?int\d*$/.test(type)) return parseNumeric(v);
  if (type === "bool") return v === "true";
  if (type === "address" || type.startsWith("bytes") || type === "string")
    return v;
  throw new Error(`unsupported argument type ${type}`);
}

/** eth_call result → form string. */
function formatResult(value: unknown): string {
  if (typeof value === "bigint") return value.toString();
  if (typeof value === "boolean") return value ? "true" : "false";
  return String(value);
}

/** Unix-seconds string → local "YYYY-MM-DDTHH:mm" for a datetime-local
 *  input ("" when the value isn't a plain timestamp). */
function unixToDatetimeLocal(value: string): string {
  const v = value.trim();
  if (!/^\d+$/.test(v)) return "";
  const d = new Date(Number(v) * 1000);
  if (Number.isNaN(d.getTime()) || d.getFullYear() > 9999) return "";
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/** Expected form value → EVML literal for the assert line. */
function formatExpected(value: string, returnType: string | null): string {
  const v = value.trim();
  if (returnType === "string") return JSON.stringify(v);
  return v;
}

const btnPrimaryCls =
  "px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-bp-500)] text-white hover:bg-[var(--color-bp-400)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors";
const btnSmallCls =
  "px-2.5 py-1.5 rounded-lg text-xs font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors whitespace-nowrap";
const labelCls = "block text-sm text-[var(--color-ink-2)] mb-1.5";
const smallLabelCls =
  "block text-xs font-mono text-[var(--color-ink-3)] mb-1";

export function AssertionForm({
  scriptState,
  chainId,
  executor,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  executor: Address | undefined;
}) {
  const { script, insertAssertion } = scriptState;
  const mainnetClient = usePublicClient({ chainId: 1 });
  const chainClient = usePublicClient({ chainId });

  const [placement, setPlacement] = useState<AssertionPlacement>("post");
  const [kind, setKind] = useState<Kind>("state");

  // Contract state / code fields.
  const [addressInput, setAddressInput] = useState("");
  const [selectedSig, setSelectedSig] = useState("");
  const [manualSig, setManualSig] = useState("");
  const [manualRet, setManualRet] = useState("");
  const [args, setArgs] = useState<Record<string, string>>({});
  const [codeVariant, setCodeVariant] = useState<CodeVariant>("codehash");
  const [blockField, setBlockField] = useState<BlockField>("number");

  // Balance fields.
  const [account, setAccount] = useState("@me");

  // Comparison fields shared by most kinds.
  const [operator, setOperator] = useState("==");
  const [expected, setExpected] = useState("");
  const [delta, setDelta] = useState("");
  const [message, setMessage] = useState("");

  const [fetchStatus, setFetchStatus] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [justAdded, setJustAdded] = useState(false);

  const needsContract = kind === "state" || kind === "code";
  const contract = useContractFunctions(
    chainId,
    needsContract ? addressInput : "",
    "view",
  );

  // A new address means a new ABI — drop the previous function selection.
  useEffect(() => {
    setSelectedSig("");
  }, [addressInput]);

  const resetFields = (nextKind: Kind) => {
    setAddressInput("");
    setSelectedSig("");
    setManualSig("");
    setManualRet("");
    setArgs({});
    setCodeVariant("codehash");
    setBlockField("number");
    setAccount("@me");
    setOperator(nextKind === "balance" || nextKind === "block" ? ">=" : "==");
    setExpected(nextKind === "chainid" ? String(chainId) : "");
    setDelta("");
    setMessage("");
    setFetchStatus(null);
  };

  const changeKind = (next: Kind) => {
    setKind(next);
    resetFields(next);
  };

  // View functions the `assert` command can compare directly (single return
  // value — tuple returns need a destructure lens, which the editor covers).
  const viewFns = useMemo(
    () => contract.functions?.filter((f) => f.outputs.length === 1) ?? null,
    [contract.functions],
  );

  const selectedFn = useMemo(
    () => viewFns?.find((f) => f.signature === selectedSig) ?? null,
    [viewFns, selectedSig],
  );

  // Manual view signature: "fn(argTypes)" plus an explicit return type, so
  // the line can use the inline-ABI form (no on-chain ABI lookup needed).
  const manualFn = useMemo(() => {
    const sig = manualSig.trim();
    const ret = manualRet.trim();
    if (!sig || !ret) return null;
    try {
      const item = parseAbiItem(`function ${sig} view returns (${ret})`);
      if (item.type !== "function" || item.outputs.length !== 1) return null;
      return {
        name: item.name,
        inputs: toInputs(item.inputs),
        argTypes: item.inputs.map(canonicalType),
        returnType: canonicalType(item.outputs[0]),
      };
    } catch {
      return null;
    }
  }, [manualSig, manualRet]);

  const useManual =
    kind === "state" &&
    (selectedSig === CUSTOM_SIG || (viewFns !== null && viewFns.length === 0));

  const activeFn = useMemo(() => {
    if (kind !== "state") return null;
    if (useManual)
      return manualFn ? { ...manualFn, inline: true as const } : null;
    if (!selectedFn) return null;
    return {
      name: selectedFn.name,
      inputs: selectedFn.inputs,
      argTypes: selectedFn.inputs.map((i) => i.type),
      returnType: selectedFn.outputs[0],
      inline: false as const,
    };
  }, [kind, useManual, manualFn, selectedFn]);

  const returnType = activeFn?.returnType ?? null;

  const operators = useMemo(() => {
    switch (kind) {
      case "state":
        return opsForReturnType(returnType);
      case "balance":
        return BALANCE_OPS;
      case "block":
        return BLOCK_OPS;
      default:
        return null; // code & chainid have no operator
    }
  }, [kind, returnType]);

  // Keep the operator within the allowed set when the return type changes.
  useEffect(() => {
    if (operators && !operators.includes(operator)) setOperator(operators[0]);
  }, [operators, operator]);

  // Booleans are compared against a fixed true/false select.
  const boolExpected = kind === "state" && returnType === "bool";
  useEffect(() => {
    if (boolExpected && operator !== BARE_OP && !["true", "false"].includes(expected))
      setExpected("true");
  }, [boolExpected, operator, expected]);

  const targetInput = addressInput.trim();
  const targetAddress: Address | null = isAddress(targetInput)
    ? targetInput
    : contract.resolved;

  /**
   * Build the assertion line (+ hoisted `set` lines) from the form, or null
   * while the form is incomplete. `ensToVar` resolves ENS names appearing in
   * call arguments; the live preview passes a no-op.
   */
  const buildAssertion = async (
    ensToVar: (name: string) => Promise<string | null>,
  ): Promise<{ line: string; sets: string[] } | null> => {
    const sets: string[] = [];
    const registerEns = (name: string): string => {
      const varName = ensVarName(name);
      const setLine = `set ${varName} @ens(${name})`;
      if (!sets.includes(setLine)) sets.push(setLine);
      return varName;
    };
    // Contract given as an ENS name keeps the name in the script via a set
    // line (same convention as the batch composer).
    const target = () => {
      if (!targetInput) return null;
      if (isAddress(targetInput)) return targetInput;
      return contract.resolved ? registerEns(targetInput) : null;
    };
    const msg = message.trim() ? ` ${JSON.stringify(message.trim())}` : "";
    const comparison = (allowDelta: boolean): string | null => {
      if (!expected.trim()) return null;
      let out = ` ${operator} ${formatExpected(expected, returnType)}`;
      if (operator === "~=") {
        if (!allowDelta || !delta.trim()) return null;
        out += ` --delta ${delta.trim()}`;
      }
      return out;
    };

    switch (kind) {
      case "state": {
        const t = target();
        if (!t || !activeFn) return null;
        if (activeFn.inputs.some((i) => !(args[i.name] ?? "").trim()))
          return null;
        const argVals = await Promise.all(
          activeFn.inputs.map((i) =>
            evmlArg(i.type, args[i.name] ?? "", ensToVar),
          ),
        );
        const call = activeFn.inline
          ? `${t}::{${activeFn.name}(${activeFn.argTypes.join(",")})(${activeFn.returnType})${argVals.length ? ` ${argVals.join(" ")}` : ""}}`
          : `${t}::${activeFn.name}(${argVals.join(" ")})`;
        if (operator === BARE_OP)
          return { line: `assertions:assert ${call}${msg}`, sets };
        const cmp = comparison(true);
        if (!cmp) return null;
        return { line: `assertions:assert ${call}${cmp}${msg}`, sets };
      }
      case "balance": {
        if (!account.trim()) return null;
        const acct =
          account.trim() === "@me"
            ? "@me"
            : await evmlArg("address", account, ensToVar);
        const cmp = comparison(true);
        if (!cmp) return null;
        return { line: `assertions:assert-balance ${acct}${cmp}${msg}`, sets };
      }
      case "code": {
        const t = target();
        if (!t) return null;
        if (codeVariant === "codehash") {
          const exp = expected.trim();
          if (!exp) return null;
          return { line: `assertions:assert-codehash ${t} ${exp}${msg}`, sets };
        }
        const cmd = codeVariant === "has-code" ? "assert-code" : "assert-no-code";
        return { line: `assertions:${cmd} ${t}${msg}`, sets };
      }
      case "block": {
        const cmp = comparison(false);
        if (!cmp) return null;
        const cmd =
          blockField === "number" ? "assert-block-number" : "assert-timestamp";
        return { line: `assertions:${cmd}${cmp}${msg}`, sets };
      }
      case "chainid": {
        if (!expected.trim()) return null;
        return {
          line: `assertions:assert-chainid ${expected.trim()}${msg}`,
          sets,
        };
      }
    }
  };

  // Live preview: rebuilt on every form change (ENS args stay as typed —
  // they only resolve on Add).
  const [preview, setPreview] = useState<{
    line: string;
    sets: string[];
  } | null>(null);
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const built = await buildAssertion(async () => null).catch(() => null);
      if (cancelled) return;
      setPreview((prev) =>
        JSON.stringify(prev) === JSON.stringify(built) ? prev : built,
      );
    })();
    return () => {
      cancelled = true;
    };
  });

  // Validate the candidate script (current script + this assertion) with the
  // EVML validator, debounced.
  const [validation, setValidation] = useState<
    | { state: "checking" }
    | { state: "done"; valid: boolean; messages: string[] }
    | null
  >(null);
  const previewKey = preview ? `${preview.line}\n${preview.sets.join("\n")}` : "";
  useEffect(() => {
    if (!preview) {
      setValidation(null);
      return;
    }
    let cancelled = false;
    setValidation({ state: "checking" });
    const timer = setTimeout(async () => {
      const candidate = insertAssertionLines(
        script,
        preview.line,
        placement,
        preview.sets,
      );
      try {
        const tag = chainId ? evml.with({ chainId }) : evml;
        const { valid, diagnostics } = await tag.script(candidate).validate();
        if (cancelled) return;
        setValidation({
          state: "done",
          valid,
          messages: diagnostics.map((d) => d.message),
        });
      } catch (e) {
        if (cancelled) return;
        setValidation({
          state: "done",
          valid: false,
          messages: [e instanceof Error ? e.message : String(e)],
        });
      }
    }, 500);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [previewKey, script, placement, chainId]);

  const fetchCurrentValue = async () => {
    setFetchStatus(null);
    try {
      if (kind === "block") {
        if (!chainClient) throw new Error("no RPC for this chain");
        const block = await chainClient.getBlock();
        setExpected(
          String(blockField === "number" ? block.number : block.timestamp),
        );
        return;
      }
      if (kind !== "state" || !activeFn || !targetAddress) return;
      if (!chainClient) throw new Error("no RPC for this chain");
      setFetchStatus("Fetching current value…");
      const abiItem = parseAbiItem(
        `function ${activeFn.name}(${activeFn.argTypes.join(",")}) view returns (${activeFn.returnType})`,
      );
      const callArgs = activeFn.inputs.map((i) =>
        parseCallArg(i.type, args[i.name] ?? "", executor),
      );
      const result = await chainClient.readContract({
        address: targetAddress,
        abi: [abiItem],
        functionName: activeFn.name,
        args: callArgs,
      });
      setExpected(formatResult(result));
      setFetchStatus(null);
    } catch {
      setFetchStatus("Could not fetch the current value — enter it manually.");
    }
  };

  const add = async () => {
    if (adding) return;
    setAdding(true);
    try {
      const ensToVar = async (name: string): Promise<string | null> => {
        try {
          const addr = await mainnetClient?.getEnsAddress({
            name: normalize(name),
          });
          if (!addr) return null;
          const varName = ensVarName(name);
          return varName;
        } catch {
          return null;
        }
      };
      // Collect the set lines the resolved names need.
      const sets: string[] = [];
      const built = await buildAssertion(async (name) => {
        const varName = await ensToVar(name);
        if (!varName) return null;
        const setLine = `set ${varName} @ens(${name})`;
        if (!sets.includes(setLine)) sets.push(setLine);
        return varName;
      });
      if (!built) return;
      insertAssertion(built.line, placement, [...built.sets, ...sets]);
      resetFields(kind);
      setJustAdded(true);
    } finally {
      setAdding(false);
    }
  };

  const showOperator =
    operators !== null && (kind !== "state" || !!activeFn);
  const showExpected =
    kind === "state" ? !!activeFn : kind !== "code" || codeVariant === "codehash";
  const canAdd =
    !!preview && validation?.state === "done" && validation.valid && !adding;

  const kindMeta = KINDS.find((k) => k.value === kind)!;
  const contractStatus =
    kind === "state"
      ? contract.status
      : contract.status?.includes("ENS")
        ? contract.status
        : null;

  return (
    <div className="space-y-4">
      {/* When: pre vs post */}
      <div>
        <div className="flex items-center gap-1">
          {PLACEMENTS.map((p) => (
            <button
              key={p.value}
              type="button"
              onClick={() => setPlacement(p.value)}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
                placement === p.value
                  ? "bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)]"
                  : "text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
        <p className="mt-1.5 text-xs text-[var(--color-ink-3)]">
          {PLACEMENTS.find((p) => p.value === placement)!.hint}
        </p>
      </div>

      {/* What: assertion type */}
      <div>
        <label className={labelCls}>What to assert</label>
        <div className="grid grid-cols-2 lg:grid-cols-5 gap-2">
          {KINDS.map((k) => (
            <button
              key={k.value}
              type="button"
              onClick={() => changeKind(k.value)}
              className={`px-3 py-2.5 rounded-lg text-sm font-medium border transition-all ${
                kind === k.value
                  ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 text-[var(--color-bp-300)]"
                  : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/50"
              }`}
            >
              {k.label}
            </button>
          ))}
        </div>
        <p className="mt-1.5 text-xs text-[var(--color-ink-3)]">
          {kindMeta.hint}
        </p>
      </div>

      {/* Configure: block field */}
      {kind === "block" && (
        <div className="flex items-center gap-1">
          {(
            [
              ["number", "Block number"],
              ["timestamp", "Timestamp"],
            ] as [BlockField, string][]
          ).map(([field, label]) => (
            <button
              key={field}
              type="button"
              onClick={() => {
                setBlockField(field);
                setExpected("");
              }}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
                blockField === field
                  ? "bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)]"
                  : "text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      )}

      {/* Configure: contract target (state & code) */}
      {needsContract && (
        <div>
          <label className={labelCls}>Contract address or ENS name</label>
          <input
            className={inputCls}
            placeholder="0x… or mydao.eth"
            value={addressInput}
            onChange={(e) => setAddressInput(e.target.value)}
            spellCheck={false}
          />
          {contract.resolved && !isAddress(targetInput) && (
            <p className="mt-1 text-xs font-mono text-[var(--color-ink-3)]">
              {contract.resolved}
            </p>
          )}
          {contractStatus && (
            <p className="mt-1 text-xs text-[var(--color-ink-3)]">
              {contractStatus}
            </p>
          )}
          {kind === "state" && contract.contractName && (
            <p className="mt-1 text-xs text-[var(--color-ok)]">
              Verified: {contract.contractName}
            </p>
          )}
        </div>
      )}

      {/* Configure: view function (state) */}
      {kind === "state" && viewFns && viewFns.length > 0 && (
        <div>
          <label className={labelCls}>View function</label>
          <select
            className={inputCls}
            value={selectedSig}
            onChange={(e) => {
              setSelectedSig(e.target.value);
              setManualSig("");
              setManualRet("");
              setArgs({});
            }}
          >
            <option value="">Select a view function…</option>
            {viewFns.map((fn) => (
              <option key={fn.signature} value={fn.signature}>
                {fn.signature} → {fn.outputs[0]}
              </option>
            ))}
            <option value={CUSTOM_SIG}>
              Custom signature (not in the ABI)…
            </option>
          </select>
        </div>
      )}

      {kind === "state" && contract.resolved && useManual && (
        <div className="grid grid-cols-[1fr_8rem] gap-2">
          <div>
            <label className={labelCls}>Function signature</label>
            <input
              className={inputCls}
              placeholder="balanceOf(address)"
              value={manualSig}
              onChange={(e) => setManualSig(e.target.value)}
              spellCheck={false}
            />
          </div>
          <div>
            <label className={labelCls}>Returns</label>
            <input
              className={inputCls}
              placeholder="uint256"
              value={manualRet}
              onChange={(e) => setManualRet(e.target.value)}
              spellCheck={false}
            />
          </div>
        </div>
      )}

      {/* Configure: call arguments (state) */}
      {kind === "state" && activeFn && activeFn.inputs.length > 0 && (
        <div className="space-y-2">
          {activeFn.inputs.map((input) => (
            <div key={input.name}>
              <label className={smallLabelCls}>
                {input.name} <span className="opacity-60">({input.type})</span>
                {input.type === "address" && (
                  <span className="opacity-60"> — @me = the executor</span>
                )}
              </label>
              <input
                className={inputCls}
                value={args[input.name] ?? ""}
                onChange={(e) =>
                  setArgs((prev) => ({
                    ...prev,
                    [input.name]: e.target.value,
                  }))
                }
                spellCheck={false}
              />
            </div>
          ))}
        </div>
      )}

      {/* Configure: account (balance) */}
      {kind === "balance" && (
        <div>
          <label className={labelCls}>Account</label>
          <input
            className={inputCls}
            placeholder="@me, 0x… or name.eth"
            value={account}
            onChange={(e) => setAccount(e.target.value)}
            spellCheck={false}
          />
          <p className="mt-1 text-xs text-[var(--color-ink-3)]">
            @me is the executor
            {executor ? ` (${executor.slice(0, 6)}…${executor.slice(-4)})` : ""}.
          </p>
        </div>
      )}

      {/* Configure: code variant */}
      {kind === "code" && (
        <div>
          <label className={labelCls}>Condition</label>
          <select
            className={inputCls}
            value={codeVariant}
            onChange={(e) => setCodeVariant(e.target.value as CodeVariant)}
          >
            <option value="codehash">
              Code hash equals a known value (e.g. audited bytecode)
            </option>
            <option value="has-code">Address has deployed code</option>
            <option value="no-code">Address has no code</option>
          </select>
          {codeVariant === "codehash" && (
            <p className="mt-1 text-xs text-[var(--color-ink-3)]">
              Note: proxy upgrades don't change code — to guard against them,
              assert implementation() under Contract state instead.
            </p>
          )}
        </div>
      )}

      {/* Configure: comparison */}
      {(showOperator || showExpected) && (
        <div className="flex gap-2 items-end flex-wrap">
          {showOperator && (
            <div className="w-28">
              <label className={labelCls}>Operator</label>
              <select
                className={inputCls}
                value={operator}
                onChange={(e) => setOperator(e.target.value)}
              >
                {operators!.map((op) => (
                  <option key={op} value={op}>
                    {op}
                  </option>
                ))}
              </select>
            </div>
          )}
          {showExpected && operator !== BARE_OP && (
            <div className="flex-1 min-w-40">
              <label className={labelCls}>
                {kind === "code" ? "Expected code hash (bytes32)" : "Expected value"}
              </label>
              {boolExpected ? (
                <select
                  className={inputCls}
                  value={expected}
                  onChange={(e) => setExpected(e.target.value)}
                >
                  <option value="true">true</option>
                  <option value="false">false</option>
                </select>
              ) : (
                <input
                  className={inputCls}
                  placeholder={
                    kind === "balance"
                      ? "wei, e.g. 1e18"
                      : kind === "code"
                        ? "0x…"
                        : ""
                  }
                  value={expected}
                  onChange={(e) => setExpected(e.target.value)}
                  spellCheck={false}
                />
              )}
            </div>
          )}
          {(kind === "block" ||
            (kind === "state" && activeFn && targetAddress)) &&
            operator !== BARE_OP && (
              <button
                type="button"
                onClick={() => void fetchCurrentValue()}
                className={btnSmallCls}
                title="Read the value from the chain and prefill it"
              >
                Use current value
              </button>
            )}
        </div>
      )}
      {fetchStatus && (
        <p className="text-xs text-[var(--color-ink-3)]">{fetchStatus}</p>
      )}

      {/* Timestamp convenience: a date picker kept in sync with the unix
          timestamp above (both ways). */}
      {kind === "block" && blockField === "timestamp" && (
        <div>
          <label className={smallLabelCls}>
            …or pick a date{" "}
            <span className="opacity-60">
              (synced with the unix timestamp above)
            </span>
          </label>
          <input
            type="datetime-local"
            className={inputCls}
            value={unixToDatetimeLocal(expected)}
            onChange={(e) => {
              if (e.target.value)
                setExpected(
                  String(Math.floor(new Date(e.target.value).getTime() / 1000)),
                );
            }}
          />
        </div>
      )}

      {/* Approximate comparisons need a tolerance */}
      {operator === "~=" && showExpected && (
        <div>
          <label className={labelCls}>
            Allowed delta <span className="text-xs text-[var(--color-ink-3)]">(tolerance for ~=)</span>
          </label>
          <input
            className={inputCls}
            placeholder="e.g. 50e8"
            value={delta}
            onChange={(e) => setDelta(e.target.value)}
            spellCheck={false}
          />
        </div>
      )}

      {/* Revert message */}
      <div>
        <label className={labelCls}>
          Revert message{" "}
          <span className="text-xs text-[var(--color-ink-3)]">(optional)</span>
        </label>
        <input
          className={inputCls}
          placeholder="e.g. tokens did not arrive"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
        />
      </div>

      {/* Live preview + validation */}
      {preview && (
        <div>
          <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
            Will be inserted as a {placement === "pre" ? "pre" : "post"}
            -condition
          </p>
          <pre className="p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap">
            {[...preview.sets, preview.line].join("\n")}
          </pre>
          {validation?.state === "checking" && (
            <p className="mt-1.5 text-xs text-[var(--color-ink-3)]">
              Validating…
            </p>
          )}
          {validation?.state === "done" && !validation.valid && (
            <div className="mt-1.5 text-xs text-[var(--color-err)] space-y-0.5">
              {(validation.messages.length
                ? validation.messages
                : ["The assertion does not validate."]
              ).map((m, i) => (
                <p key={i} className="font-mono whitespace-pre-wrap">
                  {m}
                </p>
              ))}
            </div>
          )}
        </div>
      )}

      <button
        type="button"
        disabled={!canAdd}
        onClick={() => void add()}
        className={btnPrimaryCls}
      >
        {adding ? "Adding…" : "Add assertion"}
      </button>

      {script && (
        <div>
          <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
            Batch so far
            {justAdded && (
              <span className="text-[var(--color-bp-300)]">
                {" "}
                — assertion added, simulate with assertions in step 5 to
                verify it holds
              </span>
            )}
          </p>
          <pre className="p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap">
            {script}
          </pre>
        </div>
      )}
    </div>
  );
}
