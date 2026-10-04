import type { ReactNode } from "react";

import aragon from "../../assets/executors/aragon.svg?url";
import safe from "../../assets/executors/safe.svg?url";

/**
 * Icons for the accounts a batch can execute from, all in the surrounding
 * text color. Safe and Aragon use the shape of their own logos; a wallet
 * and a Governor are not anyone's brand, so they get line glyphs.
 *
 * Always decorative: the label sits next to it.
 */

export type ExecutorKind = "eoa" | "safe" | "governor" | "aragonosx";

interface IconProps {
  /** Rendered width and height in pixels. */
  size?: number;
  className?: string;
}

/** Logo shapes, painted in the text color through a mask. */
const SHAPES: Partial<Record<ExecutorKind, string>> = {
  safe,
  aragonosx: aragon,
};

function Glyph({
  size = 16,
  className = "",
  children,
}: IconProps & { children: ReactNode }) {
  return (
    <svg
      className={`shrink-0 ${className}`}
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      {children}
    </svg>
  );
}

export function WalletIcon(props: IconProps) {
  return (
    <Glyph {...props}>
      <path d="M4 7.5V17a2.5 2.5 0 0 0 2.5 2.5H19a1 1 0 0 0 1-1v-9a1 1 0 0 0-1-1H6.25A2.25 2.25 0 0 1 4 6.25v0A2.25 2.25 0 0 1 6.25 4H17" />
      <circle cx="16" cy="14" r="1" fill="currentColor" stroke="none" />
    </Glyph>
  );
}

function GovernorIcon(props: IconProps) {
  return (
    <Glyph {...props}>
      <path d="M3 9.5 12 4l9 5.5" />
      <path d="M5 10v7M9.67 10v7M14.33 10v7M19 10v7" />
      <path d="M3 20h18" />
    </Glyph>
  );
}

export function ExecutorIcon({
  kind,
  size = 16,
  className = "",
}: IconProps & { kind: ExecutorKind }) {
  const shape = SHAPES[kind];
  if (shape) {
    // Solid logos look larger than line glyphs of the same box, so they are
    // drawn smaller inside it; the box stays the same for alignment.
    const mask = `url("${shape}") center / 75% 75% no-repeat`;
    return (
      <span
        className={`shrink-0 inline-block bg-current ${className}`}
        style={{ width: size, height: size, mask, WebkitMask: mask }}
        aria-hidden="true"
      />
    );
  }
  return kind === "governor" ? (
    <GovernorIcon size={size} className={className} />
  ) : (
    <WalletIcon size={size} className={className} />
  );
}

export default ExecutorIcon;
