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
import {
  isEvaluable,
  readSubjectValue,
  unixToDatetimeLocal,
} from "./assertion-eval";
import {
  type Assertion,
  type ValueExpr,
  BARE_OP,
  emptyAssertion,
  emptyCall,
  inferCategory,
  opsFor,
  validateAssertion,
} from "./assertion-model";
import { CallEditor } from "./expr/CallEditor";
import { LineIcon } from "./expr/icons";
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
import {
  btnPrimaryCls,
  btnSmallCls,
  focusRingCls,
  labelCls,
  segBtnCls,
  smallLabelCls,
  tileBtnCls,
} from "./ui";

/** Direct mode ("simple") emits the dedicated assert-* commands of the
 *  Assertions core. Composed mode ("advanced") is the expression editor
 *  (subject ⟨op⟩ expected over the Combinators tree). Suggest hands the
 *  batch to the AI assistant instead of building one manually. */
type Mode = "simple" | "advanced" | "suggest";
type SimpleKind = "call" | "balance" | "code" | "block" | "chainid";

/** The subject shape the "Contract call" simple kind edits. */
type CallNode = Extract<ValueExpr, { kind: "call" }>;

const SIMPLE_KINDS: { value: SimpleKind; label: string; hint: string }[] = [
  {
    value: "call",
    label: "Contract state",
    hint: "A view function's return value compared to what you expect, e.g. the new owner is set",
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

/** Check-tile icons, shared with the expression editor's source pickers
 *  (SimpleKind values map 1:1 onto shared icon names). */
function KindIcon({ kind }: { kind: SimpleKind }) {
  return <LineIcon name={kind} />;
}

const MODES: {
  value: Mode;
  label: string;
  dependency: string;
  hint: string;
}[] = [
  {
    value: "simple",
    label: "Direct assertion",
    dependency: "Assertions core only",
    hint: "Check one contract value or environment property.",
  },
  {
    value: "advanced",
    label: "Composed expression",
    dependency: "Uses Combinators v1.0",
    hint: "Chain, combine, or transform runtime values.",
  },
  {
    value: "suggest",
    label: "Suggest assertions",
    dependency: "AI assistant",
    hint: "Let the assistant propose and insert protective assertions.",
  },
];

const COMPOSED_HINT =
  "A view call, balance, clock or code-hash value — wrapped in combinators (min/max, |a − b|, lengths, arithmetic…) and compared to a value or another live expression";

const PLACEMENTS: {
  value: AssertionPlacement;
  label: string;
  hint: string;
}[] = [
  {
    value: "pre",
    label: "Before actions",
    hint: "A pre-condition: checked before the batch's actions run. Guards the state the batch relies on (prices, code you reviewed, rights you hold).",
  },
  {
    value: "post",
    label: "After actions",
    hint: "A post-condition: checked after the actions run. Guards the outcome (funds arrived, rights granted, parameters set).",
  },
];

const BALANCE_OPS = ["==", ">", "<", ">=", "<=", "~="];
const BLOCK_OPS = ["==", ">", "<", ">=", "<="];

export function AssertionForm({
  scriptState,
  chainId,
  executor,
  suggest,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  executor: Address | undefined;
  /** Wiring for the "Suggest assertions" mode: whether the batch simulated
   *  successfully (step 3), whether the assistant is busy, whether the user
   *  is logged in to the chat, and the action that hands the prompt to the
   *  chat panel. */
  suggest: {
    ready: boolean;
    running: boolean;
    loggedIn: boolean;
    onSuggest: () => void;
  };
}) {
  const { script, insertAssertion, removeLine } = scriptState;
  const mainnetClient = usePublicClient({ chainId: 1 });
  const chainClient = useChainClient(chainId);

  const [placement, setPlacement] = useState<AssertionPlacement>("post");
  const [mode, setMode] = useState<Mode>("simple");
  const [simpleKind, setSimpleKind] = useState<SimpleKind>("call");

  // The expression-kind assertion (subject/operator/expected tree).
  const [assertion, setAssertion] = useState<Assertion>(emptyAssertion);

  // Contract-call fields: a single call subject, no combinators.
  const [callNode, setCallNode] = useState<CallNode>(
    () => emptyCall() as CallNode,
  );

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

  // The code kind resolves its target here; the advanced mode's call nodes
  // each fetch their own ABI inside the tree editor.
  const contract = useContractFunctions(
    chainId,
    mode === "simple" && simpleKind === "code" ? addressInput : "",
    "view",
  );

  const resetFields = (nextKind: SimpleKind) => {
    setAssertion(emptyAssertion());
    setCallNode(emptyCall() as CallNode);
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

  const changeKind = (next: SimpleKind) => {
    setSimpleKind(next);
    resetFields(next);
  };

  const operators = useMemo(() => {
    switch (simpleKind) {
      case "call":
        // Category-driven, like the advanced editor: the subject is live,
        // the expected side is a build-time literal.
        return opsFor(
          inferCategory(callNode),
          inferCategory({ kind: "literal", value: expected }),
          false,
          true,
        );
      case "balance":
        return BALANCE_OPS;
      case "block":
        return BLOCK_OPS;
      default:
        return null; // code & chainid have no operator select
    }
  }, [simpleKind, callNode, expected]);

  // Keep the operator within the allowed set when the kind changes.
  useEffect(() => {
    if (operators && !operators.includes(operator)) setOperator(operators[0]);
  }, [operators, operator]);

  const targetInput = addressInput.trim();

  /** The Assertion the Contract-call simple kind describes: the call as
   *  subject, a literal expected side, no combinators. */
  const callAssertion = (): Assertion => ({
    subject: callNode,
    operator: operator === BARE_OP ? null : operator,
    expected:
      operator === BARE_OP ? null : { kind: "literal", value: expected },
    delta,
    message,
  });

  /**
   * Build the assertion line (+ hoisted `set` lines) from the form, or null
   * while the form is incomplete. `resolveEns` resolves ENS names appearing
   * in the expression to their address on this chain; the live preview
   * passes a no-op.
   */
  const buildAssertion = async (
    resolveEns: (name: string) => Promise<string | null>,
  ): Promise<{ line: string; sets: string[] } | null> => {
    if (mode === "suggest") return null;
    const options = { resolveEns, chainId };
    if (mode === "advanced")
      return buildAssertionLine({ ...assertion, message }, options);
    if (simpleKind === "call")
      return buildAssertionLine(callAssertion(), options);
    return buildFlatLine(
      {
        kind: simpleKind,
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

  // Live preview: rebuilt on every form change. ENS args render as their
  // $variable + `set $var @ens(name)` line without resolving; Add swaps in
  // the chain-aware set line (frozen per-chain address off mainnet).
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
      if (simpleKind === "call") {
        setExpected(await readSubjectValue(chainClient, callNode, executor));
        return;
      }
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
      resetFields(simpleKind);
      setJustAdded(true);
    } finally {
      setAdding(false);
    }
  };

  const showExpected =
    simpleKind === "call"
      ? operator !== BARE_OP
      : simpleKind !== "code" || codeVariant === "codehash";
  const canAdd =
    !!preview && validation?.state === "done" && validation.valid && !adding;

  const kindMeta = SIMPLE_KINDS.find((k) => k.value === simpleKind)!;
  const contractStatus = contract.status?.includes("ENS")
    ? contract.status
    : null;

  /** Convert the current simple form into the equivalent expression tree
   *  and switch to advanced mode (one-way; the codegen collapses an
   *  uncustomized expression back to the same flat command). */
  const promoteToExpression = () => {
    let subject: ValueExpr;
    let op = operator;
    switch (simpleKind) {
      case "call":
        setAssertion({ ...callAssertion(), message: "" });
        setMode("advanced");
        return;
      case "balance":
        subject = {
          kind: "balance",
          token: "ETH",
          account: { kind: "literal", value: account },
        };
        break;
      case "block":
        subject = {
          kind: "clock",
          which: blockField === "number" ? "blocknumber" : "timestamp",
        };
        break;
      case "chainid":
        subject = { kind: "chainid" };
        op = "==";
        break;
      case "code":
        subject = {
          kind: "codehash",
          address: { kind: "literal", value: targetInput },
        };
        op = "==";
        break;
    }
    setAssertion({
      subject,
      operator: op,
      expected: { kind: "literal", value: expected },
      delta,
      message: "",
    });
    setMode("advanced");
  };

  const canPromote = simpleKind !== "code" || codeVariant === "codehash";

  // Eager guidance for the contract-call kind (the expression editor shows
  // these inline per node; here the call is the only node).
  const callIssues = useMemo(
    () =>
      mode === "simple" && simpleKind === "call"
        ? validateAssertion(callAssertion())
        : [],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [mode, simpleKind, callNode, operator, expected, delta],
  );

  return (
    <div className="space-y-4">
      {/* First decision: build directly on the Assertions core, compose an
          expression through the Combinators contract, or hand the batch to
          the AI assistant */}
      <div role="group" aria-label="How do you want to add assertions?">
        <span className={labelCls}>How do you want to add assertions?</span>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
          {MODES.map((m) => (
            <button
              key={m.value}
              type="button"
              aria-pressed={mode === m.value}
              onClick={() => setMode(m.value)}
              className={`px-3.5 py-3 ${tileBtnCls(mode === m.value)}`}
            >
              <span className="flex items-center gap-2 text-sm font-medium">
                {m.label}
                {mode === m.value && (
                  <span className="text-xs" aria-hidden>
                    ✓
                  </span>
                )}
              </span>
              <span className="block mt-0.5 text-xs font-mono text-[var(--color-ink-3)]">
                {m.dependency}
              </span>
              <span className="block mt-1 text-xs text-[var(--color-ink-3)]">
                {m.hint}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Suggest: hand the batch to the assistant */}
      {mode === "suggest" && (
        <div className="flex items-center gap-3 flex-wrap rounded-xl border border-[var(--color-bp-400)]/30 bg-[var(--color-bp-500)]/5 px-4 py-3">
          <button
            type="button"
            disabled={!suggest.ready || !suggest.loggedIn || suggest.running}
            onClick={suggest.onSuggest}
            className={`px-4 py-2 rounded-lg text-sm font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors ${focusRingCls}`}
          >
            <span aria-hidden>✦</span>{" "}
            {suggest.running ? "Assistant is working…" : "Suggest assertions"}
          </button>
          <span className="text-xs text-[var(--color-ink-3)]">
            {!suggest.loggedIn
              ? "Requires the assertion assistant — log in from the chat panel first."
              : !suggest.ready
                ? "Available after the batch simulates successfully in step 3."
                : "The assistant reads your batch, inserts pre- and post-conditions, and simulates to confirm they hold."}
          </span>
        </div>
      )}

      {mode === "simple" && (
        <div role="group" aria-label="Choose a check">
          <span className={labelCls}>Choose a check</span>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
            {SIMPLE_KINDS.map((k) => (
              <button
                key={k.value}
                type="button"
                aria-pressed={simpleKind === k.value}
                onClick={() => changeKind(k.value)}
                className={`px-3 py-2.5 text-sm font-medium ${tileBtnCls(simpleKind === k.value)}`}
              >
                <span className="flex items-center gap-2">
                  <KindIcon kind={k.value} />
                  {k.label}
                </span>
              </button>
            ))}
          </div>
          <p className="mt-1.5 text-xs text-[var(--color-ink-3)]">
            {kindMeta.hint}
            {canPromote && (
              <>
                {" · "}
                <button
                  type="button"
                  className="text-[var(--color-bp-300)] hover:underline"
                  title="One-way: opens this check in the expression editor so it can be combined with other values"
                  onClick={promoteToExpression}
                >
                  Convert this check to a composed expression →
                </button>
              </>
            )}
          </p>
        </div>
      )}

      {/* Configure: the expression editor (composed mode) */}
      {mode === "advanced" && (
        <div>
          <span className={labelCls}>Build the expression</span>
          <p className="mb-2 text-xs text-[var(--color-ink-3)]">
            {COMPOSED_HINT}
          </p>
          <ExpressionAssertionEditor
            assertion={assertion}
            setAssertion={setAssertion}
            chainId={chainId}
            executor={executor}
          />
        </div>
      )}

      {/* Configure: the view call (contract-call kind) */}
      {mode === "simple" && simpleKind === "call" && (
        <div className="space-y-2">
          <CallEditor
            node={callNode}
            onChange={(updater) => setCallNode(updater)}
            chainId={chainId}
            allowChain={false}
          />
          {callIssues.length > 0 && (
            <Callout tone="error">
              {callIssues.map((issue, i) => (
                <p key={i}>{issue.message}</p>
              ))}
            </Callout>
          )}
        </div>
      )}

      {/* Configure: block field */}
      {mode === "simple" && simpleKind === "block" && (
        <div
          role="group"
          aria-label="Block field"
          className="flex items-center gap-1"
        >
          {(
            [
              ["number", "Block number"],
              ["timestamp", "Timestamp"],
            ] as [BlockField, string][]
          ).map(([field, label]) => (
            <button
              key={field}
              type="button"
              aria-pressed={blockField === field}
              onClick={() => {
                setBlockField(field);
                setExpected("");
              }}
              className={segBtnCls(blockField === field)}
            >
              {label}
            </button>
          ))}
        </div>
      )}

      {/* Configure: contract target (code) */}
      {mode === "simple" && simpleKind === "code" && (
        <div>
          <label className={labelCls} htmlFor="assert-code-address">
            Contract address or ENS name
          </label>
          <input
            id="assert-code-address"
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
      {mode === "simple" && simpleKind === "balance" && (
        <div>
          <label className={labelCls} htmlFor="assert-balance-account">
            Account
          </label>
          <input
            id="assert-balance-account"
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
      {mode === "simple" && simpleKind === "code" && (
        <div>
          <label className={labelCls} htmlFor="assert-code-variant">
            Condition
          </label>
          <select
            id="assert-code-variant"
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
      {mode === "simple" && (operators !== null || showExpected) && (
        <div className="flex gap-2 items-end flex-wrap">
          {operators !== null && (
            <div className="w-28">
              <label className={labelCls} htmlFor="assert-operator">
                Operator
              </label>
              <select
                id="assert-operator"
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
              <label className={labelCls} htmlFor="assert-expected">
                {simpleKind === "code"
                  ? "Expected code hash (bytes32)"
                  : "Expected value"}
              </label>
              <input
                id="assert-expected"
                className={inputCls}
                placeholder={
                  simpleKind === "balance"
                    ? "wei, e.g. 1e18"
                    : simpleKind === "code"
                      ? "0x…"
                      : ""
                }
                value={expected}
                onChange={(e) => setExpected(e.target.value)}
                spellCheck={false}
              />
            </div>
          )}
          {(simpleKind === "block" ||
            (simpleKind === "call" &&
              showExpected &&
              isEvaluable(callNode))) && (
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
      {mode === "simple" && simpleKind === "block" && blockField === "timestamp" && (
        <div>
          <label className={smallLabelCls} htmlFor="assert-datetime">
            …or pick a date{" "}
            <span className="opacity-60">
              (synced with the unix timestamp above)
            </span>
          </label>
          <input
            id="assert-datetime"
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
      {mode === "simple" && operator === "~=" && showExpected && (
        <div>
          <label className={labelCls} htmlFor="assert-delta">
            Allowed delta{" "}
            <span className="text-xs text-[var(--color-ink-3)]">
              (tolerance for ~=)
            </span>
          </label>
          <input
            id="assert-delta"
            className={inputCls}
            placeholder="e.g. 50e8"
            value={delta}
            onChange={(e) => setDelta(e.target.value)}
            spellCheck={false}
          />
        </div>
      )}

      {/* Revert message */}
      {mode !== "suggest" && (
        <div>
          <label className={labelCls} htmlFor="assert-message">
            Revert message{" "}
            <span className="text-xs text-[var(--color-ink-3)]">
              (optional)
            </span>
          </label>
          <input
            id="assert-message"
            className={inputCls}
            placeholder="e.g. tokens did not arrive"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
          />
        </div>
      )}

      {/* When: pre vs post — decided last, right before the assertion is
          inserted into the script */}
      {mode !== "suggest" && (
        <div role="group" aria-label="When should it run?">
          <span className={labelCls}>When should it run?</span>
          <div className="flex items-center gap-1">
            {PLACEMENTS.map((p) => (
              <button
                key={p.value}
                type="button"
                aria-pressed={placement === p.value}
                onClick={() => setPlacement(p.value)}
                className={segBtnCls(placement === p.value)}
              >
                {p.label}
              </button>
            ))}
          </div>
          <p className="mt-1.5 text-xs text-[var(--color-ink-3)]">
            {PLACEMENTS.find((p) => p.value === placement)!.hint}
          </p>
        </div>
      )}

      {/* Footer: generated EVML, validation state and the Add action */}
      {mode !== "suggest" && (
        <div className="rounded-xl border border-[var(--color-ink-3)]/20 p-4 space-y-3">
          {preview ? (
            <details open>
              <summary className="cursor-pointer list-none flex items-center gap-2 flex-wrap text-xs text-[var(--color-ink-3)] [&::-webkit-details-marker]:hidden">
                <span className="font-medium text-[var(--color-ink-2)]">
                  Generated assertion
                </span>
                <span>
                  · inserted {placement === "pre" ? "before" : "after"} the
                  actions
                </span>
                {validation?.state === "checking" && (
                  <span>· validating…</span>
                )}
                {validation?.state === "done" && validation.valid && (
                  <span className="text-[var(--color-ok)]">✓ valid</span>
                )}
                {validation?.state === "done" && !validation.valid && (
                  <span className="text-[var(--color-err)]">
                    needs attention
                  </span>
                )}
              </summary>
              <pre className="mt-2 p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap">
                {[...preview.sets, preview.line].join("\n")}
              </pre>
            </details>
          ) : (
            <p className="text-xs text-[var(--color-ink-3)]">
              <span className="font-medium text-[var(--color-ink-2)]">
                Generated assertion
              </span>{" "}
              · complete the fields above to see the EVML this check compiles
              to.
            </p>
          )}
          {preview && validation?.state === "done" && !validation.valid && (
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
          <button
            type="button"
            disabled={!canAdd}
            onClick={() => void add()}
            className={btnPrimaryCls}
          >
            {adding ? "Adding…" : "Add assertion"}
          </button>
        </div>
      )}

      {script && (
        <div className="border-t border-[var(--color-ink-3)]/15 pt-4">
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
