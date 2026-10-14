import { useState } from "react";

import { AddressLink } from "./AddressLink";
import { ButtonIcon } from "./ButtonIcon";
import {
  type CommandSpan,
  splitComment,
  unmarkSuggested,
  withoutComment,
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
/** Auto-managed lines: `set` and `load`, removed with the last command
 *  that needs them, never from a bin. */
const isScaffolding = (span: CommandSpan): boolean =>
  (span.module ?? "std") === "std" && (span.name === "set" || span.name === "load");

function VariableName({
  name,
  onRename,
  dim = false,
}: {
  name: string;
  onRename?: (from: string, to: string) => { error?: string };
  /** Not used by the commands this listing is about: drawn dimmed. */
  dim?: boolean;
}) {
  const [draft, setDraft] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const ink = dim ? "text-[var(--color-ink-3)]" : "text-[var(--color-ink)]";
  if (!onRename) return <span className={ink}>${name}</span>;
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
        className={`rounded ${ink} underline decoration-dotted underline-offset-2 hover:text-[var(--color-bp-300)] ${focusRingCls}`}
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
 * Variables pinned to an address are listed first, as the script writes
 * them (`set $usdc 0xA0b8…eB48`), dimmed with the rest of the scaffolding:
 * the address shortened and linked to the explorer, the name changeable.
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
  // This listing's own commands (the actions in step 1, the checks in step
  // 2): a variable they use is drawn in full, any other one dimmed.
  const own = spans.filter((span) => !isScaffolding(span) && (canRemove?.(span) ?? true));
  const usedHere = (name: string) => {
    const token = new RegExp(`\\$${name}(?![A-Za-z0-9_])`);
    return own.some((span) => token.test(withoutComment(span.text)));
  };
  return (
    <div className="rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto">
      {addresses.length > 0 && (
        // Written as the script writes them, dimmed like the rest of the
        // scaffolding: the name can be changed, the address is linked.
        <div role="group" aria-label="Addresses" className="pt-1.5">
          {addresses.map(({ name, address }) => (
            <div
              key={name}
              data-used={usedHere(name) || undefined}
              className={`px-3 py-1 first:pt-1 text-[var(--color-ink-3)] ${
                usedHere(name)
                  ? "[&_a]:text-[var(--color-ink-2)]"
                  : "[&_a]:text-[var(--color-ink-3)]"
              }`}
            >
              <span className={noBreakCls}>
                set <VariableName name={name} onRename={onRename} dim={!usedHere(name)} />{" "}
                <AddressLink link={addressLink(chainId ?? -1, address)} />
              </span>
            </div>
          ))}
        </div>
      )}
      {spans.map((span) => {
        const t = span.text.trim();
        if (isHelperLoad(t) || addressVariable(span)) return null;
        const scaffolding = isScaffolding(span);
        const removable = !scaffolding && (canRemove?.(span) ?? true);
        const edit = !scaffolding && onEdit ? (editable?.(span) ?? null) : null;
        // A check is named by its code and the comment it has, less the
        // mark a suggested one carries.
        const first = unmarkSuggested(t).split("\n")[0];
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
              {span.text.split("\n").some((line) => splitComment(line).comment)
                ? span.text.split("\n").map((line, i) => {
                    // Comments (a unit, the `# suggested` mark) are said,
                    // dimmed.
                    const { code, comment } = splitComment(line);
                    return (
                      <span key={i}>
                        {i > 0 && "\n"}
                        {code}
                        {comment && (
                          <span className="text-[var(--color-ink-3)] whitespace-nowrap">{comment}</span>
                        )}
                      </span>
                    );
                  })
                : span.text}
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
                <ButtonIcon name="delete" size={13} />
              </button>
            )}
          </div>
        );
      })}
    </div>
  );
}
