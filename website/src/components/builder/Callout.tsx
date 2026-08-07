import type { ReactNode } from "react";

const TONES = {
  warn: "border-amber-500/40 bg-amber-500/10 text-amber-800 dark:border-amber-400/30 dark:bg-amber-400/10 dark:text-amber-200",
  error:
    "border-red-500/40 bg-red-500/10 text-red-700 dark:border-red-400/30 dark:bg-red-400/10 dark:text-red-300",
} as const;

function WarningIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="size-4 shrink-0"
      aria-hidden
    >
      <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
      <path d="M12 9v4" />
      <path d="M12 17h.01" />
    </svg>
  );
}

function ErrorIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="size-4 shrink-0"
      aria-hidden
    >
      <circle cx="12" cy="12" r="10" />
      <path d="m15 9-6 6" />
      <path d="m9 9 6 6" />
    </svg>
  );
}

/** Inline warning/error box: icon, tinted border and background, and the
 *  padding/margin bare colored text lines lack. */
export function Callout({
  tone,
  children,
}: {
  tone: keyof typeof TONES;
  children: ReactNode;
}) {
  return (
    <div
      className={`mt-3 flex items-start gap-2.5 rounded-lg border px-3.5 py-3 text-xs leading-relaxed ${TONES[tone]}`}
    >
      <span className="mt-px">
        {tone === "warn" ? <WarningIcon /> : <ErrorIcon />}
      </span>
      <div className="min-w-0 space-y-1.5">{children}</div>
    </div>
  );
}
