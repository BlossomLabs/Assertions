import { describe, expect, it } from "vitest";

import { buildAssertionLine, buildExprText } from "../assertion-codegen";
import { type Assertion, type CallHop, type CallNode } from "../assertion-model";

const T = "0x1234567890123456789012345678901234567890";
const VITALIK = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045";

const hop = (partial: Partial<CallHop> & { fnName: string }): CallHop => ({
  inline: false,
  argTypes: [],
  returnTypes: ["uint256"],
  args: [],
  ...partial,
});
const call = (target: string, hops: CallHop[], resolved?: string): CallNode => ({
  kind: "call",
  target,
  resolved: resolved ?? null,
  hops,
});
const literal = (value: string) => ({ kind: "literal" as const, value });
const assertion = (partial: Partial<Assertion>): Assertion => ({
  subject: literal(""),
  operator: "==",
  expected: literal(""),
  delta: "",
  message: "",
  ...partial,
});
const noEns = { resolveEns: async () => null, chainId: 1 };

describe("buildAssertionLine", () => {
  it("renders a named call with arguments", async () => {
    const a = assertion({
      subject: call(T, [hop({ fnName: "balanceOf", argTypes: ["address"], args: ["@me"] })]),
      operator: ">=",
      expected: literal("1e18"),
    });
    expect(await buildAssertionLine(a, noEns)).toEqual({
      line: `assert ${T}::balanceOf(@me) >= 1e18`,
      sets: [],
    });
  });

  it("renders inline ABIs, chains and lenses", async () => {
    const a = assertion({
      subject: call(T, [
        hop({
          fnName: "pair",
          inline: true,
          returnTypes: ["uint112", "uint112", "address"],
          lensIndex: 2,
        }),
        hop({ fnName: "owners", inline: true, returnTypes: ["address[]"], lensPath: ["-1"] }),
      ]),
      expected: literal("@me"),
    });
    expect((await buildAssertionLine(a, noEns))?.line).toBe(
      `assert ${T}::{pair()(uint112,uint112,address)}[_ _ $]::{owners()(address[])}[[... $]] == @me`,
    );
  });

  it("renders a nested tuple lens", async () => {
    const a = assertion({
      subject: call(T, [
        hop({
          fnName: "proposals",
          inline: true,
          returnTypes: ["(address,uint256,bool)[]"],
          lensPath: ["1", "2"],
        }),
      ]),
      expected: literal("true"),
    });
    expect((await buildAssertionLine(a, noEns))?.line).toBe(
      `assert ${T}::{proposals()((address,uint256,bool)[])}[[_ [_ _ $]]] == true`,
    );
  });

  it("quotes string literals against a string call", async () => {
    const a = assertion({
      subject: {
        kind: "split",
        call: call(T, [hop({ fnName: "name", returnTypes: ["string"] })]),
        delimiter: " ",
        index: "-1",
      },
      expected: literal("LP"),
    });
    expect((await buildAssertionLine(a, noEns))?.line).toBe(
      `assert @str.split!(${T}::name() " " -1) == "LP"`,
    );
  });

  it("keeps an ENS target live on mainnet and freezes it elsewhere", async () => {
    const a = assertion({
      subject: call("vitalik.eth", [hop({ fnName: "owner", returnTypes: ["address"] })], VITALIK),
      expected: literal("@me"),
    });
    expect(await buildAssertionLine(a, noEns)).toEqual({
      line: "assert $vitalik::owner() == @me",
      sets: ["set $vitalik @ens(vitalik.eth)"],
    });
    expect(await buildAssertionLine(a, { ...noEns, chainId: 100 })).toEqual({
      line: "assert $vitalik::owner() == @me",
      sets: [`set $vitalik ${VITALIK}`],
    });
  });

  it("hoists an ENS argument, live when unresolved", async () => {
    const a = assertion({
      subject: call(T, [
        hop({ fnName: "balanceOf", argTypes: ["address"], args: ["vitalik.eth"] }),
      ]),
      operator: ">",
      expected: literal("0"),
    });
    expect(await buildAssertionLine(a, { ...noEns, chainId: 100 })).toEqual({
      line: `assert ${T}::balanceOf($vitalik) > 0`,
      sets: ["set $vitalik @ens(vitalik.eth)"],
    });
    expect(
      await buildAssertionLine(a, { resolveEns: async () => VITALIK, chainId: 100 }),
    ).toEqual({
      line: `assert ${T}::balanceOf($vitalik) > 0`,
      sets: [`set $vitalik ${VITALIK}`],
    });
  });

  it("wraps arithmetic and logic once and renders the bare form", async () => {
    const supply = call(T, [hop({ fnName: "totalSupply" })]);
    const arith = assertion({
      subject: { kind: "arith", op: "*", left: supply, right: literal("2") },
      operator: "<=",
      expected: literal("1e24"),
    });
    expect((await buildAssertionLine(arith, noEns))?.line).toBe(
      `assert @calc!(${T}::totalSupply() * 2) <= 1e24`,
    );
    // `@calc!` spells integer division `//`; `/` is the rounded division
    // of `@calcFloor!`/`@calcCeil!`, its own helper with `/` at the root and
    // nested arithmetic wrapped on its own.
    const trunc = assertion({
      subject: { kind: "arith", op: "//", left: supply, right: literal("2") },
      operator: "<=",
      expected: literal("1e24"),
    });
    expect((await buildAssertionLine(trunc, noEns))?.line).toBe(
      `assert @calc!(${T}::totalSupply() // 2) <= 1e24`,
    );
    const floor = assertion({
      subject: { kind: "arith", op: "/", left: supply, right: literal("3") },
      operator: "<=",
      expected: literal("1e24"),
    });
    expect((await buildAssertionLine(floor, noEns))?.line).toBe(
      `assert @calcFloor!(${T}::totalSupply() / 3) <= 1e24`,
    );
    const ceil = assertion({
      subject: {
        kind: "arith",
        op: "/",
        rounding: "ceil",
        left: { kind: "arith", op: "+", left: supply, right: literal("1") },
        right: literal("3"),
      },
      operator: "<=",
      expected: literal("1e24"),
    });
    expect((await buildAssertionLine(ceil, noEns))?.line).toBe(
      `assert @calcCeil!(@calc!(${T}::totalSupply() + 1) / 3) <= 1e24`,
    );
  });

  it("renders the decimal format and parse helpers with their options", async () => {
    const supply = call(T, [hop({ fnName: "totalSupply" })]);
    const format = assertion({
      subject: { kind: "numformat", value: supply, decimals: "18" },
      operator: "==",
      expected: literal("1.5"),
    });
    expect((await buildAssertionLine(format, noEns))?.line).toBe(
      `assert @num.format!(${T}::totalSupply() 18) == "1.5"`,
    );
    const name = call(T, [hop({ fnName: "name", returnTypes: ["string"] })]);
    const parse = (rounding: "trunc" | "floor" | "ceil", signedness: "signed" | "unsigned") =>
      assertion({
        subject: { kind: "numparse", value: name, decimals: "6", rounding, signedness },
        operator: ">",
        expected: literal("0"),
      });
    expect((await buildAssertionLine(parse("trunc", "signed"), noEns))?.line).toBe(
      `assert @num.parse!(${T}::name() 6) > 0`,
    );
    expect((await buildAssertionLine(parse("floor", "signed"), noEns))?.line).toBe(
      `assert @num.parse!(${T}::name() 6 floor) > 0`,
    );
    expect((await buildAssertionLine(parse("trunc", "unsigned"), noEns))?.line).toBe(
      `assert @num.parse!(${T}::name() 6 trunc unsigned) > 0`,
    );
    // An out-of-range precision leaves the line incomplete.
    const bad = assertion({
      subject: { kind: "numformat", value: supply, decimals: "78" },
      operator: "==",
      expected: literal("1"),
    });
    expect(await buildAssertionLine(bad, noEns)).toBeNull();
    const bare = assertion({
      subject: {
        kind: "logic",
        op: "or",
        left: { kind: "cmp", op: ">", left: supply, right: literal("0") },
        right: { kind: "not", operand: call(T, [hop({ fnName: "paused", returnTypes: ["bool"] })]) },
      },
      operator: null,
      expected: null,
      message: "halted",
    });
    expect((await buildAssertionLine(bare, noEns))?.line).toBe(
      `assert @bool!((${T}::totalSupply() > 0) or (not ${T}::paused())) "halted"`,
    );
  });

  it("renders the deployed-code source and the delta option", async () => {
    const code = assertion({
      subject: { kind: "callwrap", helper: "hash", call: { kind: "codeAt", address: literal(T) } },
      expected: literal(`0x${"ab".repeat(32)}`),
    });
    expect((await buildAssertionLine(code, noEns))?.line).toBe(
      `assert @hash!(@codeAt!(${T})) == 0x${"ab".repeat(32)}`,
    );
    const approx = assertion({
      subject: call(T, [hop({ fnName: "price" })]),
      operator: "~=",
      expected: literal("100e8"),
      delta: "50e8",
    });
    expect((await buildAssertionLine(approx, noEns))?.line).toBe(
      `assert ${T}::price() ~= 100e8 --delta 50e8`,
    );
    expect(await buildAssertionLine({ ...approx, delta: "" }, noEns)).toBeNull();
  });
});

describe("buildExprText", () => {
  it("renders one expression with its sets", async () => {
    expect(
      await buildExprText(
        { kind: "balance", token: "ETH", account: literal("vitalik.eth") },
        { ...noEns, chainId: 100 },
      ),
    ).toEqual({
      line: "@balance!(ETH $vitalik)",
      sets: ["set $vitalik @ens(vitalik.eth)"],
    });
    expect(await buildExprText(literal(""), noEns)).toBeNull();
  });
});
