/** Shared Tailwind classes for the builder's controls. */

/** Visible keyboard focus for buttons and card selectors. */
export const focusRingCls =
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-bp-400)]/70 focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--color-surface-2)]";

/** Segmented pill toggle (placement, block field, editor tabs). */
export const segBtnCls = (active: boolean) =>
  `px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${focusRingCls} ${
    active
      ? "bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)]"
      : "text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
  }`;

/** Bordered selectable tile/card (evaluation method, check kinds). */
export const tileBtnCls = (active: boolean) =>
  `rounded-lg border text-left transition-all ${focusRingCls} ${
    active
      ? "border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 text-[var(--color-bp-300)]"
      : "border-[var(--color-ink-3)]/25 text-[var(--color-ink-2)] hover:border-[var(--color-bp-400)]/50"
  }`;

export const btnPrimaryCls = `px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors ${focusRingCls}`;

export const btnSmallCls = `px-2.5 py-1.5 rounded-lg text-xs font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors whitespace-nowrap ${focusRingCls}`;

export const labelCls = "block text-sm text-[var(--color-ink-2)] mb-1.5";

export const smallLabelCls =
  "block text-xs font-mono text-[var(--color-ink-3)] mb-1";

/** Compact select used for node kinds and operators inside the tree. */
export const chipSelectCls =
  "px-1.5 py-1 rounded-md bg-transparent border border-[var(--color-ink-3)]/25 text-xs font-mono text-[var(--color-ink-3)] hover:border-[var(--color-bp-400)]/50 focus:border-[var(--color-bp-400)] focus:outline-none cursor-pointer";
