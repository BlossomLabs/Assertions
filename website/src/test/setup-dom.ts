import { afterEach } from "vitest";

/**
 * Setup for the component tests. It runs before every test file, and does
 * nothing in the node environment the logic tests use.
 */
if (typeof document !== "undefined") {
  // React's act() warnings need this flag outside a framework runner.
  (globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT =
    true;

  // jsdom has no layout: the pieces of it the components call are stubbed.
  if (!Element.prototype.scrollIntoView)
    Element.prototype.scrollIntoView = () => {};
  if (!Element.prototype.scrollTo) Element.prototype.scrollTo = () => {};
  if (!("ResizeObserver" in globalThis))
    (globalThis as { ResizeObserver?: unknown }).ResizeObserver = class {
      observe() {}
      unobserve() {}
      disconnect() {}
    };

  // Vitest runs without globals, so Testing Library cannot register its own
  // cleanup: unmount what each test rendered.
  const { cleanup } = await import("@testing-library/react");
  afterEach(() => cleanup());
}
