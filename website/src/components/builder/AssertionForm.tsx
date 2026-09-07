import { useEvmlTag } from "@evmcrispr/editor";
import { useEffect, useState } from "react";
import { usePublicClient } from "wagmi";

import { Callout } from "./Callout";
import { ExpressionAssertionEditor } from "./ExpressionAssertionEditor";
import { buildAssertionLine } from "./assertion-codegen";
import type { Assertion } from "./assertion-model";
import {
  type CompileDiagnostic,
  type CompileOutcome,
  compileAssertionLine,
} from "./compile-adapter";
import { LineIcon } from "./expr/icons";
import { PRESETS, type PresetKey, seedAssertion } from "./presets";
import type { AssertionPlacement } from "./script-ops";
import { inputCls, resolveEnsAddress } from "./useContractFunctions";
import type { useScriptState } from "./useScriptState";
import {
  btnPrimaryCls,
  focusRingCls,
  labelCls,
  segBtnCls,
  tileBtnCls,
} from "./ui";

const PRESET_ICONS: Record<PresetKey, "call" | "balance" | "code" | "block" | "timestamp" | "chainId"> = {
  call: "call",
  balance: "balance",
  codeHash: "code",
  hasCode: "code",
  noCode: "code",
  blockNumber: "block",
  timestamp: "timestamp",
  chainId: "chainId",
};

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

type CompileState =
  | { state: "checking" }
  | { state: "done"; outcome: CompileOutcome };

/** The preview line with the diagnostic's `[col, endCol)` range marked,
 *  when the diagnostic points inside the assertion. */
function MarkedLine({
  line,
  diagnostic,
  insertedAt,
}: {
  line: string;
  diagnostic: CompileDiagnostic;
  insertedAt: number;
}) {
  const rows = line.split("\n");
  const row = (diagnostic.line ?? insertedAt) - insertedAt;
  const text = rows[row];
  if (text === undefined || diagnostic.col === undefined)
    return <span>{line}</span>;
  const start = Math.min(diagnostic.col, text.length);
  const end =
    diagnostic.endLine === undefined || diagnostic.endLine === diagnostic.line
      ? Math.min(diagnostic.endCol ?? text.length, text.length)
      : text.length;
  const marked = text.slice(start, Math.max(end, start + 1));
  return (
    <span>
      {rows.slice(0, row).map((r) => `${r}\n`)}
      {text.slice(0, start)}
      <mark className="bg-[var(--color-err)]/20 text-inherit rounded-sm px-0.5 underline decoration-[var(--color-err)] decoration-wavy">
        {marked}
      </mark>
      {text.slice(start + marked.length)}
      {rows.slice(row + 1).map((r) => `\n${r}`)}
    </span>
  );
}

