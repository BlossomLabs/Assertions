import { useId } from "react";

import type { EyeState } from "./timeline";

/** The ring's color per state. */
const TONE: Record<EyeState, string> = {
  asleep: "text-[var(--color-ink-3)]",
  stale: "text-amber-700 dark:text-amber-300",
  running: "text-[var(--color-bp-400)]",
  pass: "text-[var(--color-ok)]",
  fail: "text-[var(--color-err)]",
};

const PLAY = "M10 8.5v7l5.5-3.5z";

/**
 * The status of a simulation, drawn with the simulate button's own mark: a
 * ring that stays dashed until the batch as it is now has passed a
 * simulation, and only then turns solid. Empty with nothing to simulate, a
 * play triangle while a run is due or under way (the ring turns), a tick on
 * a pass, the play triangle with an exclamation mark at the ring's corner on
 * a failure (a cross reads as "close"). Decorative unless given a `label`, which
 * is also what hovering it shows.
 */
export function SimRing({
  state,
  size = 22,
  className = "",
  label,
}: {
  state: EyeState;
  /** Rendered width and height in pixels. */
  size?: number;
  className?: string;
  label?: string;
}) {
  const id = useId();
  return (
    <span
      className={`shrink-0 inline-flex ${TONE[state]} ${className}`}
      data-state={state}
      {...(label
        ? { role: "img", "aria-label": label, title: label }
        : { "aria-hidden": true })}
    >
      <svg
        width={size}
        height={size}
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={size > 30 ? 1.6 : 2}
        strokeLinecap="round"
        strokeLinejoin="round"
        focusable="false"
      >
        <circle
          cx="12"
          cy="12"
          r="9"
          strokeDasharray={state === "pass" ? undefined : "2.6 3.05"}
          mask={state === "fail" ? `url(#${id}-cut)` : undefined}
          className={
            state === "running"
              ? "origin-center [transform-box:fill-box] animate-spin [animation-duration:2.4s] motion-reduce:animate-none"
              : undefined
          }
        />
        {state === "stale" && <path d={PLAY} opacity="0.55" />}
        {state === "running" && <path d={PLAY} />}
        {state === "pass" && <path d="m8 12.3 2.7 2.7 5.3-6" />}
        {state === "fail" && (
          <>
            {/* The corner the badge sits in is cut out of the ring, so the
                two stay apart on any background. */}
            <mask id={`${id}-cut`} maskUnits="userSpaceOnUse">
              <rect width="24" height="24" fill="#fff" />
              <circle cx="18.5" cy="18.5" r="5" fill="#000" stroke="none" />
            </mask>
            <path d="M9.5 7.5v9l7-4.5z" />
            <path d="M18.5 16v2.6M18.5 21v.1" strokeWidth="1.8" />
          </>
        )}
      </svg>
    </span>
  );
}

export default SimRing;
