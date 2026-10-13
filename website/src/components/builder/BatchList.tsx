import { useState } from "react";

import { AddressLink } from "./AddressLink";
import { ButtonIcon } from "./ButtonIcon";
import {
  type CommandSpan,
  addressVariable,
  commandSpans,
  isHelperLoad,
} from "./script-ops";
import { addressLink } from "./suggested-checks";
import { focusRingCls, noBreakCls } from "./ui";

/** A variable's name in the "Addresses" block. With `onRename` it is a
 *  button: a click turns it into a field, Enter renames the variable in
 *  the whole script, Escape (or leaving the field) keeps the name. A name
 *  that is refused stays in the field with the reason beside it. */
function VariableName({
  name,
  onRename,
}: {
  name: string;
  onRename?: (from: string, to: string) => { error?: string };
}) {
  const [draft, setDraft] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  if (!onRename) return <span className="text-[var(--color-ink)]">${name}</span>;
  if (draft === null)
    return (
      <button
        type="button"
        onClick={() => {
          setDraft(name);
          setError(null);
        }}
        title="Rename this variable"
        aria-label={`Rename $${name}`}
        className={`rounded text-[var(--color-ink)] underline decoration-dotted underline-offset-2 hover:text-[var(--color-bp-300)] ${focusRingCls}`}
      >
        ${name}
      </button>
    );
  const close = () => {
    setDraft(null);
    setError(null);
  };
  return (
    <>
      <span className="text-[var(--color-ink)]">$</span>
      <input
        autoFocus
        value={draft}
        onChange={(e) => {
          setDraft(e.target.value);
          setError(null);
        }}
        onFocus={(e) => e.target.select()}
        onBlur={close}
        onKeyDown={(e) => {
          if (e.key === "Escape") close();
          if (e.key !== "Enter") return;
          const result = onRename(name, draft);
          if (result.error) setError(result.error);
          else close();
        }}
        aria-label={`New name for $${name}`}
        aria-invalid={error !== null}
        spellCheck={false}
        autoCapitalize="off"
        autoCorrect="off"
        size={Math.max(draft.length, 4)}
        className="max-w-[10rem] px-1 -my-0.5 rounded bg-[var(--color-surface-2)] border border-[var(--color-ink-3)]/30 focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-xs text-[var(--color-ink)]"
      />
      {error && (
        <span role="alert" className="whitespace-normal text-[var(--color-err)]">
          {" "}
          {error}
        </span>
      )}
    </>
  );
}

/**
 * The "Batch so far" listing: the script's commands, one row each (a
 * command spanning several lines is one row), each removable command with
 * a delete button, and each action with an edit button where the caller
 * can edit it. Auto-managed scaffolding (`set` and `load` lines,
 * garbage-collected when the commands referencing them go away) is shown
 * without one, and helper-module load lines are hidden altogether.
 * Variables pinned to an address (`set $usdc 0x…`) are not commands to
 * read through: they are listed once, above, as "Addresses", each name
 * with its address shortened and linked to the explorer; a name can be
 * changed there.
 */
export function BatchList({
  script,
  onRemove,
  canRemove,
  highlight,
  chainId,
  onRename,
  editable,
  onEdit,
}: {
  script: string;
  /** The chain the batch targets: whose explorer the addresses link to.
   *  Without it they are shown unlinked. */
  chainId?: number;
  /** Remove the command starting at this 1-based line. */
  onRemove: (line: number) => void;
  /** Extra restriction on which commands offer a delete button (scaffolding
   *  `set`/`load` lines are always excluded). Non-removable rows render
   *  dimmed. Defaults to all commands. */
  canRemove?: (span: CommandSpan) => boolean;
  /** 1-based first line of a command to point out. */
  highlight?: number | null;
  /** Rename a variable everywhere (names without the `$`); the reason
   *  when the name is refused. Without it the names are plain text. */
  onRename?: (from: string, to: string) => { error?: string };
  /** Where a command can be edited: in the contract form, only in the
   *  EVML editor (the form does not model it), or nowhere from here. */
  editable?: (span: CommandSpan) => "form" | "editor" | null;
  /** Edit the command starting at this 1-based line, there. */
  onEdit?: (line: number, where: "form" | "editor") => void;
}) {
  const spans = commandSpans(script);
  const addresses = spans.flatMap((span) => addressVariable(span) ?? []);
  return (
    <div className="rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto">
      {addresses.length > 0 && (
        <div
          role="group"
          aria-label="Addresses"
          className="flex flex-wrap items-baseline gap-x-4 gap-y-1 px-3 py-2 border-b border-[var(--color-ink-3)]/20 text-[var(--color-ink-2)]"
        >
          <span
            aria-hidden
            className="text-[0.625rem] font-semibold uppercase tracking-widest text-[var(--color-ink-3)]"
          >
            Addresses
          </span>
          {addresses.map(({ name, address }) => (
            <span key={name} className={noBreakCls}>
              <VariableName name={name} onRename={onRename} />{" "}
              <AddressLink link={addressLink(chainId ?? -1, address)} />
            </span>
          ))}
        </div>
      )}
      {spans.map((span) => {
        const t = span.text.trim();
        if (isHelperLoad(t) || addressVariable(span)) return null;
        const scaffolding =
          (span.module ?? "std") === "std" &&
          (span.name === "set" || span.name === "load");
        const removable = !scaffolding && (canRemove?.(span) ?? true);
        const edit = !scaffolding && onEdit ? (editable?.(span) ?? null) : null;
        const first = t.split("\n")[0];
        return (
          <div
            key={`${span.start}-${t}`}
            className={`group flex items-start gap-2 px-3 py-1 first:pt-2.5 last:pb-2.5 ${
              highlight === span.start
                ? "bg-[var(--color-bp-500)]/15"
                : "hover:bg-[var(--color-ink-3)]/10"
            }`}
          >
            <pre
              className={`flex-1 min-w-0 whitespace-pre-wrap wrap-anywhere min-h-4 ${
                removable ? "" : "text-[var(--color-ink-3)]"
              }`}
            >
              {span.text}
            </pre>
            {edit && (
              <button
                type="button"
                onClick={() => onEdit?.(span.start, edit)}
                title={
                  edit === "form"
                    ? "Edit this action"
                    : "Edit in the EVML editor: the form cannot show this action"
                }
                aria-label={
                  edit === "form"
                    ? `Edit action: ${first}`
                    : `Edit in the EVML editor: ${first}`
                }
                className={`shrink-0 h-5 -my-0.5 inline-flex items-center justify-center gap-1 rounded-full text-[var(--color-ink-2)] opacity-60 group-hover:opacity-100 hover:bg-[var(--color-ink-3)]/15 transition-opacity ${
                  edit === "form" ? "w-5" : "px-1.5 font-sans"
                } ${focusRingCls}`}
              >
                <ButtonIcon name="edit" size={13} />
                {edit === "editor" && <span>EVML editor</span>}
              </button>
            )}
            {removable && (
              <button
                type="button"
                onClick={() => onRemove(span.start)}
                title="Remove this command from the batch"
                aria-label={`Remove command: ${first}`}
                className="shrink-0 w-5 h-5 -my-0.5 flex items-center justify-center rounded-full text-[var(--color-err)] opacity-50 group-hover:opacity-100 hover:bg-[var(--color-err)]/10 transition-opacity"
              >
                <svg
                  width="13"
                  height="13"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  aria-hidden="true"
                >
                  <path d="M3 6h18" />
                  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" />
                  <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                  <path d="M10 11v6" />
                  <path d="M14 11v6" />
                </svg>
              </button>
            )}
          </div>
        );
      })}
    </div>
  );
}