export function AssertionForm({
  scriptState,
  chainId,
  suggest,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  /** Wiring for "Suggest assertions": whether the batch simulated
   *  successfully, whether the assistant is busy, whether the user is
   *  logged in to the chat, and the action that hands the prompt to the
   *  chat panel. */
  suggest: {
    ready: boolean;
    running: boolean;
    loggedIn: boolean;
    onSuggest: () => void;
  };
}) {
  const { script, insertAssertion } = scriptState;
  const tag = useEvmlTag();
  const mainnetClient = usePublicClient({ chainId: 1 });

  const [placement, setPlacement] = useState<AssertionPlacement>("post");
  const [preset, setPreset] = useState<PresetKey>("call");
  const [assertion, setAssertion] = useState<Assertion>(() =>
    seedAssertion("call", chainId),
  );
  const [message, setMessage] = useState("");
  const [adding, setAdding] = useState(false);
  const [justAdded, setJustAdded] = useState(false);

  const pick = (key: PresetKey) => {
    setPreset(key);
    setAssertion(seedAssertion(key, chainId));
    setMessage("");
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
      const built = await buildAssertionLine(
        { ...assertion, message },
        { resolveEns: async () => null, chainId },
      ).catch(() => null);
      if (cancelled) return;
      setPreview((prev) =>
        JSON.stringify(prev) === JSON.stringify(built) ? prev : built,
      );
    })();
    return () => {
      cancelled = true;
    };
  });

  // The compiler's verdict on the candidate (current script + this
  // assertion), debounced.
  const [compile, setCompile] = useState<CompileState | null>(null);
  const previewKey = preview ? `${preview.line}\n${preview.sets.join("\n")}` : "";
  useEffect(() => {
    if (!preview) {
      setCompile(null);
      return;
    }
    const abort = new AbortController();
    setCompile({ state: "checking" });
    const timer = setTimeout(async () => {
      const outcome = await compileAssertionLine(
        tag,
        script,
        preview.line,
        preview.sets,
        placement,
        { signal: abort.signal },
      ).catch(
        (e): CompileOutcome => ({
          ok: false,
          diagnostics: [
            {
              message: e instanceof Error ? e.message : String(e),
              inAssertion: true,
            },
          ],
          candidate: script,
          insertedAt: 0,
        }),
      );
      if (abort.signal.aborted) return;
      setCompile({ state: "done", outcome });
    }, 500);
    return () => {
      abort.abort();
      clearTimeout(timer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [previewKey, script, placement, tag]);

  const add = async () => {
    if (adding) return;
    setAdding(true);
    try {
      // Resolve ENS names to this chain's address (multichain names record
      // one per chain); the codegen hoists the matching `set` lines.
      const built = await buildAssertionLine(
        { ...assertion, message },
        {
          resolveEns: (name) => resolveEnsAddress(mainnetClient, name, chainId),
          chainId,
        },
      );
      if (!built) return;
      insertAssertion(built.line, placement, built.sets);
      pick(preset);
      setJustAdded(true);
    } finally {
      setAdding(false);
    }
  };

  const outcome = compile?.state === "done" ? compile.outcome : null;
  const canAdd = !!preview && outcome?.ok === true && !adding;
  const failure = outcome && !outcome.ok ? outcome.diagnostics[0] : null;
  const suggestHint = !suggest.loggedIn
    ? "Requires the assertion assistant: log in from the chat panel first."
    : !suggest.ready
      ? "Available after a passing simulation of the batch (step 1)."
      : "The assistant reads your batch, inserts pre- and post-conditions, and simulates to confirm they hold.";

  return (
    <div className="space-y-4">
      {/* The assistant: one row, description inline with the button */}
      <div className="flex items-center gap-3 rounded-xl border border-[var(--color-bp-400)]/30 bg-[var(--color-bp-500)]/5 px-4 py-2.5">
        <button
          type="button"
          disabled={!suggest.ready || !suggest.loggedIn || suggest.running}
          onClick={suggest.onSuggest}
          className={`shrink-0 px-4 py-2 rounded-lg text-sm font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors ${focusRingCls}`}
        >
          <span aria-hidden>✦</span>{" "}
          {suggest.running ? "Assistant is working…" : "Suggest assertions"}
        </button>
        <span className="min-w-0 text-xs text-[var(--color-ink-3)]">{suggestHint}</span>
      </div>

      {/* Presets */}
      <div role="group" aria-label="Start from">
        <span className={labelCls}>Start from</span>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
          {PRESETS.map((p) => (
            <button
              key={p.key}
              type="button"
              aria-pressed={preset === p.key}
              onClick={() => pick(p.key)}
              title={p.hint}
              className={`px-3 py-2 text-sm font-medium ${tileBtnCls(preset === p.key)}`}
            >
              <span className="flex items-center gap-2">
                <LineIcon name={PRESET_ICONS[p.key]} />
                {p.label}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* The expression editor, seeded by the preset */}
      <div>
        <span className={labelCls}>Build the expression</span>
        <ExpressionAssertionEditor
          assertion={assertion}
          setAssertion={setAssertion}
          chainId={chainId}
          script={script}
        />
      </div>

      {/* Revert message */}
      <div>
        <label className={labelCls} htmlFor="assert-message">
          Revert message{" "}
          <span className="text-xs text-[var(--color-ink-3)]">(optional)</span>
        </label>
        <input
          id="assert-message"
          className={inputCls}
          placeholder="e.g. tokens did not arrive"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
        />
      </div>

      {/* When: pre vs post */}
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

      {/* Footer: generated EVML, the compiler's verdict and Add */}
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
              {compile?.state === "checking" && <span>· compiling…</span>}
              {outcome?.ok && (
                <span className="text-[var(--color-ok)]">✓ compiles</span>
              )}
              {outcome && !outcome.ok && (
                <span className="text-[var(--color-err)]">needs attention</span>
              )}
            </summary>
            <pre className="mt-2 p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap">
              {preview.sets.map((s) => `${s}\n`)}
              {failure?.inAssertion && outcome ? (
                <MarkedLine
                  line={preview.line}
                  diagnostic={failure}
                  insertedAt={outcome.insertedAt}
                />
              ) : (
                preview.line
              )}
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
        {preview && failure && (
          <Callout tone="error">
            <p className="font-mono whitespace-pre-wrap">
              {failure.inAssertion || failure.line === undefined
                ? failure.message
                : `Line ${failure.line} of the batch: ${failure.message}`}
            </p>
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
        {justAdded && (
          <p className="text-xs text-[var(--color-bp-300)]">
            Assertion added. Simulate the protected batch below to confirm it
            holds.
          </p>
        )}
      </div>
    </div>
  );
}
