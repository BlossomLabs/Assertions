import { useEffect, useMemo, useState } from "react";
import type { Address } from "viem";
import { isAddress } from "viem";
import { usePublicClient } from "wagmi";

import { BatchList } from "./BatchList";
import { Callout } from "./Callout";
import { ExpressionAssertionEditor } from "./ExpressionAssertionEditor";
import {
  type BlockField,
  type CodeVariant,
  buildAssertionLine,
  buildFlatLine,
} from "./assertion-codegen";
import { unixToDatetimeLocal } from "./assertion-eval";
import { type Assertion, emptyAssertion } from "./assertion-model";
import { evml } from "./evml";
import { useChainClient } from "./useChainSupport";
import {
  inputCls,
  resolveEnsAddress,
  useContractFunctions,
} from "./useContractFunctions";
import {
  type AssertionPlacement,
  insertAssertionLines,
  type useScriptState,
} from "./useScriptState";
import { btnPrimaryCls, btnSmallCls, labelCls, smallLabelCls } from "./ui";

type Kind = "state" | "balance" | "code" | "block" | "chainid";

const KINDS: { value: Kind; label: string; hint: string }[] = [
  {
    value: "state",
    label: "Contract state",
    hint: "A view call or a composed expression (min/max, |a − b|, lengths, arithmetic…) compared to a value or another live expression",
  },
  {
    value: "balance",
    label: "ETH balance",
    hint: "Native balance of an account, e.g. the recipient's balance grew to the expected amount",
  },
  {
    value: "code",
    label: "Contract code",
    hint: "Code exists, is absent, or matches a known hash",
  },
  {
    value: "block",
    label: "Block",
    hint: "Block number or timestamp, e.g. a proposal executes before a deadline",
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
    hint: "Checked before the batch's actions run. Guards the state the batch relies on (prices, code you reviewed, rights you hold).",
  },
  {
    value: "post",
    label: "Post-condition",
    hint: "Checked after the actions run. Guards the outcome (funds arrived, rights granted, parameters set).",
  },
];

const BALANCE_OPS = ["==", ">", "<", ">=", "<=", "~="];
const BLOCK_OPS = ["==", ">", "<", ">=", "<="];

