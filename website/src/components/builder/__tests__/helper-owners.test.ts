import { describe, expect, it } from "vitest";

import {
  HELPER_MODULES,
  HELPER_OWNER,
  REGISTRIES,
  ownerOf,
} from "../helper-owners";

describe("helper-owners", () => {
  it("gives every on-chain face exactly one owner", () => {
    const seen = new Map<string, string[]>();
    for (const [module, registry] of Object.entries(REGISTRIES)) {
      for (const [name, entry] of Object.entries(registry)) {
        if (!entry.onchain) continue;
        expect(name.endsWith("!")).toBe(true);
        seen.set(name, [...(seen.get(name) ?? []), module]);
      }
    }
    expect(seen.size).toBeGreaterThan(40);
    for (const [name, modules] of seen) {
      expect(modules, name).toHaveLength(1);
      expect(HELPER_OWNER[name]).toBe(modules[0]);
    }
    expect(Object.keys(HELPER_OWNER)).toHaveLength(seen.size);
  });

  it("names the owners the codegen relies on", () => {
    expect(ownerOf({ name: "len!" })).toBe("lang");
    expect(ownerOf({ name: "bytes.len!" })).toBe("lang");
    expect(ownerOf({ name: "codeAt!" })).toBe("contracts");
    expect(ownerOf({ name: "codeHash!" })).toBe("contracts");
    expect(ownerOf({ name: "chainId!" })).toBe("receipts");
    expect(ownerOf({ name: "block.timestamp!" })).toBe("receipts");
    expect(ownerOf({ name: "absDiff!" })).toBe("math");
    expect(ownerOf({ name: "balance!" })).toBe("std");
    expect(ownerOf({ name: "calc!" })).toBe("std");
    expect(ownerOf({ name: "calcFloor!" })).toBe("std");
    expect(ownerOf({ name: "calcCeil!" })).toBe("std");
    expect(ownerOf({ name: "num.format!" })).toBe("lang");
    expect(ownerOf({ name: "num.parse!" })).toBe("lang");
  });

  it("leaves storageAt without an on-chain owner", () => {
    expect("storageAt!" in HELPER_OWNER).toBe(false);
    expect(ownerOf({ name: "storageAt!" })).toBeUndefined();
  });

  it("looks up unprefixed names only for ! faces", () => {
    expect(ownerOf({ name: "min" })).toBeUndefined();
    expect(ownerOf({ name: "nope!" })).toBeUndefined();
    expect(ownerOf({ module: "contracts", name: "codeAt!" })).toBe("contracts");
    expect(ownerOf({ module: "math", name: "min" })).toBe("math");
  });

  it("lists the helper modules without std", () => {
    expect(HELPER_MODULES).not.toContain("std");
    for (const module of ["lang", "receipts", "contracts", "math"])
      expect(HELPER_MODULES).toContain(module);
  });
});
