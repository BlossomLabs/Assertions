import type { SimulationResult } from "@evmcrispr/core";
import { createElement, Fragment, type ReactNode } from "react";
import { vi } from "vitest";

/**
 * Stands in for the configured EVML tag (`useEvmlTag()`): nothing is
 * compiled or sent to a fork. `simulate` answers with whatever the test
 * makes it answer, and records the scripts it was asked to run.
 */
export function createFakeTag(account?: string) {
  const simulate = vi.fn(
    async (_script: string, _options?: unknown): Promise<SimulationResult> => ({
      success: true,
      logs: [],
      actions: [],
    }),
  );
  const execute = vi.fn(async (_script: string, _wallet?: unknown) => {});
  const interpret = vi.fn(async (_script: string) => []);
  const withConfig = vi.fn((_config: unknown) => tag);
  const tag = {
    config: { account, chainId: 1 },
    with: withConfig,
    script: (script: string) => ({
      simulate: (options?: unknown) => simulate(script, options),
      execute: (wallet?: unknown) => execute(script, wallet),
      interpret: () => interpret(script),
    }),
  };
  return { tag, simulate, execute, interpret, withConfig };
}

export type FakeTag = ReturnType<typeof createFakeTag>;

/** The tag `useEvmlTag()` hands out; tests replace it before rendering. */
export const currentTag: { fake: FakeTag } = { fake: createFakeTag() };

export function useFreshTag(account?: string): FakeTag {
  currentTag.fake = createFakeTag(account);
  return currentTag.fake;
}

/** The module the tests install with `vi.mock("@evmcrispr/editor", …)`:
 *  the real one pulls in Monaco, which has no place in jsdom. */
export function fakeEditorModule() {
  return {
    useEvmlTag: () => currentTag.fake.tag,
    EvmcrisprProvider: ({ children }: { children: ReactNode }) =>
      createElement(Fragment, null, children),
    Editor: () => null,
  };
}
