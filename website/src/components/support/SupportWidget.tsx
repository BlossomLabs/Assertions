import { useCallback, useEffect, useId, useRef, useState } from "react";
import { createPortal } from "react-dom";

import "./support-widget.css";

/**
 * Blossom's support inbox, the one the support widgets of our other apps
 * write to. Its contract is {name, email, message, screenshot?}. This site is
 * static, so the widget posts there directly and tags the message itself.
 */
export const SUPPORT_URL = "https://octosupport.blossom.deno.net";
const SITE_TAG = "Assertions";

export const SUPPORT_CATEGORIES = {
  problem: "Report a problem",
  idea: "Suggest an improvement",
  other: "Something else",
} as const;

export type SupportCategory = keyof typeof SUPPORT_CATEGORIES;

const CATEGORY_KEYS = Object.keys(SUPPORT_CATEGORIES) as SupportCategory[];

export const SUPPORT_MESSAGE_MAX = 4000;
/** Data-URL JPEG from the page capture. */
export const SUPPORT_SCREENSHOT_MAX = 1_500_000;

/** A loose shape check; a typo is caught before sending. */
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

type View = "picker" | "form" | "success" | "error";

const PLACEHOLDERS: Record<SupportCategory, string> = {
  problem: "I noticed that...",
  idea: "What if...",
  other: "I'd like to share...",
};

function Icon({ d, size = 16 }: { d: string[]; size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {d.map((path) => (
        <path key={path} d={path} />
      ))}
    </svg>
  );
}

const ICONS = {
  message: ["M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"],
  problem: [
    "m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3",
    "M12 9v4",
    "M12 17h.01",
  ],
  idea: [
    "M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5",
    "M9 18h6",
    "M10 22h4",
  ],
  back: ["m15 18-6-6 6-6"],
  close: ["M18 6 6 18", "m6 6 12 12"],
  camera: [
    "M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3z",
    "M12 16a3 3 0 1 0 0-6 3 3 0 0 0 0 6",
  ],
  trash: [
    "M3 6h18",
    "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6",
    "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2",
  ],
  check: ["M22 11.08V12a10 10 0 1 1-5.93-9.14", "m9 11 3 3L22 4"],
  alert: ["M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20", "M12 8v4", "M12 16h.01"],
};

const CATEGORY_ICONS: Record<SupportCategory, string[]> = {
  problem: ICONS.problem,
  idea: ICONS.idea,
  other: ICONS.message,
};

/**
 * Floating "Support" button (bottom right) and its panel: pick a category,
 * write a message (email and a full-page screenshot optional), and it goes to
 * the support inbox. Portaled to <body> after mount, so the prerender never
 * sees it and no transformed ancestor can capture its fixed position.
 */
