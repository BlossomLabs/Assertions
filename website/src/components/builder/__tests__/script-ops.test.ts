import { describe, expect, it } from "vitest";

import {
  commandSpans,
  gcScaffolding,
  hasAssertions,
  hoistLoads,
  insertAssertionLines,
  isAssertSpan,
  isHelperLoad,
  removeCommand,
  requiredLoads,
  spanAtLine,
  stripAssertions,
} from "../script-ops";

const T = "0x1234567890123456789012345678901234567890";
const EXEC = `exec $tok transfer(address,uint256) @me 1`;

const MULTI_LINE = [
  "load math",
  `set $tok ${T}`,
  EXEC,
  "assert @min!(",
  "  $tok::balanceOf(@me)",
  "  $tok::totalSupply()",
  ') > 0 "msg"',
].join("\n");

describe("commandSpans", () => {
  it("makes one span of a command that spans several lines", () => {
    const spans = commandSpans(MULTI_LINE);
    expect(spans.map((s) => [s.name, s.start, s.end])).toEqual([
      ["load", 1, 1],
      ["set", 2, 2],
      ["exec", 3, 3],
      ["assert", 4, 7],
    ]);
    const assertion = spanAtLine(spans, 6);
    expect(assertion && isAssertSpan(assertion)).toBe(true);
    expect(assertion?.text).toBe(MULTI_LINE.split("\n").slice(3).join("\n"));
  });

  it("skips blank and comment lines and keeps the module prefix", () => {
    const spans = commandSpans("# note\n\nload sim\nsim:fork (\n  exec $a b()\n)\n");
    expect(spans.map((s) => [s.module, s.name, s.start, s.end])).toEqual([
      [undefined, "load", 3, 3],
      ["sim", "fork", 4, 6],
    ]);
  });

  it("keeps a line the parser rejects as its own span", () => {
    const spans = commandSpans(`${EXEC}\n@nope\n${EXEC}`);
    expect(spans.map((s) => [s.name, s.start, s.node !== undefined])).toEqual([
      ["exec", 1, true],
      ["@nope", 2, false],
      ["exec", 3, true],
    ]);
  });
});

describe("requiredLoads", () => {
  it("derives the owners of the ! faces a line uses", () => {
    expect(requiredLoads(`assert @len!(@filter!(${T}::{v()(uint256[])} @pos!)) > 0`)).toEqual([
      "lang",
    ]);
    expect(requiredLoads(`assert @contracts:codeAt!(${T}) != 0x`)).toEqual([
      "contracts",
    ]);
    expect(requiredLoads(`assert @bytes.len!(@codeAt!(${T})) > 0`)).toEqual([
      "lang",
      "contracts",
    ]);
    expect(requiredLoads("assert @chainId! == 1")).toEqual(["receipts"]);
  });

  it("adds nothing for unknown or std faces, plain helpers and std commands", () => {
    expect(requiredLoads(`assert @nope!(${T}) > 0`)).toEqual([]);
    expect(requiredLoads(`assert @balance!(ETH @me) > @min(1 2)`)).toEqual([]);
    expect(requiredLoads("load lang\nload math")).toEqual([]);
  });

  it("counts module commands and prefixed plain helpers", () => {
    expect(requiredLoads(`sim:fork (\n  exec ${T} f(uint256) @math:min(1 2)\n)`)).toEqual([
      "sim",
      "math",
    ]);
  });

  it("follows import lists for unprefixed names", () => {
    expect(
      requiredLoads(`load lang [@split]\nset $x @split("a b" " " 0)`),
    ).toEqual(["lang"]);
  });
});

describe("isHelperLoad", () => {
  it("recognises the load lines of helper-owning modules", () => {
    expect(isHelperLoad("load lang")).toBe(true);
    expect(isHelperLoad("  load contracts")).toBe(true);
    expect(isHelperLoad("load math [min!]")).toBe(true);
    expect(isHelperLoad("load sim")).toBe(false);
    expect(isHelperLoad("exec lang")).toBe(false);
  });
});

describe("stripAssertions", () => {
  it("drops a multi-line assertion whole, with the load it orphaned", () => {
    expect(hasAssertions(MULTI_LINE)).toBe(true);
    const stripped = stripAssertions(MULTI_LINE);
    expect(stripped).toBe(`set $tok ${T}\n${EXEC}`);
    expect(hasAssertions(stripped)).toBe(false);
  });

  it("keeps a load another command still needs", () => {
    const script = `load math\n${EXEC}\nexec $tok f(uint256) @math:min(1 2)\nassert @min!(1 $tok::totalSupply()) > 0`;
    expect(stripAssertions(script)).toBe(
      `load math\n${EXEC}\nexec $tok f(uint256) @math:min(1 2)`,
    );
  });
});

