/**
 * The "Batch so far" listing shared by the composer and the assertion form:
 * the script rendered line by line, each removable command with a delete
 * button. Auto-managed scaffolding (`set` and `load` lines, cleaned up by
 * `removeLine` when the commands referencing them go away) is shown
 * without one.
 */
export function BatchList({
  script,
  onRemoveLine,
  canRemove,
  hideLine,
}: {
  script: string;
  onRemoveLine: (index: number) => void;
  /** Extra restriction on which lines offer a delete button (scaffolding
   *  `set`/`load` lines are always excluded). Non-removable lines render
   *  dimmed. Defaults to all commands. */
  canRemove?: (line: string) => boolean;
  /** Lines to omit from the listing entirely (indices passed to
   *  `onRemoveLine` still refer to the full script). */
  hideLine?: (line: string) => boolean;
}) {
  const lines = script.split("\n");
  return (
    <div className="rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto">
      {lines.map((line, i) => {
        const t = line.trim();
        if (hideLine?.(t)) return null;
        const removable =
          t !== "" &&
          !t.startsWith("set ") &&
          !t.startsWith("load ") &&
          (canRemove?.(t) ?? true);
        return (
          <div
            key={`${i}-${line}`}
            className="group flex items-start gap-2 px-3 py-1 first:pt-2.5 last:pb-2.5 hover:bg-[var(--color-ink-3)]/10"
          >
            <pre
              className={`flex-1 whitespace-pre-wrap min-h-4 ${
                removable ? "" : "text-[var(--color-ink-3)]"
              }`}
            >
              {line}
            </pre>
            {removable && (
              <button
                type="button"
                onClick={() => onRemoveLine(i)}
                title="Remove this line from the batch"
                aria-label={`Remove line: ${line.trim()}`}
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