export default function SupportWidget() {
  const [mounted, setMounted] = useState(false);
  const [open, setOpen] = useState(false);
  const [view, setView] = useState<View>("picker");
  const [category, setCategory] = useState<SupportCategory | null>(null);
  const [email, setEmail] = useState("");
  const [text, setText] = useState("");
  const [website, setWebsite] = useState("");
  const [screenshot, setScreenshot] = useState<string | null>(null);
  const [capturing, setCapturing] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string | null>(null);

  const panelRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const headingId = useId();
  const panelId = useId();
  const emailId = useId();

  useEffect(() => setMounted(true), []);

  const reset = useCallback(() => {
    setView("picker");
    setCategory(null);
    setEmail("");
    setText("");
    setWebsite("");
    setScreenshot(null);
    setError(null);
    setEmailError(null);
  }, []);

  const close = useCallback(() => {
    setOpen(false);
    reset();
  }, [reset]);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") close();
    };
    const onPointerDown = (e: PointerEvent) => {
      const t = e.target as Node | null;
      if (
        !t ||
        panelRef.current?.contains(t) ||
        triggerRef.current?.contains(t)
      )
        return;
      close();
    };
    document.addEventListener("keydown", onKey);
    document.addEventListener("pointerdown", onPointerDown);
    return () => {
      document.removeEventListener("keydown", onKey);
      document.removeEventListener("pointerdown", onPointerDown);
    };
  }, [open, close]);

  useEffect(() => {
    if (open && view === "form") textareaRef.current?.focus();
  }, [open, view]);

  const pick = (c: SupportCategory) => {
    setCategory(c);
    setView("form");
  };

  const back = () => {
    setView("picker");
    setText("");
    setScreenshot(null);
    setError(null);
  };

  const capture = async () => {
    if (capturing) return;
    setCapturing(true);
    setError(null);
    try {
      const { default: html2canvas } = await import("html2canvas-pro");
      const doc = document.documentElement;
      const body = document.body;
      const width = Math.max(doc.scrollWidth, body.scrollWidth, doc.clientWidth);
      const height = Math.max(
        doc.scrollHeight,
        body.scrollHeight,
        doc.clientHeight,
      );
      const canvas = await html2canvas(body, {
        useCORS: true,
        logging: false,
        backgroundColor: getComputedStyle(body).backgroundColor,
        width,
        height,
        windowWidth: width,
        windowHeight: height,
        scrollX: 0,
        scrollY: 0,
        ignoreElements: (el) => el.hasAttribute("data-support-widget"),
      });
      const url = canvas.toDataURL("image/jpeg", 0.7);
      if (url.length > SUPPORT_SCREENSHOT_MAX) {
        setError("The page is too big to attach as a screenshot.");
        return;
      }
      setScreenshot(url);
    } catch (e) {
      setError(
        e instanceof Error
          ? `Screenshot failed: ${e.message}`
          : "Screenshot failed.",
      );
    } finally {
      setCapturing(false);
    }
  };

  const overCap = text.trim().length > SUPPORT_MESSAGE_MAX;
  const canSend =
    Boolean(category) && text.trim().length > 0 && !overCap && !sending;

  const submit = async (e: React.SyntheticEvent) => {
    e.preventDefault();
    if (!canSend || !category) return;
    // Left empty by people; a filled one is a bot and is dropped.
    if (website) return;
    setError(null);
    // Checked here, under the field, rather than by the browser's own bubble.
    if (email.trim() && !EMAIL_RE.test(email.trim())) {
      setEmailError("That email does not look right. Fix it, or leave it blank.");
      return;
    }
    setEmailError(null);
    setSending(true);
    try {
      const { origin, pathname } = window.location;
      const response = await fetch(SUPPORT_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: "",
          email: email.trim(),
          message: `[${SITE_TAG} · ${SUPPORT_CATEGORIES[category]}]\nPage: ${origin}${pathname}\n\n${text.trim()}`,
          ...(screenshot ? { screenshot } : {}),
        }),
      });
      if (!response.ok) throw new Error(String(response.status));
      setView("success");
    } catch {
      setError("We couldn't send your message. Please try again in a moment.");
      setView("error");
    } finally {
      setSending(false);
    }
  };

  const title =
    view === "picker"
      ? "How can we help?"
      : view === "form" && category
        ? SUPPORT_CATEGORIES[category]
        : view === "success"
          ? "Thanks!"
          : "Something went wrong";

  if (!mounted) return null;

  return createPortal(
    <div className="support-widget" data-support-widget>
      <button
        ref={triggerRef}
        type="button"
        onClick={() => (open ? close() : setOpen(true))}
        aria-expanded={open}
        aria-controls={panelId}
        aria-label="Support"
        className="support-trigger"
      >
        <Icon d={ICONS.message} />
        <span>Support</span>
      </button>

      {open && (
        <div
          ref={panelRef}
          id={panelId}
          role="dialog"
          aria-modal="false"
          aria-labelledby={headingId}
          className="support-panel"
        >
          <div className="support-head">
            {view === "form" ? (
              <button
                type="button"
                onClick={back}
                aria-label="Back"
                className="support-icon-btn"
              >
                <Icon d={ICONS.back} />
              </button>
            ) : (
              <span className="support-icon-gap" aria-hidden />
            )}
            <h2 id={headingId}>{title}</h2>
            <button
              type="button"
              onClick={close}
              aria-label="Close"
              className="support-icon-btn"
            >
              <Icon d={ICONS.close} />
            </button>
          </div>

          {view === "picker" && (
            <div className="support-body">
              {CATEGORY_KEYS.map((c) => (
                <button
                  key={c}
                  type="button"
                  onClick={() => pick(c)}
                  className="support-category"
                  data-category={c}
                >
                  <span className="support-category-icon">
                    <Icon d={CATEGORY_ICONS[c]} />
                  </span>
                  {SUPPORT_CATEGORIES[c]}
                </button>
              ))}
            </div>
          )}

          {view === "form" && category && (
            <form onSubmit={submit} noValidate className="support-body">
              <input
                id={emailId}
                type="email"
                aria-label="Email (optional)"
                placeholder="your@email.com (optional)"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  setEmailError(null);
                }}
                autoComplete="email"
                aria-invalid={Boolean(emailError)}
                aria-describedby={emailError ? `${emailId}-msg` : undefined}
                className="support-field"
              />
              {emailError && (
                <p id={`${emailId}-msg`} className="support-error" role="alert">
                  {emailError}
                </p>
              )}
              <textarea
                ref={textareaRef}
                aria-label="Message"
                value={text}
                onChange={(e) => setText(e.target.value)}
                placeholder={PLACEHOLDERS[category]}
                rows={4}
                required
                className="support-field"
              />
              <input
                name="website"
                type="text"
                value={website}
                onChange={(e) => setWebsite(e.target.value)}
                tabIndex={-1}
                autoComplete="off"
                aria-hidden="true"
                hidden
              />
              {screenshot && (
                <div className="support-shot">
                  <div className="support-shot-scroll">
                    <img src={screenshot} alt="Screenshot preview" />
                  </div>
                  <button
                    type="button"
                    onClick={() => setScreenshot(null)}
                    disabled={sending}
                    aria-label="Remove screenshot"
                    className="support-shot-remove"
                  >
                    <Icon d={ICONS.trash} size={14} />
                  </button>
                </div>
              )}
              <div className="support-actions">
                <button
                  type="button"
                  onClick={capture}
                  disabled={capturing || sending}
                  aria-label={
                    screenshot ? "Recapture screenshot" : "Attach a screenshot"
                  }
                  title={
                    screenshot ? "Recapture screenshot" : "Attach a screenshot"
                  }
                  className="support-btn support-btn-square"
                  data-busy={capturing || undefined}
                >
                  <Icon d={ICONS.camera} />
                </button>
                <button
                  type="submit"
                  disabled={!canSend}
                  className="support-btn support-btn-primary"
                >
                  {sending ? "Sending…" : "Send"}
                </button>
              </div>
              {overCap && (
                <p className="support-error" role="alert">
                  The message is too long: keep it under{" "}
                  {SUPPORT_MESSAGE_MAX.toLocaleString("en-US")} characters.
                </p>
              )}
              {error && (
                <p className="support-error" role="alert">
                  {error}
                </p>
              )}
            </form>
          )}

          {view === "success" && (
            <div className="support-result">
              <span className="support-result-ok">
                <Icon d={ICONS.check} size={40} />
              </span>
              <p>Thanks for writing. We read every message.</p>
              <button type="button" onClick={close} className="support-btn">
                Done
              </button>
            </div>
          )}

          {view === "error" && (
            <div className="support-result">
              <span className="support-result-err">
                <Icon d={ICONS.alert} size={40} />
              </span>
              <p role="alert">{error ?? "We couldn't send your message."}</p>
              <button
                type="button"
                onClick={() => {
                  setView("form");
                  setError(null);
                }}
                className="support-btn"
              >
                Try again
              </button>
            </div>
          )}
        </div>
      )}
    </div>,
    document.body,
  );
}
