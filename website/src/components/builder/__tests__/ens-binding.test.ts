import { describe, expect, it } from "vitest";

import { ensSetLine, evmlArg } from "../useContractFunctions";

const VITALIK = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045";

describe("ensSetLine", () => {
  it("keeps a resolved name live on mainnet", () => {
    expect(ensSetLine("vitalik.eth", VITALIK, 1)).toBe("set $vitalik @ens(vitalik.eth)");
  });

  it("freezes the per-chain address elsewhere", () => {
    expect(ensSetLine("vitalik.eth", VITALIK, 100)).toBe(`set $vitalik ${VITALIK}`);
  });

  it.each([1, 100])("keeps a name that did not resolve live on chain %i", (chainId) => {
    expect(ensSetLine("vitalik.eth", null, chainId)).toBe("set $vitalik @ens(vitalik.eth)");
  });
});

describe("an ENS name in an address argument", () => {
  // The contract form's binding: resolve, then hoist the set line.
  const bind = (address: string | null) => {
    const sets: string[] = [];
    const ensToVar = async (name: string) => {
      sets.push(ensSetLine(name, address, 1));
      return "$vitalik";
    };
    return { sets, ensToVar };
  };

  it("becomes a $variable even when the lookup fails, never the raw name", async () => {
    const { sets, ensToVar } = bind(null);
    expect(await evmlArg("address", "vitalik.eth", ensToVar)).toBe("$vitalik");
    expect(sets).toEqual(["set $vitalik @ens(vitalik.eth)"]);
  });

  it("does the same inside an address list", async () => {
    const { ensToVar } = bind(null);
    expect(await evmlArg("address[]", "vitalik.eth, nick.eth", ensToVar)).toBe("[$vitalik $vitalik]");
  });
});
