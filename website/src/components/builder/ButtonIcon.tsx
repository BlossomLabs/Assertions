import {
  ArrowUp,
  Download,
  Eye,
  EyeOff,
  Info,
  Key,
  type LucideIcon,
  Minus,
  Pencil,
  Pin,
  PinOff,
  Play,
  Plus,
  Settings,
  Square,
  Trash2,
} from "lucide-react";

/**
 * The glyph in front of a button's label, in the button's text color.
 * Always decorative: the label says what the button does. The icons are
 * Lucide's (lucide.dev), one set for the whole site; the simulate glyph is
 * the site's own, drawn on the same grid.
 */

export type ButtonIconName =
  | "add"
  | "simulate"
  | "run"
  | "download"
  | "send"
  | "stop"
  | "key"
  | "settings"
  | "edit"
  | "remove"
  | "delete"
  | "keep"
  | "unkeep"
  | "show"
  | "hide"
  | "info";

const LUCIDE: Record<Exclude<ButtonIconName, "simulate">, LucideIcon> = {
  add: Plus,
  // The play button on its own: this one is for real.
  run: Play,
  download: Download,
  send: ArrowUp,
  stop: Square,
  // A pencil: change what is there.
  edit: Pencil,
  key: Key,
  settings: Settings,
  // A minus: take it out of a list it can come back to.
  remove: Minus,
  // A bin: delete it.
  delete: Trash2,
  // A pushpin: hold it where it is; struck through, let it go.
  keep: Pin,
  unkeep: PinOff,
  // An eye: show what is folded away; struck through, fold it.
  show: Eye,
  hide: EyeOff,
  // More about it.
  info: Info,
};

export function ButtonIcon({
  name,
  size = 16,
}: {
  name: ButtonIconName;
  /** Rendered width and height in pixels. */
  size?: number;
}) {
  if (name === "simulate")
    return (
      // A play button inside a dashed ring: run it, but not for real.
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
        <circle cx="12" cy="12" r="9" strokeDasharray="2.6 3.05" />
        <path d="M10 8.5v7l5.5-3.5z" />
      </svg>
    );
  const Icon = LUCIDE[name];
  return (
    <Icon
      className="shrink-0"
      size={size}
      strokeWidth={2}
      aria-hidden="true"
      focusable="false"
    />
  );
}

export default ButtonIcon;
