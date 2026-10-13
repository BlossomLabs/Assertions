import { useState } from "react";

import { AddressLink } from "./AddressLink";
import { ButtonIcon } from "./ButtonIcon";
import type { ContextKind } from "./context";
import type { SimKey, SimulationState } from "./simulation";
import {
  type SuggestedCheck,
  type SuggestionSource,
  amountWarning,
  descriptionParts,
  displayDescription,
  sentenceView,
  suggestedChecks,
  suggestionSource,
  suggestionVariables,
} from "./suggested-checks";
import { btnSmallCls, focusRingCls, noBreakCls } from "./ui";
import type { useScriptState } from "./useScriptState";

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
function Sentence({ check, chainId }: { check: SuggestedCheck; chainId: number }) {
  const view = sentenceView(check, chainId);
  return (
    <p className="text-sm text-[var(--color-ink-2)]">
      {view
        ? view.map((part, i) =>
            typeof part === "string" ? part : <AddressLink key={i} link={part} />,
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
    </p>
  );
}

/**
 * The checks the last simulation of the protected batch suggests for the
 * batch as it is now. Each row says what the check asserts as a sentence,
 * where it comes from, and adds it on a click; the EVML it adds is one
 * click away. Nothing is added without a click. Which ones are listed,
 * and until when, is `suggestedChecks`' call. Renders nothing when there
 * is nothing to offer.
 */
export function SuggestedChecks({
  state,
  simKey,
  context,
  chainId,
  scriptState,
}: {
  /** The protected-batch simulation. */
  state: SimulationState;
  /** The batch as it is now. */
  simKey: SimKey;
  /** Who executes: later for anything but a wallet. */
  context: ContextKind;
  /** The chain the batch targets: whose explorer the rows link to. */
  chainId: number;
  /** The script a check is added to. */
  scriptState: Pick<ReturnType<typeof useScriptState>, "addLine" | "previewLine">;
}) {
  // The rows whose code is shown, by their line.
  const [open, setOpen] = useState<ReadonlySet<string>>(new Set());
  const found = suggestedChecks(state, simKey);
  if (!found) return null;
  const { checks, truncated, added } = found;

  /** Add a check after the actions, through the form's own path: under
   *  the script's variable names, with the `set` lines it still needs and
   *  the loads derived. Each is bound to the script as it is when its turn
   *  comes, so that several added in a row see each other's variables. */
  const add = (check: SuggestedCheck) =>
    void scriptState.addLine(check.line, "post", {
      vars: suggestionVariables(check),
    });

  const addedNote = added && (
    <p className="text-xs text-[var(--color-bp-300)]">
      Checks added. Simulate the protected batch again to confirm they hold.
    </p>
  );
  if (checks.length === 0 && !truncated) return addedNote || null;

  return (
    <div
      data-suggested-checks
      className="rounded-xl border border-[var(--color-ink-3)]/20 p-4 space-y-3"
    >
      <div className="flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <h4 className="text-sm font-semibold text-[var(--color-ink)]">
            Suggested checks
          </h4>
          <p className="text-xs text-[var(--color-ink-2)]">
            Drawn from what the simulation did: read each one before adding
            it.
          </p>
        </div>
        {checks.length > 1 && (
          <button
            type="button"
            onClick={() => {
              for (const check of checks) add(check);
            }}
            className={`shrink-0 inline-flex items-center gap-1.5 ${btnSmallCls}`}
          >
            <ButtonIcon name="add" size={14} />
            Add all
          </button>
        )}
      </div>

      {checks.length > 0 && (
        <ul className="space-y-2">
          {checks.map((check) => {
            const warning = amountWarning(check, context);
            const source = suggestionSource(check, chainId);
            const shown = open.has(check.line);
            const code = shown
              ? scriptState.previewLine(
                  check.line,
                  suggestionVariables(check),
                  simKey.script,
                )
              : null;
            return (
              <li
                key={check.line}
                className="flex items-start gap-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 px-3 py-2.5"
              >
                <div className="min-w-0 flex-1 space-y-1.5">
                  <Sentence check={check} chainId={chainId} />
                  {source && <SourceLine source={source} />}
                  {warning && (
                    <p className="text-xs text-amber-800 dark:text-amber-200">
                      {warning}
                    </p>
                  )}
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
                    className={`block rounded text-xs text-[var(--color-ink-2)] underline underline-offset-2 hover:text-[var(--color-bp-300)] ${focusRingCls}`}
                  >
                    {shown ? "Hide code" : "Show code"}
                  </button>
                  {code && (
                    // What adding it puts in the batch: the variables it
                    // still needs, then its line.
                    <pre className="font-mono text-xs whitespace-pre-wrap wrap-anywhere">
                      <code>{[...code.sets, code.line].join("\n")}</code>
                    </pre>
                  )}
                </div>
                <button
                  type="button"
                  onClick={() => add(check)}
                  aria-label={`Add check: ${displayDescription(check.description)}`}
                  className={`shrink-0 inline-flex items-center gap-1.5 ${btnSmallCls}`}
                >
                  <ButtonIcon name="add" size={14} />
                  Add
                </button>
              </li>
            );
          })}
        </ul>
      )}

      {truncated && (
        <p className="text-xs text-[var(--color-ink-3)]">
          The simulation did more than was looked at: this list may be
          incomplete.
        </p>
      )}
      {addedNote}
    </div>
  );
}
