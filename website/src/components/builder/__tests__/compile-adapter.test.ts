import type { PublicClient } from "viem";
import { describe, expect, it } from "vitest";

import { compileAssertionLine, previewSubjectValue } from "../compile-adapter";
import { evml } from "../evml";

// Offline: inline ABIs need no fetch, no command reaches an RPC, and the
// account satisfies @me/@sender.
const T = "0x1234567890123456789012345678901234567890";
const ACCOUNT = "0x0000000000000000000000000000000000000001";
const tag = evml.with({ chainId: 1, account: ACCOUNT });
const EXEC = `exec ${T} transfer(address,uint256) @me 1`;

const compile = (script: string, line: string, sets: string[] = []) =>
  compileAssertionLine(tag, script, line, sets, "post");

describe("compileAssertionLine", () => {
  it("compiles a valid line and hands back the subject operand", async () => {
    const out = await compile(EXEC, `assert ${T}::{totalSupply()(uint256)} > 0`);
    expect(out.ok).toBe(true);
    expect(out.diagnostics).toEqual([]);
    expect(out.subject?.kind).toBe("call");
    expect(out.subject?.cat).toBe("Uint");
    expect(out.expected?.kind).toBe("const");
    expect(out.param).toBeDefined();
    expect(out.transact).toBe(false);
    expect(out.candidate).toBe(`${EXEC}\nassert ${T}::{totalSupply()(uint256)} > 0`);
    expect(out.insertedAt).toBe(2);
  });

  it("attributes a both-constants line to the assertion", async () => {
    const out = await compile(EXEC, "assert 1 == 1");
    expect(out.ok).toBe(false);
    expect(out.diagnostics).toHaveLength(1);
    expect(out.diagnostics[0].message).toMatch(/both sides are build-time constants/);
    expect(out.diagnostics[0].inAssertion).toBe(true);
    expect(out.diagnostics[0].line).toBe(2);
  });

  it("attributes a bare non-boolean subject to the assertion", async () => {
    const out = await compile(EXEC, `assert ${T}::{totalSupply()(uint256)}`);
    expect(out.ok).toBe(false);
    expect(out.diagnostics[0].message).toMatch(/boolean/);
    expect(out.diagnostics[0].inAssertion).toBe(true);
  });

  it("locates a side that fails to compile inside the line", async () => {
    const out = await compile(EXEC, `assert @hash!(${T}::{values()(uint256[])}) == 0x${"00".repeat(32)}`);
    expect(out.ok).toBe(false);
    const [d] = out.diagnostics;
    expect(d.message).toMatch(/string or bytes/);
    expect(d.inAssertion).toBe(true);
    expect(d.line).toBe(2);
    expect(d.col).toBeGreaterThan(0);
  });

  it("adds the loads a helper needs and compiles through them", async () => {
    const out = await compile(EXEC, `assert @bytes.len!(@codeAt!(${T})) > 0`);
    expect(out.ok).toBe(true);
    expect(out.candidate.split("\n")).toEqual([
      "load lang",
      "load contracts",
      EXEC,
      `assert @bytes.len!(@codeAt!(${T})) > 0`,
    ]);
    expect(out.insertedAt).toBe(4);
    expect(out.subject?.cat).toBe("Uint");
  });

  it("never interprets the batch's actions, only the sets the line reaches", async () => {
    // Interpreting the exec line would add a second action; interpreting
    // the unreferenced set would resolve ENS over RPC.
    const script = [
      `set $tok ${T}`,
      "set $other @ens(vitalik.eth)",
      `exec $tok transfer(address,uint256) @me @get(${T} "totalSupply()(uint256)")`,
    ].join("\n");
    const out = await compile(script, "assert $tok::{totalSupply()(uint256)} > 0");
    expect(out.ok).toBe(true);
    expect(out.subject?.cat).toBe("Uint");
  });

  it("reports a validation error with its location in the batch", async () => {
    const out = await compile(`${EXEC}\nassert $missing::{f()(uint256)} > 0`, "assert @chainId! == 1");
    expect(out.ok).toBe(false);
    expect(out.diagnostics.some((d) => d.inAssertion === false && d.line === 3)).toBe(true);
  });
});

describe("previewSubjectValue", () => {
  const client = {
    call: async () => {
      throw new Error("no RPC in tests");
    },
  } as unknown as PublicClient;

  it("reports an incomplete expression", async () => {
    const out = await previewSubjectValue(tag, client, "", { kind: "literal", value: "" }, 1);
    expect(out).toEqual({ kind: "error", message: "The value is incomplete." });
  });

  it("returns a build-time constant as its text without an RPC call", async () => {
    const out = await previewSubjectValue(tag, client, "", { kind: "literal", value: "5" }, 1);
    expect(out).toEqual({ kind: "const", text: "5" });
  });

  it("surfaces the RPC failure of a live value", async () => {
    const out = await previewSubjectValue(tag, client, "", { kind: "chainId" }, 1);
    expect(out).toEqual({ kind: "error", message: "no RPC in tests" });
  });
});
