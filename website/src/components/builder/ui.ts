/** Shared Tailwind classes for the builder's controls. */

export const btnPrimaryCls =
  "px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors";

export const btnSmallCls =
  "px-2.5 py-1.5 rounded-lg text-xs font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors whitespace-nowrap";

export const labelCls = "block text-sm text-[var(--color-ink-2)] mb-1.5";

export const smallLabelCls =
  "block text-xs font-mono text-[var(--color-ink-3)] mb-1";

/** Compact select used for node kinds and operators inside the tree. */
export const chipSelectCls =
  "px-1.5 py-1 rounded-md bg-transparent border border-[var(--color-ink-3)]/25 text-xs font-mono text-[var(--color-ink-3)] hover:border-[var(--color-bp-400)]/50 focus:border-[var(--color-bp-400)] focus:outline-none cursor-pointer";