describe("insertAssertionLines", () => {
  it("adds the loads the line needs after the leading load run", () => {
    const { script, insertedAt } = insertAssertionLines(
      `load safe\n${EXEC}`,
      `assert @bytes.len!(@codeAt!(${T})) > 0`,
      "post",
    );
    expect(script.split("\n")).toEqual([
      "load safe",
      "load lang",
      "load contracts",
      EXEC,
      `assert @bytes.len!(@codeAt!(${T})) > 0`,
    ]);
    expect(insertedAt).toBe(5);
  });

  it("does not duplicate a load already present", () => {
    const { script } = insertAssertionLines(
      `load lang\n${EXEC}`,
      `assert @len!(${T}::{v()(uint256[])}) > 0`,
      "post",
    );
    expect(script.split("\n").filter((l) => l === "load lang")).toHaveLength(1);
  });

  it("places a pre-condition after the header and its pre-assertions", () => {
    const base = [
      "load lang",
      `set $tok ${T}`,
      "assert $tok::paused() == false",
      EXEC,
    ].join("\n");
    const { script, insertedAt } = insertAssertionLines(
      base,
      "assert $tok::owner() == @me",
      "pre",
    );
    expect(script.split("\n")[3]).toBe("assert $tok::owner() == @me");
    expect(insertedAt).toBe(4);
  });

  it("places a post-condition at the end", () => {
    const { script, insertedAt } = insertAssertionLines(
      `${EXEC}\n`,
      "assert $tok::owner() == @me",
      "post",
    );
    expect(script).toBe(`${EXEC}\nassert $tok::owner() == @me`);
    expect(insertedAt).toBe(2);
  });

  it("hoists missing sets to the header end and dedupes present ones", () => {
    const set = "set $vitalik @ens(vitalik.eth)";
    const { script } = insertAssertionLines(
      `${set}\n${EXEC}`,
      "assert $vitalik::owner() == $other",
      "post",
      [set, "set $other @ens(other.eth)"],
    );
    expect(script.split("\n")).toEqual([
      set,
      "set $other @ens(other.eth)",
      EXEC,
      "assert $vitalik::owner() == $other",
    ]);
  });

  it("builds a script from nothing", () => {
    const { script, insertedAt } = insertAssertionLines(
      "",
      "assert @chainId! == 1",
      "pre",
    );
    expect(script).toBe("load receipts\nassert @chainId! == 1");
    expect(insertedAt).toBe(2);
  });
});

describe("removeCommand and gcScaffolding", () => {
  const script = [
    "load lang",
    `set $tok ${T}`,
    "set $cfg 5",
    EXEC,
    `assert @len!($tok::{v()(uint256[])}) > $cfg`,
  ].join("\n");

  it("removes the command at a line and the scaffolding it orphaned", () => {
    expect(removeCommand(script, 5)).toBe(`set $tok ${T}\n${EXEC}`);
  });

  it("removes any line of a multi-line command", () => {
    expect(removeCommand(MULTI_LINE, 6)).toBe(`set $tok ${T}\n${EXEC}`);
  });

  it("keeps sets other commands reference and config variables", () => {
    const withConfig = `set $std:gasPrice 1\n${script}`;
    const cleaned = removeCommand(withConfig, 6);
    expect(cleaned).toBe(`set $std:gasPrice 1\nset $tok ${T}\n${EXEC}`);
  });

  it("reaches a fixpoint through chained sets", () => {
    const chained = `set $a 1\nset $b @num($a + 1)\nset $c $b\n${EXEC}\nset $tok ${T}`;
    expect(gcScaffolding(chained)).toBe(`${EXEC}\nset $tok ${T}`);
  });

  it("leaves a script untouched when the line is outside every command", () => {
    expect(removeCommand(script, 42)).toBe(script);
  });
});

describe("hoistLoads", () => {
  it("pulls every load line out of the block, once", () => {
    const { loads, body } = hoistLoads(
      `load lang\n${EXEC}\nload math\nload lang\nassert @min!(1 $tok::totalSupply()) > 0`,
    );
    expect(loads).toEqual(["load lang", "load math"]);
    expect(body).toBe(`${EXEC}\nassert @min!(1 $tok::totalSupply()) > 0`);
  });
});
