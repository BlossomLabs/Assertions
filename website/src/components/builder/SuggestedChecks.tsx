import { type ReactNode, useEffect, useState } from "react";

import { AddressLink } from "./AddressLink";
import { type AddressName, useAddressNames } from "./address-names";
import { ButtonIcon } from "./ButtonIcon";
import type { ContextKind } from "./context";
import { markSuggested } from "./script-ops";
import type { SimKey, SimulationState } from "./simulation";
import {
  type SuggestedCheck,
  type SuggestionSource,
  checkNotices,
  descriptionParts,
  displayDescription,
  BALANCE_SOURCE,
  fromBalances,
  sentenceView,
  suggestedChecks,
  suggestionSpan,
  suggestionSource,
  suggestionVariables,
} from "./suggested-checks";
import { btnSmallCls, focusRingCls, noBreakCls } from "./ui";
import type { useScriptState } from "./useScriptState";

/** A row's text actions (Show code, Keep): links with their icon. */
const rowLinkCls = `inline-flex items-center gap-1 rounded text-xs text-[var(--color-ink-2)] underline underline-offset-2 hover:text-[var(--color-bp-300)] ${focusRingCls}`;

/** An id for a row's popover, from its line. */
const rowId = (line: string): string => {
  let h = 0;
  for (let i = 0; i < line.length; i++) h = (h * 31 + line.charCodeAt(i)) | 0;
  return (h >>> 0).toString(36);
};

/** The (i) beside a check's sentence: where it comes from, and what can
 *  make it fail, one click away. */
function InfoButton({
  open,
  controls,
  onToggle,
}: {
  open: boolean;
  controls: string;
  onToggle: () => void;
}) {
  return (
    <button
      type="button"
      data-about-toggle
      aria-label="About this check"
      aria-expanded={open}
      aria-controls={controls}
      onClick={onToggle}
      className={`ml-1 inline-block align-[-3px] rounded-full text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)] aria-expanded:text-[var(--color-bp-300)] ${focusRingCls}`}
    >
      <ButtonIcon name="info" size={16} />
    </button>
  );
}

/** "Suggested by USDC's Transfer event": the contract a check comes from,
 *  by the name it gives itself, linked to its page on the explorer, with
 *  its address on hover either way. */
function SourceLine({ source }: { source: SuggestionSource }) {
  return (
    <p className="text-xs text-[var(--color-ink-2)]">
      Suggested by <AddressLink link={source} />'s {source.eventName} event
    </p>
  );
}

/** What a check says, as a sentence: its words, with every account,
 *  contract and token it mentions linked. A suggestion of the older shape
 *  has only a description, shown with its shortened addresses unbroken. */
function Sentence({
  check,
  chainId,
  names,
  children,
}: {
  check: SuggestedCheck;
  chainId: number;
  names?: ReadonlyMap<string, AddressName>;
  /** Drawn at the end of the sentence, inline with its words. */
  children?: ReactNode;
}) {
  const view = sentenceView(check, chainId, names);
  return (
    <p className="text-sm text-[var(--color-ink-2)]">
      {view
        ? view.map((part, i) =>
            typeof part === "string" ? (
              part
            ) : "abbreviated" in part ? (
              <abbr
                key={i}
                title={part.full}
                aria-label={part.full}
                className="no-underline cursor-help"
              >
                {part.abbreviated}
              </abbr>
            ) : (
              <AddressLink key={i} link={part} />
            ),
          )
        : descriptionParts(check.description).map((part, i) =>
            typeof part === "string" ? (
              part
            ) : (
              <span key={i} className={noBreakCls}>
                {part.address}
              </span>
            ),
          )}
      {children}
    </p>
  );
}

/** Wiring for the assistant's "Suggest more assertions": whether the
 *  batch has a fresh passing simulation, whether the assistant is busy,
 *  whether the user is logged in to it, and the action that hands it the
 *  prompt. */
export interface SuggestWiring {
  ready: boolean;
  running: boolean;
  loggedIn: boolean;
  onSuggest: () => void;
}

/** Why "Suggest more assertions" cannot be used now, or what it does. */
function suggestHint(
  suggest: SuggestWiring,
  simulated: boolean,
): { text: string; enabled: boolean } {
  if (!suggest.ready)
    return simulated
      ? {
          text: "The batch changed since its last simulation: simulate it again first.",
          enabled: false,
        }
      : { text: "Simulate the batch in step 1 first.", enabled: false };
  if (!suggest.loggedIn)
    return {
      text: "Log in to Dappnode Nexus in the assistant panel to use it.",
      enabled: false,
    };
  return {
    text: "The assistant reads the batch, adds pre- and post-conditions, and simulates to confirm they hold.",
    enabled: !suggest.running,
  };
}

/**
 * The checks step 1's simulation suggests, at the top of step 2, and the
 * assistant's button for more. Each row says what its check asserts, has
 * where it comes from and its notices behind its (i), its EVML one click
 * away, and Add, or Remove once the batch holds it. Rows stay when the
 * actions change after the run, marked as from an earlier simulation:
 * which checks to keep is the user's call. Nothing is added or removed
 * without a click.
 */
