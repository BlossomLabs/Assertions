import { type ReactNode, useEffect, useRef, useState } from "react";

/**
 * The assistant's sidebar. While there is only something to read (the login),
 * it is as tall as its content; once the chat is open it takes the height of
 * the screen. Either way a change of height is animated: the content's height
 * is measured and set on the panel, since CSS cannot transition to `auto`.
 */
export function AssistantAside({
  full,
  children,
}: {
  /** The chat is open: fill the screen instead of hugging the content. */
  full: boolean;
  children: ReactNode;
}) {
  const innerRef = useRef<HTMLDivElement>(null);
  const [height, setHeight] = useState<number | null>(null);

  useEffect(() => {
    const inner = innerRef.current;
    if (!inner || full) return;
    // + 2 for the panel's own border.
    const measure = () => setHeight(inner.offsetHeight + 2);
    measure();
    const observer = new ResizeObserver(measure);
    observer.observe(inner);
    return () => observer.disconnect();
  }, [full]);

  return (
    <aside
      className={`rounded-2xl border border-[var(--color-ink-3)]/20 bg-[var(--color-surface-2)] overflow-hidden lg:sticky lg:top-24 transition-[height] duration-300 ease-out motion-reduce:transition-none ${
        full ? "min-h-96 lg:h-[calc(100vh-8rem)]" : ""
      }`}
      style={!full && height !== null ? { height } : undefined}
    >
      <div ref={innerRef} className={`p-6 flex flex-col ${full ? "h-full min-h-96" : ""}`}>
        {children}
      </div>
    </aside>
  );
}

export default AssistantAside;
