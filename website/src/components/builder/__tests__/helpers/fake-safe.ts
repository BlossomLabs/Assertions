import { createContext } from "react";

/**
 * Stands in for the on-chain Safe lookup: no client, no RPC. A test lists
 * the addresses that are Safes before rendering.
 */
export const safes = new Set<string>();

export function resetSafes() {
  safes.clear();
}

export function fakeIsSafeModule() {
  return {
    ExecutorIsSafe: createContext(false),
    CurrentAddress: createContext(null),
    useIsSafe: (node: { kind: string; value?: string }) =>
      (node.kind === "literal" && safes.has((node.value ?? "").trim().toLowerCase())) ||
      // A call stands for the address it returns: listed by its target here.
      (node.kind === "call" && safes.has(`call:${(node as { target?: string }).target ?? ""}`.toLowerCase())),
    probeSafe: async () => false,
    resetSafeProbes: () => {},
  };
}
