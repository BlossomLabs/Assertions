import { describe, expect, it } from "vitest";

import {
  type CallHop,
  type ValueExpr,
  categoryFromAbiType,
  inferCategory,
  literalCategory,
  opsFor,
  resolveLens,
} from "../assertion-model";

const T = "0x1234567890123456789012345678901234567890";
const callOf = (hop: Partial<CallHop>): ValueExpr => ({
  kind: "call",
  target: T,
  resolved: null,
  hops: [{ fnName: "f", inline: true, argTypes: [], returnTypes: ["uint256"], args: [], ...hop }],
});

describe("categoryFromAbiType", () => {
  it("follows the compiler for word and dynamic types", () => {
    expect(categoryFromAbiType("uint256")).toBe("uint");
    expect(categoryFromAbiType("uint8")).toBe("uint");
    expect(categoryFromAbiType("int128")).toBe("int");
    expect(categoryFromAbiType("address")).toBe("address");
    expect(categoryFromAbiType("bool")).toBe("bool");
    expect(categoryFromAbiType("bytes32")).toBe("bytes32");
    expect(categoryFromAbiType("string")).toBe("string");
    expect(categoryFromAbiType("bytes")).toBe("bytes");
  });

  it("names the shapes the compiler's table does not reason about", () => {
    expect(categoryFromAbiType("uint256[]")).toBe("array");
    expect(categoryFromAbiType("address[3]")).toBe("array");
    expect(categoryFromAbiType("(address,uint256)")).toBe("tuple");
    expect(categoryFromAbiType("bytes4")).toBe("unknown");
    expect(categoryFromAbiType("function")).toBe("unknown");
  });
});

describe("inferCategory", () => {
  it("narrows a call through its lens", () => {
    expect(inferCategory(callOf({ returnTypes: ["uint256", "address"] }))).toBe("tuple");
    expect(inferCategory(callOf({ returnTypes: ["uint256", "address"], lensIndex: 1 }))).toBe(
      "address",
    );
    expect(inferCategory(callOf({ returnTypes: ["address[]"] }))).toBe("array");
    expect(inferCategory(callOf({ returnTypes: ["address[]"], lensPath: ["0"] }))).toBe(
      "address",
    );
    expect(
      inferCategory(callOf({ returnTypes: ["(address,uint256,bool)[]"], lensPath: ["1", "2"] })),
    ).toBe("bool");
    expect(inferCategory(callOf({ returnTypes: [] }))).toBe("unknown");
  });

  it("reports a malformed lens path as invalid", () => {
    const lens = resolveLens({
      fnName: "f",
      inline: true,
      argTypes: [],
      returnTypes: ["address[2]"],
      args: [],
      lensPath: ["5"],
    });
    expect(lens?.valid).toBe(false);
    expect(lens?.entries).toEqual([]);
  });

  it("classifies literals by shape", () => {
    expect(literalCategory("1e18")).toBe("uint");
    expect(literalCategory("-5")).toBe("int");
    expect(literalCategory(T)).toBe("address");
    expect(literalCategory("vitalik.eth")).toBe("address");
    expect(literalCategory("@me")).toBe("address");
    expect(literalCategory(`0x${"00".repeat(32)}`)).toBe("bytes32");
    expect(literalCategory("0x1234")).toBe("bytes");
    expect(literalCategory("true")).toBe("bool");
    expect(literalCategory("hello world")).toBe("string");
    expect(literalCategory("$var")).toBe("unknown");
    expect(literalCategory("")).toBe("unknown");
  });

  it("knows the category of every source and combinator", () => {
    const lit = (value: string): ValueExpr => ({ kind: "literal", value });
    expect(inferCategory({ kind: "codeAt", address: lit(T) })).toBe("bytes");
    expect(inferCategory({ kind: "codeHash", address: lit(T) })).toBe("bytes32");
    expect(inferCategory({ kind: "callwrap", helper: "hash", call: callOf({}) })).toBe("bytes32");
    expect(inferCategory({ kind: "callwrap", helper: "bytelen", call: callOf({}) })).toBe("uint");
    expect(inferCategory({ kind: "minmax", op: "min", items: [lit("1"), lit("-2")] })).toBe("int");
    expect(inferCategory({ kind: "arith", op: "+", left: lit("1"), right: lit("2") })).toBe("uint");
    expect(inferCategory({ kind: "strtest", helper: "includes", call: callOf({}), arg: "x" })).toBe(
      "bool",
    );
    expect(inferCategory({ kind: "split", call: callOf({}), delimiter: " ", index: "0" })).toBe(
      "string",
    );
  });
});

describe("opsFor", () => {
  it("offers ~= only with one constant numeric side", () => {
    expect(opsFor("uint", "uint", false, true)).toContain("~=");
    expect(opsFor("uint", "uint", false, false)).not.toContain("~=");
    expect(opsFor("bool", "bool", false, true)).toEqual(["is true", "==", "!="]);
    expect(opsFor("bytes", "bytes", false, true)).toEqual(["==", "!="]);
    expect(opsFor("array", "uint", false, true)).toEqual(["==", "!="]);
  });
});
