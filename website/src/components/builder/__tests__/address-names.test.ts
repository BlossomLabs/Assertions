import { beforeEach, describe, expect, it, vi } from "vitest";
import { getAddress } from "viem";

const verified = vi.hoisted(() => ({ info: null as { name: string } | null }));
vi.mock("@evmcrispr/sdk", async (original) => ({
  ...(await original<typeof import("@evmcrispr/sdk")>()),
  fetchVerifiedContract: async () => verified.info,
}));

import { ensName, lookupAddressName, verifiedName } from "../address-names";
import { nameKey, sentenceView, type SuggestedCheck } from "../suggested-checks";

const A = getAddress("0x00000000000000000000000000000000000a0001");
const B = getAddress("0x00000000000000000000000000000000000a0002");

/** A mainnet client that knows one primary name and one forward record. */
const ens = (primary: string | null, resolvesTo: string | null) => ({
  getEnsName: async () => primary,
  getEnsAddress: async () => resolvesTo,
});

beforeEach(() => {
  verified.info = null;
});

describe("ensName", () => {
  it("keeps a primary name that resolves back to the address", async () => {
    expect(await ensName(ens("alice.eth", A), A, 1)).toBe("alice.eth");
  });

  it("drops one that resolves elsewhere, or nowhere: anyone can set a name that is not theirs", async () => {
    expect(await ensName(ens("alice.eth", B), A, 1)).toBeNull();
    expect(await ensName(ens("alice.eth", null), A, 1)).toBeNull();
  });

  it("drops a name that is not in its normalized form, or too long to be a label", async () => {
    expect(await ensName(ens("Alice.eth", A), A, 1)).toBeNull();
    expect(await ensName(ens(`${"a".repeat(40)}.eth`, A), A, 1)).toBeNull();
  });

  it("asks nothing without a client", async () => {
    expect(await ensName(undefined, A, 1)).toBeNull();
  });
});

describe("verifiedName", () => {
  it("is the name published with the verified source, when it looks like one", async () => {
    verified.info = { name: "SafeProxy" };
    expect(await verifiedName(A, 1)).toBe("SafeProxy");
    verified.info = { name: "Safe (official) https://x" };
    expect(await verifiedName(A, 1)).toBeNull();
    verified.info = null;
    expect(await verifiedName(A, 1)).toBeNull();
  });

  it("does not ask the explorer about an account without code", async () => {
    verified.info = { name: "SafeProxy" };
    const code = (c: string) => ({ getCode: async () => c });
    expect(await verifiedName(A, 1, code("0x"))).toBeNull();
    // An account that only delegates is still an account.
    expect(await verifiedName(A, 1, code(`0xef0100${"ab".repeat(20)}`))).toBeNull();
    expect(await verifiedName(A, 1, code("0x6080"))).toBe("SafeProxy");
  });

  it("comes after an ENS name that resolves back", async () => {
    verified.info = { name: "SafeProxy" };
    expect(await lookupAddressName(ens("dao.eth", A), A, 1)).toEqual({
      name: "dao.eth",
      source: "ens",
    });
    expect(await lookupAddressName(ens(null, null), A, 1)).toEqual({
      name: "SafeProxy",
      source: "verified",
    });
  });
});

describe("a looked-up name in a sentence", () => {
  const mention = (part: Record<string, unknown>): SuggestedCheck =>
    ({
      line: "assert 1 == 1",
      description: "d",
      kind: "state",
      module: "t",
      event: "e",
      emitter: A,
      sentence: [{ type: "address", address: A, ...part }],
    }) as SuggestedCheck;
  const label = (
    part: Record<string, unknown>,
    name?: { name: string; source: "ens" | "verified" },
  ) => {
    const names = new Map(name ? [[nameKey(1, A), name]] : []);
    const [first] = sentenceView(mention(part), 1, names) ?? [];
    return first as { label: string; named?: string };
  };

  it("stands beside the shortened address, and says where it comes from", () => {
    expect(label({}, { name: "alice.eth", source: "ens" })).toMatchObject({
      label: "alice.eth (0x0000…0001)",
      named: "ens",
    });
    expect(label({}, { name: "SafeProxy", source: "verified" })).toMatchObject({
      label: "SafeProxy (0x0000…0001)",
      named: "verified",
    });
    expect(label({})).toMatchObject({ label: "0x0000…0001" });
  });

  it("a token list's name still stands alone; an ENS name comes before the contract's own word, and that before a verified name", () => {
    const ensName = { name: "usdc.eth", source: "ens" as const };
    const verifiedName = { name: "FiatTokenProxy", source: "verified" as const };
    expect(label({ name: "USDC", listed: true }, ensName).label).toBe("USDC");
    expect(label({ name: "USDC" }, ensName).label).toBe("usdc.eth (0x0000…0001)");
    expect(label({ name: "USDC" }, verifiedName).label).toBe("USDC (0x0000…0001)");
  });
});