export function SuggestedChecks({
  state,
  simKey,
  context,
  chainId,
  scriptState,
  suggest,
  manual,
}: {
  /** Step 1's simulation: the run that suggests. */
  state: SimulationState;
  /** The protected batch as it is now. */
  simKey: SimKey;
  /** Who executes: later for anything but a wallet. */
  context: ContextKind;
  /** The chain the batch targets: whose explorer the rows link to. */
  chainId: number;
  /** The script a check is added to and removed from. */
  scriptState: Pick<
    ReturnType<typeof useScriptState>,
    "addLine" | "previewLine" | "removeCommand" | "unmarkCommand" | "markCommand"
  >;
  suggest: SuggestWiring;
  /** "Add assertions manually": whether the form is shown, and the toggle. */
  manual: { open: boolean; controls: string; onToggle: () => void };
}) {
  // The rows whose code is shown, by their line.
  const [open, setOpen] = useState<ReadonlySet<string>>(new Set());
  // The row whose (i) is open: one at a time, closed by Escape or a click
  // anywhere else.
  const [info, setInfo] = useState<string | null>(null);
  useEffect(() => {
    if (info === null) return;
    const onDown = (e: MouseEvent) => {
      const target = e.target as Element | null;
      if (!target?.closest?.("[data-about-check], [data-about-toggle]"))
        setInfo(null);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setInfo(null);
    };
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [info]);
  const found = suggestedChecks(state, simKey);
  const rows = found?.rows ?? [];
  // Every account and contract the rows mention, named where a name can
  // be found for it (an ENS name that resolves back, a verified contract).
  const mentioned = rows.flatMap(({ check }) =>
    Array.isArray(check.sentence)
      ? check.sentence.flatMap((part) =>
          part.type === "address" ? [String(part.address)] : [],
        )
      : [],
  );
  const names = useAddressNames(mentioned, chainId);

  /** Add a check after the actions, through the form's own path: under
   *  the script's variable names, with the `set` lines it still needs and
   *  the loads derived. Each is bound to the script as it is when its turn
   *  comes, so that several added in a row see each other's variables. */
  const add = (check: SuggestedCheck) =>
    void scriptState.addLine(markSuggested(check.line), "post", {
      vars: suggestionVariables(check),
    });
  /** Take out the command that holds it, and with it the variables only
   *  it used. */
  const remove = (check: SuggestedCheck) => {
    const span = suggestionSpan(simKey.script, check);
    if (span) scriptState.removeCommand(span.start);
  };
  /** Make it the user's: the mark taken off the command that holds it. */
  const unmark = (check: SuggestedCheck) => {
    const span = suggestionSpan(simKey.script, check);
    if (span) scriptState.unmarkCommand(span.start);
  };
  /** Hand it back to the suggestions: the mark put back. */
  const mark = (check: SuggestedCheck) => {
    const span = suggestionSpan(simKey.script, check);
    if (span) scriptState.markCommand(span.start);
  };
  const hint = suggestHint(suggest, found !== null || state.status === "success");

  return (
    <div
      data-suggested-checks
      className="rounded-xl border border-[var(--color-bp-400)]/30 bg-[var(--color-bp-500)]/5 p-4 space-y-3"
    >
      <div className="flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <h4 className="text-sm font-semibold text-[var(--color-ink)]">
            Suggested checks
          </h4>
          <p className="text-xs text-[var(--color-ink-2)]">
            {!found
              ? "Simulate the batch in step 1 to see the checks it suggests."
              : found.error
                ? `No checks suggested: ${found.error}`
                : rows.length === 0
                  ? "This simulation suggested no checks."
                  : "Drawn from what the simulation of step 1 did: read each one before adding it."}
          </p>
        </div>
      </div>

      {found?.stale && rows.length > 0 && (
        <p className="text-xs text-[var(--color-ink-2)]">
          The actions changed since these were suggested: simulate the batch
          in step 1 again to update them.
        </p>
      )}

      {rows.length > 0 && (
        <ul className="space-y-2">
          {rows.map(({ check, inBatch, marked }, index) => {
            // The step clips what spills past it (it folds), so the last
            // row's popover opens upward, over the row before.
            const upward = index === rows.length - 1 && rows.length > 1;
            const notices = checkNotices(check, context, simKey.from);
            const source = suggestionSource(check, chainId);
            const about = source || fromBalances(check) || notices.length > 0;
            const shown = open.has(check.line);
            const code = shown
              ? scriptState.previewLine(
                  check.line,
                  suggestionVariables(check),
                  simKey.script,
                )
              : null;
            const label = displayDescription(check.description);
            return (
              <li
                key={check.line}
                data-in-batch={inBatch || undefined}
                className="relative flex items-start gap-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 px-3 py-2.5"
              >
                <div className="min-w-0 flex-1 space-y-1.5">
                  <Sentence check={check} chainId={chainId} names={names}>
                    {about && (
                      <InfoButton
                        open={info === check.line}
                        controls={`about-${rowId(check.line)}`}
                        onToggle={() =>
                          setInfo((was) => (was === check.line ? null : check.line))
                        }
                      />
                    )}
                  </Sentence>
                  {about && (
                    <div
                      id={`about-${rowId(check.line)}`}
                      role="note"
                      hidden={info !== check.line}
                      data-about-check
                      className={`absolute left-3 right-3 z-20 ${upward ? "bottom-full -mb-1" : "top-full -mt-1"} space-y-1.5 rounded-lg border border-[var(--color-bp-400)]/50 bg-[var(--color-surface)] p-3 text-xs text-[var(--color-ink-2)] shadow-xl shadow-black/40`}
                    >
                      {source ? (
                        <SourceLine source={source} />
                      ) : (
                        fromBalances(check) && <p>{BALANCE_SOURCE}</p>
                      )}
                      {notices.map((notice) => (
                        <p key={notice}>{notice}</p>
                      ))}
                    </div>
                  )}
                  <div className="flex flex-wrap items-center gap-x-4 gap-y-1">
                    <button
                      type="button"
                      aria-expanded={shown}
                      onClick={() =>
                        setOpen((was) => {
                          const next = new Set(was);
                          if (!next.delete(check.line)) next.add(check.line);
                          return next;
                        })
                      }
                      className={rowLinkCls}
                    >
                      <ButtonIcon name={shown ? "hide" : "show"} size={14} />
                      {shown ? "Hide code" : "Show code"}
                    </button>
                    {inBatch &&
                      (marked ? (
                        // Make it the user's: the mark comes off and later
                        // runs of step 1 leave it as it is.
                        <button
                          type="button"
                          onClick={() => unmark(check)}
                          title="Keep as if you added this manually"
                          aria-label={`Keep check: ${label}`}
                          className={rowLinkCls}
                        >
                          <ButtonIcon name="keep" size={14} />
                          Keep
                        </button>
                      ) : (
                        // Hand it back: the mark returns and later runs keep,
                        // replace or remove it again.
                        <button
                          type="button"
                          onClick={() => mark(check)}
                          title="Treat as suggested again: later simulations may update or remove it"
                          aria-label={`Unkeep check: ${label}`}
                          className={rowLinkCls}
                        >
                          <ButtonIcon name="unkeep" size={14} />
                          Unkeep
                        </button>
                      ))}
                  </div>
                  {code && (
                    // What adding it puts in the batch: the variables it
                    // still needs, then its line.
                    <pre className="font-mono text-xs whitespace-pre-wrap wrap-anywhere">
                      <code>{[...code.sets, code.line].join("\n")}</code>
                    </pre>
                  )}
                </div>
                {inBatch ? (
                  <button
                    type="button"
                    onClick={() => remove(check)}
                    aria-label={`Remove check: ${label}`}
                    className={`shrink-0 inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-medium border border-[var(--color-ink-3)]/40 text-[var(--color-ink-2)] hover:border-[var(--color-ink-3)]/70 hover:text-[var(--color-ink)] transition-colors whitespace-nowrap ${focusRingCls}`}
                  >
                    <ButtonIcon name="remove" size={14} />
                    Remove
                  </button>
                ) : (
                  <button
                    type="button"
                    onClick={() => add(check)}
                    aria-label={`Add check: ${label}`}
                    className={`shrink-0 inline-flex items-center gap-1.5 ${btnSmallCls}`}
                  >
                    <ButtonIcon name="add" size={14} />
                    Add
                  </button>
                )}
              </li>
            );
          })}
        </ul>
      )}

      {found?.truncated && (
        <p className="text-xs text-[var(--color-ink-3)]">
          The simulation did more than was looked at: this list may be
          incomplete.
        </p>
      )}

      {/* More checks than the simulation suggests: written by hand, or by
          the assistant. */}
      <div className="flex flex-col items-start gap-2 border-t border-[var(--color-ink-3)]/15 pt-3 sm:flex-row sm:flex-wrap sm:items-center sm:gap-3">
        <button
          type="button"
          aria-expanded={manual.open}
          aria-controls={manual.controls}
          onClick={manual.onToggle}
          className={`shrink-0 px-3 py-1.5 rounded-lg text-sm font-medium border border-[var(--color-ink-3)]/40 text-[var(--color-ink-2)] hover:border-[var(--color-ink-3)]/70 hover:text-[var(--color-ink)] aria-expanded:border-[var(--color-bp-400)] aria-expanded:text-[var(--color-bp-300)] transition-colors ${focusRingCls}`}
        >
          Add assertions manually
        </button>
        <button
          type="button"
          disabled={!hint.enabled}
          onClick={suggest.onSuggest}
          className={`shrink-0 px-3 py-1.5 rounded-lg text-sm font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors ${focusRingCls}`}
        >
          <span aria-hidden>✦</span>{" "}
          {suggest.running ? "Assistant is working…" : "Suggest more assertions"}
        </button>
        <span className="min-w-0 text-xs text-[var(--color-ink-3)]">{hint.text}</span>
      </div>
    </div>
  );
}
