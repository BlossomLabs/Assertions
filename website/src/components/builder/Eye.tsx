import "./eye.css";

import { type CSSProperties, useId } from "react";

import type { EyeState } from "./timeline";

/** How far the lids open, 0 (shut) to 1, and the pupil's radius. */
const POSES: Record<EyeState, { open: number; pupil: number }> = {
  asleep: { open: 0, pupil: 15 },
  stale: { open: 0.42, pupil: 15 },
  running: { open: 0.85, pupil: 15 },
  pass: { open: 1, pupil: 15 },
  fail: { open: 1, pupil: 8 },
};

/** Geometry goes out both as an attribute and as a CSS property: the
 *  property is what transitions, the attribute is what browsers that
 *  cannot style SVG geometry draw. */
const d = (path: string) => ({ d: path, style: { d: `path("${path}")` } as CSSProperties });

/**
 * The status eye: shut with nothing to watch, drooping while unverified,
 * scanning during a simulation, open on a pass and red on a failure.
 * Decorative unless given a `label`, which is also what hovering it shows.
 * `bold` thickens the lines for the
 * small sizes used inside timeline nodes.
 */
export function Eye({
  state,
  className = "w-14",
  bold = false,
  label,
}: {
  state: EyeState;
  /** Sizing; the eye is as wide as its box. */
  className?: string;
  bold?: boolean;
  label?: string;
}) {
  const id = useId();
  const { pupil } = POSES[state];
  // A drooping lid closes to a sliver at node size; keep it readable.
  const open = bold && state === "stale" ? 0.7 : POSES[state].open;
  const upper = 40 - 135 * open;
  const lower = 40 + 25 * open;
  const opening = `M-125 0 Q0 ${upper} 125 0 Q0 ${lower} -125 0 Z`;

  return (
    <span
      className={`builder-eye ${className}`}
      data-state={state}
      {...(label
        ? { role: "img", "aria-label": label, title: label }
        : { "aria-hidden": true })}
    >
      <svg viewBox="-160 -112 320 200">
        <defs>
          <clipPath id={`${id}-opening`}>
            <path {...d(opening)} />
          </clipPath>
          <radialGradient id={`${id}-globe`} cx="42%" cy="34%" r="75%">
            <stop offset="0" stopColor="#ffffff" />
            <stop offset="0.55" stopColor="var(--color-bp-50)" />
            <stop offset="1" stopColor="var(--color-bp-300)" />
          </radialGradient>
          <radialGradient id={`${id}-iris`}>
            <stop offset="0.35" stopColor="var(--eye-iris)" />
            <stop offset="1" stopColor="var(--eye-iris-edge)" />
          </radialGradient>
        </defs>

        {!bold && (
          <path
            d="M-138 -4 Q0 -121 138 -4"
            fill="none"
            stroke="var(--eye-fold)"
            strokeWidth="2.8"
            strokeLinecap="round"
            opacity={0.25 + 0.75 * open}
          />
        )}

        <g clipPath={`url(#${id}-opening)`}>
          <rect x="-160" y="-112" width="320" height="200" fill={`url(#${id}-globe)`} />
          <g className="builder-eye-iris">
            <circle r="34" fill={`url(#${id}-iris)`} />
            <circle r="34" fill="none" stroke="var(--color-bp-950)" strokeWidth="3" />
            <circle r={pupil} style={{ r: pupil } as CSSProperties} fill="var(--color-bp-950)" />
          </g>
          <ellipse
            cx="-11"
            cy="-13"
            rx="7"
            ry="5"
            fill="#ffffff"
            opacity="0.85"
            transform="rotate(-30 -11 -13)"
          />
        </g>

        <path
          {...d(opening)}
          fill="none"
          stroke="var(--eye-rim)"
          strokeWidth={bold ? 7 : 3}
          strokeLinejoin="round"
        />
        <path
          {...d(`M-125 0 Q0 ${upper} 125 0`)}
          fill="none"
          stroke="var(--color-ink)"
          strokeWidth={bold ? 11 : 7}
          strokeLinecap="round"
        />
      </svg>
    </span>
  );
}
