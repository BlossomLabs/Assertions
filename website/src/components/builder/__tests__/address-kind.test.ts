import { beforeEach, describe, expect, it, vi } from "vitest";

import { addressKind, kindOfCode, resetAddressKinds } from "../address-kind";

const A = "0x000000000000000000000000000000000000dEaD";

describe("addressKind", () => {
  beforeEach(resetAddressKinds);

  it("is a contract with code, an account without, and an account that only delegates", () => {
    expect(kindOfCode("0x6080")).toBe("contract");
    expect(kindOfCode("0x")).toBe("account");
    expect(kindOfCode(undefined)).toBe("account");
    expect(kindOfCode(`0xef0100${"ab".repeat(20)}`)).toBe("account");
  });

  it("reads once per chain and address, whatever the case", async () => {
    const getCode = vi.fn(async () => "0x6080");
    expect(await addressKind({ getCode }, 1, A)).toBe("contract");
    expect(await addressKind({ getCode }, 1, A.toLowerCase())).toBe("contract");
    expect(getCode).toHaveBeenCalledTimes(1);
    await addressKind({ getCode }, 100, A);
    expect(getCode).toHaveBeenCalledTimes(2);
  });

  it("says nothing when it cannot read, and asks again next time", async () => {
    const failing = vi.fn(async () => {
      throw new Error("rpc");
    });
    expect(await addressKind({ getCode: failing }, 1, A)).toBeUndefined();
    expect(await addressKind({ getCode: async () => "0x" }, 1, A)).toBe("account");
    expect(await addressKind(undefined, 1, A)).toBeUndefined();
  });
});