export function AssertionForm({
  scriptState,
  chainId,
  executor,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  executor: Address | undefined;
}) {
  const { script, insertAssertion, removeLine } = scriptState;
  const mainnetClient = usePublicClient({ chainId: 1 });
  const chainClient = useChainClient(chainId);

  const [placement, setPlacement] = useState<AssertionPlacement>("post");
  const [kind, setKind] = useState<Kind>("state");

  // The expression-kind assertion (subject/operator/expected tree).
  const [assertion, setAssertion] = useState<Assertion>(emptyAssertion);

  // Code fields.
  const [addressInput, setAddressInput] = useState("");
  const [codeVariant, setCodeVariant] = useState<CodeVariant>("codehash");
  const [blockField, setBlockField] = useState<BlockField>("number");

  // Balance fields.
  const [account, setAccount] = useState("@me");

  // Comparison fields shared by the flat kinds.
  const [operator, setOperator] = useState("==");
  const [expected, setExpected] = useState("");
  const [delta, setDelta] = useState("");
  const [message, setMessage] = useState("");

  const [fetchStatus, setFetchStatus] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [justAdded, setJustAdded] = useState(false);

  // The code kind resolves its target here; the state kind's call nodes
  // each fetch their own ABI inside the tree editor.
  const contract = useContractFunctions(
    chainId,
    kind === "code" ? addressInput : "",
    "view",
  );

  const resetFields = (nextKind: Kind) => {
    setAssertion(emptyAssertion());
    setAddressInput("");
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

  const operators = useMemo(() => {
    switch (kind) {
      case "balance":
        return BALANCE_OPS;
      case "block":
        return BLOCK_OPS;
      default:
        return null; // state has its own editor; code & chainid no operator
    }
  }, [kind]);

  // Keep the operator within the allowed set when the kind changes.
  useEffect(() => {
    if (operators && !operators.includes(operator)) setOperator(operators[0]);
  }, [operators, operator]);

  const targetInput = addressInput.trim();

  /**
   * Build the assertion line (+ hoisted `set` lines) from the form, or null
   * while the form is incomplete. `resolveEns` resolves ENS names appearing
   * in the expression to their address on this chain; the live preview
   * passes a no-op.
   */
  const buildAssertion = async (
    resolveEns: (name: string) => Promise<string | null>,
  ): Promise<{ line: string; sets: string[] } | null> => {
    const options = { resolveEns, chainId };
    if (kind === "state")
      return buildAssertionLine({ ...assertion, message }, options);
    return buildFlatLine(
      {
        kind,
        account,
        targetInput,
        targetResolved: contract.resolved,
        codeVariant,
        blockField,
        operator,
        expected,
        delta,
        message,
      },
      options,
    );
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
      if (!chainClient) throw new Error("no RPC for this chain");
      const block = await chainClient.getBlock();
      setExpected(
        String(blockField === "number" ? block.number : block.timestamp),
      );
    } catch {
      setFetchStatus("Could not fetch the current value. Enter it manually.");
    }
  };

  const add = async () => {
    if (adding) return;
    setAdding(true);
    try {
      // Resolve ENS names to this chain's address (multichain names record
      // one per chain); the codegen hoists the matching `set` lines.
      const built = await buildAssertion((name) =>
        resolveEnsAddress(mainnetClient, name, chainId),
      );
      if (!built) return;
      insertAssertion(built.line, placement, built.sets);
      resetFields(kind);
      setJustAdded(true);
    } finally {
      setAdding(false);
    }
  };

  const showExpected = kind !== "code" || codeVariant === "codehash";
  const canAdd =
    !!preview && validation?.state === "done" && validation.valid && !adding;

  const kindMeta = KINDS.find((k) => k.value === kind)!;
  const contractStatus = contract.status?.includes("ENS")
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

      {/* Configure: the expression editor (state kind) */}
      {kind === "state" && (
        <ExpressionAssertionEditor
          assertion={assertion}
          setAssertion={setAssertion}
          chainId={chainId}
          executor={executor}
        />
      )}

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

      {/* Configure: contract target (code) */}
      {kind === "code" && (
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
              Note: proxy upgrades don't change code. To guard against them,
              assert implementation() under Contract state instead.
            </p>
          )}
        </div>
      )}

      {/* Configure: comparison (flat kinds) */}
      {kind !== "state" && (operators !== null || showExpected) && (
        <div className="flex gap-2 items-end flex-wrap">
          {operators !== null && (
            <div className="w-28">
              <label className={labelCls}>Operator</label>
              <select
                className={inputCls}
                value={operator}
                onChange={(e) => setOperator(e.target.value)}
              >
                {operators.map((op) => (
                  <option key={op} value={op}>
                    {op}
                  </option>
                ))}
              </select>
            </div>
          )}
          {showExpected && (
            <div className="flex-1 min-w-40">
              <label className={labelCls}>
                {kind === "code"
                  ? "Expected code hash (bytes32)"
                  : "Expected value"}
              </label>
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
            </div>
          )}
          {kind === "block" && (
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

      {/* Approximate comparisons need a tolerance (flat kinds) */}
      {kind !== "state" && operator === "~=" && showExpected && (
        <div>
          <label className={labelCls}>
            Allowed delta{" "}
            <span className="text-xs text-[var(--color-ink-3)]">
              (tolerance for ~=)
            </span>
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
            <Callout tone="error">
              {(validation.messages.length
                ? validation.messages
                : ["The assertion does not validate."]
              ).map((m, i) => (
                <p key={i} className="font-mono whitespace-pre-wrap">
                  {m}
                </p>
              ))}
            </Callout>
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
                · assertion added, simulate with assertions in step 5 to
                verify it holds
              </span>
            )}
          </p>
          <BatchList
            script={script}
            onRemoveLine={removeLine}
            canRemove={(line) => line.startsWith("assertions:")}
            hideLine={(line) => line === "load assertions"}
          />
        </div>
      )}
    </div>
  );
}
