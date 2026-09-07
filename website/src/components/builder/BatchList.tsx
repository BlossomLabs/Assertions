import { type CommandSpan, commandSpans, isHelperLoad } from "./script-ops";

/**
 * The "Batch so far" listing: the script's commands, one row each (a
 * command spanning several lines is one row), each removable command with
 * a delete button. Auto-managed scaffolding (`set` and `load` lines,
 * garbage-collected when the commands referencing them go away) is shown
 * without one, and helper-module load lines are hidden altogether.
 */
export function BatchList({
  script,
  onRemove,
  canRemove,
}: {
  script: string;
  /** Remove the command starting at this 1-based line. */
  onRemove: (line: number) => void;
  /** Extra restriction on which commands offer a delete button (scaffolding
   *  `set`/`load` lines are always excluded). Non-removable rows render
   *  dimmed. Defaults to all commands. */
  canRemove?: (span: CommandSpan) => boolean;
}) {
  const spans = commandSpans(script);
  return (
    <div className="rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto">
      {spans.map((span) => {
        const t = span.text.trim();
        if (isHelperLoad(t)) return null;
        const scaffolding =
          (span.module ?? "std") === "std" &&
          (span.name === "set" || span.name === "load");
        const removable = !scaffolding && (canRemove?.(span) ?? true);
        return (
          <div
            key={`${span.start}-${t}`}
            className="group flex items-start gap-2 px-3 py-1 first:pt-2.5 last:pb-2.5 hover:bg-[var(--color-ink-3)]/10"
          >
            <pre
              className={`flex-1 whitespace-pre-wrap min-h-4 ${
                removable ? "" : "text-[var(--color-ink-3)]"
              }`}
            >
              {span.text}
            </pre>
            {removable && (
              <button
                type="button"
                onClick={() => onRemove(span.start)}
                title="Remove this command from the batch"
                aria-label={`Remove command: ${t.split("\n")[0]}`}
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
