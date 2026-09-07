import {
  type KeyboardEvent as ReactKeyboardEvent,
  type ReactNode,
  useCallback,
  useEffect,
  useId,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { createPortal } from "react-dom";

/**
 * The site's dropdown: a styled trigger that opens a floating listbox,
 * replacing native <select>s so every picker (the homepage's encoding
 * switch, the builder's forms and expression tree) shares one look.
 *
 * Fully keyboard operable (arrows, Home/End, Enter, Escape, type-ahead);
 * the menu renders in a portal with fixed positioning so overflow-clipped
 * containers never cut it off, flipping upward when the viewport runs out.
 *
 * Controlled through `value` + `onChange`, or uncontrolled through
 * `defaultValue`. Either way a bubbling `ui-select-change` DOM event
 * (`detail: { name, value }`) fires on the root so non-React code (Astro
 * component scripts) can listen too.
 */

export interface SelectOption<V extends string = string> {
  value: V;
  label: string;
  /** Tooltip on the option. */
  description?: string;
  /** Leading icon, shown in the menu and beside the selected label. */
  icon?: ReactNode;
  disabled?: boolean;
}

export interface SelectGroup<V extends string = string> {
  /** Group heading (omit for an unlabeled run of options). */
  label?: string;
  options: SelectOption<V>[];
}

export type SelectItem<V extends string = string> =
  | SelectOption<V>
  | SelectGroup<V>;

export type SelectVariant = "form" | "chip" | "pill";

export interface SelectProps<V extends string = string> {
  options: SelectItem<V>[];
  value?: V;
  defaultValue?: V;
  onChange?: (value: V) => void;
  /** Shown when no option matches the value (e.g. an empty value). */
  placeholder?: string;
  /** form: full-width input look; chip: compact inline tag; pill: accent capsule. */
  variant?: SelectVariant;
  /** Which trigger edge the menu aligns to. */
  align?: "left" | "right";
  /** Reported in the `ui-select-change` DOM event. */
  name?: string;
  id?: string;
  title?: string;
  "aria-label"?: string;
  disabled?: boolean;
  className?: string;
}

const isGroup = <V extends string>(item: SelectItem<V>): item is SelectGroup<V> =>
  "options" in item;

const FOCUS_RING =
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-bp-400)]/70 focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--color-surface-2)]";

const TRIGGER: Record<SelectVariant, string> = {
  form:
    "w-full gap-2 px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 text-sm text-[var(--color-ink)] hover:border-[var(--color-ink-3)]/50 aria-expanded:border-[var(--color-bp-400)]",
  chip:
    "gap-1.5 px-1.5 py-1 rounded-md bg-transparent border border-[var(--color-ink-3)]/25 text-xs text-[var(--color-ink-3)] hover:border-[var(--color-bp-400)]/50 hover:text-[var(--color-ink-2)] aria-expanded:border-[var(--color-bp-400)] aria-expanded:text-[var(--color-ink-2)]",
  pill:
    "gap-1.5 px-2.5 py-[5px] rounded-full border border-[var(--color-bp-400)]/40 bg-[var(--color-bp-500)]/8 text-[11px] text-[var(--color-bp-400)] hover:border-[var(--color-bp-400)]/70 hover:bg-[var(--color-bp-500)]/15",
};

const MENU_TEXT: Record<SelectVariant, string> = {
  form: "text-sm",
  chip: "text-xs",
  pill: "text-[11px]",
};

const CHEVRON_SIZE: Record<SelectVariant, number> = {
  form: 14,
  chip: 11,
  pill: 12,
};

