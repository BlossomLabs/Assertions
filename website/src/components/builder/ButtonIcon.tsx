import type { ReactNode } from "react";

/**
 * The glyph in front of a button's label, in the button's text color.
 * Always decorative: the label says what the button does.
 */

export type ButtonIconName =
  | "add"
  | "simulate"
  | "run"
  | "download"
  | "send"
  | "stop"
  | "key"
  | "settings";

const GLYPHS: Record<ButtonIconName, ReactNode> = {
  add: <path d="M12 5v14M5 12h14" />,
  // A play button inside a dashed ring: run it, but not for real.
  simulate: (
    <>
      <circle cx="12" cy="12" r="9" strokeDasharray="2.6 3.05" />
      <path d="M10 8.5v7l5.5-3.5z" />
    </>
  ),
  // The same play button with nothing around it: this one is for real.
  run: <path d="M7.5 5v14l11-7z" />,
  download: (
    <>
      <path d="M12 4v11" />
      <path d="m7.5 11 4.5 4.5 4.5-4.5" />
      <path d="M5 19.5h14" />
    </>
  ),
  send: (
    <>
      <path d="M12 19V5.5" />
      <path d="m6 11 6-6 6 6" />
    </>
  ),
  stop: <rect x="6.5" y="6.5" width="11" height="11" rx="1.5" />,
  key: (
    <>
      <circle cx="8" cy="15" r="4" />
      <path d="m11 12 8.5-8.5" />
      <path d="m16 7 2.5 2.5" />
    </>
  ),
  settings: (
    <>
      <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" />
      <circle cx="12" cy="12" r="3" />
    </>
  ),
};

export function ButtonIcon({
  name,
  size = 16,
}: {
  name: ButtonIconName;
  /** Rendered width and height in pixels. */
  size?: number;
}) {
  return (
    <svg
      className="shrink-0"
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      {GLYPHS[name]}
    </svg>
  );
}

export default ButtonIcon;
