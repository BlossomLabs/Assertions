// @vitest-environment jsdom
import { renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { ValueExpr } from "../assertion-model";
import {
  type AddressReader,
  CurrentAddress,
  ExecutorIsSafe,
  resetSafeProbes,
  useIsSafe,
} from "../useIsSafe";

const SAFE = "0x1234567890123456789012345678901234567890";
const OTHER = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001";

/** The chain: which addresses answer as a Safe, and what names resolve to. */
const chain = {
  safes: new Set<string>(),
  names: new Map<string, string>(),
  reads: 0,
  lookups: 0,
};

vi.mock("wagmi", async (importOriginal) => ({
  ...(await importOriginal<typeof import("wagmi")>()),
  usePublicClient: () => mainnet,
}));
vi.mock("../useChainSupport", () => ({
  useChainClient: () => client,
}));

const client = {
  readContract: async ({ address }: { address: string }) => {
    chain.reads++;
    if (!chain.safes.has(address.toLowerCase())) throw new Error("execution reverted");
    return 2n;
  },
};
const mainnet = {
  getEnsAddress: async ({ name }: { name: string }) => {
    chain.lookups++;
    return chain.names.get(name) ?? null;
  },
};

const literal = (value: string): ValueExpr => ({ kind: "literal", value });
const asExecutor = (isSafe: boolean) => ({
  wrapper: ({ children }: { children: ReactNode }) => (
    <ExecutorIsSafe.Provider value={isSafe}>{children}</ExecutorIsSafe.Provider>
  ),
});

beforeEach(() => {
  resetSafeProbes();
  chain.safes = new Set([SAFE.toLowerCase()]);
  chain.names = new Map([
    ["mysafe.eth", SAFE],
    ["friend.eth", OTHER],
  ]);
  chain.reads = 0;
  chain.lookups = 0;
});

describe("useIsSafe", () => {
  it("is true for a typed address that is a Safe, once the chain has answered", async () => {
    const { result } = renderHook(() => useIsSafe(literal(SAFE), 1));
    expect(result.current).toBe(false);
    await waitFor(() => expect(result.current).toBe(true));
  });

  it("stays false for a typed address that is not one", async () => {
    const { result } = renderHook(() => useIsSafe(literal(OTHER), 1));
    await waitFor(() => expect(chain.reads).toBeGreaterThan(0));
    expect(result.current).toBe(false);
  });

  it("resolves an ENS name, then asks about the address it names", async () => {
    const { result } = renderHook(() => useIsSafe(literal("mysafe.eth"), 1));
    expect(result.current).toBe(false);
    await waitFor(() => expect(result.current).toBe(true));
    expect(chain.lookups).toBeGreaterThan(0);
  });

  it("stays false for a name that resolves to something else, or to nothing", async () => {
    const other = renderHook(() => useIsSafe(literal("friend.eth"), 1));
    await waitFor(() => expect(chain.reads).toBeGreaterThan(0));
    expect(other.result.current).toBe(false);
    const lookups = chain.lookups;
    const none = renderHook(() => useIsSafe(literal("nobody.eth"), 1));
    await waitFor(() => expect(chain.lookups).toBeGreaterThan(lookups));
    expect(none.result.current).toBe(false);
  });

  it("takes @me to be a Safe exactly when the executor is one, without asking the chain", () => {
    expect(renderHook(() => useIsSafe(literal("@me"), 1), asExecutor(true)).result.current).toBe(true);
    expect(renderHook(() => useIsSafe(literal("@me"), 1), asExecutor(false)).result.current).toBe(false);
    expect(chain.reads).toBe(0);
  });

  const call: ValueExpr = {
    kind: "call",
    target: OTHER,
    resolved: null,
    hops: [{ fnName: "safe", inline: false, argTypes: [], returnTypes: ["address"], args: [] }],
  };
  const reading = (reader: AddressReader) => ({
    wrapper: ({ children }: { children: ReactNode }) => (
      <CurrentAddress.Provider value={reader}>{children}</CurrentAddress.Provider>
    ),
  });

  it("judges a call by the address it returns now", async () => {
    const yes = renderHook(() => useIsSafe(call, 1), reading(async () => SAFE));
    expect(yes.result.current).toBe(false);
    await waitFor(() => expect(yes.result.current).toBe(true));
    const reads = chain.reads;
    const no = renderHook(() => useIsSafe(call, 1), reading(async () => OTHER));
    await waitFor(() => expect(chain.reads).toBeGreaterThan(reads));
    expect(no.result.current).toBe(false);
  });

  it("stays false for a call that cannot be read now, or with nothing to read it", async () => {
    let asked = 0;
    const unread = renderHook(
      () => useIsSafe(call, 1),
      reading(async () => {
        asked++;
        return null;
      }),
    );
    await waitFor(() => expect(asked).toBe(1));
    expect(unread.result.current).toBe(false);
    expect(renderHook(() => useIsSafe(call, 1)).result.current).toBe(false);
    expect(chain.reads).toBe(0);
  });

  it("does not ask about a call that returns something else than an address", () => {
    const count: ValueExpr = {
      ...call,
      hops: [{ fnName: "count", inline: false, argTypes: [], returnTypes: ["uint256"], args: [] }],
    } as ValueExpr;
    let asked = 0;
    const { result } = renderHook(
      () => useIsSafe(count, 1),
      reading(async () => {
        asked++;
        return SAFE;
      }),
    );
    expect(result.current).toBe(false);
    expect(asked).toBe(0);
    expect(renderHook(() => useIsSafe(literal("42"), 1), asExecutor(true)).result.current).toBe(false);
  });
});