export function Select<V extends string = string>({
  options: items,
  value,
  defaultValue,
  onChange,
  placeholder = "Select…",
  variant = "form",
  align = "left",
  name,
  id,
  title,
  "aria-label": ariaLabel,
  disabled = false,
  className = "",
}: SelectProps<V>) {
  const reactId = useId();
  const listId = `${reactId}-list`;
  const rootRef = useRef<HTMLSpanElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  const [inner, setInner] = useState<V | undefined>(defaultValue);
  const current = value !== undefined ? value : inner;

  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(-1);
  const [pos, setPos] = useState<{ top: number; left: number } | null>(null);
  const typeahead = useRef({ text: "", at: 0 });

  const flat = useMemo(
    () => items.flatMap((item) => (isGroup(item) ? item.options : [item])),
    [items],
  );
  const selected = flat.find((o) => o.value === current);

  const close = useCallback(() => {
    setOpen(false);
    setPos(null);
  }, []);

  const openMenu = useCallback(() => {
    if (disabled) return;
    const idx = flat.findIndex((o) => o.value === current && !o.disabled);
    setActive(idx >= 0 ? idx : flat.findIndex((o) => !o.disabled));
    setOpen(true);
  }, [disabled, flat, current]);

  const choose = useCallback(
    (next: V) => {
      if (value === undefined) setInner(next);
      onChange?.(next);
      rootRef.current?.dispatchEvent(
        new CustomEvent("ui-select-change", {
          bubbles: true,
          detail: { name, value: next },
        }),
      );
      close();
    },
    [value, onChange, name, close],
  );

  // Place the floating menu against the trigger, flipping upward when the
  // viewport below runs out; re-run on scroll/resize while open.
  const place = useCallback(() => {
    const t = triggerRef.current;
    const m = menuRef.current;
    if (!t || !m) return;
    const r = t.getBoundingClientRect();
    if (variant === "form") m.style.minWidth = `${r.width}px`;
    const gap = 6;
    const mh = m.offsetHeight;
    const mw = m.offsetWidth;
    const below = window.innerHeight - r.bottom - gap;
    const up = mh > below && r.top - gap > below;
    const top = up ? Math.max(8, r.top - gap - mh) : r.bottom + gap;
    let left = align === "right" ? r.right - mw : r.left;
    left = Math.max(8, Math.min(left, window.innerWidth - mw - 8));
    setPos({ top, left });
  }, [align, variant]);

  useLayoutEffect(() => {
    if (!open) return;
    place();
    window.addEventListener("resize", place);
    window.addEventListener("scroll", place, true);
    return () => {
      window.removeEventListener("resize", place);
      window.removeEventListener("scroll", place, true);
    };
  }, [open, place]);

  // Click outside closes; the menu lives in a portal so check both parts.
  useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      const t = e.target as Node;
      if (rootRef.current?.contains(t) || menuRef.current?.contains(t)) return;
      close();
    };
    document.addEventListener("mousedown", onDown);
    return () => document.removeEventListener("mousedown", onDown);
  }, [open, close]);

  useEffect(() => {
    if (!open || active < 0) return;
    menuRef.current
      ?.querySelector<HTMLElement>(`[data-index="${active}"]`)
      ?.scrollIntoView({ block: "nearest" });
  }, [open, active]);

  const step = (from: number, dir: 1 | -1) => {
    if (flat.length === 0) return -1;
    let i = from;
    for (let n = 0; n < flat.length; n++) {
      i = (i + dir + flat.length) % flat.length;
      if (!flat[i].disabled) return i;
    }
    return from;
  };
  const edge = (dir: 1 | -1) => step(dir === 1 ? -1 : 0, dir);

  const findTyped = (key: string, from: number) => {
    const now = Date.now();
    const t = typeahead.current;
    t.text = now - t.at < 600 ? t.text + key : key;
    t.at = now;
    const q = t.text.toLowerCase();
    for (let n = 1; n <= flat.length; n++) {
      const i = (from + n) % flat.length;
      if (!flat[i].disabled && flat[i].label.toLowerCase().startsWith(q))
        return i;
    }
    return -1;
  };

  const onKeyDown = (e: ReactKeyboardEvent<HTMLButtonElement>) => {
    if (disabled) return;
    if (!open) {
      if (["ArrowDown", "ArrowUp", "Enter", " "].includes(e.key)) {
        e.preventDefault();
        openMenu();
      } else if (e.key.length === 1 && !e.altKey && !e.ctrlKey && !e.metaKey) {
        const i = findTyped(e.key, flat.findIndex((o) => o.value === current));
        if (i >= 0) choose(flat[i].value);
      }
      return;
    }
    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        setActive((a) => step(a, 1));
        break;
      case "ArrowUp":
        e.preventDefault();
        setActive((a) => step(a, -1));
        break;
      case "Home":
        e.preventDefault();
        setActive(edge(1));
        break;
      case "End":
        e.preventDefault();
        setActive(edge(-1));
        break;
      case "Enter":
      case " ":
        e.preventDefault();
        if (active >= 0 && !flat[active].disabled) choose(flat[active].value);
        break;
      case "Escape":
        e.preventDefault();
        close();
        break;
      case "Tab":
        close();
        break;
      default:
        if (e.key.length === 1 && !e.altKey && !e.ctrlKey && !e.metaKey) {
          const i = findTyped(e.key, active);
          if (i >= 0) setActive(i);
        }
    }
  };

  const chevron = CHEVRON_SIZE[variant];
  let index = -1;
  const renderOption = (o: SelectOption<V>) => {
    const i = ++index;
    const isActive = i === active;
    const isSelected = o.value === current;
    return (
      <button
        key={o.value}
        type="button"
        role="option"
        id={`${listId}-${i}`}
        data-index={i}
        aria-selected={isSelected}
        aria-disabled={o.disabled || undefined}
        title={o.description}
        tabIndex={-1}
        className={`flex items-center gap-2 w-full text-left whitespace-nowrap px-2.5 py-1.5 rounded-[7px] transition-colors ${
          o.disabled
            ? "opacity-40 cursor-not-allowed"
            : "cursor-pointer"
        } ${
          isActive
            ? "bg-[var(--color-bp-500)]/10 text-[var(--color-ink)]"
            : "text-[var(--color-ink-2)]"
        } ${isSelected ? "text-[var(--color-bp-400)]" : ""}`}
        onMouseDown={(e) => e.preventDefault()}
        onMouseEnter={() => !o.disabled && setActive(i)}
        onClick={() => !o.disabled && choose(o.value)}
      >
        {o.icon && (
          <span className="shrink-0 inline-flex opacity-80">{o.icon}</span>
        )}
        <span className="truncate">{o.label}</span>
      </button>
    );
  };

  const menu = open && typeof document !== "undefined" && (
    <div
      ref={menuRef}
      id={listId}
      role="listbox"
      aria-label={ariaLabel ?? title}
      className={`fixed z-50 flex flex-col gap-0.5 p-1 rounded-[10px] border border-[var(--color-ink-3)]/25 bg-[var(--color-surface-2)] shadow-[0_8px_24px_rgba(8,13,24,0.25)] max-h-80 max-w-[min(90vw,34rem)] overflow-y-auto font-mono ${MENU_TEXT[variant]}`}
      style={{
        top: pos?.top ?? 0,
        left: pos?.left ?? 0,
        visibility: pos ? "visible" : "hidden",
      }}
    >
      {items.map((item, gi) =>
        isGroup(item) ? (
          <div
            key={item.label ?? gi}
            className={`flex flex-col gap-0.5 ${
              gi > 0 ? "mt-1 pt-1 border-t border-[var(--color-ink-3)]/15" : ""
            }`}
          >
            {item.label && (
              <div className="px-2.5 pt-1.5 pb-1 font-sans text-[10px] uppercase tracking-wider text-[var(--color-ink-3)]">
                {item.label}
              </div>
            )}
            {item.options.map(renderOption)}
          </div>
        ) : (
          renderOption(item)
        ),
      )}
    </div>
  );

  return (
    <span
      ref={rootRef}
      className={`${variant === "form" ? "flex w-full" : "inline-flex"} ${className}`}
    >
      <button
        ref={triggerRef}
        type="button"
        id={id}
        title={title}
        aria-label={ariaLabel}
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-controls={open ? listId : undefined}
        aria-activedescendant={
          open && active >= 0 ? `${listId}-${active}` : undefined
        }
        disabled={disabled}
        className={`group inline-flex items-center justify-between font-mono leading-none whitespace-nowrap cursor-pointer select-none transition-colors disabled:opacity-40 disabled:cursor-not-allowed ${TRIGGER[variant]} ${FOCUS_RING}`}
        onClick={() => (open ? close() : openMenu())}
        onKeyDown={onKeyDown}
      >
        <span className="flex items-center gap-1.5 min-w-0">
          {selected?.icon && (
            <span className="shrink-0 inline-flex opacity-80">
              {selected.icon}
            </span>
          )}
          <span
            className={`truncate ${
              selected ? "" : variant === "form" ? "text-[var(--color-ink-3)]" : ""
            }`}
          >
            {selected?.label ?? placeholder}
          </span>
        </span>
        <svg
          className="shrink-0 transition-transform group-aria-expanded:rotate-180"
          width={chevron}
          height={chevron}
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>
      {menu && createPortal(menu, document.body)}
    </span>
  );
}

export default Select;
