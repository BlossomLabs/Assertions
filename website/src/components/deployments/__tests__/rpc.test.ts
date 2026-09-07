import { describe, expect, it } from "vitest";
import { gnosis, mainnet, polygon, zora } from "viem/chains";

import { DRPC_SLUGS, drpcUrl, rpcUrl } from "../rpc";
import { makePublicClient } from "../shared";

describe("drpcUrl", () => {
  it("builds the load-balanced dRPC endpoint for a covered chain", () => {
    expect(drpcUrl(mainnet.id, "k3y")).toBe("https://lb.drpc.live/ethereum/k3y");
    expect(drpcUrl(gnosis.id, "k3y")).toBe("https://lb.drpc.live/gnosis/k3y");
  });

  it("returns undefined without a key, or for a chain dRPC does not cover", () => {
    expect(drpcUrl(mainnet.id, undefined)).toBeUndefined();
    expect(drpcUrl(mainnet.id, "")).toBeUndefined();
    expect(drpcUrl(zora.id, "k3y")).toBeUndefined();
  });

  it("covers every chain the builder offers", async () => {
    const { CHAINS } = await import("../../builder/wagmi");
    for (const chain of CHAINS) expect(DRPC_SLUGS[chain.id]).toBeDefined();
  });
});

describe("rpcUrl (VITE_DRPC_API_KEY from the environment)", () => {
  const key = import.meta.env.VITE_DRPC_API_KEY as string | undefined;

  it("follows the env key: dRPC when set, viem defaults otherwise", () => {
    if (key) {
      expect(rpcUrl(mainnet.id)).toBe(`https://lb.drpc.live/ethereum/${key}`);
    } else {
      expect(rpcUrl(mainnet.id)).toBeUndefined();
    }
  });

  it("drives the public clients the deployments table uses", () => {
    const expectMain = key
      ? `https://lb.drpc.live/ethereum/${key}`
      : mainnet.rpcUrls.default.http[0];
    expect(makePublicClient(mainnet).transport.url).toBe(expectMain);
    // Polygon keeps its hand-picked public node when no key is set (viem's
    // default rejects requests) and moves to dRPC when there is one.
    const expectPolygon = key
      ? `https://lb.drpc.live/polygon/${key}`
      : "https://polygon-bor-rpc.publicnode.com";
    expect(makePublicClient(polygon).transport.url).toBe(expectPolygon);
  });
});
